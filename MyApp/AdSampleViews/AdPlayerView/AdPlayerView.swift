//
//  AdPlayerView.swift
//  MyApp
//
//  Created by Cong Le on 4/8/25.
//

import SwiftUI

struct AdPlayerView: View {
    // State for playback (example, not fully functional)
    @State private var isPlaying: Bool = false
    @State private var progress: Double = 0.1 // Example progress (10%)

    // Define colors based on the screenshot
    let darkGreenBackground = Color(red: 30/255, green: 89/255, blue: 69/255) // #1E5945
    let lighterGreenBanner = Color(red: 42/255, green: 126/255, blue: 99/255) // #2A7E63
    let adIconBackground = Color(red: 42/255, green: 126/255, blue: 99/255) // #2A7E63 (same as banner for consistency)
    let adIconForeground = Color(red: 237/255, green: 90/255, blue: 48/255) // Orange #ED5A30 (approx)
    let artworkPlaceholderColor = Color(red: 20/255, green: 70/255, blue: 55/255) // Slightly darker green
    let progressBarColor = Color.white.opacity(0.8)
    let progressBarBackgroundColor = Color.white.opacity(0.3)

    var body: some View {
        ZStack {
            darkGreenBackground.edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) { // Added spacing between main elements
                // --- Top Bar ---
                HStack {
                    Image(systemName: "chevron.down")
                    Spacer()
                    Text("Your podcast will continue after the break")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                    Spacer()
                    Image(systemName: "ellipsis")
                }
                .foregroundColor(.white)
                .padding(.horizontal)
                .padding(.top, 5) // Reduced top padding slightly

                // --- Podcast Artwork ---
                Image("podcastArtworkPlaceholder") // Replace with your actual image asset name
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .background(artworkPlaceholderColor) // Placeholder background
                    .cornerRadius(12)
                     // Add a placeholder icon in the center if no image is loaded
                     // This requires overlaying another view or using a custom placeholder view
                    .overlay(
                         // Placeholder for the central white icon in the artwork
                         Image(systemName: "basket.fill") // Example icon
                             .resizable()
                             .scaledToFit()
                             .frame(width: 50, height: 50)
                             .foregroundColor(.white)
                             .opacity(0.8) // Make it slightly transparent like the image
                     )
                    .padding(.horizontal)

                // --- Ad Info ---
                HStack(spacing: 12) {
                    // Placeholder Ad Icon
                    Image(systemName: "basket.fill") // Using basket as placeholder
                        .resizable()
                        .scaledToFit()
                        .frame(width: 25, height: 25)
                        .foregroundColor(adIconForeground)
                        .padding(10)
                        .background(adIconBackground)
                        .cornerRadius(8)

                    VStack(alignment: .leading) {
                        Text("Artisan Market")
                            .font(.headline)
                            .fontWeight(.bold)
                        Text("Advertisement")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    Spacer() // Pushes content to the left
                }
                .foregroundColor(.white)
                .padding(.horizontal)

                // --- Progress Bar Area ---
                VStack(spacing: 5) {
                    // Custom Progress Bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(progressBarBackgroundColor)
                                .frame(height: 4)
                            Capsule()
                                .fill(progressBarColor)
                                .frame(width: geometry.size.width * CGFloat(progress), height: 4)
                        }
                    }
                    .frame(height: 4) // Height for the GeometryReader

                    // Time Labels
                    HStack {
                        Text("0:02") // Example time
                        Spacer()
                        Text("-0:15") // Example time
                    }
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.7))
                }
                .padding(.horizontal)

                // --- Player Controls ---
                HStack {
                    Spacer()
                    Image(systemName: "thumbsup")
                        .font(.title2)
                    Spacer()
                    Image(systemName: "backward.end.fill")
                        .font(.title)
                    Spacer()
                    // Play/Pause Button
                    Button {
                        isPlaying.toggle()
                    } label: {
                        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 28)) // Larger icon size
                            .frame(width: 65, height: 65) // Larger circle
                            .background(.white)
                            .foregroundColor(darkGreenBackground) // Icon color is the background color
                            .clipShape(Circle())
                    }
                    Spacer()
                    Image(systemName: "forward.end.fill")
                        .font(.title)
                    Spacer()
                    Image(systemName: "thumbsdown")
                        .font(.title2)
                    Spacer()
                }
                .foregroundColor(.white)
                .padding(.horizontal)
                .padding(.vertical, 10) // Add some vertical padding

                // --- Bottom Banner ---
                HStack {
                    Text("Save 10% on your first grocery delivery")
                        .font(.footnote)
                        .fontWeight(.medium)
                        .lineLimit(2) // Allow text to wrap
                         .minimumScaleFactor(0.8) // Allow text to shrink slightly if needed

                    Spacer() // Pushes button to the right

                    Button("Learn more") {
                        // Action for learn more
                    }
                    .font(.footnote)
                    .fontWeight(.bold)
                    .foregroundColor(darkGreenBackground) // Dark text color
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(.white)
                    .clipShape(Capsule())
                }
                .foregroundColor(.white) // Text color for the banner
                .padding() // Padding inside the banner
                .background(lighterGreenBanner) // Banner background color
                .cornerRadius(15) // Rounded corners for the banner
                .padding(.horizontal) // Padding outside the banner
                .padding(.bottom) // Padding at the very bottom

                Spacer() // Pushes everything up
            }
        }
         // Add a dummy image asset named "podcastArtworkPlaceholder" to your project
         // or replace it with a real image loading mechanism.
    }
}

struct AdPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        AdPlayerView()
            .preferredColorScheme(.dark) // Preview in dark mode
    }
}
