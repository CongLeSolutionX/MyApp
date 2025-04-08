//
//  MusicAdView.swift
//  MyApp
//
//  Created by Cong Le on 4/8/25.
//

import SwiftUI

// Main View Structure replicating the ad screen
struct MusicAdView: View {
    // State variable to simulate progress (0.0 to 1.0)
    @State private var adProgress: Double = 0.15 // Example starting progress

    var body: some View {
        ZStack {
            // 1. Background Image/Video (Blurred)
            // Replace "backgroundImage" with your actual image asset name
            Image("backgroundImage") // Placeholder - Use your actual background
                .resizable()
                .scaledToFill()
                .blur(radius: 15) // Apply blur effect
                .edgesIgnoringSafeArea(.all) // Make it fill the entire screen

            // 2. Foreground Content Layer
            VStack(spacing: 15) { // Main vertical stack for UI elements
                // 2a. Top Bar (Info Text & More Options)
                HStack {
                    Text("Your music will continue after the break")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                    Spacer() // Pushes elements to sides
                    Image(systemName: "ellipsis")
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.horizontal)
                .padding(.top, 5) // Reduced top padding for closer alignment

                Spacer() // Pushes content down

                // 2b. Advertisement Info Section
                HStack(spacing: 12) {
                    // Ad Icon (Replace with actual asset)
                    Image(systemName: "dog.fill") // Placeholder using SF Symbol
                        .resizable()
                        .scaledToFit()
                        .frame(width: 45, height: 45)
                        .padding(5)
                        .background(Color.orange.opacity(0.8)) // Orange background like icon
                        .foregroundColor(.white)
                        .cornerRadius(8)

                    // Ad Text
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Waggery")
                            .font(.headline)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                        Text("Advertisement")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    Spacer() // Push ad info to the left
                }
                .padding(.horizontal)

                // 2c. Progress Bar & Timers
                VStack(spacing: 4) {
                    ProgressView(value: adProgress)
                        .progressViewStyle(LinearProgressViewStyle(tint: .white.opacity(0.8)))
                        .frame(height: 3) // Thin progress bar
                        .padding(.horizontal)

                    HStack {
                        Text("0:02") // Example current time
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.7))
                        Spacer()
                        Text("-0:15") // Example remaining time
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding(.horizontal)
                }

                // 2d. Playback Controls
                HStack(spacing: 30) {
                    Button {} label: {
                        Image(systemName: "hand.thumbsup") // Placeholder
                            .font(.title2)
                    }

                    Button {} label: {
                        Image(systemName: "backward.fill") // Placeholder
                            .font(.title2)
                    }

                    // Larger Pause Button
                    Button {} label: {
                        Image(systemName: "pause.fill") // Placeholder
                            .font(.system(size: 30))
                            .frame(width: 60, height: 60)
                            .background(Color.white)
                            .foregroundColor(.black)
                            .clipShape(Circle())
                    }

                    Button {} label: {
                        Image(systemName: "forward.fill") // Placeholder
                            .font(.title2)
                    }

                    Button {} label: {
                        Image(systemName: "hand.thumbsdown") // Placeholder
                            .font(.title2)
                    }
                }
                .foregroundColor(.white.opacity(0.9)) // Apply color to all buttons in HStack
                .padding(.vertical, 10)

                Spacer().frame(height: 20) // Add specific spacing before banner

                // 2e. Bottom Call-to-Action Banner
                HStack {
                    Text("Shop Waggery's wag-worthy toys and healthy dog food.")
                        .font(.footnote)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .lineLimit(2) // Allow text to wrap to two lines
                        .minimumScaleFactor(0.8) // Allow font to shrink if needed

                    Spacer()

                    Button("Learn more") {
                        // Action for Learn more button
                    }
                    .font(.footnote)
                    .fontWeight(.bold)
                    .foregroundColor(Color(red: 0.6, green: 0.2, blue: 0.1)) // Dark red text
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.white)
                    .clipShape(Capsule()) // Pill-shaped button
                }
                .padding()
                .background(Color(red: 0.7, green: 0.25, blue: 0.15)) // Reddish-brown background
                .cornerRadius(12)
                .padding(.horizontal) // Padding for the banner itself
                .padding(.bottom) // Bottom padding for the banner

            } // End Main VStack
//            .padding(.top, UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0) // Adjust for status bar
//            .padding(.bottom, UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0) // Adjust for home indicator/bottom safe area

        } // End ZStack
        .preferredColorScheme(.dark) // Suggest dark mode for system elements if needed
    }
}
// MARK: - Preview

#Preview("MusicAdView"){
    MusicAdView()
        .background(Image(systemName: "photo").resizable().scaledToFit().blur(radius: 15))
}

// Placeholder for the background image name
// In a real app, you'd load this from your assets
//#if DEBUG
//struct MusicAdView_Previews: PreviewProvider {
//    static var previews: some View {
//        // Create a dummy image for the preview if needed
//        MusicAdView()
//            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//             // Add a placeholder background for the preview
//            .background(Image(systemName: "photo").resizable().scaledToFill().blur(radius: 15))
//    }
//}

//// Dummy Persistence Controller for Preview
//struct PersistenceController {
//    static let preview = PersistenceController(inMemory: true)
//    let container: NSPersistentContainer
//
//    init(inMemory: Bool = false) {
//        container = NSPersistentContainer(name: "DummyModel") // Use a non-existent model name
//        if inMemory {
//            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
//        }
//        container.loadPersistentStores { _, _ in }
//        container.viewContext.automaticallyMergesChangesFromParent = true
//    }
//}
//#endif

// Helper to get safe area insets (optional, can use .ignoresSafeArea instead)
// Note: Accessing UIApplication like this is common but sometimes discouraged
// in pure SwiftUI. Often, GeometryReader or .ignoresSafeArea() are preferred.
