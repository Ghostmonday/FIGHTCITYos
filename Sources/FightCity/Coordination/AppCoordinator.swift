//
//  AppCoordinator.swift
//  FightCity
//
//  Navigation coordinator pattern for managing screen transitions
//

import SwiftUI
import FightCityiOS
import FightCityFoundation

/// Navigation destinations for the app
public enum NavigationDestination: Hashable {
    case onboarding
    case capture
    case confirmation(CaptureResult)
    case history
    case settings
    
    public func hash(into hasher: inout Hasher) {
        switch self {
        case .onboarding: hasher.combine(0)
        case .capture: hasher.combine(1)
        case .confirmation(let result): hasher.combine(2); hasher.combine(result.id)
        case .history: hasher.combine(3)
        case .settings: hasher.combine(4)
        }
    }
}

/// Main coordinator for managing app navigation state
@MainActor
public final class AppCoordinator: ObservableObject {
    @Published public var currentScreen: NavigationDestination = .onboarding
    @Published public var navigationPath = NavigationPath()
    @Published public var isShowingSheet = false
    @Published public var selectedSheet: SheetDestination?
    
    public enum SheetDestination: Identifiable {
        case citySelection
        case telemetryOptIn
        case editCitation(CaptureResult)
        
        public var id: String {
            switch self {
            case .citySelection: return "citySelection"
            case .telemetryOptIn: return "telemetryOptIn"
            case .editCitation(let result): return "editCitation-\(result.extractedCitationNumber ?? "unknown")"
            }
        }
    }
    
    public init() {}
    
    // MARK: - Navigation Actions
    
    public func navigateTo(_ destination: NavigationDestination) {
        navigationPath.append(destination)
    }
    
    public func navigateBack() {
        guard !navigationPath.isEmpty else { return }
        navigationPath.removeLast()
    }
    
    public func navigateToRoot() {
            navigationPath = NavigationPath()
    }
    
    // MARK: - Sheet Actions
    
    public func showSheet(_ sheet: SheetDestination) {
        selectedSheet = sheet
        isShowingSheet = true
    }
    
    public func dismissSheet() {
        isShowingSheet = false
        selectedSheet = nil
    }
    
    // MARK: - Flow Actions
    
    public func startCaptureFlow() {
        navigateTo(.capture)
    }
    
    public func proceedToConfirmation(with result: CaptureResult) {
        navigateTo(.confirmation(result))
    }
    
    public func viewHistory() {
        navigateTo(.history)
    }
    
    public func openSettings() {
        navigateTo(.settings)
    }
    
    // MARK: - Citation Flow
    
    public func onCitationConfirmed(_ result: CaptureResult) {
        // Navigate to next step in appeal flow
        // This would connect to the backend API validation
        dismissSheet()
    }
    
    public func onCitationEdited(_ result: CaptureResult, newCitationNumber: String) {
        // Update result with edited citation and proceed
        dismissSheet()
    }
}

// MARK: - Navigation Path Extension

extension NavigationDestination: Identifiable {
    public var id: String {
        String(describing: self)
    }
}
