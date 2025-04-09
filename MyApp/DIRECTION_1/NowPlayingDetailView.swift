//
//  NowPlayingDetailView.swift
//  MyApp
//
//  Created by Cong Le on 4/9/25.
//

// MARK: - Song Model (Add Mock Lyrics)
// In Song.swift
import SwiftUI
import UIKit
import Combine

struct Song: Identifiable, Equatable {
    var id = UUID()
    let title: String
    let artist: String
    let albumArtName: String
    let duration: TimeInterval
    let lyrics: String? // Optional lyrics

     // Convenience initializer for songs without lyrics
        init(id: UUID = UUID(), title: String, artist: String, albumArtName: String, duration: TimeInterval) {
            self.id = id
            self.title = title
            self.artist = artist
            self.albumArtName = albumArtName
            self.duration = duration
            self.lyrics = nil // Default to nil if not provided
        }

         // Full initializer
         init(id: UUID = UUID(), title: String, artist: String, albumArtName: String, duration: TimeInterval, lyrics: String?) {
             self.id = id
             self.title = title
             self.artist = artist
             self.albumArtName = albumArtName
             self.duration = duration
             self.lyrics = lyrics // Assign provided lyrics
         }

        // Add some mock lyrics
    static let mockLyricsUHP = """
    Em đã nói dối tôi lời đầu tiên
    Em đã nói dối tôi lời sau cuối
    Em đã nói dối tôi nói dối rất nhiều
    Để giờ đây khi em nói lời yêu tôi
    Tôi không tin!

    Tôi không tin vào những gì em nói
    Tôi không tin vào những gì em trao
    Tôi không tin em dù chỉ 1 lần
    Một lần được nghe em nói thật lòng em
    Tôi không tin!
    """

     static let mockLyricsMono = """
     [Verse 1]
     Em muốn anh sống sao? Ở bên một người mà tim không trao
     Yeah, người nói đi em muốn anh sống sao?
     Thà không yêu xin em đừng gieo tương tư xong lại nào ngờ phũ phàng lên môi câu chia ly?
     Giờ lại muốn đôi ta làm bạn thân okay

     [Chorus]
     Maybe I'm crazy, yeah crazy
     Khi mà em buông lời chia tay dù cho bao lỗi lầm anh đây bỏ qua hết babe
     Giờ con tim em đã đổi thay
     Còn tâm trí anh thì giờ đây waiting for you oh oh oh
     Waiting for you oh oh oh
     """

    // Update Mock Data
    static let mockSongs = [
        Song(title: "Những Lời Dối Gian (Remix)", artist: "Ưng Hoàng Phúc", albumArtName: "uhp-album", duration: 305, lyrics: mockLyricsUHP),
        Song(title: "Waiting For You", artist: "Mono", albumArtName: "mono-album", duration: 266, lyrics: mockLyricsMono),
        Song(title: "See Tình", artist: "Hoàng Thuỳ Linh", albumArtName: "htl-album", duration: 185, lyrics: nil) // No lyrics for this one
    ]

    static let placeholder = Song(title: "No Song Loaded", artist: "Unknown Artist", albumArtName: "music.note", duration: 0, lyrics: nil)
}

// MARK: - Add Queue Reordering to PlaybackManager
// In PlaybackManager.swift


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
    
    // MARK: - Queue Management
    func moveItems(from source: IndexSet, to destination: Int) {
        // Ensure the move makes sense within the queue bounds
        guard let sourceIndex = source.first, // Assuming single item move for simplicity
              destination >= 0, destination <= queue.count else {
            print("Invalid move operation")
            return
        }

        // Adjust destination if moving downwards
        let adjustedDestination = destination > sourceIndex ? destination - 1 : destination

        // Only modify the non-playing part of the queue for now (safer)
        // A more complex implementation would handle moving the currently playing item
        // or items before it, potentially adjusting currentQueueIndex.

        // Perform the move on a temporary copy
        var updatedQueue = queue
        updatedQueue.move(fromOffsets: source, toOffset: destination)

        // Find the current playing song's ID before the queue changes
        let currentPlayingSongID = queue[currentQueueIndex].id

         // Update the main queue
        queue = updatedQueue

        // Find the NEW index of the currently playing song after the move
        if let newIndex = queue.firstIndex(where: { $0.id == currentPlayingSongID }) {
            // IMPORTANT: Update currentQueueIndex *without* triggering its didSet
            // otherwise it might reload the song unnecessarily.
            // If you need intermediate loading states, handle them explicitly.
                print("Moving items. Old index: \(currentQueueIndex), New index: \(newIndex)")
             // Direct update to avoid side effects of didSet during reorder
             _currentQueueIndex = Published(initialValue: newIndex)
             print("currentQueueIndex updated to \(newIndex)")

        } else {
            // This shouldn't happen if the current song is always in the queue
            print("Error: Could not find currently playing song after move.")
            // Handle potential error state, maybe reset index?
            currentQueueIndex = 0 // Reset as a fallback
        }

         print("Queue reordered. New queue order:")
         queue.enumerated().forEach { index, song in
             print("\(index): \(song.title) \(index == currentQueueIndex ? "<-- Playing" : "")")
         }
    }

    func removeItem(at index: Int) {
        guard index >= 0 && index < queue.count else { return }

        // Prevent removing the currently playing song (or handle it gracefully)
        if index == currentQueueIndex {
            print("Cannot remove the currently playing song (basic implementation).")
            // Option: Play next, then remove, or just disallow.
            return
        }

        let removedSong = queue.remove(at: index)
        print("Removed \(removedSong.title) from queue.")

        // Adjust currentQueueIndex if an item *before* it was removed
        if index < currentQueueIndex {
            // Direct update to prevent didSet logic from running inappropriately
             _currentQueueIndex = Published(initialValue: currentQueueIndex - 1)
            print("Adjusted currentQueueIndex to \(currentQueueIndex)")
        }
    }

    deinit {
        stopTimer()
        seekTimerDebounce?.cancel()
        print("PlaybackManager deinitialized")
    }
}

// MARK: - The NowPlayingDetailsView

// NowPlayingDetailsView.swift

import SwiftUI

struct NowPlayingDetailsView: View {
    // Use @ObservedObject when the view receives an existing instance
    @ObservedObject var playbackManager: PlaybackManager

    @Environment(\.dismiss) var dismiss // To close the sheet

    // State to manage the selected segment
    @State private var selectedSegment: DetailsSegment = .queue

    enum DetailsSegment: String, CaseIterable {
        case queue = "Queue"
        case lyrics = "Lyrics"
    }

    var body: some View {
        NavigationView { // Embed in NavigationView for Title and ToolbarItem
            VStack(spacing: 0) { // Remove spacing for seamless look
                Picker("Details", selection: $selectedSegment) {
                    ForEach(DetailsSegment.allCases, id: \.self) { segment in
                        Text(segment.rawValue).tag(segment)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding() // Add padding around the picker

                // Content based on selection
                switch selectedSegment {
                case .queue:
                    QueueView(playbackManager: playbackManager)
                case .lyrics:
                    LyricsView(lyrics: playbackManager.currentSong?.lyrics)
                }

                Spacer() // Pushes content to the top
            }
            // Apply consistent background
//            .background(Color.appBackground.ignoresSafeArea())
            // Set the title - gets the current song dynamically
            .navigationTitle(playbackManager.currentSong?.title ?? "Details")
             .navigationBarTitleDisplayMode(.inline) // Keep title concise
             // Add a Done button to the navigation bar
             .toolbar {
                 ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss() // Action to close the sheet
                     }
                    .foregroundColor(Color.yellow) // Use theme's accent color
                }
             }
        }
        .preferredColorScheme(.dark) // Match the player's theme
        // Set text color for unstyled text within the NavigationView
        .accentColor(Color.green) // Affects Toolbar Button Color if needed
    }
}

// --- Subviews for Queue and Lyrics ---
// In NowPlayingDetailsView.swift (or wherever QueueView is defined)

struct QueueView: View {
    @ObservedObject var playbackManager: PlaybackManager

    var body: some View {
        List {
            // Check if queue is empty
            if playbackManager.queue.isEmpty {
                Text("Queue is empty.")
                    .foregroundColor(Color.green)
                    .listRowBackground(Color.yellow) // Apply background to the placeholder row
            } else {
                // Iterate and create QueueRowView instances
                ForEach(Array(playbackManager.queue.enumerated()), id: \.element.id) { index, song in
                    // Create the dedicated row view
                    QueueRowView(
                        song: song,
                        // Calculate the boolean flag here
                        isCurrentlyPlaying: index == playbackManager.currentQueueIndex
                    )
                    // Apply the row-specific background modifier here
                    .listRowBackground(Color.purple)
                }
                .onMove(perform: move) // Modifiers for ForEach remain
                .onDelete(perform: delete)
            }
        }
        .listStyle(PlainListStyle()) // Modifiers for List remain
        .background(Color.primary) // Ensure overall list background
        .environment(\.editMode, .constant(.active))
    }

    // Action handlers remain the same
    private func move(from source: IndexSet, to destination: Int) {
        playbackManager.moveItems(from: source, to: destination)
    }

    private func delete(at offsets: IndexSet) {
        if let index = offsets.first {
            playbackManager.removeItem(at: index)
        }
    }
}

// Make sure QueueRowView is defined before QueueView or accessible in the same scope.
// The rest of NowPlayingDetailsView and LyricsView remain the same.

// Add this helper struct before QueueView or in a separate file

struct QueueRowView: View {
    let song: Song
    let isCurrentlyPlaying: Bool // Pass boolean instead of comparing index inside

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(song.title)
                    .font(.headline)
                    // Use the boolean to decide the color
                    .foregroundColor(isCurrentlyPlaying ? Color.accentColor : Color.yellow)

                Text(song.artist)
                    .font(.subheadline)
                    .foregroundColor(Color.secondary)
            }

            Spacer()

            // Use the boolean to show the indicator
            if isCurrentlyPlaying {
                Image(systemName: "speaker.wave.2.fill")
                    .foregroundColor(Color.accentColor)
            }
        }
        .padding(.vertical, 4) // Keep padding within the row content
        // .listRowBackground is applied outside this view, on the instance
    }
}


struct LyricsView: View {
    let lyrics: String?

    var body: some View {
        ScrollView {
            if let lyrics = lyrics, !lyrics.isEmpty {
                Text(lyrics)
                    .font(.system(.body, design: .serif)) // Serif might look nice for lyrics
                    .foregroundColor(Color.primary)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading) // Align text left
            } else {
                Text("No lyrics available for this song.")
                    .foregroundColor(Color.secondary)
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity) // Center placeholder
            }
        }
        .background(Color.primary) // Ensure scroll view background matches
    }
}

// --- Preview Provider (Important: Needs a PlaybackManager instance) ---

struct NowPlayingDetailsView_Previews: PreviewProvider {
    // Create a mock manager instance for the preview
    static var playbackManager = PlaybackManager()

    static var previews: some View {
        NowPlayingDetailsView(playbackManager: playbackManager)
            .preferredColorScheme(.dark)
    }
}
