////
////  MusicKitSwiftUIDemoView_V2.swift
////  MyApp
////
////  Created by Cong Le on 4/13/25.
////
//import SwiftUI
//// Make sure CoreGraphics is imported if not already globally available
//import CoreGraphics
//import _MusicKit_SwiftUI
//
//// --- Placeholder Artwork structure (assuming it's defined as before) ---
//@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
//struct PlaceholderArtwork {
//    var id = UUID()
//    var backgroundColor: CGColor? = CGColor(red: 0.8, green: 0.8, blue: 0.85, alpha: 1.0)
//    var maximumWidth: Int = 1000
//    var maximumHeight: Int = 1000
//
//    // Mock function to simulate MusicKit.Artwork.url(width:height:)
//    func mockUrl(width: Int, height: Int) -> URL? {
//        let symbolSize = min(width, height)
//        return URL(string: "https://via.placeholder.com/\(symbolSize)")
//    }
//}
//
//
///// A View demonstrating the use of `ArtworkImage`.
//@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
//struct ArtworkDisplayView: View {
//    // Use the placeholder Artwork for demonstration
//    let artwork: PlaceholderArtwork
//
//    var body: some View {
//        VStack(alignment: .leading) {
//            Text("ArtworkImage Demo").font(.headline)
//
//            // --- ArtworkImage Usage ---
//            // In a real app, you would pass a genuine MusicKit.Artwork object.
//            // Since we can't instantiate MusicKit.Artwork directly here and need
//            // an actual view builder, we'll simulate its appearance using our placeholder.
//            // The real ArtworkImage view handles loading and placeholder display internally.
//
//            // --- FIX 1: Pass optional URL directly to AsyncImage ---
//            // Remove the 'if let' check, as AsyncImage handles nil URLs.
//            let artworkURL = artwork.mockUrl(width: 150, height: 150)
//
//            // Simulate asynchronous loading (placeholder shown meanwhile)
//            AsyncImage(url: artworkURL) { phase in // Pass optional URL directly
//                switch phase {
//                case .empty:
//                    // Placeholder matching the real ArtworkImage behavior
//                    Rectangle()
//                        // --- FIX 2: Use a valid CGColor fallback ---
//                        .fill(Color(cgColor: artwork.backgroundColor ?? CGColor(gray: 0.5, alpha: 1.0))) // Use a gray CGColor
//                        .frame(width: 150, height: 150)
//                        .overlay(ProgressView()) // Show loading indicator
//                case .success(let image):
//                    image
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//                        .frame(width: 150, height: 150)
//                case .failure:
//                    // Error placeholder
//                    Rectangle()
//                        .fill(Color.red.opacity(0.5))
//                        .frame(width: 150, height: 150)
//                        .overlay(Image(systemName: "exclamationmark.triangle.fill"))
//                @unknown default:
//                    EmptyView()
//               }
//            }
//            .frame(width: 150, height: 150) // Apply frame to the AsyncImage container
//            .clipShape(RoundedRectangle(cornerRadius: 8)) // Style it slightly
//            .shadow(radius: 5)
//
//            Text("Displays artwork. Shows a background-colored placeholder while loading.")
//                .font(.caption)
//                .foregroundColor(.secondary)
//                .padding(.top, 5)
//        }
//        .padding()
//        .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemGray6))) // Background for visual separation
//    }
//}
//
//// Rest of your file (SubscriptionOfferView, MusicKitSwiftUIDemoView, Previews) remains the same
//// ... (Include the PlaceholderMusicItemID and SubscriptionOfferView, etc. from the previous correct code)
//
//@available(iOS 15.0, macOS 12.0, *)
//@available(tvOS, unavailable)
//@available(watchOS, unavailable)
//@available(visionOS, unavailable) // Check visionOS availability for musicSubscriptionOffer if needed
//struct SubscriptionOfferView: View {
//    @State private var isShowingSubscriptionOffer = false
//    @State private var offerLoadError: Error? = nil
//
//    // --- MusicSubscriptionOffer.Options Configuration ---
//    // Configure options for the subscription sheet
//    @State private var subscriptionOfferOptions: MusicSubscriptionOffer.Options = {
//        var options = MusicSubscriptionOffer.Options.default // Start with default options
//
//        // Customize the entry point action if needed
//        options.action = .subscribe // Default is .subscribe
//
//        // Customize the message presented to the user
//        options.messageIdentifier = .playMusic // e.g., If triggered by trying to play content
//
//        // If the offer is triggered by a specific item, provide its ID
//        // options.itemID = PlaceholderMusicItemID(rawValue: "placeholder-album-id-123") // Example
//
//        // Set your affiliate and campaign tokens if applicable
//        options.affiliateToken = "YOUR_AFFILIATE_TOKEN" // Replace with your actual token
//        options.campaignToken = "YOUR_CAMPAIGN_TOKEN"   // Replace with your actual token
//
//        return options
//    }()
//
//    var body: some View {
//        VStack(alignment: .leading) {
//            Text("Subscription Offer Modifier Demo").font(.headline)
//
//            Button("Show Apple Music Offer") {
//                // Reset error state before showing
//                offerLoadError = nil
//                // --- Triggering the Modifier ---
//                // Set the binding to true to present the sheet
//                isShowingSubscriptionOffer = true
//            }
//            .buttonStyle(.borderedProminent)
//            .padding(.bottom, 5)
//
//            if let error = offerLoadError {
//                Text("Offer Load Error: \(error.localizedDescription)")
//                    .font(.caption)
//                    .foregroundColor(.red)
//            } else {
//                 Text("Presents a sheet offering an Apple Music subscription. Configurable with options.")
//                    .font(.caption)
//                    .foregroundColor(.secondary)
//            }
//        }
//        .padding()
//        .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemGray6))) // Background for visual separation
//        // --- Attaching the Modifier ---
//        .musicSubscriptionOffer(
//            isPresented: $isShowingSubscriptionOffer, // Binding to control presentation
//            options: subscriptionOfferOptions,         // Pass the configured options
//            onLoadCompletion: { error in              // Optional completion handler
//                // This closure is called when the sheet finishes loading
//                // or if an error occurs during loading.
//                // The sheet is presented ONLY if error is nil.
//                if let error = error {
//                    print("Failed to load subscription offer: \(error)")
//                    self.offerLoadError = error
//                    // isPresented is automatically set back to false by the modifier on error
//                } else {
//                    print("Subscription offer loaded and presented successfully.")
//                    self.offerLoadError = nil
//                }
//            }
//        )
//    }
//}
//
//@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
//struct MusicKitSwiftUIDemoView: View {
//    // Create a sample placeholder artwork
//    private let sampleArtwork = PlaceholderArtwork(
//        backgroundColor: CGColor(red: 0.2, green: 0.3, blue: 0.5, alpha: 1.0)
//    )
//
//    var body: some View {
//        NavigationView {
//            ScrollView {
//                VStack(spacing: 20) {
//                    ArtworkDisplayView(artwork: sampleArtwork)
//
//                    // Only show the subscription offer view on supported platforms
//                    #if os(iOS) || os(macOS)
//                    // Ensure visionOS availability if needed
//                    #if !os(tvOS) && !os(watchOS) && !os(visionOS)
//                    SubscriptionOfferView()
//                    #else
//                    Text("Subscription Offer View not available on this platform.")
//                         .font(.caption)
//                         .foregroundColor(.secondary)
//                         .padding()
//                         .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemGray6)))
//                    #endif
//                    #else
//                     Text("Subscription Offer View not available on this platform.")
//                         .font(.caption)
//                         .foregroundColor(.secondary)
//                         .padding()
//                         .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemGray6)))
//                    #endif
//
//                    Spacer() // Pushes content to the top
//                }
//                .padding()
//            }
//            .navigationTitle("MusicKit SwiftUI")
//        }
//    }
//}
//
//
//#if os(iOS) || os(macOS)
//@available(iOS 15.0, macOS 12.0, *)
//struct MusicKitSwiftUIDemoView_Previews: PreviewProvider {
//    static var previews: some View {
//        MusicKitSwiftUIDemoView()
//    }
//}
//#endif
