//
//  Typography.swift
//  FightCity
//
//  App typography system
//

import SwiftUI

// MARK: - Typography

/// App typography system
public enum AppTypography {
    // MARK: - Display Styles
    
    public static let displayLarge = Font.system(size: 57, weight: .bold, design: .default)
    public static let displayMedium = Font.system(size: 45, weight: .bold, design: .default)
    public static let displaySmall = Font.system(size: 36, weight: .bold, design: .default)
    
    // MARK: - Headline Styles
    
    public static let headlineLarge = Font.system(size: 32, weight: .semibold, design: .default)
    public static let headlineMedium = Font.system(size: 28, weight: .semibold, design: .default)
    public static let headlineSmall = Font.system(size: 24, weight: .semibold, design: .default)
    
    // MARK: - Title Styles
    
    public static let titleLarge = Font.system(size: 22, weight: .semibold, design: .default)
    public static let titleMedium = Font.system(size: 16, weight: .medium, design: .default)
    public static let titleSmall = Font.system(size: 14, weight: .medium, design: .default)
    
    // MARK: - Body Styles
    
    public static let bodyLarge = Font.system(size: 16, weight: .regular, design: .default)
    public static let bodyMedium = Font.system(size: 14, weight: .regular, design: .default)
    public static let bodySmall = Font.system(size: 12, weight: .regular, design: .default)
    
    // MARK: - Label Styles
    
    public static let labelLarge = Font.system(size: 14, weight: .medium, design: .default)
    public static let labelMedium = Font.system(size: 12, weight: .medium, design: .default)
    public static let labelSmall = Font.system(size: 11, weight: .medium, design: .default)
    
    // MARK: - Special Styles
    
    /// For citation numbers
    public static let citationNumber = Font.system(size: 24, weight: .bold, design: .monospaced)
    
    /// For monetary amounts
    public static let monetaryAmount = Font.system(size: 32, weight: .bold, design: .default)
    
    /// For OCR confidence scores
    public static let confidenceScore = Font.system(size: 14, weight: .semibold, design: .default)
}

// MARK: - Text Style Extensions

public extension Font {
    static func appDisplay(_ style: AppTypography.DisplayStyle) -> Font {
        switch style {
        case .large: return AppTypography.displayLarge
        case .medium: return AppTypography.displayMedium
        case .small: return AppTypography.displaySmall
        }
    }
    
    static func appHeadline(_ style: AppTypography.HeadlineStyle) -> Font {
        switch style {
        case .large: return AppTypography.headlineLarge
        case .medium: return AppTypography.headlineMedium
        case .small: return AppTypography.headlineSmall
        }
    }
    
    static func appTitle(_ style: AppTypography.TitleStyle) -> Font {
        switch style {
        case .large: return AppTypography.titleLarge
        case .medium: return AppTypography.titleMedium
        case .small: return AppTypography.titleSmall
        }
    }
    
    static func appBody(_ style: AppTypography.BodyStyle) -> Font {
        switch style {
        case .large: return AppTypography.bodyLarge
        case .medium: return AppTypography.bodyMedium
        case .small: return AppTypography.bodySmall
        }
    }
    
    static func appLabel(_ style: AppTypography.LabelStyle) -> Font {
        switch style {
        case .large: return AppTypography.labelLarge
        case .medium: return AppTypography.labelMedium
        case .small: return AppTypography.labelSmall
        }
    }
}

// MARK: - Typography Styles

public extension AppTypography {
    enum DisplayStyle {
        case large, medium, small
    }
    
    enum HeadlineStyle {
        case large, medium, small
    }
    
    enum TitleStyle {
        case large, medium, small
    }
    
    enum BodyStyle {
        case large, medium, small
    }
    
    enum LabelStyle {
        case large, medium, small
    }
}

// MARK: - Line Height Extensions

public extension Text {
    func appLineHeight(_ lineHeight: CGFloat) -> some View {
        self.font(.body).lineSpacing(lineHeight - AppTypography.bodyLarge.lineHeight)
    }
}
