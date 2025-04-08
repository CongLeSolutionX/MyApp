//
//  AVPlayerView_V4.swift
//  MyApp
//
//  Created by Cong Le on 4/8/25.
//


// MARK: - Define Mock Data and Media Item Structure
import Foundation

// Represents the media content we are "playing"
struct MediaItem: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let artist: String
    let mockURL: URL // Simulate loading from a URL
    let mockDuration: TimeInterval // In seconds
    let mockThumbnailName: String // Name of an asset in your Assets catalog
}

// Sample data (Could fetch this from a network service in a real app)
struct MockDataService {
    static func fetchSampleMedia() -> MediaItem {
        // Simulate a plausible streaming URL
        let sampleURL = URL(string: "https://stream.example.com/path/to/media/master.m3u8")!

        return MediaItem(
            title: "The Optimistic Trail",
            artist: "Ambient Echoes",
            mockURL: sampleURL,
            mockDuration: 215.0, // 3 minutes 35 seconds
            mockThumbnailName: "placeholderImage" // Add an image named this to your Assets
        )
    }

    // Simulate different potential errors
    enum MockNetworkError: Error, LocalizedError {
        case serverUnreachable
        case invalidFormat
        case timeout
        case permissionDenied

        var errorDescription: String? {
            switch self {
            case .serverUnreachable: return "Cannot connect to the media server."
            case .invalidFormat: return "The media format is not supported."
            case .timeout: return "The connection timed out."
            case .permissionDenied: return "You don't have permission to access this content."
            }
        }
    }
}


// MARK: - Player State Enum
import SwiftUI // For Color

enum PlayerState: Equatable {
    case idle
    case loading(item: MediaItem) // Associate the item being loaded
    case readyToPlay(item: MediaItem)
    case playing(item: MediaItem)
    case paused(item: MediaItem)
    case finished(item: MediaItem)
    case failed(error: String) // Carry the error message

    // Computed property for status color
    var displayColor: Color {
        switch self {
        case .idle: return .gray
        case .loading: return .orange
        case .readyToPlay: return .blue
        case .playing: return .green
        case .paused: return .orange
        case .finished: return .purple // Changed color for finished
        case .failed: return .red
        }
    }

    // Computed property for user-facing status string
    var statusString: String {
        switch self {
        case .idle: return "Idle"
        case .loading: return "Loading..."
        case .readyToPlay: return "Ready"
        case .playing: return "Playing"
        case .paused: return "Paused"
        case .finished: return "Finished"
        case .failed(let error): return "Failed: \(error.prefix(50))..." // Show truncated error
        }
    }

    // Helper to check if playing
    var isPlaying: Bool {
        if case .playing = self { return true }
        return false
    }

    // Helper to get the current item (if applicable)
    var currentItem: MediaItem? {
        switch self {
        case .loading(let item), .readyToPlay(let item), .playing(let item), .paused(let item), .finished(let item):
            return item
        case .idle, .failed:
            return nil
        }
    }

    // Determine if seeking is allowed
    var canScrub: Bool {
        switch self {
        case .readyToPlay, .playing, .paused, .finished:
            return true
        default:
            return false
        }
    }

    // Determine if play/pause interaction is allowed
    var canPlayPause: Bool {
         switch self {
         case .readyToPlay, .playing, .paused, .finished:
             return true
         default:
             return false
         }
     }
}

// MARK: - PlayerViewModel
import Combine // For Timer
import SwiftUI // For Color, etc.

@MainActor // Ensure UI updates happen on the main thread
class PlayerViewModel: ObservableObject {

    // MARK: - Published Properties (State for the View)
    @Published private(set) var playerState: PlayerState = .idle
    @Published private(set) var currentTime: TimeInterval = 0.0
    @Published var playbackProgress: Double = 0.0 // Needs to be settable by Slider binding
    @Published private(set) var logs: [LogEntry] = [] // Use a struct for better log management
    @Published private(set) var currentMediaItem: MediaItem? = nil // Convenience for UI

    // MARK: - Private Properties
    private var playbackTimer: Timer?
    private var totalDuration: TimeInterval = 0.0 // Internal storage for duration

    // MARK: - Initialization
    init() {
        addLog(message: "ViewModel Initialized.", level: .info)
        // Automatically load media on init (optional)
        // Task { await loadMedia() }
    }

    // MARK: - Public Actions (Called by the View)

    /// Simulates loading media from a (mock) URL.
    func loadMedia() async {
        guard playerState == .idle || playerState == .finished || playerState == .failed else {
            addLog(message: "Load requested in invalid state: \(playerState)", level: .warning)
            return
        }

        let itemToLoad = MockDataService.fetchSampleMedia()
        playerState = .loading(item: itemToLoad)
        currentMediaItem = itemToLoad // Update convenience property
        resetPlayback()
        addLog(message: "Loading media: \(itemToLoad.title)", level: .info)

        do {
            // Simulate network delay (1 to 3 seconds)
            try await Task.sleep(nanoseconds: UInt64.random(in: 1...3) * 1_000_000_000)

            // Simulate potential network errors randomly
            let shouldFail = Double.random(in: 0..<1) < 0.15 // 15% chance of failure
            if shouldFail {
                // Simulate different errors
                let randomError: MockDataService.MockNetworkError
                switch Int.random(in: 0..<4) {
                case 0: randomError = .serverUnreachable
                case 1: randomError = .invalidFormat
                case 2: randomError = .timeout
                default: randomError = .permissionDenied
                }
                throw randomError
            }

            // Success: Update state to Ready
            guard playerState == .loading(item: itemToLoad) else {
                 addLog(message: "Loading cancelled or state changed during load.", level: .warning)
                 return // State changed while loading
            }

            totalDuration = itemToLoad.mockDuration
            playerState = .readyToPlay(item: itemToLoad)
            addLog(message: "Media ready: \(itemToLoad.title)", level: .info)

        } catch {
            // Failure: Update state to Failed
             guard playerState == .loading(item: itemToLoad) else {
                 addLog(message: "State changed during error handling of load.", level: .warning)
                 return // Avoid setting failed state if it was cancelled etc.
            }
            let errorMessage = (error as? LocalizedError)?.errorDescription ?? "An unknown error occurred during loading."
            playerState = .failed(error: errorMessage)
            addLog(message: "Loading failed: \(errorMessage)", level: .error)
             resetPlayback() // Clear progress on failure
        }
    }

    func play() {
        guard let currentItem = playerState.currentItem else {
             addLog(message: "Play attempted with no current item.", level: .warning)
             return
         }

        switch playerState {
        case .readyToPlay, .paused:
            playerState = .playing(item: currentItem)
            startTimer()
            addLog(message: "Playback started.", level: .info)
        case .finished:
             // Restart playback from beginning
             seek(toProgress: 0) // Seek first
             playerState = .playing(item: currentItem) // Then set state
             startTimer()
             addLog(message: "Playback restarted.", level: .info)
        case .playing:
            addLog(message: "Play called when already playing.", level: .debug)
            break // Already playing
        default:
            addLog(message: "Play called in invalid state: \(playerState)", level: .warning)
        }
    }

    func pause() {
        guard let currentItem = playerState.currentItem, playerState.isPlaying else {
            addLog(message: "Pause called in invalid state: \(playerState)", level: .warning)
            return
        }
        stopTimer()
        playerState = .paused(item: currentItem)
        addLog(message: "Playback paused.", level: .info)
    }

    func togglePlayPause() {
        if playerState.isPlaying {
            pause()
        } else {
            play()
        }
    }

    /// Seeks playback to a specific progress (0.0 to 1.0).
    func seek(toProgress progress: Double) {
        guard let currentItem = playerState.currentItem, playerState.canScrub else {
            addLog(message: "Seek attempted in invalid state: \(playerState)", level: .warning)
            return
        }
        guard totalDuration > 0 else { return } // Avoid division by zero

        stopTimer() // Stop timer during seek

        let clampedProgress = max(0.0, min(1.0, progress))
        let seekTime = clampedProgress * totalDuration
        currentTime = seekTime
        playbackProgress = clampedProgress // Update published progress

        addLog(message: "Seeked to \(formatTime(seekTime)) (\(String(format: "%.1f", clampedProgress * 100))%)", level: .debug)

        // Update state based on seek position
        if clampedProgress >= 1.0 {
            playerState = .finished(item: currentItem)
            addLog(message: "Seeked to end, state set to Finished", level: .debug)
        } else {
            // If previously finished or playing/paused, set to paused after seek
             if playerState == .finished(item: currentItem) || playerState == .playing(item: currentItem) || playerState == .paused(item: currentItem) {
                 playerState = .paused(item: currentItem)
                 addLog(message: "Seek finished, state set to Paused", level: .debug)
             }
             // If it was readyToPlay, keep it that way after seeking before start
             else if playerState == .readyToPlay(item: currentItem) {
                 // State remains readyToPlay
                 addLog(message: "Seek finished while Ready, state remains Ready", level: .debug)
             }
        }

        // Decide whether to restart timer automatically after seek
        // Common UX: Require user to press play again after manual seek.
        // If you want it to resume playing if it WAS playing before seek:
        // if wasPlayingBeforeSeek { startTimer() } // Need to track this
    }

    /// Called when slider editing starts or stops.
    func sliderEditingChanged(editingStarted: Bool) {
        if editingStarted {
            // Stop timer while scrubbing for smooth seeking
             if playerState.isPlaying { stopTimer() }
            addLog(message: "Slider scrubbing started.", level: .debug)
        } else {
            // User finished scrubbing, perform the seek
             seek(toProgress: playbackProgress) // Use the final value from the binding
            addLog(message: "Slider scrubbing ended.", level: .debug)
            // If you want auto-resume after scrubbing:
            // if playerState == .paused(item: ...) { /* and was playing before */ play() }
        }
    }


    func fetchAccessLog() {
        addLog(message: "--- Access Log Requested ---", level: .info)
        // Simulate fetching more realistic access log data
        guard let item = currentMediaItem else {
            addLog(message: "No media item loaded to generate access log.", level: .warning)
            return
        }
        let ip = "198.51.100. \(Int.random(in: 1...254))" // Random client IP
        let events = [
            "ts=\(timestamp()), event=CONNECT, url=\(item.mockURL), client_ip=\(ip)",
            "ts=\(timestamp()), event=MANIFEST_LOAD, url=\(item.mockURL), status=200, duration_ms=\(Int.random(in: 50...300))",
            "ts=\(timestamp()), event=SEGMENT_LOAD, url=\(item.mockURL.deletingLastPathComponent())/segment1.ts, status=200, duration_ms=\(Int.random(in: 100...1000)), bytes=\(Int.random(in: 500000...1500000))",
            // ... more segment loads ...
        ]
        events.forEach { addLog(message: $0, level: .access) }
        addLog(message: "--- Access Log End ---", level: .info)
    }

    func fetchErrorLog() {
         addLog(message: "--- Error Log Requested ---", level: .info)
        let errorLogs = logs.filter { $0.level == .error }
        if errorLogs.isEmpty {
            addLog(message: "No errors recorded in this session.", level: .info)
        } else {
            addLog(message: "Found \(errorLogs.count) error(s) in session:", level: .info)
            errorLogs.forEach { addLog(message: $0.message, level: .error) } // Re-log existing errors
        }
        // You could also simulate *new* rare errors appearing here
         addLog(message: "--- Error Log End ---", level: .info)
    }

    func clearLogs() {
        logs.removeAll()
        addLog(message: "UI Logs Cleared.", level: .info)
    }


    // MARK: - Private Helpers

    private func startTimer() {
        stopTimer() // Ensure no duplicates
        guard totalDuration > 0 else { return } // Don't start if duration is unknown

        playbackTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, self.playerState.isPlaying else {
                self?.stopTimer() // Stop if state changed unexpectedly
                return
            }

            let newTime = self.currentTime + 0.1
            if newTime >= self.totalDuration {
                self.currentTime = self.totalDuration
                self.playbackProgress = 1.0
                 if let item = self.playerState.currentItem {
                    self.playerState = .finished(item: item) // Update state
                 }
                 self.stopTimer() // Stop on finish
                 self.addLog(message: "Playback finished naturally.", level: .info)
            } else {
                self.currentTime = newTime
                self.playbackProgress = newTime / self.totalDuration
            }
        }
        // Add to common runloop mode to avoid pausing during UI interaction
        RunLoop.current.add(playbackTimer!, forMode: .common)
        addLog(message: "Playback timer started.", level: .debug)
    }

    private func stopTimer() {
        if playbackTimer != nil {
            playbackTimer?.invalidate()
            playbackTimer = nil
            addLog(message: "Playback timer stopped.", level: .debug)
        }
    }

    /// Resets time and progress, usually called when loading new media or on failure.
    private func resetPlayback() {
         stopTimer()
         currentTime = 0.0
         playbackProgress = 0.0
         totalDuration = 0.0 // Reset duration until loaded
     }

    // --- Logging ---
    struct LogEntry: Identifiable {
        let id = UUID()
        let timestamp: Date
        let message: String
        let level: LogLevel
    }

    enum LogLevel: String { case debug, info, warning, error, access }

    private func addLog(message: String, level: LogLevel) {
        let entry = LogEntry(timestamp: Date(), message: message, level: level)
        // Insert at the beginning for newest first
        logs.insert(entry, at: 0)
        // Limit log history (optional)
        if logs.count > 200 {
            logs.removeLast()
        }
    }

    // --- Formatting ---

    func formatTime(_ totalSeconds: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = totalDuration >= 3600 ? [.hour, .minute, .second] : [.minute, .second] // Show hours if needed
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: totalSeconds) ?? "00:00"
    }

    private func timestamp() -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.string(from: Date())
    }

    // Cleanup
    deinit {
        stopTimer()
        addLog(message: "ViewModel Deinitialized.", level: .debug)
    }
}


// MARK: - The ContentView (View Layer)
import SwiftUI

struct AVPlayerView: View {

    // Observe the ViewModel
    @StateObject private var viewModel = PlayerViewModel()

    // Computed properties for cleaner binding/display
    private var currentItem: MediaItem? { viewModel.currentMediaItem }
    private var playerState: PlayerState { viewModel.playerState }
    private var currentTimeString: String { viewModel.formatTime(viewModel.currentTime) }
    private var totalTimeString: String { viewModel.formatTime(currentItem?.mockDuration ?? 0) }
    private var playerStatusString: String { playerState.statusString }
    private var statusColor: Color { playerState.displayColor }
    private var canScrub: Bool { playerState.canScrub }
    private var canPlayPause: Bool { playerState.canPlayPause }
    private var isPlaying: Bool { playerState.isPlaying }

    var body: some View {
        VStack(spacing: 0) {

            // 1. Title Area (Shows current item title)
            Text(currentItem?.title ?? "AVPlayerItem Demo")
                .font(.title2) // Slightly smaller title
                .fontWeight(.semibold)
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .id("Title_\(currentItem?.id.uuidString ?? "None")") // Change ID to force update

            // 2. Player Placeholder View
            playerAreaView()
                .frame(height: 200) // Maintain fixed height

            // 3. Player Info (Artist, Status)
            playerInfoView()
                 .padding(.horizontal)
                 .padding(.top, 12)


            // 4. Controls and Timing
            playerControlsView()
                .padding(.horizontal)
                .padding(.vertical, 8) // Reduced vertical padding

            // 5. Progress Slider
             Slider(value: $viewModel.playbackProgress, in: 0...1, onEditingChanged: viewModel.sliderEditingChanged)
                 .disabled(!canScrub)
                 .accentColor(statusColor)
                 .padding(.horizontal)
                 .padding(.bottom, 12)


            Divider()

            // 6. Logs Section
             logsView()
                .padding(.horizontal)
                .padding(.top, 15)


            Spacer() // Pushes content to the top
        }
        .background(Color(.systemGroupedBackground))
        .task { // Use .task for async work tied to the view lifecycle
           await viewModel.loadMedia()
        }
        // Add subtle haptic feedback on button taps
        .sensoryFeedback(.impact(weight: .light), trigger: viewModel.playerState)
    }

    // MARK: - Subviews for Organization

    @ViewBuilder
    private func playerAreaView() -> some View {
        ZStack {
            // Background
            Rectangle()
                .fill(Color.black.opacity(0.9)) // Slightly less intense black

            // Content based on state
            switch playerState {
            case .idle:
                 VStack {
                    Image(systemName: "play.rectangle.fill")
                        .resizable().scaledToFit().frame(width: 50, height: 50)
                        .foregroundColor(.gray.opacity(0.6))
                    Text("Tap to Load Media")
                         .font(.caption)
                         .foregroundColor(.gray)
                         .padding(.top, 4)
                 }
                 .onTapGesture {
                     Task { await viewModel.loadMedia() }
                 }

            case .loading(let item):
                VStack(spacing: 8) {
                     ProgressView().tint(.white).scaleEffect(1.5)
                     Text("Loading \(item.title)...").font(.caption).foregroundColor(.gray)
                }


            case .readyToPlay(let item), .playing(let item), .paused(let item), .finished(let item):
                 // Show thumbnail (replace "placeholderImage" with actual asset name)
                 Image(item.mockThumbnailName) // Assumes asset exists
                    .resizable()
                    .aspectRatio(contentMode: .fill) // Fill the area
                    .clipped() // Clip excess
                    .opacity(isPlaying ? 1.0 : 0.6) // Dim when paused/finished
                    .blur(radius: playerState == .finished ? 3 : 0) // Blur when finished
                    .overlay(playerOverlayView(item: item)) // Add play/replay icon overlay
                     .animation(.easeInOut, value: isPlaying)
                     .animation(.easeInOut, value: playerState)


            case .failed(let error):
                VStack(spacing: 8) {
                    Image(systemName: "xmark.octagon.fill")
                        .resizable().scaledToFit().frame(width: 40, height: 40)
                        .foregroundColor(.red.opacity(0.8))
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                     Button("Retry Load") {
                         Task { await viewModel.loadMedia() }
                     }
                     .font(.caption)
                     .padding(.top, 5)
                     .tint(.blue) // Use tint for button color
                }
            }
        }
        .animation(.easeInOut, value: playerState) // Animate transitions between states
    }

    @ViewBuilder
    private func playerOverlayView(item: MediaItem) -> some View {
         // Overlay for play/pause/replay button on top of the thumbnail
         Color.black.opacity(0.2) // Subtle dark overlay for contrast
             .allowsHitTesting(false) // Don't block gestures to underlying image if needed


        // Centered Button
         Image(systemName: systemIconForOverlayState())
             .resizable()
             .scaledToFit()
             .frame(width: 40, height: 40)
             .foregroundColor(.white.opacity(0.8))
             .shadow(radius: 3)
             .padding(10)
             .background(.thinMaterial, in: Circle()) // Modern background
             .scaleEffect(playerState == .finished ? 1.1 : 1.0) // Slightly bigger replay icon
             .opacity(showOverlayIcon() ? 1.0 : 0.0) // Fade in/out
             .animation(.spring(), value: showOverlayIcon())
             .contentTransition(.symbolEffect(.replace)) // Animate icon changes
             .onTapGesture {
                 viewModel.togglePlayPause() // Action for the overlay button
              }


    }

     // Helper to decide if the central overlay icon should be shown
     func showOverlayIcon() -> Bool {
         switch playerState {
         case .readyToPlay, .paused, .finished:
             return true
         default:
             return false // Hide during loading, playing, idle, failed
         }
     }


     // Helper to get the correct system icon for the overlay button
     func systemIconForOverlayState() -> String {
         switch playerState {
         case .finished: return "gobackward" // Replay icon
         case .playing: return "pause.fill" // Should ideally not be shown if showOverlayIcon logic is correct
         default: return "play.fill" // Play icon for ready/paused
         }
     }



    @ViewBuilder
    private func playerInfoView() -> some View {
         VStack(alignment: .leading, spacing: 4) {
              // Artist Name
              Text(currentItem?.artist ?? " ") // Show empty space if no artist
                 .font(.subheadline)
                 .foregroundColor(.secondary)
                 .lineLimit(1)

             // Status Label
             HStack {
                 Text("Status:")
                     .font(.caption.weight(.medium))
                     .foregroundColor(.secondary)
                 Text(playerStatusString)
                     .font(.caption.weight(.bold))
                     .foregroundColor(statusColor)
                      // Animate changes smoothly
                     .animation(.easeInOut, value: playerStatusString)
             }
         }
         .frame(maxWidth: .infinity, alignment: .leading) // Ensure takes full width
    }


    @ViewBuilder
    private func playerControlsView() -> some View {
        HStack {
            Text(currentTimeString)
                .font(.caption)
                .monospacedDigit() // Ensures consistent spacing for numbers
                .foregroundColor(.secondary)

            Spacer()

            // Main Play/Pause Button (Larger, central)
            Button {
                 viewModel.togglePlayPause()
                 // Add haptic feedback specifically for this main button
                 triggerHapticFeedback()
            } label: {
                 Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                     .resizable().scaledToFit().frame(width: 28, height: 28) // Larger icon
                     .contentTransition(.symbolEffect(.replace)) // Nice animation
                     .animation(.spring(), value: isPlaying) // Spring animation for play/pause
             }
             .disabled(!canPlayPause)
             .buttonStyle(.plain) // Remove default button styling for custom look
             .foregroundColor(canPlayPause ? .primary : .gray) // Dynamic color


             // Add Skip Forward/Backward Buttons (Optional)
             /*
             Button { viewModel.seekRelative(by: -15) } label: { // Example: Need seekRelative in VM
                  Image(systemName: "gobackward.15")
                      .font(.title2)
             }
             .disabled(!canScrub)
             .padding(.leading, 20)


             Button { viewModel.seekRelative(by: 15) } label: { // Example: Need seekRelative in VM
                  Image(systemName: "goforward.15")
                      .font(.title2)
             }
             .disabled(!canScrub)
             .padding(.trailing, 20)
             */


            Spacer()

            Text(totalTimeString)
                .font(.caption)
                .monospacedDigit()
                .foregroundColor(.secondary)
        }
    }

    @ViewBuilder
     private func logsView() -> some View {
         VStack(alignment: .leading, spacing: 10) { // Reduced spacing
             Text("LOGS")
                 .font(.caption.weight(.bold)) // Smaller log title
                 .foregroundColor(.secondary)
                 .frame(maxWidth: .infinity, alignment: .leading)

             // Action Buttons (Condensed)
             HStack {
                 Button("Access Log") { viewModel.fetchAccessLog() }
                      .buttonStyle(LogButtonStyle(color: .blue))
                 Button("Error Log") { viewModel.fetchErrorLog() }
                      .buttonStyle(LogButtonStyle(color: .orange)) // Changed color
                 Spacer() // Push clear button to the right
                 Button("Clear") { viewModel.clearLogs() }
                      .buttonStyle(LogButtonStyle(color: .pink.opacity(0.8)))
             }

             // Log Output Area
             List { // Use List for better performance with many logs
                  ForEach(viewModel.logs) { entry in
                      HStack {
                          Text("[\(entry.level.rawValue.uppercased())]")
                               .font(.system(size: 9, weight: .bold, design: .monospaced))
                               .foregroundColor(logLevelColor(entry.level))
                          Text(entry.timestamp, style: .time) // Just show time
                               .font(.system(size: 9, design: .monospaced))
                               .foregroundColor(.gray)
                          Text(entry.message)
                               .font(.system(size: 10, design: .monospaced)) // Smaller log text
                               .lineLimit(2) // Limit lines shown per entry
                      }
                      .listRowInsets(EdgeInsets(top: 2, leading: 0, bottom: 2, trailing: 0)) // Compact rows
                      .listRowSeparator(.hidden) // Hide default separators
                  }
             }
             .listStyle(.plain) // Simple list style
             .frame(height: 150)
             .background(Color(.secondarySystemBackground)) // Subtle background
             .cornerRadius(6)
             .overlay(
                 RoundedRectangle(cornerRadius: 6)
                     .stroke(Color.gray.opacity(0.2), lineWidth: 1)
             )
         }
     }


     // Helper to get color for log levels
     func logLevelColor(_ level: PlayerViewModel.LogLevel) -> Color {
         switch level {
         case .debug: return .gray
         case .info: return .blue
         case .warning: return .orange
         case .error: return .red
         case .access: return .purple
         }
     }


     // Helper to trigger haptic feedback
     func triggerHapticFeedback() {
         let impact = UIImpactFeedbackGenerator(style: .medium)
         impact.impactOccurred()
     }

}

// MARK: - Custom Button Style for Logs
struct LogButtonStyle: ButtonStyle {
    var color: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 11, weight: .medium)) // Smaller log buttons
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .foregroundColor(.white)
            .background(color)
            .clipShape(Capsule()) // Use Capsule shape
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}


// MARK: - Preview Provider
struct AVPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        AVPlayerView()
            .preferredColorScheme(.dark) // Preview in dark mode
        AVPlayerView()
            .preferredColorScheme(.light) // Preview in light mode
    }
}

// Remember to add an image named "placeholderImage" to your Assets.xcassets
