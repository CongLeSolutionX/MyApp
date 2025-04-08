//
//  MusicAdView_V3.swift
//  MyApp
//
//  Created by Cong Le on 4/8/25.
//

import SwiftUI
import Combine
import CoreHaptics // For feedback

// --- Enums & Data Structures ---
enum LikeState {
    case none, liked, disliked
}

struct Advertisment { // Simple struct for ad data
    let advertiserName: String
    let tagLine: String
    let callToAction: String
    let logoSystemName: String // Using SF Symbols for simplicity
    let logoBackgroundColor: Color
    let bannerBackgroundColor: Color
    let learnMoreURL: URL?
    let duration: Double
}

struct MusicTrack { // Simple struct for music data
    let title: String
    let artist: String
}

// --- Main Functional View Structure ---
struct FunctionalMusicAdView: View {

    // --- Sample Data ---
    // Ad Data (Replace with real data source if needed)
    let currentAd = Advertisment(
        advertiserName: "Cosmic Coffee Co.",
        tagLine: "CongLeSolutionX Advertisement",
        callToAction: "Taste the galaxy! Try our new Nebula Nectar blend.",
        logoSystemName: "cup.and.saucer.fill",
        logoBackgroundColor: Color(red: 0.1, green: 0.3, blue: 0.5), // Deep blue
        bannerBackgroundColor: Color(red: 0.2, green: 0.4, blue: 0.6), // Slightly lighter blue
        learnMoreURL: URL(string: "https://www.example-cosmic-coffee.com/nebula-nectar"),
        duration: 20.0 // Ad duration in seconds
    )

    // Next Song Data (Replace with real data source)
    let nextTrack = MusicTrack(title: "Starlight Serenade", artist: "The AstroBeats")

    // --- State Variables ---
    @State private var isPlaying: Bool = true
    @State private var currentTime: Double = 0.0
    @State private var likeState: LikeState = .none
    @State private var showAdOptionsSheet: Bool = false
    @State private var showLearnMoreSheet: Bool = false

    // --- Timer & Haptics ---
    @State private var timerSubscription: Cancellable?
    @State private var feedbackGenerator = UIImpactFeedbackGenerator(style: .light) // Haptic feedback

    // Computed Properties
    private var totalDuration: Double { currentAd.duration }
    private var adProgress: Double {
        guard totalDuration > 0 else { return 0 } // Avoid division by zero
        return min(max(currentTime / totalDuration, 0.0), 1.0)
    }
    private var remainingTime: Double {
        max(0, totalDuration - currentTime) // Ensure remaining time doesn't go negative
    }

    var body: some View {
        ZStack {
            // 1. Background Gradient
            LinearGradient(
                gradient: Gradient(colors: [Color(red: 0.1, green: 0.1, blue: 0.2), Color(red: 0.3, green: 0.2, blue: 0.4)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
            .accessibilityHidden(true)

            // 2. Foreground Content Layer
            VStack(spacing: 15) {
                // 2a. Top Bar (Info Text & More Options)
                 HStack {
                    VStack(alignment: .leading, spacing: 2) {
                         Text("Up Next:")
                             .font(.caption2)
                             .foregroundColor(.white.opacity(0.6))
                         Text("\(nextTrack.title) - \(nextTrack.artist)")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.white.opacity(0.9))
                            .lineLimit(1)
                     }
                    Spacer()
                    Button {
                        feedbackGenerator.impactOccurred()
                        showAdOptionsSheet = true
                        print("Action: Show ad options sheet")
                    } label: {
                        Image(systemName: "ellipsis")
                            .foregroundColor(.white.opacity(0.8))
                            .padding(5) // Increase tap area slightly
                    }
                    .accessibilityLabel("More ad options")
                }
                .padding(.horizontal)
                .padding(.top, 5)

                Spacer() // Pushes content down

                 // 2b. Advertisement Info Section
                HStack(spacing: 12) {
                    Image(systemName: currentAd.logoSystemName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 45, height: 45)
                        .padding(8) // Slightly more padding
                        .background(currentAd.logoBackgroundColor)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .shadow(radius: 3)
                        .accessibilityLabel("\(currentAd.advertiserName) logo")

                    VStack(alignment: .leading, spacing: 2) {
                        Text(currentAd.advertiserName)
                            .font(.headline)
                            .fontWeight(.semibold) // Slightly bolder
                            .foregroundColor(.white)
                        Text(currentAd.tagLine)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    Spacer()
                }
                .padding(.horizontal)

                // 2c. Progress Bar & Timers (Dynamic)
                VStack(spacing: 4) {
                    ProgressView(value: adProgress)
                        .progressViewStyle(LinearProgressViewStyle(tint: .white.opacity(0.9)))
                        .frame(height: 4) // Slightly thicker
                         .shadow(color: .black.opacity(0.2), radius: 1, y: 1)
                        .padding(.horizontal)
                        .accessibilityValue("\(Int(adProgress * 100)) percent complete")

                    HStack {
                        Text(formatTime(currentTime))
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.8))
                            .frame(width: 45, alignment: .leading) // Wider fixed width
                             .monospacedDigit() // Ensures stable width as time changes
                        Spacer()
                        Text("-\(formatTime(remainingTime))")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.8))
                            .frame(width: 45, alignment: .trailing) // Wider fixed width
                             .monospacedDigit()
                    }
                    .padding(.horizontal)
                }

                 // 2d. Playback Controls (Functional)
                HStack(spacing: 30) {
                    // Thumbs Down Button
                     Button { handleLikeDislike(.disliked) } label: {
                        Image(systemName: likeState == .disliked ? "hand.thumbsdown.fill" : "hand.thumbsdown")
                            .font(.title2)
                             .foregroundColor(likeState == .disliked ? .red : .white.opacity(0.9)) // Use red for dislike maybe?
                    }
                    .accessibilityLabel(likeState == .disliked ? "Disliked (Selected)" : "Dislike this ad")

                    // Backward Button (Functional Skip)
                    Button { skipBackward() } label: {
                        Image(systemName: "gobackward.5")
                            .font(.title2)
                    }
                     .disabled(currentTime < 1.0) // Disable if near start
                    .accessibilityLabel("Skip backward 5 seconds")

                    // Play/Pause Button
                    Button { togglePlayPause() } label: {
                        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 30))
                            .frame(width: 60, height: 60)
                            .background(Color.white.opacity(0.9))
                            .foregroundColor(.black)
                            .clipShape(Circle())
                             .shadow(radius: 4)
                    }
                    .accessibilityLabel(isPlaying ? "Pause ad" : "Play ad")

                    // Forward Button (Functional Skip)
                    Button { skipForward() } label: {
                        Image(systemName: "goforward.5")
                            .font(.title2)
                    }
                     .disabled(remainingTime < 1.0) // Disable if near end
                    .accessibilityLabel("Skip forward 5 seconds")

                     // Thumbs Up Button
                    Button { handleLikeDislike(.liked) } label: {
                        Image(systemName: likeState == .liked ? "hand.thumbsup.fill" : "hand.thumbsup")
                            .font(.title2)
                             .foregroundColor(likeState == .liked ? .green : .white.opacity(0.9)) // Use green for like maybe?
                    }
                    .accessibilityLabel(likeState == .liked ? "Liked (Selected)" : "Like this ad")

                }
                .foregroundColor(.white.opacity(0.9))
                 .padding(.vertical, 10)
                 .onChange(of: currentTime) {
                     // Update UI based on time if needed, e.g., enabling/disabling skip
                 }

                  Spacer().frame(height: 20)

                // 2e. Bottom Call-to-Action Banner (Functional)
                HStack {
                    Text(currentAd.callToAction)
                        .font(.footnote)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)

                    Spacer()

                    Button {
                        feedbackGenerator.impactOccurred()
                        showLearnMoreSheet = true
                         print("Action: Show Learn More sheet for \(currentAd.advertiserName)")
                    } label: {
                         Text("Learn more")
                            .font(.footnote)
                            .fontWeight(.bold)
                            .foregroundColor(currentAd.bannerBackgroundColor.opacity(0.9)) // Use ad color
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.white)
                            .clipShape(Capsule())
                             .shadow(radius: 2)
                    }
                      .accessibilityHint("Opens advertiser website or details")
                }
                .padding()
                .background(currentAd.bannerBackgroundColor)
                .cornerRadius(12)
                .padding(.horizontal)
                .padding(.bottom)

            } // End Main VStack
            .padding(.top, SafeAreaInsetsKey.defaultValue.top > 0 ? SafeAreaInsetsKey.defaultValue.top : 20) // Ensure some top padding even without safe area
            .padding(.bottom, SafeAreaInsetsKey.defaultValue.bottom)

        } // End ZStack
           .onAppear {
            prepareHaptics()
            startTimer() // Start timer when view appears
            print("FunctionalMusicAdView Appeared - Ad: \(currentAd.advertiserName)")
        }
        .onDisappear {
            stopTimer() // Stop timer when view disappears
            print("FunctionalMusicAdView Disappeared")
        }
        // --- Sheets ---
        .sheet(isPresented: $showAdOptionsSheet) {
            // Pass necessary info if needed, e.g., ad ID for reporting
             AdOptionsView()
        }
        .sheet(isPresented: $showLearnMoreSheet) {
            LearnMoreView(advertiserName: currentAd.advertiserName,
                          logoSystemName: currentAd.logoSystemName,
                          logoColor: currentAd.logoBackgroundColor,
                          url: currentAd.learnMoreURL)
                // Add presentation detents if you only want a partial sheet
                // .presentationDetents([.medium, .large])
        }
    }

    // --- Action Handlers ---

    func togglePlayPause() {
        feedbackGenerator.impactOccurred() // Haptic feedback
        isPlaying.toggle()
        if isPlaying {
             print("Action: Resume ad playback")
            startTimer() // Ensure timer restarts if paused
        } else {
             print("Action: Pause ad playback")
            // Timer pausing is handled within the timer's receive block check
        }
    }

    func handleLikeDislike(_ newStatus: LikeState) {
        feedbackGenerator.impactOccurred() // Haptic feedback
        let previousState = likeState
        if likeState == newStatus {
            likeState = .none // Toggle off if tapped again
            print("Simulating: Reset ad feedback (was \(newStatus))")
        } else {
            likeState = newStatus
            print("Simulating: Sending ad feedback to server - Status: \(newStatus)")
            // In a real app, make a network call here:
            // sendFeedbackToServer(adId: currentAd.id, status: newStatus)
        }
        // Optionally provide more feedback, e.g., a small animation
    }

    func skipForward() {
        guard remainingTime > 0.5 else { return } // Don't skip if already at the end
        feedbackGenerator.impactOccurred()
        let skipAmount = 5.0
        currentTime = min(totalDuration, currentTime + skipAmount)
         print("Action: Skip forward \(skipAmount) seconds. New time: \(currentTime)")
        // If paused, keep it paused, just update time
        // If playing, the timer will continue from the new time
         if !isPlaying {
              // Update progress manually if paused
              // Not strictly needed as progress is computed, but good for clarity
         }
    }

    func skipBackward() {
        guard currentTime > 0 else { return } // Don't skip if at the start
        feedbackGenerator.impactOccurred()
        let skipAmount = 5.0
        currentTime = max(0, currentTime - skipAmount)
         print("Action: Skip backward \(skipAmount) seconds. New time: \(currentTime)")
        // If paused, keep it paused
    }

    // --- Timer Management ---

    func startTimer() {
        // Avoid multiple timers
        stopTimer()
        // Start timer only if playing and not finished
        guard isPlaying, currentTime < totalDuration else { return }

        timerSubscription = Timer.publish(every: 0.1, tolerance: 0.05, on: .main, in: .common) // More frequent timer for smoother progress
            .autoconnect()
            .sink { _ in
                guard isPlaying else { return } // Check isPlaying *inside* timer block

                if currentTime < totalDuration {
                    currentTime += 0.1 // Increment by timer interval
                } else {
                    currentTime = totalDuration // Clamp to duration
                    isPlaying = false // Ensure it stops playing
                    stopTimer()
                    print("Ad finished playback naturally.")
                    // --- Trigger next action ---
                    // In a real app: notify player to resume, dismiss view, etc.
                    // triggerMusicResumeNotification()
                    // ---                     ---
                }
            }
        if isPlaying && abs(currentTime) < 0.1 { // Check if starting near 0
            print("Ad starting playback.")
        }
    }

    func stopTimer() {
        timerSubscription?.cancel()
        timerSubscription = nil
    }

    // --- Helper Functions ---
    func formatTime(_ time: Double) -> String {
        let totalSeconds = Int(max(0, time)) // Ensure time is not negative
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

     func prepareHaptics() {
        feedbackGenerator.prepare() // Prepare the haptic engine
         print("Haptic engine prepared.")
    }
}

// --- Supporting Views for Sheets (Updated LearnMoreView) ---

struct AdOptionsView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            List {
                Button {
                    print("Simulating: Fetching ad relevance info...")
                    // Show an alert or navigate to a detailed view
                    dismiss()
                } label: {
                    Label("Why am I seeing this ad?", systemImage: "info.circle")
                }

                 Button {
                    print("Simulating: Opening ad reporting flow...")
                    // Show reporting UI / Network request
                     dismiss()
                } label: {
                     Label("Report this ad", systemImage: "exclamationmark.bubble")
                }
                 .tint(.red) // Indicate potentially negative action

                 Button {
                     print("Simulating: Navigating to ad settings...")
                     // Open app settings or relevant web view
                     dismiss()
                 } label: {
                     Label("Advertiser settings", systemImage: "gearshape")
                 }
            }
            .navigationTitle("Ad Options")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// Updated to receive more specific ad data
struct LearnMoreView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.openURL) var openURL

    let advertiserName: String
    let logoSystemName: String
    let logoColor: Color
    let url: URL?

    var body: some View {
         NavigationView {
             VStack(spacing: 20) {
                 Image(systemName: logoSystemName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60) // Slightly larger logo
                    .padding(12)
                    .background(logoColor)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                     .shadow(radius: 4)
                    .padding(.top, 30)

                 Text("Visit \(advertiserName)")
                    .font(.title2).bold() // Bolder title

                 Text("Learn more about \(advertiserName)'s products on their official website.")
                     .font(.body)
                     .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                 if let validURL = url {
                     Button {
                         print("Action: Attempting to open URL - \(validURL)")
                         openURL(validURL)
                         // Optionally dismiss after a delay, or let user dismiss
                         // dismiss()
                     } label: {
                         Label("Visit Website", systemImage: "safari.fill")
                             .padding(.horizontal)
                     }
                     .buttonStyle(.borderedProminent)
                     .tint(logoColor) // Use advertiser color for button
                     .controlSize(.large) // Larger button
                 } else {
                     Text("No website link provided for this advertiser.")
                         .font(.footnote)
                         .foregroundColor(.secondary)
                 }
                 Spacer() // Pushes content to top
             }
             .padding()
             .navigationTitle("Learn More")
             .navigationBarTitleDisplayMode(.inline)
              .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
         }
    }
}

// --- Safe Area Helper (Remains the same) ---
struct SafeAreaInsetsKey: EnvironmentKey {
    static var defaultValue: EdgeInsets {
        // Simplified for broader compatibility, might need adjustment for specific scenarios
         (UIApplication.shared.connectedScenes.first as? UIWindowScene)?
            .windows.first(where: { $0.isKeyWindow })?
            .safeAreaInsets.swiftUiInsets ?? EdgeInsets()
    }
}
// Helper extension to convert UIEdgeInsets to EdgeInsets
extension UIEdgeInsets {
    var swiftUiInsets: EdgeInsets {
        EdgeInsets(top: top, leading: left, bottom: bottom, trailing: right)
    }
}

extension EnvironmentValues {
    var safeAreaInsets: EdgeInsets {
        self[SafeAreaInsetsKey.self]
    }
}

// --- Preview Provider ---
#if DEBUG
struct FunctionalMusicAdView_Previews: PreviewProvider {
    static var previews: some View {
         FunctionalMusicAdView()
           // Previews often run in Dark mode based on system;
           // you can force one if needed:
           // .preferredColorScheme(.dark)
    }
}
#endif

// --- PersistenceController Dummy (If needed - remains same) ---
#if DEBUG
import CoreData // Needed if PersistenceController is used
struct PersistenceController {
    static let preview = PersistenceController(inMemory: true)
    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "DummyModel") // Use a non-existent model name
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { _, error in
             if let error = error as NSError? {
                 fatalError("Unresolved error \(error), \(error.userInfo)")
             }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
#endif
