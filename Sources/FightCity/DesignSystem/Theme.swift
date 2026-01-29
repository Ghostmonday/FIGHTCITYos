//
//  Theme.swift
//  FightCity
//
//  App theming configuration
//

import SwiftUI

// MARK: - Theme

/// App theme configuration
public struct AppTheme {
    // MARK: - Light Theme
    
    public static let light = Theme(
        colors: ThemeColors(
            primary: Color(hex: "#0066CC"),
            primaryVariant: Color(hex: "#0052A3"),
            secondary: Color(hex: "#34C759"),
            secondaryVariant: Color(hex: "#28A745"),
            background: Color(hex: "#F2F2F7"),
            surface: Color.white,
            surfaceVariant: Color(hex: "#E5E5EA"),
            onPrimary: .white,
            onSecondary: .white,
            onBackground: Color(hex: "#1C1C1E"),
            onSurface: Color(hex: "#1C1C1E"),
            onSurfaceVariant: Color(hex: "#8E8E93"),
            disabled: Color(hex: "#C7C7CC"),
            success: Color(hex: "#34C759"),
            warning: Color(hex: "#FF9500"),
            error: Color(hex: "#FF3B30"),
            info: Color(hex: "#007AFF"),
            deadlineSafe: Color(hex: "#34C759"),
            deadlineApproaching: Color(hex: "#FF9500"),
            deadlineUrgent: Color(hex: "#FF3B30"),
            confidenceHigh: Color(hex: "#34C759"),
            confidenceMedium: Color(hex: "#FF9500"),
            confidenceLow: Color(hex: "#FF3B30")
        ),
        typography: ThemeTypography()
    )
    
    // MARK: - Dark Theme
    
    public static let dark = Theme(
        colors: ThemeColors(
            primary: Color(hex: "#0A84FF"),
            primaryVariant: Color(hex: "#0066CC"),
            secondary: Color(hex: "#30D158"),
            secondaryVariant: Color(hex: "#34C759"),
            background: Color(hex: "#1C1C1E"),
            surface: Color(hex: "#2C2C2E"),
            surfaceVariant: Color(hex: "#3A3A3C"),
            onPrimary: .white,
            onSecondary: .black,
            onBackground: Color(hex: "#FFFFFF"),
            onSurface: Color(hex: "#FFFFFF"),
            onSurfaceVariant: Color(hex: "#AEAEB2"),
            disabled: Color(hex: "#48484A"),
            success: Color(hex: "#30D158"),
            warning: Color(hex: "#FF9F0A"),
            error: Color(hex: "#FF453A"),
            info: Color(hex: "#0A84FF"),
            deadlineSafe: Color(hex: "#30D158"),
            deadlineApproaching: Color(hex: "#FF9F0A"),
            deadlineUrgent: Color(hex: "#FF453A"),
            confidenceHigh: Color(hex: "#30D158"),
            confidenceMedium: Color(hex: "#FF9F0A"),
            confidenceLow: Color(hex: "#FF453A")
        ),
        typography: ThemeTypography()
    )
}

// MARK: - Theme Colors

public struct ThemeColors {
    public let primary: Color
    public let primaryVariant: Color
    public let secondary: Color
    public let secondaryVariant: Color
    public let background: Color
    public let surface: Color
    public let surfaceVariant: Color
    public let onPrimary: Color
    public let onSecondary: Color
    public let onBackground: Color
    public let onSurface: Color
    public let onSurfaceVariant: Color
    public let disabled: Color
    public let success: Color
    public let warning: Color
    public let error: Color
    public let info: Color
    public let deadlineSafe: Color
    public let deadlineApproaching: Color
    public let deadlineUrgent: Color
    public let confidenceHigh: Color
    public let confidenceMedium: Color
    public let confidenceLow: Color
}

// MARK: - Theme Typography

public struct ThemeTypography {
    // Typography settings for the theme
}

// MARK: - Theme Struct

public struct Theme {
    public let colors: ThemeColors
    public let typography: ThemeTypography
    
    public static var current: Theme {
        // Could be extended to support dynamic theme switching
        return .light
    }
}

// MARK: - Color Extension for Theme Colors

public extension Color {
    init(_ themeColor: KeyPath<ThemeColors, Color>, theme: Theme = .current) {
        self = theme.colors[keyPath: themeColor]
    }
}

// MARK: - View Extension for Theming

public extension View {
    func theme(_ theme: Theme) -> some View {
        self.environment(\.theme, theme)
    }
}

// MARK: - Environment Key

private struct ThemeKey: EnvironmentKey {
    static let defaultValue: Theme = AppTheme.light
}

public extension EnvironmentValues {
    var theme: Theme {
        get { self[ThemeKey.self] }
        set { self[ThemeKey.self] = newValue }
    }
}
