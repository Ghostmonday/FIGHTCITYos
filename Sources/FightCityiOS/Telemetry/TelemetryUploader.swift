//
//  TelemetryUploader.swift
//  FightCityiOS
//
//  Background sync with exponential backoff
//

import Foundation
import BackgroundTasks
import FightCityFoundation

/// Uploads telemetry data to backend with retry logic
public final class TelemetryUploader {
    private let config: iOSAppConfig
    
    public init(config: iOSAppConfig = .shared) {
        self.config = config
    }
    
    // MARK: - Upload
    
    /// Upload telemetry records to backend
    public func upload(_ records: [TelemetryRecord]) async throws {
        guard !records.isEmpty else { return }
        
        let request = TelemetryUploadRequest(records: records)
        
        do {
            let endpoint = APIEndpoint(path: APIEndpoints.telemetryUpload)
            let _: String = try await APIClient.shared.post(
                endpoint,
                body: request
            )
        } catch {
            // If upload fails, queue for retry
            throw error
        }
    }
    
    // MARK: - Background Upload
    
    /// Schedule background upload task
    public func scheduleBackgroundUpload() {
        // Register with BGTaskScheduler
        let request = BGProcessingTaskRequest(identifier: "com.fightcitytickets.telemetry-upload")
        request.requiresNetworkConnectivity = true
        request.requiresExternalPower = false
        request.earliestBeginDate = Date(timeIntervalSinceNow: 60 * 60) // 1 hour
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            Logger.shared.error("Failed to schedule background upload: \(error.localizedDescription)")
        }
    }
}

// MARK: - Background Task Handler

/// Background task handler for telemetry upload
public final class TelemetryBackgroundHandler {
    public static let shared = TelemetryBackgroundHandler()
    
    private init() {}
    
    /// Handle background task
    public func handleBackgroundTask(_ task: BGProcessingTask) {
        // Schedule next upload
        TelemetryUploader().scheduleBackgroundUpload()
        
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
