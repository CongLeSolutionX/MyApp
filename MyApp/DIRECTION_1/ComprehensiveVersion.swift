//
//  AlbumArtView.swift
//  MyApp
//
//  Created by Cong Le on 4/9/25.
//

// --- Album.swift ---
import Foundation
import Combine

struct Album: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let artistName: String
    let coverArtName: String // Use the same asset names for simplicity
    let releaseYear: Int
    var songs: [Song] // An album contains songs
    
    // Mock Albums
    static let mockUHPAlbum = Album(
        title: "Trở Về", // Fictional album name
        artistName: "Ưng Hoàng Phúc",
        coverArtName: "uhp-album",
        releaseYear: 2004, // Fictional year
        songs: [ // Only include songs belonging to this album
            Song.mockSongs[0] // "Những Lời Dối Gian"
            // Add other fictional UHP songs if needed
               ]
    )
    
    static let mockMonoAlbum = Album(
        title: "22", // Real album name
        artistName: "Mono",
        coverArtName: "mono-album",
        releaseYear: 2022, // Real year
        songs: [ // Only include songs belonging to this album
            Song.mockSongs[1] // "Waiting For You"
            // Add other real/fictional Mono songs if needed
               ]
    )
    
    static let mockHTLAlbum = Album(
        title: "LINK", // Real album name
        artistName: "Hoàng Thuỳ Linh",
        coverArtName: "htl-album",
        releaseYear: 2022, // Real year
        songs: [ // Only include songs belonging to this album
            Song.mockSongs[2] // "See Tình"
            // Add other real/fictional HTL songs if needed
               ]
    )
    
    static let allMockAlbums: [Album] = [mockUHPAlbum, mockMonoAlbum, mockHTLAlbum]
    
    // Helper to find an album for a song (simple lookup for mock data)
    static func findAlbum(for songId: UUID) -> Album? {
        return allMockAlbums.first { album in
            album.songs.contains { $0.id == songId }
        }
    }
}

// --- Song.swift (Add album title for display/lookup if needed) ---
struct Song: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let artist: String
    let albumTitle: String // Add album title reference
    let albumArtName: String
    let duration: TimeInterval
    let lyrics: String?
    
    // Update Initializers
    init(id: UUID = UUID(), title: String, artist: String, albumTitle: String, albumArtName: String, duration: TimeInterval, lyrics: String? = nil) {
        self.id = id
        self.title = title
        self.artist = artist
        self.albumTitle = albumTitle // Initialize album title
        self.albumArtName = albumArtName
        self.duration = duration
        self.lyrics = lyrics
    }
    
    // Update Mock Data with Album Titles
    // (Keep mockLyrics definitions as they were)
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
    
    static let mockSongs = [
        Song(title: "Những Lời Dối Gian (Remix)", artist: "Ưng Hoàng Phúc", albumTitle: "Trở Về", albumArtName: "uhp-album", duration: 305, lyrics: mockLyricsUHP),
        Song(title: "Waiting For You", artist: "Mono", albumTitle: "22", albumArtName: "mono-album", duration: 266, lyrics: mockLyricsMono),
        Song(title: "See Tình", artist: "Hoàng Thuỳ Linh", albumTitle: "LINK", albumArtName: "htl-album", duration: 185, lyrics: nil)
    ]
    
    // Update Placeholder
    static let placeholder = Song(title: "No Song Loaded", artist: "Unknown Artist", albumTitle: "Unknown Album", albumArtName: "music.note", duration: 0, lyrics: nil)
}

// MARK: - PlaybackManager
class PlaybackManager: ObservableObject {
    
    @Published var currentSong: Song?
    @Published var queue: [Song] = Song.mockSongs // Initialize with mock data
    @Published var currentQueueIndex: Int = 0 {
        didSet {
            loadSong(at: currentQueueIndex) // Load song when index changes
        }
    }
    
    @Published var currentAlbum: Album? // Keep track of the current album context
    
    
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
    
    func updateCurrentAlbum() {
        guard let currentSongId = currentSong?.id else {
            currentAlbum = nil
            return
        }
        // Use the helper to find the album for the current song
        currentAlbum = Album.findAlbum(for: currentSongId)
        print("Current album context updated to: \(currentAlbum?.title ?? "None")")
    }
    
    // MARK: - Playback Control for Albums/Tracks
    
    func playAlbum(_ album: Album, startAtIndex index: Int = 0) {
        print("Starting playback for Album: \(album.title), starting at track \(index + 1)")
        guard !album.songs.isEmpty, index >= 0, index < album.songs.count else {
            print("Album is empty or index is out of bounds.")
            return
        }
        
        // Replace the current queue with the album's songs
        queue = album.songs
        // Immediately set the current song and index *before* playing
        // This prevents potential race conditions or brief flashes of old info
        currentQueueIndex = index
        // Assign directly to bypass didSet side-effects during this specific setup
        _currentSong = Published(initialValue: queue[currentQueueIndex])
        updateCurrentAlbum() // Set the album context
        
        // Now load and play the selected song
        loadCurrentSong(autoplay: true) // Load the new currentSong and start playing
    }
    
    func playTrackFromAlbum(album: Album, track: Song) {
        guard let trackIndex = album.songs.firstIndex(where: { $0.id == track.id }) else {
            print("Track \(track.title) not found in album \(album.title)")
            return
        }
        print("Playing track '\(track.title)' from album '\(album.title)'")
        playAlbum(album, startAtIndex: trackIndex)
    }
    
    // Make sure playNext/playPrevious works correctly with the updated queue
    func playNext() {
        guard !queue.isEmpty else { return }
        currentQueueIndex = (currentQueueIndex + 1) % queue.count
        _currentSong = Published(initialValue: queue[currentQueueIndex]) // Update song without triggering full reload yet
        updateCurrentAlbum()
        loadCurrentSong(autoplay: true) // Load and play
        print("Playing next track: \(currentSong?.title ?? "N/A") at index \(currentQueueIndex)")
    }
    
    func playPrevious() {
        guard !queue.isEmpty else { return }
        if playbackProgress > 3.0 { // If played more than 3 seconds, restart current song
            seek(to: 0)
        } else { // Otherwise, go to the previous song
            currentQueueIndex = (currentQueueIndex - 1 + queue.count) % queue.count
            _currentSong = Published(initialValue: queue[currentQueueIndex]) // Update song
            updateCurrentAlbum()
            loadCurrentSong(autoplay: true) // Load and play
            print("Playing previous track: \(currentSong?.title ?? "N/A") at index \(currentQueueIndex)")
        }
    }
    
    // Ensure loadCurrentSong exists and handles playback
    private func loadCurrentSong(autoplay: Bool = false) {
        guard let song = currentSong else {
            player?.pause()
            // Reset progress etc.
            playbackProgress = 0
            return
        }
        
        // Simulate loading/playing
        print("Loading song: \(song.title)")
        // In a real app: Load the actual audio asset URL here
        // player = AVPlayer(url: song.audioURL)
        playbackProgress = 0 // Reset progress
        totalDuration = song.duration
        objectWillChange.send() // Notify views
        
        if isPlaying || autoplay {
            // Simulate playback starting
            isPlaying = true // Ensure state is set correctly
            startPlaybackSimulation() // Restart timer if needed
            print("Autoplaying song: \(song.title)")
            // In real app: player?.play()
        } else {
            // Just load, don't play yet
            isPlaying = false
            stopPlaybackSimulation() // Stop timer if needed
            print("Song \(song.title) loaded, ready to play.")
        }
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


// MARK: - AlbumDetailView

// AlbumDetailView.swift

import SwiftUI
import Combine

struct AlbumDetailView: View {
    let album: Album
    // Pass the playback manager if actions like play are needed directly
    @ObservedObject var playbackManager: PlaybackManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // --- Header Section ---
                AlbumHeaderView(album: album, playbackManager: playbackManager)
                    .padding(.horizontal)
                
                // --- Track List Section ---
                Text("Tracks")
                    .font(.title2).bold()
                    .padding(.horizontal)
                
                // Use LazyVStack for potentially long lists within ScrollView
                LazyVStack(alignment: .leading, spacing: 0) {
                    ForEach(Array(album.songs.enumerated()), id: \.element.id) { index, song in
                        TrackRowView(
                            trackNumber: index + 1,
                            song: song,
                            isCurrentlyPlaying: playbackManager.currentSong?.id == song.id && playbackManager.currentAlbum?.id == album.id,
                            onTrackTap: {
                                // Action: Play this specific track from this album
                                playbackManager.playTrackFromAlbum(album: album, track: song)
                                // Optional: Dismiss this view after selection
                                // dismiss()
                            }
                        )
                        Divider().padding(.leading, 50) // Indent divider
                    }
                }
            }
            .padding(.top) // Add padding at the top of the VStack
        }
        .background(Color.orange) // Apply background
        .foregroundColor(Color.yellow) // Default text color
        .navigationTitle(album.title) // Set navigation title
        .navigationBarTitleDisplayMode(.inline) // Keep title neat
        .preferredColorScheme(.dark)
    }
}

// --- Subviews for AlbumDetailView ---

struct AlbumHeaderView: View {
    let album: Album
    @ObservedObject var playbackManager: PlaybackManager // Needed for play action
    
    var body: some View {
        HStack(alignment: .center, spacing: 15) {
            Image(album.coverArtName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 120, height: 120)
                .cornerRadius(8)
                .shadow(radius: 5)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(album.title)
                    .font(.title3).bold()
                    .lineLimit(2) // Allow wrapping
                // Make artist name tappable (placeholder for future navigation)
                Button(album.artistName) {
                    print("Navigate to Artist: \(album.artistName)")
                    // Future: Implement navigation to ArtistDetailView
                }
                .font(.subheadline)
                .foregroundColor(Color.green)
                
                Text("Album • \(album.releaseYear)")
                    .font(.caption)
                    .foregroundColor(Color.textSecondary)
                
                Spacer() // Pushes buttons down
                
                // Play / Shuffle Buttons
                HStack {
                    Button {
                        // Action: Play album from the beginning
                        playbackManager.playAlbum(album)
                    } label: {
                        Label("Play", systemImage: "play.fill")
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .background(Color.accentColor)
                            .foregroundColor(Color.white)
                            .cornerRadius(8)
                    }
                    
                    Button {
                        // Action: Shuffle album (requires shuffle logic in PlaybackManager)
                        print("Shuffle Album Tapped (Not Implemented)")
                        // playbackManager.shuffleAlbum(album)
                    } label: {
                        Label("Shuffle", systemImage: "shuffle")
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.3))
                            .foregroundColor(Color.textPrimary)
                            .cornerRadius(8)
                    }
                }
            }
            .frame(height: 120) // Match image height
        }
    }
}

struct TrackRowView: View {
    let trackNumber: Int
    let song: Song
    let isCurrentlyPlaying: Bool
    let onTrackTap: () -> Void
    
    var body: some View {
        Button(action: onTrackTap) { // Make the whole row tappable
            HStack {
                Text("\(trackNumber)")
                    .font(.subheadline)
                    .foregroundColor(isCurrentlyPlaying ? Color.accentColor : Color.green)
                    .frame(width: 30, alignment: .trailing) // Align track number
                
                VStack(alignment: .leading) {
                    Text(song.title)
                        .font(.body)
                        .lineLimit(1)
                        .foregroundColor(isCurrentlyPlaying ? Color.accentColor : Color.yellow)
                    // Optional: Show artist if album has various artists
                    // Text(song.artist)
                    //    .font(.caption)
                    //    .foregroundColor(Color.textSecondary)
                }
                
                Spacer()
                
                // Display duration
                Text(formatTime(song.duration))
                    .font(.caption)
                    .foregroundColor(Color.textSecondary)
                
                // Optional: Add explicit play icon or playing indicator
                if isCurrentlyPlaying {
                    Image(systemName: "speaker.wave.2.fill")
                        .foregroundColor(Color.accentColor)
                    //.padding(.leading, 5)
                }
                // else {
                //    Image(systemName: "play.fill") // Example: Show play icon on hover/tap area
                //        .foregroundColor(Color.textSecondary)
                // }
                
            }
            .padding(.vertical, 10)
            .padding(.horizontal) // Add horizontal padding to the HStack content
            .background(Color.purple) // Ensure background for the tappable area
        }
        .buttonStyle(PlainButtonStyle()) // Use plain style to make row look like content
    }
    
    // Helper to format time (copy from MusicPlayerView or create shared utility)
    private func formatTime(_ interval: TimeInterval) -> String {
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// --- Preview ---
struct AlbumDetailView_Previews: PreviewProvider {
    // Create mock data specifically for the preview
    static let previewAlbum = Album.mockMonoAlbum // Or any other mock album
    static var previewPlaybackManager = PlaybackManager()
    
    // Pre-select a song to show the 'playing' state in preview
    static var setupPreview: () = {
        previewPlaybackManager.currentSong = previewAlbum.songs.first
        previewPlaybackManager.updateCurrentAlbum() // Set album context
        previewPlaybackManager.isPlaying = true // Simulate playing state
    }()
    
    static var previews: some View {
        NavigationView { // Wrap in NavigationView for previewing title bar
            AlbumDetailView(album: previewAlbum, playbackManager: previewPlaybackManager)
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: -  Integrate Navigation in MusicPlayerView



// In MusicPlayerView.swift

struct MusicPlayerView: View {
    @StateObject private var playbackManager = PlaybackManager()
    @State private var showingDetailsSheet = false
    @State private var initialDetailSegment: NowPlayingDetailsView.DetailsSegment = .queue
    
    var body: some View {
        // Use NavigationStack for modern navigation
        NavigationStack {
            ZStack {
                // Background Gradient
                LinearGradient(gradient: Gradient(colors: [.playerGrayDark, .appBackground]), startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
                
                // Main Content VStack
                VStack(spacing: 20) {
                    //Spacer() // Pushes Album Art Down slightly
                    
                    // --- Make Album Art Navigable ---
                    // Ensure we have album data before creating the link
                    if let currentAlbum = playbackManager.currentAlbum {
                        NavigationLink(destination: AlbumDetailView(album: currentAlbum, playbackManager: playbackManager)) {
                            AlbumArtView(albumArtName: currentAlbum.coverArtName) // Use album's art
                        }
                        .buttonStyle(PlainButtonStyle()) // Prevent default button styling on the image
                    } else {
                        // Fallback if no album context yet (e.g., initial load)
                        AlbumArtView(albumArtName: playbackManager.currentSong?.albumArtName ?? "music.note")
                    }
                    
                    SongInfoView(
                        title: playbackManager.currentSong?.title ?? "No Title",
                        artist: playbackManager.currentSong?.artist ?? "No Artist"
                    )
                    
                    PlaybackProgressView(
                        progress: $playbackManager.playbackProgress,
                        totalDuration: playbackManager.totalDuration,
                        onSeek: playbackManager.seek // Pass the seek function
                    )
                    .padding(.horizontal)
                    
                    PlaybackControlsView(
                        isPlaying: $playbackManager.isPlaying,
                        onPlayPause: playbackManager.togglePlayPause,
                        onNext: playbackManager.playNext,
                        onPrevious: playbackManager.playPrevious
                    )
                    .padding(.horizontal)
                    
                    BottomActionsView(
                        onLyricsTap: {
                            initialDetailSegment = .lyrics
                            showingDetailsSheet = true
                        },
                        onCastTap: playbackManager.showCastingOptions,
                        onQueueTap: {
                            initialDetailSegment = .queue
                            showingDetailsSheet = true
                        }
                    )
                    .padding(.horizontal)
                    
                    Spacer() // Pushes content towards center/top
                }
                .padding(.top, 40) // Adjust top padding as needed
                .padding(.bottom)
                .foregroundColor(Color.textPrimary) // Default text color for the VStack
                
            } // End ZStack
            .navigationTitle("Now Playing") // Optional: Title for the root view
            .navigationBarHidden(true) // Hide the default nav bar for this custom player UI
        } // End NavigationStack
        .preferredColorScheme(.dark)
        .onAppear { // Load initial song/album context
            if playbackManager.currentSong == nil {
                playbackManager.currentSong = Song.mockSongs.first
                // PlaybackManager's didSet for currentSong should call updateCurrentAlbum
            }
        }
        .sheet(isPresented: $showingDetailsSheet) {
            NowPlayingDetailsView(
                playbackManager: playbackManager,
                selectedSegment: initialDetailSegment
            )
        }
        // Important: Handle potential changes if PlaybackManager is modified elsewhere
        .environmentObject(playbackManager) // Provide manager if needed by deeper views via EnvironmentObject
    }
}

// --- AlbumArtView (ensure it uses the passed name) ---
struct AlbumArtView: View {
    let albumArtName: String
    
    var body: some View {
        Image(albumArtName) // Use the dynamic name
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(maxWidth: 300, maxHeight: 300) // Adjust size as needed
            .cornerRadius(10)
            .shadow(color: .black.opacity(0.4), radius: 10, x: 0, y: 5)
            .padding(.bottom, 10)
    }
}

// MARK: - PlaybackControlsView

struct PlaybackControlsView: View {
    @Binding var isPlaying: Bool
    
    var body: some View {
        HStack(spacing: 40) { // Control spacing between buttons
            Button { /* Previous track action */ } label: {
                Image(systemName: "backward.fill")
            }
            
            Button { isPlaying.toggle() /* Play/Pause action */ } label: {
                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: 45)) // Make play/pause slightly larger
            }
            
            Button { /* Next track action */ } label: {
                Image(systemName: "forward.fill")
            }
        }
        .font(.largeTitle) // Set default size for side buttons
        .foregroundColor(Color.yellow) // Ensure controls are white
        .padding(.vertical, 15) // Add vertical spacing around controls
    }
}

// MARK: - NowPlayingDetailsView
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
