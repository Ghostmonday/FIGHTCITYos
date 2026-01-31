//
//  Haptics.swift
//  FightCity
//
//  Premium haptic feedback utilities for satisfying user interactions
//

import UIKit

// MARK: - Haptic Feedback Manager

/// Centralized haptic feedback for consistent, satisfying interactions
/// IMPORTANT: Always call FCHaptics.prepare() before interactions that need instant response
/// e.g., in onAppear or when button appears. Haptics feel wrong if delayed!
/// Use FCHaptics.lightImpact() for subtle taps, .mediumImpact() for primary buttons
public enum FCHaptics {
    
    // MARK: - Impact Feedback
    
    /// Trigger a heavy impact haptic (for important actions)
    public static func heavyImpact() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }
    
    /// Trigger a medium impact haptic (for primary actions)
    public static func mediumImpact() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    /// Trigger a light impact haptic (for subtle interactions)
    public static func lightImpact() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    /// Trigger a rigid impact haptic (for iOS 13+)
    public static func rigidImpact() {
        if #available(iOS 13.0, *) {
            let generator = UIImpactFeedbackGenerator(style: .rigid)
            generator.impactOccurred()
        } else {
            mediumImpact()
        }
    }
    
    /// Trigger a soft impact haptic (for iOS 13+)
    public static func softImpact() {
        if #available(iOS 13.0, *) {
            let generator = UIImpactFeedbackGenerator(style: .soft)
            generator.impactOccurred()
        } else {
            lightImpact()
        }
    }
    
    // MARK: - Notification Feedback
    
    /// Trigger success notification haptic
    public static func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    /// Trigger warning notification haptic
    public static func warning() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }
    
    /// Trigger error notification haptic
    public static func error() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
    
    // MARK: - Selection Feedback
    
    /// Trigger selection change haptic (for taps on selectable items)
    public static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
    
    // MARK: - Button Taps
    
    /// Haptic for primary button tap
    public static func primaryButtonTap() {
        mediumImpact()
    }
    
    /// Haptic for secondary button tap
    public static func secondaryButtonTap() {
        lightImpact()
    }
    
    /// Haptic for destructive action (delete, remove)
    public static func destructiveAction() {
        rigidImpact()
        error()
    }
    
    // MARK: - Card Interactions
    
    /// Haptic when card is pressed
    public static func cardPress() {
        lightImpact()
    }
    
    /// Haptic when card is selected
    public static func cardSelect() {
        mediumImpact()
        success()
    }
    
    // MARK: - Scan Interactions
    
    /// Haptic when scan frame detects document
    public static func scanDetected() {
        lightImpact()
    }
    
    /// Haptic when capture completes
    public static func captureComplete() {
        mediumImpact()
        success()
    }
    
    // MARK: - Navigation
    
    /// Haptic when navigating back
    public static func navigateBack() {
        lightImpact()
    }
    
    /// Haptic when navigating forward
    public static func navigateForward() {
        lightImpact()
    }
    
    /// Haptic when page changes
    public static func pageChange() {
        selection()
    }
    
    // MARK: - Status Changes
    
    /// Haptic when status changes to success
    public static func statusSuccess() {
        success()
    }
    
    /// Haptic when status changes to pending
    public static func statusPending() {
        warning()
    }
    
    /// Haptic when status changes to error
    public static func statusError() {
        error()
    }
}

// MARK: - Haptic Lifecycle

extension FCHaptics {
    
    /// Prepare haptic generators for immediate response
    /// Call this before the interaction occurs (e.g., in onAppear)
    public static func prepare() {
        UIImpactFeedbackGenerator(style: .medium).prepare()
        UINotificationFeedbackGenerator().prepare()
        UISelectionFeedbackGenerator().prepare()
    }
    
    /// Prepare for button tap
    public static func prepareForButtonTap() {
        UIImpactFeedbackGenerator(style: .medium).prepare()
    }
    
    /// Prepare for selection
    public static func prepareForSelection() {
        UISelectionFeedbackGenerator().prepare()
    }
}

// MARK: - SwiftUI View Extension

import SwiftUI

public extension View {
    /// Add haptic feedback on tap
    func hapticFeedback(_ style: FCHapticTapStyle = .medium) -> some View {
        self.onTapGesture {
            switch style {
            case .light:
                FCHaptics.lightImpact()
            case .medium:
                FCHaptics.mediumImpact()
            case .heavy:
                FCHaptics.heavyImpact()
            case .rigid:
                FCHaptics.rigidImpact()
            case .selection:
                FCHaptics.selection()
            }
        }
    }
    
    /// Add haptic on long press
    func hapticOnLongPress(_ style: FCHapticLongPressStyle = .success) -> some View {
        self.onLongPressGesture(minimumDuration: 0.5, maximumDistance: .infinity, pressing: { _ in
            FCHaptics.prepareForButtonTap()
        }) {
            switch style {
            case .success:
                FCHaptics.success()
            case .warning:
                FCHaptics.warning()
            case .error:
                FCHaptics.error()
            case .selection:
                FCHaptics.selection()
            }
        }
    }
}

// MARK: - Haptic Styles

public enum FCHapticTapStyle {
    case light
    case medium
    case heavy
    case rigid
    case selection
}

public enum FCHapticLongPressStyle {
    case success
    case warning
    case error
    case selection
}
