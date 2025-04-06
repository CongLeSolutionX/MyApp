//
//  PasswordShareView.swift
//  MyApp
//
//  Created by Cong Le on 4/5/25.
//

import SwiftUI

/// # PasswordShareView
/// A SwiftUI view representing the UI for sharing a password,
/// based on the Google Password Manager screenshot.
///
/// ## Features:
/// - Displays overlapping user avatars.
/// - Shows the Google Password Manager key icon.
/// - Presents a clear title and descriptive text.
/// - Includes a prominent "Share" button.
/// - Encapsulated within a styled card container.
struct PasswordShareView: View {

    // --- Properties ---
    // Placeholder data matching the screenshot's context
    let recipientName: String = "Melody Beckett"
    let website: String = "gurushape.com"

    // --- Body ---
    var body: some View {
        // Main container mimicking the card/sheet appearance
        VStack(spacing: 20) { // Vertical stack for content elements

            // --- Top Image Section ---
            VStack(spacing: 8) {
                // Placeholder for overlapping profile pictures
                ZStack {
                    // Background Avatar (Slightly behind)
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())
                        .foregroundColor(.gray.opacity(0.5)) // Slightly desaturated color
                        .offset(x: -15) // Offset left for overlap effect

                    // Foreground Avatar (Slightly in front)
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())
                        .foregroundColor(.cyan.opacity(0.6)) // Different color for distinction
                        .overlay(Circle().stroke(Color(.systemGray6), lineWidth: 2)) // White border for separation
                        .offset(x: 15) // Offset right for overlap effect
                }
                .frame(height: 70) // Ensure enough height for avatars

                 // Placeholder for Google Password Manager logo (Key Icon)
                Image(systemName: "key.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 25, height: 25)
                    .foregroundColor(.blue) // Google Blue color approximation
            }
            .padding(.top, 25) // Add padding above the avatar section

            // --- Text Content Section ---
            VStack(spacing: 8) {
                // Title
                Text("Share Your Passwords")
                    .font(.title2) // Slightly smaller than .title for balance
                    .fontWeight(.semibold) // Semibold for emphasis
                    .foregroundColor(.primary) // Standard text color

                // Description
                // Using AttributedString for potential future styling of "Learn more"
                Text(descriptionAttributedString())
                    .font(.subheadline) // Appropriate size for descriptive text
                    .foregroundColor(.secondary) // Grayed out for secondary info
                    .multilineTextAlignment(.center) // Center align as per screenshot
                    .lineSpacing(4) // Add a bit of line spacing for readability
                    .padding(.horizontal, 25) // Prevent text from touching edges
            }

            // --- Action Button Section ---
            Button(action: {
                // Define the action to perform when the share button is tapped
                performShareAction()
            }) {
                Text("Share")
                    .fontWeight(.semibold) // Match title weight
                    .frame(maxWidth: .infinity) // Make button full width
                    .padding(.vertical, 12) // Vertical padding for button height
                    .background(Color.blue) // Google Blue background
                    .foregroundColor(.white) // White text color
                    .cornerRadius(10) // Rounded corners for the button
            }
            .padding(.horizontal) // Horizontal padding around the button
            .padding(.bottom) // Padding at the bottom edge of the card
            .padding(.top, 10) // Add some space above the button

        }
        // --- Container Styling ---
        .background(Color(.systemGray6)) // Use a system light gray for the card background
        .cornerRadius(20) // Generous corner radius for the card
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4) // Subtle shadow for depth
        .padding() // Padding around the entire card view
    }

    // --- Helper Methods ---

    /// Creates the attributed string for the description text.
    /// This allows for potential future styling (e.g., making "Learn more" interactive).
    private func descriptionAttributedString() -> AttributedString {
        var string = AttributedString("\(recipientName) can now use your username and password when they use Google Password Manager to sign in to \(website). ")
        var learnMore = AttributedString("Learn more")
        // Example: If "Learn more" needed basic styling (uncomment if needed)
        // learnMore.foregroundColor = .blue
        // learnMore.underlineStyle = .single
        // learnMore.link = URL(string: "https://support.google.com/chrome/?p=sharing_password") // Example link

        string.append(learnMore)
        return string
    }

    /// Placeholder function for the share button's action.
    private func performShareAction() {
        print("Share button tapped! Implement sharing logic here.")
        // In a real app, this would initiate the password sharing flow.
    }
}

// --- Preview Provider ---
/// Provides a preview of the PasswordShareView in Xcode Canvas.
struct PasswordShareView_Previews: PreviewProvider {
    static var previews: some View {
        // Simulate the dark background context from the original screenshot
        ZStack {
            Color.black.opacity(0.85).edgesIgnoringSafeArea(.all) // Dark background
            PasswordShareView()
        }
        .previewDisplayName("Password Share UI") // Name for the preview

        // Also preview on a standard background
        PasswordShareView()
            .padding()
            .background(Color.gray.opacity(0.1))
            .previewDisplayName("Password Share UI (Light)")
            .previewLayout(.sizeThatFits) // Make preview fit the content size
    }
}
