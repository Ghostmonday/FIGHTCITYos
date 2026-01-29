//
//  AuthManager.swift
//  FightCityFoundation
//
//  Secure token storage using Keychain
//

import Foundation
import Security

/// Manages authentication tokens securely using Keychain
public final class AuthManager {
    public static let shared = AuthManager()
    
    private let keychain = KeychainService.shared
    
    private enum Keys {
        static let accessToken = "access_token"
        static let refreshToken = "refresh_token"
        static let tokenExpiry = "token_expiry"
        static let userId = "user_id"
        static let userEmail = "user_email"
    }
    
    private init() {}
    
    // MARK: - Token Management
    
    public func saveTokens(accessToken: String, refreshToken: String?, expiry: Date?) {
        keychain.save(Keys.accessToken, value: accessToken)
        if let refreshToken = refreshToken {
            keychain.save(Keys.refreshToken, value: refreshToken)
        }
        if let expiry = expiry {
            keychain.save(Keys.tokenExpiry, value: String(Int(expiry.timeIntervalSince1970)))
        }
    }
    
    public func getAccessToken() -> String? {
        keychain.load(Keys.accessToken)
    }
    
    public func getRefreshToken() -> String? {
        keychain.load(Keys.refreshToken)
    }
    
    public func getTokenExpiry() -> Date? {
        guard let timestampString = keychain.load(Keys.tokenExpiry),
              let timestamp = Double(timestampString) else {
            return nil
        }
        return Date(timeIntervalSince1970: timestamp)
    }
    
    public func isTokenValid() -> Bool {
        guard let _ = getAccessToken() else { return false }
        if let expiry = getTokenExpiry() {
            return expiry > Date()
        }
        return true // No expiry means valid
    }
    
    public func clearTokens() {
        keychain.delete(Keys.accessToken)
        keychain.delete(Keys.refreshToken)
        keychain.delete(Keys.tokenExpiry)
        keychain.delete(Keys.userId)
        keychain.delete(Keys.userEmail)
    }
    
    // MARK: - User Info
    
    public func saveUserId(_ userId: String) {
        keychain.save(Keys.userId, value: userId)
    }
    
    public func getUserId() -> String? {
        keychain.load(Keys.userId)
    }
    
    public func saveUserEmail(_ email: String) {
        keychain.save(Keys.userEmail, value: email)
    }
    
    public func getUserEmail() -> String? {
        keychain.load(Keys.userEmail)
    }
}

// MARK: - Keychain Service

/// Low-level Keychain wrapper
public final class KeychainService {
    public static let shared = KeychainService()
    
    private let serviceName = "com.fightcitytickets.app"
    
    private init() {}
    
    public func save(_ key: String, value: String) {
        guard let data = value.data(using: .utf8) else { return }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        
        // Delete existing item first
        SecItemDelete(query as CFDictionary)
        
        // Add new item
        let status = SecItemAdd(query as CFDictionary, nil)
        if status != errSecSuccess {
            print("Keychain save error: \(status)")
        }
    }
    
    public func load(_ key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let value = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return value
    }
    
    public func delete(_ key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key
        ]
        
        SecItemDelete(query as CFDictionary)
    }
    
    public func deleteAll() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName
        ]
        
        SecItemDelete(query as CFDictionary)
    }
}
