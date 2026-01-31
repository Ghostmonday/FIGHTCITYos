//
//  AppealEditorViewModel.swift
//  FightCity
//
//  ViewModel for managing appeal text refinement with DeepSeek AI
//

import Foundation
import UIKit
import FightCityFoundation
import FightCityiOS

@MainActor
public final class AppealEditorViewModel: ObservableObject {
    @Published public var originalText: String = ""
    @Published public var refinedText: String = ""
    @Published public var isRefining: Bool = false
    @Published public var refinementError: String?
    @Published public var rateLimitRetryAfter: Int? // seconds until retry allowed
    @Published public var fallbackUsed: Bool = false
    @Published public var processingTimeMs: Int = 0
    
    private let citation: Citation
    private let deviceIdentifier: String
    
    public init(citation: Citation) {
        self.citation = citation
        // Use device identifier for rate limiting
        self.deviceIdentifier = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
    }
    
    /// Refines the user's appeal text using DeepSeek AI
    public func refineAppeal() async {
        guard !originalText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            refinementError = "Please enter your appeal reason first"
            return
        }
        
        isRefining = true
        refinementError = nil
        rateLimitRetryAfter = nil
        fallbackUsed = false
        
        do {
            let request = StatementRefinementRequest(
                citationNumber: citation.citationNumber,
                appealReason: originalText,
                userName: nil, // Could be added from user profile
                cityId: citation.cityId,
                violationDate: citation.violationDate,
                vehicleInfo: citation.licensePlate
            )
            
            let response = try await DeepSeekRefinementService.shared.refineStatement(
                request,
                clientId: deviceIdentifier
            )
            
            refinedText = response.refinedText
            fallbackUsed = response.fallbackUsed
            processingTimeMs = response.processingTimeMs
            
            isRefining = false
        } catch let error as RefinementError {
            isRefining = false
            
            switch error {
            case .rateLimited(let retryAfter):
                refinementError = "Rate limit exceeded. Please try again in \(retryAfter) seconds."
                rateLimitRetryAfter = retryAfter
                startRateLimitCountdown(retryAfter)
            case .circuitBreakerOpen:
                refinementError = "AI service temporarily unavailable. Using fallback refinement."
                // Fallback will be handled by the service
                fallbackUsed = true
            default:
                refinementError = error.localizedDescription
            }
        } catch {
            isRefining = false
            refinementError = error.localizedDescription
        }
    }
    
    /// Validates that appeal text is ready to proceed
    public var canProceed: Bool {
        !refinedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    /// Starts countdown timer for rate limit
    private func startRateLimitCountdown(_ seconds: Int) {
        Task {
            for remaining in stride(from: seconds, through: 0, by: -1) {
                await MainActor.run {
                    rateLimitRetryAfter = remaining > 0 ? remaining : nil
                }
                try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
            }
        }
    }
}
