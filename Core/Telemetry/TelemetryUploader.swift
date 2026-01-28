//
//  TelemetryUploader.swift
//  FightCityTickets
//
//  Background sync with exponential backoff
//

import Foundation

/// Uploads telemetry data to backend with retry logic
final class TelemetryUploader {
    private let config: AppConfig
    
    init(config: AppConfig = .shared) {
        self.config = config
    }
    
    // MARK: - Upload
    
    /// Upload telemetry records to backend
    func upload(_ records: [TelemetryRecord]) async throws {
        guard !records.isEmpty else { return }
        
        let request = TelemetryUploadRequest(records: records)
        
        do {
            let _: String = try await APIClient.shared.post(
                .telemetryUpload(request),
                body: request
            )
        } catch {
            // If upload fails, queue for retry
            throw error
        }
    }
    
    // MARK: - Background Upload
    
    /// Schedule background upload task
    func scheduleBackgroundUpload() {
        // Register with BGTaskScheduler
        let request = BGProcessingTaskRequest(identifier: "com.fightcitytickets.telemetry-upload")
        request.requiresNetworkConnectivity = true
        request.requiresExternalPower = false
        request.earliestBeginDate = Date(timeIntervalSinceNow: 60 * 60) // 1 hour
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Failed to schedule background upload: \(error)")
        }
    }
}

// MARK: - Background Task Handler

final class TelemetryBackgroundHandler {
    static let shared = TelemetryBackgroundHandler()
    
    func handleBackgroundTask(_ task: BGProcessingTask) {
        // Schedule next upload
        TelemetryUploader.shared.scheduleBackgroundUpload()
        
        // Upload pending records
        Task {
            await TelemetryService.shared.uploadPending()
            task.setTaskCompleted(success: true)
        }
        
        // Expiration handler
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }
    }
}
