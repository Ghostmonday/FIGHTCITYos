//
//  CitationDetailView.swift
//  FightCity
//
//  Full citation detail view with tracking timeline
//

import SwiftUI
import FightCityFoundation
import FightCityiOS

public struct CitationDetailView: View {
    let citation: Citation
    
    @StateObject private var viewModel: CitationDetailViewModel
    @ObservedObject private var mailTracker = MailTracker.shared
    @Environment(\.dismiss) var dismiss
    @State private var hasAppeared = false
    
    public init(citation: Citation) {
        self.citation = citation
        self._viewModel = StateObject(wrappedValue: CitationDetailViewModel(citation: citation))
    }
    
    public var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Citation header
                    citationHeader
                        .opacity(hasAppeared ? 1 : 0)
                        .offset(y: hasAppeared ? 0 : 20)
                        .animation(.easeOut(duration: 0.4), value: hasAppeared)
                    
                    // Citation details
                    citationDetails
                        .opacity(hasAppeared ? 1 : 0)
                        .offset(y: hasAppeared ? 0 : 20)
                        .animation(.easeOut(duration: 0.4).delay(0.1), value: hasAppeared)
                    
                    // Appeal status
                    if citation.status == .appealed || citation.status == .inReview {
                        appealStatusSection
                            .opacity(hasAppeared ? 1 : 0)
                            .offset(y: hasAppeared ? 0 : 20)
                            .animation(.easeOut(duration: 0.4).delay(0.2), value: hasAppeared)
                    }
                    
                    // Tracking timeline
                    if let mailingStatus = citation.mailingStatus ?? mailTracker.getStatus(for: citation.id.uuidString),
                       let events = mailTracker.trackingEvents[citation.id.uuidString] {
                        TrackingTimelineView(events: events, citationId: citation.id.uuidString)
                            .opacity(hasAppeared ? 1 : 0)
                            .offset(y: hasAppeared ? 0 : 20)
                            .animation(.easeOut(duration: 0.4).delay(0.3), value: hasAppeared)
                    }
                    
                    // Actions
                    actionButtons
                        .opacity(hasAppeared ? 1 : 0)
                        .offset(y: hasAppeared ? 0 : 20)
                        .animation(.easeOut(duration: 0.4).delay(0.4), value: hasAppeared)
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
        }
        .navigationTitle("Citation Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    FCHaptics.lightImpact()
                    dismiss()
                }
                .foregroundColor(AppColors.gold)
            }
        }
        .onAppear {
            FCHaptics.prepare()
            withAnimation {
                hasAppeared = true
            }
        }
        .preferredColorScheme(.dark)
    }
    
    // MARK: - Citation Header
    
    private var citationHeader: some View {
        VStack(spacing: 16) {
            Text(citation.citationNumber)
                .font(SwiftUI.Font.system(size: 32, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
            
            if let city = citation.cityName {
                Text(city)
                    .font(SwiftUI.Font.system(size: 16))
                    .foregroundColor(AppColors.textSecondary)
            }
            
            StatusPill(status: citation.status)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(AppColors.surface)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppColors.glassBorder, lineWidth: 1)
        )
    }
    
    // MARK: - Citation Details
    
    private var citationDetails: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Citation Details")
                .font(SwiftUI.Font.system(size: 13, weight: .semibold))
                .foregroundColor(AppColors.textTertiary)
                .textCase(.uppercase)
                .tracking(1)
            
            VStack(spacing: 12) {
                if let amount = citation.amount {
                    detailRow(label: "Amount", value: amount, format: .currency(code: "USD"))
                }
                
                if let violationDate = citation.violationDate {
                    detailRow(label: "Violation Date", value: violationDate)
                }
                
                if let deadlineDate = citation.deadlineDate {
                    detailRow(label: "Deadline", value: deadlineDate)
                }
                
                if let days = citation.daysRemaining {
                    HStack {
                        Text("Days Remaining")
                            .font(SwiftUI.Font.system(size: 15))
                            .foregroundColor(AppColors.textSecondary)
                        Spacer()
                        Text(deadlineText(days: days, isPast: citation.isPastDeadline))
                            .font(SwiftUI.Font.system(size: 15, weight: .semibold))
                            .foregroundColor(deadlineColor(days: days, isPast: citation.isPastDeadline))
                    }
                }
                
                if let licensePlate = citation.licensePlate {
                    detailRow(label: "License Plate", value: licensePlate)
                }
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
    
    private func detailRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(SwiftUI.Font.system(size: 15))
                .foregroundColor(AppColors.textSecondary)
            Spacer()
            Text(value)
                .font(SwiftUI.Font.system(size: 15, weight: .medium))
                .foregroundColor(.white)
        }
    }
    
    private func detailRow<Value: Equatable, Style: FormatStyle>(label: String, value: Value, format: Style) -> some View where Style.FormatInput == Value, Style.FormatOutput == String {
        HStack {
            Text(label)
                .font(SwiftUI.Font.system(size: 15))
                .foregroundColor(AppColors.textSecondary)
            Spacer()
            Text(value, format: format)
                .font(SwiftUI.Font.system(size: 15, weight: .medium))
                .foregroundColor(.white)
        }
    }
    
    // MARK: - Appeal Status Section
    
    private var appealStatusSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Appeal Status")
                .font(SwiftUI.Font.system(size: 13, weight: .semibold))
                .foregroundColor(AppColors.textTertiary)
                .textCase(.uppercase)
                .tracking(1)
            
            HStack(spacing: 12) {
                Image(systemName: "doc.text.fill")
                    .font(SwiftUI.Font.system(size: 20))
                    .foregroundColor(AppColors.info)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(citation.status.displayName)
                        .font(SwiftUI.Font.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text("Your appeal is being reviewed")
                        .font(SwiftUI.Font.system(size: 14))
                        .foregroundColor(AppColors.textSecondary)
                }
                
                Spacer()
            }
            .padding(16)
            .background(AppColors.info.opacity(0.1))
            .cornerRadius(12)
        }
        .padding(16)
        .background(AppColors.surface)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppColors.glassBorder, lineWidth: 1)
        )
    }
    
    // MARK: - Action Buttons
    
    private var actionButtons: some View {
        VStack(spacing: 12) {
            if let trackingNumber = citation.trackingNumber {
                Button(action: {
                    FCHaptics.lightImpact()
                    UIPasteboard.general.string = trackingNumber
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "doc.on.doc")
                            .font(SwiftUI.Font.system(size: 14))
                        Text("Copy Tracking Number")
                            .font(SwiftUI.Font.system(size: 15, weight: .medium))
                    }
                    .foregroundColor(AppColors.gold)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(AppColors.surface)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(AppColors.gold.opacity(0.3), lineWidth: 1)
                    )
                }
            }
        }
    }
    
    // MARK: - Helpers
    
    private func deadlineText(days: Int, isPast: Bool) -> String {
        if isPast {
            return "Past due"
        } else if days == 0 {
            return "Due today"
        } else if days == 1 {
            return "1 day left"
        } else {
            return "\(days) days left"
        }
    }
    
    private func deadlineColor(days: Int, isPast: Bool) -> Color {
        if isPast {
            return AppColors.error
        } else if days <= 3 {
            return AppColors.error
        } else if days <= 7 {
            return AppColors.warning
        } else {
            return AppColors.success
        }
    }
}

// MARK: - Citation Detail ViewModel

@MainActor
public final class CitationDetailViewModel: ObservableObject {
    @Published public var isLoading = false
    
    private let citation: Citation
    
    public init(citation: Citation) {
        self.citation = citation
    }
}

// MARK: - Previews

#if DEBUG
struct CitationDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            CitationDetailView(
                citation: Citation(
                    citationNumber: "123456789",
                    cityId: "us-ca-san_francisco",
                    cityName: "San Francisco",
                    violationDate: "2026-01-15",
                    amount: 75.00,
                    deadlineDate: "2026-02-15",
                    daysRemaining: 15,
                    status: .appealed,
                    mailingStatus: .delivered,
                    trackingNumber: "9400111899223197428490"
                )
            )
        }
    }
}
#endif
