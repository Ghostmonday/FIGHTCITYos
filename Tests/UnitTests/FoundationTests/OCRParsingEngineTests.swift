//
//  OCRParsingEngineTests.swift
//  FightCityFoundationTests
//
//  Unit tests for OCRParsingEngine pattern matching
//

import XCTest
@testable import FightCityFoundation

final class OCRParsingEngineTests: XCTestCase {
    
    var sut: OCRParsingEngine!
    
    override func setUp() {
        super.setUp()
        sut = OCRParsingEngine()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - San Francisco Pattern Tests
    
    func testSanFranciscoValidSFMTA() {
        // Given
        let text = "SFMTA91234567"
        
        // When
        let result = sut.parse(text)
        
        // Then
        XCTAssertNotNil(result.citationNumber)
        XCTAssertEqual(result.citationNumber, text)
        XCTAssertEqual(result.cityId, "us-ca-san_francisco")
        XCTAssertEqual(result.cityName, "San Francisco")
        XCTAssertNotNil(result.matchedPattern)
        XCTAssertEqual(result.matchedPattern?.priority, 1)
    }
    
    func testSanFranciscoValidMT() {
        // Given
        let text = "MT91234567"
        
        // When
        let result = sut.parse(text)
        
        // Then
        XCTAssertNotNil(result.citationNumber)
        XCTAssertEqual(result.cityId, "us-ca-san_francisco")
    }
    
    func testSanFranciscoInvalidTooShort() {
        // Given - only 7 digits
        let text = "SFMTA912345"
        
        // When
        let result = sut.parse(text)
        
        // Then
        XCTAssertNil(result.citationNumber)
        XCTAssertNil(result.cityId)
    }
    
    func testSanFranciscoInvalidTooLong() {
        // Given - 10 digits instead of 8
        let text = "SFMTA9123456789"
        
        // When
        let result = sut.parse(text)
        
        // Then
        XCTAssertNil(result.citationNumber)
    }
    
    func testSanFranciscoInvalidPrefix() {
        // Given - wrong prefix
        let text = "NYC91234567"
        
        // When
        let result = sut.parse(text)
        
        // Then
        XCTAssertNil(result.cityId)
    }
    
    // MARK: - NYC Pattern Tests
    
    func testNYCValid10Digits() {
        // Given
        let text = "1234567890"
        
        // When
        let result = sut.parse(text)
        
        // Then
        XCTAssertNotNil(result.citationNumber)
        XCTAssertEqual(result.citationNumber, text)
        XCTAssertEqual(result.cityId, "us-ny-new_york")
        XCTAssertEqual(result.cityName, "New York")
        XCTAssertEqual(result.matchedPattern?.priority, 2)
    }
    
    func testNYCInvalidTooShort() {
        // Given
        let text = "123456789"
        
        // When
        let result = sut.parse(text)
        
        // Then - should not match NYC, might match another pattern or none
        XCTAssertNil(result.cityId)
    }
    
    func testNYCInvalidTooLong() {
        // Given
        let text = "12345678901"
        
        // When
        let result = sut.parse(text)
        
        // Then
        XCTAssertNil(result.cityId)
    }
    
    func testNYCInvalidWithLetters() {
        // Given
        let text = "12345ABC90"
        
        // When
        let result = sut.parse(text)
        
        // Then
        XCTAssertNil(result.cityId)
    }
    
    // MARK: - Denver Pattern Tests
    
    func testDenverValid5Digits() {
        // Given
        let text = "12345"
        
        // When
        let result = sut.parse(text)
        
        // Then
        XCTAssertNotNil(result.citationNumber)
        XCTAssertEqual(result.cityId, "us-co-denver")
        XCTAssertEqual(result.cityName, "Denver")
        XCTAssertEqual(result.matchedPattern?.priority, 3)
    }
    
    func testDenverValid9Digits() {
        // Given
        let text = "123456789"
        
        // When
        let result = sut.parse(text)
        
        // Then
        XCTAssertNotNil(result.citationNumber)
        XCTAssertEqual(result.cityId, "us-co-denver")
    }
    
    func testDenverInvalidTooShort() {
        // Given
        let text = "1234"
        
        // When
        let result = sut.parse(text)
        
        // Then
        XCTAssertNil(result.cityId)
    }
    
    func testDenverInvalidTooLong() {
        // Given
        let text = "1234567890"
        
        // When - 10 digits should match NYC, not Denver
        let result = sut.parse(text)
        
        // Then
        XCTAssertEqual(result.cityId, "us-ny-new_york")
    }
    
    // MARK: - Los Angeles Pattern Tests
    
    func testLAValidAlphanumeric6() {
        // Given
        let text = "LA1234"
        
        // When
        let result = sut.parse(text)
        
        // Then
        XCTAssertNotNil(result.citationNumber)
        XCTAssertEqual(result.cityId, "us-ca-los_angeles")
        XCTAssertEqual(result.cityName, "Los Angeles")
        XCTAssertEqual(result.matchedPattern?.priority, 4)
    }
    
    func testLAValidAlphanumeric11() {
        // Given
        let text = "LA123456789"
        
        // When
        let result = sut.parse(text)
        
        // Then
        XCTAssertNotNil(result.citationNumber)
        XCTAssertEqual(result.cityId, "us-ca-los_angeles")
    }
    
    func testLAValidNumericOnly() {
        // Given
        let text = "123456"
        
        // When
        let result = sut.parse(text)
        
        // Then
        XCTAssertNotNil(result.citationNumber)
        XCTAssertEqual(result.cityId, "us-ca-los_angeles")
    }
    
    func testLAInvalidTooShort() {
        // Given
        let text = "LA123"
        
        // When
        let result = sut.parse(text)
        
        // Then
        XCTAssertNil(result.cityId)
    }
    
    func testLAInvalidTooLong() {
        // Given
        let text = "LA12345678901"
        
        // When
        let result = sut.parse(text)
        
        // Then
        XCTAssertNil(result.cityId)
    }
    
    func testLAInvalidLowercase() {
        // Given
        let text = "la123456"
        
        // When
        let result = sut.parse(text)
        
        // Then
        XCTAssertNil(result.cityId)
    }
    
    // MARK: - Priority Tests
    
    func testSF优先于NYC() {
        // Given - 10-digit number that could match both
        let text = "SFMTA91234567" // This won't match NYC, SF should match
        
        // When
        let result = sut.parse(text)
        
        // Then
        XCTAssertEqual(result.cityId, "us-ca-san_francisco")
        XCTAssertEqual(result.matchedPattern?.priority, 1)
    }
    
    func testNYC优先于Denver() {
        // Given - 9-digit number could match Denver, but 10-digit should match NYC
        let text = "1234567890" // 10 digits - NYC
        
        // When
        let result = sut.parse(text)
        
        // Then
        XCTAssertEqual(result.cityId, "us-ny-new_york")
    }
    
    func testDenver优先于LA() {
        // Given - 6 alphanumeric could match LA, but 5-9 digits only matches Denver
        let text = "123456" // 6 digits - could match LA (6-11) but Denver (5-9) should match first
        
        // When
        let result = sut.parse(text)
        
        // Then - Denver should match first due to priority
        XCTAssertEqual(result.cityId, "us-co-denver")
    }
    
    // MARK: - Text Normalization Tests
    
    func testNormalizeRemovesSpaces() {
        // Given
        let text = "SFMTA 912 345 67"
        
        // When
        let result = sut.parse(text)
        
        // Then
        XCTAssertEqual(result.citationNumber, "SFMTA91234567")
    }
    
    func testNormalizeConvertsToUppercase() {
        // Given
        let text = "sfmta91234567"
        
        // When
        let result = sut.parse(text)
        
        // Then
        XCTAssertNotNil(result.citationNumber)
        XCTAssertEqual(result.cityId, "us-ca-san_francisco")
    }
    
    func testNormalizeConvertsPipeToI() {
        // Given
        let text = "SFMTA9|234567"
        
        // When
        let result = sut.parse(text)
        
        // Then
        XCTAssertEqual(result.citationNumber, "SFMTA9I234567")
    }
    
    func testNormalizeConvertsLowercaseLToI() {
        // Given
        let text = "SFMTA9l234567"
        
        // When
        let result = sut.parse(text)
        
        // Then
        XCTAssertEqual(result.citationNumber, "SFMTA9I234567")
    }
    
    func testNormalizePreservesZeros() {
        // Given - ensure OCR doesn't turn 0 into O
        let text = "1234506789"
        
        // When
        let result = sut.parse(text)
        
        // Then
        XCTAssertEqual(result.citationNumber, "1234506789")
    }
    
    func testNormalizeRemovesSpecialCharacters() {
        // Given
        let text = "SFMTA@91234567"
        
        // When
        let result = sut.parse(text)
        
        // Then
        XCTAssertEqual(result.citationNumber, "SFMTA91234567")
    }
    
    // MARK: - Confidence Score Tests
    
    func testSFHasHighestConfidence() {
        // Given
        let sfResult = sut.parse("SFMTA91234567")
        let nycResult = sut.parse("1234567890")
        let denverResult = sut.parse("1234567")
        let laResult = sut.parse("LA123456")
        
        // Then
        XCTAssertGreaterThan(sfResult.confidence, nycResult.confidence)
        XCTAssertGreaterThan(nycResult.confidence, denverResult.confidence)
        XCTAssertGreaterThan(denverResult.confidence, laResult.confidence)
    }
    
    func testConfidenceInValidRange() {
        // Given - various valid patterns
        let patterns = [
            "SFMTA91234567",
            "1234567890",
            "1234567",
            "LA123456"
        ]
        
        // When/Then
        for pattern in patterns {
            let result = sut.parse(pattern)
            XCTAssertGreaterThanOrEqual(result.confidence, 0.5)
            XCTAssertLessThanOrEqual(result.confidence, 1.0)
        }
    }
    
    func testNoMatchHasZeroConfidence() {
        // Given
        let result = sut.parse("INVALID_TEXT")
        
        // Then
        XCTAssertNil(result.citationNumber)
        XCTAssertEqual(result.confidence, 0)
    }
    
    // MARK: - City Hint Tests
    
    func testParseWithCityHintSF() {
        // Given
        let text = "91234567"
        let cityHint = "us-ca-san_francisco"
        
        // When
        let result = sut.parseWithCityHint(text, cityId: cityHint)
        
        // Then - should match because text matches SF pattern
        XCTAssertNotNil(result.citationNumber)
        XCTAssertEqual(result.cityId, cityHint)
    }
    
    func testParseWithCityHintMismatch() {
        // Given - 10 digits with NYC hint
        let text = "1234567890"
        let cityHint = "us-ny-new_york"
        
        // When
        let result = sut.parseWithCityHint(text, cityId: cityHint)
        
        // Then
        XCTAssertNotNil(result.citationNumber)
        XCTAssertEqual(result.cityId, cityHint)
    }
    
    func testParseWithCityHintFallback() {
        // Given - text that doesn't match hint, should fallback to general parsing
        let text = "LA123456"
        let cityHint = "us-ny-new_york" // NYC hint but LA text
        
        // When
        let result = sut.parseWithCityHint(text, cityId: cityHint)
        
        // Then - should fallback to LA
        XCTAssertEqual(result.cityId, "us-ca-los_angeles")
    }
    
    // MARK: - Formatting Tests
    
    func testFormatSFCitationWithDashes() {
        // Given
        let citation = "912345678"
        let cityId = "us-ca-san_francisco"
        
        // When
        let formatted = sut.formatCitation(citation, cityId: cityId)
        
        // Then
        XCTAssertEqual(formatted, "912-345-678")
    }
    
    func testFormatSFCitationAlreadyFormatted() {
        // Given
        let citation = "912-345-678"
        let cityId = "us-ca-san_francisco"
        
        // When
        let formatted = sut.formatCitation(citation, cityId: cityId)
        
        // Then
        XCTAssertEqual(formatted, "912-345-678")
    }
    
    func testFormatNYCCitationNoDashes() {
        // Given
        let citation = "1234567890"
        let cityId = "us-ny-new_york"
        
        // When
        let formatted = sut.formatCitation(citation, cityId: cityId)
        
        // Then
        XCTAssertEqual(formatted, "1234567890")
    }
    
    func testFormatLACitationNoDashes() {
        // Given
        let citation = "LA123456"
        let cityId = "us-ca-los_angeles"
        
        // When
        let formatted = sut.formatCitation(citation, cityId: cityId)
        
        // Then
        XCTAssertEqual(formatted, "LA123456")
    }
    
    func testFormatUnknownCityReturnsOriginal() {
        // Given
        let citation = "UNKNOWN123"
        let cityId = "unknown-city"
        
        // When
        let formatted = sut.formatCitation(citation, cityId: cityId)
        
        // Then
        XCTAssertEqual(formatted, "UNKNOWN123")
    }
    
    // MARK: - Date Extraction Tests
    
    func testExtractDatesMMDDYYYY() {
        // Given
        let text = "Ticket issued on 01/15/2024"
        
        // When
        let dates = sut.extractDates(from: text)
        
        // Then
        XCTAssertFalse(dates.isEmpty)
        XCTAssertEqual(dates.first?.rawValue, "01/15/2024")
    }
    
    func testExtractDatesMMDDYYYYWithDashes() {
        // Given
        let text = "Violation 01-15-2024"
        
        // When
        let dates = sut.extractDates(from: text)
        
        // Then
        XCTAssertFalse(dates.isEmpty)
    }
    
    func testExtractDatesYYYYMMDD() {
        // Given
        let text = "Date: 2024-01-15"
        
        // When
        let dates = sut.extractDates(from: text)
        
        // Then
        XCTAssertFalse(dates.isEmpty)
    }
    
    func testExtractDatesMonthDDYYYY() {
        // Given
        let text = "January 15, 2024"
        
        // When
        let dates = sut.extractDates(from: text)
        
        // Then
        XCTAssertFalse(dates.isEmpty)
    }
    
    func testExtractDatesMultipleDates() {
        // Given
        let text = "Issued 01/15/2024, Due 02/15/2024"
        
        // When
        let dates = sut.extractDates(from: text)
        
        // Then
        XCTAssertEqual(dates.count, 2)
    }
    
    func testExtractDatesNoDates() {
        // Given
        let text = "No dates here"
        
        // When
        let dates = sut.extractDates(from: text)
        
        // Then
        XCTAssertTrue(dates.isEmpty)
    }
    
    // MARK: - Raw Matches Tests
    
    func testRawMatchesContainsAllMatches() {
        // Given
        let text = "SFMTA91234567 and also 1234567890"
        
        // When
        let result = sut.parse(text)
        
        // Then
        XCTAssertTrue(result.rawMatches.count >= 1)
        XCTAssertTrue(result.rawMatches.contains("SFMTA91234567"))
    }
    
    func testRawMatchesEmptyOnNoMatch() {
        // Given
        let text = "no matches here"
        
        // When
        let result = sut.parse(text)
        
        // Then
        XCTAssertTrue(result.rawMatches.isEmpty)
    }
    
    // MARK: - Edge Cases
    
    func testEmptyStringReturnsNoMatch() {
        // Given
        let text = ""
        
        // When
        let result = sut.parse(text)
        
        // Then
        XCTAssertNil(result.citationNumber)
        XCTAssertNil(result.cityId)
    }
    
    func testWhitespaceOnlyReturnsNoMatch() {
        // Given
        let text = "   "
        
        // When
        let result = sut.parse(text)
        
        // Then
        XCTAssertNil(result.citationNumber)
    }
    
    func testVeryLongStringDoesNotCrash() {
        // Given
        let text = String(repeating: "A", count: 1000)
        
        // When
        let result = sut.parse(text)
        
        // Then
        XCTAssertNotNil(result)
    }
    
    func testMixedValidInvalidPattern() {
        // Given - text with valid pattern in noise
        let text = "ABC SFMTA91234567 XYZ 123"
        
        // When
        let result = sut.parse(text)
        
        // Then
        XCTAssertNotNil(result.citationNumber)
        XCTAssertEqual(result.cityId, "us-ca-san_francisco")
    }
}
