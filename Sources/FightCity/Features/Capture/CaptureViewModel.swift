//
//  CaptureViewModel.swift
//  FightCity
//
//  View model for camera capture and OCR processing
//

import SwiftUI
import Combine
import AVFoundation
import Vision
import FightCityiOS
import FightCityFoundation

@MainActor
public final class CaptureViewModel: ObservableObject {
    // MARK: - Published State
    
    @Published public var processingState: ProcessingState = .idle
    @Published public var captureResult: CaptureResult?
    @Published public var qualityWarning: String?
    @Published public var showManualEntry = false
    @Published public var manualCitationNumber = ""
    
    // MARK: - Dependencies
    
    private let cameraManager: CameraManager
    private let ocrEngine = OCREngine()
    private let preprocessor = OCRPreprocessor()
    private let parsingEngine = OCRParsingEngine()
    private let confidenceScorer = ConfidenceScorer()
    private let frameAnalyzer = FrameQualityAnalyzer()
    private let apiClient = APIClient.shared
    private let config: AppConfig
    
    // MARK: - Private State
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    public init(config: AppConfig = .shared) {
        self.config = config
        self.cameraManager = CameraManager(config: iOSAppConfig.shared)
    }
    
    // MARK: - Authorization
    
    public func requestCameraAuthorization() async {
        let granted = await cameraManager.requestAuthorization()
        if granted {
            try? await setupCamera()
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
        
        // Preprocess for OCR
        let processedImage: UIImage
        do {
            processedImage = try await preprocessor.preprocess(image)
        } catch {
            processedImage = image
        }
        
        // Perform OCR
        let ocrResult: OCREngine.RecognitionResult
        do {
            ocrResult = try await ocrEngine.recognizeText(in: processedImage)
        } catch {
            return CaptureResult(
                originalImageData: data,
                croppedImageData: processedImage.pngData(),
                rawText: "",
                confidence: 0,
                processingTimeMs: Int(Date().timeIntervalSince(startTime) * 1000)
            )
        }
        
        // Parse citation number
        let parsingResult = parsingEngine.parse(ocrResult.text)
        
        // Calculate confidence
        let scoreResult = confidenceScorer.score(
            rawText: ocrResult.text,
            observations: ocrResult.observations,
            matchedPattern: parsingResult.matchedPattern
        )
        
        // Validate with API if we have a citation number
        var citation: Citation?
        if let citationNumber = parsingResult.citationNumber {
            citation = await validateCitation(citationNumber, cityId: parsingResult.cityId)
        }
        
        let processingTimeMs = Int(Date().timeIntervalSince(startTime) * 1000)
        
        return CaptureResult(
            originalImageData: data,
            croppedImageData: processedImage.pngData(),
            rawText: ocrResult.text,
            extractedCitationNumber: citation?.citationNumber ?? parsingResult.citationNumber,
            extractedCityId: citation?.cityId ?? parsingResult.cityId,
            extractedDate: citation?.violationDate,
            confidence: scoreResult.overallConfidence,
            processingTimeMs: processingTimeMs,
            observations: [:]
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
