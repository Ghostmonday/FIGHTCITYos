//
//  Components.swift
//  FightCity
//
//  Reusable UI components
//

import SwiftUI

// MARK: - Primary Button

public struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var isEnabled: Bool = true
    var isLoading: Bool = false
    
    public init(title: String, action: @escaping () -> Void, isEnabled: Bool = true, isLoading: Bool = false) {
        self.title = title
        self.action = action
        self.isEnabled = isEnabled
        self.isLoading = isLoading
    }
    
    public var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                }
                Text(title)
                    .font(AppTypography.labelLarge)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .padding(.horizontal, 24)
            .background(isEnabled ? Color.accentColor : Color.gray)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .disabled(!isEnabled || isLoading)
    }
}

// MARK: - Secondary Button

public struct SecondaryButton: View {
    let title: String
    let action: () -> Void
    var isEnabled: Bool = true
    
    public init(title: String, action: @escaping () -> Void, isEnabled: Bool = true) {
        self.title = title
        self.action = action
        self.isEnabled = isEnabled
    }
    
    public var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppTypography.labelLarge)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .padding(.horizontal, 24)
                .background(Color.clear)
                .foregroundColor(.accentColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.accentColor, lineWidth: 2)
                )
        }
        .disabled(!isEnabled)
    }
}

// MARK: - Card View

public struct CardView<Content: View>: View {
    let content: Content
    
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            content
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Citation Card

public struct CitationCard: View {
    let citation: Citation
    let onTap: () -> Void
    
    public init(citation: Citation, onTap: @escaping () -> Void) {
        self.citation = citation
        self.onTap = onTap
    }
    
    public var body: some View {
        Button(action: onTap) {
            CardView {
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(citation.citationNumber)
                            .font(AppTypography.citationNumber)
                            .foregroundColor(.primary)
                        
                        if let cityName = citation.cityName {
                            Text(cityName)
                                .font(AppTypography.bodyMedium)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    StatusBadge(status: citation.status)
                }
                
                HStack {
                    if let deadline = citation.deadlineDate {
                        Text("Due: \(deadline)")
                            .font(AppTypography.labelMedium)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    if let days = citation.daysRemaining {
                        Text("\(days) days left")
                            .font(AppTypography.labelMedium)
                            .foregroundColor(Color.deadlineColor(for: citation.deadlineStatus))
                    }
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Status Badge

public struct StatusBadge: View {
    let status: CitationStatus
    
    public init(status: CitationStatus) {
        self.status = status
    }
    
    public var body: some View {
        Text(status.displayName)
            .font(AppTypography.labelSmall)
            .fontWeight(.medium)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.statusColor(for: status).opacity(0.15))
            .foregroundColor(Color.statusColor(for: status))
            .cornerRadius(8)
    }
}

// MARK: - Confidence Indicator

public struct ConfidenceIndicator: View {
    let confidence: Double
    let level: ConfidenceScorer.ConfidenceLevel
    
    public init(confidence: Double, level: ConfidenceScorer.ConfidenceLevel) {
        self.confidence = confidence
        self.level = level
    }
    
    public var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(Color.confidenceColor(for: level))
                .frame(width: 8, height: 8)
            
            Text("\(Int(confidence * 100))%")
                .font(AppTypography.confidenceScore)
                .foregroundColor(Color.confidenceColor(for: level))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.confidenceColor(for: level).opacity(0.15))
        .cornerRadius(8)
    }
}

// MARK: - Loading Overlay

public struct LoadingOverlay: View {
    let message: String
    let isShowing: Bool
    
    public init(message: String, isShowing: Bool) {
        self.message = message
        self.isShowing = isShowing
    }
    
    public var body: some View {
        if isShowing {
            ZStack {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                
                VStack(spacing: 16) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                    
                    Text(message)
                        .font(AppTypography.bodyMedium)
                        .foregroundColor(.white)
                }
                .padding(32)
                .background(Color(.systemGray5))
                .cornerRadius(16)
            }
        }
    }
}

// MARK: - Empty State View

public struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    let buttonTitle: String?
    let buttonAction: (() -> Void)?
    
    public init(
        icon: String,
        title: String,
        message: String,
        buttonTitle: String? = nil,
        buttonAction: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.buttonTitle = buttonTitle
        self.buttonAction = buttonAction
    }
    
    public var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text(title)
                .font(AppTypography.titleMedium)
                .foregroundColor(.primary)
            
            Text(message)
                .font(AppTypography.bodyMedium)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            if let buttonTitle = buttonTitle, let buttonAction = buttonAction {
                PrimaryButton(title: buttonTitle, action: buttonAction)
                    .padding(.top, 8)
            }
        }
        .padding(32)
    }
}

// MARK: - Error View

public struct ErrorView: View {
    let message: String
    let retryAction: () -> Void
    
    public init(message: String, retryAction: @escaping () -> Void) {
        self.message = message
        self.retryAction = retryAction
    }
    
    public var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.orange)
            
            Text("Something went wrong")
                .font(AppTypography.titleMedium)
            
            Text(message)
                .font(AppTypography.bodyMedium)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            PrimaryButton(title: "Try Again", action: retryAction)
        }
        .padding(32)
    }
}
