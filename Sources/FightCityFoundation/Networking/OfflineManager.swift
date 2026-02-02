//
//  OfflineManager.swift
//  FightCityFoundation
//
//  Offline queue with exponential backoff
//

import Foundation

/// Protocol for network connectivity checking (platform-agnostic)
public protocol NetworkConnectivityChecker {
    var isConnected: Bool { get }
}

/// Default connectivity checker (always assumes connected - can be overridden)
public struct DefaultConnectivityChecker: NetworkConnectivityChecker {
    public var isConnected: Bool { true }
    
    public init() {}
}

/// Manages offline operations with persistent queue and exponential backoff
public final class OfflineManager {
    public static let shared = OfflineManager()
    
    private var queue: PersistentQueue<OfflineOperation>
    private var connectivityChecker: NetworkConnectivityChecker
    private var retryTimer: Timer?
    
    /// Configuration for offline manager
    public struct Configuration {
        public var maxRetryAttempts: Int
        public var retryBackoffMultiplier: Double
        public var retryMaxBackoff: TimeInterval
        public var offlineQueueMaxSize: Int
        
        public init(
            maxRetryAttempts: Int = 3,
            retryBackoffMultiplier: Double = 2.0,
            retryMaxBackoff: TimeInterval = 300.0,
            offlineQueueMaxSize: Int = 100
        ) {
            self.maxRetryAttempts = maxRetryAttempts
            self.retryBackoffMultiplier = retryBackoffMultiplier
            self.retryMaxBackoff = retryMaxBackoff
            self.offlineQueueMaxSize = offlineQueueMaxSize
        }
    }
    
    private let config: Configuration
    
    public init(
        connectivityChecker: NetworkConnectivityChecker = DefaultConnectivityChecker(),
        configuration: Configuration = Configuration()
    ) {
        self.connectivityChecker = connectivityChecker
        self.config = configuration
        self.queue = PersistentQueue(name: "offline_operations", maxSize: configuration.offlineQueueMaxSize)
        startRetryTimer()
    }
    
    // MARK: - Operation Management
    
    /// Add an operation to the offline queue
    public func enqueue(_ operation: OfflineOperation) {
        queue.enqueue(operation)
        attemptSync()
    }
    
    /// Remove an operation from the queue
    public func remove(id: UUID) {
        queue.remove(id: id)
    }
    
    /// Clear all queued operations
    public func clearQueue() {
        queue.clear()
    }
    
    /// Get all pending operations
    public func pendingOperations() -> [OfflineOperation] {
        queue.all()
    }
    
    /// Get count of pending operations
    public var pendingCount: Int {
        queue.count
    }
    
    /// Check if queue has pending operations
    public var hasPendingOperations: Bool {
        !queue.isEmpty
    }
    
    // MARK: - Sync Management
    
    /// Attempt to sync pending operations
    public func attemptSync() {
        guard connectivityChecker.isConnected else { return }
        guard !queue.isEmpty else { return }
        
        syncPendingOperations()
    }
    
    /// Sync all pending operations
    private func syncPendingOperations() {
        guard connectivityChecker.isConnected else { return }
        
        Task {
            var failedOperations: [OfflineOperation] = []
            
            for operation in queue.all() {
                do {
                    try await performOperation(operation)
                    queue.remove(id: operation.id)
                } catch {
                    // Calculate backoff for this operation
                    let backoff = calculateBackoff(attempt: operation.attemptCount)
                    var updatedOperation = operation
                    updatedOperation.attemptCount += 1
                    updatedOperation.nextRetry = Date().addingTimeInterval(backoff)
                    
                    if updatedOperation.attemptCount >= config.maxRetryAttempts {
                        // Max retries reached, move to failed
                        updatedOperation.status = .failed
                        failedOperations.append(updatedOperation)
                    } else {
                        // Update retry time and requeue
                        updatedOperation.status = .retrying
                        queue.update(updatedOperation)
                    }
                }
            }
            
            // Handle permanently failed operations
            for op in failedOperations {
                queue.remove(id: op.id)
                NotificationCenter.default.post(
                    name: .operationFailed,
                    object: nil,
                    userInfo: ["operation": op]
                )
            }
        }
    }
    
    /// Perform a single operation (throws on failure)
    private func performOperation(_ operation: OfflineOperation) async throws {
        switch operation.type {
        case .validateCitation(let request):
            try Task.checkCancellation()
            let _: CitationValidationResponse = try await APIClient.shared.post(.validateCitation(request), body: request)
            
        case .submitAppeal(let request):
            try Task.checkCancellation()
            let _: String = try await APIClient.shared.post(.submitAppeal(request), body: request)
            
        case .telemetryUpload(let request):
            try Task.checkCancellation()
            let _: String = try await APIClient.shared.post(.telemetryUpload(request), body: request)
        }
    }
    
    /// Calculate exponential backoff
    private func calculateBackoff(attempt: Int) -> TimeInterval {
        let baseDelay = config.retryBackoffMultiplier
        let maxDelay = config.retryMaxBackoff
        let delay = pow(baseDelay, Double(attempt))
        return min(delay, maxDelay)
    }
    
    // MARK: - Retry Timer
    
    private func startRetryTimer() {
        retryTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.attemptSync()
        }
    }
    
    /// Stop the retry timer and clean up
    public func stopRetryTimer() {
        retryTimer?.invalidate()
        retryTimer = nil
    }
    
    deinit {
        retryTimer?.invalidate()
    }
}

// MARK: - Persistent Queue

/// Thread-safe persistent queue for offline operations
public final class PersistentQueue<T: Codable & Identifiable> where T.ID == UUID {
    private var items: [T] = []
    private let queue = DispatchQueue(label: "com.fightcitytickets.offlinequeue", attributes: .concurrent)
    private let persistence: FilePersistence<T>
    private let maxSize: Int
    
    public init(name: String, maxSize: Int = 100) {
        self.persistence = FilePersistence(name: name)
        self.maxSize = maxSize
        self.items = persistence.load() ?? []
    }
    
    public func enqueue(_ item: T) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            if self.items.count >= self.maxSize {
                self.items.removeFirst()
            }
            self.items.append(item)
            self.persistence.save(self.items)
        }
    }
    
    public func dequeue() -> T? {
        queue.sync {
            guard !items.isEmpty else { return nil }
            let item = items.removeFirst()
            persistence.save(items)
            return item
        }
    }
    
    public func remove(id: UUID) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            self.items.removeAll { $0.id == id }
            self.persistence.save(self.items)
        }
    }
    
    public func update(_ item: T) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            if let index = self.items.firstIndex(where: { $0.id == item.id }) {
                self.items[index] = item
                self.persistence.save(self.items)
            }
        }
    }
    
    public func clear() {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            self.items.removeAll()
            self.persistence.save(self.items)
        }
    }
    
    public func all() -> [T] {
        queue.sync { items }
    }
    
    public var count: Int {
        queue.sync { items.count }
    }
    
    public var isEmpty: Bool {
        queue.sync { items.isEmpty }
    }
}

// MARK: - Offline Operation

/// Operation that can be queued for offline execution
public struct OfflineOperation: Codable, Identifiable {
    public let id: UUID
    public let type: OperationType
    public var attemptCount: Int
    public var nextRetry: Date?
    public var status: OperationStatus
    
    public enum OperationType: Codable {
        case validateCitation(CitationValidationRequest)
        case submitAppeal(AppealSubmitRequest)
        case telemetryUpload(TelemetryUploadRequest)
    }
    
    public enum OperationStatus: String, Codable {
        case pending
        case retrying
        case failed
    }
    
    public init(type: OperationType) {
        self.id = UUID()
        self.type = type
        self.attemptCount = 0
        self.nextRetry = nil
        self.status = .pending
    }
}

// MARK: - File Persistence

/// Simple file-based persistence for Codable types
public struct FilePersistence<T: Codable> {
    private let fileURL: URL
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    public init(name: String) {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.fileURL = documentsPath.appendingPathComponent("\(name).json")
    }
    
    public func save(_ items: [T]) {
        do {
            let data = try encoder.encode(items)
            try data.write(to: fileURL)
        } catch {
            // TODO: Replace with Logger.shared.error("Persistence save error", error: error)
            // AUDIT: Replace print() with Logger to avoid leaking file system details in release builds.
            // Consider surfacing a non-fatal warning if persistence fails (data loss risk).
            print("Persistence save error: \(error)")
        }
    }
    
    public func load() -> [T]? {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return nil }
        do {
            let data = try Data(contentsOf: fileURL)
            return try decoder.decode([T].self, from: data)
        } catch {
            // TODO: Replace with Logger.shared.error("Persistence load error", error: error)
            // AUDIT: Replace print() with Logger; also consider resetting corrupted data to recover
            // gracefully instead of repeatedly failing to decode.
            print("Persistence load error: \(error)")
            return nil
        }
    }
}

// MARK: - Notifications

public extension Notification.Name {
    static let operationFailed = Notification.Name("operationFailed")
}
