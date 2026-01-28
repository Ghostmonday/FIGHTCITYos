//
//  OnboardingView.swift
//  FightCityTickets
//
//  Onboarding flow with permissions and telemetry opt-in
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @EnvironmentObject var config: AppConfig
    @State private var currentStep = 0
    
    private let steps = [
        OnboardingStep(
            title: "Scan Your Ticket",
            description: "Take a photo of your parking ticket and we'll help you fight it.",
            icon: "camera.fill"
        ),
        OnboardingStep(
            title: "Instant Validation",
            description: "We verify your citation against city records instantly.",
            icon: "checkmark.shield.fill"
        ),
        OnboardingStep(
            title: "Fight Your Ticket",
            description: "Get help preparing your appeal with our AI-powered tools.",
            icon: "doc.text.fill"
        )
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Progress indicator
            HStack(spacing: 8) {
                ForEach(0..<steps.count, id: \.self) { index in
                    Capsule()
                        .fill(index <= currentStep ? AppColors.primary : AppColors.disabled)
                        .frame(height: 4)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            
            // Content
            TabView(selection: $currentStep) {
                ForEach(0..<steps.count, id: \.self) { index in
                    stepContent(steps[index])
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: currentStep)
            
            // Navigation buttons
            VStack(spacing: 16) {
                if currentStep < steps.count - 1 {
                    PrimaryButton(title: "Continue") {
                        withAnimation {
                            currentStep += 1
                        }
                    }
                    
                    SecondaryButton(title: "Skip") {
                        coordinator.startCaptureFlow()
                    }
                } else {
                    PrimaryButton(title: "Get Started") {
                        coordinator.startCaptureFlow()
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .background(AppColors.background)
    }
    
    private func stepContent(_ step: OnboardingStep) -> some View {
        VStack(spacing: 32) {
            Spacer()
            
            Image(systemName: step.icon)
                .font(.system(size: 80))
                .foregroundColor(AppColors.primary)
                .padding(24)
                .background(
                    Circle()
                        .fill(AppColors.primary.opacity(0.1))
                        .frame(width: 160, height: 160)
                )
            
            VStack(spacing: 16) {
                Text(step.title)
                    .headlineLarge()
                    .multilineTextAlignment(.center)
                
                Text(step.description)
                    .bodyLarge()
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            Spacer()
            Spacer()
        }
    }
}

// MARK: - Onboarding Step

struct OnboardingStep {
    let title: String
    let description: String
    let icon: String
}

// MARK: - City Selection Sheet

struct CitySelectionSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var config: AppConfig
    @State private var selectedCity: String?
    
    var body: some View {
        NavigationStack {
            List(config.supportedCities) { city in
                Button {
                    selectedCity = city.id
                } label: {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(city.name)
                                .bodyMedium()
                            Text("Appeal deadline: \(city.appealDeadlineDays) days")
                                .labelSmall()
                                .foregroundColor(AppColors.textSecondary)
                        }
                        
                        Spacer()
                        
                        if selectedCity == city.id {
                            Image(systemName: "checkmark")
                                .foregroundColor(AppColors.primary)
                        }
                    }
                }
                .foregroundColor(AppColors.textPrimary)
            }
            .navigationTitle("Select City")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Confirm") {
                        // Save selected city and dismiss
                        dismiss()
                    }
                    .disabled(selectedCity == nil)
                }
            }
        }
    }
}

// MARK: - Telemetry Opt-In Sheet

struct TelemetryOptInSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var config: AppConfig
    @State private var isEnabled = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    Image(systemName: "chart.bar.fill")
                        .font(.system(size: 60))
                        .foregroundColor(AppColors.primary)
                        .padding(.top, 32)
                    
                    Text("Help Improve OCR")
                        .headlineMedium()
                    
                    Text("By sharing anonymous data about your scans, you help us improve accuracy for your city and all users.")
                        .bodyMedium()
                        .foregroundColor(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        InfoRow(label: "Data shared:", value: "Scan images, OCR output, corrections")
                        InfoRow(label: "Data NOT shared:", value: "Personal information, location")
                        InfoRow(label: "Privacy:", value: "Images are hashed, never stored in original form")
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(AppColors.secondaryBackground)
                    )
                    .padding(.horizontal, 24)
                    
                    Toggle("Enable telemetry", isOn: $isEnabled)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(AppColors.secondaryBackground)
                        )
                        .padding(.horizontal, 24)
                }
            }
            .navigationTitle("Privacy")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        config.setTelemetryEnabled(isEnabled)
                        dismiss()
                    }
                }
            }
        }
    }
}

#if DEBUG
struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
            .environmentObject(AppCoordinator())
            .environmentObject(AppConfig.shared)
    }
}
#endif
