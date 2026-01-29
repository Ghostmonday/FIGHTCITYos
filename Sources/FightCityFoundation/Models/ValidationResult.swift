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
