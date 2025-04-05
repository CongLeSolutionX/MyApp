//
//  EditingView.swift
//  MyApp
//
//  Created by Cong Le on 4/5/25.
//

import SwiftUI

// MARK: - Reusable Views

struct CircularIconButton: View {
    let systemName: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 18, weight: .medium)) // Adjust size as needed
                .foregroundColor(.white)
                .frame(width: 36, height: 36) // Standard tappable size
                .background(Color.black.opacity(0.6)) // Semi-transparent black
                .clipShape(Circle())
        }
    }
}

struct VerticalIconButton: View {
    let systemName: String
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: systemName)
                    .font(.system(size: 24)) // Larger icon
                    .foregroundColor(.white)
                Text(label)
                    .font(.caption) // Small label text
                    .foregroundColor(.white)
            }
            .frame(width: 60) // Fixed width for alignment
        }
    }
}

// MARK: - Main Content View

struct EditingView: View {

    var body: some View {
        ZStack {
            // 1. Background Image (Placeholder)
            Image("My-meme-original") // Replace with your actual image name
                 .resizable()
                 .aspectRatio(contentMode: .fill)
                 .edgesIgnoringSafeArea(.all) // Fill the whole screen
                // Or use a color as placeholder:
            Color.gray.edgesIgnoringSafeArea(.all).opacity(0.3)

            // Scrim overlay to make top/bottom controls more visible
            VStack {
                LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.5), Color.clear]), startPoint: .top, endPoint: .bottom)
                    .frame(height: 150) // Adjust height as needed
                Spacer()
                LinearGradient(gradient: Gradient(colors: [Color.clear, Color.black.opacity(0.7)]), startPoint: .top, endPoint: .bottom)
                    .frame(height: 150) // Adjust height as needed
            }
            .edgesIgnoringSafeArea(.all)

            // 2. Content VStack (holds Top Bar, Spacer, Bottom Bar)
            VStack(spacing: 0) {
                // 3. Top Bar
                TopBarView()
                    .padding(.top, 44) // Adjust for safe area or status bar height
                    .padding(.horizontal)

                Spacer() // Pushes Top and Bottom bars to edges

                // --- Text Overlay would go here in the ZStack layer ---
                // Positioned separately for flexibility

                // 4. Bottom Bar
                BottomBarView()
                    .padding(.bottom, 34) // Adjust for safe area or home indicator
                    .padding(.horizontal)
            }
            .edgesIgnoringSafeArea(.top) // Allow content under status bar notch

             // --- Add Text Overlay Here ---
             // Positioned manually within the ZStack for centering or specific placement
             Text("Bao asdasdas  asda sdsd") // Placeholder, use actual font if possible
                 .font(.system(size: 30, weight: .light, design: .serif)) // Approximating cursive style
                 .foregroundColor(.white)
                 .multilineTextAlignment(.center)
                 .shadow(radius: 2)
                 .padding(.bottom, 100) // Adjust vertical position

        }
        // Ensure the ZStack takes up the full screen if needed, though child elements handle edges
        // .frame(maxWidth: .infinity, maxHeight: .infinity)
        // .background(Color.black) // Base background if image doesn't load/cover
    }
}

// MARK: - Subviews for Organization

struct TopBarView: View {
    var body: some View {
        HStack {
            // Close Button
            Button(action: { print("Close tapped") }) {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(8) // Add padding for larger tap area
                    .background(Color.black.opacity(0.6))
                    .clipShape(Circle())
            }

            Spacer()

            // Right Icon Buttons
            HStack(spacing: 12) { // Adjust spacing between icons
                CircularIconButton(systemName: "scissors", action: { print("Cut tapped") })
                CircularIconButton(systemName: "speaker.wave.2.fill", action: { print("Volume tapped") }) // Using filled version
                CircularIconButton(systemName: "face.smiling", action: { print("Sticker tapped") })
                CircularIconButton(systemName: "textformat", action: { print("Text tapped") })
                CircularIconButton(systemName: "link", action: { print("Link tapped") })
                CircularIconButton(systemName: "captions.bubble.fill", action: { print("Captions tapped") }) // Using filled version
            }
        }
        .frame(height: 44) // Standard navigation bar height
    }
}

struct BottomBarView: View {
    var body: some View {
        HStack(alignment: .bottom) { // Align items to the bottom
            // Left Vertical Icons
            VStack(spacing: 20) { // Spacing between Effects and Settings
                VerticalIconButton(systemName: "wand.and.rays", label: "Effects", action: { print("Effects tapped") })
                VerticalIconButton(systemName: "gearshape", label: "Settings", action: { print("Settings tapped") })
            }

            Spacer()

            // Right Horizontal Buttons
            HStack(spacing: 10) {
                // Subscribe Button
                Button(action: { print("Subscribe tapped") }) {
                    HStack(spacing: 5) {
                        Image(systemName: "heart.shield") // Example icon
                            .font(.system(size: 14))
                        Text("Subscri...")
                            .font(.system(size: 15, weight: .medium))
                    }
                    .foregroundColor(.black)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.white)
                    .cornerRadius(8) // Rounded corners
                }

                // Share Button
                Button(action: { print("Share tapped") }) {
                    HStack(spacing: 5) {
                        Image(systemName: "globe")
                            .font(.system(size: 14))
                        Text("Share to story")
                            .font(.system(size: 15, weight: .medium))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.blue) // Blue background
                    .cornerRadius(8) // Rounded corners
                }
            }
        }
        .frame(height: 80) // Set a height for the bottom bar area
    }
}

// MARK: - Placeholder for Image assets (Important!)
// Add an image named "landscapePlaceholder.jpg" (or similar) to your Assets.xcassets
// or replace `"landscapePlaceholder"` with a `systemName` if using SF Symbols for the background.

// MARK: - Preview Provider

struct EditingView_Previews: PreviewProvider {
    static var previews: some View {
        EditingView()
            .preferredColorScheme(.dark) // Preview in dark mode as per the UI
    }
}

// Extension for Heart Shield Icon (Approximation)
extension Image {
    static let heartShield = Image(systemName: "suit.heart.fill") // Placeholder, find a better icon if needed
}
