//
//  Typography.swift
//  FightCityTickets
//
//  App typography system with scalable text styles
//

import SwiftUI

/// App typography system with semantic text styles
enum AppTypography {
    // MARK: - Display Styles
    
    /// Large display text for hero sections
    static let displayLarge = Font.system(size: 57, weight: .bold, design: .default)
    
    /// Medium display text
    static let displayMedium = Font.system(size: 45, weight: .bold, design: .default)
    
    /// Small display text
    static let displaySmall = Font.system(size: 36, weight: .bold, design: .default)
    
    // MARK: - Headline Styles
    
    /// Large headline for section headers
    static let headlineLarge = Font.system(size: 32, weight: .semibold, design: .default)
    
    /// Medium headline
    static let headlineMedium = Font.system(size: 28, weight: .semibold, design: .default)
    
    /// Small headline
    static let headlineSmall = Font.system(size: 24, weight: .semibold, design: .default)
    
    // MARK: - Title Styles
    
    /// Large title for primary screen titles
    static let titleLarge = Font.system(size: 22, weight: .bold, design: .default)
    
    /// Medium title for section titles
    static let titleMedium = Font.system(size: 18, weight: .semibold, design: .default)
    
    /// Small title for card/section titles
    static let titleSmall = Font.system(size: 16, weight: .semibold, design: .default)
    
    // MARK: - Body Styles
    
    /// Large body text for important content
    static let bodyLarge = Font.system(size: 17, weight: .regular, design: .default)
    
    /// Medium body text (default)
    static let bodyMedium = Font.system(size: 16, weight: .regular, design: .default)
    
    /// Small body text for secondary content
    static let bodySmall = Font.system(size: 14, weight: .regular, design: .default)
    
    // MARK: - Label Styles
    
    /// Large label for buttons and controls
    static let labelLarge = Font.system(size: 16, weight: .semibold, design: .default)
    
    /// Medium label
    static let labelMedium = Font.system(size: 14, weight: .semibold, design: .default)
    
    /// Small label for captions
    static let labelSmall = Font.system(size: 12, weight: .medium, design: .default)
    
    // MARK: - Monospaced Styles
    
    /// Monospaced for citation numbers
    static let citationNumber = Font.system(size: 24, weight: .bold, design: .monospaced)
    
    /// Monospaced small for details
    static let monospacedSmall = Font.system(size: 14, weight: .regular, design: .monospaced)
    
    /// Monospaced caption
    static let monospacedCaption = Font.system(size: 12, weight: .regular, design: .monospaced)
}

// MARK: - Text Style Extensions

extension View {
    /// Apply display large style
    func displayLarge() -> some View {
        self.font(AppTypography.displayLarge)
    }
    
    /// Apply headline large style
    func headlineLarge() -> some View {
        self.font(AppTypography.headlineLarge)
    }
    
    /// Apply title large style
    func titleLarge() -> some View {
        self.font(AppTypography.titleLarge)
    }
    
    /// Apply body large style
    func bodyLarge() -> some View {
        self.font(AppTypography.bodyLarge)
    }
    
    /// Apply body medium style
    func bodyMedium() -> some View {
        self.font(AppTypography.bodyMedium)
    }
    
    /// Apply label large style
    func labelLarge() -> some View {
        self.font(AppTypography.labelLarge)
    }
    
    /// Apply citation number style
    func citationNumber() -> some View {
        self.font(AppTypography.citationNumber)
    }
}

// MARK: - Dynamic Type Support

/// Custom text style with dynamic type support
struct AdaptiveTextStyle: ViewModifier {
    let style: TextStyle
    
    enum TextStyle {
        case display, headline, title, body, label, monospaced
        case citationNumber
    }
    
    @Environment(\.sizeCategory) var sizeCategory
    
    func body(content: Content) -> some View {
        switch style {
        case .display:
            Text(content)
                .font(.system(size: scaledSize(base: 57), weight: .bold))
        case .headline:
            Text(content)
                .font(.system(size: scaledSize(base: 32), weight: .semibold))
        case .title:
            Text(content)
                .font(.system(size: scaledSize(base: 22), weight: .bold))
        case .body:
            Text(content)
                .font(.system(size: scaledSize(base: 17), weight: .regular))
        case .label:
            Text(content)
                .font(.system(size: scaledSize(base: 16), weight: .semibold))
        case .monospaced:
            Text(content)
                .font(.system(size: scaledSize(base: 14), weight: .regular, design: .monospaced))
        case .citationNumber:
            Text(content)
                .font(.system(size: scaledSize(base: 24), weight: .bold, design: .monospaced))
        }
    }
    
    private func scaledSize(base: CGFloat) -> CGFloat {
        // Scale based on accessibility size category
        let scaleFactor: CGFloat
        switch sizeCategory {
        case .extraSmall: scaleFactor = 0.85
        case .small: scaleFactor = 0.9
        case .medium: scaleFactor = 1.0
        case .large: scaleFactor = 1.1
        case .extraLarge: scaleFactor = 1.2
        case .extraExtraLarge: scaleFactor = 1.3
        case .extraExtraExtraLarge: scaleFactor = 1.4
        case .accessibilityMedium: scaleFactor = 1.5
        case .accessibilityLarge: scaleFactor = 1.7
        case .accessibilityExtraLarge: scaleFactor = 1.9
        case .accessibilityExtraExtraLarge: scaleFactor = 2.1
        case .accessibilityExtraExtraExtraLarge: scaleFactor = 2.3
        @unknown default: scaleFactor = 1.0
        }
        return base * scaleFactor
    }
}

extension View {
    func adaptiveTextStyle(_ style: AdaptiveTextStyle.TextStyle) -> some View {
        modifier(AdaptiveTextStyle(style: style))
    }
}
