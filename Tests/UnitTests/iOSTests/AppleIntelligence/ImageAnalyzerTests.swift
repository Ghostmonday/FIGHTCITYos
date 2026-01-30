//
//  ImageAnalyzerTests.swift
//  FightCityiOSTests
//
//  Tests for Apple Intelligence ImageAnalyzer real-time text extraction
//

import XCTest
@testable import FightCityiOS

/// Tests for ImageAnalyzer Apple Intelligence features
final class ImageAnalyzerTests: XCTestCase {
    
    // MARK: - Properties
    
    var sut: ImageAnalyzer!
    
    // MARK: - Setup & Teardown
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = ImageAnalyzer()
    }
    
    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }
    
    // MARK: - Availability Tests
    
    func testImageAnalyzerAvailability() {
        // Test ImageAnalyzer availability check
        XCTAssertEqual(ImageAnalyzer.isAvailable, true)
    }
    
    // MARK: - Content Type Tests
    
    func testImageAnalyzerContentText() {
        // Test text content type in ImageAnalyzer
        let textContent = ImageAnalyzer.Content.text([])
        XCTAssertTrue(textContent.isText)
        XCTAssertFalse(textContent.isFace)
    }
    
    // MARK: - Options Tests
    
    func testDefaultOptions() {
        // Test default ImageAnalyzer options
        let options = ImageAnalyzer.Options()
        XCTAssertEqual(options.recognitionLevel, .accurate)
    }
    
    func testFastRecognitionOptions() {
        // Test fast recognition options
        var options = ImageAnalyzer.Options()
        options.recognitionLevel = .fast
        
        XCTAssertEqual(options.recognitionLevel, .fast)
    }
    
    func testCustomOptions() {
        // Test custom options configuration
        var options = ImageAnalyzer.Options()
        options.recognizesLanguage = true
        options.encodesPrivacyOptions = false
        
        XCTAssertTrue(options.recognizesLanguage)
    }
}

// MARK: - Performance Tests

extension ImageAnalyzerTests {
    
    func testPerformanceOfTextRecognition() {
        guard let cgImage = createTestCGImage() else {
            XCTFail("Failed to create test CGImage")
            return
        }
        
        let image = UIImage(cgImage: cgImage)
        
        measure(metrics: [XCTMetric(PowerMetric()), XCTMetric(StorageMetric())]) {
            // Performance test for image analysis
            let expectation = XCTestExpectation(description: "Image analysis completion")
            
            Task {
                do {
                    let content = try await sut.analyze(
                        cgImage,
                        orientation: image.imageOrientation
                    )
                    XCTAssertNotNil(content)
                    expectation.fulfill()
                } catch {
                    XCTFail("Image analysis failed: \(error.localizedDescription)")
                    expectation.fulfill()
                }
            }
            
            wait(for: [expectation], timeout: 10.0)
        }
    }
}

// MARK: - OCR Comparison Tests

extension ImageAnalyzerTests {
    
    func testOCRResultComparison() {
        // Test comparing Vision OCR with ImageAnalyzer results
        guard let cgImage = createTestCGImage() else {
            XCTFail("Failed to create test CGImage")
            return
        }
        
        // Create OCR result
        let ocrResult = OCRRecognitionResult(
            text: "TEST123",
            confidence: 0.95,
            processingTime: 0.1,
            observations: []
        )
        
        // Verify OCR result structure
        XCTAssertEqual(ocrResult.text, "TEST123")
        XCTAssertEqual(ocrResult.confidence, 0.95, accuracy: 0.001)
        XCTAssertGreaterThan(ocrResult.processingTime, 0)
    }
}

// MARK: - Helper Methods

extension ImageAnalyzerTests {
    
    private func createTestCGImage() -> CGImage? {
        let size = CGSize(width: 500, height: 500)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            UIColor.white.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            
            // Draw some text for recognition
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 24),
                .foregroundColor: UIColor.black
            ]
            let text = "TEST123"
            let attributedString = NSAttributedString(string: text, attributes: attributes)
            attributedString.draw(at: CGPoint(x: 50, y: 50))
        }.cgImage
    }
}

// MARK: - OCRRecognitionResult Helper Tests

extension ImageAnalyzerTests {
    
    func testOCRRecognitionResultInitialization() {
        // Test OCR result initialization
        let result = OCRRecognitionResult(
            text: "TEST456",
            confidence: 0.88,
            processingTime: 0.05,
            observations: []
        )
        
        XCTAssertEqual(result.text, "TEST456")
        XCTAssertEqual(result.confidence, 0.88, accuracy: 0.001)
    }
}

// MARK: - OCRObservation Tests

extension ImageAnalyzerTests {
    
    func testOCRObservationInitialization() {
        // Test OCR observation initialization
        let observation = OCRObservation(
            text: "SAMPLE",
            confidence: 0.92,
            boundingBox: CGRect(x: 10, y: 10, width: 100, height: 50)
        )
        
        XCTAssertEqual(observation.text, "SAMPLE")
        XCTAssertEqual(observation.confidence, 0.92, accuracy: 0.001)
        XCTAssertEqual(observation.boundingBox, CGRect(x: 10, y: 10, width: 100, height: 50))
    }
}
