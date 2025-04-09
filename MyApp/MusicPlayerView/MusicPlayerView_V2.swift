//
//  MusicPlayerView_V2.swift
//  MyApp
//
//  Created by Cong Le on 4/9/25.
//

// MARK: - Song Model
import Foundation

struct Song: Identifiable, Equatable {
    let id = UUID() // Unique identifier for list iteration or other needs
    let title: String
    let artist: String
    let albumArtName: String // Name of the image in Assets.xcassets
    let duration: TimeInterval // Duration in seconds
}

// Mock Data
extension Song {
    static let mockSongs = [
        Song(title: "Những Lời Dối Gian (Remix)", artist: "Ưng Hoàng Phúc", albumArtName: "My-meme-microphone", duration: 305), // Approx 5:05
        Song(title: "Waiting For You", artist: "Mono", albumArtName: "My-meme-orange-microphone", duration: 266), // Approx 4:26
        Song(title: "See Tình", artist: "Hoàng Thuỳ Linh", albumArtName: "My-meme-heineken", duration: 185)  // Approx 3:05
    ]

    // Placeholder for when no song is loaded (optional)
    static let placeholder = Song(title: "No Song Loaded", artist: "Unknown Artist", albumArtName: "music.note", duration: 0)
}

// MARK: - Playback Manager

import Foundation
import Combine // For Timer and @Published

class PlaybackManager: ObservableObject {

    @Published var currentSong: Song?
    @Published var queue: [Song] = Song.mockSongs // Initialize with mock data
    @Published var currentQueueIndex: Int = 0 {
        didSet {
            loadSong(at: currentQueueIndex) // Load song when index changes
        }
    }

    @Published var isPlaying: Bool = false
    @Published var currentTime: TimeInterval = 0.0
    @Published var volume: Double = 0.6
    @Published var isFavorite: Bool = false // Song-specific favorite status

    private var playbackTimer: AnyCancellable?
    private var seekTimerDebounce: AnyCancellable?

    // MARK: - Initialization
    init() {
        // Load the initial song from the queue
        if !queue.isEmpty {
            currentSong = queue[currentQueueIndex]
            // Simulate initial favorite status (you'd load this from persistence)
            isFavorite = (currentQueueIndex == 0) // Let's say the first song is favorited
        } else {
            currentSong = nil
        }
    }

    // MARK: - Computed Properties
    var currentSongDuration: TimeInterval {
        currentSong?.duration ?? 0.0
    }

    var canGoNext: Bool {
        currentQueueIndex < queue.count - 1
    }

    var canGoPrevious: Bool {
        currentQueueIndex > 0
    }

    // MARK: - Playback Controls
    func playPause() {
        isPlaying.toggle()
        if isPlaying {
            startTimer()
        } else {
            stopTimer()
        }
    }

    func nextTrack() {
        guard canGoNext else { return }
        currentQueueIndex += 1
        // Reset time and potentially pause/play based on desired behavior
        resetPlayback()
    }

    func previousTrack() {
        guard canGoPrevious else { return }
        currentQueueIndex -= 1
        resetPlayback()
    }

    // MARK: - Seeking
    func seek(to progress: Double) {
        // Debounce seeks slightly to avoid spamming while dragging
        seekTimerDebounce?.cancel()
        seekTimerDebounce = Just(progress)
            .delay(for: 0.1, scheduler: RunLoop.main) // Adjust delay as needed
            .sink { [weak self] newProgress in
                guard let self = self, let duration = self.currentSong?.duration, duration > 0 else { return }
                self.currentTime = newProgress * duration
                // If playing, restart timer from new position
                if self.isPlaying {
                    self.startTimer(from: self.currentTime)
                }
            }
    }

    func seekingDidChange(_ isEditing: Bool) {
        if isEditing {
             // Pause timer while scrubbing if it was playing
            if isPlaying { stopTimer() }
        } else {
            // Resume timer when scrubbing stops if it was playing
            if isPlaying { startTimer(from: currentTime) }
        }
    }

    // MARK: - Volume
    func setVolume(_ newVolume: Double) {
        self.volume = max(0.0, min(1.0, newVolume)) // Clamp volume between 0 and 1
        print("Volume set to: \(self.volume)")
        // Add actual system volume change logic here if needed (e.g., using AVPlayer or MediaPlayer)
    }

    // MARK: - Other Actions
    func toggleFavorite() {
        guard currentSong != nil else { return }
        isFavorite.toggle()
        print("Song '\(currentSong?.title ?? "")' favorite status: \(isFavorite)")
        // Add logic to save favorite status persistence here
    }

    func showMoreOptions() {
        print("Show more options for: \(currentSong?.title ?? "")")
        // Trigger a sheet or menu presentation in the View
    }

    func showLyrics() {
         print("Show lyrics for: \(currentSong?.title ?? "")")
         // Trigger navigation or sheet
     }

     func showCastingOptions() {
         print("Show casting/AirPlay options")
         // Integrate with AVRoutePickerView or similar
     }

     func showQueue() {
         print("Show playback queue")
         // Trigger navigation or sheet displaying `queue`
     }

    // MARK: - Private Helpers
    private func loadSong(at index: Int) {
        guard index >= 0 && index < queue.count else {
            currentSong = nil
            isFavorite = false // Reset favorite status
            return
        }
        currentSong = queue[index]
        // Simulate loading favorite status
        isFavorite = (index == 0) // Example: First song is favorited
        print("Loaded song: \(currentSong?.title ?? "None")")
    }

    private func resetPlayback(autoPlay: Bool = false) {
        stopTimer()
        currentTime = 0.0
        isPlaying = autoPlay // Decide if loading a new track should auto-play
        if isPlaying {
            startTimer()
        }
    }

    private func startTimer(from startTime: TimeInterval = -1) {
        stopTimer() // Ensure no duplicate timers

        let initialTime = (startTime >= 0) ? startTime : currentTime

        // Prevent starting timer if song is already finished
        guard let duration = currentSong?.duration, initialTime < duration else {
            isPlaying = false // Ensure state is correct if trying to play finished song
            return
        }

        playbackTimer = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self, self.isPlaying, let duration = self.currentSong?.duration else {
                    self?.stopTimer()
                    return
                }

                self.currentTime += 0.1

                if self.currentTime >= duration {
                    self.currentTime = duration // Clamp to duration
                    self.isPlaying = false // Stop playback
                    self.stopTimer()
                    // Optional: Automatically play next song
                    // self.nextTrack()
                    // if self.currentSong != nil { self.playPause() }
                    print("Song finished")
                }
            }
    }

    private func stopTimer() {
        playbackTimer?.cancel()
        playbackTimer = nil
    }

    deinit {
        stopTimer()
        seekTimerDebounce?.cancel()
        print("PlaybackManager deinitialized")
    }
}

// MARK: - SwiftUI Views and Subviews


import SwiftUI

// Define custom colors (reuse from previous response)
extension Color {
    static let appBackground = Color(red: 55/255, green: 48/255, blue: 45/255)
    static let textPrimary = Color.white
    static let textSecondary = Color.gray
    static let sliderTrack = Color.gray.opacity(0.6)
    static let sliderThumb = Color.white
    static let favoriteColor = Color.pink // Color for favorited items
}

struct MusicPlayerView: View {
    // Use @StateObject to create and manage the PlaybackManager instance
    @StateObject private var playbackManager = PlaybackManager()
    @State private var showingMoreOptions = false // For the ellipsis menu/sheet

    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()

            VStack(spacing: 20) {
                GrabberHandle()
                    .padding(.top, 5)

                // Pass necessary data/bindings from playbackManager
                AlbumArtView(imageName: playbackManager.currentSong?.albumArtName)

                TrackInfoView(
                    title: playbackManager.currentSong?.title ?? "Unknown Title",
                    artist: playbackManager.currentSong?.artist ?? "Unknown Artist",
                    isFavorite: playbackManager.isFavorite,
                    onFavoriteTap: playbackManager.toggleFavorite, // Pass the action
                    onMoreTap: { showingMoreOptions = true } // Trigger sheet/menu
                )
                .padding(.horizontal) // Added padding here

                PlaybackProgressView(
                    currentTime: playbackManager.currentTime,
                    duration: playbackManager.currentSongDuration,
                    onSeek: playbackManager.seek, // Pass seek action
                    seekingDidChange: playbackManager.seekingDidChange // Pass seeking state change
                )
                .padding(.horizontal) // Added padding here

                PlaybackControlsView(
                    isPlaying: playbackManager.isPlaying,
                    onPlayPause: playbackManager.playPause,
                    onNext: playbackManager.nextTrack,
                    onPrevious: playbackManager.previousTrack,
                    canGoNext: playbackManager.canGoNext,       // Pass state for disabling
                    canGoPrevious: playbackManager.canGoPrevious // Pass state for disabling
                )

                VolumeControlView(volume: $playbackManager.volume) // Use binding
                    .padding(.horizontal)

                BottomActionsView(
                     onLyricsTap: playbackManager.showLyrics,
                     onCastTap: playbackManager.showCastingOptions,
                     onQueueTap: playbackManager.showQueue
                 )
                .padding(.horizontal) // Added padding here

                Spacer()
            }
            // Apply consistent text color unless overridden
            .foregroundColor(Color.textPrimary)
        }
        // Example of presenting a sheet for "More Options"
        .sheet(isPresented: $showingMoreOptions) {
            // Replace with your actual options sheet view
            VStack {
                Text("More Options For:")
                Text(playbackManager.currentSong?.title ?? "").italic()
                Button("Dismiss") { showingMoreOptions = false }
                    .padding()
            }
            .presentationDetents([.height(200)]) // Example sheet size
        }
        // Present alert or confirmation if needed for other actions
    }
}

// --- Subviews (Updated with bindings/data/actions) ---

struct GrabberHandle: View { // No changes needed
    var body: some View {
        Capsule()
            .fill(Color.gray.opacity(0.5))
            .frame(width: 40, height: 5)
    }
}

struct AlbumArtView: View {
    let imageName: String?

    var body: some View {
        Group {
            if let name = imageName, let uiImage = UIImage(named: name) {
                Image(uiImage: uiImage)
                    .resizable()
            } else {
                // Fallback if no image name or image not found
                Image(systemName: "music.note")
                    .resizable()
                    .padding(50) // Add padding to make system image look okay
                    .foregroundColor(Color.textSecondary)
                    .background(Color.gray.opacity(0.3)) // Placeholder background
            }
        }
        .aspectRatio(contentMode: .fit)
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
        .padding(.vertical)
    }
}

struct TrackInfoView: View {
    let title: String
    let artist: String
    let isFavorite: Bool
    let onFavoriteTap: () -> Void // Action for favorite button
    let onMoreTap: () -> Void     // Action for more button

    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .lineLimit(1)

                Text(artist)
                    .font(.title3)
                    .foregroundColor(Color.textSecondary)
            }

            Spacer()

            HStack(spacing: 20) { // Increased spacing
                Button(action: onFavoriteTap) { // Use the passed action
                    Image(systemName: isFavorite ? "star.fill" : "star")
                        .font(.title2)
                        .foregroundColor(isFavorite ? Color.favoriteColor : Color.textSecondary) // Change color based on state
                        .animation(.easeInOut, value: isFavorite) // Animate change
                }

                Button(action: onMoreTap) { // Use the passed action
                    Image(systemName: "ellipsis")
                        .font(.title2)
                        .foregroundColor(Color.textSecondary)
                }
            }
        }
    }
}

struct PlaybackProgressView: View {
    let currentTime: TimeInterval
    let duration: TimeInterval
    let onSeek: (Double) -> Void
    let seekingDidChange: (Bool) -> Void

    // Local state to track slider interaction without constant updates upstream
    @State private var sliderValue: Double = 0
    @State private var isEditingSlider: Bool = false

    private var formattedElapsedTime: String {
        formatTime(currentTime)
    }

    private var formattedRemainingTime: String {
        formatTime(max(0, duration - currentTime), prefix: "-") // Ensure non-negative
    }

    private func formatTime(_ time: TimeInterval, prefix: String = "") -> String {
        guard !time.isNaN && !time.isInfinite && time >= 0 else { return "\(prefix)0:00" }
        let totalSeconds = Int(time)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "\(prefix)%d:%02d", minutes, seconds)
    }

    var body: some View {
        VStack(spacing: 5) {
            Slider(value: $sliderValue, in: 0...1, onEditingChanged: { editing in
                isEditingSlider = editing
                seekingDidChange(editing) // Inform manager about editing state change
                if !editing {
                    // Only call the main seek action when editing *finishes*
                    onSeek(sliderValue)
                }
            })
            .accentColor(Color.sliderThumb)
            // Update slider value visually when external currentTime changes, *unless* user is dragging
            .onChange(of: currentTime) { newTime in
                 guard !isEditingSlider, duration > 0 else { return }
                 sliderValue = newTime / duration
            }
             // Initialize slider value when view appears or duration changes
            .onAppear { updateSliderValue() }
            .onChange(of: duration) { _ in updateSliderValue() }

            HStack {
                Text(formattedElapsedTime)
                Spacer()
                Text(formattedRemainingTime)
            }
            .font(.caption)
            .foregroundColor(Color.textSecondary)
        }
    }
    
    private func updateSliderValue() {
         sliderValue = (duration > 0) ? (currentTime / duration) : 0
     }
}

struct PlaybackControlsView: View {
    let isPlaying: Bool
    let onPlayPause: () -> Void
    let onNext: () -> Void
    let onPrevious: () -> Void
    let canGoNext: Bool
    let canGoPrevious: Bool

    var body: some View {
        HStack(spacing: 45) { // Adjusted spacing
            Button(action: onPrevious) {
                Image(systemName: "backward.fill")
            }
            .disabled(!canGoPrevious) // Disable if cannot go previous
            .opacity(canGoPrevious ? 1.0 : 0.5) // Visual cue for disabled

            Button(action: onPlayPause) {
                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: 45))
                    .frame(width: 50, height: 50) // Ensure consistent tap area
            }

            Button(action: onNext) {
                Image(systemName: "forward.fill")
            }
            .disabled(!canGoNext) // Disable if cannot go next
             .opacity(canGoNext ? 1.0 : 0.5) // Visual cue for disabled
        }
        .font(.largeTitle)
        .foregroundColor(Color.textPrimary)
        .padding(.vertical, 15)
    }
}

struct VolumeControlView: View {
    // Use a binding directly to the manager's volume
    @Binding var volume: Double

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: volume == 0 ? "speaker.slash.fill" : (volume < 0.5 ? "speaker.fill" : "speaker.wave.2.fill"))
                .frame(width: 25, alignment: .center) // Give icon consistent width

            Slider(value: $volume, in: 0...1)
                 .accentColor(Color.sliderThumb)

            // Optional: Add a subtle number display
            // Text(String(format: "%.0f", volume * 100))
            //    .font(.caption)
            //    .frame(width: 30, alignment: .trailing)

        }
        .foregroundColor(Color.textSecondary)
        .frame(height: 30)
    }
}

struct BottomActionsView: View {
    let onLyricsTap: () -> Void
    let onCastTap: () -> Void
    let onQueueTap: () -> Void

    var body: some View {
        HStack {
            Button(action: onLyricsTap) {
                Image(systemName: "message")
            }
            Spacer()
            Button(action: onCastTap) {
                Image(systemName: "airplayaudio")
            }
            Spacer()
            Button(action: onQueueTap) {
                Image(systemName: "list.bullet")
            }
        }
        .font(.title2)
        .foregroundColor(Color.textSecondary)
        .padding(.vertical)
    }
}

// --- Preview Provider ---

struct MusicPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        MusicPlayerView()
            .preferredColorScheme(.dark)
            // Make sure you have placeholder images in Assets or handle image loading failure gracefully.
    }
}
