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
    // TODO: PHASE 5 - Update production API URL after backend deployment
    // Current DEBUG: http://localhost:8000
    // Current RELEASE: https://api.fightcitytickets.com (not yet deployed)
    // 
    // Backend deployment checklist (PHASE 5):
    // 1. Deploy FastAPI backend to Railway/Render/Fly.io
    // 2. Set up PostgreSQL database
    // 3. Configure HTTPS with valid certificate
    // 4. Update this URL to actual deployed endpoint
    // 5. Test all APIEndpoints from iOS app
    // AUDIT: For App Store review, ensure these URLs point to production services. Avoid localhost in
    // release builds and document a staging configuration to prevent misrouted traffic.
    @Published public var apiBaseURL: URL
    
    /// API timeout interval in seconds
    public let apiTimeout: TimeInterval = 30
    
    /// Number of retry attempts for failed requests
    public let maxRetryAttempts: Int = 3
    
    /// Base URL for the web frontend (for deep links)
    @Published public var webBaseURL: URL
    
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
    
    public init() {
        // Configure based on build environment
        #if DEBUG
        guard let apiURL = URL(string: "http://localhost:8000"),
              let webURL = URL(string: "http://localhost:3000") else {
            // AUDIT: Avoid fatalError in production builds. Prefer throwing init, or default to a known-safe URL
            // and surface a user-facing configuration error. This reduces crash risk during App Store review.
            fatalError("Failed to create debug URLs - this should never happen")
        }
        self.apiBaseURL = apiURL
        self.webBaseURL = webURL
        #else
        guard let apiURL = URL(string: "https://api.fightcitytickets.com"),
              let webURL = URL(string: "https://fightcitytickets.com") else {
            // AUDIT: Avoid fatalError on release builds; surface configuration errors via logging + fallback
            // instead of crashing. App Store review expects graceful handling of misconfiguration.
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
    
    // MARK: - Lob Proxy Configuration
    
    /// Backend proxy URL for Lob API (API key stored server-side)
    public static var lobProxyURL: String? {
        #if DEBUG
        return "http://localhost:5000"  // Local development
        #else
        return "https://api.fightcitytickets.com"  // Production
        #endif
    }
    
    // MARK: - API Endpoints
    
    public struct APIEndpoints {
        public static let health = "/health"
        public static let validateCitation = "/api/citations/validate"
        public static let validateTicket = "/tickets/validate"
        public static let appealSubmit = "/api/appeals"
        public static let statusLookup = "/api/status/lookup"
        public static let telemetryUpload = "/mobile/telemetry"
    }
    
    // MARK: - Utility
    
    public func cityConfig(for cityId: String) -> CityConfig? {
        supportedCities.first { $0.id == cityId }
    }
    
    public func cityConfigFromCitationNumber(_ citationNumber: String) -> CityConfig? {
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
