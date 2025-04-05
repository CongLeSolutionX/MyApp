//
//  AddCardView_V2.swift
//  MyApp
//
//  Created by Cong Le on 4/5/25.
//

import SwiftUI

// AlertInfo struct should be defined here or globally accessible
struct AlertInfo: Identifiable {
    let id = UUID()
    var title: String
    var message: String
}

struct AddCardView: View {
    @State private var cardNumber: String = ""
    @State private var securityCode: String = ""
    @State private var alertInfo: AlertInfo? = nil // State for the alert

    @Environment(\.presentationMode) var presentationMode
    let starbucksGreen = Color(red: 0.0, green: 0.4, blue: 0.2)
    let starbucksGold = Color(red: 0.76, green: 0.6, blue: 0.32)
    let backgroundColor = Color(.systemGray6)

    // --- Validation Function ---
     func isCardNumberValid() -> Bool {
         let cleanedNumber = cardNumber.replacingOccurrences(of: " ", with: "")
         // Basic validation: Check for 16 digits exactly
         return cleanedNumber.count == 16 && cleanedNumber.allSatisfy { $0.isNumber }
     }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // --- Top Bar ---
            HStack {
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .foregroundColor(.primary)
                }
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top)
            .padding(.bottom, 5)

            // --- Screen Title ---
            Text("Add a card")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.horizontal)
                .padding(.bottom, 20)

            // --- Input Card Section ---
            VStack(spacing: 0) {
                // --- Card Number Row ---
                HStack {
                    TextField("Starbucks Card number", text: $cardNumber)
                        .keyboardType(.numberPad)

                    Spacer()

                    Image(systemName: "barcode.viewfinder")
                        .foregroundColor(starbucksGreen)
                        .font(.title2)
                }
                .padding(.horizontal)
                .padding(.vertical, 15)

                Divider()

                // --- Security Code Row ---
                SecureField("Security code", text: $securityCode)
                    .keyboardType(.numberPad)
                    .padding(.horizontal)
                    .padding(.vertical, 15)

                // --- Gold Decorative Bar ---
                starbucksGold
                    .frame(height: 40)
            }
            .background(Color.white)
            .cornerRadius(15)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
            .padding(.horizontal)

            // --- Informational Text ---
            Text("Earn Stars toward Rewards when you pay with a registered Starbucks Card.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.horizontal)
                .padding(.top, 20)

            Spacer()

            // --- Add Card Button ---
            Button {
                // --- Action with Validation ---
                if isCardNumberValid() {
                    // Validation successful - proceed with adding card (or print for now)
                    print("Add Card button tapped - Validation Passed")
                    print("Card Number: \(cardNumber), Security Code: \(securityCode)")
                    // In a real app, call your API or data store here
                    // You might want to dismiss the view on success too
                    // presentationMode.wrappedValue.dismiss()
                } else {
                    // Validation failed - Prepare and show the alert
                    alertInfo = AlertInfo(
                        title: "The card number might be incorrect",
                        message: "Check your card information and try again."
                    )
                    print("Add Card button tapped - Validation Failed")
                }
            } label: {
                Text("Add card")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(starbucksGreen)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .background(backgroundColor.ignoresSafeArea())
        .navigationBarHidden(true)
        // --- Attach the Alert Modifier ---
        .alert(item: $alertInfo) { info in
            Alert(
                title: Text(info.title),
                message: Text(info.message),
                dismissButton: .default(Text("Got it")) // Single dismiss button
            )
        }
    }
}

// MARK: - Preview Provider
struct AddCardView_Previews: PreviewProvider {
    static var previews: some View {
        AddCardView()
    }
}
