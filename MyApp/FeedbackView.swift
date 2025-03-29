//
//  FeedbackView.swift
//  MyApp
//
//  Created by Cong Le on 3/28/25.
//

import SwiftUI

// Enum to represent the user's mood selection
enum FeedbackMood: String, CaseIterable, Identifiable {
    case happy = "face.smiling"
    case sad = "face.frowning"

    var id: String { self.rawValue } // Conformance to Identifiable for ForEach
}

// The main view structure
struct FeedbackView: View {
    // State for the text editor input
    @State private var feedbackText: String = ""
    // State to track the selected mood button
    @State private var selectedMood: FeedbackMood? = nil

    // Constants for styling to match the design
    private let containerBackgroundColor = Color(.systemGray6)
    private let elementBackgroundColor = Color(.systemGray5)
    private let elementBorderColor = Color(.systemGray4)
    private let placeholderColor = Color(.placeholderText)
    private let titleColor = Color(.systemGray2)
    private let iconColor = Color(.darkGray)
    private let selectedBorderColor = Color.blue
    private let cornerRadius: CGFloat = 10
    private let elementPadding: CGFloat = 10

    var body: some View {
        VStack(spacing: 16) {
            // 1. Title
            Text("Send Feedback")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(titleColor)
                .padding(.top, 8) // Add some top padding inside the container

            // 2. Text Editor with Placeholder logic
            ZStack(alignment: .topLeading) {
                TextEditor(text: $feedbackText)
                    .padding(4) // Inner padding for the text itself
                    .background(elementBackgroundColor) // Background for the editor area
                    .cornerRadius(cornerRadius)
                    .frame(height: 120) // Fixed height like h-28
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(elementBorderColor, lineWidth: 1)
                    )

                // Placeholder Text shown only when feedbackText is empty
                if feedbackText.isEmpty {
                    Text("Your feedback...")
                        .foregroundColor(placeholderColor)
                        .padding(.horizontal, elementPadding) // Align with TextEditor's visual padding
                        .padding(.vertical, 12)
                        .allowsHitTesting(false) // Allows taps to go through to the TextEditor
                }
            }

            // 3. Bottom Row: Mood buttons and Send button
            HStack(spacing: 10) {
                // Mood Buttons (Happy and Sad)
                ForEach(FeedbackMood.allCases) { mood in
                    moodButton(mood: mood)
                }

                Spacer() // Creates the gap like col-span-2

                // Send Button
                sendButton()

            } // End HStack
            .frame(height: 44) // Give the HStack a defined height

        } // End VStack
        .padding(elementPadding) // Padding inside the main container
        .background(containerBackgroundColor) // Background for the whole component
        .cornerRadius(cornerRadius + 4) // Slightly larger radius for the main container
        .padding() // Padding outside the container for spacing from screen edges
        .onAppear {
            loadFeedback() // Load data when the view appears
        }
    }

    // Reusable view builder for the mood buttons
    @ViewBuilder
    private func moodButton(mood: FeedbackMood) -> some View {
        let isSelected = selectedMood == mood
        Button {
            // Toggle selection: If already selected, deselect; otherwise, select.
            selectedMood = isSelected ? nil : mood
        } label: {
            Image(systemName: mood.rawValue)
                .font(.title2)
                .foregroundColor(iconColor)
                .frame(width: 30, height: 30) // Ensure consistent size
        }
        .padding(elementPadding / 2) // Smaller padding for these buttons
        .background(elementBackgroundColor)
        .cornerRadius(cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(isSelected ? selectedBorderColor : elementBorderColor, lineWidth: isSelected ? 2 : 1)
        )
        .scaleEffect(isSelected ? 1.05 : 1.0) // Add a subtle scale effect on selection
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected) // Animate selection change
    }

    // View builder for the Send button
    @ViewBuilder
    private func sendButton() -> some View {
        // Determine if the button should be enabled
        let isEnabled = !feedbackText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && selectedMood != nil

        Button {
            saveFeedback()
            // Optionally clear the form after saving
            feedbackText = ""
            selectedMood = nil
        } label: {
            Image(systemName: "paperplane")
                .font(.title2)
                .foregroundColor(isEnabled ? iconColor : Color.gray) // Dim icon when disabled
                .frame(minWidth: 40) // Ensure it's wider than mood buttons
        }
        .padding(.vertical, elementPadding / 2)
        .padding(.horizontal, elementPadding * 1.5) // Make it wider with horizontal padding
        .background(elementBackgroundColor)
        .cornerRadius(cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(elementBorderColor, lineWidth: 1)
        )
        .disabled(!isEnabled) // Disable the button based on state
        .opacity(isEnabled ? 1.0 : 0.6) // Reduce opacity when disabled
        .animation(.easeOut(duration: 0.2), value: isEnabled) // Animate enabled state change
    }

    // --- Local Storage Logic ---

    // Function to save the current feedback state to UserDefaults
    private func saveFeedback() {
        guard let mood = selectedMood else {
            print("Cannot save feedback: Mood not selected.")
            return
        }
        if feedbackText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
             print("Cannot save feedback: Text is empty.")
            return
        }

        let defaults = UserDefaults.standard
        defaults.set(feedbackText, forKey: "UserFeedbackText")
        // Store the rawValue (string) of the enum case
        defaults.set(mood.rawValue, forKey: "UserFeedbackMoodRawValue")

        print("Feedback Saved:")
        print("- Text: \(feedbackText)")
        print("- Mood: \(mood.rawValue)")

        // Consider giving user feedback (e.g., an alert or visual cue)
    }

    // Function to load previously saved feedback from UserDefaults
    private func loadFeedback() {
        let defaults = UserDefaults.standard
        feedbackText = defaults.string(forKey: "UserFeedbackText") ?? ""

        if let moodRawValue = defaults.string(forKey: "UserFeedbackMoodRawValue"),
           let loadedMood = FeedbackMood(rawValue: moodRawValue) {
            selectedMood = loadedMood
            print("Loaded Mood: \(loadedMood.rawValue)")
        } else {
            selectedMood = nil // Ensure it's nil if nothing valid is loaded
             print("No valid mood loaded or found.")
        }
         print("Loaded Text: \(feedbackText)")
    }
}

//// --- App Entry Point and Preview ---
//
//// Simple App structure to host the FeedbackView
//@main
//struct FeedbackApp: App {
//    var body: some Scene {
//        WindowGroup {
//            // Embed in a ZStack to easily control the background for preview
//            ZStack {
//                // Match the dark background from the original image preview context
//                 Color(.black).ignoresSafeArea()
//                 FeedbackView()
//            }
//        }
//    }
//}

// Preview Provider for Xcode Canvas
struct FeedbackView_Previews: PreviewProvider {
    static var previews: some View {
         ZStack {
             // Dark background for preview consistency
             Color(.black).ignoresSafeArea()
             FeedbackView()
         }
    }
}
