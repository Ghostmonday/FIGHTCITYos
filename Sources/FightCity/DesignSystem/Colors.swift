//
//  Colors.swift
//  FightCity
//
//  Premium color palette - Luxury Fintech Aesthetic
//  Design Direction: Stripe, Airbnb, Apple Design Award quality
//

import SwiftUI
import FightCityFoundation

// MARK: - App Colors

/// Premium color palette with navy/gold luxury aesthetic
public enum AppColors {
    
    // MARK: - Brand Colors (Luxury Palette)
    
    /// Obsidian Navy - Deepest background #0a0a0f
    public static let obsidian = Color(red: 0.039, green: 0.039, blue: 0.059)
    
    /// Midnight Blue - Primary brand color #1a2a4a
    public static let midnight = Color(red: 0.102, green: 0.165, blue: 0.290)
    
    /// Brushed Gold - Premium accent #d4af37
    public static let gold = Color(red: 0.831, green: 0.686, blue: 0.216)
    
    /// Soft Gold - Lighter gold for text #e8c547
    public static let goldLight = Color(red: 0.91, green: 0.77, blue: 0.28)
    
    // MARK: - Primary Colors (Mapped to Brand)
    
    public static let primary = midnight
    public static let primaryVariant = Color(red: 0.133, green: 0.200, blue: 0.333) // Lighter midnight
    public static let secondary = gold
    public static let secondaryVariant = goldLight
    
    // MARK: - Accent Colors
    
    public static let accent = gold
    
    // MARK: - Background Colors
    
    public static let background = obsidian
    public static let surface = Color(red: 0.067, green: 0.078, blue: 0.114) // Slightly lighter than obsidian
    public static let surfaceVariant = Color(red: 0.098, green: 0.114, blue: 0.161)
    public static let surfaceElevated = Color(red: 0.118, green: 0.137, blue: 0.196)
    
    // MARK: - Text Colors
    
    public static let textPrimary = Color.white
    public static let textSecondary = Color.white.opacity(0.7)
    public static let textTertiary = Color.white.opacity(0.5)
    
    public static let onPrimary = Color.white
    public static let onSecondary = obsidian
    public static let onBackground = Color.white
    public static let onSurface = Color.white
    public static let onSurfaceVariant = Color.white.opacity(0.7)
    public static let disabled = Color.white.opacity(0.3)
    
    // MARK: - Semantic Colors
    
    /// Emerald success - matches onboarding verify
    public static let success = Color(red: 0.2, green: 0.78, blue: 0.45)
    
    /// Warm orange - matches onboarding status
    public static let warning = Color(red: 0.96, green: 0.65, blue: 0.14)
    
    /// Vibrant red for errors
    public static let error = Color(red: 0.94, green: 0.27, blue: 0.27)
    
    /// Cool blue for info
    public static let info = Color(red: 0.25, green: 0.56, blue: 0.96)
    
    // MARK: - Deadline Colors
    
    public static let deadlineSafe = success
    public static let deadlineApproaching = warning
    public static let deadlineUrgent = error
    
    // MARK: - OCR Confidence Colors
    
    public static let confidenceHigh = success
    public static let confidenceMedium = warning
    public static let confidenceLow = error
    
    // MARK: - AI Feature Colors
    
    /// Apple Intelligence brand color
    public static let intelligence = Color(red: 0.4, green: 0.35, blue: 0.95)
    
    /// Scan/capture - gold glow
    public static let scanActive = gold
    
    /// Document/vision blue
    public static let visionBlue = Color(red: 0.2, green: 0.5, blue: 0.9)
}

// MARK: - Premium Gradient Definitions

public extension AppColors {
    /// Hero gradient - obsidian to midnight (main backgrounds)
    static let heroGradient = LinearGradient(
        colors: [obsidian, midnight.opacity(0.8), obsidian],
        startPoint: .top,
        endPoint: .bottom
    )
    
    /// Gold shimmer gradient for CTAs
    static let goldGradient = LinearGradient(
        colors: [gold, goldLight, gold],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    /// Card gradient - subtle depth
    static let cardGradient = LinearGradient(
        colors: [surface, surfaceVariant.opacity(0.5)],
        startPoint: .top,
        endPoint: .bottom
    )
    
    /// Primary button gradient
    static let primaryGradient = LinearGradient(
        colors: [midnight, primaryVariant],
        startPoint: .top,
        endPoint: .bottom
    )
    
    /// Intelligence gradient for AI features
    static let intelligenceGradient = LinearGradient(
        colors: [intelligence, intelligence.opacity(0.7)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    /// Success gradient
    static let successGradient = LinearGradient(
        colors: [success, success.opacity(0.7)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    /// Warning gradient
    static let warningGradient = LinearGradient(
        colors: [warning, warning.opacity(0.7)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    /// Error gradient
    static let errorGradient = LinearGradient(
        colors: [error, error.opacity(0.7)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    /// Scan active glow gradient
    static let scanGlowGradient = RadialGradient(
        colors: [gold.opacity(0.6), gold.opacity(0.0)],
        center: .center,
        startRadius: 0,
        endRadius: 150
    )
}

// MARK: - Glassmorphism (Dark Theme)

public extension AppColors {
    /// Glass overlay - dark mode optimized
    static let glass = Color.white.opacity(0.08)
    
    /// Glass border
    static let glassBorder = Color.white.opacity(0.12)
    
    /// Glass highlight
    static let glassHighlight = Color.white.opacity(0.15)
    
    /// Frosted dark glass
    static let frostedGlass = surface.opacity(0.85)
}

// MARK: - Semantic Color Extensions

public extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Color Helpers

public extension Color {
    static func deadlineColor(for status: DeadlineStatus) -> Color {
        switch status {
        case .safe:
            return AppColors.deadlineSafe
        case .approaching:
            return AppColors.deadlineApproaching
        case .urgent, .past:
            return AppColors.deadlineUrgent
        }
    }
    
    static func confidenceColor(for level: String) -> Color {
        switch level.lowercased() {
        case "high":
            return AppColors.confidenceHigh
        case "medium":
            return AppColors.confidenceMedium
        case "low":
            return AppColors.confidenceLow
        default:
            return AppColors.confidenceMedium
        }
    }
    
    static func statusColor(for status: CitationStatus) -> Color {
        switch status {
        case .pending:
            return AppColors.warning
        case .validated, .approved:
            return AppColors.success
        case .inReview:
            return AppColors.info
        case .appealed:
            return AppColors.info
        case .denied, .expired:
            return AppColors.error
        case .paid:
            return AppColors.success
        }
    }
}
