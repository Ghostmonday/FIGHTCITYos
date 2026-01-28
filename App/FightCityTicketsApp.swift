//
//  FightCityTicketsApp.swift
//  FightCityTickets
//
//  Native iOS app for scanning and validating parking citations
//  Integrates with existing FastAPI backend
//

import SwiftUI

@main
struct FightCityTicketsApp: App {
    @StateObject private var appCoordinator = AppCoordinator()
    @StateObject private var appConfig = AppConfig()
    
    init() {
        configureAppearance()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appCoordinator)
                .environmentObject(appConfig)
        }
    }
    
    private func configureAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(AppColors.background)
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
}
