////
////  GetCurrentlyPlayingTrackView_V2.swift
////  MyApp
////
////  Created by Cong Le on 4/16/25.
////
//import Foundation
//
//// MARK: - Main Response Structure
//struct CurrentlyPlayingResponse: Codable, Identifiable {
//    let id = UUID() // Add identifiable conformance for potential list usage
//    let device: Device?
//    var repeatState: String? // e.g., "off", "track", "context"
//    var shuffleState: Bool?
//    let context: PlaybackContext?
//    let timestamp: Int?
//    var progressMs: Int?
//    var isPlaying: Bool?
//    var item: PlayableItem?
//    let currentlyPlayingType: String? // e.g., "track", "episode"
//    let actions: PlayerActions?
//
//    enum CodingKeys: String, CodingKey {
//        case device
//        case repeatState = "repeat_state"
//        case shuffleState = "shuffle_state"
//        case context, timestamp
//        case progressMs = "progress_ms"
//        case isPlaying = "is_playing"
//        case item
//        case currentlyPlayingType = "currently_playing_type"
//        case actions
//    }
//}
//
//// MARK: - Device Information
//struct Device: Codable, Identifiable {
//    let id: String?
//    let isActive: Bool?
//    let isPrivateSession: Bool?
//    let isRestricted: Bool?
//    let name: String?
//    let type: String? // e.g., "computer", "speaker", "smartphone"
//    let volumePercent: Int?
//    let supportsVolume: Bool?
//
//    enum CodingKeys: String, CodingKey {
//        case id
//        case isActive = "is_active"
//        case isPrivateSession = "is_private_session"
//        case isRestricted = "is_restricted"
//        case name, type
//        case volumePercent = "volume_percent"
//        case supportsVolume = "supports_volume"
//    }
//}
//
//// MARK: - Playback Context
//struct PlaybackContext: Codable {
//    let type: String? // e.g., "album", "playlist", "artist"
//    let href: String?
//    let externalUrls: ExternalUrls?
//    let uri: String?
//
//    enum CodingKeys: String, CodingKey {
//        case type, href
//        case externalUrls = "external_urls"
//        case uri
//    }
//}
//
//// MARK: - Playable Item (Track/Episode)
//struct PlayableItem: Codable, Identifiable {
//    let album: Album?
//    let artists: [Artist]?
//    let availableMarkets: [String]?
//    let discNumber: Int?
//    let durationMs: Int?
//    let explicit: Bool?
//    let externalIds: ExternalIds?
//    let externalUrls: ExternalUrls?
//    let href: String?
//    let id: String?
//    let isPlayable: Bool?
//    // let linkedFrom: LinkedFrom? // Simplified for this example
//    let restrictions: Restrictions?
//    let name: String? // Track or Episode name
//    let popularity: Int?
//    let previewUrl: String?
//    let trackNumber: Int?
//    let type: String? // "track" or "episode"
//    let uri: String?
//    let isLocal: Bool?
//
//    enum CodingKeys: String, CodingKey {
//        case album, artists
//        case availableMarkets = "available_markets"
//        case discNumber = "disc_number"
//        case durationMs = "duration_ms"
//        case explicit
//        case externalIds = "external_ids"
//        case externalUrls = "external_urls"
//        case href, id
//        case isPlayable = "is_playable"
//        // case linkedFrom = "linked_from"
//        case restrictions, name, popularity
//        case previewUrl = "preview_url"
//        case trackNumber = "track_number"
//        case type, uri
//        case isLocal = "is_local"
//    }
//}
//
//// MARK: - Album Information
//struct Album: Codable, Identifiable {
//    let albumType: String?
//    let totalTracks: Int?
//    let availableMarkets: [String]?
//    let externalUrls: ExternalUrls?
//    let href: String?
//    let id: String?
//    let images: [ImageInfo]?
//    let name: String?
//    let releaseDate: String?
//    let releaseDatePrecision: String?
//    let restrictions: Restrictions?
//    let type: String?
//    let uri: String?
//    let artists: [Artist]? // Sometimes simplified artist info is nested here too
//
//    enum CodingKeys: String, CodingKey {
//        case albumType = "album_type"
//        case totalTracks = "total_tracks"
//        case availableMarkets = "available_markets"
//        case externalUrls = "external_urls"
//        case href, id, images, name
//        case releaseDate = "release_date"
//        case releaseDatePrecision = "release_date_precision"
//        case restrictions, type, uri, artists
//    }
//}
//
//// MARK: - Artist Information
//struct Artist: Codable, Identifiable {
//    let externalUrls: ExternalUrls?
//    let href: String?
//    let id: String?
//    let name: String?
//    let type: String?
//    let uri: String?
//
//    enum CodingKeys: String, CodingKey {
//        case externalUrls = "external_urls"
//        case href, id, name, type, uri
//    }
//}
//
//// MARK: - Image Information
//struct ImageInfo: Codable, Hashable { // Hashable for potential use in ForEach
//    let url: String?
//    let height: Int?
//    let width: Int?
//}
//
//// MARK: - External URLs
//struct ExternalUrls: Codable {
//    let spotify: String?
//}
//
//// MARK: - External IDs
//struct ExternalIds: Codable {
//    let isrc: String?
//    let ean: String?
//    let upc: String?
//}
//
//// MARK: - Restrictions
//struct Restrictions: Codable {
//    let reason: String? // e.g., "market", "explicit"
//}
//
//// MARK: - Player Actions
//struct PlayerActions: Codable {
//    let interruptingPlayback: Bool?
//    let pausing: Bool?
//    let resuming: Bool?
//    let seeking: Bool?
//    let skippingNext: Bool?
//    let skippingPrev: Bool?
//    let togglingRepeatContext: Bool?
//    let togglingShuffle: Bool?
//    let togglingRepeatTrack: Bool?
//    let transferringPlayback: Bool?
//
//     enum CodingKeys: String, CodingKey {
//        case interruptingPlayback = "interrupting_playback"
//        case pausing, resuming, seeking
//        case skippingNext = "skipping_next"
//        case skippingPrev = "skipping_prev"
//        case togglingRepeatContext = "toggling_repeat_context"
//        case togglingShuffle = "toggling_shuffle"
//        case togglingRepeatTrack = "toggling_repeat_track"
//        case transferringPlayback = "transferring_playback"
//    }
//}
//
//// Helper function to format milliseconds to MM:SS
//func formatTime(milliseconds: Int?) -> String {
//    guard let ms = milliseconds, ms > 0 else { return "0:00" }
//    let totalSeconds = ms / 1000
//    let minutes = totalSeconds / 60
//    let seconds = totalSeconds % 60
//    return String(format: "%d:%02d", minutes, seconds)
//}
//
//// Helper function to get device icon
//func deviceIcon(type: String?) -> String {
//    switch type?.lowercased() {
//    case "computer": return "desktopcomputer"
//    case "smartphone": return "iphone"
//    case "speaker": return "speaker.wave.2.fill"
//    case "tv": return "tv"
//    case "avr": return "hifireceiver" // Example
//    case "stb": return "appletv"     // Example
//    case "audiodongle": return "airpodspro.chargingcase.wireless" // Example
//    case "castvideo", "castaudio": return "airplayaudio" // Example
//    default: return "questionmark.circle"
//    }
//}
//
//struct MockData {
//    static let track1 = PlayableItem(
//        album: Album(albumType: "album", totalTracks: 12, availableMarkets: nil, externalUrls: nil, href: nil, id: "alb1", images: [ImageInfo(url: "https://i.scdn.co/image/ab67616d0000b273f5245ac602c9e9d6a993f1bb", height: 640, width: 640)], name: "Midnight Drive", releaseDate: "2023", releaseDatePrecision: "year", restrictions: nil, type: "album", uri: "spotify:album:alb1", artists: [artist1]),
//        artists: [artist1], availableMarkets: ["US"], discNumber: 1, durationMs: 245000, explicit: false, externalIds: nil, externalUrls: nil, href: nil, id: "track1", isPlayable: true, restrictions: nil, name: "Synthwave Dreams", popularity: 85, previewUrl: nil, trackNumber: 3, type: "track", uri: "spotify:track:track1", isLocal: false
//    )
//
//    static let track2 = PlayableItem(
//        album: Album(albumType: "album", totalTracks: 10, availableMarkets: nil, externalUrls: nil, href: nil, id: "alb2", images: [ImageInfo(url: "https://i.scdn.co/image/ab67616d0000b273a9a72c0a1f2a3e3f9de3d6c0", height: 640, width: 640)], name: "Neon Nights", releaseDate: "2022", releaseDatePrecision: "year", restrictions: nil, type: "album", uri: "spotify:album:alb2", artists: [artist2]),
//        artists: [artist2], availableMarkets: ["US"], discNumber: 1, durationMs: 198000, explicit: true, externalIds: nil, externalUrls: nil, href: nil, id: "track2", isPlayable: true, restrictions: nil, name: "City Lights", popularity: 78, previewUrl: nil, trackNumber: 1, type: "track", uri: "spotify:track:track2", isLocal: false
//    )
//
//    static let track3 = PlayableItem(
//         album: Album(albumType: "single", totalTracks: 1, availableMarkets: nil, externalUrls: nil, href: nil, id: "alb3", images: [ImageInfo(url: "https://i.scdn.co/image/ab67616d0000b2738c5c6d0f9c9b7a1b9c2b9f0e", height: 640, width: 640)], name: "Lost Signal", releaseDate: "2024", releaseDatePrecision: "year", restrictions: nil, type: "single", uri: "spotify:album:alb3", artists: [artist1]),
//        artists: [artist1], availableMarkets: ["US"], discNumber: 1, durationMs: 310000, explicit: false, externalIds: nil, externalUrls: nil, href: nil, id: "track3", isPlayable: true, restrictions: nil, name: "Lost Signal", popularity: 91, previewUrl: nil, trackNumber: 1, type: "track", uri: "spotify:track:track3", isLocal: false
//    )
//
//    static let artist1 = Artist(externalUrls: nil, href: nil, id: "art1", name: "Virtual Voyager", type: "artist", uri: "spotify:artist:art1")
//    static let artist2 = Artist(externalUrls: nil, href: nil, id: "art2", name: "Chrome Cruiser", type: "artist", uri: "spotify:artist:art2")
//
//    static let sampleDevice = Device(id: "dev1_mac", isActive: true, isPrivateSession: false, isRestricted: false, name: "My MacBook Pro", type: "Computer", volumePercent: 68, supportsVolume: true)
//
//    static let defaultActions = PlayerActions(interruptingPlayback: true, pausing: true, resuming: true, seeking: true, skippingNext: true, skippingPrev: true, togglingRepeatContext: true, togglingShuffle: true, togglingRepeatTrack: true, transferringPlayback: true)
//
//    // Function to get initial data
//    static func getInitialData() -> CurrentlyPlayingResponse {
//        return CurrentlyPlayingResponse(
//            device: sampleDevice,
//            repeatState: "off",
//            shuffleState: false,
//            context: PlaybackContext(type: "playlist", href: nil, externalUrls: nil, uri: "spotify:playlist:playlist1"),
//            timestamp: Int(Date().timeIntervalSince1970 * 1000),
//            progressMs: 35000, // Start partway through
//            isPlaying: false, // Start paused
//            item: track1,
//            currentlyPlayingType: "track",
//            actions: defaultActions
//        )
//    }
//
//    // Helper to get next track (simplified logic)
//    static func getNextTrack(currentTrackId: String?) -> PlayableItem {
//        switch currentTrackId {
//            case track1.id: return track2
//            case track2.id: return track3
//            default: return track1 // Loop back or default
//        }
//    }
//
//     // Helper to get previous track (simplified logic)
//    static func getPreviousTrack(currentTrackId: String?) -> PlayableItem {
//        switch currentTrackId {
//            case track3.id: return track2
//            case track2.id: return track1
//            default: return track3 // Loop back or default
//        }
//    }
//}
//
//import SwiftUI
//import Combine // Needed for Timer
//
//struct CurrentlyPlayingView: View {
//    // State to hold the currently playing data, allowing modifications
//    @State private var currentlyPlayingData: CurrentlyPlayingResponse? = MockData.getInitialData() // Start with mock data
//
//    // Timer for progress updates
//    @State private var progressTimer: AnyCancellable?
//    @State private var isEditingSlider: Bool = false // Track slider interaction separately
//
//    var body: some View {
//        VStack(spacing: 15) {
//            if let data = currentlyPlayingData, let item = data.item {
//                // --- Album Art ---
//                AlbumArtView(imageUrl: item.album?.images?.first?.url)
//                    .padding(.top)
//
//                // --- Track Info ---
//                TrackInfoView(trackName: item.name, artistName: item.artists?.map { $0.name ?? "" }.joined(separator: ", "))
//                    .padding(.horizontal)
//
//                // --- Progress Bar (Interactive) ---
//                ProgressBarView(
//                    progressMs: Binding( // Bind directly to the state's progress
//                        get: { currentlyPlayingData?.progressMs ?? 0 },
//                        set: { newValue in currentlyPlayingData?.progressMs = Int(newValue) }
//                    ),
//                    durationMs: item.durationMs,
//                    isEditing: $isEditingSlider, // Pass binding for slider editing state
//                    onEditingChanged: { editing in // Closure called when editing starts/ends
//                        if !editing {
//                            // User finished seeking, simulate seek action
//                            seek(to: currentlyPlayingData?.progressMs ?? 0)
//                        }
//                    }
//                )
//                .padding(.horizontal)
//
//                // --- Playback Controls ---
//                PlaybackControlsView(
//                    isPlaying: data.isPlaying ?? false,
//                    actions: data.actions,
//                    shuffleState: data.shuffleState ?? false,
//                    repeatState: data.repeatState ?? "off",
//                    // Pass action closures down
//                    shuffleAction: toggleShuffle,
//                    skipBackAction: skipToPrevious,
//                    playPauseAction: togglePlayPause,
//                    skipForwardAction: skipToNext,
//                    repeatAction: cycleRepeatMode
//                )
//                .padding(.horizontal)
//
//                // --- Device Info ---
//                DeviceInfoView(device: data.device)
//                    .padding(.bottom)
//
//                Spacer() // Push content to the top
//
//            } else {
//                // --- Placeholder/Loading State ---
//                ContentUnavailableView(
//                    "Nothing Playing",
//                    systemImage: "music.note.list",
//                    description: Text("Open Spotify on another device to control playback.")
//                )
//            }
//        }
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .background(Color(.systemGroupedBackground).edgesIgnoringSafeArea(.all))
//        .onAppear(perform: setupTimerIfNeeded)
//        .onDisappear(perform: stopTimer)
//        .onChange(of: currentlyPlayingData?.isPlaying) { _, isPlaying in
//            setupTimerIfNeeded() // Restart/stop timer when play state changes
//        }
//         .onChange(of: isEditingSlider) { _, editing in
//             // Pause/resume timer based on slider interaction
//             if editing {
//                 stopTimer()
//             } else {
//                 setupTimerIfNeeded()
//             }
//         }
//    }
//
//    // MARK: - Timer Management
//    private func setupTimerIfNeeded() {
//        // Only run timer if playing and not editing slider
//        guard currentlyPlayingData?.isPlaying == true, !isEditingSlider else {
//            stopTimer()
//            return
//        }
//
//        // Debounce or ensure timer isn't created multiple times rapidly if needed
//        stopTimer() // Ensure previous timer is stopped
//
//        progressTimer = Timer.publish(every: 1.0, on: .main, in: .common)
//            .autoconnect()
//            .sink { [weak self] _ in
//                self?.updateProgress()
//            }
//    }
//
//    private func stopTimer() {
//        progressTimer?.cancel()
//        progressTimer = nil
//    }
//
//    private func updateProgress() {
//        guard currentlyPlayingData?.isPlaying == true else { return } // Should be redundant due to setupTimerIfNeeded, but safe
//
//        let currentProgress = currentlyPlayingData?.progressMs ?? 0
//        let duration = currentlyPlayingData?.item?.durationMs ?? 0
//        let newProgress = currentProgress + 1000 // Add 1 second
//
//        if duration > 0 && newProgress >= duration {
//            // Track finished, handle based on repeat state
//            handleTrackFinished()
//        } else {
//            currentlyPlayingData?.progressMs = newProgress
//        }
//    }
//
//    private func handleTrackFinished() {
//        switch currentlyPlayingData?.repeatState {
//        case "track":
//            // Repeat the same track
//             currentlyPlayingData?.progressMs = 0
//             // Timer will continue as isPlaying is still true
//        case "context":
//            // Play next track in context (simulate)
//            skipToNext()
//            // If skipToNext resets progress and keeps playing, timer handles it
//        default: // "off"
//            // Stop playback
//             currentlyPlayingData?.progressMs = durationMs // Show as finished
//             currentlyPlayingData?.isPlaying = false
//             stopTimer()
//        }
//    }
//
//    // Computed property for easy access to duration
//    private var durationMs: Int {
//        currentlyPlayingData?.item?.durationMs ?? 0
//    }
//
//    // MARK: - Simulated Actions (Replace with actual API calls)
//
//    func togglePlayPause() {
//        currentlyPlayingData?.isPlaying?.toggle()
//        print("ACTION: Play/Pause Toggled. New state: \(currentlyPlayingData?.isPlaying ?? false)")
//        // In real app: Call Spotify API to play/pause
//    }
//
//    func skipToNext() {
//        guard currentlyPlayingData?.actions?.skippingNext == true else { return }
//        let currentTrackId = currentlyPlayingData?.item?.id
//        let nextTrack = MockData.getNextTrack(currentTrackId: currentTrackId)
//
//        currentlyPlayingData?.item = nextTrack
//        currentlyPlayingData?.progressMs = 0 // Reset progress
//        currentlyPlayingData?.isPlaying = true // Assume playback continues
//        print("ACTION: Skipped to Next. New track: \(nextTrack.name ?? "Unknown")")
//        setupTimerIfNeeded() // Ensure timer is running for the new track
//        // In real app: Call Spotify API to skip next
//    }
//
//    func skipToPrevious() {
//        guard currentlyPlayingData?.actions?.skippingPrev == true else { return }
//
//        // Spotify logic: If progress > threshold (e.g., 3s), restart track, else go to previous
//        if (currentlyPlayingData?.progressMs ?? 0) > 3000 {
//             currentlyPlayingData?.progressMs = 0
//             print("ACTION: Restarted Track.")
//             // In real app: Call Spotify API to seek(0)
//        } else {
//            let currentTrackId = currentlyPlayingData?.item?.id
//            let prevTrack = MockData.getPreviousTrack(currentTrackId: currentTrackId)
//            currentlyPlayingData?.item = prevTrack
//            currentlyPlayingData?.progressMs = 0 // Reset progress
//            print("ACTION: Skipped to Previous. New track: \(prevTrack.name ?? "Unknown")")
//            // In real app: Call Spotify API to skip previous
//        }
//         currentlyPlayingData?.isPlaying = true // Assume playback continues
//         setupTimerIfNeeded()
//    }
//
//    func toggleShuffle() {
//        guard currentlyPlayingData?.actions?.togglingShuffle == true else { return }
//        currentlyPlayingData?.shuffleState?.toggle()
//        print("ACTION: Toggled Shuffle. New state: \(currentlyPlayingData?.shuffleState ?? false)")
//        // In real app: Call Spotify API to toggle shuffle
//    }
//
//    func cycleRepeatMode() {
//         guard (currentlyPlayingData?.actions?.togglingRepeatContext == true ||
//                currentlyPlayingData?.actions?.togglingRepeatTrack == true) else { return }
//
//        let currentMode = currentlyPlayingData?.repeatState ?? "off"
//        var nextMode = "off"
//
//        // Determine next mode based on API allowance
//        let canToggleContext = currentlyPlayingData?.actions?.togglingRepeatContext ?? false
//        let canToggleTrack = currentlyPlayingData?.actions?.togglingRepeatTrack ?? false
//
//        switch currentMode {
//            case "off":
//                // Prefer context repeat if available, otherwise track repeat
//                if canToggleContext { nextMode = "context" }
//                else if canToggleTrack { nextMode = "track" }
//                else { nextMode = "off"} // Should not happen if button enabled
//            case "context":
//                 // Prefer track repeat if available, otherwise off
//                if canToggleTrack { nextMode = "track" }
//                else { nextMode = "off" }
//            case "track":
//                // Always go back to off from track repeat
//                nextMode = "off"
//            default:
//                nextMode = "off"
//        }
//
//        currentlyPlayingData?.repeatState = nextMode
//        print("ACTION: Cycled Repeat Mode. New mode: \(nextMode)")
//        // In real app: Call Spotify API to set repeat mode
//    }
//
//    func seek(to milliseconds: Int) {
//        // Clamp the seek value to the duration
//        let clampedMs = max(0, min(milliseconds, durationMs))
//        currentlyPlayingData?.progressMs = clampedMs
//        print("ACTION: Seeked to \(clampedMs)ms")
//        // Restart timer immediately after seeking if playing
//        setupTimerIfNeeded()
//        // In real app: Call Spotify API to seek
//    }
//}
//
//// MARK: - Sub-Views (Updated ProgressBarView, PlaybackControlsView)
//
//struct AlbumArtView: View { // No changes needed
//    let imageUrl: String?
//    // ... existing code ...
//    var body: some View {
//        AsyncImage(url: URL(string: imageUrl ?? "")) { phase in
//            switch phase {
//            case .empty:
//                ProgressView()
//                    .frame(width: 250, height: 250) // Consistent size
//                    .background(Color.secondary.opacity(0.2))
//            case .success(let image):
//                image
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//                 .shadow(radius: 8) // Add a subtle shadow
//            case .failure:
//                Image(systemName: "music.note")
//                    .font(.system(size: 100))
//                    .foregroundColor(.secondary)
//                    .frame(width: 250, height: 250)
//                    .background(Color.secondary.opacity(0.2))
//            @unknown default:
//                EmptyView()
//            }
//        }
//        .frame(width: 250, height: 250) // Define frame for the image area
//        .cornerRadius(8) // Rounded corners for the album art
//    }
//}
//
//struct TrackInfoView: View { // No changes needed
//     let trackName: String?
//     let artistName: String?
//     // ... existing code ...
//    var body: some View {
//        VStack {
//            Text(trackName ?? "Unknown Track")
//                .font(.title2)
//                .fontWeight(.bold)
//                .lineLimit(1) // Prevent long track names from wrapping excessively
//
//            Text(artistName ?? "Unknown Artist")
//                .font(.title3)
//                .foregroundColor(.secondary)
//                .lineLimit(1)
//        }
//        .multilineTextAlignment(.center)
//    }
//}
//
//struct ProgressBarView: View {
//    // Use Binding to directly modify the state in the parent view
//    @Binding var progressMs: Int
//    let durationMs: Int?
//    @Binding var isEditing: Bool // Track if user is dragging
//    var onEditingChanged: (Bool) -> Void // Callback for when editing starts/ends
//
//    private var progressValue: Double {
//        guard let duration = durationMs, duration > 0 else { return 0.0 }
//        // Ensure progress doesn't exceed duration visually
//        return min(1.0, max(0.0, Double(progressMs) / Double(duration)))
//    }
//
//    private var durationMilliseconds: Int {
//        durationMs ?? 0
//    }
//
//    var body: some View {
//        VStack(spacing: 5) {
//            // Interactive Slider
//            Slider(
//                value: Binding( // Convert Int progressMs to Double for Slider
//                    get: { Double(progressMs) },
//                    set: { progressMs = Int($0) } // Update Int state on change
//                ),
//                in: 0...Double(max(1, durationMilliseconds)), // Ensure range > 0
//                onEditingChanged: onEditingChanged // Notify parent view
//            )
//            .tint(.primary)
//            // Disable slider interaction based on API response if needed
//             .disabled(!(currentlyPlayingData?.actions?.seeking ?? false)) // Example: Disable if seeking not allowed
//
//            HStack {
//                Text(formatTime(milliseconds: progressMs))
//                Spacer()
//                Text(formatTime(milliseconds: durationMs))
//            }
//            .font(.caption)
//            .foregroundColor(.secondary)
//        }
//    }
//}
//
//struct PlaybackControlsView: View {
//    let isPlaying: Bool
//    let actions: PlayerActions?
//    let shuffleState: Bool
//    let repeatState: String // "off", "track", "context"
//
//    // Action Closures provided by the parent view
//    let shuffleAction: () -> Void
//    let skipBackAction: () -> Void
//    let playPauseAction: () -> Void
//    let skipForwardAction: () -> Void
//    let repeatAction: () -> Void
//
//    var body: some View {
//        HStack(spacing: 30) {
//            // --- Shuffle Button ---
//            Button(action: shuffleAction) { // Call the passed closure
//                Image(systemName: "shuffle")
//                    .font(.title2)
//                    .foregroundColor(shuffleState ? .accentColor : .secondary)
//            }
//            .disabled(!(actions?.togglingShuffle ?? false))
//
//            // --- Previous Button ---
//            Button(action: skipBackAction) { // Call the passed closure
//                Image(systemName: "backward.fill")
//                    .font(.title)
//            }
//             .disabled(!(actions?.skippingPrev ?? false))
//
//            // --- Play/Pause Button ---
//             Button(action: playPauseAction) { // Call the passed closure
//                 Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
//                    .font(.system(size: 50))
//            }
//             // Disable based on the *current* state and available action
//            .disabled(isPlaying ? !(actions?.pausing ?? false) : !(actions?.resuming ?? false))
//
//            // --- Next Button ---
//            Button(action: skipForwardAction) { // Call the passed closure
//                Image(systemName: "forward.fill")
//                     .font(.title)
//            }
//            .disabled(!(actions?.skippingNext ?? false))
//
//            // --- Repeat Button ---
//            Button(action: repeatAction) { // Call the passed closure
//                let repeatIcon: String
//                switch repeatState {
//                    case "track": repeatIcon = "repeat.1"
//                    case "context": repeatIcon = "repeat"
//                    default: repeatIcon = "repeat" // Also for "off"
//                }
//                 Image(systemName: repeatIcon)
//                     .font(.title2)
//                    .foregroundColor(repeatState != "off" ? .accentColor : .secondary)
//            }
//            // Disable if neither repeat action is possible
//             .disabled(!(actions?.togglingRepeatContext ?? false) && !(actions?.togglingRepeatTrack ?? false))
//        }
//        .foregroundColor(.primary)
//    }
//}
//
//struct DeviceInfoView: View { // No changes needed
//     let device: Device?
//     // ... existing code ...
//    var body: some View {
//         HStack {
//            Spacer() // Push to center alignment (or adjust as needed)
//            Image(systemName: deviceIcon(type: device?.type))
//            Text(device?.name ?? "Unknown Device")
//            if let volume = device?.volumePercent, device?.supportsVolume ?? false {
//                 // Optionally show volume if supported
//                 Text("(\(volume)%)")
//            }
//            Spacer()
//        }
//        .font(.caption)
//        .foregroundColor(.secondary) // Less prominent text
//        .padding(.top, 5) // Add some space above device info
//    }
//}
//
//// MARK: - Preview
//struct CurrentlyPlayingView_Previews: PreviewProvider {
//    static var previews: some View {
//        CurrentlyPlayingView() // Will use the initial mock data from MockData.getInitialData()
//             .preferredColorScheme(.dark) // Example: Dark mode preview
//
//         CurrentlyPlayingView(currentlyPlayingData: nil) // Preview empty state
//             .preferredColorScheme(.light)
//    }
//}
//
//// MARK: - Helper functions (formatTime, deviceIcon) - Ensure these are available
//// Add the Codable structs (CurrentlyPlayingResponse, Device, etc.) from the previous response here.
