// FIXME: REDUNDANT - This file is unnecessary for SwiftUI @main apps.
// DELETE THIS FILE - FightCityApp.swift already handles app lifecycle.
// SceneDelegate is only needed for UIKit-based apps or specific scene management.
// Decision: Remove this file entirely or comment out all code.

//
//  SceneDelegate.swift
//  FightCity
//
//  UIKit lifecycle management for SwiftUI app
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        let contentView = ContentView()
            .environmentObject(AppCoordinator())
            .environmentObject(AppConfig.shared)
        
        window.rootViewController = UIHostingController(rootView: contentView)
        self.window = window
        window.makeKeyAndVisible()
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Resume any paused tasks
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Pause ongoing tasks
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Undo changes made when entering background
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Save data and release shared resources
    }
}
