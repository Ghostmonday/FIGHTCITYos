//
//  AppConfig.swift
//  FightCityTickets
//
//  Build configuration and API endpoint settings
//

import Foundation

/// App configuration including API endpoints and build settings
final class AppConfig: ObservableObject {
    static let shared = AppConfig()
    
    // MARK: - API Configuration
    
    /// Base URL for the API - configurable for different environments
    @Published var apiBaseURL: URL
    
    /// API timeout interval in seconds
    let apiTimeout: TimeInterval = 30
    
    /// Number of retry attempts for failed requests
    let maxRetryAttempts: Int = 3
    
    /// Base URL for the web frontend (for deep links)
    @Published var webBaseURL: URL
    
    // MARK: - OCR Configuration
    
    /// Minimum confidence threshold for auto-accepting OCR results
    let ocrConfidenceThreshold: Double = 0.85
    
    /// Fallback confidence threshold requiring user review
    let ocrReviewThreshold: Double = 0.60
    
    /// Maximum image dimensions for OCR processing
    let ocrMaxImageDimension: CGFloat = 1920
    
    // MARK: - Telemetry Configuration
    
    /// Whether telemetry collection is enabled
    @Published var telemetryEnabled: Bool = false
    
    /// Maximum number of telemetry records to batch
    let telemetryBatchSize: Int = 50
    
    /// Maximum age of telemetry records before upload (24 hours)
    let telemetryMaxAge: TimeInterval = 86400
    
    // MARK: - Offline Configuration
    
    /// Maximum number of pending operations to queue
    let offlineQueueMaxSize: Int = 100
    
    /// Retry backoff multiplier
    let retryBackoffMultiplier: Double = 2.0
    
    /// Maximum retry backoff (5 minutes)
    let retryMaxBackoff: TimeInterval = 300
    
    // MARK: - City Configuration
    
    /// Default cities supported by the app
    let supportedCities: [CityConfig] = [
        CityConfig(
            id: "us-ca-san_francisco",
            name: "San Francisco",
            pattern: "^(SFMTA|MT)[0-9]{8}$",
            formattedPattern: "###-###-###",
            appealDeadlineDays: 21,
            phoneConfirmationRequired: true,
            canAppealOnline: true
        ),
        CityConfig(
            id: "us-ca-los_angeles",
            name: "Los Angeles",
            pattern: "^[0-9A-Z]{6,11}$",
            formattedPattern: "######",
            appealDeadlineDays: 21,
            phoneConfirmationRequired: true,
            canAppealOnline: true
        ),
        CityConfig(
            id: "us-ny-new_york",
            name: "New York",
            pattern: "^[0-9]{10}$",
            formattedPattern: "##########",
            appealDeadlineDays: 30,
            phoneConfirmationRequired: true,
            canAppealOnline: true
        ),
        CityConfig(
            id: "us-co-denver",
            name: "Denver",
            pattern: "^[0-9]{5,9}$",
            formattedPattern: "#######",
            appealDeadlineDays: 21,
            phoneConfirmationRequired: false,
            canAppealOnline: true
        )
    ]
    
    // MARK: - Initialization
    
    init() {
        // Configure based on build environment
        #if DEBUG
        self.apiBaseURL = URL(string: "http://localhost:8000")!
        self.webBaseURL = URL(string: "http://localhost:3000")!
        #else
        self.apiBaseURL = URL(string: "https://api.fightcitytickets.com")!
        self.webBaseURL = URL(string: "https://fightcitytickets.com")!
        #endif
        
        loadUserPreferences()
    }
    
    // MARK: - User Preferences
    
    private func loadUserPreferences() {
        telemetryEnabled = UserDefaults.standard.bool(forKey: "telemetryEnabled")
    }
    
    func setTelemetryEnabled(_ enabled: Bool) {
        telemetryEnabled = enabled
        UserDefaults.standard.set(enabled, forKey: "telemetryEnabled")
    }
    
    // MARK: - API Endpoints
    
    struct APIEndpoints {
        static let health = "/health"
        static let validateCitation = "/api/citations/validate"
        static let validateTicket = "/tickets/validate"
        static let appealSubmit = "/api/appeals"
        static let statusLookup = "/api/status/lookup"
        static let telemetryUpload = "/mobile/ocr/telemetry"
        static let ocrConfig = "/mobile/ocr/config"
    }
    
    // MARK: - Utility
    
    func cityConfig(for cityId: String) -> CityConfig? {
        supportedCities.first { $0.id == cityId }
    }
    
    func cityConfig(for citationNumber: String) -> CityConfig? {
        // Check patterns in priority order (from backend CitationValidator)
        let priorityOrder = ["us-ca-san_francisco", "us-ny-new_york", "us-co-denver", "us-ca-los_angeles"]
        
        for cityId in priorityOrder {
            if let config = cityConfig(for: cityId),
               citationNumber.range(of: config.pattern, options: .regularExpression) != nil {
                return config
            }
        }
        
        return nil
    }
}

/// Per-city configuration for citation parsing
struct CityConfig: Identifiable, Codable {
    let id: String
    let name: String
    let pattern: String
    let formattedPattern: String
    let appealDeadlineDays: Int
    let phoneConfirmationRequired: Bool
    let canAppealOnline: Bool
}
