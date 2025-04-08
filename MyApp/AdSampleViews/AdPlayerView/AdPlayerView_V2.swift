//
//  AdPlayerView_V2.swift
//  MyApp
//
//  Created by Cong Le on 4/8/25.
//

import SwiftUI
import Combine // For Timer
import SafariServices // For Learn More button

// Simple enum for user feedback state
enum AdFeedback: Equatable {
    case liked
    case disliked
    case none
}

struct AdPlayerView: View {
    // --- State Variables ---
    @State private var isPlaying: Bool = true // Assume ad starts playing automatically
    @State private var progress: Double = 0.0 // Progress from 0.0 to 1.0
    @State private var elapsedTime: Double = 0.0 // Elapsed time in seconds
    @State private var userFeedback: AdFeedback = .none
    @State private var showOptionsSheet: Bool = false
    @State private var isShowingSafariView: Bool = false

    // --- Mock Data & Configuration ---
    let adTitle: String = "Artisan Market"
    let adSubtitle: String = "Advertisement"
    let adDuration: Double = 17.0 // Total ad duration in seconds (mock)
    let skipIncrement: Double = 5.0 // Seconds to skip forward/backward
    let learnMoreURL: URL? = URL(string: "https://www.example.com/artisanmarket") // Mock URL

    // --- Timer for Playback Simulation ---
    @State private var timerSubscription: Cancellable?
    let timerPublisher = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    // --- UI Colors (as defined before) ---
    let darkGreenBackground = Color(red: 30/255, green: 89/255, blue: 69/255)
    let lighterGreenBanner = Color(red: 42/255, green: 126/255, blue: 99/255)
    let adIconBackground = Color(red: 42/255, green: 126/255, blue: 99/255)
    let adIconForeground = Color(red: 237/255, green: 90/255, blue: 48/255)
    let artworkPlaceholderColor = Color(red: 20/255, green: 70/255, blue: 55/255)
    let progressBarColor = Color.white.opacity(0.8)
    let progressBarBackgroundColor = Color.white.opacity(0.3)
    let feedbackButtonSelectedColor = Color.yellow // Color for selected thumbs up/down

    // --- Haptic Feedback Generator ---
    let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    let selectionGenerator = UISelectionFeedbackGenerator()

    // --- Computed Properties ---
    var remainingTime: Double {
        max(0, adDuration - elapsedTime)
    }

    // --- Body ---
    var body: some View {
        ZStack {
            darkGreenBackground.edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                topBar
                artworkSection
                adInfoSection
                progressBarArea
                playerControls
                bottomBanner
                Spacer() // Pushes everything up
            }
        }
        .onAppear(perform: startTimerIfNeeded)
        .onDisappear(perform: stopTimer)
        .onReceive(timerPublisher) { _ in
            updateProgress()
        }
        .sheet(isPresented: $showOptionsSheet) {
            //optionsActionSheet // Presents the action sheet modally
        }
        .sheet(isPresented: $isShowingSafariView) {
            // Present Safari View for "Learn More"
            if let url = learnMoreURL {
                AdPlayerView_SafariView(url: url)
                    .ignoresSafeArea() // Allow Safari view to use full screen
            } else {
                // Fallback if URL is somehow nil
                Text("Could not load page.")
                    .padding()
            }
        }
        .onChange(of: isPlaying) {
             selectionGenerator.selectionChanged() // Feedback when play/pause toggled
        }
    }

    // MARK: - Subviews

    private var topBar: some View {
        HStack {
            Button {
                // Action to dismiss view - In a real app, this would use a binding or coordinator
                print("Dismiss action triggered")
                stopTimer() // Stop timer when dismissing
            } label: {
                Image(systemName: "chevron.down")
            }

            Spacer()
            Text("Your podcast will continue after the break")
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
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
        Image("podcastArtworkPlaceholder") // Use the placeholder name
            .resizable()
            .aspectRatio(contentMode: .fit)
            .background(artworkPlaceholderColor)
            .cornerRadius(12)
            .overlay(
                Image(systemName: "basket.fill") // Example placeholder icon
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.white.opacity(0.7)) // Slightly less prominent
            )
            .padding(.horizontal)
    }

    private var adInfoSection: some View {
        HStack(spacing: 12) {
            Image(systemName: "basket.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 25, height: 25)
                .foregroundColor(adIconForeground)
                .padding(10)
                .background(adIconBackground)
                .cornerRadius(8)

            VStack(alignment: .leading) {
                Text(adTitle)
                    .font(.headline)
                    .fontWeight(.bold)
                Text(adSubtitle)
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
                        .animation(.linear(duration: 0.1), value: progress) // Smooth progress update
                }
                 // Allow scrubbing - simplified example
                 .gesture(DragGesture(minimumDistance: 0)
                     .onChanged { value in
                         if isPlaying { isPlaying = false } // Pause on scrub start
                         let newProgress = min(max(0, Double(value.location.x / geometry.size.width)), 1)
                         updatePlaybackTime(to: newProgress * adDuration)
                     }
                 )
            }
            .frame(height: 10) // Increase hit area slightly for scrubbing

            HStack {
                Text(timeString(from: elapsedTime))
                Spacer()
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

    // Generic button for skipping
    private func skipButton(systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.title) // Slightly larger skip buttons
        }
    }

     // Generic button for feedback
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
            Text("Save 10% on your first grocery delivery")
                .font(.footnote)
                .fontWeight(.medium)
                .lineLimit(2)
                .minimumScaleFactor(0.8)

            Spacer()

            Button {
                 if learnMoreURL != nil {
                     isShowingSafariView = true // Trigger the sheet
                      selectionGenerator.selectionChanged()
                 }
            } label: {
                Text("Learn more")
                    .font(.footnote)
                    .fontWeight(.bold)
                    .foregroundColor(darkGreenBackground)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(.white)
                    .clipShape(Capsule())
            }
             .disabled(learnMoreURL == nil) // Disable if no valid URL
        }
        .foregroundColor(.white)
        .padding()
        .background(lighterGreenBanner)
        .cornerRadius(15)
        .padding(.horizontal)
        .padding(.bottom)
    }

    // MARK: - Action Sheet Content
    private var optionsActionSheet: ActionSheet {
        // Using ActionSheet directly - deprecated but simpler for this example
        // In modern iOS, use .confirmationDialog
         ActionSheet(
             title: Text("Ad Options"),
             message: Text("What would you like to do?"),
             buttons: [
                 .default(Text("Visit Advertiser Website")) {
                     if learnMoreURL != nil { isShowingSafariView = true }
                 },
                 .destructive(Text("Report This Ad")) {
                     print("Report Ad action triggered")
                     // Add reporting logic here
                 },
                 .cancel()
             ]
         )

         // --- Modern equivalent using .confirmationDialog ---
         // This would replace the .sheet modifier and the ActionSheet view above
         // You'd attach this modifier to a view inside the body
         /*
         .confirmationDialog(
             "Ad Options",
             isPresented: $showOptionsSheet,
             titleVisibility: .visible
         ) {
             Button("Visit Advertiser Website") {
                 if learnMoreURL != nil { isShowingSafariView = true }
             }
             Button("Report This Ad", role: .destructive) {
                 print("Report Ad action triggered")
                 // Add reporting logic here
             }
             Button("Cancel", role: .cancel) { }
         } message: {
             Text("What would you like to do?")
         }
         */
    }

    // MARK: - Helper Functions

    private func timeString(from totalSeconds: Double) -> String {
        let seconds = Int(totalSeconds) % 60
        let minutes = Int(totalSeconds) / 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    private func togglePlayPause() {
        isPlaying.toggle()
        if isPlaying {
            // If ad finished and user hits play, restart it (example behavior)
            if elapsedTime >= adDuration {
                elapsedTime = 0
                progress = 0
            }
            startTimerIfNeeded()
        } else {
            stopTimer() // Timer logic now handles pausing internally based on isPlaying
        }
    }

    private func updatePlaybackTime(to time: Double) {
         elapsedTime = max(0, min(time, adDuration))
         progress = adDuration > 0 ? elapsedTime / adDuration : 0
         if elapsedTime >= adDuration {
             isPlaying = false // Stop playback when reaching the end
         }
    }

    private func skipForward() {
         feedbackGenerator.impactOccurred() // Haptic feedback
        updatePlaybackTime(to: elapsedTime + skipIncrement)
    }

    private func skipBackward() {
         feedbackGenerator.impactOccurred()
        updatePlaybackTime(to: elapsedTime - skipIncrement)
    }

     private func toggleFeedback(_ feedback: AdFeedback) {
         feedbackGenerator.impactOccurred()
         if userFeedback == feedback {
             userFeedback = .none // Toggle off if already selected
         } else {
             userFeedback = feedback
             print("User feedback set to: \(feedback)")
             // Here you would typically send this feedback to your analytics server
         }
     }

    private func updateProgress() {
        guard isPlaying else { return }

        if elapsedTime < adDuration {
            elapsedTime += 0.1 // Increment by timer interval
            progress = elapsedTime / adDuration
        } else {
            // Ad finished
            elapsedTime = adDuration
            progress = 1.0
            isPlaying = false // Stop playback
            // Optionally trigger "ad finished" event/callback here
            print("Ad finished playing.")
        }
    }

    private func startTimerIfNeeded() {
        // This method isn't strictly needed if using the .onReceive approach,
        // as the timer starts automatically. Kept for potential future logic.
        print("Timer check: AdPlayerView appeared.")
    }

    private func stopTimer() {
        // Cancel the timer subscription when the view disappears or is dismissed
        timerSubscription?.cancel()
        timerSubscription = nil
        print("Timer stopped.")
    }
}

// MARK: - SafariView Wrapper

struct AdPlayerView_SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
        // No update needed typically
    }
}

// MARK: - Preview

struct AdPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        AdPlayerView()
            .preferredColorScheme(.dark)
    }
}
