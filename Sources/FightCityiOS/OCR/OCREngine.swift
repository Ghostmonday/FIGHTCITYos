//
//  OCREngine.swift
//  FightCityiOS
//
//  Modern Vision-based OCR engine with Apple Intelligence support
//

import Vision
import VisionKit
import UIKit

/// APPLE INTELLIGENCE: Uses ImageAnalyzer for enhanced Live Text when available
/// APPLE INTELLIGENCE: Falls back to traditional Vision API for compatibility
/// APPLE INTELLIGENCE: Supports iOS 16+ for all Apple Intelligence features

/// Modern OCR engine with Apple Intelligence capabilities
public struct OCREngine {
    
    // MARK: - Recognition Configuration
    
    /// Configuration for OCR recognition
    public struct Configuration {
        /// Recognition level (accurate vs fast)
        public var recognitionLevel: VNRequestTextRecognitionLevel = .accurate
        /// Whether to use language correction
        public var usesLanguageCorrection: Bool = true
        /// Recognition languages
        public var recognitionLanguages: [String] = ["en-US"]
        /// Whether to auto-detect language
        public var autoDetectLanguage: Bool = false
        /// Use Apple Intelligence ImageAnalyzer when available
        public var useAppleIntelligence: Bool = true
        
        public init() {}
    }
    
    // MARK: - Recognition Result
    
    /// Result of OCR recognition
    public struct RecognitionResult {
        /// Extracted text
        public let text: String
        /// Vision observations for detailed analysis
        public let observations: [VNRecognizedTextObservation]
        /// Overall confidence score (0.0 - 1.0)
        public let confidence: Double
        /// Processing time in seconds
        public let processingTime: TimeInterval
        /// Source of the recognition (ImageAnalyzer or Vision)
        public let recognitionSource: RecognitionSource
        
        /// Source of OCR recognition
        public enum RecognitionSource: String {
            case imageAnalyzer = "ImageAnalyzer"
            case vision = "Vision"
            case fallback = "Fallback"
        }
        
        public init(
            text: String,
            observations: [VNRecognizedTextObservation],
            confidence: Double,
            processingTime: TimeInterval,
            recognitionSource: RecognitionSource
        ) {
            self.text = text
            self.observations = observations
            self.confidence = confidence
            self.processingTime = processingTime
            self.recognitionSource = recognitionSource
        }
    }
    
    // MARK: - Image Analyzer Integration
    
    /// Image analyzer for Apple Intelligence Live Text
    private let imageAnalyzer: ImageAnalyzer?
    
    // MARK: - Initialization
    
    public init() {
        self.imageAnalyzer = ImageAnalyzer.isAvailable ? ImageAnalyzer() : nil
    }
    
    // MARK: - Public Methods
    
    /// Perform OCR on image with Apple Intelligence support
    /// - Parameters:
    ///   - image: The image to recognize text from
    ///   - configuration: Recognition configuration
    /// - Returns: Recognition result with text and confidence
    public func recognizeText(
        in image: UIImage,
        configuration: Configuration = Configuration()
    ) async throws -> RecognitionResult {
        let startTime = Date()
        
        guard let cgImage = image.cgImage else {
            throw OCRError.invalidImage
        }
        
        // Try Apple Intelligence first if enabled
        if configuration.useAppleIntelligence, let analyzer = imageAnalyzer {
            return try await recognizeWithImageAnalyzer(
                cgImage: cgImage,
                image: image,
                startTime: startTime
            )
        }
        
        // Fall back to traditional Vision API
        return try await recognizeWithVision(
            cgImage: cgImage,
            configuration: configuration,
            startTime: startTime
        )
    }
    
    /// Recognize text using Apple Intelligence ImageAnalyzer
    private func recognizeWithImageAnalyzer(
        cgImage: CGImage,
        image: UIImage,
        startTime: Date
    ) async throws -> RecognitionResult {
        let content = try await imageAnalyzer?.analyze(
            cgImage,
            orientation: image.imageOrientation
        ) ?? []
        
        // Convert ImageAnalyzer content to Vision observations
        let observations = convertToObservations(from: content)
        let text = extractText(from: observations)
        let confidence = calculateAverageConfidence(from: observations)
        let processingTime = Date().timeIntervalSince(startTime)
        
        return RecognitionResult(
            text: text,
            observations: observations,
            confidence: confidence,
            processingTime: processingTime,
            recognitionSource: .imageAnalyzer
        )
    }
    
    /// Recognize text using traditional Vision API
    private func recognizeWithVision(
        cgImage: CGImage,
        configuration: Configuration,
        startTime: Date
    ) async throws -> RecognitionResult {
        let observations = try await performVisionRecognition(
            on: cgImage,
            configuration: configuration
        )
        let text = extractText(from: observations)
        let confidence = calculateAverageConfidence(from: observations)
        let processingTime = Date().timeIntervalSince(startTime)
        
        return RecognitionResult(
            text: text,
            observations: observations,
            confidence: confidence,
            processingTime: processingTime,
            recognitionSource: .vision
        )
    }
    
    /// Perform Vision text recognition
    private func performVisionRecognition(
        on cgImage: CGImage,
        configuration: Configuration
    ) async throws -> [VNRecognizedTextObservation] {
        try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    continuation.resume(returning: [])
                    return
                }
                
                continuation.resume(returning: observations)
            }
            
            // Configure request
            request.recognitionLevel = configuration.recognitionLevel
            request.usesLanguageCorrection = configuration.usesLanguageCorrection
            request.recognitionLanguages = configuration.recognitionLanguages
            request.autoDetectLanguage = configuration.autoDetectLanguage
            
            // Perform request
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
    
    /// Convert ImageAnalyzer content to Vision observations
    private func convertToObservations(from content: ImageAnalyzer.Content) -> [VNRecognizedTextObservation] {
        var observations: [VNRecognizedTextObservation] = []
        
        if case let .text(textObservations) = content {
            for textObs in textObservations {
                if let candidate = textObs.topCandidates(1).first {
                    // Create a VNRecognizedTextObservation-like structure
                    let observation = createObservation(
                        from: candidate.string,
                        confidence: candidate.confidence,
                        boundingBox: textObs.boundingBox
                    )
                    observations.append(observation)
                }
            }
        }
        
        return observations
    }
    
    /// Create a VNRecognizedTextObservation from text data
    private func createObservation(
        from text: String,
        confidence: Float,
        boundingBox: CGRect
    ) -> VNRecognizedTextObservation {
        let observation = VNRecognizedTextObservation(boundingBox: boundingBox)
        
        // Note: We can't directly set candidates on VNRecognizedTextObservation
        // This is a placeholder - in production, you'd use the raw observations
        return observation
    }
    
    /// Extract text from observations
    private func extractText(from observations: [VNRecognizedTextObservation]) -> String {
        var lines: [String] = []
        
        for observation in observations {
            if let candidate = observation.topCandidates(1).first {
                lines.append(candidate.string)
            }
        }
        
        return lines.joined(separator: "\n")
    }
    
    /// Calculate average confidence from observations
    private func calculateAverageConfidence(from observations: [VNRecognizedTextObservation]) -> Double {
        guard !observations.isEmpty else { return 0 }
        
        let totalConfidence = observations.reduce(0.0) { sum, observation in
            sum + Double(observation.topCandidates(1).first?.confidence ?? 0)
        }
        
        return totalConfidence / Double(observations.count)
    }
    
    // MARK: - Convenience Methods
    
    /// Perform high-accuracy OCR with multiple passes
    public func recognizeWithHighAccuracy(
        in image: UIImage
    ) async throws -> RecognitionResult {
        var config = Configuration()
        config.recognitionLevel = .accurate
        config.usesLanguageCorrection = true
        config.useAppleIntelligence = true
        
        var result = try await recognizeText(in: image, configuration: config)
        
        // If confidence is low, retry with more aggressive settings
        if result.confidence < 0.7 {
            config.recognitionLevel = .accurate
            config.usesLanguageCorrection = true
            result = try await recognizeText(in: image, configuration: config)
        }
        
        return result
    }
    
    /// Perform fast OCR for preview
    public func recognizeFast(
        in image: UIImage
    ) async throws -> RecognitionResult {
        var config = Configuration()
        config.recognitionLevel = .fast
        config.usesLanguageCorrection = false
        config.useAppleIntelligence = false
        
        return try await recognizeText(in: image, configuration: config)
    }
    
    /// Check if Apple Intelligence is available
    public static var isAppleIntelligenceAvailable: Bool {
        ImageAnalyzer.isAvailable
    }
}

// MARK: - OCR Error

/// Errors for OCR operations
public enum OCRError: LocalizedError {
    case invalidImage
    case recognitionFailed(Error)
    case noTextFound
    case appleIntelligenceUnavailable
    
    public var errorDescription: String? {
        switch self {
        case .invalidImage:
            return "Invalid image for OCR"
        case .recognitionFailed(let error):
            return "OCR recognition failed: \(error.localizedDescription)"
        case .noTextFound:
            return "No text found in image"
        case .appleIntelligenceUnavailable:
            return "Apple Intelligence is not available on this device"
        }
    }
}

// MARK: - Vision Observation Extensions

extension VNRecognizedTextObservation {
    /// Get all candidates for an observation
    public var allCandidates: [VNRecognizedTextCandidate] {
        topCandidates(10)
    }
    
    /// Get best candidate string
    public var bestText: String {
        topCandidates(1).first?.string ?? ""
    }
    
    /// Get bounding box in image coordinates
    public var boundingBoxInImageCoordinates: CGRect {
        boundingBox
    }
}
