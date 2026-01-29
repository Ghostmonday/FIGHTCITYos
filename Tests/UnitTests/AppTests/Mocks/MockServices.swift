//
//  MockServices.swift
//  UnitTests
//
//  Mock implementations for testing
//

import Foundation
import FightCityFoundation
import FightCityiOS

// MARK: - Mock OCR Engine

public final class MockOCREngine: OCREngineProtocol {
    public var shouldFail = false
    public var failError = OCRError.noTextFound
    public var nextResult: OCRRecognitionResult?
    
    public init() {}
    
    public func recognizeText(in imageData: Data, configuration: OCRConfiguration) async throws -> OCRRecognitionResult {
        if shouldFail {
            throw failError
        }
        return nextResult ?? OCRRecognitionResult(
            text: "SFMTA12345678",
            confidence: 0.92,
            processingTime: 0.5,
            observations: [
                OCRObservation(text: "SFMTA12345678", confidence: 0.92, boundingBox: .zero)
            ]
        )
    }
    
    public func recognizeWithHighAccuracy(in imageData: Data) async throws -> OCRRecognitionResult {
        return try await recognizeText(in: imageData, configuration: OCRConfiguration(recognitionLevel: .accurate))
    }
    
    public func recognizeFast(in imageData: Data) async throws -> OCRRecognitionResult {
        return try await recognizeText(in: imageData, configuration: OCRConfiguration(recognitionLevel: .fast))
    }
}

// MARK: - Mock Camera Manager

public final class MockCameraManager: CameraManagerProtocol {
    public var isAuthorized = true
    public var isSessionRunning = false
    public var shouldFailAuthorization = false
    public var shouldFailCapture = false
    public var capturedImages: [Data] = []
    
    public init() {}
    
    public func requestAuthorization() async -> Bool {
        if shouldFailAuthorization {
            return false
        }
        return isAuthorized
    }
    
    public func setupSession() async throws {
        // No-op for mock
    }
    
    public func startSession() async {
        isSessionRunning = true
    }
    
    public func stopSession() async {
        isSessionRunning = false
    }
    
    public func capturePhoto() async throws -> Data? {
        if shouldFailCapture {
            return nil
        }
        let imageData = UIImage.pngData(UIImage())()
        capturedImages.append(imageData)
        return imageData
    }
    
    public func switchCamera() async {
        // No-op for mock
    }
    
    public func setZoom(_ factor: Float) async {
        // No-op for mock
    }
    
    public func toggleTorch() async {
        // No-op for mock
    }
}

// MARK: - Mock API Client

public final class MockAPIClient: APIClientProtocol {
    public var shouldFail = false
    public var failError = APIError.networkUnavailable
    public var nextResponse: CitationValidationResponse?
    public var capturedRequests: [CitationValidationRequest] = []
    
    public init() {}
    
    public func get<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        if shouldFail {
            throw failError
        }
        // swiftlint:disable force_cast
        return nextResponse as! T
        // swiftlint:enable force_cast
    }
    
    public func post<T: Decodable, B: Encodable>(_ endpoint: APIEndpoint, body: B) async throws -> T {
        if shouldFail {
            throw failError
        }
        
        if let request = body as? CitationValidationRequest {
            capturedRequests.append(request)
        }
        
        // swiftlint:disable force_cast
        return nextResponse as! T
        // swiftlint:enable force_cast
    }
    
    public func postVoid<B: Encodable>(_ endpoint: APIEndpoint, body: B) async throws {
        if shouldFail {
            throw failError
        }
    }
    
    public func validateCitation(_ request: CitationValidationRequest) async throws -> CitationValidationResponse {
        capturedRequests.append(request)
        
        if shouldFail {
            throw failError
        }
        
        return nextResponse ?? CitationValidationResponse(
            isValid: true,
            citation: Citation(
                id: UUID(),
                citationNumber: request.citation_number,
                cityId: request.city_id,
                cityName: "Test City",
                agency: "TEST",
                violationDate: Date(),
                amount: 95.00,
                deadlineDate: Calendar.current.date(byAdding: .day, value: 21, to: Date()),
                daysRemaining: 21,
                isPastDeadline: false,
                isUrgent: false,
                canAppealOnline: true,
                phoneConfirmationRequired: true,
                status: .validated
            ),
            confidence: 0.92
        )
    }
}

// MARK: - Mock Confidence Scorer

public final class MockConfidenceScorer: ConfidenceScorerProtocol {
    public var nextResult: ConfidenceResult!
    
    public init() {}
    
    public func score(rawText: String, observations: [OCRObservation], matchedPattern: CityPattern?) -> ConfidenceResult {
        return nextResult ?? ConfidenceResult(
            overallConfidence: 0.85,
            level: .high,
            components: [],
            recommendation: .accept
        )
    }
}

// MARK: - Mock Pattern Matcher

public final class MockPatternMatcher: PatternMatcherProtocol {
    public var nextResult: PatternMatchResult!
    
    public init() {}
    
    public func match(_ text: String) -> PatternMatchResult {
        return nextResult ?? PatternMatchResult(
            cityId: "us-ca-san_francisco",
            pattern: CityPattern(
                cityId: "us-ca-san_francisco",
                cityName: "San Francisco",
                pattern: "^(SFMTA|MT)[0-9]{8}$",
                priority: 1,
                deadlineDays: 21,
                canAppealOnline: true,
                phoneConfirmationRequired: true
            ),
            priority: 1
        )
    }
}

// MARK: - Mock Frame Quality Analyzer

public final class MockFrameQualityAnalyzer: FrameQualityAnalyzerProtocol {
    public var nextResult: QualityAnalysisResult!
    
    public init() {}
    
    public func analyze(_ imageData: Data) -> QualityAnalysisResult {
        return nextResult ?? QualityAnalysisResult(
            isAcceptable: true,
            feedbackMessage: nil,
            warnings: []
        )
    }
}

// MARK: - Mock Image Preprocessor

public final class MockImagePreprocessor: ImagePreprocessorProtocol {
    public var shouldFail = false
    public var nextOutput: Data!
    
    public init() {}
    
    public func preprocess(_ imageData: Data) async throws -> Data {
        if shouldFail {
            throw NSError(domain: "MockPreprocessor", code: 1)
        }
        return nextOutput ?? imageData
    }
}

// MARK: - Mock History Storage

public final class MockHistoryStorage: HistoryStorageProtocol {
    public var citations: [Citation] = []
    public var shouldFail = false
    
    public init() {}
    
    public func loadHistory() async throws -> [Citation] {
        if shouldFail {
            throw NSError(domain: "MockStorage", code: 1)
        }
        return citations
    }
    
    public func saveCitation(_ citation: Citation) async throws {
        if shouldFail {
            throw NSError(domain: "MockStorage", code: 1)
        }
        citations.insert(citation, at: 0)
    }
    
    public func deleteCitation(_ id: UUID) async throws {
        if shouldFail {
            throw NSError(domain: "MockStorage", code: 1)
        }
        citations.removeAll { $0.id == id }
    }
}
