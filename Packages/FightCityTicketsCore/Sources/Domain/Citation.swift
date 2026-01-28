//
//  Citation.swift
//  FightCityTicketsCore
//
//  Citation model matching the backend API schema
//

import Foundation

/// Main citation model representing a parking ticket
public struct Citation: Identifiable, Codable, Equatable, Sendable {
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
        updatedAt: Date = Date()
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
    
    enum CodingKeys: String, CodingKey {
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
    }
}

// MARK: - Citation Status

/// Status of a citation in the appeal flow
public enum CitationStatus: String, Codable, Sendable {
    case pending
    case validated
    case inReview
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
public enum DeadlineStatus: Sendable {
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
}

// MARK: - Citation Agency

/// Known citation agencies (from backend CitationAgency enum)
public enum CitationAgency: String, Codable, CaseIterable, Sendable {
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
