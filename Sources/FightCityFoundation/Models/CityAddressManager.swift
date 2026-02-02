//
//  CityAddressManager.swift
//  FightCityFoundation
//
//  Manager for city mailing addresses with caching and fallback support
//

import Foundation

/// Manages city mailing addresses with local caching and backend sync
public actor CityAddressManager {
    public static let shared = CityAddressManager()
    
    private var addresses: [String: CityMailingAddress] = [:]
    private let storage: UserDefaults
    private let storageKey = "city_mailing_addresses"
    
    private init() {
        self.storage = UserDefaults.standard
        loadCachedAddresses()
    }
    
    // MARK: - Public Methods
    
    /// Gets the mailing address for a city
    ///
    /// - Parameter cityId: The city identifier (e.g., "sf", "la", "nyc")
    /// - Returns: The city's mailing address
    /// - Throws: Error if address not found
    public func getMailingAddress(for cityId: String) async throws -> CityMailingAddress {
        // Check cache first
        if let cached = addresses[cityId] {
            return cached
        }
        
        // Try to fetch from backend (if available)
        // TODO: Implement backend fetch when endpoint is available
        // AUDIT: Implement backend fetch with caching + ETag to avoid stale addresses. This reduces
        // shipping outdated legal addresses, which is critical for App Store compliance and user trust.
        // let backendAddress = try await fetchFromBackend(cityId: cityId)
        // addresses[cityId] = backendAddress
        // saveCachedAddresses()
        // return backendAddress
        
        // Fallback to hardcoded addresses
        if let fallback = CityMailingAddress.fallbackAddresses[cityId] {
            addresses[cityId] = fallback
            saveCachedAddresses()
            return fallback
        }
        
        throw CityAddressError.addressNotFound(cityId: cityId)
    }
    
    /// Updates a city's mailing address (from scraper or backend)
    ///
    /// - Parameter address: The updated address
    public func updateAddress(_ address: CityMailingAddress) {
        addresses[address.cityId] = address
        saveCachedAddresses()
    }
    
    /// Verifies an address using Lob's verification API
    ///
    /// ⚠️ BLOCKED: Requires Lob API documentation for verification endpoint
    ///
    /// - Parameter address: The address to verify
    /// - Returns: True if address is valid
    /// - Throws: Error if verification fails
    public func verifyAddress(_ address: CityMailingAddress) async throws -> Bool {
        // TODO: Implement Lob address verification once API docs provided
        // AUDIT: Address verification should call the backend proxy (not Lob directly) to avoid exposing API
        // keys. Validate standardized address components and return detailed errors to the UI.
        // For now, assume addresses are valid if they have required fields
        return !address.addressLine1.isEmpty &&
               !address.city.isEmpty &&
               !address.state.isEmpty &&
               !address.zip.isEmpty
    }
    
    /// Clears all cached addresses (useful for testing or forced refresh)
    public func clearCache() {
        addresses.removeAll()
        storage.removeObject(forKey: storageKey)
    }
    
    // MARK: - Private Methods
    
    private func loadCachedAddresses() {
        guard let data = storage.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([String: CityMailingAddress].self, from: data) else {
            // Load fallback addresses if no cache
            addresses = CityMailingAddress.fallbackAddresses
            return
        }
        addresses = decoded
    }
    
    private func saveCachedAddresses() {
        guard let encoded = try? JSONEncoder().encode(addresses) else {
            return
        }
        storage.set(encoded, forKey: storageKey)
    }
}

// MARK: - City Address Error

public enum CityAddressError: LocalizedError {
    case addressNotFound(cityId: String)
    case invalidAddress
    case verificationFailed
    
    public var errorDescription: String? {
        switch self {
        case .addressNotFound(let cityId):
            return "Mailing address not found for city: \(cityId)"
        case .invalidAddress:
            return "Invalid address format"
        case .verificationFailed:
            return "Address verification failed"
        }
    }
}
