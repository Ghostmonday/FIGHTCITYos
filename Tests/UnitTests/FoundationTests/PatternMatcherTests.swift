//
//  PatternMatcherTests.swift
//  UnitTests
//
//  Tests for citation pattern matching
//

import XCTest
@testable import FightCityFoundation

final class PatternMatcherTests: XCTestCase {
    var sut: PatternMatcher!
    
    override func setUp() {
        super.setUp()
        sut = PatternMatcher()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - San Francisco Pattern Tests
    
    func testSanFranciscoSFMTAFormat() {
        // Given
        let input = "SFMTA12345678"
        
        // When
        let result = sut.match(input)
        
        // Then
        XCTAssertTrue(result.isMatch)
        XCTAssertEqual(result.cityId, "us-ca-san_francisco")
        XCTAssertEqual(result.priority, 1)
    }
    
    func testSanFranciscoMTFormat() {
        // Given
        let input = "MT12345678"
        
        // When
        let result = sut.match(input)
        
        // Then
        XCTAssertTrue(result.isMatch)
        XCTAssertEqual(result.cityId, "us-ca-san_francisco")
    }
    
    func testSanFranciscoInvalidLength() {
        // Given
        let input = "SFMTA1234"
        
        // When
        let result = sut.match(input)
        
        // Then
        XCTAssertFalse(result.isMatch)
        XCTAssertNil(result.cityId)
    }
    
    // MARK: - New York Pattern Tests
    
    func testNewYork10Digits() {
        // Given
        let input = "1234567890"
        
        // When
        let result = sut.match(input)
        
        // Then
        XCTAssertTrue(result.isMatch)
        XCTAssertEqual(result.cityId, "us-ny-new_york")
        XCTAssertEqual(result.priority, 2)
    }
    
    func testNewYorkInvalidLetters() {
        // Given
        let input = "12345ABCDE"
        
        // When
        let result = sut.match(input)
        
        // Then
        XCTAssertFalse(result.isMatch)
    }
    
    // MARK: - Denver Pattern Tests
    
    func testDenverValidLengths() {
        // Valid lengths: 5-9 digits
        let validInputs = ["12345", "123456", "1234567", "12345678", "123456789"]
        
        for input in validInputs {
            let result = sut.match(input)
            XCTAssertTrue(result.isMatch, "Expected \(input) to match Denver pattern")
            XCTAssertEqual(result.cityId, "us-co-denver")
        }
    }
    
    func testDenverInvalidTooShort() {
        // Given
        let input = "1234"
        
        // When
        let result = sut.match(input)
        
        // Then
        XCTAssertFalse(result.isMatch)
    }
    
    // MARK: - Los Angeles Pattern Tests
    
    func testLos AngelesValid() {
        // LA accepts 6-11 alphanumeric characters
        let validInputs = ["ABC123", "A1B2C3D4E5", "123ABC4567"]
        
        for input in validInputs {
            let result = sut.match(input)
            XCTAssertTrue(result.isMatch, "Expected \(input) to match LA pattern")
            XCTAssertEqual(result.cityId, "us-ca-los_angeles")
        }
    }
    
    // MARK: - Priority Tests
    
    func testPriorityOrderSanFrancisco() {
        // San Francisco should match before others when applicable
        let sfInput = "SFMTA12345678"
        let result = sut.match(sfInput)
        
        XCTAssertEqual(result.priority, 1) // Highest priority
    }
    
    // MARK: - Invalid Input Tests
    
    func testEmptyString() {
        // Given
        let input = ""
        
        // When
        let result = sut.match(input)
        
        // Then
        XCTAssertFalse(result.isMatch)
        XCTAssertNil(result.cityId)
    }
    
    func testSpecialCharacters() {
        // Given
        let input = "SFMTA-1234-5678"
        
        // When
        let result = sut.match(input)
        
        // Then - dash format should not match
        XCTAssertFalse(result.isMatch)
    }
}

// MARK: - PatternMatcher Implementation

public final class PatternMatcher {
    private let patterns: [CityPattern]
    
    public init() {
        self.patterns = [
            // San Francisco - highest priority (most specific)
            CityPattern(
                cityId: "us-ca-san_francisco",
                cityName: "San Francisco",
                pattern: "^(SFMTA|MT)[0-9]{8}$",
                priority: 1,
                deadlineDays: 21,
                canAppealOnline: true,
                phoneConfirmationRequired: true
            ),
            // New York
            CityPattern(
                cityId: "us-ny-new_york",
                cityName: "New York",
                pattern: "^[0-9]{10}$",
                priority: 2,
                deadlineDays: 30,
                canAppealOnline: true,
                phoneConfirmationRequired: false
            ),
            // Denver
            CityPattern(
                cityId: "us-co-denver",
                cityName: "Denver",
                pattern: "^[0-9]{5,9}$",
                priority: 3,
                deadlineDays: 21,
                canAppealOnline: true,
                phoneConfirmationRequired: false
            ),
            // Los Angeles - lowest priority (least specific)
            CityPattern(
                cityId: "us-ca-los_angeles",
                cityName: "Los Angeles",
                pattern: "^[0-9A-Z]{6,11}$",
                priority: 4,
                deadlineDays: 21,
                canAppealOnline: false,
                phoneConfirmationRequired: true
            )
        ]
    }
    
    public func match(_ text: String) -> PatternMatchResult {
        let normalizedText = text.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        guard !normalizedText.isEmpty else {
            return PatternMatchResult(cityId: nil, pattern: nil, priority: 0)
        }
        
        // Sort by priority and try each pattern
        let sortedPatterns = patterns.sorted { $0.priority < $1.priority }
        
        for pattern in sortedPatterns {
            if let regex = try? NSRegularExpression(pattern: pattern.pattern, options: .caseInsensitive) {
                let range = NSRange(normalizedText.startIndex..., in: normalizedText)
                if regex.firstMatch(in: normalizedText, options: [], range: range) != nil {
                    return PatternMatchResult(
                        cityId: pattern.cityId,
                        pattern: pattern,
                        priority: pattern.priority
                    )
                }
            }
        }
        
        return PatternMatchResult(cityId: nil, pattern: nil, priority: 0)
    }
}
