//
//  CaptureView.swift
//  FightCity
//
//  Camera capture view for scanning tickets
//

import SwiftUI
import AVFoundation
import FightCityiOS

public struct CaptureView: View {
    @StateObject private var viewModel = CaptureViewModel()
    @EnvironmentObject private var coordinator: AppCoordinator
    @Environment(\.dismiss) private var dismiss
    
    public init() {}
    
    public var body: some View {
        ZStack {
            // Camera preview
            cameraPreview
                .ignoresSafeArea()
            
            // Overlay
            VStack {
                // Header
                headerView
                
                Spacer()
                
                // Quality warning
                if let warning = viewModel.qualityWarning {
                    qualityWarningView(warning)
                }
                
                // Controls
                controlsView
            }
            
            // Loading overlay
            if viewModel.processingState.isProcessing {
                LoadingOverlay(
                    message: viewModel.processingState.statusText,
                    isShowing: true
                )
            }
            
            // Manual entry sheet
            if viewModel.showManualEntry {
                manualEntrySheet
            }
        }
        .onAppear {
            Task {
                await viewModel.requestCameraAuthorization()
            }
        }
        .onDisappear {
            Task {
                await viewModel.stopCapture()
            }
        }
        .sheet(item: $viewModel.captureResult) { result in
            // Navigate to confirmation when capture is complete
            ConfirmationView(result: result)
                .environmentObject(viewModel)
        }
    }
    
    // MARK: - Camera Preview
    
    private var cameraPreview: some View {
        // Placeholder for camera preview
        // In real implementation, would use CameraPreviewView
        Rectangle()
            .fill(Color.black)
            .overlay(
                VStack {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.white.opacity(0.5))
                    Text("Camera Preview")
                        .foregroundColor(.white.opacity(0.5))
                }
            )
    }
    
    // MARK: - Header
    
    private var headerView: some View {
        HStack {
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "xmark")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(12)
                    .background(Color.black.opacity(0.5))
                    .clipShape(Circle())
            }
            
            Spacer()
            
            Button(action: {
                viewModel.showManualEntry = true
            }) {
                Image(systemName: "keyboard")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(12)
                    .background(Color.black.opacity(0.5))
                    .clipShape(Circle())
            }
        }
        .padding()
    }
    
    // MARK: - Quality Warning
    
    private func qualityWarningView(_ warning: String) -> some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
            
            Text(warning)
                .font(AppTypography.labelMedium)
                .foregroundColor(.orange)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.orange.opacity(0.15))
        .cornerRadius(12)
        .padding(.horizontal, 24)
    }
    
    // MARK: - Controls
    
    private var controlsView: some View {
        VStack(spacing: 24) {
            // Capture status
            Text(viewModel.processingState.statusText)
                .font(AppTypography.labelMedium)
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.black.opacity(0.5))
                .cornerRadius(20)
            
            // Capture button
            Button(action: {
                Task {
                    await viewModel.capturePhoto()
                }
            }) {
                Circle()
                    .fill(Color.white)
                    .frame(width: 72, height: 72)
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 4)
                            .frame(width: 80, height: 80)
                    )
            }
            .disabled(viewModel.processingState.isProcessing)
        }
        .padding(.bottom, 48)
    }
    
    // MARK: - Manual Entry Sheet
    
    private var manualEntrySheet: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture {
                    viewModel.showManualEntry = false
                }
            
            VStack(spacing: 24) {
                Text("Enter Citation Number")
                    .font(AppTypography.titleMedium)
                
                TextField("Citation Number", text: $viewModel.manualCitationNumber)
                    .textFieldStyle(.roundedBorder)
                    .font(AppTypography.citationNumber)
                    .textInputAutocapitalization(.characters)
                
                HStack(spacing: 16) {
                    SecondaryButton(title: "Cancel", action: {
                        viewModel.showManualEntry = false
                    })
                    
                    PrimaryButton(title: "Submit", action: {
                        Task {
                            await viewModel.submitManualEntry()
                        }
                    })
                }
            }
            .padding(24)
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .padding(.horizontal, 32)
        }
    }
}

// MARK: - Previews

#if DEBUG
struct CaptureView_Previews: PreviewProvider {
    static var previews: some View {
        CaptureView()
            .environmentObject(AppCoordinator())
    }
}
#endif
