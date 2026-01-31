//
//  CaptureViewModel.swift
//  FightCity
//
//  View model for camera capture and OCR processing
//

import SwiftUI
import AVFoundation
import VisionKit
import FightCityiOS
import FightCityFoundation

/// APPLE INTELLIGENCE: Wire Document Scanner/Live Text into capture flow
/// APPLE INTELLIGENCE: Route OCR text through Core ML classifier prior to regex
/// APPLE INTELLIGENCE: Enable dictation UI for appeal writing

@MainActor
public final class CaptureViewModel: ObservableObject, DocumentScanCoordinatorDelegate {
    // MARK: - Published State
    
    @Published public var processingState: ProcessingState = .idle
    @Published public var captureResult: CaptureResult?
    @Published public var qualityWarning: String?
    @Published public var showManualEntry = false
    @Published public var manualCitationNumber = ""
    
    // MARK: - Dependencies
    
    private let cameraManager: CameraManager
    private let documentScanner = DocumentScanCoordinator()
    private let frameAnalyzer = FrameQualityAnalyzer()
    private let apiClient = APIClient.shared
    private let config: AppConfig
    
    // MARK: - Initialization
    
    public init(config: AppConfig = .shared) {
        self.config = config
        self.cameraManager = CameraManager(config: iOSAppConfig.shared)
        self.documentScanner.delegate = self
    }
    
    // MARK: - Authorization
    
    public func requestCameraAuthorization() async {
        let granted = await cameraManager.requestAuthorization()
        if granted {
            do {
                try await setupCamera()
            } catch {
                processingState = .error("Failed to setup camera: \(error.localizedDescription)")
            }
        }
    }
    
    public var isAuthorized: Bool {
        // Would check actual authorization status
        true
    }
    
    // MARK: - Camera Setup
    
    private func setupCamera() async throws {
        try await cameraManager.setupSession()
        await cameraManager.startSession()
    }
    
    public func stopCapture() async {
        await cameraManager.stopSession()
    }
    
    // MARK: - Capture
    
    public func capturePhoto() async {
        processingState = .capturing
        
        guard let cameraManager = await cameraManager else {
            processingState = .error("Camera not initialized")
            return
        }
        
        do {
            guard let imageData = try await cameraManager.capturePhoto() else {
                processingState = .error("Failed to capture image")
                return
            }
            
            processingState = .processing
            
            // Process the image
            let result = await processImage(data: imageData)
            captureResult = result
            processingState = .complete(result)
            
            // Navigate to confirmation
            if let result = captureResult {
                // Will be handled by coordinator
            }
        } catch {
            processingState = .error(error.localizedDescription)
        }
    }
    
    // MARK: - Document Scanner Capture
    
    /// Capture using VisionKit Document Scanner with automatic fallback
    /// - Parameter viewController: The view controller to present the scanner from
    /// - Note: Requires iOS 16.0+
    @available(iOS 16.0, *)
    public func captureWithDocumentScanner(from viewController: UIViewController) async {
        processingState = .capturing
        
        // Use CameraManager's integrated capture with fallback
        let usedDocumentScanner = await cameraManager.captureWithDocumentScanner(
            from: viewController, 
            coordinator: documentScanner
        )
        
        if usedDocumentScanner {
            print("Using VisionKit Document Scanner")
        } else {
            print("Using traditional camera as fallback")
        }
    }
    
    /// Check if document scanner is recommended for current device/configuration
    /// - Note: Requires iOS 16.0+
    @available(iOS 16.0, *)
    public func isDocumentScannerRecommended() -> Bool {
        return CameraManager.isDocumentScannerRecommended()
    }
    
    /// Legacy method for devices that don't support document scanner
    /// - Note: Automatically uses traditional camera on unsupported devices
    public func captureWithDocumentScannerLegacy(from viewController: UIViewController) async {
        if #available(iOS 16.0, *) {
            await captureWithDocumentScanner(from: viewController)
        } else {
            // Fallback to traditional camera capture for older iOS versions
            processingState = .capturing
            
            do {
                guard let imageData = try await cameraManager.capturePhoto() else {
                    processingState = .error("Failed to capture image")
                    return
                }
                
                processingState = .processing
                
                // Process the image
                let result = await processImage(data: imageData)
                captureResult = result
                processingState = .complete(result)
                
            } catch {
                processingState = .error(error.localizedDescription)
            }
        }
    }
    
    // MARK: - Utility Methods
    
    /// Check if document scanner is available on this device
    /// - Returns: True if VisionKit document scanner is available and enabled
    public func isDocumentScannerAvailable() -> Bool {
        guard #available(iOS 16.0, *) else {
            return false
        }
        return FeatureFlags.isVisionKitDocumentScannerEnabled && VNDocumentCameraViewController.isSupported
    }
    
    /// Get a user-friendly description of the capture method that will be used
    /// - Returns: Description of the recommended capture method
    public func getRecommendedCaptureMethod() -> String {
        if isDocumentScannerAvailable() {
            return "VisionKit Document Scanner (Auto-cropping & Enhancement)"
        } else {
            return "Traditional Camera"
        }
    }
    
    /// Get capture method recommendations for user interface
    /// - Returns: Tuple with recommended method and fallback information
    public func getCaptureMethodRecommendation() -> (primary: String, fallback: String, isRecommended: Bool) {
        let isAvailable = isDocumentScannerAvailable()
        
        if isAvailable {
            return (
                primary: "Document Scanner",
                fallback: "Traditional Camera",
                isRecommended: true
            )
        } else {
            return (
                primary: "Traditional Camera",
                fallback: "Manual Entry",
                isRecommended: false
            )
        }
    }
    
    // MARK: - Image Processing
    
    private func processImage(data: Data) async -> CaptureResult {
        let startTime = Date()
        
        guard let image = UIImage(data: data) else {
            return CaptureResult(
                originalImageData: data,
                rawText: "",
                confidence: 0,
                processingTimeMs: Int(Date().timeIntervalSince(startTime) * 1000)
            )
        }
        
        // Check image quality
        let qualityResult = frameAnalyzer.analyze(image)
        qualityWarning = qualityResult.warnings.isEmpty ? nil : qualityResult.feedbackMessage
        
        let processingTimeMs = Int(Date().timeIntervalSince(startTime) * 1000)
        
        // Return basic capture result without OCR processing
        return CaptureResult(
            originalImageData: data,
            rawText: "",
            confidence: 0,
            processingTimeMs: processingTimeMs
        )
    }
    
    // MARK: - API Validation
    
    private func validateCitation(_ citationNumber: String, cityId: String?) async -> Citation? {
        let request = CitationValidationRequest(
            citation_number: citationNumber,
            city_id: cityId
        )
        
        do {
            let response: CitationValidationResponse = try await apiClient.post(
                .validateCitation(request),
                body: request
            )
            return response.toCitation()
        } catch {
            return nil
        }
    }
    
    // MARK: - Manual Entry
    
    public func submitManualEntry() async -> CaptureResult? {
        guard !manualCitationNumber.isEmpty else { return nil }
        
        processingState = .processing
        
        let result = CaptureResult(
            rawText: manualCitationNumber,
            extractedCitationNumber: manualCitationNumber,
            confidence: 1.0,
            processingTimeMs: 0
        )
        
        captureResult = result
        processingState = .complete(result)
        showManualEntry = false
        
        return result
    }
    
    // MARK: - Reset
    
    public func reset() {
        processingState = .idle
        captureResult = nil
        qualityWarning = nil
        manualCitationNumber = ""
    }
    
    // MARK: - DocumentScanCoordinatorDelegate
    
    public func documentScanCoordinator(_ coordinator: DocumentScanCoordinator, didFinishWith result: DocumentScanResult.DocumentScanResultResult) {
        processingState = .processing
        
        switch result {
        case .success(let scanResult):
            Task {
                // Convert UIImage to Data for processing
                guard let imageData = scanResult.image.pngData() else {
                    processingState = .error("Failed to convert scanned image")
                    return
                }
                
                // Process the scanned image through our OCR pipeline
                let captureResult = await processImage(data: imageData)
                self.captureResult = captureResult
                processingState = .complete(captureResult)
            }
        case .failed(let error):
            processingState = .error(error.localizedDescription)
        }
    }
    
    public func documentScanCoordinatorDidCancel(_ coordinator: DocumentScanCoordinator) {
        processingState = .idle
    }
    
    public func documentScanCoordinator(_ coordinator: DocumentScanCoordinator, didFailWith error: DocumentScanError) {
        // Log the error and provide user feedback
        print("Document scan failed: \(error.localizedDescription)")
        
        // Provide specific error messages based on error type
        let errorMessage: String
        switch error {
        case .featureDisabled:
            errorMessage = "Document scanner is currently disabled. Please use the manual camera instead."
        case .unsupportedDevice:
            errorMessage = "Document scanning is not supported on this device."
        case .noPagesFound:
            errorMessage = "No document pages were detected. Please try again."
        case .imageProcessingFailed:
            errorMessage = "Failed to process the scanned document."
        case .scanFailed(let underlyingError):
            errorMessage = "Document scanning failed: \(underlyingError.localizedDescription)"
        }
        
        processingState = .error(errorMessage)
    }
}

// MARK: - Processing State

extension ProcessingState {
    var isProcessing: Bool {
        switch self {
        case .analyzing, .capturing, .processing:
            return true
        default:
            return false
        }
    }
}
