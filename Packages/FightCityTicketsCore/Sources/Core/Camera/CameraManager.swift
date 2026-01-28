//
//  CameraManager.swift
//  FightCityTicketsCore
//
//  Camera abstraction protocol for cross-platform testing
//

import Foundation

/// Camera error types
public enum CameraError: Error, Sendable {
    case notAuthorized
    case deviceUnavailable
    case outputUnavailable
    case torchUnavailable
    case invalidImage
    case captureFailed
    case notSupported
    
    public var message: String {
        switch self {
        case .notAuthorized:
            return "Camera access not authorized"
        case .deviceUnavailable:
            return "Camera device unavailable"
        case .outputUnavailable:
            return "Camera output unavailable"
        case .torchUnavailable:
            return "Torch not available on this device"
        case .invalidImage:
            return "Invalid image data"
        case .captureFailed:
            return "Photo capture failed"
        case .notSupported:
            return "Camera not supported on this platform"
        }
    }
}

/// Camera position
public enum CameraPosition: Sendable {
    case back
    case front
    
    public var isBack: Bool {
        self == .back
    }
    
    public var isFront: Bool {
        self == .front
    }
}

/// Protocol for camera operations - enables mocking on Linux
public protocol CameraManagerProtocol: Sendable {
    /// Request camera authorization
    func requestAuthorization() async throws -> Bool
    
    /// Check if camera is authorized
    var isAuthorized: Bool { get }
    
    /// Check if session is running
    var isSessionRunning: Bool { get }
    
    /// Current camera position
    var currentPosition: CameraPosition { get }
    
    /// Setup capture session
    func setupSession() async throws
    
    /// Start capture session
    func startSession() async throws
    
    /// Stop capture session
    func stopSession() async throws
    
    /// Capture photo
    func capturePhoto() async throws -> Data
    
    /// Switch camera position
    func switchCamera() async throws
    
    /// Set zoom factor
    func setZoom(_ factor: Float) async throws
    
    /// Toggle torch
    func toggleTorch() async throws
    
    /// Set torch level (0.0 to 1.0)
    func setTorch(level: Float) async throws
}

/// Default implementations for Linux/macOS testing
public extension CameraManagerProtocol {
    var isAuthorized: Bool { false }
    var isSessionRunning: Bool { false }
    var currentPosition: CameraPosition { .back }
    
    func requestAuthorization() async throws -> Bool {
        throw CameraError.notSupported
    }
    
    func setupSession() async throws {
        throw CameraError.notSupported
    }
    
    func startSession() async throws {
        throw CameraError.notSupported
    }
    
    func stopSession() async throws {
        throw CameraError.notSupported
    }
    
    func capturePhoto() async throws -> Data {
        throw CameraError.notSupported
    }
    
    func switchCamera() async throws {
        throw CameraError.notSupported
    }
    
    func setZoom(_ factor: Float) async throws {
        throw CameraError.notSupported
    }
    
    func toggleTorch() async throws {
        throw CameraError.notSupported
    }
    
    func setTorch(level: Float) async throws {
        throw CameraError.notSupported
    }
}

/// Mock camera manager for testing
public actor MockCameraManager: CameraManagerProtocol {
    public var isAuthorized: Bool = true
    public var isSessionRunning: Bool = false
    public var currentPosition: CameraPosition = .back
    public var torchLevel: Float = 0.0
    public var capturedImages: [Data] = []
    public var shouldFailCapture: Bool = false
    public var authorizationGranted: Bool = true
    
    public init() {}
    
    public func requestAuthorization() async throws -> Bool {
        authorizationGranted
    }
    
    public func setupSession() async throws {
        guard authorizationGranted else {
            throw CameraError.notAuthorized
        }
    }
    
    public func startSession() async throws {
        guard authorizationGranted else {
            throw CameraError.notAuthorized
        }
        isSessionRunning = true
    }
    
    public func stopSession() async throws {
        isSessionRunning = false
    }
    
    public func capturePhoto() async throws -> Data {
        guard !shouldFailCapture else {
            throw CameraError.captureFailed
        }
        
        // Return a placeholder data
        let placeholder = "mock_image_data_\(Date().timeIntervalSince1970)".data(using: .utf8)!
        capturedImages.append(placeholder)
        return placeholder
    }
    
    public func switchCamera() async throws {
        currentPosition = currentPosition.isBack ? .front : .back
    }
    
    public func setZoom(_ factor: Float) async throws {
        // No-op for mock
    }
    
    public func toggleTorch() async throws {
        torchLevel = torchLevel > 0 ? 0 : 1
    }
    
    public func setTorch(level: Float) async throws {
        torchLevel = max(0, min(level, 1))
    }
    
    /// Reset mock state
    public func reset() {
        isSessionRunning = false
        currentPosition = .back
        torchLevel = 0
        capturedImages = []
        shouldFailCapture = false
    }
}
