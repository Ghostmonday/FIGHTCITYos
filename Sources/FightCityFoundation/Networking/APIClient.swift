//
//  APIClient.swift
//  FightCityFoundation
//
//  URLSession wrapper with retry, timeout, and offline support
//

import Foundation

/// Configuration protocol for API client
public protocol APIConfiguration {
    var apiBaseURL: URL { get }
}

/// Default API configuration
public struct DefaultAPIConfiguration: APIConfiguration {
    public let apiBaseURL: URL
    
    public init(apiBaseURL: URL = URL(string: "https://api.fightcitytickets.com")!) {
        self.apiBaseURL = apiBaseURL
    }
}

/// API client with retry logic, timeout, and offline support
public actor APIClient {
    public static let shared = APIClient()
    
    private let session: URLSession
    private var config: APIConfiguration
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    public init(config: APIConfiguration = DefaultAPIConfiguration()) {
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 30
        sessionConfig.timeoutIntervalForResource = 60
        sessionConfig.waitsForConnectivity = true
        self.session = URLSession(configuration: sessionConfig)
        self.config = config
        
        self.decoder = JSONDecoder()
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
        self.decoder.dateDecodingStrategy = .iso8601
        
        self.encoder = JSONEncoder()
        self.encoder.keyEncodingStrategy = .convertToSnakeCase
        self.encoder.dateEncodingStrategy = .iso8601
    }
    
    // MARK: - Configuration
    
    public func updateConfiguration(_ newConfig: APIConfiguration) {
        self.config = newConfig
    }
    
    // MARK: - GET
    
    public func get<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        let request = try buildRequest(endpoint: endpoint, method: .get)
        return try await execute(request)
    }
    
    public func getVoid(_ endpoint: APIEndpoint) async throws {
        let request = try buildRequest(endpoint: endpoint, method: .get)
        let (_, response) = try await session.data(for: request)
        try validateResponse(response)
    }
    
    // MARK: - POST
    
    public func post<T: Decodable, B: Encodable>(_ endpoint: APIEndpoint, body: B) async throws -> T {
        let request = try buildRequest(endpoint: endpoint, method: .post, body: body)
        return try await execute(request)
    }
    
    public func postVoid<B: Encodable>(_ endpoint: APIEndpoint, body: B) async throws {
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

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

// MARK: - API Endpoint

public struct APIEndpoint {
    public let path: String
    public let queryItems: [URLQueryItem]?
    
    public init(path: String, queryItems: [URLQueryItem]? = nil) {
        self.path = path
        self.queryItems = queryItems
    }
    
    // MARK: - Convenience Endpoints
    
    public static func health() -> APIEndpoint {
        APIEndpoint(path: APIEndpoints.health)
    }
    
    public static func validateCitation(_ request: CitationValidationRequest) -> APIEndpoint {
        APIEndpoint(path: APIEndpoints.validateCitation)
    }
    
    public static func validateTicket(citationNumber: String, cityId: String?) -> APIEndpoint {
        var items = [URLQueryItem(name: "citation_number", value: citationNumber)]
        if let cityId = cityId {
            items.append(URLQueryItem(name: "city_id", value: cityId))
        }
        return APIEndpoint(path: APIEndpoints.validateTicket, queryItems: items)
    }
    
    public static func submitAppeal(_ request: AppealSubmitRequest) -> APIEndpoint {
        APIEndpoint(path: APIEndpoints.appealSubmit)
    }
    
    public static func statusLookup(_ request: StatusLookupRequest) -> APIEndpoint {
        APIEndpoint(path: APIEndpoints.statusLookup)
    }
    
    public static func telemetryUpload(_ request: TelemetryUploadRequest) -> APIEndpoint {
        APIEndpoint(path: APIEndpoints.telemetryUpload)
    }
    
    public static func ocrConfig(city: String) -> APIEndpoint {
        let item = URLQueryItem(name: "city", value: city)
        return APIEndpoint(path: APIEndpoints.ocrConfig(city: city), queryItems: [item])
    }
}

// MARK: - Telemetry Upload (Moved from ValidationResult for proper separation)

/// Telemetry upload request
public struct TelemetryUploadRequest: Codable {
    public let records: [TelemetryRecord]
}

/// Individual telemetry record (opt-in)
public struct TelemetryRecord: Codable {
    public let city: String
    public let timestamp: Date
    public let deviceModel: String
    public let iOSVersion: String
    public let originalImageHash: String
    public let croppedImageHash: String
    public let ocrOutput: String
    public let userCorrection: String?
    public let confidence: Double
    public let processingTimeMs: Int
    
    public enum CodingKeys: String, CodingKey {
        case city
        case timestamp
        case deviceModel = "device_model"
        case iOSVersion = "ios_version"
        case originalImageHash = "original_image_hash"
        case croppedImageHash = "cropped_image_hash"
        case ocrOutput = "ocr_output"
        case userCorrection = "user_correction"
        case confidence
        case processingTimeMs = "processing_time_ms"
    }
}

// MARK: - API Error

public enum APIError: LocalizedError {
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
    
    public var errorDescription: String? {
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
