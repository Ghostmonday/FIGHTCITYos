//
//  ConfirmationViewModel.swift
//  FightCityTickets
//
//  ViewModel for confirmation screen
//

import SwiftUI
import Combine

@MainActor
final class ConfirmationViewModel: ObservableObject {
    // MARK: - Published State
    
    @Published var captureResult: CaptureResult
    @Published var isValidating = false
    @Published var showValidationResult = false
    @Published var validationResult: CitationValidationResponse?
    @Published var errorMessage = ""
    
    // MARK: - Computed Properties
    
    var confidenceLevel: ConfidenceScorer.ConfidenceLevel {
        captureResult.confidenceLevel
    }
    
    var formattedCitationNumber: String {
        guard let number = captureResult.extractedCitationNumber else {
            return "Not detected"
        }
        
        if let cityId = captureResult.extractedCityId {
            return AppConfig.shared.formatCitation(number, cityId: cityId)
        }
        return number
    }
    
    // MARK: - Initialization
    
    init(captureResult: CaptureResult) {
        self.captureResult = captureResult
    }
    
    // MARK: - Actions
    
    func confirmCitation() {
        guard let citationNumber = captureResult.extractedCitationNumber else {
            errorMessage = "No citation number to confirm"
            return
        }
        
        isValidating = true
        
        Task {
            do {
                // Validate against backend API
                let request = CitationValidationRequest(
                    citation_number: citationNumber,
                    city_id: captureResult.extractedCityId
                )
                
                let response: CitationValidationResponse = try await APIClient.shared.post(
                    .validateCitation(request),
                    body: request
                )
                
                validationResult = response
                showValidationResult = true
                
                // Update capture result with validated info
                if response.is_valid {
                    captureResult.extractedCityId = response.city_id
                }
                
            } catch {
                errorMessage = error.localizedDescription
                showValidationResult = true
            }
            
            isValidating = false
        }
    }
    
    func onCitationEdited(_ newCitationNumber: String) {
        captureResult.extractedCitationNumber = newCitationNumber
        captureResult.confidence = 1.0 // Manual entry has full confidence
        
        // Try to detect city from new number
        if let cityConfig = AppConfig.shared.cityConfig(for: newCitationNumber) {
            captureResult.extractedCityId = cityConfig.id
        }
    }
}
