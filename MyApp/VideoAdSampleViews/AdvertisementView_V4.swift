//
//  AdvertisementView_V4.swift
//  MyApp
//
//  Created by Cong Le on 4/8/25.
//

import Foundation
import SwiftUI // Needed for ImageSource definition potentially

// Enum to define the source of an image (remote URL or local asset name)
enum ImageSource: Hashable { // Hashable might be useful later
    case remote(URL)
    case local(String) // Name of the asset in Assets.xcassets
    case none // Explicitly no image
}

// Updated Data model for an Advertisement
struct Advertisement: Identifiable {
    let id = UUID()
    let advertiserName: String
    let advertiserDescription: String
    let ctaText: String
    let learnMoreURL: URL
    let imageSource: ImageSource // Use the enum for the main image
    let logoSource: ImageSource  // Use the enum for the logo
    let logoText: String?        // Fallback text remains the same
    let duration: TimeInterval

    // --- Sample Data ---

    // Sample using Remote URLs (as before)
    static let sampleAdRemote = Advertisement(
        advertiserName: "Aura Botanicals",
        advertiserDescription: "Natural Skincare",
        ctaText: "Discover radiant skin. Shop now for 15% off.",
        learnMoreURL: URL(string: "https://www.example.com/aurabotanicals")!,
        imageSource: .remote(URL(string: "https://picsum.photos/seed/skincare/800/600")!), // Remote image
        logoSource: .remote(URL(string: "https://picsum.photos/seed/leaflogo/100/100")!),   // Remote logo
        logoText: "AB",
        duration: 18.0
    )

    // Sample using Local Asset Names
    // *** IMPORTANT: Make sure you have images named "local_ad_banner" and "local_brand_x_logo"
    // *** in your Assets.xcassets folder for this to work!
    static let sampleAdLocal = Advertisement(
        advertiserName: "Brand X Gear",
        advertiserDescription: "Outdoor Apparel",
        ctaText: "Adventure awaits. Gear up with Brand X.",
        learnMoreURL: URL(string: "https://www.example.com/brandx")!,
        imageSource: .local("My-meme-microphone.png"), // Local image asset name
        logoSource: .local("My-meme-original.png"),// Local logo asset name
        logoText: "BX", // Fallback if logo asset missing
        duration: 15.0
    )

    // Sample with a mix (Remote main image, Local logo)
     static let sampleAdMixed = Advertisement(
         advertiserName: "CloudNet Services",
         advertiserDescription: "Web Hosting",
         ctaText: "Reliable hosting, 24/7 support. Sign up!",
         learnMoreURL: URL(string: "https://www.example.com/cloudnet")!,
         imageSource: .remote(URL(string: "https://picsum.photos/seed/server/800/600")!), // Remote image
         logoSource: .local("local_cloud_logo"), // Local logo asset name
         logoText: "CN",
         duration: 22.0
     )

    // Sample with No Images (using .none)
    static let sampleAdNoImages = Advertisement(
        advertiserName: "Quantum Computing Inc.",
        advertiserDescription: "Cloud Solutions",
        ctaText: "Scale your business with our secure cloud platform.",
        learnMoreURL: URL(string: "https://www.example.com/quantumcloud")!,
        imageSource: .none, // No main image
        logoSource: .none, // No logo image
        logoText: "QC",
        duration: 12.5
    )

     // Sample with only Text Logo (no image source specified)
     static let sampleAdTextLogo = Advertisement(
        advertiserName: "Chef's Table Delivery",
        advertiserDescription: "Gourmet Meals",
        ctaText: "Fine dining delivered to your door. Order tonight!",
        learnMoreURL: URL(string: "https://www.example.com/chefstable")!,
        imageSource: .remote(URL(string: "https://picsum.photos/seed/foodad/800/600")!), // Has main image
        logoSource: .none, // Explicitly no logo image
        logoText: "CT", // Will use text logo
        duration: 25.0
     )
}

// MARK: -
import SwiftUI
import Combine

// --- Custom Colors (Keep as defined before) ---
extension Color {
    static let adBackground = Color(red: 139/255, green: 0/255, blue: 0/255)
    static let ctaBackground = Color.black.opacity(0.2)
    static let logoBackground = Color(red: 250/255, green: 235/255, blue: 215/255)
    static let primaryText = Color.white
    static let secondaryText = Color.white.opacity(0.7)
    static let progressBarTint = Color.white.opacity(0.8)
    static let progressBarBackground = Color.white.opacity(0.3)
    static let buttonText = Color(red: 50/255, green: 50/255, blue: 50/255)
    static let interactionHighlight = Color.green
    static let placeholderGray = Color.gray.opacity(0.5)
}

struct FunctionalAdvertisementView: View {
    // --- Environment & State (Keep as defined before) ---
    @Environment(\.dismiss) var dismiss
    @Environment(\.openURL) var openURL
    let advertisement: Advertisement
    @State private var isPlaying: Bool = true
    @State private var currentTime: TimeInterval = 0.0
    @State private var progress: Double = 0.0
    @State private var isLiked: Bool = false
    @State private var isDisliked: Bool = false
    @State private var showOptionsSheet: Bool = false
    @State private var totalDuration: TimeInterval = 15.0
    @State private var timerSubscription: Cancellable?

    var body: some View {
        ZStack {
            Color.adBackground.edgesIgnoringSafeArea(.all)
            VStack(spacing: 15) {
                topBar
                adImageView // Renamed for clarity
                advertiserInfoView // Renamed for clarity
                progressBar
                playbackControls
                Spacer()
                ctaBanner
            }
        }
        .onAppear {
            totalDuration = advertisement.duration
            startTimerIfNeeded()
        }
        .onDisappear(perform: cancelTimer)
        .actionSheet(isPresented: $showOptionsSheet) {
             // ActionSheet definition remains the same
             ActionSheet(
                 title: Text("Ad Options"),
                 message: Text("Interact with this ad from \(advertisement.advertiserName)"),
                 buttons: [
                     .default(Text("Why this ad?")) { /* Action */ },
                     .destructive(Text("Report Ad")) { /* Action */ },
                     .cancel()
                 ]
             )
         }
    }

    // MARK: - Subviews (Updated for ImageSource)

    // Top Bar remains the same
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

    // Updated View for the main Ad Image
    @ViewBuilder // Use @ViewBuilder to allow returning different view types
    private var adImageView: some View {
        Group { // Group necessary for @ViewBuilder structure
            switch advertisement.imageSource {
            case .remote(let url):
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty: imageLoadingPlaceholder()
                    case .success(let image):
                        image.resizable()
                             .aspectRatio(contentMode: .fit)
                             .cornerRadius(10)
                             .accessibilityLabel(Text("Advertisement image for \(advertisement.advertiserName)"))
                    case .failure: imageFailurePlaceholder()
                    @unknown default: EmptyView()
                    }
                }
            case .local(let name):
                // Assume local asset exists. SwiftUI's Image handles missing assets somewhat gracefully.
                Image(name)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(10)
                    .accessibilityLabel(Text("Advertisement image for \(advertisement.advertiserName)"))
                    // Add a check/placeholder if you want more robust handling of missing local assets
                    // .onAppear { checkAssetExists(name) } // Example hook

            case .none:
                imageFailurePlaceholder() // Use failure placeholder when no image source
            }
        }
        .padding(.horizontal)
    }

    // Placeholder Views for Ad Image
    private func imageLoadingPlaceholder() -> some View {
         ProgressView()
             .frame(maxWidth: .infinity, idealHeight: 250, maxHeight: 300) // Give it size
             .background(Color.placeholderGray.opacity(0.3))
             .cornerRadius(10)
     }

    private func imageFailurePlaceholder() -> some View {
         VStack {
            Image(systemName: "photo.fill")
                .font(.largeTitle)
                .foregroundColor(.placeholderGray)
            Text("Image unavailable")
                .font(.caption)
                .foregroundColor(.placeholderGray)
        }
        .frame(maxWidth: .infinity, idealHeight: 250, maxHeight: 300)
        .background(Color.placeholderGray.opacity(0.3))
        .cornerRadius(10)
    }

    // Updated View for Advertiser Info section
    private var advertiserInfoView: some View {
        HStack(spacing: 12) {
            advertiserLogoView // Extracted logo logic
                .frame(width: 50, height: 50)
                .background(Color.logoBackground)
                .cornerRadius(6)
                .clipped()

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

    // Extracted Advertiser Logo Logic
    @ViewBuilder
    private var advertiserLogoView: some View {
         switch advertisement.logoSource {
             case .remote(let url):
                 AsyncImage(url: url) { phase in
                     switch phase {
                         case .empty: ProgressView().tint(.buttonText) // Loading
                         case .success(let image): image.resizable().scaledToFit() // Display remote image
                     case .failure: fallbackLogoTextOrIcon // Fallback if remote fails
                     @unknown default: fallbackLogoTextOrIcon
                     }
                 }
             case .local(let name):
                 Image(name) // Display local image
                    .resizable()
                    .scaledToFit()
                    // You might add more checks here if needed
             case .none:
             fallbackLogoTextOrIcon // Fallback if source is none
         }
     }

    // Combined fallback logic for Logo: Text first, then icon
    @ViewBuilder
    private var fallbackLogoTextOrIcon: some View {
        if let text = advertisement.logoText, !text.isEmpty {
            Text(text)
                 .font(.system(size: 24).weight(.bold))
                 .foregroundColor(.buttonText)
                 .minimumScaleFactor(0.5)
                 .lineLimit(1)
        } else {
            // Default icon if no image source AND no text provided
            Image(systemName: "building.2")
                 .font(.title)
                 .foregroundColor(.buttonText)
        }
    }

    // --- ProgressBar, PlaybackControls, CTABanner (remain the same) ---
    private var progressBar: some View {
         VStack(spacing: 4) {
             ProgressView(value: progress)
                 .progressViewStyle(LinearProgressViewStyle(tint: Color.progressBarTint))
                 .scaleEffect(x: 1, y: 1.5, anchor: .center)
                 .background(Color.progressBarBackground.opacity(0.5))
                 .clipShape(Capsule())

             HStack {
                 Text(formatTimeCorrected(currentTime))
                 Spacer()
                 Text(formatTimeCorrected(currentTime, isRemaining: true))
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
              Button { isLiked.toggle(); if isLiked { isDisliked = false }; print("Liked") } label: {
                  Image(systemName: isLiked ? "hand.thumbsup.fill" : "hand.thumbsup")
                     .font(.title2).foregroundColor(isLiked ? .interactionHighlight : .primaryText)
              }.accessibilityLabel(isLiked ? Text("Unlike Ad") : Text("Like Ad"))

              // Previous (Disabled)
              Button {} label: { Image(systemName: "backward.end.fill").font(.title2) }
                  .disabled(true).opacity(0.5)

              // Play/Pause
              Button { togglePlayback() } label: {
                  Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                      .font(.system(size: 30)).foregroundColor(Color.adBackground)
                      .frame(width: 60, height: 60).background(Circle().fill(Color.primaryText))
              }.accessibilityLabel(isPlaying ? Text("Pause Ad") : Text("Play Ad"))

             // Next (Disabled)
             Button {} label: { Image(systemName: "forward.end.fill").font(.title2) }
                 .disabled(true).opacity(0.5)

              // Dislike Button
              Button { isDisliked.toggle(); if isDisliked { isLiked = false }; print("Disliked") } label: {
                   Image(systemName: isDisliked ? "hand.thumbsdown.fill" : "hand.thumbsdown")
                      .font(.title2).foregroundColor(isDisliked ? .interactionHighlight : .primaryText)
              }.accessibilityLabel(isDisliked ? Text("Remove Dislike") : Text("Dislike Ad"))

               Spacer()
          }
          .foregroundColor(.primaryText)
          .padding(.horizontal)
      }

    private var ctaBanner: some View {
          HStack {
              Text(advertisement.ctaText).font(.footnote).lineLimit(2).multilineTextAlignment(.leading)
              Spacer()
              Button("Learn more") { openURL(advertisement.learnMoreURL) }
                  .font(.footnote).fontWeight(.bold).foregroundColor(.buttonText)
                  .padding(.horizontal, 16).padding(.vertical, 8)
                  .background(Color.primaryText).cornerRadius(20)
          }
          .padding().background(Color.ctaBackground).cornerRadius(12)
          .padding(.horizontal).padding(.bottom, 20)
          .accessibilityElement(children: .combine)
      }

    // --- Helper Functions (togglePlayback, startTimerIfNeeded, cancelTimer, formatTimeCorrected - remain the same) ---
    private func togglePlayback() {
       isPlaying.toggle()
       if isPlaying { startTimerIfNeeded() } else { cancelTimer() }
       print("Playback Toggled: \(isPlaying ? "Playing" : "Paused")")
   }

   private func startTimerIfNeeded() {
       guard totalDuration > 0, isPlaying, timerSubscription == nil else { return }
       timerSubscription = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect().sink { _ in
           guard isPlaying else { return }
           if currentTime < totalDuration {
               currentTime += 0.1
               progress = min(1.0, max(0.0, currentTime / totalDuration))
           } else {
               isPlaying = false; currentTime = totalDuration; progress = 1.0; cancelTimer()
               print("Ad finished.")
           }
       }
       print("Timer Started (Duration: \(totalDuration))")
   }

   private func cancelTimer() {
       timerSubscription?.cancel(); timerSubscription = nil
       print("Timer Cancelled")
   }

   private func formatTimeCorrected(_ time: TimeInterval, isRemaining: Bool = false) -> String {
       let effectiveTime = isRemaining ? max(0, totalDuration - time) : time
       let totalSeconds = Int(effectiveTime.rounded(.down))
       let seconds = totalSeconds % 60
       let minutes = totalSeconds / 60
       let sign = isRemaining ? "-": ""
       if isRemaining && currentTime >= totalDuration { return "-0:00" }
       if !isRemaining && currentTime >= totalDuration { return String(format: "%d:%02d", Int(totalDuration) / 60, Int(totalDuration) % 60) }
       return String(format: "%@%d:%02d", sign, minutes, seconds)
   }
}

// MARK: - Preview Provider

#Preview("Remote Ad") {
    FunctionalAdvertisementView(advertisement: Advertisement.sampleAdRemote)
}

#Preview("Local Ad") {
    // Make sure "local_ad_banner" & "local_brand_x_logo" exist in Assets.xcassets
    FunctionalAdvertisementView(advertisement: Advertisement.sampleAdLocal)
}

#Preview("Mixed Source Ad") {
    // Make sure "local_cloud_logo" exists in Assets.xcassets
     FunctionalAdvertisementView(advertisement: Advertisement.sampleAdMixed)
}

#Preview("No Images Ad") {
    FunctionalAdvertisementView(advertisement: Advertisement.sampleAdNoImages)
}

#Preview("Text Logo Ad") {
    FunctionalAdvertisementView(advertisement: Advertisement.sampleAdTextLogo)
}
