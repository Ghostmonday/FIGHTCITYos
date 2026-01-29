//
//  CaptureResult.swift
//  FightCityiOS
//
//  OCR capture result with confidence scores
//

import Foundation
import UIKit
import Vision

/// Result from OCR capture and processing
public struct CaptureResult: Identifiable, Codable, Equatable {
    public let id: UUID
    public let originalImageData: Data?
    public let croppedImageData: Data?
    public let rawText: String
    public let extractedCitationNumber: String?
    public let extractedCityId: String?
    public let extractedDate: String?
    public let confidence: Double
    public let processingTimeMs: Int
    public let boundingBoxes: [BoundingBox]
    public let capturedAt: Date
    
    /// Raw recognition observations from Vision (not Codable)
    public var observations: [String: VNRecognizedTextObservation]
    
    public init(
        id: UUID = UUID(),
        originalImageData: Data? = nil,
        croppedImageData: Data? = nil,
        rawText: String,
        extractedCitationNumber: String? = nil,
        extractedCityId: String? = nil,
        extractedDate: String? = nil,
        confidence: Double = 0,
        processingTimeMs: Int = 0,
        boundingBoxes: [BoundingBox] = [],
        observations: [String: VNRecognizedTextObservation] = [:],
        capturedAt: Date = Date()
    ) {
        self.id = id
        self.originalImageData = originalImageData
        self.croppedImageData = croppedImageData
        self.rawText = rawText
        self.extractedCitationNumber = extractedCitationNumber
        self.extractedCityId = extractedCityId
        self.extractedDate = extractedDate
        self.confidence = confidence
        self.processingTimeMs = processingTimeMs
        self.boundingBoxes = boundingBoxes
        self.observations = observations
        self.capturedAt = capturedAt
    }
    
    // MARK: - Computed Properties
    
    public var confidenceLevel: ConfidenceLevel {
        if confidence >= 0.85 {
            return .high
        } else if confidence >= 0.60 {
            return .medium
        } else {
            return .low
        }
    }
    
    public var hasValidCitation: Bool {
        extractedCitationNumber != nil && !extractedCitationNumber!.isEmpty
    }
    
    public var hasImage: Bool {
        originalImageData != nil
    }
    
    // MARK: - Confidence Level
    
    public enum ConfidenceLevel {
        case high, medium, low
        
        public var requiresReview: Bool {
            self != .high
        }
    }
    
    // MARK: - Coding Keys
    
    public enum CodingKeys: String, CodingKey {
        case id
        case originalImageData
        case croppedImageData
        case rawText
        case extractedCitationNumber
        case extractedCityId
        case extractedDate
        case confidence
        case processingTimeMs
        case boundingBoxes
        case capturedAt
    }
}

// MARK: - Bounding Box

/// Detected text region with bounding box
public struct BoundingBox: Identifiable, Codable, Equatable {
    public let id: UUID
    public let text: String
    public let confidence: Double
    public let rect: CGRect
    
    public init(
        id: UUID = UUID(),
        text: String,
        confidence: Double,
        rect: CGRect
    ) {
        self.id = id
        self.text = text
        self.confidence = confidence
        self.rect = rect
    }
    
    // MARK: - Coding Keys
    
    public enum CodingKeys: String, CodingKey {
        case id
        case text
        case confidence
        case rect
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        text = try container.decode(String.self, forKey: .text)
        confidence = try container.decode(Double.self, forKey: .confidence)
        
        // Decode CGRect from array [x, y, width, height]
        let rectArray = try container.decode([CGFloat].self, forKey: .rect)
        rect = CGRect(x: rectArray[0], y: rectArray[1], width: rectArray[2], height: rectArray[3])
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(text, forKey: .text)
        try container.encode(confidence, forKey: .confidence)
        try container.encode([rect.origin.x, rect.origin.y, rect.width, rect.height], forKey: .rect)
    }
}

// MARK: - Processing State

/// State of OCR processing
public enum ProcessingState: Equatable {
    case idle
    case analyzing
    case capturing
    case processing
    case complete(CaptureResult)
    case error(String)
    
    public var isProcessing: Bool {
        switch self {
        case .analyzing, .capturing, .processing:
            return true
        default:
            return false
        }
    }
    
    public var statusText: String {
        switch self {
        case .idle:
            return "Ready to scan"
        case .analyzing:
            return "Analyzing frame..."
        case .capturing:
            return "Capturing..."
        case .processing:
            return "Processing OCR..."
        case .complete:
            return "Complete"
        case .error(let message):
            return "Error: \(message)"
        }
    }
}

// MARK: - UIKit Bridge

extension CaptureResult {
    /// Convert to UIImage
    public var originalImage: UIImage? {
        guard let data = originalImageData else { return nil }
        return UIImage(data: data)
    }
    
    public var croppedImage: UIImage? {
        guard let data = croppedImageData else { return nil }
        return UIImage(data: data)
    }
}
