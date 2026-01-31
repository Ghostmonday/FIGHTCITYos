//
//  MailSuccessView.swift
//  FightCity
//
//  Success screen after sending certified mail
//

import SwiftUI
import FightCityFoundation

public struct MailSuccessView: View {
    let trackingNumber: String
    let expectedDeliveryDate: String?
    let citationId: String
    let onTrackMail: () -> Void
    let onDone: () -> Void
    
    @State private var hasAppeared = false
    
    public init(
        trackingNumber: String,
        expectedDeliveryDate: String? = nil,
        citationId: String,
        onTrackMail: @escaping () -> Void,
        onDone: @escaping () -> Void
    ) {
        self.trackingNumber = trackingNumber
        self.expectedDeliveryDate = expectedDeliveryDate
        self.citationId = citationId
        self.onTrackMail = onTrackMail
        self.onDone = onDone
    }
    
    public var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()
            
            VStack(spacing: 32) {
                Spacer()
                
                // Success animation
                successAnimation
                    .opacity(hasAppeared ? 1 : 0)
                    .scaleEffect(hasAppeared ? 1 : 0.8)
                    .animation(.spring(response: 0.6, dampingFraction: 0.7), value: hasAppeared)
                
                // Success message
                successMessage
                    .opacity(hasAppeared ? 1 : 0)
                    .offset(y: hasAppeared ? 0 : 20)
                    .animation(.easeOut(duration: 0.4).delay(0.2), value: hasAppeared)
                
                // Tracking info
                trackingInfo
                    .opacity(hasAppeared ? 1 : 0)
                    .offset(y: hasAppeared ? 0 : 20)
                    .animation(.easeOut(duration: 0.4).delay(0.3), value: hasAppeared)
                
                Spacer()
                
                // Action buttons
                actionButtons
                    .opacity(hasAppeared ? 1 : 0)
                    .offset(y: hasAppeared ? 0 : 20)
                    .animation(.easeOut(duration: 0.4).delay(0.4), value: hasAppeared)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 40)
        }
        .onAppear {
            FCHaptics.prepare()
            FCHaptics.success()
            withAnimation {
                hasAppeared = true
            }
        }
        .preferredColorScheme(.dark)
    }
    
    // MARK: - Success Animation
    
    private var successAnimation: some View {
        ZStack {
            Circle()
                .fill(AppColors.success.opacity(0.2))
                .frame(width: 120, height: 120)
            
            Circle()
                .fill(AppColors.success.opacity(0.1))
                .frame(width: 100, height: 100)
            
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundColor(AppColors.success)
        }
    }
    
    // MARK: - Success Message
    
    private var successMessage: some View {
        VStack(spacing: 12) {
            Text("Certified Mail Sent!")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
            
            Text("Your appeal letter has been sent via certified mail with tracking.")
                .font(.system(size: 16))
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
    
    // MARK: - Tracking Info
    
    private var trackingInfo: some View {
        VStack(spacing: 16) {
            VStack(spacing: 8) {
                Text("Tracking Number")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(AppColors.textTertiary)
                    .textCase(.uppercase)
                    .tracking(1)
                
                Text(trackingNumber)
                    .font(.system(size: 20, weight: .bold, design: .monospaced))
                    .foregroundColor(AppColors.gold)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(AppColors.surface)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(AppColors.gold.opacity(0.3), lineWidth: 1)
                    )
            }
            
            if let deliveryDate = expectedDeliveryDate {
                HStack(spacing: 8) {
                    Image(systemName: "calendar")
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.textSecondary)
                    Text("Expected delivery: \(formatDeliveryDate(deliveryDate))")
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.textSecondary)
                }
            }
        }
        .padding(20)
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
            Button(action: {
                FCHaptics.mediumImpact()
                onTrackMail()
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 16))
                    Text("Track Your Mail")
                        .font(.system(size: 17, weight: .semibold))
                }
                .foregroundColor(AppColors.obsidian)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(AppColors.goldGradient)
                .cornerRadius(14)
                .shadow(color: AppColors.gold.opacity(0.4), radius: 12, y: 6)
            }
            
            Button(action: {
                FCHaptics.lightImpact()
                onDone()
            }) {
                Text("Done")
                    .font(.system(size: 16, weight: .medium))
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
    
    // MARK: - Helpers
    
    private func formatDeliveryDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let date = formatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .long
            return displayFormatter.string(from: date)
        }
        
        // Fallback: try without fractional seconds
        formatter.formatOptions = [.withInternetDateTime]
        if let date = formatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .long
            return displayFormatter.string(from: date)
        }
        
        return dateString
    }
}

// MARK: - Previews

#if DEBUG
struct MailSuccessView_Previews: PreviewProvider {
    static var previews: some View {
        MailSuccessView(
            trackingNumber: "9400111899223197428490",
            expectedDeliveryDate: "2026-02-05T00:00:00Z",
            citationId: "test-id",
            onTrackMail: {},
            onDone: {}
        )
    }
}
#endif
