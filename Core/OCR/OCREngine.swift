//
//  OCREngine.swift
//  FightCityTickets
//
//  Vision framework integration for text recognition
//

import Vision
import UIKit

/// Vision-based OCR engine with confidence scoring
struct OCREngine {
    // MARK: - Recognition Configuration
    
    struct Configuration {
        var recognitionLevel: VNRequestTextRecognitionLevel = .accurate
        var usesLanguageCorrection: Bool = true
        var recognitionLanguages: [String] = ["en-US"]
        var autoDetectLanguage: Bool = false
    }
    
    // MARK: - Recognition Result
    
    struct RecognitionResult {
        let text: String
        let observations: [VNRecognizedTextObservation]
        let confidence: Double
        let processingTime: TimeInterval
    }
    
    // MARK: - Recognition
    
    /// Perform OCR on image
    func recognizeText(
        in image: UIImage,
        configuration: Configuration = Configuration()
    ) async throws -> RecognitionResult {
        let startTime = Date()
        
        guard let cgImage = image.cgImage else {
            throw OCRError.invalidImage
        }
        
        let observations = try await performRecognition(on: cgImage, configuration: configuration)
        let text = extractText(from: observations)
        let confidence = calculateAverageConfidence(from: observations)
        let processingTime = Date().timeIntervalSince(startTime)
        
        return RecognitionResult(
            text: text,
            observations: observations,
            confidence: confidence,
            processingTime: processingTime
        )
    }
    
    // MARK: - Private Methods
    
    private func performRecognition(
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
    
    private func extractText(from observations: [VNRecognizedTextObservation]) -> String {
        var lines: [String] = []
        
        for observation in observations {
            // Get top candidate for each observation
            if let candidate = observation.topCandidates(1).first {
                lines.append(candidate.string)
            }
        }
        
        return lines.joined(separator: "\n")
    }
    
    private func calculateAverageConfidence(from observations: [VNRecognizedTextObservation]) -> Double {
        guard !observations.isEmpty else { return 0 }
        
        let totalConfidence = observations.reduce(0.0) { sum, observation in
            sum + observation.topCandidates(1).first?.confidence ?? 0
        }
        
        return totalConfidence / Double(observations.count)
    }
}

// MARK: - High-Accuracy Recognition

extension OCREngine {
    /// Perform high-accuracy OCR with multiple passes
    func recognizeWithHighAccuracy(
        in image: UIImage
    ) async throws -> RecognitionResult {
        var config = Configuration()
        config.recognitionLevel = .accurate
        config.usesLanguageCorrection = true
        
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
    func recognizeFast(
        in image: UIImage
    ) async throws -> RecognitionResult {
        var config = Configuration()
        config.recognitionLevel = .fast
        config.usesLanguageCorrection = false
        
        return try await recognizeText(in: image, configuration: config)
    }
}

// MARK: - OCR Error

enum OCRError: LocalizedError {
    case invalidImage
    case recognitionFailed(Error)
    case noTextFound
    
    var errorDescription: String? {
        switch self {
        case .invalidImage:
            return "Invalid image for OCR"
        case .recognitionFailed(let error):
            return "OCR recognition failed: \(error.localizedDescription)"
        case .noTextFound:
            return "No text found in image"
        }
    }
}

// MARK: - Text Observation Extensions

extension VNRecognizedTextObservation {
    /// Get all candidates for an observation
    var allCandidates: [VNRecognizedTextCandidate] {
        topCandidates(10)
    }
    
    /// Get best candidate string
    var bestText: String {
        topCandidates(1).first?.string ?? ""
    }
    
    /// Get bounding box in image coordinates
    var boundingBoxInImageCoordinates: CGRect {
        boundingBox
    }
}
