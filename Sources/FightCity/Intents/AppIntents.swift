//
//  AppIntents.swift
//  FightCity
//
//  App Intents for Siri Shortcuts integration
//

import AppIntents
import SwiftUI

import os.log

/// APPLE INTELLIGENCE: App Intents for Siri Shortcuts integration
/// APPLE INTELLIGENCE: Enable "Scan Ticket" and "Contest Last Ticket" shortcuts
/// APPLE INTELLIGENCE: iOS 16+ App Intents framework

// MARK: - Scan Ticket Intent

/// Intent to scan a parking ticket
@available(iOS 16.0, *)
struct ScanTicketIntent: AppIntent {
    static var title: LocalizedStringResource = "Scan Parking Ticket"
    static var description = IntentDescription("Scan a parking ticket to extract citation information")
    
    static var openAppWhenRun: Bool = true
    
    func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        return .result(
            dialog: "Opening camera to scan your ticket"
        )
    }
}

// MARK: - Contest Ticket Intent

/// Intent to contest the last scanned ticket
@available(iOS 16.0, *)
struct ContestTicketIntent: AppIntent {
    static var title: LocalizedStringResource = "Contest Last Ticket"
    static var description = IntentDescription("Start an appeal for your most recently scanned ticket")
    
    static var openAppWhenRun: Bool = true
    
    func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        return .result(
            dialog: "Opening your last scanned ticket for appeal"
        )
    }
}

// MARK: - Check Citation Status Intent

/// Intent to check the status of a citation
@available(iOS 16.0, *)
struct CheckCitationStatusIntent: AppIntent {
    static var title: LocalizedStringResource = "Check Citation Status"
    static var description = IntentDescription("Check the status of a parking citation")
    
    @Parameter(title: "Citation Number")
    var citationNumber: String
    
    init() {
        self.citationNumber = ""
    }
    
    init(citationNumber: String) {
        self.citationNumber = citationNumber
    }
    
    static var parameterSummary: some ParameterSummary {
        Summary("Check status for \(\.$citationNumber)")
    }
    
    func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        // Would check citation status here
        return .result(
            dialog: "Checking status for citation \(citationNumber)"
        )
    }
}

// MARK: - App Shortcuts Provider

/// Provides app shortcuts to the system
@available(iOS 16.0, *)
struct AppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: ScanTicketIntent(),
            phrases: [
                "Scan my parking ticket with \(.applicationName)",
                "Take a photo of my ticket with \(.applicationName)",
                "Use \(.applicationName) to scan a ticket"
            ],
            shortTitle: "Scan Ticket",
            systemImageName: "camera.fill"
        )
        
        AppShortcut(
            intent: ContestTicketIntent(),
            phrases: [
                "Contest my last ticket with \(.applicationName)",
                "Appeal my ticket with \(.applicationName)",
                "Fight my parking ticket with \(.applicationName)"
            ],
            shortTitle: "Contest Ticket",
            systemImageName: "doc.text.fill"
        )
        
        AppShortcut(
            intent: CheckCitationStatusIntent(),
            phrases: [
                "Check my citation status with \(.applicationName)",
                "What's the status of my ticket with \(.applicationName)"
            ],
            shortTitle: "Check Status",
            systemImageName: "magnifyingglass"
        )
    }
}

// MARK: - Donation Handling Intent

/// Intent for handling donation from Shortcuts
@available(iOS 16.0, *)
struct DonateTicketIntent: AppIntent {
    static var title: LocalizedStringResource = "Log Ticket"
    static var description = IntentDescription("Log a parking ticket citation from another app")
    
    @Parameter(title: "Citation Number")
    var citationNumber: String
    
    @Parameter(title: "City")
    var city: String?
    
    init() {
        self.citationNumber = ""
        self.city = nil
    }
    
    init(citationNumber: String, city: String? = nil) {
        self.citationNumber = citationNumber
        self.city = city
    }
    
    static var parameterSummary: some ParameterSummary {
        Summary("Log \(\.$citationNumber)") {
            \.$city
        }
    }
    
    func perform() async throws -> some IntentResult & ProvidesDialog {
        return .result(
            dialog: "Ticket \(citationNumber) logged successfully"
        )
    }
}

// MARK: - Live Activity Intent

/// Intent for Live Activity updates
@available(iOS 16.0, *)
struct UpdateDeadlineIntent: AppIntent {
    static var title: LocalizedStringResource = "Update Deadline"
    static var description = IntentDescription("Update the appeal deadline for a citation")
    
    @Parameter(title: "Citation Number")
    var citationNumber: String
    
    @Parameter(title: "Days Remaining")
    var daysRemaining: Int
    
    init() {
        self.citationNumber = ""
        self.daysRemaining = 0
    }
    
    init(citationNumber: String, daysRemaining: Int) {
        self.citationNumber = citationNumber
        self.daysRemaining = daysRemaining
    }
    
    static var parameterSummary: some ParameterSummary {
        Summary("Update deadline for \(\.$citationNumber) to \(\.$daysRemaining) days")
    }
    
    func perform() async throws -> some IntentResult & ProvidesDialog {
        return .result(
            dialog: "Deadline updated: \(daysRemaining) days remaining for \(citationNumber)"
        )
    }
}

// MARK: - Widget Configuration Intent

/// Intent for widget configuration
@available(iOS 16.0, *)
struct ConfigureDeadlineWidgetIntent: AppIntent {
    static var title: LocalizedStringResource = "Configure Widget"
    static var description = IntentDescription("Configure which citation to show in widget")
    
    @Parameter(title: "Citation")
    var citationIdentifier: String?
    
    init() {
        self.citationIdentifier = nil
    }
    
    init(citationIdentifier: String?) {
        self.citationIdentifier = citationIdentifier
    }
    
    func perform() async throws -> some IntentResult & ProvidesDialog {
        return .result(
            dialog: "Widget configured"
        )
    }
}

// MARK: - Siri Voice Commands

extension ScanTicketIntent {
    /// Custom Siri voice command responses
    var dialog: String {
        "I've opened the camera. Position your ticket in the frame."
    }
}

extension ContestTicketIntent {
    /// Custom Siri voice command responses
    var dialog: String {
        "Let me pull up your last scanned ticket so you can start an appeal."
    }
}

// MARK: - Intent Convenience Methods

extension ScanTicketIntent {
    /// Convenience method to create scan intent
    public static var scanTicket: ScanTicketIntent {
        ScanTicketIntent()
    }
}

extension ContestTicketIntent {
    /// Convenience method to create contest intent
    public static var contestTicket: ContestTicketIntent {
        ContestTicketIntent()
    }
}
