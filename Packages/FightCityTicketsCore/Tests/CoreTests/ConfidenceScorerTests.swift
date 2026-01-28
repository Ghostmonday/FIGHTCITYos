//
//  ConfidenceScorerTests.swift
//  FightCityTicketsCoreTests
//
//  Unit tests for confidence scoring logic
//

import XCTest
@testable import FightCityTicketsCore

final class ConfidenceScorerTests: XCTestCase {
    
    var scorer: ConfidenceScorer!
    
    override func setUp() {
        super.setUp()
        scorer = ConfidenceScorer()
    }
    
    override func tearDown() {
        scorer = nil
        super.tearDown()
    }
    
    // MARK: - Vision Confidence Tests
    
    func testVisionConfidenceSingleObservation() {
        let observations = [OCObservation(text: "SFMTA12345678", confidence: 0.95)]
        let result = scorer.score(rawText: "SFMTA12345678", observations: observations, matchedCityId: "us-ca-san_francisco")
        
        XCTAssertEqual(result.components[0].score, 0.95, accuracy: 0.001)
    }
    
    func testVisionConfidenceMultipleObservations() {
        let observations = [
            OCObservation(text: "SFMTA", confidence: 0.95),
            OCObservation(text: "12345678", confidence: 0.90)
        ]
        let result = scorer.score(rawText: "SFMTA12345678", observations: observations, matchedCityId: "us-ca-san_francisco")
        
        // Average of 0.95 and 0.90
        XCTAssertEqual(result.components[0].score, 0.925, accuracy: 0.001)
    }
    
    func testVisionConfidenceEmptyObservations() {
        let observations: [OCObservation] = []
        let result = scorer.score(rawText: "", observations: observations, matchedCityId: nil)
        
        XCTAssertEqual(result.components[0].score, 0.0, accuracy: 0.001)
    }
    
    // MARK: - Pattern Match Tests
    
    func testPatternMatchSanFrancisco() {
        let observations = [OCObservation(text: "SFMTA12345678", confidence: 0.95)]
        let result = scorer.score(rawText: "SFMTA12345678", observations: observations, matchedCityId: "us-ca-san_francisco")
        
        // San Francisco has highest priority = 0.95
        XCTAssertEqual(result.components[1].score, 0.95, accuracy: 0.001)
    }
    
    func testPatternMatchNewYork() {
        let observations = [OCObservation(text: "1234567890", confidence: 0.95)]
        let result = scorer.score(rawText: "1234567890", observations: observations, matchedCityId: "us-ny-new_york")
        
        // New York = 0.90
        XCTAssertEqual(result.components[1].score, 0.90, accuracy: 0.001)
    }
    
    func testPatternMatchLosAngeles() {
        let observations = [OCObservation(text: "ABC123", confidence: 0.95)]
        let result = scorer.score(rawText: "ABC123", observations: observations, matchedCityId: "us-ca-los_angeles")
        
        // Los Angeles has lowest priority = 0.70
        XCTAssertEqual(result.components[1].score, 0.70, accuracy: 0.001)
    }
    
    func testPatternMatchNoCity() {
        let observations = [OCObservation(text: "UNKNOWN123", confidence: 0.95)]
        let result = scorer.score(rawText: "UNKNOWN123", observations: observations, matchedCityId: nil)
        
        // No city matched = 0.5
        XCTAssertEqual(result.components[1].score, 0.50, accuracy: 0.001)
    }
    
    // MARK: - Completeness Tests
    
    func testCompletenessExactLength() {
        // San Francisco: 10-11 characters
        let observations = [OCObservation(text: "SFMTA123456", confidence: 0.95)]
        let result = scorer.score(rawText: "SFMTA123456", observations: observations, matchedCityId: "us-ca-san_francisco")
        
        XCTAssertEqual(result.components[2].score, 1.0, accuracy: 0.001)
    }
    
    func testCompletenessOffByTwo() {
        // San Francisco: 10-11 characters
        let observations = [OCObservation(text: "SFMTA1234", confidence: 0.95)]
        let result = scorer.score(rawText: "SFMTA1234", observations: observations, matchedCityId: "us-ca-san_francisco")
        
        // Off by 2 = 0.7
        XCTAssertEqual(result.components[2].score, 0.70, accuracy: 0.001)
    }
    
    func testCompletenessWayOff() {
        // San Francisco: 10-11 characters
        let observations = [OCObservation(text: "SFMTA", confidence: 0.95)]
        let result = scorer.score(rawText: "SFMTA", observations: observations, matchedCityId: "us-ca-san_francisco")
        
        // Way off = 0.4
        XCTAssertEqual(result.components[2].score, 0.40, accuracy: 0.001)
    }
    
    // MARK: - Consistency Tests
    
    func testConsistencySingleObservation() {
        let observations = [OCObservation(text: "SFMTA12345678", confidence: 0.95)]
        let result = scorer.score(rawText: "SFMTA12345678", observations: observations, matchedCityId: "us-ca-san_francisco")
        
        // Single observation = perfect consistency
        XCTAssertEqual(result.components[3].score, 1.0, accuracy: 0.001)
    }
    
    func testConsistencyHighVariance() {
        let observations = [
            OCObservation(text: "SFMTA", confidence: 0.99),
            OCObservation(text: "12345678", confidence: 0.50)
        ]
        let result = scorer.score(rawText: "SFMTA12345678", observations: observations, matchedCityId: "us-ca-san_francisco")
        
        // High variance should reduce consistency score
        XCTAssertLessThan(result.components[3].score, 1.0)
    }
    
    // MARK: - Overall Score Tests
    
    func testHighConfidenceResult() {
        // High confidence: good observations + matching pattern + good completeness
        let observations = [
            OCObservation(text: "SFMTA", confidence: 0.95),
            OCObservation(text: "12345678", confidence: 0.94)
        ]
        let result = scorer.score(rawText: "SFMTA12345678", observations: observations, matchedCityId: "us-ca-san_francisco")
        
        XCTAssertGreaterThanOrEqual(result.overallConfidence, 0.85)
        XCTAssertEqual(result.level, .high)
        XCTAssertEqual(result.recommendation, .accept)
        XCTAssertTrue(result.shouldAutoAccept)
    }
    
    func testMediumConfidenceResult() {
        // Medium confidence: mediocre observations
        let observations = [OCObservation(text: "SFMTA12345678", confidence: 0.70)]
        let result = scorer.score(rawText: "SFMTA12345678", observations: observations, matchedCityId: "us-ca-san_francisco")
        
        XCTAssertGreaterThanOrEqual(result.overallConfidence, 0.60)
        XCTAssertLessThan(result.overallConfidence, 0.85)
        XCTAssertEqual(result.level, .medium)
        XCTAssertEqual(result.recommendation, .review)
        XCTAssertFalse(result.shouldAutoAccept)
    }
    
    func testLowConfidenceResult() {
        // Low confidence: bad observations
        let observations = [OCObservation(text: "SFMTA12345678", confidence: 0.40)]
        let result = scorer.score(rawText: "SFMTA12345678", observations: observations, matchedCityId: "us-ca-san_francisco")
        
        XCTAssertLessThan(result.overallConfidence, 0.60)
        XCTAssertEqual(result.level, .low)
        XCTAssertEqual(result.recommendation, .reject)
        XCTAssertFalse(result.shouldAutoAccept)
    }
    
    // MARK: - Weighted Score Calculation
    
    func testWeightedScoreSum() {
        let observations = [OCObservation(text: "SFMTA12345678", confidence: 0.90)]
        let result = scorer.score(rawText: "SFMTA12345678", observations: observations, matchedCityId: "us-ca-san_francisco")
        
        // Verify weighted scores add up to overall
        let weightedSum = result.components.reduce(0.0) { $0 + $1.weightedScore }
        XCTAssertEqual(weightedSum, result.overallConfidence, accuracy: 0.001)
    }
    
    // MARK: - Static Helpers
    
    func testMeetsAutoAcceptThreshold() {
        XCTAssertTrue(ConfidenceScorer.meetsAutoAcceptThreshold(0.85))
        XCTAssertTrue(ConfidenceScorer.meetsAutoAcceptThreshold(0.90))
        XCTAssertFalse(ConfidenceScorer.meetsAutoAcceptThreshold(0.84))
    }
    
    func testRequiresReview() {
        XCTAssertTrue(ConfidenceScorer.requiresReview(0.84))
        XCTAssertFalse(ConfidenceScorer.requiresReview(0.85))
    }
    
    func testConfidenceMessage() {
        XCTAssertEqual(ConfidenceScorer.confidenceMessage(for: .high), "High confidence - looks correct")
        XCTAssertEqual(ConfidenceScorer.confidenceMessage(for: .medium), "Medium confidence - please verify")
        XCTAssertEqual(ConfidenceScorer.confidenceMessage(for: .low), "Low confidence - please check and edit")
    }
    
    // MARK: - Fallback Suggestions
    
    func testSuggestFallbackLowVision() {
        let observations = [OCObservation(text: "SFMTA12345678", confidence: 0.30)]
        let result = scorer.score(rawText: "SFMTA12345678", observations: observations, matchedCityId: "us-ca-san_francisco")
        
        let options = scorer.suggestFallbackOptions(result)
        XCTAssertTrue(options.contains(.enhanceContrast))
        XCTAssertTrue(options.contains(.reduceNoise))
        XCTAssertTrue(options.contains(.binarize))
    }
    
    func testSuggestFallbackLowCompleteness() {
        let observations = [OCObservation(text: "SF", confidence: 0.95)]
        let result = scorer.score(rawText: "SF", observations: observations, matchedCityId: "us-ca-san_francisco")
        
        let options = scorer.suggestFallbackOptions(result)
        XCTAssertTrue(options.contains(.correctPerspective))
    }
}
