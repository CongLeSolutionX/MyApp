//
//  ConfirmationView_V2.swift
//  MyApp
//
//  Created by Cong Le on 4/7/25.
//

import SwiftUI
// Import IntentsUI if you were doing real Siri integration
// import IntentsUI

struct ConfirmationView: View {

    // MARK: - Properties (Data Input)
    let amount: Double
    let recipientName: String
    let recipientInitial: String
    let registeredName: String
    let phoneNumber: String
    let transactionID: String // Added for potential use (e.g., Siri Intent)

    // Environment properties
    @Environment(\.dismiss) var dismiss // Use Environment's dismiss action

    // State properties for interactive elements
    @State private var showingSiriAlert = false
    @State private var siriAlertTitle = ""
    @State private var siriAlertMessage = ""

    // MARK: - Constants (Styling & Layout)
    private enum Constants {
        static let checkmarkSize: CGFloat = 60
        static let avatarSize: CGFloat = 70
        static let zelleIconSize: CGFloat = 22
        static let siriIconSize: CGFloat = 24
        static let buttonCornerRadius: CGFloat = 8
        static let defaultPadding: CGFloat = 16
        static let horizontalTextPadding: CGFloat = 30
        static let siriHorizontalPadding: CGFloat = 40
        static let buttonVerticalPadding: CGFloat = 12
        static let avatarInitialFontSize: CGFloat = 36
        static let amountFontSize: CGFloat = 48
    }

    // MARK: - Computed Properties
    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD" // Or dynamically set based on context
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }

    var siriSuggestedPhrase: String {
        "Pay \(recipientName) \(formattedAmount)" // Example phrase
    }

    // MARK: - Body
    var body: some View {
        // Removed NavigationView - Typically, a confirmation screen is pushed or presented modally.
        // The hosting view (e.g., the one presenting this) would manage the Navigation stack/title.
        // If this *must* be the root view in a Navigation, uncomment the NavigationView.
        // NavigationView {
            VStack(spacing: Constants.defaultPadding) {

                successIndicator
                    .padding(.top, Constants.defaultPadding * 1.5) // More spacing from top

                confirmationMessage

                amountDisplay
                    .padding(.vertical, Constants.defaultPadding / 3)

                recipientDetails
                    .padding(.vertical, Constants.defaultPadding / 2)

                siriActionSection
                    .padding(.vertical, Constants.defaultPadding)

                Spacer() // Pushes the Done button to the bottom

                doneButton
                    .padding(.horizontal, Constants.defaultPadding)
                    .padding(.bottom, Constants.defaultPadding) // Ensure padding from safe area

            }
            .padding(.horizontal, Constants.defaultPadding) // Overall horizontal padding for content
            // .navigationTitle("Confirmation") // Set title on the *presenting* view's NavigationView
            // .navigationBarTitleDisplayMode(.inline)
            .alert(isPresented: $showingSiriAlert) {
                 Alert(title: Text(siriAlertTitle), message: Text(siriAlertMessage), dismissButton: .default(Text("OK")))
            }
        // } // End of NavigationView if uncommented
    }

    // MARK: - Subviews (for organization)

    private var successIndicator: some View {
        Image(systemName: "checkmark.circle.fill")
            .resizable()
            .scaledToFit()
            .foregroundColor(.green)
            .frame(width: Constants.checkmarkSize, height: Constants.checkmarkSize)
            .accessibilityLabel("Success")
    }

    private var confirmationMessage: some View {
        Text("We're sending your money now. \(recipientName) will get it in a few minutes.")
            .font(.headline)
            .fontWeight(.regular)
            .multilineTextAlignment(.center)
            .padding(.horizontal, Constants.horizontalTextPadding)
            .accessibilityElement(children: .combine) // Read as one block
    }

    private var amountDisplay: some View {
        Text(formattedAmount)
            .font(.system(size: Constants.amountFontSize, weight: .light))
            .accessibilityLabel("Amount sent: \(formattedAmount)")
    }

    private var recipientDetails: some View {
        VStack(spacing: 4) {
            avatarView
                .padding(.bottom, Constants.defaultPadding / 2)

            Text(recipientName)
                .font(.title2)
                .fontWeight(.medium)

            Text("Registered as \(registeredName)")
                .font(.caption)
                .foregroundColor(.secondary) // Use semantic color

            Text(phoneNumber)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .accessibilityElement(children: .contain) // Group accessibility
        .accessibilityLabel("Recipient: \(recipientName), Registered as \(registeredName), Phone number \(phoneNumber)")
    }

    private var avatarView: some View {
        ZStack(alignment: .bottomTrailing) {
            Circle()
                .fill(Color.gray.opacity(0.5)) // Slightly lighter gray
                .frame(width: Constants.avatarSize, height: Constants.avatarSize)

            Text(recipientInitial)
                .font(.system(size: Constants.avatarInitialFontSize, weight: .regular))
                .foregroundColor(.white)

            // Mock Zelle Icon Overlay
            Image(systemName: "z.circle.fill") // Using SF Symbol as placeholder
                 .resizable()
                 .scaledToFit()
                 .frame(width: Constants.zelleIconSize, height: Constants.zelleIconSize)
                 .foregroundColor(.purple) // Zelle-like color
                 .background(Circle().fill(.white)) // White background for contrast
                 .clipShape(Circle())
                 .offset(x: 5, y: 5) // Adjust offset visually
                 .accessibilityLabel("Zelle indicator")
        }
    }

    private var siriActionSection: some View {
        VStack(spacing: 15) {
            Text("Add a Siri shortcut, like “\(siriSuggestedPhrase)”, to save time sending money.")
                .font(.footnote)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Constants.siriHorizontalPadding)
                .accessibilityElement(children: .combine)

            Button {
                // --- Functional Action ---
                attemptToAddSiriShortcut()
            } label: {
                HStack(spacing: 8) {
                    // Mock Siri Icon using SF Symbol
                    Image(systemName: "mic.fill") // SF Symbol for Siri/mic
                         .resizable()
                         .scaledToFit()
                         .frame(width: Constants.siriIconSize, height: Constants.siriIconSize)
                         .foregroundColor(Color(uiColor: .systemBlue)) // Use system blue for consistency

                    Text("Add to Siri")
                        .fontWeight(.semibold)
                }
                .padding(.horizontal, Constants.defaultPadding * 1.2)
                .padding(.vertical, Constants.buttonVerticalPadding * 0.8)
                .foregroundColor(Color(uiColor: .label)) // Adapts to light/dark mode
                .overlay(
                    RoundedRectangle(cornerRadius: Constants.buttonCornerRadius)
                        .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                )
            }
            .accessibilityHint("Adds a voice command to repeat this transaction.")
        }
    }

    private var doneButton: some View {
        Button {
            // --- Functional Action ---
            dismiss() // Dismiss the current view
            print("Done button tapped - Dismissing view.")
        } label: {
           Text("Done")
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Constants.buttonVerticalPadding) // Consistent vertical padding
                .background(Color.blue) // Or your app's primary action color
                .foregroundColor(.white)
                .cornerRadius(Constants.buttonCornerRadius)
        }
        .accessibilityLabel("Done")
        .accessibilityHint("Returns to the previous screen.")
    }

    // MARK: - Helper Functions

    private func attemptToAddSiriShortcut() {
        // --- Placeholder Logic ---
        // In a real app, you'd use Intents & IntentsUI framework here.
        // This involves creating an INIntent, donating it, and potentially
        // presenting INUIAddVoiceShortcutViewController.

        print("Attempting to add Siri shortcut for transaction ID: \(transactionID)...")

        // Simulate success or failure (e.g., based on some condition or randomly)
        let didSucceed = Bool.random() // 50/50 chance for demo

        if didSucceed {
            siriAlertTitle = "Siri Shortcut Added"
            siriAlertMessage = "You can now say \"\(siriSuggestedPhrase)\" to repeat this payment."
            print("Simulated Siri shortcut addition SUCCEEDED.")
        } else {
            siriAlertTitle = "Could Not Add Shortcut"
            siriAlertMessage = "There was an issue adding the Siri shortcut. Please try again later."
             print("Simulated Siri shortcut addition FAILED.")
           }
        showingSiriAlert = true // Trigger the alert
    }
}

// MARK: - Preview

#Preview { // Using the current #Preview macro
    // Provide mock data for the preview
    ConfirmationView(
        amount: 120.00,
        recipientName: "Nguyen M",
        recipientInitial: "N",
        registeredName: "KEVIN NGUYEN",
        phoneNumber: "(714) 696-9696",
        transactionID: "TXN-12345-ABCDE" // Example transaction ID
    )
    // Wrap in NavigationView ONLY IF TESTING standalone navigation behavior
    // NavigationView {
    //     ConfirmationView(...)
    // }
}
