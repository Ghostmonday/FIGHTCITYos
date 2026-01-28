//
//  OCRParsingEngine.swift
//  FightCityTickets
//
//  Regex patterns per city for citation parsing (from backend patterns)
//

import Foundation

/// Parses OCR text using city-specific regex patterns (matching backend CitationValidator)
struct OCRParsingEngine {
    // MARK: - City Patterns (from Python backend)
    
    struct CityPattern {
        let cityId: String
        let cityName: String
        let regex: String
        let priority: Int
        let formatExample: String
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
    
    // MARK: - Parsing Result
    
    struct ParsingResult {
        let citationNumber: String?
        let cityId: String?
        let cityName: String?
        let confidence: Double
        let matchedPattern: CityPattern?
        let rawMatches: [String]
    }
    
    // MARK: - Parsing
    
    /// Parse OCR text for citation numbers
    func parse(_ text: String) -> ParsingResult {
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
    func parseWithCityHint(_ text: String, cityId: String) -> ParsingResult {
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
        result = result.replacingOccurrences(of: "0", with: "O")
        
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
        
        return matches.map { match in
            let matchedString = String(text[Range(match.range, in: text)!])
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
    
    struct MatchResult {
        let matchedString: String
        let pattern: CityPattern
        let confidence: Double
    }
}

// MARK: - Date Extraction

extension OCRParsingEngine {
    /// Extract possible dates from OCR text
    func extractDates(from text: String) -> [ExtractedDate] {
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
    
    struct ExtractedDate {
        let rawValue: String
        let parsedDate: Date
        let position: Int
    }
}

// MARK: - Formatting

extension OCRParsingEngine {
    /// Format citation number according to city conventions
    func formatCitation(_ citationNumber: String, cityId: String) -> String {
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
