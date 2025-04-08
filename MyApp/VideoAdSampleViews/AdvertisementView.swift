//
//  VideoAdSampleView.swift
//  MyApp
//
//  Created by Cong Le on 4/8/25.
//

import SwiftUI

// Define custom colors matching the screenshot
// Note: These are approximations. Use precise color values if available.
extension Color {
    static let adBackground = Color(red: 139/255, green: 0/255, blue: 0/255) // Dark Red
    static let ctaBackground = Color.black.opacity(0.2) // Semi-transparent darker shade
    static let logoBackground = Color(red: 250/255, green: 235/255, blue: 215/255) // Antique White / Cream
    static let primaryText = Color.white
    static let secondaryText = Color.white.opacity(0.7)
    static let progressBarTint = Color.white.opacity(0.8)
    static let progressBarBackground = Color.white.opacity(0.3)
    static let buttonText = Color(red: 50/255, green: 50/255, blue: 50/255) // Dark Gray for Button Text
}

struct AdvertisementView: View {
    // State for the progress bar (example value)
    @State private var progress: Double = 0.1 // approx 0:02 out of 0:17 total

    var body: some View {
        ZStack {
            // Main background color
            Color.adBackground.edgesIgnoringSafeArea(.all)

            VStack(spacing: 15) {
                // --- Top Bar ---
                HStack {
                    Image(systemName: "chevron.down")
                    Spacer()
                    Text("Your music will continue after the break")
                        .font(.caption)
                    Spacer()
                    Image(systemName: "ellipsis")
                }
                .foregroundColor(.primaryText)
                .padding(.horizontal)
                .padding(.top, 5) // Adjust as needed for status bar

                // --- Ad Image ---
                Image("ad_image_placeholder") // Replace with actual image name
                    .resizable()
                    .aspectRatio(contentMode: .fit) // or .fill depending on desired cropping
                    .cornerRadius(10)
                    .padding(.horizontal)

                // --- Advertiser Info ---
                HStack(spacing: 12) {
                    // Logo
                    Text("L")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.buttonText) // Dark text color for 'L'
                        .frame(width: 50, height: 50)
                        .background(Color.logoBackground) // Cream background
                        .cornerRadius(6)

                    // Text Info
                    VStack(alignment: .leading, spacing: 2) {
                        Text("LELUNE")
                            .font(.headline)
                            .fontWeight(.bold)
                        Text("Advertisement")
                            .font(.caption)
                            .foregroundColor(.secondaryText)
                    }
                    Spacer() // Pushes info to the left
                }
                .foregroundColor(.primaryText)
                .padding(.horizontal)

                // --- Progress Bar ---
                VStack(spacing: 4) {
                    ProgressView(value: progress)
                        .progressViewStyle(LinearProgressViewStyle(tint: Color.progressBarTint))
                        .scaleEffect(x: 1, y: 1, anchor: .center) // Adjust thickness if needed
                        .background(Color.progressBarBackground) // Background track color
                        .cornerRadius(2) // Match background rounding

                    HStack {
                        Text("0:02")
                        Spacer()
                        Text("-0:15")
                    }
                    .font(.caption2)
                    .foregroundColor(.secondaryText)
                }
                .padding(.horizontal)

                // --- Playback Controls ---
                HStack(spacing: 20) { // Adjust spacing for balance
                    Spacer() // Pushes controls towards center

                    Button {} label: {
                        Image(systemName: "hand.thumbsup")
                            .font(.title2)
                    }

                    Button {} label: {
                         Image(systemName: "backward.end.fill")
                            .font(.title2)
                    }

                    // Play/Pause Button (Larger with background)
                    Button {} label: {
                        Image(systemName: "pause.fill")
                            .font(.system(size: 30)) // Larger icon
                            .foregroundColor(Color.adBackground) // Icon color same as background
                            .frame(width: 60, height: 60) // Button size
                            .background(Circle().fill(Color.primaryText)) // White circular background
                    }

                    Button {} label: {
                         Image(systemName: "forward.end.fill")
                            .font(.title2)
                    }

                    Button {} label: {
                           Image(systemName: "hand.thumbsdown")
                            .font(.title2)
                    }
                     Spacer() // Pushes controls towards center
                }
                .foregroundColor(.primaryText)
                .padding(.horizontal)

                Spacer() // Pushes CTA banner to the bottom

                // --- CTA Banner ---
                HStack {
                    Text("Subscribe today to give your home a LeLune lift.")
                        .font(.footnote)
                        .lineLimit(2) // Allow text to wrap
                        .multilineTextAlignment(.leading)

                    Spacer() // Push button to the right

                    Button("Learn more") {
                        // Action for Learn More button
                    }
                    .font(.footnote)
                    .fontWeight(.bold)
                    .foregroundColor(.buttonText) // Dark text
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.primaryText) // White background
                    .cornerRadius(20) // Pill shape
                }
                .padding()
                .background(Color.ctaBackground) // Darker, semi-transparent background
                .cornerRadius(12)
                .padding(.horizontal)
                .padding(.bottom, 20) // Padding from screen bottom

            } // End Main VStack
        } // End ZStack
        // Use .preferredColorScheme(.dark) if needed system-wide
    }
}

#Preview {
    AdvertisementView()
        // Provide a placeholder image for the preview if needed
        // .environment(\.imageProvider, TestImageProvider())
}

// --- Placeholder for Image Loading (Optional for Preview) ---
// You might need a simple placeholder mechanism if you don't have the image asset
// struct TestImageProvider { }
// extension EnvironmentValues {
//     var imageProvider: TestImageProvider {
//         get { self[TestImageProviderKey.self] }
//         set { self[TestImageProviderKey.self] = newValue }
//     }
// }
// struct TestImageProviderKey: EnvironmentKey {
//     static let defaultValue: TestImageProvider = TestImageProvider()
// }

// Make sure you have an image named "ad_image_placeholder.png" (or similar)
// in your asset catalog for the preview to work visually.
