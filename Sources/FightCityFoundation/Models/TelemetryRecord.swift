//
//  TelemetryRecord.swift
//  FightCityFoundation
//
//  Individual telemetry record (opt-in)
//

import Foundation

/// Individual telemetry record (opt-in)
public struct TelemetryRecord: Codable, Identifiable {
    public var id: String
    public let city: String
    public let timestamp: Date
    public let deviceModel: String
    public let iOSVersion: String
    public let originalImageHash: String
    public let croppedImageHash: String
    public let ocrOutput: String
    public let userCorrection: String?
    public let confidence: Double
    public let processingTimeMs: Int
    
    public enum CodingKeys: String, CodingKey {
        case id
        case city
        case timestamp
        case deviceModel = "device_model"
        case iOSVersion = "ios_version"
        case originalImageHash = "original_image_hash"
        case croppedImageHash = "cropped_image_hash"
        case ocrOutput = "ocr_output"
        case userCorrection = "user_correction"
        case confidence
        case processingTimeMs = "processing_time_ms"
    }
    
    public init(
        id: String = UUID().uuidString,
        city: String,
        timestamp: Date = Date(),
        deviceModel: String,
        iOSVersion: String,
        originalImageHash: String,
        croppedImageHash: String,
        ocrOutput: String,
        userCorrection: String?,
        confidence: Double,
        processingTimeMs: Int
    ) {
        self.id = id
        self.city = city
        self.timestamp = timestamp
        self.deviceModel = deviceModel
        self.iOSVersion = iOSVersion
        self.originalImageHash = originalImageHash
        self.croppedImageHash = croppedImageHash
        self.ocrOutput = ocrOutput
        self.userCorrection = userCorrection
        self.confidence = confidence
        self.processingTimeMs = processingTimeMs
    }
}
