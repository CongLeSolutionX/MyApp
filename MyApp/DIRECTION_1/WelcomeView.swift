//
//  WelcomeView.swift
//  MyApp
//
//  Created by Cong Le on 4/9/25.
//

import SwiftUI

struct WelcomeView: View {

    var body: some View {
        // Use a ZStack to layer the background color behind the content
        ZStack {
            // Background Color - approximating the dark theme
            Color(red: 0.1, green: 0.1, blue: 0.1)
                .ignoresSafeArea() // Extend color to screen edges

            // Main vertical stack for content
            VStack(spacing: 20) { // Add some default spacing between elements
                Spacer() // Pushes content down a bit from the top

                // App Logo Placeholder (Replace "appLogoPlaceholder" with your actual image asset)
                // Using a system image as a fallback placeholder
                Image(systemName: "envelope.fill") // Placeholder icon
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .padding(15) // Inner padding for the dots effect if needed
                    .background(Color.yellow)
                    .foregroundColor(.white) // Color for the placeholder icon itself
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous)) // Rounded corners like an app icon
                    .padding(.bottom, 20) // Space below the logo

                // Welcome Title
                Text("Welcome to\nApple Invites")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 30) // Space below title

                // Action Row 1: Received Invitation
                InfoRow(
                    iconName: "envelope.fill",
                    text: "Received an invitation? Tap the link you were sent to see the event details."
                )

                // Action Row 2: New User
                InfoRow(
                    iconName: "plus.app.fill", // Using a combined + and square icon
                    text: "Just got the app? Continue to explore or set up your first event."
                )

                Spacer() // Pushes the info text and button towards the bottom

                // Informational Text Section
                VStack(spacing: 10) {
                    Image(systemName: "person.2.fill")
                        .font(.title3) // Slightly smaller icon
                        .foregroundColor(.yellow)

                    // Note: Making the link interactive requires AttributedString or splitting Text views
                    // This basic version styles the link part visually but isn't tappable
                    Text("Apple Invites allows iCloud+ subscribers to create party invitations, manage RSVPs, and create Shared Albums and Shared Playlists for their Apple Invites. Apple processes information about your event and invitees, such as the event name, location, and guest RSVP details, in order to send and display event details to guests. ")
                        .font(.footnote)
                        .foregroundColor(.gray)
                       // .multilineTextAlignment(.center)
                    +
                    Text("See how your data is managed...") // Link part
                        .font(.footnote)
                        .foregroundColor(.yellow) // Style as link
                        .fontWeight(.medium) // Slightly bolder for emphasis
                }
                .padding(.horizontal, 30) // Indent the info text slightly
                .padding(.bottom, 30) // Space above the button

                // Continue Button
                Button {
                    // Action to perform when continue is tapped
                    print("Continue button tapped!")
                } label: {
                    Text("Continue")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity) // Make button wide
                        .padding()
                        .background(Color.white)
                        .foregroundColor(.black)
                        .clipShape(Capsule()) // Rounded corners
                }
                .padding(.horizontal) // Padding on the sides of the button
                .padding(.bottom) // Padding below the button before safe area

            }
            .padding(.horizontal) // Overall horizontal padding for the main content
        }
    }
}

// Reusable struct for the icon + text rows
struct InfoRow: View {
    let iconName: String
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 15) { // Align items horizontally, align text to top
            Image(systemName: iconName)
                .font(.title2) // Control icon size
                .frame(width: 30) // Fixed width for alignment
                .foregroundColor(.yellow)

            Text(text)
                .font(.callout) // Appropriate text size
                .foregroundColor(.white)

            Spacer() // Pushes content to the left
        }
        .padding(.horizontal) // Padding within the row if needed
    }
}

// Preview Provider for Xcode Previews
#Preview {
    WelcomeView()
}
