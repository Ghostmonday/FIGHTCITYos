//
//  CityConfig.swift
//  FightCityTicketsCore
//
//  Per-city configuration for citation parsing
//

import Foundation

/// Per-city configuration for citation parsing
public struct CityConfig: Identifiable, Codable, Equatable, Sendable {
    public let id: String
    public let name: String
    public let pattern: String
    public let formattedPattern: String
    public let appealDeadlineDays: Int
    public let phoneConfirmationRequired: Bool
    public let canAppealOnline: Bool
    
    public init(
        id: String,
        name: String,
        pattern: String,
        formattedPattern: String,
        appealDeadlineDays: Int,
        phoneConfirmationRequired: Bool,
        canAppealOnline: Bool
    ) {
        self.id = id
        self.name = name
        self.pattern = pattern
        self.formattedPattern = formattedPattern
        self.appealDeadlineDays = appealDeadlineDays
        self.phoneConfirmationRequired = phoneConfirmationRequired
        self.canAppealOnline = canAppealOnline
    }
    
    /// Check if a citation number matches this city's pattern
    public func matches(citationNumber: String) -> Bool {
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        let range = NSRange(location: 0, length: citationNumber.count)
        return regex?.firstMatch(in: citationNumber, options: [], range: range) != nil
    }
}

/// Configuration for the entire app
public struct AppConfig: Sendable {
    public static let shared = AppConfig()
    
    // MARK: - API Configuration
    
    public var apiBaseURL: URL
    public let apiTimeout: TimeInterval = 30
    public let maxRetryAttempts: Int = 3
    public var webBaseURL: URL
    
    // MARK: - OCR Configuration
    
    public let ocrConfidenceThreshold: Double = 0.85
    public let ocrReviewThreshold: Double = 0.60
    public let ocrMaxImageDimension: Int = 1920
    
    // MARK: - Telemetry Configuration
    
    public var telemetryEnabled: Bool = false
    public let telemetryBatchSize: Int = 50
    public let telemetryMaxAge: TimeInterval = 86400
    
    // MARK: - Offline Configuration
    
    public let offlineQueueMaxSize: Int = 100
    public let retryBackoffMultiplier: Double = 2.0
    public let retryMaxBackoff: TimeInterval = 300
    
    // MARK: - City Configuration
    
    public let supportedCities: [CityConfig] = [
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
    
    #if DEBUG
    public init() {
        self.apiBaseURL = URL(string: "http://localhost:8000")!
        self.webBaseURL = URL(string: "http://localhost:3000")!
    }
    #else
    public init() {
        self.apiBaseURL = URL(string: "https://api.fightcitytickets.com")!
        self.webBaseURL = URL(string: "https://fightcitytickets.com")!
    }
    #endif
    
    // MARK: - API Endpoints
    
    public enum APIEndpoints {
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
        // Check patterns in priority order
        let priorityOrder = ["us-ca-san_francisco", "us-ny-new_york", "us-co-denver", "us-ca-los_angeles"]
        
        for cityId in priorityOrder {
            if let config = cityConfig(for: cityId),
               config.matches(citationNumber: citationNumber) {
                return config
            }
        }
        
        return nil
    }
    
    /// Get target length range for a city
    public func targetLength(for cityId: String) -> (min: Int, max: Int)? {
        switch cityId {
        case "us-ca-san_francisco":
            return (10, 11)  // SFMTA + 8 digits
        case "us-ny-new_york":
            return (10, 10)  // Exactly 10
        case "us-co-denver":
            return (5, 9)
        case "us-ca-los_angeles":
            return (6, 11)
        default:
            return (6, 12)
        }
    }
    
    /// Get pattern priority for a city (1 = highest specificity)
    public func patternPriority(for cityId: String) -> Int? {
        let priorities: [String: Int] = [
            "us-ca-san_francisco": 1,
            "us-ny-new_york": 2,
            "us-co-denver": 3,
            "us-ca-los_angeles": 4
        ]
        return priorities[cityId]
    }
}
