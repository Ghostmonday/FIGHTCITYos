//
//  AppealPDFGenerator.swift
//  FightCityiOS
//
//  PDF generator for appeal letters (print-ready for Lob mailing)
//

import Foundation
import UIKit
import PDFKit
import FightCityFoundation

/// User contact information for appeal letters
public struct UserContactInfo {
    public let name: String
    public let addressLine1: String
    public let addressLine2: String?
    public let city: String
    public let state: String
    public let zip: String
    public let email: String?
    public let phone: String?
    
    public init(
        name: String,
        addressLine1: String,
        addressLine2: String? = nil,
        city: String,
        state: String,
        zip: String,
        email: String? = nil,
        phone: String? = nil
    ) {
        self.name = name
        self.addressLine1 = addressLine1
        self.addressLine2 = addressLine2
        self.city = city
        self.state = state
        self.zip = zip
        self.email = email
        self.phone = phone
    }
    
    /// Formatted address string
    public var formattedAddress: String {
        var lines: [String] = []
        lines.append(name)
        lines.append(addressLine1)
        if let line2 = addressLine2 {
            lines.append(line2)
        }
        lines.append("\(city), \(state) \(zip)")
        return lines.joined(separator: "\n")
    }
}

/// PDF generator for appeal letters
///
/// APP STORE READINESS: PDF generation is critical for certified mail feature
/// TODO APP STORE: Ensure PDF meets USPS and Lob specifications
/// TODO ENHANCEMENT: Add customizable letterhead/branding options
/// TODO ACCESSIBILITY: Ensure generated PDFs are accessible (tagged PDF)
/// QUALITY: PDF must be print-ready at 300 DPI for professional appearance
/// TESTING: Test PDF generation with various appeal lengths and edge cases
/// COMPLIANCE: Ensure all required legal elements are present in letter
public enum AppealPDFGenerator {
    /// Generates a print-ready PDF for an appeal letter
    ///
    /// - Parameters:
    ///   - citation: The citation being appealed
    ///   - appealText: The appeal letter text
    ///   - userInfo: User's contact information
    /// - Returns: PDF data ready for Lob mailing
    /// - Throws: Error if PDF generation fails
    public static func generate(
        citation: Citation,
        appealText: String,
        userInfo: UserContactInfo
    ) throws -> Data {
        let pageSize = CGSize(width: 612, height: 792) // 8.5" x 11" in points
        let format = UIGraphicsPDFRendererFormat()
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(origin: .zero, size: pageSize), format: format)
        
        let pdfData = renderer.pdfData { context in
            context.beginPage()
            
            let margin: CGFloat = 72 // 1 inch margins
            let contentWidth = pageSize.width - (margin * 2)
            var currentY: CGFloat = margin
            
            // Draw user's return address (top left)
            let returnAddressFont = UIFont.systemFont(ofSize: 10)
            let returnAddressAttributes: [NSAttributedString.Key: Any] = [
                .font: returnAddressFont,
                .foregroundColor: UIColor.black
            ]
            let returnAddressText = NSAttributedString(
                string: userInfo.formattedAddress,
                attributes: returnAddressAttributes
            )
            let returnAddressRect = CGRect(
                x: margin,
                y: currentY,
                width: contentWidth / 2,
                height: returnAddressText.boundingRect(
                    with: CGSize(width: contentWidth / 2, height: .greatestFiniteMagnitude),
                    options: [.usesLineFragmentOrigin, .usesFontLeading],
                    context: nil
                ).height
            )
            returnAddressText.draw(in: returnAddressRect)
            currentY += returnAddressRect.height + 40
            
            // Draw date
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .long
            let dateText = dateFormatter.string(from: Date())
            let dateFont = UIFont.systemFont(ofSize: 12)
            let dateAttributes: [NSAttributedString.Key: Any] = [
                .font: dateFont,
                .foregroundColor: UIColor.black
            ]
            let dateAttributed = NSAttributedString(string: dateText, attributes: dateAttributes)
            let dateRect = CGRect(
                x: margin,
                y: currentY,
                width: contentWidth,
                height: dateAttributed.boundingRect(
                    with: CGSize(width: contentWidth, height: .greatestFiniteMagnitude),
                    options: [.usesLineFragmentOrigin, .usesFontLeading],
                    context: nil
                ).height
            )
            dateAttributed.draw(in: dateRect)
            currentY += dateRect.height + 20
            
            // Draw appeal text
            let bodyFont = UIFont.systemFont(ofSize: 12)
            let bodyAttributes: [NSAttributedString.Key: Any] = [
                .font: bodyFont,
                .foregroundColor: UIColor.black
            ]
            let bodyText = NSAttributedString(string: appealText, attributes: bodyAttributes)
            
            // Calculate text height
            let textRect = CGRect(
                x: margin,
                y: currentY,
                width: contentWidth,
                height: pageSize.height - currentY - margin - 60 // Leave room for signature
            )
            
            // Draw text with proper line spacing
            let textStorage = NSTextStorage(attributedString: bodyText)
            let layoutManager = NSLayoutManager()
            textStorage.addLayoutManager(layoutManager)
            
            let textContainer = NSTextContainer(size: textRect.size)
            textContainer.lineFragmentPadding = 0
            layoutManager.addTextContainer(textContainer)
            
            let glyphRange = layoutManager.glyphRange(for: textContainer)
            layoutManager.drawGlyphs(forGlyphRange: glyphRange, at: textRect.origin)
            
            // Draw signature line at bottom
            let signatureY = pageSize.height - margin - 40
            let signatureFont = UIFont.systemFont(ofSize: 12)
            let signatureText = "Respectfully submitted,\n\n\(userInfo.name)"
            let signatureAttributes: [NSAttributedString.Key: Any] = [
                .font: signatureFont,
                .foregroundColor: UIColor.black
            ]
            let signatureAttributed = NSAttributedString(
                string: signatureText,
                attributes: signatureAttributes
            )
            let signatureRect = CGRect(
                x: margin,
                y: signatureY,
                width: contentWidth,
                height: signatureAttributed.boundingRect(
                    with: CGSize(width: contentWidth, height: .greatestFiniteMagnitude),
                    options: [.usesLineFragmentOrigin, .usesFontLeading],
                    context: nil
                ).height
            )
            signatureAttributed.draw(in: signatureRect)
        }
        
        return pdfData
    }
}
