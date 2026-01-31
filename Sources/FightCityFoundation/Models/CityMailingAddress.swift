//
//  CityMailingAddress.swift
//  FightCityFoundation
//
//  City mailing address model for appeal submissions
//

import Foundation

/// Mailing address for a city's appeal submission office
public struct CityMailingAddress: Codable, Identifiable, Equatable {
    public let id: String // Same as cityId
    public let cityId: String
    public let agencyName: String
    public let addressLine1: String
    public let addressLine2: String?
    public let city: String
    public let state: String
    public let zip: String
    public let attentionLine: String?
    public let requiresCertified: Bool
    public let scrapedAt: Date
    public let sourceUrl: String
    
    public init(
        cityId: String,
        agencyName: String,
        addressLine1: String,
        addressLine2: String? = nil,
        city: String,
        state: String,
        zip: String,
        attentionLine: String? = nil,
        requiresCertified: Bool = true, // All appeals use certified mail
        scrapedAt: Date = Date(),
        sourceUrl: String
    ) {
        self.id = cityId
        self.cityId = cityId
        self.agencyName = agencyName
        self.addressLine1 = addressLine1
        self.addressLine2 = addressLine2
        self.city = city
        self.state = state
        self.zip = zip
        self.attentionLine = attentionLine
        self.requiresCertified = requiresCertified
        self.scrapedAt = scrapedAt
        self.sourceUrl = sourceUrl
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case cityId = "city_id"
        case agencyName = "agency_name"
        case addressLine1 = "address_line1"
        case addressLine2 = "address_line2"
        case city
        case state
        case zip
        case attentionLine = "attention_line"
        case requiresCertified = "requires_certified"
        case scrapedAt = "scraped_at"
        case sourceUrl = "source_url"
    }
}

// MARK: - Lob Address Conversion

extension CityMailingAddress {
    /// Converts to LobAddress format for API requests
    public func toLobAddress() -> LobAddress {
        var addressLine1 = self.addressLine1
        if let attention = attentionLine {
            addressLine1 = "\(attention)\n\(addressLine1)"
        }
        
        return LobAddress(
            name: agencyName,
            addressLine1: addressLine1,
            addressLine2: addressLine2,
            city: city,
            state: state,
            zip: zip,
            country: "US"
        )
    }
    
    /// Formatted address string for display
    public var formatted: String {
        var lines: [String] = []
        
        if let attention = attentionLine {
            lines.append(attention)
        }
        
        lines.append(agencyName)
        lines.append(addressLine1)
        
        if let line2 = addressLine2 {
            lines.append(line2)
        }
        
        lines.append("\(city), \(state) \(zip)")
        
        return lines.joined(separator: "\n")
    }
}

// MARK: - Hardcoded Fallback Addresses

extension CityMailingAddress {
    /// Hardcoded fallback addresses when scraping fails
    public static let fallbackAddresses: [String: CityMailingAddress] = [
        "sf": CityMailingAddress(
            cityId: "sf",
            agencyName: "SFMTA Parking Citation Assistance Center",
            addressLine1: "P.O. Box 193730",
            city: "San Francisco",
            state: "CA",
            zip: "94119-3730",
            requiresCertified: true,
            sourceUrl: "hardcoded"
        ),
        "la": CityMailingAddress(
            cityId: "la",
            agencyName: "LADOT Parking Citation Processing",
            addressLine1: "P.O. Box 30247",
            city: "Los Angeles",
            state: "CA",
            zip: "90030-0247",
            requiresCertified: true,
            sourceUrl: "hardcoded"
        ),
        "nyc": CityMailingAddress(
            cityId: "nyc",
            agencyName: "NYC Department of Finance",
            addressLine1: "P.O. Box 2900",
            addressLine2: "New York, NY 10008-2900",
            city: "New York",
            state: "NY",
            zip: "10008",
            requiresCertified: true,
            sourceUrl: "hardcoded"
        ),
        "denver": CityMailingAddress(
            cityId: "denver",
            agencyName: "Denver Department of Finance",
            addressLine1: "201 W. Colfax Ave., Dept. 101",
            city: "Denver",
            state: "CO",
            zip: "80202",
            requiresCertified: true,
            sourceUrl: "hardcoded"
        )
    ]
}
