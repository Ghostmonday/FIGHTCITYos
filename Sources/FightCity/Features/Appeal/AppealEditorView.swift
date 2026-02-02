//
//  AppealEditorView.swift
//  FightCity
//
//  Appeal editor with AI refinement integration
//

import SwiftUI
import FightCityFoundation
import FightCityiOS

// APP STORE READINESS: Appeal editor is the "killer feature" - must be perfect
// APPLE INTELLIGENCE: AI refinement showcases Apple Intelligence integration
// UI POLISH: Text editor needs smooth transitions and clear visual hierarchy
// TODO APP STORE: Add sample appeals or templates to help users start
// TODO ENHANCEMENT: Add voice-to-text for dictating appeals (Speech framework)
// TODO ACCESSIBILITY: Ensure text editor works with VoiceOver and dictation
// TODO ENHANCEMENT: Add character/word count with suggested length guidance
// PERFORMANCE: AI refinement should complete within 3 seconds max
// ERROR HANDLING: Gracefully handle AI service failures with fallback options
public struct AppealEditorView: View {
    let citation: Citation
    let onContinue: (String) -> Void
    let onCancel: () -> Void
    
    @StateObject private var viewModel: AppealEditorViewModel
    @State private var showOriginal = false
    @State private var hasAppeared = false
    @FocusState private var isTextEditorFocused: Bool
    
    public init(
        citation: Citation,
        onContinue: @escaping (String) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.citation = citation
        self.onContinue = onContinue
        self.onCancel = onCancel
        self._viewModel = StateObject(wrappedValue: AppealEditorViewModel(citation: citation))
    }
    
    public var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Header
                    headerSection
                        .opacity(hasAppeared ? 1 : 0)
                        .offset(y: hasAppeared ? 0 : 20)
                        .animation(.easeOut(duration: 0.4), value: hasAppeared)
                    
                    // Original text input
                    originalTextSection
                        .opacity(hasAppeared ? 1 : 0)
                        .offset(y: hasAppeared ? 0 : 20)
                        .animation(.easeOut(duration: 0.4).delay(0.1), value: hasAppeared)
                    
                    // Refined text section
                    if !viewModel.refinedText.isEmpty {
                        refinedTextSection
                            .opacity(hasAppeared ? 1 : 0)
                            .offset(y: hasAppeared ? 0 : 20)
                            .animation(.easeOut(duration: 0.4).delay(0.2), value: hasAppeared)
                    }
                    
                    // Error message
                    if let error = viewModel.refinementError {
                        errorSection(error)
                            .opacity(hasAppeared ? 1 : 0)
                            .animation(.easeOut(duration: 0.3), value: hasAppeared)
                    }
                    
                    // Action buttons
                    actionButtons
                        .opacity(hasAppeared ? 1 : 0)
                        .offset(y: hasAppeared ? 0 : 20)
                        .animation(.easeOut(duration: 0.4).delay(0.3), value: hasAppeared)
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
        }
        .navigationTitle("Write Your Appeal")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    FCHaptics.lightImpact()
                    onCancel()
                }
                .foregroundColor(AppColors.gold)
            }
        }
        .onAppear {
            FCHaptics.prepare()
            withAnimation {
                hasAppeared = true
            }
        }
        .preferredColorScheme(.dark)
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "sparkles")
                .font(SwiftUI.Font.system(size: 48))
                .foregroundColor(AppColors.gold)
            
            Text("AI-Powered Appeal Refinement")
                .font(SwiftUI.Font.system(size: 22, weight: .bold))
                .foregroundColor(.white)
            
            Text("Tell us why you're contesting this citation. Our AI will help refine your statement into a professional appeal letter.")
                .foregroundColor(AppColors.textSecondary)
                .modifier(SystemFontModifier(size: 15))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - Original Text Section
    
    private var originalTextSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                    Text("Your Appeal Reason")
                        .font(SwiftUI.Font.system(size: 13, weight: .semibold))
                        .foregroundColor(AppColors.textTertiary)
                    .textCase(.uppercase)
                    .tracking(1)
                
                Spacer()
            }
            
            ZStack(alignment: .topLeading) {
                if viewModel.originalText.isEmpty {
                    Text("Example: I parked at a broken meter. I put money in but it showed zero time remaining.")
                        .font(SwiftUI.Font.system(size: 15))
                        .foregroundColor(AppColors.textTertiary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 16)
                }
                
                TextEditor(text: $viewModel.originalText)
                    .font(SwiftUI.Font.system(size: 15))
                    .foregroundColor(.white)
                    .frame(minHeight: 120)
                    .padding(8)
                    .background(AppColors.surface)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isTextEditorFocused ? AppColors.gold.opacity(0.5) : AppColors.glassBorder, lineWidth: 1)
                    )
                    .focused($isTextEditorFocused)
            }
            
            Button(action: {
                FCHaptics.mediumImpact()
                Task {
                    await viewModel.refineAppeal()
                }
            }) {
                HStack(spacing: 8) {
                    if viewModel.isRefining {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: AppColors.obsidian))
                    } else {
                        Image(systemName: "sparkles")
                            .font(SwiftUI.Font.system(size: 14, weight: .semibold))
                        Text("Refine with AI")
                            .font(SwiftUI.Font.system(size: 15, weight: .semibold))
                    }
                }
                .foregroundColor(AppColors.obsidian)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(AppColors.goldGradient)
                .cornerRadius(12)
                .shadow(color: AppColors.gold.opacity(0.3), radius: 8, y: 4)
            }
            .disabled(viewModel.originalText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isRefining || viewModel.rateLimitRetryAfter != nil)
            .opacity((viewModel.originalText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isRefining || viewModel.rateLimitRetryAfter != nil) ? 0.5 : 1)
            
            if let retryAfter = viewModel.rateLimitRetryAfter, retryAfter > 0 {
                HStack(spacing: 4) {
                    Image(systemName: "clock.fill")
                        .font(SwiftUI.Font.system(size: 12))
                    Text("Rate limit: Try again in \(retryAfter)s")
                        .font(SwiftUI.Font.system(size: 13))
                }
                .foregroundColor(AppColors.warning)
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
    
    // MARK: - Refined Text Section
    
    private var refinedTextSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "sparkles")
                        .font(SwiftUI.Font.system(size: 12))
                    Text("Refined Appeal Letter")
                        .font(SwiftUI.Font.system(size: 13, weight: .semibold))
                        .foregroundColor(AppColors.textTertiary)
                        .textCase(.uppercase)
                        .tracking(1)
                }
                .foregroundColor(AppColors.gold)
                
                Spacer()
                
                if viewModel.fallbackUsed {
                    HStack(spacing: 4) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(SwiftUI.Font.system(size: 10))
                        Text("Fallback")
                            .font(SwiftUI.Font.system(size: 11, weight: .medium))
                    }
                    .foregroundColor(AppColors.warning)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppColors.warning.opacity(0.15))
                    .cornerRadius(8)
                }
            }
            
            TextEditor(text: $viewModel.refinedText)
                .font(SwiftUI.Font.system(size: 15))
                .foregroundColor(.white)
                .frame(minHeight: 200)
                .padding(12)
                .background(AppColors.surfaceVariant)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(AppColors.gold.opacity(0.3), lineWidth: 1)
                )
            
            if viewModel.processingTimeMs > 0 {
                HStack(spacing: 4) {
                    Image(systemName: "clock.fill")
                        .font(SwiftUI.Font.system(size: 11))
                    Text("Processed in \(viewModel.processingTimeMs)ms")
                        .font(SwiftUI.Font.system(size: 12))
                }
                .foregroundColor(AppColors.textTertiary)
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
    
    // MARK: - Error Section
    
    private func errorSection(_ error: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.circle.fill")
                .font(SwiftUI.Font.system(size: 18))
                .foregroundColor(AppColors.error)
            
            Text(error)
                    .font(Font.system(size: 14))
                .foregroundColor(AppColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(AppColors.error.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppColors.error.opacity(0.3), lineWidth: 1)
        )
    }
    
    // MARK: - Action Buttons
    
    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button(action: {
                FCHaptics.success()
                onContinue(viewModel.refinedText.isEmpty ? viewModel.originalText : viewModel.refinedText)
            }) {
                HStack(spacing: 8) {
                    Text("Continue to Mail")
                        .font(SwiftUI.Font.system(size: 17, weight: .semibold))
                    Image(systemName: "arrow.right")
                        .font(SwiftUI.Font.system(size: 15, weight: .semibold))
                }
                .foregroundColor(AppColors.obsidian)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(AppColors.goldGradient)
                .cornerRadius(14)
                .shadow(color: AppColors.gold.opacity(0.4), radius: 12, y: 6)
            }
            .disabled(viewModel.originalText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .opacity(viewModel.originalText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1)
        }
        .padding(.top, 8)
    }
}

// MARK: - Previews

#if DEBUG
struct AppealEditorView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            AppealEditorView(
                citation: Citation(
                    citationNumber: "123456789",
                    cityId: "us-ca-san_francisco",
                    cityName: "San Francisco"
                ),
                onContinue: { _ in },
                onCancel: {}
            )
        }
    }
}
#endif
