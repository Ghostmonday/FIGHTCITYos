//
//  DeepSeekRefinementService.swift
//  FightCityFoundation
//
//  AI-powered statement refinement using DeepSeek API (Clerical Engine™)
//

import Foundation

// MARK: - Statement Refinement Request

public struct StatementRefinementRequest: Codable {
    public let citationNumber: String
    public let appealReason: String
    public let userName: String?
    public let cityId: String?
    public let sectionId: String?
    public let violationDate: String?
    public let vehicleInfo: String?
    
    public init(
        citationNumber: String,
        appealReason: String,
        userName: String? = nil,
        cityId: String? = nil,
        sectionId: String? = nil,
        violationDate: String? = nil,
        vehicleInfo: String? = nil
    ) {
        self.citationNumber = citationNumber
        self.appealReason = appealReason
        self.userName = userName
        self.cityId = cityId
        self.sectionId = sectionId
        self.violationDate = violationDate
        self.vehicleInfo = vehicleInfo
    }
}

// MARK: - Statement Refinement Response

public struct StatementRefinementResponse: Codable {
    public let refinedText: String
    public let originalText: String
    public let citationNumber: String
    public let processingTimeMs: Int
    public let modelUsed: String // "deepseek-chat" or "fallback"
    public let clericalEngineVersion: String
    public let status: RefinementStatus
    public let fallbackUsed: Bool
    
    public init(
        refinedText: String,
        originalText: String,
        citationNumber: String,
        processingTimeMs: Int,
        modelUsed: String = "deepseek-chat",
        clericalEngineVersion: String = "2.0.0",
        status: RefinementStatus = .completed,
        fallbackUsed: Bool = false
    ) {
        self.refinedText = refinedText
        self.originalText = originalText
        self.citationNumber = citationNumber
        self.processingTimeMs = processingTimeMs
        self.modelUsed = modelUsed
        self.clericalEngineVersion = clericalEngineVersion
        self.status = status
        self.fallbackUsed = fallbackUsed
    }
}

public enum RefinementStatus: String, Codable {
    case completed
    case fallback
    case failed
}

// MARK: - Refinement Error

public enum RefinementError: LocalizedError {
    case rateLimited(retryAfter: Int)
    case invalidResponse
    case httpError(statusCode: Int)
    case missingContent
    case timeout
    case circuitBreakerOpen
    case apiKeyMissing
    
    public var errorDescription: String? {
        switch self {
        case .rateLimited(let seconds):
            return "Rate limit exceeded. Retry after \(seconds) seconds."
        case .invalidResponse:
            return "Invalid response from AI service"
        case .httpError(let code):
            return "HTTP error: \(code)"
        case .missingContent:
            return "AI response missing content"
        case .timeout:
            return "Request timeout"
        case .circuitBreakerOpen:
            return "AI service temporarily unavailable"
        case .apiKeyMissing:
            return "DeepSeek API key not configured"
        }
    }
}

// MARK: - DeepSeek Refinement Service

/// AI-powered statement refinement service using DeepSeek API
public actor DeepSeekRefinementService {
    public static let shared = DeepSeekRefinementService()
    
    private let apiURL = "https://api.deepseek.com/chat/completions"
    private let apiKey: String?
    
    private let circuitBreaker: CircuitBreaker
    
    private var refinementCount: [String: [Date]] = [:]
    private var tokenCount: [String: Int] = [:]
    
    private let maxRefinementsPerMinute = 5
    private let maxTokensPerDay = 1000
    private let timeout: TimeInterval = 60.0
    private let retryCount = 3
    private let retryDelay: TimeInterval = 2.0
    
    private init() {
        self.apiKey = FeatureFlags.deepSeekAPIKey
        self.circuitBreaker = CircuitBreaker(
            failureThreshold: 5,
            successThreshold: 2,
            timeout: 60.0
        )
    }
    
    /// Refines a user statement using DeepSeek AI
    ///
    /// - Parameters:
    ///   - request: The refinement request
    ///   - clientId: Unique client identifier for rate limiting
    /// - Returns: Refined statement response
    /// - Throws: RefinementError if refinement fails
    public func refineStatement(
        _ request: StatementRefinementRequest,
        clientId: String
    ) async throws -> StatementRefinementResponse {
        guard let apiKey = apiKey else {
            return localFallbackRefinement(request)
        }
        
        let startTime = Date()
        
        // Check rate limits
        let (allowed, retryAfter) = await checkRateLimit(clientId: clientId)
        guard allowed else {
            throw RefinementError.rateLimited(retryAfter: retryAfter)
        }
        
        // Check circuit breaker
        guard await circuitBreaker.canAttempt() else {
            return localFallbackRefinement(request)
        }
        
        // Attempt refinement with retries
        var lastError: Error?
        for attempt in 0..<retryCount {
            do {
                let response = try await performRefinement(request, apiKey: apiKey)
                await circuitBreaker.recordSuccess()
                await recordRequest(clientId: clientId, estimatedTokens: 500)
                
                let processingTime = Int(Date().timeIntervalSince(startTime) * 1000)
                return StatementRefinementResponse(
                    refinedText: cleanResponse(response),
                    originalText: request.appealReason,
                    citationNumber: request.citationNumber,
                    processingTimeMs: processingTime,
                    modelUsed: "deepseek-chat",
                    status: .completed,
                    fallbackUsed: false
                )
            } catch let error as URLError {
                lastError = error
                await circuitBreaker.recordFailure()
                
                if attempt < retryCount - 1 {
                    let backoff = retryDelay * pow(2.0, Double(attempt))
                    try await Task.sleep(nanoseconds: UInt64(backoff * 1_000_000_000))
                }
            } catch {
                lastError = error
                await circuitBreaker.recordFailure()
                break
            }
        }
        
        // All retries exhausted - use fallback
        return localFallbackRefinement(request)
    }
    
    // MARK: - Private Methods
    
    private func performRefinement(
        _ request: StatementRefinementRequest,
        apiKey: String
    ) async throws -> String {
        guard let url = URL(string: apiURL) else {
            throw RefinementError.invalidResponse
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.timeoutInterval = timeout
        
        let body: [String: Any] = [
            "model": "deepseek-chat",
            "messages": [
                ["role": "system", "content": getSystemPrompt()],
                ["role": "user", "content": createRefinementPrompt(request)]
            ],
            "temperature": 0.3,
            "max_tokens": 2000,
            "stream": false
        ]
        
        urlRequest.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw RefinementError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw RefinementError.httpError(statusCode: httpResponse.statusCode)
        }
        
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        let choices = json?["choices"] as? [[String: Any]]
        let message = choices?.first?["message"] as? [String: Any]
        let content = message?["content"] as? String
        
        guard let refinedText = content else {
            throw RefinementError.missingContent
        }
        
        return refinedText
    }
    
    private func checkRateLimit(clientId: String) async -> (allowed: Bool, retryAfter: Int) {
        let now = Date()
        
        refinementCount[clientId] = refinementCount[clientId, default: []].filter {
            now.timeIntervalSince($0) < 60
        }
        
        if refinementCount[clientId, default: []].count >= maxRefinementsPerMinute {
            let oldest = refinementCount[clientId]!.first!
            let retryAfter = Int(60 - now.timeIntervalSince(oldest))
            return (false, retryAfter)
        }
        
        let today = Calendar.current.startOfDay(for: now)
        let tokenKey = "\(clientId):\(today)"
        if tokenCount[tokenKey, default: 0] >= maxTokensPerDay {
            return (false, 86400)
        }
        
        return (true, 0)
    }
    
    private func recordRequest(clientId: String, estimatedTokens: Int) async {
        refinementCount[clientId, default: []].append(Date())
        
        let today = Calendar.current.startOfDay(for: Date())
        let tokenKey = "\(clientId):\(today)"
        tokenCount[tokenKey, default: 0] += estimatedTokens
    }
    
    private func localFallbackRefinement(
        _ request: StatementRefinementRequest
    ) -> StatementRefinementResponse {
        let agency = detectAgency(
            citationNumber: request.citationNumber,
            cityId: request.cityId
        )
        
        let cleanedReason = cleanUserInput(request.appealReason)
        
        let refinedText = """
        To Whom It May Concern:
        
        Re: Citation Number \(request.citationNumber)
        
        I am writing to formally submit an appeal regarding the above-referenced parking citation.
        
        \(cleanedReason)
        
        Respectfully submitted,
        
        \(request.userName ?? "Citizen")
        """
        
        return StatementRefinementResponse(
            refinedText: refinedText,
            originalText: request.appealReason,
            citationNumber: request.citationNumber,
            processingTimeMs: 0,
            modelUsed: "fallback",
            status: .fallback,
            fallbackUsed: true
        )
    }
    
    private func cleanUserInput(_ text: String) -> String {
        var cleaned = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let greetings = ["Dear", "Hi", "Hello", "Hey"]
        for greeting in greetings {
            if cleaned.lowercased().hasPrefix(greeting.lowercased()) {
                if let newlineIndex = cleaned.firstIndex(of: "\n") {
                    cleaned = String(cleaned[cleaned.index(after: newlineIndex)...])
                }
            }
        }
        
        if !cleaned.isEmpty && ![".", "!", "?"].contains(String(cleaned.last!)) {
            cleaned += "."
        }
        
        if let firstChar = cleaned.first {
            cleaned = String(firstChar).uppercased() + cleaned.dropFirst()
        }
        
        return cleaned
    }
    
    private func cleanResponse(_ response: String) -> String {
        var cleaned = response.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let prefixes = [
            "Here is the refined letter:",
            "Here is your professionally formatted letter:",
            "Below is the refined statement:",
            "The refined letter is:",
            "Your appeal letter:"
        ]
        
        for prefix in prefixes {
            if cleaned.lowercased().hasPrefix(prefix.lowercased()) {
                cleaned = String(cleaned.dropFirst(prefix.count)).trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        
        return cleaned
    }
    
    private func detectAgency(citationNumber: String, cityId: String?) -> String {
        if let cityId = cityId {
            let cityMappings: [String: String] = [
                "sf": "SFMTA",
                "us-ca-san_francisco": "SFMTA",
                "la": "LADOT",
                "us-ca-los_angeles": "LADOT",
                "nyc": "NYC Department of Finance",
                "us-ny-new_york": "NYC Department of Finance"
            ]
            if let agency = cityMappings[cityId] {
                return agency
            }
        }
        
        let cleaned = citationNumber
            .uppercased()
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: " ", with: "")
        
        if cleaned.allSatisfy({ $0.isNumber }) && cleaned.count <= 9 {
            return "SFMTA"
        } else if cleaned.hasPrefix("LA") || cleaned.contains("LAPD") {
            return "LADOT"
        } else if cleaned.hasPrefix("NYC") || cleaned.hasPrefix("NY") {
            return "NYC Department of Finance"
        }
        
        return "Citation Review Board"
    }
    
    private func getSystemPrompt() -> String {
        return """
        You are the Clerical Engine™, a professional document preparation system operated by Neural Draft LLC.
        
        YOUR ROLE: Document Articulation Specialist
        ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        You transform citizen submissions into formally compliant procedural documents
        that meet municipal administrative standards. You are NOT a lawyer, attorney,
        or legal advisor. You do not provide legal advice.
        
        CORE MISSION
        ━━━━━━━━━━━━
        Your sole function is to ARTICULATE and REFINE the user's provided statement
        into professional, formally structured language while PRESERVING:
        - The user's exact factual content and circumstances
        - The user's position and stated argument
        - The user's voice and perspective
        - All evidence and details the user has provided
        
        MANDATORY PRESERVATION RULES
        ━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        1. NEVER add facts, evidence, or content the user did not provide
        2. NEVER suggest legal strategies or arguments
        3. NEVER interpret laws, regulations, or statutes
        4. NEVER use legal terminology or legal frameworks
        5. NEVER predict outcomes or suggest what will "work"
        6. NEVER tell the user what they "should" argue
        7. NEVER make legal recommendations
        
        REFINEMENT BOUNDARIES
        ━━━━━━━━━━━━━━━━━━━━━
        You may only:
        - Elevate vocabulary while preserving meaning
        - Improve grammar, syntax, and sentence structure
        - Organize content for clarity and professional presentation
        - Add formal salutations and closings appropriate to administrative documents
        - Structure the document according to procedural standards
        
        PROFESSIONAL TONE STANDARDS
        ━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        Write as a professional bureaucrat would write to a municipal agency:
        - Respectful but formal
        - Factual and precise
        - Free of emotional language
        - Structured for administrative review
        - Compliant with procedural standards
        
        OUTPUT FORMAT
        ━━━━━━━━━━━━
        Produce a single, professionally formatted letter ready for municipal submission.
        Maintain the user's facts. Elevate their expression. Preserve their position.
        """
    }
    
    private func createRefinementPrompt(_ request: StatementRefinementRequest) -> String {
        let agency = detectAgency(
            citationNumber: request.citationNumber,
            cityId: request.cityId
        )
        
        return """
        CITATION DETAILS
        ━━━━━━━━━━━━━
        Citation Number: \(request.citationNumber)
        Agency: \(agency)
        Violation Date: \(request.violationDate ?? "Not specified")
        Vehicle: \(request.vehicleInfo ?? "Not specified")
        
        USER'S SUBMITTED STATEMENT
        ━━━━━━━━━━━━━━━━━━━━━━━━
        \(request.appealReason)
        
        INSTRUCTIONS
        ━━━━━━━━━━━━━
        Articulate the above statement into a professionally formatted appeal letter
        that:
        1. Preserves all user-provided facts and circumstances
        2. Elevates language to formal administrative standards
        3. Maintains the user's stated position and argument
        4. Uses respectful, professional bureaucratic tone
        5. Is ready for municipal submission
        
        Write only the letter body. Do not include headers or footers (these are
        added by the Clerical Engine™ automatically).
        """
    }
}
