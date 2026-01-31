//
//  FightCityApp.swift
//  FightCity
//
//  Premium parking ticket fighting app
//  Powered by Apple Intelligence
//

import SwiftUI
import FightCityiOS
import FightCityFoundation

@main
struct FightCityApp: App {
    @StateObject private var appCoordinator = AppCoordinator()
    @StateObject private var appConfig = AppConfig()
    
    init() {
        configurePremiumAppearance()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appCoordinator)
                .environmentObject(appConfig)
                .preferredColorScheme(.dark) // Luxury dark theme
        }
    }
    
    /// Configure premium appearance for navigation bars, tab bars, and system UI
    private func configurePremiumAppearance() {
        // Navigation bar
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        navAppearance.backgroundColor = UIColor(AppColors.obsidian)
        navAppearance.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold)
        ]
        navAppearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 34, weight: .bold)
        ]
        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
        UINavigationBar.appearance().compactAppearance = navAppearance
        UINavigationBar.appearance().tintColor = UIColor(AppColors.gold)
        
        // Tab bar
        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithOpaqueBackground()
        tabAppearance.backgroundColor = UIColor(AppColors.surface)
        UITabBar.appearance().standardAppearance = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance
        UITabBar.appearance().tintColor = UIColor(AppColors.gold)
        
        // Text field
        UITextField.appearance().tintColor = UIColor(AppColors.gold)
        
        // Scroll indicators
        UIScrollView.appearance().indicatorStyle = .white
    }
}
