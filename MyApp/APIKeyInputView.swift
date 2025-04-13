//
//  APIKeyInputView.swift
//  MyApp
//
//  Created by Cong Le on 4/13/25.
//

import SwiftUI

struct APIKeyInputView: View {
    // Use @AppStorage for direct binding to UserDefaults
    @AppStorage("userOpenAIKey") private var apiKey: String = ""

    // Environment variable to dismiss the sheet
    @Environment(\.dismiss) var dismiss

    // Callbacks provided by the presenter
    let onSave: (String) -> Void
    let onCancel: () -> Void

    // Local state to track if the current apiKey is invalid
    @State private var isInvalidKeyAttempt = false

    var body: some View {
        NavigationView { // Use NavigationView for title and buttons
            VStack(alignment: .leading, spacing: 20) {
                Text("Please enter your OpenAI API key to use the live service.")
                    .font(.headline)
                    .padding(.horizontal)

                TextField("sk-...", text: $apiKey) // Use @AppStorage binding
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)
                     // Add red border if save was attempted with empty key
                    .overlay(
                         RoundedRectangle(cornerRadius: 5)
                              .stroke(isInvalidKeyAttempt && apiKey.isEmpty ? Color.red : Color.clear, lineWidth: 1)
                    )
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never) // API keys are case-sensitive

                if isInvalidKeyAttempt && apiKey.isEmpty {
                    Text("API Key cannot be empty.")
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                }

                Text("Your API key will be stored locally. For production apps, consider using the Keychain for better security.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)

                Spacer() // Pushes content to the top
            }
            .padding(.top, 20) // Add some padding at the top
            .navigationTitle("Enter API Key")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        // Set invalid key flag back to false before cancelling
                        isInvalidKeyAttempt = false
                        onCancel() // Call the cancel callback
                        dismiss()  // Dismiss the sheet
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                         // Basic validation - check if not empty
                         if apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                              isInvalidKeyAttempt = true // Show validation message
                         } else {
                              isInvalidKeyAttempt = false // Reset flag
                              onSave(apiKey) // Call the save callback with the key
                              dismiss()     // Dismiss the sheet
                         }
                    }
                    .buttonStyle(.borderedProminent) // Make save more prominent
                }
            }
        }
    }
}

// Preview for the Input View
#Preview {
    APIKeyInputView(
         onSave: { key in print("Preview Save: \(key)") },
         onCancel: { print("Preview Cancel") }
    )
}
