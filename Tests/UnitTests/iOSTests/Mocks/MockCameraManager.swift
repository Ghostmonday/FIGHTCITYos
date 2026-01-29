//
//  MockCameraManager.swift
//  FightCityiOSTests
//
//  Mock implementation of CameraManager protocol for testing
//

import AVFoundation
import UIKit
@testable import FightCityiOS

/// Mock camera manager for unit testing
final class MockCameraManager: CameraManagerProtocol {
    
    // MARK: - Properties
    
    var isAuthorized: Bool = true
    var isSessionRunning: Bool = false
    var currentCameraPosition: AVCaptureDevice.Position = .back
    
    // Configurable behavior
    var shouldFailAuthorization: Bool = false
    var shouldFailCapture: Bool = false
    var shouldFailSessionSetup: Bool = false
    var captureDelay: TimeInterval = 0
    
    // Captured calls
    var capturePhotoCalled: Bool = false
    var switchCameraCalled: Bool = false
    var focusCalled: Bool = false
    var torchCalled: Bool = false
    
    // Mock data
    var mockPhotoData: Data?
    var mockError: CameraError?
    
    // MARK: - Initialization
    
    init(
        isAuthorized: Bool = true,
        mockPhotoData: Data? = nil
    ) {
        self.isAuthorized = isAuthorized
        self.mockPhotoData = mockPhotoData
    }
    
    // MARK: - Authorization
    
    func requestAuthorization() async -> Bool {
        if shouldFailAuthorization {
            isAuthorized = false
            return false
        }
        isAuthorized = true
        return true
    }
    
    // MARK: - Session Setup
    
    func setupSession() throws {
        if shouldFailSessionSetup {
            throw CameraError.deviceUnavailable
        }
        isSessionRunning = true
    }
    
    func startSession() {
        isSessionRunning = true
    }
    
    func stopSession() {
        isSessionRunning = false
    }
    
    // MARK: - Camera Controls
    
    func switchCamera() throws {
        guard isSessionRunning else {
            throw CameraError.deviceUnavailable
        }
        switchCameraCalled = true
        currentCameraPosition = currentCameraPosition == .back ? .front : .back
    }
    
    func focus(at point: CGPoint) async throws {
        guard isAuthorized else {
            throw CameraError.notAuthorized
        }
        focusCalled = true
    }
    
    func setTorch(level: Float) async throws {
        guard isAuthorized else {
            throw CameraError.notAuthorized
        }
        torchCalled = true
    }
    
    // MARK: - Capture
    
    func capturePhoto() async throws -> Data? {
        capturePhotoCalled = true
        
        if shouldFailCapture {
            throw CameraError.captureFailed
        }
        
        // Simulate capture delay if configured
        if captureDelay > 0 {
            try await Task.sleep(nanoseconds: UInt64(captureDelay * 1_000_000_000))
        }
        
        // Return mock data or generate placeholder
        if let data = mockPhotoData {
            return data
        }
        
        // Generate a 1x1 red pixel JPEG as placeholder
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 1, height: 1))
        let image = renderer.image { context in
            UIColor.red.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        }
        return image.jpegData(compressionQuality: 1.0)
    }
    
    // MARK: - Image Processing
    
    func processImage(_ imageData: Data) async throws -> (UIImage, CIImage) {
        guard let image = UIImage(data: imageData),
              let ciImage = CIImage(image: image) else {
            throw CameraError.invalidImage
        }
        return (image, ciImage)
    }
    
    // MARK: - Test Helpers
    
    func resetCalls() {
        capturePhotoCalled = false
        switchCameraCalled = false
        focusCalled = false
        torchCalled = false
    }
    
    func configureForSuccess() {
        shouldFailAuthorization = false
        shouldFailCapture = false
        shouldFailSessionSetup = false
    }
    
    func configureForFailure(error: CameraError) {
        mockError = error
        switch error {
        case .notAuthorized:
            shouldFailAuthorization = true
            isAuthorized = false
        case .captureFailed:
            shouldFailCapture = true
        case .deviceUnavailable:
            shouldFailSessionSetup = true
        default:
            break
        }
    }
}

// MARK: - CameraManager Protocol

/// Protocol defining camera manager interface for dependency injection
public protocol CameraManagerProtocol {
    var isAuthorized: Bool { get }
    var isSessionRunning: Bool { get }
    var currentCameraPosition: AVCaptureDevice.Position { get }
    
    func requestAuthorization() async -> Bool
    func setupSession() throws
    func startSession()
    func stopSession()
    func switchCamera() throws
    func focus(at point: CGPoint) async throws
    func setTorch(level: Float) async throws
    func capturePhoto() async throws -> Data?
    func processImage(_ imageData: Data) async throws -> (UIImage, CIImage)
}
