//
//  OfflineManager.swift
//  FightCityTickets
//
//  Offline queue with exponential backoff
//

import Foundation

/// Manages offline operations with persistent queue and exponential backoff
final class OfflineManager {
    static let shared = OfflineManager()
    
    private let queue: PersistentQueue<OfflineOperation>
    private let config: AppConfig
    private var retryTimer: Timer?
    
    private init() {
        self.config = AppConfig.shared
        self.queue = PersistentQueue(name: "offline_operations", maxSize: config.offlineQueueMaxSize)
        startRetryTimer()
    }
    
    // MARK: - Operation Management
    
    /// Add an operation to the offline queue
    func enqueue(_ operation: OfflineOperation) {
        queue.enqueue(operation)
        attemptSync()
    }
    
    /// Remove an operation from the queue
    func remove(id: UUID) {
        queue.remove(id: id)
    }
    
    /// Clear all queued operations
    func clearQueue() {
        queue.clear()
    }
    
    /// Get all pending operations
    func pendingOperations() -> [OfflineOperation] {
        queue.all()
    }
    
    /// Get count of pending operations
    var pendingCount: Int {
        queue.count
    }
    
    // MARK: - Sync Management
    
    /// Attempt to sync pending operations
    func attemptSync() {
        guard NetworkMonitor.shared.isConnected else { return }
        guard !queue.isEmpty else { return }
        
        Task {
            await syncPendingOperations()
        }
    }
    
    /// Sync all pending operations
    @MainActor
    private func syncPendingOperations() async {
        guard NetworkMonitor.shared.isConnected else { return }
        
        var failedOperations: [OfflineOperation] = []
        
        for operation in queue.all() {
            do {
                try await performOperation(operation)
                queue.remove(id: operation.id)
            } catch {
                // Calculate backoff for this operation
                let backoff = calculateBackoff(attempt: operation.attemptCount)
                operation.attemptCount += 1
                operation.nextRetry = Date().addingTimeInterval(backoff)
                
                if operation.attemptCount >= config.maxRetryAttempts {
                    // Max retries reached, move to failed
                    operation.status = .failed
                    failedOperations.append(operation)
                } else {
                    // Update retry time and requeue
                    queue.update(operation)
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
    
    /// Perform a single operation
    private func performOperation(_ operation: OfflineOperation) async throws {
        switch operation.type {
        case .validateCitation(let request):
            let _: CitationValidationResponse = try await APIClient.shared.post(
                .validateCitation(request),
                body: request
            )
            
        case .submitAppeal(let request):
            let _: String = try await APIClient.shared.post(
                .submitAppeal(request),
                body: request
            )
            
        case .telemetryUpload(let request):
            let _: String = try await APIClient.shared.post(
                .telemetryUpload(request),
                body: request
            )
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
            Task { @MainActor [weak self] in
                self?.attemptSync()
            }
        }
    }
}

// MARK: - Persistent Queue

/// Thread-safe persistent queue for offline operations
struct PersistentQueue<T: Codable & Identifiable> {
    private var items: [T] = []
    private let queue = DispatchQueue(label: "com.fightcitytickets.offlinequeue", attributes: .concurrent)
    private let persistence: FilePersistence<T>
    private let maxSize: Int
    
    init(name: String, maxSize: Int = 100) {
        self.persistence = FilePersistence(name: name)
        self.maxSize = maxSize
        self.items = persistence.load() ?? []
    }
    
    mutating func enqueue(_ item: T) {
        queue.async(flags: .barrier) {
            if self.items.count >= self.maxSize {
                self.items.removeFirst()
            }
            self.items.append(item)
            self.persistence.save(self.items)
        }
    }
    
    mutating func dequeue() -> T? {
        queue.sync {
            guard !items.isEmpty else { return nil }
            let item = items.removeFirst()
            persistence.save(items)
            return item
        }
    }
    
    mutating func remove(id: UUID) {
        queue.async(flags: .barrier) {
            self.items.removeAll { $0.id == id }
            self.persistence.save(self.items)
        }
    }
    
    mutating func update(_ item: T) {
        queue.async(flags: .barrier) {
            if let index = self.items.firstIndex(where: { $0.id == item.id }) {
                self.items[index] = item
                self.persistence.save(self.items)
            }
        }
    }
    
    mutating func clear() {
        queue.async(flags: .barrier) {
            self.items.removeAll()
            self.persistence.save(self.items)
        }
    }
    
    func all() -> [T] {
        queue.sync { items }
    }
    
    var count: Int {
        queue.sync { items.count }
    }
    
    var isEmpty: Bool {
        queue.sync { items.isEmpty }
    }
}

// MARK: - Offline Operation

/// Operation that can be queued for offline execution
struct OfflineOperation: Codable, Identifiable {
    let id: UUID
    let type: OperationType
    var attemptCount: Int
    var nextRetry: Date?
    var status: OperationStatus
    
    enum OperationType: Codable {
        case validateCitation(CitationValidationRequest)
        case submitAppeal(AppealSubmitRequest)
        case telemetryUpload(TelemetryUploadRequest)
    }
    
    enum OperationStatus: String, Codable {
        case pending
        case retrying
        case failed
    }
    
    init(type: OperationType) {
        self.id = UUID()
        self.type = type
        self.attemptCount = 0
        self.nextRetry = nil
        self.status = .pending
    }
}

// MARK: - File Persistence

/// Simple file-based persistence for Codable types
struct FilePersistence<T: Codable> {
    private let fileURL: URL
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    init(name: String) {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.fileURL = documentsPath.appendingPathComponent("\(name).json")
    }
    
    func save(_ items: [T]) {
        do {
            let data = try encoder.encode(items)
            try data.write(to: fileURL)
        } catch {
            print("Persistence save error: \(error)")
        }
    }
    
    func load() -> [T]? {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return nil }
        do {
            let data = try Data(contentsOf: fileURL)
            return try decoder.decode([T].self, from: data)
        } catch {
            print("Persistence load error: \(error)")
            return nil
        }
    }
}

// MARK: - Network Monitor

/// Monitors network connectivity
final class NetworkMonitor: ObservableObject {
    static let shared = NetworkMonitor()
    
    @Published var isConnected = true
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "com.fightcitytickets.networkmonitor")
    
    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
            }
        }
        monitor.start(queue: queue)
    }
}

// MARK: - Notifications

extension Notification.Name {
    static let operationFailed = Notification.Name("operationFailed")
}
