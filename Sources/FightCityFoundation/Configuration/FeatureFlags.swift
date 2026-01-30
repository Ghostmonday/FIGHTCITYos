//
//  FeatureFlags.swift
//  FightCityFoundation
//
//  Apple Intelligence feature flag management
//

import Foundation

/// Feature flags for Apple Intelligence implementation
/// These flags control the gradual rollout and backward compatibility
public struct FeatureFlags {
    
    // MARK: - Apple Intelligence Core Features
    
    /// Enables VisionKit Document Scanner for intelligent document capture
    public static let visionKitDocumentScanner = true
    
    /// Enables Live Text integration for real-time text analysis
    public static let liveTextAnalysis = true
    
    /// Enables Core ML classification for intelligent citation parsing
    public static let mlClassification = true
    
    // MARK: - Apple Intelligence Enhancement Features
    
    /// Enables NaturalLanguage processing for appeal writing assistance
    public static let naturalLanguageProcessing = false // Coming in Week 7
    
    /// Enables speech recognition for dictation features
    public static let speechRecognition = false // Coming in Week 7
    
    /// Enables MapKit Look Around for evidence collection
    public static let lookAroundEvidence = false // Coming in Week 9
    
    /// Enables Vision-based parking sign detection
    public static let visionSignDetection = false // Coming in Week 9
    
    // MARK: - Platform Features
    
    /// Enables App Intents for shortcuts integration
    public static let appIntents = false // Coming in Week 11
    
    /// Enables Live Activities for deadline tracking
    public static let liveActivities = false // Coming in Week 11
    
    /// Enables WidgetKit for quick actions
    public static let widgets = false // Coming in Week 11
    
    /// Enables smart notifications with AI assistance
    public static let smartNotifications = false // Coming in Week 11
    
    // MARK: - Fallback and Compatibility
    
    /// Enables fallback to traditional Vision framework when Apple Intelligence features fail
    public static let enableFallbacks = true
    
    /// Enables beta testing mode for gradual rollout
    public static let betaTestingMode = false // Set to true during beta testing
    
    /// Enables debug logging for Apple Intelligence features
    public static let debugLogging = false // Set to true for development
    
    // MARK: - Configuration Properties
    
    /// Percentage of users who should receive Apple Intelligence features (0-100)
    public static let featureRolloutPercentage: Int = 100 // 100% for immediate rollout
    
    /// User identifier for tracking feature adoption (for gradual rollout)
    public static var currentUserId: String? {
        // In production, this would be the actual user ID
        // For now, returning a constant for immediate rollout
        return "current-user"
    }
    
    // MARK: - Feature Availability Checkers
    
    /// Checks if Apple Intelligence features should be enabled for current user
    public static var isAppleIntelligenceEnabled: Bool {
        guard visionKitDocumentScanner || liveTextAnalysis || mlClassification else {
            return false
        }
        
        // Check if user is in rollout percentage
        if featureRolloutPercentage < 100, let userId = currentUserId {
            let userHash = userId.hashValue % 100
            return userHash < featureRolloutPercentage
        }
        
        return true
    }
    
    /// Checks if VisionKit Document Scanner is available and enabled
    public static var isVisionKitDocumentScannerEnabled: Bool {
        guard #available(iOS 16.0, *) else { return false }
        return visionKitDocumentScanner && isAppleIntelligenceEnabled
    }
    
    /// Checks if Live Text analysis is available and enabled
    public static var isLiveTextAnalysisEnabled: Bool {
        guard #available(iOS 16.0, *) else { return false }
        return liveTextAnalysis && isAppleIntelligenceEnabled
    }
    
    /// Checks if ML classification is available and enabled
    public static var isMLClassificationEnabled: Bool {
        guard #available(iOS 16.0, *) else { return false }
        return mlClassification && isAppleIntelligenceEnabled
    }
    
    /// Checks if NaturalLanguage processing is available and enabled
    public static var isNaturalLanguageProcessingEnabled: Bool {
        guard #available(iOS 16.0, *) else { return false }
        return naturalLanguageProcessing && isAppleIntelligenceEnabled
    }
    
    /// Checks if speech recognition is available and enabled
    public static var isSpeechRecognitionEnabled: Bool {
        guard #available(iOS 16.0, *) else { return false }
        return speechRecognition && isAppleIntelligenceEnabled
    }
    
    /// Checks if MapKit Look Around is available and enabled
    public static var isLookAroundEvidenceEnabled: Bool {
        guard #available(iOS 17.0, *) else { return false }
        return lookAroundEvidence && isAppleIntelligenceEnabled
    }
    
    // MARK: - Feature Flag Configuration
    
    /// Configuration for feature flags (can be overridden via UserDefaults or remote config)
    public struct Configuration {
        public var visionKitDocumentScanner: Bool
        public var liveTextAnalysis: Bool
        public var mlClassification: Bool
        public var naturalLanguageProcessing: Bool
        public var speechRecognition: Bool
        public var lookAroundEvidence: Bool
        public var enableFallbacks: Bool
        public var featureRolloutPercentage: Int
        
        public init(
            visionKitDocumentScanner: Bool = FeatureFlags.visionKitDocumentScanner,
            liveTextAnalysis: Bool = FeatureFlags.liveTextAnalysis,
            mlClassification: Bool = FeatureFlags.mlClassification,
            naturalLanguageProcessing: Bool = FeatureFlags.naturalLanguageProcessing,
            speechRecognition: Bool = FeatureFlags.speechRecognition,
            lookAroundEvidence: Bool = FeatureFlags.lookAroundEvidence,
            enableFallbacks: Bool = FeatureFlags.enableFallbacks,
            featureRolloutPercentage: Int = FeatureFlags.featureRolloutPercentage
        ) {
            self.visionKitDocumentScanner = visionKitDocumentScanner
            self.liveTextAnalysis = liveTextAnalysis
            self.mlClassification = mlClassification
            self.naturalLanguageProcessing = naturalLanguageProcessing
            self.speechRecognition = speechRecognition
            self.lookAroundEvidence = lookAroundEvidence
            self.enableFallbacks = enableFallbacks
            self.featureRolloutPercentage = featureRolloutPercentage
        }
        
        /// Update feature flags from remote configuration or UserDefaults
        public static func loadFromUserDefaults() -> Configuration {
            let defaults = UserDefaults.standard
            
            return Configuration(
                visionKitDocumentScanner: defaults.bool(forKey: "FeatureFlags.VisionKitDocumentScanner"),
                liveTextAnalysis: defaults.bool(forKey: "FeatureFlags.LiveTextAnalysis"),
                mlClassification: defaults.bool(forKey: "FeatureFlags.MLClassification"),
                naturalLanguageProcessing: defaults.bool(forKey: "FeatureFlags.NaturalLanguageProcessing"),
                speechRecognition: defaults.bool(forKey: "FeatureFlags.SpeechRecognition"),
                lookAroundEvidence: defaults.bool(forKey: "FeatureFlags.LookAroundEvidence"),
                enableFallbacks: defaults.bool(forKey: "FeatureFlags.EnableFallbacks"),
                featureRolloutPercentage: defaults.integer(forKey: "FeatureFlags.FeatureRolloutPercentage")
            )
        }
        
        /// Save feature flag configuration to UserDefaults
        public func saveToUserDefaults() {
            let defaults = UserDefaults.standard
            
            defaults.set(visionKitDocumentScanner, forKey: "FeatureFlags.VisionKitDocumentScanner")
            defaults.set(liveTextAnalysis, forKey: "FeatureFlags.LiveTextAnalysis")
            defaults.set(mlClassification, forKey: "FeatureFlags.MLClassification")
            defaults.set(naturalLanguageProcessing, forKey: "FeatureFlags.NaturalLanguageProcessing")
            defaults.set(speechRecognition, forKey: "FeatureFlags.SpeechRecognition")
            defaults.set(lookAroundEvidence, forKey: "FeatureFlags.LookAroundEvidence")
            defaults.set(enableFallbacks, forKey: "FeatureFlags.EnableFallbacks")
            defaults.set(featureRolloutPercentage, forKey: "FeatureFlags.FeatureRolloutPercentage")
        }
    }
    
    // MARK: - Debug and Testing Support
    
    /// Print current feature flag status (for debugging)
    public static func printCurrentStatus() {
        print("=== Apple Intelligence Feature Flags Status ===")
        print("VisionKit Document Scanner: \(visionKitDocumentScanner)")
        print("Live Text Analysis: \(liveTextAnalysis)")
        print("ML Classification: \(mlClassification)")
        print("NaturalLanguage Processing: \(naturalLanguageProcessing)")
        print("Speech Recognition: \(speechRecognition)")
        print("Look Around Evidence: \(lookAroundEvidence)")
        print("Enable Fallbacks: \(enableFallbacks)")
        print("Feature Rollout Percentage: \(featureRolloutPercentage)%")
        print("Apple Intelligence Enabled: \(isAppleIntelligenceEnabled)")
        print("========================================")
    }
}