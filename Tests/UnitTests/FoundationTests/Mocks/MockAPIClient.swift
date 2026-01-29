//
//  MockAPIClient.swift
//  FightCityFoundationTests
//
//  Mock implementation of APIClient for testing
//

import Foundation
@testable import FightCityFoundation

/// Mock API client for unit testing
final class MockAPIClient: APIClientProtocol {
    
    // MARK: - Properties
    
    var shouldFail: Bool = false
    var shouldReturnError: APIError?
    var simulatedDelay: TimeInterval = 0
    
    var getCalled: Bool = false
    var postCalled: Bool = false
    var requestCount: Int = 0
    
    // Configurable responses
    var mockResponse: Any?
    var mockStatusCode: Int = 200
    var mockHeaders: [String: String] = [:]
    
    // Request tracking
    var lastEndpoint: APIEndpoint?
    var lastRequestBody: Data?
    var allRequests: [(endpoint: APIEndpoint, method: String, body: Data?)] = []
    
    // MARK: - Initialization
    
    init(
        mockResponse: Any? = nil,
        mockStatusCode: Int = 200
    ) {
        self.mockResponse = mockResponse
        self.mockStatusCode = mockStatusCode
    }
    
    // MARK: - APIClient Protocol
    
    func get<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        getCalled = true
        requestCount += 1
        lastEndpoint = endpoint
        allRequests.append((endpoint, "GET", nil))
        
        return try handleRequest()
    }
    
    func getVoid(_ endpoint: APIEndpoint) async throws {
        getCalled = true
        requestCount += 1
        lastEndpoint = endpoint
        allRequests.append((endpoint, "GET", nil))
        
        try validateResponse()
    }
    
    func post<T: Decodable, B: Encodable>(_ endpoint: APIEndpoint, body: B) async throws -> T {
        postCalled = true
        requestCount += 1
        lastEndpoint = endpoint
        lastRequestBody = try JSONEncoder().encode(body)
        allRequests.append((endpoint, "POST", lastRequestBody))
        
        return try handleRequest()
    }
    
    func postVoid<B: Encodable>(_ endpoint: APIEndpoint, body: B) async throws {
        postCalled = true
        requestCount += 1
        lastEndpoint = endpoint
        lastRequestBody = try JSONEncoder().encode(body)
        allRequests.append((endpoint, "POST", lastRequestBody))
        
        try validateResponse()
    }
    
    // MARK: - Private Helpers
    
    private func handleRequest<T: Decodable>() throws -> T {
        if shouldFail, let error = shouldReturnError {
            throw error
        }
        
        if simulatedDelay > 0 {
            Thread.sleep(forTimeInterval: simulatedDelay)
        }
        
        try validateResponse()
        
        guard let response = mockResponse as? T else {
            throw APIError.decodingError(error: NSError(domain: "MockAPIClient", code: -1))
        }
        
        return response
    }
    
    private func validateResponse() throws {
        if shouldFail {
            throw shouldReturnError ?? .serverError(statusCode: 500)
        }
        
        switch mockStatusCode {
        case 200...299:
            return
        case 400:
            throw APIError.badRequest
        case 401:
            throw APIError.unauthorized
        case 404:
            throw APIError.notFound
        case 422:
            throw APIError.validationError
        case 429:
            throw APIError.rateLimited
        case 500...599:
            throw APIError.serverError(statusCode: mockStatusCode)
        default:
            throw APIError.unknown(statusCode: mockStatusCode)
        }
    }
    
    // MARK: - Test Helpers
    
    func resetCalls() {
        getCalled = false
        postCalled = false
        requestCount = 0
        lastEndpoint = nil
        lastRequestBody = nil
        allRequests.removeAll()
    }
    
    func configureForSuccess<T: Encodable>(response: T) {
        shouldFail = false
        shouldReturnError = nil
        mockResponse = response
        mockStatusCode = 200
    }
    
    func configureForNotFound() {
        shouldFail = true
        shouldReturnError = .notFound
        mockStatusCode = 404
    }
    
    func configureForValidationError() {
        shouldFail = true
        shouldReturnError = .validationError
        mockStatusCode = 422
    }
    
    func configureForServerError() {
        shouldFail = true
        shouldReturnError = .serverError(statusCode: 500)
        mockStatusCode = 500
    }
    
    func configureForRateLimited() {
        shouldFail = true
        shouldReturnError = .rateLimited
        mockStatusCode = 429
    }
    
    func configureForNetworkUnavailable() {
        shouldFail = true
        shouldReturnError = .networkUnavailable
        mockStatusCode = -1
    }
    
    func verifyRequestCount(_ count: Int) -> Bool {
        return requestCount == count
    }
    
    func verifyEndpointCalled(_ path: String) -> Bool {
        return allRequests.contains { $0.endpoint.path == path }
    }
}

// MARK: - APIClient Protocol

/// Protocol defining API client interface for dependency injection
public protocol APIClientProtocol {
    func get<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T
    func getVoid(_ endpoint: APIEndpoint) async throws
    func post<T: Decodable, B: Encodable>(_ endpoint: APIEndpoint, body: B) async throws -> T
    func postVoid<B: Encodable>(_ endpoint: APIEndpoint, body: B) async throws
}

// MARK: - Mock Response Builders

extension MockAPIClient {
    
    /// Create a mock citation response
    static func createMockCitationResponse(
        citationNumber: String = "SFMTA91234567",
        cityId: String = "us-ca-san_francisco",
        amount: Double = 95.00,
        daysRemaining: Int = 21
    ) -> CitationValidationResponse {
        CitationValidationResponse(
            is_valid: true,
            citation: Citation(
                id: UUID(),
                citationNumber: citationNumber,
                cityId: cityId,
                cityName: cityId.components(separatedBy: "-").last?.replacingOccurrences(of: "_", with: " ").capitalized ?? "Unknown",
                agency: "SFMTA",
                amount: Decimal(amount),
                violationDate: "2024-01-15",
                violationTime: "14:30",
                deadlineDate: "2024-02-05",
                daysRemaining: daysRemaining,
                isPastDeadline: daysRemaining < 0,
                isUrgent: daysRemaining <= 3,
                canAppealOnline: true,
                phoneConfirmationRequired: true,
                status: .pending
            ),
            confidence: 0.95
        )
    }
    
    /// Create a mock health response
    static func createMockHealthResponse() -> HealthResponse {
        HealthResponse(status: "healthy", version: "1.0.0", timestamp: Date())
    }
}

// MARK: - Mock Response Types

/// Health check response
public struct HealthResponse: Codable {
    public let status: String
    public let version: String
    public let timestamp: Date
}

/// Citation validation response
public struct CitationValidationResponse: Codable {
    public let is_valid: Bool
    public let citation: Citation
    public let confidence: Double
}

// MARK: - Test Configuration

/// Configuration for test suite
struct TestConfiguration {
    static let validSFCitation = "SFMTA91234567"
    static let validNYCCitation = "1234567890"
    static let validDenverCitation = "1234567"
    static let validLACitation = "LA123456"
    static let invalidCitation = "INVALID"
    static let mockAPIKey = "test-api-key-12345"
    static let mockBaseURL = "https://api.test.fightcitytickets.com"
}
