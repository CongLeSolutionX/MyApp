////
////  MusicPlayerView.swift
////  MyApp
////
////  Created by Cong Le on 4/17/25.
////
//
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
//    private let albumArt: String = "My-meme-orange_2" // Replace with actual image name
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
//                        // Dismiss or go back
//                    }) {
//                        Image(systemName: "xmark")
//                            .font(.title2)
//                            .foregroundColor(.primary)
//                    }
//                    Spacer()
//                    Text("Audio")
//                        .font(.headline)
//                        .foregroundColor(.primary)
//                    Spacer()
//                    Button(action: {
//                        // Save favorite
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
//                    
//                    Text(trackTitle)
//                        .font(.title2)
//                        .fontWeight(.semibold)
//                        .padding(.top, 8)
//                    
//                    Text(artistName)
//                        .font(.subheadline)
//                        .foregroundColor(.secondary)
//                }
//                .padding()
//                
//                // Playback Controls
//                VStack {
//                    // Slider for progress
//                    Slider(value: $currentTime, in: 0...totalTime, onEditingChanged: { editing in
//                        if !editing {
//                            // Handle slider release if needed
//                        }
//                    })
//                    .accentColor(.primary)
//                    .padding([.horizontal])
//                    
//                    // Time Labels
//                    HStack {
//                        Text(timeString(from: currentTime))
//                            .font(.caption)
//                        Spacer()
//                        Text(timeString(from: totalTime))
//                            .font(.caption)
//                    }
//                    .padding(.horizontal)
//                }
//                
//                // Playback Buttons
//                HStack(spacing: 50) {
//                    Button(action: {
//                        // Previous track
//                        currentTime = 0
//                    }) {
//                        Image(systemName: "backward.fill")
//                            .font(.title2)
//                            .foregroundColor(.primary)
//                    }
//                    Button(action: {
//                        // Play/Pause toggle
//                        isPlaying.toggle()
//                    }) {
//                        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
//                            .font(.largeTitle)
//                            .foregroundColor(.primary)
//                    }
//                    Button(action: {
//                        // Next track
//                        currentTime = 0
//                    }) {
//                        Image(systemName: "forward.fill")
//                            .font(.title2)
//                            .foregroundColor(.primary)
//                    }
//                }
//                .padding()
//                
//                // Unfold Plus Button
//                Button(action: {
//                    // Example action for "Try with Unfold Plus"
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
//            guard isPlaying, currentTime < totalTime else { return }
//            currentTime += 1
//        }
//    }
//    
//    // MARK: - Helper
//    func timeString(from seconds: Double) -> String {
//        let totalSeconds = Int(seconds)
//        let minutes = totalSeconds / 60
//        let seconds = totalSeconds % 60
//        return String(format: "%d:%02d", minutes, seconds)
//    }
//}
//
//struct MusicPlayerView_Previews: PreviewProvider {
//    static var previews: some View {
//        MusicPlayerView()
//    }
//}
