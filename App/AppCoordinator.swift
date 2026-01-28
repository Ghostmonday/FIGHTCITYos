//
//  AppCoordinator.swift
//  FightCityTickets
//
//  Navigation coordinator pattern for managing screen transitions
//

import SwiftUI
import Combine

/// Navigation destinations for the app
enum NavigationDestination: Hashable {
    case onboarding
    case capture
    case confirmation(CaptureResult)
    case history
    case settings
}

/// Main coordinator for managing app navigation state
@MainActor
final class AppCoordinator: ObservableObject {
    @Published var currentScreen: NavigationDestination = .onboarding
    @Published var navigationPath = NavigationPath()
    @Published var isShowingSheet = false
    @Published var selectedSheet: SheetDestination?
    
    private var cancellables = Set<AnyCancellable>()
    
    enum SheetDestination: Identifiable {
        case citySelection
        case telemetryOptIn
        case editCitation(CaptureResult)
        
        var id: Int {
            hashValue
        }
    }
    
    // MARK: - Navigation Actions
    
    func navigateTo(_ destination: NavigationDestination) {
        navigationPath.append(destination)
    }
    
    func navigateBack() {
        guard !navigationPath.isEmpty else { return }
        navigationPath.removeLast()
    }
    func navigateToRoot() {
        navigationPath.removeAll()
    }
    
    // MARK: - Sheet Actions
    
    func showSheet(_ sheet: SheetDestination) {
        selectedSheet = sheet
        isShowingSheet = true
    }
    
    func dismissSheet() {
        isShowingSheet = false
        selectedSheet = nil
    }
    
    // MARK: - Flow Actions
    
    func startCaptureFlow() {
        navigateTo(.capture)
    }
    
    func proceedToConfirmation(with result: CaptureResult) {
        navigateTo(.confirmation(result))
    }
    
    func viewHistory() {
        navigateTo(.history)
    }
    
    func openSettings() {
        navigateTo(.settings)
    }
    
    // MARK: - Citation Flow
    
    func onCitationConfirmed(_ result: CaptureResult) {
        // Navigate to next step in appeal flow
        // This would connect to the backend API validation
        dismissSheet()
    }
    
    func onCitationEdited(_ result: CaptureResult, newCitationNumber: String) {
        // Update result with edited citation and proceed
        dismissSheet()
    }
}

// MARK: - Navigation Path Extension

extension NavigationDestination: Identifiable {
    var id: String {
        String(describing: self)
    }
}
