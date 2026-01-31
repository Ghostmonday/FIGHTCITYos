//
//  OnboardingView.swift
//  FightCity
//
//  Onboarding flow for new users
//

import SwiftUI

public struct OnboardingView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    @State private var currentPage = 0
    
    private let pages: [OnboardingPage] = [
        OnboardingPage(
            imageName: "onboarding_scan",
            icon: "camera.viewfinder",
            title: "Scan Your Ticket",
            description: "Use your camera to scan parking ticket citation numbers quickly and accurately."
        ),
        OnboardingPage(
            imageName: "onboarding_verify",
            icon: "checkmark.circle",
            title: "Verify Details",
            description: "Review the extracted information and make corrections if needed."
        ),
        OnboardingPage(
            imageName: "onboarding_status",
            icon: "doc.text.magnifyingglass",
            title: "Check Status",
            description: "Look up your appeal status and deadline for any ticket."
        ),
        OnboardingPage(
            imageName: "onboarding_fight",
            icon: "shield.checkered",
            title: "Fight Your Ticket",
            description: "Get assistance with contesting valid tickets and avoiding fines."
        )
    ]
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            // Page indicator
            HStack(spacing: 8) {
                ForEach(0..<pages.count, id: \.self) { index in
                    Circle()
                        .fill(index == currentPage ? AppColors.primary : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                        .animation(.easeInOut, value: currentPage)
                }
            }
            .padding(.top, 32)
            
            // Page content
            TabView(selection: $currentPage) {
                ForEach(0..<pages.count, id: \.self) { index in
                    pageContent(pages[index])
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: currentPage)
            
            // Navigation buttons
            VStack(spacing: 16) {
                if currentPage < pages.count - 1 {
                    PrimaryButton(title: "Next", action: {
                        withAnimation {
                            currentPage += 1
                        }
                    })
                    
                    SecondaryButton(title: "Skip", action: {
                        completeOnboarding()
                    })
                } else {
                    PrimaryButton(title: "Get Started", action: {
                        completeOnboarding()
                    })
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 48)
        }
        .background(AppColors.background)
    }
    
    private func pageContent(_ page: OnboardingPage) -> some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Icon
            Image(systemName: page.icon)
                .font(.system(size: 80))
                .foregroundColor(AppColors.primary)
                .padding()
            
            Text(page.title)
                .font(AppTypography.headlineMedium)
                .foregroundColor(AppColors.onBackground)
                .multilineTextAlignment(.center)
            
            Text(page.description)
                .font(AppTypography.bodyLarge)
                .foregroundColor(AppColors.onSurfaceVariant)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Spacer()
            Spacer()
        }
    }
    
    private func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        coordinator.navigateToRoot()
    }
}

// MARK: - Onboarding Page Model

struct OnboardingPage {
    let imageName: String?
    let icon: String
    let title: String
    let description: String
    
    init(imageName: String? = nil, icon: String, title: String, description: String) {
        self.imageName = imageName
        self.icon = icon
        self.title = title
        self.description = description
    }
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
