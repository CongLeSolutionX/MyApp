//
//  HomeView.swift
//  MyApp
//
//  Created by Cong Le on 4/2/25.
//

import SwiftUI

// MARK: - Data Structures (Optional, for clarity)

struct ProfileStats {
    let posts: Int
    let followers: String // Using String for "k" or "m" if needed
    let following: Int
}

struct Highlight: Identifiable {
    let id = UUID()
    let imageName: String // Use system names or asset names
    let title: String
    let isNewButton: Bool = false // Special case for the first item
}

// MARK: - Sample Data

let sampleStats = ProfileStats(posts: 231, followers: "479", following: 2774)

let sampleHighlights: [Highlight] = [
    Highlight(imageName: "plus", title: "New"),
    Highlight(imageName: "person.fill", title: "Pretty Girls..."), // Placeholders
    Highlight(imageName: "figure.wave", title: "Cyberpunk..."),
    Highlight(imageName: "building.columns.fill", title: "Hong Kong..."),
    Highlight(imageName: "brain.head.profile", title: "I asked AI..."),
    Highlight(imageName: "photo.artframe", title: "Travel")
]

// MARK: - Reusable Components

struct ProfileStatView: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary) // Adapts to light/dark
            Text(label)
                .font(.system(size: 13))
                .foregroundColor(.primary)
        }
        .frame(width: 80) // Give stats items some consistent width
    }
}

struct ProfileActionButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity)
                .frame(height: 32) // Explicit height
                .background(Color(UIColor.systemGray5)) // Similar background to screenshot
                .cornerRadius(8)
        }
    }
}

struct HighlightItemView: View {
    let item: Highlight

    var body: some View {
        VStack(spacing: 5) {
            ZStack {
                Circle()
                     // Slightly inset the background circle if it's not the 'New' button
                    .fill(item.isNewButton ? Color.clear : Color(UIColor.systemGray4))
                    .frame(width: 64, height: 64) // Background size

                // Display image or plus icon
                if item.isNewButton {
                    Image(systemName: item.imageName)
                        .font(.system(size: 28, weight: .thin))
                         .foregroundColor(.primary) // Color of the plus
                         .frame(width: 60, height: 60) // Icon container
                         .background(Color(UIColor.systemGray5)) // Background for the plus
                         .clipShape(Circle())
                           .overlay(
                                Circle().stroke(Color(UIColor.systemGray3), lineWidth: 1) // Border for plus
                           )
                } else {
                    Image(systemName: item.imageName) // Use asset name if needed: Image(item.imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())
                        .overlay(
                             // Add a subtle border around actual highlights if desired
                              Circle().stroke(Color.gray.opacity(0.5), lineWidth: 0.5)
                            )
                }
            }

            Text(item.title)
                .font(.system(size: 12))
                .foregroundColor(.primary)
                .lineLimit(1) // Prevent long titles from wrapping awkwardly
                .frame(width: 70) // Limit text width for truncation
        }
    }
}

// MARK: - Main Profile View Sections

struct ProfileHeaderView: View {
    let stats: ProfileStats
    let profileImageName: String = "person.crop.circle.fill" // Placeholder

    var body: some View {
        HStack(spacing: 20) {
            // Profile Picture
            ZStack(alignment: .bottomTrailing) {
                Image(systemName: profileImageName) // Replace with actual Image("your_asset_name")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 85, height: 85)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(
                                AngularGradient(gradient: Gradient(colors: [.red, .orange, .yellow, .green, .blue, .purple, .red]), center: .center),
                                lineWidth: 2.5
                            )
                            .frame(width: 90, height: 90) // Slightly larger for border
                    )

                // Plus button overlay
                Image(systemName: "plus.circle.fill")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(.blue) // Instagram's blue
                    .background(Color.white) // White background makes it pop
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 2)) // White border
                    .offset(x: 4, y: 4) // Adjust position
            }
            .padding(.leading) // Add padding on the left of the image

            // Stats
            HStack(spacing: 0) { // Reduce spacing between stats
                 Spacer() // Push stats to the right
                 ProfileStatView(value: "\(stats.posts)", label: "posts")
                 Spacer()
                 ProfileStatView(value: stats.followers, label: "followers")
                 Spacer()
                 ProfileStatView(value: "\(stats.following)", label: "following")
                 Spacer()
             }
             .frame(maxWidth: .infinity) // Allow HStack to take available space

        }
        .frame(height: 90) // Set height for the header area
        .padding(.trailing) // Balance padding
    }
}

struct BioSectionView: View {
    let name: String
    let bio: String // Could be multiple lines
    let link: String
    let username: String = "conglesolutionx" // Example

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(name)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.primary)

            // Using AttributedString for potential future hashtag/mention highlighting
            // For now, just simple text
            Text(bio)
                 .font(.system(size: 14))
                 .foregroundColor(.primary)
                 .lineSpacing(3) // Add a bit of space between lines if bio is multi-line

            if let url = URL(string: link) {
                Link(link, destination: url)
                   .font(.system(size: 14, weight: .medium))
                   .foregroundColor(.blue) // Standard link color
            }

            // Linked Accounts (Example)
            HStack(spacing: 10) {
                 HStack(spacing: 4) {
                     Image(systemName: "at") // Placeholder for Threads/other icon
                     Text(username)
                 }
                 HStack(spacing: 4) {
                     // You might need a custom Facebook icon image asset
                      Image(systemName: "f.circle") // Placeholder FB icon
                     Text("Cong Le")
                 }
             }
             .font(.system(size: 14, weight: .medium))
             .foregroundColor(.secondary) // Less emphasis
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity, alignment: .leading) // Ensure leading alignment
    }
}

struct ProfessionalDashboardView: View {
    var body: some View {
         VStack(alignment: .leading, spacing: 2) {
             Text("Professional dashboard")
                 .font(.system(size: 14, weight: .semibold))
                 .foregroundColor(.primary)
             Text("1.4K views in the last 30 days.")
                 .font(.system(size: 12))
                 .foregroundColor(.secondary)
         }
         .padding(.vertical, 10)
         .padding(.horizontal)
         .frame(maxWidth: .infinity, alignment: .leading)
         .background(Color(UIColor.systemGray6)) // Use a background color
         .cornerRadius(8)
         .padding(.horizontal)
    }
}

struct ActionButtonsView: View {
    var body: some View {
        HStack(spacing: 8) {
            ProfileActionButton(title: "Edit profile") {
                print("Edit profile tapped")
            }
            ProfileActionButton(title: "Share profile") {
                print("Share profile tapped")
            }
            ProfileActionButton(title: "Learn more") { // Or Contact / Email etc.
                print("Learn more tapped")
            }
        }
        .padding(.horizontal)
        .frame(height: 40) // Constrain height of the button row
    }
}

struct HighlightsView: View {
    let highlights: [Highlight]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: 15) { // Align items to top
                ForEach(highlights) { item in
                    HighlightItemView(item: item)
                }
            }
            .padding(.horizontal) // Padding for the scroll content
            .padding(.vertical, 5) // Small vertical padding
        }
        .frame(height: 100) // Set height for the scroll view area
    }
}

struct ContentTabView: View {
    @Binding var selectedTab: Int // 0: Grid, 1: Reels, 2: Tagged

    var body: some View {
         // Use GeometryReader to calculate underline position/width
        GeometryReader { geometry in
            VStack(spacing: 0) {
                HStack {
                    // Grid Button
                    Button { selectedTab = 0 } label: {
                        Image(systemName: "squareshape.split.3x3")
                            .font(.system(size: 22))
                             .foregroundColor(selectedTab == 0 ? .primary : .secondary)
                             .frame(maxWidth: .infinity)
                            .frame(height: 44) // Tappable height
                    }

                    // Reels Button
                    Button { selectedTab = 1 } label: {
                         Image(systemName: "play.rectangle") // Or appropriate Reels icon
                             .font(.system(size: 22))
                             .foregroundColor(selectedTab == 1 ? .primary : .secondary)
                             .frame(maxWidth: .infinity)
                             .frame(height: 44)
                    }

                    // Tagged Button
                    Button { selectedTab = 2 } label: {
                         Image(systemName: "person.crop.square") // Or appropriate Tagged icon
                             .font(.system(size: 22))
                             .foregroundColor(selectedTab == 2 ? .primary : .secondary)
                             .frame(maxWidth: .infinity)
                             .frame(height: 44)
                    }
                }

                 // Underline Indicator
                 Rectangle()
                     .fill(Color.primary) // Color of the underline
                     .frame(width: geometry.size.width / 3, height: 1) // Width is 1/3rd of total
                     // Calculate offset based on selected tab
                     .offset(x: calculateUnderlineOffset(width: geometry.size.width))
                     .animation(.easeInOut(duration: 0.2), value: selectedTab) // Animate underline movement
             }
         }
         .frame(height: 45) // Total height for tabs + underline
    }

    // Helper to calculate the X offset for the underline
    private func calculateUnderlineOffset(width: CGFloat) -> CGFloat {
         let segmentWidth = width / 3
         let padding = segmentWidth / 2 // Center the underline within the segment
         return CGFloat(selectedTab) * segmentWidth - width / 2 + padding
     }
}

struct PostGridView: View {
    // Example using simple colored rectangles
    let columns = [
        GridItem(.flexible(), spacing: 1),
        GridItem(.flexible(), spacing: 1),
        GridItem(.flexible(), spacing: 1)
    ]

     // Simple range for generating placeholders
     let items = 1...21 // Example count

    var body: some View {
        LazyVGrid(columns: columns, spacing: 1) {
            ForEach(items, id: \.self) { index in
                // Replace with actual image loading if needed
                Rectangle()
                    // Give placeholder varied colors for visual interest
                    .fill(Color(hue: Double(index) / 21.0, saturation: 0.7, brightness: 0.8))
                    .aspectRatio(1, contentMode: .fill) // Make them square
            }
        }
         // No padding needed here as spacing handles it
    }
}

struct ReelsPlaceholderView: View {
   var body: some View {
       VStack {
           Spacer()
           Image(systemName: "play.rectangle.fill")
               .font(.system(size: 60))
               .foregroundColor(.secondary)
           Text("Reels Go Here")
               .font(.title2)
               .foregroundColor(.secondary)
           Spacer()
           Spacer()
       }
       .frame(maxWidth: .infinity, maxHeight: .infinity)
       .background(Color(UIColor.systemGroupedBackground)) // Example background
   }
}

struct TaggedPlaceholderView: View {
   var body: some View {
       VStack {
           Spacer()
           Image(systemName: "person.crop.square.fill")
               .font(.system(size: 60))
               .foregroundColor(.secondary)
           Text("Tagged Posts Go Here")
               .font(.title2)
               .foregroundColor(.secondary)
           Spacer()
           Spacer()
       }
       .frame(maxWidth: .infinity, maxHeight: .infinity)
       .background(Color(UIColor.systemGroupedBackground)) // Example background
   }
}

// MARK: - Simulated Navigation Bar

struct ProfileNavBar: View {
     let username: String = "conglesolutionx"

     var body: some View {
         HStack(spacing: 10) {
             HStack(spacing: 2) { // Group username, badge, dropdown
                 Text(username)
                     .font(.system(size: 22, weight: .bold))
                     .foregroundColor(.primary)
                     .lineLimit(1)
                 Image(systemName: "checkmark.seal.fill") // Verification badge
                     .foregroundColor(.blue)
                      .font(.system(size: 14))
                 Image(systemName: "chevron.down") // Dropdown indicator
                     .font(.caption)
                     .foregroundColor(.primary)
                      .opacity(0.8)
             }
             .onTapGesture {
                   print("Username/Dropdown tapped")
             }

             Spacer() // Push right-side icons

             // Right side icons
             HStack(spacing: 20) {
                  // Threads Icon (replace with custom asset or correct SF Symbol if available)
                  // Using 'at' as a placeholder
                  Image(systemName: "at")
                      .font(.system(size: 22))
                      .foregroundColor(.primary)
                      .overlay( // Red notification badge
                          ZStack {
                              Circle().fill(.red)
                              Text("9+")
                                  .font(.system(size: 9, weight: .bold))
                                  .foregroundColor(.white)
                          }
                          .frame(width: 18, height: 18)
                          .offset(x: 10, y: -10) // Adjust badge position
                          , alignment: .topTrailing
                      )
                      .onTapGesture { print("Threads/Notifications tapped") }

                  Image(systemName: "plus.square") // Add Post icon
                      .font(.system(size: 22))
                      .foregroundColor(.primary)
                      .onTapGesture { print("Add Post tapped") }

                  Image(systemName: "line.3.horizontal") // Menu icon
                      .font(.system(size: 22))
                      .foregroundColor(.primary)
                      .onTapGesture { print("Menu tapped") }
            }
         }
         .padding(.horizontal)
         .frame(height: 44) // Standard nav bar height
     }
 }

// MARK: - Full Profile Screen View

struct InstagramProfileView: View {
    @State private var selectedContentTab: Int = 0 // 0: Grid, 1: Reels, 2: Tagged

    var body: some View {
         // Main container using VStack
         VStack(spacing: 0) { // Use spacing: 0 to control padding manually

             // Simulated Navigation Bar
            ProfileNavBar()
             // Use a Divider or background color change if needed to separate nav visually

            // Scrollable Content Area
            ScrollView {
                 VStack(alignment: .leading, spacing: 12) { // Spacing between sections

                    ProfileHeaderView(stats: sampleStats)
                         .padding(.top, 5) // Small padding below nav bar

                    BioSectionView(
                         name: "Cong Le",
                         bio: "Digital creator\n👨‍💻 Tech Writer | #iOS Developer\n🌍 Demystifying #AI for everyone\n📚 Explore #StableDiffusion, #ChatGPT, #LLMs & more on Medium and Facebook profile 🔗👆",
                         link: "medium.com/@CongLeSolutionX" // Keep it simple or use https://
                     )

                    ProfessionalDashboardView()
                         .padding(.top, 5) // Space above dashboard

                    ActionButtonsView()
                         .padding(.top, 5) // Space above buttons

                    HighlightsView(highlights: sampleHighlights)
                         .padding(.top, 10) // Space above highlights

                    // Divider before tabs
                    Divider().padding(.vertical, 5)

                     // Content Tabs
                    ContentTabView(selectedTab: $selectedContentTab)

                     // Spacer(minLength: 1) // Ensure divider is visible and sections below are pushed

                    // Content based on selected tab
                     // Use 'if' or 'switch' for content - 'if' is simpler here
                     if selectedContentTab == 0 {
                         PostGridView()
                     } else if selectedContentTab == 1 {
                         ReelsPlaceholderView()
                     } else {
                         TaggedPlaceholderView()
                     }

                 }
                 .padding(.bottom, 60) // Add padding at the bottom to avoid overlap with potential tab bar
             } // End ScrollView
              .coordinateSpace(name: "scroll") // Needed for potential scroll effects later

             // Spacer() // Pushes content up if ScrollView doesn't fill space

            // Simulated Bottom Tab Bar (Optional - as it's part of the overall app, not just profile)
             // Uncomment and style if you need to show it visually as part of the screenshot
              /*
             Divider() // Separator for tab bar
             HStack {
                 Image(systemName: "house").frame(maxWidth: .infinity)
                 Image(systemName: "magnifyingglass").frame(maxWidth: .infinity)
                 Image(systemName: "plus.square").frame(maxWidth: .infinity)
                 Image(systemName: "play.rectangle").frame(maxWidth: .infinity)
                 Image(systemName: "person.circle.fill").frame(maxWidth: .infinity) // Selected profile
             }
             .font(.system(size: 24))
             .foregroundColor(.primary)
             .frame(height: 50) // Standard tab bar height
             .padding(.bottom, safeAreaInsets.bottom > 0 ? 0 : 10) // Basic safe area padding
              */

         }
         .background(Color(UIColor.systemBackground).ignoresSafeArea()) // Use system background color for adaptability
         .ignoresSafeArea(.keyboard) // Avoid keyboard overlap issues
         // Apply dark mode preference if needed for consistent preview
         // .preferredColorScheme(.dark)
     }

     // Helper to access safe area insets if needed for custom bottom bar
     // @Environment(\.safeAreaInsets) private var safeAreaInsets
}

// MARK: - App Entry Point

@main
struct InstagramProfileCloneApp: App { // Make sure this matches your project name
    var body: some Scene {
        WindowGroup {
            InstagramProfileView()
                 // Apply dark mode for the whole app if desired
                 .preferredColorScheme(.dark)
        }
    }
}

// MARK: - Previews

#Preview {
     InstagramProfileView()
         .preferredColorScheme(.dark) // Preview in dark mode
}

#Preview("Light Mode") {
     InstagramProfileView()
         .preferredColorScheme(.light) // Preview in light mode
}
