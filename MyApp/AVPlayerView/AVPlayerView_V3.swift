////
////  V3.swift
////  MyApp
////
////  Created by Cong Le on 4/8/25.
////
//
//import SwiftUI
//import Combine // Needed for Timer
//
//// MARK: - Player State Enum
//enum PlayerState: String {
//    case idle = "Idle"
//    case loading = "Loading..."
//    case readyToPlay = "Ready"
//    case playing = "Playing"
//    case paused = "Paused"
//    case finished = "Finished"
//    case failed = "Failed"
//
//    // Computed property for status color
//    var displayColor: Color {
//        switch self {
//        case .idle: return .gray
//        case .loading: return .orange
//        case .readyToPlay: return .blue
//        case .playing: return .green
//        case .paused: return .orange
//        case .finished: return .blue
//        case .failed: return .red
//        }
//    }
//}
//
//// MARK: - Main View
//struct AVPlayerView: View {
//
//    // MARK: - State Variables
//    @State private var playerState: PlayerState = .idle
//    @State private var currentTime: Double = 0.0 // Track time numerically
//    @State private var totalDuration: Double = 185.0 // Mock duration: 3 minutes 5 seconds
//    @State private var playbackProgress: Double = 0.0 // Normalized progress (0.0 to 1.0)
//    @State private var logs: String = ""
//    @State private var playbackTimer: Timer? // Timer for playback simulation
//
//    // Computed properties for display strings
//    private var currentTimeString: String { formatTime(currentTime) }
//    private var totalTimeString: String { formatTime(totalDuration) }
//    private var playerStatusString: String { playerState.rawValue }
//    private var statusColor: Color { playerState.displayColor }
//    private var isPlaying: Bool { playerState == .playing }
//
//    // MARK: - Body
//    var body: some View {
//        VStack(spacing: 0) {
//
//            // 1. Title Area
//            Text("AVPlayerItem Demo")
//                .font(.title)
//                .fontWeight(.bold)
//                .frame(maxWidth: .infinity, alignment: .leading)
//                .padding()
//
//            // 2. Player Placeholder View
//            ZStack { // Use ZStack to overlay loading indicator if needed
//                Rectangle()
//                    .fill(Color.black)
//                    .frame(height: 200)
//
//                if playerState == .loading {
//                    ProgressView() // Shows a loading spinner
//                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
//                        .scaleEffect(1.5)
//                } else if playerState == .failed {
//                    Image(systemName: "xmark.octagon.fill")
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 50, height: 50)
//                        .foregroundColor(.red.opacity(0.8))
//                }
//                 else if playerState == .idle || playerState == .finished {
//                     // Optionally show a replay icon when finished or placeholder
//                    Image(systemName: playerState == .finished ? "gobackward" : "play.rectangle.fill")
//                         .resizable()
//                         .scaledToFit()
//                         .frame(width: 50, height: 50)
//                         .foregroundColor(.gray.opacity(0.7))
//                         .onTapGesture {
//                             if playerState == .finished {
//                                 seek(to: 0) // Restart
//                                 play()
//                             } else if playerState == .idle {
//                                 // Simulate loading when tapping idle placeholder
//                                 loadMedia()
//                             }
//                         }
//                 }
//            }
//
//
//            // 3. Player Info and Controls Section
//            VStack(alignment: .leading, spacing: 10) { // Increased spacing slightly
//                // Status Label
//                HStack {
//                    Text("Status:")
//                        .font(.headline)
//                    Text(playerStatusString)
//                        .font(.headline)
//                        .foregroundColor(statusColor)
//                        .animation(.easeInOut, value: playerStatusString) // Animate status text changes
//                    Spacer()
//                }
//
//                // Playback Controls and Timing
//                HStack {
//                    Text(currentTimeString)
//                        .font(.caption)
//                        .monospacedDigit()
//
//                    Spacer()
//
//                    // Play/Pause Button
//                    Button {
//                        togglePlayPause()
//                    } label: {
//                        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: 25, height: 25)
//                            .contentTransition(.symbolEffect(.replace)) // Nice animation for icon change
//                    }
//                    .disabled(!canPlayPause()) // Disable if not ready, finished, or failed
//
//                    Spacer()
//
//                    Text(totalTimeString)
//                        .font(.caption)
//                        .monospacedDigit()
//                }
//
//                // Progress Slider
//                Slider(value: $playbackProgress, in: 0...1, onEditingChanged: sliderEditingChanged)
//                .disabled(playerState == .idle || playerState == .loading || playerState == .failed) // Disable slider when not applicable
//                .accentColor(statusColor) // Match slider color to status
//            }
//            .padding(.horizontal)
//            .padding(.vertical, 12)
//
//            Divider()
//
//            // 4. Logs Section
//            VStack(alignment: .leading, spacing: 15) { // Increased spacing
//                Text("LOGS")
//                    .font(.headline)
//                    .frame(maxWidth: .infinity, alignment: .leading)
//
//                // Action Buttons
//                HStack(spacing: 15) {
//                    Button("Fetch Access Log") { fetchAccessLog() }
//                        .buttonStyle(FilledButtonStyle(backgroundColor: .blue))
//
//                    Button("Fetch Error Log") { fetchErrorLog() }
//                        .buttonStyle(FilledButtonStyle(backgroundColor: .blue))
//
//                    Button("Clear UI Logs") { clearLogs() }
//                        .buttonStyle(FilledButtonStyle(backgroundColor: .pink.opacity(0.8)))
//                }
//                .frame(maxWidth: .infinity)
//
//                // Log Output Area
//                TextEditor(text: $logs)
//                    .font(.system(.caption, design: .monospaced)) // Slightly larger log font
//                    .frame(height: 150)
//                    .border(Color.gray.opacity(0.3), width: 1)
//                    .cornerRadius(4)
//                    .disabled(true) // Read-only
//
//            }
//            .padding()
//
//            Spacer()
//        }
//        .background(Color(.systemGroupedBackground))
//        .onAppear(perform: setupInitialState)
//        .onDisappear(perform: cleanupTimer)
//        // React to state changes to manage the timer
//        .onChange(of: playerState) { _, newState in
//             handleStateChange(newState: newState)
//        }
//        // Optional: Simulate loading on view appear
//        // .task { await loadMediaAsync() }
//    }
//
//    // MARK: - Helper & Simulation Methods
//
//    func setupInitialState() {
//        addLog(message: "View appeared. Player state: \(playerState.rawValue)", level: "INFO")
//        // Optionally trigger loading immediately
//         loadMedia()
//    }
//
//    func handleStateChange(newState: PlayerState) {
//        switch newState {
//        case .playing:
//            startTimer()
//        case .paused, .finished, .failed, .idle:
//            stopTimer()
//        case .loading, .readyToPlay:
//             // Timer might already be stopped or not started
//             stopTimer() // Ensure timer is stopped if we transition here unexpectedly
//             if newState == .readyToPlay {
//                 // Reset time if we just became ready (optional)
//                 // seek(to: 0)
//             }
//        }
//        addLog(message: "State changed to: \(newState.rawValue)", level: "STATE")
//    }
//
//    // --- Playback Simulation ---
//
//    func loadMedia() {
//        guard playerState == .idle || playerState == .finished || playerState == .failed else { return } // Allow loading from these states
//        playerState = .loading
//        seek(to: 0) // Reset time on load
//
//        // Simulate loading delay
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
//            // Simulate success or failure randomly
//            if Bool.random() || playerState != .loading { // Add check in case state changed during delay
//                playerState = .readyToPlay
//            } else {
//                playerState = .failed
//                addLog(message: "Simulated media loading failed.", level: "ERROR")
//            }
//        }
//    }
//
//    // Alternative async loading
//    // func loadMediaAsync() async {
//    //     guard playerState == .idle else { return }
//    //     playerState = .loading
//    //     seek(to: 0)
//    //     do {
//    //         try await Task.sleep(nanoseconds: 1_500_000_000) // Simulate 1.5 seconds load
//    //         playerState = .readyToPlay
//    //     } catch {
//    //         playerState = .failed
//    //          addLog(message: "Media loading task cancelled or failed.", level: "ERROR")
//    //     }
//    // }
//
//    func play() {
//        guard playerState == .readyToPlay || playerState == .paused || playerState == .finished else {
//            addLog(message: "Play() called in invalid state: \(playerState.rawValue)", level: "WARN")
//            return
//        }
//        // If finished, restart from beginning
//        if playerState == .finished {
//            seek(to: 0)
//        }
//        playerState = .playing
//    }
//
//    func pause() {
//        guard playerState == .playing else {
//            addLog(message: "Pause() called in invalid state: \(playerState.rawValue)", level: "WARN")
//            return
//        }
//        playerState = .paused
//    }
//
//    func togglePlayPause() {
//        if isPlaying {
//            pause()
//        } else {
//            play()
//        }
//    }
//
//    func canPlayPause() -> Bool {
//        switch playerState {
//        case .readyToPlay, .playing, .paused, .finished:
//            return true
//        default:
//            return false
//        }
//    }
//
//    func seek(to time: Double) {
//        let newTime = max(0, min(time, totalDuration)) // Clamp time within bounds
//        currentTime = newTime
//        playbackProgress = totalDuration > 0 ? (newTime / totalDuration) : 0
//        addLog(message: "Seeked to \(formatTime(newTime))", level: "DEBUG")
//
//         // If seeking makes the player finished, update state
//         if currentTime >= totalDuration && playerState != .finished {
//              playerState = .finished
//         } else if playerState == .finished && currentTime < totalDuration {
//             // If seeking backwards from finished state, make it paused or ready
//             playerState = .paused // Or .readyToPlay depending on desired UX
//         }
//    }
//
//    // --- Timer Management ---
//
//    func startTimer() {
//        stopTimer() // Ensure no duplicate timers
//        playbackTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) {_ in
//            //guard let self = self, self.playerState == .playing else { return }
//
//            let newTime = self.currentTime + 0.1
//            if newTime >= self.totalDuration {
//                self.currentTime = self.totalDuration
//                self.playbackProgress = 1.0
//                self.playerState = .finished // Update state to finished
//                 self.stopTimer() // Timer stops itself via state change, but explicit stop is safe
//            } else {
//                self.currentTime = newTime
//                self.playbackProgress = self.totalDuration > 0 ? (newTime / self.totalDuration) : 0
//            }
//        }
//         // Add to runloop common mode to avoid timer pausing during scroll etc.
//         RunLoop.current.add(playbackTimer!, forMode: .common)
//        addLog(message: "Playback timer started.", level: "DEBUG")
//    }
//
//    func stopTimer() {
//        if playbackTimer != nil {
//            playbackTimer?.invalidate()
//            playbackTimer = nil
//             addLog(message: "Playback timer stopped.", level: "DEBUG")
//        }
//    }
//
//    func cleanupTimer() {
//        stopTimer()
//    }
//
//    // --- Slider Interaction ---
//
//    func sliderEditingChanged(editingStarted: Bool) {
//        if editingStarted {
//            // If playing, temporarily pause while scrubbing
//            // if isPlaying { pause() } // Decide if you want this behavior
//            stopTimer() // Stop timer updates while user is dragging
//            addLog(message: "Slider scrubbing started.", level: "DEBUG")
//        } else {
//            // User finished scrubbing, calculate seek time
//            let seekTime = playbackProgress * totalDuration
//            seek(to: seekTime)
//            // Optionally resume playback if it was paused *due* to scrubbing
//            // For simplicity, we just let the user tap play again if needed.
//            // Or, if the state *before* seeking was playing, restart timer:
//             if playerState == .playing {
//                 startTimer() // Restart timer only if state is still playing after seek
//             }
//             addLog(message: "Slider scrubbing ended. Set time to \(formatTime(seekTime))", level: "DEBUG")
//        }
//    }
//
//    // --- Logging ---
//
//    func addLog(message: String, level: String) {
//        // Append to the beginning for newest first (optional)
//        logs = "[\(level)] \(getCurrentTimestamp()): \(message)\n" + logs
//        // Or append to the end:
//        // logs += "[\(level)] \(getCurrentTimestamp()): \(message)\n"
//    }
//
//    func getCurrentTimestamp() -> String {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "HH:mm:ss.SSS" // Hours:Minutes:Seconds.Milliseconds
//        return formatter.string(from: Date())
//    }
//
//    func fetchAccessLog() {
//        let mockEvents = [
//            "uri=master.m3u8, s-ip=192.168.1.100, cs-bytes=1024, sc-bytes=512000, duration=5.1",
//            "uri=segment1.ts, s-ip=192.168.1.100, cs-bytes=0, sc-bytes=1234567, duration=10.0",
//            "uri=segment2.ts, s-ip=192.168.1.100, cs-bytes=0, sc-bytes=987654, duration=9.8",
//        ]
//        addLog(message: "--- Access Log Start ---", level: "LOG")
//        for event in mockEvents {
//            addLog(message: event, level: "ACCESS")
//        }
//        addLog(message: "--- Access Log End ---", level: "LOG")
//    }
//
//    func fetchErrorLog() {
//        let mockErrors = [
//            "errorDomain=CoreMediaErrorDomain, errorCode=-12847, comment='Media segment processing error'", // Simulated error
//            "errorDomain=AVFoundationErrorDomain, errorCode=-11819, comment='Cannot Decode'",         // Simulated error
//        ]
//        addLog(message: "--- Error Log Start ---", level: "LOG")
//        if playerState == .failed || Bool.random() { // Maybe add a random error if not failed
//             let error = mockErrors.randomElement() ?? "Unknown simulated error"
//             addLog(message: error, level: "ERROR")
//        } else {
//            addLog(message: "No errors recorded in this session.", level: "INFO")
//        }
//        addLog(message: "--- Error Log End ---", level: "LOG")
//    }
//
//    func clearLogs() {
//        logs = ""
//        addLog(message: "UI Logs Cleared.", level: "INFO") // Add a confirmation log
//    }
//
//    // --- Formatting ---
//
//    func formatTime(_ totalSeconds: Double) -> String {
//        let formatter = DateComponentsFormatter()
//        formatter.allowedUnits = [.minute, .second]
//        formatter.unitsStyle = .positional
//        formatter.zeroFormattingBehavior = .pad // Ensure "0:05" becomes "00:05"
//        return formatter.string(from: TimeInterval(totalSeconds)) ?? "00:00"
//    }
//}
//
//// MARK: - Custom Button Style (Unchanged from previous)
//struct FilledButtonStyle: ButtonStyle {
//    var backgroundColor: Color
//
//    func makeBody(configuration: Configuration) -> some View {
//        configuration.label
//            .font(.caption.weight(.semibold))
//            .padding(.horizontal, 12)
//            .padding(.vertical, 8)
//            .foregroundColor(.white)
//            .background(backgroundColor)
//            .clipShape(RoundedRectangle(cornerRadius: 8))
//            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
//            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
//    }
//}
//
//// MARK: - Preview Provider
//struct AVPlayerView_Previews: PreviewProvider {
//    static var previews: some View {
//        AVPlayerView()
//    }
//}
