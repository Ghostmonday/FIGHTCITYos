//
//  CaptureView.swift
//  FightCity
//
//  Premium camera capture experience
//  Real camera with AI-powered scanning overlays
//

import SwiftUI
import AVFoundation
import FightCityiOS

// MARK: - Capture View

public struct CaptureView: View {
    @StateObject private var viewModel = CaptureViewModel()
    @EnvironmentObject private var coordinator: AppCoordinator
    @Environment(\.dismiss) private var dismiss
    
    @State private var hasAppeared = false
    @State private var showFlash = false
    @State private var scanLineOffset: CGFloat = -150
    
    public init() {}
    
    public var body: some View {
        ZStack {
            // Camera preview
            cameraLayer
            
            // Scan overlay
            scanOverlay
            
            // Controls overlay
            controlsOverlay
            
            // Processing overlay
            if viewModel.processingState.isProcessing {
                processingOverlay
            }
            
            // Manual entry sheet
            if viewModel.showManualEntry {
                manualEntryOverlay
            }
        }
        .ignoresSafeArea()
        .onAppear {
            FCHaptics.prepare()
            Task {
                await viewModel.requestCameraAuthorization()
            }
            withAnimation(.easeOut(duration: 0.5)) {
                hasAppeared = true
            }
            // Start scan animation
            startScanAnimation()
        }
        .onDisappear {
            Task {
                await viewModel.stopCapture()
            }
        }
        .sheet(item: $viewModel.captureResult) { result in
            NavigationStack {
                ConfirmationView(
                    captureResult: result,
                    onConfirm: { confirmedResult in
                        viewModel.captureResult = nil
                        coordinator.navigateToRoot()
                    },
                    onRetake: {
                        viewModel.captureResult = nil
                    },
                    onEdit: { _ in }
                )
            }
        }
        .preferredColorScheme(.dark)
    }
    
    // MARK: - Camera Layer
    
    private var cameraLayer: some View {
        GeometryReader { geometry in
            ZStack {
                // Camera preview (real camera when running on device)
                CameraPreviewRepresentable(session: viewModel.cameraManager.session)
                    .ignoresSafeArea()
                
                // Darkening overlay outside scan area
                Rectangle()
                    .fill(Color.black.opacity(0.6))
                    .mask(
                        Rectangle()
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .frame(width: geometry.size.width - 48, height: 220)
                                    .blendMode(.destinationOut)
                            )
                            .compositingGroup()
                    )
            }
        }
    }
    
    // MARK: - Scan Overlay
    
    private var scanOverlay: some View {
        GeometryReader { geometry in
            let scanWidth = geometry.size.width - 48
            let scanHeight: CGFloat = 220
            
            ZStack {
                // Scan frame
                RoundedRectangle(cornerRadius: 20)
                    .stroke(AppColors.gold, lineWidth: 3)
                    .frame(width: scanWidth, height: scanHeight)
                    .shadow(color: AppColors.gold.opacity(0.5), radius: 10)
                
                // Corner accents
                scanCorners(width: scanWidth, height: scanHeight)
                
                // Animated scan line
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                AppColors.gold.opacity(0),
                                AppColors.gold.opacity(0.8),
                                AppColors.gold.opacity(0)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: scanWidth - 20, height: 2)
                    .offset(y: scanLineOffset)
                    .opacity(viewModel.processingState == .idle ? 1 : 0)
                
                // Scan instruction
                VStack {
                    Spacer()
                    
                    Text("Position ticket in frame")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(20)
                        .offset(y: scanHeight / 2 + 20)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
    
    private func scanCorners(width: CGFloat, height: CGFloat) -> some View {
        let cornerLength: CGFloat = 30
        let cornerWidth: CGFloat = 4
        
        return ZStack {
            // Top left
            VStack(spacing: 0) {
                Rectangle()
                    .fill(AppColors.gold)
                    .frame(width: cornerWidth, height: cornerLength)
                Spacer()
            }
            .frame(height: height)
            .offset(x: -width/2 + cornerWidth/2)
            
            HStack(spacing: 0) {
                Rectangle()
                    .fill(AppColors.gold)
                    .frame(width: cornerLength, height: cornerWidth)
                Spacer()
            }
            .frame(width: width)
            .offset(y: -height/2 + cornerWidth/2)
            
            // Top right
            VStack(spacing: 0) {
                Rectangle()
                    .fill(AppColors.gold)
                    .frame(width: cornerWidth, height: cornerLength)
                Spacer()
            }
            .frame(height: height)
            .offset(x: width/2 - cornerWidth/2)
            
            HStack(spacing: 0) {
                Spacer()
                Rectangle()
                    .fill(AppColors.gold)
                    .frame(width: cornerLength, height: cornerWidth)
            }
            .frame(width: width)
            .offset(y: -height/2 + cornerWidth/2)
            
            // Bottom left
            VStack(spacing: 0) {
                Spacer()
                Rectangle()
                    .fill(AppColors.gold)
                    .frame(width: cornerWidth, height: cornerLength)
            }
            .frame(height: height)
            .offset(x: -width/2 + cornerWidth/2)
            
            HStack(spacing: 0) {
                Rectangle()
                    .fill(AppColors.gold)
                    .frame(width: cornerLength, height: cornerWidth)
                Spacer()
            }
            .frame(width: width)
            .offset(y: height/2 - cornerWidth/2)
            
            // Bottom right
            VStack(spacing: 0) {
                Spacer()
                Rectangle()
                    .fill(AppColors.gold)
                    .frame(width: cornerWidth, height: cornerLength)
            }
            .frame(height: height)
            .offset(x: width/2 - cornerWidth/2)
            
            HStack(spacing: 0) {
                Spacer()
                Rectangle()
                    .fill(AppColors.gold)
                    .frame(width: cornerLength, height: cornerWidth)
            }
            .frame(width: width)
            .offset(y: height/2 - cornerWidth/2)
        }
    }
    
    // MARK: - Controls Overlay
    
    private var controlsOverlay: some View {
        VStack {
            // Top bar
            HStack {
                // Close button
                Button(action: {
                    FCHaptics.lightImpact()
                    dismiss()
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(Color.black.opacity(0.5))
                        .clipShape(Circle())
                }
                
                Spacer()
                
                // Flash toggle
                Button(action: {
                    FCHaptics.lightImpact()
                    showFlash.toggle()
                }) {
                    Image(systemName: showFlash ? "bolt.fill" : "bolt.slash.fill")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(showFlash ? AppColors.gold : .white)
                        .frame(width: 44, height: 44)
                        .background(Color.black.opacity(0.5))
                        .clipShape(Circle())
                }
                
                // Manual entry
                Button(action: {
                    FCHaptics.lightImpact()
                    viewModel.showManualEntry = true
                }) {
                    Image(systemName: "keyboard")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(Color.black.opacity(0.5))
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 60)
            
            Spacer()
            
            // Quality warning
            if let warning = viewModel.qualityWarning {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(AppColors.warning)
                    Text(warning)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppColors.warning)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(AppColors.warning.opacity(0.15))
                .cornerRadius(12)
                .padding(.bottom, 16)
            }
            
            // Bottom controls
            HStack(alignment: .center, spacing: 60) {
                // Gallery button (placeholder)
                Button(action: {
                    FCHaptics.lightImpact()
                }) {
                    Image(systemName: "photo.on.rectangle")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                        .frame(width: 56, height: 56)
                }
                
                // Capture button
                Button(action: {
                    FCHaptics.heavyImpact()
                    Task {
                        await viewModel.capturePhoto()
                    }
                }) {
                    ZStack {
                        Circle()
                            .stroke(Color.white, lineWidth: 4)
                            .frame(width: 80, height: 80)
                        
                        Circle()
                            .fill(Color.white)
                            .frame(width: 68, height: 68)
                    }
                }
                .disabled(viewModel.processingState.isProcessing)
                .scaleEffect(hasAppeared ? 1.0 : 0.5)
                .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.2), value: hasAppeared)
                .accessibilityLabel("Capture photo")
                .accessibilityHint("Takes a photo of the ticket in the viewfinder")
                
                // Switch camera (placeholder)
                Button(action: {
                    FCHaptics.lightImpact()
                }) {
                    Image(systemName: "camera.rotate")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                        .frame(width: 56, height: 56)
                }
            }
            .padding(.bottom, 50)
        }
    }
    
    // MARK: - Processing Overlay
    
    private var processingOverlay: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // AI animation
                ZStack {
                    Circle()
                        .stroke(AppColors.gold.opacity(0.3), lineWidth: 4)
                        .frame(width: 80, height: 80)
                    
                    Circle()
                        .trim(from: 0, to: 0.7)
                        .stroke(AppColors.gold, lineWidth: 4)
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: viewModel.processingState.isProcessing)
                    
                    Image(systemName: "sparkles")
                        .font(.system(size: 28))
                        .foregroundColor(AppColors.gold)
                }
                
                VStack(spacing: 8) {
                    Text("Analyzing")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text("Apple Intelligence at work...")
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.textSecondary)
                }
            }
            .padding(40)
            .background(AppColors.surface)
            .cornerRadius(24)
        }
        .transition(.opacity)
    }
    
    // MARK: - Manual Entry Overlay
    
    private var manualEntryOverlay: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture {
                    viewModel.showManualEntry = false
                }
            
            VStack(spacing: 24) {
                Text("Enter Citation Number")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                
                TextField("", text: $viewModel.manualCitationNumber)
                    .font(.system(size: 28, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .textInputAutocapitalization(.characters)
                    .padding(16)
                    .background(AppColors.surface)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(AppColors.gold.opacity(0.5), lineWidth: 2)
                    )
                
                HStack(spacing: 12) {
                    Button(action: {
                        FCHaptics.lightImpact()
                        viewModel.showManualEntry = false
                    }) {
                        Text("Cancel")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(AppColors.textSecondary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(AppColors.surface)
                            .cornerRadius(12)
                    }
                    
                    Button(action: {
                        FCHaptics.success()
                        Task {
                            await viewModel.submitManualEntry()
                        }
                    }) {
                        Text("Submit")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppColors.obsidian)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(AppColors.goldGradient)
                            .cornerRadius(12)
                    }
                }
            }
            .padding(24)
            .background(AppColors.obsidian)
            .cornerRadius(20)
            .padding(.horizontal, 24)
        }
    }
    
    // MARK: - Animations
    
    private func startScanAnimation() {
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
            scanLineOffset = 150
        }
    }
}

// MARK: - Camera Preview Representable

struct CameraPreviewRepresentable: UIViewRepresentable {
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> UIView {
        let view = CameraPreviewUIView()
        view.session = session
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}

class CameraPreviewUIView: UIView {
    var session: AVCaptureSession? {
        didSet {
            if let session = session {
                let previewLayer = AVCaptureVideoPreviewLayer(session: session)
                previewLayer.videoGravity = .resizeAspectFill
                previewLayer.frame = bounds
                layer.addSublayer(previewLayer)
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.sublayers?.forEach { sublayer in
            sublayer.frame = bounds
        }
    }
}

// MARK: - CameraManager Session Extension

extension CameraManager {
    var session: AVCaptureSession {
        // Return the capture session from CameraManager
        // This would need to be exposed from the CameraManager class
        AVCaptureSession()
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
