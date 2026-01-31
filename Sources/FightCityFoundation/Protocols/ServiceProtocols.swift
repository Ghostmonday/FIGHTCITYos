//
//  ServiceProtocols.swift
//  FightCityFoundation
//
//  Protocol definitions for dependency injection and testability
//

import Foundation

// MARK: - Camera Protocol

/// Protocol for camera operations - enables mock testing
public protocol CameraManagerProtocol {
    var isAuthorized: Bool { get }
    var isSessionRunning: Bool { get }
    
    func requestAuthorization() async -> Bool
    func setupSession() async throws
    func startSession() async
    func stopSession() async
    func capturePhoto() async throws -> Data?
    func switchCamera() async
    func setZoom(_ factor: Float) async
    func toggleTorch() async
}

// MARK: - API Client Protocol

/// Protocol for API client - enables mock testing
public protocol APIClientProtocol {
    func get<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T
    func post<T: Decodable, B: Encodable>(_ endpoint: APIEndpoint, body: B) async throws -> T
    func postVoid<B: Encodable>(_ endpoint: APIEndpoint, body: B) async throws
    func validateCitation(_ request: CitationValidationRequest) async throws -> CitationValidationResponse
}

// MARK: - Confidence Result Types

/// Confidence result
public struct ConfidenceResult {
    public let overallConfidence: Double
    public let level: ConfidenceLevel
    public let components: [ConfidenceComponent]
    public let recommendation: Recommendation
    
    public init(
        overallConfidence: Double,
        level: ConfidenceLevel,
        components: [ConfidenceComponent],
        recommendation: Recommendation
    ) {
        self.overallConfidence = overallConfidence
        self.level = level
        self.components = components
        self.recommendation = recommendation
    }
}

public enum ConfidenceLevel: String {
    case high
    case medium
    case low
}

public enum Recommendation: String {
    case accept
    case review
    case reject
}

public struct ConfidenceComponent {
    public let name: String
    public let score: Double
    public let weight: Double
    public let weightedScore: Double
    
    public init(name: String, score: Double, weight: Double, weightedScore: Double) {
        self.name = name
        self.score = score
        self.weight = weight
        self.weightedScore = weightedScore
    }
}

// MARK: - Pattern Matching Protocol

/// Protocol for citation pattern matching
public protocol PatternMatcherProtocol {
    func match(_ text: String) -> PatternMatchResult
}

/// Result of pattern matching
public struct PatternMatchResult {
    public let cityId: String?
    public let pattern: CityPattern?
    public let priority: Int
    
    public init(cityId: String?, pattern: CityPattern?, priority: Int) {
        self.cityId = cityId
        self.pattern = pattern
        self.priority = priority
    }
    
    public var isMatch: Bool { pattern != nil }
}

/// City pattern configuration
public struct CityPattern: Codable {
    public let cityId: String
    public let cityName: String
    public let pattern: String
    public let priority: Int
    public let deadlineDays: Int
    public let canAppealOnline: Bool
    public let phoneConfirmationRequired: Bool
    
    public init(
        cityId: String,
        cityName: String,
        pattern: String,
        priority: Int,
        deadlineDays: Int,
        canAppealOnline: Bool,
        phoneConfirmationRequired: Bool
    ) {
        self.cityId = cityId
        self.cityName = cityName
        self.pattern = pattern
        self.priority = priority
        self.deadlineDays = deadlineDays
        self.canAppealOnline = canAppealOnline
        self.phoneConfirmationRequired = phoneConfirmationRequired
    }
}

// MARK: - Frame Quality Protocol

/// Protocol for frame quality analysis
public protocol FrameQualityAnalyzerProtocol {
    func analyze(_ imageData: Data) -> QualityAnalysisResult
}

/// Result of quality analysis
public struct QualityAnalysisResult {
    public let isAcceptable: Bool
    public let feedbackMessage: String?
    public let warnings: [QualityWarning]
    
    public init(isAcceptable: Bool, feedbackMessage: String?, warnings: [QualityWarning]) {
        self.isAcceptable = isAcceptable
        self.feedbackMessage = feedbackMessage
        self.warnings = warnings
    }
}

public enum QualityWarning: String {
    case blurry
    case tooDark
    case tooBright
    case skewed
    case tooFar
    case tooClose
}
