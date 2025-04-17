////
////  V3.swift
////  MyApp
////
////  Created by Cong Le on 4/8/25.
////
//
//import SwiftUI
//import AVKit // Import AVKit for AVPlayerViewController
//import SafariServices
//
//// MARK: - Main Ad View (Stateful with AVPlayer)
//
//struct GoogleAdViewFunctionalVideo: View {
//    @Environment(\.dismiss) var dismiss
//    
//    // --- Player State ---
//    @State private var player: AVPlayer? // The actual AVPlayer instance
//    // Sample Video URLs (HTTPS preferred)
//    // Big Buck Bunny (Creative Commons): H.264/MP4
//    private let sampleVideoURL = URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!
//    // Sintel (Creative Commons): H.264/MP4
//    // private let sampleVideoURL = URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4")!
//    
//    // --- UI & Timing State ---
//    @State private var isPlaying: Bool = true       // User's intent to play/pause
//    @State private var currentTime: Double = 0.0   // Current playback time in seconds
//    @State private var totalDuration: Double = 0.0 // Total video duration in seconds
//    @State private var progress: Double = 0.0      // Derived progress (0.0 to 1.0)
//    @State private var isSeeking: Bool = false    // To prevent observer updates during seek
//    @State private var isPlayerReady: Bool = false // Tracks if the player item is ready
//    
//    @State private var showOptionsSheet: Bool = false
//    @State private var showWebView: Bool = false
//    private let advertiserURL = URL(string: "https://www.example.com/artisan-market-offer")!
//    
//    // Observer for player time updates
//    @State private var timeObserverToken: Any?
//    
//    var body: some View {
//        ZStack {
//            Color.black
//                .ignoresSafeArea()
//            
//            VStack(spacing: 0) {
//                // 1. Top Bar
//                TopBarView(
//                    dismissAction: {
//                        cleanupPlayer() // Ensure player stops on dismiss
//                        dismiss()
//                    },
//                    showOptionsAction: { showOptionsSheet = true }
//                )
//                .padding(.horizontal)
//                .padding(.top, 5)
//                .padding(.bottom, 10)
//                
//                // 2. Video Player View
//                VideoPlayerView(url: sampleVideoURL, player: $player)
//                    .aspectRatio(16/9, contentMode: .fit)
//                // Show loading indicator until ready
//                    .overlay(
//                        Group {
//                            if !isPlayerReady {
//                                ProgressView() // Loading spinner
//                                    .controlSize(.large) // Or .regular
//                                    .tint(.white) // Make spinner white
//                            }
//                        }
//                    )
//                
//                // 3. Advertiser Info
//                AdvertiserInfoView()
//                    .padding(.horizontal)
//                    .padding(.top, 15)
//                
//                // 4. Playback Controls
//                PlaybackControlsView(
//                    progress: $progress,
//                    currentTime: $currentTime,
//                    totalDuration: $totalDuration,
//                    isPlaying: $isPlaying,
//                    isDraggingSlider: $isSeeking, // Use isSeeking for slider state
//                    isPlayerReady: isPlayerReady, // Pass player readiness
//                    playPauseAction: togglePlayPause,
//                    skipBackwardAction: skipBackward,
//                    skipForwardAction: skipForward,
//                    likeAction: { print("Action: Liked Ad") },
//                    dislikeAction: { print("Action: Disliked Ad") }
//                )
//                .padding(.horizontal)
//                .padding(.vertical, 15)
//                // Disable controls slightly if player isn't ready
//                .opacity(isPlayerReady ? 1.0 : 0.7)
//                .disabled(!isPlayerReady)
//                
//                // 5. Call to Action Bar
//                CtaBarView(learnMoreAction: {
//                    player?.pause() // Pause video when opening web view
//                    isPlaying = false
//                    showWebView = true
//                } )
//                .padding(.horizontal)
//                .padding(.bottom, 20)
//                
//                Spacer()
//            }
//            .foregroundColor(.white) // Default text color
//        }
//        .onAppear(perform: setupPlayer)
//        .onDisappear(perform: cleanupPlayer)
//        // --- KVO Observer for Player Status ---
//        // Using onChange is simpler than traditional KVO for status checks in SwiftUI
//        .onChange(of: player?.currentItem?.status) {
//            let newStatus = player?.currentItem?.status
//            handlePlayerStatusChange(status: newStatus)
//        }
//        // --- Handle Slider Value Changes ---
//        .onChange(of: progress) {
//            guard isSeeking else { return } // Only react to slider drag changes here
//            seekPlayerToProgress(progress)
//        }
//        // Sheet for ellipsis options
//        .actionSheet(isPresented: $showOptionsSheet) {
//            ActionSheet(
//                title: Text("Ad Options"),
//                message: Text("What would you like to do?"),
//                buttons: [
//                    .default(Text("Stop seeing this ad")) { print("Action: Stop Seeing Ad") },
//                    .default(Text("Why this ad?")) { print("Action: Why This Ad?") },
//                    .destructive(Text("Report ad")) { print("Action: Report Ad") },
//                    .cancel()
//                ]
//            )
//        }
//        // Sheet for "Learn More" CTA using SFSafariViewController
//        .sheet(isPresented: $showWebView) {
//            SafariView(url: advertiserURL)
//        }
//    }
//    
//    // MARK: - Player Setup & Control
//    private func setupPlayer() {
//        // Player instance is created by VideoPlayerView's makeUIViewController
//        // We just need to wait for the binding to update $player
//        
//        // Add periodic time observer *after* player is potentially set
//        // Using a slight delay or checking if player is non-nil
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//            guard let player = player else { return }
//            
//            // Get initial duration if already available (might need KVO)
//            updateDuration(player: player)
//            
//            // Ensure initial state is set
//            if isPlaying {
//                player.play()
//            } else {
//                player.pause()
//            }
//            addTimeObserver(player: player)
//        }
//    }
//    
//    private func handlePlayerStatusChange(status: AVPlayerItem.Status?) {
//        switch status {
//        case .readyToPlay:
//            print("Player Ready to Play")
//            isPlayerReady = true
//            updateDuration(player: player!) // Update duration once ready
//            // Sync isPlaying state with player rate in case it changed during load
//            isPlaying = (player?.rate ?? 0) > 0
//            if isPlaying {
//                player?.play() // Ensure playback starts if intended
//            }
//        case .failed:
//            print("Player Failed: \(player?.currentItem?.error?.localizedDescription ?? "Unknown error")")
//            isPlayerReady = false
//            // Handle error state in UI (e.g., show error message)
//        case .unknown:
//            print("Player status unknown")
//            isPlayerReady = false
//        case .none:
//            print("No player item")
//            isPlayerReady = false
//        case .some(_):
//            print("Player have status of some")
//            isPlayerReady = false
//        }
//    }
//    
//    private func addTimeObserver(player: AVPlayer) {
//        // Remove existing observer if any
//        removeTimeObserver()
//        
//        // Observe time periodically
//        let interval = CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
//        timeObserverToken = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak player] time in
//            guard let player = player, !isSeeking else { return } // Don't update during seek
//            
//            let timeSeconds = CMTimeGetSeconds(time)
//            let durationSeconds = totalDuration // Use the stored duration
//            
//            if durationSeconds.isFinite && durationSeconds > 0 {
//                self.currentTime = timeSeconds
//                self.progress = durationSeconds == 0 ? 0 : timeSeconds / durationSeconds
//                
//                // Check if playback finished
//                if timeSeconds >= durationSeconds - 0.1 { // Add tolerance
//                    self.isPlaying = false
//                    self.progress = 1.0 // Ensure progress hits 100%
//                    self.currentTime = durationSeconds // Cap current time
//                    player.pause()
//                    player.seek(to: .zero) // Optional: Reset to beginning
//                    print("Playback Finished")
//                }
//            }
//        }
//    }
//    
//    private func removeTimeObserver() {
//        if let token = timeObserverToken {
//            player?.removeTimeObserver(token)
//            timeObserverToken = nil
//        }
//    }
//    
//    private func cleanupPlayer() {
//        print("Cleaning up player...")
//        removeTimeObserver()
//        player?.pause()
//        player = nil // Release the player instance
//        isPlayerReady = false
//        isPlaying = false
//        currentTime = 0
//        progress = 0
//        totalDuration = 0
//    }
//    
//    private func updateDuration(player: AVPlayer) {
//        guard let duration = player.currentItem?.duration else { return }
//        let seconds = CMTimeGetSeconds(duration)
//        if seconds.isFinite && seconds > 0 {
//            self.totalDuration = seconds
//            print("Video duration set: \(self.totalDuration)")
//            // Update progress immediately if duration changes while playing/paused
//            self.progress = totalDuration == 0 ? 0 : currentTime / totalDuration
//        }
//    }
//    
//    // MARK: - Playback Actions
//    
//    private func togglePlayPause() {
//        guard isPlayerReady else { return }
//        isPlaying.toggle()
//        if isPlaying {
//            player?.play()
//            print("Action: Play")
//        } else {
//            player?.pause()
//            print("Action: Pause")
//        }
//    }
//    
//    private func skipBackward() {
//        guard isPlayerReady, totalDuration > 0 else { return }
//        let newTimeValue = max(0, currentTime - 5.0) // Skip back 5 seconds
//        let seekTime = CMTime(seconds: newTimeValue, preferredTimescale: 600) // Higher timescale for precision
//        seekPlayerAndUpdateState(to: seekTime, newTimeValue: newTimeValue)
//        print("Action: Skipped Backward to \(formatTime(seconds: newTimeValue))")
//    }
//    
//    private func skipForward() {
//        guard isPlayerReady, totalDuration > 0 else { return }
//        let newTimeValue = min(totalDuration, currentTime + 5.0) // Skip forward 5 seconds
//        let seekTime = CMTime(seconds: newTimeValue, preferredTimescale: 600)
//        seekPlayerAndUpdateState(to: seekTime, newTimeValue: newTimeValue)
//        print("Action: Skipped Forward to \(formatTime(seconds: newTimeValue))")
//    }
//    
//    private func seekPlayerToProgress(_ newProgress: Double) {
//        guard isPlayerReady, totalDuration > 0 else { return }
//        let newTimeValue = newProgress * totalDuration
//        let seekTime = CMTime(seconds: newTimeValue, preferredTimescale: 600)
//        
//        // Only seek if the change is significant enough to avoid jitter
//        if abs(CMTimeGetSeconds(player?.currentTime() ?? .zero) - newTimeValue) > 0.1 {
//            seekPlayerAndUpdateState(to: seekTime, newTimeValue: newTimeValue)
//        }
//    }
//    
//    // Helper to seek and update UI state, avoiding observer interference
//        private func seekPlayerAndUpdateState(to time: CMTime, newTimeValue: Double) {
//             guard let player = player else { return }
//             isSeeking = true // Pause observer updates
//
//             // *** FIX: Remove [weak self] from the capture list ***
//             player.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero) { finished in
//                 DispatchQueue.main.async { // Ensure UI updates on main thread
//                    // No need for guard let self = self, self is implicitly captured
//                    guard finished else {
//                        // Re-enable observer if seek fails/cancelled
//                        // Note: 'self' is already accessible here
//                        self.isSeeking = false
//                        return
//                    }
//
//                    // *** FIX: Remove optional chaining '?' after self ***
//                    self.currentTime = newTimeValue
//                    self.progress = self.totalDuration == 0 ? 0 : newTimeValue / self.totalDuration
//                    self.isSeeking = false // Re-enable observer updates
//                    print("Seek finished. New time: \(newTimeValue)")
//                 }
//             }
//             // Update UI immediately for responsiveness (optional, seek completion block is safer)
//             // This part remains the same
//             self.currentTime = newTimeValue
//             self.progress = self.totalDuration == 0 ? 0 : newTimeValue / self.totalDuration
//        }
//}
//
//// MARK: - Video Player View (UIViewControllerRepresentable)
//
//struct VideoPlayerView: UIViewControllerRepresentable {
//    let url: URL?
//    @Binding var player: AVPlayer? // Pass player instance back up
//    
//    func makeUIViewController(context: Context) -> AVPlayerViewController {
//        let controller = AVPlayerViewController()
//        controller.showsPlaybackControls = false // Hide default controls
//        controller.videoGravity = .resizeAspect // Or .resizeAspectFill
//        
//        if let url = url {
//            let playerInstance = AVPlayer(url: url)
//            controller.player = playerInstance
//            // Update the binding *after* creating the player instance
//            DispatchQueue.main.async {
//                self.player = playerInstance
//            }
//        } else {
//            // Handle nil URL case if necessary (e.g., show error or different placeholder)
//            controller.player = nil
//            DispatchQueue.main.async {
//                self.player = nil
//            }
//        }
//        return controller
//    }
//    
//    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
//        // This is called when SwiftUI state changes.
//        // Basic implementation: If the URL changes, create a new player item.
//        // More robust: Check current URL vs new URL.
//        guard let currentItemURL = (uiViewController.player?.currentItem?.asset as? AVURLAsset)?.url else {
//            // If there's no current item or URL, and we have a new URL, set it up
//            if let newURL = url, uiViewController.player == nil || uiViewController.player?.currentItem == nil {
//                let playerInstance = AVPlayer(url: newURL)
//                uiViewController.player = playerInstance
//                // Update binding
//                DispatchQueue.main.async {
//                    self.player = playerInstance
//                }
//            }
//            return
//        }
//        
//        if currentItemURL != url {
//            if let newURL = url {
//                let newPlayerItem = AVPlayerItem(url: newURL)
//                uiViewController.player?.replaceCurrentItem(with: newPlayerItem)
//                // Update binding if player instance was replaced (less common here)
//                // If just replacing item, the player instance remains the same usually
//                print("Player item updated with new URL")
//            } else {
//                // Handle setting URL to nil (e.g., stop playback)
//                uiViewController.player?.replaceCurrentItem(with: nil)
//                print("Player item removed (URL is nil)")
//            }
//        }
//    }
//}
//
//// MARK: - Subviews
//struct TopBarView: View {
//    // Actions passed from parent
//    var dismissAction: () -> Void
//    var showOptionsAction: () -> Void
//    
//    var body: some View {
//        HStack {
//            Button(action: dismissAction) { // Make chevron a button
//                Image(systemName: "chevron.down")
//                    .font(.headline)
//                    .contentShape(Rectangle()) // Increase tap area slightly
//            }
//            .buttonStyle(.plain) // Remove default button styling
//            
//            Text("Your music will continue after the break")
//                .font(.caption)
//                .lineLimit(1)
//            
//            Spacer()
//            
//            Button(action: showOptionsAction) { // Make ellipsis a button
//                Image(systemName: "ellipsis")
//                    .font(.headline)
//                    .contentShape(Rectangle())
//            }
//            .buttonStyle(.plain)
//        }
//    }
//}
//
//
//// MARK: - AdvertiserInfoView
//
//struct AdvertiserInfoView: View {
//    var body: some View {
//        HStack(spacing: 12) {
//            Image("artisan-logo-placeholder")
//                .resizable()
//                .scaledToFit()
//                .frame(width: 40, height: 40)
//                .background(Color.teal)
//                .cornerRadius(4)
//                .overlay(
//                    Text("Artisan")
//                        .font(.system(size: 8, weight: .bold))
//                        .foregroundColor(.white)
//                )
//            
//            VStack(alignment: .leading, spacing: 2) {
//                Text("I Asked AI Bots")
//                    .font(.headline)
//                Text("CongLeSolutionX Advertisement")
//                    .font(.caption)
//                    .foregroundColor(.gray)
//            }
//            Spacer()
//        }
//    }
//}
//
//// CtaBarView - Updated to use the action
//struct CtaBarView: View {
//    var learnMoreAction: () -> Void // Action passed from parent
//    
//    var body: some View {
//        HStack {
//            Text("Save 10% on your first grocery box delivery")
//                .font(.subheadline)
//                .lineLimit(2)
//                .fixedSize(horizontal: false, vertical: true)
//            
//            Spacer()
//            
//            Button("Learn more", action: learnMoreAction) // Use the passed action
//                .font(.subheadline.weight(.semibold))
//                .foregroundColor(.black)
//                .padding(.horizontal, 16)
//                .padding(.vertical, 8)
//                .background(Color.white)
//                .cornerRadius(20)
//                .buttonStyle(.plain) // Ensure consistent styling
//        }
//    }
//}
//
//
//// MARK: - Subviews (Updated PlaybackControlsView)
//
//// TopBarView, AdvertiserInfoView, CtaBarView remain the same as the functional version
//
//struct PlaybackControlsView: View {
//    @Binding var progress: Double
//    @Binding var currentTime: Double
//    @Binding var totalDuration: Double
//    @Binding var isPlaying: Bool
//    @Binding var isDraggingSlider: Bool // Use the correct binding name
//    var isPlayerReady: Bool // Know if player is ready
//    
//    var playPauseAction: () -> Void
//    var skipBackwardAction: () -> Void
//    var skipForwardAction: () -> Void
//    var likeAction: () -> Void
//    var dislikeAction: () -> Void
//    
//    var body: some View {
//        VStack(spacing: 8) {
//            VStack(spacing: 4) {
//                Slider(
//                    value: $progress,
//                    in: 0...1,
//                    onEditingChanged: sliderEditingChanged
//                )
//                .accentColor(.white)
//                .tint(.gray.opacity(0.5))
//                .disabled(!isPlayerReady) // Disable slider if player not ready
//                
//                HStack {
//                    Text(formatTime(seconds: currentTime))
//                        .font(.caption2)
//                        .foregroundColor(.gray)
//                    Spacer()
//                    // Show total duration if ready, otherwise "--:--"
//                    Text(isPlayerReady ? "-\(formatTime(seconds: max(0, totalDuration - currentTime)))" : "--:--")
//                        .font(.caption2)
//                        .foregroundColor(.gray)
//                }
//            }
//            
//            HStack(spacing: 25) {
//                Button(action: dislikeAction) { Image(systemName: "hand.thumbsdown").font(.title2) }
//                Button(action: skipBackwardAction) { Image(systemName: "backward.fill").font(.title2) }
//                Button(action: playPauseAction) {
//                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
//                        .font(.system(size: 44))
//                }
//                Button(action: skipForwardAction) { Image(systemName: "forward.fill").font(.title2) }
//                Button(action: likeAction) { Image(systemName: "hand.thumbsup").font(.title2) }
//            }
//            .foregroundColor(.white)
//            .buttonStyle(.plain)
//            .disabled(!isPlayerReady) // Disable buttons if player not ready
//        }
//    }
//    
//    private func sliderEditingChanged(editingStarted: Bool) {
//        isDraggingSlider = editingStarted
//        if !editingStarted {
//            // Action to seek player is handled by the parent view's .onChange(of: progress)
//            // based on isDraggingSlider being false after the change.
//            print("Slider drag ended.")
//        } else {
//            print("Slider drag started.")
//            // Player observer updates are already paused via isSeeking flag in parent
//        }
//    }
//}
//
//// MARK: - Helpers (formatTime, SafariView)
//
//// formatTime function remains the same as before
//func formatTime(seconds: Double) -> String {
//    guard !seconds.isNaN, !seconds.isInfinite, seconds >= 0 else { return "0:00" }
//    let totalSeconds = Int(seconds.rounded(.down))
//    let mins = totalSeconds / 60
//    let secs = totalSeconds % 60
//    return String(format: "%d:%02d", mins, secs)
//}
//
//// SafariView struct remains the same as before
//struct SafariView: UIViewControllerRepresentable {
//    let url: URL
//    func makeUIViewController(context: Context) -> SFSafariViewController { SFSafariViewController(url: url) }
//    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
//}
//
//// MARK: - Preview
//
//struct GoogleAdViewFunctionalVideo_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//            GoogleAdViewFunctionalVideo()
//                .navigationBarHidden(true)
//        }
//        .preferredColorScheme(.dark)
//        // Ensure "artisan-logo-placeholder" exists in Assets
//    }
//}
