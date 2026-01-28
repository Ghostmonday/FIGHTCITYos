//
//  ValidationResult.swift
//  FightCityTickets
//
//  Backend API validation response models
//

import Foundation

/// Request model matching backend API
struct CitationValidationRequest: Codable {
    let citation_number: String
    let city_id: String?
    let license_plate: String?
    let violation_date: String?
    
    init(
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
struct CitationValidationResponse: Codable {
    let is_valid: Bool
    let citation_number: String
    let city_id: String?
    let city_name: String?
    let agency: String?
    let section_id: String?
    let formatted_citation: String?
    let deadline_date: String?
    let days_remaining: Int?
    let is_past_deadline: Bool?
    let is_urgent: Bool?
    let can_appeal_online: Bool
    let phone_confirmation_required: Bool
    let error_message: String?
    
    // MARK: - Computed Properties
    
    var deadlineStatus: DeadlineStatus {
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
    
    var hasError: Bool {
        !is_valid || error_message != nil
    }
    
    // MARK: - Conversion to Citation
    
    func toCitation() -> Citation {
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
struct StatusLookupRequest: Codable {
    let email: String
    let citation_number: String
}

/// Response for status lookup
struct StatusLookupResponse: Codable {
    let citations: [Citation]
    let email: String
    let has_pending_appeals: Bool
}

// MARK: - Appeal Submit

/// Request to submit an appeal
struct AppealSubmitRequest: Codable {
    let citation_id: String
    let appeal_reason: String
    let statement: String?
    let evidence_photos: [Data]?
}

// MARK: - API Error

/// API error response
struct APIError: Codable, Error {
    let error: String
    let message: String?
    let code: String?
    
    static let networkError = APIError(
        error: "Network Error",
        message: "Unable to connect to the server. Please check your internet connection.",
        code: "NETWORK_ERROR"
    )
    
    static let decodingError = APIError(
        error: "Data Error",
        message: "Unable to process server response.",
        code: "DECODING_ERROR"
    )
}

// MARK: - Health Check

/// Health check response
struct HealthResponse: Codable {
    let status: String
    let timestamp: String
    let version: String?
    
    var isHealthy: Bool {
        status.lowercased() == "ok" || status.lowercased() == "healthy"
    }
}

// MARK: - Telemetry Upload

/// Telemetry upload request
struct TelemetryUploadRequest: Codable {
    let records: [TelemetryRecord]
}

// MARK: - Telemetry Record

/// Individual telemetry record (opt-in)
struct TelemetryRecord: Codable {
    let city: String
    let timestamp: Date
    let deviceModel: String
    let iOSVersion: String
    let originalImageHash: String
    let croppedImageHash: String
    let ocrOutput: String
    let userCorrection: String?
    let confidence: Double
    let processingTimeMs: Int
    
    enum CodingKeys: String, CodingKey {
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
    
    static func create(
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

// MARK: - OCR Config Response

/// Per-city OCR configuration from backend
struct OCRConfigResponse: Codable {
    let city_id: String
    let patterns: [CityPattern]
    let preprocessing_options: PreprocessingOptions?
    
    struct CityPattern: Codable {
        let pattern: String
        let section_id: String
        let priority: Int
    }
    
    struct PreprocessingOptions: Codable {
        let contrast_enhancement: Double?
        let noise_reduction: Bool?
        let perspective_correction: Bool?
    }
}
