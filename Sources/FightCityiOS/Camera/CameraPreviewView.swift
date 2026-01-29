//
//  CameraPreviewView.swift
//  FightCityiOS
//
//  UIKit camera preview wrapped for SwiftUI
//

import SwiftUI
import AVFoundation

/// UIKit camera preview view wrapped for SwiftUI
public struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession
    var showBoundingBoxes: Bool = false
    var boundingBoxes: [BoundingBoxOverlayData] = []
    
    public func makeUIView(context: Context) -> CameraPreviewUIView {
        let view = CameraPreviewUIView()
        view.session = session
        view.showBoundingBoxes = showBoundingBoxes
        view.boundingBoxes = boundingBoxes
        return view
    }
    
    public func updateUIView(_ uiView: CameraPreviewUIView, context: Context) {
        uiView.session = session
        uiView.showBoundingBoxes = showBoundingBoxes
        uiView.boundingBoxes = boundingBoxes
        uiView.setNeedsLayout()
    }
}

/// UIKit preview view with bounding box overlay
public final class CameraPreviewUIView: UIView {
    public var session: AVCaptureSession? {
        didSet {
            if let session = session {
                previewLayer.session = session
            }
        }
    }
    
    public var showBoundingBoxes: Bool = false {
        didSet {
            boundingBoxOverlay.isHidden = !showBoundingBoxes
        }
    }
    
    public var boundingBoxes: [BoundingBoxOverlayData] = [] {
        didSet {
            boundingBoxOverlay.boxes = boundingBoxes
        }
    }
    
    private let previewLayer = AVCaptureVideoPreviewLayer()
    private let boundingBoxOverlay = BoundingBoxOverlayView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        backgroundColor = .black
        
        // Setup preview layer
        previewLayer.videoGravity = .resizeAspectFill
        layer.addSublayer(previewLayer)
        
        // Setup bounding box overlay
        boundingBoxOverlay.isHidden = !showBoundingBoxes
        addSubview(boundingBoxOverlay)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer.frame = bounds
        boundingBoxOverlay.frame = bounds
    }
}

/// Data for bounding box overlay
public struct BoundingBoxOverlayData: Identifiable {
    public let id = UUID()
    public let rect: CGRect
    public let text: String
    public let confidence: Double
    
    public init(rect: CGRect, text: String, confidence: Double) {
        self.rect = rect
        self.text = text
        self.confidence = confidence
    }
}

/// Overlay view for showing detected text regions
final class BoundingBoxOverlayView: UIView {
    var boxes: [BoundingBoxOverlayData] = [] {
        didSet {
            setNeedsDraw()
        }
    }
    
    override func draw(_ rect: CGRect) {
        guard !boxes.isEmpty else { return }
        
        for box in boxes {
            // Draw rectangle
            let path = UIBezierPath(roundedRect: box.rect, cornerRadius: 4)
            path.lineWidth = 2
            UIColor.orange.setStroke()
            path.stroke()
            
            // Draw fill
            UIColor.orange.withAlphaComponent(0.1).setFill()
            path.fill()
            
            // Draw confidence label
            let label = UILabel()
            label.text = "\(Int(box.confidence * 100))%"
            label.font = .systemFont(ofSize: 10, weight: .semibold)
            label.textColor = .white
            label.backgroundColor = UIColor.orange
            label.textAlignment = .center
            label.sizeToFit()
            
            let labelRect = CGRect(
                x: box.rect.origin.x,
                y: box.rect.origin.y - 16,
                width: label.frame.width + 8,
                height: 16
            )
            label.frame = labelRect
            label.drawText(in: labelRect)
        }
    }
}

// MARK: - Bounding Box from Vision

import Vision

extension BoundingBoxOverlayData {
    /// Create from Vision observation
    public static func from(observation: VNRecognizedTextObservation, imageSize: CGSize) -> BoundingBoxOverlayData? {
        guard let topCandidate = observation.topCandidates(1).first else { return nil }
        
        let boundingBox = observation.boundingBox
        let normalizedRect = CGRect(
            x: boundingBox.minX,
            y: 1 - boundingBox.maxY, // Flip Y for UIKit
            width: boundingBox.width,
            height: boundingBox.height
        )
        
        let uiRect = CGRect(
            x: normalizedRect.minX * imageSize.width,
            y: normalizedRect.minY * imageSize.height,
            width: normalizedRect.width * imageSize.width,
            height: normalizedRect.height * imageSize.height
        )
        
        return BoundingBoxOverlayData(
            rect: uiRect,
            text: topCandidate.string,
            confidence: Double(topCandidate.confidence)
        )
    }
}

// MARK: - SwiftUI Preview

#if DEBUG
struct CameraPreviewView_Previews: PreviewProvider {
    static var previews: some View {
        CameraPreviewView(session: AVCaptureSession())
            .frame(height: 400)
    }
}
#endif
