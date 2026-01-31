//
//  TelemetryStorage.swift
//  FightCityFoundation
//
//  Secure local storage for telemetry data
//

import Foundation

/// Secure storage for telemetry records
public final class TelemetryStorage {
    private let persistence: FilePersistence<TelemetryRecord>
    private let uploadQueue: FilePersistence<UploadedRecord>
    
    private let maxRecords = 1000
    
    public init() {
        self.persistence = FilePersistence(name: "telemetry_pending")
        self.uploadQueue = FilePersistence(name: "telemetry_uploaded")
    }
    
    // MARK: - Save
    
    /// Save a telemetry record
    public func save(_ record: TelemetryRecord) {
        var records = persistence.load() ?? []
        
        // Remove old records if exceeding max
        if records.count >= maxRecords {
            records.removeFirst(records.count - maxRecords + 1)
        }
        
        records.append(record)
        persistence.save(records)
    }
    
    // MARK: - Query
    
    /// Get all pending records
    public func pendingRecords() -> [TelemetryRecord] {
        persistence.load() ?? []
    }
    
    /// Get count of pending records
    public func pendingCount() -> Int {
        pendingRecords().count
    }
    
    /// Get total records (including uploaded)
    public func totalCount() -> Int {
        let pending = pendingRecords().count
        let uploaded = (uploadQueue.load() ?? []).count
        return pending + uploaded
    }
    
    // MARK: - Update
    
    /// Mark records as uploaded
    public func markAsUploaded(_ records: [TelemetryRecord]) {
        var existing = uploadQueue.load() ?? []
        
        for record in records {
            let uploaded = UploadedRecord(id: record.id, timestamp: Date())
            existing.append(uploaded)
        }
        
        // Keep only recent uploads (last 100)
        if existing.count > 100 {
            existing.removeFirst(existing.count - 100)
        }
        
        uploadQueue.save(existing)
        
        // Remove from pending
        var pending = persistence.load() ?? []
        let uploadedIds = Set(records.map { $0.id })
        pending.removeAll { uploadedIds.contains($0.id) }
        persistence.save(pending)
    }
    
    // MARK: - Clear
    
    /// Clear all telemetry data
    public func clearAll() {
        persistence.save([])
        uploadQueue.save([])
    }
    
    /// Remove old records
    public func removeOldRecords(olderThan date: Date) {
        var records = pendingRecords()
        records.removeAll { $0.timestamp < date }
        persistence.save(records)
    }
}

// MARK: - Uploaded Record

public struct UploadedRecord: Codable {
    public let id: String
    public let timestamp: Date
}

// MARK: - Secure Storage

extension TelemetryStorage {
    /// Encrypt sensitive data before storage
    private func encrypt(_ data: Data) -> Data {
        // In production, use proper encryption
        // This is a placeholder for demo purposes
        return data
    }
    
    /// Decrypt data after retrieval
    private func decrypt(_ data: Data) -> Data {
        // In production, use proper decryption
        return data
    }
}
