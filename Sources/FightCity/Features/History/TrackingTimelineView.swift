//
//  TrackingTimelineView.swift
//  FightCity
//
//  Reusable timeline component for displaying mail tracking events
//

import SwiftUI
import FightCityFoundation
import FightCityiOS

private struct PaddingModifier: ViewModifier {
    func body(content: Content) -> some View {
        content.padding()
    }
}

public struct TrackingTimelineView: View {
    let events: [LobTrackingEvent]
    let citationId: String
    
    @State private var isRefreshing = false
    @ObservedObject private var mailTracker = MailTracker.shared
    
    public init(events: [LobTrackingEvent], citationId: String) {
        self.events = events
        self.citationId = citationId
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Tracking Timeline")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(AppColors.textTertiary)
                    .textCase(.uppercase)
                    .tracking(1)
                
                Spacer()
                
                Button(action: {
                    refreshTracking()
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.gold)
                }
                .disabled(isRefreshing)
            }
            
            if events.isEmpty {
                emptyState
            } else {
                timelineContent
            }
        }
        .padding(16)
        .background(AppColors.surface)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppColors.glassBorder, lineWidth: 1)
        )
    }
    
    // MARK: - Timeline Content
    
    private var timelineContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(events.enumerated()), id: \.offset) { index, event in
                TimelineRow(
                    event: event,
                    isLast: index == events.count - 1,
                    isHighlighted: event.name == "letter.certified.return_receipt_received"
                )
            }
        }
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "clock.fill")
                .font(.system(size: 32))
                .foregroundColor(AppColors.textTertiary)
            
            Text("No tracking events yet")
                .font(.system(size: 14))
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }
    
    // MARK: - Actions
    
    private func refreshTracking() {
        isRefreshing = true
        Task {
            // Get letter ID from citation if available
            // For now, just refresh from MailTracker
            if let _ = mailTracker.trackedMailings[citationId] {
                // Would need letterId to refresh - this is a placeholder
                // In real implementation, citation would have lobLetterId
            }
            
            await MainActor.run {
                isRefreshing = false
            }
        }
    }
}

// MARK: - Timeline Row

private struct TimelineRow: View {
    let event: LobTrackingEvent
    let isLast: Bool
    let isHighlighted: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Timeline indicator
            VStack(spacing: 0) {
                Circle()
                    .fill(isHighlighted ? AppColors.success : AppColors.gold)
                    .frame(width: 12, height: 12)
                    .overlay(
                        Circle()
                            .stroke(AppColors.background, lineWidth: 2)
                    )
                
                if !isLast {
                    Rectangle()
                        .fill(AppColors.glassBorder)
                        .frame(width: 2)
                        .frame(maxHeight: .infinity)
                }
            }
            .frame(width: 12)
            
            // Event content
            VStack(alignment: .leading, spacing: 4) {
                Text(eventDisplayName(event.name))
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(isHighlighted ? AppColors.success : .white)
                
                if let location = event.location {
                    Text(location)
                        .font(.system(size: 13))
                        .foregroundColor(AppColors.textSecondary)
                }
                
                Text(formatDate(event.time))
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.textTertiary)
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
    
    private func eventDisplayName(_ eventName: String) -> String {
        switch eventName {
        case "letter.created":
            return "Letter Created"
        case "letter.certified.mailed":
            return "Certified Mail Sent"
        case "letter.in_transit":
            return "In Transit"
        case "letter.certified.delivered":
            return "Delivered"
        case "letter.certified.return_receipt_received":
            return "Signature Received"
        case "letter.returned_to_sender":
            return "Returned to Sender"
        default:
            return eventName.replacingOccurrences(of: "letter.", with: "")
                .replacingOccurrences(of: ".", with: " ")
                .capitalized
        }
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let date = formatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .medium
            displayFormatter.timeStyle = .short
            return displayFormatter.string(from: date)
        }
        
        // Fallback: try without fractional seconds
        formatter.formatOptions = [.withInternetDateTime]
        if let date = formatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .medium
            displayFormatter.timeStyle = .short
            return displayFormatter.string(from: date)
        }
        
        return dateString
    }
}

// MARK: - Previews

#if DEBUG
struct TrackingTimelineView_Previews: PreviewProvider {
    static var previews: some View {
        TrackingTimelineView(
            events: [
                LobTrackingEvent(name: "letter.certified.mailed", time: "2026-01-31T10:00:00Z", location: "San Francisco, CA", details: nil),
                LobTrackingEvent(name: "letter.in_transit", time: "2026-01-31T14:00:00Z", location: "Oakland, CA", details: nil),
                LobTrackingEvent(name: "letter.certified.delivered", time: "2026-02-01T09:00:00Z", location: "Los Angeles, CA", details: nil),
                LobTrackingEvent(name: "letter.certified.return_receipt_received", time: "2026-02-01T09:15:00Z", location: "Los Angeles, CA", details: nil)
            ],
            citationId: "test-id"
        )
        .padding(Edge.Set.all)
        .background(AppColors.background)
    }
}
#endif
