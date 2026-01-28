//
//  APIClient.swift
//  FightCityTicketsCore
//
//  HTTP client abstraction for cross-platform testing
//

import Foundation

/// HTTP method
public enum HTTPMethod: String, Sendable {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

/// API error types
public enum APIError: Error, Sendable {
    case invalidURL(path: String)
    case invalidResponse
    case decodingError(String)
    case badRequest
    case unauthorized
    case notFound
    case validationError
    case rateLimited
    case serverError(statusCode: Int)
    case unknown(statusCode: Int)
    case networkUnavailable
    
    public var message: String {
        switch self {
        case .invalidURL(let path):
            return "Invalid URL: \(path)"
        case .invalidResponse:
            return "Invalid server response"
        case .decodingError(let error):
            return "Failed to decode response: \(error)"
        case .badRequest:
            return "Invalid request"
        case .unauthorized:
            return "Authentication required"
        case .notFound:
            return "Resource not found"
        case .validationError:
            return "Validation failed"
        case .rateLimited:
            return "Too many requests. Please try again later."
        case .serverError(let code):
            return "Server error (\(code))"
        case .unknown(let code):
            return "Unexpected error (\(code))"
        case .networkUnavailable:
            return "Network unavailable. Your changes will sync when online."
        }
    }
}

/// HTTP request
public struct APIRequest: Sendable {
    public let path: String
    public let method: HTTPMethod
    public let queryItems: [URLQueryItem]?
    public let headers: [String: String]
    public let body: Data?
    
    public init(
        path: String,
        method: HTTPMethod = .get,
        queryItems: [URLQueryItem]? = nil,
        headers: [String: String] = [:],
        body: Data? = nil
    ) {
        self.path = path
        self.method = method
        self.queryItems = queryItems
        self.headers = headers
        self.body = body
    }
}

/// HTTP response
public struct APIResponse: Sendable {
    public let statusCode: Int
    public let body: Data?
    public let headers: [String: String]
    
    public init(statusCode: Int, body: Data? = nil, headers: [String: String] = [:]) {
        self.statusCode = statusCode
        self.body = body
        self.headers = headers
    }
    
    public var isSuccess: Bool {
        (200...299).contains(statusCode)
    }
}

/// Protocol for HTTP client - enables mocking on Linux
public protocol APIClientProtocol: Sendable {
    /// Perform HTTP request
    func perform(_ request: APIRequest) async throws -> APIResponse
    
    /// Set authorization token
    func setAuthorizationToken(_ token: String?)
    
    /// Clear authorization
    func clearAuthorization()
}

/// Default implementations
public extension APIClientProtocol {
    func setAuthorizationToken(_ token: String?) {}
    func clearAuthorization() {}
}

/// Mock API client for testing
public actor MockAPIClient: APIClientProtocol {
    public var baseURL: URL
    public var shouldFail: Bool = false
    public var shouldReturnNetworkUnavailable: Bool = false
    public var simulatedStatusCode: Int = 200
    public var simulatedResponseBody: Data?
    public var simulatedDelay: TimeInterval = 0.1
    public var callHistory: [APIRequest] = []
    public var authorizationToken: String?
    
    public init(baseURL: URL = URL(string: "http://localhost:8000")!) {
        self.baseURL = baseURL
    }
    
    public func perform(_ request: APIRequest) async throws -> APIResponse {
        callHistory.append(request)
        
        // Simulate delay
        try await Task.sleep(nanoseconds: UInt64(simulatedDelay * 1_000_000_000))
        
        if shouldReturnNetworkUnavailable {
            throw APIError.networkUnavailable
        }
        
        if shouldFail {
            throw APIError.serverError(statusCode: 500)
        }
        
        return APIResponse(
            statusCode: simulatedStatusCode,
            body: simulatedResponseBody,
            headers: ["Content-Type": "application/json"]
        )
    }
    
    public func setAuthorizationToken(_ token: String?) {
        authorizationToken = token
    }
    
    public func clearAuthorization() {
        authorizationToken = nil
    }
    
    /// Reset mock state
    public func reset() {
        shouldFail = false
        shouldReturnNetworkUnavailable = false
        simulatedStatusCode = 200
        simulatedResponseBody = nil
        callHistory = []
        authorizationToken = nil
    }
    
    /// Setup mock to return citation validation success
    public func setupValidationSuccess(citation: Citation) {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        simulatedResponseBody = try? encoder.encode(citation)
        simulatedStatusCode = 200
    }
    
    /// Setup mock to return validation not found
    public func setupValidationNotFound() {
        simulatedStatusCode = 404
        simulatedResponseBody = nil
    }
}

// MARK: - Convenience Endpoints

extension APIClientProtocol {
    public func health() async throws -> APIResponse {
        let request = APIRequest(path: AppConfig.APIEndpoints.health)
        return try await perform(request)
    }
    
    public func validateCitation(citationNumber: String, cityId: String?) async throws -> APIResponse {
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "citation_number", value: citationNumber)
        ]
        if let cityId = cityId {
            queryItems.append(URLQueryItem(name: "city_id", value: cityId))
        }
        
        let request = APIRequest(
            path: AppConfig.APIEndpoints.validateCitation,
            queryItems: queryItems
        )
        return try await perform(request)
    }
    
    public func submitAppeal(citationId: String, reason: String) async throws -> APIResponse {
        let body = ["citation_id": citationId, "reason": reason]
        let encoder = JSONEncoder()
        let bodyData = try encoder.encode(body)
        
        let request = APIRequest(
            path: AppConfig.APIEndpoints.appealSubmit,
            method: .post,
            headers: ["Content-Type": "application/json"],
            body: bodyData
        )
        return try await perform(request)
    }
    
    public func statusLookup(citationNumber: String) async throws -> APIResponse {
        let queryItems = [
            URLQueryItem(name: "citation_number", value: citationNumber)
        ]
        let request = APIRequest(
            path: AppConfig.APIEndpoints.statusLookup,
            queryItems: queryItems
        )
        return try await perform(request)
    }
}
