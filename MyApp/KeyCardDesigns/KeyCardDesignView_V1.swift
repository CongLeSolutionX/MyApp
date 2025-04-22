//
//  KeyCardDesign.swift
//  MyApp
//
//  Created by Cong Le on 4/21/25.
//

import SwiftUI

// Represents the main view structure mimicking the screenshot
struct HotelKeyView: View {
    var body: some View {
        // Use NavigationView to get the navigation bar
        NavigationView {
            // Main vertical stack for the content
            VStack(spacing: 40) { // Add spacing between card and instruction
                Spacer() // Push card towards the top, but allow space for nav bar

                HotelKeyCard()
                    .padding(.horizontal) // Add horizontal padding to the card

                Spacer() // Pushes the instruction area down a bit

                HoldNearReaderInstruction()

                Spacer() // Pushes instruction area up a bit, centering it roughly
                Spacer() // Add more space towards the bottom
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity) // Allow VStack to expand
            .background(Color(.systemGroupedBackground)) // Match the light gray background
            .navigationTitle("") // Hide the default title if any
            .navigationBarTitleDisplayMode(.inline) // Keep title area compact
            .toolbar {
                // Leading Button (Done)
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        // Action for Done button
                        print("Done tapped")
                    }
                     .foregroundColor(.blue) // Standard blue for interactive elements
                }
                // Trailing Button (Ellipsis)
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        // Action for Ellipsis button
                        print("More options tapped")
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.title2) // Make icon slightly larger
                    }
                    .foregroundColor(.black) // Match the screenshot color
                }
            }
        }
        // Apply a specific style if needed, like for iPhone presentation
        .navigationViewStyle(.stack)
    }
}

// Represents the Hotel Key Card element
struct HotelKeyCard: View {
    var body: some View {
        ZStack(alignment: .topLeading) { // Align content within the ZStack
            // Background Image - Replace "palm_trees" with your actual image asset name
            Image("palm_trees_placeholder") // Use a placeholder if needed
                .resizable()
                .scaledToFill()
                // Define a fixed aspect ratio or height for the card
                .frame(height: 220)
                .clipped() // Clip the image to the ZStack's bounds (including corner radius)

            // Subtle overlay gradient for text readability (optional but recommended)
            LinearGradient(
                gradient: Gradient(colors: [Color.black.opacity(0.5), Color.black.opacity(0.0)]),
                startPoint: .top,
                endPoint: .center
            )
             LinearGradient(
                gradient: Gradient(colors: [Color.black.opacity(0.5), Color.black.opacity(0.0)]),
                startPoint: .bottom,
                endPoint: .center
            )

            // Overlay Content Layer
            VStack {
                HStack(alignment: .top) {
                    // Top Left Icon
                    Image(systemName: "snowflake")
                        .font(.title)
                        .foregroundColor(.white)
                        .padding([.top, .leading]) // Add padding

                    Spacer() // Pushes elements to sides

                    // Top Right Text (Location & Date)
                    VStack(alignment: .trailing) {
                        Text("MAUI, HAWAII")
                            .font(.caption.weight(.medium))
                        Text("SEP 23 - OCT 1")
                            .font(.headline)
                    }
                    .foregroundColor(.white)
                    .shadow(radius: 1) // Add subtle shadow for readability
                    .padding([.top, .trailing]) // Add padding
                }

                Spacer() // Pushes bottom text down

                HStack {
                    // Bottom Left Text
                    Text("Beachfront Suites")
                        .font(.title2.weight(.semibold))
                        .foregroundColor(.white)
                        .shadow(radius: 1) // Add subtle shadow
                        .padding([.leading, .bottom]) // Add padding

                    Spacer() // Pushes text to the left
                }
            }
        }
        // Apply styling to the ZStack itself (the card)
        .frame(height: 220) // Ensure ZStack has the same height as the image frame
        .background(Color.gray) // Fallback background if image fails
        .cornerRadius(15) // Apply rounded corners to the card
         .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2) // Add a subtle shadow to lift the card
    }
}

// Represents the "Hold Near Reader" instruction area
struct HoldNearReaderInstruction: View {
    var body: some View {
        VStack(spacing: 8) { // Spacing between icon and text
            // Icon - Using an appropriate SF Symbol
            Image(systemName: "iphone.radiowaves.left.and.right.circle")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .foregroundColor(.blue) // Match the blue color

            // Instruction Text
            Text("Hold Near Reader")
                .font(.title3)
                .foregroundColor(.secondary) // Use secondary color for less emphasis
        }
    }
}

// Add a placeholder image if you don't have the actual one
#if DEBUG
struct HotelKeyView_Previews: PreviewProvider {
    static var previews: some View {
        // Create a dummy image asset named "palm_trees_placeholder"
        // Or replace the image name in HotelKeyCard with Color.blue or similar
        // for previewing purposes if you don't have an image.
        HotelKeyView()
            // Add placeholder image for preview
            .onAppear {
                // This is a placeholder. In a real app, manage images properly.
                // You might need to create a simple colored rectangle as a placeholder
                // if direct image creation here is complex. For simplicity, ensure
                // you have an image named "palm_trees_placeholder" in your Assets.xcassets.
            }
    }
}
#endif
