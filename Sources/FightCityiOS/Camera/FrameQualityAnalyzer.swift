//
//  FrameQualityAnalyzer.swift
//  FightCityiOS
//
//  Analyzes frame quality: sharpness, glare, motion blur
//

import CoreImage
import UIKit

/// Analyzes image quality for optimal capture conditions
public struct FrameQualityAnalyzer {
    private let context = CIContext()
    
    // MARK: - Quality Thresholds
    
    public struct Thresholds {
        public static let sharpness: CGFloat = 100
        public static let glare: CGFloat = 0.3
        public static let motionBlur: CGFloat = 0.5
        
        public init() {}
    }
    
    // MARK: - Analysis Result
    
    public struct AnalysisResult {
        public let sharpness: Double
        public let glareLevel: Double
        public let motionScore: Double
        public let overallScore: Double
        public let isAcceptable: Bool
        public let warnings: [QualityWarning]
        
        public enum QualityWarning: String, CaseIterable {
            case blurry = "Image may be blurry"
            case glare = "Glare detected"
            case motionBlur = "Motion detected"
            case dark = "Image too dark"
            case bright = "Image too bright"
            
            public var displayText: String { rawValue }
        }
        
        public init(
            sharpness: Double,
            glareLevel: Double,
            motionScore: Double,
            overallScore: Double,
            isAcceptable: Bool,
            warnings: [QualityWarning]
        ) {
            self.sharpness = sharpness
            self.glareLevel = glareLevel
            self.motionScore = motionScore
            self.overallScore = overallScore
            self.isAcceptable = isAcceptable
            self.warnings = warnings
        }
    }
    
    public init() {}
    
    // MARK: - Analysis
    
    /// Analyze image quality
    public func analyze(_ uiImage: UIImage) -> AnalysisResult {
        guard let ciImage = CIImage(image: uiImage) else {
            return AnalysisResult(
                sharpness: 0,
                glareLevel: 0,
                motionScore: 0,
                overallScore: 0,
                isAcceptable: false,
                warnings: [.blurry]
            )
        }
        
        let sharpness = calculateSharpness(ciImage)
        let glare = calculateGlare(ciImage)
        let motion = calculateMotionBlur(ciImage)
        let brightness = calculateBrightness(ciImage)
        
        var warnings: [QualityWarning] = []
        
        if sharpness < Thresholds.sharpness {
            warnings.append(.blurry)
        }
        
        if glare > Thresholds.glare {
            warnings.append(.glare)
        }
        
        if motion < Thresholds.motionBlur {
            warnings.append(.motionBlur)
        }
        
        if brightness < 0.2 {
            warnings.append(.dark)
        } else if brightness > 0.9 {
            warnings.append(.bright)
        }
        
        let overallScore = calculateOverallScore(
            sharpness: sharpness,
            glare: glare,
            motion: motion
        )
        
        return AnalysisResult(
            sharpness: sharpness,
            glareLevel: glare,
            motionScore: motion,
            overallScore: overallScore,
            isAcceptable: overallScore >= 0.7 && warnings.isEmpty,
            warnings: warnings
        )
    }
    
    // MARK: - Sharpness Calculation
    
    /// Calculate sharpness using Laplacian variance
    private func calculateSharpness(_ image: CIImage) -> Double {
        guard let filter = CIFilter(name: "CILaplacian") else { return 0 }
        
        filter.setValue(image, forKey: kCIInputImageKey)
        
        guard let output = filter.outputImage,
              let bitmap = context.createCGImage(output, from: output.extent) else {
            return 0
        }
        
        let pixelData = CGDataProvider(data: bitmap.dataProvider!.data)!
        let data = CFDataGetBytePtr(pixelData)
        let length = CFDataGetLength(pixelData)
        
        var sum = 0
        var sumSquares = 0
        
        for i in stride(from: 0, to: length, by: 4) {
            let gray = (data![i] + data![i + 1] + data![i + 2]) / 3
            sum += Int(gray)
            sumSquares += Int(gray) * Int(gray)
        }
        
        let count = length / 4
        let mean = Double(sum) / Double(count)
        let variance = Double(sumSquares) / Double(count) - mean * mean
        
        return sqrt(max(0, variance))
    }
    
    // MARK: - Glare Detection
    
    /// Detect glare using highlight threshold
    private func calculateGlare(_ image: CIImage) -> Double {
        guard let filter = CIFilter(name: "CIColorControls") else { return 0 }
        
        filter.setValue(image, forKey: kCIInputImageKey)
        filter.setValue(1.5, forKey: kCIInputContrastKey)
        
        guard let output = filter.outputImage,
              let bitmap = context.createCGImage(output, from: output.extent) else {
            return 0
        }
        
        let pixelData = CGDataProvider(data: bitmap.dataProvider!.data)!
        let data = CFDataGetBytePtr(pixelData)
        let length = CFDataGetLength(pixelData)
        
        var highlightPixels = 0
        let threshold = UInt8(240)
        
        for i in stride(from: 0, to: length, by: 4) {
            if data![i] > threshold || data![i + 1] > threshold || data![i + 2] > threshold {
                highlightPixels += 1
            }
        }
        
        let totalPixels = length / 4
        return Double(highlightPixels) / Double(totalPixels)
    }
    
    // MARK: - Motion Blur Detection
    
    /// Estimate motion blur using edge coherence
    private func calculateMotionBlur(_ image: CIImage) -> Double {
        // Use Sobel filter to detect edges
        guard let sobelFilter = CIFilter(name: "CISobel") else { return 1.0 }
        
        sobelFilter.setValue(image, forKey: kCIInputImageKey)
        
        guard let edges = sobelFilter.outputImage,
              let bitmap = context.createCGImage(edges, from: edges.extent) else {
            return 1.0
        }
        
        let pixelData = CGDataProvider(data: bitmap.dataProvider!.data)!
        let data = CFDataGetBytePtr(pixelData)
        let length = CFDataGetLength(pixelData)
        
        // Count edge pixels
        var edgePixels = 0
        for i in stride(from: 0, to: length, by: 4) {
            let intensity = (data![i] + data![i + 1] + data![i + 2]) / 3
            if intensity > 50 {
                edgePixels += 1
            }
        }
        
        let totalPixels = length / 4
        let edgeDensity = Double(edgePixels) / Double(totalPixels)
        
        // High edge density suggests sharp image
        // Low edge density suggests potential blur
        return min(1.0, edgeDensity * 5)
    }
    
    // MARK: - Brightness Calculation
    
    /// Calculate average brightness
    private func calculateBrightness(_ image: CIImage) -> Double {
        guard let bitmap = context.createCGImage(image, from: image.extent) else { return 0.5 }
        
        let pixelData = CGDataProvider(data: bitmap.dataProvider!.data)!
        let data = CFDataGetBytePtr(pixelData)
        let length = CFDataGetLength(pixelData)
        
        var totalBrightness = 0
        
        for i in stride(from: 0, to: length, by: 4) {
            totalBrightness += Int(data![i] + data![i + 1] + data![i + 2])
        }
        
        let pixelCount = length / 4
        return Double(totalBrightness) / (Double(pixelCount) * 3 * 255)
    }
    
    // MARK: - Overall Score
    
    /// Calculate weighted overall quality score
    private func calculateOverallScore(sharpness: Double, glare: Double, motion: Double) -> Double {
        let normalizedSharpness = min(1.0, sharpness / 500)
        let normalizedGlare = 1.0 - min(1.0, glare * 2)
        
        // Weighted average: sharpness 50%, glare 30%, motion 20%
        return normalizedSharpness * 0.5 + normalizedGlare * 0.3 + motion * 0.2
    }
}

// MARK: - Auto-Capture Decision

extension FrameQualityAnalyzer.AnalysisResult {
    /// Determine if quality is sufficient for auto-capture
    public var shouldAutoCapture: Bool {
        overallScore >= 0.8 && warnings.isEmpty
    }
    
    /// Get user-facing quality feedback
    public var feedbackMessage: String {
        if warnings.isEmpty {
            return "Perfect conditions"
        }
        
        let messages = warnings.map { $0.displayText }
        return messages.joined(separator: ", ")
    }
}
