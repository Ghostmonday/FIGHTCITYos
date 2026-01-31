//
//  TelemetryService.swift
//  FightCityiOS
//
//  Batch telemetry collection with opt-in privacy
//

import Foundation
import CommonCrypto
import UIKit
import FightCityFoundation

/// Service for collecting and managing telemetry data (opt-in only)
@MainActor
public final class TelemetryService: ObservableObject {
    public static let shared = TelemetryService()
    
    @Published public var isEnabled = false
    @Published public var pendingCount = 0
    @Published public var lastUploadDate: Date?
    
    private let storage: TelemetryStorage
    private let uploader: TelemetryUploader
    private let config: iOSAppConfig
    
    private init() {
        self.storage = TelemetryStorage()
        self.uploader = TelemetryUploader()
        self.config = iOSAppConfig.shared
        self.isEnabled = config.telemetryEnabled
    }
    
    // MARK: - User Consent
    
    /// Request user opt-in for telemetry
    public func requestOptIn() async -> Bool {
        // Show privacy dialog
        // Return true if user accepts
        return await withCheckedContinuation { continuation in
            // In real implementation, this would show a dialog
            continuation.resume(returning: false)
        }
    }
    
    /// Enable telemetry with user consent
    public func enable() {
        guard config.telemetryEnabled else { return }
        isEnabled = true
        uploadPendingIfNeeded()
    }
    
    /// Disable telemetry
    public func disable() {
        isEnabled = false
    }
    
    // MARK: - Recording
    
    /// Record a telemetry event
    public func record(
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
    public func uploadPendingIfNeeded() {
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
    public func uploadPending() async {
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
            // TODO: Replace with Logger.shared.error("Telemetry upload failed", error: error)
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
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes { buffer in
            _ = CC_SHA256(buffer.baseAddress, CC_LONG(buffer.count), &hash)
        }
        return hash.map { String(format: "%02x", $0) }.joined()
    }
    
    // MARK: - Stats
    
    /// Get telemetry statistics
    public func getStats() -> TelemetryStats {
        TelemetryStats(
            totalRecords: storage.totalCount(),
            pendingCount: storage.pendingCount(),
            lastUploadDate: lastUploadDate,
            isEnabled: isEnabled
        )
    }
    
    /// Clear all telemetry data
    public func clearAll() {
        storage.clearAll()
        pendingCount = 0
    }
}

// MARK: - Telemetry Stats

public struct TelemetryStats {
    public let totalRecords: Int
    public let pendingCount: Int
    public let lastUploadDate: Date?
    public let isEnabled: Bool
}

// MARK: - TelemetryRecord iOS Extension

import Vision

extension TelemetryRecord {
    /// Create TelemetryRecord from CaptureResult with iOS device info
    public static func create(
        from result: CaptureResult,
        city: String,
        originalHash: String,
        croppedHash: String,
        userCorrection: String?
    ) -> TelemetryRecord {
        TelemetryRecord(
            city: city,
            timestamp: result.capturedAt,
            deviceModel: UIDevice.current.model,
            iOSVersion: UIDevice.current.systemVersion,
            originalImageHash: originalHash,
            croppedImageHash: croppedHash,
            ocrOutput: result.rawText,
            userCorrection: userCorrection,
            confidence: result.confidence,
            processingTimeMs: result.processingTimeMs
        )
    }
}
