//
//  OCREngine.swift
//  FightCityTicketsCore
//
//  OCR abstraction protocol for cross-platform testing
//

import Foundation

/// OCR error types
public enum OCRError: Error, Sendable {
    case invalidImage
    case recognitionFailed
    case noTextFound
    case notSupported
    
    public var message: String {
        switch self {
        case .invalidImage:
            return "Invalid image for OCR"
        case .recognitionFailed:
            return "OCR recognition failed"
        case .noTextFound:
            return "No text found in image"
        case .notSupported:
            return "OCR not supported on this platform"
        }
    }
}

/// OCR configuration options
public struct OCRConfiguration: Sendable {
    public var recognitionLevel: RecognitionLevel
    public var usesLanguageCorrection: Bool
    public var recognitionLanguages: [String]
    public var autoDetectLanguage: Bool
    
    public init(
        recognitionLevel: RecognitionLevel = .accurate,
        usesLanguageCorrection: Bool = true,
        recognitionLanguages: [String] = ["en-US"],
        autoDetectLanguage: Bool = false
    ) {
        self.recognitionLevel = recognitionLevel
        self.usesLanguageCorrection = usesLanguageCorrection
        self.recognitionLanguages = recognitionLanguages
        self.autoDetectLanguage = autoDetectLanguage
    }
    
    public enum RecognitionLevel: String, Sendable {
        case fast
        case accurate
    }
}

/// Per-observation confidence from OCR
public struct OCObservation: Sendable {
    public let text: String
    public let confidence: Double
    public let boundingBox: CGRect?
    
    public init(text: String, confidence: Double, boundingBox: CGRect? = nil) {
        self.text = text
        self.confidence = confidence
        self.boundingBox = boundingBox
    }
}

/// OCR recognition result
public struct OCRRecognitionResult: Sendable {
    public let text: String
    public let observations: [OCObservation]
    public let confidence: Double
    public let processingTime: TimeInterval
    public let matchedCityId: String?
    
    public init(
        text: String,
        observations: [OCObservation],
        confidence: Double,
        processingTime: TimeInterval,
        matchedCityId: String? = nil
    ) {
        self.text = text
        self.observations = observations
        self.confidence = confidence
        self.processingTime = processingTime
        self.matchedCityId = matchedCityId
    }
}

/// Protocol for OCR operations - enables mocking on Linux
public protocol OCREngineProtocol: Sendable {
    /// Perform OCR on image data
    func recognizeText(in imageData: Data, configuration: OCRConfiguration) async throws -> OCRRecognitionResult
    
    /// Perform high-accuracy OCR
    func recognizeWithHighAccuracy(in imageData: Data) async throws -> OCRRecognitionResult
    
    /// Perform fast OCR for preview
    func recognizeFast(in imageData: Data) async throws -> OCRRecognitionResult
}

/// Default implementations for Linux/macOS testing
public extension OCREngineProtocol {
    func recognizeText(in imageData: Data, configuration: OCRConfiguration) async throws -> OCRRecognitionResult {
        throw OCRError.notSupported
    }
    
    func recognizeWithHighAccuracy(in imageData: Data) async throws -> OCRRecognitionResult {
        throw OCRError.notSupported
    }
    
    func recognizeFast(in imageData: Data) async throws -> OCRRecognitionResult {
        throw OCRError.notSupported
    }
}

/// Mock OCR engine for testing
public actor MockOCREngine: OCREngineProtocol {
    public var shouldFail: Bool = false
    public var shouldReturnNoText: Bool = false
    public var simulatedText: String = ""
    public var simulatedConfidence: Double = 0.9
    public var simulatedObservations: [OCObservation] = []
    public var callCount: Int = 0
    
    public init() {}
    
    public func recognizeText(in imageData: Data, configuration: OCRConfiguration) async throws -> OCRRecognitionResult {
        callCount += 1
        
        if shouldFail {
            throw OCRError.recognitionFailed
        }
        
        if shouldReturnNoText || simulatedText.isEmpty {
            throw OCRError.noTextFound
        }
        
        let observations = simulatedObservations.isEmpty
            ? [OCObservation(text: simulatedText, confidence: simulatedConfidence)]
            : simulatedObservations
        
        return OCRRecognitionResult(
            text: simulatedText,
            observations: observations,
            confidence: simulatedConfidence,
            processingTime: 0.1,
            matchedCityId: nil
        )
    }
    
    public func recognizeWithHighAccuracy(in imageData: Data) async throws -> OCRRecognitionResult {
        // Higher simulated confidence for high accuracy mode
        let originalConfidence = simulatedConfidence
        simulatedConfidence = min(1.0, simulatedConfidence + 0.05)
        
        let result = try await recognizeText(in: imageData, configuration: OCRConfiguration(recognitionLevel: .accurate))
        
        simulatedConfidence = originalConfidence
        return result
    }
    
    public func recognizeFast(in imageData: Data) async throws -> OCRRecognitionResult {
        // Slightly lower confidence for fast mode
        let originalConfidence = simulatedConfidence
        simulatedConfidence = max(0.0, simulatedConfidence - 0.02)
        
        let result = try await recognizeText(in: imageData, configuration: OCRConfiguration(recognitionLevel: .fast))
        
        simulatedConfidence = originalConfidence
        return result
    }
    
    /// Reset mock state
    public func reset() {
        shouldFail = false
        shouldReturnNoText = false
        simulatedText = ""
        simulatedConfidence = 0.9
        simulatedObservations = []
        callCount = 0
    }
    
    /// Setup mock to return a specific citation
    public func setupForCitation(_ citationNumber: String) {
        simulatedText = citationNumber
        simulatedConfidence = 0.95
        simulatedObservations = [
            OCObservation(text: citationNumber, confidence: 0.95)
        ]
    }
}
