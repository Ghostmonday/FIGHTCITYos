// APPLE INTELLIGENCE IMPLEMENTATION - VisionKit Document Scanner
// Status: ✅ Implemented
// This coordinator handles VisionKit's VNDocumentCameraViewController
// with automatic fallback to traditional camera on unsupported devices.
//
// Testing checklist:
// - [ ] Test on device with iOS 16+ (Simulator doesn't support camera)
// - [ ] Verify auto-cropping works
// - [ ] Verify perspective correction works
// - [ ] Test fallback on iOS 15 devices
// - [ ] Test "not available" path (airplane mode, restricted camera)

//
//  DocumentScanCoordinator.swift
//  FightCityiOS
//
//  VisionKit Document Scanner integration for Apple Intelligence
//

import VisionKit
import UIKit
import Vision
import FightCityFoundation

/// Coordinator for VisionKit Document Scanner integration
/// Handles intelligent document capture with auto-detection, cropping, and enhancement
@available(iOS 16.0, *)
public class DocumentScanCoordinator: NSObject {
    
    // MARK: - Delegate
    
    public weak var delegate: DocumentScanCoordinatorDelegate?
    
    // MARK: - Properties
    
    private var documentCameraViewController: VNDocumentCameraViewController?
    private let logger = Logger.shared
    
    // MARK: - Initialization
    
    public override init() {
        super.init()
        logger.debug("DocumentScanCoordinator initialized")
    }
    
    // MARK: - Public Interface
    
    /// Present the document scanner from a view controller
    public func presentScanner(from viewController: UIViewController) {
        guard FeatureFlags.isVisionKitDocumentScannerEnabled else {
            logger.warning("VisionKit Document Scanner feature flag is disabled")
            delegate?.documentScanCoordinator(self, didFailWith: .featureDisabled)
            return
        }
        
        guard VNDocumentCameraViewController.isSupported else {
            logger.error("VNDocumentCameraViewController is not supported on this device")
            delegate?.documentScanCoordinator(self, didFailWith: .unsupportedDevice)
            return
        }
        
        let scanner = VNDocumentCameraViewController()
        scanner.delegate = self
        scanner.modalPresentationStyle = .fullScreen
        scanner.modalTransitionStyle = .crossDissolve
        
        documentCameraViewController = scanner
        viewController.present(scanner, animated: true)
        
        logger.info("Presented VisionKit Document Scanner")
    }
    
    /// Dismiss the document scanner
    public func dismissScanner() {
        documentCameraViewController?.dismiss(animated: true) { [weak self] in
            self?.documentCameraViewController = nil
            self?.logger.info("Dismissed VisionKit Document Scanner")
        }
    }
    
    // MARK: - Document Processing
    
    /// Process the scanned document and extract the best page
    private func processScannedDocument(_ scan: VNDocumentCameraScan) -> DocumentScanResult.DocumentScanResultResult {
        logger.info("Processing scanned document with \(scan.pageCount) pages")
        
        guard scan.pageCount > 0 else {
            logger.error("Scanned document has no pages")
            return .failed(.noPagesFound)
        }
        
        // Select the best page (typically page 0, but could implement smart selection)
        let bestPageIndex = selectBestPage(from: scan)
        let bestImage = scan.imageOfPage(at: bestPageIndex)
        
        // VisionKit automatically applies:
        // - Auto-cropping to document boundaries
        // - Perspective correction
        // - Glare reduction
        // - Image enhancement
        
        logger.info("Successfully processed page \(bestPageIndex) with VisionKit enhancement")
        
        return .success(
            DocumentScanResult(
                image: bestImage,
                pageIndex: bestPageIndex,
                totalPages: scan.pageCount,
                processingTime: 0, // VisionKit processing is nearly instantaneous
                enhancementApplied: true,
                scanQuality: .high // VisionKit provides high-quality results
            )
        )
    }
    
    /// Select the best page from a multi-page scan
    private func selectBestPage(from scan: VNDocumentCameraScan) -> Int {
        // For now, select the first page
        // Future enhancement: Implement smart page selection based on:
        // - Image clarity
        // - Document detection confidence
        // - Text density
        // - Blur detection
        
        logger.debug("Selected page 0 from \(scan.pageCount) pages")
        return 0
    }
}

// MARK: - VNDocumentCameraViewControllerDelegate

@available(iOS 16.0, *)
extension DocumentScanCoordinator: VNDocumentCameraViewControllerDelegate {
    
    public func documentCameraViewController(_ controller: VNDocumentCameraViewController, 
                                          didFinishWith scan: VNDocumentCameraScan) {
        logger.info("Document scanning completed successfully")
        
        let result = processScannedDocument(scan)
        
        // Clean up
        documentCameraViewController = nil
        
        // Notify delegate
        delegate?.documentScanCoordinator(self, didFinishWith: result)
    }
    
    public func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
        logger.info("Document scanning cancelled by user")
        
        documentCameraViewController = nil
        delegate?.documentScanCoordinatorDidCancel(self)
    }
    
    public func documentCameraViewController(_ controller: VNDocumentCameraViewController, 
                                          didFailWithError error: Error) {
        logger.error("Document scanning failed with error: \(error.localizedDescription)")
        
        documentCameraViewController = nil
        delegate?.documentScanCoordinator(self, didFailWith: .scanFailed(error))
    }
}

// MARK: - Supporting Types

@available(iOS 16.0, *)
public struct DocumentScanResult {
    public let image: UIImage
    public let pageIndex: Int
    public let totalPages: Int
    public let processingTime: TimeInterval
    public let enhancementApplied: Bool
    public let scanQuality: DocumentScanQuality
    
    public enum DocumentScanResultResult {
        case success(DocumentScanResult)
        case failed(DocumentScanError)
    }
    
    public static func success(_ result: DocumentScanResult) -> DocumentScanResultResult {
        return .success(result)
    }
    
    public static func failed(_ error: DocumentScanError) -> DocumentScanResultResult {
        return .failed(error)
    }
}

@available(iOS 16.0, *)
public enum DocumentScanQuality {
    case low
    case medium
    case high
    
    public var description: String {
        switch self {
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        }
    }
}

@available(iOS 16.0, *)
public enum DocumentScanError: LocalizedError {
    case featureDisabled
    case unsupportedDevice
    case noPagesFound
    case imageProcessingFailed
    case scanFailed(Error)
    
    public var errorDescription: String? {
        switch self {
        case .featureDisabled:
            return "VisionKit Document Scanner is disabled"
        case .unsupportedDevice:
            return "Document scanning is not supported on this device"
        case .noPagesFound:
            return "No pages were found in the scanned document"
        case .imageProcessingFailed:
            return "Failed to process the scanned image"
        case .scanFailed(let error):
            return "Document scanning failed: \(error.localizedDescription)"
        }
    }
}

@available(iOS 16.0, *)
public protocol DocumentScanCoordinatorDelegate: AnyObject {
    
    /// Called when document scanning completes successfully
    func documentScanCoordinator(_ coordinator: DocumentScanCoordinator, 
                               didFinishWith result: DocumentScanResult.DocumentScanResultResult)
    
    /// Called when document scanning is cancelled by the user
    func documentScanCoordinatorDidCancel(_ coordinator: DocumentScanCoordinator)
    
    /// Called when document scanning fails
    func documentScanCoordinator(_ coordinator: DocumentScanCoordinator, 
                               didFailWith error: DocumentScanError)
}

// MARK: - Extension for Fallback Support

@available(iOS 16.0, *)
extension DocumentScanCoordinator {
    
    /// Check if this coordinator should be used instead of traditional camera
    public static func shouldUseDocumentScanner() -> Bool {
        return FeatureFlags.isVisionKitDocumentScannerEnabled && VNDocumentCameraViewController.isSupported
    }
    
    /// Get recommended scanner type based on feature flags and device capabilities
    public static func recommendedScannerType() -> ScannerType {
        if shouldUseDocumentScanner() {
            return .visionKit
        } else {
            return .traditional
        }
    }
    
    public enum ScannerType {
        case visionKit
        case traditional
        
        public var description: String {
            switch self {
            case .visionKit: return "VisionKit Document Scanner"
            case .traditional: return "Traditional Camera"
            }
        }
    }
}