//
//  ConfidenceScorer.swift
//  FightCityTicketsCore
//
//  Calculates confidence scores for OCR results
//

import Foundation

/// Scores and evaluates OCR confidence
public struct ConfidenceScorer {
    
    /// Confidence levels
    public enum ConfidenceLevel: String, Sendable {
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
    
    /// Scoring result
    public struct ScoreResult: Sendable {
        public let overallConfidence: Double
        public let level: ConfidenceLevel
        public let components: [ConfidenceComponent]
        public let recommendation: Recommendation
        public let shouldAutoAccept: Bool
        
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
    
    /// Individual confidence component
    public struct ConfidenceComponent: Sendable {
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
    
    /// Component weights
    private let weights: (vision: Double, pattern: Double, completeness: Double, consistency: Double)
    
    public init(
        visionWeight: Double = 0.40,
        patternWeight: Double = 0.30,
        completenessWeight: Double = 0.20,
        consistencyWeight: Double = 0.10
    ) {
        self.weights = (visionWeight, patternWeight, completenessWeight, consistencyWeight)
    }
    
    // MARK: - Scoring
    
    /// Score OCR result with all factors
    public func score(
        rawText: String,
        observations: [OCObservation],
        matchedCityId: String?
    ) -> ScoreResult {
        var components: [ConfidenceComponent] = []
        
        // 1. Vision confidence
        let visionConfidence = calculateVisionConfidence(observations)
        components.append(ConfidenceComponent(
            name: "vision_confidence",
            score: visionConfidence,
            weight: weights.vision,
            weightedScore: visionConfidence * weights.vision
        ))
        
        // 2. Pattern match confidence
        let patternConfidence = calculatePatternConfidence(matchedCityId: matchedCityId)
        components.append(ConfidenceComponent(
            name: "pattern_match",
            score: patternConfidence,
            weight: weights.pattern,
            weightedScore: patternConfidence * weights.pattern
        ))
        
        // 3. Text completeness
        let completenessConfidence = calculateCompleteness(rawText, matchedCityId: matchedCityId)
        components.append(ConfidenceComponent(
            name: "text_completeness",
            score: completenessConfidence,
            weight: weights.completeness,
            weightedScore: completenessConfidence * weights.completeness
        ))
        
        // 4. Observation consistency
        let consistencyConfidence = calculateConsistency(observations)
        components.append(ConfidenceComponent(
            name: "observation_consistency",
            score: consistencyConfidence,
            weight: weights.consistency,
            weightedScore: consistencyConfidence * weights.consistency
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
    
    /// Simplified scoring using average confidence
    public func scoreSimple(
        rawText: String,
        averageConfidence: Double,
        matchedCityId: String?
    ) -> ScoreResult {
        var components: [ConfidenceComponent] = []
        
        // Use average confidence as vision confidence
        components.append(ConfidenceComponent(
            name: "vision_confidence",
            score: averageConfidence,
            weight: weights.vision,
            weightedScore: averageConfidence * weights.vision
        ))
        
        // Pattern match
        let patternConfidence = calculatePatternConfidence(matchedCityId: matchedCityId)
        components.append(ConfidenceComponent(
            name: "pattern_match",
            score: patternConfidence,
            weight: weights.pattern,
            weightedScore: patternConfidence * weights.pattern
        ))
        
        // Completeness
        let completenessConfidence = calculateCompleteness(rawText, matchedCityId: matchedCityId)
        components.append(ConfidenceComponent(
            name: "text_completeness",
            score: completenessConfidence,
            weight: weights.completeness,
            weightedScore: completenessConfidence * weights.completeness
        ))
        
        // Consistency (single observation = perfect consistency)
        let consistencyConfidence = observations.count == 1 ? 1.0 : 0.8
        components.append(ConfidenceComponent(
            name: "observation_consistency",
            score: consistencyConfidence,
            weight: weights.consistency,
            weightedScore: consistencyConfidence * weights.consistency
        ))
        
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
    
    private func calculateVisionConfidence(_ observations: [OCObservation]) -> Double {
        guard !observations.isEmpty else { return 0 }
        
        let totalConfidence = observations.reduce(0.0) { sum, obs in
            sum + obs.confidence
        }
        
        return totalConfidence / Double(observations.count)
    }
    
    private func calculatePatternConfidence(matchedCityId: String?) -> Double {
        guard let cityId = matchedCityId else { return 0.5 }
        
        // Higher confidence for more specific patterns
        switch cityId {
        case "us-ca-san_francisco": return 0.95  // Very specific SFMTA pattern
        case "us-ny-new_york": return 0.90       // 10 digits specific
        case "us-co-denver": return 0.80         // 5-9 digits
        case "us-ca-los_angeles": return 0.70    // Broad pattern
        default: return 0.5
        }
    }
    
    private func calculateCompleteness(_ text: String, matchedCityId: String?) -> Double {
        guard let cityId = matchedCityId else { return 0.5 }
        
        let targetLength: ClosedRange<Int>
        switch cityId {
        case "us-ca-san_francisco":
            targetLength = 10...11  // SFMTA + 8 digits
        case "us-ny-new_york":
            targetLength = 10...10  // Exactly 10
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
    
    private func calculateConsistency(_ observations: [OCObservation]) -> Double {
        guard observations.count > 1 else { return 1.0 }
        
        let confidences = observations.map { $0.confidence }
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
    
    private func determineRecommendation(_ level: ConfidenceLevel) -> Recommendation {
        switch level {
        case .high:
            return .accept
        case .medium:
            return .review
        case .low:
            return .reject
        }
    }
    
    // MARK: - Static Helpers
    
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

// MARK: - Fallback Suggestions

extension ConfidenceScorer {
    /// Determine if fallback processing is needed
    public func shouldUseFallback(_ result: ScoreResult) -> Bool {
        return result.level == .low || result.recommendation == .reject
    }
    
    /// Suggest preprocessing options based on score
    public struct PreprocessingOptions: OptionSet, Sendable {
        public let rawValue: Int
        
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
        
        public static let enhanceContrast = PreprocessingOptions(rawValue: 1 << 0)
        public static let reduceNoise = PreprocessingOptions(rawValue: 1 << 1)
        public static let binarize = PreprocessingOptions(rawValue: 1 << 2)
        public static let correctPerspective = PreprocessingOptions(rawValue: 1 << 3)
    }
    
    /// Suggest fallback preprocessing options
    public func suggestFallbackOptions(_ result: ScoreResult) -> PreprocessingOptions {
        var options = PreprocessingOptions([])
        
        if result.components.first(where: { $0.name == "vision_confidence" })?.score ?? 0 < 0.5 {
            options.insert(.enhanceContrast)
            options.insert(.reduceNoise)
            options.insert(.binarize)
        }
        
        if result.components.first(where: { $0.name == "text_completeness" })?.score ?? 0 < 0.5 {
            options.insert(.correctPerspective)
        }
        
        return options
    }
}
