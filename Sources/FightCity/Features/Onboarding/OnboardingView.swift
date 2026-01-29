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
            icon: "camera.viewfinder",
            title: "Scan Your Ticket",
            description: "Use your camera to scan parking ticket citation numbers quickly and accurately."
        ),
        OnboardingPage(
            icon: "checkmark.circle",
            title: "Verify Details",
            description: "Review the extracted information and make corrections if needed."
        ),
        OnboardingPage(
            icon: "doc.text.magnifyingglass",
            title: "Check Status",
            description: "Look up your appeal status and deadline for any ticket."
        ),
        OnboardingPage(
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
                        .fill(index == currentPage ? Color.accentColor : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
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
        .background(Color(.systemBackground))
    }
    
    private func pageContent(_ page: OnboardingPage) -> some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: page.icon)
                .font(.system(size: 80))
                .foregroundColor(.accentColor)
                .padding()
            
            Text(page.title)
                .font(AppTypography.headlineMedium)
                .multilineTextAlignment(.center)
            
            Text(page.description)
                .font(AppTypography.bodyLarge)
                .foregroundColor(.secondary)
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
    let icon: String
    let title: String
    let description: String
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
