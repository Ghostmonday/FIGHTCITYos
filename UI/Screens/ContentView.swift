//
//  ContentView.swift
//  FightCityTickets
//
//  Main content view with navigation
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @EnvironmentObject var config: AppConfig
    
    var body: some View {
        NavigationStack(path: $coordinator.navigationPath) {
            Group {
                switch coordinator.currentScreen {
                case .onboarding:
                    OnboardingView()
                case .capture:
                    CaptureView()
                case .confirmation(let result):
                    ConfirmationView(captureResult: result)
                case .history:
                    HistoryView()
                case .settings:
                    SettingsView()
                }
            }
            .navigationDestination(for: NavigationDestination.self) { destination in
                switch destination {
                case .onboarding:
                    OnboardingView()
                case .capture:
                    CaptureView()
                case .confirmation(let result):
                    ConfirmationView(captureResult: result)
                case .history:
                    HistoryView()
                case .settings:
                    SettingsView()
                }
            }
            .sheet(isPresented: $coordinator.isShowingSheet) {
                if let sheet = coordinator.selectedSheet {
                    sheetView(sheet)
                }
            }
        }
    }
    
    @ViewBuilder
    private func sheetView(_ sheet: AppCoordinator.SheetDestination) -> some View {
        switch sheet {
        case .citySelection:
            CitySelectionSheet()
        case .telemetryOptIn:
            TelemetryOptInSheet()
        case .editCitation(let result):
            EditCitationSheet(captureResult: result)
        }
    }
}

// MARK: - Preview

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AppCoordinator())
            .environmentObject(AppConfig.shared)
    }
}
#endif
