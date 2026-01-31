//
//  AppealWriter.swift
//  FightCityFoundation
//
//  AI-powered appeal letter writer using NaturalLanguage framework
//

import Foundation
import NaturalLanguage

import os.log

/// APPLE INTELLIGENCE: NaturalLanguage-based appeal writer for tone and clarity improvements
/// APPLE INTELLIGENCE: Sentiment analysis for appeal quality
/// APPLE INTELLIGENCE: Grammar and style suggestions using on-device NLP

// MARK: - Appeal Generation Result

/// Result of appeal generation
public struct AppealGenerationResult {
    public let appealText: String
    public let tone: AppealTone
    public let sentimentScore: Double
    public let clarityScore: Double
    public let suggestions: [AppealSuggestion]
    public let wordCount: Int
    public let processingTimeMs: Int
    
    public init(
        appealText: String,
        tone: AppealTone,
        sentimentScore: Double,
        clarityScore: Double,
        suggestions: [AppealSuggestion],
        wordCount: Int,
        processingTimeMs: Int
    ) {
        self.appealText = appealText
        self.tone = tone
        self.sentimentScore = sentimentScore
        self.clarityScore = clarityScore
        self.suggestions = suggestions
        self.wordCount = wordCount
        self.processingTimeMs = processingTimeMs
    }
}

// MARK: - Appeal Tone

/// Tone options for appeal letters
public enum AppealTone: String, CaseIterable {
    case formal = "formal"
    case respectful = "respectful"
    case persuasive = "persuasive"
    case factual = "factual"
    
    public var displayName: String {
        switch self {
        case .formal: return "Formal"
        case .respectful: return "Respectful"
        case .persuasive: return "Persuasive"
        case .factual: return "Factual"
        }
    }
    
    public var description: String {
        switch self {
        case .formal: return "Professional legal language"
        case .respectful: return "Polite and courteous"
        case .persuasive: return "Argument-driven and compelling"
        case .factual: return "Objective and data-driven"
        }
    }
}

// MARK: - Appeal Suggestion

/// Suggestion for improving appeal content
public struct AppealSuggestion: Identifiable {
    public let id: String
    public let type: SuggestionType
    public let originalText: String
    public let suggestedText: String
    public let reason: String
    public let priority: SuggestionPriority
    
    public init(
        id: String = UUID().uuidString,
        type: SuggestionType,
        originalText: String,
        suggestedText: String,
        reason: String,
        priority: SuggestionPriority
    ) {
        self.id = id
        self.type = type
        self.originalText = originalText
        self.suggestedText = suggestedText
        self.reason = reason
        self.priority = priority
    }
}

// MARK: - Suggestion Types

public enum SuggestionType: String {
    case grammar = "grammar"
    case tone = "tone"
    case clarity = "clarity"
    case conciseness = "conciseness"
    case structure = "structure"
    case persuasive = "persuasive"
}

// MARK: - Suggestion Priority

public enum SuggestionPriority: Int, Comparable {
    case low = 1
    case medium = 2
    case high = 3
    
    public static func < (lhs: SuggestionPriority, rhs: SuggestionPriority) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

// MARK: - Appeal Context

/// Context information for appeal generation
public struct AppealContext {
    public let citationNumber: String
    public let cityName: String
    public let violationDate: Date?
    public let violationCode: String?
    public let amount: Double?
    public let userReason: String
    public let evidenceDescription: String?
    public let tone: AppealTone
    
    public init(
        citationNumber: String,
        cityName: String,
        violationDate: Date? = nil,
        violationCode: String? = nil,
        amount: Double? = nil,
        userReason: String,
        evidenceDescription: String? = nil,
        tone: AppealTone = .respectful
    ) {
        self.citationNumber = citationNumber
        self.cityName = cityName
        self.violationDate = violationDate
        self.violationCode = violationCode
        self.amount = amount
        self.userReason = userReason
        self.evidenceDescription = evidenceDescription
        self.tone = tone
    }
}

// MARK: - Appeal Writer

/// AI-powered appeal letter writer
public final class AppealWriter {
    
    // MARK: - Properties
    
    /// Shared instance
    public static let shared = AppealWriter()
    
    /// Sentiment analyzer
    private let sentimentAnalyzer: NLTagger
    
    /// Sentence tokenizer
    private let sentenceTokenizer: NLTokenizer
    
    /// Word tokenizer
    private let wordTokenizer: NLTokenizer
    
    /// Letter template for different tones
    private let templates: [AppealTone: AppealTemplate]
    
    // MARK: - Appeal Template
    
    private struct AppealTemplate {
        let opening: String
        let closing: String
        let structure: [TemplateSection]
    }
    
    private enum TemplateSection {
        case header
        case body(String)
        case evidence
        case closing
    }
    
    // MARK: - Initialization
    
    public init() {
        self.sentimentAnalyzer = NLTagger(tagSchemes: [.sentimentScore])
        self.sentenceTokenizer = NLTokenizer(unit: .sentence)
        self.wordTokenizer = NLTokenizer(unit: .word)
        
        self.templates = Self.createTemplates()
    }
    
    // MARK: - Public Methods
    
    /// Generate an appeal letter
    /// - Parameter context: Context information for the appeal
    /// - Returns: Generated appeal with analysis
    public func generateAppeal(for context: AppealContext) async -> AppealGenerationResult {
        // Check if Apple Intelligence is available
        if !FeatureFlags.isAppleIntelligenceEnabled || 
           !FeatureFlags.naturalLanguageProcessing {
            // Use fallback templates
            let fallbackService = AppealFallbackService.shared
            let template = fallbackService.selectBestTemplate(for: context)
            return fallbackService.generateFromTemplate(template: template, context: context)
        }
        
        // Try DeepSeek refinement first (if enabled)
        if FeatureFlags.deepSeekRefinement {
            do {
                let request = StatementRefinementRequest(
                    citationNumber: context.citationNumber,
                    appealReason: context.userReason,
                    userName: nil,
                    cityId: context.cityName.lowercased(),
                    violationDate: context.violationDate?.ISO8601Format()
                )
                
                let response = try await DeepSeekRefinementService.shared.refineStatement(
                    request,
                    clientId: "app-\(UUID().uuidString)"
                )
                
                // Convert to AppealGenerationResult
                return AppealGenerationResult(
                    appealText: response.refinedText,
                    tone: context.tone,
                    sentimentScore: 0.5,
                    clarityScore: 0.9,
                    suggestions: [],
                    wordCount: response.refinedText.split(separator: " ").count,
                    processingTimeMs: response.processingTimeMs
                )
            } catch {
                // Fall through to Apple Intelligence or fallback
            }
        }
        
        // Use Apple Intelligence NaturalLanguage framework
        let startTime = Date()
        
        // Analyze user reason
        let analyzedReason = analyzeReason(context.userReason)
        
        // Generate appeal based on tone
        let appealText = buildAppeal(for: context, analyzedReason: analyzedReason)
        
        // Analyze the generated appeal
        let analysis = analyzeAppeal(appealText)
        
        // Generate suggestions
        let suggestions = generateSuggestions(for: appealText, analysis: analysis, context: context)
        
        let processingTimeMs = Int(Date().timeIntervalSince(startTime) * 1000)
        
        let result = AppealGenerationResult(
            appealText: appealText,
            tone: context.tone,
            sentimentScore: analysis.sentimentScore,
            clarityScore: analysis.clarityScore,
            suggestions: suggestions,
            wordCount: appealText.split(separator: " ").count,
            processingTimeMs: processingTimeMs
        )
        
        // If result is poor quality, fall back to templates
        if result.clarityScore < 0.5 || appealText.isEmpty {
            let fallbackService = AppealFallbackService.shared
            let template = fallbackService.selectBestTemplate(for: context)
            return fallbackService.generateFromTemplate(template: template, context: context)
        }
        
        return result
    }
    
    /// Analyze text sentiment
    /// - Parameter text: Text to analyze
    /// - Returns: Sentiment score (-1.0 to 1.0)
    public func analyzeSentiment(_ text: String) -> Double {
        sentimentAnalyzer.string = text
        let range = text.startIndex..<text.endIndex
        
        var totalScore: Double = 0
        var count: Double = 0
        
        sentimentAnalyzer.enumerateTags(in: range, unit: .paragraph, scheme: .sentimentScore, options: []) { tag, _ in
            if let tag = tag, let score = Double(tag.rawValue) {
                totalScore += score
                count += 1
            }
            return true
        }
        
        return count > 0 ? totalScore / count : 0
    }
    
    /// Improve text clarity and grammar
    /// - Parameter text: Text to improve
    /// - Returns: Improved text with suggestions
    public func improveText(_ text: String) -> (improved: String, suggestions: [AppealSuggestion]) {
        var suggestions: [AppealSuggestion] = []
        var improvedText = text
        
        // Check for common issues
        let issues = detectIssues(text)
        
        for issue in issues {
            improvedText = improvedText.replacingOccurrences(
                of: issue.originalText,
                with: issue.suggestedText,
                options: .caseInsensitive
            )
            suggestions.append(issue)
        }
        
        return (improvedText, suggestions)
    }
    
    /// Summarize appeal content
    /// - Parameter text: Appeal text to summarize
    /// - Parameter maxLength: Maximum summary length in words
    /// - Returns: Summarized text
    public func summarize(_ text: String, maxLength: Int = 50) -> String {
        let sentences = tokenizeSentences(text)
        let importantSentences = rankSentences(sentences, text: text)
        
        var summary: [String] = []
        var currentLength = 0
        
        for sentence in importantSentences {
            let words = sentence.split(separator: " ").count
            if currentLength + words <= maxLength {
                summary.append(sentence)
                currentLength += words
            } else {
                break
            }
        }
        
        return summary.joined(separator: " ")
    }
    
    // MARK: - Private Methods
    
    private func buildAppeal(for context: AppealContext, analyzedReason: ReasonAnalysis) -> String {
        var components: [String] = []
        
        // Header
        components.append(generateHeader(for: context))
        
        // Opening based on tone
        components.append(generateOpening(for: context))
        
        // Body with user reason
        components.append(generateBody(for: context, analyzedReason: analyzedReason))
        
        // Evidence section if available
        if let evidence = context.evidenceDescription {
            components.append(generateEvidenceSection(evidence))
        }
        
        // Closing
        components.append(generateClosing(for: context))
        
        return components.joined(separator: "\n\n")
    }
    
    private func generateHeader(for context: AppealContext) -> String {
        var header = "To Whom It May Concern,\n\n"
        header += "Re: Appeal of Parking Citation \(context.citationNumber)"
        
        if let date = context.violationDate {
            let formatter = DateFormatter()
            formatter.dateStyle = .long
            header += "\nDate of Violation: \(formatter.string(from: date))"
        }
        
        if let code = context.violationCode {
            header += "\nViolation Code: \(code)"
        }
        
        if let amount = context.amount {
            header += String(format: "\nPenalty Amount: $%.2f", amount)
        }
        
        return header
    }
    
    private func generateOpening(for context: AppealContext) -> String {
        switch context.tone {
        case .formal:
            return "I am writing to formally appeal the aforementioned parking citation. After careful review of the circumstances, I believe there are extenuating factors that warrant reconsideration of this violation."
        case .respectful:
            return "I respectfully request an appeal of this parking citation. I understand the importance of parking regulations and believe this situation deserves a second look."
        case .persuasive:
            return "I am appealing this citation because the circumstances clearly demonstrate why enforcement should not apply in this case. I respectfully ask that you review the facts and consider dismissing this violation."
        case .factual:
            return "I am submitting an appeal for citation \(context.citationNumber) based on the following factual circumstances. The evidence supports reconsideration of this violation."
        }
    }
    
    private func generateBody(for context: AppealContext, analyzedReason: ReasonAnalysis) -> String {
        var body = ""
        
        // Incorporate user's reason with improvements
        let improvedReason = improveUserReason(context.userReason, analysis: analyzedReason)
        body += improvedReason + "\n\n"
        
        // Add context-specific arguments based on city
        body += generateCitySpecificArguments(context.cityName, violationCode: context.violationCode)
        
        return body
    }
    
    private func generateEvidenceSection(_ evidence: String) -> String {
        "Supporting Evidence:\n\(evidence)"
    }
    
    private func generateClosing(for context: AppealContext) -> String {
        var closing = ""
        
        switch context.tone {
        case .formal:
            closing += "I respectfully request that this citation be reviewed and dismissed in light of the circumstances presented. I am prepared to provide any additional documentation if required.\n\n"
        case .respectful:
            closing += "Thank you for taking the time to review my appeal. I hope you will consider the circumstances and reach a fair resolution.\n\n"
        case .persuasive:
            closing += "Based on the evidence and circumstances presented, I believe a dismissal is the appropriate outcome. I appreciate your careful consideration of this matter.\n\n"
        case .factual:
            closing += "I have presented the factual basis for this appeal. I trust the reviewing authority will give due consideration to the evidence and circumstances.\n\n"
        }
        
        closing += "Sincerely,\n\n[Your Name]\n[Your Contact Information]"
        
        return closing
    }
    
    private func analyzeReason(_ reason: String) -> ReasonAnalysis {
        let sentiment = analyzeSentiment(reason)
        let wordCount = reason.split(separator: " ").count
        
        return ReasonAnalysis(
            sentiment: sentiment,
            wordCount: wordCount,
            hasExculpatoryLanguage: reason.lowercased().contains("was not") ||
                reason.lowercased().contains("did not") ||
                reason.lowercased().contains("unable"),
            hasEvidenceKeywords: reason.lowercased().contains("photo") ||
                reason.lowercased().contains("witness") ||
                reason.lowercased().contains("document")
        )
    }
    
    private struct ReasonAnalysis {
        let sentiment: Double
        let wordCount: Int
        let hasExculpatoryLanguage: Bool
        let hasEvidenceKeywords: Bool
    }
    
    private func improveUserReason(_ reason: String, analysis: ReasonAnalysis) -> String {
        var improved = reason
        
        // Capitalize first letter
        if let firstChar = improved.first {
            improved = String(firstChar).uppercased() + improved.dropFirst()
        }
        
        // Add period if missing
        if !improved.hasSuffix(".") && !improved.hasSuffix("!") {
            improved += "."
        }
        
        // Enhance exculpatory statements
        if analysis.hasExculpatoryLanguage {
            // Keep as-is, it's already clear
        }
        
        // Add context if reason is too brief
        if analysis.wordCount < 10 {
            improved += " I respectfully request that you consider these circumstances when reviewing my case."
        }
        
        return improved
    }
    
    private func generateCitySpecificArguments(_ cityName: String, violationCode: String?) -> String {
        let cityArguments: [String: [String]] = [
            "San Francisco": [
                "Given the unique parking challenges in San Francisco, particularly the complex signage and limited parking availability, this situation warrants consideration."
            ],
            "Los Angeles": [
                "Los Angeles parking regulations can be particularly challenging to navigate, especially in areas with changing restrictions."
            ],
            "New York": [
                "New York City parking enforcement has specific guidelines that may not have been properly communicated in this instance."
            ],
            "Denver": [
                "Denver municipal parking codes should be applied with consideration of the circumstances of each case."
            ]
        ]
        
        if let arguments = cityArguments[cityName] {
            return arguments.joined(separator: " ")
        }
        
        return "These circumstances demonstrate why the citation should be reviewed and potentially dismissed."
    }
    
    private func analyzeAppeal(_ text: String) -> AppealAnalysis {
        let sentimentScore = analyzeSentiment(text)
        let clarityScore = calculateClarityScore(text)
        
        return AppealAnalysis(
            sentimentScore: sentimentScore,
            clarityScore: clarityScore
        )
    }
    
    private struct AppealAnalysis {
        let sentimentScore: Double
        let clarityScore: Double
    }
    
    private func calculateClarityScore(_ text: String) -> Double {
        var score = 0.7 // Base score
        
        // Check sentence length (optimal: 15-25 words)
        let sentences = tokenizeSentences(text)
        var optimalSentences = 0
        
        for sentence in sentences {
            let wordCount = sentence.split(separator: " ").count
            if wordCount >= 10 && wordCount <= 30 {
                optimalSentences += 1
            }
        }
        
        if !sentences.isEmpty {
            let ratio = Double(optimalSentences) / Double(sentences.count)
            score += ratio * 0.2
        }
        
        // Check for proper structure
        if text.contains("Dear") || text.contains("To Whom") {
            score += 0.05
        }
        if text.contains("Sincerely") || text.contains("Respectfully") {
            score += 0.05
        }
        
        return min(1.0, score)
    }
    
    private func detectIssues(_ text: String) -> [AppealSuggestion] {
        var issues: [AppealSuggestion] = []
        
        // Check for double spaces
        if text.contains("  ") {
            issues.append(AppealSuggestion(
                type: .clarity,
                originalText: "  ",
                suggestedText: " ",
                reason: "Remove extra whitespace",
                priority: .low
            ))
        }
        
        // Check for very long sentences
        let sentences = tokenizeSentences(text)
        for sentence in sentences {
            let wordCount = sentence.split(separator: " ").count
            if wordCount > 40 {
                issues.append(AppealSuggestion(
                    type: .conciseness,
                    originalText: sentence,
                    suggestedText: summarize(sentence, maxLength: 30),
                    reason: "Consider breaking up long sentences",
                    priority: .medium
                ))
            }
        }
        
        return issues
    }
    
    private func generateSuggestions(for text: String, analysis: AppealAnalysis, context: AppealContext) -> [AppealSuggestion] {
        var suggestions: [AppealSuggestion] = []
        
        // Tone suggestions
        if analysis.sentimentScore < -0.3 {
            suggestions.append(AppealSuggestion(
                type: .tone,
                originalText: text,
                suggestedText: improveTone(text, targetTone: context.tone),
                reason: "Consider a more neutral tone for better reception",
                priority: .high
            ))
        }
        
        // Clarity suggestions
        if analysis.clarityScore < 0.7 {
            suggestions.append(AppealSuggestion(
                type: .clarity,
                originalText: "Consider simplifying your language",
                suggestedText: "",
                reason: "Your appeal could be clearer with simpler language",
                priority: .medium
            ))
        }
        
        return suggestions
    }
    
    private func improveTone(_ text: String, targetTone: AppealTone) -> String {
        // Simplified tone improvement
        switch targetTone {
        case .formal:
            return text.replacingOccurrences(of: "I think", with: "I believe")
                .replacingOccurrences(of: "maybe", with: "perhaps")
        default:
            return text
        }
    }
    
    private func tokenizeSentences(_ text: String) -> [String] {
        sentenceTokenizer.string = text
        var sentences: [String] = []
        
        sentenceTokenizer.enumerateTokens(in: text.startIndex..<text.endIndex) { range, _ in
            sentences.append(String(text[range]))
            return true
        }
        
        return sentences
    }
    
    private func rankSentences(_ sentences: [String], text: String) -> [String] {
        // Simple ranking based on position and keyword presence
        let keywords = ["because", "therefore", "however", "evidence", "citation", "violation", "appeal"]
        
        var scoredSentences: [(sentence: String, score: Double)] = []
        
        for (index, sentence) in sentences.enumerated() {
            var score = 1.0
            
            // Prefer sentences with keywords
            for keyword in keywords {
                if sentence.lowercased().contains(keyword) {
                    score += 0.5
                }
            }
            
            // Prefer first and last sentences
            if index == 0 || index == sentences.count - 1 {
                score += 0.3
            }
            
            scoredSentences.append((sentence, score))
        }
        
        return scoredSentences
            .sorted { $0.score > $1.score }
            .map { $0.sentence }
    }
    
    // MARK: - Templates
    
    private static func createTemplates() -> [AppealTone: AppealTemplate] {
        [
            .formal: AppealTemplate(
                opening: "I am writing to formally appeal...",
                closing: "I respectfully request...",
                structure: [.header, .body("formal"), .evidence, .closing]
            ),
            .respectful: AppealTemplate(
                opening: "I respectfully request...",
                closing: "Thank you for your consideration...",
                structure: [.header, .body("respectful"), .evidence, .closing]
            ),
            .persuasive: AppealTemplate(
                opening: "I am appealing because...",
                closing: "I believe dismissal is appropriate...",
                structure: [.header, .body("persuasive"), .evidence, .closing]
            ),
            .factual: AppealTemplate(
                opening: "I am submitting an appeal based on...",
                closing: "I trust you will give due consideration...",
                structure: [.header, .body("factual"), .evidence, .closing]
            )
        ]
    }
}

// MARK: - Appeal Preview

extension AppealWriter {
    /// Generate a preview of the appeal
    public func generatePreview(for context: AppealContext, maxLength: Int = 200) async -> String {
        let result = await generateAppeal(for: context)
        let preview = String(result.appealText.prefix(maxLength))
        return preview + (result.appealText.count > maxLength ? "..." : "")
    }
}
