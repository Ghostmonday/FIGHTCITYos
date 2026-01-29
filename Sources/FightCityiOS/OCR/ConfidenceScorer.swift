//
//  ConfidenceScorer.swift
//  FightCityiOS
//
//  Calculates confidence scores for OCR results
//

import Vision
import UIKit
import FightCityFoundation

/// Scores and evaluates OCR confidence
public struct ConfidenceScorer {
    // MARK: - Confidence Levels
    
    public enum ConfidenceLevel: String {
        case high = "high"
        case medium = "medium"
        case low = "low"
        
        public var threshold: Double {
            switch self {
            case .high: return 0.85
            case .medium: return 0.60
            case .low: return 0.0
            }
        }
        
        public var requiresReview: Bool {
            self != .high
        }
    }
    
    // MARK: - Scoring Result
    
    public struct ScoreResult {
        public let overallConfidence: Double
        public let level: ConfidenceLevel
        public let components: [ConfidenceComponent]
        public let recommendation: Recommendation
        public let shouldAutoAccept: Bool
        
        public enum Recommendation {
            case accept
            case review
            case reject
        }
        
        public init(
            overallConfidence: Double,
            level: ConfidenceLevel,
            components: [ConfidenceComponent],
            recommendation: Recommendation,
            shouldAutoAccept: Bool
        ) {
            self.overallConfidence = overallConfidence
            self.level = level
            self.components = components
            self.recommendation = recommendation
            self.shouldAutoAccept = shouldAutoAccept
        }
    }
    
    public struct ConfidenceComponent {
        public let name: String
        public let score: Double
        public let weight: Double
        public let weightedScore: Double
        
        public init(name: String, score: Double, weight: Double, weightedScore: Double) {
            self.name = name
            self.score = score
            self.weight = weight
            self.weightedScore = weightedScore
        }
    }
    
    public init() {}
    
    // MARK: - Scoring
    
    /// Score OCR result with all factors
    public func score(
        rawText: String,
        observations: [VNRecognizedTextObservation],
        matchedPattern: OCRParsingEngine.CityPattern?
    ) -> ScoreResult {
        var components: [ConfidenceComponent] = []
        
        // 1. Vision confidence
        let visionConfidence = calculateVisionConfidence(observations)
        components.append(ConfidenceComponent(
            name: "vision_confidence",
            score: visionConfidence,
            weight: 0.4,
            weightedScore: visionConfidence * 0.4
        ))
        
        // 2. Pattern match confidence
        let patternConfidence = calculatePatternConfidence(matchedPattern)
        components.append(ConfidenceComponent(
            name: "pattern_match",
            score: patternConfidence,
            weight: 0.3,
            weightedScore: patternConfidence * 0.3
        ))
        
        // 3. Text completeness
        let completenessConfidence = calculateCompleteness(rawText, matchedPattern: matchedPattern)
        components.append(ConfidenceComponent(
            name: "text_completeness",
            score: completenessConfidence,
            weight: 0.2,
            weightedScore: completenessConfidence * 0.2
        ))
        
        // 4. Observation consistency
        let consistencyConfidence = calculateConsistency(observations)
        components.append(ConfidenceComponent(
            name: "observation_consistency",
            score: consistencyConfidence,
            weight: 0.1,
            weightedScore: consistencyConfidence * 0.1
        ))
        
        // Calculate overall
        let overallScore = components.reduce(0.0) { $0 + $1.weightedScore }
        let level = determineLevel(overallScore)
        let recommendation = determineRecommendation(level)
        
        return ScoreResult(
            overallConfidence: overallScore,
            level: level,
            components: components,
            recommendation: recommendation,
            shouldAutoAccept: level == .high
        )
    }
    
    // MARK: - Component Calculations
    
    private func calculateVisionConfidence(_ observations: [VNRecognizedTextObservation]) -> Double {
        guard !observations.isEmpty else { return 0 }
        
        let totalConfidence = observations.reduce(0.0) { sum, obs in
            sum + (obs.topCandidates(1).first?.confidence ?? 0)
        }
        
        return totalConfidence / Double(observations.count)
    }
    
    private func calculatePatternConfidence(_ pattern: OCRParsingEngine.CityPattern?) -> Double {
        guard let pattern = pattern else { return 0.5 }
        
        // Higher confidence for more specific patterns
        switch pattern.priority {
        case 1: return 0.95 // SF - very specific
        case 2: return 0.90 // NYC - 10 digits specific
        case 3: return 0.80 // Denver - 5-9 digits
        case 4: return 0.70 // LA - broad pattern
        default: return 0.5
        }
    }
    
    private func calculateCompleteness(_ text: String, matchedPattern: OCRParsingEngine.CityPattern?) -> Double {
        guard let pattern = matchedPattern else { return 0.5 }
        
        // Check if extracted text matches pattern length expectations
        let targetLength: ClosedRange<Int>
        switch pattern.cityId {
        case "us-ca-san_francisco":
            targetLength = 10...11 // SFMTA + 8 digits
        case "us-ny-new_york":
            targetLength = 10...10 // Exactly 10
        case "us-co-denver":
            targetLength = 5...9
        case "us-ca-los_angeles":
            targetLength = 6...11
        default:
            targetLength = 6...12
        }
        
        let textLength = text.count
        if targetLength.contains(textLength) {
            return 1.0
        } else if abs(textLength - targetLength.lowerBound) <= 2 {
            return 0.7
        } else {
            return 0.4
        }
    }
    
    private func calculateConsistency(_ observations: [VNRecognizedTextObservation]) -> Double {
        guard observations.count > 1 else { return 1.0 }
        
        let confidences = observations.map { $0.topCandidates(1).first?.confidence ?? 0 }
        let mean = confidences.reduce(0, +) / Double(confidences.count)
        let variance = confidences.reduce(0) { $0 + pow($1 - mean, 2) } / Double(confidences.count)
        let stdDev = sqrt(variance)
        
        // Low variance = high consistency
        return max(0, 1.0 - stdDev * 2)
    }
    
    // MARK: - Level Determination
    
    private func determineLevel(_ score: Double) -> ConfidenceLevel {
        if score >= 0.85 {
            return .high
        } else if score >= 0.60 {
            return .medium
        } else {
            return .low
        }
    }
    
    private func determineRecommendation(_ level: ConfidenceLevel) -> ScoreResult.Recommendation {
        switch level {
        case .high:
            return .accept
        case .medium:
            return .review
        case .low:
            return .reject
        }
    }
}

// MARK: - Threshold Helpers

extension ConfidenceScorer {
    /// Check if result meets auto-accept threshold
    public static func meetsAutoAcceptThreshold(_ confidence: Double) -> Bool {
        confidence >= ConfidenceLevel.high.threshold
    }
    
    /// Check if result requires review
    public static func requiresReview(_ confidence: Double) -> Bool {
        confidence < ConfidenceLevel.high.threshold
    }
    
    /// Get user-friendly confidence message
    public static func confidenceMessage(for level: ConfidenceLevel) -> String {
        switch level {
        case .high:
            return "High confidence - looks correct"
        case .medium:
            return "Medium confidence - please verify"
        case .low:
            return "Low confidence - please check and edit"
        }
    }
}

// MARK: - Fallback Pipeline

extension ConfidenceScorer {
    /// Determine if fallback processing is needed
    public func shouldUseFallback(_ result: ScoreResult) -> Bool {
        return result.level == .low || result.recommendation == .reject
    }
    
    /// Suggest fallback preprocessing options
    public func suggestFallbackOptions(_ result: ScoreResult) -> OCRPreprocessor.Options {
        var options = OCRPreprocessor.Options()
        
        if result.components.first(where: { $0.name == "vision_confidence" })?.score ?? 0 < 0.5 {
            // Low vision confidence - increase preprocessing
            options.enhanceContrast = true
            options.reduceNoise = true
            options.binarize = true
        }
        
        if result.components.first(where: { $0.name == "text_completeness" })?.score ?? 0 < 0.5 {
            // Incomplete text - try perspective correction
            options.correctPerspective = true
        }
        
        return options
    }
}
