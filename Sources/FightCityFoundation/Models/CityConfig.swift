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
