//
//  VideoAdView.swift
//  MyApp
//
//  Created by Cong Le on 4/8/25.
//


import SwiftUI

struct GoogleAdView_V1: View {
    // State for the progress bar (example value)
    @State private var progress: Double = 0.1

    var body: some View {
        ZStack {
            // Background color for the entire screen
            Color.black
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // 1. Top Bar
                TopBarView()
                    .padding(.horizontal)
                    .padding(.top, 5) // Adjust top padding as needed for status bar area
                    .padding(.bottom, 10)

                // 2. Video Player Placeholder
                VideoPlayerPlaceholderView()
                    // Adjust aspect ratio or frame as needed
                    .aspectRatio(16/9, contentMode: .fit)

                // 3. Advertiser Info
                AdvertiserInfoView()
                    .padding(.horizontal)
                    .padding(.top, 15)

                // 4. Playback Controls
                PlaybackControlsView(progress: $progress)
                    .padding(.horizontal)
                    .padding(.vertical, 15)

                // 5. Call to Action Bar
                CtaBarView()
                    .padding(.horizontal)
                    .padding(.bottom, 20) // Padding from bottom edge

                Spacer() // Pushes content up if needed, though likely filled on most devices
            }
            .foregroundColor(.white) // Default text color for descendants
        }
    }
}

// MARK: - Subviews

struct TopBarView: View {
    var body: some View {
        HStack {
            Image(systemName: "chevron.down")
                .font(.headline)
            Text("Your music will continue after the break")
                .font(.caption)
                .lineLimit(1)
            Spacer()
            Image(systemName: "ellipsis")
                .font(.headline)
        }
    }
}

struct VideoPlayerPlaceholderView: View {
    var body: some View {
        // Using a system color as a placeholder for the video
        // Replace with actual video player view (e.g., AVPlayerViewControllerRepresentable)
        Color.secondary // Placeholder visual
            .overlay(
                // Example overlay to mimic the image content slightly
                Image(systemName: "photo.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.gray.opacity(0.5))
                    .padding(50)
            )
            .clipped() // Ensures overlay doesn't go outside bounds
    }
}

struct AdvertiserInfoView: View {
    var body: some View {
        HStack(spacing: 12) {
            // Placeholder for the logo
            Image("artisan-logo-placeholder") // Use a real placeholder name if you have one
                 .resizable()
                 .scaledToFit()
                 .frame(width: 40, height: 40)
                 .background(Color.teal) // Placeholder color similar to image
                 .cornerRadius(4)
                 .overlay(
                    Text("Artisan") // Placeholder text on logo
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(.white)
                 )

            VStack(alignment: .leading, spacing: 2) {
                Text("Artisan Market")
                    .font(.headline)
                Text("Advertisement")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer() // Pushes content to the left
        }
    }
}

struct PlaybackControlsView: View {
    @Binding var progress: Double

    var body: some View {
        VStack(spacing: 8) {
            // Progress Bar and Time
            VStack(spacing: 4) {
                 // Custom Progress Bar Simulation
                GeometryReader { geometry in
                     ZStack(alignment: .leading) {
                         Rectangle() // Background track
                             .frame(width: geometry.size.width, height: 4)
                             .foregroundColor(.gray.opacity(0.5))
                             .cornerRadius(2)

                         Rectangle() // Progress track
                             .frame(width: geometry.size.width * CGFloat(progress), height: 4)
                             .foregroundColor(.white)
                             .cornerRadius(2)

                         // Draggable Circle (Thumb)
                         Circle()
                             .fill(Color.white)
                             .frame(width: 12, height: 12)
                             .offset(x: geometry.size.width * CGFloat(progress) - 6) // Center the circle
                     }
                }
                .frame(height: 12) // Height accommodates the thumb circle

                HStack {
                    Text("0:02") // Example current time
                        .font(.caption2)
                        .foregroundColor(.gray)
                    Spacer()
                    Text("-0:15") // Example remaining time
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }

            // Control Buttons
            HStack(spacing: 25) {
                Button {} label: { Image(systemName: "hand.thumbsdown").font(.title2) }
                Button {} label: { Image(systemName: "backward.fill").font(.title2) }
                Button {} label: {
                    Image(systemName: "pause.fill") // Or "play.fill"
                        .font(.system(size: 44)) // Larger central button
                }
                Button {} label: { Image(systemName: "forward.fill").font(.title2) }
                Button {} label: { Image(systemName: "hand.thumbsup").font(.title2) }
            }
            .foregroundColor(.white) // Ensure buttons are visible
        }
    }
}

struct CtaBarView: View {
    var body: some View {
        HStack {
            Text("Save 10% on your first grocery box delivery")
                .font(.subheadline)
                .lineLimit(2) // Allow text to wrap if needed
                .fixedSize(horizontal: false, vertical: true) // Allows vertical expansion

            Spacer()

            Button("Learn more") {
                // Action for CTA button
            }
            .font(.subheadline.weight(.semibold))
            .foregroundColor(.black) // Text color inside button
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.white) // Button background
            .cornerRadius(20) // Rounded corners
        }
        // Add a subtle background if needed, like in some designs
        // .padding(10)
        // .background(Color.gray.opacity(0.2))
        // .cornerRadius(10)
    }
}

// MARK: - Preview

struct GoogleAdView_Previews: PreviewProvider {
    static var previews: some View {
        // Add a placeholder image named "artisan-logo-placeholder" to your assets
        // or remove the Image initialization that uses it in AdvertiserInfoView
        // for the preview to work without crashing.
        GoogleAdView_V1()
            .preferredColorScheme(.dark) // Preview in dark modes
    }
}
