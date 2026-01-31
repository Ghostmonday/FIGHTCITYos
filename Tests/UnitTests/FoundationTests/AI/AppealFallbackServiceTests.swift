//
//  AppealFallbackServiceTests.swift
//  FightCityFoundationTests
//
//  Unit tests for AppealFallbackService
//

import XCTest
@testable import FightCityFoundation

final class AppealFallbackServiceTests: XCTestCase {
    var sut: AppealFallbackService!
    
    override func setUp() {
        super.setUp()
        sut = AppealFallbackService.shared
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testGetAllTemplates() {
        // Given
        let templates = sut.getAllTemplates()
        
        // Then
        XCTAssertEqual(templates.count, 5, "Should have 5 templates")
        XCTAssertTrue(templates.contains { $0.id == "general_signage" })
        XCTAssertTrue(templates.contains { $0.id == "meter_malfunction" })
        XCTAssertTrue(templates.contains { $0.id == "valid_receipt" })
        XCTAssertTrue(templates.contains { $0.id == "medical_emergency" })
        XCTAssertTrue(templates.contains { $0.id == "vehicle_breakdown" })
    }
    
    func testGetTemplateById() {
        // Given
        let templateId = "general_signage"
        
        // When
        let template = sut.getTemplate(id: templateId)
        
        // Then
        XCTAssertNotNil(template)
        XCTAssertEqual(template?.id, templateId)
        XCTAssertEqual(template?.name, "Unclear Signage")
    }
    
    func testGenerateFromTemplate() {
        // Given
        let template = sut.getTemplate(id: "general_signage")!
        let context = AppealContext(
            citationNumber: "SFMTA12345678",
            cityName: "San Francisco",
            userReason: "The sign was unclear",
            tone: .respectful
        )
        
        // When
        let result = sut.generateFromTemplate(template: template, context: context)
        
        // Then
        XCTAssertFalse(result.appealText.isEmpty)
        XCTAssertTrue(result.appealText.contains("SFMTA12345678"))
        XCTAssertTrue(result.appealText.contains("The sign was unclear"))
        XCTAssertEqual(result.tone, .respectful)
        XCTAssertGreaterThan(result.wordCount, 0)
    }
    
    func testSelectBestTemplate() {
        // Given
        let context = AppealContext(
            citationNumber: "SFMTA12345678",
            cityName: "San Francisco",
            userReason: "The sign was unclear",
            tone: .respectful
        )
        
        // When
        let template = sut.selectBestTemplate(for: context)
        
        // Then
        XCTAssertNotNil(template)
        XCTAssertFalse(template.template.isEmpty)
    }
    
    func testTemplatePlaceholderReplacement() {
        // Given
        let template = sut.getTemplate(id: "meter_malfunction")!
        let context = AppealContext(
            citationNumber: "LA123456",
            cityName: "Los Angeles",
            violationDate: Date(),
            violationCode: "CVC123",
            amount: 75.0,
            userReason: "The meter was broken",
            tone: .factual
        )
        
        // When
        let result = sut.generateFromTemplate(template: template, context: context)
        
        // Then
        XCTAssertTrue(result.appealText.contains("LA123456"))
        XCTAssertTrue(result.appealText.contains("The meter was broken"))
        XCTAssertFalse(result.appealText.contains("[citation_number]"))
        XCTAssertFalse(result.appealText.contains("[reason]"))
    }
}
