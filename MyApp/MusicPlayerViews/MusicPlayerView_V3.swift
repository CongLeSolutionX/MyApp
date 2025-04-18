////
////  MusicPlayerView_V2.swift
////  MyApp
////
////  Created by Cong Le on 4/17/25.
////
//
//import SwiftUI
//
//struct MusicPlayerView: View {
//    // MARK: - Properties
//    @State private var isPlaying: Bool = false
//    @State private var currentTime: Double = 0
//    private let totalTime: Double = 3 * 60 + 43 // 3:43 in seconds
//    private let trackTitle: String = "Melting Horizons"
//    private let artistName: String = "Lazy B."
//    private let albumArt: String = "My-meme-orange" // Replace with actual image asset name
//
//    // Mock data for playlist
//    let playlist: [Song] = [
//        Song(title: "Melting Horizons", artist: "Lazy B.", duration: 223),
//        Song(title: "Skyline", artist: "The Sunsets", duration: 198),
//        Song(title: "Waveforms", artist: "Electric Pulse", duration: 250)
//    ]
//    @State private var currentTrackIndex: Int = 0
//    
//    // Timer to simulate playback progress
//    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
//    
//    // MARK: - View
//    var body: some View {
//        ZStack {
//            Color(.systemBackground).edgesIgnoringSafeArea(.all)
//            VStack(spacing: 20) {
//                // Top Navigation Bar
//                HStack {
//                    Button(action: {
//                        // Dismiss or go back - placeholder
//                    }) {
//                        Image(systemName: "chevron.down")
//                            .font(.title2)
//                            .foregroundColor(.primary)
//                    }
//                    
//                    Spacer()
//                    
//                    Text("Playing Now")
//                        .font(.headline)
//                        .foregroundColor(.primary)
//                    
//                    Spacer()
//                    
//                    Button(action: {
//                        // Save favorite or options - placeholder
//                    }) {
//                        Image(systemName: "heart")
//                            .font(.title2)
//                            .foregroundColor(.primary)
//                    }
//                }
//                .padding([.horizontal, .top])
//                
//                // Album Art and Song Info
//                VStack {
//                    Image(albumArt)
//                        .resizable()
//                        .aspectRatio(contentMode: .fill)
//                        .frame(width: 250, height: 250)
//                        .clipped()
//                        .cornerRadius(12)
//                        .shadow(radius: 5)
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 12)
//                                .stroke(Color.primary.opacity(0.1), lineWidth: 1)
//                        )
//                    
//                    Text(playlist[currentTrackIndex].title)
//                        .font(.title2)
//                        .fontWeight(.semibold)
//                        .padding(.top, 8)
//                    
//                    Text(playlist[currentTrackIndex].artist)
//                        .font(.subheadline)
//                        .foregroundColor(.secondary)
//                }
//                .padding()
//                
//                // Playback Progress Slider
//                VStack {
//                    Slider(value: Binding(
//                        get: {
//                            self.currentTime
//                        },
//                        set: { newValue in
//                            self.currentTime = newValue
//                            self.checkIfTrackFinished()
//                        }
//                    ), in: 0...Double(playlist[currentTrackIndex].duration))
//                    .accentColor(.primary)
//                    .padding([.horizontal])
//                    
//                    // Time Labels
//                    HStack {
//                        Text(timeString(from: currentTime))
//                            .font(.caption)
//                        Spacer()
//                        Text(timeString(from: Double(playlist[currentTrackIndex].duration)))
//                            .font(.caption)
//                    }
//                    .padding(.horizontal)
//                }
//                
//                // Playback Controls
//                HStack(spacing: 50) {
//                    Button(action: {
//                        // Previous track
//                        self.prevTrack()
//                    }) {
//                        Image(systemName: "backward.fill")
//                            .font(.title2)
//                            .foregroundColor(.primary)
//                    }
//
//                    Button(action: {
//                        // Play/Pause toggle
//                        togglePlayPause()
//                    }) {
//                        Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
//                            .font(.system(size: 60))
//                            .foregroundColor(.primary)
//                    }
//
//                    Button(action: {
//                        // Next track
//                        self.nextTrack()
//                    }) {
//                        Image(systemName: "forward.fill")
//                            .font(.title2)
//                            .foregroundColor(.primary)
//                    }
//                }
//                .padding()
//                
//                // Functional "Try with Unfold Plus" Button
//                Button(action: {
//                    // Example: add current song to favorites or premium feature
//                }) {
//                    Text("TRY WITH UNFOLD PLUS")
//                        .fontWeight(.semibold)
//                        .foregroundColor(.white)
//                        .frame(maxWidth: .infinity)
//                        .padding()
//                        .background(Color(.systemBlue))
//                        .cornerRadius(8)
//                }
//                .padding(.horizontal)
//                .padding(.bottom, 20)
//            }
//        }
//        .onReceive(timer) { _ in
//            guard isPlaying else { return }
//            guard currentTime < Double(playlist[currentTrackIndex].duration) else {
//                // Track finished, move to next
//                self.nextTrack()
//                return
//            }
//            currentTime += 1
//        }
//    }
//    
//    // MARK: - Helper Functions
//    
//    func togglePlayPause() {
//        isPlaying.toggle()
//    }
//    
//    func checkIfTrackFinished() {
//        if currentTime >= Double(playlist[currentTrackIndex].duration) {
//            nextTrack()
//        }
//    }
//    
//    func prevTrack() {
//        if currentTrackIndex > 0 {
//            currentTrackIndex -= 1
//        } else {
//            currentTrackIndex = playlist.count - 1
//        }
//        resetTrack()
//    }
//
//    func nextTrack() {
//        if currentTrackIndex < playlist.count - 1 {
//            currentTrackIndex += 1
//        } else {
//            currentTrackIndex = 0
//        }
//        resetTrack()
//    }
//    
//    func resetTrack() {
//        currentTime = 0
//        isPlaying = true
//    }
//    
//    func timeString(from seconds: Double) -> String {
//        let totalSeconds = Int(seconds)
//        let minutes = totalSeconds / 60
//        let seconds = totalSeconds % 60
//        return String(format: "%d:%02d", minutes, seconds)
//    }
//}
//
//// MARK: - Song Model
//struct Song: Identifiable {
//    let id = UUID()
//    let title: String
//    let artist: String
//    let duration: Int // in seconds
//}
//
//struct MusicPlayerView_Previews: PreviewProvider {
//    static var previews: some View {
//        // Add a placeholder image named "album_art_placeholder" in Assets
//        MusicPlayerView()
//    }
//}
