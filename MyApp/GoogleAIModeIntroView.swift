//
//  GoogleAIModeIntroView.swift
//  MyApp
//
//  Created by Cong Le on 4/4/25.
//


import SwiftUI

struct GoogleAIModeIntroView: View {
    // State for the toggle switch
    @State private var isExperimentOn = true

    // Define the gradient for the glow and icon
    let rainbowGradient = AngularGradient(
        gradient: Gradient(colors: [
            .yellow, .orange, .red, .purple, .blue, .green, .yellow
        ]),
        center: .center
    )

    let buttonBlue = Color(red: 0.6, green: 0.8, blue: 1.0) // Approximate blue
    let darkGrayBackground = Color(white: 0.1)
    let darkerGrayElement = Color(white: 0.15)
    let veryDarkBackground = Color(white: 0.05) // Even darker for top section

    var body: some View {
        ZStack {
            // Main Background
            darkGrayBackground.ignoresSafeArea()

            VStack(spacing: 30) {
                // --- Top Search Bar Area ---
                searchBarArea()
                    .padding(.top, 50) // Adjust top padding as needed

                // --- Bottom Introductory Content ---
                introductoryContent()

                Spacer() // Pushes content up
            }
        }
        .preferredColorScheme(.dark) // Enforce dark mode appearance
    }

    // Extracted function for the Search Bar Area
    @ViewBuilder
    private func searchBarArea() -> some View {
        ZStack {
            // Make the background slightly darker here if needed
             veryDarkBackground
                 .cornerRadius(20) // Optional: Round the background area
                 .padding(.horizontal, 20) // Confine background if needed


            // Glowing effect layer behind the search bar
             Capsule()
                 .strokeBorder(rainbowGradient, lineWidth: 4) // Use strokeBorder for outline
                 .blur(radius: 8) // Apply blur for the glow effect
                 .opacity(0.8)
                 .frame(height: 55)
                 .padding(.horizontal, 40) // Ensure glow extends beyond bar

            // Actual Search Bar
            HStack {
                Text("Ask anything...")
                    .foregroundColor(.gray)
                    .padding(.leading, 20)

                Spacer()

                Image(systemName: "mic.fill")
                    .foregroundColor(.white)

                Image(systemName: "camera.viewfinder")
                    .foregroundColor(.white)
                    .padding(.trailing, 20)
                    .padding(.leading, 10)
            }
            .frame(height: 50) // Slightly smaller than glow layer
            .background(Color.black)
            .clipShape(Capsule())
            .padding(.horizontal, 45) // Padding inside the glow padding
        }
        .frame(height: 100) // Give space for the glow
    }

    // Extracted function for the Introductory Content
    @ViewBuilder
    private func introductoryContent() -> some View {
        VStack(alignment: .leading, spacing: 20) {
            // Icon and Title Row
            HStack(alignment: .center, spacing: 15) {
                aiIcon()

                VStack(alignment: .leading) {
                    Text("Ask Anything with AI Mode")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("New")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                Spacer() // Pushes title to the left
            }

            // Description Text
            Text("Be the first to try the new AI Mode experiment in Google Search. Get AI-powered responses and explore further with follow-up questions and links to helpful web content.")
                .font(.subheadline)
                .foregroundColor(.gray)

            // Toggle Section
            HStack {
                Text("Turn this experiment on or off.")
                    .font(.subheadline)
                Spacer()
                Toggle("", isOn: $isExperimentOn)
                    .labelsHidden()
                    .tint(buttonBlue) // Style the toggle color
            }
            .padding()
            .background(darkerGrayElement)
            .cornerRadius(15)

            // Try AI Mode Button
            Button {
                // Action for the button
                print("Try AI Mode tapped")
            } label: {
                Text("Try AI Mode")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(buttonBlue)
                    .foregroundColor(Color(white: 0.1)) // Dark text on light blue
                    .cornerRadius(25) // Capsule-like corners
            }
        }
        .padding(.horizontal, 25) // Padding for the entire intro section
    }

    // Extracted function for the AI Icon
    @ViewBuilder
    private func aiIcon() -> some View {
        ZStack {
            // Background shape for the icon
             RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.8)) // Slightly darker background
                .frame(width: 55, height: 55)

            // Gradient Circle inside
            Circle()
                 .fill(rainbowGradient)
                 .frame(width: 45, height: 45) // Slightly smaller circle

            // Magnifying Glass Symbol
            Image(systemName: "magnifyingglass")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
    }
}

// Preview Provider for Canvas
struct GoogleAIModeIntroView_Previews: PreviewProvider {
    static var previews: some View {
        GoogleAIModeIntroView()
    }
}
