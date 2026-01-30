//
//  LiveTextHelperTests.swift
//  FightCityiOSTests
//
//  Tests for Apple Intelligence Live Text integration
//

import XCTest
@testable import FightCityiOS

/// Tests for LiveTextHelper Apple Intelligence features
final class LiveTextHelperTests: XCTestCase {
    
    // MARK: - Properties
    
    var sut: LiveTextHelper!
    var mockAnalyzer: MockImageAnalyzer!
    
    // MARK: - Setup & Teardown
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        mockAnalyzer = MockImageAnalyzer()
        sut = LiveTextHelper(confidenceScorer: ConfidenceScorer())
    }
    
    override func tearDownWithError() throws {
        sut = nil
        mockAnalyzer = nil
        try super.tearDownWithError()
    }
    
    // MARK: - Availability Tests
    
    func testAnalyzerAvailability() {
        // Test that analyzer availability is properly reported
        XCTAssertEqual(sut.isAnalyzerAvailable, ImageAnalyzer.isAvailable)
    }
    
    func testLiveTextAvailabilityStaticCheck() {
        // Test static availability check
        XCTAssertEqual(LiveTextHelper.isLiveTextAvailable, ImageAnalyzer.isAvailable)
    }
    
    func testMinimumIOSVersion() {
        // Verify minimum iOS version requirement
        XCTAssertEqual(LiveTextHelper.minimumIOSVersion, 16.0)
    }
    
    func testIOSVersionSupported() {
        // Verify iOS version check
        if #available(iOS 16.0, *) {
            XCTAssertTrue(LiveTextHelper.isIOSVersionSupported)
        } else {
            XCTAssertFalse(LiveTextHelper.isIOSVersionSupported)
        }
    }
    
    // MARK: - Privacy Tests
    
    func testPrivacyAppropriateImage() {
        // Test privacy check with valid image
        let validImage = createTestImage(size: CGSize(width: 500, height: 500))
        XCTAssertTrue(LiveTextHelper.isAnalysisAppropriate(for: validImage))
    }
    
    func testPrivacyInappropriateSmallImage() {
        // Test privacy check with image too small
        let smallImage = createTestImage(size: CGSize(width: 100, height: 100))
        XCTAssertFalse(LiveTextHelper.isAnalysisAppropriate(for: smallImage))
    }
    
    func testPrivacyPreservingOptions() {
        // Test privacy-preserving options configuration
        let options = LiveTextHelper.privacyPreservingOptions
        XCTAssertEqual(options.recognitionLevel, .fast)
    }
    
    // MARK: - Analysis Tests
    
    func testAnalyzeImageWithNilCGImage() async throws {
        // Test error handling for invalid image
        let invalidImage = UIImage()
        
        do {
            _ = try await sut.analyzeImage(invalidImage)
            XCTFail("Expected error for invalid image")
        } catch let error as LiveTextError {
            XCTAssertEqual(error, .invalidImage)
        }
    }
    
    func testExtractTextFromImage() async throws {
        // Test text extraction functionality
        guard let cgImage = createTestCGImage() else {
            XCTFail("Failed to create test CGImage")
            return
        }
        
        let uiImage = UIImage(cgImage: cgImage)
        
        // This test verifies the method doesn't throw when analyzer is available
        // Actual analysis depends on ImageAnalyzer availability
        if sut.isAnalyzerAvailable {
            let text = try await sut.extractText(from: uiImage)
            XCTAssertNotNil(text)
        }
    }
    
    // MARK: - OCR Integration Tests
    
    func testCreateOCRResultFromAnalysisResult() {
        // Test OCR result creation from Live Text analysis
        let analysisResult = createMockAnalysisResult()
        
        let ocrResult = sut.createOCRResult(from: analysisResult)
        
        XCTAssertEqual(ocrResult.text, analysisResult.text)
        XCTAssertEqual(ocrResult.confidence, analysisResult.overallConfidence, accuracy: 0.001)
        XCTAssertEqual(ocrResult.observations.count, analysisResult.textObservations.count)
    }
    
    func testScoreLiveTextResult() {
        // Test confidence scoring of Live Text results
        let analysisResult = createMockAnalysisResult()
        
        let scoreResult = sut.scoreLiveTextResult(analysisResult)
        
        XCTAssertGreaterThanOrEqual(scoreResult.overallConfidence, 0.0)
        XCTAssertLessThanOrEqual(scoreResult.overallConfidence, 1.0)
        XCTAssertFalse(scoreResult.components.isEmpty)
    }
    
    // MARK: - Barcode Tests
    
    func testExtractBarcodesWithInvalidImage() async throws {
        // Test barcode extraction with invalid image
        let invalidImage = UIImage()
        
        do {
            _ = try await sut.extractBarcodes(from: invalidImage, types: [.qrCode])
            XCTFail("Expected error for invalid image")
        } catch let error as LiveTextError {
            XCTAssertEqual(error, .invalidImage)
        }
    }
    
    func testBarcodeTypeMapping() {
        // Test barcode type mapping to Vision symbology
        XCTAssertEqual(BarcodeType.qrCode.visionSymbology, .qr)
        XCTAssertEqual(BarcodeType.dataMatrix.visionSymbology, .dataMatrix)
        XCTAssertEqual(BarcodeType.pdf417.visionSymbology, .pdf417)
    }
    
    // MARK: - Cancellation Tests
    
    func testCancelCurrentAnalysis() {
        // Test cancellation of ongoing analysis
        sut.cancelCurrentAnalysis()
        // Verify no crash occurs
        XCTAssertNil(sut)
    }
    
    // MARK: - Helper Methods
    
    private func createTestImage(size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            UIColor.white.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
    }
    
    private func createTestCGImage() -> CGImage? {
        let size = CGSize(width: 500, height: 500)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in }.cgImage
    }
    
    private func createMockAnalysisResult() -> AnalysisResult {
        let textObservations = [
            TextObservation(
                text: "TEST123",
                confidence: 0.95,
                boundingBox: CGRect(x: 0, y: 0, width: 100, height: 50),
                candidates: ["TEST123", "TEST12", "TEST1"]
            )
        ]
        
        return AnalysisResult(
            text: "TEST123",
            textObservations: textObservations,
            barcodeResults: [],
            overallConfidence: 0.95,
            processingTime: 0.1,
            metadata: AnalysisMetadata(
                imageSize: CGSize(width: 500, height: 500),
                imageOrientation: .up,
                analysisDate: Date(),
                deviceSupportsLiveText: true
            )
        )
    }
}

// MARK: - Mock Image Analyzer

/// Mock implementation of ImageAnalyzer for testing
final class MockImageAnalyzer: @unchecked Sendable {
    var isAvailable: Bool = true
    var shouldFail: Bool = false
    var analysisDelay: TimeInterval = 0.01
    
    func analyze(_ cgImage: CGImage, orientation: UIImage.Orientation, options: ImageAnalyzer.Options?) async throws -> ImageAnalyzer.Content {
        try await Task.sleep(nanoseconds: UInt64(analysisDelay * 1_000_000_000))
        
        if shouldFail {
            throw NSError(domain: "MockImageAnalyzer", code: -1, userInfo: nil)
        }
        
        return []
    }
}
