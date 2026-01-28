//
//  Components.swift
//  FightCityTickets
//
//  Reusable UI components with app styling
//

import SwiftUI

// MARK: - Primary Button

/// Primary action button with app styling
struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var isEnabled: Bool = true
    var isLoading: Bool = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                }
                Text(title)
                    .labelLarge()
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .padding(.horizontal, 24)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isEnabled ? AppColors.primary : AppColors.disabled)
            )
            .foregroundColor(AppColors.onPrimary)
        }
        .disabled(!isEnabled || isLoading)
    }
}

// MARK: - Secondary Button

/// Secondary outline button
struct SecondaryButton: View {
    let title: String
    let action: () -> Void
    var isEnabled: Bool = true
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .labelLarge()
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .padding(.horizontal, 24)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(AppColors.primary, lineWidth: 2)
                )
                .foregroundColor(isEnabled ? AppColors.primary : AppColors.disabled)
        }
        .disabled(!isEnabled)
    }
}

// MARK: - Capture Button

/// Large circular capture button for camera screen
struct CaptureButton: View {
    let action: () -> Void
    var isCapturing: Bool = false
    
    var body: some View {
        Button(action: action) {
            ZStack {
                // Outer ring
                Circle()
                    .stroke(AppColors.onPrimary, lineWidth: 4)
                    .frame(width: 76, height: 76)
                
                // Inner circle
                Circle()
                    .fill(isCapturing ? AppColors.error : AppColors.captureButtonStart)
                    .frame(width: 62, height: 62)
                
                // Recording indicator
                if isCapturing {
                    Circle()
                        .fill(AppColors.onPrimary)
                        .frame(width: 54, height: 54)
                }
            }
        }
        .accessibilityLabel("Capture ticket photo")
        .accessibilityHint("Tap to take a photo of your parking ticket")
    }
}

// MARK: - Citation Card

/// Card displaying citation information
struct CitationCard: View {
    let citationNumber: String
    let cityName: String
    let deadlineDate: String?
    let isUrgent: Bool
    let onTap: (() -> Void)?
    
    var body: some View {
        Button(action: { onTap?() }) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(cityName)
                            .labelMedium()
                            .foregroundColor(AppColors.textSecondary)
                        
                        Text(citationNumber)
                            .citationNumber()
                            .foregroundColor(AppColors.textPrimary)
                    }
                    
                    Spacer()
                    
                    if let deadline = deadlineDate {
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Deadline")
                                .labelSmall()
                                .foregroundColor(AppColors.textSecondary)
                            
                            Text(deadline)
                                .labelMedium()
                                .foregroundColor(isUrgent ? AppColors.deadlineUrgent : AppColors.deadlineSafe)
                        }
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppColors.secondaryBackground)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Status Badge

/// Status badge for validation results
struct StatusBadge: View {
    let status: StatusType
    let text: String
    
    enum StatusType {
        case success, warning, error, info
    }
    
    var backgroundColor: Color {
        switch status {
        case .success: return AppColors.success.opacity(0.2)
        case .warning: return AppColors.warning.opacity(0.2)
        case .error: return AppColors.error.opacity(0.2)
        case .info: return AppColors.info.opacity(0.2)
        }
    }
    
    var foregroundColor: Color {
        switch status {
        case .success: return AppColors.success
        case .warning: return AppColors.warning
        case .error: return AppColors.error
        case .info: return AppColors.info
        }
    }
    
    var body: some View {
        Text(text)
            .labelSmall()
            .foregroundColor(foregroundColor)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(backgroundColor)
            )
    }
}

// MARK: - Confidence Indicator

/// Visual confidence score indicator
struct ConfidenceIndicator: View {
    let confidence: Double
    let label: String
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(AppColors.disabled, lineWidth: 4)
                    .frame(width: 60, height: 60)
                
                Circle()
                    .trim(from: 0, to: confidence)
                    .stroke(
                        confidenceColor,
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(-90))
                
                Text("\(Int(confidence * 100))%")
                    .labelMedium()
                    .foregroundColor(confidenceColor)
            }
            
            Text(label)
                .labelSmall()
                .foregroundColor(AppColors.textSecondary)
        }
    }
    
    private var confidenceColor: Color {
        if confidence >= 0.85 {
            return AppColors.success
        } else if confidence >= 0.60 {
            return AppColors.warning
        } else {
            return AppColors.error
        }
    }
}

// MARK: - Loading Overlay

/// Full-screen loading overlay
struct LoadingOverlay: View {
    let message: String
    var isShowing: Bool
    
    var body: some View {
        if isShowing {
            ZStack {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                
                VStack(spacing: 16) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                    
                    Text(message)
                        .bodyMedium()
                        .foregroundColor(.white)
                }
                .padding(32)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(AppColors.secondaryBackground)
                )
            }
        }
    }
}

// MARK: - Info Row

/// Reusable info row for key-value display
struct InfoRow: View {
    let label: String
    let value: String
    var isUrgent: Bool = false
    
    var body: some View {
        HStack {
            Text(label)
                .bodyMedium()
                .foregroundColor(AppColors.textSecondary)
            
            Spacer()
            
            Text(value)
                .bodyMedium()
                .foregroundColor(isUrgent ? AppColors.deadlineUrgent : AppColors.textPrimary)
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Toast View

/// Toast notification for feedback
struct Toast: View {
    let message: String
    let type: ToastType
    
    enum ToastType {
        case success, error, info
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: iconName)
                .foregroundColor(iconColor)
            
            Text(message)
                .bodyMedium()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(toastColor)
        )
        .foregroundColor(AppColors.textPrimary)
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
    }
    
    private var iconName: String {
        switch type {
        case .success: return "checkmark.circle.fill"
        case .error: return "xmark.circle.fill"
        case .info: return "info.circle.fill"
        }
    }
    
    private var iconColor: Color {
        switch type {
        case .success: return AppColors.success
        case .error: return AppColors.error
        case .info: return AppColors.info
        }
    }
    
    private var toastColor: Color {
        switch type {
        case .success: return AppColors.success.opacity(0.1)
        case .error: return AppColors.error.opacity(0.1)
        case .info: return AppColors.info.opacity(0.1)
        }
    }
}
