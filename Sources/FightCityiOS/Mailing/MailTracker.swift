//
//  MailTracker.swift
//  FightCityiOS
//
//  Tracks certified mail status for citations
//

import Foundation
import FightCityFoundation

/// Tracks certified mail status for citations
@MainActor
public final class MailTracker: ObservableObject {
    public static let shared = MailTracker()
    
    @Published public var trackedMailings: [String: MailingStatus] = [:] // citationId -> status
    @Published public var trackingEvents: [String: [LobTrackingEvent]] = [:] // citationId -> events
    
    private var pollingTasks: [String: Task<Void, Never>] = [:] // citationId -> polling task
    
    private init() {}
    
    /// Updates the mailing status for a citation
    ///
    /// - Parameters:
    ///   - citationId: The citation ID
    ///   - status: The new mailing status
    public func updateStatus(citationId: String, status: MailingStatus) {
        trackedMailings[citationId] = status
    }
    
    /// Gets the mailing status for a citation
    ///
    /// - Parameter citationId: The citation ID
    /// - Returns: The mailing status, or nil if not tracked
    public func getStatus(for citationId: String) -> MailingStatus? {
        return trackedMailings[citationId]
    }
    
    /// Starts tracking a letter and begins polling for status updates
    ///
    /// - Parameters:
    ///   - citationId: The citation ID
    ///   - letterId: The Lob letter ID
    public func startTracking(citationId: String, letterId: String) {
        // Cancel any existing polling task for this citation
        pollingTasks[citationId]?.cancel()
        
        // Start new polling task
        let task = Task {
            await pollStatus(letterId: letterId, citationId: citationId)
        }
        
        pollingTasks[citationId] = task
    }
    
    /// Stops tracking a citation
    ///
    /// - Parameter citationId: The citation ID
    public func stopTracking(citationId: String) {
        pollingTasks[citationId]?.cancel()
        pollingTasks.removeValue(forKey: citationId)
    }
    
    /// Polls backend proxy for updated mail status
    ///
    /// Polls every 5 minutes for up to 30 days (typical delivery window)
    ///
    /// - Parameters:
    ///   - letterId: The Lob letter ID
    ///   - citationId: The citation ID
    private func pollStatus(letterId: String, citationId: String) async {
        // Poll every 5 minutes for 30 days (typical delivery window)
        // 30 days * 24 hours * 12 (5-min intervals) = 8640 polls
        // AUDIT: Long-lived polling should be managed via background tasks or server-side webhooks.
        // A server-driven status update is more reliable and battery-friendly for App Store review.
        for _ in 0..<8640 {
            // Check if task was cancelled
            if Task.isCancelled {
                break
            }
            
            do {
                let response = try await LobService.shared.checkLetterStatus(letterId)
                
                // Parse tracking events to determine status
                let status = parseStatus(from: response.trackingEvents ?? [])
                
                await MainActor.run {
                    self.trackedMailings[citationId] = status
                    self.trackingEvents[citationId] = response.trackingEvents
                }
                
                // Stop polling if delivered or returned
                if status == .delivered || status == .returned {
                    pollingTasks.removeValue(forKey: citationId)
                    break
                }
                
                // Wait 5 minutes before next poll
                try await Task.sleep(nanoseconds: 5 * 60 * 1_000_000_000)
            } catch {
                Logger.shared.error("Tracking poll failed: \(error.localizedDescription)")
                // Continue polling even on error (might be temporary network issue)
                do {
                    try await Task.sleep(nanoseconds: 5 * 60 * 1_000_000_000)
                } catch {
                    // Task was cancelled
                    break
                }
            }
        }
    }
    
    /// Parses tracking events to determine mailing status
    ///
    /// - Parameter events: Array of tracking events from Lob API
    /// - Returns: MailingStatus enum value
    private func parseStatus(from events: [LobTrackingEvent]) -> MailingStatus {
        let eventNames = events.map { $0.name }
        
        if eventNames.contains("letter.certified.delivered") {
            return .delivered
        } else if eventNames.contains("letter.returned_to_sender") {
            return .returned
        } else if eventNames.contains("letter.in_transit") {
            return .inTransit
        } else if eventNames.contains("letter.certified.mailed") {
            return .mailed
        } else {
            return .processing
        }
    }
    
    /// Polls Lob API for updated mail status (manual poll)
    ///
    /// - Parameter letterId: The Lob letter ID
    /// - Returns: Updated mailing status
    public func pollStatus(letterId: String) async throws -> MailingStatus {
        let response = try await LobService.shared.checkLetterStatus(letterId)
        return parseStatus(from: response.trackingEvents ?? [])
    }
}
