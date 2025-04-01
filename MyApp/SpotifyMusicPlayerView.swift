////
////  SpotifyMusicPlayerView.swift
////  MyApp
////
////  Created by Cong Le on 4/1/25.
////
//
//import SwiftUI
//
//struct MusicPlayerView: View {
//    // State variables to mimic UI states (can be hooked to actual player logic)
//    @State private var isPlaying: Bool = true // Example: Assume playing initially
//    @State private var progressValue: Double = 0.3 // Example: Progress slider value (0.0 to 1.0)
//    @State private var isLiked: Bool = true    // Example: Song is liked
//    @State private var isShuffling: Bool = true // Example: Shuffle is active
//    @State private var repeatMode: Int = 0     // Example: 0 = no repeat, 1 = repeat one, 2 = repeat all
//    @State private var isShowingShareSheet = false // State to control the share sheet
//    
//    
//    // --- Add Placeholder Data for Sharing ---
//    // Replace these with your actual data source for the current song
//    let songTitle = "để tôi ôm em bằng giai điệu này"
//    let artistName = "CongLeSolutionX"
//    let songURL: URL? = URL(string: "https://open.spotify.com/track/example-track-id") // Replace with actual URL
//
//    
//    // Computed properties for display times (replace with actual logic)
//    var currentTime: String {
//        // Placeholder calculation based on progress
//        let totalSeconds: Double = 278 // Example total duration (2:38 + 1:46 = 4:24 = 264s - discrepancy in SS?) Let's use 4:14 = 254s based on labels
//        let current = totalSeconds * progressValue
//        let minutes = Int(current) / 60
//        let seconds = Int(current) % 60
//        return String(format: "%d:%02d", minutes, seconds)
//    }
//    
//    var remainingTime: String {
//        // Placeholder calculation based on progress
//        let totalSeconds: Double = 254 // Example total duration
//        let remaining = totalSeconds * (1.0 - progressValue)
//        let minutes = Int(remaining) / 60
//        let seconds = Int(remaining) % 60
//        return String(format: "-%d:%02d", minutes, seconds)
//    }
//    
//    var body: some View {
//        ZStack {
//            // Background Color
//            Color(red: 0.18, green: 0.20, blue: 0.18) // Approximate dark green/grey
//                .ignoresSafeArea()
//            
//            VStack(spacing: 20) {
//                Spacer(minLength: 10) // Push content down slightly from top status bar
//                
//                // 1. Top Bar
//                topBar
//                
//                // 2. Album Art
//                albumArt
//                
//                // 3. Song Info & Like Button
//                songInfo
//                
//                // 4. Progress Bar
//                progressBar
//                
//                // 5. Playback Controls
//                playbackControls
//                
//                // 6. Device/Share/Queue Controls
//                bottomControls
//                
//                // 7. Lyrics Section
//                lyricsSection
//                
//                Spacer(minLength: 10) // Push lyrics section up slightly from bottom
//            }
//            // Modifier to present the sheet
//                .sheet(isPresented: $isShowingShareSheet) {
////                    // ---- OPTION 1 FOR SHARESHEET VIEW
////                    // Configure sheet presentation if needed (e.g., background)
////                    ShareSheetView()
////                        // Optional: Apply presentation detents if you want a half-sheet option
////                        // .presentationDetents([.medium, .large])
////                        // Optional: Set background color for the sheet itself
////                        .preferredColorScheme(.dark) // Ensures sheet content uses dark mode appearance
////                    
////                    
////                    // ------- ----------
//                    // ---- OPTION 2 FOR SHARESHEET VIEW
////                    // Prepare items to share
//                    var itemsToShare: [Any] = []
////                    let shareText = "\(songTitle) - \(artistName)" // Example text
////                    itemsToShare.append(shareText)
////
////                    if let url = songURL {
////                        itemsToShare.append(url) // Add the URL
////                    }
//                    // Optionally add an image (e.g., album art)
//                    // if let image = UIImage(named: "album_art_placeholder") {
//                    //     itemsToShare.append(image)
//                    // }
//
//                    if !itemsToShare.isEmpty {
//                         // Present the standard iOS Share Sheet via our wrapper
//                        ActivityViewController(activityItems: itemsToShare)
//                            // Optional: Exclude specific actions if needed
//                            // .excludedActivityTypes([.addToReadingList, .assignToContact])
//                    } else {
//                        // Fallback if there's nothing to share (optional)
//                         Text("Nothing to share")
//                            .padding()
//                            .onAppear {
//                                // Optionally dismiss automatically if nothing to share
//                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
//                                    isShowingShareSheet = false
//                                }
//                            }
//                    }
//                }
//                // --- END MODIFICATION ---
//                }
//            .foregroundColor(.white) // Default text/icon color
//            .padding(.horizontal)
//        }
//        // Hide the system status bar if desired for a more immersive look
//        // .statusBar(hidden: true)
////    }
//    
//    // MARK: - UI Components
//    
//    private var topBar: some View {
//        HStack {
//            Button {} label: {
//                Image(systemName: "chevron.down")
//                    .font(.body.weight(.semibold))
//            }
//            Spacer()
//            Text("Liked Songs")
//                .font(.footnote.weight(.bold))
//            Spacer()
//            Button {} label: {
//                Image(systemName: "ellipsis")
//                    .font(.body.weight(.semibold))
//            }
//        }
//        .padding(.vertical, 5)
//    }
//    
//    private var albumArt: some View {
//        Image("My-meme-microphone") // Replace with actual image loading
//            .resizable()
//            .aspectRatio(1.0, contentMode: .fit) // Make it square
//            .cornerRadius(8)
//            .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
//            .padding(.vertical) // Add some vertical space around the art
//    }
//    
//    private var songInfo: some View {
//        HStack {
//            VStack(alignment: .leading) {
//                Text("để tôi ôm em bằng giai điệu này")
//                    .font(.title3)
//                    .fontWeight(.bold)
//                    .lineLimit(1)
//                Text("CongLeSolutionX")
//                    .font(.callout)
//                    .foregroundColor(.white.opacity(0.7))
//                    .lineLimit(1)
//            }
//            Spacer()
//            Button {
//                isLiked.toggle()
//            } label: {
//                Image(systemName: isLiked ? "checkmark.circle.fill" : "plus.circle")
//                    .font(.title2)
//                    .foregroundColor(isLiked ? .green : .white.opacity(0.7))
//            }
//        }
//    }
//    
//    private var progressBar: some View {
//        VStack(spacing: 4) {
//            Slider(value: $progressValue, in: 0...1)
//            // Custom styling to match screenshot
//                .accentColor(.white) // Color for the track to the left of the thumb
//            // Requires more custom implementation for different track/thumb colors if needed
//            
//            HStack {
//                Text(currentTime) // Use calculated current time
//                Spacer()
//                Text(remainingTime) // Use calculated remaining time
//            }
//            .font(.caption)
//            .foregroundColor(.white.opacity(0.7))
//        }
//        .padding(.vertical)
//    }
//    
//    private var playbackControls: some View {
//        HStack(spacing: 25) { // Adjust spacing as needed
//            Button {
//                isShuffling.toggle()
//            } label: {
//                Image(systemName: "shuffle")
//                    .font(.title2)
//                    .foregroundColor(isShuffling ? .green : .white.opacity(0.7)) // Green when active
//            }
//            
//            Button {} label: {
//                Image(systemName: "backward.fill")
//                    .font(.title) // Larger than shuffle/repeat
//                    .fontWeight(.bold)
//            }
//            
//            Button {
//                isPlaying.toggle()
//            } label: {
//                Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//                    .frame(width: 70, height: 70) // Large central button
//                    .foregroundColor(.white)
//            }
//            
//            Button {} label: {
//                Image(systemName: "forward.fill")
//                    .font(.title) // Larger than shuffle/repeat
//                    .fontWeight(.bold)
//            }
//            
//            Button {
//                // Cycle through repeat modes: 0 -> 1 -> 2 -> 0
//                repeatMode = (repeatMode + 1) % 3
//            } label: {
//                Image(systemName: repeatMode == 1 ? "repeat.1" : "repeat")
//                    .font(.title2)
//                    .foregroundColor(repeatMode != 0 ? .green : .white.opacity(0.7)) // Green when active
//            }
//        }
//    }
//    
//    private var bottomControls: some View {
//        HStack {
//            // Device connection icon (approximation)
//            Button {} label: {
//                Image(systemName: "hifispeaker.and.appletv") // Or "airplayaudio", "speaker.wave.2.fill"
//                    .font(.callout)
//                    .foregroundColor(.white.opacity(0.7))
//            }
//            Spacer()
//            // Queue/List icon
//            Button {} label: {
//                Image(systemName: "list.bullet")
//                    .font(.callout)
//                    .foregroundColor(.white.opacity(0.7))
//            }
//        }
//        .padding(.top, 10) // Add some space above this row
//    }
//    
//    private var lyricsSection: some View {
//            HStack {
//                Text("Lyrics")
//                    .font(.headline)
//                    .fontWeight(.bold)
//
//                Spacer()
//
//                // --- MODIFIED SHARE BUTTON ---
//                Button {
//                    isShowingShareSheet = true // Toggle the state to show the sheet
//                } label: {
//                    Image(systemName: "square.and.arrow.up")
//                       .font(.callout)
//                       .foregroundColor(.white.opacity(0.7))
//                }
//                .padding(.trailing, 5)
//                // --- END MODIFICATION ---
//
//                Button {} label: {
//                    Image(systemName: "arrow.up.left.and.arrow.down.right")
//                       .font(.callout)
//                       .foregroundColor(.white.opacity(0.7))
//                }
//            }
//            .padding()
//            .background(
//                RoundedRectangle(cornerRadius: 12)
//                    .fill(Color.white.opacity(0.1))
//            )
//            .padding(.top)
//       }
//    
//}
//
//// MARK: - Preview
//
//struct MusicPlayerView_Previews: PreviewProvider {
//    static var previews: some View {
//        MusicPlayerView()
//            .preferredColorScheme(.dark) // Preview in dark mode
//            .onAppear {
//                // Placeholder image setup for preview if needed
//                // You might need to add an actual image named "album_art_placeholder.jpg"
//                // to your Assets.xcassets for the preview to show the image.
//            }
//    }
//}
//
//// NOTE: For the slider styling (thumb color, track color on the right),
//// a fully custom implementation might be needed beyond the standard SwiftUI Slider.
//// This implementation uses the default Slider behavior with an accent color.
//// Also, add an actual image named "album_art_placeholder" to your Assets catalog
//// for the album art to display.
