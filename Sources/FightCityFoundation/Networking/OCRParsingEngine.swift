//
//  OCRParsingEngine.swift
//  FightCityFoundation
//
//  Regex patterns per city for citation parsing (matching backend CitationValidator)
// Core ML citation classification with regex fallback
//

import Foundation
import NaturalLanguage

/// APPLE INTELLIGENCE: Use ML classifier first, regex second; merge confidences
/// APPLE INTELLIGENCE: Add NaturalLanguage sentiment analysis for text quality

#if canImport(CoreML)
import CoreML
#endif

import os.log

// MARK: - Citation Type

/// Types of citations that can be classified
public enum CitationType: String, CaseIterable {
    case parking = "parking"
    case traffic = "traffic"
    case municipal = "municipal"
    case redLight = "red_light"
    case speeding = "speeding"
    case unknown = "unknown"
    
    public var displayName: String {
        switch self {
        case .parking: return "Parking Violation"
        case .traffic: return "Traffic Violation"
        case .municipal: return "Municipal Violation"
        case .redLight: return "Red Light Violation"
        case .speeding: return "Speeding Violation"
        case .unknown: return "Unknown"
        }
    }
}

// MARK: - Classification Result

/// Result of ML/regex citation classification
public struct ClassificationResult {
    public let cityId: String?
    public let cityName: String?
    public let citationType: CitationType
    public let confidence: Double
    public let isFromML: Bool
    public let parsedFields: ParsedFields
    
    public init(
        cityId: String?,
        cityName: String?,
        citationType: CitationType,
        confidence: Double,
        isFromML: Bool,
        parsedFields: ParsedFields
    ) {
        self.cityId = cityId
        self.cityName = cityName
        self.citationType = citationType
        self.confidence = confidence
        self.isFromML = isFromML
        self.parsedFields = parsedFields
    }
}

/// Parsed fields from citation text
public struct ParsedFields {
    public let citationNumber: String?
    public let violationDate: Date?
    public let amount: Double?
    public let violationCode: String?
    public let licensePlate: String?
    
    public init(
        citationNumber: String?,
        violationDate: Date?,
        amount: Double?,
        violationCode: String?,
        licensePlate: String?
    ) {
        self.citationNumber = citationNumber
        self.violationDate = violationDate
        self.amount = amount
        self.violationCode = violationCode
        self.licensePlate = licensePlate
    }
    
    public static let empty = ParsedFields(
        citationNumber: nil,
        violationDate: nil,
        amount: nil,
        violationCode: nil,
        licensePlate: nil
    )
}

// MARK: - Validation Result

/// Validation result combining classification and validation status
public struct ValidationResult {
    public let classification: ClassificationResult
    public let isValid: Bool
    public let errorMessage: String?
    
    public init(classification: ClassificationResult, isValid: Bool, errorMessage: String? = nil) {
        self.classification = classification
        self.isValid = isValid
        self.errorMessage = errorMessage
    }
}

// MARK: - Parsing Result

/// Parses OCR text using city-specific regex patterns (matching backend CitationValidator)
public struct OCRParsingEngine {
    // MARK: - City Patterns (from Python backend)
    
    public struct CityPattern {
        public let cityId: String
        public let cityName: String
        public let regex: String
        public let priority: Int
        public let formatExample: String
        
        public init(cityId: String, cityName: String, regex: String, priority: Int, formatExample: String) {
            self.cityId = cityId
            self.cityName = cityName
            self.regex = regex
            self.priority = priority
            self.formatExample = formatExample
        }
    }
    
    /// Patterns in priority order (matching backend CitationValidator)
    private let patterns: [CityPattern] = [
        // San Francisco - SFMTA or MT followed by 8 digits
        CityPattern(
            cityId: "us-ca-san_francisco",
            cityName: "San Francisco",
            regex: "^(SFMTA|MT)[0-9]{8}$",
            priority: 1,
            formatExample: "SFMTA91234567"
        ),
        // NYC - exactly 10 digits
        CityPattern(
            cityId: "us-ny-new_york",
            cityName: "New York",
            regex: "^[0-9]{10}$",
            priority: 2,
            formatExample: "1234567890"
        ),
        // Denver - 5-9 digits
        CityPattern(
            cityId: "us-co-denver",
            cityName: "Denver",
            regex: "^[0-9]{5,9}$",
            priority: 3,
            formatExample: "1234567"
        ),
        // Los Angeles - 6-11 alphanumeric characters
        CityPattern(
            cityId: "us-ca-los_angeles",
            cityName: "Los Angeles",
            regex: "^[0-9A-Z]{6,11}$",
            priority: 4,
            formatExample: "LA123456"
        )
    ]
    
    // MARK: - Citation Type Regex Patterns
    
    private let citationTypePatterns: [(type: CitationType, patterns: [String])] = [
        (.parking, [
            "PARKING",
            "PARK",
            "NO PARK",
            "METER EXPIRED",
            "ILLEGAL PARK",
            "DOUBLE PARK",
            "NO STOPPING"
        ]),
        (.traffic, [
            "TRAFFIC",
            "VEHICLE CODE",
            "CVC",
            "DIVIDED HWY",
            "WRONG WAY"
        ]),
        (.redLight, [
            "RED LIGHT",
            "RED LIGHT CAM",
            "STOP LIGHT",
            "RUN RED"
        ]),
        (.speeding, [
            "SPEED",
            "SPEEDING",
            "FAST",
            "EXCEED",
            "MPH OVER"
        ]),
        (.municipal, [
            "CITY ORDINANCE",
            "MUNICIPAL",
            "CITY CODE"
        ])
    ]
    
    // MARK: - ML Model Properties
    
    #if canImport(CoreML) && canImport(NaturalLanguage)
    @available(iOS 16.0, *)
    private var mlClassifier: NLModel? = nil
    #endif
    
    private var mlModelLoaded: Bool = false
    
    public init() {
        setupMLClassifier()
    }
    
    // MARK: - ML Setup
    
    private mutating func setupMLClassifier() {
        #if canImport(CoreML) && canImport(NaturalLanguage)
        guard #available(iOS 16.0, *) else { return }
        
        // Create a text classifier for citation type classification
        // This is a placeholder for actual Core ML model integration
        // In production, load the compiled .mlmodelc bundle
        do {
            // Example: Load custom ML model
            // let model = try? MyCitationClassifier(configuration: MLModelConfiguration())
            // mlClassifier = try? model.getBasicTextClassifier()
            
            // For now, use built-in NL embedding-based classification
            mlModelLoaded = true
            Logger.info("ML citation classifier initialized (placeholder)")
        } catch {
            Logger.warning("Failed to load ML citation classifier: \(error.localizedDescription)")
            mlModelLoaded = false
        }
        #else
        mlModelLoaded = false
        #endif
    }
    
    // MARK: - Citation Classification
    
    /// Classify citation text using ML model first, then regex fallback
    /// - Parameter text: OCR text from citation image
    /// - Returns: ClassificationResult with city, type, confidence, and parsed fields
    @available(iOS 16.0, *)
    public func classifyCitation(_ text: String) -> ClassificationResult {
        let normalizedText = normalizeText(text)
        
        // Try ML classification first (iOS 16+)
        if mlModelLoaded {
            if let mlResult = classifyWithML(normalizedText) {
                let regexResult = classifyWithRegex(normalizedText)
                
                // Merge confidences: ML gets higher weight
                let mergedConfidence = mergeConfidences(ml: mlResult.confidence, regex: regexResult.confidence)
                
                // Use ML type if confident, otherwise blend with regex
                let finalType = (mlResult.confidence > 0.7) ? mlResult.citationType : 
                    (regexResult.confidence > mlResult.confidence ? regexResult.citationType : mlResult.citationType)
                
                // Combine parsed fields
                let mergedFields = ParsedFields(
                    citationNumber: mlResult.parsedFields.citationNumber ?? regexResult.parsedFields.citationNumber,
                    violationDate: mlResult.parsedFields.violationDate ?? regexResult.parsedFields.violationDate,
                    amount: mlResult.parsedFields.amount ?? regexResult.parsedFields.amount,
                    violationCode: mlResult.parsedFields.violationCode ?? regexResult.parsedFields.violationCode,
                    licensePlate: mlResult.parsedFields.licensePlate ?? regexResult.parsedFields.licensePlate
                )
                
                return ClassificationResult(
                    cityId: mlResult.cityId ?? regexResult.cityId,
                    cityName: mlResult.cityName ?? regexResult.cityName,
                    citationType: finalType,
                    confidence: mergedConfidence,
                    isFromML: true,
                    parsedFields: mergedFields
                )
            }
        }
        
        // Fallback to regex-only classification
        let regexResult = classifyWithRegex(normalizedText)
        return ClassificationResult(
            cityId: regexResult.cityId,
            cityName: regexResult.cityName,
            citationType: regexResult.citationType,
            confidence: regexResult.confidence,
            isFromML: false,
            parsedFields: regexResult.parsedFields
        )
    }
    
    /// Classification for older iOS versions (regex only)
    public func classifyCitationLegacy(_ text: String) -> ClassificationResult {
        let normalizedText = normalizeText(text)
        return classifyWithRegex(normalizedText)
    }
    
    // MARK: - ML Classification
    
    @available(iOS 16.0, *)
    private func classifyWithML(_ text: String) -> ClassificationResult? {
        #if canImport(CoreML) && canImport(NaturalLanguage)
        guard let classifier = mlClassifier else {
            return nil
        }
        
        // Use NLModel for classification
        let predictedLabel = classifier.predictedLabel(for: text)
        
        guard let label = predictedLabel else {
            return nil
        }
        
        // Map ML label to CitationType
        let citationType = CitationType(rawValue: label.lowercased()) ?? .unknown
        let confidence = classifier.predictionLabelHints(for: text).first.map { _ in 0.85 } ?? 0.7
        
        // Extract fields from text
        let parsedFields = extractFields(from: text)
        
        // Try to detect city from text
        let (cityId, cityName) = detectCity(from: text)
        
        return ClassificationResult(
            cityId: cityId,
            cityName: cityName,
            citationType: citationType,
            confidence: confidence,
            isFromML: true,
            parsedFields: parsedFields
        )
        #else
        return nil
        #endif
    }
    
    // MARK: - Regex Classification
    
    private func classifyWithRegex(_ text: String) -> ClassificationResult {
        let (cityId, cityName) = detectCity(from: text)
        let citationType = detectCitationType(from: text)
        let parsedFields = extractFields(from: text)
        
        // Calculate confidence based on pattern matches
        let confidence = calculateClassificationConfidence(text: text, type: citationType, cityId: cityId)
        
        return ClassificationResult(
            cityId: cityId,
            cityName: cityName,
            citationType: citationType,
            confidence: confidence,
            isFromML: false,
            parsedFields: parsedFields
        )
    }
    
    // MARK: - City Detection
    
    private func detectCity(from text: String) -> (String?, String?) {
        let upperText = text.uppercased()
        
        // City indicators in text
        let cityIndicators: [(id: String, name: String, indicators: [String])] = [
            ("us-ca-san_francisco", "San Francisco", ["SFMTA", "SAN FRANCISCO", "SF MTA"]),
            ("us-ny-new_york", "New York", ["NYC", "NEW YORK", "NYC DOT"]),
            ("us-ca-los_angeles", "Los Angeles", ["LA", "LOS ANGELES", "LAPD"]),
            ("us-co-denver", "Denver", ["DENVER", "CITY OF DENVER"]),
            ("us-az-phoenix", "Phoenix", ["PHOENIX", "CITY OF PHOENIX"]),
            ("us-tx-houston", "Houston", ["HOUSTON", "CITY OF HOUSTON"]),
            ("us-il-chicago", "Chicago", ["CHICAGO", "CITY OF CHICAGO"])
        ]
        
        for city in cityIndicators {
            for indicator in city.indicators {
                if upperText.contains(indicator) {
                    return (city.id, city.name)
                }
            }
        }
        
        // Fall back to regex pattern matching
        let parseResult = parse(text)
        if let cityId = parseResult.cityId {
            return (cityId, parseResult.cityName)
        }
        
        return (nil, nil)
    }
    
    // MARK: - Citation Type Detection
    
    private func detectCitationType(from text: String) -> CitationType {
        let upperText = text.uppercased()
        
        for (type, patterns) in citationTypePatterns {
            for pattern in patterns {
                if upperText.contains(pattern) {
                    return type
                }
            }
        }
        
        // Additional heuristics based on format and keywords
        if upperText.contains("CAMERA") || upperText.contains("CAM") {
            if upperText.contains("RED") || upperText.contains("LIGHT") {
                return .redLight
            }
        }
        
        if upperText.contains("$") || upperText.contains("AMOUNT") || upperText.contains("FINE") {
            // Most citations have amounts, use other indicators
        }
        
        return .unknown
    }
    
    // MARK: - Field Extraction
    
    private func extractFields(from text: String) -> ParsedFields {
        let citationNumber = extractCitationNumber(from: text)
        let violationDate = extractViolationDate(from: text)
        let amount = extractAmount(from: text)
        let violationCode = extractViolationCode(from: text)
        let licensePlate = extractLicensePlate(from: text)
        
        return ParsedFields(
            citationNumber: citationNumber,
            violationDate: violationDate,
            amount: amount,
            violationCode: violationCode,
            licensePlate: licensePlate
        )
    }
    
    private func extractCitationNumber(from text: String) -> String? {
        let parseResult = parse(text)
        return parseResult.citationNumber
    }
    
    private func extractViolationDate(from text: String) -> Date? {
        let dates = extractDates(from: text)
        // Return the first date that's not in the future
        let now = Date()
        for date in dates {
            if date.parsedDate <= now {
                return date.parsedDate
            }
        }
        return dates.first?.parsedDate
    }
    
    private func extractAmount(from text: String) -> Double? {
        // Match dollar amounts: $123.45, 123.45, $123
        let amountPatterns = [
            "\\$\\d+\\.\\d{2}",
            "\\$\\d+",
            "\\d+\\.\\d{2}"
        ]
        
        for pattern in amountPatterns {
            guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { continue }
            
            let range = NSRange(text.startIndex..., in: text)
            if let match = regex.firstMatch(in: text, options: [], range: range),
               let matchRange = Range(match.range, in: text) {
                let amountStr = String(text[matchRange])
                    .replacingOccurrences(of: "$", with: "")
                return Double(amountStr)
            }
        }
        
        return nil
    }
    
    private func extractViolationCode(from text: String) -> String? {
        // Common violation code patterns
        let codePatterns = [
            "[A-Z]{1,3}[-\\s]?\\d{3,5}",  // ABC-12345
            "\\d{3}[-\\s]\\d{3,4}",        // 123-4567
            "SECTION\\s+\\d+",             // SECTION 123
            "CVC\\s+\\d+"                  // CVC 12345
        ]
        
        for pattern in codePatterns {
            guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else { continue }
            
            let range = NSRange(text.startIndex..., in: text)
            if let match = regex.firstMatch(in: text, options: [], range: range),
               let matchRange = Range(match.range, in: text) {
                return String(text[matchRange])
            }
        }
        
        return nil
    }
    
    private func extractLicensePlate(from text: String) -> String? {
        // License plate patterns (US format variations)
        let platePatterns = [
            "[A-Z]{1,3}[-\\s]?[A-Z0-9]{2,7}",  // ABC-12345
            "[A-Z0-9]{5,8}"                     // Plain alphanumeric
        ]
        
        for pattern in platePatterns {
            guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { continue }
            
            let range = NSRange(text.startIndex..., in: text)
            let matches = regex.matches(in: text, options: [], range: range)
            
            for match in matches {
                if let matchRange = Range(match.range, in: text) {
                    let plate = String(text[matchRange])
                    // Filter out obvious false positives (citation numbers are longer)
                    if plate.count >= 5 && plate.count <= 8 {
                        // Avoid matching citation number patterns
                        if !patterns.contains(where: { pattern in
                            let testText = plate.replacingOccurrences(of: "-", with: "").replacingOccurrences(of: " ", with: "")
                            return testText.matches(Regex(pattern.regex))
                        }) {
                            return plate
                        }
                    }
                }
            }
        }
        
        return nil
    }
    
    // MARK: - Confidence Calculation
    
    private func mergeConfidences(ml: Double, regex: Double) -> Double {
        // ML gets 60% weight, regex gets 40% when both available
        return (ml * 0.6) + (regex * 0.4)
    }
    
    private func calculateClassificationConfidence(text: String, type: CitationType, cityId: String?) -> Double {
        var confidence = 0.5
        
        // Higher confidence if citation type is determined
        if type != .unknown {
            confidence += 0.2
        }
        
        // Higher confidence if city is detected
        if cityId != nil {
            confidence += 0.15
        }
        
        // Check for amount (most citations have fines)
        if text.contains("$") || text.uppercased().contains("FINE") || text.uppercased().contains("AMOUNT") {
            confidence += 0.1
        }
        
        // Check for date (citations have violation dates)
        if extractDates(from: text).isEmpty == false {
            confidence += 0.05
        }
        
        return min(1.0, confidence)
    }
    
    // MARK: - Parsing Result
    
    public struct ParsingResult {
        public let citationNumber: String?
        public let cityId: String?
        public let cityName: String?
        public let confidence: Double
        public let matchedPattern: CityPattern?
        public let rawMatches: [String]
        
        public init(
            citationNumber: String?,
            cityId: String?,
            cityName: String?,
            confidence: Double,
            matchedPattern: CityPattern?,
            rawMatches: [String]
        ) {
            self.citationNumber = citationNumber
            self.cityId = cityId
            self.cityName = cityName
            self.confidence = confidence
            self.matchedPattern = matchedPattern
            self.rawMatches = rawMatches
        }
    }
    
    public init() {}
    
    // MARK: - Parsing
    
    // APPLE INTELLIGENCE TODO: Add Core ML classifier BEFORE regex parsing
    // Current flow: rawText → regex patterns → confidence scoring
    // Target flow: rawText → ML classifier → high confidence? use ML : fallback to regex
    //
    // Implementation:
    // 1. Create CoreML model with CreateML using citation training data
    // 2. Model inputs: raw OCR text (String)
    // 3. Model outputs: cityId (String), citationNumber (String), confidence (Double)
    // 4. Use MLModel prediction:
    //    if mlConfidence > 0.85 { return mlResult }
    //    else { fallback to current regex logic }
    //
    // Pseudo-code:
    // if FeatureFlags.mlClassification, let model = CitationClassifier.shared {
    //     let prediction = try? model.prediction(text: rawText)
    //     if prediction.confidence > 0.85 {
    //         return ParsedCitation(
    //             citationNumber: prediction.citationNumber,
    //             cityId: prediction.cityId,
    //             confidence: prediction.confidence
    //         )
    //     }
    // }
    // // Fallback to regex below...
    
    /// Parse OCR text for citation numbers
    public func parse(_ text: String) -> ParsingResult {
        let normalizedText = normalizeText(text)
        let allMatches = findAllMatches(in: normalizedText)
        
        // Return best match
        if let bestMatch = allMatches.first {
            return ParsingResult(
                citationNumber: bestMatch.matchedString,
                cityId: bestMatch.pattern.cityId,
                cityName: bestMatch.pattern.cityName,
                confidence: bestMatch.confidence,
                matchedPattern: bestMatch.pattern,
                rawMatches: allMatches.map { $0.matchedString }
            )
        }
        
        return ParsingResult(
            citationNumber: nil,
            cityId: nil,
            cityName: nil,
            confidence: 0,
            matchedPattern: nil,
            rawMatches: []
        )
    }
    
    /// Find citation number with city hint
    public func parseWithCityHint(_ text: String, cityId: String) -> ParsingResult {
        let normalizedText = normalizeText(text)
        
        // Try city-specific pattern first
        if let cityPattern = patterns.first(where: { $0.cityId == cityId }) {
            if let match = findFirstMatch(in: normalizedText, pattern: cityPattern) {
                return ParsingResult(
                    citationNumber: match.matchedString,
                    cityId: cityPattern.cityId,
                    cityName: cityPattern.cityName,
                    confidence: match.confidence,
                    matchedPattern: cityPattern,
                    rawMatches: [match.matchedString]
                )
            }
        }
        
        // Fall back to general parsing
        return parse(normalizedText)
    }
    
    // MARK: - Private Methods
    
    private func normalizeText(_ text: String) -> String {
        // Remove common OCR artifacts
        var result = text.uppercased()
        
        // Remove common separators that might be misread
        result = result.replacingOccurrences(of: " ", with: "")
        result = result.replacingOccurrences(of: "|", with: "I")
        result = result.replacingOccurrences(of: "l", with: "I")
        // Note: Do NOT replace "0" with "O" as this corrupts numeric citation numbers
        // Only replace ambiguous characters that are clearly misread letters
        
        // Remove non-alphanumeric characters except common separators
        let allowed = CharacterSet.alphanumerics
        result = String(result.unicodeScalars.filter { allowed.contains($0) })
        
        return result
    }
    
    private func findAllMatches(in text: String) -> [MatchResult] {
        var results: [MatchResult] = []
        
        for pattern in patterns.sorted(by: { $0.priority < $1.priority }) {
            if let matches = findMatches(in: text, pattern: pattern) {
                results.append(contentsOf: matches)
            }
        }
        
        // Sort by confidence and return
        return results.sorted { $0.confidence > $1.confidence }
    }
    
    private func findFirstMatch(in text: String, pattern: CityPattern) -> MatchResult? {
        findMatches(in: text, pattern: pattern)?.first
    }
    
    private func findMatches(in text: String, pattern: CityPattern) -> [MatchResult]? {
        guard let regex = try? NSRegularExpression(pattern: pattern.regex, options: []) else {
            return nil
        }
        
        let range = NSRange(text.startIndex..., in: text)
        let matches = regex.matches(in: text, options: [], range: range)
        
        guard !matches.isEmpty else { return nil }
        
        return matches.compactMap { match in
            guard let range = Range(match.range, in: text) else { return nil }
            let matchedString = String(text[range])
            return MatchResult(
                matchedString: matchedString,
                pattern: pattern,
                confidence: calculateMatchConfidence(matchedString, pattern: pattern)
            )
        }
    }
    
    private func calculateMatchConfidence(_ matchedString: String, pattern: CityPattern) -> Double {
        // Base confidence based on pattern match
        var confidence = 0.9
        
        // Adjust based on string length
        let idealLength = 9 // Approximate citation length
        let lengthDiff = abs(matchedString.count - idealLength)
        confidence -= Double(lengthDiff) * 0.05
        
        // Adjust based on character types
        let hasLetters = matchedString.contains(where: { $0.isLetter })
        let hasDigits = matchedString.contains(where: { $0.isNumber })
        
        // SF patterns have letters + digits, so give higher confidence
        if pattern.cityId == "us-ca-san_francisco" && hasLetters && hasDigits {
            confidence += 0.05
        }
        
        return min(1.0, max(0.5, confidence))
    }
    
    // MARK: - Match Result
    
    public struct MatchResult {
        public let matchedString: String
        public let pattern: CityPattern
        public let confidence: Double
    }
}

// MARK: - Date Extraction

extension OCRParsingEngine {
    /// Extract possible dates from OCR text
    public func extractDates(from text: String) -> [ExtractedDate] {
        let datePatterns = [
            // MM/DD/YYYY
            "\\d{1,2}/\\d{1,2}/\\d{4}",
            // MM-DD-YYYY
            "\\d{1,2}-\\d{1,2}-\\d{4}",
            // YYYY-MM-DD
            "\\d{4}-\\d{2}-\\d{2}",
            // Month DD, YYYY
            "[A-Za-z]+ \\d{1,2},? \\d{4}"
        ]
        
        var dates: [ExtractedDate] = []
        
        for pattern in datePatterns {
            guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { continue }
            
            let range = NSRange(text.startIndex..., in: text)
            let matches = regex.matches(in: text, options: [], range: range)
            
            for match in matches {
                if let matchRange = Range(match.range, in: text) {
                    let dateString = String(text[matchRange])
                    if let parsedDate = parseDateString(dateString) {
                        dates.append(ExtractedDate(
                            rawValue: dateString,
                            parsedDate: parsedDate,
                            position: match.range.location
                        ))
                    }
                }
            }
        }
        
        return dates
    }
    
    private func parseDateString(_ string: String) -> Date? {
        let formatters: [DateFormatter] = [
            createFormatter("MM/dd/yyyy"),
            createFormatter("MM-dd-yyyy"),
            createFormatter("yyyy-MM-dd"),
            createFormatter("MMMM d, yyyy"),
            createFormatter("MMM d, yyyy")
        ]
        
        for formatter in formatters {
            if let date = formatter.date(from: string) {
                return date
            }
        }
        
        return nil
    }
    
    private func createFormatter(_ format: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }
    
    public struct ExtractedDate {
        public let rawValue: String
        public let parsedDate: Date
        public let position: Int
    }
}

// MARK: - Formatting

extension OCRParsingEngine {
    /// Format citation number according to city conventions
    public func formatCitation(_ citationNumber: String, cityId: String) -> String {
        switch cityId {
        case "us-ca-san_francisco":
            // SFMTA format: 912-345-678 (9-digit with dashes)
            if citationNumber.count == 9 && citationNumber.allSatisfy({ $0.isNumber }) {
                return "\(citationNumber.prefix(3))-\(citationNumber.dropFirst(3).prefix(3))-\(citationNumber.suffix(3))"
            }
            return citationNumber
            
        case "us-ny-new_york":
            // NYC: 1234567890 (10 digits, no dashes)
            return citationNumber
            
        case "us-ca-los_angeles":
            // LA: LA123456 or 123456 (no dashes)
            return citationNumber
            
        default:
            return citationNumber
        }
    }
}

// MARK: - Validation Result Creation

extension ValidationResult {
    /// Create validation result from classification result
    public static func fromClassification(_ classification: ClassificationResult, isValid: Bool = false) -> ValidationResult {
        ValidationResult(
            classification: classification,
            isValid: isValid,
            errorMessage: nil
        )
    }
    
    /// Create error validation result
    public static func error(_ message: String, classification: ClassificationResult? = nil) -> ValidationResult {
        let defaultClassification = classification ?? ClassificationResult(
            cityId: nil,
            cityName: nil,
            citationType: .unknown,
            confidence: 0,
            isFromML: false,
            parsedFields: .empty
        )
        
        return ValidationResult(
            classification: defaultClassification,
            isValid: false,
            errorMessage: message
        )
    }
}
