//
//  AdPlayerView_V3.swift
//  MyApp
//
//  Created by Cong Le on 4/8/25.
//

import Foundation
import SwiftUI // For Color, needed if you add color properties

struct Ad: Identifiable {
    let id = UUID() // Conforms to Identifiable
    let title: String
    let advertiserName: String
    let duration: Double // In seconds
    let learnMoreURL: URL?
    let artworkImageName: String // Name of image asset in Assets.xcassets
    let iconSystemName: String   // SF Symbol name for the small icon
    let bannerText: String
    let callToActionText: String = "Learn More" // Default, could be customized per ad
    // Optional: Add properties for colors, tracking URLs, etc.
}

// Sample Ad Data
struct SampleAds {
    static let artisanMarket = Ad(
        title: "Artisan Market",
        advertiserName: "Local Grocers Inc.",
        duration: 17.0,
        learnMoreURL: URL(string: "https://www.example.com/artisanmarket"),
        artworkImageName: "podcastArtworkPlaceholder", // MUST exist in Assets.xcassets
        iconSystemName: "basket.fill",
        bannerText: "Save 10% on your first grocery delivery!"
    )

    static let travelDeal = Ad(
        title: "Weekend Getaway",
        advertiserName: "Adventure Tours",
        duration: 25.5,
        learnMoreURL: URL(string: "https://www.example.com/traveldeals"),
        artworkImageName: "travelAdPlaceholder", // Add another placeholder image to Assets
        iconSystemName: "airplane",
        bannerText: "Book your dream escape today. Limited time offer!"
    )

    static let appDownload = Ad(
        title: "Brain Game Pro",
        advertiserName: "CongLeSolutionX Tech",
        duration: 12.0,
        learnMoreURL: nil, // Example of an ad with no direct link
        artworkImageName: "appAdPlaceholder", // Add another placeholder image to Assets
        iconSystemName: "gamecontroller.fill",
        bannerText: "Challenge your mind! Download Brain Game Pro now."
        // callToActionText property could be "Download" if customized
    )
}

import SwiftUI
import Combine
import SafariServices

// Simple enum for user feedback state (remains the same)
enum AdFeedback: Equatable {
    case liked
    case disliked
    case none
}

struct AdPlayerView: View {
    // --- Data Model ---
    let ad: Ad // Inject the Ad data

    // --- State Variables ---
    @State private var isPlaying: Bool = true
    @State private var progress: Double = 0.0
    @State private var elapsedTime: Double = 0.0
    @State private var userFeedback: AdFeedback = .none
    @State private var showOptionsSheet: Bool = false
    @State private var isShowingSafariView: Bool = false

    // --- Configuration (can be adjusted) ---
    let skipIncrement: Double = 5.0

    // --- Timer for Playback Simulation ---
    @State private var timerSubscription: Cancellable?
    let timerPublisher = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    // --- UI Colors (remain the same) ---
    let darkGreenBackground = Color(red: 30/255, green: 89/255, blue: 69/255)
    let lighterGreenBanner = Color(red: 42/255, green: 126/255, blue: 99/255)
    let adIconBackground = Color(red: 42/255, green: 126/255, blue: 99/255) // Icon background
    let adIconForeground = Color(red: 237/255, green: 90/255, blue: 48/255) // Icon color itself
    let artworkPlaceholderColor = Color(red: 20/255, green: 70/255, blue: 55/255)
    let progressBarColor = Color.white.opacity(0.8)
    let progressBarBackgroundColor = Color.white.opacity(0.3)
    let feedbackButtonSelectedColor = Color.yellow

    // --- Haptic Feedback Generators (remain the same) ---
    let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    let selectionGenerator = UISelectionFeedbackGenerator()

    // --- Computed Properties ---
    var adDuration: Double { ad.duration } // Get duration from the model
    var remainingTime: Double {
        max(0, adDuration - elapsedTime)
    }
    var learnMoreURL: URL? { ad.learnMoreURL } // Get URL from the model

    // --- Body ---
    var body: some View {
        ZStack {
            darkGreenBackground.edgesIgnoringSafeArea(.all)

            VStack(spacing: 15) { // Adjusted spacing slightly
                topBar
                artworkSection
                adInfoSection
                progressBarArea
                playerControls
                Spacer() // Pushes everything up before the banner
                bottomBanner
            }
            .padding(.bottom) // Add padding at the very bottom of the VStack
        }
        .onAppear {
             // Reset state when the view appears with a potentially new ad
             resetPlaybackState()
             startTimerIfNeeded()
         }
        .onDisappear(perform: stopTimer)
        .onReceive(timerPublisher) { _ in
            updateProgress()
        }
         // Use modern .confirmationDialog attached to a visible element
         .confirmationDialog(
             "Ad Options",
             isPresented: $showOptionsSheet,
             titleVisibility: .visible
         ) {
             // Only show "Visit" if URL exists
             if learnMoreURL != nil {
                 Button("Visit Advertiser Website") {
                     isShowingSafariView = true
                 }
             }
             Button("Report This Ad", role: .destructive) {
                 print("Reporting ad: \(ad.title) (ID: \(ad.id))")
                 // Add actual reporting logic here (e.g., API call)
             }
             Button("Cancel", role: .cancel) { }
         } message: {
             Text("\"\(ad.title)\" by \(ad.advertiserName)") // Contextual message
         }
        .sheet(isPresented: $isShowingSafariView) {
            // Present Safari View for "Learn More"
            if let url = learnMoreURL {
                AdPlayerView_V3_SafariView(url: url)
                    .ignoresSafeArea()
            }
        }
        .onChange(of: isPlaying) {
             selectionGenerator.selectionChanged()
        }
        .onChange(of: ad.id) { // React if the ad itself changes
            print("Ad changed, resetting state for \(ad.title)")
            resetPlaybackState()
            isPlaying = true // Autoplay new ad
        }
    }

    // MARK: - Subviews (Updated to use `ad` model)

    private var topBar: some View {
        HStack {
            Button {
                print("Dismiss action triggered for ad: \(ad.title)")
                stopTimer()
                // Add actual dismiss logic (e.g., binding, environment object)
            } label: {
                Image(systemName: "chevron.down")
            }

            Spacer()
            Text("Your content continues after the break") // More generic
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Spacer()

            Button {
                showOptionsSheet = true
                 selectionGenerator.selectionChanged()
            } label: {
                 Image(systemName: "ellipsis")
            }
        }
        .foregroundColor(.white)
        .padding(.horizontal)
        .padding(.top, 5)
    }

    private var artworkSection: some View {
        // Use the image name from the Ad model
        Image(ad.artworkImageName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            // Use placeholder color *behind* the image
            .background(artworkPlaceholderColor)
             // Overlay the icon as a fallback visual *if* the main image fails or is generic
             .overlay(
                 Image(systemName: ad.iconSystemName)
                     .resizable()
                     .scaledToFit()
                     .frame(width: 50, height: 50)
                     .foregroundColor(.white.opacity(0.5)) // Make it subtle
             )
            .cornerRadius(12)
            .shadow(radius: 5) // Add a subtle shadow
            .padding(.horizontal)
    }

    private var adInfoSection: some View {
        HStack(spacing: 12) {
            Image(systemName: ad.iconSystemName) // Use icon from model
                .resizable()
                .scaledToFit()
                .frame(width: 25, height: 25)
                .foregroundColor(.white) // Make icon white for contrast on background
                .padding(10)
                .background(adIconBackground) // Use the defined background color
                .cornerRadius(8)

            VStack(alignment: .leading) {
                Text(ad.title) // Use title from model
                    .font(.headline)
                    .fontWeight(.bold)
                Text(ad.advertiserName) // Use advertiser from model
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            Spacer()
        }
        .foregroundColor(.white)
        .padding(.horizontal)
    }

    private var progressBarArea: some View {
        VStack(spacing: 5) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(progressBarBackgroundColor)
                        .frame(height: 4)
                    Capsule()
                        .fill(progressBarColor)
                        .frame(width: geometry.size.width * CGFloat(progress), height: 4)
                        .animation(.linear(duration: 0.1), value: progress)
                }
                 .gesture(DragGesture(minimumDistance: 0)
                     .onChanged { value in
                         if isPlaying { isPlaying = false } // Pause on scrub start
                         let newProgress = min(max(0, Double(value.location.x / geometry.size.width)), 1)
                         // Directly update playback time based on gesture
                         updatePlaybackTime(to: newProgress * adDuration)
                     }
                     // Optional: Resume playback on gesture end if it was playing before
                     // .onEnded { _ in // if isPlayingBeforeScrub { isPlaying = true } }
                 )
            }
            .frame(height: 10) // Hit area

            HStack {
                Text(timeString(from: elapsedTime))
                Spacer()
                // Use computed remainingTime
                Text("-\(timeString(from: remainingTime))")
            }
            .font(.caption2)
            .foregroundColor(.white.opacity(0.7))
        }
        .padding(.horizontal)
    }

    private var playerControls: some View {
        HStack {
            Spacer()
            feedbackButton(type: .liked, systemName: "thumbsup")
            Spacer()
            skipButton(systemName: "gobackward.\(Int(skipIncrement))", action: skipBackward)
            Spacer()
            playPauseButton
            Spacer()
            skipButton(systemName: "goforward.\(Int(skipIncrement))", action: skipForward)
            Spacer()
            feedbackButton(type: .disliked, systemName: "thumbsdown")
            Spacer()
        }
        .foregroundColor(.white)
        .padding(.horizontal)
        .padding(.vertical, 10)
    }

    // Unchanged: playPauseButton, skipButton, feedbackButton logic, timeString

    private var playPauseButton: some View {
         Button {
             togglePlayPause()
         } label: {
             Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                 .font(.system(size: 28))
                 .frame(width: 65, height: 65)
                 .background(.white)
                 .foregroundColor(darkGreenBackground)
                 .clipShape(Circle())
         }
     }

     private func skipButton(systemName: String, action: @escaping () -> Void) -> some View {
         Button(action: action) {
             Image(systemName: systemName)
                 .font(.title)
         }
     }

     private func feedbackButton(type: AdFeedback, systemName: String) -> some View {
         Button {
             toggleFeedback(type)
         } label: {
             Image(systemName: userFeedback == type ? "\(systemName).fill" : systemName)
                 .font(.title2)
                 .foregroundColor(userFeedback == type ? feedbackButtonSelectedColor : .white)
         }
     }

    private var bottomBanner: some View {
        HStack {
            Text(ad.bannerText) // Use banner text from model
                .font(.footnote)
                .fontWeight(.medium)
                .lineLimit(2)
                .minimumScaleFactor(0.8)

            Spacer()

            Button {
                 if learnMoreURL != nil {
                     isShowingSafariView = true
                     selectionGenerator.selectionChanged()
                 }
            } label: {
                Text(ad.callToActionText) // Use CTA text from model
                    .font(.footnote)
                    .fontWeight(.bold)
                    .foregroundColor(darkGreenBackground)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(.white)
                    .clipShape(Capsule())
            }
             // Disable button if URL is nil
             .disabled(learnMoreURL == nil)
             // Add opacity effect when disabled
             .opacity(learnMoreURL == nil ? 0.5 : 1.0)
        }
        .foregroundColor(.white)
        .padding()
        .background(lighterGreenBanner)
        .cornerRadius(15)
        .padding(.horizontal)
    }

    // MARK: - Helper Functions (Updated)

    private func timeString(from totalSeconds: Double) -> String {
         guard totalSeconds.isFinite && totalSeconds >= 0 else { return "0:00" } // Handle potential NaN/negative
         let seconds = Int(totalSeconds) % 60
         let minutes = Int(totalSeconds) / 60
         return String(format: "%d:%02d", minutes, seconds)
     }

     private func togglePlayPause() {
         isPlaying.toggle()
         if isPlaying {
             // If ad finished and user hits play, restart it
             if elapsedTime >= adDuration && adDuration > 0 { // Check duration > 0
                resetPlaybackState() // Restart fully
             }
             startTimerIfNeeded() // Ensure timer is running
         }
         // No need to explicitly stop timer here, the updateProgress guard handles it
     }

     // Renamed for clarity and added clamping
     private func updatePlaybackTime(to time: Double) {
         // Clamp the time between 0 and the ad's duration
         let clampedTime = max(0, min(time, adDuration))
         elapsedTime = clampedTime
         progress = adDuration > 0 ? elapsedTime / adDuration : 0 // Avoid division by zero

         // If manually scrubbed to the end, stop playback
         if elapsedTime >= adDuration {
             isPlaying = false
             progress = 1.0 // Ensure progress bar is full
         }
     }

     private func skipForward() {
         feedbackGenerator.impactOccurred()
         updatePlaybackTime(to: elapsedTime + skipIncrement)
     }

     private func skipBackward() {
         feedbackGenerator.impactOccurred()
         updatePlaybackTime(to: elapsedTime - skipIncrement)
     }

     private func toggleFeedback(_ feedback: AdFeedback) {
         feedbackGenerator.impactOccurred()
         if userFeedback == feedback {
             userFeedback = .none
             print("Feedback removed for ad: \(ad.title)")
         } else {
             userFeedback = feedback
             print("Feedback set to \(feedback) for ad: \(ad.title) (ID: \(ad.id))")
             // Send feedback to analytics/server here
         }
     }

     private func updateProgress() {
         // Only update if playing and duration is valid
         guard isPlaying, adDuration > 0 else { return }

         if elapsedTime < adDuration {
             elapsedTime += 0.1 // Increment by timer interval
             progress = elapsedTime / adDuration
         } else {
             // Ad finished
             elapsedTime = adDuration // Ensure exact end value
             progress = 1.0
             isPlaying = false // Stop playback
             print("Ad finished playing: \(ad.title)")
             // Optionally trigger "ad finished" delegate/callback/notification
         }
     }

    // Resets player state, useful when the ad changes or restarts
    private func resetPlaybackState() {
        elapsedTime = 0
        progress = 0
        userFeedback = .none // Reset feedback for new ad
        // isPlaying might be set separately depending on autoplay logic
    }

     private func startTimerIfNeeded() {
         // Ensure only one timer subscription exists
         if timerSubscription == nil && isPlaying {
            timerSubscription = timerPublisher.sink { _ in /* Handled by onReceive */ }
            print("Timer started for ad: \(ad.title)")
         } else if !isPlaying {
             // If not playing, ensure timer stops (though guard in updateProgress handles ticks)
             stopTimer()
         }
     }

     private func stopTimer() {
         timerSubscription?.cancel()
         timerSubscription = nil
         print("Timer stopped for ad: \(ad.title)")
     }
}

// MARK: - SafariView Wrapper (remains the same)

struct AdPlayerView_V3_SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        // Configure Safari view controller appearance if desired
        // let config = SFSafariViewController.Configuration()
        // config.entersReaderIfAvailable = false
        // let vc = SFSafariViewController(url: url, configuration: config)
        // vc.preferredControlTintColor = .systemBlue // Example customization
        let vc = SFSafariViewController(url: url)
        return vc
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) { }
}

// MARK: - Preview (Updated with Sample Data)

struct AdPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        // Preview with the first sample ad
        AdPlayerView(ad: SampleAds.artisanMarket)
            .preferredColorScheme(.dark)
            .previewDisplayName("Artisan Market Ad")

        // Preview with the ad that has no URL
        AdPlayerView(ad: SampleAds.appDownload)
            .preferredColorScheme(.dark)
            .previewDisplayName("App Ad (No URL)")

         // Preview inside a NavigationView (more realistic container)
         NavigationView {
             AdPlayerView(ad: SampleAds.travelDeal)
                 .navigationBarHidden(true) // Hide nav bar for this specific view
         }
         .preferredColorScheme(.dark)
         .previewDisplayName("Travel Ad (Nav)")

    }
}
