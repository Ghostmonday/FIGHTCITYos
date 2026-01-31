//
//  OnboardingView.swift
//  FightCity
//
//  Premium onboarding experience - Apple Design Award quality
//  Full-screen hero pages with parallax, bold typography, spring animations
//

import SwiftUI

// MARK: - Onboarding View

public struct OnboardingView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    @State private var currentPage = 0
    @State private var dragOffset: CGFloat = 0
    @State private var hasAppeared = false
    
    private let pages: [OnboardingPage] = [
        OnboardingPage(
            id: 0,
            imageName: "onboarding_scan",
            icon: "viewfinder",
            headline: "Scan",
            title: "Capture Your Ticket",
            description: "Point your camera at any parking ticket. Our AI instantly recognizes citation numbers with precision accuracy.",
            accentColor: AppColors.gold
        ),
        OnboardingPage(
            id: 1,
            imageName: "onboarding_verify",
            icon: "checkmark.seal.fill",
            headline: "Verify",
            title: "Confirm Details",
            description: "Review extracted information with confidence scores. Edit if needed - you're always in control.",
            accentColor: AppColors.success
        ),
        OnboardingPage(
            id: 2,
            imageName: "onboarding_status",
            icon: "magnifyingglass",
            headline: "Track",
            title: "Monitor Status",
            description: "Track deadlines, appeal status, and payment due dates. Never miss an important date again.",
            accentColor: AppColors.warning
        ),
        OnboardingPage(
            id: 3,
            imageName: "onboarding_fight",
            icon: "shield.checkered",
            headline: "Fight",
            title: "Win Your Case",
            description: "AI-powered appeal assistance helps you contest unfair tickets with professional-grade arguments.",
            accentColor: AppColors.gold
        )
    ]
    
    public init() {}
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background gradient
                AppColors.heroGradient
                    .ignoresSafeArea()
                
                // Page content
                TabView(selection: $currentPage) {
                    ForEach(pages) { page in
                        OnboardingPageView(
                            page: page,
                            isActive: currentPage == page.id,
                            geometry: geometry
                        )
                        .tag(page.id)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: currentPage)
                .onChange(of: currentPage) { _ in
                    FCHaptics.pageChange()
                }
                
                // Overlay controls
                VStack {
                    // Skip button (top right)
                    HStack {
                        Spacer()
                        if currentPage < pages.count - 1 {
                            Button(action: {
                                FCHaptics.lightImpact()
                                completeOnboarding()
                            }) {
                                Text("Skip")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(AppColors.textSecondary)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                            }
                        }
                    }
                    .padding(.top, 8)
                    .padding(.horizontal, 20)
                    
                    Spacer()
                    
                    // Bottom controls
                    bottomControls
                        .padding(.bottom, 50)
                }
            }
        }
        .onAppear {
            FCHaptics.prepare()
            withAnimation(.easeOut(duration: 0.8).delay(0.2)) {
                hasAppeared = true
            }
        }
        .preferredColorScheme(.dark)
    }
    
    // MARK: - Bottom Controls
    
    private var bottomControls: some View {
        VStack(spacing: 24) {
            // Page indicator
            HStack(spacing: 12) {
                ForEach(0..<pages.count, id: \.self) { index in
                    Capsule()
                        .fill(index == currentPage ? AppColors.gold : AppColors.glass)
                        .frame(width: index == currentPage ? 32 : 8, height: 8)
                        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: currentPage)
                }
            }
            
            // Action button
            if currentPage < pages.count - 1 {
                // Next button
                Button(action: {
                    FCHaptics.mediumImpact()
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        currentPage += 1
                    }
                }) {
                    HStack(spacing: 8) {
                        Text("Continue")
                            .font(.system(size: 18, weight: .semibold))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(AppColors.obsidian)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(AppColors.goldGradient)
                    .cornerRadius(16)
                    .shadow(color: AppColors.gold.opacity(0.4), radius: 16, y: 8)
                }
                .padding(.horizontal, 24)
                .accessibilityLabel("Continue to next page")
                .accessibilityHint("Page \(currentPage + 1) of \(pages.count)")
            } else {
                // Get Started button
                Button(action: {
                    FCHaptics.success()
                    completeOnboarding()
                }) {
                    HStack(spacing: 8) {
                        Text("Get Started")
                            .font(.system(size: 18, weight: .bold))
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.system(size: 20, weight: .semibold))
                    }
                    .foregroundColor(AppColors.obsidian)
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(AppColors.goldGradient)
                    .cornerRadius(16)
                    .shadow(color: AppColors.gold.opacity(0.5), radius: 20, y: 10)
                }
                .padding(.horizontal, 24)
                .scaleEffect(hasAppeared ? 1.0 : 0.9)
                .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.3), value: hasAppeared)
                .accessibilityLabel("Get Started")
                .accessibilityHint("Complete onboarding and start using the app")
            }
        }
    }
    
    // MARK: - Actions
    
    private func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        coordinator.navigateToRoot()
    }
}

// MARK: - Onboarding Page View

struct OnboardingPageView: View {
    let page: OnboardingPage
    let isActive: Bool
    let geometry: GeometryProxy
    
    @State private var imageOpacity: Double = 0
    @State private var textOpacity: Double = 0
    @State private var textOffset: CGFloat = 30
    
    var body: some View {
        ZStack {
            // Hero image background
            Image(page.imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: geometry.size.width, height: geometry.size.height * 0.55)
                .clipped()
                .overlay(
                    // Gradient overlay for text readability
                    LinearGradient(
                        colors: [
                            AppColors.obsidian.opacity(0.3),
                            AppColors.obsidian.opacity(0.7),
                            AppColors.obsidian
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .opacity(imageOpacity)
                .offset(y: -geometry.size.height * 0.15)
            
            // Content overlay
            VStack(spacing: 0) {
                Spacer()
                
                // Text content
                VStack(alignment: .leading, spacing: 16) {
                    // Headline badge
                    Text(page.headline.uppercased())
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .tracking(3)
                        .foregroundColor(page.accentColor)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(page.accentColor.opacity(0.15))
                        .cornerRadius(20)
                    
                    // Title
                    Text(page.title)
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(2)
                    
                    // Description
                    Text(page.description)
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(AppColors.textSecondary)
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, 24)
                .opacity(textOpacity)
                .offset(y: textOffset)
                
                Spacer()
                    .frame(height: 180) // Space for bottom controls
            }
        }
        .onChange(of: isActive) { active in
            if active {
                animateIn()
            } else {
                resetAnimation()
            }
        }
        .onAppear {
            if isActive {
                animateIn()
            }
        }
    }
    
    private func animateIn() {
        withAnimation(.easeOut(duration: 0.6)) {
            imageOpacity = 1
        }
        withAnimation(.easeOut(duration: 0.5).delay(0.2)) {
            textOpacity = 1
            textOffset = 0
        }
    }
    
    private func resetAnimation() {
        imageOpacity = 0
        textOpacity = 0
        textOffset = 30
    }
}

// MARK: - Onboarding Page Model

struct OnboardingPage: Identifiable {
    let id: Int
    let imageName: String
    let icon: String
    let headline: String
    let title: String
    let description: String
    let accentColor: Color
}

// MARK: - Previews

#if DEBUG
struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
            .environmentObject(AppCoordinator())
    }
}
#endif
