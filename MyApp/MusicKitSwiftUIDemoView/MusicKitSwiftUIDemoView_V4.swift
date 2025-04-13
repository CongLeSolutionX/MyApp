//
//  V4.swift
//  MyApp
//
//  Created by Cong Le on 4/13/25.
//

import SwiftUI
import CoreGraphics
import Foundation // Still needed for other parts potentially
import _MusicKit_SwiftUI

// --- Updated PlaceholderArtwork for Local Image ---
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
struct PlaceholderArtwork {
    var id = UUID()
    var backgroundColor: CGColor? = CGColor(red: 0.8, green: 0.8, blue: 0.85, alpha: 1.0)
    // --- NEW: Property for local image name ---
    var localImageName: String? = "My-meme-microphone" // Set to your asset name, or nil if none

    // maximumWidth/Height might still be relevant for layout hints, but not for loading
    var maximumWidth: Int = 1000
    var maximumHeight: Int = 1000

    // Remove mockUrl function - it's not needed for local assets
    // func mockUrl(width: Int, height: Int) -> Foundation.URL? { ... }
}

/// A View demonstrating the use of ArtworkImage (simulated with local assets).
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
struct ArtworkDisplayView: View {
    // Use the placeholder Artwork for demonstration
    let artwork: PlaceholderArtwork

    // Determine a fallback background color
    private var fallbackBackgroundColor: Color {
        Color(cgColor: artwork.backgroundColor ?? CGColor(gray: 0.5, alpha: 1.0))
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text("ArtworkImage Demo (Local)").font(.headline)

            // --- Updated Display Logic for Local Image ---
            ZStack { // Use ZStack to layer background color behind the image
                // Background color (placeholder)
                fallbackBackgroundColor

                // --- Load local image using Image(name) ---
                if let imageName = artwork.localImageName {
                    Image(imageName) // Load from Asset Catalog
                        .resizable()
                        .aspectRatio(contentMode: .fill) // Fill ensures it covers the frame
//                        .background(ignoresSafeAreaEdges: .all)
                } else {
                    // Fallback if no image name is provided
                    Image(systemName: "photo") // System placeholder icon
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(30) // Add padding to make the icon smaller
                        .foregroundColor(.secondary) // Make the icon gray
                }
            }
            .frame(width: 150, height: 150) // Apply frame to the ZStack
            .clipped() // Clip the image/icon to the frame bounds
            .clipShape(RoundedRectangle(cornerRadius: 8)) // Apply corner radius
            .shadow(radius: 5) // Apply shadow

            Text("Displays artwork from local assets.")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.top, 5)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemGray6))) // Background for visual separation
    }
}

// --- Rest of your file (PlaceholderMusicItemID, SubscriptionOfferView, etc.) ---
// Make sure PlaceholderMusicItemID is defined if needed by other views
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
struct PlaceholderMusicItemID: RawRepresentable, Equatable, Hashable, Sendable {
    var rawValue: String
    init(rawValue: String) {
        self.rawValue = rawValue
    }
}

@available(iOS 15.0, macOS 12.0, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
@available(visionOS, unavailable)
struct SubscriptionOfferView: View {
     @State private var isShowingSubscriptionOffer = false
     @State private var offerLoadError: Error? = nil
     @State private var subscriptionOfferOptions: MusicSubscriptionOffer.Options = {
         var options = MusicSubscriptionOffer.Options.default
         options.action = .subscribe
         options.messageIdentifier = .playMusic
         // options.itemID = PlaceholderMusicItemID(rawValue: "placeholder-album-id-123")
         options.affiliateToken = "YOUR_AFFILIATE_TOKEN"
         options.campaignToken = "YOUR_CAMPAIGN_TOKEN"
         return options
     }()

     var body: some View {
         VStack(alignment: .leading) {
             Text("Subscription Offer Modifier Demo").font(.headline)
             Button("Show Apple Music Offer") {
                 offerLoadError = nil
                 isShowingSubscriptionOffer = true
             }
             .buttonStyle(.borderedProminent)
             .padding(.bottom, 5)

             if let error = offerLoadError {
                 Text("Offer Load Error: \(error.localizedDescription)")
                     .font(.caption)
                     .foregroundColor(.red)
             } else {
                  Text("Presents a sheet offering an Apple Music subscription.")
                     .font(.caption)
                     .foregroundColor(.secondary)
             }
         }
         .padding()
         .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemGray6)))
         .musicSubscriptionOffer(
             isPresented: $isShowingSubscriptionOffer,
             options: subscriptionOfferOptions,
             onLoadCompletion: { error in
                 self.offerLoadError = error
                 if let error = error { print("Offer load failed: \(error)") }
             }
         )
     }
 }

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
struct MusicKitSwiftUIDemoView: View {
    // Now initializes with the default localImageName = "placeholder_artwork"
    private let sampleArtwork = PlaceholderArtwork(
        backgroundColor: CGColor(red: 0.2, green: 0.3, blue: 0.5, alpha: 1.0),
        localImageName: "placeholder_artwork" // Explicitly set your asset name here
    )
     // Or create one without an image name to test the fallback
    private let sampleArtworkNoImage = PlaceholderArtwork(
        backgroundColor: CGColor(red: 0.5, green: 0.2, blue: 0.3, alpha: 1.0),
        localImageName: nil
    )

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    ArtworkDisplayView(artwork: sampleArtwork) // Uses "placeholder_artwork"
                    // ArtworkDisplayView(artwork: sampleArtworkNoImage) // Test fallback

                    // Only show the subscription offer view on supported platforms
                    #if os(iOS) || os(macOS)
                    #if !os(tvOS) && !os(watchOS) && !os(visionOS)
                    SubscriptionOfferView()
                    #else
                     Text("Subscription Offer View not available here.") // Placeholder text
                         .font(.caption).foregroundColor(.secondary)
                         .padding().background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemGray6)))
                    #endif
                    #else
                     Text("Subscription Offer View not available here.") // Placeholder text
                         .font(.caption).foregroundColor(.secondary)
                         .padding().background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemGray6)))
                    #endif

                    Spacer() // Pushes content to the top
                }
                .padding()
            }
            .navigationTitle("MusicKit SwiftUI")
        }
    }
}

#if os(iOS) || os(macOS)
@available(iOS 15.0, macOS 12.0, *)
struct MusicKitSwiftUIDemoView_Previews: PreviewProvider {
    static var previews: some View {
        MusicKitSwiftUIDemoView()
    }
}
#endif
