# FightCityTickets - Complete Code Collection

Generated: Thu Jan 29 06:00:45 AM PST 2026

## File Structure
```
./APP_SPECIFICATION.md
./APP_STORE_SUBMISSION_CHECKLIST.md
./ARCHITECTURE_BLUEPRINT.md
./Cargo.toml
./CHANGELOG.md
./CONTRIBUTING.md
./decrypt_chrome_cookies.py
./extract_proton_cookies.py
./extract_proton_creds.sh
./find_proton_pdf.rs
./get_proton_session.sh
./.github/workflows/ci.yml
./.github/workflows/swift-linux-ci.yml
./MAC_DAY_CHECKLIST.md
./project.yml
./QUICK_START.md
./README_IOS_BUILD.md
./REPO_CODE_COLLECTION.md
./Resources/Assets.xcassets/AccentColor.colorset/Contents.json
./Resources/Assets.xcassets/AppIcon.appiconset/Contents.json
./Resources/Assets.xcassets/Contents.json
./Resources/Info.plist
./ROADMAP.md
./Scripts/mac-setup.sh
./Scripts/xcode-setup.sh
./Sources/FightCity/App/FightCityApp.swift
./Sources/FightCity/App/SceneDelegate.swift
./Sources/FightCity/Configuration/AppConfig.swift
./Sources/FightCity/Coordination/AppCoordinator.swift
./Sources/FightCity/DesignSystem/Colors.swift
./Sources/FightCity/DesignSystem/Components.swift
./Sources/FightCity/DesignSystem/Theme.swift
./Sources/FightCity/DesignSystem/Typography.swift
./Sources/FightCity/Features/Capture/CaptureViewModel.swift
./Sources/FightCity/Features/Capture/CaptureView.swift
./Sources/FightCity/Features/Confirmation/ConfirmationView.swift
./Sources/FightCity/Features/History/HistoryView.swift
./Sources/FightCity/Features/Onboarding/OnboardingView.swift
./Sources/FightCity/Features/Root/ContentView.swift
./Sources/FightCityFoundation/Logging/Logger.swift
./Sources/FightCityFoundation/Models/Citation.swift
./Sources/FightCityFoundation/Models/CityConfig.swift
./Sources/FightCityFoundation/Models/TelemetryRecord.swift
./Sources/FightCityFoundation/Models/TelemetryStorage.swift
./Sources/FightCityFoundation/Models/ValidationResult.swift
./Sources/FightCityFoundation/Networking/APIClient.swift
./Sources/FightCityFoundation/Networking/APIEndpoints.swift
./Sources/FightCityFoundation/Networking/AuthManager.swift
./Sources/FightCityFoundation/Networking/OCRParsingEngine.swift
./Sources/FightCityFoundation/Networking/OfflineManager.swift
./Sources/FightCityFoundation/Offline/OfflineQueueManager.swift
./Sources/FightCityFoundation/Protocols/ServiceProtocols.swift
./Sources/FightCityiOS/Camera/CameraManager.swift
./Sources/FightCityiOS/Camera/CameraPreviewView.swift
./Sources/FightCityiOS/Camera/FrameQualityAnalyzer.swift
./Sources/FightCityiOS/Models/CaptureResult.swift
./Sources/FightCityiOS/OCR/ConfidenceScorer.swift
./Sources/FightCityiOS/OCR/OCREngine.swift
./Sources/FightCityiOS/OCR/OCRPreprocessor.swift
./Sources/FightCityiOS/Telemetry/TelemetryService.swift
./Sources/FightCityiOS/Telemetry/TelemetryUploader.swift
./Support/FightCityFoundation-Info.plist
./Support/FightCityiOS-Info.plist
./.swiftlint.yml
./Tests/UnitTests/AppTests/Mocks/MockServices.swift
./Tests/UnitTests/FoundationTests/ConfidenceScorerTests.swift
./Tests/UnitTests/FoundationTests/Mocks/MockAPIClient.swift
./Tests/UnitTests/FoundationTests/OCRParsingEngineTests.swift
./Tests/UnitTests/FoundationTests/PatternMatcherTests.swift
./Tests/UnitTests/iOSTests/ConfidenceScorerTests.swift
./Tests/UnitTests/iOSTests/Mocks/MockCameraManager.swift
./Tests/UnitTests/iOSTests/Mocks/MockOCREngine.swift
./WINDOWS_DEVELOPMENT_GUIDE.md
```

## Sources/FightCity/App/FightCityApp.swift
```
//
//  FightCityApp.swift
//  FightCity
//
//  Native iOS app for scanning and validating parking citations
//  Integrates with existing FastAPI backend
//

import SwiftUI
import FightCityiOS
import FightCityFoundation

@main
struct FightCityApp: App {
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
```

## Sources/FightCity/App/SceneDelegate.swift
```
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
```

## Sources/FightCity/Configuration/AppConfig.swift
```
//
//  AppConfig.swift
//  FightCity
//
//  Build configuration and API endpoint settings
//

import Foundation
import Combine
import FightCityFoundation

/// App configuration including API endpoints and build settings
public final class AppConfig: ObservableObject {
    public static let shared = AppConfig()
    
    // MARK: - API Configuration
    
    /// Base URL for the API - configurable for different environments
    @Published public var apiBaseURL: URL
    
    /// API timeout interval in seconds
    public let apiTimeout: TimeInterval = 30
    
    /// Number of retry attempts for failed requests
    public let maxRetryAttempts: Int = 3
    
    /// Base URL for the web frontend (for deep links)
    @Published public var webBaseURL: URL
    
    // MARK: - OCR Configuration
    
    /// Minimum confidence threshold for auto-accepting OCR results
    public let ocrConfidenceThreshold: Double = 0.85
    
    /// Fallback confidence threshold requiring user review
    public let ocrReviewThreshold: Double = 0.60
    
    /// Maximum image dimensions for OCR processing
    public let ocrMaxImageDimension: CGFloat = 1920
    
    // MARK: - Telemetry Configuration
    
    /// Whether telemetry collection is enabled
    @Published public var telemetryEnabled: Bool = false
    
    /// Maximum number of telemetry records to batch
    public let telemetryBatchSize: Int = 50
    
    /// Maximum age of telemetry records before upload (24 hours)
    public let telemetryMaxAge: TimeInterval = 86400
    
    // MARK: - Offline Configuration
    
    /// Maximum number of pending operations to queue
    public let offlineQueueMaxSize: Int = 100
    
    /// Retry backoff multiplier
    public let retryBackoffMultiplier: Double = 2.0
    
    /// Maximum retry backoff (5 minutes)
    public let retryMaxBackoff: TimeInterval = 300
    
    // MARK: - City Configuration
    
    /// Default cities supported by the app
    public let supportedCities: [CityConfig] = [
        CityConfig(
            id: "us-ca-san_francisco",
            name: "San Francisco",
            state: "CA",
            agencyCode: "SFMTA",
            citationPattern: "^(SFMTA|MT)[0-9]{8}$",
            timezone: "America/Los_Angeles",
            deadlineDays: 21
        ),
        CityConfig(
            id: "us-ca-los_angeles",
            name: "Los Angeles",
            state: "CA",
            agencyCode: "LADOT",
            citationPattern: "^[0-9A-Z]{6,11}$",
            timezone: "America/Los_Angeles",
            deadlineDays: 21
        ),
        CityConfig(
            id: "us-ny-new_york",
            name: "New York",
            state: "NY",
            agencyCode: "NYC_DO",
            citationPattern: "^[0-9]{10}$",
            timezone: "America/New_York",
            deadlineDays: 30
        ),
        CityConfig(
            id: "us-co-denver",
            name: "Denver",
            state: "CO",
            agencyCode: "DENVER",
            citationPattern: "^[0-9]{5,9}$",
            timezone: "America/Denver",
            deadlineDays: 21
        )
    ]
    
    // MARK: - Initialization
    
    private init() {
        // Configure based on build environment
        #if DEBUG
        guard let apiURL = URL(string: "http://localhost:8000"),
              let webURL = URL(string: "http://localhost:3000") else {
            fatalError("Failed to create debug URLs - this should never happen")
        }
        self.apiBaseURL = apiURL
        self.webBaseURL = webURL
        #else
        guard let apiURL = URL(string: "https://api.fightcitytickets.com"),
              let webURL = URL(string: "https://fightcitytickets.com") else {
            fatalError("Failed to create production URLs - this should never happen")
        }
        self.apiBaseURL = apiURL
        self.webBaseURL = webURL
        #endif
        
        loadUserPreferences()
    }
    
    // MARK: - User Preferences
    
    private func loadUserPreferences() {
        telemetryEnabled = UserDefaults.standard.bool(forKey: "telemetryEnabled")
    }
    
    public func setTelemetryEnabled(_ enabled: Bool) {
        telemetryEnabled = enabled
        UserDefaults.standard.set(enabled, forKey: "telemetryEnabled")
    }
    
    // MARK: - API Endpoints
    
    public struct APIEndpoints {
        public static let health = "/health"
        public static let validateCitation = "/api/citations/validate"
        public static let validateTicket = "/tickets/validate"
        public static let appealSubmit = "/api/appeals"
        public static let statusLookup = "/api/status/lookup"
        public static let telemetryUpload = "/mobile/ocr/telemetry"
        public static let ocrConfig = "/mobile/ocr/config"
    }
    
    // MARK: - Utility
    
    public func cityConfig(for cityId: String) -> CityConfig? {
        supportedCities.first { $0.id == cityId }
    }
    
    public func cityConfig(for citationNumber: String) -> CityConfig? {
        // Check patterns in priority order (from backend CitationValidator)
        let priorityOrder = ["us-ca-san_francisco", "us-ny-new_york", "us-co-denver", "us-ca-los_angeles"]
        
        for cityId in priorityOrder {
            if let config = cityConfig(for: cityId),
               let pattern = config.citationPattern,
               citationNumber.range(of: pattern, options: .regularExpression) != nil {
                return config
            }
        }
        
        return nil
    }
}
```

## Sources/FightCity/Coordination/AppCoordinator.swift
```
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
        
        public var id: Int {
            hashValue
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
        navigationPath.removeAll()
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
```

## Sources/FightCity/DesignSystem/Colors.swift
```
//
//  Colors.swift
//  FightCity
//
//  App color palette and semantic colors
//

import SwiftUI

// MARK: - App Colors

/// App color palette
public enum AppColors {
    // MARK: - Primary Colors
    
    public static let primary = Color("Primary", bundle: nil)
    public static let primaryVariant = Color("PrimaryVariant", bundle: nil)
    public static let secondary = Color("Secondary", bundle: nil)
    public static let secondaryVariant = Color("SecondaryVariant", bundle: nil)
    
    // MARK: - Background Colors
    
    public static let background = Color("Background", bundle: nil)
    public static let surface = Color("Surface", bundle: nil)
    public static let surfaceVariant = Color("SurfaceVariant", bundle: nil)
    
    // MARK: - Text Colors
    
    public static let onPrimary = Color("OnPrimary", bundle: nil)
    public static let onSecondary = Color("OnSecondary", bundle: nil)
    public static let onBackground = Color("OnBackground", bundle: nil)
    public static let onSurface = Color("OnSurface", bundle: nil)
    public static let onSurfaceVariant = Color("OnSurfaceVariant", bundle: nil)
    public static let disabled = Color("Disabled", bundle: nil)
    
    // MARK: - Semantic Colors
    
    public static let success = Color("Success", bundle: nil)
    public static let warning = Color("Warning", bundle: nil)
    public static let error = Color("Error", bundle: nil)
    public static let info = Color("Info", bundle: nil)
    
    // MARK: - Deadline Colors
    
    public static let deadlineSafe = Color("DeadlineSafe", bundle: nil)
    public static let deadlineApproaching = Color("DeadlineApproaching", bundle: nil)
    public static let deadlineUrgent = Color("DeadlineUrgent", bundle: nil)
    
    // MARK: - OCR Confidence Colors
    
    public static let confidenceHigh = Color("ConfidenceHigh", bundle: nil)
    public static let confidenceMedium = Color("ConfidenceMedium", bundle: nil)
    public static let confidenceLow = Color("ConfidenceLow", bundle: nil)
}

// MARK: - Semantic Color Extensions

public extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Color Helpers

public extension Color {
    static func deadlineColor(for status: DeadlineStatus) -> Color {
        switch status {
        case .safe:
            return AppColors.deadlineSafe
        case .approaching:
            return AppColors.deadlineApproaching
        case .urgent, .past:
            return AppColors.deadlineUrgent
        }
    }
    
    static func confidenceColor(for level: ConfidenceScorer.ConfidenceLevel) -> Color {
        switch level {
        case .high:
            return AppColors.confidenceHigh
        case .medium:
            return AppColors.confidenceMedium
        case .low:
            return AppColors.confidenceLow
        }
    }
    
    static func statusColor(for status: CitationStatus) -> Color {
        switch status {
        case .pending:
            return AppColors.warning
        case .validated, .approved:
            return AppColors.success
        case .inReview:
            return AppColors.info
        case .appealed:
            return AppColors.info
        case .denied, .expired:
            return AppColors.error
        case .paid:
            return AppColors.success
        }
    }
}
```

## Sources/FightCity/DesignSystem/Components.swift
```
//
//  Components.swift
//  FightCity
//
//  Reusable UI components
//

import SwiftUI

// MARK: - Primary Button

public struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var isEnabled: Bool = true
    var isLoading: Bool = false
    
    public init(title: String, action: @escaping () -> Void, isEnabled: Bool = true, isLoading: Bool = false) {
        self.title = title
        self.action = action
        self.isEnabled = isEnabled
        self.isLoading = isLoading
    }
    
    public var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                }
                Text(title)
                    .font(AppTypography.labelLarge)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .padding(.horizontal, 24)
            .background(isEnabled ? Color.accentColor : Color.gray)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .disabled(!isEnabled || isLoading)
    }
}

// MARK: - Secondary Button

public struct SecondaryButton: View {
    let title: String
    let action: () -> Void
    var isEnabled: Bool = true
    
    public init(title: String, action: @escaping () -> Void, isEnabled: Bool = true) {
        self.title = title
        self.action = action
        self.isEnabled = isEnabled
    }
    
    public var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppTypography.labelLarge)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .padding(.horizontal, 24)
                .background(Color.clear)
                .foregroundColor(.accentColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.accentColor, lineWidth: 2)
                )
        }
        .disabled(!isEnabled)
    }
}

// MARK: - Card View

public struct CardView<Content: View>: View {
    let content: Content
    
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            content
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Citation Card

public struct CitationCard: View {
    let citation: Citation
    let onTap: () -> Void
    
    public init(citation: Citation, onTap: @escaping () -> Void) {
        self.citation = citation
        self.onTap = onTap
    }
    
    public var body: some View {
        Button(action: onTap) {
            CardView {
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(citation.citationNumber)
                            .font(AppTypography.citationNumber)
                            .foregroundColor(.primary)
                        
                        if let cityName = citation.cityName {
                            Text(cityName)
                                .font(AppTypography.bodyMedium)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    StatusBadge(status: citation.status)
                }
                
                HStack {
                    if let deadline = citation.deadlineDate {
                        Text("Due: \(deadline)")
                            .font(AppTypography.labelMedium)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    if let days = citation.daysRemaining {
                        Text("\(days) days left")
                            .font(AppTypography.labelMedium)
                            .foregroundColor(Color.deadlineColor(for: citation.deadlineStatus))
                    }
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Status Badge

public struct StatusBadge: View {
    let status: CitationStatus
    
    public init(status: CitationStatus) {
        self.status = status
    }
    
    public var body: some View {
        Text(status.displayName)
            .font(AppTypography.labelSmall)
            .fontWeight(.medium)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.statusColor(for: status).opacity(0.15))
            .foregroundColor(Color.statusColor(for: status))
            .cornerRadius(8)
    }
}

// MARK: - Confidence Indicator

public struct ConfidenceIndicator: View {
    let confidence: Double
    let level: ConfidenceScorer.ConfidenceLevel
    
    public init(confidence: Double, level: ConfidenceScorer.ConfidenceLevel) {
        self.confidence = confidence
        self.level = level
    }
    
    public var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(Color.confidenceColor(for: level))
                .frame(width: 8, height: 8)
            
            Text("\(Int(confidence * 100))%")
                .font(AppTypography.confidenceScore)
                .foregroundColor(Color.confidenceColor(for: level))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.confidenceColor(for: level).opacity(0.15))
        .cornerRadius(8)
    }
}

// MARK: - Loading Overlay

public struct LoadingOverlay: View {
    let message: String
    let isShowing: Bool
    
    public init(message: String, isShowing: Bool) {
        self.message = message
        self.isShowing = isShowing
    }
    
    public var body: some View {
        if isShowing {
            ZStack {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                
                VStack(spacing: 16) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                    
                    Text(message)
                        .font(AppTypography.bodyMedium)
                        .foregroundColor(.white)
                }
                .padding(32)
                .background(Color(.systemGray5))
                .cornerRadius(16)
            }
        }
    }
}

// MARK: - Empty State View

public struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    let buttonTitle: String?
    let buttonAction: (() -> Void)?
    
    public init(
        icon: String,
        title: String,
        message: String,
        buttonTitle: String? = nil,
        buttonAction: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.buttonTitle = buttonTitle
        self.buttonAction = buttonAction
    }
    
    public var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text(title)
                .font(AppTypography.titleMedium)
                .foregroundColor(.primary)
            
            Text(message)
                .font(AppTypography.bodyMedium)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            if let buttonTitle = buttonTitle, let buttonAction = buttonAction {
                PrimaryButton(title: buttonTitle, action: buttonAction)
                    .padding(.top, 8)
            }
        }
        .padding(32)
    }
}

// MARK: - Error View

public struct ErrorView: View {
    let message: String
    let retryAction: () -> Void
    
    public init(message: String, retryAction: @escaping () -> Void) {
        self.message = message
        self.retryAction = retryAction
    }
    
    public var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.orange)
            
            Text("Something went wrong")
                .font(AppTypography.titleMedium)
            
            Text(message)
                .font(AppTypography.bodyMedium)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            PrimaryButton(title: "Try Again", action: retryAction)
        }
        .padding(32)
    }
}
```

## Sources/FightCity/DesignSystem/Theme.swift
```
//
//  Theme.swift
//  FightCity
//
//  App theming configuration with colors and typography
//

import SwiftUI

// MARK: - Theme

/// App theme configuration
public struct AppTheme {
    // MARK: - Light Theme
    
    public static let light = Theme(
        colors: ThemeColors(
            primary: Color(hex: "#0066CC"),
            primaryVariant: Color(hex: "#0052A3"),
            secondary: Color(hex: "#34C759"),
            secondaryVariant: Color(hex: "#28A745"),
            background: Color(hex: "#F2F2F7"),
            surface: .white,
            surfaceVariant: Color(hex: "#E5E5EA"),
            onPrimary: .white,
            onSecondary: .white,
            onBackground: Color(hex: "#1C1C1E"),
            onSurface: Color(hex: "#1C1C1E"),
            onSurfaceVariant: Color(hex: "#8E8E93"),
            disabled: Color(hex: "#C7C7CC"),
            success: Color(hex: "#34C759"),
            warning: Color(hex: "#FF9500"),
            error: Color(hex: "#FF3B30"),
            info: Color(hex: "#007AFF"),
            deadlineSafe: Color(hex: "#34C759"),
            deadlineApproaching: Color(hex: "#FF9500"),
            deadlineUrgent: Color(hex: "#FF3B30"),
            confidenceHigh: Color(hex: "#34C759"),
            confidenceMedium: Color(hex: "#FF9500"),
            confidenceLow: Color(hex: "#FF3B30")
        ),
        typography: ThemeTypography()
    )
    
    // MARK: - Dark Theme
    
    public static let dark = Theme(
        colors: ThemeColors(
            primary: Color(hex: "#0A84FF"),
            primaryVariant: Color(hex: "#0066CC"),
            secondary: Color(hex: "#30D158"),
            secondaryVariant: Color(hex: "#34C759"),
            background: Color(hex: "#1C1C1E"),
            surface: Color(hex: "#2C2C2E"),
            surfaceVariant: Color(hex: "#3A3A3C"),
            onPrimary: .white,
            onSecondary: .black,
            onBackground: Color(hex: "#FFFFFF"),
            onSurface: Color(hex: "#FFFFFF"),
            onSurfaceVariant: Color(hex: "#AEAEB2"),
            disabled: Color(hex: "#48484A"),
            success: Color(hex: "#30D158"),
            warning: Color(hex: "#FF9F0A"),
            error: Color(hex: "#FF453A"),
            info: Color(hex: "#0A84FF"),
            deadlineSafe: Color(hex: "#30D158"),
            deadlineApproaching: Color(hex: "#FF9F0A"),
            deadlineUrgent: Color(hex: "#FF453A"),
            confidenceHigh: Color(hex: "#30D158"),
            confidenceMedium: Color(hex: "#FF9F0A"),
            confidenceLow: Color(hex: "#FF453A")
        ),
        typography: ThemeTypography()
    )
}

// MARK: - Theme Colors

/// Theme color palette
public struct ThemeColors {
    public let primary: Color
    public let primaryVariant: Color
    public let secondary: Color
    public let secondaryVariant: Color
    public let background: Color
    public let surface: Color
    public let surfaceVariant: Color
    public let onPrimary: Color
    public let onSecondary: Color
    public let onBackground: Color
    public let onSurface: Color
    public let onSurfaceVariant: Color
    public let disabled: Color
    public let success: Color
    public let warning: Color
    public let error: Color
    public let info: Color
    public let deadlineSafe: Color
    public let deadlineApproaching: Color
    public let deadlineUrgent: Color
    public let confidenceHigh: Color
    public let confidenceMedium: Color
    public let confidenceLow: Color
    
    public init(
        primary: Color,
        primaryVariant: Color,
        secondary: Color,
        secondaryVariant: Color,
        background: Color,
        surface: Color,
        surfaceVariant: Color,
        onPrimary: Color,
        onSecondary: Color,
        onBackground: Color,
        onSurface: Color,
        onSurfaceVariant: Color,
        disabled: Color,
        success: Color,
        warning: Color,
        error: Color,
        info: Color,
        deadlineSafe: Color,
        deadlineApproaching: Color,
        deadlineUrgent: Color,
        confidenceHigh: Color,
        confidenceMedium: Color,
        confidenceLow: Color
    ) {
        self.primary = primary
        self.primaryVariant = primaryVariant
        self.secondary = secondary
        self.secondaryVariant = secondaryVariant
        self.background = background
        self.surface = surface
        self.surfaceVariant = surfaceVariant
        self.onPrimary = onPrimary
        self.onSecondary = onSecondary
        self.onBackground = onBackground
        self.onSurface = onSurface
        self.onSurfaceVariant = onSurfaceVariant
        self.disabled = disabled
        self.success = success
        self.warning = warning
        self.error = error
        self.info = info
        self.deadlineSafe = deadlineSafe
        self.deadlineApproaching = deadlineApproaching
        self.deadlineUrgent = deadlineUrgent
        self.confidenceHigh = confidenceHigh
        self.confidenceMedium = confidenceMedium
        self.confidenceLow = confidenceLow
    }
}

// MARK: - Theme Typography

/// Typography configuration for the theme
public struct ThemeTypography {
    // MARK: - Display Fonts
    
    public let displayLarge: Font
    public let displayMedium: Font
    public let displaySmall: Font
    
    // MARK: - Headline Fonts
    
    public let headlineLarge: Font
    public let headlineMedium: Font
    public let headlineSmall: Font
    
    // MARK: - Title Fonts
    
    public let titleLarge: Font
    public let titleMedium: Font
    public let titleSmall: Font
    
    // MARK: - Body Fonts
    
    public let bodyLarge: Font
    public let bodyMedium: Font
    public let bodySmall: Font
    
    // MARK: - Label Fonts
    
    public let labelLarge: Font
    public let labelMedium: Font
    public let labelSmall: Font
    
    // MARK: - Special Fonts
    
    /// For citation numbers - monospaced for readability
    public let citationNumber: Font
    
    /// For monetary amounts
    public let monetaryAmount: Font
    
    /// For OCR confidence scores
    public let confidenceScore: Font
    
    /// For caption text
    public let caption: Font
    
    /// For button text
    public let button: Font
    
    // MARK: - Line Heights
    
    public let displayLineHeight: CGFloat
    public let headlineLineHeight: CGFloat
    public let titleLineHeight: CGFloat
    public let bodyLineHeight: CGFloat
    public let labelLineHeight: CGFloat
    
    public init() {
        // Display fonts
        self.displayLarge = .system(size: 57, weight: .bold, design: .default)
        self.displayMedium = .system(size: 45, weight: .bold, design: .default)
        self.displaySmall = .system(size: 36, weight: .bold, design: .default)
        
        // Headline fonts
        self.headlineLarge = .system(size: 32, weight: .semibold, design: .default)
        self.headlineMedium = .system(size: 28, weight: .semibold, design: .default)
        self.headlineSmall = .system(size: 24, weight: .semibold, design: .default)
        
        // Title fonts
        self.titleLarge = .system(size: 22, weight: .semibold, design: .default)
        self.titleMedium = .system(size: 16, weight: .medium, design: .default)
        self.titleSmall = .system(size: 14, weight: .medium, design: .default)
        
        // Body fonts
        self.bodyLarge = .system(size: 16, weight: .regular, design: .default)
        self.bodyMedium = .system(size: 14, weight: .regular, design: .default)
        self.bodySmall = .system(size: 12, weight: .regular, design: .default)
        
        // Label fonts
        self.labelLarge = .system(size: 14, weight: .medium, design: .default)
        self.labelMedium = .system(size: 12, weight: .medium, design: .default)
        self.labelSmall = .system(size: 11, weight: .medium, design: .default)
        
        // Special fonts
        self.citationNumber = .system(size: 24, weight: .bold, design: .monospaced)
        self.monetaryAmount = .system(size: 32, weight: .bold, design: .default)
        self.confidenceScore = .system(size: 14, weight: .semibold, design: .default)
        self.caption = .system(size: 11, weight: .regular, design: .default)
        self.button = .system(size: 16, weight: .semibold, design: .default)
        
        // Line heights (based on Apple Human Interface Guidelines)
        self.displayLineHeight = 64
        self.headlineLineHeight = 40
        self.titleLineHeight = 28
        self.bodyLineHeight = 22
        self.labelLineHeight = 16
    }
    
    // MARK: - Convenience Accessors
    
    /// Get font for a text style
    public func font(for style: TextStyle) -> Font {
        switch style {
        case .displayLarge: return displayLarge
        case .displayMedium: return displayMedium
        case .displaySmall: return displaySmall
        case .headlineLarge: return headlineLarge
        case .headlineMedium: return headlineMedium
        case .headlineSmall: return headlineSmall
        case .titleLarge: return titleLarge
        case .titleMedium: return titleMedium
        case .titleSmall: return titleSmall
        case .bodyLarge: return bodyLarge
        case .bodyMedium: return bodyMedium
        case .bodySmall: return bodySmall
        case .labelLarge: return labelLarge
        case .labelMedium: return labelMedium
        case .labelSmall: return labelSmall
        case .citationNumber: return citationNumber
        case .monetaryAmount: return monetaryAmount
        case .confidenceScore: return confidenceScore
        case .caption: return caption
        case .button: return button
        }
    }
    
    /// Get line height for a text style
    public func lineHeight(for style: TextStyle) -> CGFloat {
        switch style {
        case .displayLarge, .displayMedium, .displaySmall:
            return displayLineHeight
        case .headlineLarge, .headlineMedium, .headlineSmall:
            return headlineLineHeight
        case .titleLarge, .titleMedium, .titleSmall:
            return titleLineHeight
        case .bodyLarge, .bodyMedium, .bodySmall:
            return bodyLineHeight
        case .labelLarge, .labelMedium, .labelSmall, .caption, .button:
            return labelLineHeight
        case .citationNumber, .monetaryAmount, .confidenceScore:
            return bodyLineHeight
        }
    }
}

// MARK: - Text Styles

/// Predefined text styles for consistent typography
public enum TextStyle {
    case displayLarge
    case displayMedium
    case displaySmall
    case headlineLarge
    case headlineMedium
    case headlineSmall
    case titleLarge
    case titleMedium
    case titleSmall
    case bodyLarge
    case bodyMedium
    case bodySmall
    case labelLarge
    case labelMedium
    case labelSmall
    case citationNumber
    case monetaryAmount
    case confidenceScore
    case caption
    case button
}

// MARK: - Theme Struct

/// Complete theme definition
public struct Theme {
    public let colors: ThemeColors
    public let typography: ThemeTypography
    
    public static var current: Theme {
        // Could be extended to support dynamic theme switching
        return .light
    }
}

// MARK: - Color Extension for Theme Colors

public extension Color {
    init(_ themeColor: KeyPath<ThemeColors, Color>, theme: Theme = .current) {
        self = theme.colors[keyPath: themeColor]
    }
}

// MARK: - View Extension for Theming

public extension View {
    func theme(_ theme: Theme) -> some View {
        self.environment(\.theme, theme)
    }
}

// MARK: - Environment Key

private struct ThemeKey: EnvironmentKey {
    static let defaultValue: Theme = AppTheme.light
}

public extension EnvironmentValues {
    var theme: Theme {
        get { self[ThemeKey.self] }
        set { self[ThemeKey.self] = newValue }
    }
}

// MARK: - Text Extensions

public extension Text {
    /// Apply theme typography style with optional line height
    func typography(_ style: TextStyle, theme: Theme = .current, lineHeight: CGFloat? = nil) -> some View {
        let font = theme.typography.font(for: style)
        let height = lineHeight ?? theme.typography.lineHeight(for: style)
        return self.font(font).lineSpacing(height - font.lineHeight)
    }
    
    /// Apply theme color
    func themeColor(_ keyPath: KeyPath<ThemeColors, Color>, theme: Theme = .current) -> some View {
        self.foregroundColor(theme.colors[keyPath: keyPath])
    }
}

// MARK: - View Extensions for Common Styles

public extension View {
    /// Style as a primary title
    func titleStyle(theme: Theme = .current) -> some View {
        self.font(theme.typography.titleLarge)
            .foregroundColor(theme.colors.onBackground)
    }
    
    /// Style as a secondary title
    func subtitleStyle(theme: Theme = .current) -> some View {
        self.font(theme.typography.titleMedium)
            .foregroundColor(theme.colors.onSurfaceVariant)
    }
    
    /// Style as body text
    func bodyStyle(theme: Theme = .current) -> some View {
        self.font(theme.typography.bodyLarge)
            .foregroundColor(theme.colors.onBackground)
    }
    
    /// Style as caption text
    func captionStyle(theme: Theme = .current) -> some View {
        self.font(theme.typography.caption)
            .foregroundColor(theme.colors.onSurfaceVariant)
    }
    
    /// Style for citation number display
    func citationStyle(theme: Theme = .current) -> some View {
        self.font(theme.typography.citationNumber)
            .foregroundColor(theme.colors.primary)
    }
    
    /// Style for monetary amount display
    func monetaryStyle(theme: Theme = .current) -> some View {
        self.font(theme.typography.monetaryAmount)
            .foregroundColor(theme.colors.onBackground)
    }
    
    /// Style for confidence score display
    func confidenceStyle(level: ConfidenceLevelType, theme: Theme = .current) -> some View {
        let color: Color
        switch level {
        case .high:
            color = theme.colors.confidenceHigh
        case .medium:
            color = theme.colors.confidenceMedium
        case .low:
            color = theme.colors.confidenceLow
        }
        return self.font(theme.typography.confidenceScore)
            .foregroundColor(color)
    }
    
    /// Style for deadline status
    func deadlineStyle(_ status: DeadlineStatus, theme: Theme = .current) -> some View {
        let color: Color
        switch status {
        case .safe:
            color = theme.colors.deadlineSafe
        case .approaching:
            color = theme.colors.deadlineApproaching
        case .urgent, .past:
            color = theme.colors.deadlineUrgent
        }
        return self.font(theme.typography.labelMedium)
            .foregroundColor(color)
    }
}

// MARK: - Confidence Level Type Alias

/// Type alias for confidence level from ConfidenceScorer
public typealias ConfidenceLevelType = FightCityiOS.ConfidenceScorer.ConfidenceLevel
```

## Sources/FightCity/DesignSystem/Typography.swift
```
//
//  Typography.swift
//  FightCity
//
//  App typography system
//

import SwiftUI

// MARK: - Typography

/// App typography system
public enum AppTypography {
    // MARK: - Display Styles
    
    public static let displayLarge = Font.system(size: 57, weight: .bold, design: .default)
    public static let displayMedium = Font.system(size: 45, weight: .bold, design: .default)
    public static let displaySmall = Font.system(size: 36, weight: .bold, design: .default)
    
    // MARK: - Headline Styles
    
    public static let headlineLarge = Font.system(size: 32, weight: .semibold, design: .default)
    public static let headlineMedium = Font.system(size: 28, weight: .semibold, design: .default)
    public static let headlineSmall = Font.system(size: 24, weight: .semibold, design: .default)
    
    // MARK: - Title Styles
    
    public static let titleLarge = Font.system(size: 22, weight: .semibold, design: .default)
    public static let titleMedium = Font.system(size: 16, weight: .medium, design: .default)
    public static let titleSmall = Font.system(size: 14, weight: .medium, design: .default)
    
    // MARK: - Body Styles
    
    public static let bodyLarge = Font.system(size: 16, weight: .regular, design: .default)
    public static let bodyMedium = Font.system(size: 14, weight: .regular, design: .default)
    public static let bodySmall = Font.system(size: 12, weight: .regular, design: .default)
    
    // MARK: - Label Styles
    
    public static let labelLarge = Font.system(size: 14, weight: .medium, design: .default)
    public static let labelMedium = Font.system(size: 12, weight: .medium, design: .default)
    public static let labelSmall = Font.system(size: 11, weight: .medium, design: .default)
    
    // MARK: - Special Styles
    
    /// For citation numbers
    public static let citationNumber = Font.system(size: 24, weight: .bold, design: .monospaced)
    
    /// For monetary amounts
    public static let monetaryAmount = Font.system(size: 32, weight: .bold, design: .default)
    
    /// For OCR confidence scores
    public static let confidenceScore = Font.system(size: 14, weight: .semibold, design: .default)
}

// MARK: - Text Style Extensions

public extension Font {
    static func appDisplay(_ style: AppTypography.DisplayStyle) -> Font {
        switch style {
        case .large: return AppTypography.displayLarge
        case .medium: return AppTypography.displayMedium
        case .small: return AppTypography.displaySmall
        }
    }
    
    static func appHeadline(_ style: AppTypography.HeadlineStyle) -> Font {
        switch style {
        case .large: return AppTypography.headlineLarge
        case .medium: return AppTypography.headlineMedium
        case .small: return AppTypography.headlineSmall
        }
    }
    
    static func appTitle(_ style: AppTypography.TitleStyle) -> Font {
        switch style {
        case .large: return AppTypography.titleLarge
        case .medium: return AppTypography.titleMedium
        case .small: return AppTypography.titleSmall
        }
    }
    
    static func appBody(_ style: AppTypography.BodyStyle) -> Font {
        switch style {
        case .large: return AppTypography.bodyLarge
        case .medium: return AppTypography.bodyMedium
        case .small: return AppTypography.bodySmall
        }
    }
    
    static func appLabel(_ style: AppTypography.LabelStyle) -> Font {
        switch style {
        case .large: return AppTypography.labelLarge
        case .medium: return AppTypography.labelMedium
        case .small: return AppTypography.labelSmall
        }
    }
}

// MARK: - Typography Styles

public extension AppTypography {
    enum DisplayStyle {
        case large, medium, small
    }
    
    enum HeadlineStyle {
        case large, medium, small
    }
    
    enum TitleStyle {
        case large, medium, small
    }
    
    enum BodyStyle {
        case large, medium, small
    }
    
    enum LabelStyle {
        case large, medium, small
    }
}

// MARK: - Line Height Extensions

public extension Text {
    func appLineHeight(_ lineHeight: CGFloat) -> some View {
        self.font(.body).lineSpacing(lineHeight - AppTypography.bodyLarge.lineHeight)
    }
}
```

## Sources/FightCity/Features/Capture/CaptureViewModel.swift
```
//
//  CaptureViewModel.swift
//  FightCity
//
//  View model for camera capture and OCR processing
//

import SwiftUI
import AVFoundation
import Vision
import FightCityiOS
import FightCityFoundation

@MainActor
public final class CaptureViewModel: ObservableObject {
    // MARK: - Published State
    
    @Published public var processingState: ProcessingState = .idle
    @Published public var captureResult: CaptureResult?
    @Published public var qualityWarning: String?
    @Published public var showManualEntry = false
    @Published public var manualCitationNumber = ""
    
    // MARK: - Dependencies
    
    private let cameraManager: CameraManager
    private let ocrEngine = OCREngine()
    private let preprocessor = OCRPreprocessor()
    private let parsingEngine = OCRParsingEngine()
    private let confidenceScorer = ConfidenceScorer()
    private let frameAnalyzer = FrameQualityAnalyzer()
    private let apiClient = APIClient.shared
    private let config: AppConfig
    
    // MARK: - Initialization
    
    public init(config: AppConfig = .shared) {
        self.config = config
        self.cameraManager = CameraManager(config: iOSAppConfig.shared)
    }
    
    // MARK: - Authorization
    
    public func requestCameraAuthorization() async {
        let granted = await cameraManager.requestAuthorization()
        if granted {
            do {
                try await setupCamera()
            } catch {
                processingState = .error("Failed to setup camera: \(error.localizedDescription)")
            }
        }
    }
    
    public var isAuthorized: Bool {
        // Would check actual authorization status
        true
    }
    
    // MARK: - Camera Setup
    
    private func setupCamera() async throws {
        try await cameraManager.setupSession()
        await cameraManager.startSession()
    }
    
    public func stopCapture() async {
        await cameraManager.stopSession()
    }
    
    // MARK: - Capture
    
    public func capturePhoto() async {
        processingState = .capturing
        
        do {
            guard let imageData = try await cameraManager.capturePhoto() else {
                processingState = .error("Failed to capture image")
                return
            }
            
            processingState = .processing
            
            // Process the image
            let result = await processImage(data: imageData)
            captureResult = result
            processingState = .complete(result)
            
            // Navigate to confirmation
            if let result = captureResult {
                // Will be handled by coordinator
            }
        } catch {
            processingState = .error(error.localizedDescription)
        }
    }
    
    // MARK: - Image Processing
    
    private func processImage(data: Data) async -> CaptureResult {
        let startTime = Date()
        
        guard let image = UIImage(data: data) else {
            return CaptureResult(
                originalImageData: data,
                rawText: "",
                confidence: 0,
                processingTimeMs: Int(Date().timeIntervalSince(startTime) * 1000)
            )
        }
        
        // Check image quality
        let qualityResult = frameAnalyzer.analyze(image)
        qualityWarning = qualityResult.warnings.isEmpty ? nil : qualityResult.feedbackMessage
        
        // Preprocess for OCR
        let processedImage: UIImage
        do {
            processedImage = try await preprocessor.preprocess(image)
        } catch {
            // Log preprocessing error but continue with original image
            print("Warning: Image preprocessing failed: \(error.localizedDescription)")
            processedImage = image
        }
        
        // Perform OCR
        let ocrResult: OCREngine.RecognitionResult
        do {
            ocrResult = try await ocrEngine.recognizeText(in: processedImage)
        } catch {
            return CaptureResult(
                originalImageData: data,
                croppedImageData: processedImage.pngData(),
                rawText: "",
                confidence: 0,
                processingTimeMs: Int(Date().timeIntervalSince(startTime) * 1000)
            )
        }
        
        // Parse citation number
        let parsingResult = parsingEngine.parse(ocrResult.text)
        
        // Calculate confidence
        let scoreResult = confidenceScorer.score(
            rawText: ocrResult.text,
            observations: ocrResult.observations,
            matchedPattern: parsingResult.matchedPattern
        )
        
        // Validate with API if we have a citation number
        var citation: Citation?
        if let citationNumber = parsingResult.citationNumber {
            citation = await validateCitation(citationNumber, cityId: parsingResult.cityId)
        }
        
        let processingTimeMs = Int(Date().timeIntervalSince(startTime) * 1000)
        
        return CaptureResult(
            originalImageData: data,
            croppedImageData: processedImage.pngData(),
            rawText: ocrResult.text,
            extractedCitationNumber: citation?.citationNumber ?? parsingResult.citationNumber,
            extractedCityId: citation?.cityId ?? parsingResult.cityId,
            extractedDate: citation?.violationDate,
            confidence: scoreResult.overallConfidence,
            processingTimeMs: processingTimeMs,
            observations: [:]
        )
    }
    
    // MARK: - API Validation
    
    private func validateCitation(_ citationNumber: String, cityId: String?) async -> Citation? {
        let request = CitationValidationRequest(
            citation_number: citationNumber,
            city_id: cityId
        )
        
        do {
            let response: CitationValidationResponse = try await apiClient.post(
                .validateCitation(request),
                body: request
            )
            return response.toCitation()
        } catch {
            return nil
        }
    }
    
    // MARK: - Manual Entry
    
    public func submitManualEntry() async -> CaptureResult? {
        guard !manualCitationNumber.isEmpty else { return nil }
        
        processingState = .processing
        
        let result = CaptureResult(
            rawText: manualCitationNumber,
            extractedCitationNumber: manualCitationNumber,
            confidence: 1.0,
            processingTimeMs: 0
        )
        
        captureResult = result
        processingState = .complete(result)
        showManualEntry = false
        
        return result
    }
    
    // MARK: - Reset
    
    public func reset() {
        processingState = .idle
        captureResult = nil
        qualityWarning = nil
        manualCitationNumber = ""
    }
}

// MARK: - Processing State

extension ProcessingState {
    var isProcessing: Bool {
        switch self {
        case .analyzing, .capturing, .processing:
            return true
        default:
            return false
        }
    }
}
```

## Sources/FightCity/Features/Capture/CaptureView.swift
```
//
//  CaptureView.swift
//  FightCity
//
//  Camera capture view for scanning tickets
//

import SwiftUI
import AVFoundation
import FightCityiOS

public struct CaptureView: View {
    @StateObject private var viewModel = CaptureViewModel()
    @EnvironmentObject private var coordinator: AppCoordinator
    @Environment(\.dismiss) private var dismiss
    
    public init() {}
    
    public var body: some View {
        ZStack {
            // Camera preview
            cameraPreview
                .ignoresSafeArea()
            
            // Overlay
            VStack {
                // Header
                headerView
                
                Spacer()
                
                // Quality warning
                if let warning = viewModel.qualityWarning {
                    qualityWarningView(warning)
                }
                
                // Controls
                controlsView
            }
            
            // Loading overlay
            if viewModel.processingState.isProcessing {
                LoadingOverlay(
                    message: viewModel.processingState.statusText,
                    isShowing: true
                )
            }
            
            // Manual entry sheet
            if viewModel.showManualEntry {
                manualEntrySheet
            }
        }
        .onAppear {
            Task {
                await viewModel.requestCameraAuthorization()
            }
        }
        .onDisappear {
            Task {
                await viewModel.stopCapture()
            }
        }
        .sheet(item: $viewModel.captureResult) { result in
            // Navigate to confirmation when capture is complete
            ConfirmationView(result: result)
                .environmentObject(viewModel)
        }
    }
    
    // MARK: - Camera Preview
    
    private var cameraPreview: some View {
        // Placeholder for camera preview
        // In real implementation, would use CameraPreviewView
        Rectangle()
            .fill(Color.black)
            .overlay(
                VStack {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.white.opacity(0.5))
                    Text("Camera Preview")
                        .foregroundColor(.white.opacity(0.5))
                }
            )
    }
    
    // MARK: - Header
    
    private var headerView: some View {
        HStack {
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "xmark")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(12)
                    .background(Color.black.opacity(0.5))
                    .clipShape(Circle())
            }
            
            Spacer()
            
            Button(action: {
                viewModel.showManualEntry = true
            }) {
                Image(systemName: "keyboard")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(12)
                    .background(Color.black.opacity(0.5))
                    .clipShape(Circle())
            }
        }
        .padding()
    }
    
    // MARK: - Quality Warning
    
    private func qualityWarningView(_ warning: String) -> some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
            
            Text(warning)
                .font(AppTypography.labelMedium)
                .foregroundColor(.orange)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.orange.opacity(0.15))
        .cornerRadius(12)
        .padding(.horizontal, 24)
    }
    
    // MARK: - Controls
    
    private var controlsView: some View {
        VStack(spacing: 24) {
            // Capture status
            Text(viewModel.processingState.statusText)
                .font(AppTypography.labelMedium)
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.black.opacity(0.5))
                .cornerRadius(20)
            
            // Capture button
            Button(action: {
                Task {
                    await viewModel.capturePhoto()
                }
            }) {
                Circle()
                    .fill(Color.white)
                    .frame(width: 72, height: 72)
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 4)
                            .frame(width: 80, height: 80)
                    )
            }
            .disabled(viewModel.processingState.isProcessing)
        }
        .padding(.bottom, 48)
    }
    
    // MARK: - Manual Entry Sheet
    
    private var manualEntrySheet: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture {
                    viewModel.showManualEntry = false
                }
            
            VStack(spacing: 24) {
                Text("Enter Citation Number")
                    .font(AppTypography.titleMedium)
                
                TextField("Citation Number", text: $viewModel.manualCitationNumber)
                    .textFieldStyle(.roundedBorder)
                    .font(AppTypography.citationNumber)
                    .textInputAutocapitalization(.characters)
                
                HStack(spacing: 16) {
                    SecondaryButton(title: "Cancel", action: {
                        viewModel.showManualEntry = false
                    })
                    
                    PrimaryButton(title: "Submit", action: {
                        Task {
                            await viewModel.submitManualEntry()
                        }
                    })
                }
            }
            .padding(24)
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .padding(.horizontal, 32)
        }
    }
}

// MARK: - Previews

#if DEBUG
struct CaptureView_Previews: PreviewProvider {
    static var previews: some View {
        CaptureView()
            .environmentObject(AppCoordinator())
    }
}
#endif
```

## Sources/FightCity/Features/Confirmation/ConfirmationView.swift
```
//
//  ConfirmationView.swift
//  FightCity
//
//  View for confirming extracted citation details
//

import SwiftUI
import FightCityFoundation
import FightCityiOS

public struct ConfirmationView: View {
    let captureResult: CaptureResult
    let onConfirm: (CaptureResult) -> Void
    let onRetake: () -> Void
    let onEdit: (String) -> Void
    
    @State private var editedCitationNumber: String
    @State private var showEditSheet = false
    
    public init(captureResult: CaptureResult, onConfirm: @escaping (CaptureResult) -> Void, onRetake: @escaping () -> Void, onEdit: @escaping (String) -> Void) {
        self.captureResult = captureResult
        self.onConfirm = onConfirm
        self.onRetake = onRetake
        self.onEdit = onEdit
        self._editedCitationNumber = State(initialValue: captureResult.extractedCitationNumber ?? "")
    }
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Image preview
                imagePreviewSection
                
                // Citation details
                citationDetailsSection
                
                // Confidence indicator
                confidenceSection
                
                // Action buttons
                actionButtonsSection
            }
            .padding()
        }
        .navigationTitle("Confirm")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var imagePreviewSection: some View {
        Group {
            if let imageData = captureResult.croppedImageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 200)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                    )
            }
        }
    }
    
    private var citationDetailsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Extracted Details")
                .font(.headline)
            
            VStack(spacing: 12) {
                detailRow(label: "Citation Number", value: captureResult.extractedCitationNumber ?? "Not detected", isEditable: true)
                
                if let cityId = captureResult.extractedCityId {
                    detailRow(label: "City", value: formatCityId(cityId))
                }
                
                if let date = captureResult.extractedDate {
                    detailRow(label: "Violation Date", value: date)
                }
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
        }
    }
    
    private func detailRow(label: String, value: String, isEditable: Bool = false) -> some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
                .multilineTextAlignment(.trailing)
            if isEditable {
                Button(action: {
                    showEditSheet = true
                }) {
                    Image(systemName: "pencil.circle")
                        .foregroundColor(.accentColor)
                }
            }
        }
    }
    
    private var confidenceSection: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Recognition Confidence")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                ConfidenceIndicator(
                    confidence: captureResult.confidence,
                    level: confidenceLevel(for: captureResult.confidence)
                )
            }
            
            if captureResult.confidence < 0.85 {
                Text(confidenceMessage(for: captureResult.confidence))
                    .font(.caption)
                    .foregroundColor(.orange)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
    
    private var actionButtonsSection: some View {
        VStack(spacing: 12) {
            PrimaryButton(title: "Looks Good - Validate", action: {
                var result = captureResult
                result.extractedCitationNumber = editedCitationNumber
                onConfirm(result)
            })
            .disabled(editedCitationNumber.isEmpty)
            
            SecondaryButton(title: "Edit Number", action: {
                showEditSheet = true
            })
            
            TertiaryButton(title: "Retake Photo", action: onRetake)
        }
    }
    
    private func confidenceLevel(for confidence: Double) -> ConfidenceScorer.ConfidenceLevel {
        if confidence >= 0.85 { return .high }
        if confidence >= 0.60 { return .medium }
        return .low
    }
    
    private func confidenceMessage(for confidence: Double) -> String {
        if confidence < 0.60 {
            return "Confidence is low. Please verify the citation number carefully or retake the photo."
        } else {
            return "Confidence is medium. Please verify the extracted information is correct."
        }
    }
    
    private func formatCityId(_ cityId: String) -> String {
        let components = cityId.components(separatedBy: "-")
        return components.dropFirst().map { $0.capitalized }.joined(separator: " ")
    }
}

// MARK: - Tertiary Button

struct TertiaryButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
    }
}

// MARK: - Citation Detail View

public struct CitationDetailView: View {
    let citation: Citation
    
    @State private var showPaymentSheet = false
    @State private var showAppealSheet = false
    
    public init(citation: Citation) {
        self.citation = citation
    }
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header card
                headerCard
                
                // Deadline card
                deadlineCard
                
                // Actions
                actionButtons
            }
            .padding()
        }
        .navigationTitle("Citation Details")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var headerCard: some View {
        CardView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(citation.citationNumber)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        if let city = citation.cityName {
                            Text(city)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    StatusBadge(status: citation.status)
                }
                
                if let amount = citation.amount {
                    Divider()
                    HStack {
                        Text("Amount Due")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(amount, format: .currency(code: "USD"))
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                }
            }
        }
    }
    
    private var deadlineCard: some View {
        CardView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Deadline")
                    .font(.headline)
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        if let deadline = citation.deadlineDate {
                            Text(deadline, style: .date)
                                .font(.title3)
                                .fontWeight(.semibold)
                        }
                        
                        if let days = citation.daysRemaining {
                            Text("\(days) days remaining")
                                .font(.subheadline)
                                .foregroundColor(deadlineColor)
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: deadlineIcon)
                        .font(.largeTitle)
                        .foregroundColor(deadlineColor)
                }
            }
        }
    }
    
    private var deadlineColor: Color {
        if citation.isPastDeadline {
            return .red
        } else if let days = citation.daysRemaining, days <= 7 {
            return .orange
        }
        return .green
    }
    
    private var deadlineIcon: String {
        if citation.isPastDeadline {
            return "exclamationmark.triangle.fill"
        } else if let days = citation.daysRemaining, days <= 7 {
            return "clock.fill"
        }
        return "checkmark.circle.fill"
    }
    
    private var actionButtons: some View {
        VStack(spacing: 12) {
            if citation.status != .paid {
                PrimaryButton(title: "Pay Fine", action: {
                    showPaymentSheet = true
                })
            }
            
            if citation.canAppealOnline && !citation.isPastDeadline {
                SecondaryButton(title: "File Appeal", action: {
                    showAppealSheet = true
                })
            }
            
            if !citation.isPastDeadline {
                TertiaryButton(title: "Set Reminder", action: {
                    // Set reminder logic
                })
            }
        }
    }
}
```

## Sources/FightCity/Features/History/HistoryView.swift
```
//
//  HistoryView.swift
//  FightCity
//
//  View displaying citation history with search and filtering
//

import SwiftUI
import FightCityFoundation
import FightCityiOS

public struct HistoryView: View {
    @StateObject private var viewModel = HistoryViewModel()
    @State private var searchText = ""
    @State private var selectedFilter: CitationFilter = .all
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            Group {
                if viewModel.citations.isEmpty {
                    EmptyHistoryView(onAddTapped: {
                        // Navigate to capture
                    })
                } else {
                    historyList
                }
            }
            .navigationTitle("History")
            .searchable(text: $searchText, prompt: "Search citations")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    filterMenu
                }
            }
            .refreshable {
                await viewModel.loadCitations()
            }
            .task {
                await viewModel.loadCitations()
            }
        }
    }
    
    private var historyList: some View {
        List {
            ForEach(groupedCitations.keys.sorted().reversed(), id: \.self) { month in
                Section(header: Text(month)) {
                    ForEach(groupedCitations[month] ?? []) { citation in
                        NavigationLink(destination: CitationDetailView(citation: citation)) {
                            CitationRow(citation: citation)
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }
    
    private var filterMenu: some View {
        Menu {
            ForEach(CitationFilter.allCases, id: \.self) { filter in
                Button(action: {
                    selectedFilter = filter
                    viewModel.setFilter(filter)
                }) {
                    Label(filter.displayName, systemImage: filter.iconName)
                }
            }
        } label: {
            Image(systemName: "line.3.horizontal.decrease.circle")
        }
    }
    
    private var groupedCitations: [String: [Citation]] {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        
        var groups: [String: [Citation]] = [:]
        
        let filtered = viewModel.citations.filter { citation in
            if searchText.isEmpty { return true }
            return citation.citationNumber.localizedCaseInsensitiveContains(searchText)
        }
        
        for citation in filtered {
            let key = formatter.string(from: citation.violationDate ?? Date())
            groups[key, default: []].append(citation)
        }
        
        return groups
    }
}

// MARK: - History View Model

@MainActor
public final class HistoryViewModel: ObservableObject {
    @Published public var citations: [Citation] = []
    @Published public var isLoading = false
    @Published public var error: Error?
    
    private let storage: HistoryStorageProtocol
    
    public init(storage: HistoryStorageProtocol = HistoryStorage()) {
        self.storage = storage
    }
    
    public func loadCitations() async {
        isLoading = true
        do {
            citations = try await storage.loadHistory()
            citations.sort { ($0.violationDate ?? .distantPast) > ($1.violationDate ?? .distantPast) }
        } catch {
            self.error = error
        }
        isLoading = false
    }
    
    public func setFilter(_ filter: CitationFilter) {
        // Apply filter logic
    }
    
    public func deleteCitation(_ citation: Citation) async {
        citations.removeAll { $0.id == citation.id }
        try? await storage.deleteCitation(citation.id)
    }
}

// MARK: - Citation Filter

public enum CitationFilter: CaseIterable {
    case all
    case pending
    case appealed
    case paid
    
    public var displayName: String {
        switch self {
        case .all: return "All"
        case .pending: return "Pending"
        case .appealed: return "Appealed"
        case .paid: return "Paid"
        }
    }
    
    public var iconName: String {
        switch self {
        case .all: return "tray.full"
        case .pending: return "clock"
        case .appealed: return "bubble.left.and.bubble.right"
        case .paid: return "checkmark.circle"
        }
    }
}

// MARK: - Citation Row

struct CitationRow: View {
    let citation: Citation
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(citation.citationNumber)
                    .font(.headline)
                Spacer()
                StatusBadge(status: citation.status)
            }
            
            HStack {
                if let city = citation.cityName {
                    Text(city)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if let date = citation.violationDate {
                    Text(date, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if let amount = citation.amount {
                Text(amount, format: .currency(code: "USD"))
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Empty History View

struct EmptyHistoryView: View {
    let onAddTapped: () -> Void
    
    var body: some View {
        EmptyStateView(
            icon: "tray",
            title: "No Citations Yet",
            message: "Capture your first parking ticket to get started.",
            buttonTitle: "Scan Ticket",
            buttonAction: onAddTapped
        )
    }
}

// MARK: - History Storage Protocol

public protocol HistoryStorageProtocol {
    func loadHistory() async throws -> [Citation]
    func saveCitation(_ citation: Citation) async throws
    func deleteCitation(_ id: UUID) async throws
}

// MARK: - History Storage Implementation

public final class HistoryStorage: HistoryStorageProtocol {
    private let storage: Storage
    private let key = "citation_history"
    
    public init(storage: Storage = UserDefaultsStorage()) {
        self.storage = storage
    }
    
    public func loadHistory() async throws -> [Citation] {
        guard let data = storage.load(key: key) else {
            return []
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode([Citation].self, from: data)
    }
    
    public func saveCitation(_ citation: Citation) async throws {
        var history = (try? await loadHistory()) ?? []
        
        // Remove existing with same ID
        history.removeAll { $0.id == citation.id }
        history.insert(citation, at: 0)
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(history)
        _ = storage.save(key: key, data: data)
    }
    
    public func deleteCitation(_ id: UUID) async throws {
        var history = (try? await loadHistory()) ?? []
        history.removeAll { $0.id == id }
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(history)
        _ = storage.save(key: key, data: data)
    }
}
```

## Sources/FightCity/Features/Onboarding/OnboardingView.swift
```
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
```

## Sources/FightCity/Features/Root/ContentView.swift
```
//
//  ContentView.swift
//  FightCity
//
//  Root content view with navigation
//

import SwiftUI

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
            ConfirmationView(result: result)
            
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

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AppCoordinator())
            .environmentObject(AppConfig.shared)
    }
}
#endif
```

## Sources/FightCityFoundation/Logging/Logger.swift
```
//
//  Logger.swift
//  FightCityFoundation
//
//  Production-ready logging with levels and OS integration
//

import Foundation
import os.log

/// Log levels for filtering and configuration
public enum LogLevel: String, CaseIterable {
    case debug = "DEBUG"
    case info = "INFO"
    case warning = "WARNING"
    case error = "ERROR"
    
    var osLogType: OSLogType {
        switch self {
        case .debug: return .debug
        case .info: return .info
        case .warning: return .default
        case .error: return .error
        }
    }
}

/// Logger protocol for testability
public protocol LoggerProtocol {
    func debug(_ message: String, file: String, function: String, line: Int)
    func info(_ message: String, file: String, function: String, line: Int)
    func warning(_ message: String, file: String, function: String, line: Int)
    func error(_ message: String, file: String, function: String, line: Int)
    func error(_ error: Error, file: String, function: String, line: Int)
}

/// Production logger using OSLog
public final class Logger: LoggerProtocol {
    public static let shared = Logger()
    
    private let subsystem: String
    private let logger: os.Logger
    
    public init(subsystem: String = "com.fightcitytickets.app") {
        self.subsystem = subsystem
        self.logger = os.Logger(subsystem: subsystem, category: "App")
    }
    
    public func debug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(level: .debug, message: message, file: file, function: function, line: line)
    }
    
    public func info(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(level: .info, message: message, file: file, function: function, line: line)
    }
    
    public func warning(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(level: .warning, message: message, file: file, function: function, line: line)
    }
    
    public func error(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(level: .error, message: message, file: file, function: function, line: line)
    }
    
    public func error(_ error: Error, file: String = #file, function: String = #function, line: Int = #line) {
        log(level: .error, message: error.localizedDescription, file: file, function: function, line: line)
    }
    
    private func log(level: LogLevel, message: String, file: String, function: String, line: Int) {
        #if DEBUG
        let filename = (file as NSString).lastPathComponent
        let formattedMessage = "[\(level.rawValue)] \(filename):\(line) \(function) - \(message)"
        print(formattedMessage)
        #endif
        
        logger.log(level: level.osLogType, "\(message, privacy: .public)")
    }
}

/// Mock logger for testing
public final class MockLogger: LoggerProtocol {
    public var logs: [(level: LogLevel, message: String, file: String, function: String, line: Int)] = []
    
    public init() {}
    
    public func debug(_ message: String, file: String, function: String, line: Int) {
        logs.append((.debug, message, file, function, line))
    }
    
    public func info(_ message: String, file: String, function: String, line: Int) {
        logs.append((.info, message, file, function, line))
    }
    
    public func warning(_ message: String, file: String, function: String, line: Int) {
        logs.append((.warning, message, file, function, line))
    }
    
    public func error(_ message: String, file: String, function: String, line: Int) {
        logs.append((.error, message, file, function, line))
    }
    
    public func error(_ error: Error, file: String, function: String, line: Int) {
        logs.append((.error, error.localizedDescription, file, function, line))
    }
    
    public func clear() {
        logs.removeAll()
    }
}
```

## Sources/FightCityFoundation/Models/Citation.swift
```
//
//  Citation.swift
//  FightCityFoundation
//
//  Citation model matching the backend API schema
//

import Foundation

/// Main citation model representing a parking ticket
public struct Citation: Identifiable, Codable, Equatable {
    public let id: UUID
    public let citationNumber: String
    public let cityId: String?
    public let cityName: String?
    public let agency: String?
    public let sectionId: String?
    public let formattedCitation: String?
    public let licensePlate: String?
    public let violationDate: String?
    public let violationTime: String?
    public let amount: Decimal?
    public let deadlineDate: String?
    public let daysRemaining: Int?
    public let isPastDeadline: Bool
    public let isUrgent: Bool
    public let canAppealOnline: Bool
    public let phoneConfirmationRequired: Bool
    public let status: CitationStatus
    public let createdAt: Date
    public let updatedAt: Date
    
    public init(
        id: UUID = UUID(),
        citationNumber: String,
        cityId: String? = nil,
        cityName: String? = nil,
        agency: String? = nil,
        sectionId: String? = nil,
        formattedCitation: String? = nil,
        licensePlate: String? = nil,
        violationDate: String? = nil,
        violationTime: String? = nil,
        amount: Decimal? = nil,
        deadlineDate: String? = nil,
        daysRemaining: Int? = nil,
        isPastDeadline: Bool = false,
        isUrgent: Bool = false,
        canAppealOnline: Bool = true,
        phoneConfirmationRequired: Bool = false,
        status: CitationStatus = .pending,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.citationNumber = citationNumber
        self.cityId = cityId
        self.cityName = cityName
        self.agency = agency
        self.sectionId = sectionId
        self.formattedCitation = formattedCitation
        self.licensePlate = licensePlate
        self.violationDate = violationDate
        self.violationTime = violationTime
        self.amount = amount
        self.deadlineDate = deadlineDate
        self.daysRemaining = daysRemaining
        self.isPastDeadline = isPastDeadline
        self.isUrgent = isUrgent
        self.canAppealOnline = canAppealOnline
        self.phoneConfirmationRequired = phoneConfirmationRequired
        self.status = status
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    // MARK: - Computed Properties
    
    public var displayCitationNumber: String {
        formattedCitation ?? citationNumber
    }
    
    public var deadlineStatus: DeadlineStatus {
        if isPastDeadline {
            return .past
        } else if isUrgent {
            return .urgent
        } else if let days = daysRemaining, days <= 7 {
            return .approaching
        } else {
            return .safe
        }
    }
    
    public var isValidatable: Bool {
        !citationNumber.isEmpty && citationNumber.count >= 5
    }
    
    // MARK: - Coding Keys
    
    public enum CodingKeys: String, CodingKey {
        case id
        case citation_number
        case city_id
        case city_name
        case agency
        case section_id
        case formatted_citation
        case license_plate
        case violation_date
        case violation_time
        case amount
        case deadline_date
        case days_remaining
        case is_past_deadline
        case is_urgent
        case can_appeal_online
        case phone_confirmation_required
        case status
        case created_at
        case updated_at
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        citationNumber = try container.decode(String.self, forKey: .citation_number)
        cityId = try container.decodeIfPresent(String.self, forKey: .city_id)
        cityName = try container.decodeIfPresent(String.self, forKey: .city_name)
        agency = try container.decodeIfPresent(String.self, forKey: .agency)
        sectionId = try container.decodeIfPresent(String.self, forKey: .section_id)
        formattedCitation = try container.decodeIfPresent(String.self, forKey: .formatted_citation)
        licensePlate = try container.decodeIfPresent(String.self, forKey: .license_plate)
        violationDate = try container.decodeIfPresent(String.self, forKey: .violation_date)
        violationTime = try container.decodeIfPresent(String.self, forKey: .violation_time)
        amount = try container.decodeIfPresent(Decimal.self, forKey: .amount)
        deadlineDate = try container.decodeIfPresent(String.self, forKey: .deadline_date)
        daysRemaining = try container.decodeIfPresent(Int.self, forKey: .days_remaining)
        isPastDeadline = try container.decode(Bool.self, forKey: .is_past_deadline)
        isUrgent = try container.decode(Bool.self, forKey: .is_urgent)
        canAppealOnline = try container.decode(Bool.self, forKey: .can_appeal_online)
        phoneConfirmationRequired = try container.decode(Bool.self, forKey: .phone_confirmation_required)
        status = try container.decodeIfPresent(CitationStatus.self, forKey: .status) ?? .pending
        createdAt = try container.decodeIfPresent(Date.self, forKey: .created_at) ?? Date()
        updatedAt = try container.decodeIfPresent(Date.self, forKey: .updated_at) ?? Date()
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(citationNumber, forKey: .citation_number)
        try container.encodeIfPresent(cityId, forKey: .city_id)
        try container.encodeIfPresent(cityName, forKey: .city_name)
        try container.encodeIfPresent(agency, forKey: .agency)
        try container.encodeIfPresent(sectionId, forKey: .section_id)
        try container.encodeIfPresent(formattedCitation, forKey: .formatted_citation)
        try container.encodeIfPresent(licensePlate, forKey: .license_plate)
        try container.encodeIfPresent(violationDate, forKey: .violation_date)
        try container.encodeIfPresent(violationTime, forKey: .violation_time)
        try container.encodeIfPresent(amount, forKey: .amount)
        try container.encodeIfPresent(deadlineDate, forKey: .deadline_date)
        try container.encodeIfPresent(daysRemaining, forKey: .days_remaining)
        try container.encode(isPastDeadline, forKey: .is_past_deadline)
        try container.encode(isUrgent, forKey: .is_urgent)
        try container.encode(canAppealOnline, forKey: .can_appeal_online)
        try container.encode(phoneConfirmationRequired, forKey: .phone_confirmation_required)
        try container.encode(status, forKey: .status)
        try container.encode(createdAt, forKey: .created_at)
        try container.encode(updatedAt, forKey: .updated_at)
    }
}

// MARK: - Citation Status

/// Status of a citation in the appeal flow
public enum CitationStatus: String, Codable {
    case pending
    case validated
    case inReview = "in_review"
    case appealed
    case approved
    case denied
    case paid
    case expired
    
    public var displayName: String {
        switch self {
        case .pending: return "Pending"
        case .validated: return "Validated"
        case .inReview: return "In Review"
        case .appealed: return "Appealed"
        case .approved: return "Approved"
        case .denied: return "Denied"
        case .paid: return "Paid"
        case .expired: return "Expired"
        }
    }
}

// MARK: - Deadline Status

/// Deadline urgency status
public enum DeadlineStatus {
    case safe
    case approaching
    case urgent
    case past
    
    public var displayText: String {
        switch self {
        case .safe: return "On Track"
        case .approaching: return "Approaching"
        case .urgent: return "Urgent"
        case .past: return "Past Due"
        }
    }
    
    public var colorName: String {
        switch self {
        case .safe: return "deadlineSafe"
        case .approaching: return "deadlineApproaching"
        case .urgent: return "deadlineUrgent"
        case .past: return "deadlineUrgent"
        }
    }
}

// MARK: - Citation Agency

/// Known citation agencies (from backend CitationAgency enum)
public enum CitationAgency: String, Codable, CaseIterable {
    case unknown = "UNKNOWN"
    case sfMta = "SFMTA"
    case sfPd = "SFPD"
    case laDot = "LADOT"
    case laXd = "LAXD"
    case laPd = "LAPD"
    case nycDo = "NYC_DO"
    case nycPd = "NYPD"
    case denver = "DENVER"
    
    public var displayName: String {
        switch self {
        case .unknown: return "Unknown"
        case .sfMta: return "SFMTA"
        case .sfPd: return "SFPD"
        case .laDot: return "LADOT"
        case .laXd: return "LAX"
        case .laPd: return "LAPD"
        case .nycDo: return "NYC DOF"
        case .nycPd: return "NYPD"
        case .denver: return "Denver"
        }
    }
}
```

## Sources/FightCityFoundation/Models/CityConfig.swift
```
//
//  CityConfig.swift
//  FightCityFoundation
//
//  City configuration and settings for portable Foundation code
//

import Foundation

/// City configuration for citation processing
public struct CityConfig: Codable, Identifiable, Equatable {
    public let id: String
    public let name: String
    public let state: String
    public let agencyCode: String
    public let citationPrefix: String?
    public let citationPattern: String?
    public let timezone: String
    public let deadlineDays: Int
    public let appealUrl: String?
    
    public init(
        id: String,
        name: String,
        state: String,
        agencyCode: String,
        citationPrefix: String? = nil,
        citationPattern: String? = nil,
        timezone: String = "America/Los_Angeles",
        deadlineDays: Int = 21,
        appealUrl: String? = nil
    ) {
        self.id = id
        self.name = name
        self.state = state
        self.agencyCode = agencyCode
        self.citationPrefix = citationPrefix
        self.citationPattern = citationPattern
        self.timezone = timezone
        self.deadlineDays = deadlineDays
        self.appealUrl = appealUrl
    }
}

/// Known city configurations
public enum CityConfigFactory {
    public static let sf = CityConfig(
        id: "sf",
        name: "San Francisco",
        state: "CA",
        agencyCode: "SFMTA",
        citationPattern: "^[0-9]{8,}$",
        timezone: "America/Los_Angeles",
        deadlineDays: 21
    )
    
    public static let la = CityConfig(
        id: "la",
        name: "Los Angeles",
        state: "CA",
        agencyCode: "LADOT",
        citationPattern: "^[A-Z0-9]{6,12}$",
        timezone: "America/Los_Angeles",
        deadlineDays: 21
    )
    
    public static let nyc = CityConfig(
        id: "nyc",
        name: "New York City",
        state: "NY",
        agencyCode: "NYC_DO",
        citationPattern: "^[0-9]{10,}$",
        timezone: "America/New_York",
        deadlineDays: 30
    )
    
    public static let allCities: [CityConfig] = [sf, la, nyc]
    
    public static func config(for cityId: String) -> CityConfig? {
        allCities.first { $0.id == cityId }
    }
}
```

## Sources/FightCityFoundation/Models/TelemetryRecord.swift
```
//
//  TelemetryRecord.swift
//  FightCityFoundation
//
//  Individual telemetry record (opt-in)
//

import Foundation

/// Individual telemetry record (opt-in)
public struct TelemetryRecord: Codable {
    public let city: String
    public let timestamp: Date
    public let deviceModel: String
    public let iOSVersion: String
    public let originalImageHash: String
    public let croppedImageHash: String
    public let ocrOutput: String
    public let userCorrection: String?
    public let confidence: Double
    public let processingTimeMs: Int
    
    public enum CodingKeys: String, CodingKey {
        case city
        case timestamp
        case deviceModel = "device_model"
        case iOSVersion = "ios_version"
        case originalImageHash = "original_image_hash"
        case croppedImageHash = "cropped_image_hash"
        case ocrOutput = "ocr_output"
        case userCorrection = "user_correction"
        case confidence
        case processingTimeMs = "processing_time_ms"
    }
    
    public init(
        city: String,
        timestamp: Date,
        deviceModel: String,
        iOSVersion: String,
        originalImageHash: String,
        croppedImageHash: String,
        ocrOutput: String,
        userCorrection: String?,
        confidence: Double,
        processingTimeMs: Int
    ) {
        self.city = city
        self.timestamp = timestamp
        self.deviceModel = deviceModel
        self.iOSVersion = iOSVersion
        self.originalImageHash = originalImageHash
        self.croppedImageHash = croppedImageHash
        self.ocrOutput = ocrOutput
        self.userCorrection = userCorrection
        self.confidence = confidence
        self.processingTimeMs = processingTimeMs
    }
}
```

## Sources/FightCityFoundation/Models/TelemetryStorage.swift
```
//
//  TelemetryStorage.swift
//  FightCityFoundation
//
//  Secure local storage for telemetry data
//

import Foundation

/// Secure storage for telemetry records
public final class TelemetryStorage {
    private let persistence: FilePersistence<TelemetryRecord>
    private let uploadQueue: FilePersistence<UploadedRecord>
    
    private let maxRecords = 1000
    
    public init() {
        self.persistence = FilePersistence(name: "telemetry_pending")
        self.uploadQueue = FilePersistence(name: "telemetry_uploaded")
    }
    
    // MARK: - Save
    
    /// Save a telemetry record
    public func save(_ record: TelemetryRecord) {
        var records = persistence.load() ?? []
        
        // Remove old records if exceeding max
        if records.count >= maxRecords {
            records.removeFirst(records.count - maxRecords + 1)
        }
        
        records.append(record)
        persistence.save(records)
    }
    
    // MARK: - Query
    
    /// Get all pending records
    public func pendingRecords() -> [TelemetryRecord] {
        persistence.load() ?? []
    }
    
    /// Get count of pending records
    public func pendingCount() -> Int {
        pendingRecords().count
    }
    
    /// Get total records (including uploaded)
    public func totalCount() -> Int {
        let pending = pendingRecords().count
        let uploaded = (uploadQueue.load() ?? []).count
        return pending + uploaded
    }
    
    // MARK: - Update
    
    /// Mark records as uploaded
    public func markAsUploaded(_ records: [TelemetryRecord]) {
        var existing = uploadQueue.load() ?? []
        
        for record in records {
            let uploaded = UploadedRecord(id: record.id, timestamp: Date())
            existing.append(uploaded)
        }
        
        // Keep only recent uploads (last 100)
        if existing.count > 100 {
            existing.removeFirst(existing.count - 100)
        }
        
        uploadQueue.save(existing)
        
        // Remove from pending
        var pending = persistence.load() ?? []
        let uploadedIds = Set(records.map { $0.id })
        pending.removeAll { uploadedIds.contains($0.id) }
        persistence.save(pending)
    }
    
    // MARK: - Clear
    
    /// Clear all telemetry data
    public func clearAll() {
        persistence.save([])
        uploadQueue.save([])
    }
    
    /// Remove old records
    public func removeOldRecords(olderThan date: Date) {
        var records = pendingRecords()
        records.removeAll { $0.timestamp < date }
        persistence.save(records)
    }
}

// MARK: - Uploaded Record

public struct UploadedRecord: Codable {
    public let id: UUID
    public let timestamp: Date
}

// MARK: - Secure Storage

extension TelemetryStorage {
    /// Encrypt sensitive data before storage
    private func encrypt(_ data: Data) -> Data {
        // In production, use proper encryption
        // This is a placeholder for demo purposes
        return data
    }
    
    /// Decrypt data after retrieval
    private func decrypt(_ data: Data) -> Data {
        // In production, use proper decryption
        return data
    }
}
```

## Sources/FightCityFoundation/Models/ValidationResult.swift
```
//
//  ValidationResult.swift
//  FightCityFoundation
//
//  Backend API validation response models
//

import Foundation

/// Request model matching backend API
public struct CitationValidationRequest: Codable {
    public let citation_number: String
    public let city_id: String?
    public let license_plate: String?
    public let violation_date: String?
    
    public init(
        citation_number: String,
        city_id: String? = nil,
        license_plate: String? = nil,
        violation_date: String? = nil
    ) {
        self.citation_number = citation_number
        self.city_id = city_id
        self.license_plate = license_plate
        self.violation_date = violation_date
    }
}

/// Response model matching backend API
public struct CitationValidationResponse: Codable {
    public let is_valid: Bool
    public let citation_number: String
    public let city_id: String?
    public let city_name: String?
    public let agency: String?
    public let section_id: String?
    public let formatted_citation: String?
    public let deadline_date: String?
    public let days_remaining: Int?
    public let is_past_deadline: Bool?
    public let is_urgent: Bool?
    public let can_appeal_online: Bool
    public let phone_confirmation_required: Bool
    public let error_message: String?
    
    // MARK: - Computed Properties
    
    public var deadlineStatus: DeadlineStatus {
        if is_past_deadline == true {
            return .past
        } else if is_urgent == true {
            return .urgent
        } else if let days = days_remaining, days <= 7 {
            return .approaching
        } else {
            return .safe
        }
    }
    
    public var hasError: Bool {
        !is_valid || error_message != nil
    }
    
    // MARK: - Conversion to Citation
    
    public func toCitation() -> Citation {
        Citation(
            citationNumber: citation_number,
            cityId: city_id,
            cityName: city_name,
            agency: agency,
            sectionId: section_id,
            formattedCitation: formatted_citation,
            deadlineDate: deadline_date,
            daysRemaining: days_remaining,
            isPastDeadline: is_past_deadline ?? false,
            isUrgent: is_urgent ?? false,
            canAppealOnline: can_appeal_online,
            phoneConfirmationRequired: phone_confirmation_required,
            status: is_valid ? .validated : .pending
        )
    }
}

// MARK: - Status Lookup

/// Request for looking up appeal status
public struct StatusLookupRequest: Codable {
    public let email: String
    public let citation_number: String
}

/// Response for status lookup
public struct StatusLookupResponse: Codable {
    public let citations: [Citation]
    public let email: String
    public let has_pending_appeals: Bool
}

// MARK: - Appeal Submit

/// Request to submit an appeal
public struct AppealSubmitRequest: Codable {
    public let citation_id: String
    public let appeal_reason: String
    public let statement: String?
    public let evidence_photos: [Data]?
}

// MARK: - API Error

/// API error response
public struct APIError: Codable, Error {
    public let error: String
    public let message: String?
    public let code: String?
    
    public static let networkError = APIError(
        error: "Network Error",
        message: "Unable to connect to the server. Please check your internet connection.",
        code: "NETWORK_ERROR"
    )
    
    public static let decodingError = APIError(
        error: "Data Error",
        message: "Unable to process server response.",
        code: "DECODING_ERROR"
    )
}

// MARK: - Health Check

/// Health check response
public struct HealthResponse: Codable {
    public let status: String
    public let timestamp: String
    public let version: String?
    
    public var isHealthy: Bool {
        status.lowercased() == "ok" || status.lowercased() == "healthy"
    }
}

// MARK: - OCR Config Response

/// Per-city OCR configuration from backend
public struct OCRConfigResponse: Codable {
    public let city_id: String
    public let patterns: [CityPattern]
    public let preprocessing_options: PreprocessingOptions?
    
    public struct CityPattern: Codable {
        public let pattern: String
        public let section_id: String
        public let priority: Int
    }
    
    public struct PreprocessingOptions: Codable {
        public let contrast_enhancement: Double?
        public let noise_reduction: Bool?
        public let perspective_correction: Bool?
    }
}
```

## Sources/FightCityFoundation/Networking/APIClient.swift
```
//
//  APIClient.swift
//  FightCityFoundation
//
//  URLSession wrapper with retry, timeout, and offline support
//

import Foundation

/// Configuration protocol for API client
public protocol APIConfiguration {
    var apiBaseURL: URL { get }
}

/// Default API configuration
public struct DefaultAPIConfiguration: APIConfiguration {
    public let apiBaseURL: URL
    
    public init(apiBaseURL: URL? = nil) {
        if let url = apiBaseURL {
            self.apiBaseURL = url
        } else if let url = URL(string: "https://api.fightcitytickets.com") {
            self.apiBaseURL = url
        } else {
            fatalError("Failed to create default API URL - this should never happen")
        }
    }
}

/// API client with retry logic, timeout, and offline support
public actor APIClient {
    public static let shared = APIClient()
    
    private let session: URLSession
    private var config: APIConfiguration
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    public init(config: APIConfiguration = DefaultAPIConfiguration()) {
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 30
        sessionConfig.timeoutIntervalForResource = 60
        sessionConfig.waitsForConnectivity = true
        self.session = URLSession(configuration: sessionConfig)
        self.config = config
        
        self.decoder = JSONDecoder()
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
        self.decoder.dateDecodingStrategy = .iso8601
        
        self.encoder = JSONEncoder()
        self.encoder.keyEncodingStrategy = .convertToSnakeCase
        self.encoder.dateEncodingStrategy = .iso8601
    }
    
    // MARK: - Configuration
    
    public func updateConfiguration(_ newConfig: APIConfiguration) {
        self.config = newConfig
    }
    
    // MARK: - GET
    
    public func get<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        let request = try buildRequest(endpoint: endpoint, method: .get)
        return try await execute(request)
    }
    
    public func getVoid(_ endpoint: APIEndpoint) async throws {
        let request = try buildRequest(endpoint: endpoint, method: .get)
        let (_, response) = try await session.data(for: request)
        try validateResponse(response)
    }
    
    // MARK: - POST
    
    public func post<T: Decodable, B: Encodable>(_ endpoint: APIEndpoint, body: B) async throws -> T {
        let request = try buildRequest(endpoint: endpoint, method: .post, body: body)
        return try await execute(request)
    }
    
    public func postVoid<B: Encodable>(_ endpoint: APIEndpoint, body: B) async throws {
        let request = try buildRequest(endpoint: endpoint, method: .post, body: body)
        let (_, response) = try await session.data(for: request)
        try validateResponse(response)
    }
    
    // MARK: - Private Methods
    
    private func buildRequest<B: Encodable>(endpoint: APIEndpoint, method: HTTPMethod, body: B? = nil) throws -> URLRequest {
        guard let url = URL(string: endpoint.path, relativeTo: config.apiBaseURL) else {
            throw APIError.invalidURL(path: endpoint.path)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        if let body = body {
            request.httpBody = try encoder.encode(body)
        }
        
        return request
    }
    
    private func execute<T: Decodable>(_ request: URLRequest) async throws -> T {
        let (data, response) = try await session.data(for: request)
        try validateResponse(response)
        
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingError(error: error)
        }
    }
    
    private func validateResponse(_ response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            return
        case 400:
            throw APIError.badRequest
        case 401:
            throw APIError.unauthorized
        case 404:
            throw APIError.notFound
        case 422:
            throw APIError.validationError
        case 429:
            throw APIError.rateLimited
        case 500...599:
            throw APIError.serverError(statusCode: httpResponse.statusCode)
        default:
            throw APIError.unknown(statusCode: httpResponse.statusCode)
        }
    }
}

// MARK: - HTTP Method

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

// MARK: - API Endpoint

public struct APIEndpoint {
    public let path: String
    public let queryItems: [URLQueryItem]?
    
    public init(path: String, queryItems: [URLQueryItem]? = nil) {
        self.path = path
        self.queryItems = queryItems
    }
    
    // MARK: - Convenience Endpoints
    
    public static func health() -> APIEndpoint {
        APIEndpoint(path: APIEndpoints.health)
    }
    
    public static func validateCitation(_ request: CitationValidationRequest) -> APIEndpoint {
        APIEndpoint(path: APIEndpoints.validateCitation)
    }
    
    public static func validateTicket(citationNumber: String, cityId: String?) -> APIEndpoint {
        var items = [URLQueryItem(name: "citation_number", value: citationNumber)]
        if let cityId = cityId {
            items.append(URLQueryItem(name: "city_id", value: cityId))
        }
        return APIEndpoint(path: APIEndpoints.validateTicket, queryItems: items)
    }
    
    public static func submitAppeal(_ request: AppealSubmitRequest) -> APIEndpoint {
        APIEndpoint(path: APIEndpoints.appealSubmit)
    }
    
    public static func statusLookup(_ request: StatusLookupRequest) -> APIEndpoint {
        APIEndpoint(path: APIEndpoints.statusLookup)
    }
    
    public static func telemetryUpload(_ request: TelemetryUploadRequest) -> APIEndpoint {
        APIEndpoint(path: APIEndpoints.telemetryUpload)
    }
    
    public static func ocrConfig(city: String) -> APIEndpoint {
        let item = URLQueryItem(name: "city", value: city)
        return APIEndpoint(path: APIEndpoints.ocrConfig(city: city), queryItems: [item])
    }
}

// MARK: - Telemetry Upload (Moved from ValidationResult for proper separation)

/// Telemetry upload request
public struct TelemetryUploadRequest: Codable {
    public let records: [TelemetryRecord]
}

/// Individual telemetry record (opt-in)
public struct TelemetryRecord: Codable {
    public let city: String
    public let timestamp: Date
    public let deviceModel: String
    public let iOSVersion: String
    public let originalImageHash: String
    public let croppedImageHash: String
    public let ocrOutput: String
    public let userCorrection: String?
    public let confidence: Double
    public let processingTimeMs: Int
    
    public enum CodingKeys: String, CodingKey {
        case city
        case timestamp
        case deviceModel = "device_model"
        case iOSVersion = "ios_version"
        case originalImageHash = "original_image_hash"
        case croppedImageHash = "cropped_image_hash"
        case ocrOutput = "ocr_output"
        case userCorrection = "user_correction"
        case confidence
        case processingTimeMs = "processing_time_ms"
    }
}

// MARK: - API Error

public enum APIError: LocalizedError {
    case invalidURL(path: String)
    case invalidResponse
    case decodingError(Error)
    case badRequest
    case unauthorized
    case notFound
    case validationError
    case rateLimited
    case serverError(statusCode: Int)
    case unknown(statusCode: Int)
    case networkUnavailable
    
    public var errorDescription: String? {
        switch self {
        case .invalidURL(let path):
            return "Invalid URL: \(path)"
        case .invalidResponse:
            return "Invalid server response"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .badRequest:
            return "Invalid request"
        case .unauthorized:
            return "Authentication required"
        case .notFound:
            return "Resource not found"
        case .validationError:
            return "Validation failed"
        case .rateLimited:
            return "Too many requests. Please try again later."
        case .serverError(let code):
            return "Server error (\(code))"
        case .unknown(let code):
            return "Unexpected error (\(code))"
        case .networkUnavailable:
            return "Network unavailable. Your changes will sync when online."
        }
    }
}
```

## Sources/FightCityFoundation/Networking/APIEndpoints.swift
```
//
//  APIEndpoints.swift
//  FightCityFoundation
//
//  Endpoint definitions for the backend API
//

import Foundation

/// Endpoint definitions matching the FastAPI backend
public enum APIEndpoints {
    // MARK: - Base
    
    public static let base = "/api/v1"
    public static let mobile = "/mobile"
    
    // MARK: - Health
    
    /// Health check endpoint
    public static let health = "/health"
    
    // MARK: - Citations
    
    /// Validate a citation number
    public static let validateCitation = "\(base)/citations/validate"
    
    /// Alternative validation with city mapping
    public static let validateTicket = "/tickets/validate"
    
    /// Get citation details
    public static func citationDetail(id: String) -> String {
        "\(base)/citations/\(id)"
    }
    
    // MARK: - Appeals
    
    /// Submit an appeal
    public static let appealSubmit = "\(base)/appeals"
    
    /// Get appeal status
    public static func appealStatus(appealId: String) -> String {
        "\(base)/appeals/\(appealId)"
    }
    
    /// Update appeal evidence
    public static func updateAppealEvidence(appealId: String) -> String {
        "\(base)/appeals/\(appealId)/evidence"
    }
    
    // MARK: - Status Lookup
    
    /// Look up appeal status by email
    public static let statusLookup = "\(base)/status/lookup"
    
    // MARK: - Mobile (iOS Specific)
    
    /// Upload telemetry data
    public static let telemetryUpload = "\(mobile)/ocr/telemetry"
    
    /// Get OCR configuration for a city
    public static func ocrConfig(city: String) -> String {
        "\(mobile)/ocr/config?city=\(city)"
    }
    
    // MARK: - Auth
    
    /// Login endpoint
    public static let login = "\(base)/auth/login"
    
    /// Register endpoint
    public static let register = "\(base)/auth/register"
    
    /// Refresh token
    public static let refreshToken = "\(base)/auth/refresh"
    
    // MARK: - User
    
    /// Get user profile
    public static let userProfile = "\(base)/users/me"
    
    /// Update user settings
    public static let updateSettings = "\(base)/users/me/settings"
}

// MARK: - Request Builders

extension APIEndpoints {
    /// Build validate citation request body
    public static func buildValidationRequest(
        citationNumber: String,
        cityId: String? = nil,
        licensePlate: String? = nil,
        violationDate: String? = nil
    ) -> CitationValidationRequest {
        CitationValidationRequest(
            citation_number: citationNumber,
            city_id: cityId,
            license_plate: licensePlate,
            violation_date: violationDate
        )
    }
    
    /// Build status lookup request
    public static func buildStatusRequest(email: String, citationNumber: String) -> StatusLookupRequest {
        StatusLookupRequest(email: email, citation_number: citationNumber)
    }
}
```

## Sources/FightCityFoundation/Networking/AuthManager.swift
```
//
//  AuthManager.swift
//  FightCityFoundation
//
//  Secure token storage using Keychain
//

import Foundation
import Security

/// Manages authentication tokens securely using Keychain
public final class AuthManager {
    public static let shared = AuthManager()
    
    private let keychain = KeychainService.shared
    
    private enum Keys {
        static let accessToken = "access_token"
        static let refreshToken = "refresh_token"
        static let tokenExpiry = "token_expiry"
        static let userId = "user_id"
        static let userEmail = "user_email"
    }
    
    private init() {}
    
    // MARK: - Token Management
    
    public func saveTokens(accessToken: String, refreshToken: String?, expiry: Date?) {
        keychain.save(Keys.accessToken, value: accessToken)
        if let refreshToken = refreshToken {
            keychain.save(Keys.refreshToken, value: refreshToken)
        }
        if let expiry = expiry {
            keychain.save(Keys.tokenExpiry, value: String(Int(expiry.timeIntervalSince1970)))
        }
    }
    
    public func getAccessToken() -> String? {
        keychain.load(Keys.accessToken)
    }
    
    public func getRefreshToken() -> String? {
        keychain.load(Keys.refreshToken)
    }
    
    public func getTokenExpiry() -> Date? {
        guard let timestampString = keychain.load(Keys.tokenExpiry),
              let timestamp = Double(timestampString) else {
            return nil
        }
        return Date(timeIntervalSince1970: timestamp)
    }
    
    public func isTokenValid() -> Bool {
        guard let _ = getAccessToken() else { return false }
        if let expiry = getTokenExpiry() {
            return expiry > Date()
        }
        return true // No expiry means valid
    }
    
    public func clearTokens() {
        keychain.delete(Keys.accessToken)
        keychain.delete(Keys.refreshToken)
        keychain.delete(Keys.tokenExpiry)
        keychain.delete(Keys.userId)
        keychain.delete(Keys.userEmail)
    }
    
    // MARK: - User Info
    
    public func saveUserId(_ userId: String) {
        keychain.save(Keys.userId, value: userId)
    }
    
    public func getUserId() -> String? {
        keychain.load(Keys.userId)
    }
    
    public func saveUserEmail(_ email: String) {
        keychain.save(Keys.userEmail, value: email)
    }
    
    public func getUserEmail() -> String? {
        keychain.load(Keys.userEmail)
    }
}

// MARK: - Keychain Service

/// Low-level Keychain wrapper
public final class KeychainService {
    public static let shared = KeychainService()
    
    private let serviceName = "com.fightcitytickets.app"
    
    private init() {}
    
    public func save(_ key: String, value: String) {
        guard let data = value.data(using: .utf8) else { return }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        
        // Delete existing item first
        SecItemDelete(query as CFDictionary)
        
        // Add new item
        let status = SecItemAdd(query as CFDictionary, nil)
        if status != errSecSuccess {
            print("Keychain save error: \(status)")
        }
    }
    
    public func load(_ key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let value = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return value
    }
    
    public func delete(_ key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key
        ]
        
        SecItemDelete(query as CFDictionary)
    }
    
    public func deleteAll() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName
        ]
        
        SecItemDelete(query as CFDictionary)
    }
}
```

## Sources/FightCityFoundation/Networking/OCRParsingEngine.swift
```
//
//  OCRParsingEngine.swift
//  FightCityFoundation
//
//  Regex patterns per city for citation parsing (matching backend CitationValidator)
//

import Foundation

/// Parses OCR text using city-specific regex patterns (matching backend CitationValidator)
public struct OCRParsingEngine {
    // MARK: - City Patterns (from Python backend)
    
    public struct CityPattern {
        public let cityId: String
        public let cityName: String
        public let regex: String
        public let priority: Int
        public let formatExample: String
        
        public init(cityId: String, cityName: String, regex: String, priority: Int, formatExample: String) {
            self.cityId = cityId
            self.cityName = cityName
            self.regex = regex
            self.priority = priority
            self.formatExample = formatExample
        }
    }
    
    /// Patterns in priority order (matching backend CitationValidator)
    private let patterns: [CityPattern] = [
        // San Francisco - SFMTA or MT followed by 8 digits
        CityPattern(
            cityId: "us-ca-san_francisco",
            cityName: "San Francisco",
            regex: "^(SFMTA|MT)[0-9]{8}$",
            priority: 1,
            formatExample: "SFMTA91234567"
        ),
        // NYC - exactly 10 digits
        CityPattern(
            cityId: "us-ny-new_york",
            cityName: "New York",
            regex: "^[0-9]{10}$",
            priority: 2,
            formatExample: "1234567890"
        ),
        // Denver - 5-9 digits
        CityPattern(
            cityId: "us-co-denver",
            cityName: "Denver",
            regex: "^[0-9]{5,9}$",
            priority: 3,
            formatExample: "1234567"
        ),
        // Los Angeles - 6-11 alphanumeric characters
        CityPattern(
            cityId: "us-ca-los_angeles",
            cityName: "Los Angeles",
            regex: "^[0-9A-Z]{6,11}$",
            priority: 4,
            formatExample: "LA123456"
        )
    ]
    
    // MARK: - Parsing Result
    
    public struct ParsingResult {
        public let citationNumber: String?
        public let cityId: String?
        public let cityName: String?
        public let confidence: Double
        public let matchedPattern: CityPattern?
        public let rawMatches: [String]
        
        public init(
            citationNumber: String?,
            cityId: String?,
            cityName: String?,
            confidence: Double,
            matchedPattern: CityPattern?,
            rawMatches: [String]
        ) {
            self.citationNumber = citationNumber
            self.cityId = cityId
            self.cityName = cityName
            self.confidence = confidence
            self.matchedPattern = matchedPattern
            self.rawMatches = rawMatches
        }
    }
    
    public init() {}
    
    // MARK: - Parsing
    
    /// Parse OCR text for citation numbers
    public func parse(_ text: String) -> ParsingResult {
        let normalizedText = normalizeText(text)
        let allMatches = findAllMatches(in: normalizedText)
        
        // Return best match
        if let bestMatch = allMatches.first {
            return ParsingResult(
                citationNumber: bestMatch.matchedString,
                cityId: bestMatch.pattern.cityId,
                cityName: bestMatch.pattern.cityName,
                confidence: bestMatch.confidence,
                matchedPattern: bestMatch.pattern,
                rawMatches: allMatches.map { $0.matchedString }
            )
        }
        
        return ParsingResult(
            citationNumber: nil,
            cityId: nil,
            cityName: nil,
            confidence: 0,
            matchedPattern: nil,
            rawMatches: []
        )
    }
    
    /// Find citation number with city hint
    public func parseWithCityHint(_ text: String, cityId: String) -> ParsingResult {
        let normalizedText = normalizeText(text)
        
        // Try city-specific pattern first
        if let cityPattern = patterns.first(where: { $0.cityId == cityId }) {
            if let match = findFirstMatch(in: normalizedText, pattern: cityPattern) {
                return ParsingResult(
                    citationNumber: match.matchedString,
                    cityId: cityPattern.cityId,
                    cityName: cityPattern.cityName,
                    confidence: match.confidence,
                    matchedPattern: cityPattern,
                    rawMatches: [match.matchedString]
                )
            }
        }
        
        // Fall back to general parsing
        return parse(normalizedText)
    }
    
    // MARK: - Private Methods
    
    private func normalizeText(_ text: String) -> String {
        // Remove common OCR artifacts
        var result = text.uppercased()
        
        // Remove common separators that might be misread
        result = result.replacingOccurrences(of: " ", with: "")
        result = result.replacingOccurrences(of: "|", with: "I")
        result = result.replacingOccurrences(of: "l", with: "I")
        // Note: Do NOT replace "0" with "O" as this corrupts numeric citation numbers
        // Only replace ambiguous characters that are clearly misread letters
        
        // Remove non-alphanumeric characters except common separators
        let allowed = CharacterSet.alphanumerics
        result = String(result.unicodeScalars.filter { allowed.contains($0) })
        
        return result
    }
    
    private func findAllMatches(in text: String) -> [MatchResult] {
        var results: [MatchResult] = []
        
        for pattern in patterns.sorted(by: { $0.priority < $1.priority }) {
            if let matches = findMatches(in: text, pattern: pattern) {
                results.append(contentsOf: matches)
            }
        }
        
        // Sort by confidence and return
        return results.sorted { $0.confidence > $1.confidence }
    }
    
    private func findFirstMatch(in text: String, pattern: CityPattern) -> MatchResult? {
        findMatches(in: text, pattern: pattern)?.first
    }
    
    private func findMatches(in text: String, pattern: CityPattern) -> [MatchResult]? {
        guard let regex = try? NSRegularExpression(pattern: pattern.regex, options: []) else {
            return nil
        }
        
        let range = NSRange(text.startIndex..., in: text)
        let matches = regex.matches(in: text, options: [], range: range)
        
        guard !matches.isEmpty else { return nil }
        
        return matches.compactMap { match in
            guard let range = Range(match.range, in: text) else { return nil }
            let matchedString = String(text[range])
            return MatchResult(
                matchedString: matchedString,
                pattern: pattern,
                confidence: calculateMatchConfidence(matchedString, pattern: pattern)
            )
        }
    }
    
    private func calculateMatchConfidence(_ matchedString: String, pattern: CityPattern) -> Double {
        // Base confidence based on pattern match
        var confidence = 0.9
        
        // Adjust based on string length
        let idealLength = 9 // Approximate citation length
        let lengthDiff = abs(matchedString.count - idealLength)
        confidence -= Double(lengthDiff) * 0.05
        
        // Adjust based on character types
        let hasLetters = matchedString.contains(where: { $0.isLetter })
        let hasDigits = matchedString.contains(where: { $0.isNumber })
        
        // SF patterns have letters + digits, so give higher confidence
        if pattern.cityId == "us-ca-san_francisco" && hasLetters && hasDigits {
            confidence += 0.05
        }
        
        return min(1.0, max(0.5, confidence))
    }
    
    // MARK: - Match Result
    
    public struct MatchResult {
        public let matchedString: String
        public let pattern: CityPattern
        public let confidence: Double
    }
}

// MARK: - Date Extraction

extension OCRParsingEngine {
    /// Extract possible dates from OCR text
    public func extractDates(from text: String) -> [ExtractedDate] {
        let datePatterns = [
            // MM/DD/YYYY
            "\\d{1,2}/\\d{1,2}/\\d{4}",
            // MM-DD-YYYY
            "\\d{1,2}-\\d{1,2}-\\d{4}",
            // YYYY-MM-DD
            "\\d{4}-\\d{2}-\\d{2}",
            // Month DD, YYYY
            "[A-Za-z]+ \\d{1,2},? \\d{4}"
        ]
        
        var dates: [ExtractedDate] = []
        
        for pattern in datePatterns {
            guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { continue }
            
            let range = NSRange(text.startIndex..., in: text)
            let matches = regex.matches(in: text, options: [], range: range)
            
            for match in matches {
                if let matchRange = Range(match.range, in: text) {
                    let dateString = String(text[matchRange])
                    if let parsedDate = parseDateString(dateString) {
                        dates.append(ExtractedDate(
                            rawValue: dateString,
                            parsedDate: parsedDate,
                            position: match.range.location
                        ))
                    }
                }
            }
        }
        
        return dates
    }
    
    private func parseDateString(_ string: String) -> Date? {
        let formatters: [DateFormatter] = [
            createFormatter("MM/dd/yyyy"),
            createFormatter("MM-dd-yyyy"),
            createFormatter("yyyy-MM-dd"),
            createFormatter("MMMM d, yyyy"),
            createFormatter("MMM d, yyyy")
        ]
        
        for formatter in formatters {
            if let date = formatter.date(from: string) {
                return date
            }
        }
        
        return nil
    }
    
    private func createFormatter(_ format: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }
    
    public struct ExtractedDate {
        public let rawValue: String
        public let parsedDate: Date
        public let position: Int
    }
}

// MARK: - Formatting

extension OCRParsingEngine {
    /// Format citation number according to city conventions
    public func formatCitation(_ citationNumber: String, cityId: String) -> String {
        switch cityId {
        case "us-ca-san_francisco":
            // SFMTA format: 912-345-678 (9-digit with dashes)
            if citationNumber.count == 9 && citationNumber.allSatisfy({ $0.isNumber }) {
                return "\(citationNumber.prefix(3))-\(citationNumber.dropFirst(3).prefix(3))-\(citationNumber.suffix(3))"
            }
            return citationNumber
            
        case "us-ny-new_york":
            // NYC: 1234567890 (10 digits, no dashes)
            return citationNumber
            
        case "us-ca-los_angeles":
            // LA: LA123456 or 123456 (no dashes)
            return citationNumber
            
        default:
            return citationNumber
        }
    }
}
```

## Sources/FightCityFoundation/Networking/OfflineManager.swift
```
//
//  OfflineManager.swift
//  FightCityFoundation
//
//  Offline queue with exponential backoff
//

import Foundation

/// Protocol for network connectivity checking (platform-agnostic)
public protocol NetworkConnectivityChecker {
    var isConnected: Bool { get }
}

/// Default connectivity checker (always assumes connected - can be overridden)
public struct DefaultConnectivityChecker: NetworkConnectivityChecker {
    public var isConnected: Bool { true }
}

/// Manages offline operations with persistent queue and exponential backoff
public final class OfflineManager {
    public static let shared = OfflineManager()
    
    private let queue: PersistentQueue<OfflineOperation>
    private var connectivityChecker: NetworkConnectivityChecker
    private var retryTimer: Timer?
    
    /// Configuration for offline manager
    public struct Configuration {
        public var maxRetryAttempts: Int
        public var retryBackoffMultiplier: Double
        public var retryMaxBackoff: TimeInterval
        public var offlineQueueMaxSize: Int
        
        public init(
            maxRetryAttempts: Int = 3,
            retryBackoffMultiplier: Double = 2.0,
            retryMaxBackoff: TimeInterval = 300.0,
            offlineQueueMaxSize: Int = 100
        ) {
            self.maxRetryAttempts = maxRetryAttempts
            self.retryBackoffMultiplier = retryBackoffMultiplier
            self.retryMaxBackoff = retryMaxBackoff
            self.offlineQueueMaxSize = offlineQueueMaxSize
        }
    }
    
    private let config: Configuration
    
    public init(
        connectivityChecker: NetworkConnectivityChecker = DefaultConnectivityChecker(),
        configuration: Configuration = Configuration()
    ) {
        self.connectivityChecker = connectivityChecker
        self.config = configuration
        self.queue = PersistentQueue(name: "offline_operations", maxSize: configuration.offlineQueueMaxSize)
        startRetryTimer()
    }
    
    // MARK: - Operation Management
    
    /// Add an operation to the offline queue
    public func enqueue(_ operation: OfflineOperation) {
        queue.enqueue(operation)
        attemptSync()
    }
    
    /// Remove an operation from the queue
    public func remove(id: UUID) {
        queue.remove(id: id)
    }
    
    /// Clear all queued operations
    public func clearQueue() {
        queue.clear()
    }
    
    /// Get all pending operations
    public func pendingOperations() -> [OfflineOperation] {
        queue.all()
    }
    
    /// Get count of pending operations
    public var pendingCount: Int {
        queue.count
    }
    
    /// Check if queue has pending operations
    public var hasPendingOperations: Bool {
        !queue.isEmpty
    }
    
    // MARK: - Sync Management
    
    /// Attempt to sync pending operations
    public func attemptSync() {
        guard connectivityChecker.isConnected else { return }
        guard !queue.isEmpty else { return }
        
        syncPendingOperations()
    }
    
    /// Sync all pending operations
    private func syncPendingOperations() {
        guard connectivityChecker.isConnected else { return }
        
        Task {
            var failedOperations: [OfflineOperation] = []
            
            for operation in queue.all() {
                do {
                    try await performOperation(operation)
                    queue.remove(id: operation.id)
                } catch {
                    // Calculate backoff for this operation
                    let backoff = calculateBackoff(attempt: operation.attemptCount)
                    var updatedOperation = operation
                    updatedOperation.attemptCount += 1
                    updatedOperation.nextRetry = Date().addingTimeInterval(backoff)
                    
                    if updatedOperation.attemptCount >= config.maxRetryAttempts {
                        // Max retries reached, move to failed
                        updatedOperation.status = .failed
                        failedOperations.append(updatedOperation)
                    } else {
                        // Update retry time and requeue
                        updatedOperation.status = .retrying
                        queue.update(updatedOperation)
                    }
                }
            }
            
            // Handle permanently failed operations
            for op in failedOperations {
                queue.remove(id: op.id)
                NotificationCenter.default.post(
                    name: .operationFailed,
                    object: nil,
                    userInfo: ["operation": op]
                )
            }
        }
    }
    
    /// Perform a single operation (throws on failure)
    private func performOperation(_ operation: OfflineOperation) async throws {
        switch operation.type {
        case .validateCitation(let request):
            try Task.checkCancellation()
            let _: CitationValidationResponse = try await APIClient.shared.post(.validateCitation(request), body: request)
            
        case .submitAppeal(let request):
            try Task.checkCancellation()
            let _: String = try await APIClient.shared.post(.submitAppeal(request), body: request)
            
        case .telemetryUpload(let request):
            try Task.checkCancellation()
            let _: String = try await APIClient.shared.post(.telemetryUpload(request), body: request)
        }
    }
    
    /// Calculate exponential backoff
    private func calculateBackoff(attempt: Int) -> TimeInterval {
        let baseDelay = config.retryBackoffMultiplier
        let maxDelay = config.retryMaxBackoff
        let delay = pow(baseDelay, Double(attempt))
        return min(delay, maxDelay)
    }
    
    // MARK: - Retry Timer
    
    private func startRetryTimer() {
        retryTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.attemptSync()
        }
    }
    
    /// Stop the retry timer and clean up
    public func stopRetryTimer() {
        retryTimer?.invalidate()
        retryTimer = nil
    }
    
    deinit {
        retryTimer?.invalidate()
    }
}

// MARK: - Persistent Queue

/// Thread-safe persistent queue for offline operations
public struct PersistentQueue<T: Codable & Identifiable> {
    private var items: [T] = []
    private let queue = DispatchQueue(label: "com.fightcitytickets.offlinequeue", attributes: .concurrent)
    private let persistence: FilePersistence<T>
    private let maxSize: Int
    
    public init(name: String, maxSize: Int = 100) {
        self.persistence = FilePersistence(name: name)
        self.maxSize = maxSize
        self.items = persistence.load() ?? []
    }
    
    public mutating func enqueue(_ item: T) {
        queue.async(flags: .barrier) {
            if self.items.count >= self.maxSize {
                self.items.removeFirst()
            }
            self.items.append(item)
            self.persistence.save(self.items)
        }
    }
    
    public mutating func dequeue() -> T? {
        queue.sync {
            guard !items.isEmpty else { return nil }
            let item = items.removeFirst()
            persistence.save(items)
            return item
        }
    }
    
    public mutating func remove(id: UUID) {
        queue.async(flags: .barrier) {
            self.items.removeAll { $0.id == id }
            self.persistence.save(self.items)
        }
    }
    
    public mutating func update(_ item: T) {
        queue.async(flags: .barrier) {
            if let index = self.items.firstIndex(where: { $0.id == item.id }) {
                self.items[index] = item
                self.persistence.save(self.items)
            }
        }
    }
    
    public mutating func clear() {
        queue.async(flags: .barrier) {
            self.items.removeAll()
            self.persistence.save(self.items)
        }
    }
    
    public func all() -> [T] {
        queue.sync { items }
    }
    
    public var count: Int {
        queue.sync { items.count }
    }
    
    public var isEmpty: Bool {
        queue.sync { items.isEmpty }
    }
}

// MARK: - Offline Operation

/// Operation that can be queued for offline execution
public struct OfflineOperation: Codable, Identifiable {
    public let id: UUID
    public let type: OperationType
    public var attemptCount: Int
    public var nextRetry: Date?
    public var status: OperationStatus
    
    public enum OperationType: Codable {
        case validateCitation(CitationValidationRequest)
        case submitAppeal(AppealSubmitRequest)
        case telemetryUpload(TelemetryUploadRequest)
    }
    
    public enum OperationStatus: String, Codable {
        case pending
        case retrying
        case failed
    }
    
    public init(type: OperationType) {
        self.id = UUID()
        self.type = type
        self.attemptCount = 0
        self.nextRetry = nil
        self.status = .pending
    }
}

// MARK: - File Persistence

/// Simple file-based persistence for Codable types
public struct FilePersistence<T: Codable> {
    private let fileURL: URL
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    public init(name: String) {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.fileURL = documentsPath.appendingPathComponent("\(name).json")
    }
    
    public func save(_ items: [T]) {
        do {
            let data = try encoder.encode(items)
            try data.write(to: fileURL)
        } catch {
            print("Persistence save error: \(error)")
        }
    }
    
    public func load() -> [T]? {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return nil }
        do {
            let data = try Data(contentsOf: fileURL)
            return try decoder.decode([T].self, from: data)
        } catch {
            print("Persistence load error: \(error)")
            return nil
        }
    }
}

// MARK: - Notifications

public extension Notification.Name {
    static let operationFailed = Notification.Name("operationFailed")
}
```

## Sources/FightCityFoundation/Offline/OfflineQueueManager.swift
```
//
//  OfflineQueueManager.swift
//  FightCityFoundation
//
//  Offline queue with retry logic and persistence
//

import Foundation

/// Offline queue item for pending operations
public struct QueueItem: Identifiable, Codable {
    public let id: UUID
    public let operation: QueuedOperation
    public let createdAt: Date
    public var retryCount: Int
    public var nextRetryAt: Date?
    
    public init(id: UUID = UUID(), operation: QueuedOperation, createdAt: Date = Date(), retryCount: Int = 0, nextRetryAt: Date? = nil) {
        self.id = id
        self.operation = operation
        self.createdAt = createdAt
        self.retryCount = retryCount
        self.nextRetryAt = nextRetryAt
    }
}

/// Types of queued operations
public enum QueuedOperation: Codable {
    case validateCitation(request: CitationValidationRequest)
    case submitAppeal(request: AppealSubmitRequest)
    case uploadTelemetry(records: [TelemetryRecord])
    
    private enum CodingKeys: String, CodingKey {
        case type
        case request
        case records
    }
    
    private enum OperationType: String, Codable {
        case validateCitation
        case submitAppeal
        case uploadTelemetry
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(OperationType.self, forKey: .type)
        
        switch type {
        case .validateCitation:
            let request = try container.decode(CitationValidationRequest.self, forKey: .request)
            self = .validateCitation(request: request)
        case .submitAppeal:
            let request = try container.decode(AppealSubmitRequest.self, forKey: .request)
            self = .submitAppeal(request: request)
        case .uploadTelemetry:
            let records = try container.decode([TelemetryRecord].self, forKey: .records)
            self = .uploadTelemetry(records: records)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .validateCitation(let request):
            try container.encode(OperationType.validateCitation, forKey: .type)
            try container.encode(request, forKey: .request)
        case .submitAppeal(let request):
            try container.encode(OperationType.submitAppeal, forKey: .type)
            try container.encode(request, forKey: .request)
        case .uploadTelemetry(let records):
            try container.encode(OperationType.uploadTelemetry, forKey: .type)
            try container.encode(records, forKey: .records)
        }
    }
}

/// Manager for offline queue operations
public actor OfflineQueueManager {
    public static let shared = OfflineQueueManager()
    
    private let storageKey = "offline_queue"
    private let maxQueueSize = 100
    private let maxRetryAttempts = 3
    private let initialDelay: TimeInterval = 1.0
    private let maxDelay: TimeInterval = 300.0 // 5 minutes
    private let multiplier: TimeInterval = 2.0
    
    private var queue: [QueueItem] = []
    private let storage: Storage
    private let apiClient: APIClientProtocol
    private let logger: LoggerProtocol
    
    public init(storage: Storage = UserDefaultsStorage(), apiClient: APIClientProtocol = APIClient.shared, logger: LoggerProtocol = Logger.shared) {
        self.storage = storage
        self.apiClient = apiClient
        self.logger = logger
        loadQueue()
    }
    
    // MARK: - Public Methods
    
    /// Add operation to queue
    public func enqueue(_ operation: QueuedOperation) async throws {
        guard queue.count < maxQueueSize else {
            logger.warning("Offline queue is full, dropping oldest item")
            queue.removeFirst()
        }
        
        let item = QueueItem(operation: operation)
        queue.append(item)
        await persistQueue()
        
        logger.info("Added operation to offline queue, current size: \(queue.count)")
        
        // Try to process immediately if online
        await tryProcessQueue()
    }
    
    /// Process all pending items
    public func processQueue() async {
        await tryProcessQueue()
    }
    
    /// Get current queue count
    public var count: Int {
        queue.count
    }
    
    /// Clear all items
    public func clear() {
        queue.removeAll()
        persistQueue()
    }
    
    // MARK: - Private Methods
    
    private func tryProcessQueue() async {
        guard !queue.isEmpty else { return }
        
        // Filter out items that need to wait
        let now = Date()
        let readyItems = queue.filter { item in
            guard let nextRetry = item.nextRetryAt else { return true }
            return nextRetry <= now
        }
        
        for item in readyItems {
            do {
                try await processItem(item)
                queue.removeAll { $0.id == item.id }
                await persistQueue()
                logger.info("Successfully processed queue item: \(item.id)")
            } catch {
                await handleRetry(for: item, error: error)
            }
        }
    }
    
    private func processItem(_ item: QueueItem) async throws {
        switch item.operation {
        case .validateCitation(let request):
            _ = try await apiClient.validateCitation(request)
        case .submitAppeal(let request):
            // Would call submit appeal endpoint
            break
        case .uploadTelemetry(let records):
            // Would upload telemetry
            break
        }
    }
    
    private func handleRetry(for item: QueueItem, error: Error) async {
        if item.retryCount >= maxRetryAttempts {
            logger.error("Max retries exceeded for item \(item.id), dropping")
            queue.removeAll { $0.id == item.id }
        } else {
            let delay = calculateDelay(retryCount: item.retryCount)
            let nextRetry = Date().addingTimeInterval(delay)
            
            if let index = queue.firstIndex(where: { $0.id == item.id }) {
                queue[index].retryCount += 1
                queue[index].nextRetryAt = nextRetry
                logger.warning("Retry scheduled for item \(item.id) in \(delay)s, attempt \(queue[index].retryCount)")
            }
        }
        
        await persistQueue()
    }
    
    private func calculateDelay(retryCount: Int) -> TimeInterval {
        let delay = initialDelay * pow(multiplier, Double(retryCount))
        return min(delay, maxDelay)
    }
    
    private func loadQueue() {
        if let data = storage.load(key: storageKey),
           let decoded = try? JSONDecoder().decode([QueueItem].self, from: data) {
            queue = decoded
            logger.info("Loaded \(queue.count) items from offline queue")
        }
    }
    
    private func persistQueue() async {
        if let encoded = try? JSONEncoder().encode(queue) {
            _ = storage.save(key: storageKey, data: encoded)
        }
    }
}

// MARK: - Simple Storage Protocol

public protocol Storage {
    func save(key: String, data: Data) -> Bool
    func load(key: String) -> Data?
    func delete(key: String) -> Bool
}

// MARK: - UserDefaults Storage Implementation

public final class UserDefaultsStorage: Storage {
    private let defaults: UserDefaults
    
    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }
    
    public func save(key: String, data: Data) -> Bool {
        defaults.set(data, forKey: key)
        return true
    }
    
    public func load(key: String) -> Data? {
        defaults.data(forKey: key)
    }
    
    public func delete(key: String) -> Bool {
        defaults.removeObject(forKey: key)
        return true
    }
}

// MARK: - In-Memory Storage (for testing)

public final class InMemoryStorage: Storage {
    private var storage: [String: Data] = [:]
    
    public init() {}
    
    public func save(key: String, data: Data) -> Bool {
        storage[key] = data
        return true
    }
    
    public func load(key: String) -> Data? {
        storage[key]
    }
    
    public func delete(key: String) -> Bool {
        storage.removeValue(forKey: key)
        return true
    }
}
```

## Sources/FightCityFoundation/Protocols/ServiceProtocols.swift
```
//
//  ServiceProtocols.swift
//  FightCityFoundation
//
//  Protocol definitions for dependency injection and testability
//

import Foundation

// MARK: - Camera Protocol

/// Protocol for camera operations - enables mock testing
public protocol CameraManagerProtocol {
    var isAuthorized: Bool { get }
    var isSessionRunning: Bool { get }
    
    func requestAuthorization() async -> Bool
    func setupSession() async throws
    func startSession() async
    func stopSession() async
    func capturePhoto() async throws -> Data?
    func switchCamera() async
    func setZoom(_ factor: Float) async
    func toggleTorch() async
}

// MARK: - OCR Protocol

/// Protocol for OCR operations - enables mock testing
public protocol OCREngineProtocol {
    func recognizeText(in image: Data, configuration: OCRConfiguration) async throws -> OCRRecognitionResult
    func recognizeWithHighAccuracy(in image: Data) async throws -> OCRRecognitionResult
    func recognizeFast(in image: Data) async throws -> OCRRecognitionResult
}

/// OCR configuration
public struct OCRConfiguration {
    public var recognitionLevel: RecognitionLevel
    public var usesLanguageCorrection: Bool
    public var recognitionLanguages: [String]
    public var autoDetectLanguage: Bool
    
    public init(
        recognitionLevel: RecognitionLevel = .accurate,
        usesLanguageCorrection: Bool = true,
        recognitionLanguages: [String] = ["en-US"],
        autoDetectLanguage: Bool = false
    ) {
        self.recognitionLevel = recognitionLevel
        self.usesLanguageCorrection = usesLanguageCorrection
        self.recognitionLanguages = recognitionLanguages
        self.autoDetectLanguage = autoDetectLanguage
    }
}

public enum RecognitionLevel: String {
    case fast = "fast"
    case accurate = "accurate"
}

/// OCR result from engine
public struct OCRRecognitionResult {
    public let text: String
    public let confidence: Double
    public let processingTime: TimeInterval
    public let observations: [OCRObservation]
    
    public init(text: String, confidence: Double, processingTime: TimeInterval, observations: [OCRObservation]) {
        self.text = text
        self.confidence = confidence
        self.processingTime = processingTime
        self.observations = observations
    }
}

public struct OCRObservation {
    public let text: String
    public let confidence: Double
    public let boundingBox: CGRect
    
    public init(text: String, confidence: Double, boundingBox: CGRect) {
        self.text = text
        self.confidence = confidence
        self.boundingBox = boundingBox
    }
}

// MARK: - Image Preprocessing Protocol

/// Protocol for image preprocessing
public protocol ImagePreprocessorProtocol {
    func preprocess(_ imageData: Data) async throws -> Data
}

// MARK: - API Client Protocol

/// Protocol for API client - enables mock testing
public protocol APIClientProtocol {
    func get<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T
    func post<T: Decodable, B: Encodable>(_ endpoint: APIEndpoint, body: B) async throws -> T
    func postVoid<B: Encodable>(_ endpoint: APIEndpoint, body: B) async throws
    func validateCitation(_ request: CitationValidationRequest) async throws -> CitationValidationResponse
}

// MARK: - Confidence Scoring Protocol

/// Protocol for confidence scoring
public protocol ConfidenceScorerProtocol {
    func score(rawText: String, observations: [OCRObservation], matchedPattern: CityPattern?) -> ConfidenceResult
}

/// Confidence result
public struct ConfidenceResult {
    public let overallConfidence: Double
    public let level: ConfidenceLevel
    public let components: [ConfidenceComponent]
    public let recommendation: Recommendation
    
    public init(
        overallConfidence: Double,
        level: ConfidenceLevel,
        components: [ConfidenceComponent],
        recommendation: Recommendation
    ) {
        self.overallConfidence = overallConfidence
        self.level = level
        self.components = components
        self.recommendation = recommendation
    }
}

public enum ConfidenceLevel: String {
    case high
    case medium
    case low
}

public enum Recommendation: String {
    case accept
    case review
    case reject
}

public struct ConfidenceComponent {
    public let name: String
    public let score: Double
    public let weight: Double
    public let weightedScore: Double
    
    public init(name: String, score: Double, weight: Double, weightedScore: Double) {
        self.name = name
        self.score = score
        self.weight = weight
        self.weightedScore = weightedScore
    }
}

// MARK: - Pattern Matching Protocol

/// Protocol for citation pattern matching
public protocol PatternMatcherProtocol {
    func match(_ text: String) -> PatternMatchResult
}

/// Result of pattern matching
public struct PatternMatchResult {
    public let cityId: String?
    public let pattern: CityPattern?
    public let priority: Int
    
    public init(cityId: String?, pattern: CityPattern?, priority: Int) {
        self.cityId = cityId
        self.pattern = pattern
        self.priority = priority
    }
    
    public var isMatch: Bool { pattern != nil }
}

/// City pattern configuration
public struct CityPattern: Codable {
    public let cityId: String
    public let cityName: String
    public let pattern: String
    public let priority: Int
    public let deadlineDays: Int
    public let canAppealOnline: Bool
    public let phoneConfirmationRequired: Bool
    
    public init(
        cityId: String,
        cityName: String,
        pattern: String,
        priority: Int,
        deadlineDays: Int,
        canAppealOnline: Bool,
        phoneConfirmationRequired: Bool
    ) {
        self.cityId = cityId
        self.cityName = cityName
        self.pattern = pattern
        self.priority = priority
        self.deadlineDays = deadlineDays
        self.canAppealOnline = canAppealOnline
        self.phoneConfirmationRequired = phoneConfirmationRequired
    }
}

// MARK: - Frame Quality Protocol

/// Protocol for frame quality analysis
public protocol FrameQualityAnalyzerProtocol {
    func analyze(_ imageData: Data) -> QualityAnalysisResult
}

/// Result of quality analysis
public struct QualityAnalysisResult {
    public let isAcceptable: Bool
    public let feedbackMessage: String?
    public let warnings: [QualityWarning]
    
    public init(isAcceptable: Bool, feedbackMessage: String?, warnings: [QualityWarning]) {
        self.isAcceptable = isAcceptable
        self.feedbackMessage = feedbackMessage
        self.warnings = warnings
    }
}

public enum QualityWarning: String {
    case blurry
    case tooDark
    case tooBright
    case skewed
    case tooFar
    case tooClose
}
```

## Sources/FightCityiOS/Camera/CameraManager.swift
```
//
//  CameraManager.swift
//  FightCityiOS
//
//  AVFoundation camera control with exposure, focus, torch, and stabilization
//

import AVFoundation
import UIKit

/// Manages camera capture with full control over exposure, focus, torch, and stabilization
actor CameraManager: NSObject {
    // MARK: - Published State
    
    private(set) var isAuthorized = false
    private(set) var isSessionRunning = false
    private(set) var currentCameraPosition: AVCaptureDevice.Position = .back
    
    // MARK: - Capture Session
    
    private let captureSession = AVCaptureSession()
    private var photoOutput: AVCapturePhotoOutput?
    private var videoOutput: AVCaptureVideoDataOutput?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    // MARK: - Device Configuration
    
    private var currentDevice: AVCaptureDevice? {
        AVCaptureDevice.default(
            .builtInWideAngleCamera,
            for: .video,
            position: currentCameraPosition
        )
    }
    
    private var torchLevel: Float = 0.0
    
    // MARK: - Configuration
    
    private let config: iOSAppConfig
    
    init(config: iOSAppConfig = .shared) {
        self.config = config
        super.init()
    }
    
    // MARK: - Authorization
    
    func requestAuthorization() async -> Bool {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch status {
        case .authorized:
            isAuthorized = true
            return true
        case .notDetermined:
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            isAuthorized = granted
            return granted
        default:
            isAuthorized = false
            return false
        }
    }
    
    // MARK: - Session Setup
    
    func setupSession() throws {
        guard isAuthorized else {
            throw CameraError.notAuthorized
        }
        
        captureSession.beginConfiguration()
        captureSession.sessionPreset = .photo
        
        // Add video input
        guard let device = currentDevice,
              let videoInput = try? AVCaptureDeviceInput(device: device) else {
            throw CameraError.deviceUnavailable
        }
        
        if captureSession.inputs.isEmpty {
            captureSession.addInput(videoInput)
        }
        
        // Add photo output
        let photoOutput = AVCapturePhotoOutput()
        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
            self.photoOutput = photoOutput
        }
        
        // Add video output for frame analysis
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "com.fightcitytickets.video"))
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
            self.videoOutput = videoOutput
        }
        
        // Configure for high quality
        if let connection = photoOutput?.connection(with: .video) {
            connection.videoStabilizationEnabled = true
        }
        
        captureSession.commitConfiguration()
    }
    
    func startSession() {
        guard !captureSession.isRunning else { return }
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.startRunning()
            Task { [weak self] in
                await self?.updateSessionState()
            }
        }
    }
    
    func stopSession() {
        guard captureSession.isRunning else { return }
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.stopRunning()
            Task { [weak self] in
                await self?.updateSessionState()
            }
        }
    }
    
    private func updateSessionState() {
        isSessionRunning = captureSession.isRunning
    }
    
    // MARK: - Camera Controls
    
    func switchCamera() throws {
        guard isSessionRunning else { return }
        
        captureSession.beginConfiguration()
        
        // Remove current input
        if let currentInput = captureSession.inputs.compactMap({ $0 as? AVCaptureDeviceInput }).first {
            captureSession.removeInput(currentInput)
        }
        
        // Toggle camera position
        currentCameraPosition = currentCameraPosition == .back ? .front : .back
        
        // Add new input
        guard let newDevice = currentDevice,
              let newInput = try? AVCaptureDeviceInput(device: newDevice) else {
            captureSession.cancelConfiguration()
            throw CameraError.deviceUnavailable
        }
        
        captureSession.addInput(newInput)
        captureSession.commitConfiguration()
    }
    
    // MARK: - Focus & Exposure
    
    func focus(at point: CGPoint) async throws {
        guard let device = currentDevice,
              device.isFocusModeSupported(.continuousAutoFocus) else {
            return
        }
        
        try device.lockForConfiguration()
        device.focusPointOfInterest = point
        device.focusMode = .continuousAutoFocus
        device.unlockForConfiguration()
    }
    
    func lockExposure(at point: CGPoint) async throws {
        guard let device = currentDevice,
              device.isExposureModeSupported(.continuousAutoExposure) else {
            return
        }
        
        try device.lockForConfiguration()
        device.exposurePointOfInterest = point
        device.exposureMode = .continuousAutoExposure
        device.unlockForConfiguration()
    }
    
    // MARK: - Torch Control
    
    func setTorch(level: Float) async throws {
        guard let device = currentDevice,
              device.hasTorch else {
            throw CameraError.torchUnavailable
        }
        
        let clampedLevel = max(0, min(level, 1))
        
        try device.lockForConfiguration()
        device.torchMode = clampedLevel > 0 ? .on : .off
        if clampedLevel > 0 {
            try device.setTorchModeOn(level: clampedLevel)
        }
        torchLevel = clampedLevel
        device.unlockForConfiguration()
    }
    
    func toggleTorch() async throws {
        let newLevel: Float = torchLevel > 0 ? 0 : 1
        try await setTorch(level: newLevel)
    }
    
    // MARK: - Zoom
    
    func setZoom(_ zoomFactor: CGFloat) async throws {
        guard let device = currentDevice else { return }
        
        let maxZoom = device.activeFormat.videoMaxZoomFactor
        let clampedZoom = max(1, min(zoomFactor, maxZoom))
        
        try device.lockForConfiguration()
        device.videoZoomFactor = clampedZoom
        device.unlockForConfiguration()
    }
    
    // MARK: - Capture
    
    func capturePhoto() async throws -> Data? {
        guard let photoOutput = photoOutput else {
            throw CameraError.outputUnavailable
        }
        
        let settings = AVCapturePhotoSettings()
        settings.flashMode = torchLevel > 0 ? .on : .off
        
        return try await withCheckedThrowingContinuation { continuation in
            let delegate = PhotoCaptureDelegate { result in
                continuation.resume(with: result)
            }
            photoOutput.capturePhoto(with: settings, delegate: delegate)
        }
    }
    
    // MARK: - Image Processing
    
    func processImage(_ imageData: Data) async throws -> (UIImage, CIImage) {
        guard let image = UIImage(data: imageData) else {
            throw CameraError.invalidImage
        }
        
        let ciImage = CIImage(image: image)
        return (image, ciImage)
    }
    
    // MARK: - Helper Methods
    
    func convertToCIImage(_ uiImage: UIImage) -> CIImage? {
        CIImage(image: uiImage)
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    nonisolated func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        // This is called on the video queue for frame analysis
        // Can be used for live preview analysis if needed
    }
}

// MARK: - Photo Capture Delegate

private class PhotoCaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate {
    private let completion: (Result<Data?, Error>) -> Void
    
    init(completion: @escaping (Result<Data?, Error>) -> Void) {
        self.completion = completion
    }
    
    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        if let error = error {
            completion(.failure(error))
            return
        }
        completion(.success(photo.fileDataRepresentation()))
    }
}

// MARK: - Camera Error

public enum CameraError: LocalizedError {
    case notAuthorized
    case deviceUnavailable
    case outputUnavailable
    case torchUnavailable
    case invalidImage
    case captureFailed
    
    public var errorDescription: String? {
        switch self {
        case .notAuthorized:
            return "Camera access not authorized"
        case .deviceUnavailable:
            return "Camera device unavailable"
        case .outputUnavailable:
            return "Camera output unavailable"
        case .torchUnavailable:
            return "Torch not available on this device"
        case .invalidImage:
            return "Invalid image data"
        case .captureFailed:
            return "Photo capture failed"
        }
    }
}

// MARK: - iOS App Configuration

/// iOS-specific app configuration
public struct iOSAppConfig {
    public static let shared = iOSAppConfig()
    
    public let apiBaseURL: URL
    public let telemetryEnabled: Bool
    public let telemetryBatchSize: Int
    public let telemetryMaxAge: TimeInterval
    public let offlineQueueMaxSize: Int
    public let maxRetryAttempts: Int
    public let retryBackoffMultiplier: Double
    public let retryMaxBackoff: TimeInterval
    
    private init() {
        // Default configuration - can be overridden by app
        self.apiBaseURL = URL(string: "https://api.fightcitytickets.com")!
        self.telemetryEnabled = false
        self.telemetryBatchSize = 10
        self.telemetryMaxAge = 3600
        self.offlineQueueMaxSize = 100
        self.maxRetryAttempts = 3
        self.retryBackoffMultiplier = 2.0
        self.retryMaxBackoff = 300.0
    }
}
```

## Sources/FightCityiOS/Camera/CameraPreviewView.swift
```
//
//  CameraPreviewView.swift
//  FightCityiOS
//
//  UIKit camera preview wrapped for SwiftUI
//

import SwiftUI
import AVFoundation

/// UIKit camera preview view wrapped for SwiftUI
public struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession
    var showBoundingBoxes: Bool = false
    var boundingBoxes: [BoundingBoxOverlayData] = []
    
    public func makeUIView(context: Context) -> CameraPreviewUIView {
        let view = CameraPreviewUIView()
        view.session = session
        view.showBoundingBoxes = showBoundingBoxes
        view.boundingBoxes = boundingBoxes
        return view
    }
    
    public func updateUIView(_ uiView: CameraPreviewUIView, context: Context) {
        uiView.session = session
        uiView.showBoundingBoxes = showBoundingBoxes
        uiView.boundingBoxes = boundingBoxes
        uiView.setNeedsLayout()
    }
}

/// UIKit preview view with bounding box overlay
public final class CameraPreviewUIView: UIView {
    public var session: AVCaptureSession? {
        didSet {
            if let session = session {
                previewLayer.session = session
            }
        }
    }
    
    public var showBoundingBoxes: Bool = false {
        didSet {
            boundingBoxOverlay.isHidden = !showBoundingBoxes
        }
    }
    
    public var boundingBoxes: [BoundingBoxOverlayData] = [] {
        didSet {
            boundingBoxOverlay.boxes = boundingBoxes
        }
    }
    
    private let previewLayer = AVCaptureVideoPreviewLayer()
    private let boundingBoxOverlay = BoundingBoxOverlayView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        backgroundColor = .black
        
        // Setup preview layer
        previewLayer.videoGravity = .resizeAspectFill
        layer.addSublayer(previewLayer)
        
        // Setup bounding box overlay
        boundingBoxOverlay.isHidden = !showBoundingBoxes
        addSubview(boundingBoxOverlay)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer.frame = bounds
        boundingBoxOverlay.frame = bounds
    }
}

/// Data for bounding box overlay
public struct BoundingBoxOverlayData: Identifiable {
    public let id = UUID()
    public let rect: CGRect
    public let text: String
    public let confidence: Double
    
    public init(rect: CGRect, text: String, confidence: Double) {
        self.rect = rect
        self.text = text
        self.confidence = confidence
    }
}

/// Overlay view for showing detected text regions
final class BoundingBoxOverlayView: UIView {
    var boxes: [BoundingBoxOverlayData] = [] {
        didSet {
            setNeedsDraw()
        }
    }
    
    override func draw(_ rect: CGRect) {
        guard !boxes.isEmpty else { return }
        
        for box in boxes {
            // Draw rectangle
            let path = UIBezierPath(roundedRect: box.rect, cornerRadius: 4)
            path.lineWidth = 2
            UIColor.orange.setStroke()
            path.stroke()
            
            // Draw fill
            UIColor.orange.withAlphaComponent(0.1).setFill()
            path.fill()
            
            // Draw confidence label
            let label = UILabel()
            label.text = "\(Int(box.confidence * 100))%"
            label.font = .systemFont(ofSize: 10, weight: .semibold)
            label.textColor = .white
            label.backgroundColor = UIColor.orange
            label.textAlignment = .center
            label.sizeToFit()
            
            let labelRect = CGRect(
                x: box.rect.origin.x,
                y: box.rect.origin.y - 16,
                width: label.frame.width + 8,
                height: 16
            )
            label.frame = labelRect
            label.drawText(in: labelRect)
        }
    }
}

// MARK: - Bounding Box from Vision

import Vision

extension BoundingBoxOverlayData {
    /// Create from Vision observation
    public static func from(observation: VNRecognizedTextObservation, imageSize: CGSize) -> BoundingBoxOverlayData? {
        guard let topCandidate = observation.topCandidates(1).first else { return nil }
        
        let boundingBox = observation.boundingBox
        let normalizedRect = CGRect(
            x: boundingBox.minX,
            y: 1 - boundingBox.maxY, // Flip Y for UIKit
            width: boundingBox.width,
            height: boundingBox.height
        )
        
        let uiRect = CGRect(
            x: normalizedRect.minX * imageSize.width,
            y: normalizedRect.minY * imageSize.height,
            width: normalizedRect.width * imageSize.width,
            height: normalizedRect.height * imageSize.height
        )
        
        return BoundingBoxOverlayData(
            rect: uiRect,
            text: topCandidate.string,
            confidence: Double(topCandidate.confidence)
        )
    }
}

// MARK: - SwiftUI Preview

#if DEBUG
struct CameraPreviewView_Previews: PreviewProvider {
    static var previews: some View {
        CameraPreviewView(session: AVCaptureSession())
            .frame(height: 400)
    }
}
#endif
```

## Sources/FightCityiOS/Camera/FrameQualityAnalyzer.swift
```
//
//  FrameQualityAnalyzer.swift
//  FightCityiOS
//
//  Analyzes frame quality: sharpness, glare, motion blur
//

import CoreImage
import UIKit

/// Analyzes image quality for optimal capture conditions
public struct FrameQualityAnalyzer {
    private let context = CIContext()
    
    // MARK: - Quality Thresholds
    
    public struct Thresholds {
        public static let sharpness: CGFloat = 100
        public static let glare: CGFloat = 0.3
        public static let motionBlur: CGFloat = 0.5
        
        public init() {}
    }
    
    // MARK: - Analysis Result
    
    public struct AnalysisResult {
        public let sharpness: Double
        public let glareLevel: Double
        public let motionScore: Double
        public let overallScore: Double
        public let isAcceptable: Bool
        public let warnings: [QualityWarning]
        
        public enum QualityWarning: String, CaseIterable {
            case blurry = "Image may be blurry"
            case glare = "Glare detected"
            case motionBlur = "Motion detected"
            case dark = "Image too dark"
            case bright = "Image too bright"
            
            public var displayText: String { rawValue }
        }
        
        public init(
            sharpness: Double,
            glareLevel: Double,
            motionScore: Double,
            overallScore: Double,
            isAcceptable: Bool,
            warnings: [QualityWarning]
        ) {
            self.sharpness = sharpness
            self.glareLevel = glareLevel
            self.motionScore = motionScore
            self.overallScore = overallScore
            self.isAcceptable = isAcceptable
            self.warnings = warnings
        }
    }
    
    public init() {}
    
    // MARK: - Analysis
    
    /// Analyze image quality
    public func analyze(_ uiImage: UIImage) -> AnalysisResult {
        guard let ciImage = CIImage(image: uiImage) else {
            return AnalysisResult(
                sharpness: 0,
                glareLevel: 0,
                motionScore: 0,
                overallScore: 0,
                isAcceptable: false,
                warnings: [.blurry]
            )
        }
        
        let sharpness = calculateSharpness(ciImage)
        let glare = calculateGlare(ciImage)
        let motion = calculateMotionBlur(ciImage)
        let brightness = calculateBrightness(ciImage)
        
        var warnings: [QualityWarning] = []
        
        if sharpness < Thresholds.sharpness {
            warnings.append(.blurry)
        }
        
        if glare > Thresholds.glare {
            warnings.append(.glare)
        }
        
        if motion < Thresholds.motionBlur {
            warnings.append(.motionBlur)
        }
        
        if brightness < 0.2 {
            warnings.append(.dark)
        } else if brightness > 0.9 {
            warnings.append(.bright)
        }
        
        let overallScore = calculateOverallScore(
            sharpness: sharpness,
            glare: glare,
            motion: motion
        )
        
        return AnalysisResult(
            sharpness: sharpness,
            glareLevel: glare,
            motionScore: motion,
            overallScore: overallScore,
            isAcceptable: overallScore >= 0.7 && warnings.isEmpty,
            warnings: warnings
        )
    }
    
    // MARK: - Sharpness Calculation
    
    /// Calculate sharpness using Laplacian variance
    private func calculateSharpness(_ image: CIImage) -> Double {
        guard let filter = CIFilter(name: "CILaplacian") else { return 0 }
        
        filter.setValue(image, forKey: kCIInputImageKey)
        
        guard let output = filter.outputImage,
              let bitmap = context.createCGImage(output, from: output.extent),
              let dataProvider = bitmap.dataProvider,
              let dataProviderData = dataProvider.data else {
            return 0
        }
        
        let pixelData = CGDataProvider(data: dataProviderData)
        guard let data = CFDataGetBytePtr(pixelData) else {
            return 0
        }
        let length = CFDataGetLength(pixelData)
        
        var sum = 0
        var sumSquares = 0
        
        for i in stride(from: 0, to: length, by: 4) {
            let gray = (data[i] + data[i + 1] + data[i + 2]) / 3
            sum += Int(gray)
            sumSquares += Int(gray) * Int(gray)
        }
        
        let count = length / 4
        let mean = Double(sum) / Double(count)
        let variance = Double(sumSquares) / Double(count) - mean * mean
        
        return sqrt(max(0, variance))
    }
    
    // MARK: - Glare Detection
    
    /// Detect glare using highlight threshold
    private func calculateGlare(_ image: CIImage) -> Double {
        guard let filter = CIFilter(name: "CIColorControls") else { return 0 }
        
        filter.setValue(image, forKey: kCIInputImageKey)
        filter.setValue(1.5, forKey: kCIInputContrastKey)
        
        guard let output = filter.outputImage,
              let bitmap = context.createCGImage(output, from: output.extent),
              let dataProvider = bitmap.dataProvider,
              let dataProviderData = dataProvider.data else {
            return 0
        }
        
        let pixelData = CGDataProvider(data: dataProviderData)
        guard let data = CFDataGetBytePtr(pixelData) else {
            return 0
        }
        let length = CFDataGetLength(pixelData)
        
        var highlightPixels = 0
        let threshold = UInt8(240)
        
        for i in stride(from: 0, to: length, by: 4) {
            if data[i] > threshold || data[i + 1] > threshold || data[i + 2] > threshold {
                highlightPixels += 1
            }
        }
        
        let totalPixels = length / 4
        return Double(highlightPixels) / Double(totalPixels)
    }
    
    // MARK: - Motion Blur Detection
    
    /// Estimate motion blur using edge coherence
    private func calculateMotionBlur(_ image: CIImage) -> Double {
        // Use Sobel filter to detect edges
        guard let sobelFilter = CIFilter(name: "CISobel") else { return 1.0 }
        
        sobelFilter.setValue(image, forKey: kCIInputImageKey)
        
        guard let edges = sobelFilter.outputImage,
              let bitmap = context.createCGImage(edges, from: edges.extent),
              let dataProvider = bitmap.dataProvider,
              let dataProviderData = dataProvider.data else {
            return 1.0
        }
        
        let pixelData = CGDataProvider(data: dataProviderData)
        guard let data = CFDataGetBytePtr(pixelData) else {
            return 1.0
        }
        let length = CFDataGetLength(pixelData)
        
        // Count edge pixels
        var edgePixels = 0
        for i in stride(from: 0, to: length, by: 4) {
            let intensity = (data[i] + data[i + 1] + data[i + 2]) / 3
            if intensity > 50 {
                edgePixels += 1
            }
        }
        
        let totalPixels = length / 4
        let edgeDensity = Double(edgePixels) / Double(totalPixels)
        
        // High edge density suggests sharp image
        // Low edge density suggests potential blur
        return min(1.0, edgeDensity * 5)
    }
    
    // MARK: - Brightness Calculation
    
    /// Calculate average brightness
    private func calculateBrightness(_ image: CIImage) -> Double {
        guard let bitmap = context.createCGImage(image, from: image.extent),
              let dataProvider = bitmap.dataProvider,
              let dataProviderData = dataProvider.data else {
            return 0.5
        }
        
        let pixelData = CGDataProvider(data: dataProviderData)
        guard let data = CFDataGetBytePtr(pixelData) else {
            return 0.5
        }
        let length = CFDataGetLength(pixelData)
        
        var totalBrightness = 0
        
        for i in stride(from: 0, to: length, by: 4) {
            totalBrightness += Int(data[i] + data[i + 1] + data[i + 2])
        }
        
        let pixelCount = length / 4
        return Double(totalBrightness) / (Double(pixelCount) * 3 * 255)
    }
    
    // MARK: - Overall Score
    
    /// Calculate weighted overall quality score
    private func calculateOverallScore(sharpness: Double, glare: Double, motion: Double) -> Double {
        let normalizedSharpness = min(1.0, sharpness / 500)
        let normalizedGlare = 1.0 - min(1.0, glare * 2)
        
        // Weighted average: sharpness 50%, glare 30%, motion 20%
        return normalizedSharpness * 0.5 + normalizedGlare * 0.3 + motion * 0.2
    }
}

// MARK: - Auto-Capture Decision

extension FrameQualityAnalyzer.AnalysisResult {
    /// Determine if quality is sufficient for auto-capture
    public var shouldAutoCapture: Bool {
        overallScore >= 0.8 && warnings.isEmpty
    }
    
    /// Get user-facing quality feedback
    public var feedbackMessage: String {
        if warnings.isEmpty {
            return "Perfect conditions"
        }
        
        let messages = warnings.map { $0.displayText }
        return messages.joined(separator: ", ")
    }
}
```

## Sources/FightCityiOS/Models/CaptureResult.swift
```
//
//  CaptureResult.swift
//  FightCityiOS
//
//  OCR capture result with confidence scores
//

import Foundation
import UIKit
import Vision

/// Result from OCR capture and processing
public struct CaptureResult: Identifiable, Codable, Equatable {
    public let id: UUID
    public let originalImageData: Data?
    public let croppedImageData: Data?
    public let rawText: String
    public let extractedCitationNumber: String?
    public let extractedCityId: String?
    public let extractedDate: String?
    public let confidence: Double
    public let processingTimeMs: Int
    public let boundingBoxes: [BoundingBox]
    public let capturedAt: Date
    
    /// Raw recognition observations from Vision (not Codable - excluded from encoding)
    public var observations: [String: VNRecognizedTextObservation]
    
    public init(
        id: UUID = UUID(),
        originalImageData: Data? = nil,
        croppedImageData: Data? = nil,
        rawText: String,
        extractedCitationNumber: String? = nil,
        extractedCityId: String? = nil,
        extractedDate: String? = nil,
        confidence: Double = 0,
        processingTimeMs: Int = 0,
        boundingBoxes: [BoundingBox] = [],
        observations: [String: VNRecognizedTextObservation] = [:],
        capturedAt: Date = Date()
    ) {
        self.id = id
        self.originalImageData = originalImageData
        self.croppedImageData = croppedImageData
        self.rawText = rawText
        self.extractedCitationNumber = extractedCitationNumber
        self.extractedCityId = extractedCityId
        self.extractedDate = extractedDate
        self.confidence = confidence
        self.processingTimeMs = processingTimeMs
        self.boundingBoxes = boundingBoxes
        self.observations = observations
        self.capturedAt = capturedAt
    }
    
    // MARK: - Computed Properties
    
    public var confidenceLevel: ConfidenceLevel {
        if confidence >= 0.85 {
            return .high
        } else if confidence >= 0.60 {
            return .medium
        } else {
            return .low
        }
    }
    
    public var hasValidCitation: Bool {
        guard let citationNumber = extractedCitationNumber else { return false }
        return !citationNumber.isEmpty
    }
    
    public var hasImage: Bool {
        originalImageData != nil
    }
    
    // MARK: - Confidence Level
    
    public enum ConfidenceLevel {
        case high, medium, low
        
        public var requiresReview: Bool {
            self != .high
        }
    }
    
    // MARK: - Codable Conformance
    
    public enum CodingKeys: String, CodingKey {
        case id
        case originalImageData
        case croppedImageData
        case rawText
        case extractedCitationNumber
        case extractedCityId
        case extractedDate
        case confidence
        case processingTimeMs
        case boundingBoxes
        case capturedAt
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        originalImageData = try container.decodeIfPresent(Data.self, forKey: .originalImageData)
        croppedImageData = try container.decodeIfPresent(Data.self, forKey: .croppedImageData)
        rawText = try container.decode(String.self, forKey: .rawText)
        extractedCitationNumber = try container.decodeIfPresent(String.self, forKey: .extractedCitationNumber)
        extractedCityId = try container.decodeIfPresent(String.self, forKey: .extractedCityId)
        extractedDate = try container.decodeIfPresent(String.self, forKey: .extractedDate)
        confidence = try container.decode(Double.self, forKey: .confidence)
        processingTimeMs = try container.decode(Int.self, forKey: .processingTimeMs)
        boundingBoxes = try container.decode([BoundingBox].self, forKey: .boundingBoxes)
        capturedAt = try container.decode(Date.self, forKey: .capturedAt)
        observations = [:] // Not decoded - Vision observations are runtime-only
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(originalImageData, forKey: .originalImageData)
        try container.encodeIfPresent(croppedImageData, forKey: .croppedImageData)
        try container.encode(rawText, forKey: .rawText)
        try container.encodeIfPresent(extractedCitationNumber, forKey: .extractedCitationNumber)
        try container.encodeIfPresent(extractedCityId, forKey: .extractedCityId)
        try container.encodeIfPresent(extractedDate, forKey: .extractedDate)
        try container.encode(confidence, forKey: .confidence)
        try container.encode(processingTimeMs, forKey: .processingTimeMs)
        try container.encode(boundingBoxes, forKey: .boundingBoxes)
        try container.encode(capturedAt, forKey: .capturedAt)
        // observations is excluded from encoding (not Codable)
    }
}

// MARK: - Bounding Box

/// Detected text region with bounding box
public struct BoundingBox: Identifiable, Codable, Equatable {
    public let id: UUID
    public let text: String
    public let confidence: Double
    public let rect: CGRect
    
    public init(
        id: UUID = UUID(),
        text: String,
        confidence: Double,
        rect: CGRect
    ) {
        self.id = id
        self.text = text
        self.confidence = confidence
        self.rect = rect
    }
    
    // MARK: - Coding Keys
    
    public enum CodingKeys: String, CodingKey {
        case id
        case text
        case confidence
        case rect
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        text = try container.decode(String.self, forKey: .text)
        confidence = try container.decode(Double.self, forKey: .confidence)
        
        // Decode CGRect from array [x, y, width, height]
        let rectArray = try container.decode([CGFloat].self, forKey: .rect)
        rect = CGRect(x: rectArray[0], y: rectArray[1], width: rectArray[2], height: rectArray[3])
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(text, forKey: .text)
        try container.encode(confidence, forKey: .confidence)
        try container.encode([rect.origin.x, rect.origin.y, rect.width, rect.height], forKey: .rect)
    }
}

// MARK: - Processing State

/// State of OCR processing
public enum ProcessingState: Equatable {
    case idle
    case analyzing
    case capturing
    case processing
    case complete(CaptureResult)
    case error(String)
    
    public var isProcessing: Bool {
        switch self {
        case .analyzing, .capturing, .processing:
            return true
        default:
            return false
        }
    }
    
    public var statusText: String {
        switch self {
        case .idle:
            return "Ready to scan"
        case .analyzing:
            return "Analyzing frame..."
        case .capturing:
            return "Capturing..."
        case .processing:
            return "Processing OCR..."
        case .complete:
            return "Complete"
        case .error(let message):
            return "Error: \(message)"
        }
    }
}

// MARK: - UIKit Bridge

extension CaptureResult {
    /// Convert to UIImage
    public var originalImage: UIImage? {
        guard let data = originalImageData else { return nil }
        return UIImage(data: data)
    }
    
    public var croppedImage: UIImage? {
        guard let data = croppedImageData else { return nil }
        return UIImage(data: data)
    }
}
```

## Sources/FightCityiOS/OCR/ConfidenceScorer.swift
```
//
//  ConfidenceScorer.swift
//  FightCityiOS
//
//  Calculates confidence scores for OCR results
//

import Vision
import UIKit
import FightCityFoundation

/// Scores and evaluates OCR confidence
public struct ConfidenceScorer {
    // MARK: - Confidence Levels
    
    public enum ConfidenceLevel: String {
        case high = "high"
        case medium = "medium"
        case low = "low"
        
        public var threshold: Double {
            switch self {
            case .high: return 0.85
            case .medium: return 0.60
            case .low: return 0.0
            }
        }
        
        public var requiresReview: Bool {
            self != .high
        }
    }
    
    // MARK: - Scoring Result
    
    public struct ScoreResult {
        public let overallConfidence: Double
        public let level: ConfidenceLevel
        public let components: [ConfidenceComponent]
        public let recommendation: Recommendation
        public let shouldAutoAccept: Bool
        
        public enum Recommendation {
            case accept
            case review
            case reject
        }
        
        public init(
            overallConfidence: Double,
            level: ConfidenceLevel,
            components: [ConfidenceComponent],
            recommendation: Recommendation,
            shouldAutoAccept: Bool
        ) {
            self.overallConfidence = overallConfidence
            self.level = level
            self.components = components
            self.recommendation = recommendation
            self.shouldAutoAccept = shouldAutoAccept
        }
    }
    
    public struct ConfidenceComponent {
        public let name: String
        public let score: Double
        public let weight: Double
        public let weightedScore: Double
        
        public init(name: String, score: Double, weight: Double, weightedScore: Double) {
            self.name = name
            self.score = score
            self.weight = weight
            self.weightedScore = weightedScore
        }
    }
    
    public init() {}
    
    // MARK: - Scoring
    
    /// Score OCR result with all factors
    public func score(
        rawText: String,
        observations: [VNRecognizedTextObservation],
        matchedPattern: OCRParsingEngine.CityPattern?
    ) -> ScoreResult {
        var components: [ConfidenceComponent] = []
        
        // 1. Vision confidence
        let visionConfidence = calculateVisionConfidence(observations)
        components.append(ConfidenceComponent(
            name: "vision_confidence",
            score: visionConfidence,
            weight: 0.4,
            weightedScore: visionConfidence * 0.4
        ))
        
        // 2. Pattern match confidence
        let patternConfidence = calculatePatternConfidence(matchedPattern)
        components.append(ConfidenceComponent(
            name: "pattern_match",
            score: patternConfidence,
            weight: 0.3,
            weightedScore: patternConfidence * 0.3
        ))
        
        // 3. Text completeness
        let completenessConfidence = calculateCompleteness(rawText, matchedPattern: matchedPattern)
        components.append(ConfidenceComponent(
            name: "text_completeness",
            score: completenessConfidence,
            weight: 0.2,
            weightedScore: completenessConfidence * 0.2
        ))
        
        // 4. Observation consistency
        let consistencyConfidence = calculateConsistency(observations)
        components.append(ConfidenceComponent(
            name: "observation_consistency",
            score: consistencyConfidence,
            weight: 0.1,
            weightedScore: consistencyConfidence * 0.1
        ))
        
        // Calculate overall
        let overallScore = components.reduce(0.0) { $0 + $1.weightedScore }
        let level = determineLevel(overallScore)
        let recommendation = determineRecommendation(level)
        
        return ScoreResult(
            overallConfidence: overallScore,
            level: level,
            components: components,
            recommendation: recommendation,
            shouldAutoAccept: level == .high
        )
    }
    
    // MARK: - Component Calculations
    
    private func calculateVisionConfidence(_ observations: [VNRecognizedTextObservation]) -> Double {
        guard !observations.isEmpty else { return 0 }
        
        let totalConfidence = observations.reduce(0.0) { sum, obs in
            sum + (obs.topCandidates(1).first?.confidence ?? 0)
        }
        
        return totalConfidence / Double(observations.count)
    }
    
    private func calculatePatternConfidence(_ pattern: OCRParsingEngine.CityPattern?) -> Double {
        guard let pattern = pattern else { return 0.5 }
        
        // Higher confidence for more specific patterns
        switch pattern.priority {
        case 1: return 0.95 // SF - very specific
        case 2: return 0.90 // NYC - 10 digits specific
        case 3: return 0.80 // Denver - 5-9 digits
        case 4: return 0.70 // LA - broad pattern
        default: return 0.5
        }
    }
    
    private func calculateCompleteness(_ text: String, matchedPattern: OCRParsingEngine.CityPattern?) -> Double {
        guard let pattern = matchedPattern else { return 0.5 }
        
        // Check if extracted text matches pattern length expectations
        let targetLength: ClosedRange<Int>
        switch pattern.cityId {
        case "us-ca-san_francisco":
            targetLength = 10...11 // SFMTA + 8 digits
        case "us-ny-new_york":
            targetLength = 10...10 // Exactly 10
        case "us-co-denver":
            targetLength = 5...9
        case "us-ca-los_angeles":
            targetLength = 6...11
        default:
            targetLength = 6...12
        }
        
        let textLength = text.count
        if targetLength.contains(textLength) {
            return 1.0
        } else if abs(textLength - targetLength.lowerBound) <= 2 {
            return 0.7
        } else {
            return 0.4
        }
    }
    
    private func calculateConsistency(_ observations: [VNRecognizedTextObservation]) -> Double {
        guard observations.count > 1 else { return 1.0 }
        
        let confidences = observations.map { $0.topCandidates(1).first?.confidence ?? 0 }
        let mean = confidences.reduce(0, +) / Double(confidences.count)
        let variance = confidences.reduce(0) { $0 + pow($1 - mean, 2) } / Double(confidences.count)
        let stdDev = sqrt(variance)
        
        // Low variance = high consistency
        return max(0, 1.0 - stdDev * 2)
    }
    
    // MARK: - Level Determination
    
    private func determineLevel(_ score: Double) -> ConfidenceLevel {
        if score >= 0.85 {
            return .high
        } else if score >= 0.60 {
            return .medium
        } else {
            return .low
        }
    }
    
    private func determineRecommendation(_ level: ConfidenceLevel) -> ScoreResult.Recommendation {
        switch level {
        case .high:
            return .accept
        case .medium:
            return .review
        case .low:
            return .reject
        }
    }
}

// MARK: - Threshold Helpers

extension ConfidenceScorer {
    /// Check if result meets auto-accept threshold
    public static func meetsAutoAcceptThreshold(_ confidence: Double) -> Bool {
        confidence >= ConfidenceLevel.high.threshold
    }
    
    /// Check if result requires review
    public static func requiresReview(_ confidence: Double) -> Bool {
        confidence < ConfidenceLevel.high.threshold
    }
    
    /// Get user-friendly confidence message
    public static func confidenceMessage(for level: ConfidenceLevel) -> String {
        switch level {
        case .high:
            return "High confidence - looks correct"
        case .medium:
            return "Medium confidence - please verify"
        case .low:
            return "Low confidence - please check and edit"
        }
    }
}

// MARK: - Fallback Pipeline

extension ConfidenceScorer {
    /// Determine if fallback processing is needed
    public func shouldUseFallback(_ result: ScoreResult) -> Bool {
        return result.level == .low || result.recommendation == .reject
    }
    
    /// Suggest fallback preprocessing options
    public func suggestFallbackOptions(_ result: ScoreResult) -> OCRPreprocessor.Options {
        var options = OCRPreprocessor.Options()
        
        if result.components.first(where: { $0.name == "vision_confidence" })?.score ?? 0 < 0.5 {
            // Low vision confidence - increase preprocessing
            options.enhanceContrast = true
            options.reduceNoise = true
            options.binarize = true
        }
        
        if result.components.first(where: { $0.name == "text_completeness" })?.score ?? 0 < 0.5 {
            // Incomplete text - try perspective correction
            options.correctPerspective = true
        }
        
        return options
    }
}
```

## Sources/FightCityiOS/OCR/OCREngine.swift
```
//
//  OCREngine.swift
//  FightCityiOS
//
//  Vision framework integration for text recognition
//

import Vision
import UIKit

/// Vision-based OCR engine with confidence scoring
public struct OCREngine {
    // MARK: - Recognition Configuration
    
    public struct Configuration {
        public var recognitionLevel: VNRequestTextRecognitionLevel = .accurate
        public var usesLanguageCorrection: Bool = true
        public var recognitionLanguages: [String] = ["en-US"]
        public var autoDetectLanguage: Bool = false
        
        public init() {}
    }
    
    // MARK: - Recognition Result
    
    public struct RecognitionResult {
        public let text: String
        public let observations: [VNRecognizedTextObservation]
        public let confidence: Double
        public let processingTime: TimeInterval
        
        public init(text: String, observations: [VNRecognizedTextObservation], confidence: Double, processingTime: TimeInterval) {
            self.text = text
            self.observations = observations
            self.confidence = confidence
            self.processingTime = processingTime
        }
    }
    
    public init() {}
    
    // MARK: - Recognition
    
    /// Perform OCR on image
    public func recognizeText(
        in image: UIImage,
        configuration: Configuration = Configuration()
    ) async throws -> RecognitionResult {
        let startTime = Date()
        
        guard let cgImage = image.cgImage else {
            throw OCRError.invalidImage
        }
        
        let observations = try await performRecognition(on: cgImage, configuration: configuration)
        let text = extractText(from: observations)
        let confidence = calculateAverageConfidence(from: observations)
        let processingTime = Date().timeIntervalSince(startTime)
        
        return RecognitionResult(
            text: text,
            observations: observations,
            confidence: confidence,
            processingTime: processingTime
        )
    }
    
    // MARK: - Private Methods
    
    private func performRecognition(
        on cgImage: CGImage,
        configuration: Configuration
    ) async throws -> [VNRecognizedTextObservation] {
        try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    continuation.resume(returning: [])
                    return
                }
                
                continuation.resume(returning: observations)
            }
            
            // Configure request
            request.recognitionLevel = configuration.recognitionLevel
            request.usesLanguageCorrection = configuration.usesLanguageCorrection
            request.recognitionLanguages = configuration.recognitionLanguages
            request.autoDetectLanguage = configuration.autoDetectLanguage
            
            // Perform request
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
    
    private func extractText(from observations: [VNRecognizedTextObservation]) -> String {
        var lines: [String] = []
        
        for observation in observations {
            // Get top candidate for each observation
            if let candidate = observation.topCandidates(1).first {
                lines.append(candidate.string)
            }
        }
        
        return lines.joined(separator: "\n")
    }
    
    private func calculateAverageConfidence(from observations: [VNRecognizedTextObservation]) -> Double {
        guard !observations.isEmpty else { return 0 }
        
        let totalConfidence = observations.reduce(0.0) { sum, observation in
            sum + observation.topCandidates(1).first?.confidence ?? 0
        }
        
        return totalConfidence / Double(observations.count)
    }
}

// MARK: - High-Accuracy Recognition

extension OCREngine {
    /// Perform high-accuracy OCR with multiple passes
    public func recognizeWithHighAccuracy(
        in image: UIImage
    ) async throws -> RecognitionResult {
        var config = Configuration()
        config.recognitionLevel = .accurate
        config.usesLanguageCorrection = true
        
        var result = try await recognizeText(in: image, configuration: config)
        
        // If confidence is low, retry with more aggressive settings
        if result.confidence < 0.7 {
            config.recognitionLevel = .accurate
            config.usesLanguageCorrection = true
            result = try await recognizeText(in: image, configuration: config)
        }
        
        return result
    }
    
    /// Perform fast OCR for preview
    public func recognizeFast(
        in image: UIImage
    ) async throws -> RecognitionResult {
        var config = Configuration()
        config.recognitionLevel = .fast
        config.usesLanguageCorrection = false
        
        return try await recognizeText(in: image, configuration: config)
    }
}

// MARK: - OCR Error

public enum OCRError: LocalizedError {
    case invalidImage
    case recognitionFailed(Error)
    case noTextFound
    
    public var errorDescription: String? {
        switch self {
        case .invalidImage:
            return "Invalid image for OCR"
        case .recognitionFailed(let error):
            return "OCR recognition failed: \(error.localizedDescription)"
        case .noTextFound:
            return "No text found in image"
        }
    }
}

// MARK: - Text Observation Extensions

import Vision

extension VNRecognizedTextObservation {
    /// Get all candidates for an observation
    public var allCandidates: [VNRecognizedTextCandidate] {
        topCandidates(10)
    }
    
    /// Get best candidate string
    public var bestText: String {
        topCandidates(1).first?.string ?? ""
    }
    
    /// Get bounding box in image coordinates
    public var boundingBoxInImageCoordinates: CGRect {
        boundingBox
    }
}
```

## Sources/FightCityiOS/OCR/OCRPreprocessor.swift
```
//
//  OCRPreprocessor.swift
//  FightCityiOS
//
//  Image preprocessing: perspective correction, contrast, noise reduction
//

import CoreImage
import UIKit

/// Preprocesses images for optimal OCR results
public struct OCRPreprocessor {
    private let context = CIContext()
    private let ciContext = CIContext()
    
    // MARK: - Preprocessing Options
    
    public struct Options {
        public var enhanceContrast: Bool = true
        public var reduceNoise: Bool = true
        public var correctPerspective: Bool = true
        public var binarize: Bool = false
        public var targetSize: CGSize = CGSize(width: 1920, height: 1920)
        
        public init() {}
    }
    
    public init() {}
    
    // MARK: - Preprocessing Pipeline
    
    /// Preprocess image for OCR
    public func preprocess(_ uiImage: UIImage, options: Options = Options()) async throws -> UIImage {
        guard let ciImage = CIImage(image: uiImage) else {
            throw PreprocessingError.invalidImage
        }
        
        var outputImage = ciImage
        
        // 1. Resize if needed
        if shouldResize(ciImage, targetSize: options.targetSize) {
            outputImage = try resize(ciImage, targetSize: options.targetSize)
        }
        
        // 2. Correct perspective
        if options.correctPerspective {
            outputImage = try correctPerspective(outputImage)
        }
        
        // 3. Enhance contrast
        if options.enhanceContrast {
            outputImage = enhanceContrast(outputImage)
        }
        
        // 4. Reduce noise
        if options.reduceNoise {
            outputImage = reduceNoise(outputImage)
        }
        
        // 5. Binarize for better text extraction
        if options.binarize {
            outputImage = binarize(outputImage)
        }
        
        // Convert back to UIImage
        guard let cgImage = ciContext.createCGImage(outputImage, from: outputImage.extent) else {
            throw PreprocessingError.conversionFailed
        }
        
        return UIImage(cgImage: cgImage)
    }
    
    // MARK: - Resize
    
    private func shouldResize(_ image: CIImage, targetSize: CGSize) -> Bool {
        image.extent.width > targetSize.width || image.extent.height > targetSize.height
    }
    
    private func resize(_ image: CIImage, targetSize: CGSize) throws -> CIImage {
        let scale = min(
            targetSize.width / image.extent.width,
            targetSize.height / image.extent.height
        )
        
        let transform = CGAffineTransform(scaleX: scale, y: scale)
        let scaledImage = image.transformed(by: transform)
        
        return scaledImage
    }
    
    // MARK: - Perspective Correction
    
    private func correctPerspective(_ image: CIImage) throws -> CIImage {
        // Use CIPerspectiveCorrection if document corners can be detected
        // For now, return the original image with basic straightening
        guard let filter = CIFilter(name: "CIStraightenFilter") else {
            return image
        }
        
        filter.setValue(image, forKey: kCIInputImageKey)
        filter.setValue(0, forKey: kCIInputAngleKey) // No rotation needed
        
        return filter.outputImage ?? image
    }
    
    // MARK: - Contrast Enhancement
    
    private func enhanceContrast(_ image: CIImage) -> CIImage {
        guard let filter = CIFilter(name: "CIColorControls") else {
            return image
        }
        
        filter.setValue(image, forKey: kCIInputImageKey)
        filter.setValue(1.2, forKey: kCIInputContrastKey) // Increase contrast
        filter.setValue(0.0, forKey: kCIInputSaturationKey)
        filter.setValue(1.0, forKey: kCIInputBrightnessKey)
        
        return filter.outputImage ?? image
    }
    
    // MARK: - Noise Reduction
    
    private func reduceNoise(_ image: CIImage) -> CIImage {
        guard let filter = CIFilter(name: "CINoiseReduction") else {
            return image
        }
        
        filter.setValue(image, forKey: kCIInputImageKey)
        filter.setValue(0.4, forKey: kCIInputNoiseLevelKey)
        filter.setValue(0.2, forKey: kCIInputSharpnessKey)
        
        return filter.outputImage ?? image
    }
    
    // MARK: - Binarization
    
    private func binarize(_ image: CIImage) -> CIImage {
        guard let filter = CIFilter(name: "CIColorControls") else {
            return image
        }
        
        filter.setValue(image, forKey: kCIInputImageKey)
        filter.setValue(2.0, forKey: kCIInputContrastKey)
        filter.setValue(0.0, forKey: kCIInputSaturationKey)
        
        guard let highContrast = filter.outputImage else {
            return image
        }
        
        // Apply threshold using color matrix
        guard let thresholdFilter = CIFilter(name: "CIColorMatrix") else {
            return highContrast
        }
        
        // Simple threshold: make light pixels white, dark pixels black
        let vector = CIVector(x: 0, y: 0.5, z: 0, w: 0)
        thresholdFilter.setValue(highContrast, forKey: kCIInputImageKey)
        thresholdFilter.setValue(vector, forKey: "inputRVector")
        
        return thresholdFilter.outputImage ?? highContrast
    }
    
    // MARK: - Adaptive Binarization
    
    /// Adaptive binarization for better text separation
    public func adaptiveBinarize(_ uiImage: UIImage) async throws -> UIImage {
        guard let ciImage = CIImage(image: uiImage) else {
            throw PreprocessingError.invalidImage
        }
        
        // Use CIAreaAverage to calculate local threshold
        guard let filter = CIFilter(name: "CIAreaAverage") else {
            return uiImage
        }
        
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(CIVector(x: 0, y: 0, z: ciImage.extent.width, w: ciImage.extent.height), forKey: kCIInputExtentKey)
        
        // For now, apply strong contrast
        let highContrast = enhanceContrast(ciImage)
        let denoised = reduceNoise(highContrast)
        
        guard let cgImage = ciContext.createCGImage(denoised, from: denoised.extent) else {
            throw PreprocessingError.conversionFailed
        }
        
        return UIImage(cgImage: cgImage)
    }
}

// MARK: - Preprocessing Error

public enum PreprocessingError: LocalizedError {
    case invalidImage
    case conversionFailed
    case filterFailed
    
    public var errorDescription: String? {
        switch self {
        case .invalidImage:
            return "Invalid image data"
        case .conversionFailed:
            return "Failed to convert processed image"
        case .filterFailed:
            return "Image filter operation failed"
        }
    }
}

// MARK: - Image Utilities

extension OCRPreprocessor {
    /// Crop image to bounding box
    public static func crop(_ uiImage: UIImage, to rect: CGRect) -> UIImage? {
        guard let cgImage = uiImage.cgImage else { return nil }
        
        let scaledRect = CGRect(
            x: rect.origin.x * uiImage.scale,
            y: rect.origin.y * uiImage.scale,
            width: rect.width * uiImage.scale,
            height: rect.height * uiImage.scale
        )
        
        guard let croppedCGImage = cgImage.cropping(to: scaledRect) else {
            return nil
        }
        
        return UIImage(cgImage: croppedCGImage, scale: uiImage.scale, orientation: uiImage.imageOrientation)
    }
    
    /// Convert UIImage to grayscale CIImage
    public static func grayscale(_ ciImage: CIImage) -> CIImage? {
        guard let filter = CIFilter(name: "CIColorControls") else { return nil }
        
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(0.0, forKey: kCIInputSaturationKey)
        
        return filter.outputImage
    }
}
```

## Sources/FightCityiOS/Telemetry/TelemetryService.swift
```
//
//  TelemetryService.swift
//  FightCityiOS
//
//  Batch telemetry collection with opt-in privacy
//

import Foundation
import CommonCrypto
import UIKit
import FightCityFoundation

/// Service for collecting and managing telemetry data (opt-in only)
@MainActor
public final class TelemetryService: ObservableObject {
    public static let shared = TelemetryService()
    
    @Published public var isEnabled = false
    @Published public var pendingCount = 0
    @Published public var lastUploadDate: Date?
    
    private let storage: TelemetryStorage
    private let uploader: TelemetryUploader
    private let config: iOSAppConfig
    
    private init() {
        self.storage = TelemetryStorage()
        self.uploader = TelemetryUploader()
        self.config = iOSAppConfig.shared
        self.isEnabled = config.telemetryEnabled
    }
    
    // MARK: - User Consent
    
    /// Request user opt-in for telemetry
    public func requestOptIn() async -> Bool {
        // Show privacy dialog
        // Return true if user accepts
        return await withCheckedContinuation { continuation in
            // In real implementation, this would show a dialog
            continuation.resume(returning: false)
        }
    }
    
    /// Enable telemetry with user consent
    public func enable() {
        guard config.telemetryEnabled else { return }
        isEnabled = true
        uploadPendingIfNeeded()
    }
    
    /// Disable telemetry
    public func disable() {
        isEnabled = false
    }
    
    // MARK: - Recording
    
    /// Record a telemetry event
    public func record(
        captureResult: CaptureResult,
        city: String,
        userCorrection: String? = nil
    ) {
        guard isEnabled else { return }
        
        // Hash images for privacy (never store actual images)
        let originalHash = hashImage(captureResult.originalImageData)
        let croppedHash = hashImage(captureResult.croppedImageData)
        
        let record = TelemetryRecord.create(
            from: captureResult,
            city: city,
            originalHash: originalHash,
            croppedHash: croppedHash,
            userCorrection: userCorrection
        )
        
        storage.save(record)
        pendingCount = storage.pendingCount()
        
        uploadPendingIfNeeded()
    }
    
    // MARK: - Upload
    
    /// Upload pending telemetry if threshold reached
    public func uploadPendingIfNeeded() {
        guard isEnabled else { return }
        
        let pending = storage.pendingRecords()
        
        if pending.count >= config.telemetryBatchSize ||
           (pending.count > 0 && needsImmediateUpload()) {
            Task {
                await upload(records: pending)
            }
        }
    }
    
    /// Force upload pending records
    public func uploadPending() async {
        let pending = storage.pendingRecords()
        await upload(records: pending)
    }
    
    private func upload(records: [TelemetryRecord]) async {
        do {
            try await uploader.upload(records)
            storage.markAsUploaded(records)
            pendingCount = storage.pendingCount()
            lastUploadDate = Date()
        } catch {
            print("Telemetry upload failed: \(error)")
        }
    }
    
    private func needsImmediateUpload() -> Bool {
        guard let lastUpload = lastUploadDate else { return true }
        return Date().timeIntervalSince(lastUpload) > config.telemetryMaxAge
    }
    
    // MARK: - Privacy
    
    /// Hash image data for privacy (one-way hash)
    private func hashImage(_ data: Data?) -> String {
        guard let data = data else { return "" }
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes { buffer in
            _ = CC_SHA256(buffer.baseAddress, CC_LONG(buffer.count), &hash)
        }
        return hash.map { String(format: "%02x", $0) }.joined()
    }
    
    // MARK: - Stats
    
    /// Get telemetry statistics
    public func getStats() -> TelemetryStats {
        TelemetryStats(
            totalRecords: storage.totalCount(),
            pendingCount: storage.pendingCount(),
            lastUploadDate: lastUploadDate,
            isEnabled: isEnabled
        )
    }
    
    /// Clear all telemetry data
    public func clearAll() {
        storage.clearAll()
        pendingCount = 0
    }
}

// MARK: - Telemetry Stats

public struct TelemetryStats {
    public let totalRecords: Int
    public let pendingCount: Int
    public let lastUploadDate: Date?
    public let isEnabled: Bool
}

// MARK: - TelemetryRecord iOS Extension

import Vision

extension TelemetryRecord {
    /// Create TelemetryRecord from CaptureResult with iOS device info
    public static func create(
        from result: CaptureResult,
        city: String,
        originalHash: String,
        croppedHash: String,
        userCorrection: String?
    ) -> TelemetryRecord {
        TelemetryRecord(
            city: city,
            timestamp: result.capturedAt,
            deviceModel: UIDevice.current.model,
            iOSVersion: UIDevice.current.systemVersion,
            originalImageHash: originalHash,
            croppedImageHash: croppedHash,
            ocrOutput: result.rawText,
            userCorrection: userCorrection,
            confidence: result.confidence,
            processingTimeMs: result.processingTimeMs
        )
    }
}
```

## Sources/FightCityiOS/Telemetry/TelemetryUploader.swift
```
//
//  TelemetryUploader.swift
//  FightCityiOS
//
//  Background sync with exponential backoff
//

import Foundation
import BackgroundTasks

/// Uploads telemetry data to backend with retry logic
public final class TelemetryUploader {
    private let config: iOSAppConfig
    
    public init(config: iOSAppConfig = .shared) {
        self.config = config
    }
    
    // MARK: - Upload
    
    /// Upload telemetry records to backend
    public func upload(_ records: [TelemetryRecord]) async throws {
        guard !records.isEmpty else { return }
        
        let request = TelemetryUploadRequest(records: records)
        
        do {
            let _: String = try await APIClient.shared.post(
                .telemetryUpload(request),
                body: request
            )
        } catch {
            // If upload fails, queue for retry
            throw error
        }
    }
    
    // MARK: - Background Upload
    
    /// Schedule background upload task
    public func scheduleBackgroundUpload() {
        // Register with BGTaskScheduler
        let request = BGProcessingTaskRequest(identifier: "com.fightcitytickets.telemetry-upload")
        request.requiresNetworkConnectivity = true
        request.requiresExternalPower = false
        request.earliestBeginDate = Date(timeIntervalSinceNow: 60 * 60) // 1 hour
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Failed to schedule background upload: \(error)")
        }
    }
}

// MARK: - Background Task Handler

/// Background task handler for telemetry upload
public final class TelemetryBackgroundHandler {
    public static let shared = TelemetryBackgroundHandler()
    
    private init() {}
    
    /// Handle background task
    public func handleBackgroundTask(_ task: BGProcessingTask) {
        // Schedule next upload
        TelemetryUploader.shared.scheduleBackgroundUpload()
        
        // Upload pending records
        Task {
            await TelemetryService.shared.uploadPending()
            task.setTaskCompleted(success: true)
        }
        
        // Expiration handler
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }
    }
}
```

## Tests/UnitTests/AppTests/Mocks/MockServices.swift
```
//
//  MockServices.swift
//  UnitTests
//
//  Mock implementations for testing
//

import Foundation
import FightCityFoundation
import FightCityiOS

// MARK: - Mock OCR Engine

public final class MockOCREngine: OCREngineProtocol {
    public var shouldFail = false
    public var failError = OCRError.noTextFound
    public var nextResult: OCRRecognitionResult?
    
    public init() {}
    
    public func recognizeText(in imageData: Data, configuration: OCRConfiguration) async throws -> OCRRecognitionResult {
        if shouldFail {
            throw failError
        }
        return nextResult ?? OCRRecognitionResult(
            text: "SFMTA12345678",
            confidence: 0.92,
            processingTime: 0.5,
            observations: [
                OCRObservation(text: "SFMTA12345678", confidence: 0.92, boundingBox: .zero)
            ]
        )
    }
    
    public func recognizeWithHighAccuracy(in imageData: Data) async throws -> OCRRecognitionResult {
        return try await recognizeText(in: imageData, configuration: OCRConfiguration(recognitionLevel: .accurate))
    }
    
    public func recognizeFast(in imageData: Data) async throws -> OCRRecognitionResult {
        return try await recognizeText(in: imageData, configuration: OCRConfiguration(recognitionLevel: .fast))
    }
}

// MARK: - Mock Camera Manager

public final class MockCameraManager: CameraManagerProtocol {
    public var isAuthorized = true
    public var isSessionRunning = false
    public var shouldFailAuthorization = false
    public var shouldFailCapture = false
    public var capturedImages: [Data] = []
    
    public init() {}
    
    public func requestAuthorization() async -> Bool {
        if shouldFailAuthorization {
            return false
        }
        return isAuthorized
    }
    
    public func setupSession() async throws {
        // No-op for mock
    }
    
    public func startSession() async {
        isSessionRunning = true
    }
    
    public func stopSession() async {
        isSessionRunning = false
    }
    
    public func capturePhoto() async throws -> Data? {
        if shouldFailCapture {
            return nil
        }
        let imageData = UIImage.pngData(UIImage())()
        capturedImages.append(imageData)
        return imageData
    }
    
    public func switchCamera() async {
        // No-op for mock
    }
    
    public func setZoom(_ factor: Float) async {
        // No-op for mock
    }
    
    public func toggleTorch() async {
        // No-op for mock
    }
}

// MARK: - Mock API Client

public final class MockAPIClient: APIClientProtocol {
    public var shouldFail = false
    public var failError = APIError.networkUnavailable
    public var nextResponse: CitationValidationResponse?
    public var capturedRequests: [CitationValidationRequest] = []
    
    public init() {}
    
    public func get<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        if shouldFail {
            throw failError
        }
        // swiftlint:disable force_cast
        return nextResponse as! T
        // swiftlint:enable force_cast
    }
    
    public func post<T: Decodable, B: Encodable>(_ endpoint: APIEndpoint, body: B) async throws -> T {
        if shouldFail {
            throw failError
        }
        
        if let request = body as? CitationValidationRequest {
            capturedRequests.append(request)
        }
        
        // swiftlint:disable force_cast
        return nextResponse as! T
        // swiftlint:enable force_cast
    }
    
    public func postVoid<B: Encodable>(_ endpoint: APIEndpoint, body: B) async throws {
        if shouldFail {
            throw failError
        }
    }
    
    public func validateCitation(_ request: CitationValidationRequest) async throws -> CitationValidationResponse {
        capturedRequests.append(request)
        
        if shouldFail {
            throw failError
        }
        
        return nextResponse ?? CitationValidationResponse(
            isValid: true,
            citation: Citation(
                id: UUID(),
                citationNumber: request.citation_number,
                cityId: request.city_id,
                cityName: "Test City",
                agency: "TEST",
                violationDate: Date(),
                amount: 95.00,
                deadlineDate: Calendar.current.date(byAdding: .day, value: 21, to: Date()),
                daysRemaining: 21,
                isPastDeadline: false,
                isUrgent: false,
                canAppealOnline: true,
                phoneConfirmationRequired: true,
                status: .validated
            ),
            confidence: 0.92
        )
    }
}

// MARK: - Mock Confidence Scorer

public final class MockConfidenceScorer: ConfidenceScorerProtocol {
    public var nextResult: ConfidenceResult!
    
    public init() {}
    
    public func score(rawText: String, observations: [OCRObservation], matchedPattern: CityPattern?) -> ConfidenceResult {
        return nextResult ?? ConfidenceResult(
            overallConfidence: 0.85,
            level: .high,
            components: [],
            recommendation: .accept
        )
    }
}

// MARK: - Mock Pattern Matcher

public final class MockPatternMatcher: PatternMatcherProtocol {
    public var nextResult: PatternMatchResult!
    
    public init() {}
    
    public func match(_ text: String) -> PatternMatchResult {
        return nextResult ?? PatternMatchResult(
            cityId: "us-ca-san_francisco",
            pattern: CityPattern(
                cityId: "us-ca-san_francisco",
                cityName: "San Francisco",
                pattern: "^(SFMTA|MT)[0-9]{8}$",
                priority: 1,
                deadlineDays: 21,
                canAppealOnline: true,
                phoneConfirmationRequired: true
            ),
            priority: 1
        )
    }
}

// MARK: - Mock Frame Quality Analyzer

public final class MockFrameQualityAnalyzer: FrameQualityAnalyzerProtocol {
    public var nextResult: QualityAnalysisResult!
    
    public init() {}
    
    public func analyze(_ imageData: Data) -> QualityAnalysisResult {
        return nextResult ?? QualityAnalysisResult(
            isAcceptable: true,
            feedbackMessage: nil,
            warnings: []
        )
    }
}

// MARK: - Mock Image Preprocessor

public final class MockImagePreprocessor: ImagePreprocessorProtocol {
    public var shouldFail = false
    public var nextOutput: Data!
    
    public init() {}
    
    public func preprocess(_ imageData: Data) async throws -> Data {
        if shouldFail {
            throw NSError(domain: "MockPreprocessor", code: 1)
        }
        return nextOutput ?? imageData
    }
}

// MARK: - Mock History Storage

public final class MockHistoryStorage: HistoryStorageProtocol {
    public var citations: [Citation] = []
    public var shouldFail = false
    
    public init() {}
    
    public func loadHistory() async throws -> [Citation] {
        if shouldFail {
            throw NSError(domain: "MockStorage", code: 1)
        }
        return citations
    }
    
    public func saveCitation(_ citation: Citation) async throws {
        if shouldFail {
            throw NSError(domain: "MockStorage", code: 1)
        }
        citations.insert(citation, at: 0)
    }
    
    public func deleteCitation(_ id: UUID) async throws {
        if shouldFail {
            throw NSError(domain: "MockStorage", code: 1)
        }
        citations.removeAll { $0.id == id }
    }
}
```

## Tests/UnitTests/FoundationTests/ConfidenceScorerTests.swift
```
//
//  ConfidenceScorerTests.swift
//  UnitTests
//
//  Tests for confidence scoring algorithm
//

import XCTest
@testable import FightCityFoundation

final class ConfidenceScorerTests: XCTestCase {
    var sut: ConfidenceScorer!
    var mockLogger: MockLogger!
    
    override func setUp() {
        super.setUp()
        mockLogger = MockLogger()
        sut = ConfidenceScorer(logger: mockLogger)
    }
    
    override func tearDown() {
        sut = nil
        mockLogger = nil
        super.tearDown()
    }
    
    // MARK: - Vision Confidence Tests
    
    func testHighVisionConfidenceProducesHighOverall() {
        // Given
        let observations = [
            OCRObservation(text: "SFMTA12345678", confidence: 0.95, boundingBox: .zero),
            OCRObservation(text: "Violation", confidence: 0.92, boundingBox: .zero)
        ]
        
        // When
        let result = sut.score(rawText: "SFMTA12345678", observations: observations, matchedPattern: nil)
        
        // Then
        XCTAssertGreaterThan(result.overallConfidence, 0.85)
        XCTAssertEqual(result.level, .high)
        XCTAssertEqual(result.recommendation, .accept)
    }
    
    func testLowVisionConfidenceProducesLowOverall() {
        // Given
        let observations = [
            OCRObservation(text: "Unclear", confidence: 0.45, boundingBox: .zero),
            OCRObservation(text: "Text", confidence: 0.50, boundingBox: .zero)
        ]
        
        // When
        let result = sut.score(rawText: "Unclear Text", observations: observations, matchedPattern: nil)
        
        // Then
        XCTAssertLessThan(result.overallConfidence, 0.60)
        XCTAssertEqual(result.level, .low)
        XCTAssertEqual(result.recommendation, .reject)
    }
    
    // MARK: - Pattern Match Tests
    
    func testPatternMatchImprovesConfidence() {
        // Given
        let observations = [
            OCRObservation(text: "SFMTA12345678", confidence: 0.80, boundingBox: .zero)
        ]
        
        let sfPattern = CityPattern(
            cityId: "us-ca-san_francisco",
            cityName: "San Francisco",
            pattern: "^(SFMTA|MT)[0-9]{8}$",
            priority: 1,
            deadlineDays: 21,
            canAppealOnline: true,
            phoneConfirmationRequired: true
        )
        
        // When
        let result = sut.score(rawText: "SFMTA12345678", observations: observations, matchedPattern: sfPattern)
        
        // Then
        XCTAssertGreaterThan(result.overallConfidence, 0.80) // Should be boosted by pattern match
    }
    
    // MARK: - Component Breakdown Tests
    
    func testComponentsHaveCorrectWeights() {
        // Given
        let observations = [
            OCRObservation(text: "Test", confidence: 0.90, boundingBox: .zero)
        ]
        
        // When
        let result = sut.score(rawText: "Test", observations: observations, matchedPattern: nil)
        
        // Then
        XCTAssertEqual(result.components.count, 4)
        
        let componentNames = result.components.map { $0.name }
        XCTAssertTrue(componentNames.contains("vision"))
        XCTAssertTrue(componentNames.contains("pattern"))
        XCTAssertTrue(componentNames.contains("completeness"))
        XCTAssertTrue(componentNames.contains("consistency"))
    }
    
    // MARK: - Empty Observations Tests
    
    func testEmptyObservationsProducesZeroConfidence() {
        // When
        let result = sut.score(rawText: "", observations: [], matchedPattern: nil)
        
        // Then
        XCTAssertEqual(result.overallConfidence, 0)
        XCTAssertEqual(result.level, .low)
        XCTAssertEqual(result.recommendation, .reject)
    }
}

// MARK: - ConfidenceScorer Implementation

public final class ConfidenceScorer {
    private let logger: LoggerProtocol
    private let visionWeight = 0.40
    private let patternWeight = 0.30
    private let completenessWeight = 0.20
    private let consistencyWeight = 0.10
    
    public init(logger: LoggerProtocol = Logger.shared) {
        self.logger = logger
    }
    
    public func score(rawText: String, observations: [OCRObservation], matchedPattern: CityPattern?) -> ConfidenceResult {
        guard !observations.isEmpty else {
            return ConfidenceResult(
                overallConfidence: 0,
                level: .low,
                components: [],
                recommendation: .reject
            )
        }
        
        // Vision confidence (40%)
        let visionScore = observations.map { $0.confidence }.reduce(0, +) / Double(observations.count)
        let visionComponent = ConfidenceComponent(
            name: "vision",
            score: visionScore,
            weight: visionWeight,
            weightedScore: visionScore * visionWeight
        )
        
        // Pattern confidence (30%)
        let patternScore = matchedPattern != nil ? 1.0 : 0.5
        let patternComponent = ConfidenceComponent(
            name: "pattern",
            score: patternScore,
            weight: patternWeight,
            weightedScore: patternScore * patternWeight
        )
        
        // Completeness (20%)
        let completenessScore = calculateCompleteness(rawText: rawText, pattern: matchedPattern)
        let completenessComponent = ConfidenceComponent(
            name: "completeness",
            score: completenessScore,
            weight: completenessWeight,
            weightedScore: completenessScore * completenessWeight
        )
        
        // Consistency (10%)
        let consistencyScore = calculateConsistency(observations: observations)
        let consistencyComponent = ConfidenceComponent(
            name: "consistency",
            score: consistencyScore,
            weight: consistencyWeight,
            weightedScore: consistencyScore * consistencyWeight
        )
        
        let components = [visionComponent, patternComponent, completenessComponent, consistencyComponent]
        let overall = components.reduce(0) { $0 + $1.weightedScore }
        
        let level: ConfidenceLevel
        let recommendation: Recommendation
        
        if overall >= 0.85 {
            level = .high
            recommendation = .accept
        } else if overall >= 0.60 {
            level = .medium
            recommendation = .review
        } else {
            level = .low
            recommendation = .reject
        }
        
        logger.debug("Confidence scored: \(overall) (\(level.rawValue))")
        
        return ConfidenceResult(
            overallConfidence: overall,
            level: level,
            components: components,
            recommendation: recommendation
        )
    }
    
    private func calculateCompleteness(rawText: String, pattern: CityPattern?) -> Double {
        guard !rawText.isEmpty else { return 0 }
        
        if let pattern = pattern {
            // Check if text length is reasonable for the pattern
            let minLength = 6
            let maxLength = 20
            let textLength = rawText.count
            
            if textLength >= minLength && textLength <= maxLength {
                return 1.0
            } else if textLength < minLength {
                return Double(textLength) / Double(minLength)
            } else {
                return Double(maxLength) / Double(textLength)
            }
        }
        
        return 0.7 // Default for unknown pattern
    }
    
    private func calculateConsistency(observations: [OCRObservation]) -> Double {
        guard observations.count > 1 else { return 1.0 }
        
        let confidences = observations.map { $0.confidence }
        let mean = confidences.reduce(0, +) / Double(confidences.count)
        let variance = confidences.reduce(0) { $0 + pow($1 - mean, 2) } / Double(confidences.count)
        let stdDev = sqrt(variance)
        
        // Lower standard deviation = higher consistency
        return max(0, 1.0 - stdDev * 2)
    }
}
```

## Tests/UnitTests/FoundationTests/Mocks/MockAPIClient.swift
```
//
//  MockAPIClient.swift
//  FightCityFoundationTests
//
//  Mock implementation of APIClient for testing
//

import Foundation
@testable import FightCityFoundation

/// Mock API client for unit testing
final class MockAPIClient: APIClientProtocol {
    
    // MARK: - Properties
    
    var shouldFail: Bool = false
    var shouldReturnError: APIError?
    var simulatedDelay: TimeInterval = 0
    
    var getCalled: Bool = false
    var postCalled: Bool = false
    var requestCount: Int = 0
    
    // Configurable responses
    var mockResponse: Any?
    var mockStatusCode: Int = 200
    var mockHeaders: [String: String] = [:]
    
    // Request tracking
    var lastEndpoint: APIEndpoint?
    var lastRequestBody: Data?
    var allRequests: [(endpoint: APIEndpoint, method: String, body: Data?)] = []
    
    // MARK: - Initialization
    
    init(
        mockResponse: Any? = nil,
        mockStatusCode: Int = 200
    ) {
        self.mockResponse = mockResponse
        self.mockStatusCode = mockStatusCode
    }
    
    // MARK: - APIClient Protocol
    
    func get<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        getCalled = true
        requestCount += 1
        lastEndpoint = endpoint
        allRequests.append((endpoint, "GET", nil))
        
        return try handleRequest()
    }
    
    func getVoid(_ endpoint: APIEndpoint) async throws {
        getCalled = true
        requestCount += 1
        lastEndpoint = endpoint
        allRequests.append((endpoint, "GET", nil))
        
        try validateResponse()
    }
    
    func post<T: Decodable, B: Encodable>(_ endpoint: APIEndpoint, body: B) async throws -> T {
        postCalled = true
        requestCount += 1
        lastEndpoint = endpoint
        lastRequestBody = try JSONEncoder().encode(body)
        allRequests.append((endpoint, "POST", lastRequestBody))
        
        return try handleRequest()
    }
    
    func postVoid<B: Encodable>(_ endpoint: APIEndpoint, body: B) async throws {
        postCalled = true
        requestCount += 1
        lastEndpoint = endpoint
        lastRequestBody = try JSONEncoder().encode(body)
        allRequests.append((endpoint, "POST", lastRequestBody))
        
        try validateResponse()
    }
    
    // MARK: - Private Helpers
    
    private func handleRequest<T: Decodable>() throws -> T {
        if shouldFail, let error = shouldReturnError {
            throw error
        }
        
        if simulatedDelay > 0 {
            Thread.sleep(forTimeInterval: simulatedDelay)
        }
        
        try validateResponse()
        
        guard let response = mockResponse as? T else {
            throw APIError.decodingError(error: NSError(domain: "MockAPIClient", code: -1))
        }
        
        return response
    }
    
    private func validateResponse() throws {
        if shouldFail {
            throw shouldReturnError ?? .serverError(statusCode: 500)
        }
        
        switch mockStatusCode {
        case 200...299:
            return
        case 400:
            throw APIError.badRequest
        case 401:
            throw APIError.unauthorized
        case 404:
            throw APIError.notFound
        case 422:
            throw APIError.validationError
        case 429:
            throw APIError.rateLimited
        case 500...599:
            throw APIError.serverError(statusCode: mockStatusCode)
        default:
            throw APIError.unknown(statusCode: mockStatusCode)
        }
    }
    
    // MARK: - Test Helpers
    
    func resetCalls() {
        getCalled = false
        postCalled = false
        requestCount = 0
        lastEndpoint = nil
        lastRequestBody = nil
        allRequests.removeAll()
    }
    
    func configureForSuccess<T: Encodable>(response: T) {
        shouldFail = false
        shouldReturnError = nil
        mockResponse = response
        mockStatusCode = 200
    }
    
    func configureForNotFound() {
        shouldFail = true
        shouldReturnError = .notFound
        mockStatusCode = 404
    }
    
    func configureForValidationError() {
        shouldFail = true
        shouldReturnError = .validationError
        mockStatusCode = 422
    }
    
    func configureForServerError() {
        shouldFail = true
        shouldReturnError = .serverError(statusCode: 500)
        mockStatusCode = 500
    }
    
    func configureForRateLimited() {
        shouldFail = true
        shouldReturnError = .rateLimited
        mockStatusCode = 429
    }
    
    func configureForNetworkUnavailable() {
        shouldFail = true
        shouldReturnError = .networkUnavailable
        mockStatusCode = -1
    }
    
    func verifyRequestCount(_ count: Int) -> Bool {
        return requestCount == count
    }
    
    func verifyEndpointCalled(_ path: String) -> Bool {
        return allRequests.contains { $0.endpoint.path == path }
    }
}

// MARK: - APIClient Protocol

/// Protocol defining API client interface for dependency injection
public protocol APIClientProtocol {
    func get<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T
    func getVoid(_ endpoint: APIEndpoint) async throws
    func post<T: Decodable, B: Encodable>(_ endpoint: APIEndpoint, body: B) async throws -> T
    func postVoid<B: Encodable>(_ endpoint: APIEndpoint, body: B) async throws
}

// MARK: - Mock Response Builders

extension MockAPIClient {
    
    /// Create a mock citation response
    static func createMockCitationResponse(
        citationNumber: String = "SFMTA91234567",
        cityId: String = "us-ca-san_francisco",
        amount: Double = 95.00,
        daysRemaining: Int = 21
    ) -> CitationValidationResponse {
        CitationValidationResponse(
            is_valid: true,
            citation: Citation(
                id: UUID(),
                citationNumber: citationNumber,
                cityId: cityId,
                cityName: cityId.components(separatedBy: "-").last?.replacingOccurrences(of: "_", with: " ").capitalized ?? "Unknown",
                agency: "SFMTA",
                amount: Decimal(amount),
                violationDate: "2024-01-15",
                violationTime: "14:30",
                deadlineDate: "2024-02-05",
                daysRemaining: daysRemaining,
                isPastDeadline: daysRemaining < 0,
                isUrgent: daysRemaining <= 3,
                canAppealOnline: true,
                phoneConfirmationRequired: true,
                status: .pending
            ),
            confidence: 0.95
        )
    }
    
    /// Create a mock health response
    static func createMockHealthResponse() -> HealthResponse {
        HealthResponse(status: "healthy", version: "1.0.0", timestamp: Date())
    }
}

// MARK: - Mock Response Types

/// Health check response
public struct HealthResponse: Codable {
    public let status: String
    public let version: String
    public let timestamp: Date
}

/// Citation validation response
public struct CitationValidationResponse: Codable {
    public let is_valid: Bool
    public let citation: Citation
    public let confidence: Double
}

// MARK: - Test Configuration

/// Configuration for test suite
struct TestConfiguration {
    static let validSFCitation = "SFMTA91234567"
    static let validNYCCitation = "1234567890"
    static let validDenverCitation = "1234567"
    static let validLACitation = "LA123456"
    static let invalidCitation = "INVALID"
    static let mockAPIKey = "test-api-key-12345"
    static let mockBaseURL = "https://api.test.fightcitytickets.com"
}
```

## Tests/UnitTests/FoundationTests/OCRParsingEngineTests.swift
```
//
//  OCRParsingEngineTests.swift
//  FightCityFoundationTests
//
//  Unit tests for OCRParsingEngine pattern matching
//

import XCTest
@testable import FightCityFoundation

final class OCRParsingEngineTests: XCTestCase {
    
    var sut: OCRParsingEngine!
    
    override func setUp() {
        super.setUp()
        sut = OCRParsingEngine()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - San Francisco Pattern Tests
    
    func testSanFranciscoValidSFMTA() {
        // Given
        let text = "SFMTA91234567"
        
        // When
        let result = sut.parse(text)
        
        // Then
        XCTAssertNotNil(result.citationNumber)
        XCTAssertEqual(result.citationNumber, text)
        XCTAssertEqual(result.cityId, "us-ca-san_francisco")
        XCTAssertEqual(result.cityName, "San Francisco")
        XCTAssertNotNil(result.matchedPattern)
        XCTAssertEqual(result.matchedPattern?.priority, 1)
    }
    
    func testSanFranciscoValidMT() {
        // Given
        let text = "MT91234567"
        
        // When
        let result = sut.parse(text)
        
        // Then
        XCTAssertNotNil(result.citationNumber)
        XCTAssertEqual(result.cityId, "us-ca-san_francisco")
    }
    
    func testSanFranciscoInvalidTooShort() {
        // Given - only 7 digits
        let text = "SFMTA912345"
        
        // When
        let result = sut.parse(text)
        
        // Then
        XCTAssertNil(result.citationNumber)
        XCTAssertNil(result.cityId)
    }
    
    func testSanFranciscoInvalidTooLong() {
        // Given - 10 digits instead of 8
        let text = "SFMTA9123456789"
        
        // When
        let result = sut.parse(text)
        
        // Then
        XCTAssertNil(result.citationNumber)
    }
    
    func testSanFranciscoInvalidPrefix() {
        // Given - wrong prefix
        let text = "NYC91234567"
        
        // When
        let result = sut.parse(text)
        
        // Then
        XCTAssertNil(result.cityId)
    }
    
    // MARK: - NYC Pattern Tests
    
    func testNYCValid10Digits() {
        // Given
        let text = "1234567890"
        
        // When
        let result = sut.parse(text)
        
        // Then
        XCTAssertNotNil(result.citationNumber)
        XCTAssertEqual(result.citationNumber, text)
        XCTAssertEqual(result.cityId, "us-ny-new_york")
        XCTAssertEqual(result.cityName, "New York")
        XCTAssertEqual(result.matchedPattern?.priority, 2)
    }
    
    func testNYCInvalidTooShort() {
        // Given
        let text = "123456789"
        
        // When
        let result = sut.parse(text)
        
        // Then - should not match NYC, might match another pattern or none
        XCTAssertNil(result.cityId)
    }
    
    func testNYCInvalidTooLong() {
        // Given
        let text = "12345678901"
        
        // When
        let result = sut.parse(text)
        
        // Then
        XCTAssertNil(result.cityId)
    }
    
    func testNYCInvalidWithLetters() {
        // Given
        let text = "12345ABC90"
        
        // When
        let result = sut.parse(text)
        
        // Then
        XCTAssertNil(result.cityId)
    }
    
    // MARK: - Denver Pattern Tests
    
    func testDenverValid5Digits() {
        // Given
        let text = "12345"
        
        // When
        let result = sut.parse(text)
        
        // Then
        XCTAssertNotNil(result.citationNumber)
        XCTAssertEqual(result.cityId, "us-co-denver")
        XCTAssertEqual(result.cityName, "Denver")
        XCTAssertEqual(result.matchedPattern?.priority, 3)
    }
    
    func testDenverValid9Digits() {
        // Given
        let text = "123456789"
        
        // When
        let result = sut.parse(text)
        
        // Then
        XCTAssertNotNil(result.citationNumber)
        XCTAssertEqual(result.cityId, "us-co-denver")
    }
    
    func testDenverInvalidTooShort() {
        // Given
        let text = "1234"
        
        // When
        let result = sut.parse(text)
        
        // Then
        XCTAssertNil(result.cityId)
    }
    
    func testDenverInvalidTooLong() {
        // Given
        let text = "1234567890"
        
        // When - 10 digits should match NYC, not Denver
        let result = sut.parse(text)
        
        // Then
        XCTAssertEqual(result.cityId, "us-ny-new_york")
    }
    
    // MARK: - Los Angeles Pattern Tests
    
    func testLAValidAlphanumeric6() {
        // Given
        let text = "LA1234"
        
        // When
        let result = sut.parse(text)
        
        // Then
        XCTAssertNotNil(result.citationNumber)
        XCTAssertEqual(result.cityId, "us-ca-los_angeles")
        XCTAssertEqual(result.cityName, "Los Angeles")
        XCTAssertEqual(result.matchedPattern?.priority, 4)
    }
    
    func testLAValidAlphanumeric11() {
        // Given
        let text = "LA123456789"
        
        // When
        let result = sut.parse(text)
        
        // Then
        XCTAssertNotNil(result.citationNumber)
        XCTAssertEqual(result.cityId, "us-ca-los_angeles")
    }
    
    func testLAValidNumericOnly() {
        // Given
        let text = "123456"
        
        // When
        let result = sut.parse(text)
        
        // Then
        XCTAssertNotNil(result.citationNumber)
        XCTAssertEqual(result.cityId, "us-ca-los_angeles")
    }
    
    func testLAInvalidTooShort() {
        // Given
        let text = "LA123"
        
        // When
        let result = sut.parse(text)
        
        // Then
        XCTAssertNil(result.cityId)
    }
    
    func testLAInvalidTooLong() {
        // Given
        let text = "LA12345678901"
        
        // When
        let result = sut.parse(text)
        
        // Then
        XCTAssertNil(result.cityId)
    }
    
    func testLAInvalidLowercase() {
        // Given
        let text = "la123456"
        
        // When
        let result = sut.parse(text)
        
        // Then
        XCTAssertNil(result.cityId)
    }
    
    // MARK: - Priority Tests
    
    func testSF优先于NYC() {
        // Given - 10-digit number that could match both
        let text = "SFMTA91234567" // This won't match NYC, SF should match
        
        // When
        let result = sut.parse(text)
        
        // Then
        XCTAssertEqual(result.cityId, "us-ca-san_francisco")
        XCTAssertEqual(result.matchedPattern?.priority, 1)
    }
    
    func testNYC优先于Denver() {
        // Given - 9-digit number could match Denver, but 10-digit should match NYC
        let text = "1234567890" // 10 digits - NYC
        
        // When
        let result = sut.parse(text)
        
        // Then
        XCTAssertEqual(result.cityId, "us-ny-new_york")
    }
    
    func testDenver优先于LA() {
        // Given - 6 alphanumeric could match LA, but 5-9 digits only matches Denver
        let text = "123456" // 6 digits - could match LA (6-11) but Denver (5-9) should match first
        
        // When
        let result = sut.parse(text)
        
        // Then - Denver should match first due to priority
        XCTAssertEqual(result.cityId, "us-co-denver")
    }
    
    // MARK: - Text Normalization Tests
    
    func testNormalizeRemovesSpaces() {
        // Given
        let text = "SFMTA 912 345 67"
        
        // When
        let result = sut.parse(text)
        
        // Then
        XCTAssertEqual(result.citationNumber, "SFMTA91234567")
    }
    
    func testNormalizeConvertsToUppercase() {
        // Given
        let text = "sfmta91234567"
        
        // When
        let result = sut.parse(text)
        
        // Then
        XCTAssertNotNil(result.citationNumber)
        XCTAssertEqual(result.cityId, "us-ca-san_francisco")
    }
    
    func testNormalizeConvertsPipeToI() {
        // Given
        let text = "SFMTA9|234567"
        
        // When
        let result = sut.parse(text)
        
        // Then
        XCTAssertEqual(result.citationNumber, "SFMTA9I234567")
    }
    
    func testNormalizeConvertsLowercaseLToI() {
        // Given
        let text = "SFMTA9l234567"
        
        // When
        let result = sut.parse(text)
        
        // Then
        XCTAssertEqual(result.citationNumber, "SFMTA9I234567")
    }
    
    func testNormalizePreservesZeros() {
        // Given - ensure OCR doesn't turn 0 into O
        let text = "1234506789"
        
        // When
        let result = sut.parse(text)
        
        // Then
        XCTAssertEqual(result.citationNumber, "1234506789")
    }
    
    func testNormalizeRemovesSpecialCharacters() {
        // Given
        let text = "SFMTA@91234567"
        
        // When
        let result = sut.parse(text)
        
        // Then
        XCTAssertEqual(result.citationNumber, "SFMTA91234567")
    }
    
    // MARK: - Confidence Score Tests
    
    func testSFHasHighestConfidence() {
        // Given
        let sfResult = sut.parse("SFMTA91234567")
        let nycResult = sut.parse("1234567890")
        let denverResult = sut.parse("1234567")
        let laResult = sut.parse("LA123456")
        
        // Then
        XCTAssertGreaterThan(sfResult.confidence, nycResult.confidence)
        XCTAssertGreaterThan(nycResult.confidence, denverResult.confidence)
        XCTAssertGreaterThan(denverResult.confidence, laResult.confidence)
    }
    
    func testConfidenceInValidRange() {
        // Given - various valid patterns
        let patterns = [
            "SFMTA91234567",
            "1234567890",
            "1234567",
            "LA123456"
        ]
        
        // When/Then
        for pattern in patterns {
            let result = sut.parse(pattern)
            XCTAssertGreaterThanOrEqual(result.confidence, 0.5)
            XCTAssertLessThanOrEqual(result.confidence, 1.0)
        }
    }
    
    func testNoMatchHasZeroConfidence() {
        // Given
        let result = sut.parse("INVALID_TEXT")
        
        // Then
        XCTAssertNil(result.citationNumber)
        XCTAssertEqual(result.confidence, 0)
    }
    
    // MARK: - City Hint Tests
    
    func testParseWithCityHintSF() {
        // Given
        let text = "91234567"
        let cityHint = "us-ca-san_francisco"
        
        // When
        let result = sut.parseWithCityHint(text, cityId: cityHint)
        
        // Then - should match because text matches SF pattern
        XCTAssertNotNil(result.citationNumber)
        XCTAssertEqual(result.cityId, cityHint)
    }
    
    func testParseWithCityHintMismatch() {
        // Given - 10 digits with NYC hint
        let text = "1234567890"
        let cityHint = "us-ny-new_york"
        
        // When
        let result = sut.parseWithCityHint(text, cityId: cityHint)
        
        // Then
        XCTAssertNotNil(result.citationNumber)
        XCTAssertEqual(result.cityId, cityHint)
    }
    
    func testParseWithCityHintFallback() {
        // Given - text that doesn't match hint, should fallback to general parsing
        let text = "LA123456"
        let cityHint = "us-ny-new_york" // NYC hint but LA text
        
        // When
        let result = sut.parseWithCityHint(text, cityId: cityHint)
        
        // Then - should fallback to LA
        XCTAssertEqual(result.cityId, "us-ca-los_angeles")
    }
    
    // MARK: - Formatting Tests
    
    func testFormatSFCitationWithDashes() {
        // Given
        let citation = "912345678"
        let cityId = "us-ca-san_francisco"
        
        // When
        let formatted = sut.formatCitation(citation, cityId: cityId)
        
        // Then
        XCTAssertEqual(formatted, "912-345-678")
    }
    
    func testFormatSFCitationAlreadyFormatted() {
        // Given
        let citation = "912-345-678"
        let cityId = "us-ca-san_francisco"
        
        // When
        let formatted = sut.formatCitation(citation, cityId: cityId)
        
        // Then
        XCTAssertEqual(formatted, "912-345-678")
    }
    
    func testFormatNYCCitationNoDashes() {
        // Given
        let citation = "1234567890"
        let cityId = "us-ny-new_york"
        
        // When
        let formatted = sut.formatCitation(citation, cityId: cityId)
        
        // Then
        XCTAssertEqual(formatted, "1234567890")
    }
    
    func testFormatLACitationNoDashes() {
        // Given
        let citation = "LA123456"
        let cityId = "us-ca-los_angeles"
        
        // When
        let formatted = sut.formatCitation(citation, cityId: cityId)
        
        // Then
        XCTAssertEqual(formatted, "LA123456")
    }
    
    func testFormatUnknownCityReturnsOriginal() {
        // Given
        let citation = "UNKNOWN123"
        let cityId = "unknown-city"
        
        // When
        let formatted = sut.formatCitation(citation, cityId: cityId)
        
        // Then
        XCTAssertEqual(formatted, "UNKNOWN123")
    }
    
    // MARK: - Date Extraction Tests
    
    func testExtractDatesMMDDYYYY() {
        // Given
        let text = "Ticket issued on 01/15/2024"
        
        // When
        let dates = sut.extractDates(from: text)
        
        // Then
        XCTAssertFalse(dates.isEmpty)
        XCTAssertEqual(dates.first?.rawValue, "01/15/2024")
    }
    
    func testExtractDatesMMDDYYYYWithDashes() {
        // Given
        let text = "Violation 01-15-2024"
        
        // When
        let dates = sut.extractDates(from: text)
        
        // Then
        XCTAssertFalse(dates.isEmpty)
    }
    
    func testExtractDatesYYYYMMDD() {
        // Given
        let text = "Date: 2024-01-15"
        
        // When
        let dates = sut.extractDates(from: text)
        
        // Then
        XCTAssertFalse(dates.isEmpty)
    }
    
    func testExtractDatesMonthDDYYYY() {
        // Given
        let text = "January 15, 2024"
        
        // When
        let dates = sut.extractDates(from: text)
        
        // Then
        XCTAssertFalse(dates.isEmpty)
    }
    
    func testExtractDatesMultipleDates() {
        // Given
        let text = "Issued 01/15/2024, Due 02/15/2024"
        
        // When
        let dates = sut.extractDates(from: text)
        
        // Then
        XCTAssertEqual(dates.count, 2)
    }
    
    func testExtractDatesNoDates() {
        // Given
        let text = "No dates here"
        
        // When
        let dates = sut.extractDates(from: text)
        
        // Then
        XCTAssertTrue(dates.isEmpty)
    }
    
    // MARK: - Raw Matches Tests
    
    func testRawMatchesContainsAllMatches() {
        // Given
        let text = "SFMTA91234567 and also 1234567890"
        
        // When
        let result = sut.parse(text)
        
        // Then
        XCTAssertTrue(result.rawMatches.count >= 1)
        XCTAssertTrue(result.rawMatches.contains("SFMTA91234567"))
    }
    
    func testRawMatchesEmptyOnNoMatch() {
        // Given
        let text = "no matches here"
        
        // When
        let result = sut.parse(text)
        
        // Then
        XCTAssertTrue(result.rawMatches.isEmpty)
    }
    
    // MARK: - Edge Cases
    
    func testEmptyStringReturnsNoMatch() {
        // Given
        let text = ""
        
        // When
        let result = sut.parse(text)
        
        // Then
        XCTAssertNil(result.citationNumber)
        XCTAssertNil(result.cityId)
    }
    
    func testWhitespaceOnlyReturnsNoMatch() {
        // Given
        let text = "   "
        
        // When
        let result = sut.parse(text)
        
        // Then
        XCTAssertNil(result.citationNumber)
    }
    
    func testVeryLongStringDoesNotCrash() {
        // Given
        let text = String(repeating: "A", count: 1000)
        
        // When
        let result = sut.parse(text)
        
        // Then
        XCTAssertNotNil(result)
    }
    
    func testMixedValidInvalidPattern() {
        // Given - text with valid pattern in noise
        let text = "ABC SFMTA91234567 XYZ 123"
        
        // When
        let result = sut.parse(text)
        
        // Then
        XCTAssertNotNil(result.citationNumber)
        XCTAssertEqual(result.cityId, "us-ca-san_francisco")
    }
}
```

## Tests/UnitTests/FoundationTests/PatternMatcherTests.swift
```
//
//  PatternMatcherTests.swift
//  UnitTests
//
//  Tests for citation pattern matching
//

import XCTest
@testable import FightCityFoundation

final class PatternMatcherTests: XCTestCase {
    var sut: PatternMatcher!
    
    override func setUp() {
        super.setUp()
        sut = PatternMatcher()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - San Francisco Pattern Tests
    
    func testSanFranciscoSFMTAFormat() {
        // Given
        let input = "SFMTA12345678"
        
        // When
        let result = sut.match(input)
        
        // Then
        XCTAssertTrue(result.isMatch)
        XCTAssertEqual(result.cityId, "us-ca-san_francisco")
        XCTAssertEqual(result.priority, 1)
    }
    
    func testSanFranciscoMTFormat() {
        // Given
        let input = "MT12345678"
        
        // When
        let result = sut.match(input)
        
        // Then
        XCTAssertTrue(result.isMatch)
        XCTAssertEqual(result.cityId, "us-ca-san_francisco")
    }
    
    func testSanFranciscoInvalidLength() {
        // Given
        let input = "SFMTA1234"
        
        // When
        let result = sut.match(input)
        
        // Then
        XCTAssertFalse(result.isMatch)
        XCTAssertNil(result.cityId)
    }
    
    // MARK: - New York Pattern Tests
    
    func testNewYork10Digits() {
        // Given
        let input = "1234567890"
        
        // When
        let result = sut.match(input)
        
        // Then
        XCTAssertTrue(result.isMatch)
        XCTAssertEqual(result.cityId, "us-ny-new_york")
        XCTAssertEqual(result.priority, 2)
    }
    
    func testNewYorkInvalidLetters() {
        // Given
        let input = "12345ABCDE"
        
        // When
        let result = sut.match(input)
        
        // Then
        XCTAssertFalse(result.isMatch)
    }
    
    // MARK: - Denver Pattern Tests
    
    func testDenverValidLengths() {
        // Valid lengths: 5-9 digits
        let validInputs = ["12345", "123456", "1234567", "12345678", "123456789"]
        
        for input in validInputs {
            let result = sut.match(input)
            XCTAssertTrue(result.isMatch, "Expected \(input) to match Denver pattern")
            XCTAssertEqual(result.cityId, "us-co-denver")
        }
    }
    
    func testDenverInvalidTooShort() {
        // Given
        let input = "1234"
        
        // When
        let result = sut.match(input)
        
        // Then
        XCTAssertFalse(result.isMatch)
    }
    
    // MARK: - Los Angeles Pattern Tests
    
    func testLos AngelesValid() {
        // LA accepts 6-11 alphanumeric characters
        let validInputs = ["ABC123", "A1B2C3D4E5", "123ABC4567"]
        
        for input in validInputs {
            let result = sut.match(input)
            XCTAssertTrue(result.isMatch, "Expected \(input) to match LA pattern")
            XCTAssertEqual(result.cityId, "us-ca-los_angeles")
        }
    }
    
    // MARK: - Priority Tests
    
    func testPriorityOrderSanFrancisco() {
        // San Francisco should match before others when applicable
        let sfInput = "SFMTA12345678"
        let result = sut.match(sfInput)
        
        XCTAssertEqual(result.priority, 1) // Highest priority
    }
    
    // MARK: - Invalid Input Tests
    
    func testEmptyString() {
        // Given
        let input = ""
        
        // When
        let result = sut.match(input)
        
        // Then
        XCTAssertFalse(result.isMatch)
        XCTAssertNil(result.cityId)
    }
    
    func testSpecialCharacters() {
        // Given
        let input = "SFMTA-1234-5678"
        
        // When
        let result = sut.match(input)
        
        // Then - dash format should not match
        XCTAssertFalse(result.isMatch)
    }
}

// MARK: - PatternMatcher Implementation

public final class PatternMatcher {
    private let patterns: [CityPattern]
    
    public init() {
        self.patterns = [
            // San Francisco - highest priority (most specific)
            CityPattern(
                cityId: "us-ca-san_francisco",
                cityName: "San Francisco",
                pattern: "^(SFMTA|MT)[0-9]{8}$",
                priority: 1,
                deadlineDays: 21,
                canAppealOnline: true,
                phoneConfirmationRequired: true
            ),
            // New York
            CityPattern(
                cityId: "us-ny-new_york",
                cityName: "New York",
                pattern: "^[0-9]{10}$",
                priority: 2,
                deadlineDays: 30,
                canAppealOnline: true,
                phoneConfirmationRequired: false
            ),
            // Denver
            CityPattern(
                cityId: "us-co-denver",
                cityName: "Denver",
                pattern: "^[0-9]{5,9}$",
                priority: 3,
                deadlineDays: 21,
                canAppealOnline: true,
                phoneConfirmationRequired: false
            ),
            // Los Angeles - lowest priority (least specific)
            CityPattern(
                cityId: "us-ca-los_angeles",
                cityName: "Los Angeles",
                pattern: "^[0-9A-Z]{6,11}$",
                priority: 4,
                deadlineDays: 21,
                canAppealOnline: false,
                phoneConfirmationRequired: true
            )
        ]
    }
    
    public func match(_ text: String) -> PatternMatchResult {
        let normalizedText = text.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        guard !normalizedText.isEmpty else {
            return PatternMatchResult(cityId: nil, pattern: nil, priority: 0)
        }
        
        // Sort by priority and try each pattern
        let sortedPatterns = patterns.sorted { $0.priority < $1.priority }
        
        for pattern in sortedPatterns {
            if let regex = try? NSRegularExpression(pattern: pattern.pattern, options: .caseInsensitive) {
                let range = NSRange(normalizedText.startIndex..., in: normalizedText)
                if regex.firstMatch(in: normalizedText, options: [], range: range) != nil {
                    return PatternMatchResult(
                        cityId: pattern.cityId,
                        pattern: pattern,
                        priority: pattern.priority
                    )
                }
            }
        }
        
        return PatternMatchResult(cityId: nil, pattern: nil, priority: 0)
    }
}
```

## Tests/UnitTests/iOSTests/ConfidenceScorerTests.swift
```
//
//  ConfidenceScorerTests.swift
//  FightCityiOSTests
//
//  Unit tests for ConfidenceScorer
//

import XCTest
@testable import FightCityiOS
@testable import FightCityFoundation
import Vision

final class ConfidenceScorerTests: XCTestCase {
    
    var sut: ConfidenceScorer!
    
    override func setUp() {
        super.setUp()
        sut = ConfidenceScorer()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Confidence Level Tests
    
    func testConfidenceLevelThresholds() {
        XCTAssertEqual(ConfidenceScorer.ConfidenceLevel.high.threshold, 0.85)
        XCTAssertEqual(ConfidenceScorer.ConfidenceLevel.medium.threshold, 0.60)
        XCTAssertEqual(ConfidenceScorer.ConfidenceLevel.low.threshold, 0.0)
    }
    
    func testConfidenceLevelRequiresReview() {
        XCTAssertFalse(ConfidenceScorer.ConfidenceLevel.high.requiresReview)
        XCTAssertTrue(ConfidenceScorer.ConfidenceLevel.medium.requiresReview)
        XCTAssertTrue(ConfidenceScorer.ConfidenceLevel.low.requiresReview)
    }
    
    // MARK: - High Confidence Tests
    
    func testHighConfidenceAcceptsAutoAccept() {
        // Given - high vision confidence observations
        let observations = createObservations(withConfidence: 0.95)
        let pattern = createMockPattern(priority: 1)
        
        // When
        let result = sut.score(rawText: "SFMTA91234567", observations: observations, matchedPattern: pattern)
        
        // Then
        XCTAssertEqual(result.level, .high)
        XCTAssertEqual(result.recommendation, .accept)
        XCTAssertTrue(result.shouldAutoAccept)
        XCTAssertGreaterThanOrEqual(result.overallConfidence, 0.85)
    }
    
    func testHighConfidenceMessage() {
        let message = ConfidenceScorer.confidenceMessage(for: .high)
        XCTAssertEqual(message, "High confidence - looks correct")
    }
    
    // MARK: - Medium Confidence Tests
    
    func testMediumConfidenceRequiresReview() {
        // Given - medium vision confidence observations
        let observations = createObservations(withConfidence: 0.70)
        let pattern = createMockPattern(priority: 4) // LA pattern - lower confidence
        
        // When
        let result = sut.score(rawText: "LA123456", observations: observations, matchedPattern: pattern)
        
        // Then
        XCTAssertEqual(result.level, .medium)
        XCTAssertEqual(result.recommendation, .review)
        XCTAssertFalse(result.shouldAutoAccept)
        XCTAssertGreaterThanOrEqual(result.overallConfidence, 0.60)
        XCTAssertLessThan(result.overallConfidence, 0.85)
    }
    
    func testMediumConfidenceMessage() {
        let message = ConfidenceScorer.confidenceMessage(for: .medium)
        XCTAssertEqual(message, "Medium confidence - please verify")
    }
    
    // MARK: - Low Confidence Tests
    
    func testLowConfidenceRejects() {
        // Given - low vision confidence observations
        let observations = createObservations(withConfidence: 0.40)
        let pattern = createMockPattern(priority: 4)
        
        // When
        let result = sut.score(rawText: "LA123", observations: observations, matchedPattern: pattern)
        
        // Then
        XCTAssertEqual(result.level, .low)
        XCTAssertEqual(result.recommendation, .reject)
        XCTAssertFalse(result.shouldAutoAccept)
        XCTAssertLessThan(result.overallConfidence, 0.60)
    }
    
    func testLowConfidenceMessage() {
        let message = ConfidenceScorer.confidenceMessage(for: .low)
        XCTAssertEqual(message, "Low confidence - please check and edit")
    }
    
    // MARK: - Empty Observations Tests
    
    func testEmptyObservationsReturnsZeroConfidence() {
        // Given
        let observations: [VNRecognizedTextObservation] = []
        let pattern = createMockPattern(priority: 1)
        
        // When
        let result = sut.score(rawText: "SFMTA91234567", observations: observations, matchedPattern: pattern)
        
        // Then
        XCTAssertEqual(result.level, .low)
        XCTAssertLessThan(result.overallConfidence, 0.50)
    }
    
    // MARK: - No Pattern Match Tests
    
    func testNoPatternMatchReturnsMediumConfidence() {
        // Given
        let observations = createObservations(withConfidence: 0.80)
        
        // When
        let result = sut.score(rawText: "UNKNOWN12345", observations: observations, matchedPattern: nil)
        
        // Then
        XCTAssertNotNil(result)
        // Should still have decent confidence due to vision score
        XCTAssertGreaterThanOrEqual(result.overallConfidence, 0.4)
    }
    
    // MARK: - Pattern Priority Tests
    
    func testSFPatternHighestConfidence() {
        // Given - same observations, different patterns
        let observations = createObservations(withConfidence: 0.90)
        
        // When
        let sfResult = sut.score(rawText: "SFMTA91234567", observations: observations, matchedPattern: createMockPattern(priority: 1))
        let nycResult = sut.score(rawText: "1234567890", observations: observations, matchedPattern: createMockPattern(priority: 2))
        let denverResult = sut.score(rawText: "123456789", observations: observations, matchedPattern: createMockPattern(priority: 3))
        let laResult = sut.score(rawText: "LA12345678", observations: observations, matchedPattern: createMockPattern(priority: 4))
        
        // Then - SF pattern should have highest confidence
        XCTAssertGreaterThan(sfResult.overallConfidence, nycResult.overallConfidence)
        XCTAssertGreaterThan(nycResult.overallConfidence, denverResult.overallConfidence)
        XCTAssertGreaterThan(denverResult.overallConfidence, laResult.overallConfidence)
    }
    
    // MARK: - Completeness Tests
    
    func testPerfectLengthAccepts() {
        // Given
        let observations = createObservations(withConfidence: 0.90)
        let sfPattern = createMockPattern(cityId: "us-ca-san_francisco", priority: 1)
        
        // When - perfect length for SF (10-11 chars)
        let result = sut.score(rawText: "SFMTA91234", observations: observations, matchedPattern: sfPattern)
        
        // Then
        let completenessComponent = result.components.first { $0.name == "text_completeness" }
        XCTAssertEqual(completenessComponent?.score, 1.0)
    }
    
    func testSlightlyOffLengthAccepts() {
        // Given
        let observations = createObservations(withConfidence: 0.90)
        let sfPattern = createMockPattern(cityId: "us-ca-san_francisco", priority: 1)
        
        // When - length within 2 of target
        let result = sut.score(rawText: "SFMTA912", observations: observations, matchedPattern: sfPattern)
        
        // Then
        let completenessComponent = result.components.first { $0.name == "text_completeness" }
        XCTAssertEqual(completenessComponent?.score, 0.7)
    }
    
    func testWrongLengthRejects() {
        // Given
        let observations = createObservations(withConfidence: 0.90)
        let sfPattern = createMockPattern(cityId: "us-ca-san_francisco", priority: 1)
        
        // When - length too far from target
        let result = sut.score(rawText: "SF", observations: observations, matchedPattern: sfPattern)
        
        // Then
        let completenessComponent = result.components.first { $0.name == "text_completeness" }
        XCTAssertEqual(completenessComponent?.score, 0.4)
    }
    
    // MARK: - Consistency Tests
    
    func testSingleObservationHasFullConsistency() {
        // Given
        let observations = createSingleObservation(withConfidence: 0.90)
        
        // When
        let result = sut.score(rawText: "SFMTA91234567", observations: observations, matchedPattern: nil)
        
        // Then
        let consistencyComponent = result.components.first { $0.name == "observation_consistency" }
        XCTAssertEqual(consistencyComponent?.score, 1.0)
    }
    
    func testConsistentObservationsHaveHighConsistency() {
        // Given - all observations have similar confidence
        let observations = createMultipleObservations(confidences: [0.90, 0.91, 0.89, 0.90])
        
        // When
        let result = sut.score(rawText: "SFMTA91234567", observations: observations, matchedPattern: nil)
        
        // Then
        let consistencyComponent = result.components.first { $0.name == "observation_consistency" }
        XCTAssertGreaterThanOrEqual(consistencyComponent?.score ?? 0, 0.9)
    }
    
    func testInconsistentObservationsHaveLowerConsistency() {
        // Given - observations have varying confidence
        let observations = createMultipleObservations(confidences: [0.90, 0.50, 0.95, 0.30])
        
        // When
        let result = sut.score(rawText: "SFMTA91234567", observations: observations, matchedPattern: nil)
        
        // Then
        let consistencyComponent = result.components.first { $0.name == "observation_consistency" }
        XCTAssertLessThan(consistencyComponent?.score ?? 1.0, 0.8)
    }
    
    // MARK: - Fallback Pipeline Tests
    
    func testShouldUseFallbackOnLowConfidence() {
        // Given
        let observations = createObservations(withConfidence: 0.40)
        
        // When
        let result = sut.score(rawText: "UNKNOWN", observations: observations, matchedPattern: nil)
        
        // Then
        XCTAssertTrue(sut.shouldUseFallback(result))
    }
    
    func testShouldNotUseFallbackOnHighConfidence() {
        // Given
        let observations = createObservations(withConfidence: 0.95)
        
        // When
        let result = sut.score(rawText: "SFMTA91234567", observations: observations, matchedPattern: createMockPattern(priority: 1))
        
        // Then
        XCTAssertFalse(sut.shouldUseFallback(result))
    }
    
    func testSuggestFallbackOptionsForLowVision() {
        // Given - low vision confidence
        let observations = createObservations(withConfidence: 0.30)
        let result = sut.score(rawText: "SFMTA91234567", observations: observations, matchedPattern: createMockPattern(priority: 1))
        
        // When
        let options = sut.suggestFallbackOptions(result)
        
        // Then
        XCTAssertTrue(options.enhanceContrast)
        XCTAssertTrue(options.reduceNoise)
        XCTAssertTrue(options.binarize)
    }
    
    func testSuggestFallbackOptionsForIncompleteText() {
        // Given - complete vision but incomplete text
        let observations = createObservations(withConfidence: 0.90)
        let result = sut.score(rawText: "SF", observations: observations, matchedPattern: createMockPattern(priority: 1))
        
        // When
        let options = sut.suggestFallbackOptions(result)
        
        // Then
        XCTAssertTrue(options.correctPerspective)
    }
    
    // MARK: - Threshold Helpers Tests
    
    func testMeetsAutoAcceptThreshold() {
        XCTAssertTrue(ConfidenceScorer.meetsAutoAcceptThreshold(0.90))
        XCTAssertTrue(ConfidenceScorer.meetsAutoAcceptThreshold(0.85))
        XCTAssertFalse(ConfidenceScorer.meetsAutoAcceptThreshold(0.84))
        XCTAssertFalse(ConfidenceScorer.meetsAutoAcceptThreshold(0.60))
    }
    
    func testRequiresReview() {
        XCTAssertFalse(ConfidenceScorer.requiresReview(0.90))
        XCTAssertTrue(ConfidenceScorer.requiresReview(0.84))
        XCTAssertTrue(ConfidenceScorer.requiresReview(0.50))
    }
    
    // MARK: - Component Weight Tests
    
    func testAllComponentsHaveCorrectWeights() {
        // Given
        let observations = createObservations(withConfidence: 0.90)
        
        // When
        let result = sut.score(rawText: "SFMTA91234567", observations: observations, matchedPattern: createMockPattern(priority: 1))
        
        // Then
        let visionComponent = result.components.first { $0.name == "vision_confidence" }
        let patternComponent = result.components.first { $0.name == "pattern_match" }
        let completenessComponent = result.components.first { $0.name == "text_completeness" }
        let consistencyComponent = result.components.first { $0.name == "observation_consistency" }
        
        XCTAssertEqual(visionComponent?.weight, 0.4)
        XCTAssertEqual(patternComponent?.weight, 0.3)
        XCTAssertEqual(completenessComponent?.weight, 0.2)
        XCTAssertEqual(consistencyComponent?.weight, 0.1)
    }
    
    // MARK: - Edge Cases
    
    func testNilPatternUsesDefaultCompleteness() {
        // Given
        let observations = createObservations(withConfidence: 0.90)
        
        // When
        let result = sut.score(rawText: "SOMEUNKNOWN123", observations: observations, matchedPattern: nil)
        
        // Then
        let completenessComponent = result.components.first { $0.name == "text_completeness" }
        XCTAssertEqual(completenessComponent?.score, 0.5) // Default for nil pattern
    }
    
    func testEmptyTextCompleteness() {
        // Given
        let observations = createObservations(withConfidence: 0.90)
        
        // When
        let result = sut.score(rawText: "", observations: observations, matchedPattern: createMockPattern(priority: 1))
        
        // Then
        let completenessComponent = result.components.first { $0.name == "text_completeness" }
        XCTAssertEqual(completenessComponent?.score, 0.4) // Empty text rejected
    }
    
    // MARK: - Helper Methods
    
    private func createObservations(withConfidence confidence: Double) -> [VNRecognizedTextObservation] {
        // Create mock observations with the given confidence
        return (0..<5).map { _ in
            createMockObservation(confidence: confidence)
        }
    }
    
    private func createSingleObservation(withConfidence confidence: Double) -> [VNRecognizedTextObservation] {
        return [createMockObservation(confidence: confidence)]
    }
    
    private func createMultipleObservations(confidences: [Double]) -> [VNRecognizedTextObservation] {
        return confidences.map { createMockObservation(confidence: $0) }
    }
    
    private func createMockObservation(confidence: Double) -> VNRecognizedTextObservation {
        // Create a mock observation with the given confidence
        let observation = VNRecognizedTextObservation()
        
        // Use reflection to set the private confidence property
        let mirror = Mirror(reflecting: observation)
        if let confidenceProperty = mirror.children.first(where: { $0.label == "confidence" }) {
            // Note: confidence is a let property on the observation, so we can't modify it directly
            // In real tests, we would use a mock or dependency injection
        }
        
        return observation
    }
    
    private func createMockPattern(priority: Int) -> OCRParsingEngine.CityPattern {
        OCRParsingEngine.CityPattern(
            cityId: "test-city",
            cityName: "Test City",
            regex: "^[A-Z0-9]+$",
            priority: priority,
            formatExample: "TEST123"
        )
    }
    
    private func createMockPattern(cityId: String, priority: Int) -> OCRParsingEngine.CityPattern {
        OCRParsingEngine.CityPattern(
            cityId: cityId,
            cityName: cityId.components(separatedBy: "-").last?.replacingOccurrences(of: "_", with: " ").capitalized ?? "Test",
            regex: "^[A-Z0-9]+$",
            priority: priority,
            formatExample: "TEST123"
        )
    }
}
```

## Tests/UnitTests/iOSTests/Mocks/MockCameraManager.swift
```
//
//  MockCameraManager.swift
//  FightCityiOSTests
//
//  Mock implementation of CameraManager protocol for testing
//

import AVFoundation
import UIKit
@testable import FightCityiOS

/// Mock camera manager for unit testing
final class MockCameraManager: CameraManagerProtocol {
    
    // MARK: - Properties
    
    var isAuthorized: Bool = true
    var isSessionRunning: Bool = false
    var currentCameraPosition: AVCaptureDevice.Position = .back
    
    // Configurable behavior
    var shouldFailAuthorization: Bool = false
    var shouldFailCapture: Bool = false
    var shouldFailSessionSetup: Bool = false
    var captureDelay: TimeInterval = 0
    
    // Captured calls
    var capturePhotoCalled: Bool = false
    var switchCameraCalled: Bool = false
    var focusCalled: Bool = false
    var torchCalled: Bool = false
    
    // Mock data
    var mockPhotoData: Data?
    var mockError: CameraError?
    
    // MARK: - Initialization
    
    init(
        isAuthorized: Bool = true,
        mockPhotoData: Data? = nil
    ) {
        self.isAuthorized = isAuthorized
        self.mockPhotoData = mockPhotoData
    }
    
    // MARK: - Authorization
    
    func requestAuthorization() async -> Bool {
        if shouldFailAuthorization {
            isAuthorized = false
            return false
        }
        isAuthorized = true
        return true
    }
    
    // MARK: - Session Setup
    
    func setupSession() throws {
        if shouldFailSessionSetup {
            throw CameraError.deviceUnavailable
        }
        isSessionRunning = true
    }
    
    func startSession() {
        isSessionRunning = true
    }
    
    func stopSession() {
        isSessionRunning = false
    }
    
    // MARK: - Camera Controls
    
    func switchCamera() throws {
        guard isSessionRunning else {
            throw CameraError.deviceUnavailable
        }
        switchCameraCalled = true
        currentCameraPosition = currentCameraPosition == .back ? .front : .back
    }
    
    func focus(at point: CGPoint) async throws {
        guard isAuthorized else {
            throw CameraError.notAuthorized
        }
        focusCalled = true
    }
    
    func setTorch(level: Float) async throws {
        guard isAuthorized else {
            throw CameraError.notAuthorized
        }
        torchCalled = true
    }
    
    // MARK: - Capture
    
    func capturePhoto() async throws -> Data? {
        capturePhotoCalled = true
        
        if shouldFailCapture {
            throw CameraError.captureFailed
        }
        
        // Simulate capture delay if configured
        if captureDelay > 0 {
            try await Task.sleep(nanoseconds: UInt64(captureDelay * 1_000_000_000))
        }
        
        // Return mock data or generate placeholder
        if let data = mockPhotoData {
            return data
        }
        
        // Generate a 1x1 red pixel JPEG as placeholder
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 1, height: 1))
        let image = renderer.image { context in
            UIColor.red.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        }
        return image.jpegData(compressionQuality: 1.0)
    }
    
    // MARK: - Image Processing
    
    func processImage(_ imageData: Data) async throws -> (UIImage, CIImage) {
        guard let image = UIImage(data: imageData),
              let ciImage = CIImage(image: image) else {
            throw CameraError.invalidImage
        }
        return (image, ciImage)
    }
    
    // MARK: - Test Helpers
    
    func resetCalls() {
        capturePhotoCalled = false
        switchCameraCalled = false
        focusCalled = false
        torchCalled = false
    }
    
    func configureForSuccess() {
        shouldFailAuthorization = false
        shouldFailCapture = false
        shouldFailSessionSetup = false
    }
    
    func configureForFailure(error: CameraError) {
        mockError = error
        switch error {
        case .notAuthorized:
            shouldFailAuthorization = true
            isAuthorized = false
        case .captureFailed:
            shouldFailCapture = true
        case .deviceUnavailable:
            shouldFailSessionSetup = true
        default:
            break
        }
    }
}

// MARK: - CameraManager Protocol

/// Protocol defining camera manager interface for dependency injection
public protocol CameraManagerProtocol {
    var isAuthorized: Bool { get }
    var isSessionRunning: Bool { get }
    var currentCameraPosition: AVCaptureDevice.Position { get }
    
    func requestAuthorization() async -> Bool
    func setupSession() throws
    func startSession()
    func stopSession()
    func switchCamera() throws
    func focus(at point: CGPoint) async throws
    func setTorch(level: Float) async throws
    func capturePhoto() async throws -> Data?
    func processImage(_ imageData: Data) async throws -> (UIImage, CIImage)
}
```

## Tests/UnitTests/iOSTests/Mocks/MockOCREngine.swift
```
//
//  MockOCREngine.swift
//  FightCityiOSTests
//
//  Mock implementation of OCREngine for testing
//

import Vision
import UIKit
@testable import FightCityiOS
@testable import FightCityFoundation

/// Mock OCR engine for unit testing
final class MockOCREngine: OCREngineProtocol {
    
    // MARK: - Properties
    
    var shouldFail: Bool = false
    var shouldReturnLowConfidence: Bool = false
    var simulatedDelay: TimeInterval = 0
    
    var recognizeTextCalled: Bool = false
    var recognizeWithHighAccuracyCalled: Bool = false
    var recognizeFastCalled: Bool = false
    
    // Configurable responses
    var mockText: String = ""
    var mockConfidence: Float = 0.95
    var mockObservations: [MockObservation] = []
    var mockMatchedCityId: String? = "us-ca-san_francisco"
    var mockProcessingTime: TimeInterval = 0.5
    
    // MARK: - Initialization
    
    init(
        mockText: String = "SFMTA91234567",
        mockConfidence: Float = 0.95,
        mockMatchedCityId: String? = "us-ca-san_francisco"
    ) {
        self.mockText = mockText
        self.mockConfidence = mockConfidence
        self.mockMatchedCityId = mockMatchedCityId
        self.mockObservations = [MockObservation(text: mockText, confidence: mockConfidence)]
    }
    
    // MARK: - OCREngine Protocol
    
    func recognizeText(imageData: Data, configuration: OCRConfiguration) async throws -> OCRRecognitionResult {
        recognizeTextCalled = true
        
        if shouldFail {
            throw OCRError.recognitionFailed
        }
        
        if simulatedDelay > 0 {
            try await Task.sleep(nanoseconds: UInt64(simulatedDelay * 1_000_000_000))
        }
        
        return createMockResult(configuration: configuration)
    }
    
    func recognizeWithHighAccuracy(imageData: Data) async throws -> OCRRecognitionResult {
        recognizeWithHighAccuracyCalled = true
        
        if shouldFail {
            throw OCRError.recognitionFailed
        }
        
        var config = OCRConfiguration()
        config.recognitionLevel = .accurate
        return createMockResult(configuration: config)
    }
    
    func recognizeFast(imageData: Data) async throws -> OCRRecognitionResult {
        recognizeFastCalled = true
        
        if shouldFail {
            throw OCRError.recognitionFailed
        }
        
        var config = OCRConfiguration()
        config.recognitionLevel = .fast
        return createMockResult(configuration: config)
    }
    
    // MARK: - Private Helpers
    
    private func createMockResult(configuration: OCRConfiguration) -> OCRRecognitionResult {
        let confidence = shouldReturnLowConfidence ? 0.40 : mockConfidence
        let observations = createObservations(confidence: confidence)
        
        return OCRRecognitionResult(
            text: mockText,
            observations: observations,
            confidence: Double(confidence),
            processingTime: mockProcessingTime,
            matchedCityId: mockMatchedCityId
        )
    }
    
    private func createObservations(confidence: Float) -> [VNRecognizedTextObservation] {
        // Create mock observations with the specified confidence
        var observations: [VNRecognizedTextObservation] = []
        
        for i in 0..<3 {
            let observation = MockObservation(
                text: mockText,
                confidence: confidence,
                topCandidatesCount: 3
            )
            (observation as! VNRecognizedTextObservation).mockCandidates = [
                MockRecognizedText(string: mockText, confidence: confidence),
                MockRecognizedText(string: mockText.lowercased(), confidence: confidence - 0.1),
                MockRecognizedText(string: "UNKNOWN", confidence: confidence - 0.3)
            ]
            observations.append(observation as! VNRecognizedTextObservation)
        }
        
        return observations
    }
    
    // MARK: - Test Helpers
    
    func resetCalls() {
        recognizeTextCalled = false
        recognizeWithHighAccuracyCalled = false
        recognizeFastCalled = false
    }
    
    func configureForSFPattern() {
        mockText = "SFMTA91234567"
        mockConfidence = 0.95
        mockMatchedCityId = "us-ca-san_francisco"
    }
    
    func configureForNYCPattern() {
        mockText = "1234567890"
        mockConfidence = 0.92
        mockMatchedCityId = "us-ny-new_york"
    }
    
    func configureForNoMatch() {
        mockText = "UNKNOWN123"
        mockConfidence = 0.45
        mockMatchedCityId = nil
    }
    
    func configureForLowConfidence() {
        shouldReturnLowConfidence = true
        mockConfidence = 0.40
    }
}

// MARK: - OCR Engine Protocol

/// Protocol defining OCR engine interface for dependency injection
public protocol OCREngineProtocol {
    func recognizeText(imageData: Data, configuration: OCRConfiguration) async throws -> OCRRecognitionResult
    func recognizeWithHighAccuracy(imageData: Data) async throws -> OCRRecognitionResult
    func recognizeFast(imageData: Data) async throws -> OCRRecognitionResult
}

// MARK: - OCR Configuration

/// Configuration for OCR processing
public struct OCRConfiguration {
    public var recognitionLevel: RecognitionLevel = .accurate
    public var usesLanguageCorrection: Bool = true
    public var recognitionLanguages: [String] = ["en"]
    public var autoDetectLanguage: Bool = false
    
    public init() {}
    
    public enum RecognitionLevel {
        case fast
        case accurate
    }
}

// MARK: - OCR Result

/// Result from OCR processing
public struct OCRRecognitionResult {
    public let text: String
    public let observations: [VNRecognizedTextObservation]
    public let confidence: Double
    public let processingTime: Double
    public let matchedCityId: String?
}

// MARK: - OCR Error

public enum OCRError: LocalizedError {
    case recognitionFailed
    case invalidImage
    case unsupportedLanguage
    
    public var errorDescription: String? {
        switch self {
        case .recognitionFailed:
            return "Text recognition failed"
        case .invalidImage:
            return "Invalid image data"
        case .unsupportedLanguage:
            return "Unsupported language"
        }
    }
}

// MARK: - Mock Observation

/// Mock observation for testing
class MockObservation: VNRecognizedTextObservation {
    var mockText: String
    var mockConfidence: Float
    var mockCandidates: [MockRecognizedText] = []
    var topCandidatesCount: Int = 1
    
    init(text: String, confidence: Float, topCandidatesCount: Int = 1) {
        self.mockText = text
        self.mockConfidence = confidence
        self.topCandidatesCount = topCandidatesCount
        super.init(topCandidates: 1)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func topCandidates(_ maxCandidatesCount: Int) -> [VNRecognizedText] {
        return mockCandidates.prefix(maxCandidatesCount).map { $0 }
    }
}

// MARK: - Mock Recognized Text

class MockRecognizedText: VNRecognizedText {
    private let mockString: String
    private let mockConfidence: Float
    
    init(string: String, confidence: Float) {
        self.mockString = string
        self.mockConfidence = confidence
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var string: String { mockString }
    override var confidence: Float { mockConfidence }
}
```

## find_proton_pdf.rs
```
use std::env;
use std::path::{Path, PathBuf};
use walkdir::WalkDir;

fn main() {
    // Get home directory - try both current user and evan user
    let current_home = env::var("HOME").unwrap_or_else(|_| "/root".to_string());
    let evan_home = PathBuf::from("/home/evan");
    
    let downloads_paths = vec![
        PathBuf::from(&current_home).join("Downloads"),
        evan_home.join("Downloads"),
        PathBuf::from("/root/Downloads"),
    ];
    
    let target_filename = "proton-recovery-kit.pdf";
    
    println!("Searching for '{}'...", target_filename);
    println!("Excluding Downloads folders:");
    for path in &downloads_paths {
        println!("  - {}", path.display());
    }
    println!();
    
    let mut found_files = Vec::new();
    let mut errors = Vec::new();
    
    // Search from root directory (/)
    let root = Path::new("/");
    
    println!("Scanning filesystem (this may take a while)...");
    
    for entry in WalkDir::new(root)
        .follow_links(false)
        .into_iter()
        .filter_entry(|e| {
            // Skip common system directories that we don't need to search
            let path = e.path();
            let path_str = path.to_string_lossy();
            
            // Skip system directories that are unlikely to contain user files
            !path_str.contains("/proc") &&
            !path_str.contains("/sys") &&
            !path_str.contains("/dev") &&
            !path_str.contains("/run") &&
            !path_str.contains("/tmp") &&
            !path_str.contains("/var/cache") &&
            !path_str.contains("/var/tmp")
        })
    {
        match entry {
            Ok(entry) => {
                let path = entry.path();
                
                // Check if this is the target file
                if path.is_file() {
                    if let Some(filename) = path.file_name() {
                        if filename == target_filename {
                            // Check if it's NOT in any Downloads folder
                            let is_in_downloads = downloads_paths.iter().any(|downloads_path| {
                                path.starts_with(downloads_path)
                            });
                            
                            if !is_in_downloads {
                                found_files.push(path.to_path_buf());
                            }
                        }
                    }
                }
            }
            Err(e) => {
                // Store errors but continue searching
                errors.push(e);
            }
        }
    }
    
    println!();
    println!("Search complete!");
    println!();
    
    if found_files.is_empty() {
        println!("No other instances of '{}' found (excluding Downloads folder).", target_filename);
    } else {
        println!("Found {} instance(s) of '{}' (excluding Downloads):", found_files.len(), target_filename);
        println!();
        for (i, file) in found_files.iter().enumerate() {
            println!("{}. {}", i + 1, file.display());
            
            // Try to get file metadata
            if let Ok(metadata) = std::fs::metadata(file) {
                println!("   Size: {} bytes", metadata.len());
                if let Ok(modified) = metadata.modified() {
                    if let Ok(datetime) = modified.duration_since(std::time::UNIX_EPOCH) {
                        println!("   Modified: {} seconds since epoch", datetime.as_secs());
                    }
                }
            }
            println!();
        }
    }
    
    if !errors.is_empty() {
        eprintln!("Note: {} errors encountered during search (likely permission denied)", errors.len());
    }
}
```

## decrypt_chrome_cookies.py
```
#!/usr/bin/env python3
import sqlite3
import json
import base64
import os
from cryptography.algorithm import AES
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
from cryptography.hazmat.backends import default_backend
import subprocess

COOKIES_DB = "/home/evan/.var/app/com.google.Chrome/config/google-chrome/Default/Cookies"

def get_chrome_key():
    """Get Chrome's encryption key from the system keyring"""
    try:
        # Try to get key from keyring
        result = subprocess.run(
            ['secret-tool', 'lookup', 'application', 'chrome'],
            capture_output=True,
            text=True
        )
        if result.returncode == 0:
            return result.stdout.strip().encode()
    except:
        pass
    
    # Alternative: try to get from Chrome's Local State
    local_state_path = "/home/evan/.var/app/com.google.Chrome/config/google-chrome/Local State"
    if os.path.exists(local_state_path):
        try:
            with open(local_state_path, 'r') as f:
                local_state = json.load(f)
                encrypted_key = local_state.get('os_crypt', {}).get('encrypted_key', '')
                if encrypted_key:
                    # Decode base64
                    encrypted_key = base64.b64decode(encrypted_key)
                    # Remove 'DPAPI' prefix (Windows) or use Linux keyring
                    if encrypted_key.startswith(b'DPAPI'):
                        encrypted_key = encrypted_key[5:]
                    return encrypted_key
        except:
            pass
    
    return None

def decrypt_cookie_value(encrypted_value, key=None):
    """Decrypt Chrome cookie value"""
    if not encrypted_value:
        return ""
    
    try:
        # Chrome on Linux uses different encryption
        # Try direct access first
        if encrypted_value.startswith(b'v10') or encrypted_value.startswith(b'v11'):
            # This is Chrome's encrypted format
            # We'd need the key from keyring
            return "[ENCRYPTED - Need keyring access]"
        else:
            return encrypted_value.decode('utf-8', errors='ignore')
    except:
        return "[DECRYPTION FAILED]"

conn = sqlite3.connect(COOKIES_DB)
conn.row_factory = sqlite3.Row
cursor = conn.cursor()

print("=== DECRYPTING PROTON COOKIES ===\n")

# Get Proton cookies
cursor.execute("""
    SELECT host_key, name, value, path, expires_utc, is_secure, is_httponly
    FROM cookies 
    WHERE host_key LIKE '%proton%'
    ORDER BY host_key, name
""")

cookies = cursor.fetchall()

if cookies:
    print(f"Found {len(cookies)} Proton cookies\n")
    
    # Focus on session cookies
    session_cookies = {}
    for cookie in cookies:
        name = cookie['name']
        if 'AUTH' in name or 'REFRESH' in name or 'Session' in name:
            domain = cookie['host_key']
            if domain not in session_cookies:
                session_cookies[domain] = []
            
            value = cookie['value']
            decrypted = decrypt_cookie_value(value)
            
            session_cookies[domain].append({
                'name': name,
                'value': decrypted if decrypted else value[:50] if value else "[EMPTY]",
                'path': cookie['path']
            })
    
    print("🔑 SESSION COOKIES (for restoring login):\n")
    for domain, cookies_list in session_cookies.items():
        print(f"📍 {domain}:")
        for cookie in cookies_list:
            print(f"  {cookie['name']}: {cookie['value']}")
            print(f"    Path: {cookie['path']}")
        print()
    
    # Also try to read raw values
    print("\n📋 ALL PROTON COOKIES (Raw):\n")
    for cookie in cookies[:10]:  # First 10
        value_preview = cookie['value'][:80] if cookie['value'] else "[EMPTY]"
        print(f"{cookie['host_key']} | {cookie['name']}: {value_preview}")
    
    print("\n\n💡 TO RESTORE SESSION:")
    print("1. Open Chrome")
    print("2. Go to https://pass.proton.me")
    print("3. Open Developer Tools (F12)")
    print("4. Go to Application > Cookies > https://pass.proton.me")
    print("5. Manually add the cookies above if session expired")
    print("\nOR try opening https://pass.proton.me directly - you might still be logged in!")
    
else:
    print("❌ No Proton cookies found!")

conn.close()
```

## extract_proton_cookies.py
```
#!/usr/bin/env python3
import sqlite3
import json
import os

COOKIES_DB = "/home/evan/.var/app/com.google.Chrome/config/google-chrome/Default/Cookies"

if not os.path.exists(COOKIES_DB):
    print("❌ Cookies database not found!")
    exit(1)

conn = sqlite3.connect(COOKIES_DB)
cursor = conn.cursor()

print("=== PROTON SESSION COOKIES ===\n")

# Get all Proton cookies
cursor.execute("""
    SELECT host_key, name, value, path, expires_utc, is_secure, is_httponly
    FROM cookies 
    WHERE host_key LIKE '%proton%'
    ORDER BY host_key, name
""")

cookies = cursor.fetchall()

if cookies:
    print("Found {} Proton cookies:\n".format(len(cookies)))
    
    # Group by domain
    domains = {}
    for cookie in cookies:
        domain = cookie[0]
        if domain not in domains:
            domains[domain] = []
        domains[domain].append(cookie)
    
    # Print cookies that might give session access
    important_cookies = ['AUTH', 'REFRESH', 'Session-Id', 'connect.sid']
    
    for domain, domain_cookies in domains.items():
        print(f"\n📍 {domain}:")
        for cookie in domain_cookies:
            name = cookie[1]
            value = cookie[2]
            if name in important_cookies or len(value) > 20:
                print(f"  {name}: {value[:50]}..." if len(value) > 50 else f"  {name}: {value}")
    
    # Create browser extension format
    print("\n\n=== TO USE IN BROWSER ===")
    print("Install 'EditThisCookie' or 'Cookie-Editor' extension")
    print("Then import these cookies manually, or:")
    print("\nOr use this JavaScript in browser console:")
    print("\n// Run this on account.proton.me:")
    for cookie in cookies:
        if cookie[0] == 'account.proton.me' and cookie[1] in ['AUTH', 'REFRESH']:
            print(f"document.cookie = '{cookie[1]}={cookie[2]}; path={cookie[3]}; domain={cookie[0]}';")
    
    # Save to file
    with open('/tmp/proton_cookies.json', 'w') as f:
        cookie_list = []
        for cookie in cookies:
            cookie_list.append({
                'domain': cookie[0],
                'name': cookie[1],
                'value': cookie[2],
                'path': cookie[3]
            })
        json.dump(cookie_list, f, indent=2)
    
    print(f"\n✅ Cookies saved to: /tmp/proton_cookies.json")
else:
    print("❌ No Proton cookies found!")

conn.close()
```

## extract_proton_creds.sh
```
#!/bin/bash

CHROME_DATA="/home/evan/.var/app/com.google.Chrome/config/google-chrome/Default"
PROTON_PASS_DATA="/home/evan/.config/Proton Pass/Partitions/app"

echo "=== EXTRACTING PROTON CREDENTIALS ==="
echo ""

# Check if Chrome is running
if pgrep -f "chrome|chromium" > /dev/null; then
    echo "⚠️  Chrome is running. Please close Chrome first, then run this script again."
    echo "   Or run: pkill chrome"
    exit 1
fi

# Copy Login Data to temp location (Chrome locks it)
TEMP_LOGIN="/tmp/chrome_login_data_$$"
cp "$CHROME_DATA/Login Data" "$TEMP_LOGIN" 2>/dev/null

if [ -f "$TEMP_LOGIN" ]; then
    echo "📋 PROTON LOGIN CREDENTIALS:"
    sqlite3 "$TEMP_LOGIN" "SELECT origin_url, username_value FROM logins WHERE origin_url LIKE '%proton%';" 2>/dev/null
    echo ""
    rm -f "$TEMP_LOGIN"
else
    echo "❌ Could not access Login Data"
fi

# Check Cookies for Proton sessions
echo "🍪 PROTON COOKIES (Active Sessions):"
sqlite3 "$CHROME_DATA/Cookies" "SELECT host_key, name, value FROM cookies WHERE host_key LIKE '%proton%' LIMIT 20;" 2>/dev/null
echo ""

# Check Proton Pass Local Storage
echo "📝 PROTON PASS LOCAL STORAGE:"
if [ -d "$PROTON_PASS_DATA/Local Storage" ]; then
    find "$PROTON_PASS_DATA/Local Storage" -type f -name "*proton*" -exec echo "Found: {}" \;
fi
echo ""

# Check Proton Pass IndexedDB (might contain notes!)
echo "🗄️  PROTON PASS INDEXEDDB (May contain your notes!):"
if [ -d "$PROTON_PASS_DATA/IndexedDB" ]; then
    find "$PROTON_PASS_DATA/IndexedDB" -type f | head -10
    echo ""
    echo "Checking for note/recovery data..."
    find "$PROTON_PASS_DATA/IndexedDB" -type f -exec grep -l "recovery\|12 words\|seed\|backup" {} \; 2>/dev/null | head -5
fi
echo ""

# Check Session Storage
echo "💾 PROTON PASS SESSION STORAGE:"
if [ -d "$PROTON_PASS_DATA/Session Storage" ]; then
    find "$PROTON_PASS_DATA/Session Storage" -type f | head -5
fi

echo ""
echo "=== DONE ==="
```

## get_proton_session.sh
```
#!/bin/bash

echo "=== EXTRACTING PROTON SESSION DATA ==="
echo ""

COOKIES_DB="/home/evan/.var/app/com.google.Chrome/config/google-chrome/Default/Cookies"
LOGIN_DB="/home/evan/.var/app/com.google.Chrome/config/google-chrome/Default/Login Data"

# Extract cookies
echo "🍪 PROTON COOKIES (Full Values):"
sqlite3 "$COOKIES_DB" <<EOF
.mode column
.headers on
SELECT host_key, name, substr(value, 1, 100) as value_preview, 
       datetime(expires_utc/1000000-11644473600, 'unixepoch') as expires
FROM cookies 
WHERE host_key LIKE '%proton%' 
ORDER BY host_key, name;
EOF

echo ""
echo "📋 PROTON LOGIN CREDENTIALS:"
if [ -f "$LOGIN_DB" ]; then
    cp "$LOGIN_DB" /tmp/login_temp.db 2>/dev/null
    sqlite3 /tmp/login_temp.db <<EOF
.mode column
.headers on
SELECT origin_url, username_value 
FROM logins 
WHERE origin_url LIKE '%proton%';
EOF
    rm -f /tmp/login_temp.db
else
    echo "Login Data file not accessible"
fi

echo ""
echo "=== IMPORTANT COOKIES TO RESTORE SESSION ==="
echo ""
echo "To restore your session, you need these cookies:"
sqlite3 "$COOKIES_DB" <<EOF
SELECT 'Cookie: ' || name || '=' || value || '; Domain=' || host_key || '; Path=' || path
FROM cookies 
WHERE host_key LIKE '%proton%' 
  AND (name LIKE '%AUTH%' OR name LIKE '%REFRESH%' OR name LIKE '%Session%')
ORDER BY host_key;
EOF
```

## Scripts/mac-setup.sh
```
#!/bin/bash

# Mac Setup Script - Run this first on your rented Mac
# This script sets up everything needed for iOS development

set -e  # Exit on error

echo "🚀 FightCityTickets Mac Setup Script"
echo "======================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print status
print_status() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# Check macOS version
echo "Checking macOS version..."
MACOS_VERSION=$(sw_vers -productVersion)
echo "macOS Version: $MACOS_VERSION"

if [[ $(echo "$MACOS_VERSION 13.0" | awk '{print ($1 >= $2)}') == 1 ]]; then
    print_status "macOS version is compatible"
else
    print_error "macOS 13.0+ required. Current: $MACOS_VERSION"
    exit 1
fi

# Check Xcode
echo ""
echo "Checking Xcode installation..."
if command -v xcodebuild &> /dev/null; then
    XCODE_VERSION=$(xcodebuild -version | head -n 1)
    print_status "Xcode found: $XCODE_VERSION"
    
    # Check if license accepted
    if xcodebuild -checkFirstLaunchStatus 2>&1 | grep -q "requires admin privileges"; then
        print_warning "Xcode license needs to be accepted"
        echo "Run: sudo xcodebuild -license accept"
    else
        print_status "Xcode license accepted"
    fi
else
    print_error "Xcode not found. Please install Xcode from App Store."
    exit 1
fi

# Install Homebrew if not installed
echo ""
echo "Checking Homebrew..."
if command -v brew &> /dev/null; then
    print_status "Homebrew installed"
    BREW_VERSION=$(brew --version | head -n 1)
    echo "  Version: $BREW_VERSION"
else
    print_warning "Homebrew not found. Installing..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    print_status "Homebrew installed"
fi

# Update Homebrew
echo ""
echo "Updating Homebrew..."
brew update

# Install XcodeGen
echo ""
echo "Checking XcodeGen..."
if command -v xcodegen &> /dev/null; then
    XCODEGEN_VERSION=$(xcodegen --version)
    print_status "XcodeGen installed: $XCODEGEN_VERSION"
else
    print_warning "XcodeGen not found. Installing..."
    brew install xcodegen
    print_status "XcodeGen installed"
fi

# Install SwiftLint
echo ""
echo "Checking SwiftLint..."
if command -v swiftlint &> /dev/null; then
    SWIFTLINT_VERSION=$(swiftlint version)
    print_status "SwiftLint installed: $SWIFTLINT_VERSION"
else
    print_warning "SwiftLint not found. Installing..."
    brew install swiftlint
    print_status "SwiftLint installed"
fi

# Check Git
echo ""
echo "Checking Git..."
if command -v git &> /dev/null; then
    GIT_VERSION=$(git --version)
    print_status "Git installed: $GIT_VERSION"
else
    print_error "Git not found. Please install Git."
    exit 1
fi

# Check if project exists
echo ""
echo "Checking project files..."
if [ -f "project.yml" ]; then
    print_status "project.yml found"
else
    print_error "project.yml not found. Are you in the project directory?"
    exit 1
fi

# Generate Xcode project using foolproof script
echo ""
echo "Setting up Xcode project (foolproof)..."
if [ -f "Scripts/xcode-setup.sh" ]; then
    chmod +x Scripts/xcode-setup.sh
    ./Scripts/xcode-setup.sh
else
    # Fallback to basic xcodegen
    echo "Using basic xcodegen (xcode-setup.sh not found)..."
    if xcodegen generate; then
        print_status "Xcode project generated successfully"
    else
        print_error "Failed to generate Xcode project"
        exit 1
    fi
    
    if [ -d "FightCityTickets.xcodeproj" ]; then
        print_status "Xcode project created: FightCityTickets.xcodeproj"
    else
        print_error "Xcode project not found after generation"
        exit 1
    fi
fi

# Run SwiftLint
echo ""
echo "Running SwiftLint..."
if swiftlint lint --quiet; then
    print_status "SwiftLint passed"
else
    print_warning "SwiftLint found issues. Run 'swiftlint lint' to see details."
    print_warning "Run 'swiftlint lint --fix' to auto-fix issues."
fi

# Summary
echo ""
echo "======================================"
echo "✅ Setup Complete!"
echo ""
echo "Next steps:"
echo "1. Open FightCityTickets.xcodeproj in Xcode"
echo "2. Select your development team in Signing & Capabilities"
echo "3. Build the project (Cmd+B)"
echo "4. Run in Simulator (Cmd+R)"
echo ""
echo "For detailed instructions, see MAC_DAY_CHECKLIST.md"
echo "======================================"
```

## Scripts/xcode-setup.sh
```
#!/bin/bash
# Foolproof Xcode Setup Script
# This script validates, generates, and verifies Xcode project setup
# Run this after project reorganization to ensure Xcode is perfectly configured

set -e

echo "🚀 FightCityTickets Xcode Setup - Foolproof Edition"
echo "===================================================="
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Step 1: Validate project.yml
echo -e "${BLUE}Step 1:${NC} Validating project.yml..."
if ! command -v xcodegen &> /dev/null; then
    echo -e "${YELLOW}⚠${NC} XcodeGen not installed. Installing..."
    if command -v brew &> /dev/null; then
        brew install xcodegen
    else
        echo -e "${RED}✗${NC} Homebrew not found. Please install XcodeGen manually:"
        echo "  brew install xcodegen"
        exit 1
    fi
fi

if [ ! -f "project.yml" ]; then
    echo -e "${RED}✗${NC} project.yml not found!"
    echo "Make sure you're in the project root directory."
    exit 1
fi

# Validate YAML syntax by attempting dry-run
echo "Validating project.yml syntax..."
if xcodegen generate --dry-run > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} project.yml syntax is valid"
else
    echo -e "${YELLOW}⚠${NC} Validating project.yml (may show warnings)..."
    xcodegen generate --dry-run || true
fi
echo ""

# Step 2: Generate Xcode project
echo -e "${BLUE}Step 2:${NC} Generating Xcode project..."
if [ -d "FightCityTickets.xcodeproj" ]; then
    echo "Removing existing project..."
    rm -rf FightCityTickets.xcodeproj
fi

if xcodegen generate; then
    echo -e "${GREEN}✓${NC} Xcode project generated successfully"
else
    echo -e "${RED}✗${NC} Failed to generate Xcode project"
    echo "Check project.yml for errors."
    exit 1
fi
echo ""

# Step 3: Verify project structure
echo -e "${BLUE}Step 3:${NC} Verifying project structure..."
if [ ! -d "FightCityTickets.xcodeproj" ]; then
    echo -e "${RED}✗${NC} Xcode project not created!"
    exit 1
fi

# Check for required targets
echo "Checking targets..."
TARGETS=("FightCity" "FightCityiOS" "FightCityFoundation")
MISSING_TARGETS=()

for target in "${TARGETS[@]}"; do
    if xcodebuild -list -project FightCityTickets.xcodeproj 2>/dev/null | grep -q "$target"; then
        echo -e "${GREEN}✓${NC} Target '$target' found"
    else
        echo -e "${RED}✗${NC} Target '$target' not found!"
        MISSING_TARGETS+=("$target")
    fi
done

if [ ${#MISSING_TARGETS[@]} -gt 0 ]; then
    echo -e "${RED}✗${NC} Missing targets: ${MISSING_TARGETS[*]}"
    echo "Check project.yml target definitions."
    exit 1
fi
echo ""

# Step 4: Verify source files exist
echo -e "${BLUE}Step 4:${NC} Verifying source files..."
SOURCE_DIRS=("Sources/FightCity" "Sources/FightCityiOS" "Sources/FightCityFoundation")
MISSING_DIRS=()

for dir in "${SOURCE_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        FILE_COUNT=$(find "$dir" -name "*.swift" 2>/dev/null | wc -l | tr -d ' ')
        if [ "$FILE_COUNT" -gt 0 ]; then
            echo -e "${GREEN}✓${NC} $dir ($FILE_COUNT Swift files)"
        else
            echo -e "${YELLOW}⚠${NC} $dir exists but has no Swift files yet"
        fi
    else
        echo -e "${YELLOW}⚠${NC} $dir not found (will be created during migration)"
        MISSING_DIRS+=("$dir")
    fi
done
echo ""

# Step 5: Check Xcode installation
echo -e "${BLUE}Step 5:${NC} Checking Xcode installation..."
if ! command -v xcodebuild &> /dev/null; then
    echo -e "${RED}✗${NC} Xcode not installed or command line tools missing"
    echo "Install Xcode from App Store, then run:"
    echo "  sudo xcodebuild -license accept"
    exit 1
fi

XCODE_VERSION=$(xcodebuild -version | head -n 1)
echo -e "${GREEN}✓${NC} $XCODE_VERSION installed"

# Check license
if xcodebuild -checkFirstLaunchStatus 2>&1 | grep -q "requires admin"; then
    echo -e "${YELLOW}⚠${NC} Xcode license needs acceptance"
    echo "Run: sudo xcodebuild -license accept"
else
    echo -e "${GREEN}✓${NC} Xcode license accepted"
fi
echo ""

# Step 6: Test project configuration
echo -e "${BLUE}Step 6:${NC} Testing project configuration..."
echo "Checking build settings..."

# Check if we can list schemes
if xcodebuild -list -project FightCityTickets.xcodeproj > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Project configuration is valid"
    
    # List all schemes
    echo ""
    echo "Available schemes:"
    xcodebuild -list -project FightCityTickets.xcodeproj | grep -A 10 "Schemes:" | tail -n +2 | sed 's/^/  /'
else
    echo -e "${YELLOW}⚠${NC} Could not list schemes (sources may not exist yet)"
fi
echo ""

# Step 7: Check for common issues
echo -e "${BLUE}Step 7:${NC} Checking for common issues..."

# Check Swift version
SWIFT_VERSION=$(xcodebuild -project FightCityTickets.xcodeproj -showBuildSettings -target FightCity 2>/dev/null | grep "SWIFT_VERSION" | head -n 1 | awk '{print $3}')
if [ -n "$SWIFT_VERSION" ]; then
    echo -e "${GREEN}✓${NC} Swift version: $SWIFT_VERSION"
else
    echo -e "${YELLOW}⚠${NC} Could not determine Swift version"
fi

# Check deployment target
DEPLOYMENT_TARGET=$(xcodebuild -project FightCityTickets.xcodeproj -showBuildSettings -target FightCity 2>/dev/null | grep "IPHONEOS_DEPLOYMENT_TARGET" | head -n 1 | awk '{print $3}')
if [ -n "$DEPLOYMENT_TARGET" ]; then
    echo -e "${GREEN}✓${NC} Deployment target: iOS $DEPLOYMENT_TARGET"
else
    echo -e "${YELLOW}⚠${NC} Could not determine deployment target"
fi
echo ""

# Step 8: Open in Xcode
echo -e "${BLUE}Step 8:${NC} Opening in Xcode..."
if command -v open &> /dev/null; then
    open FightCityTickets.xcodeproj
    echo -e "${GREEN}✓${NC} Project opened in Xcode"
else
    echo -e "${YELLOW}⚠${NC} Could not open Xcode (not on macOS?)"
    echo "Manually open: FightCityTickets.xcodeproj"
fi
echo ""

# Final instructions
echo "===================================================="
echo -e "${GREEN}✅ Xcode Setup Complete!${NC}"
echo ""
echo "Next steps in Xcode:"
echo "1. Select your development team:"
echo "   - Click project → Signing & Capabilities"
echo "   - Select your team from dropdown"
echo "   - Enable 'Automatically manage signing'"
echo ""
echo "2. Build the project:"
echo "   - Press Cmd+B or Product → Build"
echo ""
echo "3. Run in Simulator:"
echo "   - Select iPhone 15 Simulator"
echo "   - Press Cmd+R or Product → Run"
echo ""
echo "If you see any errors:"
echo "- Check 'Common Xcode Issues' section in plan"
echo "- Run: xcodebuild clean"
echo "- Run: xcodegen generate"
echo "- Run this script again: ./Scripts/xcode-setup.sh"
echo ""
echo "For detailed troubleshooting, see:"
echo "- MAC_DAY_CHECKLIST.md"
echo "- Repository reorganization plan"
echo "===================================================="
```

## Cargo.toml
```
[package]
name = "find_proton_pdf"
version = "0.1.0"
edition = "2021"

[[bin]]
name = "find_proton_pdf"
path = "find_proton_pdf.rs"

[dependencies]
walkdir = "2.4"
```

## project.yml
```
name: FightCityTickets
options:
  bundleIdPrefix: com.fightcitytickets
  deploymentTarget:
    iOS: "16.0"
  xcodeVersion: "15.0"
  generateEmptyDirectories: true
  groupSortPosition: top
  developmentLanguage: en
  defaultConfig: Debug
  xcodeVersion: '15.0'
  groupSortPosition: top
  createIntermediateGroups: true

settings:
  base:
    SWIFT_VERSION: "5.9"
    SWIFT_OPTIMIZATION_LEVEL: -Onone
    SWIFT_ACTIVE_COMPILATION_CONDITIONS: DEBUG
    GCC_OPTIMIZATION_LEVEL: 0
    ENABLE_BITCODE: NO
    ENABLE_TESTABILITY: YES
    CODE_SIGN_STYLE: Automatic
    DEVELOPMENT_TEAM: ""
    IPHONEOS_DEPLOYMENT_TARGET: "16.0"
    TARGETED_DEVICE_FAMILY: "1,2"
    SUPPORTS_MACCATALYST: NO
    SUPPORTS_MAC_DESIGNED_FOR_IPHONE_IPAD: YES

configs:
  Debug:
    SWIFT_OPTIMIZATION_LEVEL: -Onone
    SWIFT_ACTIVE_COMPILATION_CONDITIONS: DEBUG
    GCC_OPTIMIZATION_LEVEL: 0
  Release:
    SWIFT_OPTIMIZATION_LEVEL: -O
    GCC_OPTIMIZATION_LEVEL: s

targets:
  # ============================================
  # FightCityFoundation Framework (Pure Swift)
  # ============================================
  FightCityFoundation:
    type: framework
    platform: iOS
    deploymentTarget: "16.0"
    sources:
      - path: Sources/FightCityFoundation
        excludes:
          - "**/.DS_Store"
    settings:
      base:
        PRODUCT_BUNDLE_IDENTIFIER: com.fightcitytickets.foundation
        PRODUCT_NAME: FightCityFoundation
        DEFINES_MODULE: YES
        SWIFT_VERSION: "5.9"
        ENABLE_TESTABILITY: YES
        CODE_SIGN_STYLE: Automatic
        APPLICATION_EXTENSION_API_ONLY: YES
    frameworks:
      - Foundation
      - Security
    info:
      path: Support/FightCityFoundation-Info.plist
      properties:
        CFBundleName: $(PRODUCT_NAME)
        CFBundlePackageType: FMWK
        CFBundleShortVersionString: "1.0"
        CFBundleVersion: "1"
        CFBundleIdentifier: $(PRODUCT_BUNDLE_IDENTIFIER)
        CFBundleExecutable: $(EXECUTABLE_NAME)
        NSPrincipalClass: ""

  # ============================================
  # FightCityiOS Framework (iOS-Specific)
  # ============================================
  FightCityiOS:
    type: framework
    platform: iOS
    deploymentTarget: "16.0"
    sources:
      - path: Sources/FightCityiOS
        excludes:
          - "**/.DS_Store"
    dependencies:
      - target: FightCityFoundation
    settings:
      base:
        PRODUCT_BUNDLE_IDENTIFIER: com.fightcitytickets.ios
        PRODUCT_NAME: FightCityiOS
        DEFINES_MODULE: YES
        SWIFT_VERSION: "5.9"
        ENABLE_TESTABILITY: YES
        CODE_SIGN_STYLE: Automatic
        APPLICATION_EXTENSION_API_ONLY: YES
    frameworks:
      - Foundation
      - UIKit
      - AVFoundation
      - Vision
      - CoreImage
      - Security
    info:
      path: Support/FightCityiOS-Info.plist
      properties:
        CFBundleName: $(PRODUCT_NAME)
        CFBundlePackageType: FMWK
        CFBundleShortVersionString: "1.0"
        CFBundleVersion: "1"
        CFBundleIdentifier: $(PRODUCT_BUNDLE_IDENTIFIER)
        CFBundleExecutable: $(EXECUTABLE_NAME)
        NSPrincipalClass: ""

  # ============================================
  # FightCity App (Main Application)
  # ============================================
  FightCity:
    type: application
    platform: iOS
    deploymentTarget: "16.0"
    sources:
      - path: Sources/FightCity
        excludes:
          - "**/.DS_Store"
      - path: Resources
        excludes:
          - "**/.DS_Store"
    dependencies:
      - target: FightCityiOS
      - target: FightCityFoundation
    settings:
      base:
        PRODUCT_BUNDLE_IDENTIFIER: com.fightcitytickets.app
        PRODUCT_NAME: FightCityTickets
        ASSETCATALOG_COMPILER_APPICON_NAME: AppIcon
        ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME: AccentColor
        INFOPLIST_FILE: Resources/Info.plist
        INFOPLIST_PREPROCESS: YES
        GENERATE_INFOPLIST_FILE: NO
        SWIFT_VERSION: "5.9"
        SWIFT_EMIT_LOC_STRINGS: YES
        ENABLE_TESTABILITY: YES
        CODE_SIGN_STYLE: Automatic
        DEVELOPMENT_TEAM: ""
        IPHONEOS_DEPLOYMENT_TARGET: "16.0"
        TARGETED_DEVICE_FAMILY: "1,2"
        SUPPORTS_MACCATALYST: NO
        LD_RUNPATH_SEARCH_PATHS: "$(inherited) @executable_path/Frameworks"
    frameworks:
      - Foundation
      - SwiftUI
      - UIKit
      - AVFoundation
      - Vision
      - CoreImage
      - Security
      - BackgroundTasks
    capabilities:
      - Background Modes:
          - Background processing
          - Background fetch
    info:
      path: Resources/Info.plist
      properties:
        CFBundleName: FightCityTickets
        CFBundleDisplayName: FightCityTickets
        CFBundleIdentifier: $(PRODUCT_BUNDLE_IDENTIFIER)
        CFBundleVersion: "1"
        CFBundleShortVersionString: "1.0"
        CFBundlePackageType: APPL
        CFBundleExecutable: $(EXECUTABLE_NAME)
        CFBundleInfoDictionaryVersion: "6.0"
        CFBundleDevelopmentRegion: en
        CFBundleSupportedPlatforms:
          - iPhoneOS
        LSRequiresIPhoneOS: YES
        UIRequiredDeviceCapabilities:
          - armv7
        UISupportedInterfaceOrientations:
          - UIInterfaceOrientationPortrait
        UISupportedInterfaceOrientations~ipad:
          - UIInterfaceOrientationPortrait
          - UIInterfaceOrientationPortraitUpsideDown
          - UIInterfaceOrientationLandscapeLeft
          - UIInterfaceOrientationLandscapeRight
        UIApplicationSceneManifest:
          UIApplicationSupportsMultipleScenes: false
          UISceneConfigurations:
            UIWindowSceneSessionRoleApplication:
              - UISceneConfigurationName: Default Configuration
                UISceneDelegateClassName: $(PRODUCT_MODULE_NAME).SceneDelegate
        NSCameraUsageDescription: "FightCityTickets needs camera access to scan parking ticket citation numbers."
        NSPhotoLibraryUsageDescription: "FightCityTickets needs photo library access to import ticket photos."
        NSPhotoLibraryAddUsageDescription: "FightCityTickets needs photo library access to save captured ticket images."
        BGTaskSchedulerPermittedIdentifiers:
          - com.fightcitytickets.telemetry-upload
        ITSAppUsesNonExemptEncryption: NO
        UIApplicationSupportsIndirectInputEvents: YES
        UILaunchScreen:
          UIColorName: AccentColor
          UIImageName: ""

  # ============================================
  # Test Targets
  # ============================================
  FightCityFoundationTests:
    type: bundle.unit-test
    platform: iOS
    sources:
      - path: Tests/UnitTests/FoundationTests
    dependencies:
      - target: FightCityFoundation
    settings:
      base:
        PRODUCT_BUNDLE_IDENTIFIER: com.fightcitytickets.foundation.tests
        PRODUCT_NAME: FightCityFoundationTests
        SWIFT_VERSION: "5.9"
        CODE_SIGN_STYLE: Automatic
        TEST_HOST: ""
        BUNDLE_LOADER: ""
    frameworks:
      - Foundation
      - XCTest

  FightCityiOSTests:
    type: bundle.unit-test
    platform: iOS
    sources:
      - path: Tests/UnitTests/iOSTests
    dependencies:
      - target: FightCityiOS
      - target: FightCityFoundation
    settings:
      base:
        PRODUCT_BUNDLE_IDENTIFIER: com.fightcitytickets.ios.tests
        PRODUCT_NAME: FightCityiOSTests
        SWIFT_VERSION: "5.9"
        CODE_SIGN_STYLE: Automatic
        TEST_HOST: ""
        BUNDLE_LOADER: ""
    frameworks:
      - Foundation
      - UIKit
      - XCTest
      - Vision
      - AVFoundation

  FightCityAppTests:
    type: bundle.unit-test
    platform: iOS
    sources:
      - path: Tests/UnitTests/AppTests
    dependencies:
      - target: FightCity
      - target: FightCityiOS
      - target: FightCityFoundation
    settings:
      base:
        PRODUCT_BUNDLE_IDENTIFIER: com.fightcitytickets.app.tests
        PRODUCT_NAME: FightCityAppTests
        SWIFT_VERSION: "5.9"
        CODE_SIGN_STYLE: Automatic
        TEST_HOST: "$(BUILT_PRODUCTS_DIR)/FightCity.app/FightCity"
        BUNDLE_LOADER: "$(TEST_HOST)"
    frameworks:
      - Foundation
      - SwiftUI
      - UIKit
      - XCTest

  FightCityUITests:
    type: bundle.ui-testing
    platform: iOS
    sources:
      - path: Tests/UITests
    dependencies:
      - target: FightCity
    settings:
      base:
        PRODUCT_BUNDLE_IDENTIFIER: com.fightcitytickets.app.uitests
        PRODUCT_NAME: FightCityUITests
        SWIFT_VERSION: "5.9"
        CODE_SIGN_STYLE: Automatic
        TEST_TARGET_NAME: FightCity
    frameworks:
      - Foundation
      - XCTest
      - XCTestUI
```

## Resources/Assets.xcassets/AccentColor.colorset/Contents.json
```
{
  "images" : [
    {
      "idiom" : "universal",
      "scale" : "1x"
    },
    {
      "idiom" : "universal",
      "scale" : "2x"
    },
    {
      "idiom" : "universal",
      "scale" : "3x"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
```

## Resources/Assets.xcassets/AppIcon.appiconset/Contents.json
```
{
  "images" : [
    {
      "idiom" : "universal",
      "scale" : "1x"
    },
    {
      "idiom" : "universal",
      "scale" : "2x"
    },
    {
      "idiom" : "universal",
      "scale" : "3x"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
```

## Resources/Assets.xcassets/Contents.json
```
{
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
```

## .swiftlint.yml
```
# FightCityTickets SwiftLint Configuration
# ==========================================

# ============================================
# Disabled Rules
# ============================================
disabled_rules:
  - trailing_whitespace
  - file_length
  - type_body_length

# ============================================
# Opt-in Rules (Enabled)
# ==========================================
opt_in_rules:
  # Style
  - closure_spacing
  - empty_count
  - explicit_init
  - force_unwrapping
  - implicitly_unwrapped_optional
  - operator_usage_whitespace
  - sorted_first_last
  - sorted_imports
  - static_operator
  - strong_iboutlet
  - unneeded_parentheses_in_closure_argument
  - vertical_parameter_alignment_on_call
  - yoda_condition
  
  # Best Practices
  - array_init
  - attributes
  - collective_closure
  - convenience_type
  - discouraged_object_literal
  - empty_string
  - enum_case_associated_values_count
  - fatal_error_message
  - first_where
  - for_where
  - identical_operands
  - last_where
  - modifier_order
  - multiline_arguments
  - multiline_function_chains
  - multiline_literal_brackets
  - nimble_operator
  - nslocalizedstring_key
  - optional_enum_case_matching
  - overridden_super_call
  - private_action
  - private_outlet
  - prohibited_super_call
  - redundant_nil_coalescing
  - redundant_type_annotation
  - single_test_class
  - strict_fileprivate
  - toggle_bool
  - unavailable_function
  - unowned_variable_capture
  - unused_declaration
  - unused_import
  - vertical_whitespace_opening_braces
  - vertical_whitespace_closing_braces
  - weak_delegate

# ============================================
# Excluded Paths
# ============================================
excluded:
  - ${PWD}/DerivedData
  - ${PWD}/.build
  - ${PWD}/Pods
  - ${PWD}/Tests/UITests
  - ${PWD}/Tests/UnitTests/iOSTests/Mocks
  - ${PWD}/Tests/UnitTests/FoundationTests/Mocks

# ============================================
# Rule Configurations
# ============================================

# Line Length
line_length:
  warning: 120
  error: 200
  ignores_function_declarations: true
  ignores_comments: true
  ignores_urls: true

# Function Body Length
function_body_length:
  warning: 50
  error: 100
  ignore_single_line_functions: true

# Type Body Length
type_body_length:
  warning: 300
  error: 500

# File Length
file_length:
  warning: 500
  error: 1000
  ignore_comment_only_lines: true

# Cyclomatic Complexity
cyclomatic_complexity:
  warning: 10
  error: 20
  ignores_statements: ["guard"]

# Identifier Name
identifier_name:
  min_length: 2
  max_length: 60
  excluded:
    - id
    - ok
    - no
    - x
    - y
    - z
    - i
    - j
    - k
    - e   # error
    - u   # url

# Type Name
type_name:
  min_length: 3
  max_length: 60
  excluded:
    - ID

# ============================================
# Custom Configuration by File Type
# ============================================

# Test files - more lenient
test_case_inlineable_class: true

# ============================================
# Swift Package Manager Support
# ============================================
reporter: "xcode"

# ============================================
# Custom Rules
# ============================================

custom_rules:
  # Ensure async functions are marked with async
  async_function_naming:
    name: "Async function naming"
    regex: 'func\s+\w+\s*\([^)]*\)\s*(?!async\s*\()throws?\s*->\s*(?:Void|())'
    message: "Async functions should be marked with 'async'"
    severity: error
    
  # Prefer @Published over willSet/didSet for properties
  published_property:
    name: "Use @Published for observable properties"
    regex: '(@Published\s+)?var\s+\w+:\s+\w+\s*\{(\s*willSet|get|set|\s*)\}'
    message: "Use @Published property wrapper instead of willSet/didSet"
    severity: warning
    
  # Ensure accessibility identifiers are set
  accessibility_identifier:
    name: "Accessibility identifier for UI elements"
    regex: '@State\s+private\s+var\s+.*Id:\s*String'
    message: "Consider adding an accessibilityIdentifier for UI testing"
    severity: warning
    
  # Prefer SwiftUI views to be internal or public
  view_modifier_order:
    name: "View modifier ordering"
    regex: '\.frame\(|\.padding\(|\.foregroundColor\(|\.background\(|\.cornerRadius\(|\.shadow\('
    message: "Consider grouping related modifiers together"
    severity: warning

# ============================================
# Legacy Swift (Swift 4) Support
# ============================================
legacy_hashing: error
legacy_objc_type: error
legacy_random: error

# ============================================
# Documentation Rules
# ============================================
private_declaration:
  severity: warning

# ============================================
# Performance Rules
# ============================================
reduce_into: error
yields: error
```

## Resources/Info.plist
```
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleDevelopmentRegion</key>
	<string>$(DEVELOPMENT_LANGUAGE)</string>
	<key>CFBundleDisplayName</key>
	<string>FightCityTickets</string>
	<key>CFBundleExecutable</key>
	<string>$(EXECUTABLE_NAME)</string>
	<key>CFBundleIdentifier</key>
	<string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
	<key>CFBundleInfoDictionaryVersion</key>
	<string>6.0</string>
	<key>CFBundleName</key>
	<string>$(PRODUCT_NAME)</string>
	<key>CFBundlePackageType</key>
	<string>$(PRODUCT_BUNDLE_PACKAGE_TYPE)</string>
	<key>CFBundleShortVersionString</key>
	<string>1.0</string>
	<key>CFBundleVersion</key>
	<string>1</string>
	<key>LSRequiresIPhoneOS</key>
	<true/>
	<key>NSCameraUsageDescription</key>
	<string>FightCityTickets needs camera access to scan parking ticket citation numbers.</string>
	<key>NSPhotoLibraryUsageDescription</key>
	<string>FightCityTickets needs photo library access to import ticket photos.</string>
	<key>UIApplicationSceneManifest</key>
	<dict>
		<key>UIApplicationSupportsMultipleScenes</key>
		<false/>
		<key>UISceneConfigurations</key>
		<dict>
			<key>UIWindowSceneSessionRoleApplication</key>
			<array>
				<dict>
					<key>UISceneConfigurationName</key>
					<string>Default Configuration</string>
					<key>UISceneDelegateClassName</key>
					<string>$(PRODUCT_MODULE_NAME).SceneDelegate</string>
				</dict>
			</array>
		</dict>
	</dict>
	<key>UILaunchScreen</key>
	<dict>
		<key>UIColorName</key>
		<string></string>
		<key>UIImageName</key>
		<string></string>
	</dict>
	<key>UIRequiredDeviceCapabilities</key>
	<array>
		<string>armv7</string>
	</array>
	<key>UISupportedInterfaceOrientations</key>
	<array>
		<string>UIInterfaceOrientationPortrait</string>
	</array>
	<key>UISupportedInterfaceOrientations~ipad</key>
	<array>
		<string>UIInterfaceOrientationPortrait</string>
		<string>UIInterfaceOrientationPortraitUpsideDown</string>
		<string>UIInterfaceOrientationLandscapeLeft</string>
		<string>UIInterfaceOrientationLandscapeRight</string>
	</array>
	<key>BGTaskSchedulerPermittedIdentifiers</key>
	<array>
		<string>com.fightcitytickets.telemetry-upload</string>
	</array>
</dict>
</plist>
```

