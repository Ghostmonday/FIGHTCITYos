//
//  ConfidenceScorerTests.swift
//  UnitTests
//
//  Tests for confidence scoring algorithm
//

import XCTest
@testable import FightCityFoundation

final class ConfidenceScorerTests: XCTestCase {
    var sut: ConfidenceScorer!
    var mockLogger: MockLogger!
    
    override func setUp() {
        super.setUp()
        mockLogger = MockLogger()
        sut = ConfidenceScorer(logger: mockLogger)
    }
    
    override func tearDown() {
        sut = nil
        mockLogger = nil
        super.tearDown()
    }
    
    // MARK: - Vision Confidence Tests
    
    func testHighVisionConfidenceProducesHighOverall() {
        // Given
        let observations = [
            OCRObservation(text: "SFMTA12345678", confidence: 0.95, boundingBox: .zero),
            OCRObservation(text: "Violation", confidence: 0.92, boundingBox: .zero)
        ]
        
        // When
        let result = sut.score(rawText: "SFMTA12345678", observations: observations, matchedPattern: nil)
        
        // Then
        XCTAssertGreaterThan(result.overallConfidence, 0.85)
        XCTAssertEqual(result.level, .high)
        XCTAssertEqual(result.recommendation, .accept)
    }
    
    func testLowVisionConfidenceProducesLowOverall() {
        // Given
        let observations = [
            OCRObservation(text: "Unclear", confidence: 0.45, boundingBox: .zero),
            OCRObservation(text: "Text", confidence: 0.50, boundingBox: .zero)
        ]
        
        // When
        let result = sut.score(rawText: "Unclear Text", observations: observations, matchedPattern: nil)
        
        // Then
        XCTAssertLessThan(result.overallConfidence, 0.60)
        XCTAssertEqual(result.level, .low)
        XCTAssertEqual(result.recommendation, .reject)
    }
    
    // MARK: - Pattern Match Tests
    
    func testPatternMatchImprovesConfidence() {
        // Given
        let observations = [
            OCRObservation(text: "SFMTA12345678", confidence: 0.80, boundingBox: .zero)
        ]
        
        let sfPattern = CityPattern(
            cityId: "us-ca-san_francisco",
            cityName: "San Francisco",
            pattern: "^(SFMTA|MT)[0-9]{8}$",
            priority: 1,
            deadlineDays: 21,
            canAppealOnline: true,
            phoneConfirmationRequired: true
        )
        
        // When
        let result = sut.score(rawText: "SFMTA12345678", observations: observations, matchedPattern: sfPattern)
        
        // Then
        XCTAssertGreaterThan(result.overallConfidence, 0.80) // Should be boosted by pattern match
    }
    
    // MARK: - Component Breakdown Tests
    
    func testComponentsHaveCorrectWeights() {
        // Given
        let observations = [
            OCRObservation(text: "Test", confidence: 0.90, boundingBox: .zero)
        ]
        
        // When
        let result = sut.score(rawText: "Test", observations: observations, matchedPattern: nil)
        
        // Then
        XCTAssertEqual(result.components.count, 4)
        
        let componentNames = result.components.map { $0.name }
        XCTAssertTrue(componentNames.contains("vision"))
        XCTAssertTrue(componentNames.contains("pattern"))
        XCTAssertTrue(componentNames.contains("completeness"))
        XCTAssertTrue(componentNames.contains("consistency"))
    }
    
    // MARK: - Empty Observations Tests
    
    func testEmptyObservationsProducesZeroConfidence() {
        // When
        let result = sut.score(rawText: "", observations: [], matchedPattern: nil)
        
        // Then
        XCTAssertEqual(result.overallConfidence, 0)
        XCTAssertEqual(result.level, .low)
        XCTAssertEqual(result.recommendation, .reject)
    }
}

// MARK: - ConfidenceScorer Implementation

public final class ConfidenceScorer {
    private let logger: LoggerProtocol
    private let visionWeight = 0.40
    private let patternWeight = 0.30
    private let completenessWeight = 0.20
    private let consistencyWeight = 0.10
    
    public init(logger: LoggerProtocol = Logger.shared) {
        self.logger = logger
    }
    
    public func score(rawText: String, observations: [OCRObservation], matchedPattern: CityPattern?) -> ConfidenceResult {
        guard !observations.isEmpty else {
            return ConfidenceResult(
                overallConfidence: 0,
                level: .low,
                components: [],
                recommendation: .reject
            )
        }
        
        // Vision confidence (40%)
        let visionScore = observations.map { $0.confidence }.reduce(0, +) / Double(observations.count)
        let visionComponent = ConfidenceComponent(
            name: "vision",
            score: visionScore,
            weight: visionWeight,
            weightedScore: visionScore * visionWeight
        )
        
        // Pattern confidence (30%)
        let patternScore = matchedPattern != nil ? 1.0 : 0.5
        let patternComponent = ConfidenceComponent(
            name: "pattern",
            score: patternScore,
            weight: patternWeight,
            weightedScore: patternScore * patternWeight
        )
        
        // Completeness (20%)
        let completenessScore = calculateCompleteness(rawText: rawText, pattern: matchedPattern)
        let completenessComponent = ConfidenceComponent(
            name: "completeness",
            score: completenessScore,
            weight: completenessWeight,
            weightedScore: completenessScore * completenessWeight
        )
        
        // Consistency (10%)
        let consistencyScore = calculateConsistency(observations: observations)
        let consistencyComponent = ConfidenceComponent(
            name: "consistency",
            score: consistencyScore,
            weight: consistencyWeight,
            weightedScore: consistencyScore * consistencyWeight
        )
        
        let components = [visionComponent, patternComponent, completenessComponent, consistencyComponent]
        let overall = components.reduce(0) { $0 + $1.weightedScore }
        
        let level: ConfidenceLevel
        let recommendation: Recommendation
        
        if overall >= 0.85 {
            level = .high
            recommendation = .accept
        } else if overall >= 0.60 {
            level = .medium
            recommendation = .review
        } else {
            level = .low
            recommendation = .reject
        }
        
        logger.debug("Confidence scored: \(overall) (\(level.rawValue))")
        
        return ConfidenceResult(
            overallConfidence: overall,
            level: level,
            components: components,
            recommendation: recommendation
        )
    }
    
    private func calculateCompleteness(rawText: String, pattern: CityPattern?) -> Double {
        guard !rawText.isEmpty else { return 0 }
        
        if let pattern = pattern {
            // Check if text length is reasonable for the pattern
            let minLength = 6
            let maxLength = 20
            let textLength = rawText.count
            
            if textLength >= minLength && textLength <= maxLength {
                return 1.0
            } else if textLength < minLength {
                return Double(textLength) / Double(minLength)
            } else {
                return Double(maxLength) / Double(textLength)
            }
        }
        
        return 0.7 // Default for unknown pattern
    }
    
    private func calculateConsistency(observations: [OCRObservation]) -> Double {
        guard observations.count > 1 else { return 1.0 }
        
        let confidences = observations.map { $0.confidence }
        let mean = confidences.reduce(0, +) / Double(confidences.count)
        let variance = confidences.reduce(0) { $0 + pow($1 - mean, 2) } / Double(confidences.count)
        let stdDev = sqrt(variance)
        
        // Lower standard deviation = higher consistency
        return max(0, 1.0 - stdDev * 2)
    }
}
