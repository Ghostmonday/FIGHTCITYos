//
//  CameraManager.swift
//  FightCityiOS
//
//  AVFoundation camera control with exposure, focus, torch, and stabilization
//

import AVFoundation
import UIKit
import VisionKit
import FightCityFoundation

/// APPLE INTELLIGENCE: Provide real-time frame guidance overlays via Live Text
/// APPLE INTELLIGENCE: Integrate with DocumentScanCoordinator for intelligent capture

/// Manages camera capture with full control over exposure, focus, torch, and stabilization
public actor CameraManager: NSObject {
    // MARK: - Published State
    
    private(set) var isAuthorized = false
    private(set) var isSessionRunning = false
    private(set) var currentCameraPosition: AVCaptureDevice.Position = .back
    
    // MARK: - Capture Session
    
    private let captureSession = AVCaptureSession()
    private var photoOutput: AVCapturePhotoOutput?
    private var videoOutput: AVCaptureVideoDataOutput?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    // MARK: - Device Configuration
    
    private var currentDevice: AVCaptureDevice? {
        AVCaptureDevice.default(
            .builtInWideAngleCamera,
            for: .video,
            position: currentCameraPosition
        )
    }
    
    private var torchLevel: Float = 0.0
    
    // MARK: - Configuration
    
    private let config: iOSAppConfig
    
    public init(config: iOSAppConfig = .shared) {
        self.config = config
        super.init()
    }
    
    // MARK: - Authorization
    
    public func requestAuthorization() async -> Bool {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch status {
        case .authorized:
            isAuthorized = true
            return true
        case .notDetermined:
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            isAuthorized = granted
            return granted
        default:
            isAuthorized = false
            return false
        }
    }
    
    // MARK: - Session Setup
    
    public func setupSession() async throws {
        guard isAuthorized else {
            throw CameraError.notAuthorized
        }
        
        captureSession.beginConfiguration()
        captureSession.sessionPreset = .photo
        
        // Add video input
        guard let device = currentDevice,
              let videoInput = try? AVCaptureDeviceInput(device: device) else {
            throw CameraError.deviceUnavailable
        }
        
        if captureSession.inputs.isEmpty {
            captureSession.addInput(videoInput)
        }
        
        // Add photo output
        let photoOutput = AVCapturePhotoOutput()
        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
            self.photoOutput = photoOutput
        }
        
        // Add video output for frame analysis
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "com.fightcitytickets.video"))
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
            self.videoOutput = videoOutput
        }
        
        // Configure for high quality
        // Note: Video stabilization is configured via AVCapturePhotoSettings, not connection
        
        captureSession.commitConfiguration()
    }
    
    public func startSession() async {
        guard !captureSession.isRunning else { return }
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.startRunning()
            Task { [weak self] in
                await self?.updateSessionState()
            }
        }
    }
    
    public func stopSession() async {
        guard captureSession.isRunning else { return }
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.stopRunning()
            Task { [weak self] in
                await self?.updateSessionState()
            }
        }
    }
    
    private func updateSessionState() {
        isSessionRunning = captureSession.isRunning
    }
    
    // MARK: - Camera Controls
    
    func switchCamera() throws {
        guard isSessionRunning else { return }
        
        captureSession.beginConfiguration()
        
        // Remove current input
        if let currentInput = captureSession.inputs.compactMap({ $0 as? AVCaptureDeviceInput }).first {
            captureSession.removeInput(currentInput)
        }
        
        // Toggle camera position
        currentCameraPosition = currentCameraPosition == .back ? .front : .back
        
        // Add new input
        guard let newDevice = currentDevice,
              let newInput = try? AVCaptureDeviceInput(device: newDevice) else {
            captureSession.commitConfiguration()
            throw CameraError.deviceUnavailable
        }
        
        captureSession.addInput(newInput)
        captureSession.commitConfiguration()
    }
    
    // MARK: - Focus & Exposure
    
    func focus(at point: CGPoint) async throws {
        guard let device = currentDevice,
              device.isFocusModeSupported(.continuousAutoFocus) else {
            return
        }
        
        try device.lockForConfiguration()
        device.focusPointOfInterest = point
        device.focusMode = .continuousAutoFocus
        device.unlockForConfiguration()
    }
    
    func lockExposure(at point: CGPoint) async throws {
        guard let device = currentDevice,
              device.isExposureModeSupported(.continuousAutoExposure) else {
            return
        }
        
        try device.lockForConfiguration()
        device.exposurePointOfInterest = point
        device.exposureMode = .continuousAutoExposure
        device.unlockForConfiguration()
    }
    
    // MARK: - Torch Control
    
    func setTorch(level: Float) async throws {
        guard let device = currentDevice,
              device.hasTorch else {
            throw CameraError.torchUnavailable
        }
        
        let clampedLevel = max(0, min(level, 1))
        
        try device.lockForConfiguration()
        device.torchMode = clampedLevel > 0 ? .on : .off
        if clampedLevel > 0 {
            try device.setTorchModeOn(level: clampedLevel)
        }
        torchLevel = clampedLevel
        device.unlockForConfiguration()
    }
    
    func toggleTorch() async throws {
        let newLevel: Float = torchLevel > 0 ? 0 : 1
        try await setTorch(level: newLevel)
    }
    
    // MARK: - Zoom
    
    func setZoom(_ zoomFactor: CGFloat) async throws {
        guard let device = currentDevice else { return }
        
        let maxZoom = device.activeFormat.videoMaxZoomFactor
        let clampedZoom = max(1, min(zoomFactor, maxZoom))
        
        try device.lockForConfiguration()
        device.videoZoomFactor = clampedZoom
        device.unlockForConfiguration()
    }
    
    // MARK: - Capture
    
    public func capturePhoto() async throws -> Data? {
        guard let photoOutput = photoOutput else {
            throw CameraError.outputUnavailable
        }
        
        let settings = AVCapturePhotoSettings()
        settings.flashMode = torchLevel > 0 ? .on : .off
        
        return try await withCheckedThrowingContinuation { continuation in
            let delegate = PhotoCaptureDelegate { result in
                continuation.resume(with: result)
            }
            photoOutput.capturePhoto(with: settings, delegate: delegate)
        }
    }
    
    // MARK: - Document Scanner Capture
    
    /// Capture using VisionKit Document Scanner with fallback to traditional camera
    /// - Parameters:
    ///   - viewController: The view controller to present the scanner from
    ///   - coordinator: The document scanner coordinator to use
    /// - Returns: True if document scanner was used, false if fallback to traditional camera
    /// - Note: Requires iOS 16.0+
    @available(iOS 16.0, *)
    public func captureWithDocumentScanner(from viewController: UIViewController, coordinator: DocumentScanCoordinator) async -> Bool {
        // Check if we should use document scanner
        if DocumentScanCoordinator.shouldUseDocumentScanner() {
            // Use VisionKit Document Scanner
            coordinator.presentScanner(from: viewController)
            return true
        } else {
            // Fallback to traditional camera capture
            print("Document scanner not available, falling back to traditional camera")
            
            // Stop current session if running
            if isSessionRunning {
                await stopSession()
            }
            
            do {
                // Setup and start session for fallback capture
                try await setupSession()
                await startSession()
                
                // Wait a moment for camera to stabilize
                try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
                
                // Try to capture photo
                guard let imageData = try await capturePhoto() else {
                    throw CameraError.captureFailed
                }
                
                // Stop session after capture
                await stopSession()
                
                // Create a mock scan result to match the document scanner interface
                let mockImage = UIImage(data: imageData)!
                let scanResult = DocumentScanResult(
                    image: mockImage,
                    pageIndex: 0,
                    totalPages: 1,
                    processingTime: 0,
                    enhancementApplied: false,
                    scanQuality: .medium
                )
                
                // Notify delegate with success
                coordinator.delegate?.documentScanCoordinator(coordinator, didFinishWith: .success(scanResult))
                return false
                
            } catch {
                // Stop session on error
                await stopSession()
                
                // Notify delegate with error
                if let cameraError = error as? CameraError {
                    let documentError = DocumentScanError.scanFailed(cameraError)
                    coordinator.delegate?.documentScanCoordinator(coordinator, didFailWith: documentError)
                } else {
                    let documentError = DocumentScanError.scanFailed(error)
                    coordinator.delegate?.documentScanCoordinator(coordinator, didFailWith: documentError)
                }
                return false
            }
        }
    }
    
    /// Check if document scanner is recommended for current device/configuration
    /// - Note: Requires iOS 16.0+
    @available(iOS 16.0, *)
    public static func isDocumentScannerRecommended() -> Bool {
        return DocumentScanCoordinator.shouldUseDocumentScanner()
    }
    
    // MARK: - Image Processing
    
    func processImage(_ imageData: Data) async throws -> (UIImage, CIImage) {
        guard let image = UIImage(data: imageData) else {
            throw CameraError.invalidImage
        }
        
        guard let ciImage = CIImage(image: image) else {
            throw CameraError.invalidImage
        }
        return (image, ciImage)
    }
    
    // MARK: - Helper Methods
    
    func convertToCIImage(_ uiImage: UIImage) -> CIImage? {
        CIImage(image: uiImage)
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    public nonisolated func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        // This is called on the video queue for frame analysis
        // Can be used for live preview analysis if needed
    }
}

// MARK: - Photo Capture Delegate

private class PhotoCaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate {
    private let completion: (Result<Data?, Error>) -> Void
    
    init(completion: @escaping (Result<Data?, Error>) -> Void) {
        self.completion = completion
    }
    
    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        if let error = error {
            completion(.failure(error))
            return
        }
        completion(.success(photo.fileDataRepresentation()))
    }
}

// MARK: - Camera Error

public enum CameraError: LocalizedError {
    case notAuthorized
    case deviceUnavailable
    case outputUnavailable
    case torchUnavailable
    case invalidImage
    case captureFailed
    
    public var errorDescription: String? {
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
        }
    }
}

// MARK: - iOS App Configuration

/// iOS-specific app configuration
public struct iOSAppConfig {
    public static let shared = iOSAppConfig()
    
    public let apiBaseURL: URL
    public let telemetryEnabled: Bool
    public let telemetryBatchSize: Int
    public let telemetryMaxAge: TimeInterval
    public let offlineQueueMaxSize: Int
    public let maxRetryAttempts: Int
    public let retryBackoffMultiplier: Double
    public let retryMaxBackoff: TimeInterval
    
    private init() {
        // Default configuration - can be overridden by app
        self.apiBaseURL = URL(string: "https://api.fightcitytickets.com")!
        self.telemetryEnabled = false
        self.telemetryBatchSize = 10
        self.telemetryMaxAge = 3600
        self.offlineQueueMaxSize = 100
        self.maxRetryAttempts = 3
        self.retryBackoffMultiplier = 2.0
        self.retryMaxBackoff = 300.0
    }
}
