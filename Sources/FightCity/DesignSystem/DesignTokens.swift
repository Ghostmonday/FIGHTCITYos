//
//  DesignTokens.swift
//  FightCity
//
//  Premium design tokens for consistent spacing, radius, and animations
//

import SwiftUI

// MARK: - Spacing Tokens

/// Consistent spacing values throughout the app
/// TIP: Use these instead of magic numbers. When in doubt, prefer FCSpacing.md (16pt)
/// This ensures visual consistency across all screens.
public enum FCSpacing {
    public static let xxs: CGFloat = 4
    public static let xs: CGFloat = 8
    public static let sm: CGFloat = 12
    public static let md: CGFloat = 16
    public static let lg: CGFloat = 24
    public static let xl: CGFloat = 32
    public static let xxl: CGFloat = 48
    public static let xxxl: CGFloat = 64
    
    public static let screenEdge: CGFloat = 20
    public static let cardPadding: CGFloat = 16
    public static let itemSpacing: CGFloat = 12
    public static let sectionSpacing: CGFloat = 32
}

// MARK: - Corner Radius Tokens

/// Consistent corner radius values
/// TIP: FCRadius.lg (16pt) is perfect for cards, FCRadius.md (12pt) for buttons
/// Avoid using different radius values inconsistently.
public enum FCRadius {
    public static let sm: CGFloat = 8
    public static let md: CGFloat = 12
    public static let lg: CGFloat = 16
    public static let xl: CGFloat = 24
    public static let full: CGFloat = 9999  // For pills/fully rounded
    
    public static let button: CGFloat = 12
    public static let card: CGFloat = 16
    public static let buttonLarge: CGFloat = 16
}

// MARK: - Animation Tokens

/// Consistent animation definitions
/// TIP: Use FCAnimation.spring for interactions, FCAnimation.smooth for transitions
/// Quick animations (<0.2s) feel snappy, spring animations add delight
public enum FCAnimation {
    public static let quick: Animation = .easeOut(duration: 0.2)
    public static let smooth: Animation = .easeInOut(duration: 0.35)
    public static let spring: Animation = .spring(response: 0.5, dampingFraction: 0.8)
    public static let springBouncy: Animation = .spring(response: 0.4, dampingFraction: 0.6)
    public static let scale: Animation = .spring(response: 0.3, dampingFraction: 0.7)
    
    public static func easeOut(duration: Double = 0.3) -> Animation {
        .easeOut(duration: duration)
    }
    
    public static func easeInOut(duration: Double = 0.4) -> Animation {
        .easeInOut(duration: duration)
    }
}

// MARK: - Shadow Tokens

/// Consistent shadow definitions for depth
public enum FCShadow {
    public static let subtle = ShadowToken(radius: 2, x: 0, y: 1, opacity: 0.05)
    public static let card = ShadowToken(radius: 8, x: 0, y: 4, opacity: 0.1)
    public static let elevated = ShadowToken(radius: 16, x: 0, y: 8, opacity: 0.15)
    public static let popover = ShadowToken(radius: 24, x: 0, y: 12, opacity: 0.2)
    
    public struct ShadowToken {
        public let radius: CGFloat
        public let x: CGFloat
        public let y: CGFloat
        public let opacity: Double
        
        public func apply(to view: some View) -> some View {
            view.shadow(color: .black.opacity(opacity), radius: radius, x: x, y: y)
        }
    }
}

// MARK: - Opacity Tokens

/// Semantic opacity values
public enum FCOpacity {
    public static let disabled: CGFloat = 0.5
    public static let secondary: CGFloat = 0.6
    public static let tertiary: CGFloat = 0.4
    public static let overlay: CGFloat = 0.3
    public static let background: CGFloat = 0.05
}

// MARK: - Size Tokens

/// Standard sizing for UI elements
public enum FCSize {
    public static let iconSmall: CGFloat = 20
    public static let iconMedium: CGFloat = 24
    public static let iconLarge: CGFloat = 32
    public static let iconXL: CGFloat = 48
    
    public static let buttonHeight: CGFloat = 56
    public static let buttonHeightSmall: CGFloat = 44
    public static let buttonHeightLarge: CGFloat = 64
    
    public static let minimumTouchTarget: CGFloat = 44
    public static let cornerIconSize: CGFloat = 44
    
    public static let avatarSize: CGFloat = 40
    public static let avatarSizeLarge: CGFloat = 64
}

// MARK: - Grid System

/// Grid layout helpers
public enum FCGrid {
    public static let columns = 12
    public static let gutter: CGFloat = 16
    
    public static func columnWidth(for totalWidth: CGFloat, columns: Int = 12) -> CGFloat {
        (totalWidth - (CGFloat(columns + 1) * gutter)) / CGFloat(columns)
    }
}

// MARK: - Duration Tokens

/// Animation and timing durations
public enum FCDuration {
    public static let veryShort: Double = 0.1
    public static let short: Double = 0.2
    public static let medium: Double = 0.3
    public static let long: Double = 0.5
    public static let veryLong: Double = 0.8
}

// MARK: - Scale Factors

/// Text scale factors for accessibility
public enum FCScale {
    public static let caption: CGFloat = 0.85
    public static let body: CGFloat = 1.0
    public static let heading: CGFloat = 1.25
    public static let title: CGFloat = 1.5
    public static let display: CGFloat = 2.0
}

// MARK: - View Extensions

extension View {
    /// Apply spacing tokens
    public func padding(_ edges: Edge.Set = .all, _ token: FCSpacing.Type = FCSpacing.self) -> some View {
        padding(edges, token.md)
    }
    
    /// Apply corner radius
    public func cornerRadius(_ token: FCRadius.Type = FCRadius.self, _ style: FCRadius.Type = FCRadius.self) -> some View {
        cornerRadius(token.md)
    }
    
    /// Apply animation
    public func animate(_ token: FCAnimation.Type = FCAnimation.self, _ animation: FCAnimation.Type = FCAnimation.self) -> some View {
        animation(.smooth)
    }
}
