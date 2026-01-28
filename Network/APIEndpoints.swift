//
//  APIEndpoints.swift
//  FightCityTickets
//
//  Endpoint definitions for the backend API
//

import Foundation

/// Endpoint definitions matching the FastAPI backend
enum APIEndpoints {
    // MARK: - Base
    
    static let base = "/api/v1"
    static let mobile = "/mobile"
    
    // MARK: - Health
    
    /// Health check endpoint
    static let health = "/health"
    
    // MARK: - Citations
    
    /// Validate a citation number
    static let validateCitation = "\(base)/citations/validate"
    
    /// Alternative validation with city mapping
    static let validateTicket = "/tickets/validate"
    
    /// Get citation details
    static func citationDetail(id: String) -> String {
        "\(base)/citations/\(id)"
    }
    
    // MARK: - Appeals
    
    /// Submit an appeal
    static let appealSubmit = "\(base)/appeals"
    
    /// Get appeal status
    static func appealStatus(appealId: String) -> String {
        "\(base)/appeals/\(appealId)"
    }
    
    /// Update appeal evidence
    static func updateAppealEvidence(appealId: String) -> String {
        "\(base)/appeals/\(appealId)/evidence"
    }
    
    // MARK: - Status Lookup
    
    /// Look up appeal status by email
    static let statusLookup = "\(base)/status/lookup"
    
    // MARK: - Mobile (iOS Specific)
    
    /// Upload telemetry data
    static let telemetryUpload = "\(mobile)/ocr/telemetry"
    
    /// Get OCR configuration for a city
    static func ocrConfig(city: String) -> String {
        "\(mobile)/ocr/config?city=\(city)"
    }
    
    // MARK: - Auth
    
    /// Login endpoint
    static let login = "\(base)/auth/login"
    
    /// Register endpoint
    static let register = "\(base)/auth/register"
    
    /// Refresh token
    static let refreshToken = "\(base)/auth/refresh"
    
    // MARK: - User
    
    /// Get user profile
    static let userProfile = "\(base)/users/me"
    
    /// Update user settings
    static let updateSettings = "\(base)/users/me/settings"
}

// MARK: - Request Builders

extension APIEndpoints {
    /// Build validate citation request body
    static func buildValidationRequest(
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
    static func buildStatusRequest(email: String, citationNumber: String) -> StatusLookupRequest {
        StatusLookupRequest(email: email, citation_number: citationNumber)
    }
}
