//
//  GetPlaybackStateDemoView_V2.swift
//  MyApp
//
//  Created by Cong Le on 4/16/25.
//

import SwiftUI
import Combine // Needed for Timer

// MARK: - Enums and Data Structures (Slightly Enhanced)
import SwiftUI

// MARK: - Placeholder Data Structures (Mirroring JSON for clarity)

// Note: In a real app, these would be Codable and populated from the JSON.
// For this UI design, we'll use them conceptually or with sample data.

struct SpotifyImage: Identifiable {
    let id = UUID()
    let url: String
    let height: Int?
    let width: Int?
}

struct SpotifyArtist: Identifiable {
    let id = UUID() // Use actual ID from JSON in real app
    let name: String
}

struct SpotifyAlbum: Identifiable {
    let id = UUID() // Use actual ID from JSON
    let name: String
    let images: [SpotifyImage]
    let artists: [SpotifyArtist] // Album artists might differ
}

struct SpotifyTrack: Identifiable {
    let id = UUID() // Use actual ID from JSON
    let name: String
    let duration_ms: Int
    let artists: [SpotifyArtist]
    let album: SpotifyAlbum
}

struct SpotifyDevice: Identifiable {
    let id = UUID() // Use actual ID from JSON
    let name: String
    let type: String // e.g., "computer", "speaker"
    let volume_percent: Int?
    let is_active: Bool
    let supports_volume: Bool
}

struct SpotifyPlayerActions {
    let resuming: Bool
    let pausing: Bool
    let skipping_next: Bool
    let skipping_prev: Bool
    let toggling_shuffle: Bool
    let toggling_repeat_context: Bool
    let toggling_repeat_track: Bool
}

enum RepeatMode: CaseIterable {
    case off, context, track

    var systemImageName: String {
        switch self {
        case .off: return "repeat"
        case .context: return "repeat" // Same icon, but behavior differs
        case .track: return "repeat.1"
        }
    }
}

// Reusing previous structures: SpotifyImage, SpotifyArtist, SpotifyAlbum, SpotifyTrack, SpotifyDevice, SpotifyPlayerActions

// MARK: - Mock Data Generation

struct MockPlayerData {
    static let artist1 = SpotifyArtist(name: "The Midnight")
    static let artist2 = SpotifyArtist(name: "FM-84")
    static let artist3 = SpotifyArtist(name: "Gunship")

    static let album1 = SpotifyAlbum(
        name: "Endless Summer",
        images: [SpotifyImage(url: "https://i.scdn.co/image/ab67616d00001e02f9e065d2c10a6e0b4c2bada0", height: 300, width: 300)], // Replace with actual URLs if possible
        artists: [artist1]
    )
    static let album2 = SpotifyAlbum(
        name: "Atlas",
        images: [SpotifyImage(url: "https://i.scdn.co/image/ab67616d00001e02aabb12794c16c37b14177560", height: 300, width: 300)],
        artists: [artist2]
    )
     static let album3 = SpotifyAlbum(
        name: "Dark All Day",
        images: [SpotifyImage(url: "https://i.scdn.co/image/ab67616d00001e02e081b2d650796f7a921c9732", height: 300, width: 300)],
        artists: [artist3]
    )

    static let track1 = SpotifyTrack(name: "Sunset", duration_ms: 315000, artists: [artist1], album: album1)
    static let track2 = SpotifyTrack(name: "Days of Thunder", duration_ms: 310000, artists: [artist1], album: album1)
    static let track3 = SpotifyTrack(name: "Running in the Night", duration_ms: 273000, artists: [artist2], album: album2)
    static let track4 = SpotifyTrack(name: "Let's Go", duration_ms: 241000, artists: [artist2], album: album2)
     static let track5 = SpotifyTrack(name: "When You Grow Up, Your Heart Dies", duration_ms: 354000, artists: [artist3], album: album3)
     static let track6 = SpotifyTrack(name: "Dark All Day", duration_ms: 325000, artists: [artist3], album: album3)

    static let playlist: [SpotifyTrack] = [track1, track2, track3, track4, track5, track6]

    static let defaultDevice = SpotifyDevice(
        name: "My iPhone",
        type: "smartphone",
        volume_percent: 75,
        is_active: true,
        supports_volume: true
    )

    // Define which actions are generally allowed
    static let defaultActions = SpotifyPlayerActions(
        resuming: true, pausing: true, skipping_next: true, skipping_prev: true,
        toggling_shuffle: true, toggling_repeat_context: true, toggling_repeat_track: true
    )
}

// MARK: - Functional SwiftUI View

struct SpotifyPlayerView: View {
    // --- State Variables ---
    @State private var currentTrack: SpotifyTrack? = MockPlayerData.playlist.first
    @State private var isPlaying: Bool = false
    @State private var progressMs: Double = 0 // Use Double for ProgressView compatibility
    @State private var shuffleState: Bool = false
    @State private var repeatState: RepeatMode = .off
    @State private var playlist: [SpotifyTrack] = MockPlayerData.playlist
    @State private var currentDevice: SpotifyDevice? = MockPlayerData.defaultDevice

    // Mock available actions (can be dynamic later)
    private let playbackActions: SpotifyPlayerActions = MockPlayerData.defaultActions

    // Timer for playback progress simulation
    @State private var timerSubscription: Cancellable?
    private let progressUpdateInterval: TimeInterval = 0.1 // Update frequently for smoother bar

    // Haptic feedback generator
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private let impactLight = UIImpactFeedbackGenerator(style: .light)

    // --- Computed Properties ---
    private var currentTrackDurationMs: Double {
        Double(currentTrack?.duration_ms ?? 1) // Avoid division by zero
    }

    private var progressValue: Double {
        min(max(0.0, progressMs / currentTrackDurationMs), 1.0)
    }

    private var artistNames: String {
        currentTrack?.artists.map { $0.name }.joined(separator: ", ") ?? "Unknown Artist"
    }

    // --- View Body ---
    var body: some View {
        VStack(spacing: 15) {
            // --- Album Artwork ---
            AsyncImage(url: URL(string: currentTrack?.album.images.first?.url ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(8)
                    .shadow(radius: 5)
            } placeholder: {
                Rectangle()
                    .fill(Color.secondary.opacity(0.3))
                    .aspectRatio(1, contentMode: .fit)
                    .cornerRadius(8)
                    .overlay(Image(systemName: "music.note").font(.largeTitle).foregroundColor(.gray))
            }
            .padding(.horizontal)
            .id(currentTrack?.id) // Force redraw on track change

            // --- Track Info ---
            VStack {
                Text(currentTrack?.name ?? "No Track Playing")
                    .font(.title2)
                    .fontWeight(.bold)
                    .lineLimit(1)
                Text(artistNames)
                    .font(.body)
                    .foregroundColor(.gray)
                    .lineLimit(1)
                Text(currentTrack?.album.name ?? "")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(1)
                    .padding(.top, 1)
            }
            .padding(.horizontal)

            // --- Progress Bar ---
            VStack(spacing: 4) {
                // TODO: Add gesture recognizer for scrubbing later
                ProgressView(value: progressValue)
                    .tint(.accentColor) // Use theme color
                    .padding(.horizontal)

                HStack {
                    Text(formatTime(Int(progressMs)))
                    Spacer()
                    Text(formatTime(currentTrack?.duration_ms ?? 0))
                }
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.horizontal)
            }

            // --- Playback Controls ---
            HStack(spacing: 30) {
                // Shuffle Button
                Button(action: toggleShuffle) {
                    Image(systemName: "shuffle")
                        .font(.title2)
                        .foregroundColor(shuffleState ? .accentColor : .primary)
                }
                .disabled(!playbackActions.toggling_shuffle || playlist.isEmpty)

                // Previous Button
                Button(action: playPreviousTrack) {
                    Image(systemName: "backward.fill")
                        .font(.title)
                }
                .disabled(!playbackActions.skipping_prev || playlist.isEmpty)

                // Play/Pause Button
                Button(action: togglePlayPause) {
                    Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 50))
                }
                 .disabled(!(isPlaying ? playbackActions.pausing : playbackActions.resuming) || currentTrack == nil)

                // Next Button
                Button { // Use trailing closure syntax for the action
                    playNextTrack() // Call the function *inside* the closure
                } label: {
                    Image(systemName: "forward.fill")
                        .font(.title)
                }
                .disabled(!playbackActions.skipping_next || playlist.isEmpty)

                 // Repeat Button
                Button(action: toggleRepeat) {
                     Image(systemName: repeatState.systemImageName)
                        .font(.title2)
                        .foregroundColor(repeatState != .off ? .accentColor : .primary)
                }
                .disabled(!(playbackActions.toggling_repeat_context || playbackActions.toggling_repeat_track) || playlist.isEmpty)

            }
            .padding(.vertical)

            // --- Device Info ---
            HStack {
                Image(systemName: deviceIconName(currentDevice?.type ?? ""))
                Text(currentDevice?.name ?? "No Device")
                Spacer()
                if let volume = currentDevice?.volume_percent, currentDevice?.supports_volume == true {
                    Image(systemName: volumeIconName(volume))
                    // Could add Text("\(volume)%") or a Slider...
                }
                // Active indicator dot
                if currentDevice?.is_active == true {
                     Circle()
                         .fill(Color.green)
                         .frame(width: 8, height: 8)
                         .padding(.leading, 4)
                 }
            }
            .font(.caption)
            .foregroundColor(.gray)
            .padding(.horizontal)
            .padding(.bottom)
        }
        .padding()
        // .background(BackgroundBlurView()) // Optional: Add a blur background
        .onAppear(perform: setupInitialState)
        .onChange(of: isPlaying) {
            handlePlaybackChange(newValue: isPlaying)
        }
    }

    // --- Helper Functions ---
    private func formatTime(_ totalMs: Int) -> String {
        let totalSeconds = totalMs / 1000
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private func deviceIconName(_ type: String) -> String {
        // (Same implementation as before)
        switch type.lowercased() {
            case "computer": return "desktopcomputer"
            case "smartphone": return "iphone" // Or specific icon
            case "speaker": return "speaker.wave.2.fill"
            case "tv": return "tv.fill"
            case "avr","cast_video": return "hifispeaker.and.appletv.fill"
            case "stb": return "tv.and.hifispeaker.fill"
            case "tablet": return "ipad" // Or specific icon
            default: return "speaker.fill" // Default fallback
        }
    }

    private func volumeIconName(_ volume: Int) -> String {
        // (Same implementation as before)
         switch volume {
            case 0: return "speaker.slash.fill"
            case 1..<33: return "speaker.wave.1.fill"
            case 33..<66: return "speaker.wave.2.fill"
            default: return "speaker.wave.3.fill"
        }
    }

    // --- Action Functions ---

    private func setupInitialState() {
        // If the view appears and should be playing (e.g., returning to app)
        // but the timer isn't running, restart it.
        // For this mock, we just ensure it starts paused.
        isPlaying = false
        stopTimer()

        // Select the first track if none is selected
        if currentTrack == nil {
            currentTrack = playlist.first
            progressMs = 0
        }
    }

    private func togglePlayPause() {
        guard currentTrack != nil else { return } // Don't play if no track
        isPlaying.toggle()
        impactMedium.impactOccurred()
    }

    private func handlePlaybackChange(newValue: Bool) {
        if newValue {
            startTimer()
        } else {
            stopTimer()
        }
    }

    private func startTimer() {
        // Invalidate existing timer if any
        stopTimer()
        // Start a new timer
        timerSubscription = Timer.publish(every: progressUpdateInterval, on: .main, in: .common)
            .autoconnect()
            .sink { [self] _ in
                guard self.isPlaying else {
                    self.stopTimer()
                    return
                }

                self.progressMs += (progressUpdateInterval * 1000) // Increment progress

                // Check if track finished
                if self.progressMs >= self.currentTrackDurationMs {
                    handleTrackFinished()
                }
            }
    }

    private func stopTimer() {
        timerSubscription?.cancel()
        timerSubscription = nil
    }

    private func handleTrackFinished() {
        impactLight.impactOccurred()
        switch repeatState {
        case .track:
            // Repeat the current track
            progressMs = 0
            if !isPlaying { isPlaying = true } // Ensure it continues playing
        case .context:
            // Play the next track in sequence (or shuffled)
            playNextTrack(trackJustFinished: true)
        case .off:
            // Try playing next, but stop if it was the last track
             guard let currentIndex = getCurrentTrackIndex() else {
                stopPlaybackCompletely(); return
            }
            if !shuffleState && currentIndex == playlist.count - 1 {
                 // Last track and not shuffling/repeating context: Stop
                 stopPlaybackCompletely()
            } else if playlist.isEmpty {
                 stopPlaybackCompletely()
            }
            else {
                 // Play next track (handles shuffle internally)
                 playNextTrack(trackJustFinished: true)
            }
        }
    }

    private func stopPlaybackCompletely() {
        progressMs = currentTrackDurationMs // Show as finished
        isPlaying = false
        // Optionally: could reset progressMs to 0 after a short delay
    }

    private func playNextTrack(trackJustFinished: Bool = false) {
        guard !playlist.isEmpty else { stopPlaybackCompletely(); return }

        let nextIndex = findNextTrackIndex()
        guard nextIndex != -1 else { // -1 indicates stop condition
            stopPlaybackCompletely()
            return
        }

        changeTrack(to: playlist[nextIndex])
        // If the track finished naturally, keep playing. If manually skipped, keep current play state.
        if trackJustFinished && !isPlaying { isPlaying = true }
        impactMedium.impactOccurred()
    }

    private func playPreviousTrack() {
        guard !playlist.isEmpty else { return }
        impactMedium.impactOccurred()

        // Spotify behavior: If track played > 3 seconds, restart it. Otherwise, go to previous.
        if progressMs > 3000 {
            progressMs = 0
            if !isPlaying { isPlaying = true } // Start playing if paused
            return
        }

        // Find previous track index
        guard let currentIndex = getCurrentTrackIndex() else { return }
        var prevIndex: Int

        if shuffleState {
            // In shuffle, 'previous' might just restart or go to a random different one?
            // Let's simplify: Shuffle previous restarts the current track.
            progressMs = 0
            if !isPlaying { isPlaying = true }
            return
        } else {
            // Normal previous
            prevIndex = currentIndex - 1
            if prevIndex < 0 {
                 // Was first track, wrap around if repeating context, else restart first track
                 if repeatState == .context {
                    prevIndex = playlist.count - 1
                 } else {
                     progressMs = 0 // Restart first track
                     if !isPlaying { isPlaying = true }
                     return
                 }
            }
        }
         changeTrack(to: playlist[prevIndex])

    }

    private func findNextTrackIndex() -> Int {
         guard let currentIndex = getCurrentTrackIndex() else { return playlist.isEmpty ? -1 : 0 } // Play first if no current index

        if shuffleState {
            // Play a random *different* track
            if playlist.count <= 1 { return (repeatState == .off) ? -1 : 0 } // Can't shuffle if only 1 track unless repeating

            var nextIndex = Int.random(in: 0..<playlist.count)
            while nextIndex == currentIndex { // Ensure it's a different track
                 nextIndex = Int.random(in: 0..<playlist.count)
            }
             return nextIndex

        } else {
            // Play next in sequence
            var nextIndex = currentIndex + 1
             if nextIndex >= playlist.count {
                 // Reached end of playlist
                 if repeatState == .context {
                    nextIndex = 0 // Wrap around
                 } else {
                     return -1 // Signal to stop
                 }
             }
             return nextIndex
        }
    }

    private func getCurrentTrackIndex() -> Int? {
        guard let currentTrack = currentTrack else { return nil }
        return playlist.firstIndex(where: { $0.id == currentTrack.id })
    }

    private func changeTrack(to newTrack: SpotifyTrack) {
        currentTrack = newTrack
        progressMs = 0 // Reset progress
        // Timer will continue if isPlaying is true
         if !isPlaying { // If paused, changing track shouldn't start playback
            // No action needed, just track changed
         } else {
             // Ensure timer keeps running
             startTimer()
         }
    }

    private func toggleShuffle() {
        shuffleState.toggle()
        impactLight.impactOccurred()
        // In a real app, might need to reshuffle the upcoming queue
    }

    private func toggleRepeat() {
        // Cycle through: off -> context -> track -> off
        let allCases = RepeatMode.allCases
        if let currentIndex = allCases.firstIndex(of: repeatState) {
            let nextIndex = (currentIndex + 1) % allCases.count
            repeatState = allCases[nextIndex]
        }
        impactLight.impactOccurred()
    }
}

// MARK: - Optional Background Blur VIew

struct BackgroundBlurView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
        return view
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}

// MARK: - SwiftUI Preview

struct SpotifyPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        SpotifyPlayerView()
           // .preferredColorScheme(.dark) // Test dark mode
            .previewLayout(.sizeThatFits)
            .padding()
            .tint(.green) // Example accent color like Spotify's
    }
}
