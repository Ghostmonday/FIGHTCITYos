//
//  SceneAnalyzer.swift
//  FightCityiOS
//
//  Vision-based scene analysis for evidence photos (signs, meters, context)
//

import Vision
import CoreImage
import UIKit

import os.log

/// APPLE INTELLIGENCE: Vision-based scene analysis for parking sign and meter detection
/// APPLE INTELLIGENCE: Uses VNClassifyImageRequest for object detection
/// APPLE INTELLIGENCE: Real-time analysis of evidence photo content

// MARK: - Scene Analysis Result

/// Result of scene analysis
public struct SceneAnalysisResult {
    public let detectedObjects: [DetectedObject]
    public let sceneClassification: SceneClassification
    public let qualityAssessment: ImageQualityAssessment
    public let isSuitableForEvidence: Bool
    public let processingTimeMs: Int
    
    public init(
        detectedObjects: [DetectedObject],
        sceneClassification: SceneClassification,
        qualityAssessment: ImageQualityAssessment,
        isSuitableForEvidence: Bool,
        processingTimeMs: Int
    ) {
        self.detectedObjects = detectedObjects
        self.sceneClassification = sceneClassification
        self.qualityAssessment = qualityAssessment
        self.isSuitableForEvidence = isSuitableForEvidence
        self.processingTimeMs = processingTimeMs
    }
}

// MARK: - Detected Object

/// Object detected in scene
public struct DetectedObject {
    public let type: DetectedObjectType
    public let confidence: Double
    public let boundingBox: CGRect
    public let label: String?
    
    public init(
        type: DetectedObjectType,
        confidence: Double,
        boundingBox: CGRect,
        label: String? = nil
    ) {
        self.type = type
        self.confidence = confidence
        self.boundingBox = boundingBox
        self.label = label
    }
}

// MARK: - Detected Object Types

/// Types of objects that can be detected
public enum DetectedObjectType: String, CaseIterable {
    case parkingSign = "parking_sign"
    case parkingMeter = "parking_meter"
    case streetSign = "street_sign"
    case trafficLight = "traffic_light"
    case crosswalk = "crosswalk"
    case curb = "curb"
    case vehicle = "vehicle"
    case building = "building"
    case tree = "tree"
    case sidewalk = "sidewalk"
    case unknown = "unknown"
    
    public var displayName: String {
        switch self {
        case .parkingSign: return "Parking Sign"
        case .parkingMeter: return "Parking Meter"
        case .streetSign: return "Street Sign"
        case .trafficLight: return "Traffic Light"
        case .crosswalk: return "Crosswalk"
        case .curb: return "Curb"
        case .vehicle: return "Vehicle"
        case .building: return "Building"
        case .tree: return "Tree"
        case .sidewalk: return "Sidewalk"
        case .unknown: return "Unknown"
        }
    }
    
    public var isRelevantEvidence: Bool {
        switch self {
        case .parkingSign, .parkingMeter, .streetSign, .crosswalk, .curb:
            return true
        default:
            return false
        }
    }
}

// MARK: - Scene Classification

/// Classification of the overall scene
public struct SceneClassification {
    public let category: SceneCategory
    public let confidence: Double
    public let subcategories: [SceneSubcategory]
    
    public init(
        category: SceneCategory,
        confidence: Double,
        subcategories: [SceneSubcategory] = []
    ) {
        self.category = category
        self.confidence = confidence
        self.subcategories = subcategories
    }
}

// MARK: - Scene Categories

/// High-level scene categories
public enum SceneCategory: String, CaseIterable {
    case streetScene = "street_scene"
    case parkingLot = "parking_lot"
    case curbSide = "curb_side"
    case intersection = "intersection"
    case buildingExterior = "building_exterior"
    case unclear = "unclear"
    
    public var displayName: String {
        switch self {
        case .streetScene: return "Street Scene"
        case .parkingLot: return "Parking Lot"
        case .curbSide: return "Curb Side"
        case .intersection: return "Intersection"
        case .buildingExterior: return "Building Exterior"
        case .unclear: return "Unclear"
        }
    }
}

// MARK: - Scene Subcategories

/// Detailed scene subcategories
public enum SceneSubcategory: String, CaseIterable {
    case residential = "residential"
    case commercial = "commercial"
    case industrial = "industrial"
    case mixedUse = "mixed_use"
    case streetParking = "street_parking"
    case meteredParking = "metered_parking"
    case permitParking = "permit_parking"
    case noParking = "no_parking"
}

// MARK: - Image Quality Assessment

/// Assessment of image quality for evidence
public struct ImageQualityAssessment {
    public let brightness: Double
    public let sharpness: Double
    public let composition: Double
    public let isBlurry: Bool
    public let hasGlare: Bool
    public let isTooDark: Bool
    public let overallScore: Double
    
    public init(
        brightness: Double,
        sharpness: Double,
        composition: Double,
        isBlurry: Bool,
        hasGlare: Bool,
        isTooDark: Bool,
        overallScore: Double
    ) {
        self.brightness = brightness
        self.sharpness = sharpness
        self.composition = composition
        self.isBlurry = isBlurry
        self.hasGlare = hasGlare
        self.isTooDark = isTooDark
        self.overallScore = overallScore
    }
}

// MARK: - Scene Analyzer

/// Vision-based scene analyzer for evidence photos
public final class SceneAnalyzer {
    
    // MARK: - Properties
    
    /// Shared instance
    public static let shared = SceneAnalyzer()
    
    /// Core Image context
    private let ciContext = CIContext()
    
    /// VNRequest for image classification
    private var classificationRequest: VNClassifyImageRequest?
    
    // MARK: - Initialization
    
    public init() {
        setupClassificationRequest()
    }
    
    // MARK: - Public Methods
    
    /// Analyze a scene for evidence
    /// - Parameter image: Image to analyze
    /// - Returns: Complete scene analysis result
    public func analyzeScene(_ image: UIImage) async -> SceneAnalysisResult {
        let startTime = Date()
        
        guard let cgImage = image.cgImage else {
            return createErrorResult(processingTimeMs: 0)
        }
        
        // Perform object detection
        let objects = await detectObjects(in: cgImage)
        
        // Perform scene classification
        let classification = await classifyScene(cgImage)
        
        // Assess image quality
        let qualityAssessment = assessQuality(of: image)
        
        // Determine if suitable for evidence
        let isSuitable = determineEvidenceSuitability(
            objects: objects,
            classification: classification,
            quality: qualityAssessment
        )
        
        let processingTimeMs = Int(Date().timeIntervalSince(startTime) * 1000)
        
        return SceneAnalysisResult(
            detectedObjects: objects,
            sceneClassification: classification,
            qualityAssessment: qualityAssessment,
            isSuitableForEvidence: isSuitable,
            processingTimeMs: processingTimeMs
        )
    }
    
    /// Detect specific object types in image
    /// - Parameters:
    ///   - image: Image to analyze
    ///   - objectTypes: Types of objects to detect
    /// - Returns: Detected objects of specified types
    public func detectSpecificObjects(
        in image: UIImage,
        types: [DetectedObjectType]
    ) async -> [DetectedObject] {
        guard let cgImage = image.cgImage else { return [] }
        
        let allObjects = await detectObjects(in: cgImage)
        
        return allObjects.filter { object in
            types.contains(object.type)
        }
    }
    
    /// Check if image contains evidence-relevant objects
    /// - Parameter image: Image to check
    /// - Returns: Whether evidence-relevant objects were found
    public func hasEvidenceRelevance(_ image: UIImage) async -> Bool {
        let objects = await detectSpecificObjects(
            in: image,
            types: [.parkingSign, .parkingMeter, .streetSign, .crosswalk]
        )
        
        return !objects.isEmpty
    }
    
    // MARK: - Private Methods
    
    private func setupClassificationRequest() {
        classificationRequest = VNClassifyImageRequest { request, error in
            // Handle classification results
        }
    }
    
    private func detectObjects(in cgImage: CGImage) async -> [DetectedObject] {
        var detectedObjects: [DetectedObject] = []
        
        // Use text recognition to find signs
        let signTexts = await recognizeTextInImage(cgImage)
        if !signTexts.isEmpty {
            let signObjects = parseSignText(signTexts)
            detectedObjects.append(contentsOf: signObjects)
        }
        
        // Use rectangle detection for sign boundaries
        let rectangleObjects = await detectRectangles(in: cgImage)
        detectedObjects.append(contentsOf: rectangleObjects)
        
        return detectedObjects
    }
    
    private func recognizeTextInImage(_ cgImage: CGImage) async -> [String] {
        return await withCheckedContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                guard error == nil,
                      let observations = request.results as? [VNRecognizedTextObservation] else {
                    continuation.resume(returning: [])
                    return
                }
                
                let texts = observations.compactMap { observation in
                    observation.topCandidates(1).first?.string
                }
                
                continuation.resume(returning: texts)
            }
            
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = false
            
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(returning: [])
            }
        }
    }
    
    private func parseSignText(_ texts: [String]) -> [DetectedObject] {
        var objects: [DetectedObject] = []
        
        for text in texts {
            let upperText = text.uppercased()
            
            // Check for parking-related keywords
            if upperText.contains("NO PARKING") || upperText.contains("NO STOPPING") {
                objects.append(DetectedObject(
                    type: .parkingSign,
                    confidence: 0.9,
                    boundingBox: .zero,
                    label: text
                ))
            } else if upperText.contains("2 HR") || upperText.contains("2 HOUR") || upperText.contains("PARKING") {
                objects.append(DetectedObject(
                    type: .parkingSign,
                    confidence: 0.85,
                    boundingBox: .zero,
                    label: text
                ))
            } else if upperText.contains("METER") {
                objects.append(DetectedObject(
                    type: .parkingMeter,
                    confidence: 0.8,
                    boundingBox: .zero,
                    label: text
                ))
            }
        }
        
        return objects
    }
    
    private func detectRectangles(in cgImage: CGImage) async -> [DetectedObject] {
        return await withCheckedContinuation { continuation in
            var objects: [DetectedObject] = []
            
            // Request rectangle detection
            let request = VNDetectRectanglesRequest { request, error in
                guard error == nil,
                      let observations = request.results as? [VNRectangleObservation] else {
                    continuation.resume(returning: [])
                    return
                }
                
                for observation in observations {
                    objects.append(DetectedObject(
                        type: .streetSign,
                        confidence: Double(observation.confidence),
                        boundingBox: observation.boundingBox
                    ))
                }
                
                continuation.resume(returning: objects)
            }
            
            request.minimumAspectRatio = 0.2
            request.maximumAspectRatio = 5.0
            request.minimumSize = 10000 // 100x100 pixels minimum
            
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(returning: [])
            }
        }
    }
    
    private func classifyScene(_ cgImage: CGImage) async -> SceneClassification {
        // Use image classification
        return await withCheckedContinuation { continuation in
            let request = VNClassifyImageRequest { request, error in
                guard error == nil,
                      let observations = request.results as? [VNClassificationObservation] else {
                    continuation.resume(returning: SceneClassification(
                        category: .unclear,
                        confidence: 0.0
                    ))
                    return
                }
                
                // Map Vision categories to our scene categories
                let topObservation = observations.first
                let category = self.mapToSceneCategory(topObservation?.identifier ?? "")
                
                let subcategories = observations.prefix(5).compactMap { obs in
                    SceneSubcategory(rawValue: obs.identifier.replacingOccurrences(of: " ", with: "_"))
                }
                
                let classification = SceneClassification(
                    category: category,
                    confidence: Double(topObservation?.confidence ?? 0),
                    subcategories: Array(subcategories)
                )
                
                continuation.resume(returning: classification)
            }
            
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(returning: SceneClassification(
                    category: .unclear,
                    confidence: 0.0
                ))
            }
        }
    }
    
    private func mapToSceneCategory(_ visionIdentifier: String) -> SceneCategory {
        let lowerIdentifier = visionIdentifier.lowercased()
        
        if lowerIdentifier.contains("street") || lowerIdentifier.contains("road") {
            return .streetScene
        } else if lowerIdentifier.contains("parking") || lowerIdentifier.contains("lot") {
            return .parkingLot
        } else if lowerIdentifier.contains("building") || lowerIdentifier.contains("facade") {
            return .buildingExterior
        } else if lowerIdentifier.contains("intersection") || lowerIdentifier.contains("crossroad") {
            return .intersection
        }
        
        return .streetScene // Default
    }
    
    private func assessQuality(of image: UIImage) -> ImageQualityAssessment {
        // Calculate brightness
        let brightness = calculateBrightness(image)
        
        // Calculate sharpness (Laplacian variance)
        let sharpness = calculateSharpness(image)
        
        // Check for blur
        let isBlurry = sharpness < 0.01
        
        // Check for glare (simple heuristic)
        let hasGlare = checkForGlare(image)
        
        // Check for darkness
        let isTooDark = brightness < 0.2
        
        // Composition assessment
        let composition = assessComposition(image)
        
        // Overall score
        var overallScore = 0.5
        overallScore += (1 - abs(brightness - 0.5)) * 0.3 // Good brightness
        overallScore += sharpness * 0.3 // Good sharpness
        overallScore += composition * 0.2 // Good composition
        
        if isBlurry { overallScore -= 0.2 }
        if hasGlare { overallScore -= 0.15 }
        if isTooDark { overallScore -= 0.15 }
        
        overallScore = max(0, min(1, overallScore))
        
        return ImageQualityAssessment(
            brightness: brightness,
            sharpness: sharpness,
            composition: composition,
            isBlurry: isBlurry,
            hasGlare: hasGlare,
            isTooDark: isTooDark,
            overallScore: overallScore
        )
    }
    
    private func calculateBrightness(_ image: UIImage) -> Double {
        guard let ciImage = CIImage(image: image) else { return 0.5 }
        
        let extent = ciImage.extent
        let inputImage = ciImage.applyingFilter("CIAreaAverage", parameters: [
            kCIInputExtentKey: extent
        ])
        
        guard let outputImage = ciContext.createCGImage(inputImage, from: inputImage.extent) else {
            return 0.5
        }
        
        let pixelData = outputImage.dataProvider?.data
        let data = (pixelData as Data?) ?? Data(count: 4)
        
        let r = Double(data[0]) / 255.0
        let g = Double(data[1]) / 255.0
        let b = Double(data[2]) / 255.0
        
        return (0.299 * r + 0.587 * g + 0.114 * b)
    }
    
    private func calculateSharpness(_ image: UIImage) -> Double {
        guard let ciImage = CIImage(image: image) else { return 0 }
        
        // Laplacian filter for edge detection
        let filter = CIFilter(name: "CILaplacian")
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        
        guard let outputCIImage = filter?.outputImage else { return 0 }
        guard let outputCGImage = ciContext.createCGImage(outputCIImage, from: outputCIImage.extent) else { return 0 }
        
        // Calculate variance of pixel values
        let pixelData = outputCGImage.dataProvider?.data
        let data = (pixelData as Data?) ?? Data()
        
        guard data.count > 0 else { return 0 }
        
        let bytes = [UInt8](data)
        var sum: Double = 0
        var sumSquares: Double = 0
        
        for i in stride(from: 0, to: min(data.count, 1000), by: 4) {
            let value = Double(bytes[i])
            sum += value
            sumSquares += value * value
        }
        
        let count = Double(min(data.count, 1000) / 4)
        let mean = sum / count
        let variance = (sumSquares / count) - (mean * mean)
        
        return sqrt(max(0, variance)) / 255.0
    }
    
    private func checkForGlare(_ image: UIImage) -> Bool {
        guard let ciImage = CIImage(image: image) else { return false }
        
        // Check for very bright regions
        let extent = ciImage.extent
        let inputImage = ciImage.applyingFilter("CIAreaMaximum", parameters: [
            kCIInputExtentKey: extent
        ])
        
        guard let outputImage = ciContext.createCGImage(inputImage, from: inputImage.extent) else { return false }
        
        let pixelData = outputImage.dataProvider?.data
        let data = (pixelData as Data?) ?? Data(count: 4)
        
        // Check if maximum brightness exceeds threshold
        let maxBrightness = Double(data[0]) / 255.0
        return maxBrightness > 0.95
    }
    
    private func assessComposition(_ image: UIImage) -> Double {
        // Simple composition assessment
        // Check if main subject is centered and not cut off
        let width = image.size.width
        let height = image.size.height
        
        // Aspect ratio check
        let aspectRatio = width / height
        let goodAspect = aspectRatio >= 0.5 && aspectRatio <= 2.0
        
        return goodAspect ? 0.8 : 0.5
    }
    
    private func determineEvidenceSuitability(
        objects: [DetectedObject],
        classification: SceneClassification,
        quality: ImageQualityAssessment
    ) -> Bool {
        // Check quality
        guard quality.overallScore >= 0.5 else { return false }
        guard !quality.isBlurry else { return false }
        
        // Check for relevant objects
        let relevantObjects = objects.filter { $0.type.isRelevantEvidence }
        guard !relevantObjects.isEmpty else { return false }
        
        // Check scene classification
        switch classification.category {
        case .streetScene, .curbSide, .parkingLot:
            return true
        default:
            return relevantObjects.count >= 2
        }
    }
    
    private func createErrorResult(processingTimeMs: Int) -> SceneAnalysisResult {
        SceneAnalysisResult(
            detectedObjects: [],
            sceneClassification: SceneClassification(category: .unclear, confidence: 0),
            qualityAssessment: ImageQualityAssessment(
                brightness: 0,
                sharpness: 0,
                composition: 0,
                isBlurry: false,
                hasGlare: false,
                isTooDark: false,
                overallScore: 0
            ),
            isSuitableForEvidence: false,
            processingTimeMs: processingTimeMs
        )
    }
}

// MARK: - Analysis Feedback

extension SceneAnalyzer {
    /// Generate user-friendly feedback from analysis
    public func generateFeedback(for result: SceneAnalysisResult) -> [String] {
        var feedback: [String] = []
        
        // Quality feedback
        if result.qualityAssessment.isBlurry {
            feedback.append("Image is blurry. Try holding the camera steady.")
        }
        if result.qualityAssessment.hasGlare {
            feedback.append("Glare detected. Try adjusting the angle.")
        }
        if result.qualityAssessment.isTooDark {
            feedback.append("Image is too dark. Try better lighting.")
        }
        
        // Object feedback
        let relevantObjects = result.detectedObjects.filter { $0.type.isRelevantEvidence }
        if relevantObjects.isEmpty {
            feedback.append("No parking signs or meters detected. Make sure to include relevant signage.")
        } else {
            let objectNames = relevantObjects.map { $0.type.displayName }.joined(separator: ", ")
            feedback.append("Detected: \(objectNames)")
        }
        
        // Evidence suitability
        if result.isSuitableForEvidence {
            feedback.append("This image is suitable as evidence.")
        } else {
            feedback.append("Consider taking another photo with clearer signs.")
        }
        
        return feedback
    }
}
