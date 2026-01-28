//
//  ConfirmationView.swift
//  FightCityTickets
//
//  Confirmation screen with YES/EDIT workflow
//

import SwiftUI

struct ConfirmationView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @StateObject private var viewModel: ConfirmationViewModel
    @State private var showingEditSheet = false
    
    init(captureResult: CaptureResult) {
        _viewModel = StateObject(wrappedValue: ConfirmationViewModel(captureResult: copyResult(captureResult)))
    }
    
    static func copyResult(_ result: CaptureResult) -> CaptureResult {
        CaptureResult(
            id: result.id,
            originalImageData: result.originalImageData,
            croppedImageData: result.croppedImageData,
            rawText: result.rawText,
            extractedCitationNumber: result.extractedCitationNumber,
            extractedCityId: result.extractedCityId,
            extractedDate: result.extractedDate,
            confidence: result.confidence,
            processingTimeMs: result.processingTimeMs,
            boundingBoxes: result.boundingBoxes,
            capturedAt: result.capturedAt
        )
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Captured image preview
                imagePreview
                
                // Confidence indicator
                confidenceSection
                
                // Extracted info
                extractedInfoSection
                
                // Action buttons
                actionButtons
            }
            .padding()
        }
        .background(AppColors.background)
        .navigationTitle("Confirm")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingEditSheet) {
            EditCitationSheet(captureResult: viewModel.captureResult) { editedNumber in
                viewModel.onCitationEdited(editedNumber)
            }
        }
        .alert("Validation", isPresented: $viewModel.showValidationResult) {
            Button("Continue") {
                if viewModel.validationResult?.is_valid == true {
                    // Proceed to next step
                }
            }
        } message: {
            if let result = viewModel.validationResult {
                Text(result.error_message ?? "Citation validated successfully!")
            }
        }
    }
    
    // MARK: - Image Preview
    
    private var imagePreview: some View {
        Group {
            if let imageData = viewModel.captureResult.originalImageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 250)
                    .cornerRadius(12)
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppColors.secondaryBackground)
                    .frame(height: 200)
                    .overlay(
                        Image(systemName: "doc.text")
                            .font(.largeTitle)
                            .foregroundColor(AppColors.textSecondary)
                    )
            }
        }
    }
    
    // MARK: - Confidence Section
    
    private var confidenceSection: some View {
        HStack(spacing: 24) {
            ConfidenceIndicator(
                confidence: viewModel.captureResult.confidence,
                label: "Confidence"
            )
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Is this correct?")
                    .titleMedium()
                
                Text(ConfidenceScorer.confidenceMessage(for: viewModel.confidenceLevel))
                    .bodySmall()
                    .foregroundColor(AppColors.textSecondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(AppColors.secondaryBackground)
        )
    }
    
    // MARK: - Extracted Info
    
    private var extractedInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Extracted Information")
                .titleMedium()
            
            VStack(spacing: 12) {
                InfoRow(
                    label: "Citation Number",
                    value: viewModel.formattedCitationNumber,
                    isUrgent: false
                )
                
                if let cityId = viewModel.captureResult.extractedCityId,
                   let cityConfig = AppConfig.shared.cityConfig(for: cityId) {
                    InfoRow(
                        label: "City",
                        value: cityConfig.name
                    )
                }
                
                InfoRow(
                    label: "Raw Text",
                    value: viewModel.captureResult.rawText
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(AppColors.secondaryBackground)
        )
    }
    
    // MARK: - Action Buttons
    
    private var actionButtons: some View {
        VStack(spacing: 16) {
            PrimaryButton(
                title: "Yes, Continue",
                action: { viewModel.confirmCitation() }
            )
            .disabled(viewModel.isValidating)
            
            SecondaryButton(
                title: "Edit Citation",
                action: { showingEditSheet = true }
            )
            
            SecondaryButton(
                title: "Retake Photo",
                action: { coordinator.navigateBack() }
            )
        }
    }
    
    // MARK: - Computed Properties
    
    private var confidenceLevel: ConfidenceScorer.ConfidenceLevel {
        viewModel.captureResult.confidenceLevel
    }
    
    private var formattedCitationNumber: String {
        guard let number = viewModel.captureResult.extractedCitationNumber else {
            return "Not detected"
        }
        
        if let cityId = viewModel.captureResult.extractedCityId {
            return AppConfig.shared.formatCitation(number, cityId: cityId)
        }
        return number
    }
}

// MARK: - Edit Citation Sheet

struct EditCitationSheet: View {
    @Environment(\.dismiss) var dismiss
    let captureResult: CaptureResult
    let onSubmit: (String) -> Void
    
    @State private var editedCitation: String
    @State private var cityId: String?
    
    init(captureResult: CaptureResult, onSubmit: @escaping (String) -> Void) {
        self.captureResult = captureResult
        self.onSubmit = onSubmit
        _editedCitation = State(initialValue: captureResult.extractedCitationNumber ?? "")
        _cityId = State(initialValue: captureResult.extractedCityId)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Citation Number") {
                    TextField("Enter citation number", text: $editedCitation)
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled()
                }
                
                if let cityId = cityId,
                   let cityConfig = AppConfig.shared.cityConfig(for: cityId) {
                    Section("Detected City") {
                        HStack {
                            Text("City")
                            Spacer()
                            Text(cityConfig.name)
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }
                }
                
                Section {
                    Text("Please verify the citation number matches exactly what's on your ticket.")
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                }
            }
            .navigationTitle("Edit Citation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Confirm") {
                        onSubmit(editedCitation)
                        dismiss()
                    }
                    .disabled(editedCitation.count < 5)
                }
            }
        }
    }
}

#if DEBUG
struct ConfirmationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ConfirmationView(
                captureResult: CaptureResult(
                    rawText: "SFMTA91234567",
                    extractedCitationNumber: "SFMTA91234567",
                    extractedCityId: "us-ca-san_francisco",
                    confidence: 0.92
                )
            )
            .environmentObject(AppCoordinator())
        }
    }
}
#endif
