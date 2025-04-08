//
//  ConfirmationView.swift
//  MyApp
//
//  Created by Cong Le on 4/7/25.
//

import SwiftUI

struct ConfirmationView_V1: View {
    // State or properties for dynamic data (optional for this static example)
    let amount: Double = 700.00
    let recipientName: String = "Kevin Nguyen"
    let recipientInitial: String = "N"
    let registeredName: String = "NGUYEN NGUYEN"
    let phoneNumber: String = "(714) 6969696"

    // Format currency
    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD" // Adjust if needed
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 16) { // Adjust spacing to match visual hierarchy

                // 1. Success Indicator
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.green)
                    .frame(width: 60, height: 60)
                    .padding(.top, 20) // Add padding from the nav bar

                // 2. Main Confirmation Message
                Text("We're sending your money now. \(recipientName) will get it in a few minutes.")
                    .font(.headline)
                    .fontWeight(.regular)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30) // Keep text from edge

                // 3. Amount Transferred
                Text(formattedAmount)
                    .font(.system(size: 48, weight: .light)) // Large, lighter weight font
                    .padding(.vertical, 5)

                // 4. Recipient Details
                VStack(spacing: 4) {
                    // Avatar
                    ZStack(alignment: .bottomTrailing) {
                        Image("My-meme-original")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.green)
                            .frame(width: 70, height: 70)
                            .padding(.top, 20) // Add padding from the nav bar

                        Text(recipientInitial)
                            .font(.system(size: 36, weight: .regular))
                            .foregroundColor(.white)

                        // Optional: Zelle Icon overlay - requires custom image asset
                        Image("zelle_icon") // Placeholder: Use your actual asset name
                             .resizable()
                             .scaledToFit()
                             .frame(width: 20, height: 20)
                             .background(Circle().fill(.purple)) // Example background
                             .clipShape(Circle())
                             .offset(x: 5, y: 5) // Adjust offset as needed
                             .foregroundColor(.white) // Make icon white if needed
                             // Comment out or replace if no Zelle icon needed/available

                    }
                    .padding(.bottom, 8)

                    // Recipient Name
                     Text(recipientName)
                         .font(.title2)
                         .fontWeight(.medium)

                     // Registration Details
                     Text("Registered as \(registeredName)")
                         .font(.caption)
                         .foregroundColor(.gray)

                     Text(phoneNumber)
                         .font(.caption)
                         .foregroundColor(.gray)
                }
                .padding(.vertical, 10) // Space around the recipient block

                // 5. Siri Shortcut Suggestion
                VStack(spacing: 15) {
                    Text("Add a Siri shortcut, such as “Pay \(recipientName),” to save time when sending money.")
                        .font(.footnote)
                        .foregroundColor(.secondary) // Slightly muted text color
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40) // Ensure text wraps nicely

                    Button {
                        // Action for "Add to Siri"
                        print("Add to Siri tapped")
                    } label: {
                        HStack(spacing: 8) {
                            // Using system image as placeholder for actual Siri icon
                            Image("siri_icon") // Placeholder: Use your actual asset name
                                 .resizable()
                                 .scaledToFit()
                                 .frame(width: 24, height: 24)
                                // Add specific styling for the gradient Siri icon if needed

                            Text("Add to Siri")
                                .fontWeight(.semibold)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .foregroundColor(.primary) // Text color for the button label
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.4), lineWidth: 1) // Light gray border
                        )
                    }
                }
                .padding(.vertical, 15) // Space around the Siri section

                // Pushes the Done button to the bottom
                Spacer()

                // 6. Action Button
                Button {
                   // Action for "Done"
                   print("Done tapped")
                } label: {
                   Text("Done")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity) // Make button full width
                        .padding()
                        .background(Color.blue) // Standard blue color
                        .foregroundColor(.white) // White text
                        .cornerRadius(8)
                }
                .padding(.horizontal) // Padding around the button horizontally
                .padding(.bottom) // Padding from the bottom safe area

            }
            .padding(.horizontal) // Overall padding for the main content VStack
            .navigationTitle("Confirmation")
            .navigationBarTitleDisplayMode(.inline) // Center the title
        }
    }
}

// MARK: - Preview
#Preview { // Using the new #Preview macro
    ConfirmationView_V1()
}

// Notes:
// 1. Replace placeholder Image names ("zelle_icon", "siri_icon") with your actual asset names.
// 2. The Zelle 'Z' icon and the specific Siri icon require custom image assets added to your project's Asset Catalog.
// 3. Adjust padding, spacing, font sizes/weights, and colors for pixel-perfect matching if required.
// 4. The actions for the buttons (`print(...)`) should be replaced with actual navigation or logic.
