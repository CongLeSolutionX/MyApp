//
//  GoogleStyleModalView.swift
//  MyApp
//
//  Created by Cong Le on 4/6/25.
//

import SwiftUI

// Define custom colors to closely match the UI design
extension Color {
    // A light lavender/off-white background similar to the image
    static let modalBackground = Color(red: 248/255, green: 245/255, blue: 250/255)
    // A purple color for the primary button and potentially text
    static let actionPurple = Color.purple // Using system purple, can be adjusted
    // A subtle gray for borders or secondary elements
    static let subtleBorderGray = Color.gray.opacity(0.5)
}

struct GoogleStyleModalView: View {
    // Use Environment Variable to allow dismissing the modal
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 0) { // Use spacing 0 to control spacing manually with padding/dividers
            // --- Header Section ---
            HStack {
                Text("Title")
                    .font(.headline) // Standard headline font for titles
                    .fontWeight(.medium)

                Spacer() // Pushes title left and button right

                Button {
                    dismiss() // Standard dismiss action
                } label: {
                    Image(systemName: "xmark")
                        .font(.body) // Match body font size
                        .foregroundColor(.secondary) // Standard color for secondary icons
                }
            }
            .padding() // Add padding inside the header

            // --- Content Section ---
            // This Spacer represents the main content area, which is empty in the design
            Spacer()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.clear) // Ensure it doesn't interfere with the main background

            // --- Footer Section ---
            Divider() // Visual separator above the footer buttons

            HStack(spacing: 12) { // Add spacing between the buttons
                // --- Save Button (Primary Action) ---
                Button {
                    // Action to perform on Save
                    print("Save action triggered")
                    dismiss()
                } label: {
                    Text("Save")
                        .fontWeight(.medium)
                        .frame(minWidth: 80) // Give buttons a minimum reasonable width
                        .padding(.vertical, 10)
                        .padding(.horizontal, 24)
                        .background(Color.actionPurple)
                        .foregroundColor(.white)
                        .clipShape(Capsule()) // Capsule shape for fully rounded ends
                }

                // --- Cancel Button (Secondary Action) ---
                Button {
                    // Action to perform on Cancel
                    print("Cancel action triggered")
                    dismiss()
                } label: {
                     Text("Cancel")
                        .fontWeight(.medium)
                        .frame(minWidth: 80) // Give buttons a minimum reasonable width
                        .padding(.vertical, 10)
                        .padding(.horizontal, 24)
                        .foregroundColor(Color.actionPurple) // Use the accent color for text
                        .clipShape(Capsule())
                        .overlay( // Create the outline effect
                            Capsule()
                                .stroke(Color.subtleBorderGray, lineWidth: 1.5) // Subtle border
                        )
                }
            }
            .padding() // Add padding around the buttons in the footer
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity) // Ensure the VStack fills its container
        .background(Color.modalBackground) // Apply the lavender background to the entire modal content
        // Optionally add corner radius and shadow if the view itself should be styled
        // .cornerRadius(12)
        // .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

// --- Preview Provider ---
#Preview {
    // Simulate the modal presentation look for better context
    ZStack {
         // Dimmed background like typical modal presentations
         Color.black.opacity(0.7).ignoresSafeArea()

         // Present the modal view centered and sized
         GoogleStyleModalView()
            .frame(width: 320, height: 450) // Example fixed size for preview
            .cornerRadius(12) // Add corner radius to the preview container
            .shadow(radius: 10)
    }
}
