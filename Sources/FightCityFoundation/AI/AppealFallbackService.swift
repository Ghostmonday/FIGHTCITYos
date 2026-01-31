//
//  AppealFallbackService.swift
//  FightCityFoundation
//
//  Static appeal templates for when Apple Intelligence is unavailable
//

import Foundation

/// Static appeal templates for fallback scenarios
public struct AppealTemplate {
    public let id: String
    public let name: String
    public let tone: AppealTone
    public let template: String // Placeholder-based text
    public let requiredFields: [String] // "citation_number", "city", "reason"
    public let cityCompatibility: [String]? // nil = all cities
    
    public init(
        id: String,
        name: String,
        tone: AppealTone,
        template: String,
        requiredFields: [String] = ["citation_number", "reason"],
        cityCompatibility: [String]? = nil
    ) {
        self.id = id
        self.name = name
        self.tone = tone
        self.template = template
        self.requiredFields = requiredFields
        self.cityCompatibility = cityCompatibility
    }
}

/// Service for generating appeals from static templates
public final class AppealFallbackService {
    public static let shared = AppealFallbackService()
    
    private let templates: [AppealTemplate]
    
    private init() {
        self.templates = Self.createTemplates()
    }
    
    /// Generates an appeal from a template
    ///
    /// - Parameters:
    ///   - template: The template to use
    ///   - context: Appeal context with citation and user reason
    /// - Returns: Generated appeal text
    public func generateFromTemplate(
        template: AppealTemplate,
        context: AppealContext
    ) -> AppealGenerationResult {
        let startTime = Date()
        
        // Replace placeholders in template
        var appealText = template.template
        
        // Replace citation number
        appealText = appealText.replacingOccurrences(
            of: "[citation_number]",
            with: context.citationNumber
        )
        
        // Replace city name
        appealText = appealText.replacingOccurrences(
            of: "[city]",
            with: context.cityName
        )
        
        // Replace user reason
        appealText = appealText.replacingOccurrences(
            of: "[reason]",
            with: context.userReason
        )
        
        // Replace violation date if available
        if let date = context.violationDate {
            let formatter = DateFormatter()
            formatter.dateStyle = .long
            appealText = appealText.replacingOccurrences(
                of: "[violation_date]",
                with: formatter.string(from: date)
            )
        }
        
        // Replace violation code if available
        if let code = context.violationCode {
            appealText = appealText.replacingOccurrences(
                of: "[violation_code]",
                with: code
            )
        }
        
        // Replace amount if available
        if let amount = context.amount {
            appealText = appealText.replacingOccurrences(
                of: "[amount]",
                with: String(format: "$%.2f", amount)
            )
        }
        
        // Add header
        let header = generateHeader(for: context)
        let fullAppeal = "\(header)\n\n\(appealText)"
        
        let processingTime = Int(Date().timeIntervalSince(startTime) * 1000)
        let wordCount = fullAppeal.split(separator: " ").count
        
        return AppealGenerationResult(
            appealText: fullAppeal,
            tone: template.tone,
            sentimentScore: 0.5, // Neutral for templates
            clarityScore: 0.8, // Templates are pre-written, so high clarity
            suggestions: [],
            wordCount: wordCount,
            processingTimeMs: processingTime
        )
    }
    
    /// Selects the best template for the given context
    ///
    /// - Parameter context: Appeal context
    /// - Returns: Best matching template
    public func selectBestTemplate(for context: AppealContext) -> AppealTemplate {
        // Filter by city compatibility if specified
        let compatibleTemplates = templates.filter { template in
            guard let cities = template.cityCompatibility else { return true }
            return cities.contains(context.cityName.lowercased())
        }
        
        // For now, return general appeal template
        // In future, could use keyword matching on userReason
        return compatibleTemplates.first { $0.id == "general_signage" } ??
               compatibleTemplates.first ??
               templates.first!
    }
    
    /// Gets all available templates
    public func getAllTemplates() -> [AppealTemplate] {
        return templates
    }
    
    /// Gets a template by ID
    public func getTemplate(id: String) -> AppealTemplate? {
        return templates.first { $0.id == id }
    }
    
    // MARK: - Private Methods
    
    private func generateHeader(for context: AppealContext) -> String {
        var header = "To Whom It May Concern,\n\n"
        header += "Re: Appeal of Parking Citation \(context.citationNumber)\n\n"
        
        if let date = context.violationDate {
            let formatter = DateFormatter()
            formatter.dateStyle = .long
            header += "Date of Violation: \(formatter.string(from: date))\n"
        }
        
        if let code = context.violationCode {
            header += "Violation Code: \(code)\n"
        }
        
        if let amount = context.amount {
            header += String(format: "Penalty Amount: $%.2f\n", amount)
        }
        
        return header
    }
    
    // MARK: - Template Definitions
    
    private static func createTemplates() -> [AppealTemplate] {
        [
            // Template 1: General Signage Confusion
            AppealTemplate(
                id: "general_signage",
                name: "Unclear Signage",
                tone: .respectful,
                template: """
                I am writing to formally appeal the parking citation referenced above.
                
                The parking signage at the location where I was parked was unclear, ambiguous, or obscured at the time of the violation. Specifically, [reason].
                
                I respectfully request that you review the circumstances and consider dismissing this citation, as the signage did not provide adequate notice of the parking restrictions.
                
                Thank you for your consideration.
                
                Respectfully submitted,
                """,
                requiredFields: ["citation_number", "reason"]
            ),
            
            // Template 2: Meter Malfunction
            AppealTemplate(
                id: "meter_malfunction",
                name: "Meter Malfunction",
                tone: .factual,
                template: """
                I am writing to formally appeal the parking citation referenced above.
                
                The parking meter at the space where I was parked was not functioning properly at the time of the violation. [reason]
                
                I attempted to pay for parking, but the meter did not accept payment or did not display the correct time remaining. This mechanical failure was beyond my control.
                
                I respectfully request that this citation be reviewed and dismissed due to the meter malfunction.
                
                Respectfully submitted,
                """,
                requiredFields: ["citation_number", "reason"]
            ),
            
            // Template 3: Time Limit Violation - Valid Receipt
            AppealTemplate(
                id: "valid_receipt",
                name: "Valid Payment Receipt",
                tone: .factual,
                template: """
                I am writing to formally appeal the parking citation referenced above.
                
                I paid for parking via [payment_method] and have proof of payment. [reason]
                
                Despite having a valid payment receipt, I received this citation. I believe this was issued in error, as I was in compliance with the parking regulations at the time.
                
                I respectfully request that you review my payment records and dismiss this citation.
                
                Respectfully submitted,
                """,
                requiredFields: ["citation_number", "reason"]
            ),
            
            // Template 4: Medical Emergency
            AppealTemplate(
                id: "medical_emergency",
                name: "Medical Emergency",
                tone: .respectful,
                template: """
                I am writing to formally appeal the parking citation referenced above.
                
                I parked in violation due to a medical emergency requiring immediate attention. [reason]
                
                The circumstances were beyond my control and required immediate action. I understand the importance of parking regulations, but this situation warranted an exception.
                
                I respectfully request that you consider these extenuating circumstances and dismiss this citation.
                
                Respectfully submitted,
                """,
                requiredFields: ["citation_number", "reason"]
            ),
            
            // Template 5: Vehicle Breakdown
            AppealTemplate(
                id: "vehicle_breakdown",
                name: "Vehicle Breakdown",
                tone: .factual,
                template: """
                I am writing to formally appeal the parking citation referenced above.
                
                My vehicle experienced mechanical failure and could not be moved safely at the time of the violation. [reason]
                
                The vehicle was disabled due to mechanical issues that occurred unexpectedly. I took appropriate steps to address the situation as quickly as possible, but the vehicle could not be moved immediately.
                
                I respectfully request that you consider these circumstances and dismiss this citation.
                
                Respectfully submitted,
                """
            )
        ]
    }
}
