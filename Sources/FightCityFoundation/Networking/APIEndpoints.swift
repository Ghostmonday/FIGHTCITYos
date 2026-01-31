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
    public static let telemetryUpload = "\(mobile)/telemetry"
    
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
