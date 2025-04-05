//
//  SendFeedbackView.swift
//  MyApp
//
//  Created by Cong Le on 4/4/25.
//

import SwiftUI

// Enum for Feedback Type
enum FeedbackType: String, CaseIterable, Identifiable {
    case bugReport = "Bug Report"
    case featureRequest = "Feature Request"
    case generalFeedback = "General Feedback"
    case compliment = "Compliment"

    var id: String { self.rawValue }
}

// MARK: - Feedback Screen View

struct FeedbackView: View {
    // --- State Variables ---
    @State private var feedbackType: FeedbackType = .generalFeedback
    @State private var feedbackMessage: String = ""
    @State private var userEmail: String = "" // Optional email
    @State private var showingConfirmationAlert = false
    @State private var submissionAttempted = false // Track if submission was tried

    // --- Environment ---
    @Environment(\.dismiss) private var dismiss // To dismiss the modal view

    // --- Constants ---
    private let feedbackPlaceholder = "Please provide detailed feedback here..."
    private let emailPlaceholder = "Your email (optional, for follow-up)"
    private let characterLimit = 2000 // Example character limit

    // --- Computed Properties ---
    private var isFeedbackMessageValid: Bool {
        !feedbackMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        feedbackMessage != feedbackPlaceholder // Ensure it's not just the placeholder
    }

    private var isFormValid: Bool {
        isFeedbackMessageValid
        // Add email validation if required, e.g., simple format check
    }

    private var remainingCharacters: Int {
        characterLimit - feedbackMessage.count
    }

    var body: some View {
        NavigationView { // Wrap in NavigationView for title and toolbar items
            Form {
                // Section: Feedback Type
                Section("Feedback Type") {
                    Picker("Select Type", selection: $feedbackType) {
                        ForEach(FeedbackType.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    // Consider .pickerStyle(.inline) or .menu if preferred
                }

                // Section: Feedback Message
                Section("Your Feedback (Required)") {
                    ZStack(alignment: .topLeading) {
                        // Placeholder Text
                        if feedbackMessage.isEmpty {
                            Text(feedbackPlaceholder)
                                .foregroundColor(Color(UIColor.placeholderText))
                                .padding(.top, 8) // Align with TextEditor padding
                                .padding(.leading, 5)
                                .allowsHitTesting(false) // Let taps pass through to TextEditor
                        }

                        // Actual TextEditor
                        TextEditor(text: $feedbackMessage)
                            .frame(minHeight: 150, maxHeight: 300) // Set reasonable height limits
                            .onChange(of: feedbackMessage) { newValue in
                                // Enforce character limit
                                if newValue.count > characterLimit {
                                    feedbackMessage = String(newValue.prefix(characterLimit))
                                }
                            }
                            .border(submissionAttempted && !isFeedbackMessageValid ? Color.red : Color.clear, width: 1) // Show red border if invalid after trying to submit
                    }

                    // Character Count Indicator
                    HStack {
                         Spacer() // Pushes the text to the right
                         Text("\(remainingCharacters)/\(characterLimit)")
                            .font(.caption)
                            .foregroundColor(remainingCharacters < 50 ? .orange : .gray) // Change color when near limit
                    }
                }

                 // Section: Contact Information (Optional)
                Section("Contact (Optional)") {
                     TextField(emailPlaceholder, text: $userEmail)
                         .keyboardType(.emailAddress)
                         .textContentType(.emailAddress)
                         .autocapitalization(.none)
                         .disableAutocorrection(true)
                 }

                // Section: Submit Button
                Section {
                    Button(action: submitFeedback) {
                        HStack {
                            Spacer()
                            Text("Submit Feedback")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                    .disabled(!isFormValid) // Disable button if form is not valid
                    .foregroundColor(isFormValid ? .accentColor : .gray) // Adjust text color based on validity
                }

            }
            .navigationTitle("Send Feedback")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Leading Item: Cancel Button
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        print("[Feedback Action] User tapped Cancel.")
                        dismiss() // Dismiss the view
                    }
                }
            }
            // Confirmation Alert
            .alert("Feedback Submitted", isPresented: $showingConfirmationAlert) {
                Button("OK") {
                    print("[Feedback Action] User acknowledged feedback submission.")
                    dismiss() // Dismiss the view after confirmation
                }
            } message: {
                Text("Thank you for your feedback! We appreciate you helping us improve.")
            }
        }
        // Apply theme if necessary (e.g., for dark mode consistency)
         .preferredColorScheme(.dark) // Match the rest of the app
         .accentColor(Color(red: 0.6, green: 0.8, blue: 1.0)) // Match button blue
    }

    // --- Action Methods ---
    private func submitFeedback() {
        submissionAttempted = true // Mark that submission was attempted
        guard isFormValid else {
             print("[Feedback Validation] Form is invalid. Submission halted.")
             // Optionally shake the view or provide more specific feedback
             return
         }

        print("[Feedback Action] Submit button tapped.")
        print("  -> Type: \(feedbackType.rawValue)")
        print("  -> Message: \(feedbackMessage)")
        print("  -> Email: \(userEmail.isEmpty ? "Not Provided" : userEmail)")

        // --- Simulate Network Request ---
        // In a real app, you would send this data to your backend API:
        // Task {
        //     do {
        //         let success = await sendFeedbackToAPI(type: feedbackType, message: feedbackMessage, email: userEmail)
        //         if success {
        //             showingConfirmationAlert = true
        //         } else {
        //             // Show an error alert
        //         }
        //     } catch {
        //         // Show an error alert
        //     }
        // }
        // --- End Simulation ---

        // For this example, just show the confirmation directly
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { // Simulate slight delay
            showingConfirmationAlert = true
            print("[Feedback Action] Feedback submission simulated successfully.")
        }
    }
}

// MARK: - Integration into SettingsScreenView

// Add this @State variable to SettingsScreenView:
// @State private var showingFeedbackSheet = false

// Modify the "Send Feedback" button action in SettingsScreenView:
/*
 Button("Send Feedback") {
     print("[Settings Action] Opening feedback form.")
     showingFeedbackSheet = true // Set the state to true
 }
 .sheet(isPresented: $showingFeedbackSheet) { // Add this sheet modifier
     FeedbackView() // Present the FeedbackView modally
 }
*/

// MARK: - Preview Provider

struct FeedbackView_Previews: PreviewProvider {
    static var previews: some View {
        FeedbackView()
            .preferredColorScheme(.dark) // Preview in dark mode
    }
}
