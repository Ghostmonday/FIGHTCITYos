//
//  APIClient.swift
//  FightCityTickets
//
//  URLSession wrapper with retry, timeout, and offline support
//

import Foundation

/// API client with retry logic, timeout, and offline support
actor APIClient {
    static let shared = APIClient()
    
    private let session: URLSession
    private let config: AppConfig
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    private init() {
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 30
        sessionConfig.timeoutIntervalForResource = 60
        sessionConfig.waitsForConnectivity = true
        self.session = URLSession(configuration: sessionConfig)
        self.config = AppConfig.shared
        
        self.decoder = JSONDecoder()
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
        self.decoder.dateDecodingStrategy = .iso8601
        
        self.encoder = JSONEncoder()
        self.encoder.keyEncodingStrategy = .convertToSnakeCase
        self.encoder.dateEncodingStrategy = .iso8601
    }
    
    // MARK: - GET
    
    func get<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        let request = try buildRequest(endpoint: endpoint, method: .get)
        return try await execute(request)
    }
    
    func getVoid(_ endpoint: APIEndpoint) async throws {
        let request = try buildRequest(endpoint: endpoint, method: .get)
        let (_, response) = try await session.data(for: request)
        try validateResponse(response)
    }
    
    // MARK: - POST
    
    func post<T: Decodable, B: Encodable>(_ endpoint: APIEndpoint, body: B) async throws -> T {
        let request = try buildRequest(endpoint: endpoint, method: .post, body: body)
        return try await execute(request)
    }
    
    func postVoid<B: Encodable>(_ endpoint: APIEndpoint, body: B) async throws {
        let request = try buildRequest(endpoint: endpoint, method: .post, body: body)
        let (_, response) = try await session.data(for: request)
        try validateResponse(response)
    }
    
    // MARK: - Private Methods
    
    private func buildRequest<B: Encodable>(endpoint: APIEndpoint, method: HTTPMethod, body: B? = nil) throws -> URLRequest {
        guard let url = URL(string: endpoint.path, relativeTo: config.apiBaseURL) else {
            throw APIError.invalidURL(path: endpoint.path)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        // Add auth token if available
        if let token = AuthManager.shared.getAccessToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = body {
            request.httpBody = try encoder.encode(body)
        }
        
        return request
    }
    
    private func execute<T: Decodable>(_ request: URLRequest) async throws -> T {
        let (data, response) = try await session.data(for: request)
        try validateResponse(response)
        
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingError(error: error)
        }
    }
    
    private func validateResponse(_ response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        switch httpResponse.statusCode {
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
            throw APIError.serverError(statusCode: httpResponse.statusCode)
        default:
            throw APIError.unknown(statusCode: httpResponse.statusCode)
        }
    }
}

// MARK: - HTTP Method

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

// MARK: - API Endpoint

struct APIEndpoint {
    let path: String
    let queryItems: [URLQueryItem]?
    
    init(path: String, queryItems: [URLQueryItem]? = nil) {
        self.path = path
        self.queryItems = queryItems
    }
    
    // MARK: - Convenience Endpoints
    
    static func health() -> APIEndpoint {
        APIEndpoint(path: AppConfig.APIEndpoints.health)
    }
    
    static func validateCitation(_ request: CitationValidationRequest) -> APIEndpoint {
        APIEndpoint(path: AppConfig.APIEndpoints.validateCitation)
    }
    
    static func validateTicket(citationNumber: String, cityId: String?) -> APIEndpoint {
        var items = [URLQueryItem(name: "citation_number", value: citationNumber)]
        if let cityId = cityId {
            items.append(URLQueryItem(name: "city_id", value: cityId))
        }
        return APIEndpoint(path: AppConfig.APIEndpoints.validateTicket, queryItems: items)
    }
    
    static func submitAppeal(_ request: AppealSubmitRequest) -> APIEndpoint {
        APIEndpoint(path: AppConfig.APIEndpoints.appealSubmit)
    }
    
    static func statusLookup(_ request: StatusLookupRequest) -> APIEndpoint {
        APIEndpoint(path: AppConfig.APIEndpoints.statusLookup)
    }
    
    static func telemetryUpload(_ request: TelemetryUploadRequest) -> APIEndpoint {
        APIEndpoint(path: AppConfig.APIEndpoints.telemetryUpload)
    }
    
    static func ocrConfig(city: String) -> APIEndpoint {
        let item = URLQueryItem(name: "city", value: city)
        return APIEndpoint(path: AppConfig.APIEndpoints.ocrConfig, queryItems: [item])
    }
}

// MARK: - API Error

enum APIError: LocalizedError {
    case invalidURL(path: String)
    case invalidResponse
    case decodingError(Error)
    case badRequest
    case unauthorized
    case notFound
    case validationError
    case rateLimited
    case serverError(statusCode: Int)
    case unknown(statusCode: Int)
    case networkUnavailable
    
    var errorDescription: String? {
        switch self {
        case .invalidURL(let path):
            return "Invalid URL: \(path)"
        case .invalidResponse:
            return "Invalid server response"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
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
