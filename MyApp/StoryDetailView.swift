//
//  V4.swift
//  MyApp
//
//  Created by Cong Le on 4/5/25.
//

import SwiftUI

// MARK: - Data Models (Keep Existing Models)

struct StoryPreview: Identifiable {
    let id = UUID()
    let imageName: String // Used for thumbnail in the first screen
    var isAddButton: Bool = false

    // Keep properties potentially useful for Detail View, even if not used in *this specific* new design
    let detailImageName: String // Might be used for the vinyl center
    let userName: String // Not used in new design, but keep for model consistency
    let userProfileImage: String // Not used in new design
    let timestamp: String // Not used in new design

    // Add properties needed by the *new* Detail View Design
    let songTitle: String? // Example: "Magnificent"
    let artistName: String? // Example: "Pufino"
    let vinylCenterImageName: String? // Specific image for the center of the vinyl
}

struct Viewer: Identifiable {
    let id = UUID()
    let name: String
    let profileImageName: String
    let source: String? = nil
}

// MARK: - Main Insights View (No changes needed here for this request)
// ... (StoryInsightsView and its subviews remain as before) ...
// We'll paste the updated StoryDetailView and its new subviews below.

// MARK: - Updated Story Detail View & New Subviews

struct StoryDetailView: View {
    let story: StoryPreview // Pass the story data, including potential song info
    @Environment(\.dismiss) var dismiss // Environment variable to dismiss the modal

     // Helper to get safe area insets (can be useful for precise positioning)
//     private var safeAreaInsets: EdgeInsets {
//         (UIApplication.shared.connectedScenes.first as? UIWindowScene)?
//             .windows.first?.safeAreaInsets ?? EdgeInsets()
//     }

    var body: some View {
        ZStack {
            // 1. Background Gradient
            GradientBackgroundView()
                .edgesIgnoringSafeArea(.all)

            // 2. Main Content Layer
            VStack(spacing: 0) {
                 // Top Bar (Just the Back Button)
                 HStack {
                      BackButton(action: { dismiss() })
                      Spacer() // Pushes back button to the left
                 }
                 .padding(.horizontal)
//                 .padding(.top, safeAreaInsets.top) // Respect safe area top
                  .padding(.bottom, 10) // Add some space below the back button


                 Spacer() // Pushes central content down

                // Central Content (Vinyl + Text)
                VStack(spacing: 15) {
                    VinylRecordView(
                        centerImageName: story.vinylCenterImageName ?? story.detailImageName // Fallback
                    )
                    // Add rotation animation if desired later
                    // .rotationEffect(.degrees(isPlaying ? 360 : 0))

                    // Song Info Text
                    if let title = story.songTitle, let artist = story.artistName {
                        VStack {
                            Text(title)
                                .font(.title2)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                            Text(artist)
                                .font(.body)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                }
                 .padding(.horizontal, 40) // Give vinyl some horizontal space

                Spacer() // Pushes bottom controls down

                 // Bottom Controls Bar
                 BottomControlsView()
                      .padding(.horizontal)
                      // Use max of safe area bottom or default padding
//                      .padding(.bottom, max(safeAreaInsets.bottom, 15))


            } // End of Main VStack

            // 3. Overlay for Right-Side Toolbar
             SideToolbarView()
                .padding(.trailing)
                 // Position below top safe area, adjust vertical offset as needed
//                 .padding(.top, safeAreaInsets.top + 60) // Example offset


        }
         .navigationBarHidden(true) // Hide the default navigation bar
         .statusBar(hidden: false) // Keep status bar visible
         // .preferredColorScheme(.dark) // Enforce dark mode if needed
    }
}

// MARK: - New Subviews for Updated StoryDetailView

struct GradientBackgroundView: View {
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 247/255, green: 214/255, blue: 194/255).opacity(0.9), // Light Peach/Orange Top
                Color(red: 224/255, green: 179/255, blue: 196/255).opacity(0.8), // Pinkish Middle
                Color(red: 100/255, green: 91/255, blue: 120/255).opacity(0.9), // Purplish Mid-Bottom
                Color(red: 60/255, green: 60/255, blue: 80/255) // Darker Purple/Blue Bottom
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

struct BackButton: View {
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "chevron.left")
                .font(.title2)
                .foregroundColor(.white)
                .padding(10)
                .background(Color.black.opacity(0.3))
                .clipShape(Circle())
        }
    }
}

struct VinylRecordView: View {
    let centerImageName: String
    // You might add @State for rotation animation later
    // @State private var rotationDegrees: Double = 0

    var body: some View {
        ZStack {
            // Vinyl Texture Background (Replace "vinyl_record" with your actual asset)
            Image("vinyl_record") // <<-- !! ADD THIS ASSET !!
                .resizable()
                .scaledToFit()
                 // Make vinyl slightly smaller than screen width with padding
                .padding(.horizontal, 20)


            // Center Image (Make sure this asset exists)
            Image(centerImageName)
                .resizable()
                 // Scale to fill a circular area proportional to the vinyl size
                .scaledToFill()
                 // Adjust frame size relative to the vinyl image size
                 // This requires knowing the vinyl image's aspect ratio or size
                 // Example: Make center circle roughly 40% of the vinyl width
                 .frame(width: UIScreen.main.bounds.width * 0.7 * 0.4,
                        height: UIScreen.main.bounds.width * 0.7 * 0.4)
                .clipShape(Circle())
        }
         // Add animation modifier later if needed
         // .rotationEffect(.degrees(rotationDegrees))
         // .onAppear {
         //     withAnimation(.linear(duration: 5).repeatForever(autoreverses: false)) {
         //         rotationDegrees = 360
         //     }
         // }
    }
}

struct SideToolbarView: View {
     // Placeholder system names - replace with actual icons if needed
     let icons = [
         "face.smiling", // Placeholder for smiley menu
         "textformat.alt", // Placeholder for Aa
         "photo", // Placeholder for Image/Sticker
         "waveform.path", // Placeholder for sound wave/music
         "slider.horizontal.3", // Placeholder for effects/adjustments
         "tag", // Placeholder for tag person
         "circle.dashed" // Placeholder for filter/effect intensity
     ]

    var body: some View {
        VStack(alignment: .trailing, spacing: 18) { // Align to trailing edge, add spacing
            ForEach(icons, id: \.self) { iconName in
                Button {
                    print("\(iconName) button tapped")
                } label: {
                    Image(systemName: iconName)
                        .font(.system(size: 20)) // Adjust icon size
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40) // Ensure consistent button size
                        .background(Color.black.opacity(0.35))
                        .clipShape(Circle())
                }
            }
        }
    }
}


struct BottomControlsView: View {
    var body: some View {
        HStack(spacing: 10) {
            // Settings Button
            Button {
                print("Settings tapped")
            } label: {
                Image(systemName: "gearshape")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(10) // Add padding for better tap area
            }

            Spacer() // Pushes Subscribers/Share buttons apart from Settings

            // Subscribers Button
             Button {
                 print("Subscribers tapped")
             } label: {
                 Label {
                     Text("Subscribers")
                         .fontWeight(.semibold)
                 } icon: {
                      // Custom filled heart (replace 'heart.fill.black' if needed)
                      Image(systemName: "heart.fill")
                           .imageScale(.small) // Make icon slightly smaller
                 }
                 .foregroundColor(.black)
                 .padding(.vertical, 10)
                 .padding(.horizontal, 15)
                 .background(Color.white)
                 .cornerRadius(8) // Slightly rounded corners
             }

            Spacer() // Add a smaller spacer or adjust main HStack spacing

             // Share Button
            ZStack(alignment: .bottomTrailing) { // Use ZStack for overlay
                 Button {
                      print("Share tapped")
                 } label: {
                      Label {
                          Text("Share")
                              .fontWeight(.semibold)
                      } icon: {
                          Image(systemName: "globe") // Globe icon
                      }
                      .foregroundColor(.white)
                      .padding(.vertical, 10)
                      .padding(.leading, 15)
                      .padding(.trailing, 35) // Extra trailing padding for the overlay icons
                      .background(Color.blue) // Blue background
                      .cornerRadius(8)
                 }

                 // Overlay for FB/Insta Icons
                 HStack(spacing: -8) { // Overlap icons slightly
                      Image("facebook_icon_small") // <<-- !! ADD THIS ASSET (small circle) !!
                           .resizable()
                           .frame(width: 20, height: 20)
                           .clipShape(Circle())
                           .overlay(Circle().stroke(Color.black, lineWidth: 1.5)) // Border like screenshot


                      Image("instagram_icon_small") // <<-- !! ADD THIS ASSET (small circle) !!
                           .resizable()
                           .frame(width: 20, height: 20)
                           .clipShape(Circle())
                            .overlay(Circle().stroke(Color.black, lineWidth: 1.5)) // Border like screenshot

                 }
                 // Offset the icons slightly to match the screenshot position
                 .offset(x: -5, y: 5)
            }


            Spacer() // Push Share button to the right

        } // End of HStack
    }
}

// MARK: - Previews

// Preview for the main Insights/Viewers screen (remains unchanged)
struct StoryInsightsView_Previews: PreviewProvider {
    static var previews: some View {
        // ... (Previews for StoryInsightsView remain the same) ...

        // Updated Preview for StoryDetailView
        StoryDetailViewPreviewWrapper()
            .previewDisplayName("Story Detail (New Design)")
    }
}

// Wrapper for previewing StoryDetailView with sample data
struct StoryDetailViewPreviewWrapper: View {
     // Create sample data matching the new design's needs
     let sampleStory = StoryPreview(
         imageName: "story_placeholder_1", // Thumbnail on first screen
         detailImageName: "mountains_bg",    // Used as fallback for vinyl center
         userName: "Cong Le",
         userProfileImage: "profile_placeholder",
         timestamp: "4h",
         songTitle: "Magnificent",           // New data
         artistName: "Pufino",             // New data
         vinylCenterImageName: "mountains_bg" // <<-- !! ADD THIS ASSET (for vinyl center) !!
     )

     var body: some View {
          StoryDetailView(story: sampleStory)
               // You might want dark mode for preview accuracy
               // .preferredColorScheme(.dark)
     }
}


// MARK: - IMPORTANT Placeholders & Assets

/*
 !! Add the following image assets to your Assets.xcassets !!

 FOR FIRST SCREEN (No changes needed unless you changed previews):
 - story_placeholder_1
 - story_placeholder_2
 - story_placeholder_detail_1 (now less critical if not used as vinyl fallback)
 - story_placeholder_detail_2 (now less critical if not used as vinyl fallback)
 - profile_placeholder (no longer used in new detail view, but keep for first screen)

 NEW ASSETS FOR UPDATED DETAIL VIEW:
 - vinyl_record           (Texture/image of the black vinyl disc)
 - mountains_bg           (Example image for the vinyl center - replace with your actual asset)
 - facebook_icon_small    (Small circular Facebook logo)
 - instagram_icon_small   (Small circular Instagram logo)

 * If you don't add these, the Image views will be empty or show
   system placeholders. Replace placeholder names with your actual asset names.
 * The vinyl center image (`mountains_bg` in the example) should ideally match
   the visual theme of the background gradient or the story's content.
 */
