//
//  AppealWriterTests.swift
//  FightCityFoundationTests
//
//  Unit tests for AppealWriter
//

import XCTest
@testable import FightCityFoundation

final class AppealWriterTests: XCTestCase {
    
    var sut: AppealWriter!
    
    override func setUp() {
        super.setUp()
        sut = AppealWriter.shared
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Appeal Generation Tests
    
    func testGenerateAppealReturnsNonEmptyText() {
        // Given
        let context = AppealContext(
            citationNumber: "SFMTA91234567",
            cityName: "San Francisco",
            violationDate: Date(),
            amount: 95.00,
            userReason: "The parking sign was not visible due to overgrown trees.",
            tone: .respectful
        )
        
        // When
        let result = sut.generateAppeal(for: context)
        
        // Then
        XCTAssertFalse(result.appealText.isEmpty)
        XCTAssertGreaterThan(result.wordCount, 0)
    }\n    \n    func testGenerateAppealWithFormalTone() {\n        // Given\n        let context = AppealContext(\n            citationNumber: \"SFMTA91234567\",\n            cityName: \"San Francisco\",\n            userReason: \"I was parked legally.\",\n            tone: .formal\n        )\n        \n        // When\n        let result = sut.generateAppeal(for: context)\n        \n        // Then\n        XCTAssertEqual(result.tone, .formal)\n    }\n    \n    func testGenerateAppealWithPersuasiveTone() {\n        // Given\n        let context = AppealContext(\n            citationNumber: \"SFMTA91234567\",\n            cityName: \"San Francisco\",\n            userReason: \"The meter was broken.\",\n            tone: .persuasive\n        )\n        \n        // When\n        let result = sut.generateAppeal(for: context)\n        \n        // Then\n        XCTAssertEqual(result.tone, .persuasive)\n        XCTAssertFalse(result.appealText.isEmpty)\n    }\n    \n    // MARK: - Sentiment Analysis Tests\n    \n    func testSentimentAnalysisReturnsValidScore() {\n        // Given\n        let text = \"I respectfully request an appeal of this citation.\"\n        \n        // When\n        let score = sut.analyzeSentiment(text)\n        \n        // Then\n        XCTAssertGreaterThanOrEqual(score, -1.0)\n        XCTAssertLessThanOrEqual(score, 1.0)\n    }\n    \n    func testPositiveSentimentReturnsPositiveScore() {\n        // Given\n        let positiveText = \"I am grateful for your consideration and look forward to your positive response.\"\n        \n        // When\n        let score = sut.analyzeSentiment(positiveText)\n        \n        // Then\n        XCTAssertGreaterThan(score, 0.0, \"Positive text should have positive sentiment\")\n    }\n    \n    func testNegativeSentimentReturnsNegativeScore() {\n        // Given\n        let negativeText = \"This is unfair and I am very upset about this situation.\"\n        \n        // When\n        let score = sut.analyzeSentiment(negativeText)\n        \n        // Then\n        XCTAssertLessThan(score, 0.0, \"Negative text should have negative sentiment\")\n    }\n    \n    // MARK: - Text Improvement Tests\n    \n    func testImproveTextRemovesDoubleSpaces() {\n        // Given\n        let textWithDoubleSpaces = \"This has  double spaces\"\n        \n        // When\n        let (improved, suggestions) = sut.improveText(textWithDoubleSpaces)\n        \n        // Then\n        XCTAssertFalse(improved.contains(\"  \"))\n        XCTAssertFalse(suggestions.isEmpty)\n    }\n    \n    // MARK: - Summarization Tests\n    \n    func testSummarizeReturnsShorterText() {\n        // Given\n        let longText = \"\"\"\n        I am writing to appeal this parking citation because I believe there are \n        extenuating circumstances that should be considered. The parking sign was \n        not clearly visible due to overgrown vegetation from a nearby property. \n        Additionally, the meter had expired by only two minutes and I had been \n        actively searching for change to extend my parking time.\n        \"\"\"\n        \n        // When\n        let summary = sut.summarize(longText, maxLength: 30)\n        \n        // Then\n        let summaryWordCount = summary.split(separator: \" \").count\n        XCTAssertLessThanOrEqual(summaryWordCount, 30)\n    }\n    \n    // MARK: - Processing Time Tests\n    \n    func testGenerateAppealReportsProcessingTime() {\n        // Given\n        let context = AppealContext(\n            citationNumber: \"SFMTA91234567\",\n            cityName: \"San Francisco\",\n            userReason: \"The sign was not visible.\",\n            tone: .respectful\n        )\n        \n        // When\n        let result = sut.generateAppeal(for: context)\n        \n        // Then\n        XCTAssertGreaterThanOrEqual(result.processingTimeMs, 0)\n    }\n    \n    // MARK: - Preview Tests\n    \n    func testGeneratePreviewReturnsTruncatedText() {\n        // Given\n        let context = AppealContext(\n            citationNumber: \"SFMTA91234567\",\n            cityName: \"San Francisco\",\n            userReason: \"This is a test reason for the appeal letter that will be generated.\",\n            tone: .respectful\n        )\n        \n        // When\n        let preview = sut.generatePreview(for: context, maxLength: 50)\n        \n        // Then\n        XCTAssertLessThanOrEqual(preview.count, 53) // 50 + \"...\"\n    }\n    \n    // MARK: - Tone Consistency Tests\n    \n    func testAllTonesGenerateValidAppeals() {\n        // Given\n        let context = AppealContext(\n            citationNumber: \"SFMTA91234567\",\n            cityName: \"San Francisco\",\n            userReason: \"The sign was unclear.\",\n            tone: .respectful\n        )\n        \n        // When/Then\n        for tone in AppealTone.allCases {\n            var testContext = context\n            testContext.tone = tone\n            \n            let result = sut.generateAppeal(for: testContext)\n            XCTAssertEqual(result.tone, tone)\n            XCTAssertFalse(result.appealText.isEmpty)\n        }\n    }\n}\n