//
//  ContentView.swift
//  FightCity
//
//  Root content view - Premium iOS experience
//  Apple Design Award quality navigation and home screen
//

import SwiftUI
import FightCityiOS

// MARK: - Content View

public struct ContentView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    @EnvironmentObject private var config: AppConfig
    
    public init() {}
    
    public var body: some View {
        NavigationStack(path: $coordinator.navigationPath) {
            Group {
                if shouldShowOnboarding {
                    OnboardingView()
                } else {
                    MainTabView()
                }
            }
            .navigationDestination(for: NavigationDestination.self) { destination in
                destinationView(for: destination)
            }
            .sheet(isPresented: $coordinator.isShowingSheet) {
                if let sheet = coordinator.selectedSheet {
                    sheetView(for: sheet)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private var shouldShowOnboarding: Bool {
        !UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    }
    
    @ViewBuilder
    private func destinationView(for destination: NavigationDestination) -> some View {
        switch destination {
        case .onboarding:
            OnboardingView()
        case .capture:
            CaptureView()
        case .confirmation(let result):
            ConfirmationView(
                captureResult: result,
                onConfirm: { result in
                    coordinator.navigateToRoot()
                },
                onRetake: {
                    coordinator.navigateBack()
                },
                onEdit: { _ in }
            )
        case .history:
            HistoryView()
        case .settings:
            SettingsView()
        }
    }
    
    @ViewBuilder
    private func sheetView(for sheet: AppCoordinator.SheetDestination) -> some View {
        switch sheet {
        case .citySelection:
            CitySelectionSheet()
        case .telemetryOptIn:
            TelemetryOptInSheet()
        case .editCitation(let result):
            EditCitationSheet(result: result)
        }
    }
}

// MARK: - Main Tab View

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Image(systemName: selectedTab == 0 ? "house.fill" : "house")
                    Text("Home")
                }
                .tag(0)
            
            HistoryView()
                .tabItem {
                    Image(systemName: selectedTab == 1 ? "clock.fill" : "clock")
                    Text("History")
                }
                .tag(1)
            
            SettingsView()
                .tabItem {
                    Image(systemName: selectedTab == 2 ? "gearshape.fill" : "gearshape")
                    Text("Settings")
                }
                .tag(2)
        }
        .tint(AppColors.gold)
        .onAppear {
            // Premium tab bar styling
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(AppColors.surface)
            appearance.stackedLayoutAppearance.selected.iconColor = UIColor(AppColors.gold)
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(AppColors.gold)]
            appearance.stackedLayoutAppearance.normal.iconColor = UIColor(AppColors.textTertiary)
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(AppColors.textTertiary)]
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}

// MARK: - Home View (Hero Screen)

struct HomeView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    @State private var hasAppeared = false
    @State private var pulseAnimation = false
    
    var body: some View {
        ZStack {
            // Background
            AppColors.background
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Hero section
                    heroSection
                    
                    // Quick actions
                    quickActionsSection
                        .padding(.top, 24)
                    
                    // Recent activity
                    recentActivitySection
                        .padding(.top, 32)
                    
                    Spacer(minLength: 100)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            FCHaptics.prepare()
            withAnimation(.easeOut(duration: 0.6)) {
                hasAppeared = true
            }
            // Start pulse animation
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                pulseAnimation = true
            }
        }
    }
    
    // MARK: - Hero Section
    
    private var heroSection: some View {
        VStack(spacing: 24) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("FIGHTCITY")
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .tracking(2)
                        .foregroundColor(.white)
                    
                    HStack(spacing: 6) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 12))
                        Text("Powered by Apple Intelligence")
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundColor(AppColors.gold)
                }
                
                Spacer()
                
                // Settings button
                Button(action: {
                    FCHaptics.lightImpact()
                    coordinator.navigateTo(.settings)
                }) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 20))
                        .foregroundColor(AppColors.textSecondary)
                        .frame(width: 44, height: 44)
                        .background(AppColors.glass)
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 60)
            
            // Hero scan button
            Button(action: {
                FCHaptics.heavyImpact()
                coordinator.startCaptureFlow()
            }) {
                ZStack {
                    // Glow effect
                    Circle()
                        .fill(AppColors.gold.opacity(0.15))
                        .frame(width: 220, height: 220)
                        .scaleEffect(pulseAnimation ? 1.1 : 1.0)
                    
                    Circle()
                        .fill(AppColors.gold.opacity(0.1))
                        .frame(width: 180, height: 180)
                        .scaleEffect(pulseAnimation ? 1.15 : 1.0)
                    
                    // Main button
                    VStack(spacing: 12) {
                        Image(systemName: "viewfinder")
                            .font(.system(size: 48, weight: .light))
                            .foregroundColor(AppColors.gold)
                        
                        Text("Scan Ticket")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    .frame(width: 160, height: 160)
                    .background(
                        Circle()
                            .fill(AppColors.surface)
                            .overlay(
                                Circle()
                                    .stroke(AppColors.gold.opacity(0.3), lineWidth: 2)
                            )
                    )
                    .shadow(color: AppColors.gold.opacity(0.3), radius: 20, y: 10)
                }
            }
            .scaleEffect(hasAppeared ? 1.0 : 0.8)
            .opacity(hasAppeared ? 1.0 : 0)
            .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1), value: hasAppeared)
            .padding(.vertical, 20)
            .accessibilityLabel("Scan Ticket")
            .accessibilityHint("Opens camera to scan a parking ticket")
        }
    }
    
    // MARK: - Quick Actions
    
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Actions")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(AppColors.textTertiary)
                .textCase(.uppercase)
                .tracking(1)
                .padding(.horizontal, 20)
            
            HStack(spacing: 12) {
                // Manual entry
                QuickActionCard(
                    icon: "keyboard",
                    title: "Manual Entry",
                    subtitle: "Type citation #"
                ) {
                    FCHaptics.lightImpact()
                    // Show manual entry
                }
                
                // View history
                QuickActionCard(
                    icon: "clock.arrow.circlepath",
                    title: "History",
                    subtitle: "Past tickets"
                ) {
                    FCHaptics.lightImpact()
                    coordinator.navigateTo(.history)
                }
            }
            .padding(.horizontal, 20)
        }
        .opacity(hasAppeared ? 1.0 : 0)
        .offset(y: hasAppeared ? 0 : 20)
        .animation(.easeOut(duration: 0.5).delay(0.3), value: hasAppeared)
    }
    
    // MARK: - Recent Activity
    
    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recent Activity")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(AppColors.textTertiary)
                    .textCase(.uppercase)
                    .tracking(1)
                
                Spacer()
                
                Button(action: {
                    coordinator.navigateTo(.history)
                }) {
                    Text("See All")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppColors.gold)
                }
            }
            .padding(.horizontal, 20)
            
            // Empty state or recent items
            VStack(spacing: 12) {
                EmptyActivityCard()
            }
            .padding(.horizontal, 20)
        }
        .opacity(hasAppeared ? 1.0 : 0)
        .offset(y: hasAppeared ? 0 : 20)
        .animation(.easeOut(duration: 0.5).delay(0.4), value: hasAppeared)
    }
}

// MARK: - Quick Action Card

struct QuickActionCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(AppColors.gold)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text(subtitle)
                        .font(.system(size: 13))
                        .foregroundColor(AppColors.textTertiary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(AppColors.surface)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(AppColors.glassBorder, lineWidth: 1)
            )
        }
    }
}

// MARK: - Empty Activity Card

struct EmptyActivityCard: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 32))
                .foregroundColor(AppColors.textTertiary)
            
            VStack(spacing: 4) {
                Text("No tickets yet")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(AppColors.textSecondary)
                
                Text("Scan your first ticket to get started")
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.textTertiary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(32)
        .background(AppColors.surface)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppColors.glassBorder, lineWidth: 1)
        )
    }
}

// MARK: - City Selection Sheet

struct CitySelectionSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var config: AppConfig
    
    var body: some View {
        NavigationStack {
            List(config.supportedCities) { city in
                Button(action: {
                    FCHaptics.selection()
                    dismiss()
                }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(city.name)
                                .font(.system(size: 17, weight: .medium))
                                .foregroundColor(.white)
                            Text(city.state)
                                .font(.system(size: 14))
                                .foregroundColor(AppColors.textSecondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(AppColors.textTertiary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(AppColors.background)
            .navigationTitle("Select City")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(AppColors.gold)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}

// MARK: - Telemetry Opt-In Sheet

struct TelemetryOptInSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var config: AppConfig
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()
                
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 56))
                    .foregroundColor(AppColors.gold)
                
                VStack(spacing: 12) {
                    Text("Improve Recognition")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Share anonymous usage data to help us improve text recognition accuracy for everyone.")
                        .font(.system(size: 16))
                        .foregroundColor(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
                
                Spacer()
                
                VStack(spacing: 12) {
                    Button(action: {
                        FCHaptics.success()
                        config.setTelemetryEnabled(true)
                        dismiss()
                    }) {
                        Text("Enable")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(AppColors.obsidian)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(AppColors.goldGradient)
                            .cornerRadius(14)
                    }
                    
                    Button(action: {
                        FCHaptics.lightImpact()
                        dismiss()
                    }) {
                        Text("Not Now")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(AppColors.textSecondary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
            .background(AppColors.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Skip") {
                        dismiss()
                    }
                    .foregroundColor(AppColors.textSecondary)
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}

// MARK: - Edit Citation Sheet

struct EditCitationSheet: View {
    @Environment(\.dismiss) private var dismiss
    let result: CaptureResult
    @State private var editedCitation: String = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Current")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(AppColors.textTertiary)
                        .textCase(.uppercase)
                    
                    Text(result.extractedCitationNumber ?? "Not detected")
                        .font(.system(size: 20, weight: .bold, design: .monospaced))
                        .foregroundColor(AppColors.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(AppColors.surface)
                .cornerRadius(12)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Edit Citation Number")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(AppColors.textTertiary)
                        .textCase(.uppercase)
                    
                    TextField("", text: $editedCitation)
                        .font(.system(size: 24, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                        .textInputAutocapitalization(.characters)
                        .padding(16)
                        .background(AppColors.surface)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(AppColors.gold.opacity(0.5), lineWidth: 2)
                        )
                }
                
                Spacer()
                
                Button(action: {
                    FCHaptics.success()
                    dismiss()
                }) {
                    Text("Save Changes")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(AppColors.obsidian)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(AppColors.goldGradient)
                        .cornerRadius(14)
                }
            }
            .padding(24)
            .background(AppColors.background)
            .navigationTitle("Edit Citation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(AppColors.gold)
                }
            }
        }
        .onAppear {
            editedCitation = result.extractedCitationNumber ?? ""
        }
    }
}

// MARK: - Settings View

struct SettingsView: View {
    @EnvironmentObject private var config: AppConfig
    @EnvironmentObject private var coordinator: AppCoordinator
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        List {
            // App section
            Section {
                SettingsRow(icon: "location.fill", title: "City", value: "Auto-detect") {
                    coordinator.showSheet(.citySelection)
                }
            } header: {
                Text("App")
            }
            
            // Privacy section
            Section {
                Toggle(isOn: $config.telemetryEnabled) {
                    HStack(spacing: 12) {
                        Image(systemName: "chart.bar.fill")
                            .font(.system(size: 18))
                            .foregroundColor(AppColors.gold)
                            .frame(width: 28)
                        
                        Text("Improve Recognition")
                            .font(.system(size: 17))
                            .foregroundColor(.white)
                    }
                }
                .tint(AppColors.gold)
            } header: {
                Text("Privacy")
            } footer: {
                Text("Help improve text recognition by sharing anonymous usage data.")
            }
            
            // About section
            Section {
                HStack {
                    Text("Version")
                        .foregroundColor(.white)
                    Spacer()
                    Text("1.0.0")
                        .foregroundColor(AppColors.textSecondary)
                }
                
                    if let privacyURL = URL(string: "https://fightcitytickets.com/privacy") {
                        Link(destination: privacyURL) {
                            HStack {
                                Text("Privacy Policy")
                                    .foregroundColor(.white)
                                Spacer()
                                Image(systemName: "arrow.up.right")
                                    .font(.system(size: 14))
                                    .foregroundColor(AppColors.textTertiary)
                            }
                        }
                    }
                    
                    if let termsURL = URL(string: "https://fightcitytickets.com/terms") {
                        Link(destination: termsURL) {
                            HStack {
                                Text("Terms of Service")
                                    .foregroundColor(.white)
                                Spacer()
                                Image(systemName: "arrow.up.right")
                                    .font(.system(size: 14))
                                    .foregroundColor(AppColors.textTertiary)
                            }
                        }
                    }
            } header: {
                Text("About")
            }
            
            #if DEBUG
            // Debug section
            Section {
                Button(action: {
                    UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
                    FCHaptics.warning()
                }) {
                    Text("Reset Onboarding")
                        .foregroundColor(AppColors.warning)
                }
            } header: {
                Text("Debug")
            }
            #endif
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(AppColors.background)
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .foregroundColor(AppColors.textSecondary)
                }
            }
        }
    }
}

// MARK: - Settings Row

struct SettingsRow: View {
    let icon: String
    let title: String
    let value: String
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            FCHaptics.lightImpact()
            action()
        }) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(AppColors.gold)
                    .frame(width: 28)
                
                Text(title)
                    .font(.system(size: 17))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text(value)
                    .font(.system(size: 15))
                    .foregroundColor(AppColors.textSecondary)
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppColors.textTertiary)
            }
        }
    }
}

// MARK: - Previews

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AppCoordinator())
            .environmentObject(AppConfig.shared)
    }
}
#endif
