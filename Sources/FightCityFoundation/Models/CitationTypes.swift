//
//  CitationTypes.swift
//  FightCityFoundation
//
//  Shared types for citation classification
//

import Foundation

// MARK: - Citation Type

/// Types of citations that can be classified
public enum CitationType: String, CaseIterable {
    case parking = "parking"
    case traffic = "traffic"
    case municipal = "municipal"
    case redLight = "red_light"
    case speeding = "speeding"
    case unknown = "unknown"
    
    public var displayName: String {
        switch self {
        case .parking: return "Parking Violation"
        case .traffic: return "Traffic Violation"
        case .municipal: return "Municipal Violation"
        case .redLight: return "Red Light Violation"
        case .speeding: return "Speeding Violation"
        case .unknown: return "Unknown"
        }
    }
}

// MARK: - Parsed Fields

/// Parsed fields from citation text
public struct ParsedFields {
    public let citationNumber: String?
    public let violationDate: Date?
    public let amount: Double?
    public let violationCode: String?
    public let licensePlate: String?
    
    public init(
        citationNumber: String?,
        violationDate: Date?,
        amount: Double?,
        violationCode: String?,
        licensePlate: String?
    ) {
        self.citationNumber = citationNumber
        self.violationDate = violationDate
        self.amount = amount
        self.violationCode = violationCode
        self.licensePlate = licensePlate
    }
    
    public static let empty = ParsedFields(
        citationNumber: nil,
        violationDate: nil,
        amount: nil,
        violationCode: nil,
        licensePlate: nil
    )
}

// MARK: - Classification Result

/// Result of ML/regex citation classification
public struct ClassificationResult {
    public let cityId: String?
    public let cityName: String?
    public let citationType: CitationType
    public let confidence: Double
    public let isFromML: Bool
    public let parsedFields: ParsedFields
    
    public init(
        cityId: String?,
        cityName: String?,
        citationType: CitationType,
        confidence: Double,
        isFromML: Bool,
        parsedFields: ParsedFields
    ) {
        self.cityId = cityId
        self.cityName = cityName
        self.citationType = citationType
        self.confidence = confidence
        self.isFromML = isFromML
        self.parsedFields = parsedFields
    }
}
