//
//  CaptureResult.swift
//  FightCityTickets
//
//  OCR capture result with confidence scores
//

import Foundation
import UIKit

/// Result from OCR capture and processing
struct CaptureResult: Identifiable, Codable, Equatable {
    let id: UUID
    let originalImageData: Data?
    let croppedImageData: Data?
    let rawText: String
    let extractedCitationNumber: String?
    let extractedCityId: String?
    let extractedDate: String?
    let confidence: Double
    let processingTimeMs: Int
    let boundingBoxes: [BoundingBox]
    let capturedAt: Date
    
    /// Raw recognition observations from Vision
    var observations: [String: VNRecognizedTextObservation]
    
    init(
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
    
    var confidenceLevel: ConfidenceLevel {
        if confidence >= 0.85 {
            return .high
        } else if confidence >= 0.60 {
            return .medium
        } else {
            return .low
        }
    }
    
    var hasValidCitation: Bool {
        extractedCitationNumber != nil && !extractedCitationNumber!.isEmpty
    }
    
    var hasImage: Bool {
        originalImageData != nil
    }
    
    // MARK: - Confidence Level
    
    enum ConfidenceLevel {
        case high, medium, low
        
        var requiresReview: Bool {
            self != .high
        }
    }
    
    // MARK: - Coding Keys
    
    enum CodingKeys: String, CodingKey {
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
struct BoundingBox: Identifiable, Codable, Equatable {
    let id: UUID
    let text: String
    let confidence: Double
    let rect: CGRect
    
    init(
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
    
    enum CodingKeys: String, CodingKey {
        case id
        case text
        case confidence
        case rect
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        text = try container.decode(String.self, forKey: .text)
        confidence = try container.decode(Double.self, forKey: .confidence)
        
        // Decode CGRect from array [x, y, width, height]
        let rectArray = try container.decode([CGFloat].self, forKey: .rect)
        rect = CGRect(x: rectArray[0], y: rectArray[1], width: rectArray[2], height: rectArray[3])
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(text, forKey: .text)
        try container.encode(confidence, forKey: .confidence)
        try container.encode([rect.origin.x, rect.origin.y, rect.width, rect.height], forKey: .rect)
    }
}

// MARK: - Processing State

/// State of OCR processing
enum ProcessingState: Equatable {
    case idle
    case analyzing
    case capturing
    case processing
    case complete(CaptureResult)
    case error(String)
    
    var isProcessing: Bool {
        switch self {
        case .analyzing, .capturing, .processing:
            return true
        default:
            return false
        }
    }
    
    var statusText: String {
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
    var originalImage: UIImage? {
        guard let data = originalImageData else { return nil }
        return UIImage(data: data)
    }
    
    var croppedImage: UIImage? {
        guard let data = croppedImageData else { return nil }
        return UIImage(data: data)
    }
}
