//
//  CaptureResult.swift
//  FightCityTicketsCore
//
//  Capture result model for OCR processing
//

import Foundation

/// Result of image capture and OCR processing
public struct CaptureResult: Identifiable, Codable, Equatable, Sendable {
    public let id: UUID
    public let imageData: Data?
    public let imagePath: String?
    public let ocrResult: OCRResult?
    public let capturedAt: Date
    
    public init(
        id: UUID = UUID(),
        imageData: Data? = nil,
        imagePath: String? = nil,
        ocrResult: OCRResult? = nil,
        capturedAt: Date = Date()
    ) {
        self.id = id
        self.imageData = imageData
        self.imagePath = imagePath
        self.ocrResult = ocrResult
        self.capturedAt = capturedAt
    }
    
    /// Extracted citation number from OCR, if available
    public var extractedCitationNumber: String? {
        ocrResult?.extractedText
    }
    
    /// Confidence score of the capture
    public var confidence: Double {
        ocrResult?.confidence.confidence ?? 0.0
    }
    
    /// Whether the capture is high confidence enough for auto-validation
    public var isHighConfidence: Bool {
        guard let ocrResult = ocrResult else { return false }
        return ocrResult.confidence.confidence >= 0.85
    }
}

/// OCR processing result
public struct OCRResult: Codable, Equatable, Sendable {
    public let extractedText: String
    public let confidence: ConfidenceResult
    public let matchedCityId: String?
    public let processingTimeMs: Double
    
    public init(
        extractedText: String,
        confidence: ConfidenceResult,
        matchedCityId: String? = nil,
        processingTimeMs: Double = 0
    ) {
        self.extractedText = extractedText
        self.confidence = confidence
        self.matchedCityId = matchedCityId
        self.processingTimeMs = processingTimeMs
    }
}

/// Validation result for a citation
public struct ValidationResult: Identifiable, Codable, Equatable, Sendable {
    public let id: UUID
    public let isValid: Bool
    public let citation: Citation?
    public let confidence: Double
    public let matchedCityId: String?
    public let errorMessage: String?
    public let validatedAt: Date
    
    public init(
        id: UUID = UUID(),
        isValid: Bool,
        citation: Citation? = nil,
        confidence: Double = 0.0,
        matchedCityId: String? = nil,
        errorMessage: String? = nil,
        validatedAt: Date = Date()
    ) {
        self.id = id
        self.isValid = isValid
        self.citation = citation
        self.confidence = confidence
        self.matchedCityId = matchedCityId
        self.errorMessage = errorMessage
        self.validatedAt = validatedAt
    }
    
    /// Recommendation based on confidence
    public var recommendation: Recommendation {
        if confidence >= 0.85 {
            return .accept
        } else if confidence >= 0.60 {
            return .review
        } else {
            return .reject
        }
    }
}

/// User action recommendation
public enum Recommendation: String, Sendable {
    case accept
    case review
    case reject
    
    public var displayText: String {
        switch self {
        case .accept: return "Accept"
        case .review: return "Review"
        case .reject: return "Retake"
        }
    }
}
