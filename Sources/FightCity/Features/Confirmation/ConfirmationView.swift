//
//  ConfirmationView.swift
//  FightCity
//
//  Premium confirmation flow with confidence visualization
//  Apple Design Award quality details display
//

import SwiftUI
import FightCityiOS
import FightCityFoundation

// MARK: - Confirmation View

public struct ConfirmationView: View {
    let captureResult: CaptureResult
    let onConfirm: (CaptureResult) -> Void
    let onRetake: () -> Void
    let onEdit: (String) -> Void
    
    @State private var editedCitationNumber: String
    @State private var showEditSheet = false
    @State private var hasAppeared = false
    @State private var showAppealEditor = false
    @State private var showCertifiedMailSheet = false
    @State private var generatedAppeal: String?
    @State private var citation: Citation?
    
    public init(
        captureResult: CaptureResult,
        onConfirm: @escaping (CaptureResult) -> Void,
        onRetake: @escaping () -> Void,
        onEdit: @escaping (String) -> Void
    ) {
        self.captureResult = captureResult
        self.onConfirm = onConfirm
        self.onRetake = onRetake
        self.onEdit = onEdit
        self._editedCitationNumber = State(initialValue: captureResult.extractedCitationNumber ?? "")
    }
    
    public var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Image preview
                    imagePreview
                        .opacity(hasAppeared ? 1 : 0)
                        .offset(y: hasAppeared ? 0 : 20)
                        .animation(.easeOut(duration: 0.4), value: hasAppeared)
                    
                    // Extracted data card
                    extractedDataCard
                        .opacity(hasAppeared ? 1 : 0)
                        .offset(y: hasAppeared ? 0 : 20)
                        .animation(.easeOut(duration: 0.4).delay(0.1), value: hasAppeared)
                    
                    // Confidence indicator
                    confidenceCard
                        .opacity(hasAppeared ? 1 : 0)
                        .offset(y: hasAppeared ? 0 : 20)
                        .animation(.easeOut(duration: 0.4).delay(0.2), value: hasAppeared)
                    
                    // Next steps
                    nextStepsCard
                        .opacity(hasAppeared ? 1 : 0)
                        .offset(y: hasAppeared ? 0 : 20)
                        .animation(.easeOut(duration: 0.4).delay(0.3), value: hasAppeared)
                    
                    // Action buttons
                    actionButtons
                        .opacity(hasAppeared ? 1 : 0)
                        .animation(.easeOut(duration: 0.4).delay(0.4), value: hasAppeared)
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
        }
        .navigationTitle("Confirm")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    FCHaptics.lightImpact()
                    onRetake()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(AppColors.gold)
                }
            }
        }
        .onAppear {
            FCHaptics.prepare()
            withAnimation {
                hasAppeared = true
            }
        }
        .sheet(isPresented: $showEditSheet) {
            editSheet
        }
        .sheet(isPresented: $showAppealEditor) {
            if let citation = citation {
                NavigationStack {
                    AppealEditorView(
                        citation: citation,
                        onContinue: { appealText in
                            generatedAppeal = appealText
                            showAppealEditor = false
                            showCertifiedMailSheet = true
                        },
                        onCancel: {
                            showAppealEditor = false
                        }
                    )
                }
            }
        }
        .sheet(isPresented: $showCertifiedMailSheet) {
            if let citation = citation, let appealText = generatedAppeal {
                CertifiedMailConfirmationSheet(
                    citation: citation,
                    appealText: appealText
                )
            }
        }
        .preferredColorScheme(.dark)
    }
    
    // MARK: - Image Preview
    
    private var imagePreview: some View {
        Group {
            if let imageData = captureResult.croppedImageData ?? captureResult.originalImageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 180)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(AppColors.glassBorder, lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.3), radius: 10, y: 5)
            } else {
                // Placeholder when no image
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppColors.surface)
                    .frame(height: 120)
                    .overlay(
                        VStack(spacing: 8) {
                            Image(systemName: "photo")
                                .font(.system(size: 32))
                                .foregroundColor(AppColors.textTertiary)
                            Text("Manual Entry")
                                .font(.system(size: 14))
                                .foregroundColor(AppColors.textTertiary)
                        }
                    )
            }
        }
    }
    
    // MARK: - Extracted Data Card
    
    private var extractedDataCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Extracted Details")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(AppColors.textTertiary)
                    .textCase(.uppercase)
                    .tracking(1)
                
                Spacer()
                
                // AI badge
                HStack(spacing: 4) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 10))
                    Text("AI")
                        .font(.system(size: 11, weight: .semibold))
                }
                .foregroundColor(AppColors.gold)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(AppColors.gold.opacity(0.15))
                .cornerRadius(12)
            }
            
            VStack(spacing: 16) {
                // Citation number (main)
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Citation Number")
                            .font(.system(size: 13))
                            .foregroundColor(AppColors.textSecondary)
                        
                        Text(editedCitationNumber.isEmpty ? "Not detected" : editedCitationNumber)
                            .font(.system(size: 24, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        FCHaptics.lightImpact()
                        showEditSheet = true
                    }) {
                        Image(systemName: "pencil.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(AppColors.gold)
                    }
                }
                
                Divider()
                    .background(AppColors.glassBorder)
                
                // Additional details
                if let cityId = captureResult.extractedCityId {
                    detailRow(label: "City", value: formatCityId(cityId))
                }
                
                if let date = captureResult.extractedDate {
                    detailRow(label: "Violation Date", value: date)
                }
            }
            .padding(16)
            .background(AppColors.surface)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(AppColors.glassBorder, lineWidth: 1)
            )
        }
    }
    
    private func detailRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 15))
                .foregroundColor(AppColors.textSecondary)
            Spacer()
            Text(value)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.white)
        }
    }
    
    // MARK: - Confidence Card
    
    private var confidenceCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recognition Confidence")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(AppColors.textTertiary)
                .textCase(.uppercase)
                .tracking(1)
            
            HStack(spacing: 16) {
                // Progress ring
                ZStack {
                    Circle()
                        .stroke(AppColors.surface, lineWidth: 8)
                        .frame(width: 60, height: 60)
                    
                    Circle()
                        .trim(from: 0, to: captureResult.confidence)
                        .stroke(
                            confidenceColor,
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .frame(width: 60, height: 60)
                        .rotationEffect(.degrees(-90))
                    
                    Text("\(Int(captureResult.confidence * 100))%")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(confidenceLevel)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(confidenceColor)
                    
                    Text(confidenceMessage)
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(16)
            .background(AppColors.surface)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(AppColors.glassBorder, lineWidth: 1)
            )
        }
    }
    
    private var confidenceColor: Color {
        if captureResult.confidence >= 0.85 {
            return AppColors.success
        } else if captureResult.confidence >= 0.60 {
            return AppColors.warning
        } else {
            return AppColors.error
        }
    }
    
    private var confidenceLevel: String {
        if captureResult.confidence >= 0.85 {
            return "High Confidence"
        } else if captureResult.confidence >= 0.60 {
            return "Medium Confidence"
        } else {
            return "Low Confidence"
        }
    }
    
    private var confidenceMessage: String {
        if captureResult.confidence >= 0.85 {
            return "Text was clearly recognized."
        } else if captureResult.confidence >= 0.60 {
            return "Please verify the details are correct."
        } else {
            return "Consider retaking the photo for better accuracy."
        }
    }
    
    // MARK: - Next Steps Card
    
    private var nextStepsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("What Happens Next")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(AppColors.textTertiary)
                .textCase(.uppercase)
                .tracking(1)
            
            VStack(spacing: 12) {
                nextStepRow(icon: "checkmark.circle.fill", text: "Verify this citation exists", color: AppColors.success)
                nextStepRow(icon: "calendar", text: "Check appeal deadlines", color: AppColors.warning)
                nextStepRow(icon: "sparkles", text: "AI will help draft your appeal", color: AppColors.gold)
            }
            .padding(16)
            .background(AppColors.surface)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(AppColors.glassBorder, lineWidth: 1)
            )
        }
    }
    
    private func nextStepRow(icon: String, text: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(color)
                .frame(width: 24)
            
            Text(text)
                .font(.system(size: 15))
                .foregroundColor(AppColors.textSecondary)
            
            Spacer()
        }
    }
    
    // MARK: - Action Buttons
    
    private var actionButtons: some View {
        VStack(spacing: 12) {
            // Primary CTA
            Button(action: {
                FCHaptics.success()
                createCitationAndShowAppealEditor()
            }) {
                HStack(spacing: 8) {
                    Text("Looks Good")
                        .font(.system(size: 17, weight: .semibold))
                    Image(systemName: "arrow.right")
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundColor(AppColors.obsidian)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(AppColors.goldGradient)
                .cornerRadius(14)
                .shadow(color: AppColors.gold.opacity(0.4), radius: 12, y: 6)
            }
            .disabled(editedCitationNumber.isEmpty)
            .opacity(editedCitationNumber.isEmpty ? 0.5 : 1)
            
            // Secondary actions
            HStack(spacing: 12) {
                Button(action: {
                    FCHaptics.lightImpact()
                    showEditSheet = true
                }) {
                    Text("Edit")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(AppColors.gold)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(AppColors.surface)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(AppColors.gold.opacity(0.3), lineWidth: 1)
                        )
                }
                
                Button(action: {
                    FCHaptics.lightImpact()
                    onRetake()
                }) {
                    Text("Retake")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(AppColors.textSecondary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(AppColors.surface)
                        .cornerRadius(12)
                }
            }
        }
        .padding(.top, 8)
    }
    
    // MARK: - Edit Sheet
    
    private var editSheet: some View {
        NavigationStack {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Citation Number")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(AppColors.textTertiary)
                        .textCase(.uppercase)
                    
                    TextField("", text: $editedCitationNumber)
                        .font(.system(size: 28, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                        .textInputAutocapitalization(.characters)
                        .padding(16)
                        .background(AppColors.surface)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(AppColors.gold.opacity(0.5), lineWidth: 2)
                        )
                }
                
                Spacer()
                
                Button(action: {
                    FCHaptics.success()
                    showEditSheet = false
                }) {
                    Text("Done")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(AppColors.obsidian)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(AppColors.goldGradient)
                        .cornerRadius(14)
                }
            }
            .padding(24)
            .background(AppColors.background)
            .navigationTitle("Edit Citation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        showEditSheet = false
                    }
                    .foregroundColor(AppColors.gold)
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
    
    // MARK: - Helpers
    
    private func formatCityId(_ cityId: String) -> String {
        let components = cityId.components(separatedBy: "-")
        return components.dropFirst().map { $0.capitalized }.joined(separator: " ")
    }
    
    // MARK: - Citation Creation
    
    private func createCitationAndShowAppealEditor() {
        // Create Citation from CaptureResult
        let citation = Citation(
            citationNumber: editedCitationNumber,
            cityId: captureResult.extractedCityId,
            cityName: captureResult.extractedCityId?.replacingOccurrences(of: "us-", with: "").replacingOccurrences(of: "-", with: " ").capitalized,
            violationDate: captureResult.extractedDate,
            status: .validated
        )
        
        self.citation = citation
        showAppealEditor = true
    }
}

// MARK: - Previews

#if DEBUG
struct ConfirmationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ConfirmationView(
                captureResult: CaptureResult(
                    rawText: "SFMTA12345678",
                    extractedCitationNumber: "SFMTA12345678",
                    extractedCityId: "us-ca-san_francisco",
                    confidence: 0.92,
                    processingTimeMs: 1500
                ),
                onConfirm: { _ in },
                onRetake: {},
                onEdit: { _ in }
            )
        }
    }
}
#endif
