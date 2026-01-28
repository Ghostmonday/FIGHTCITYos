//
//  CaptureViewModel.swift
//  FightCityTickets
//
//  ViewModel for capture screen
//

import SwiftUI
import AVFoundation
import Combine

@MainActor
final class CaptureViewModel: ObservableObject {
    // MARK: - Published State
    
    @Published var isCameraAuthorized = false
    @Published var isProcessing = false
    @Published var isCapturing = false
    @Published var isTorchOn = false
    @Published var frameQuality: FrameQualityAnalyzer.AnalysisResult?
    @Published var captureResult: CaptureResult?
    @Published var showError = false
    @Published var errorMessage = ""
    
    // MARK: - Services
    
    let cameraManager = CameraManager()
    let preprocessor = OCRPreprocessor()
    let ocrEngine = OCREngine()
    let parser = OCRParsingEngine()
    let scorer = ConfidenceScorer()
    let analyzer = FrameQualityAnalyzer()
    
    var captureSession = AVCaptureSession()
    
    // MARK: - Lifecycle
    
    func onAppear() {
        Task {
            await setupCamera()
        }
    }
    
    func onDisappear() {
        Task {
            await cameraManager.stopSession()
        }
    }
    
    // MARK: - Camera Setup
    
    private func setupCamera() async {
        let authorized = await cameraManager.requestAuthorization()
        isCameraAuthorized = authorized
        
        guard authorized else { return }
        
        do {
            try await cameraManager.setupSession()
            await cameraManager.startSession()
        } catch {
            errorMessage = "Failed to setup camera: \(error.localizedDescription)"
            showError = true
        }
    }
    
    // MARK: - Torch Control
    
    func toggleTorch() async {
        do {
            try await cameraManager.setTorch(level: isTorchOn ? 0 : 1)
            isTorchOn.toggle()
        } catch {
            errorMessage = "Torch not available"
            showError = true
        }
    }
    
    // MARK: - Photo Capture
    
    func capturePhoto() {
        guard !isCapturing && !isProcessing else { return }
        
        Task {
            isCapturing = true
            
            do {
                guard let imageData = try await cameraManager.capturePhoto() else {
                    throw CameraError.captureFailed
                }
                
                await processCapture(imageData: imageData)
            } catch {
                errorMessage = "Capture failed: \(error.localizedDescription)"
                showError = true
            }
            
            isCapturing = false
        }
    }
    
    private func processCapture(imageData: Data) async {
        isProcessing = true
        
        // Create capture result
        var result = CaptureResult(
            originalImageData: imageData,
            rawText: ""
        )
        
        // Preprocess image
        guard let uiImage = UIImage(data: imageData) else {
            isProcessing = false
            return
        }
        
        // Analyze frame quality
        frameQuality = analyzer.analyze(uiImage)
        
        do {
            // Preprocess for OCR
            let preprocessedImage = try await preprocessor.preprocess(uiImage)
            
            // Perform OCR
            let ocrResult = try await ocrEngine.recognizeWithHighAccuracy(in: preprocessedImage)
            result.rawText = ocrResult.text
            
            // Parse citation
            let parseResult = parser.parse(ocrResult.text)
            result.extractedCitationNumber = parseResult.citationNumber
            result.extractedCityId = parseResult.cityId
            result.confidence = parseResult.confidence
            
            // Calculate final confidence
            let scoreResult = scorer.score(
                rawText: ocrResult.text,
                observations: ocrResult.observations,
                matchedPattern: parseResult.matchedPattern
            )
            
            result.confidence = scoreResult.overallConfidence
            result.processingTimeMs = Int(ocrResult.processingTime * 1000)
            
            // Check if we have a valid citation
            if result.hasValidCitation && scoreResult.level != .low {
                captureResult = result
                proceedToConfirmation()
            } else {
                // Show error or prompt for manual entry
                errorMessage = scoreResult.recommendation == .reject
                    ? "Could not read the ticket. Please try again or enter manually."
                    : "We couldn't read the citation number clearly. Please verify."
                showError = true
            }
            
        } catch {
            errorMessage = "Processing failed: \(error.localizedDescription)"
            showError = true
        }
        
        isProcessing = false
    }
    
    // MARK: - Navigation
    
    private func proceedToConfirmation() {
        guard let result = captureResult else { return }
        
        // Record telemetry if enabled
        TelemetryService.shared.record(
            captureResult: result,
            city: result.extractedCityId ?? "unknown"
        )
        
        // Navigate to confirmation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // Navigate via coordinator
        }
    }
    
    // MARK: - Manual Entry
    
    func handleManualEntry(_ citationNumber: String) {
        var result = CaptureResult(rawText: citationNumber)
        result.extractedCitationNumber = citationNumber
        
        // Try to detect city
        if let cityConfig = AppConfig.shared.cityConfig(for: citationNumber) {
            result.extractedCityId = cityConfig.id
        }
        
        result.confidence = 1.0 // Manual entry has full confidence
        captureResult = result
        
        proceedToConfirmation()
    }
}
