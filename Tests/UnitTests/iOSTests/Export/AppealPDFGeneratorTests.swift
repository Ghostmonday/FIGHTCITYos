//
//  AppealPDFGeneratorTests.swift
//  FightCityiOSTests
//
//  Unit tests for AppealPDFGenerator
//

import XCTest
@testable import FightCityiOS
@testable import FightCityFoundation

final class AppealPDFGeneratorTests: XCTestCase {
    func testGeneratePDF() throws {
        // Given
        let citation = Citation(
            citationNumber: "SFMTA12345678",
            cityId: "sf",
            cityName: "San Francisco",
            status: .validated
        )
        let appealText = """
        To Whom It May Concern:
        
        I am writing to appeal citation SFMTA12345678.
        
        The parking meter was malfunctioning.
        
        Respectfully submitted,
        """
        let userInfo = UserContactInfo(
            name: "John Doe",
            addressLine1: "123 Main St",
            city: "San Francisco",
            state: "CA",
            zip: "94102"
        )
        
        // When
        let pdfData = try AppealPDFGenerator.generate(
            citation: citation,
            appealText: appealText,
            userInfo: userInfo
        )
        
        // Then
        XCTAssertFalse(pdfData.isEmpty, "PDF data should not be empty")
        XCTAssertGreaterThan(pdfData.count, 1000, "PDF should be substantial size")
        
        // Verify it's valid PDF by checking PDF header
        let pdfHeader = pdfData.prefix(4)
        let expectedHeader = Data([0x25, 0x50, 0x44, 0x46]) // "%PDF"
        XCTAssertEqual(pdfHeader, expectedHeader, "Should be valid PDF format")
    }
    
    func testGeneratePDFWithAllFields() throws {
        // Given
        let citation = Citation(
            citationNumber: "LA123456",
            cityId: "la",
            cityName: "Los Angeles",
            violationDate: "2024-01-15",
            amount: 75.0,
            status: .validated
        )
        let appealText = "Test appeal text"
        let userInfo = UserContactInfo(
            name: "Jane Smith",
            addressLine1: "456 Oak Ave",
            addressLine2: "Apt 2B",
            city: "Los Angeles",
            state: "CA",
            zip: "90001",
            email: "jane@example.com",
            phone: "555-1234"
        )
        
        // When
        let pdfData = try AppealPDFGenerator.generate(
            citation: citation,
            appealText: appealText,
            userInfo: userInfo
        )
        
        // Then
        XCTAssertFalse(pdfData.isEmpty)
        let pdfHeader = pdfData.prefix(4)
        let expectedHeader = Data([0x25, 0x50, 0x44, 0x46])
        XCTAssertEqual(pdfHeader, expectedHeader)
    }
}
