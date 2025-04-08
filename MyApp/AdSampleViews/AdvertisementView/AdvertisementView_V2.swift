////
////  AdvertisementView_V2.swift
////  MyApp
////
////  Created by Cong Le on 4/8/25.
////
//
//import SwiftUI
//import Combine // Needed for Timer
//
//// --- Mock Data & Constants ---
//struct AdConstants {
//    static let totalDuration: TimeInterval = 17.0 // seconds
//    static let advertiserName = "LELUNE"
//    static let advertiserType = "Advertisement"
//    static let ctaText = "Subscribe today to give your home a LeLune lift."
//    static let learnMoreURL = URL(string: "https://google.com/")! // Replace with actual if possible
//    static let imageName = "My-meme-microphone.png" // Ensure this exists in Assets
//    static let logoText = "C"
//}
//
//// Define custom colors matching the screenshot
//// Note: These are approximations. Use precise color values if available.
//extension Color {
//    static let adBackground = Color(red: 139/255, green: 0/255, blue: 0/255) // Dark Red
//    static let ctaBackground = Color.black.opacity(0.2) // Semi-transparent darker shade
//    static let logoBackground = Color(red: 250/255, green: 235/255, blue: 215/255) // Antique White / Cream
//    static let primaryText = Color.white
//    static let secondaryText = Color.white.opacity(0.7)
//    static let progressBarTint = Color.white.opacity(0.8)
//    static let progressBarBackground = Color.white.opacity(0.3)
//    static let buttonText = Color(red: 50/255, green: 50/255, blue: 50/255) // Dark Gray for Button Text
//    static let interactionHighlight = Color.green // Example for like/dislike
//}
//
//struct FunctionalAdvertisementView: View {
//    // --- Environment ---
//    @Environment(\.dismiss) var dismiss
//    @Environment(\.openURL) var openURL
//
//    // --- State Variables ---
//    @State private var isPlaying: Bool = true // Start playing automatically
//    @State private var currentTime: TimeInterval = 0.0
//    @State private var progress: Double = 0.0
//    @State private var isLiked: Bool = false
//    @State private var isDisliked: Bool = false
//    @State private var showOptionsSheet: Bool = false
//
//    // --- Timer ---
//    // Use Combine's Timer publisher for UI updates
//    @State private var timerSubscription: Cancellable?
//
//    var body: some View {
//        ZStack {
//            // --- Main background color ---
//            Color.adBackground.edgesIgnoringSafeArea(.all)
//
//            VStack(spacing: 15) {
//                // --- Top Bar ---
//                topBar
//
//                // --- Ad Image ---
//                adImage
//
//                // --- Advertiser Info ---
//                advertiserInfo
//
//                // --- Progress Bar ---
//                progressBar
//
//                // --- Playback Controls ---
//                playbackControls
//
//                Spacer() // Pushes CTA banner to the bottom
//
//                // --- CTA Banner ---
//                ctaBanner
//
//            } // End Main VStack
//        } // End ZStack
//        .onAppear(perform: startTimerIfNeeded)
//        .onDisappear(perform: cancelTimer)
//        // --- Action Sheet ---
//        .actionSheet(isPresented: $showOptionsSheet) {
//             ActionSheet(
//                 title: Text("Ad Options"),
//                 message: Text("What would you like to do?"),
//                 buttons: [
//                     .default(Text("Why this ad?")) { /* Handle action */ print("Selected: Why this ad?") },
//                     .destructive(Text("Report Ad")) { /* Handle action */ print("Selected: Report Ad") },
//                     .cancel()
//                 ]
//             )
//         }
//    }
//
//    // MARK: - Subviews
//
//    private var topBar: some View {
//        HStack {
//            Button {
//                dismiss() // Close the ad view
//            } label: {
//                Image(systemName: "chevron.down")
//            }
//
//            Spacer()
//            Text("Your music will continue after the break")
//                .font(.caption)
//            Spacer()
//
//            Button {
//                showOptionsSheet = true // Show options
//            } label: {
//                 Image(systemName: "ellipsis")
//            }
//        }
//        .foregroundColor(.primaryText)
//        .padding(.horizontal)
//        .padding(.top, 5)
//    }
//
//    private var adImage: some View {
//        Image(AdConstants.imageName)
//             .resizable()
//             .aspectRatio(contentMode: .fit)
//             .cornerRadius(10)
//             .padding(.horizontal)
//             // Add accessibility label
//             .accessibilityLabel(Text("Advertisement for \(AdConstants.advertiserName)"))
//    }
//
//    private var advertiserInfo: some View {
//        HStack(spacing: 12) {
//            Text(AdConstants.logoText)
//                .font(.largeTitle)
//                .fontWeight(.bold)
//                .foregroundColor(.buttonText)
//                .frame(width: 50, height: 50)
//                .background(Color.logoBackground)
//                .cornerRadius(6)
//
//            VStack(alignment: .leading, spacing: 2) {
//                Text(AdConstants.advertiserName)
//                    .font(.headline)
//                    .fontWeight(.bold)
//                Text(AdConstants.advertiserType)
//                    .font(.caption)
//                    .foregroundColor(.secondaryText)
//            }
//            Spacer()
//        }
//        .foregroundColor(.primaryText)
//        .padding(.horizontal)
//    }
//
//    private var progressBar: some View {
//         VStack(spacing: 4) {
//             ProgressView(value: progress)
//                 .progressViewStyle(LinearProgressViewStyle(tint: Color.progressBarTint))
//                 .scaleEffect(x: 1, y: 1.5, anchor: .center) // Slightly thicker
//                 .background(Color.progressBarBackground.opacity(0.5)) // Background track
//                 .clipShape(Capsule()) // Rounded ends for the background
//
//             HStack {
//                 Text(formatTime(currentTime))
//                 Spacer()
//                 Text(formatTime(max(0, AdConstants.totalDuration - currentTime))) // Remaining time
//             }
//             .font(.caption2)
//             .foregroundColor(.secondaryText)
//         }
//         .padding(.horizontal)
//     }
//
//    private var playbackControls: some View {
//         HStack(spacing: 20) {
//             Spacer()
//
//             // --- Thumbs Up ---
//             Button {
//                 isLiked.toggle()
//                 if isLiked { isDisliked = false } // Can't like and dislike
//                 print("Ad Liked: \(isLiked)")
//             } label: {
//                 Image(systemName: isLiked ? "hand.thumbsup.fill" : "hand.thumbsup")
//                     .font(.title2)
//                     .foregroundColor(isLiked ? .interactionHighlight : .primaryText) // Highlight if liked
//             }
//             .accessibilityLabel(isLiked ? Text("Unlike Ad") : Text("Like Ad"))
//
//            // --- Previous (Disabled) ---
//            Button {} label: {
//                 Image(systemName: "backward.end.fill")
//                    .font(.title2)
//            }
//            .disabled(true) // Ads typically cannot be skipped back
//            .opacity(0.5) // Visually indicate disabled state
//
//             // --- Play/Pause ---
//             Button {
//                 togglePlayback()
//             } label: {
//                 Image(systemName: isPlaying ? "pause.fill" : "play.fill")
//                     .font(.system(size: 30))
//                     .foregroundColor(Color.adBackground)
//                     .frame(width: 60, height: 60)
//                     .background(Circle().fill(Color.primaryText))
//             }
//             .accessibilityLabel(isPlaying ? Text("Pause Ad") : Text("Play Ad"))
//
//            // --- Next (Disabled) ---
//            Button {} label: {
//                 Image(systemName: "forward.end.fill")
//                    .font(.title2)
//            }
//            .disabled(true) // Ads typically cannot be skipped forward
//            .opacity(0.5) // Visually indicate disabled state
//
//             // --- Thumbs Down ---
//             Button {
//                 isDisliked.toggle()
//                 if isDisliked { isLiked = false } // Can't like and dislike
//                 print("Ad Disliked: \(isDisliked)")
//             } label: {
//                  Image(systemName: isDisliked ? "hand.thumbsdown.fill" : "hand.thumbsdown")
//                     .font(.title2)
//                     .foregroundColor(isDisliked ? .interactionHighlight : .primaryText) // Highlight if disliked
//             }
//             .accessibilityLabel(isDisliked ? Text("Remove Dislike") : Text("Dislike Ad"))
//
//              Spacer()
//         }
//         .foregroundColor(.primaryText)
//         .padding(.horizontal)
//     }
//
//    private var ctaBanner: some View {
//         HStack {
//             Text(AdConstants.ctaText)
//                 .font(.footnote)
//                 .lineLimit(2)
//                 .multilineTextAlignment(.leading)
//
//             Spacer()
//
//             Button("Learn more") {
//                 print("Attempting to open URL: \(AdConstants.learnMoreURL)")
//                 openURL(AdConstants.learnMoreURL) // Open the defined URL
//             }
//             .font(.footnote)
//             .fontWeight(.bold)
//             .foregroundColor(.buttonText)
//             .padding(.horizontal, 16)
//             .padding(.vertical, 8)
//             .background(Color.primaryText)
//             .cornerRadius(20)
//         }
//         .padding()
//         .background(Color.ctaBackground)
//         .cornerRadius(12)
//         .padding(.horizontal)
//         .padding(.bottom, 20)
//         .accessibilityElement(children: .combine) // Combine text and button for accessibility
//     }
//
//    // MARK: - Helper Functions
//
//    private func togglePlayback() {
//        isPlaying.toggle()
//        if isPlaying {
//            startTimerIfNeeded()
//        } else {
//            cancelTimer()
//        }
//    }
//
//    private func startTimerIfNeeded() {
//        guard isPlaying, timerSubscription == nil else { return }
//
//        // Schedule timer to fire frequently for smooth progress update
//        timerSubscription = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect().sink { _ in
//            guard isPlaying else { return } // Check again in case it was paused between intervals
//
//            if currentTime < AdConstants.totalDuration {
//                currentTime += 0.1
//                progress = currentTime / AdConstants.totalDuration
//            } else {
//                // Ad finished
//                isPlaying = false
//                currentTime = AdConstants.totalDuration
//                progress = 1.0
//                cancelTimer()
//                print("Ad finished playing.")
//                // Optionally: Automatically dismiss after a short delay
//                 // DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                 //     dismiss()
//                 // }
//            }
//        }
//        print("Timer Started")
//    }
//
//    private func cancelTimer() {
//        timerSubscription?.cancel()
//        timerSubscription = nil // Important to prevent memory leaks
//        print("Timer Cancelled")
//    }
//
//    // Formats time interval (seconds) into MM:SS or SS string
//   private func formatTime(_ time: TimeInterval) -> String {
//        let totalSeconds = Int(time.rounded())
//        let seconds = totalSeconds % 60
//        let minutes = totalSeconds / 60
//
//        if minutes > 0 {
//            return String(format: "%d:%02d", minutes, seconds)
//        } else {
//            // Show negative sign for remaining time if needed elsewhere,
//            // but here ensure positive display or 0
//            let displaySeconds = max(0, seconds)
//             // Prefix with "-" for remaining time style
//            let prefix = (time < AdConstants.totalDuration && time > 0 && self.currentTime == time) ? "" : "-" // Only show "-" for remaining time display
//            // Recheck logic: Use currentTime compared to totalDuration to decide the right sign display
//             let remainingSeconds = Int((AdConstants.totalDuration - currentTime).rounded())
//             if remainingSeconds < 0 && self.currentTime == time { // This check might be overly complex, simplify
//                 return String(format: "%d:%02d", minutes, max(0,seconds))
//             } else if time >= AdConstants.totalDuration {
//                  return String(format: "%d:%02d", Int(AdConstants.totalDuration / 60), Int(AdConstants.totalDuration) % 60) // Show total duration if finished
//             } else if self.currentTime != time { // Assumes this is the remaining time label
//                 return String(format: "-%d:%02d", remainingSeconds / 60, max(0, remainingSeconds % 60))
//             } else { // Must be the current time label
//                 return String(format: "%d:%02d", minutes, seconds)
//             }
//        }
//   }
//    // Simpler time formatter
//    private func formatTimeSimple(_ time: TimeInterval) -> String {
//        let totalSeconds = Int(abs(time).rounded()) // Use abs for remaining time formatting
//        let seconds = totalSeconds % 60
//        let minutes = totalSeconds / 60
//        let sign = time < 0 ? "-" : "" // Add sign for remaining time maybe? Check screenshot again. Looks like "-0:15"
//
//         // Apply sign logic based on which label calls this
//        // For now, let's assume the caller handles the sign if needed.
//        // The Text views above handle the sign display logic.
//        return String(format: "%d:%02d", minutes, seconds)
//
//    }
//
//     private func formatTimeCorrected(_ time: TimeInterval, isRemaining: Bool = false) -> String {
//         let effectiveTime = isRemaining ? max(0, AdConstants.totalDuration - time) : time
//         let totalSeconds = Int(effectiveTime.rounded())
//         let seconds = totalSeconds % 60
//         let minutes = totalSeconds / 60
//         let sign = isRemaining ? "-": "" // Add the minus sign for remaining time
//
//         // Prevent showing "-0:00" when ad finishes
//         if isRemaining && totalSeconds <= 0 {
//             return "-0:00" // Or just "0:00" depending on desired style
//         }
//
//         return String(format: "%@%d:%02d", sign, minutes, seconds)
//     }
//}
//// MARK: - Preview
//#Preview {
//    FunctionalAdvertisementView()
//        // If your image is named differently or needs specific handling in preview:
//        // .environment(\.imageProvider, ...) // Example of overriding environment if needed
//}
//
//// --- Placeholder Image Logic (if needed for preview/testing) ---
//// struct PlaceholderImageProvider { }
//// extension EnvironmentValues {
////     var imageProvider: PlaceholderImageProvider { /* ... */ }
//// }
//// struct PlaceholderImageProviderKey: EnvironmentKey { /* ... */ }
