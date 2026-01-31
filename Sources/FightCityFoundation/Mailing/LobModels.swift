//
//  LobModels.swift
//  FightCityFoundation
//
//  Lob API request/response models
//

import Foundation

// MARK: - Lob Letter Request

/// Request model for creating a Lob letter via backend proxy
///
/// ⚠️ CRITICAL: This request MUST ALWAYS include certified mail with return receipt.
/// NO regular mail option - certified_return_receipt is hardcoded.
public struct LobLetterRequest: Codable {
    public let description: String
    public let to: LobAddress
    public let from: LobAddress
    public let file: String // base64 PDF
    public let color: Bool
    public let doubleSided: Bool
    public let mailType: String // "usps_first_class" (required for extra services)
    public let extraService: String // "certified_return_receipt" (HARDCODED)
    
    enum CodingKeys: String, CodingKey {
        case description, to, from, file, color
        case doubleSided = "double_sided"
        case mailType = "mail_type"
        case extraService = "extra_service"
    }
    
    /// Creates a request for certified mail with return receipt ONLY
    ///
    /// - Parameters:
    ///   - to: Recipient address
    ///   - from: Return address
    ///   - pdfBase64: PDF file as base64 string
    ///   - description: Letter description
    public init(
        to: LobAddress,
        from: LobAddress,
        pdfBase64: String,
        description: String
    ) {
        self.to = to
        self.from = from
        self.file = pdfBase64
        self.description = description
        self.color = true
        self.doubleSided = true
        self.mailType = "usps_first_class" // Required for certified mail
        self.extraService = "certified_return_receipt" // HARDCODED - signature proof
    }
}

// MARK: - Lob Letter Response

/// Response from Lob API when creating a certified mail letter
public struct LobLetterResponse: Codable {
    public let id: String
    public let description: String?
    public let url: String?
    public let to: LobAddress
    public let from: LobAddress
    public let expectedDeliveryDate: String?
    public let trackingNumber: String?
    public let trackingEvents: [LobTrackingEvent]?
    public let carrier: String?
    public let mailType: String?
    public let extraService: String?
    
    enum CodingKeys: String, CodingKey {
        case id, description, url, to, from, carrier
        case expectedDeliveryDate = "expected_delivery_date"
        case trackingNumber = "tracking_number"
        case trackingEvents = "tracking_events"
        case mailType = "mail_type"
        case extraService = "extra_service"
    }
}

/// Tracking event from Lob API
public struct LobTrackingEvent: Codable {
    public let name: String // e.g., "letter.certified.delivered"
    public let time: String // ISO 8601 timestamp
    public let location: String?
    public let details: [String: String]? // Extra data (e.g., signature info)
    
    public init(name: String, time: String, location: String?, details: [String: String]?) {
        self.name = name
        self.time = time
        self.location = location
        self.details = details
    }
    
    enum CodingKeys: String, CodingKey {
        case name, time, location, details
    }
}

public struct LobThumbnail: Codable {
    public let small: String?
    public let medium: String?
    public let large: String?
}
