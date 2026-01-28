//
//  TelemetryService.swift
//  FightCityTickets
//
//  Batch telemetry collection with opt-in privacy
//

import Foundation

/// Service for collecting and managing telemetry data (opt-in only)
@MainActor
final class TelemetryService: ObservableObject {
    static let shared = TelemetryService()
    
    @Published var isEnabled = false
    @Published var pendingCount = 0
    @Published var lastUploadDate: Date?
    
    private let storage: TelemetryStorage
    private let uploader: TelemetryUploader
    private let config: AppConfig
    
    private init() {
        self.storage = TelemetryStorage()
        self.uploader = TelemetryUploader()
        self.config = AppConfig.shared
        self.isEnabled = config.telemetryEnabled
    }
    
    // MARK: - User Consent
    
    /// Request user opt-in for telemetry
    func requestOptIn() async -> Bool {
        // Show privacy dialog
        // Return true if user accepts
        return await withCheckedContinuation { continuation in
            // In real implementation, this would show a dialog
            continuation.resume(returning: false)
        }
    }
    
    /// Enable telemetry with user consent
    func enable() {
        guard config.telemetryEnabled else { return }
        isEnabled = true
        uploadPendingIfNeeded()
    }
    
    /// Disable telemetry
    func disable() {
        isEnabled = false
    }
    
    // MARK: - Recording
    
    /// Record a telemetry event
    func record(
        captureResult: CaptureResult,
        city: String,
        userCorrection: String? = nil
    ) {
        guard isEnabled else { return }
        
        // Hash images for privacy (never store actual images)
        let originalHash = hashImage(captureResult.originalImageData)
        let croppedHash = hashImage(captureResult.croppedImageData)
        
        let record = TelemetryRecord.create(
            from: captureResult,
            city: city,
            originalHash: originalHash,
            croppedHash: croppedHash,
            userCorrection: userCorrection
        )
        
        storage.save(record)
        pendingCount = storage.pendingCount()
        
        uploadPendingIfNeeded()
    }
    
    // MARK: - Upload
    
    /// Upload pending telemetry if threshold reached
    func uploadPendingIfNeeded() {
        guard isEnabled else { return }
        
        let pending = storage.pendingRecords()
        
        if pending.count >= config.telemetryBatchSize ||
           (pending.count > 0 && needsImmediateUpload()) {
            Task {
                await upload(records: pending)
            }
        }
    }
    
    /// Force upload pending records
    func uploadPending() async {
        let pending = storage.pendingRecords()
        await upload(records: pending)
    }
    
    private func upload(records: [TelemetryRecord]) async {
        do {
            try await uploader.upload(records)
            storage.markAsUploaded(records)
            pendingCount = storage.pendingCount()
            lastUploadDate = Date()
        } catch {
            print("Telemetry upload failed: \(error)")
        }
    }
    
    private func needsImmediateUpload() -> Bool {
        guard let lastUpload = lastUploadDate else { return true }
        return Date().timeIntervalSince(lastUpload) > config.telemetryMaxAge
    }
    
    // MARK: - Privacy
    
    /// Hash image data for privacy (one-way hash)
    private func hashImage(_ data: Data?) -> String {
        guard let data = data else { return "" }
        var hash = [UInt8](repeating: 0, count: 32)
        data.withUnsafeBytes { buffer in
            _ = CC_SHA256(buffer.baseAddress, CC_LONG(buffer.count), &hash)
        }
        return hash.map { String(format: "%02x", $0) }.joined()
    }
    
    // MARK: - Stats
    
    /// Get telemetry statistics
    func getStats() -> TelemetryStats {
        TelemetryStats(
            totalRecords: storage.totalCount(),
            pendingCount: storage.pendingCount(),
            lastUploadDate: lastUploadDate,
            isEnabled: isEnabled
        )
    }
    
    /// Clear all telemetry data
    func clearAll() {
        storage.clearAll()
        pendingCount = 0
    }
}

// MARK: - Telemetry Stats

struct TelemetryStats {
    let totalRecords: Int
    let pendingCount: Int
    let lastUploadDate: Date?
    let isEnabled: Bool
}

// MARK: - Import CommonCrypto

import CommonCrypto
