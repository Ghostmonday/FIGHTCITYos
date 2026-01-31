//
//  AddressFormSheet.swift
//  FightCity
//
//  Return address collection form for certified mail
//

import SwiftUI

struct AddressFormSheet: View {
    @Binding var address: UserAddress?
    @Environment(\.dismiss) var dismiss
    
    @State private var name: String = ""
    @State private var addressLine1: String = ""
    @State private var addressLine2: String = ""
    @State private var city: String = ""
    @State private var state: String = ""
    @State private var zip: String = ""
    @State private var email: String = ""
    @State private var phone: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Contact Information")) {
                    TextField("Full Name", text: $name)
                    TextField("Email (Optional)", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    TextField("Phone (Optional)", text: $phone)
                        .keyboardType(.phonePad)
                }
                
                Section(header: Text("Address")) {
                    TextField("Address Line 1", text: $addressLine1)
                    TextField("Address Line 2 (Optional)", text: $addressLine2)
                    TextField("City", text: $city)
                    TextField("State", text: $state)
                        .autocapitalization(.allCharacters)
                    TextField("ZIP Code", text: $zip)
                        .keyboardType(.numberPad)
                }
            }
            .background(AppColors.background)
            .navigationTitle("Return Address")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(AppColors.gold)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveAddress()
                    }
                    .foregroundColor(AppColors.gold)
                    .disabled(!isValid)
                }
            }
        }
        .onAppear {
            if let existing = address {
                name = existing.name
                addressLine1 = existing.addressLine1
                addressLine2 = existing.addressLine2 ?? ""
                city = existing.city
                state = existing.state
                zip = existing.zip
                email = existing.email ?? ""
                phone = existing.phone ?? ""
            }
        }
    }
    
    private var isValid: Bool {
        !name.isEmpty &&
        !addressLine1.isEmpty &&
        !city.isEmpty &&
        !state.isEmpty &&
        !zip.isEmpty
    }
    
    private func saveAddress() {
        address = UserAddress(
            name: name,
            addressLine1: addressLine1,
            addressLine2: addressLine2.isEmpty ? nil : addressLine2,
            city: city,
            state: state,
            zip: zip,
            email: email.isEmpty ? nil : email,
            phone: phone.isEmpty ? nil : phone
        )
        dismiss()
    }
}
