////
////  MusicPlayerView.swift
////  MyApp
////
////  Created by Cong Le on 4/9/25.
////
//
//import SwiftUI
//
//// Define custom colors for better theming
//extension Color {
//    static let appBackground = Color(red: 55/255, green: 48/255, blue: 45/255) // Approximated from screenshot
//    static let textPrimary = Color.white
//    static let textSecondary = Color.gray
//    static let sliderTrack = Color.gray.opacity(0.6)
//    static let sliderThumb = Color.white // Though it looks subtle in the screenshot
//}
//
//struct MusicPlayerView: View {
//    // State variables for interactive elements (using default values for mockup)
//    @State private var playbackProgress: Double = 0.1 // Approx 0:05 out of ~5:00
//    @State private var volumeLevel: Double = 0.6
//    @State private var isPlaying: Bool = false // Button shows Pause, so player is playing
//
//    var body: some View {
//        ZStack {
//            // Background Color
//            Color.appBackground
//                .ignoresSafeArea()
//
//            // Main Vertical Stack for Content
//            VStack(spacing: 20) { // Added spacing between major sections
//                // Grabber Handle
//                GrabberHandle()
//                    .padding(.top, 5) // Add some space from the edge
//
//                // Album Art
//                AlbumArtView()
//
//                // Track Information & Action Buttons
//                TrackInfoView()
//
//                // Playback Progress Bar
//                PlaybackProgressView(progress: $playbackProgress)
//
//                // Playback Controls
//                PlaybackControlsView(isPlaying: $isPlaying)
//
//                // Volume Control
//                VolumeControlView(volume: $volumeLevel)
//                    .padding(.horizontal) // Give some horizontal space
//
//                // Bottom Action Buttons
//                BottomActionsView()
//
//                Spacer() // Pushes content up if needed, adjust spacing above if preferred
//
//            }
//            .padding(.horizontal) // Add padding to the main VStack
//        }
//        // Apply a consistent text color unless overridden
//        .foregroundColor(Color.textPrimary)
//    }
//}
//
//// --- Subviews for better organization ---
//
//struct GrabberHandle: View {
//    var body: some View {
//        Capsule()
//            .fill(Color.gray.opacity(0.5))
//            .frame(width: 40, height: 5)
//    }
//}
//
//struct AlbumArtView: View {
//    var body: some View {
//        Image("My-meme-microphone") // Ensure you have this image in your Assets
//            .resizable()
//            .aspectRatio(contentMode: .fit)
//             // Provide a fallback system image if the asset is missing
//            .background(Color.secondary) // Placeholder background
//            .cornerRadius(10)
//            // Add subtle shadow like the screenshot
//            .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
//            .padding(.vertical) // Add some vertical padding around artwork
//    }
//}
//
//struct TrackInfoView: View {
//    var body: some View {
//        HStack(alignment: .center) {
//            VStack(alignment: .leading) {
//                Text("Những Lời Dối Gian (Remix)")
//                    .font(.title2)
//                    .fontWeight(.bold)
//                    .lineLimit(1) // Prevents wrapping if title is too long
//
//                Text("ft Ưng Hoàng Phúc")
//                    .font(.title3)
//                    .foregroundColor(Color.textSecondary)
//            }
//
//            Spacer() // Pushes buttons to the right
//
//            HStack(spacing: 15) {
//                Button { /* Add to favorites action */ } label: {
//                    Image(systemName: "star")
//                        .font(.title2)
//                        .foregroundColor(Color.textSecondary)
//                }
//
//                Button { /* Show more options action */ } label: {
//                    Image(systemName: "ellipsis")
//                        .font(.title2)
//                        .foregroundColor(Color.textSecondary)
//                }
//            }
//        }
//    }
//}
//
//struct PlaybackProgressView: View {
//    @Binding var progress: Double
//
//    // Dummy total time for calculation (replace with actual duration)
//    let totalDuration: Double = 305 // Approx 5:05 in seconds
//
//    var formattedElapsedTime: String {
//        let time = Int(progress * totalDuration)
//        let minutes = time / 60
//        let seconds = time % 60
//        return String(format: "%d:%02d", minutes, seconds)
//    }
//
//    var formattedRemainingTime: String {
//        let time = Int((1.0 - progress) * totalDuration)
//        let minutes = time / 60
//        let seconds = time % 60
//        return String(format: "-%d:%02d", minutes, seconds)
//    }
//
//    var body: some View {
//        VStack(spacing: 5) {
//            Slider(value: $progress, in: 0...1)
//                .accentColor(Color.sliderThumb) // Color of the thumb/filled track
//                 // Note: Styling the track itself requires more custom approach if needed
//
//            HStack {
//                Text(formattedElapsedTime)
//                Spacer()
//                Text(formattedRemainingTime)
//            }
//            .font(.caption)
//            .foregroundColor(Color.textSecondary)
//        }
//    }
//}
//
//struct PlaybackControlsView: View {
//    @Binding var isPlaying: Bool
//
//    var body: some View {
//        HStack(spacing: 40) { // Control spacing between buttons
//            Button { /* Previous track action */ } label: {
//                Image(systemName: "backward.fill")
//            }
//
//            Button { isPlaying.toggle() /* Play/Pause action */ } label: {
//                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
//                    .font(.system(size: 45)) // Make play/pause slightly larger
//            }
//
//            Button { /* Next track action */ } label: {
//                Image(systemName: "forward.fill")
//            }
//        }
//        .font(.largeTitle) // Set default size for side buttons
//        .foregroundColor(Color.textPrimary) // Ensure controls are white
//        .padding(.vertical, 15) // Add vertical spacing around controls
//    }
//}
//
//struct VolumeControlView: View {
//    @Binding var volume: Double
//
//    var body: some View {
//        HStack(spacing: 10) {
//            Image(systemName: "speaker.fill")
//            Slider(value: $volume, in: 0...1)
//                 .accentColor(Color.sliderThumb)
//            Image(systemName: "speaker.wave.2.fill") // Icon shows more waves for higher volume perception
//        }
//        .foregroundColor(Color.textSecondary) // Use secondary color for less emphasis
//        .frame(height: 30) // Control vertical height
//    }
//}
//
//struct BottomActionsView: View {
//    var body: some View {
//        HStack {
//            Button { /* Show lyrics action */ } label: {
//                Image(systemName: "message")
//            }
//            Spacer()
//            Button { /* AirPlay/Cast action */ } label: {
//                Image(systemName: "airplayaudio")
//            }
//            Spacer()
//            Button { /* Show queue action */ } label: {
//                Image(systemName: "list.bullet")
//                // Example of overlaying (though not exactly as in some music apps)
//                // .overlay(alignment: .bottomTrailing) {
//                //     Image(systemName: "shuffle")
//                //         .font(.caption2)
//                //         .foregroundColor(.accentColor)
//                //         .offset(x: 5, y: 5)
//                // }
//            }
//        }
//        .font(.title2) // Control icon size
//        .foregroundColor(Color.textSecondary)
//        .padding(.vertical)
//    }
//}
//
//// --- Preview Provider ---
//
//struct MusicPlayerView_Previews: PreviewProvider {
//    static var previews: some View {
//        MusicPlayerView()
//            .preferredColorScheme(.dark) // Ensure preview uses dark mode
//            .previewLayout(.sizeThatFits) // Adjust preview size
//            // Add a placeholder image asset named "placeholderAlbumArt" to your Assets.xcassets
//            // Or replace the Image("placeholderAlbumArt") with Image(systemName: "music.note") for testing
//    }
//}
