//
//  MockOCREngine.swift
//  FightCityiOSTests
//
//  Mock implementation of OCREngine for testing
//

import Vision
import UIKit
@testable import FightCityiOS
@testable import FightCityFoundation

/// Mock OCR engine for unit testing
final class MockOCREngine: OCREngineProtocol {
    
    // MARK: - Properties
    
    var shouldFail: Bool = false
    var shouldReturnLowConfidence: Bool = false
    var simulatedDelay: TimeInterval = 0
    
    var recognizeTextCalled: Bool = false
    var recognizeWithHighAccuracyCalled: Bool = false
    var recognizeFastCalled: Bool = false
    
    // Configurable responses
    var mockText: String = ""
    var mockConfidence: Float = 0.95
    var mockObservations: [MockObservation] = []
    var mockMatchedCityId: String? = "us-ca-san_francisco"
    var mockProcessingTime: TimeInterval = 0.5
    
    // MARK: - Initialization
    
    init(
        mockText: String = "SFMTA91234567",
        mockConfidence: Float = 0.95,
        mockMatchedCityId: String? = "us-ca-san_francisco"
    ) {
        self.mockText = mockText
        self.mockConfidence = mockConfidence
        self.mockMatchedCityId = mockMatchedCityId
        self.mockObservations = [MockObservation(text: mockText, confidence: mockConfidence)]
    }
    
    // MARK: - OCREngine Protocol
    
    func recognizeText(imageData: Data, configuration: OCRConfiguration) async throws -> OCRRecognitionResult {
        recognizeTextCalled = true
        
        if shouldFail {
            throw OCRError.recognitionFailed
        }
        
        if simulatedDelay > 0 {
            try await Task.sleep(nanoseconds: UInt64(simulatedDelay * 1_000_000_000))
        }
        
        return createMockResult(configuration: configuration)
    }
    
    func recognizeWithHighAccuracy(imageData: Data) async throws -> OCRRecognitionResult {
        recognizeWithHighAccuracyCalled = true
        
        if shouldFail {
            throw OCRError.recognitionFailed
        }
        
        var config = OCRConfiguration()
        config.recognitionLevel = .accurate
        return createMockResult(configuration: config)
    }
    
    func recognizeFast(imageData: Data) async throws -> OCRRecognitionResult {
        recognizeFastCalled = true
        
        if shouldFail {
            throw OCRError.recognitionFailed
        }
        
        var config = OCRConfiguration()
        config.recognitionLevel = .fast
        return createMockResult(configuration: config)
    }
    
    // MARK: - Private Helpers
    
    private func createMockResult(configuration: OCRConfiguration) -> OCRRecognitionResult {
        let confidence = shouldReturnLowConfidence ? 0.40 : mockConfidence
        let observations = createObservations(confidence: confidence)
        
        return OCRRecognitionResult(
            text: mockText,
            observations: observations,
            confidence: Double(confidence),
            processingTime: mockProcessingTime,
            matchedCityId: mockMatchedCityId
        )
    }
    
    private func createObservations(confidence: Float) -> [VNRecognizedTextObservation] {
        // Create mock observations with the specified confidence
        var observations: [VNRecognizedTextObservation] = []
        
        for i in 0..<3 {
            let observation = MockObservation(
                text: mockText,
                confidence: confidence,
                topCandidatesCount: 3
            )
            (observation as! VNRecognizedTextObservation).mockCandidates = [
                MockRecognizedText(string: mockText, confidence: confidence),
                MockRecognizedText(string: mockText.lowercased(), confidence: confidence - 0.1),
                MockRecognizedText(string: "UNKNOWN", confidence: confidence - 0.3)
            ]
            observations.append(observation as! VNRecognizedTextObservation)
        }
        
        return observations
    }
    
    // MARK: - Test Helpers
    
    func resetCalls() {
        recognizeTextCalled = false
        recognizeWithHighAccuracyCalled = false
        recognizeFastCalled = false
    }
    
    func configureForSFPattern() {
        mockText = "SFMTA91234567"
        mockConfidence = 0.95
        mockMatchedCityId = "us-ca-san_francisco"
    }
    
    func configureForNYCPattern() {
        mockText = "1234567890"
        mockConfidence = 0.92
        mockMatchedCityId = "us-ny-new_york"
    }
    
    func configureForNoMatch() {
        mockText = "UNKNOWN123"
        mockConfidence = 0.45
        mockMatchedCityId = nil
    }
    
    func configureForLowConfidence() {
        shouldReturnLowConfidence = true
        mockConfidence = 0.40
    }
}

// MARK: - OCR Engine Protocol

/// Protocol defining OCR engine interface for dependency injection
public protocol OCREngineProtocol {
    func recognizeText(imageData: Data, configuration: OCRConfiguration) async throws -> OCRRecognitionResult
    func recognizeWithHighAccuracy(imageData: Data) async throws -> OCRRecognitionResult
    func recognizeFast(imageData: Data) async throws -> OCRRecognitionResult
}

// MARK: - OCR Configuration

/// Configuration for OCR processing
public struct OCRConfiguration {
    public var recognitionLevel: RecognitionLevel = .accurate
    public var usesLanguageCorrection: Bool = true
    public var recognitionLanguages: [String] = ["en"]
    public var autoDetectLanguage: Bool = false
    
    public init() {}
    
    public enum RecognitionLevel {
        case fast
        case accurate
    }
}

// MARK: - OCR Result

/// Result from OCR processing
public struct OCRRecognitionResult {
    public let text: String
    public let observations: [VNRecognizedTextObservation]
    public let confidence: Double
    public let processingTime: Double
    public let matchedCityId: String?
}

// MARK: - OCR Error

public enum OCRError: LocalizedError {
    case recognitionFailed
    case invalidImage
    case unsupportedLanguage
    
    public var errorDescription: String? {
        switch self {
        case .recognitionFailed:
            return "Text recognition failed"
        case .invalidImage:
            return "Invalid image data"
        case .unsupportedLanguage:
            return "Unsupported language"
        }
    }
}

// MARK: - Mock Observation

/// Mock observation for testing
class MockObservation: VNRecognizedTextObservation {
    var mockText: String
    var mockConfidence: Float
    var mockCandidates: [MockRecognizedText] = []
    var topCandidatesCount: Int = 1
    
    init(text: String, confidence: Float, topCandidatesCount: Int = 1) {
        self.mockText = text
        self.mockConfidence = confidence
        self.topCandidatesCount = topCandidatesCount
        super.init(topCandidates: 1)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func topCandidates(_ maxCandidatesCount: Int) -> [VNRecognizedText] {
        return mockCandidates.prefix(maxCandidatesCount).map { $0 }
    }
}

// MARK: - Mock Recognized Text

class MockRecognizedText: VNRecognizedText {
    private let mockString: String
    private let mockConfidence: Float
    
    init(string: String, confidence: Float) {
        self.mockString = string
        self.mockConfidence = confidence
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var string: String { mockString }
    override var confidence: Float { mockConfidence }
}
