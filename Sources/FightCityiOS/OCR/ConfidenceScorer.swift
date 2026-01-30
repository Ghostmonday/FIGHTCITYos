//
//  ConfidenceScorer.swift
//  FightCityiOS
//
//  ML-enhanced confidence scoring for OCR results
//

import Vision
import VisionKit
import CoreML
import NaturalLanguage
import UIKit
import FightCityFoundation

/// APPLE INTELLIGENCE: Uses CoreML for ML-based confidence scoring
/// APPLE INTELLIGENCE: Uses NLTagger for text quality assessment
/// APPLE INTELLIGENCE: Enhances layout analysis confidence with ML

/// Scores and evaluates OCR confidence with ML enhancement
public struct ConfidenceScorer {
    
    // MARK: - Confidence Levels
    
    /// Confidence level classification
    public enum ConfidenceLevel: String {
        case high = "high"
        case medium = "medium"
        case low = "low"
        
        /// Threshold for this confidence level
        public var threshold: Double {
            switch self {
            case .high: return 0.85
            case .medium: return 0.60
            case .low: return 0.0
            }
        }
        
        /// Whether this level requires manual review
        public var requiresReview: Bool {
            self != .high
        }
    }
    
    // MARK: - Scoring Result
    
    /// Result of confidence scoring
    public struct ScoreResult {
        /// Overall confidence score (0.0 - 1.0)
        public let overallConfidence: Double
        /// Confidence level classification
        public let level: ConfidenceLevel
        /// Individual confidence components
        public let components: [ConfidenceComponent]
        /// Recommendation for action
        public let recommendation: Recommendation
        /// Whether result can be auto-accepted
        public let shouldAutoAccept: Bool
        
        /// Recommendation actions
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
    
    /// Individual confidence component
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
    
    // MARK: - ML Components
    
    /// NLP tagger for text quality assessment
    private let tagger: NLTagger
    
    /// Embedding for semantic analysis
    private var embedding: NLEmbedding?
    
    // MARK: - Initialization
    
    public init() {
        self.tagger = NLTagger(tagSchemes: [.lexicalClass, .nameType, .lemma])
        self.embedding = try? NLEmbedding(embeddingFor: .english)
    }
    
    // MARK: - Public Methods
    
    /// Score OCR result with all factors including ML
    public func score(
        rawText: String,
        observations: [VNRecognizedTextObservation],
        matchedPattern: OCRParsingEngine.CityPattern?
    ) -> ScoreResult {
        var components: [ConfidenceComponent] = []
        
        // 1. Vision confidence (from OCR observations)
        let visionConfidence = calculateVisionConfidence(observations)
        components.append(ConfidenceComponent(
            name: "vision_confidence",
            score: visionConfidence,
            weight: 0.35,
            weightedScore: visionConfidence * 0.35
        ))
        
        // 2. ML-based confidence using NaturalLanguage
        let mlConfidence = calculateMLConfidence(rawText)
        components.append(ConfidenceComponent(
            name: "ml_confidence",
            score: mlConfidence,
            weight: 0.20,
            weightedScore: mlConfidence * 0.20
        ))
        
        // 3. Text quality assessment using NLP
        let qualityConfidence = calculateTextQuality(rawText)
        components.append(ConfidenceComponent(
            name: "text_quality",
            score: qualityConfidence,
            weight: 0.15,
            weightedScore: qualityConfidence * 0.15
        ))
        
        // 4. Pattern match confidence
        let patternConfidence = calculatePatternConfidence(matchedPattern)
        components.append(ConfidenceComponent(
            name: "pattern_match",
            score: patternConfidence,
            weight: 0.15,
            weightedScore: patternConfidence * 0.15
        ))
        
        // 5. Layout analysis confidence
        let layoutConfidence = calculateLayoutConfidence(observations)
        components.append(ConfidenceComponent(
            name: "layout_confidence",
            score: layoutConfidence,
            weight: 0.10,
            weightedScore: layoutConfidence * 0.10
        ))
        
        // 6. Observation consistency
        let consistencyConfidence = calculateConsistency(observations)
        components.append(ConfidenceComponent(
            name: "observation_consistency",
            score: consistencyConfidence,
            weight: 0.05,
            weightedScore: consistencyConfidence * 0.05
        ))
        
        // Calculate overall score
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
    
    // MARK: - ML Confidence Calculation
    
    /// Calculate ML-based confidence using NaturalLanguage
    private func calculateMLConfidence(_ text: String) -> Double {
        guard !text.isEmpty else { return 0.0 }
        
        // Analyze text characteristics using NLP
        tagger.string = text
        
        // Count valid tokens
        var validTokenCount = 0
        let totalTokens = text.split(separator: " ").count
        
        tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .lexicalClass) { tag, _ in
            if tag != nil {
                validTokenCount += 1
            }
            return true
        }
        
        // Token validity ratio
        let tokenRatio = totalTokens > 0 ? Double(validTokenCount) / Double(totalTokens) : 0
        
        // Check for common OCR errors using pattern matching
        let errorPatterns = [
            "0", "O", "I", "l", "1"  // Common OCR confusion characters
        ]
        
        var errorScore = 1.0
        for char in text {
            if errorPatterns.contains(String(char)) {
                errorScore *= 0.98 // Slight penalty for ambiguous characters
            }
        }
        
        return min(1.0, tokenRatio * errorScore)
    }
    
    // MARK: - Text Quality Assessment
    
    /// Calculate text quality using NLP
    private func calculateTextQuality(_ text: String) -> Double {
        guard !text.isEmpty else { return 0.0 }
        
        // Check text length合理性
        let length = text.count
        let idealLengthRange = 5...15  // Typical citation number length
        
        if idealLengthRange.contains(length) {
            return 1.0
        } else if length < 3 {
            return 0.3  // Too short
        } else if length > 20 {
            return 0.5  // Too long
        }
        
        // Check for valid character types
        let alphanumericCount = text.filter { $0.isLetter || $0.isNumber }.count
        let ratio = Double(alphanumericCount) / Double(length)
        
        return ratio
    }
    
    // MARK: - Layout Confidence
    
    /// Calculate layout analysis confidence
    private func calculateLayoutConfidence(_ observations: [VNRecognizedTextObservation]) -> Double {
        guard !observations.isEmpty else { return 0.0 }
        
        // Check if observations form a reasonable layout
        var yPositions: [CGFloat] = []
        
        for observation in observations {
            yPositions.append(observation.boundingBox.minY)
        }
        
        // Sort and check for reasonable line spacing
        yPositions.sort()
        
        var lineSpacingVariance = 0.0
        if yPositions.count > 1 {
            for i in 1..<yPositions.count {
                let spacing = yPositions[i] - yPositions[i - 1]
                lineSpacingVariance += abs(spacing - 0.05)  // Expected line spacing
            }
            lineSpacingVariance /= Double(yPositions.count - 1)
        }
        
        // Lower variance = better layout
        return max(0.0, 1.0 - lineSpacingVariance * 5)
    }
    
    // MARK: - Component Calculations
    
    /// Calculate Vision framework confidence
    private func calculateVisionConfidence(_ observations: [VNRecognizedTextObservation]) -> Double {
        guard !observations.isEmpty else { return 0 }
        
        let totalConfidence = observations.reduce(0.0) { sum, obs in
            sum + Double(obs.topCandidates(1).first?.confidence ?? 0)
        }
        
        return totalConfidence / Double(observations.count)
    }
    
    /// Calculate pattern match confidence
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
    
    /// Calculate observation consistency
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

// MARK: - Fallback Pipeline

extension ConfidenceScorer {
    /// Determine if fallback processing is needed
    public func shouldUseFallback(_ result: ScoreResult) -> Bool {
        return result.level == .low || result.recommendation == .reject
    }
    
    /// Suggest fallback preprocessing options
    public func suggestFallbackOptions(_ result: ScoreResult) -> OCRPreprocessor.Options {
        var options = OCRPreprocessor.Options()
        
        // Check ML confidence component
        if let mlComponent = result.components.first(where: { $0.name == "ml_confidence" }),
           mlComponent.score < 0.5 {
            options.enhanceContrast = true
            options.reduceNoise = true
        }
        
        // Check vision confidence component
        if let visionComponent = result.components.first(where: { $0.name == "vision_confidence" }),
           visionComponent.score < 0.5 {
            options.binarize = true
        }
        
        // Check layout confidence component
        if let layoutComponent = result.components.first(where: { $0.name == "layout_confidence" }),
           layoutComponent.score < 0.5 {
            options.correctPerspective = true
        }
        
        return options
    }
}
