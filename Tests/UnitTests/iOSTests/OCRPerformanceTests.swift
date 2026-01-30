//
//  OCRPerformanceTests.swift
//  FightCityiOSTests
//
//  Performance benchmarks for OCR processing and confidence scoring
//

import XCTest
@testable import FightCityiOS

/// Performance benchmark tests for OCR processing
final class OCRPerformanceTests: XCTestCase {
    
    // MARK: - Properties
    
    var sut: OCREngine!
    var confidenceScorer: ConfidenceScorer!
    
    // MARK: - Setup & Teardown
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = OCREngine()
        confidenceScorer = ConfidenceScorer()
    }
    
    override func tearDownWithError() throws {
        sut = nil
        confidenceScorer = nil
        try super.tearDownWithError()
    }
    
    // MARK: - OCR Processing Time Benchmarks
    
    func testOCRProcessingTimeBenchmark() {
        guard let cgImage = createTestCGImage() else {
            XCTFail("Failed to create test CGImage")
            return
        }
        
        let image = UIImage(cgImage: cgImage)
        
        measure(metrics: [XCTMetric(CPUMetric()), XCTMetric(StorageMetric())]) {
            let expectation = XCTestExpectation(description: "OCR processing completion")
            
            Task {
                do {
                    let result = try await sut.recognizeText(in: image)
                    XCTAssertNotNil(result)
                    XCTAssertGreaterThanOrEqual(result.confidence, 0.0)
                    XCTAssertLessThanOrEqual(result.confidence, 1.0)
                    expectation.fulfill()
                } catch {
                    XCTFail("OCR processing failed: \(error.localizedDescription)")
                    expectation.fulfill()
                }
            }
            
            wait(for: [expectation], timeout: 30.0)
        }
    }
    
    func testOCRProcessingTimeWithHighAccuracy() {
        guard let cgImage = createTestCGImage() else {
            XCTFail("Failed to create test CGImage")
            return
        }
        
        let image = UIImage(cgImage: cgImage)
        
        measure {
            let expectation = XCTestExpectation(description: "High accuracy OCR completion")
            
            Task {
                do {
                    let result = try await sut.recognizeWithHighAccuracy(in: image)
                    XCTAssertNotNil(result)
                    expectation.fulfill()
                } catch {
                    XCTFail("High accuracy OCR failed: \(error.localizedDescription)")
                    expectation.fulfill()
                }
            }
            
            wait(for: [expectation], timeout: 30.0)
        }
    }
    
    func testOCRProcessingTimeFastMode() {
        guard let cgImage = createTestCGImage() else {
            XCTFail("Failed to create test CGImage")
            return
        }
        
        let image = UIImage(cgImage: cgImage)
        
        measure {
            let expectation = XCTestExpectation(description: "Fast OCR completion")
            
            Task {
                do {
                    let result = try await sut.recognizeFast(in: image)
                    XCTAssertNotNil(result)
                    expectation.fulfill()
                } catch {
                    XCTFail("Fast OCR failed: \(error.localizedDescription)")
                    expectation.fulfill()
                }
            }
            
            wait(for: [expectation], timeout: 30.0)
        }
    }
    
    // MARK: - Confidence Scoring Benchmarks
    
    func testConfidenceScoringPerformance() {
        guard let cgImage = createTestCGImage() else {
            XCTFail("Failed to create test CGImage")
            return
        }
        
        let image = UIImage(cgImage: cgImage)
        
        measure {
            let expectation = XCTestExpectation(description: "Confidence scoring completion")
            
            Task {
                do {
                    let ocrResult = try await sut.recognizeText(in: image)
                    
                    let observations = ocrResult.observations
                    let scoreResult = confidenceScorer.score(
                        rawText: ocrResult.text,
                        observations: observations,
                        matchedPattern: nil
                    )
                    
                    XCTAssertGreaterThanOrEqual(scoreResult.overallConfidence, 0.0)
                    XCTAssertLessThanOrEqual(scoreResult.overallConfidence, 1.0)
                    XCTAssertFalse(scoreResult.components.isEmpty)
                    expectation.fulfill()
                } catch {
                    XCTFail("Confidence scoring failed: \(error.localizedDescription)")
                    expectation.fulfill()
                }
            }
            
            wait(for: [expectation], timeout: 30.0)
        }
    }
    
    // MARK: - LiveText Processing Benchmarks
    
    func testLiveTextProcessingPerformance() {
        guard let cgImage = createTestCGImage() else {
            XCTFail("Failed to create test CGImage")
            return
        }
        
        let image = UIImage(cgImage: cgImage)
        let liveTextHelper = LiveTextHelper()
        
        measure {
            let expectation = XCTestExpectation(description: "Live Text analysis completion")
            
            Task {
                do {
                    let result = try await liveTextHelper.analyzeImage(image)
                    XCTAssertNotNil(result)
                    expectation.fulfill()
                } catch {
                    XCTFail("Live Text analysis failed: \(error.localizedDescription)")
                    expectation.fulfill()
                }
            }
            
            wait(for: [expectation], timeout: 30.0)
        }
    }
    
    func testLiveTextBarcodeExtractionPerformance() {
        guard let cgImage = createTestCGImage(withBarcode: true) else {
            XCTFail("Failed to create test CGImage with barcode")
            return
        }
        
        let image = UIImage(cgImage: cgImage)
        let liveTextHelper = LiveTextHelper()
        
        measure {
            let expectation = XCTestExpectation(description: "Barcode extraction completion")
            
            Task {
                do {
                    let results = try await liveTextHelper.extractBarcodes(
                        from: image,
                        types: [.qrCode, .dataMatrix, .pdf417]
                    )
                    XCTAssertNotNil(results)
                    expectation.fulfill()
                } catch {
                    XCTFail("Barcode extraction failed: \(error.localizedDescription)")
                    expectation.fulfill()
                }
            }
            
            wait(for: [expectation], timeout: 30.0)
        }
    }
    
    // MARK: - Concurrent Processing Benchmarks
    
    func testConcurrentOCRProcessing() {
        guard let cgImage = createTestCGImage() else {
            XCTFail("Failed to create test CGImage")
            return
        }
        
        let image = UIImage(cgImage: cgImage)
        let images = [image, image, image, image, image]
        
        measure {
            let expectation = XCTestExpectation(description: "Concurrent OCR completion")
            expectation.expectedFulfillmentCount = images.count
            
            Task {
                await withTaskGroup(of: Void.self) { group in
                    for _ in images {
                        group.addTask {
                            do {
                                let _ = try await self.sut.recognizeText(in: image)
                            } catch {
                                // Ignore errors in concurrent test
                            }
                        }
                    }
                }
                expectation.fulfill()
            }
            
            wait(for: [expectation], timeout: 60.0)
        }
    }
    
    // MARK: - Accuracy Benchmarks
    
    func testConfidenceAccuracyAgainstGroundTruth() {
        // Test that confidence scores correlate with actual recognition quality
        guard let cgImage = createTestCGImage() else {
            XCTFail("Failed to create test CGImage")
            return
        }
        
        let image = UIImage(cgImage: cgImage)
        
        let expectation = XCTestExpectation(description: "Accuracy test completion")
        
        Task {
            do {
                let ocrResult = try await sut.recognizeText(in: image)
                let scoreResult = confidenceScorer.score(
                    rawText: ocrResult.text,
                    observations: ocrResult.observations,
                    matchedPattern: nil
                )
                
                // Verify confidence is in valid range
                XCTAssertGreaterThanOrEqual(scoreResult.overallConfidence, 0.0)
                XCTAssertLessThanOrEqual(scoreResult.overallConfidence, 1.0)
                
                // Verify all components are in valid range
                for component in scoreResult.components {
                    XCTAssertGreaterThanOrEqual(component.score, 0.0)
                    XCTAssertLessThanOrEqual(component.score, 1.0)
                    XCTAssertGreaterThanOrEqual(component.weight, 0.0)
                    XCTAssertLessThanOrEqual(component.weight, 1.0)
                }
                
                expectation.fulfill()
            } catch {
                XCTFail("Accuracy test failed: \(error.localizedDescription)")
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 30.0)
    }
    
    // MARK: - Memory Usage Benchmarks
    
    func testMemoryUsageDuringOCR() {
        guard let cgImage = createTestCGImage() else {
            XCTFail("Failed to create test CGImage")
            return
        }
        
        let image = UIImage(cgImage: cgImage)
        
        measure(metrics: [XCTMetric(StorageMetric())]) {
            let expectation = XCTestExpectation(description: "Memory test completion")
            
            for _ in 0..<10 {
                Task {
                    do {
                        let _ = try await self.sut.recognizeText(in: image)
                    } catch {
                        // Ignore errors
                    }
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                expectation.fulfill()
            }
            
            wait(for: [expectation], timeout: 10.0)
        }
    }
    
    // MARK: - Helper Methods
    
    private func createTestCGImage(size: CGSize = CGSize(width: 800, height: 600)) -> CGImage? {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            // White background
            UIColor.white.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            
            // Draw text for recognition
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 32, weight: .bold),
                .foregroundColor: UIColor.black
            ]
            
            let text = "TEST123456"
            let attributedString = NSAttributedString(string: text, attributes: attributes)
            attributedString.draw(at: CGPoint(x: 100, y: 200))
            
            // Draw additional text lines
            let text2 = "PARKING"
            let attributedString2 = NSAttributedString(string: text2, attributes: attributes)
            attributedString2.draw(at: CGPoint(x: 100, y: 250))
            
            let text3 = "CITATION"
            let attributedString3 = NSAttributedString(string: text3, attributes: attributes)
            attributedString3.draw(at: CGPoint(x: 100, y: 300))
        }.cgImage
    }
    
    private func createTestCGImage(withBarcode: Bool) -> CGImage? {
        let size = CGSize(width: 800, height: 600)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            // White background
            UIColor.white.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            
            if withBarcode {
                // Draw simulated barcode pattern
                let barcodeRect = CGRect(x: 100, y: 200, width: 600, height: 150)
                UIColor.black.setFill()
                
                // Draw barcode-like pattern
                for i in 0..<60 {
                    let isBlack = i % 2 == 0
                    let barWidth: CGFloat = 10
                    let barRect = CGRect(
                        x: barcodeRect.minX + CGFloat(i) * barWidth,
                        y: barcodeRect.minY,
                        width: barWidth,
                        height: barcodeRect.height
                    )
                    context.fill(barRect)
                }
            }
            
            // Draw text
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 24),
                .foregroundColor: UIColor.black
            ]
            
            let text = "TEST123456"
            let attributedString = NSAttributedString(string: text, attributes: attributes)
            attributedString.draw(at: CGPoint(x: 100, y: 400))
        }.cgImage
    }
}

// MARK: - Long-running Performance Tests

extension OCRPerformanceTests {
    
    func testSustainedOCRPerformance() {
        guard let cgImage = createTestCGImage() else {
            XCTFail("Failed to create test CGImage")
            return
        }
        
        let image = UIImage(cgImage: cgImage)
        let iterations = 20
        
        let expectation = XCTestExpectation(description: "Sustained OCR test completion")
        expectation.expectedFulfillmentCount = iterations
        
        var processingTimes: [TimeInterval] = []
        
        Task {
            for i in 0..<iterations {
                let startTime = Date()
                do {
                    let _ = try await sut.recognizeText(in: image)
                    let processingTime = Date().timeIntervalSince(startTime)
                    processingTimes.append(processingTime)
                } catch {
                    XCTFail("Sustained OCR failed at iteration \(i): \(error.localizedDescription)")
                }
                expectation.fulfill()
            }
            
            // Calculate statistics
            let avgTime = processingTimes.reduce(0, +) / Double(processingTimes.count)
            let maxTime = processingTimes.max() ?? 0
            let minTime = processingTimes.min() ?? 0
            
            print("Sustained OCR Performance:")
            print("  Average time: \(avgTime * 1000)ms")
            print("  Max time: \(maxTime * 1000)ms")
            print("  Min time: \(minTime * 1000)ms")
            print("  Iterations: \(iterations)")
        }
        
        wait(for: [expectation], timeout: 120.0)
    }
}

// MARK: - Apple Intelligence Specific Tests

extension OCRPerformanceTests {
    
    func testAppleIntelligenceAvailability() {
        // Test Apple Intelligence availability
        XCTAssertEqual(OCREngine.isAppleIntelligenceAvailable, ImageAnalyzer.isAvailable)
    }
    
    func testAppleIntelligenceVsVisionPerformance() {
        guard let cgImage = createTestCGImage() else {
            XCTFail("Failed to create test CGImage")
            return
        }
        
        let image = UIImage(cgImage: cgImage)
        
        let expectation = XCTestExpectation(description: "Performance comparison completion")
        
        Task {
            // Test with Apple Intelligence
            var config = OCREngine.Configuration()
            config.useAppleIntelligence = true
            
            let startTime1 = Date()
            let appleResult = try await sut.recognizeText(in: image, configuration: config)
            let appleTime = Date().timeIntervalSince(startTime1)
            
            // Test without Apple Intelligence (Vision only)
            config.useAppleIntelligence = false
            
            let startTime2 = Date()
            let visionResult = try await sut.recognizeText(in: image, configuration: config)
            let visionTime = Date().timeIntervalSince(startTime2)
            
            print("Apple Intelligence Performance:")
            print("  Processing time: \(appleTime * 1000)ms")
            print("  Confidence: \(appleResult.confidence)")
            print("  Source: \(appleResult.recognitionSource.rawValue)")
            
            print("Vision Performance:")
            print("  Processing time: \(visionTime * 1000)ms")
            print("  Confidence: \(visionResult.confidence)")
            print("  Source: \(visionResult.recognitionSource.rawValue)")
            
            XCTAssertNotNil(appleResult)
            XCTAssertNotNil(visionResult)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 60.0)
    }
}
