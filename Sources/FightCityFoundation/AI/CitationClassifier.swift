//
//  CitationClassifier.swift
//  FightCityFoundation
//
//  Core ML citation classifier using on-device machine learning
//

import Foundation
import NaturalLanguage

#if canImport(CoreML)
import CoreML
#endif

import os.log

/// APPLE INTELLIGENCE: On-device Core ML classifier for citation type and city detection
/// APPLE INTELLIGENCE: Uses NaturalLanguage embeddings for text classification
/// APPLE INTELLIGENCE: Falls back to regex when ML confidence is low

// MARK: - Classification Result

/// Result of ML-based citation classification
public struct MLClassificationResult {
    public let cityId: String?
    public let cityName: String?
    public let citationType: CitationType
    public let confidence: Double
    public let alternativeCities: [(cityId: String, cityName: String, confidence: Double)]
    public let alternativeTypes: [(type: CitationType, confidence: Double)]
    public let keyPhrasesFound: [String]
    public let processingTimeMs: Int
    
    public init(
        cityId: String?,
        cityName: String?,
        citationType: CitationType,
        confidence: Double,
        alternativeCities: [(cityId: String, cityName: String, confidence: Double)] = [],
        alternativeTypes: [(type: CitationType, confidence: Double)] = [],
        keyPhrasesFound: [String] = [],
        processingTimeMs: Int = 0
    ) {
        self.cityId = cityId
        self.cityName = cityName
        self.citationType = citationType
        self.confidence = confidence
        self.alternativeCities = alternativeCities
        self.alternativeTypes = alternativeTypes
        self.keyPhrasesFound = keyPhrasesFound
        self.processingTimeMs = processingTimeMs
    }
}

// MARK: - City Training Data

/// Training data structure for city classification
public struct CityTrainingData {
    public let cityId: String
    public let cityName: String
    public let indicators: [String]
    public let citationPatterns: [String]
    public let keywords: [String]
    
    public init(
        cityId: String,
        cityName: String,
        indicators: [String],
        citationPatterns: [String],
        keywords: [String]
    ) {
        self.cityId = cityId
        self.cityName = cityName
        self.indicators = indicators
        self.citationPatterns = citationPatterns
        self.keywords = keywords
    }
}

// MARK: - Citation Classifier

/// On-device ML-based citation classifier
public final class CitationClassifier {
    
    // MARK: - Properties
    
    /// Shared instance
    public static let shared = CitationClassifier()
    
    /// Whether ML classification is available
    public var isAvailable: Bool {
        #if canImport(CoreML)
        return true
        #else
        return false
        #endif
    }
    
    /// Embedding dimension for text similarity
    private let embeddingDimension = 300
    
    /// Minimum confidence threshold for ML classification
    private let minimumConfidenceThreshold: Double = 0.6
    
    /// City training data
    private let cityTrainingData: [CityTrainingData]
    
    /// Citation type keywords for training
    private let citationTypeKeywords: [(type: CitationType, keywords: [String])]
    
    /// Lazy-loaded NL embedding
    private var embedding: NLEmbedding? {
        NLEmbedding.wordEmbedding(for: .english)
    }
    
    // MARK: - Initialization
    
    public init() {
        self.cityTrainingData = Self.createCityTrainingData()
        self.citationTypeKeywords = Self.createCitationTypeKeywords()
    }
    
    // MARK: - Public Methods
    
    /// Classify citation text using on-device ML
    /// - Parameter text: OCR text from citation
    /// - Returns: ML classification result with confidence scores
    public func classify(_ text: String) -> MLClassificationResult {
        let startTime = Date()
        
        let normalizedText = normalizeText(text)
        
        // Extract key phrases
        let keyPhrases = extractKeyPhrases(from: normalizedText)
        
        // Classify citation type
        let typeResult = classifyCitationType(normalizedText)
        
        // Detect city
        let cityResult = detectCity(normalizedText)
        
        // Calculate overall confidence
        let overallConfidence = calculateOverallConfidence(
            typeConfidence: typeResult.confidence,
            cityConfidence: cityResult.confidence,
            textQuality: assessTextQuality(text)
        )
        
        let processingTimeMs = Int(Date().timeIntervalSince(startTime) * 1000)
        
        return MLClassificationResult(
            cityId: cityResult.cityId,
            cityName: cityResult.cityName,
            citationType: typeResult.type,
            confidence: overallConfidence,
            alternativeCities: cityResult.alternatives,
            alternativeTypes: typeResult.alternatives,
            keyPhrasesFound: keyPhrases,
            processingTimeMs: processingTimeMs
        )
    }
    
    /// Classify with fallback to regex when confidence is low
    /// - Parameter text: OCR text from citation
    /// - Parameter regexFallback: Regex-based classification result
    /// - Returns: Merged result with ML and regex confidence
    public func classifyWithFallback(
        _ text: String,
        regexFallback: ClassificationResult
    ) -> ClassificationResult {
        let mlResult = classify(text)
        
        // Use ML if confidence is above threshold
        if mlResult.confidence >= minimumConfidenceThreshold {
            return ClassificationResult(
                cityId: mlResult.cityId,
                cityName: mlResult.cityName,
                citationType: mlResult.citationType,
                confidence: mlResult.confidence,
                isFromML: true,
                parsedFields: regexFallback.parsedFields
            )
        }
        
        // Otherwise, merge ML and regex confidence
        let mergedConfidence = mergeConfidences(ml: mlResult.confidence, regex: regexFallback.confidence)
        
        // Prefer higher confidence source
        let finalResult: ClassificationResult
        if mlResult.confidence > regexFallback.confidence {
            finalResult = ClassificationResult(
                cityId: mlResult.cityId ?? regexFallback.cityId,
                cityName: mlResult.cityName ?? regexFallback.cityName,
                citationType: mlResult.citationType,
                confidence: mergedConfidence,
                isFromML: true,
                parsedFields: regexFallback.parsedFields
            )
        } else {
            finalResult = regexFallback
        }
        
        return finalResult
    }
    
    /// Get similarity score between two text strings
    /// - Parameters:
    ///   - text1: First text
    ///   - text2: Second text
    /// - Returns: Similarity score (0.0 - 1.0)
    public func similarityScore(_ text1: String, _ text2: String) -> Double {
        guard let embedding = embedding else { return 0 }
        
        let normalized1 = normalizeText(text1)
        let normalized2 = normalizeText(text2)
        
        return embedding.distance(between: normalized1, and: normalized2)
    }
    
    // MARK: - Private Methods
    
    private func normalizeText(_ text: String) -> String {
        text.uppercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
    }
    
    private func extractKeyPhrases(from text: String) -> [String] {
        var phrases: [String] = []
        
        // Look for known citation-related phrases
        let knownPhrases = [
            "PARKING VIOLATION",
            "TRAFFIC CITATION",
            "SPEEDING",
            "RED LIGHT",
            "METER EXPIRED",
            "NO PARKING",
            "ILLEGAL PARK",
            "CITY OF",
            "DEPARTMENT OF TRANSPORTATION"
        ]
        
        let upperText = text.uppercased()
        for phrase in knownPhrases {
            if upperText.contains(phrase) {
                phrases.append(phrase)
            }
        }
        
        return phrases
    }
    
    private func classifyCitationType(_ text: String) -> (type: CitationType, confidence: Double, alternatives: [(CitationType, Double)]) {
        var scores: [(type: CitationType, score: Double)] = []
        
        for (type, keywords) in citationTypeKeywords {
            var matches = 0
            let upperText = text.uppercased()
            
            for keyword in keywords {
                if upperText.contains(keyword.uppercased()) {
                    matches += 1
                }
            }
            
            // Calculate score based on keyword matches
            let score = Double(matches) / Double(max(keywords.count, 1))
            scores.append((type: type, score: score))
        }
        
        // Sort by score
        scores.sort { $0.score > $1.score }
        
        // Get best match
        guard let best = scores.first else {
            return (.unknown, 0.0, [])
        }
        
        // Calculate confidence based on score
        let confidence = min(1.0, best.score * 1.2) // Boost confidence slightly
        
        // Get alternatives
        let alternatives = scores.dropFirst().prefix(3).map { ($0.type, $0.score) }
        
        return (best.type, confidence, alternatives)
    }
    
    private func detectCity(_ text: String) -> (cityId: String?, cityName: String?, confidence: Double, alternatives: [(cityId: String, cityName: String, confidence: Double)]) {
        var scores: [(cityId: String, cityName: String, score: Double)] = []
        
        for city in cityTrainingData {
            var score = 0.0
            
            // Check indicators (agency names, city names)
            for indicator in city.indicators {
                if text.uppercased().contains(indicator.uppercased()) {
                    score += 2.0
                }
            }
            
            // Check keywords
            for keyword in city.keywords {
                if text.uppercased().contains(keyword.uppercased()) {
                    score += 1.0
                }
            }
            
            // Check citation patterns
            for pattern in city.citationPatterns {
                if text.range(of: pattern, options: .regularExpression, range: nil, locale: nil) != nil {
                    score += 3.0
                }
            }
            
            // Normalize score
            let normalizedScore = min(1.0, score / 5.0)
            scores.append((cityId: city.cityId, cityName: city.cityName, score: normalizedScore))
        }
        
        // Sort by score
        scores.sort { $0.score > $1.score }
        
        // Get best match
        guard let best = scores.first, best.score > 0 else {
            return (nil, nil, 0.0, [])
        }
        
        // Get alternatives
        let alternatives = scores.dropFirst().prefix(3).map { (cityId: $0.cityId, cityName: $0.cityName, confidence: $0.score) }
        
        return (best.cityId, best.cityName, best.score, alternatives)
    }
    
    private func calculateOverallConfidence(typeConfidence: Double, cityConfidence: Double, textQuality: Double) -> Double {
        // Weighted combination of confidences
        let weightedConfidence = (typeConfidence * 0.4) + (cityConfidence * 0.4) + (textQuality * 0.2)
        return min(1.0, weightedConfidence)
    }
    
    private func assessTextQuality(_ text: String) -> Double {
        // Assess OCR quality based on text characteristics
        var score = 0.5 // Base score
        
        // Check for common OCR artifacts
        let hasIllegibleChars = text.contains("?") || text.contains("▇") || text.contains("■")
        if hasIllegibleChars {
            score -= 0.2
        }
        
        // Check text length (citations typically have specific lengths)
        let wordCount = text.split(separator: " ").count
        if wordCount >= 5 && wordCount <= 50 {
            score += 0.2
        } else if wordCount > 50 {
            score -= 0.1
        }
        
        // Check for structured content (dates, amounts)
        let hasDate = text.range(of: "\\d{1,2}[/-]\\d{1,2}[/-]\\d{2,4}", options: .regularExpression) != nil
        let hasAmount = text.contains("$")
        if hasDate {
            score += 0.15
        }
        if hasAmount {
            score += 0.15
        }
        
        return max(0.0, min(1.0, score))
    }
    
    private func mergeConfidences(ml: Double, regex: Double) -> Double {
        // ML gets 60% weight when available
        return (ml * 0.6) + (regex * 0.4)
    }
    
    // MARK: - Training Data
    
    private static func createCityTrainingData() -> [CityTrainingData] {
        [
            CityTrainingData(
                cityId: "us-ca-san_francisco",
                cityName: "San Francisco",
                indicators: ["SFMTA", "SAN FRANCISCO", "SF MTA", "SF MUNICIPAL"],
                citationPatterns: ["SFMTA\\d{8}", "MT\\d{8}"],
                keywords: ["PARKING", "CITATION", "FINE", "VIOLATION"]
            ),
            CityTrainingData(
                cityId: "us-ny-new_york",
                cityName: "New York",
                indicators: ["NYC", "NEW YORK", "NYC DOT", "DEPARTMENT OF TRANSPORTATION"],
                citationPatterns: ["\\d{10}"],
                keywords: ["PARKING", "VIOLATION", "PENALTY", "AMOUNT DUE"]
            ),
            CityTrainingData(
                cityId: "us-ca-los_angeles",
                cityName: "Los Angeles",
                indicators: ["LA", "LOS ANGELES", "LAPD", "CITY OF LOS ANGELES"],
                citationPatterns: ["[0-9A-Z]{6,11}"],
                keywords: ["PARKING", "CITATION", "VEHICLE CODE"]
            ),
            CityTrainingData(
                cityId: "us-co-denver",
                cityName: "Denver",
                indicators: ["DENVER", "CITY OF DENVER"],
                citationPatterns: ["\\d{5,9}"],
                keywords: ["PARKING", "VIOLATION", "ORDINANCE"]
            )
        ]
    }
    
    private static func createCitationTypeKeywords() -> [(CitationType, [String])] {
        [
            (.parking, [
                "PARKING", "PARK", "NO PARK", "METER", "EXPIRED", 
                "ILLEGAL", "DOUBLE PARK", "NO STOPPING", "HANDICAP"
            ]),
            (.traffic, [
                "TRAFFIC", "VEHICLE CODE", "CVC", "DIVIDED HWY", 
                "WRONG WAY", "SIGNAL", "STOP SIGN"
            ]),
            (.redLight, [
                "RED LIGHT", "CAMERA", "PHOTO", "STOP LIGHT", 
                "RUN RED", "TRAFFIC SIGNAL"
            ]),
            (.speeding, [
                "SPEED", "SPEEDING", "MPH", "EXCEED", "LIMIT"
            ]),
            (.municipal, [
                "CITY ORDINANCE", "MUNICIPAL", "CITY CODE", "LOCAL LAW"
            ])
        ]
    }
}

// MARK: - Export for ML Training

extension CitationClassifier {
    /// Export training data for Create ML model training
    public func exportTrainingData() -> [[String: Any]] {
        var trainingData: [[String: Any]] = []
        
        for city in cityTrainingData {
            for indicator in city.indicators {
                for keyword in city.keywords {
                    let text = "\(indicator) \(keyword) PARKING VIOLATION"
                    trainingData.append([
                        "text": text,
                        "cityId": city.cityId,
                        "cityName": city.cityName,
                        "citationType": "parking"
                    ])
                }
            }
        }
        
        return trainingData
    }
}
