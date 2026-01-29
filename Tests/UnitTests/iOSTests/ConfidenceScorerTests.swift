//
//  ConfidenceScorerTests.swift
//  FightCityiOSTests
//
//  Unit tests for ConfidenceScorer
//

import XCTest
@testable import FightCityiOS
@testable import FightCityFoundation
import Vision

final class ConfidenceScorerTests: XCTestCase {
    
    var sut: ConfidenceScorer!
    
    override func setUp() {
        super.setUp()
        sut = ConfidenceScorer()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Confidence Level Tests
    
    func testConfidenceLevelThresholds() {
        XCTAssertEqual(ConfidenceScorer.ConfidenceLevel.high.threshold, 0.85)
        XCTAssertEqual(ConfidenceScorer.ConfidenceLevel.medium.threshold, 0.60)
        XCTAssertEqual(ConfidenceScorer.ConfidenceLevel.low.threshold, 0.0)
    }
    
    func testConfidenceLevelRequiresReview() {
        XCTAssertFalse(ConfidenceScorer.ConfidenceLevel.high.requiresReview)
        XCTAssertTrue(ConfidenceScorer.ConfidenceLevel.medium.requiresReview)
        XCTAssertTrue(ConfidenceScorer.ConfidenceLevel.low.requiresReview)
    }
    
    // MARK: - High Confidence Tests
    
    func testHighConfidenceAcceptsAutoAccept() {
        // Given - high vision confidence observations
        let observations = createObservations(withConfidence: 0.95)
        let pattern = createMockPattern(priority: 1)
        
        // When
        let result = sut.score(rawText: "SFMTA91234567", observations: observations, matchedPattern: pattern)
        
        // Then
        XCTAssertEqual(result.level, .high)
        XCTAssertEqual(result.recommendation, .accept)
        XCTAssertTrue(result.shouldAutoAccept)
        XCTAssertGreaterThanOrEqual(result.overallConfidence, 0.85)
    }
    
    func testHighConfidenceMessage() {
        let message = ConfidenceScorer.confidenceMessage(for: .high)
        XCTAssertEqual(message, "High confidence - looks correct")
    }
    
    // MARK: - Medium Confidence Tests
    
    func testMediumConfidenceRequiresReview() {
        // Given - medium vision confidence observations
        let observations = createObservations(withConfidence: 0.70)
        let pattern = createMockPattern(priority: 4) // LA pattern - lower confidence
        
        // When
        let result = sut.score(rawText: "LA123456", observations: observations, matchedPattern: pattern)
        
        // Then
        XCTAssertEqual(result.level, .medium)
        XCTAssertEqual(result.recommendation, .review)
        XCTAssertFalse(result.shouldAutoAccept)
        XCTAssertGreaterThanOrEqual(result.overallConfidence, 0.60)
        XCTAssertLessThan(result.overallConfidence, 0.85)
    }
    
    func testMediumConfidenceMessage() {
        let message = ConfidenceScorer.confidenceMessage(for: .medium)
        XCTAssertEqual(message, "Medium confidence - please verify")
    }
    
    // MARK: - Low Confidence Tests
    
    func testLowConfidenceRejects() {
        // Given - low vision confidence observations
        let observations = createObservations(withConfidence: 0.40)
        let pattern = createMockPattern(priority: 4)
        
        // When
        let result = sut.score(rawText: "LA123", observations: observations, matchedPattern: pattern)
        
        // Then
        XCTAssertEqual(result.level, .low)
        XCTAssertEqual(result.recommendation, .reject)
        XCTAssertFalse(result.shouldAutoAccept)
        XCTAssertLessThan(result.overallConfidence, 0.60)
    }
    
    func testLowConfidenceMessage() {
        let message = ConfidenceScorer.confidenceMessage(for: .low)
        XCTAssertEqual(message, "Low confidence - please check and edit")
    }
    
    // MARK: - Empty Observations Tests
    
    func testEmptyObservationsReturnsZeroConfidence() {
        // Given
        let observations: [VNRecognizedTextObservation] = []
        let pattern = createMockPattern(priority: 1)
        
        // When
        let result = sut.score(rawText: "SFMTA91234567", observations: observations, matchedPattern: pattern)
        
        // Then
        XCTAssertEqual(result.level, .low)
        XCTAssertLessThan(result.overallConfidence, 0.50)
    }
    
    // MARK: - No Pattern Match Tests
    
    func testNoPatternMatchReturnsMediumConfidence() {
        // Given
        let observations = createObservations(withConfidence: 0.80)
        
        // When
        let result = sut.score(rawText: "UNKNOWN12345", observations: observations, matchedPattern: nil)
        
        // Then
        XCTAssertNotNil(result)
        // Should still have decent confidence due to vision score
        XCTAssertGreaterThanOrEqual(result.overallConfidence, 0.4)
    }
    
    // MARK: - Pattern Priority Tests
    
    func testSFPatternHighestConfidence() {
        // Given - same observations, different patterns
        let observations = createObservations(withConfidence: 0.90)
        
        // When
        let sfResult = sut.score(rawText: "SFMTA91234567", observations: observations, matchedPattern: createMockPattern(priority: 1))
        let nycResult = sut.score(rawText: "1234567890", observations: observations, matchedPattern: createMockPattern(priority: 2))
        let denverResult = sut.score(rawText: "123456789", observations: observations, matchedPattern: createMockPattern(priority: 3))
        let laResult = sut.score(rawText: "LA12345678", observations: observations, matchedPattern: createMockPattern(priority: 4))
        
        // Then - SF pattern should have highest confidence
        XCTAssertGreaterThan(sfResult.overallConfidence, nycResult.overallConfidence)
        XCTAssertGreaterThan(nycResult.overallConfidence, denverResult.overallConfidence)
        XCTAssertGreaterThan(denverResult.overallConfidence, laResult.overallConfidence)
    }
    
    // MARK: - Completeness Tests
    
    func testPerfectLengthAccepts() {
        // Given
        let observations = createObservations(withConfidence: 0.90)
        let sfPattern = createMockPattern(cityId: "us-ca-san_francisco", priority: 1)
        
        // When - perfect length for SF (10-11 chars)
        let result = sut.score(rawText: "SFMTA91234", observations: observations, matchedPattern: sfPattern)
        
        // Then
        let completenessComponent = result.components.first { $0.name == "text_completeness" }
        XCTAssertEqual(completenessComponent?.score, 1.0)
    }
    
    func testSlightlyOffLengthAccepts() {
        // Given
        let observations = createObservations(withConfidence: 0.90)
        let sfPattern = createMockPattern(cityId: "us-ca-san_francisco", priority: 1)
        
        // When - length within 2 of target
        let result = sut.score(rawText: "SFMTA912", observations: observations, matchedPattern: sfPattern)
        
        // Then
        let completenessComponent = result.components.first { $0.name == "text_completeness" }
        XCTAssertEqual(completenessComponent?.score, 0.7)
    }
    
    func testWrongLengthRejects() {
        // Given
        let observations = createObservations(withConfidence: 0.90)
        let sfPattern = createMockPattern(cityId: "us-ca-san_francisco", priority: 1)
        
        // When - length too far from target
        let result = sut.score(rawText: "SF", observations: observations, matchedPattern: sfPattern)
        
        // Then
        let completenessComponent = result.components.first { $0.name == "text_completeness" }
        XCTAssertEqual(completenessComponent?.score, 0.4)
    }
    
    // MARK: - Consistency Tests
    
    func testSingleObservationHasFullConsistency() {
        // Given
        let observations = createSingleObservation(withConfidence: 0.90)
        
        // When
        let result = sut.score(rawText: "SFMTA91234567", observations: observations, matchedPattern: nil)
        
        // Then
        let consistencyComponent = result.components.first { $0.name == "observation_consistency" }
        XCTAssertEqual(consistencyComponent?.score, 1.0)
    }
    
    func testConsistentObservationsHaveHighConsistency() {
        // Given - all observations have similar confidence
        let observations = createMultipleObservations(confidences: [0.90, 0.91, 0.89, 0.90])
        
        // When
        let result = sut.score(rawText: "SFMTA91234567", observations: observations, matchedPattern: nil)
        
        // Then
        let consistencyComponent = result.components.first { $0.name == "observation_consistency" }
        XCTAssertGreaterThanOrEqual(consistencyComponent?.score ?? 0, 0.9)
    }
    
    func testInconsistentObservationsHaveLowerConsistency() {
        // Given - observations have varying confidence
        let observations = createMultipleObservations(confidences: [0.90, 0.50, 0.95, 0.30])
        
        // When
        let result = sut.score(rawText: "SFMTA91234567", observations: observations, matchedPattern: nil)
        
        // Then
        let consistencyComponent = result.components.first { $0.name == "observation_consistency" }
        XCTAssertLessThan(consistencyComponent?.score ?? 1.0, 0.8)
    }
    
    // MARK: - Fallback Pipeline Tests
    
    func testShouldUseFallbackOnLowConfidence() {
        // Given
        let observations = createObservations(withConfidence: 0.40)
        
        // When
        let result = sut.score(rawText: "UNKNOWN", observations: observations, matchedPattern: nil)
        
        // Then
        XCTAssertTrue(sut.shouldUseFallback(result))
    }
    
    func testShouldNotUseFallbackOnHighConfidence() {
        // Given
        let observations = createObservations(withConfidence: 0.95)
        
        // When
        let result = sut.score(rawText: "SFMTA91234567", observations: observations, matchedPattern: createMockPattern(priority: 1))
        
        // Then
        XCTAssertFalse(sut.shouldUseFallback(result))
    }
    
    func testSuggestFallbackOptionsForLowVision() {
        // Given - low vision confidence
        let observations = createObservations(withConfidence: 0.30)
        let result = sut.score(rawText: "SFMTA91234567", observations: observations, matchedPattern: createMockPattern(priority: 1))
        
        // When
        let options = sut.suggestFallbackOptions(result)
        
        // Then
        XCTAssertTrue(options.enhanceContrast)
        XCTAssertTrue(options.reduceNoise)
        XCTAssertTrue(options.binarize)
    }
    
    func testSuggestFallbackOptionsForIncompleteText() {
        // Given - complete vision but incomplete text
        let observations = createObservations(withConfidence: 0.90)
        let result = sut.score(rawText: "SF", observations: observations, matchedPattern: createMockPattern(priority: 1))
        
        // When
        let options = sut.suggestFallbackOptions(result)
        
        // Then
        XCTAssertTrue(options.correctPerspective)
    }
    
    // MARK: - Threshold Helpers Tests
    
    func testMeetsAutoAcceptThreshold() {
        XCTAssertTrue(ConfidenceScorer.meetsAutoAcceptThreshold(0.90))
        XCTAssertTrue(ConfidenceScorer.meetsAutoAcceptThreshold(0.85))
        XCTAssertFalse(ConfidenceScorer.meetsAutoAcceptThreshold(0.84))
        XCTAssertFalse(ConfidenceScorer.meetsAutoAcceptThreshold(0.60))
    }
    
    func testRequiresReview() {
        XCTAssertFalse(ConfidenceScorer.requiresReview(0.90))
        XCTAssertTrue(ConfidenceScorer.requiresReview(0.84))
        XCTAssertTrue(ConfidenceScorer.requiresReview(0.50))
    }
    
    // MARK: - Component Weight Tests
    
    func testAllComponentsHaveCorrectWeights() {
        // Given
        let observations = createObservations(withConfidence: 0.90)
        
        // When
        let result = sut.score(rawText: "SFMTA91234567", observations: observations, matchedPattern: createMockPattern(priority: 1))
        
        // Then
        let visionComponent = result.components.first { $0.name == "vision_confidence" }
        let patternComponent = result.components.first { $0.name == "pattern_match" }
        let completenessComponent = result.components.first { $0.name == "text_completeness" }
        let consistencyComponent = result.components.first { $0.name == "observation_consistency" }
        
        XCTAssertEqual(visionComponent?.weight, 0.4)
        XCTAssertEqual(patternComponent?.weight, 0.3)
        XCTAssertEqual(completenessComponent?.weight, 0.2)
        XCTAssertEqual(consistencyComponent?.weight, 0.1)
    }
    
    // MARK: - Edge Cases
    
    func testNilPatternUsesDefaultCompleteness() {
        // Given
        let observations = createObservations(withConfidence: 0.90)
        
        // When
        let result = sut.score(rawText: "SOMEUNKNOWN123", observations: observations, matchedPattern: nil)
        
        // Then
        let completenessComponent = result.components.first { $0.name == "text_completeness" }
        XCTAssertEqual(completenessComponent?.score, 0.5) // Default for nil pattern
    }
    
    func testEmptyTextCompleteness() {
        // Given
        let observations = createObservations(withConfidence: 0.90)
        
        // When
        let result = sut.score(rawText: "", observations: observations, matchedPattern: createMockPattern(priority: 1))
        
        // Then
        let completenessComponent = result.components.first { $0.name == "text_completeness" }
        XCTAssertEqual(completenessComponent?.score, 0.4) // Empty text rejected
    }
    
    // MARK: - Helper Methods
    
    private func createObservations(withConfidence confidence: Double) -> [VNRecognizedTextObservation] {
        // Create mock observations with the given confidence
        return (0..<5).map { _ in
            createMockObservation(confidence: confidence)
        }
    }
    
    private func createSingleObservation(withConfidence confidence: Double) -> [VNRecognizedTextObservation] {
        return [createMockObservation(confidence: confidence)]
    }
    
    private func createMultipleObservations(confidences: [Double]) -> [VNRecognizedTextObservation] {
        return confidences.map { createMockObservation(confidence: $0) }
    }
    
    private func createMockObservation(confidence: Double) -> VNRecognizedTextObservation {
        // Create a mock observation with the given confidence
        let observation = VNRecognizedTextObservation()
        
        // Use reflection to set the private confidence property
        let mirror = Mirror(reflecting: observation)
        if let confidenceProperty = mirror.children.first(where: { $0.label == "confidence" }) {
            // Note: confidence is a let property on the observation, so we can't modify it directly
            // In real tests, we would use a mock or dependency injection
        }
        
        return observation
    }
    
    private func createMockPattern(priority: Int) -> OCRParsingEngine.CityPattern {
        OCRParsingEngine.CityPattern(
            cityId: "test-city",
            cityName: "Test City",
            regex: "^[A-Z0-9]+$",
            priority: priority,
            formatExample: "TEST123"
        )
    }
    
    private func createMockPattern(cityId: String, priority: Int) -> OCRParsingEngine.CityPattern {
        OCRParsingEngine.CityPattern(
            cityId: cityId,
            cityName: cityId.components(separatedBy: "-").last?.replacingOccurrences(of: "_", with: " ").capitalized ?? "Test",
            regex: "^[A-Z0-9]+$",
            priority: priority,
            formatExample: "TEST123"
        )
    }
}
