//
//  LobService.swift
//  FightCityFoundation
//
//  Lob API client for CERTIFIED MAIL ONLY letter mailing
//
//  ⚠️ BLOCKED: Requires Lob API Documentation
//  This is a stub implementation until API docs are provided.
//

import Foundation

// MARK: - Lob API Error

public enum LobAPIError: LocalizedError {
    case networkError(String)
    case apiError(statusCode: Int, message: String)
    case encodingError
    case invalidResponse
    
    public var errorDescription: String? {
        switch self {
        case .networkError(let message):
            return "Network error: \(message)"
        case .apiError(let code, let message):
            return "API error (\(code)): \(message)"
        case .encodingError:
            return "Failed to encode request data"
        case .invalidResponse:
            return "Invalid response from server"
        }
    }
}

// MARK: - Lob Address

public struct LobAddress: Codable, Equatable {
    public let name: String?
    public let addressLine1: String
    public let addressLine2: String?
    public let city: String
    public let state: String
    public let zip: String
    public let country: String
    
    public init(
        name: String? = nil,
        addressLine1: String,
        addressLine2: String? = nil,
        city: String,
        state: String,
        zip: String,
        country: String = "US"
    ) {
        self.name = name
        self.addressLine1 = addressLine1
        self.addressLine2 = addressLine2
        self.city = city
        self.state = state
        self.zip = zip
        self.country = country
    }
}

// MARK: - Lob Service
// Note: LobLetterResponse, LobTrackingEvent, and LobThumbnail are defined in LobModels.swift

/// Lob API service for sending CERTIFIED MAIL ONLY letters via backend proxy
///
/// ⚠️ CRITICAL REQUIREMENTS:
/// - ALL requests MUST use certified mail with return receipt
/// - NO regular mail option
/// - NO fallback to regular mail
/// - Certified mail parameters are hardcoded
/// - API key stored on backend proxy (never on device)
public actor LobService {
    public static let shared = LobService()
    
    private let backendURL: String
    
    private init() {
        // Backend proxy URL - API key stored server-side
        // TODO: Configure via AppConfig or environment variable
        // AUDIT: Inject this URL via AppConfig or dependency injection so it's testable and can be
        // configured per environment (including App Store review builds). Avoid hardcoded URLs.
        #if DEBUG
        self.backendURL = "http://localhost:5000"
        #else
        self.backendURL = "https://api.fightcitytickets.com"
        #endif
    }
    
    /// Configure the backend proxy URL (call before first use)
    public func configure(backendURL: String) {
        // Note: This is a workaround - ideally URL should be passed via dependency injection
        // For now, URL is set in init() based on build configuration
        // AUDIT: Implement this so tests and App Store review can point to staging or prod without
        // modifying code. Prefer dependency injection in the initializer.
    }
    
    /// Sends a letter via backend proxy using CERTIFIED MAIL WITH RETURN RECEIPT ONLY
    ///
    /// **CRITICAL**: This method MUST ONLY send certified mail with return receipt.
    /// NO regular mail option, NO fallback to regular mail.
    /// If implementation allows regular mail, that's a bug.
    ///
    /// - Parameters:
    ///   - to: Recipient address (city appeal address)
    ///   - from: Return address (user's address)
    ///   - pdfData: PDF data of the appeal letter
    ///   - description: Description of the letter
    /// - Returns: Lob letter response with tracking information
    /// - Throws: LobAPIError if request fails
    public func sendCertifiedLetter(
        to: LobAddress,
        from: LobAddress,
        pdfData: Data,
        description: String
    ) async throws -> LobLetterResponse {
        // CRITICAL: This method MUST ONLY send certified mail with return receipt
        // NO regular mail option, NO fallback to regular mail
        
        // Convert PDF to base64
        let pdfBase64 = pdfData.base64EncodedString()
        
        // Build request payload for backend proxy
        let payload: [String: Any] = [
            "to": [
                "name": to.name ?? "",
                "address_line1": to.addressLine1,
                "address_line2": to.addressLine2 ?? "",
                "city": to.city,
                "state": to.state,
                "zip": to.zip
            ],
            "from": [
                "name": from.name ?? "",
                "address_line1": from.addressLine1,
                "address_line2": from.addressLine2 ?? "",
                "city": from.city,
                "state": from.state,
                "zip": from.zip
            ],
            "pdfBase64": pdfBase64,
            "description": description
        ]
        
        // Call backend proxy
        guard let url = URL(string: "\(backendURL)/api/mail/send-certified") else {
            throw LobAPIError.networkError("Invalid backend URL")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 60 // Letter creation can take time
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        } catch {
            throw LobAPIError.encodingError
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw LobAPIError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            let errorBody = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw LobAPIError.apiError(statusCode: httpResponse.statusCode, message: errorBody)
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(LobLetterResponse.self, from: data)
    }
    
    /// Checks the status of a previously sent certified mail letter
    ///
    /// - Parameter letterId: The Lob letter ID
    /// - Returns: Updated letter response with current status and tracking events
    public func checkLetterStatus(_ letterId: String) async throws -> LobLetterResponse {
        guard let url = URL(string: "\(backendURL)/api/mail/status/\(letterId)") else {
            throw LobAPIError.networkError("Invalid backend URL")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 30
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw LobAPIError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            let errorBody = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw LobAPIError.apiError(statusCode: httpResponse.statusCode, message: errorBody)
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(LobLetterResponse.self, from: data)
    }
    
    // DO NOT create a sendRegularLetter() method - certified mail only
    // DO NOT create a sendLetter() method with mail type parameter - certified mail only
    // ONLY sendCertifiedLetter() exists - this enforces certified mail only
}
