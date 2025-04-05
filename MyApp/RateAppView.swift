//
//  RateAppView.swift
//  MyApp
//
//  Created by Cong Le on 4/4/25.
//

import SwiftUI
import StoreKit // Required for SKStoreReviewController if using that approach

// Placeholder for your actual App Store ID
let YOUR_APP_STORE_ID = "1234567890" // Replace with your real App ID

struct RateAppView: View {
    // Environment variable to dismiss the view if presented modally
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 25) {
            Spacer() // Pushes content towards the center

            Image(systemName: "star.leadinghalf.filled")
                .font(.system(size: 60))
                .foregroundColor(.yellow)
                .padding(.bottom, 10)

            Text("Enjoying the App?")
                .font(.title)
                .fontWeight(.bold)

            Text("Your feedback helps us improve and supports future development. Please take a moment to rate us on the App Store.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30) // Keep text lines from getting too long

            // Optional: Visual cue like stars
            HStack(spacing: 5) {
                ForEach(0..<5) { _ in
                    Image(systemName: "star.fill")
                        .foregroundColor(.orange)
                        .font(.title2)
                }
            }

            Spacer() // Pushes action buttons towards the bottom

            VStack(spacing: 15) {
                // Button to open App Store
                Button {
                    print("[RateAppView Action] User tapped 'Rate Now'. Attempting to open App Store.")
                    openAppStorePage()
                    // Optionally dismiss the view after tapping
                    // dismiss()
                } label: {
                    Text("Rate Now")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue) // Use an appropriate theme color
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }

                // Button to dismiss the view
                Button {
                    print("[RateAppView Action] User tapped 'Not Now'. Dismissing.")
                    dismiss() // Dismiss the view
                } label: {
                    Text("Not Now")
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10) // Less prominent padding
                        .foregroundColor(.secondary) // Less prominent color
                }
            }
            .padding(.horizontal, 30) // Add padding to the buttons
            .padding(.bottom, 40) // Add some space from the bottom edge

        }
        .navigationTitle("Rate Our App") // Title for the navigation bar if pushed
        .navigationBarTitleDisplayMode(.inline)
         .toolbar { // Optional: Add a close button if presented modally
             ToolbarItem(placement: .navigationBarLeading) {
                 Button("Close") {
                     dismiss()
                 }
             }
         }
    }

    // Function to construct and open the App Store URL
    private func openAppStorePage() {
        // Construct the App Store URL
        // Note: Replace YOUR_APP_STORE_ID with your actual App ID
        guard let writeReviewURL = URL(string: "https://apps.apple.com/app/id\(YOUR_APP_STORE_ID)?action=write-review") else {
            print("[RateAppView Error] Could not create App Store URL.")
            // Optionally show an alert to the user here
            return
        }

         // Construct the general App Store product page URL as a fallback
         guard let productURL = URL(string: "https://apps.apple.com/app/id\(YOUR_APP_STORE_ID)") else {
             print("[RateAppView Error] Could not create App Store product URL.")
             return
         }

        // Check if the device can open the URL scheme
        if UIApplication.shared.canOpenURL(writeReviewURL) {
            print("[RateAppView Info] Opening App Store write review URL: \(writeReviewURL)")
            UIApplication.shared.open(writeReviewURL, options: [:]) { success in
                if success {
                     print("[RateAppView Info] Successfully opened App Store write review page.")
                 } else {
                     print("[RateAppView Error] Failed to open App Store write review page, trying product page.")
                     // Fallback to product page if write review fails
                     UIApplication.shared.open(productURL, options: [:]) { productSuccess in
                          if productSuccess {
                               print("[RateAppView Info] Successfully opened App Store product page as fallback.")
                           } else {
                               print("[RateAppView Error] Failed to open App Store product page as fallback.")
                           }
                     }
                 }
            }
        } else {
             print("[RateAppView Error] Cannot open App Store URLs. Attempting product page directly.")
             // If cannot open write review, attempt product page directly
             if UIApplication.shared.canOpenURL(productURL) {
                 UIApplication.shared.open(productURL, options: [:]) { productSuccess in
                     if productSuccess {
                          print("[RateAppView Info] Successfully opened App Store product page (direct attempt).")
                      } else {
                          print("[RateAppView Error] Failed to open App Store product page (direct attempt).")
                      }
                 }
             } else {
                 print("[RateAppView Error] Cannot open any App Store URL (product or review).")
                 // Optionally show an alert to the user here
             }
        }

        /*
         // Alternative using SKStoreReviewController (Recommended by Apple):
         // This presents a standardised prompt *within* the app,
         // but Apple controls when/if it's actually shown to the user.
         if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
             print("[RateAppView Info] Requesting in-app review using SKStoreReviewController.")
             SKStoreReviewController.requestReview(in: scene)
         } else {
              print("[RateAppView Error] Could not find active UIWindowScene for SKStoreReviewController.")
              // Fallback to opening URL if SKStoreReviewController fails
             // openAppStorePage() // Could call the URL opening method here as fallback
         }
        */
    }
}

// MARK: - Preview Provider
struct RateAppView_Previews: PreviewProvider {
    static var previews: some View {
        // Wrap in NavigationView for preview context
        NavigationView {
            RateAppView()
        }
        .preferredColorScheme(.light) // Preview in light mode

        NavigationView {
            RateAppView()
        }
        .preferredColorScheme(.dark) // Preview in dark mode
    }
}
