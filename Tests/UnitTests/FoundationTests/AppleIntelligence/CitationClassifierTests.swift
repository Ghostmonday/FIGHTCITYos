//
//  CitationClassifierTests.swift
//  FightCityFoundationTests
//
//  Unit tests for CitationClassifier
//

import XCTest
@testable import FightCityFoundation

final class CitationClassifierTests: XCTestCase {
    
    var sut: CitationClassifier!
    
    override func setUp() {
        super.setUp()
        sut = CitationClassifier.shared
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Availability Tests
    
    func testIsAvailable() {
        XCTAssertTrue(sut.isAvailable, "CitationClassifier should be available")
    }
    
    // MARK: - Classification Tests
    
    func testClassifySanFranciscoCitation() {
        let text = "SFMTA91234567 Parking Violation"
        let result = sut.classify(text)
        XCTAssertEqual(result.cityId, "us-ca-san_francisco")
        XCTAssertEqual(result.cityName, "San Francisco")
        XCTAssertGreaterThan(result.confidence, 0.5)
    }
    
    func testClassifyNewYorkCitation() {
        let text = "1234567890 NYC DOT Parking"
        let result = sut.classify(text)
        XCTAssertEqual(result.cityId, "us-ny-new_york")
        XCTAssertEqual(result.cityName, "New York")
    }
    
    func testClassifyLosAngelesCitation() {
        let text = "LA123456 Parking Citation"
        let result = sut.classify(text)
        XCTAssertEqual(result.cityId, "us-ca-los_angeles")
        XCTAssertEqual(result.cityName, "Los Angeles")
    }
    
    func testClassifyDenverCitation() {
        let text = "1234567 Denver Parking Violation"
        let result = sut.classify(text)
        XCTAssertEqual(result.cityId, "us-co-denver")
        XCTAssertEqual(result.cityName, "Denver")
    }
    
    // MARK: - Citation Type Tests
    
    func testClassifyParkingViolation() {
        let text = "SFMTA91234567 NO PARKING METER EXPIRED"
        let result = sut.classify(text)
        XCTAssertEqual(result.citationType, .parking)
    }
    
    func testClassifySpeedingViolation() {
        let text = "SFMTA91234567 SPEEDING 35 MPH IN 25 ZONE"
        let result = sut.classify(text)
        XCTAssertEqual(result.citationType, .speeding)
    }
    
    func testClassifyRedLightViolation() {
        let text = "CITATION RED LIGHT CAMERA"
        let result = sut.classify(text)
        XCTAssertEqual(result.citationType, .redLight)
    }
    
    // MARK: - Confidence Tests
    
    func testConfidenceIsWithinRange() {
        let texts = ["SFMTA91234567", "1234567890 NYC", "LA123456", "1234567 Denver"]
        for text in texts {
            let result = sut.classify(text)
            XCTAssertGreaterThanOrEqual(result.confidence, 0.0)
            XCTAssertLessThanOrEqual(result.confidence, 1.0)
        }
    }
    
    // MARK: - Key Phrases Tests
    
    func testKeyPhrasesExtraction() {
        let text = "SFMTA91234567 PARKING VIOLATION METER EXPIRED"
        let result = sut.classify(text)
        XCTAssertFalse(result.keyPhrasesFound.isEmpty)
        XCTAssertTrue(result.keyPhrasesFound.contains("PARKING VIOLATION"))
    }
    
    // MARK: - Similarity Tests
    
    func testSimilarityScoreReturnsValidValue() {
        let text1 = "SFMTA91234567"
        let text2 = "SFMTA91234567"
        let score = sut.similarityScore(text1, text2)
        XCTAssertGreaterThanOrEqual(score, 0.0)
        XCTAssertLessThanOrEqual(score, 1.0)
    }
    
    // MARK: - Training Data Tests
    
    func testTrainingDataIsNotEmpty() {
        let trainingData = sut.exportTrainingData()
        XCTAssertFalse(trainingData.isEmpty)
    }
}
