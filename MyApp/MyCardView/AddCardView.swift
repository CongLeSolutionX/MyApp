////
////  AddCardView.swift
////  MyApp
////
////  Created by Cong Le on 4/5/25.
////
//
//import SwiftUI
//
//struct AddCardView: View {
//    // State variables to hold the text field inputs
//    @State private var cardNumber: String = ""
//    @State private var securityCode: String = ""
//
//    // Environment variable to dismiss the view (assuming it's presented modally)
//    @Environment(\.presentationMode) var presentationMode
//
//    // Define Starbucks brand colors (approximations)
//    let starbucksGreen = Color(red: 0.0, green: 0.4, blue: 0.2) // Darker green
//    let starbucksGold = Color(red: 0.76, green: 0.6, blue: 0.32) // Mustard/Gold color
//    let backgroundColor = Color(.systemGray6) // Light background typical in iOS apps
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 0) {
//            // --- Top Bar ---
//            HStack {
//                Button {
//                    presentationMode.wrappedValue.dismiss() // Action to close the view
//                } label: {
//                    Image(systemName: "xmark")
//                        .font(.title2)
//                        .foregroundColor(.primary) // Use primary color for adaptability
//                }
//                Spacer() // Pushes the button to the left
//            }
//            .padding(.horizontal)
//            .padding(.top) // Add some padding from the status bar
//            .padding(.bottom, 5)
//
//            // --- Screen Title ---
//            Text("Add a card")
//                .font(.largeTitle)
//                .fontWeight(.bold)
//                .padding(.horizontal)
//                .padding(.bottom, 20) // Space below title
//
//            // --- Input Card Section ---
//            VStack(spacing: 0) {
//                // --- Card Number Row ---
//                HStack {
//                    TextField("Starbucks Card number", text: $cardNumber)
//                        .keyboardType(.numberPad) // Appropriate keyboard
//
//                    Spacer() // Pushes text field left and icon right
//
//                    Image(systemName: "barcode.viewfinder") // Scanner icon
//                        .foregroundColor(starbucksGreen) // Use brand color
//                        .font(.title2)
//                }
//                .padding(.horizontal)
//                .padding(.vertical, 15) // Vertical padding for the row
//
//                Divider() // Thin separator line
//
//                // --- Security Code Row ---
//                SecureField("Security code", text: $securityCode)
//                    .keyboardType(.numberPad) // Appropriate keyboard
//                    .padding(.horizontal)
//                    .padding(.vertical, 15) // Vertical padding for the row
//
//                // --- Gold Decorative Bar ---
//                starbucksGold
//                    .frame(height: 40) // Height of the gold bar
//            }
//            .background(Color.white) // Card background
//            .cornerRadius(15) // Rounded corners for the card
//            .overlay(
//                RoundedRectangle(cornerRadius: 15)
//                    .stroke(Color.gray.opacity(0.2), lineWidth: 1) // Subtle border
//            )
//            .padding(.horizontal) // Padding around the card
//
//            // --- Informational Text ---
//            Text("Earn Stars toward Rewards when you pay with a registered Starbucks Card.")
//                .font(.subheadline)
//                .foregroundColor(.secondary) // Use secondary color for less emphasis
//                .padding(.horizontal)
//                .padding(.top, 20) // Space above the text
//
//            Spacer() // Pushes the button to the bottom
//
//            // --- Add Card Button ---
//            Button {
//                // Action for adding the card goes here
//                print("Add Card button tapped")
//                print("Card Number: \(cardNumber), Security Code: \(securityCode)")
//            } label: {
//                Text("Add card")
//                    .fontWeight(.semibold)
//                    .frame(maxWidth: .infinity) // Make button wide
//                    .padding()
//                    .background(starbucksGreen) // Button background color
//                    .foregroundColor(.white) // Button text color
//                    .clipShape(Capsule()) // Rounded ends
//            }
//            .padding(.horizontal)
//            .padding(.bottom) // Padding from the bottom edge
//        }
//        .background(backgroundColor.ignoresSafeArea()) // Extend background color
//        .navigationBarHidden(true) // Hide the default navigation bar if embedded
//    }
//}
//
//// MARK: - Preview Provider
//struct AddCardView_Previews: PreviewProvider {
//    static var previews: some View {
//        // Wrap in NavigationView for realistic preview context if needed elsewhere
//        // NavigationView {
//             AddCardView()
//        // }
//    }
//}
