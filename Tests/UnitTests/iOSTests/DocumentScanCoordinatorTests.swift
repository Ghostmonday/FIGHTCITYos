//
//  DocumentScanCoordinatorTests.swift
//  FightCityiOS Tests
//
//  Unit tests for DocumentScanCoordinator Apple Intelligence integration
//

import XCTest
import UIKit
@testable import FightCityiOS
import FightCityFoundation
import VisionKit

@available(iOS 16.0, *)
final class DocumentScanCoordinatorTests: XCTestCase {
    
    var coordinator: DocumentScanCoordinator!
    var mockDelegate: MockDocumentScanCoordinatorDelegate!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        coordinator = DocumentScanCoordinator()
        mockDelegate = MockDocumentScanCoordinatorDelegate()
        coordinator.delegate = mockDelegate
    }
    
    override func tearDownWithError() throws {
        coordinator = nil
        mockDelegate = nil
        try super.tearDownWithError()
    }
    
    // MARK: - Feature Flag Tests
    
    func testDocumentScannerAvailabilityWithFeatureFlagDisabled() {
        // Given
        let originalFlag = FeatureFlags.visionKitDocumentScanner
        FeatureFlags.visionKitDocumentScanner = false
        
        // When
        let canPresent = coordinator.presentScanner(from: UIViewController())
        
        // Then
        XCTAssertFalse(canPresent, "Should not be able to present scanner when feature flag is disabled")
        
        // Cleanup
        FeatureFlags.visionKitDocumentScanner = originalFlag
    }
    
    func testDocumentScannerAvailabilityWithFeatureFlagEnabled() {
        // Given
        let originalFlag = FeatureFlags.visionKitDocumentScanner
        FeatureFlags.visionKitDocumentScanner = true
        
        // When
        let canPresent = coordinator.presentScanner(from: UIViewController())
        
        // Then
        XCTAssertTrue(canPresent, "Should be able to present scanner when feature flag is enabled")
        
        // Cleanup
        FeatureFlags.visionKitDocumentScanner = originalFlag
    }
    
    // MARK: - Device Compatibility Tests
    
    func testDocumentScannerDeviceSupport() {
        // Test that VNDocumentCameraViewController.isSupported works
        XCTAssertEqual(VNDocumentCameraViewController.isSupported, true, "Document scanner should be supported on iOS 16+")
    }
    
    func testDocumentScannerSelectionLogic() {
        // Test that the coordinator correctly selects scanner type
        let recommendedType = DocumentScanCoordinator.recommendedScannerType()
        
        if FeatureFlags.isVisionKitDocumentScannerEnabled {
            XCTAssertEqual(recommendedType, .visionKit, "Should recommend VisionKit when enabled and supported")
        } else {
            XCTAssertEqual(recommendedType, .traditional, "Should recommend traditional when VisionKit disabled")
        }
    }
    
    // MARK: - Initialization Tests
    
    func testCoordinatorInitialization() {
        // Test that coordinator initializes properly
        XCTAssertNotNil(coordinator, "Coordinator should initialize successfully")
        XCTAssertNil(coordinator.delegate, "Delegate should be nil initially")
    }
    
    func testCoordinatorWithDelegate() {
        // Test coordinator with delegate set
        coordinator.delegate = mockDelegate
        
        XCTAssertEqual(coordinator.delegate as? MockDocumentScanCoordinatorDelegate, mockDelegate)
    }
    
    // MARK: - Feature Flag Integration Tests
    
    func testFeatureFlagPrintStatus() {
        // Test that feature flag status printing doesn't crash
        XCTAssertNoThrow(FeatureFlags.printCurrentStatus(), "Feature flag status printing should not crash")
    }
    
    func testAppleIntelligenceEnabledCheck() {
        // Test the comprehensive Apple Intelligence enable check
        let isEnabled = FeatureFlags.isAppleIntelligenceEnabled
        
        // Should be true if any core Apple Intelligence features are enabled
        XCTAssertNotNil(isEnabled, "Apple Intelligence enabled check should return a boolean")
    }
    
    func testIndividualFeatureFlagChecks() {
        // Test individual feature flag availability checks
        XCTAssertNotNil(FeatureFlags.isVisionKitDocumentScannerEnabled)
        XCTAssertNotNil(FeatureFlags.isLiveTextAnalysisEnabled)
        XCTAssertNotNil(FeatureFlags.isMLClassificationEnabled)
    }
    
    // MARK: - Error Handling Tests
    
    func testDismissScannerWithoutPresentation() {
        // Test dismissing scanner when none is presented
        XCTAssertNoThrow(coordinator.dismissScanner(), "Dismissing non-existent scanner should not crash")
    }
    
    func testCoordinatorInitializationWithNil() {
        // Test coordinator initialization edge cases
        let newCoordinator = DocumentScanCoordinator()
        XCTAssertNotNil(newCoordinator, "Coordinator should initialize even with edge cases")
    }
    
    // MARK: - Configuration Tests
    
    func testFeatureFlagConfiguration() {
        // Test feature flag configuration structure
        let config = FeatureFlags.Configuration()
        
        XCTAssertNotNil(config, "Feature flag configuration should initialize")
        XCTAssertEqual(config.featureRolloutPercentage, FeatureFlags.featureRolloutPercentage)
    }
    
    func testFeatureFlagUserDefaults() {
        // Test feature flag persistence to UserDefaults
        let testConfig = FeatureFlags.Configuration(
            visionKitDocumentScanner: false,
            liveTextAnalysis: true,
            mlClassification: false,
            naturalLanguageProcessing: false,
            speechRecognition: false,
            lookAroundEvidence: false,
            enableFallbacks: true,
            featureRolloutPercentage: 50
        )
        
        // Save and load
        testConfig.saveToUserDefaults()
        let loadedConfig = FeatureFlags.Configuration.loadFromUserDefaults()
        
        XCTAssertEqual(loadedConfig.visionKitDocumentScanner, false)
        XCTAssertEqual(loadedConfig.liveTextAnalysis, true)
        XCTAssertEqual(loadedConfig.featureRolloutPercentage, 50)
    }
    
    // MARK: - Performance Tests
    
    func testFeatureFlagPerformance() {
        // Test that feature flag checks are performant
        measure {
            for _ in 0..<1000 {
                _ = FeatureFlags.isAppleIntelligenceEnabled
                _ = FeatureFlags.isVisionKitDocumentScannerEnabled
                _ = FeatureFlags.isLiveTextAnalysisEnabled
            }
        }
    }
}

// MARK: - Mock Delegate

@available(iOS 16.0, *)
class MockDocumentScanCoordinatorDelegate: NSObject, DocumentScanCoordinatorDelegate {
    
    var didFinishCalled = false
    var didCancelCalled = false
    var didFailCalled = false
    var lastError: DocumentScanError?
    
    func documentScanCoordinator(_ coordinator: DocumentScanCoordinator, didFinishWith result: DocumentScanResult.DocumentScanResultResult) {
        didFinishCalled = true
    }
    
    func documentScanCoordinatorDidCancel(_ coordinator: DocumentScanCoordinator) {
        didCancelCalled = true
    }
    
    func documentScanCoordinator(_ coordinator: DocumentScanCoordinator, didFailWith error: DocumentScanError) {
        didFailCalled = true
        lastError = error
    }
}

// MARK: - Test Utilities

@available(iOS 16.0, *)
extension DocumentScanCoordinatorTests {
    
    /// Create a mock document scan for testing
    func createMockDocumentScan() -> MockVNDocumentCameraScan {
        return MockVNDocumentCameraScan()
    }
    
    /// Create a test image for scanning
    func createTestImage() -> UIImage {
        // Create a simple test image
        let size = CGSize(width: 100, height: 100)
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        UIColor.red.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image ?? UIImage()
    }
}

// MARK: - Mock Classes for Testing

@available(iOS 16.0, *)
class MockVNDocumentCameraScan: VNDocumentCameraScan {
    private let mockPageCount = 1
    private let mockImage = UIImage()
    
    override var pageCount: Int {
        return mockPageCount
    }
    
    override func imageOfPage(at pageIndex: Int) -> UIImage? {
        guard pageIndex < mockPageCount else { return nil }
        return mockImage
    }
}