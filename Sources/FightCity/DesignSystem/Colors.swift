//
//  Colors.swift
//  FightCity
//
//  App color palette and semantic colors
//

import SwiftUI
import FightCityFoundation

// MARK: - App Colors

/// App color palette
public enum AppColors {
    // MARK: - Primary Colors
    
    public static let primary = Color("Primary", bundle: nil)
    public static let primaryVariant = Color("PrimaryVariant", bundle: nil)
    public static let secondary = Color("Secondary", bundle: nil)
    public static let secondaryVariant = Color("SecondaryVariant", bundle: nil)
    
    // MARK: - Accent Colors
    
    public static let accent = Color("AccentColor", bundle: nil)
    
    // MARK: - Background Colors
    
    public static let background = Color("Background", bundle: nil)
    public static let surface = Color("Surface", bundle: nil)
    public static let surfaceVariant = Color("SurfaceVariant", bundle: nil)
    
    // MARK: - Text Colors
    
    public static let textPrimary = Color("TextPrimary", bundle: nil)
    public static let textSecondary = Color("TextSecondary", bundle: nil)
    public static let textTertiary = Color("TextTertiary", bundle: nil)
    
    public static let onPrimary = Color("OnPrimary", bundle: nil)
    public static let onSecondary = Color("OnSecondary", bundle: nil)
    public static let onBackground = Color("OnBackground", bundle: nil)
    public static let onSurface = Color("OnSurface", bundle: nil)
    public static let onSurfaceVariant = Color("OnSurfaceVariant", bundle: nil)
    public static let disabled = Color("Disabled", bundle: nil)
    
    // MARK: - Semantic Colors
    
    public static let success = Color("Success", bundle: nil)
    public static let warning = Color("Warning", bundle: nil)
    public static let error = Color("Error", bundle: nil)
    public static let info = Color("Info", bundle: nil)
    
    // MARK: - Deadline Colors
    
    public static let deadlineSafe = Color("DeadlineSafe", bundle: nil)
    public static let deadlineApproaching = Color("DeadlineApproaching", bundle: nil)
    public static let deadlineUrgent = Color("DeadlineUrgent", bundle: nil)
    
    // MARK: - OCR Confidence Colors
    
    public static let confidenceHigh = Color("ConfidenceHigh", bundle: nil)
    public static let confidenceMedium = Color("ConfidenceMedium", bundle: nil)
    public static let confidenceLow = Color("ConfidenceLow", bundle: nil)
    
    // MARK: - AI Feature Colors
    
    /// Apple Intelligence brand color (purple/indigo)
    public static let intelligence = Color(red: 0.4, green: 0.2, blue: 0.9)
    
    /// Scan/capture green
    public static let scanGreen = Color(red: 0.2, green: 0.8, blue: 0.4)
    
    /// Document/vision blue
    public static let visionBlue = Color(red: 0.1, green: 0.5, blue: 0.9)
    
    /// Premium gold accent
    public static let premiumGold = Color(red: 0.83, green: 0.68, blue: 0.21)
}

// MARK: - Gradient Definitions

public extension AppColors {
    /// Primary gradient for hero sections
    static let primaryGradient = LinearGradient(
        colors: [primary, primary.opacity(0.8)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
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
    
    /// Premium gold gradient
    static let premiumGradient = LinearGradient(
        colors: [premiumGold, Color(red: 0.9, green: 0.8, blue: 0.3)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - Glassmorphism

public extension AppColors {
    /// Translucent white for glass effect
    static let glassWhite = Color.white.opacity(0.2)
    
    /// Translucent black for glass effect
    static let glassBlack = Color.black.opacity(0.3)
    
    /// Background blur material
    static let materialUltraThin = Color(uiColor: .systemBackground).opacity(0.4)
    static let materialThin = Color(uiColor: .systemBackground).opacity(0.6)
    static let materialMedium = Color(uiColor: .systemBackground).opacity(0.8)
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
