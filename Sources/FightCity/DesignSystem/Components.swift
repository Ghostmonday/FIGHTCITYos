//
//  Components.swift
//  FightCity
//
//  Premium UI components with haptics, animations, and polish
//

import SwiftUI
import FightCityFoundation

// MARK: - FCButton

/// Premium button with haptic feedback and loading states
/// TIP: Always use FCButton instead of SwiftUI Button for consistent UX
/// The haptic feedback is built-in and makes interactions feel premium
public struct FCButton: View {
    public enum ButtonStyle {
        case primary
        case secondary
        case ghost
        case destructive
    }
    
    private let title: String
    private let action: () -> Void
    private let style: ButtonStyle
    private let isEnabled: Bool
    private let isLoading: Bool
    private let icon: String?
    
    public init(
        _ title: String,
        style: ButtonStyle = .primary,
        isEnabled: Bool = true,
        isLoading: Bool = false,
        icon: String? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.action = action
        self.style = style
        self.isEnabled = isEnabled
        self.isLoading = isLoading
        self.icon = icon
    }
    
    public var body: some View {
        Button(action: {
            FCHaptics.primaryButtonTap()
            action()
        }) {
            HStack(spacing: FCSpacing.xs) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: foregroundColor))
                        .scaleEffect(0.9)
                } else if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                }
                
                Text(title)
                    .font(AppTypography.labelLarge)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .frame(height: FCSize.buttonHeight)
            .foregroundColor(foregroundColor)
            .background(background)
            .cornerRadius(FCRadius.button)
            .shadow(color: shadowColor, radius: 4, x: 0, y: 2)
            .opacity(opacity)
        }
        .disabled(!isEnabled || isLoading)
    }
    
    private var foregroundColor: Color {
        switch style {
        case .primary, .destructive:
            return .white
        case .secondary:
            return AppColors.primary
        case .ghost:
            return AppColors.primary
        }
    }
    
    private var background: Color {
        switch style {
        case .primary:
            return AppColors.primary
        case .secondary:
            return AppColors.surface
        case .ghost:
            return .clear
        case .destructive:
            return AppColors.error
        }
    }
    
    private var shadowColor: Color {
        switch style {
        case .primary, .destructive:
            return AppColors.primary.opacity(0.3)
        case .secondary, .ghost:
            return .clear
        }
    }
    
    private var opacity: Double {
        if !isEnabled { return FCOpacity.disabled }
        return 1.0
    }
}

// MARK: - FCCard

/// Premium glassmorphism card with subtle shadow
/// TIP: Use FCCard instead of plain VStacks for content sections
/// The shadow and rounded corners give depth and polish
public struct FCCard<Content: View>: View {
    private let content: Content
    private let hasPadding: Bool
    private let cornerRadius: CGFloat
    private let shadowStyle: FCShadow.ShadowToken?
    
    public init(
        hasPadding: Bool = true,
        cornerRadius: CGFloat = FCRadius.card,
        shadow: FCShadow.ShadowToken? = FCShadow.card,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.hasPadding = hasPadding
        self.cornerRadius = cornerRadius
        self.shadowStyle = shadow
    }
    
    public var body: some View {
        content
            .if(hasPadding) { view in
                view.padding(FCSpacing.cardPadding)
            }
            .background(AppColors.surface)
            .cornerRadius(cornerRadius)
            .if let shadow = shadowStyle { view in
                shadow.apply(to: view)
            }
    }
}

// MARK: - FCHeroSection

/// Hero section with gradient background
/// TIP: Use this for major screen headers - the gradient draws attention
/// Perfect for Onboarding, Home screen welcome, and feature highlights
public struct FCHeroSection<Content: View>: View {
    private let title: String
    private let subtitle: String?
    private let icon: String?
    private let gradient: LinearGradient
    private let content: Content
    
    public init(
        title: String,
        subtitle: String? = nil,
        icon: String? = nil,
        gradient: LinearGradient = AppColors.primaryGradient,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.gradient = gradient
        self.content = content()
    }
    
    public var body: some View {
        VStack(spacing: FCSpacing.md) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 48))
                    .foregroundColor(.white.opacity(0.9))
            }
            
            Text(title)
                .font(AppTypography.displaySmall)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(AppTypography.bodyLarge)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
            
            content
        }
        .frame(maxWidth: .infinity)
        .padding(FCSpacing.xxl)
        .background(gradient)
        .cornerRadius(FCRadius.lg)
    }
}

// MARK: - FCBadge

/// Animated status badge
/// TIP: Use FCBadge for citation status, deadlines, and category labels
/// The animation adds delight - don't overuse it though!
public struct FCBadge: View {
    public enum BadgeStyle {
        case primary
        case success
        case warning
        case error
        case info
        case neutral
    }
    
    private let text: String
    private let style: BadgeStyle
    private let isAnimated: Bool
    
    public init(_ text: String, style: BadgeStyle = .neutral, isAnimated: Bool = true) {
        self.text = text
        self.style = style
        self.isAnimated = isAnimated
    }
    
    public var body: some View {
        Text(text)
            .font(AppTypography.labelSmall)
            .fontWeight(.semibold)
            .padding(.horizontal, FCSpacing.sm)
            .padding(.vertical, FCSpacing.xxs)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .cornerRadius(FCRadius.full)
            .scaleEffect(isAnimated ? 1.0 : 1.0)
            .animation(isAnimated ? FCAnimation.spring : .none, value: text)
    }
    
    private var backgroundColor: Color {
        switch style {
        case .primary: return AppColors.primary.opacity(0.15)
        case .success: return AppColors.success.opacity(0.15)
        case .warning: return AppColors.warning.opacity(0.15)
        case .error: return AppColors.error.opacity(0.15)
        case .info: return AppColors.info.opacity(0.15)
        case .neutral: return AppColors.surfaceVariant
        }
    }
    
    private var foregroundColor: Color {
        switch style {
        case .primary: return AppColors.primary
        case .success: return AppColors.success
        case .warning: return AppColors.warning
        case .error: return AppColors.error
        case .info: return AppColors.info
        case .neutral: return AppColors.textPrimary
        }
    }
}

// MARK: - FCProgressRing

/// Animated confidence/progress ring
public struct FCProgressRing: View {
    private let progress: Double
    private let lineWidth: CGFloat
    private let gradient: LinearGradient
    
    public init(progress: Double, lineWidth: CGFloat = 6) {
        self.progress = max(0, min(1, progress))
        self.lineWidth = lineWidth
        self.gradient = LinearGradient(
            colors: [AppColors.success, AppColors.success.opacity(0.6)],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    public var body: some View {
        ZStack {
            Circle()
                .stroke(AppColors.surfaceVariant, lineWidth: lineWidth)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(gradient, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(FCAnimation.smooth, value: progress)
        }
    }
}

// MARK: - FCShimmer

/// Skeleton loading shimmer effect
/// TIP: Use this while loading data from APIs - much better than spinner
/// Creates professional "loading state" that feels like a native app
public struct FCShimmer: View {
    private let isAnimating: Bool
    
    public init(isAnimating: Bool = true) {
        self.isAnimating = isAnimating
    }
    
    public var body: some View {
        GeometryReader { geometry in
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            AppColors.surfaceVariant,
                            AppColors.surface,
                            AppColors.surfaceVariant
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .mask(
                    Rectangle()
                        .frame(width: geometry.size.width * 0.6)
                        .offset(x: isAnimating ? geometry.size.width : -geometry.size.width * 0.6)
                )
        }
        .animation(
            isAnimating ? Animation.linear(duration: 1.5).repeatForever(autoreverses: false) : .none,
            value: isAnimating
        )
    }
}

// MARK: - FCIconButton

/// Circular icon button with haptic feedback
public struct FCIconButton: View {
    private let icon: String
    private let action: () -> Void
    private let size: CGFloat
    private let backgroundColor: Color
    private let iconColor: Color
    
    public init(
        _ icon: String,
        size: CGFloat = FCSize.cornerIconSize,
        backgroundColor: Color = AppColors.surface,
        iconColor: Color = AppColors.textPrimary,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.action = action
        self.size = size
        self.backgroundColor = backgroundColor
        self.iconColor = iconColor
    }
    
    public var body: some View {
        Button(action: {
            FCHaptics.lightImpact()
            action()
        }) {
            Image(systemName: icon)
                .font(.system(size: size * 0.4, weight: .medium))
                .foregroundColor(iconColor)
                .frame(width: size, height: size)
                .background(backgroundColor)
                .cornerRadius(size / 2)
                .shadow(radius: 2, y: 1)
        }
    }
}

// MARK: - FCToggle

/// Premium toggle with haptic feedback
public struct FCToggle: View {
    @Binding private var isOn: Bool
    private let label: String
    private let icon: String?
    
    public init(_ label: String, icon: String? = nil, isOn: Binding<Bool>) {
        self._isOn = isOn
        self.label = label
        self.icon = icon
    }
    
    public var body: some View {
        Button(action: {
            FCHaptics.selection()
            isOn.toggle()
        }) {
            HStack {
                if let icon = icon {
                    Image(systemName: icon)
                        .foregroundColor(AppColors.textSecondary)
                        .frame(width: 24)
                }
                
                Text(label)
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
                
                Capsule()
                    .fill(isOn ? AppColors.primary : AppColors.surfaceVariant)
                    .frame(width: 52, height: 32)
                    .overlay(
                        Circle()
                            .fill(Color.white)
                            .padding(2)
                            .offset(x: isOn ? 10 : -10)
                    )
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - View Extension

extension View {
    /// Apply card styling
    public func asFCCard(cornerRadius: CGFloat = FCRadius.card) -> some View {
        self
            .background(AppColors.surface)
            .cornerRadius(cornerRadius)
            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
    }
    
    /// Apply shimmer effect
    public func shimmer(isAnimating: Bool = true) -> some View {
        self.overlay(
            FCShimmer(isAnimating: isAnimating)
                .mask(self),
            alignment: .leading
        )
    }
}
