//
//  Colors.swift
//  FightCityTickets
//
//  App color palette with semantic naming
//

import SwiftUI

/// App color palette with semantic naming
enum AppColors {
    // MARK: - Primary Colors
    
    /// Primary brand color - energetic orange
    static let primary = Color("Primary", bundle: nil)
    
    /// Primary variant for hover/active states
    static let primaryVariant = Color("PrimaryVariant", bundle: nil)
    
    /// Secondary accent color
    static let secondary = Color("Secondary", bundle: nil)
    
    // MARK: - Background Colors
    
    /// Main background color
    static let background = Color(UIColor.systemBackground)
    
    /// Secondary background for cards/sections
    static let secondaryBackground = Color(UIColor.secondarySystemBackground)
    
    /// Tertiary background for subtle distinction
    static let tertiaryBackground = Color(UIColor.tertiarySystemBackground)
    
    // MARK: - Text Colors
    
    /// Primary text color
    static let textPrimary = Color(UIColor.label)
    
    /// Secondary text color
    static let textSecondary = Color(UIColor.secondaryLabel)
    
    /// Tertiary text color for captions
    static let textTertiary = Color(UIColor.tertiaryLabel)
    
    /// Text on primary colored backgrounds
    static let onPrimary = Color(UIColor.white)
    
    // MARK: - Status Colors
    
    /// Success/positive state color
    static let success = Color.green
    
    /// Warning/caution state color
    static let warning = Color.orange
    
    /// Error/negative state color
    static let error = Color.red
    
    /// Information state color
    static let info = Color.blue
    
    // MARK: - UI Component Colors
    
    /// Camera overlay border color
    static let cameraOverlay = Color.white.opacity(0.8)
    
    /// Bounding box stroke color
    static let boundingBox = Color.orange
    
    /// Bounding box fill color with transparency
    static let boundingBoxFill = Color.orange.opacity(0.1)
    
    /// Capture button gradient start
    static let captureButtonStart = Color.orange
    
    /// Capture button gradient end
    static let captureButtonEnd = Color.red
    
    /// Torch on indicator
    static let torchOn = Color.yellow
    
    // MARK: - Semantic Colors
    
    /// Citation number highlight
    static let citationHighlight = Color.orange.opacity(0.2)
    
    /// Deadline urgency indicator
    static let deadlineUrgent = Color.red
    
    /// Deadline approaching indicator
    static let deadlineApproaching = Color.orange
    
    /// Deadline safe indicator
    static let deadlineSafe = Color.green
    
    /// Disabled state color
    static let disabled = Color.gray.opacity(0.5)
}

// MARK: - Color Extensions

extension Color {
    /// Create color from hex string
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

// MARK: - UIColor Extensions

extension UIColor {
    /// Convenience access to AppColors as UIColor
    static let appPrimary = UIColor(red: 1.0, green: 0.4, blue: 0.2, alpha: 1.0) // Orange
    static let appSecondary = UIColor(red: 0.2, green: 0.4, blue: 0.9, alpha: 1.0) // Blue
    static let appSuccess = UIColor.systemGreen
    static let appWarning = UIColor.systemOrange
    static let appError = UIColor.systemRed
}
