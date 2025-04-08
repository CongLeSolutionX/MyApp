//
//  AdvertisementView_V3.swift
//  MyApp
//
//  Created by Cong Le on 4/8/25.
//

// MARK: - Data Model
import Foundation

// Data model for an Advertisement
struct Advertisement: Identifiable {
    let id = UUID() // Unique identifier
    let advertiserName: String
    let advertiserDescription: String // More descriptive than just "Type"
    let ctaText: String // Call to action message
    let learnMoreURL: URL // URL for the "Learn More" button
    let imageURL: URL? // URL for the main ad image (optional)
    let logoImageURL: URL? // URL for the advertiser logo (optional)
    let logoText: String? // Fallback text if logo image isn't available
    let duration: TimeInterval // Duration of the ad in seconds

    // --- Sample Data ---
    static let sampleAd = Advertisement(
        advertiserName: "Aura Botanicals",
        advertiserDescription: "Natural Skincare",
        ctaText: "Discover radiant skin. Shop now for 15% off.",
        learnMoreURL: URL(string: "https://www.example.com/aurabotanicals")!, // Replace with a real URL
        imageURL: URL(string: "https://picsum.photos/seed/skincare/800/600"), // Placeholder image URL
        logoImageURL: URL(string: "https://picsum.photos/seed/leaflogo/100/100"), // Placeholder logo URL
        logoText: "AB", // Fallback if logo image fails
        duration: 18.0 // Ad duration
    )

    static let sampleAdNoImages = Advertisement(
        advertiserName: "CongLeSolutionX Inc.",
        advertiserDescription: "Orange Cloud Solutions",
        ctaText: "Scale your business with our secure cloud platform.",
        learnMoreURL: URL(string: "https://www.example.com/quantumcloud")!,
        imageURL: nil, // No main image
        logoImageURL: nil, // No logo image
        logoText: "QC", // Must have fallback text
        duration: 12.5
    )

     static let sampleAdTextLogo = Advertisement(
        advertiserName: "Chef's Table Delivery",
        advertiserDescription: "Gourmet Meals",
        ctaText: "Fine dining delivered to your door. Order tonight!",
        learnMoreURL: URL(string: "https://www.example.com/chefstable")!,
        imageURL: URL(string: "https://picsum.photos/seed/foodad/800/600"),
        logoImageURL: nil, // No logo image
        logoText: "CT", // Use text logo
        duration: 25.0
     )
}

// MARK: -  The View
import SwiftUI
import Combine

// --- Custom Colors (Keep these or adjust as needed) ---
extension Color {
    static let adBackground = Color(red: 139/255, green: 0/255, blue: 0/255) // Dark Red (Example)
    static let ctaBackground = Color.black.opacity(0.2)
    static let logoBackground = Color(red: 250/255, green: 235/255, blue: 215/255) // Cream
    static let primaryText = Color.white
    static let secondaryText = Color.white.opacity(0.7)
    static let progressBarTint = Color.white.opacity(0.8)
    static let progressBarBackground = Color.white.opacity(0.3)
    static let buttonText = Color(red: 50/255, green: 50/255, blue: 50/255) // Dark Gray
    static let interactionHighlight = Color.green // Example
    static let placeholderGray = Color.gray.opacity(0.5)
}

struct FunctionalAdvertisementView: View {
    // --- Environment ---
    @Environment(\.dismiss) var dismiss
    @Environment(\.openURL) var openURL

    // --- Input Data ---
    let advertisement: Advertisement // Accept the data model

    // --- State Variables ---
    @State private var isPlaying: Bool = true
    @State private var currentTime: TimeInterval = 0.0
    @State private var progress: Double = 0.0
    @State private var isLiked: Bool = false
    @State private var isDisliked: Bool = false
    @State private var showOptionsSheet: Bool = false
    @State private var totalDuration: TimeInterval = 15.0 // Default, will be updated

    // --- Timer ---
    @State private var timerSubscription: Cancellable?

    var body: some View {
        ZStack {
            // --- Main background color ---
            // Use a gradient or a color related to the ad maybe? For now, static.
            Color.adBackground.edgesIgnoringSafeArea(.all)

            VStack(spacing: 15) {
                topBar
                adImage // Uses AsyncImage
                advertiserInfo // Uses AsyncImage for logo
                progressBar
                playbackControls
                Spacer()
                ctaBanner
            }
        }
        .onAppear {
            // Set duration from data model when view appears
            totalDuration = advertisement.duration
            startTimerIfNeeded()
        }
        .onDisappear(perform: cancelTimer)
        .actionSheet(isPresented: $showOptionsSheet) {
             ActionSheet(
                 title: Text("Ad Options"),
                 message: Text("Interact with this ad from \(advertisement.advertiserName)"),
                 buttons: [
                     .default(Text("Why this ad?")) {
                         print("Action: Show 'Why this ad?' info for \(advertisement.id)")
                         // Potentially open a modal or URL with info
                     },
                     .destructive(Text("Report Ad")) {
                         print("Action: Initiate 'Report Ad' flow for \(advertisement.id)")
                         // Potentially navigate to a reporting screen
                     },
                     .cancel()
                 ]
             )
         }
    }

    // MARK: - Subviews (Updated for Data Model & AsyncImage)

    private var topBar: some View {
        HStack {
            Button { dismiss() } label: { Image(systemName: "chevron.down") }
            Spacer()
            Text("Your music will continue after the break").font(.caption)
            Spacer()
            Button { showOptionsSheet = true } label: { Image(systemName: "ellipsis") }
        }
        .foregroundColor(.primaryText)
        .padding(.horizontal)
        .padding(.top, 5)
    }

    private var adImage: some View {
        AsyncImage(url: advertisement.imageURL) { phase in
            switch phase {
            case .empty:
                ProgressView() // Loading indicator
                    .frame(maxWidth: .infinity, idealHeight: 250) // Give it size while loading
                    .background(Color.placeholderGray.opacity(0.3))
                    .cornerRadius(10)
            case .success(let image):
                image.resizable()
                     .aspectRatio(contentMode: .fit)
                     .cornerRadius(10)
            case .failure:
                // Placeholder for failed image load
                VStack {
                    Image(systemName: "photo.fill")
                        .font(.largeTitle)
                        .foregroundColor(.placeholderGray)
                    Text("Image unavailable")
                        .font(.caption)
                        .foregroundColor(.placeholderGray)
                }
                .frame(maxWidth: .infinity, idealHeight: 250)
                .background(Color.placeholderGray.opacity(0.3))
                .cornerRadius(10)

            @unknown default:
                EmptyView() // Should not happen
            }
        }
        .padding(.horizontal)
        .accessibilityLabel(Text("Advertisement image for \(advertisement.advertiserName)"))
    }

    private var advertiserInfo: some View {
        HStack(spacing: 12) {
            // Logo (AsyncImage or Text)
            Group {
                if let logoURL = advertisement.logoImageURL {
                    AsyncImage(url: logoURL) { phase in
                        switch phase {
                        case .empty: ProgressView().tint(.buttonText)
                        case .success(let image): image.resizable().scaledToFit()
                        case .failure: // Fallback to text if image fails or if no URL
                           fallbackLogoText
                        @unknown default: fallbackLogoText
                        }
                    }
                } else {
                    fallbackLogoText // Use text if no URL
                }
            }
            .frame(width: 50, height: 50)
            .background(Color.logoBackground)
            .cornerRadius(6)
            .clipped() // Ensure content stays within bounds

            VStack(alignment: .leading, spacing: 2) {
                Text(advertisement.advertiserName)
                    .font(.headline)
                    .fontWeight(.bold)
                Text(advertisement.advertiserDescription)
                    .font(.caption)
                    .foregroundColor(.secondaryText)
            }
            Spacer()
        }
        .foregroundColor(.primaryText)
        .padding(.horizontal)
    }

    // Helper for logo text fallback
    private var fallbackLogoText: some View {
        if let text = advertisement.logoText, !text.isEmpty {
           return Text(text)
                .font(.system(size: 24).weight(.bold)) // Adjust size dynamically maybe?
                .foregroundColor(.buttonText)
                .minimumScaleFactor(0.5) // Allows text to shrink
                .lineLimit(1)
        } else {
            // Default icon if no image URL and no text provided
            return Image(systemName: "building.2")
                 .font(.title)
                 .foregroundColor(.buttonText)
        }
    }

    private var progressBar: some View {
         VStack(spacing: 4) {
             ProgressView(value: progress)
                 .progressViewStyle(LinearProgressViewStyle(tint: Color.progressBarTint))
                 .scaleEffect(x: 1, y: 1.5, anchor: .center)
                 .background(Color.progressBarBackground.opacity(0.5))
                 .clipShape(Capsule())

             HStack {
                 Text(formatTimeCorrected(currentTime)) // Display current time
                 Spacer()
                 Text(formatTimeCorrected(currentTime, isRemaining: true)) // Display remaining time
             }
             .font(.caption2)
             .foregroundColor(.secondaryText)
         }
         .padding(.horizontal)
     }

    private var playbackControls: some View {
         HStack(spacing: 20) {
             Spacer()
             // Like Button
             Button {
                 isLiked.toggle()
                 if isLiked { isDisliked = false }
                 print("Action: Ad \(advertisement.id) Liked: \(isLiked)")
                 // Add network call or local save here if needed
             } label: {
                 Image(systemName: isLiked ? "hand.thumbsup.fill" : "hand.thumbsup")
                     .font(.title2)
                     .foregroundColor(isLiked ? .interactionHighlight : .primaryText)
             }.accessibilityLabel(isLiked ? Text("Unlike Ad") : Text("Like Ad"))

             // Previous (Disabled)
             Button {} label: { Image(systemName: "backward.end.fill").font(.title2) }
                 .disabled(true).opacity(0.5)

             // Play/Pause
             Button { togglePlayback() } label: {
                 Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                     .font(.system(size: 30))
                     .foregroundColor(Color.adBackground) // Use ad background color for contrast
                     .frame(width: 60, height: 60)
                     .background(Circle().fill(Color.primaryText)) // White background circle
             }.accessibilityLabel(isPlaying ? Text("Pause Ad") : Text("Play Ad"))

            // Next (Disabled)
            Button {} label: { Image(systemName: "forward.end.fill").font(.title2) }
                .disabled(true).opacity(0.5)

             // Dislike Button
             Button {
                 isDisliked.toggle()
                 if isDisliked { isLiked = false }
                 print("Action: Ad \(advertisement.id) Disliked: \(isDisliked)")
                 // Add network call or local save here
             } label: {
                  Image(systemName: isDisliked ? "hand.thumbsdown.fill" : "hand.thumbsdown")
                     .font(.title2)
                     .foregroundColor(isDisliked ? .interactionHighlight : .primaryText)
             }.accessibilityLabel(isDisliked ? Text("Remove Dislike") : Text("Dislike Ad"))

              Spacer()
         }
         .foregroundColor(.primaryText)
         .padding(.horizontal)
     }

    private var ctaBanner: some View {
         HStack {
             Text(advertisement.ctaText)
                 .font(.footnote)
                 .lineLimit(2)
                 .multilineTextAlignment(.leading)

             Spacer()

             Button("Learn more") {
                 print("Action: Opening URL \(advertisement.learnMoreURL) for ad \(advertisement.id)")
                 openURL(advertisement.learnMoreURL)
             }
             .font(.footnote)
             .fontWeight(.bold)
             .foregroundColor(.buttonText) // Text color for button
             .padding(.horizontal, 16)
             .padding(.vertical, 8)
             .background(Color.primaryText) // Background for button
             .cornerRadius(20)
         }
         .padding()
         .background(Color.ctaBackground) // Background for the whole banner
         .cornerRadius(12)
         .padding(.horizontal)
         .padding(.bottom, 20)
         .accessibilityElement(children: .combine)
     }

    // MARK: - Helper Functions

    private func togglePlayback() {
        isPlaying.toggle()
        if isPlaying {
            startTimerIfNeeded()
        } else {
            cancelTimer()
        }
        print("Playback Toggled: \(isPlaying ? "Playing" : "Paused")")
    }

    private func startTimerIfNeeded() {
        guard advertisement.duration > 0, isPlaying, timerSubscription == nil else { return } // Prevent starting if duration is 0 or already running/paused

        // Use the correct totalDuration now set from advertisement
        timerSubscription = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect().sink { _ in
            guard isPlaying else { return }

            if currentTime < totalDuration {
                currentTime += 0.1
                // Ensure progress doesn't exceed 1 due to timing inaccuracies
                progress = min(1.0, max(0.0, currentTime / totalDuration))
            } else {
                // Ad finished
                isPlaying = false
                currentTime = totalDuration
                progress = 1.0
                cancelTimer()
                print("Ad \(advertisement.id) finished playing.")
                // Consider auto-dismissing here after a small delay
                // DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { dismiss() }
            }
        }
        print("Timer Started for ad \(advertisement.id) with duration \(totalDuration)")
    }

    private func cancelTimer() {
        timerSubscription?.cancel()
        timerSubscription = nil
        print("Timer Cancelled for ad \(advertisement.id)")
    }

    // Corrected Time Formatter
    private func formatTimeCorrected(_ time: TimeInterval, isRemaining: Bool = false) -> String {
        // Use the state 'totalDuration' which is set from advertisement.duration
        let effectiveTime = isRemaining ? max(0, totalDuration - time) : time
        let totalSeconds = Int(effectiveTime.rounded(.down)) // Use floor to avoid showing 0:00 too early
        let seconds = totalSeconds % 60
        let minutes = totalSeconds / 60
        let sign = isRemaining ? "-": ""

        // Prevent showing negative time or incorrect values at the end
        if isRemaining && currentTime >= totalDuration {
            return "-0:00"
        }
        if !isRemaining && currentTime >= totalDuration {
             return String(format: "%d:%02d", Int(totalDuration) / 60, Int(totalDuration) % 60)
        }

        return String(format: "%@%d:%02d", sign, minutes, seconds)
    }
}

// MARK: - Preview Provider

#Preview("Standard Ad") {
    FunctionalAdvertisementView(advertisement: Advertisement.sampleAd)
}

#Preview("Ad with Text Logo") {
    FunctionalAdvertisementView(advertisement: Advertisement.sampleAdTextLogo)
}

#Preview("Ad with No Images") {
    FunctionalAdvertisementView(advertisement: Advertisement.sampleAdNoImages)
        .preferredColorScheme(.dark) // Preview dark mode too
}

