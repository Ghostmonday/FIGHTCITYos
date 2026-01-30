//
//  LiveTextHelper.swift
//  FightCityiOS
//
//  Real-time text analysis using VisionKit's Live Text capabilities
//

import VisionKit
import Vision
import CoreML
import UIKit
import FightCityFoundation

/// APPLE INTELLIGENCE: Enables real-time Live Text extraction from camera frames
/// APPLE INTELLIGENCE: Integration with ImageAnalyzer for Live Text support
/// APPLE INTELLIGENCE: Uses Vision framework for barcode/QR code recognition
/// APPLE INTELLIGENCE: Supports iOS 16+ with async/await concurrency

/// Protocol for Live Text analysis - enables mock testing
public protocol LiveTextHelperProtocol {
    /// Whether analyzer is available on device
    var isAnalyzerAvailable: Bool { get }
    
    /// Analyze image with custom options
    func analyzeImage(_ image: UIImage, options: ImageAnalyzer.Options?) async throws -> AnalysisResult
    /// Analyze image with default options
    func analyzeImage(_ image: UIImage) async throws -> AnalysisResult
    /// Analyze image with barcode detection
    func analyzeImage(_ image: UIImage, barcodeTypes: [BarcodeType]) async throws -> AnalysisResult
    /// Extract text from image
    func extractText(from image: UIImage) async throws -> String
    /// Extract barcodes from image
    func extractBarcodes(from image: UIImage, types: [BarcodeType]) async throws -> [BarcodeResult]
    /// Cancel ongoing analysis
    func cancelCurrentAnalysis()
}

/// Result of Live Text analysis
public struct AnalysisResult {
    /// Extracted text
    public let text: String
    /// Text observations with confidence and bounding boxes
    public let textObservations: [TextObservation]
    /// Barcode detection results
    public let barcodeResults: [BarcodeResult]
    /// Overall confidence score (0.0 - 1.0)
    public let overallConfidence: Double
    /// Processing time in seconds
    public let processingTime: TimeInterval
    /// Analysis metadata
    public let metadata: AnalysisMetadata
    
    public init(
        text: String,
        textObservations: [TextObservation],
        barcodeResults: [BarcodeResult],
        overallConfidence: Double,
        processingTime: TimeInterval,
        metadata: AnalysisMetadata
    ) {
        self.text = text
        self.textObservations = textObservations
        self.barcodeResults = barcodeResults
        self.overallConfidence = overallConfidence
        self.processingTime = processingTime
        self.metadata = metadata
    }
}

/// Observation for recognized text
public struct TextObservation {
    /// Recognized text string
    public let text: String
    /// Confidence score (0.0 - 1.0)
    public let confidence: Double
    /// Bounding box in normalized coordinates
    public let boundingBox: CGRect
    /// Alternative candidates
    public let candidates: [String]
    
    public init(text: String, confidence: Double, boundingBox: CGRect, candidates: [String]) {
        self.text = text
        self.confidence = confidence
        self.boundingBox = boundingBox
        self.candidates = candidates
    }
}

/// Result of barcode/QR code recognition
public struct BarcodeResult {
    /// Decoded barcode payload
    public let payload: String
    /// Barcode type
    public let type: BarcodeType
    /// Recognition confidence
    public let confidence: Double
    /// Bounding box
    public let boundingBox: CGRect
    /// Raw barcode data
    public let rawData: Data?
    
    public init(payload: String, type: BarcodeType, confidence: Double, boundingBox: CGRect, rawData: Data?) {
        self.payload = payload
        self.type = type
        self.confidence = confidence
        self.boundingBox = boundingBox
        self.rawData = rawData
    }
}

/// Supported barcode types
public enum BarcodeType: String, CaseIterable {
    case qrCode = "QR Code"
    case aztec = "Aztec"
    case code128 = "Code 128"
    case code39 = "Code 39"
    case code93 = "Code 93"
    case dataMatrix = "Data Matrix"
    case ean8 = "EAN-8"
    case ean13 = "EAN-13"
    case itf14 = "ITF-14"
    case pdf417 = "PDF417"
    case upce = "UPC-E"
    
    /// Convert to Vision barcode symbology
    var visionSymbology: VNBarcodeSymbology {
        switch self {
        case .qrCode: return .qr
        case .aztec: return .aztec
        case .code128: return .code128
        case .code39: return .code39
        case .code93: return .code93
        case .dataMatrix: return .dataMatrix
        case .ean8: return .ean8
        case .ean13: return .ean13
        case .itf14: return .itf14
        case .pdf417: return .pdf417
        case .upce: return .upce
        }
    }
}

/// Metadata about the analysis
public struct AnalysisMetadata {
    /// Original image size
    public let imageSize: CGSize
    /// Image orientation
    public let imageOrientation: UIImage.Orientation
    /// Analysis timestamp
    public let analysisDate: Date
    /// Whether device supports Live Text
    public let deviceSupportsLiveText: Bool
    /// Whether analysis was interrupted
    public let wasInterrupted: Bool
    
    public init(
        imageSize: CGSize,
        imageOrientation: UIImage.Orientation,
        analysisDate: Date,
        deviceSupportsLiveText: Bool,
        wasInterrupted: Bool = false
    ) {
        self.imageSize = imageSize
        self.imageOrientation = imageOrientation
        self.analysisDate = analysisDate
        self.deviceSupportsLiveText = deviceSupportsLiveText
        self.wasInterrupted = wasInterrupted
    }
}

/// Live Text helper service for real-time text analysis
public final class LiveTextHelper: LiveTextHelperProtocol {
    
    // MARK: - Properties
    
    /// Shared instance for app-wide usage
    public static let shared = LiveTextHelper()
    
    /// Image analyzer for Live Text (Apple Intelligence)
    private let analyzer: ImageAnalyzer?
    
    /// Current analysis task for cancellation
    private var currentTask: Task<AnalysisResult, Error>?
    
    /// Confidence scorer for integration with existing pipeline
    private let confidenceScorer: ConfidenceScorer
    
    /// Queue for analysis operations
    private let analysisQueue = DispatchQueue(label: "com.fightcity.livetext.analysis", qos: .userInitiated)
    
    /// Lock for thread safety
    private let lock = NSLock()
    
    // MARK: - Protocol Properties
    
    public var isAnalyzerAvailable: Bool {
        ImageAnalyzer.isAvailable
    }
    
    // MARK: - Initialization
    
    public init(confidenceScorer: ConfidenceScorer = ConfidenceScorer()) {
        self.confidenceScorer = confidenceScorer
        self.analyzer = ImageAnalyzer.isAvailable ? ImageAnalyzer() : nil
    }
    
    // MARK: - Public Methods
    
    /// Analyze image with custom options
    public func analyzeImage(_ image: UIImage, options: ImageAnalyzer.Options?) async throws -> AnalysisResult {
        // Check analyzer availability
        guard isAnalyzerAvailable else {
            throw LiveTextError.notSupportedOnDevice
        }
        
        // Validate image
        guard let cgImage = image.cgImage else {
            throw LiveTextError.invalidImage
        }
        
        let startTime = Date()
        
        // Cancel any ongoing analysis
        cancelCurrentAnalysis()
        
        return try await withCheckedThrowingContinuation { continuation in
            currentTask = Task { @MainActor in
                do {
                    let content: ImageAnalyzer.Content
                    if let options = options {
                        content = try await analyzer?.analyze(
                            cgImage,
                            orientation: image.imageOrientation,
                            options: options
                        ) ?? []
                    } else {
                        content = try await analyzer?.analyze(
                            cgImage,
                            orientation: image.imageOrientation
                        ) ?? []
                    }
                    
                    let result = await processAnalysisResult(
                        content,
                        image: image,
                        startTime: startTime
                    )
                    
                    if Task.isCancelled {
                        throw LiveTextError.cancelled
                    }
                    
                    continuation.resume(returning: result)
                } catch {
                    if Task.isCancelled {
                        continuation.resume(throwing: LiveTextError.cancelled)
                    } else {
                        continuation.resume(throwing: LiveTextError.analysisFailed(error))
                    }
                }
            }
        }
    }
    
    /// Analyze image with default options
    public func analyzeImage(_ image: UIImage) async throws -> AnalysisResult {
        try await analyzeImage(image, options: nil)
    }
    
    /// Analyze image with barcode detection
    public func analyzeImage(_ image: UIImage, barcodeTypes: [BarcodeType]) async throws -> AnalysisResult {
        var options = ImageAnalyzer.Options()
        options.recognitionLevel = .accurate
        
        let result = try await analyzeImage(image, options: options)
        
        // Perform barcode recognition if types specified
        let barcodes: [BarcodeResult]
        if !barcodeTypes.isEmpty {
            barcodes = try await extractBarcodes(from: image, types: barcodeTypes)
        } else {
            barcodes = []
        }
        
        return AnalysisResult(
            text: result.text,
            textObservations: result.textObservations,
            barcodeResults: barcodes,
            overallConfidence: result.overallConfidence,
            processingTime: result.processingTime,
            metadata: result.metadata
        )
    }
    
    /// Extract text from image using Live Text
    public func extractText(from image: UIImage) async throws -> String {
        let result = try await analyzeImage(image)
        return result.text
    }
    
    /// Extract barcodes from image using Vision
    public func extractBarcodes(from image: UIImage, types: [BarcodeType]) async throws -> [BarcodeResult] {
        guard let cgImage = image.cgImage else {
            throw LiveTextError.invalidImage
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let request = VNDetectBarcodesRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: LiveTextError.barcodeRecognitionFailed(error))
                    return
                }
                
                guard let observations = request.results as? [VNBarcodeObservation] else {
                    continuation.resume(returning: [])
                    return
                }
                
                // Filter by requested types
                let filteredObservations: [VNBarcodeObservation]
                if types.isEmpty {
                    filteredObservations = observations
                } else {
                    let symbologies = Set(types.map { $0.visionSymbology })
                    filteredObservations = observations.filter { symbologies.contains($0.symbology) }
                }
                
                let results = filteredObservations.map { observation in
                    BarcodeResult(
                        payload: observation.payloadStringValue ?? "",
                        type: Self.mapBarcodeType(observation.symbology),
                        confidence: Double(observation.confidence),
                        boundingBox: observation.boundingBox,
                        rawData: observation.rawPayloadData
                    )
                }
                
                continuation.resume(returning: results)
            }
            
            request.symbologies = types.map { $0.visionSymbology }
            
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: LiveTextError.barcodeRecognitionFailed(error))
            }
        }
    }
    
    /// Cancel ongoing analysis
    public func cancelCurrentAnalysis() {
        lock.lock()
        defer { lock.unlock() }
        
        currentTask?.cancel()
        currentTask = nil
    }
    
    // MARK: - Private Methods
    
    /// Process analysis result from ImageAnalyzer
    private func processAnalysisResult(
        _ content: ImageAnalyzer.Content,
        image: UIImage,
        startTime: Date
    ) async -> AnalysisResult {
        var textObservations: [TextObservation] = []
        var extractedText: [String] = []
        
        // Process recognized text observations
        if case let .text(recognizedTextObservations) = content {
            for observation in recognizedTextObservations {
                if let candidate = observation.topCandidates(1).first {
                    let candidates = observation.topCandidates(3).map { $0.string }
                    
                    let textObservation = TextObservation(
                        text: candidate.string,
                        confidence: Double(candidate.confidence),
                        boundingBox: observation.boundingBox,
                        candidates: candidates
                    )
                    textObservations.append(textObservation)
                    extractedText.append(candidate.string)
                }
            }
        }
        
        // Calculate confidence
        let averageConfidence: Double
        if !textObservations.isEmpty {
            averageConfidence = textObservations.reduce(0) { $0 + $1.confidence } / Double(textObservations.count)
        } else {
            averageConfidence = 0
        }
        
        let processingTime = Date().timeIntervalSince(startTime)
        let text = extractedText.joined(separator: "\n")
        
        let metadata = AnalysisMetadata(
            imageSize: image.size,
            imageOrientation: image.imageOrientation,
            analysisDate: Date(),
            deviceSupportsLiveText: isAnalyzerAvailable,
            wasInterrupted: false
        )
        
        return AnalysisResult(
            text: text,
            textObservations: textObservations,
            barcodeResults: [],
            overallConfidence: averageConfidence,
            processingTime: processingTime,
            metadata: metadata
        )
    }
    
    /// Map Vision barcode symbology to our type
    private static func mapBarcodeType(_ symbology: VNBarcodeSymbology) -> BarcodeType {
        switch symbology {
        case .qr: return .qrCode
        case .aztec: return .aztec
        case .code128: return .code128
        case .code39: return .code39
        case .code93: return .code93
        case .dataMatrix: return .dataMatrix
        case .ean8: return .ean8
        case .ean13: return .ean13
        case .itf14: return .itf14
        case .pdf417: return .pdf417
        case .upce: return .upce
        default: return .qrCode
        }
    }
}

// MARK: - Error Handling

/// Errors for Live Text operations
public enum LiveTextError: LocalizedError {
    case notSupportedOnDevice
    case invalidImage
    case analysisFailed(Error)
    case cancelled
    case barcodeRecognitionFailed(Error)
    case noTextFound
    case permissionDenied
    
    public var errorDescription: String? {
        switch self {
        case .notSupportedOnDevice:
            return "Live Text is not supported on this device"
        case .invalidImage:
            return "Invalid image for analysis"
        case .analysisFailed(let error):
            return "Analysis failed: \(error.localizedDescription)"
        case .cancelled:
            return "Analysis was cancelled"
        case .barcodeRecognitionFailed(let error):
            return "Barcode recognition failed: \(error.localizedDescription)"
        case .noTextFound:
            return "No text found in image"
        case .permissionDenied:
            return "Camera permission denied"
        }
    }
}

// MARK: - Integration Extensions

extension LiveTextHelper {
    /// Create OCR recognition result from Live Text analysis for integration with existing pipeline
    public func createOCRResult(from analysisResult: AnalysisResult) -> OCRRecognitionResult {
        let observations = analysisResult.textObservations.map { textObs in
            OCRObservation(
                text: textObs.text,
                confidence: textObs.confidence,
                boundingBox: textObs.boundingBox
            )
        }
        
        return OCRRecognitionResult(
            text: analysisResult.text,
            confidence: analysisResult.overallConfidence,
            processingTime: analysisResult.processingTime,
            observations: observations
        )
    }
    
    /// Score Live Text result using existing ConfidenceScorer
    public func scoreLiveTextResult(
        _ analysisResult: AnalysisResult,
        matchedPattern: CityPattern? = nil
    ) -> ConfidenceScorer.ScoreResult {
        let observations = analysisResult.textObservations.map { textObs in
            OCRObservation(
                text: textObs.text,
                confidence: textObs.confidence,
                boundingBox: textObs.boundingBox
            )
        }
        
        return confidenceScorer.score(
            rawText: analysisResult.text,
            observations: observations,
            matchedPattern: matchedPattern
        )
    }
}

// MARK: - Privacy Helpers

extension LiveTextHelper {
    /// Check if Live Text analysis is appropriate from a privacy perspective
    public static func isAnalysisAppropriate(for image: UIImage) -> Bool {
        let minDimension = min(image.size.width, image.size.height)
        guard minDimension >= 240 else {
            return false // Image too small for reliable analysis
        }
        
        return true
    }
    
    /// Privacy-preserving analysis options
    public static var privacyPreservingOptions: ImageAnalyzer.Options {
        var options = ImageAnalyzer.Options()
        options.recognitionLevel = .fast
        return options
    }
}

// MARK: - Availability Helpers

extension LiveTextHelper {
    /// Check if device supports Live Text
    public static var isLiveTextAvailable: Bool {
        ImageAnalyzer.isAvailable
    }
    
    /// Minimum iOS version for Live Text features
    public static let minimumIOSVersion: Float = 16.0
    
    /// Check if current iOS version supports Live Text
    public static var isIOSVersionSupported: Bool {
        #if swift(>=5.9)
        if #available(iOS 16.0, *) {
            return true
        }
        #endif
        return false
    }
    
    /// Check if Apple Intelligence features are available
    public static var isAppleIntelligenceAvailable: Bool {
        ImageAnalyzer.isAvailable
    }
}
