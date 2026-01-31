//
//  Theme.swift
//  FightCity
//
//  App theming configuration with colors and typography
//

import SwiftUI
import FightCityFoundation

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
            surface: .white,
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

/// Theme color palette
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
    
    public init(
        primary: Color,
        primaryVariant: Color,
        secondary: Color,
        secondaryVariant: Color,
        background: Color,
        surface: Color,
        surfaceVariant: Color,
        onPrimary: Color,
        onSecondary: Color,
        onBackground: Color,
        onSurface: Color,
        onSurfaceVariant: Color,
        disabled: Color,
        success: Color,
        warning: Color,
        error: Color,
        info: Color,
        deadlineSafe: Color,
        deadlineApproaching: Color,
        deadlineUrgent: Color,
        confidenceHigh: Color,
        confidenceMedium: Color,
        confidenceLow: Color
    ) {
        self.primary = primary
        self.primaryVariant = primaryVariant
        self.secondary = secondary
        self.secondaryVariant = secondaryVariant
        self.background = background
        self.surface = surface
        self.surfaceVariant = surfaceVariant
        self.onPrimary = onPrimary
        self.onSecondary = onSecondary
        self.onBackground = onBackground
        self.onSurface = onSurface
        self.onSurfaceVariant = onSurfaceVariant
        self.disabled = disabled
        self.success = success
        self.warning = warning
        self.error = error
        self.info = info
        self.deadlineSafe = deadlineSafe
        self.deadlineApproaching = deadlineApproaching
        self.deadlineUrgent = deadlineUrgent
        self.confidenceHigh = confidenceHigh
        self.confidenceMedium = confidenceMedium
        self.confidenceLow = confidenceLow
    }
}

// MARK: - Theme Typography

/// Typography configuration for the theme
public struct ThemeTypography {
    // MARK: - Display Fonts
    
    public let displayLarge: Font
    public let displayMedium: Font
    public let displaySmall: Font
    
    // MARK: - Headline Fonts
    
    public let headlineLarge: Font
    public let headlineMedium: Font
    public let headlineSmall: Font
    
    // MARK: - Title Fonts
    
    public let titleLarge: Font
    public let titleMedium: Font
    public let titleSmall: Font
    
    // MARK: - Body Fonts
    
    public let bodyLarge: Font
    public let bodyMedium: Font
    public let bodySmall: Font
    
    // MARK: - Label Fonts
    
    public let labelLarge: Font
    public let labelMedium: Font
    public let labelSmall: Font
    
    // MARK: - Special Fonts
    
    /// For citation numbers - monospaced for readability
    public let citationNumber: Font
    
    /// For monetary amounts
    public let monetaryAmount: Font
    
    /// For OCR confidence scores
    public let confidenceScore: Font
    
    /// For caption text
    public let caption: Font
    
    /// For button text
    public let button: Font
    
    // MARK: - Line Heights
    
    public let displayLineHeight: CGFloat
    public let headlineLineHeight: CGFloat
    public let titleLineHeight: CGFloat
    public let bodyLineHeight: CGFloat
    public let labelLineHeight: CGFloat
    
    public init() {
        // Display fonts
        self.displayLarge = .system(size: 57, weight: .bold, design: .default)
        self.displayMedium = .system(size: 45, weight: .bold, design: .default)
        self.displaySmall = .system(size: 36, weight: .bold, design: .default)
        
        // Headline fonts
        self.headlineLarge = .system(size: 32, weight: .semibold, design: .default)
        self.headlineMedium = .system(size: 28, weight: .semibold, design: .default)
        self.headlineSmall = .system(size: 24, weight: .semibold, design: .default)
        
        // Title fonts
        self.titleLarge = .system(size: 22, weight: .semibold, design: .default)
        self.titleMedium = .system(size: 16, weight: .medium, design: .default)
        self.titleSmall = .system(size: 14, weight: .medium, design: .default)
        
        // Body fonts
        self.bodyLarge = .system(size: 16, weight: .regular, design: .default)
        self.bodyMedium = .system(size: 14, weight: .regular, design: .default)
        self.bodySmall = .system(size: 12, weight: .regular, design: .default)
        
        // Label fonts
        self.labelLarge = .system(size: 14, weight: .medium, design: .default)
        self.labelMedium = .system(size: 12, weight: .medium, design: .default)
        self.labelSmall = .system(size: 11, weight: .medium, design: .default)
        
        // Special fonts
        self.citationNumber = .system(size: 24, weight: .bold, design: .monospaced)
        self.monetaryAmount = .system(size: 32, weight: .bold, design: .default)
        self.confidenceScore = .system(size: 14, weight: .semibold, design: .default)
        self.caption = .system(size: 11, weight: .regular, design: .default)
        self.button = .system(size: 16, weight: .semibold, design: .default)
        
        // Line heights (based on Apple Human Interface Guidelines)
        self.displayLineHeight = 64
        self.headlineLineHeight = 40
        self.titleLineHeight = 28
        self.bodyLineHeight = 22
        self.labelLineHeight = 16
    }
    
    // MARK: - Convenience Accessors
    
    /// Get font for a text style
    public func font(for style: TextStyle) -> Font {
        switch style {
        case .displayLarge: return displayLarge
        case .displayMedium: return displayMedium
        case .displaySmall: return displaySmall
        case .headlineLarge: return headlineLarge
        case .headlineMedium: return headlineMedium
        case .headlineSmall: return headlineSmall
        case .titleLarge: return titleLarge
        case .titleMedium: return titleMedium
        case .titleSmall: return titleSmall
        case .bodyLarge: return bodyLarge
        case .bodyMedium: return bodyMedium
        case .bodySmall: return bodySmall
        case .labelLarge: return labelLarge
        case .labelMedium: return labelMedium
        case .labelSmall: return labelSmall
        case .citationNumber: return citationNumber
        case .monetaryAmount: return monetaryAmount
        case .confidenceScore: return confidenceScore
        case .caption: return caption
        case .button: return button
        }
    }
    
    /// Get line height for a text style
    public func lineHeight(for style: TextStyle) -> CGFloat {
        switch style {
        case .displayLarge, .displayMedium, .displaySmall:
            return displayLineHeight
        case .headlineLarge, .headlineMedium, .headlineSmall:
            return headlineLineHeight
        case .titleLarge, .titleMedium, .titleSmall:
            return titleLineHeight
        case .bodyLarge, .bodyMedium, .bodySmall:
            return bodyLineHeight
        case .labelLarge, .labelMedium, .labelSmall, .caption, .button:
            return labelLineHeight
        case .citationNumber, .monetaryAmount, .confidenceScore:
            return bodyLineHeight
        }
    }
}

// MARK: - Text Styles

/// Predefined text styles for consistent typography
public enum TextStyle {
    case displayLarge
    case displayMedium
    case displaySmall
    case headlineLarge
    case headlineMedium
    case headlineSmall
    case titleLarge
    case titleMedium
    case titleSmall
    case bodyLarge
    case bodyMedium
    case bodySmall
    case labelLarge
    case labelMedium
    case labelSmall
    case citationNumber
    case monetaryAmount
    case confidenceScore
    case caption
    case button
}

// MARK: - Theme Struct

/// Complete theme definition
public struct Theme {
    public let colors: ThemeColors
    public let typography: ThemeTypography
    
    public static var current: Theme {
        // Return default light theme
        return AppTheme.light
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

// MARK: - Text Extensions

public extension Text {
    /// Apply theme typography style with optional line height
    func typography(_ style: TextStyle, theme: Theme = .current, lineHeight: CGFloat? = nil) -> some View {
        let font = theme.typography.font(for: style)
        let height = lineHeight ?? theme.typography.lineHeight(for: style)
        // Approximate line height for system font (typically 1.2x font size)
        // Note: Font doesn't expose pointSize directly, use estimated value
        let approximateLineHeight: CGFloat = 20.0 // Approximate for body font
        return self.font(font).lineSpacing(height - approximateLineHeight)
    }
    
    /// Apply theme color
    func themeColor(_ keyPath: KeyPath<ThemeColors, Color>, theme: Theme = .current) -> some View {
        self.foregroundColor(theme.colors[keyPath: keyPath])
    }
}

// MARK: - View Extensions for Common Styles

public extension View {
    /// Style as a primary title
    func titleStyle(theme: Theme = .current) -> some View {
        self.font(theme.typography.titleLarge)
            .foregroundColor(theme.colors.onBackground)
    }
    
    /// Style as a secondary title
    func subtitleStyle(theme: Theme = .current) -> some View {
        self.font(theme.typography.titleMedium)
            .foregroundColor(theme.colors.onSurfaceVariant)
    }
    
    /// Style as body text
    func bodyStyle(theme: Theme = .current) -> some View {
        self.font(theme.typography.bodyLarge)
            .foregroundColor(theme.colors.onBackground)
    }
    
    /// Style as caption text
    func captionStyle(theme: Theme = .current) -> some View {
        self.font(theme.typography.caption)
            .foregroundColor(theme.colors.onSurfaceVariant)
    }
    
    /// Style for citation number display
    func citationStyle(theme: Theme = .current) -> some View {
        self.font(theme.typography.citationNumber)
            .foregroundColor(theme.colors.primary)
    }
    
    /// Style for monetary amount display
    func monetaryStyle(theme: Theme = .current) -> some View {
        self.font(theme.typography.monetaryAmount)
            .foregroundColor(theme.colors.onBackground)
    }
    
    /// Style for confidence score display
    func confidenceStyle(level: ConfidenceLevelType, theme: Theme = .current) -> some View {
        let color: Color
        switch level.lowercased() {
        case "high":
            color = theme.colors.confidenceHigh
        case "medium":
            color = theme.colors.confidenceMedium
        case "low":
            color = theme.colors.confidenceLow
        default:
            color = theme.colors.confidenceMedium
        }
        return self.font(theme.typography.confidenceScore)
            .foregroundColor(color)
    }
    
    /// Style for deadline status
    func deadlineStyle(_ status: DeadlineStatus, theme: Theme = .current) -> some View {
        let color: Color
        switch status {
        case .safe:
            color = theme.colors.deadlineSafe
        case .approaching:
            color = theme.colors.deadlineApproaching
        case .urgent, .past:
            color = theme.colors.deadlineUrgent
        }
        return self.font(theme.typography.labelMedium)
            .foregroundColor(color)
    }
}

// MARK: - Confidence Level Type Alias

/// Type alias for confidence level - removed OCR dependency
public typealias ConfidenceLevelType = String
