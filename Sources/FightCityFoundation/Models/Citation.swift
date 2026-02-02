//
//  Citation.swift
//  FightCityFoundation
//
//  Citation model matching the backend API schema
//

import Foundation

/// Main citation model representing a parking ticket
///
/// APP STORE READINESS: Citation model is core data structure - must be robust
/// DATA INTEGRITY: All validation should happen before creating Citation instances
/// TODO APP STORE: Add data validation methods (validateCitationNumber, validateDate, etc.)
/// TODO ENHANCEMENT: Add support for different citation formats per city
/// TODO PERSISTENCE: Implement CoreData or SwiftData persistence layer
/// SECURITY: Never log citation data in production (contains PII)
/// PERFORMANCE: Keep model lightweight for list rendering performance
/// NOTE: Model matches backend API schema - keep in sync with server
public struct Citation: Identifiable, Codable, Equatable {
    public let id: UUID
    public let citationNumber: String
    public let cityId: String?
    public let cityName: String?
    public let agency: String?
    public let sectionId: String?
    public let formattedCitation: String?
    public let licensePlate: String?
    public let violationDate: String?
    public let violationTime: String?
    public let amount: Decimal?
    public let deadlineDate: String?
    public let daysRemaining: Int?
    public let isPastDeadline: Bool
    public let isUrgent: Bool
    public let canAppealOnline: Bool
    public let phoneConfirmationRequired: Bool
    public let status: CitationStatus
    public let createdAt: Date
    public let updatedAt: Date
    
    // MARK: - Mailing Status (Certified Mail)
    
    public let mailingStatus: MailingStatus?
    public let lobLetterId: String?
    public let trackingNumber: String?
    public let expectedDeliveryDate: Date?
    
    public init(
        id: UUID = UUID(),
        citationNumber: String,
        cityId: String? = nil,
        cityName: String? = nil,
        agency: String? = nil,
        sectionId: String? = nil,
        formattedCitation: String? = nil,
        licensePlate: String? = nil,
        violationDate: String? = nil,
        violationTime: String? = nil,
        amount: Decimal? = nil,
        deadlineDate: String? = nil,
        daysRemaining: Int? = nil,
        isPastDeadline: Bool = false,
        isUrgent: Bool = false,
        canAppealOnline: Bool = true,
        phoneConfirmationRequired: Bool = false,
        status: CitationStatus = .pending,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        mailingStatus: MailingStatus? = nil,
        lobLetterId: String? = nil,
        trackingNumber: String? = nil,
        expectedDeliveryDate: Date? = nil
    ) {
        self.id = id
        self.citationNumber = citationNumber
        self.cityId = cityId
        self.cityName = cityName
        self.agency = agency
        self.sectionId = sectionId
        self.formattedCitation = formattedCitation
        self.licensePlate = licensePlate
        self.violationDate = violationDate
        self.violationTime = violationTime
        self.amount = amount
        self.deadlineDate = deadlineDate
        self.daysRemaining = daysRemaining
        self.isPastDeadline = isPastDeadline
        self.isUrgent = isUrgent
        self.canAppealOnline = canAppealOnline
        self.phoneConfirmationRequired = phoneConfirmationRequired
        self.status = status
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.mailingStatus = mailingStatus
        self.lobLetterId = lobLetterId
        self.trackingNumber = trackingNumber
        self.expectedDeliveryDate = expectedDeliveryDate
    }
    
    // MARK: - Computed Properties
    
    public var displayCitationNumber: String {
        formattedCitation ?? citationNumber
    }
    
    public var deadlineStatus: DeadlineStatus {
        if isPastDeadline {
            return .past
        } else if isUrgent {
            return .urgent
        } else if let days = daysRemaining, days <= 7 {
            return .approaching
        } else {
            return .safe
        }
    }
    
    public var isValidatable: Bool {
        !citationNumber.isEmpty && citationNumber.count >= 5
    }
    
    // MARK: - Coding Keys
    
    public enum CodingKeys: String, CodingKey {
        case id
        case citation_number
        case city_id
        case city_name
        case agency
        case section_id
        case formatted_citation
        case license_plate
        case violation_date
        case violation_time
        case amount
        case deadline_date
        case days_remaining
        case is_past_deadline
        case is_urgent
        case can_appeal_online
        case phone_confirmation_required
        case status
        case created_at
        case updated_at
        case mailing_status
        case lob_letter_id
        case tracking_number
        case expected_delivery_date
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        citationNumber = try container.decode(String.self, forKey: .citation_number)
        cityId = try container.decodeIfPresent(String.self, forKey: .city_id)
        cityName = try container.decodeIfPresent(String.self, forKey: .city_name)
        agency = try container.decodeIfPresent(String.self, forKey: .agency)
        sectionId = try container.decodeIfPresent(String.self, forKey: .section_id)
        formattedCitation = try container.decodeIfPresent(String.self, forKey: .formatted_citation)
        licensePlate = try container.decodeIfPresent(String.self, forKey: .license_plate)
        violationDate = try container.decodeIfPresent(String.self, forKey: .violation_date)
        violationTime = try container.decodeIfPresent(String.self, forKey: .violation_time)
        amount = try container.decodeIfPresent(Decimal.self, forKey: .amount)
        deadlineDate = try container.decodeIfPresent(String.self, forKey: .deadline_date)
        daysRemaining = try container.decodeIfPresent(Int.self, forKey: .days_remaining)
        isPastDeadline = try container.decode(Bool.self, forKey: .is_past_deadline)
        isUrgent = try container.decode(Bool.self, forKey: .is_urgent)
        canAppealOnline = try container.decode(Bool.self, forKey: .can_appeal_online)
        phoneConfirmationRequired = try container.decode(Bool.self, forKey: .phone_confirmation_required)
        status = try container.decodeIfPresent(CitationStatus.self, forKey: .status) ?? .pending
        createdAt = try container.decodeIfPresent(Date.self, forKey: .created_at) ?? Date()
        updatedAt = try container.decodeIfPresent(Date.self, forKey: .updated_at) ?? Date()
        mailingStatus = try container.decodeIfPresent(MailingStatus.self, forKey: .mailing_status)
        lobLetterId = try container.decodeIfPresent(String.self, forKey: .lob_letter_id)
        trackingNumber = try container.decodeIfPresent(String.self, forKey: .tracking_number)
        expectedDeliveryDate = try container.decodeIfPresent(Date.self, forKey: .expected_delivery_date)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(citationNumber, forKey: .citation_number)
        try container.encodeIfPresent(cityId, forKey: .city_id)
        try container.encodeIfPresent(cityName, forKey: .city_name)
        try container.encodeIfPresent(agency, forKey: .agency)
        try container.encodeIfPresent(sectionId, forKey: .section_id)
        try container.encodeIfPresent(formattedCitation, forKey: .formatted_citation)
        try container.encodeIfPresent(licensePlate, forKey: .license_plate)
        try container.encodeIfPresent(violationDate, forKey: .violation_date)
        try container.encodeIfPresent(violationTime, forKey: .violation_time)
        try container.encodeIfPresent(amount, forKey: .amount)
        try container.encodeIfPresent(deadlineDate, forKey: .deadline_date)
        try container.encodeIfPresent(daysRemaining, forKey: .days_remaining)
        try container.encode(isPastDeadline, forKey: .is_past_deadline)
        try container.encode(isUrgent, forKey: .is_urgent)
        try container.encode(canAppealOnline, forKey: .can_appeal_online)
        try container.encode(phoneConfirmationRequired, forKey: .phone_confirmation_required)
        try container.encode(status, forKey: .status)
        try container.encode(createdAt, forKey: .created_at)
        try container.encode(updatedAt, forKey: .updated_at)
        try container.encodeIfPresent(mailingStatus, forKey: .mailing_status)
        try container.encodeIfPresent(lobLetterId, forKey: .lob_letter_id)
        try container.encodeIfPresent(trackingNumber, forKey: .tracking_number)
        try container.encodeIfPresent(expectedDeliveryDate, forKey: .expected_delivery_date)
    }
}

// MARK: - Citation Status

/// Status of a citation in the appeal flow
public enum CitationStatus: String, Codable {
    case pending
    case validated
    case inReview = "in_review"
    case appealed
    case approved
    case denied
    case paid
    case expired
    
    public var displayName: String {
        switch self {
        case .pending: return "Pending"
        case .validated: return "Validated"
        case .inReview: return "In Review"
        case .appealed: return "Appealed"
        case .approved: return "Approved"
        case .denied: return "Denied"
        case .paid: return "Paid"
        case .expired: return "Expired"
        }
    }
}

// MARK: - Deadline Status

/// Deadline urgency status
public enum DeadlineStatus {
    case safe
    case approaching
    case urgent
    case past
    
    public var displayText: String {
        switch self {
        case .safe: return "On Track"
        case .approaching: return "Approaching"
        case .urgent: return "Urgent"
        case .past: return "Past Due"
        }
    }
    
    public var colorName: String {
        switch self {
        case .safe: return "deadlineSafe"
        case .approaching: return "deadlineApproaching"
        case .urgent: return "deadlineUrgent"
        case .past: return "deadlineUrgent"
        }
    }
}

// MARK: - Mailing Status

/// Status of certified mail delivery via Lob
public enum MailingStatus: String, Codable {
    case queued
    case processing
    case mailed
    case inTransit = "in_transit"
    case delivered
    case returned
    
    public var displayName: String {
        switch self {
        case .queued: return "Queued"
        case .processing: return "Processing"
        case .mailed: return "Mailed"
        case .inTransit: return "In Transit"
        case .delivered: return "Delivered"
        case .returned: return "Returned"
        }
    }
}

// MARK: - Citation Agency

/// Known citation agencies (from backend CitationAgency enum)
public enum CitationAgency: String, Codable, CaseIterable {
    case unknown = "UNKNOWN"
    case sfMta = "SFMTA"
    case sfPd = "SFPD"
    case laDot = "LADOT"
    case laXd = "LAXD"
    case laPd = "LAPD"
    case nycDo = "NYC_DO"
    case nycPd = "NYPD"
    case denver = "DENVER"
    
    public var displayName: String {
        switch self {
        case .unknown: return "Unknown"
        case .sfMta: return "SFMTA"
        case .sfPd: return "SFPD"
        case .laDot: return "LADOT"
        case .laXd: return "LAX"
        case .laPd: return "LAPD"
        case .nycDo: return "NYC DOF"
        case .nycPd: return "NYPD"
        case .denver: return "Denver"
        }
    }
}
