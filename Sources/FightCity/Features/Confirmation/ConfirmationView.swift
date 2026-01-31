//
//  ConfirmationView.swift
//  FightCity
//
//  View for confirming extracted citation details
//

import SwiftUI
import FightCityiOS
import FightCityFoundation
import FightCityiOS

public struct ConfirmationView: View {
    let captureResult: CaptureResult
    let onConfirm: (CaptureResult) -> Void
    let onRetake: () -> Void
    let onEdit: (String) -> Void
    
    @State private var editedCitationNumber: String
    @State private var showEditSheet = false
    
    public init(captureResult: CaptureResult, onConfirm: @escaping (CaptureResult) -> Void, onRetake: @escaping () -> Void, onEdit: @escaping (String) -> Void) {
        self.captureResult = captureResult
        self.onConfirm = onConfirm
        self.onRetake = onRetake
        self.onEdit = onEdit
        self._editedCitationNumber = State(initialValue: captureResult.extractedCitationNumber ?? "")
    }
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Image preview
                imagePreviewSection
                
                // Citation details
                citationDetailsSection
                
                // Confidence indicator
                confidenceSection
                
                // Action buttons
                actionButtonsSection
            }
            .padding()
        }
        .navigationTitle("Confirm")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var imagePreviewSection: some View {
        Group {
            if let imageData = captureResult.croppedImageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 200)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                    )
            }
        }
    }
    
    private var citationDetailsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Extracted Details")
                .font(.headline)
            
            VStack(spacing: 12) {
                detailRow(label: "Citation Number", value: captureResult.extractedCitationNumber ?? "Not detected", isEditable: true)
                
                if let cityId = captureResult.extractedCityId {
                    detailRow(label: "City", value: formatCityId(cityId))
                }
                
                if let date = captureResult.extractedDate {
                    detailRow(label: "Violation Date", value: date)
                }
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
        }
    }
    
    private func detailRow(label: String, value: String, isEditable: Bool = false) -> some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
                .multilineTextAlignment(.trailing)
            if isEditable {
                Button(action: {
                    showEditSheet = true
                }) {
                    Image(systemName: "pencil.circle")
                        .foregroundColor(.accentColor)
                }
            }
        }
    }
    
    private var confidenceSection: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Recognition Confidence")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                ConfidenceIndicator(
                    confidence: captureResult.confidence,
                    level: confidenceLevel(for: captureResult.confidence)
                )
            }
            
            if captureResult.confidence < 0.85 {
                Text(confidenceMessage(for: captureResult.confidence))
                    .font(.caption)
                    .foregroundColor(.orange)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
    
    private var actionButtonsSection: some View {
        VStack(spacing: 12) {
            PrimaryButton(title: "Looks Good - Validate", action: {
                var result = captureResult
                result.extractedCitationNumber = editedCitationNumber
                onConfirm(result)
            })
            .disabled(editedCitationNumber.isEmpty)
            
            SecondaryButton(title: "Edit Number", action: {
                showEditSheet = true
            })
            
            TertiaryButton(title: "Retake Photo", action: onRetake)
        }
    }
    
    private func confidenceLevel(for confidence: Double) -> String {
        if confidence >= 0.85 { return "high" }
        if confidence >= 0.60 { return "medium" }
        return "low"
    }
    
    private func confidenceMessage(for confidence: Double) -> String {
        if confidence < 0.60 {
            return "Confidence is low. Please verify the citation number carefully or retake the photo."
        } else {
            return "Confidence is medium. Please verify the extracted information is correct."
        }
    }
    
    private func formatCityId(_ cityId: String) -> String {
        let components = cityId.components(separatedBy: "-")
        return components.dropFirst().map { $0.capitalized }.joined(separator: " ")
    }
}

// MARK: - Tertiary Button

struct TertiaryButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
    }
}

// MARK: - Citation Detail View

public struct CitationDetailView: View {
    let citation: Citation
    
    @State private var showPaymentSheet = false
    @State private var showAppealSheet = false
    
    public init(citation: Citation) {
        self.citation = citation
    }
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header card
                headerCard
                
                // Deadline card
                deadlineCard
                
                // Actions
                actionButtons
            }
            .padding()
        }
        .navigationTitle("Citation Details")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var headerCard: some View {
        CardView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(citation.citationNumber)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        if let city = citation.cityName {
                            Text(city)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    StatusBadge(status: citation.status)
                }
                
                if let amount = citation.amount {
                    Divider()
                    HStack {
                        Text("Amount Due")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(amount, format: .currency(code: "USD"))
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                }
            }
        }
    }
    
    private var deadlineCard: some View {
        CardView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Deadline")
                    .font(.headline)
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        if let deadline = citation.deadlineDate {
                            Text(deadline, style: .date)
                                .font(.title3)
                                .fontWeight(.semibold)
                        }
                        
                        if let days = citation.daysRemaining {
                            Text("\(days) days remaining")
                                .font(.subheadline)
                                .foregroundColor(deadlineColor)
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: deadlineIcon)
                        .font(.largeTitle)
                        .foregroundColor(deadlineColor)
                }
            }
        }
    }
    
    private var deadlineColor: Color {
        if citation.isPastDeadline {
            return .red
        } else if let days = citation.daysRemaining, days <= 7 {
            return .orange
        }
        return .green
    }
    
    private var deadlineIcon: String {
        if citation.isPastDeadline {
            return "exclamationmark.triangle.fill"
        } else if let days = citation.daysRemaining, days <= 7 {
            return "clock.fill"
        }
        return "checkmark.circle.fill"
    }
    
    private var actionButtons: some View {
        VStack(spacing: 12) {
            if citation.status != .paid {
                PrimaryButton(title: "Pay Fine", action: {
                    showPaymentSheet = true
                })
            }
            
            if citation.canAppealOnline && !citation.isPastDeadline {
                SecondaryButton(title: "File Appeal", action: {
                    showAppealSheet = true
                })
            }
            
            if !citation.isPastDeadline {
                TertiaryButton(title: "Set Reminder", action: {
                    // Set reminder logic
                })
            }
        }
    }
}
