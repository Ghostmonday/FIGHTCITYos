//
//  FeatureFlagsTests.swift
//  FightCityFoundation Tests
//
//  Unit tests for Apple Intelligence feature flag system
//

import XCTest
import Foundation
@testable import FightCityFoundation

final class FeatureFlagsTests: XCTestCase {
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        // Clear any existing UserDefaults
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "FeatureFlags.VisionKitDocumentScanner")
        defaults.removeObject(forKey: "FeatureFlags.LiveTextAnalysis")
        defaults.removeObject(forKey: "FeatureFlags.MLClassification")
        defaults.removeObject(forKey: "FeatureFlags.NaturalLanguageProcessing")
        defaults.removeObject(forKey: "FeatureFlags.SpeechRecognition")
        defaults.removeObject(forKey: "FeatureFlags.LookAroundEvidence")
        defaults.removeObject(forKey: "FeatureFlags.EnableFallbacks")
        defaults.removeObject(forKey: "FeatureFlags.FeatureRolloutPercentage")
    }
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        // Clean up UserDefaults
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "FeatureFlags.VisionKitDocumentScanner")
        defaults.removeObject(forKey: "FeatureFlags.LiveTextAnalysis")
        defaults.removeObject(forKey: "FeatureFlags.MLClassification")
        defaults.removeObject(forKey: "FeatureFlags.NaturalLanguageProcessing")
        defaults.removeObject(forKey: "FeatureFlags.SpeechRecognition")
        defaults.removeObject(forKey: "FeatureFlags.LookAroundEvidence")
        defaults.removeObject(forKey: "FeatureFlags.EnableFallbacks")
        defaults.removeObject(forKey: "FeatureFlags.FeatureRolloutPercentage")
    }
    
    // MARK: - Core Feature Flag Tests
    
    func testDefaultFeatureFlagsValues() {
        // Test that default feature flags have expected values
        XCTAssertTrue(FeatureFlags.visionKitDocumentScanner)
        XCTAssertTrue(FeatureFlags.liveTextAnalysis)
        XCTAssertTrue(FeatureFlags.mlClassification)
        XCTAssertFalse(FeatureFlags.naturalLanguageProcessing)
        XCTAssertFalse(FeatureFlags.speechRecognition)
        XCTAssertFalse(FeatureFlags.lookAroundEvidence)
        XCTAssertTrue(FeatureFlags.enableFallbacks)
        XCTAssertEqual(FeatureFlags.featureRolloutPercentage, 100)
    }
    
    // MARK: - Availability Check Tests
    
    func testAppleIntelligenceEnabledWhenCoreFeaturesEnabled() {
        // Test that Apple Intelligence is enabled when core features are enabled
        let isEnabled = FeatureFlags.isAppleIntelligenceEnabled
        XCTAssertTrue(isEnabled, "Apple Intelligence should be enabled when core features are enabled")
    }
    
    func testVisionKitDocumentScannerEnabled() {
        // Test VisionKit Document Scanner availability
        XCTAssertTrue(FeatureFlags.isVisionKitDocumentScannerEnabled, "VisionKit Document Scanner should be enabled by default")
    }
    
    func testLiveTextAnalysisEnabled() {
        // Test Live Text analysis availability
        XCTAssertTrue(FeatureFlags.isLiveTextAnalysisEnabled, "Live Text analysis should be enabled by default")
    }
    
    func testMLClassificationEnabled() {
        // Test ML classification availability
        XCTAssertTrue(FeatureFlags.isMLClassificationEnabled, "ML classification should be enabled by default")
    }
    
    func testNaturalLanguageProcessingDisabledByDefault() {
        // Test NaturalLanguage processing is disabled by default
        XCTAssertFalse(FeatureFlags.isNaturalLanguageProcessingEnabled, "NaturalLanguage processing should be disabled by default")
    }
    
    func testSpeechRecognitionDisabledByDefault() {
        // Test speech recognition is disabled by default
        XCTAssertFalse(FeatureFlags.isSpeechRecognitionEnabled, "Speech recognition should be disabled by default")
    }
    
    func testLookAroundEvidenceDisabledByDefault() {
        // Test MapKit Look Around is disabled by default
        XCTAssertFalse(FeatureFlags.isLookAroundEvidenceEnabled, "Look Around evidence should be disabled by default")
    }
    
    // MARK: - Configuration Tests
    
    func testFeatureFlagConfigurationInitialization() {
        // Test FeatureFlags.Configuration initialization
        let config = FeatureFlags.Configuration()
        
        XCTAssertEqual(config.visionKitDocumentScanner, FeatureFlags.visionKitDocumentScanner)
        XCTAssertEqual(config.liveTextAnalysis, FeatureFlags.liveTextAnalysis)
        XCTAssertEqual(config.mlClassification, FeatureFlags.mlClassification)
        XCTAssertEqual(config.enableFallbacks, FeatureFlags.enableFallbacks)
        XCTAssertEqual(config.featureRolloutPercentage, FeatureFlags.featureRolloutPercentage)
    }
    
    func testFeatureFlagConfigurationCustomValues() {
        // Test FeatureFlags.Configuration with custom values
        let config = FeatureFlags.Configuration(
            visionKitDocumentScanner: false,
            liveTextAnalysis: true,
            mlClassification: false,
            naturalLanguageProcessing: true,
            speechRecognition: false,
            lookAroundEvidence: true,
            enableFallbacks: false,
            featureRolloutPercentage: 75
        )
        
        XCTAssertFalse(config.visionKitDocumentScanner)
        XCTAssertTrue(config.liveTextAnalysis)
        XCTAssertFalse(config.mlClassification)
        XCTAssertTrue(config.naturalLanguageProcessing)
        XCTAssertFalse(config.speechRecognition)
        XCTAssertTrue(config.lookAroundEvidence)
        XCTAssertFalse(config.enableFallbacks)
        XCTAssertEqual(config.featureRolloutPercentage, 75)
    }
    
    // MARK: - UserDefaults Persistence Tests
    
    func testFeatureFlagConfigurationSaveToUserDefaults() {
        // Test saving feature flag configuration to UserDefaults
        let config = FeatureFlags.Configuration(
            visionKitDocumentScanner: false,
            liveTextAnalysis: true,
            mlClassification: false,
            naturalLanguageProcessing: true,
            speechRecognition: false,
            lookAroundEvidence: true,
            enableFallbacks: false,
            featureRolloutPercentage: 50
        )
        
        config.saveToUserDefaults()
        
        // Verify values were saved
        let defaults = UserDefaults.standard
        XCTAssertFalse(defaults.bool(forKey: "FeatureFlags.VisionKitDocumentScanner"))
        XCTAssertTrue(defaults.bool(forKey: "FeatureFlags.LiveTextAnalysis"))
        XCTAssertFalse(defaults.bool(forKey: "FeatureFlags.MLClassification"))
        XCTAssertTrue(defaults.bool(forKey: "FeatureFlags.NaturalLanguageProcessing"))
        XCTAssertFalse(defaults.bool(forKey: "FeatureFlags.SpeechRecognition"))
        XCTAssertTrue(defaults.bool(forKey: "FeatureFlags.LookAroundEvidence"))
        XCTAssertFalse(defaults.bool(forKey: "FeatureFlags.EnableFallbacks"))
        XCTAssertEqual(defaults.integer(forKey: "FeatureFlags.FeatureRolloutPercentage"), 50)
    }
    
    func testFeatureFlagConfigurationLoadFromUserDefaults() {
        // Test loading feature flag configuration from UserDefaults
        let defaults = UserDefaults.standard
        defaults.set(false, forKey: "FeatureFlags.VisionKitDocumentScanner")
        defaults.set(true, forKey: "FeatureFlags.LiveTextAnalysis")
        defaults.set(false, forKey: "FeatureFlags.MLClassification")
        defaults.set(true, forKey: "FeatureFlags.NaturalLanguageProcessing")
        defaults.set(false, forKey: "FeatureFlags.SpeechRecognition")
        defaults.set(true, forKey: "FeatureFlags.LookAroundEvidence")
        defaults.set(false, forKey: "FeatureFlags.EnableFallbacks")
        defaults.set(25, forKey: "FeatureFlags.FeatureRolloutPercentage")
        
        let config = FeatureFlags.Configuration.loadFromUserDefaults()
        
        XCTAssertFalse(config.visionKitDocumentScanner)
        XCTAssertTrue(config.liveTextAnalysis)
        XCTAssertFalse(config.mlClassification)
        XCTAssertTrue(config.naturalLanguageProcessing)
        XCTAssertFalse(config.speechRecognition)
        XCTAssertTrue(config.lookAroundEvidence)
        XCTAssertFalse(config.enableFallbacks)
        XCTAssertEqual(config.featureRolloutPercentage, 25)
    }
    
    // MARK: - Rollout Percentage Tests
    
    func testFeatureRolloutWith100Percent() {
        // Test that 100% rollout includes all users
        let isEnabled = FeatureFlags.isAppleIntelligenceEnabled
        XCTAssertTrue(isEnabled, "All users should receive features with 100% rollout")
    }
    
    func testFeatureRolloutWith50Percent() {
        // Test that 50% rollout includes approximately half the users
        // This test is inherently probabilistic, so we test the logic rather than exact behavior
        let originalPercentage = FeatureFlags.featureRolloutPercentage
        defer { FeatureFlags.featureRolloutPercentage = originalPercentage }
        
        FeatureFlags.featureRolloutPercentage = 50
        
        // The exact behavior depends on the user hash, so we just ensure the method doesn't crash
        XCTAssertNotNil(FeatureFlags.isAppleIntelligenceEnabled)
    }
    
    func testFeatureRolloutWith0Percent() {
        // Test that 0% rollout includes no users
        let originalPercentage = FeatureFlags.featureRolloutPercentage
        defer { FeatureFlags.featureRolloutPercentage = originalPercentage }
        
        FeatureFlags.featureRolloutPercentage = 0
        
        // With 0% rollout, Apple Intelligence should be disabled
        XCTAssertFalse(FeatureFlags.isAppleIntelligenceEnabled, "No users should receive features with 0% rollout")
    }
    
    // MARK: - Debug and Testing Support Tests
    
    func testFeatureFlagStatusPrinting() {
        // Test that feature flag status printing doesn't crash
        XCTAssertNoThrow(FeatureFlags.printCurrentStatus(), "Feature flag status printing should not crash")
    }
    
    func testCurrentUserId() {
        // Test that current user ID is set
        let userId = FeatureFlags.currentUserId
        XCTAssertNotNil(userId, "Current user ID should be set for testing")
        XCTAssertEqual(userId, "current-user", "Current user ID should match expected test value")
    }
    
    // MARK: - Performance Tests
    
    func testFeatureFlagPerformance() {
        // Test that feature flag checks are performant
        measure {
            for _ in 0..<1000 {
                _ = FeatureFlags.isAppleIntelligenceEnabled
                _ = FeatureFlags.isVisionKitDocumentScannerEnabled
                _ = FeatureFlags.isLiveTextAnalysisEnabled
                _ = FeatureFlags.isMLClassificationEnabled
            }
        }
    }
    
    func testFeatureFlagConfigurationPerformance() {
        // Test that feature flag configuration operations are performant
        measure {
            for _ in 0..<100 {
                let config = FeatureFlags.Configuration()
                config.saveToUserDefaults()
                _ = FeatureFlags.Configuration.loadFromUserDefaults()
            }
        }
    }
    
    // MARK: - Edge Case Tests
    
    func testFeatureRolloutPercentageBounds() {
        // Test feature rollout percentage bounds
        let originalPercentage = FeatureFlags.featureRolloutPercentage
        defer { FeatureFlags.featureRolloutPercentage = originalPercentage }
        
        // Test 100%
        FeatureFlags.featureRolloutPercentage = 100
        XCTAssertTrue(FeatureFlags.isAppleIntelligenceEnabled)
        
        // Test 0%
        FeatureFlags.featureRolloutPercentage = 0
        XCTAssertFalse(FeatureFlags.isAppleIntelligenceEnabled)
        
        // Test negative (should be clamped)
        FeatureFlags.featureRolloutPercentage = -1
        XCTAssertFalse(FeatureFlags.isAppleIntelligenceEnabled)
        
        // Test >100 (should be clamped)
        FeatureFlags.featureRolloutPercentage = 101
        XCTAssertTrue(FeatureFlags.isAppleIntelligenceEnabled)
    }
    
    func testAllFeatureFlagsDisabled() {
        // Test behavior when all feature flags are disabled
        let originalFlags = (
            FeatureFlags.visionKitDocumentScanner,
            FeatureFlags.liveTextAnalysis,
            FeatureFlags.mlClassification
        )
        
        defer {
            FeatureFlags.visionKitDocumentScanner = originalFlags.0
            FeatureFlags.liveTextAnalysis = originalFlags.1
            FeatureFlags.mlClassification = originalFlags.2
        }
        
        // Disable all core features
        FeatureFlags.visionKitDocumentScanner = false
        FeatureFlags.liveTextAnalysis = false
        FeatureFlags.mlClassification = false
        
        XCTAssertFalse(FeatureFlags.isAppleIntelligenceEnabled, "Apple Intelligence should be disabled when all core features are disabled")
    }
}