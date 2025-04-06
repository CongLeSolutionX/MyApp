//
//  GoogleStyleCardView.swift
//  MyApp
//
//  Created by Cong Le on 4/6/25.
//

import SwiftUI

struct GoogleStyleCardView: View {
    var body: some View {
        // Main Container (Card) mimicking the screenshot's dimensions and appearance
        VStack(alignment: .leading, spacing: 0) { // No spacing between major sections handled by padding
            // Header Section
            HeaderSection()
                .padding(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))

            // Image Placeholder Section
            ImagePlaceholderSection()
                .frame(height: 180) // Approximate height based on visual proportion
                .frame(maxWidth: .infinity) // Ensures it takes full width

            // Content Section
            ContentSection()
                 .padding(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))

            // Button Section (Aligned bottom right)
            ButtonSection()
                .padding(EdgeInsets(top: 0, leading: 16, bottom: 16, trailing: 16))

        }
        .background(Color(white: 0.18)) // Dark background for the card
        .cornerRadius(8) // Subtle rounded corners for the card
        .frame(width: 360) // Fixed width as indicated in the screenshot
        // Use maxWidth for more flexibility: .frame(maxWidth: 360)
        .padding() // Padding around the card itself
        // Set the overall background to very dark, almost black
        .background(Color(white: 0.1).edgesIgnoringSafeArea(.all))
    }
}

// MARK: - Header Section Components
struct HeaderSection: View {
    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            AvatarView()

            // Header/Subheader Text
            VStack(alignment: .leading, spacing: 2) {
                Text("Header") // Placeholder text
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.9)) // High visibility header
                Text("Subhead") // Placeholder text
                    .font(.system(size: 14))
                    .foregroundColor(.gray) // Lower visibility subhead
            }

            Spacer() // Pushes the ellipsis icon to the right

            // More Options Button
            Image(systemName: "ellipsis")
                .font(.system(size: 20))
                .foregroundColor(.gray)
        }
    }
}

struct AvatarView: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.gray.opacity(0.3)) // Background color similar to screenshot
                .frame(width: 40, height: 40)
            Text("A")
                .foregroundColor(.white.opacity(0.9))
                .font(.system(size: 18, weight: .medium))
        }
    }
}

// MARK: - Image Placeholder Section
struct ImagePlaceholderSection: View {
    let placeholderBackgroundColor = Color(white: 0.85) // Very light gray
    let shapeColor = Color(white: 0.6) // Medium gray for shapes

    var body: some View {
        ZStack {
            // Background for the placeholder area
            placeholderBackgroundColor

            // Placeholder shapes arranged horizontally
            HStack(spacing: 25) {
                // Using SF Symbols as approximations for the simple shapes
                Image(systemName: "triangle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 45, height: 45)
                    .foregroundColor(shapeColor)

                Image(systemName: "square.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 45, height: 45)
                    .foregroundColor(shapeColor)

                Image(systemName: "circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 45, height: 45)
                    .foregroundColor(shapeColor)
            }
        }
        .clipped() // Prevent shapes from drawing outside the bounds in weird resizing scenarios
    }
}

// MARK: - Content Section
struct ContentSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Subtitle")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.white.opacity(0.9))

            Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor")
                .font(.system(size: 14))
                .foregroundColor(.gray) // Standard body text color
                .lineSpacing(4) // Improve readability of longer text
        }
         .frame(maxWidth: .infinity, alignment: .leading) // Ensure text aligns left
    }
}

// MARK: - Button Section
struct ButtonSection: View {
    let buttonBackgroundColor = Color(red: 0.45, green: 0.4, blue: 0.8) // Custom purple shade

    var body: some View {
        HStack {
            Spacer() // Pushes the button to the trailing edge
            Button("Enabled") {
                print("Enabled button tapped") // Placeholder action
            }
            .buttonStyle(FilledButtonStyle_V2(backgroundColor: buttonBackgroundColor))
        }
    }
}

// MARK: - Custom Button Style
struct FilledButtonStyle_V2: ButtonStyle {
    let backgroundColor: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .medium))
            .padding(.horizontal, 24) // Generous horizontal padding
            .padding(.vertical, 10)
            .foregroundColor(.white)
            .background(backgroundColor)
            .cornerRadius(20) // Matches the pill shape
            .opacity(configuration.isPressed ? 0.8 : 1.0) // Subtle pressed effect
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0) // Slightly shrink when pressed
    }
}

// MARK: - Preview
struct GoogleStyleCardView_Previews: PreviewProvider {
    static var previews: some View {
        GoogleStyleCardView()
    }
}
