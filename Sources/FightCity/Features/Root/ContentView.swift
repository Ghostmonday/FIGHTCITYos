//
//  ContentView.swift
//  FightCity
//
//  Root content view with navigation
//

import SwiftUI
import FightCityiOS

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
                    mainTabView
                }
            }
            .navigationDestination(for: NavigationDestination.self) { destination in
                navigationDestination(for: destination)
            }
            .sheet(isPresented: $coordinator.isShowingSheet) {
                if let sheet = coordinator.selectedSheet {
                    sheetDestination(sheet)
                }
            }
        }
    }
    
    private var shouldShowOnboarding: Bool {
        !UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    }
    
    private var mainTabView: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            HistoryView()
                .tabItem {
                    Label("History", systemImage: "clock.fill")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
    }
    
    @ViewBuilder
    private func navigationDestination(for destination: NavigationDestination) -> some View {
        switch destination {
        case .onboarding:
            OnboardingView()
            
        case .capture:
            CaptureView()
            
        case .confirmation(let result):
            // TODO: PHASE 1, TASK 1.5 - Fix ConfirmationView initialization
            // Current issue: ConfirmationView(result:) doesn't match actual init signature
            // ConfirmationView requires init(result:onConfirm:onEdit:onRetake:)
            //
            // Fix:
            ConfirmationView(
                captureResult: result,
                onConfirm: { result in
                    // Save to history
                    // Navigate to next step
                },
                onRetake: {
                    // Clear result and return to capture
                },
                onEdit: { citationNumber in
                    // Show edit sheet
                }
            )
            
        case .history:
            HistoryView()
            
        case .settings:
            SettingsView()
        }
    }
    
    @ViewBuilder
    private func sheetDestination(_ sheet: AppCoordinator.SheetDestination) -> some View {
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

// MARK: - Home View

struct HomeView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("FightCity")
                        .font(AppTypography.headlineLarge)
                    
                    Text("Scan and contest parking tickets")
                        .font(AppTypography.bodyMedium)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 32)
                
                Spacer()
                
                // Main action
                Button(action: {
                    coordinator.startCaptureFlow()
                }) {
                    VStack(spacing: 16) {
                        Image(systemName: "camera.viewfinder")
                            .font(.system(size: 64))
                        
                        Text("Scan Ticket")
                            .font(AppTypography.titleLarge)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 48)
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(16)
                }
                .padding(.horizontal, 24)
                
                Spacer()
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        coordinator.showSheet(.citySelection)
                    }) {
                        Image(systemName: "location.fill")
                    }
                }
            }
        }
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
                    // Select city
                    dismiss()
                }) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(city.name)
                                .font(AppTypography.titleMedium)
                            Text(city.state)
                                .font(AppTypography.bodySmall)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                }
                .foregroundColor(.primary)
            }
            .navigationTitle("Select City")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

// MARK: - Telemetry Opt-In Sheet

struct TelemetryOptInSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var config: AppConfig
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.accentColor)
                
                Text("Help Improve OCR")
                    .font(AppTypography.titleLarge)
                
                Text("Share anonymous usage data to help us improve text recognition accuracy.")
                    .font(AppTypography.bodyMedium)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Spacer()
                
                VStack(spacing: 12) {
                    PrimaryButton(title: "Enable Telemetry", action: {
                        config.setTelemetryEnabled(true)
                        dismiss()
                    })
                    
                    SecondaryButton(title: "Not Now", action: {
                        dismiss()
                    })
                }
                .padding(.horizontal, 24)
            }
            .padding(.vertical, 32)
            .navigationTitle("Telemetry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Skip") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

// MARK: - Edit Citation Sheet

struct EditCitationSheet: View {
    @Environment(\.dismiss) private var dismiss
    let result: CaptureResult
    @State private var editedCitation: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Detected Citation") {
                    Text(result.extractedCitationNumber ?? "Not found")
                        .font(AppTypography.citationNumber)
                }
                
                Section("Edit Citation Number") {
                    TextField("Citation Number", text: $editedCitation)
                        .font(AppTypography.citationNumber)
                }
                
                Section {
                    Button(action: {
                        // Save edited citation
                        dismiss()
                    }) {
                        Text("Save Changes")
                    }
                }
            }
            .navigationTitle("Edit Citation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
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
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Telemetry") {
                    Toggle("Enable Telemetry", isOn: $config.telemetryEnabled)
                    
                    if config.telemetryEnabled {
                        Button("Upload Pending Data") {
                            Task {
                                await TelemetryService.shared.uploadPending()
                            }
                        }
                    }
                }
                
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    Link("Privacy Policy", destination: URL(string: "https://fightcitytickets.com/privacy")!)
                    
                    Link("Terms of Service", destination: URL(string: "https://fightcitytickets.com/terms")!)
                }
                
                Section("Debug") {
                    Button("Reset Onboarding") {
                        UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
                    }
                    
                    Button("Clear Caches") {
                        // Clear caches
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

// MARK: - Previews

// TODO: PHASE 3 - Create Appeal Flow Files (currently missing)
// Required files:
// - Sources/FightCity/Features/Appeal/AppealEntryView.swift
// - Sources/FightCity/Features/Appeal/AppealViewModel.swift
// - Sources/FightCity/Features/Appeal/EvidencePickerView.swift
// - Sources/FightCityFoundation/Models/Appeal.swift
// - Sources/FightCityFoundation/Networking/AppealAPI.swift
//
// Appeal flow: Confirmation → AppealEntry → Submit → Status tracking in History

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AppCoordinator())
            .environmentObject(AppConfig.shared)
    }
}
#endif
