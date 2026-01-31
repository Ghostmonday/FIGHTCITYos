//
//  CertifiedMailConfirmationSheet.swift
//  FightCity
//
//  Certified mail confirmation UI (only delivery option)
//

import SwiftUI
import FightCityFoundation
import FightCityiOS

struct CertifiedMailConfirmationSheet: View {
    let citation: Citation
    let appealText: String
    @State var userAddress: UserAddress?
    @State var showingAddressForm = false
    @State var isProcessing = false
    @State var errorMessage: String?
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "envelope.fill")
                            .font(.system(size: 48))
                            .foregroundColor(AppColors.gold)
                        
                        Text("Send Certified Mail")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("We'll print and mail your appeal via certified mail with tracking")
                            .font(.system(size: 16))
                            .foregroundColor(AppColors.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top, 20)
                    
                    // Cost breakdown
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Cost Breakdown")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                        
                        CostRow(label: "Letter Printing & Postage", amount: "$1.50")
                        CostRow(label: "Certified Mail Service", amount: "$4.00")
                        CostRow(label: "Electronic Return Receipt", amount: "$2.10")
                        
                        Divider()
                            .background(AppColors.textTertiary)
                        
                        HStack {
                            Text("Total")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                            Spacer()
                            Text("$7.60")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(AppColors.gold)
                        }
                    }
                    .padding()
                    .background(AppColors.surface)
                    .cornerRadius(16)
                    
                    // Return receipt info
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(.green)
                        Text("Includes signature proof of delivery")
                            .font(.system(size: 14))
                            .foregroundColor(AppColors.textSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(AppColors.surface)
                    .cornerRadius(12)
                    
                    // Return address section
                    if let address = userAddress {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Return Address")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                            
                            Text(address.formatted)
                                .font(.system(size: 14))
                                .foregroundColor(AppColors.textSecondary)
                            
                            Button("Change Address") {
                                showingAddressForm = true
                            }
                            .font(.system(size: 14))
                            .foregroundColor(AppColors.gold)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(AppColors.surface)
                        .cornerRadius(12)
                    } else {
                        Button(action: { showingAddressForm = true }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Add Return Address")
                            }
                            .foregroundColor(AppColors.gold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppColors.surface)
                            .cornerRadius(12)
                        }
                    }
                    
                    // Error message
                    if let error = errorMessage {
                        Text(error)
                            .font(.system(size: 14))
                            .foregroundColor(.red)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(AppColors.surface)
                            .cornerRadius(12)
                    }
                    
                    // Send button
                    Button(action: sendCertifiedMail) {
                        HStack {
                            if isProcessing {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: AppColors.obsidian))
                            } else {
                                Image(systemName: "paperplane.fill")
                                Text("Send Certified Mail - $7.60")
                            }
                        }
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(AppColors.obsidian)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(AppColors.goldGradient)
                        .cornerRadius(16)
                        .shadow(color: AppColors.gold.opacity(0.4), radius: 16, y: 8)
                    }
                    .disabled(isProcessing || userAddress == nil)
                    .opacity(userAddress == nil ? 0.6 : 1.0)
                }
                .padding(24)
            }
            .background(AppColors.background)
            .navigationTitle("Certified Mail")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(AppColors.gold)
                }
            }
        }
        .sheet(isPresented: $showingAddressForm) {
            AddressFormSheet(address: $userAddress)
        }
    }
    
    private func sendCertifiedMail() {
        guard let returnAddress = userAddress else { return }
        
        isProcessing = true
        errorMessage = nil
        
        Task {
            do {
                // Generate PDF
                let userInfo = UserContactInfo(
                    name: returnAddress.name,
                    addressLine1: returnAddress.addressLine1,
                    addressLine2: returnAddress.addressLine2,
                    city: returnAddress.city,
                    state: returnAddress.state,
                    zip: returnAddress.zip,
                    email: returnAddress.email,
                    phone: returnAddress.phone
                )
                
                let pdfData = try AppealPDFGenerator.generate(
                    citation: citation,
                    appealText: appealText,
                    userInfo: userInfo
                )
                
                // Get city mailing address
                let cityAddress = try await CityAddressManager.shared.getMailingAddress(
                    for: citation.cityId ?? "sf"
                )
                
                // Send via Lob with certified mail
                let response = try await LobService.shared.sendCertifiedLetter(
                    to: cityAddress.toLobAddress(),
                    from: returnAddress.toLobAddress(),
                    pdfData: pdfData,
                    description: "Appeal for Citation \(citation.citationNumber)"
                )
                
                // Save tracking info to citation
                await saveTrackingInfo(response)
                
                // Start tracking
                await MailTracker.shared.startTracking(
                    citationId: citation.id.uuidString,
                    letterId: response.id
                )
                
                // Show success
                await MainActor.run {
                    isProcessing = false
                    dismiss()
                    // TODO: Navigate to confirmation view with tracking number
                }
            } catch {
                await MainActor.run {
                    isProcessing = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    private func saveTrackingInfo(_ response: LobLetterResponse) async {
        // Update citation with tracking info
        // Note: This requires updating the Citation storage mechanism
        // For now, MailTracker will handle the status tracking
        await MailTracker.shared.updateStatus(
            citationId: citation.id.uuidString,
            status: .mailed
        )
        
        // Parse expected delivery date if available
        if let deliveryDateString = response.expectedDeliveryDate {
            // Store delivery date for display
            // This would typically update the Citation model in storage
        }
    }
}

struct CostRow: View {
    let label: String
    let amount: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(AppColors.textSecondary)
            Spacer()
            Text(amount)
                .foregroundColor(.white)
        }
        .font(.system(size: 14))
    }
}

// MARK: - User Address Model

struct UserAddress {
    let name: String
    let addressLine1: String
    let addressLine2: String?
    let city: String
    let state: String
    let zip: String
    let email: String?
    let phone: String?
    
    var formatted: String {
        var lines: [String] = []
        lines.append(name)
        lines.append(addressLine1)
        if let line2 = addressLine2 {
            lines.append(line2)
        }
        lines.append("\(city), \(state) \(zip)")
        return lines.joined(separator: "\n")
    }
    
    func toLobAddress() -> LobAddress {
        LobAddress(
            name: name,
            addressLine1: addressLine1,
            addressLine2: addressLine2,
            city: city,
            state: state,
            zip: zip,
            country: "US"
        )
    }
}
