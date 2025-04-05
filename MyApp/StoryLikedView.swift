//
//  StoryLikedView.swift
//  MyApp
//
//  Created by Cong Le on 4/5/25.
//

import SwiftUI

struct StoryLikedView: View {
    var body: some View {
        // Main container
        VStack(spacing: 0) {
            // 1. Top Navigation Area
            HStack {
                // Back Button
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(.leading)

                Spacer() // Pushes profile icons to the right

                // Profile Icons Group
                HStack(spacing: -10) { // Negative spacing for overlap
                    // Placeholder profile images - replace with actual data
                    ProfileIconView(imageName: "person.crop.circle.fill", showHeart: true)
                    ProfileIconView(imageName: "person.crop.circle.fill", showHeart: true)
                    ProfileIconView(imageName: "person.crop.circle.fill", showHeart: true)

                    // Next Button within the group
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .padding(5)
                        .background(Color.gray.opacity(0.5))
                        .clipShape(Circle())
                        .foregroundColor(.white)
                        .padding(.leading, 15) // Space before chevron
                }

                Spacer().frame(width: 15) // Add some padding on the right

            }
            .frame(height: 44) // Standard navigation bar height

            // 2. Content Area
            VStack(alignment: .leading, spacing: 8) {
                Text("People liked your story")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)

                Text("Build on your momentum and reach more people by turning it into a reel.")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                    .lineLimit(2) // Limit to two lines
            }
            .padding(.horizontal)
            .padding(.top, 20)
            .padding(.bottom, 20)

            // 3. Story Preview
            ZStack(alignment: .topTrailing) {
                // Placeholder for the actual story content (Image/Video)
                Image("storyPlaceholder") // << Replace with your story image asset name
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 450) // Adjust height as needed
                    .clipped() // Clip to bounds
                    .cornerRadius(15)

                // Music Sticker Overlay
                MusicStickerView()
                    .padding(10) // Padding from the corner

            }
            .padding(.horizontal)

            Spacer() // Pushes the button and tab bar down

            // 4. Call to Action Button
            Button {
                // Action for Create Reel
                print("Create Reel button tapped")
            } label: {
                Text("Create reel")
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                    .padding(.vertical, 15)
                    .padding(.horizontal, 40) // Adjust padding for desired width
                    .frame(minWidth: 0, maxWidth: .infinity) // Make background span
            }
            .background(Color.white)
            .clipShape(Capsule()) // Pill shape
            .padding(.horizontal, 50) // Overall horizontal padding for the button
            .padding(.bottom, 20)

            // 5. Bottom Tab Bar (Simulated)
            Divider() // Optional divider above tab bar
                .background(Color.gray.opacity(0.5))

            HStack {
                TabBarIcon(iconName: "house.fill")
                Spacer()
                TabBarIcon(iconName: "magnifyingglass")
                Spacer()
                TabBarIcon(iconName: "plus.app") // Or plus.square
                Spacer()
                TabBarIcon(iconName: "play.tv") // Or film
                Spacer()
                 // Placeholder profile icon
                Image("profilePlaceholder") // << Replace with your profile image asset name
                     .resizable()
                     .aspectRatio(contentMode: .fill)
                     .frame(width: 28, height: 28)
                     .clipShape(Circle())
                     .overlay(Circle().stroke(Color.white, lineWidth: 1)) // Optional border
                     .overlay( // Red dot indicator
                        Circle()
                           .fill(Color.red)
                           .frame(width: 6, height: 6)
                           .offset(x: 10, y: 12) // Adjust position
                     )
            }
            .padding(.horizontal, 20)
            .frame(height: 50) // Standard tab bar height
            .background(Color.black) // Tab bar background

        }
        .background(Color.black.ignoresSafeArea()) // Dark background for the whole view
        .ignoresSafeArea(.container, edges: .bottom) // Allow tab bar to touch bottom edge
        .preferredColorScheme(.dark) // Force dark mode for preview
    }
}

// Helper View for Profile Icons with Heart
struct ProfileIconView: View {
    let imageName: String
    let showHeart: Bool

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Image(systemName: imageName) // Use system name for placeholder
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 30, height: 30)
                .clipShape(Circle())
                .padding(1) // Small padding to make overlay visible
                .background(Circle().fill(Color.black)) // Background to match theme
                .overlay(Circle().stroke(Color.white, lineWidth: 1.5)) // White border

            if showHeart {
                Image(systemName: "heart.fill")
                    .foregroundColor(.red)
                    .font(.system(size: 12))
                    .padding(3)
                    .background(Circle().fill(Color.black.opacity(0.5))) // Slight dark background for contrast
                    .offset(x: 2, y: 2) // Adjust position of heart
            }
        }
    }
}

// Helper View for Music Sticker
struct MusicStickerView: View {
     var body: some View {
         HStack(spacing: 8) {
             Image("albumArtPlaceholder") // << Replace with your album art asset name
                 .resizable()
                 .aspectRatio(contentMode: .fill)
                 .frame(width: 35, height: 35)
                 .cornerRadius(4)

             VStack(alignment: .leading, spacing: 2) {
                 Text("EMOTIONAL FLOW")
                     .font(.system(size: 10, weight: .bold))
                     .foregroundColor(.white)
                 Text("♫ CHILLOUT DEEP")
                      .font(.system(size: 9))
                      .foregroundColor(.white.opacity(0.8))
             }
         }
         .padding(.horizontal, 8)
         .padding(.vertical, 6)
         .background(.ultraThinMaterial) // Use a material background for blur effect
         .cornerRadius(8)
     }
}

// Helper View for Tab Bar Icons
struct TabBarIcon: View {
    let iconName: String

    var body: some View {
        Image(systemName: iconName)
            .font(.system(size: 24)) // Adjust icon size
            .foregroundColor(.white)
    }
}

// --- Preview ---
struct StoryLikedView_Previews: PreviewProvider {
    static var previews: some View {
        // Add placeholder images to your Assets.xcassets for the preview to work
        // Naming convention: "storyPlaceholder", "albumArtPlaceholder", "profilePlaceholder"
        StoryLikedView()
           // Ensure you have placeholder assets in your project
           // Example: Create color assets named accordingly if you don't have images
//           .environment(\.colorScheme, .dark) // Preview in dark mode

    }
}

// Add placeholder images to your Assets.xcassets:
// 1. "storyPlaceholder" (e.g., a generic image or the one from the screenshot)
// 2. "albumArtPlaceholder" (e.g., a small square image)
// 3. "profilePlaceholder" (e.g., a small circular image or a default avatar)
// If you don't have images, you can create Color assets with these names
// and replace Image(...) with Rectangle().fill(Color("assetName")) temporarily.
