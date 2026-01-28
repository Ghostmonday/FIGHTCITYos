//
//  CaptureView.swift
//  FightCityTickets
//
//  Camera capture screen with OCR processing
//

import SwiftUI
import AVFoundation

struct CaptureView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @StateObject private var viewModel = CaptureViewModel()
    @State private var showingManualEntry = false
    
    var body: some View {
        ZStack {
            // Camera preview
            if viewModel.isCameraAuthorized {
                CameraPreviewView(session: viewModel.captureSession)
                    .ignoresSafeArea()
            } else {
                cameraPermissionView
            }
            
            VStack {
                // Top bar
                topBar
                
                Spacer()
                
                // Quality indicator
                if viewModel.isProcessing {
                    qualityIndicator
                }
                
                Spacer()
                
                // Bottom controls
                bottomControls
            }
            .padding()
        }
        .onAppear {
            viewModel.onAppear()
        }
        .onDisappear {
            viewModel.onDisappear()
        }
        .sheet(isPresented: $showingManualEntry) {
            ManualEntrySheet { citationNumber in
                viewModel.handleManualEntry(citationNumber)
            }
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage)
        }
    }
    
    // MARK: - Top Bar
    
    private var topBar: some View {
        HStack {
            Button {
                coordinator.navigateBack()
            } label: {
                Image(systemName: "xmark")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(12)
                    .background(Circle().fill(.black.opacity(0.3)))
            }
            
            Spacer()
            
            // Torch toggle
            Button {
                viewModel.toggleTorch()
            } label: {
                Image(systemName: viewModel.isTorchOn ? "bolt.fill" : "bolt.slash.fill")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(12)
                    .background(Circle().fill(.black.opacity(0.3)))
            }
        }
        .padding(.top, 8)
    }
    
    // MARK: - Quality Indicator
    
    private var qualityIndicator: some View {
        VStack(spacing: 8) {
            if let quality = viewModel.frameQuality {
                Text(quality.feedbackMessage)
                    .bodyMedium()
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(quality.isAcceptable ? AppColors.success : AppColors.warning)
                    )
            }
            
            if viewModel.isProcessing {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            }
        }
    }
    
    // MARK: - Bottom Controls
    
    private var bottomControls: some View {
        VStack(spacing: 24) {
            // Instruction text
            Text("Position the ticket in the frame")
                .bodyLarge()
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.5), radius: 2)
            
            // Capture controls
            HStack(spacing: 40) {
                // Gallery button
                Button {
                    // Open photo library
                } label: {
                    Image(systemName: "photo.on.rectangle")
                        .font(.title)
                        .foregroundColor(.white)
                }
                
                // Capture button
                CaptureButton(
                    action: { viewModel.capturePhoto() },
                    isCapturing: viewModel.isCapturing
                )
                
                // Manual entry button
                Button {
                    showingManualEntry = true
                } label: {
                    Image(systemName: "keyboard")
                        .font(.title)
                        .foregroundColor(.white)
                }
            }
            
            // Frame overlay
            Rectangle()
                .stroke(AppColors.cameraOverlay, lineWidth: 2)
                .frame(width: 280, height: 180)
                .cornerRadius(12)
        }
    }
    
    // MARK: - Camera Permission View
    
    private var cameraPermissionView: some View {
        VStack(spacing: 24) {
            Image(systemName: "camera.fill")
                .font(.system(size: 60))
                .foregroundColor(AppColors.textSecondary)
            
            Text("Camera Access Required")
                .headlineMedium()
            
            Text("Please enable camera access in Settings to scan tickets.")
                .bodyMedium()
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
            
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            .primaryButton()
        }
        .padding()
    }
}

// MARK: - Manual Entry Sheet

struct ManualEntrySheet: View {
    @Environment(\.dismiss) var dismiss
    @State private var citationNumber = ""
    let onSubmit: (String) -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Citation Number") {
                    TextField("Enter citation number", text: $citationNumber)
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled()
                }
                
                Section {
                    Text("Enter the citation number from your ticket. This is usually found at the top of the ticket.")
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                }
            }
            .navigationTitle("Manual Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Submit") {
                        onSubmit(citationNumber)
                        dismiss()
                    }
                    .disabled(citationNumber.count < 5)
                }
            }
        }
    }
}

#if DEBUG
struct CaptureView_Previews: PreviewProvider {
    static var previews: some View {
        CaptureView()
            .environmentObject(AppCoordinator())
    }
}
#endif
