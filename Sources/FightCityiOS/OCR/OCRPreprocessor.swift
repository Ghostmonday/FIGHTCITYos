//
//  OCRPreprocessor.swift
//  FightCityiOS
//
//  Image preprocessing: perspective correction, contrast, noise reduction
//

import CoreImage
import UIKit

/// Preprocesses images for optimal OCR results
public struct OCRPreprocessor {
    private let context = CIContext()
    private let ciContext = CIContext()
    
    // MARK: - Preprocessing Options
    
    public struct Options {
        public var enhanceContrast: Bool = true
        public var reduceNoise: Bool = true
        public var correctPerspective: Bool = true
        public var binarize: Bool = false
        public var targetSize: CGSize = CGSize(width: 1920, height: 1920)
        
        public init() {}
    }
    
    public init() {}
    
    // MARK: - Preprocessing Pipeline
    
    /// Preprocess image for OCR
    public func preprocess(_ uiImage: UIImage, options: Options = Options()) async throws -> UIImage {
        guard let ciImage = CIImage(image: uiImage) else {
            throw PreprocessingError.invalidImage
        }
        
        var outputImage = ciImage
        
        // 1. Resize if needed
        if shouldResize(ciImage, targetSize: options.targetSize) {
            outputImage = try resize(ciImage, targetSize: options.targetSize)
        }
        
        // 2. Correct perspective
        if options.correctPerspective {
            outputImage = try correctPerspective(outputImage)
        }
        
        // 3. Enhance contrast
        if options.enhanceContrast {
            outputImage = enhanceContrast(outputImage)
        }
        
        // 4. Reduce noise
        if options.reduceNoise {
            outputImage = reduceNoise(outputImage)
        }
        
        // 5. Binarize for better text extraction
        if options.binarize {
            outputImage = binarize(outputImage)
        }
        
        // Convert back to UIImage
        guard let cgImage = ciContext.createCGImage(outputImage, from: outputImage.extent) else {
            throw PreprocessingError.conversionFailed
        }
        
        return UIImage(cgImage: cgImage)
    }
    
    // MARK: - Resize
    
    private func shouldResize(_ image: CIImage, targetSize: CGSize) -> Bool {
        image.extent.width > targetSize.width || image.extent.height > targetSize.height
    }
    
    private func resize(_ image: CIImage, targetSize: CGSize) throws -> CIImage {
        let scale = min(
            targetSize.width / image.extent.width,
            targetSize.height / image.extent.height
        )
        
        let transform = CGAffineTransform(scaleX: scale, y: scale)
        let scaledImage = image.transformed(by: transform)
        
        return scaledImage
    }
    
    // MARK: - Perspective Correction
    
    private func correctPerspective(_ image: CIImage) throws -> CIImage {
        // Use CIPerspectiveCorrection if document corners can be detected
        // For now, return the original image with basic straightening
        guard let filter = CIFilter(name: "CIStraightenFilter") else {
            return image
        }
        
        filter.setValue(image, forKey: kCIInputImageKey)
        filter.setValue(0, forKey: kCIInputAngleKey) // No rotation needed
        
        return filter.outputImage ?? image
    }
    
    // MARK: - Contrast Enhancement
    
    private func enhanceContrast(_ image: CIImage) -> CIImage {
        guard let filter = CIFilter(name: "CIColorControls") else {
            return image
        }
        
        filter.setValue(image, forKey: kCIInputImageKey)
        filter.setValue(1.2, forKey: kCIInputContrastKey) // Increase contrast
        filter.setValue(0.0, forKey: kCIInputSaturationKey)
        filter.setValue(1.0, forKey: kCIInputBrightnessKey)
        
        return filter.outputImage ?? image
    }
    
    // MARK: - Noise Reduction
    
    private func reduceNoise(_ image: CIImage) -> CIImage {
        guard let filter = CIFilter(name: "CINoiseReduction") else {
            return image
        }
        
        filter.setValue(image, forKey: kCIInputImageKey)
        filter.setValue(0.4, forKey: kCIInputNoiseLevelKey)
        filter.setValue(0.2, forKey: kCIInputSharpnessKey)
        
        return filter.outputImage ?? image
    }
    
    // MARK: - Binarization
    
    private func binarize(_ image: CIImage) -> CIImage {
        guard let filter = CIFilter(name: "CIColorControls") else {
            return image
        }
        
        filter.setValue(image, forKey: kCIInputImageKey)
        filter.setValue(2.0, forKey: kCIInputContrastKey)
        filter.setValue(0.0, forKey: kCIInputSaturationKey)
        
        guard let highContrast = filter.outputImage else {
            return image
        }
        
        // Apply threshold using color matrix
        guard let thresholdFilter = CIFilter(name: "CIColorMatrix") else {
            return highContrast
        }
        
        // Simple threshold: make light pixels white, dark pixels black
        let vector = CIVector(x: 0, y: 0.5, z: 0, w: 0)
        thresholdFilter.setValue(highContrast, forKey: kCIInputImageKey)
        thresholdFilter.setValue(vector, forKey: "inputRVector")
        
        return thresholdFilter.outputImage ?? highContrast
    }
    
    // MARK: - Adaptive Binarization
    
    /// Adaptive binarization for better text separation
    public func adaptiveBinarize(_ uiImage: UIImage) async throws -> UIImage {
        guard let ciImage = CIImage(image: uiImage) else {
            throw PreprocessingError.invalidImage
        }
        
        // Use CIAreaAverage to calculate local threshold
        guard let filter = CIFilter(name: "CIAreaAverage") else {
            return uiImage
        }
        
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(CIVector(x: 0, y: 0, z: ciImage.extent.width, w: ciImage.extent.height), forKey: kCIInputExtentKey)
        
        // For now, apply strong contrast
        let highContrast = enhanceContrast(ciImage)
        let denoised = reduceNoise(highContrast)
        
        guard let cgImage = ciContext.createCGImage(denoised, from: denoised.extent) else {
            throw PreprocessingError.conversionFailed
        }
        
        return UIImage(cgImage: cgImage)
    }
}

// MARK: - Preprocessing Error

public enum PreprocessingError: LocalizedError {
    case invalidImage
    case conversionFailed
    case filterFailed
    
    public var errorDescription: String? {
        switch self {
        case .invalidImage:
            return "Invalid image data"
        case .conversionFailed:
            return "Failed to convert processed image"
        case .filterFailed:
            return "Image filter operation failed"
        }
    }
}

// MARK: - Image Utilities

extension OCRPreprocessor {
    /// Crop image to bounding box
    public static func crop(_ uiImage: UIImage, to rect: CGRect) -> UIImage? {
        guard let cgImage = uiImage.cgImage else { return nil }
        
        let scaledRect = CGRect(
            x: rect.origin.x * uiImage.scale,
            y: rect.origin.y * uiImage.scale,
            width: rect.width * uiImage.scale,
            height: rect.height * uiImage.scale
        )
        
        guard let croppedCGImage = cgImage.cropping(to: scaledRect) else {
            return nil
        }
        
        return UIImage(cgImage: croppedCGImage, scale: uiImage.scale, orientation: uiImage.imageOrientation)
    }
    
    /// Convert UIImage to grayscale CIImage
    public static func grayscale(_ ciImage: CIImage) -> CIImage? {
        guard let filter = CIFilter(name: "CIColorControls") else { return nil }
        
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(0.0, forKey: kCIInputSaturationKey)
        
        return filter.outputImage
    }
}
