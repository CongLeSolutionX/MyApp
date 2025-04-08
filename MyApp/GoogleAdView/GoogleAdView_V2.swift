//
//  GoogleAdView_V2.swift
//  MyApp
//
//  Created by Cong Le on 4/8/25.
//

import SwiftUI
import SafariServices // Needed for SFSafariViewController

// MARK: - Main Ad View (Stateful)

struct GoogleAdViewFunctional: View {
    // Environment variable to dismiss the view (e.g., in a sheet or navigation)
    @Environment(\.dismiss) var dismiss

    // --- State Variables ---
    @State private var isPlaying: Bool = true          // Simulate playback state
    @State private var currentTime: Double = 2.0      // Start time in seconds (mock)
    @State private var totalDuration: Double = 17.0   // Total duration in seconds (mock)
    @State private var progress: Double = 0.0         // Progress (0.0 to 1.0) - derived
    @State private var isDraggingSlider: Bool = false // To pause timer during drag

    @State private var showOptionsSheet: Bool = false // For ellipsis menu
    @State private var showWebView: Bool = false      // For "Learn More" CTA

    // Mock Data
    private let advertiserURL = URL(string: "https://www.example.com/artisan-market-offer")! // Mock URL for CTA

    // Timer for automatic progress
    // NB: Use Publisher for timers in more complex apps for better lifecycle management
    @State private var timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // 1. Top Bar - Pass dismiss and options actions
                TopBarView(
                    dismissAction: { dismiss() },
                    showOptionsAction: { showOptionsSheet = true }
                )
                .padding(.horizontal)
                .padding(.top, 5)
                .padding(.bottom, 10)

                // 2. Video Player Placeholder - Show play/pause state
                VideoPlayerPlaceholderView(isPlaying: isPlaying)
                    .aspectRatio(16/9, contentMode: .fit)

                // 3. Advertiser Info (Mostly Static)
                AdvertiserInfoView()
                    .padding(.horizontal)
                    .padding(.top, 15)

                // 4. Playback Controls - Pass state and actions
                PlaybackControlsView(
                    progress: $progress,
                    currentTime: $currentTime,
                    totalDuration: $totalDuration,
                    isPlaying: $isPlaying,
                    isDraggingSlider: $isDraggingSlider, // Pass dragging state
                    playPauseAction: togglePlayPause,
                    skipBackwardAction: skipBackward,
                    skipForwardAction: skipForward,
                    likeAction: { print("Action: Liked Ad") },    // Placeholder action
                    dislikeAction: { print("Action: Disliked Ad") } // Placeholder action
                )
                .padding(.horizontal)
                .padding(.vertical, 15)

                // 5. Call to Action Bar - Pass action
                CtaBarView(learnMoreAction: { showWebView = true } )
                    .padding(.horizontal)
                    .padding(.bottom, 20)

                Spacer()
            }
            .foregroundColor(.white)
        }
        .onAppear(perform: setupInitialProgress) // Set initial progress value
        // Timer logic
        .onReceive(timer) { _ in
            guard isPlaying, !isDraggingSlider, totalDuration > 0 else { return } // Only advance if playing and not dragging
            let newTime = currentTime + 0.1
            if newTime >= totalDuration {
                currentTime = totalDuration
                progress = 1.0
                isPlaying = false // Stop playback at the end
                // Stop the timer if needed (or let it run idly)
                // self.timer.upstream.connect().cancel()
            } else {
                currentTime = newTime
                progress = currentTime / totalDuration
            }
        }
         // Stop timer when view disappears to prevent leaks
        .onDisappear {
             self.timer.upstream.connect().cancel()
        }
        // Sheet for ellipsis options
        .actionSheet(isPresented: $showOptionsSheet) {
            ActionSheet(
                title: Text("Ad Options"),
                message: Text("What would you like to do?"),
                buttons: [
                    .default(Text("Stop seeing this ad")) { print("Action: Stop Seeing Ad") },
                    .default(Text("Why this ad?")) { print("Action: Why This Ad?") },
                    .destructive(Text("Report ad")) { print("Action: Report Ad") },
                    .cancel()
                ]
            )
        }
        // Sheet for "Learn More" CTA using SFSafariViewController
        .sheet(isPresented: $showWebView) {
            // Present the Safari view controller
            SafariView(url: advertiserURL)
                // Optional: Add presentation detents if needed
                // .presentationDetents([.medium, .large])
        }
    }

    // MARK: - Helper Functions
    private func setupInitialProgress() {
        // Ensure initial progress reflects initial time
        if totalDuration > 0 {
            progress = currentTime / totalDuration
        } else {
            progress = 0
        }
        // Initially cancel and reconnect timer to respect initial isPlaying state
        self.timer.upstream.connect().cancel()
        if isPlaying {
             self.timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
        }
    }

    private func togglePlayPause() {
        isPlaying.toggle()
        // Manage timer connection based on play state
        if isPlaying {
            // Reconnect timer only if needed (if it was cancelled)
            self.timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
        } else {
            // Stop the timer publisher immediately
             self.timer.upstream.connect().cancel()
        }
    }

    private func skipBackward() {
        guard totalDuration > 0 else { return }
        let newTime = max(0, currentTime - 5.0) // Skip back 5 seconds
        currentTime = newTime
        progress = currentTime / totalDuration
        print("Action: Skipped Backward to \(formatTime(seconds: currentTime))")
    }

    private func skipForward() {
        guard totalDuration > 0 else { return }
        let newTime = min(totalDuration, currentTime + 5.0) // Skip forward 5 seconds
        currentTime = newTime
        progress = currentTime / totalDuration
        // If skipping makes it end, update state
        if currentTime == totalDuration {
            isPlaying = false
            self.timer.upstream.connect().cancel()
        }
        print("Action: Skipped Forward to \(formatTime(seconds: currentTime))")
    }
}

// MARK: - Subviews (Updated with Actions/Bindings)

struct TopBarView: View {
    // Actions passed from parent
    var dismissAction: () -> Void
    var showOptionsAction: () -> Void

    var body: some View {
        HStack {
            Button(action: dismissAction) { // Make chevron a button
                Image(systemName: "chevron.down")
                    .font(.headline)
                    .contentShape(Rectangle()) // Increase tap area slightly
            }
            .buttonStyle(.plain) // Remove default button styling

            Text("Your music will continue after the break")
                .font(.caption)
                .lineLimit(1)

            Spacer()

            Button(action: showOptionsAction) { // Make ellipsis a button
                Image(systemName: "ellipsis")
                    .font(.headline)
                     .contentShape(Rectangle())
            }
             .buttonStyle(.plain)
        }
    }
}

struct VideoPlayerPlaceholderView: View {
    var isPlaying: Bool // Reflect playback state

    var body: some View {
        Color.secondary // Placeholder visual
            .overlay(
                // Show play/pause icon overlay based on state
                Image(systemName: isPlaying ? "" : "play.fill") // Show play icon when paused
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.white.opacity(0.7))
            )
             .overlay( // Simulate some content
                 Image(systemName: "photo.fill")
                     .resizable()
                     .scaledToFit()
                     .foregroundColor(.gray.opacity(0.3))
                     .padding(50)
             )
            .clipped()
             .animation(.easeInOut(duration: 0.2), value: isPlaying) // Animate icon change
    }
}

// AdvertiserInfoView remains mostly static - no changes needed for this example

struct PlaybackControlsView: View {
    // Bindings to parent state
    @Binding var progress: Double
    @Binding var currentTime: Double
    @Binding var totalDuration: Double
    @Binding var isPlaying: Bool
    @Binding var isDraggingSlider: Bool // Track slider interaction

    // Actions passed from parent
    var playPauseAction: () -> Void
    var skipBackwardAction: () -> Void
    var skipForwardAction: () -> Void
    var likeAction: () -> Void
    var dislikeAction: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            // Progress Bar and Time
            VStack(spacing: 4) {
                // Use SwiftUI Slider for built-in dragging
                Slider(
                    value: $progress,
                    in: 0...1,
                    onEditingChanged: sliderEditingChanged // Handle drag start/end
                )
                 .accentColor(.white) // Makes the track white
                 .tint(.gray.opacity(0.5)) // Fallback, though accentColor is primary

                HStack {
                    Text(formatTime(seconds: currentTime)) // Use formatted time
                        .font(.caption2)
                        .foregroundColor(.gray)
                    Spacer()
                    // Calculate remaining time correctly
                    Text("-\(formatTime(seconds: max(0, totalDuration - currentTime)))")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }

            // Control Buttons
            HStack(spacing: 25) {
                Button(action: dislikeAction) { Image(systemName: "hand.thumbsdown").font(.title2) }
                Button(action: skipBackwardAction) { Image(systemName: "backward.fill").font(.title2) }
                Button(action: playPauseAction) {
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill") // Dynamic icon
                        .font(.system(size: 44))
                }
                Button(action: skipForwardAction) { Image(systemName: "forward.fill").font(.title2) }
                Button(action: likeAction) { Image(systemName: "hand.thumbsup").font(.title2) }
            }
            .foregroundColor(.white) // Ensure buttons are visible
            .buttonStyle(.plain) // Consistent styling
        }
         // Update currentTime when slider value changes *after* dragging
         .onChange(of: progress) { newValue in
             if isDraggingSlider == false { // Only update if change wasn't from timer
                  // Handled by onEditingChanged(false) - Can be removed if logic is sound there
             }
         }
    }

    // Update state when slider dragging starts/ends
    private func sliderEditingChanged(editingStarted: Bool) {
        isDraggingSlider = editingStarted
        if !editingStarted {
            // Update actual currentTime when dragging finishes
            currentTime = progress * totalDuration
             // Resume timer if needed
            // The main view's onReceive will handle this naturally if isPlaying is true
            print("Slider drag ended. New time: \(currentTime)")
        } else {
             print("Slider drag started.")
             // Timer is already paused via onReceive check
        }
    }
}

// CtaBarView - Updated to use the action
struct CtaBarView: View {
    var learnMoreAction: () -> Void // Action passed from parent

    var body: some View {
        HStack {
            Text("Save 10% on your first grocery box delivery")
                .font(.subheadline)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            Spacer()

            Button("Learn more", action: learnMoreAction) // Use the passed action
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.black)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.white)
                .cornerRadius(20)
                .buttonStyle(.plain) // Ensure consistent styling
        }
    }
}

// MARK: - Helper: Time Formatter

func formatTime(seconds: Double) -> String {
    guard !seconds.isNaN, !seconds.isInfinite else { return "0:00" } // Handle invalid input
    let totalSeconds = Int(seconds.rounded(.down)) // Use Int for calculation
    let mins = totalSeconds / 60
    let secs = totalSeconds % 60
    return String(format: "%d:%02d", mins, secs)
}

// MARK: - Helper: Safari View Controller Wrapper

struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        let config = SFSafariViewController.Configuration()
        // config.entersReaderIfAvailable = true // Optional: Reader mode
        let vc = SFSafariViewController(url: url, configuration: config)
        return vc
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
        // No update needed for this simple case
    }
}

// MARK: - AdvertiserInfoView (Unchanged from previous example)

struct AdvertiserInfoView: View {
    var body: some View {
        HStack(spacing: 12) {
            Image("artisan-logo-placeholder")
                 .resizable()
                 .scaledToFit()
                 .frame(width: 40, height: 40)
                 .background(Color.teal)
                 .cornerRadius(4)
                 .overlay(
                    Text("Artisan")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(.white)
                 )

            VStack(alignment: .leading, spacing: 2) {
                Text("Artisan Market")
                    .font(.headline)
                Text("Advertisement")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()
        }
    }
}

// MARK: - Preview

struct GoogleAdViewFunctional_Previews: PreviewProvider {
    static var previews: some View {
        // Embed in a view that can present/dismiss if needed for testing dismiss action
        NavigationView { // Or Button showing a sheet
             GoogleAdViewFunctional()
                 .navigationBarHidden(true)
        }
         .preferredColorScheme(.dark) // Preview in dark mode
         // Ensure "artisan-logo-placeholder" exists in Assets
    }
}
