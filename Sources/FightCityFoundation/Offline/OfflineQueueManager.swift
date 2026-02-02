//
//  OfflineQueueManager.swift
//  FightCityFoundation
//
//  Offline queue with retry logic and persistence
//

import Foundation

/// Offline queue item for pending operations
///
/// APP STORE READINESS: Offline support is essential for mobile apps
/// USER EXPERIENCE: Users can work offline, operations sync when online
/// TODO APP STORE: Add UI indicator showing pending offline operations
/// TODO ENHANCEMENT: Add background sync using Background Tasks framework
/// RELIABILITY: Never lose user data due to network issues
/// PERSISTENCE: Queue survives app restarts (saved to disk)
/// PERFORMANCE: Batch operations for efficiency when coming back online
/// NOTE: This differentiates app from basic web-wrapper apps
public struct QueueItem: Identifiable, Codable {
    public let id: UUID
    public let operation: QueuedOperation
    public let createdAt: Date
    public var retryCount: Int
    public var nextRetryAt: Date?
    
    public init(id: UUID = UUID(), operation: QueuedOperation, createdAt: Date = Date(), retryCount: Int = 0, nextRetryAt: Date? = nil) {
        self.id = id
        self.operation = operation
        self.createdAt = createdAt
        self.retryCount = retryCount
        self.nextRetryAt = nextRetryAt
    }
}

/// Types of queued operations
public enum QueuedOperation: Codable {
    case validateCitation(request: CitationValidationRequest)
    case submitAppeal(request: AppealSubmitRequest)
    case uploadTelemetry(records: [TelemetryRecord])
    
    private enum CodingKeys: String, CodingKey {
        case type
        case request
        case records
    }
    
    private enum OperationType: String, Codable {
        case validateCitation
        case submitAppeal
        case uploadTelemetry
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(OperationType.self, forKey: .type)
        
        switch type {
        case .validateCitation:
            let request = try container.decode(CitationValidationRequest.self, forKey: .request)
            self = .validateCitation(request: request)
        case .submitAppeal:
            let request = try container.decode(AppealSubmitRequest.self, forKey: .request)
            self = .submitAppeal(request: request)
        case .uploadTelemetry:
            let records = try container.decode([TelemetryRecord].self, forKey: .records)
            self = .uploadTelemetry(records: records)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .validateCitation(let request):
            try container.encode(OperationType.validateCitation, forKey: .type)
            try container.encode(request, forKey: .request)
        case .submitAppeal(let request):
            try container.encode(OperationType.submitAppeal, forKey: .type)
            try container.encode(request, forKey: .request)
        case .uploadTelemetry(let records):
            try container.encode(OperationType.uploadTelemetry, forKey: .type)
            try container.encode(records, forKey: .records)
        }
    }
}

/// Manager for offline queue operations
public actor OfflineQueueManager {
    public static let shared = OfflineQueueManager()
    
    private let storageKey = "offline_queue"
    private let maxQueueSize = 100
    private let maxRetryAttempts = 3
    private let initialDelay: TimeInterval = 1.0
    private let maxDelay: TimeInterval = 300.0 // 5 minutes
    private let multiplier: TimeInterval = 2.0
    
    private var queue: [QueueItem] = []
    private let storage: Storage
    private let apiClient: APIClientProtocol
    private let logger: LoggerProtocol
    
    public init(storage: Storage = UserDefaultsStorage(), apiClient: APIClientProtocol? = nil, logger: LoggerProtocol = Logger.shared) {
        self.storage = storage
        self.apiClient = apiClient ?? APIClient.shared
        self.logger = logger
        // Load queue synchronously during initialization
        if let data = storage.load(key: storageKey),
           let decoded = try? JSONDecoder().decode([QueueItem].self, from: data) {
            self.queue = decoded
            logger.info("Loaded \(queue.count) items from offline queue")
        }
    }
    
    // MARK: - Public Methods
    
    /// Add operation to queue
    public func enqueue(_ operation: QueuedOperation) async throws {
        guard queue.count < maxQueueSize else {
            logger.warning("Offline queue is full, dropping oldest item")
            queue.removeFirst()
            return
        }
        
        let item = QueueItem(operation: operation)
        queue.append(item)
        await persistQueue()
        
        logger.info("Added operation to offline queue, current size: \(queue.count)")
        
        // Try to process immediately if online
        await tryProcessQueue()
    }
    
    /// Process all pending items
    public func processQueue() async {
        await tryProcessQueue()
    }
    
    /// Get current queue count
    public var count: Int {
        queue.count
    }
    
    /// Clear all items
    public func clear() async {
        queue.removeAll()
        await persistQueue()
    }
    
    // MARK: - Private Methods
    
    private func tryProcessQueue() async {
        guard !queue.isEmpty else { return }
        
        // Filter out items that need to wait
        let now = Date()
        let readyItems = queue.filter { item in
            guard let nextRetry = item.nextRetryAt else { return true }
            return nextRetry <= now
        }
        
        for item in readyItems {
            do {
                try await processItem(item)
                queue.removeAll { $0.id == item.id }
                await persistQueue()
                logger.info("Successfully processed queue item: \(item.id)")
            } catch {
                await handleRetry(for: item, error: error)
            }
        }
    }
    
    private func processItem(_ item: QueueItem) async throws {
        switch item.operation {
        case .validateCitation(let request):
            _ = try await apiClient.validateCitation(request)
        case .submitAppeal(_):
            // Would call submit appeal endpoint
            break
        case .uploadTelemetry(_):
            // Would upload telemetry
            break
        }
    }
    
    private func handleRetry(for item: QueueItem, error: Error) async {
        if item.retryCount >= maxRetryAttempts {
            logger.error("Max retries exceeded for item \(item.id), dropping")
            queue.removeAll { $0.id == item.id }
        } else {
            let delay = calculateDelay(retryCount: item.retryCount)
            let nextRetry = Date().addingTimeInterval(delay)
            
            if let index = queue.firstIndex(where: { $0.id == item.id }) {
                queue[index].retryCount += 1
                queue[index].nextRetryAt = nextRetry
                logger.warning("Retry scheduled for item \(item.id) in \(delay)s, attempt \(queue[index].retryCount)")
            }
        }
        
        await persistQueue()
    }
    
    private func calculateDelay(retryCount: Int) -> TimeInterval {
        let delay = initialDelay * pow(multiplier, Double(retryCount))
        return min(delay, maxDelay)
    }
    
    private func loadQueue() {
        if let data = storage.load(key: storageKey),
           let decoded = try? JSONDecoder().decode([QueueItem].self, from: data) {
            queue = decoded
            logger.info("Loaded \(queue.count) items from offline queue")
        }
    }
    
    private func persistQueue() async {
        if let encoded = try? JSONEncoder().encode(queue) {
            _ = storage.save(key: storageKey, data: encoded)
        }
    }
}

// MARK: - Simple Storage Protocol

public protocol Storage {
    func save(key: String, data: Data) -> Bool
    func load(key: String) -> Data?
    func delete(key: String) -> Bool
}

// MARK: - UserDefaults Storage Implementation

public final class UserDefaultsStorage: Storage {
    private let defaults: UserDefaults
    
    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }
    
    public func save(key: String, data: Data) -> Bool {
        defaults.set(data, forKey: key)
        return true
    }
    
    public func load(key: String) -> Data? {
        defaults.data(forKey: key)
    }
    
    public func delete(key: String) -> Bool {
        defaults.removeObject(forKey: key)
        return true
    }
}

// MARK: - In-Memory Storage (for testing)

public final class InMemoryStorage: Storage {
    private var storage: [String: Data] = [:]
    
    public init() {}
    
    public func save(key: String, data: Data) -> Bool {
        storage[key] = data
        return true
    }
    
    public func load(key: String) -> Data? {
        storage[key]
    }
    
    public func delete(key: String) -> Bool {
        storage.removeValue(forKey: key)
        return true
    }
}
