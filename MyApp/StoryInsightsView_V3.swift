//
//  StoryInsightsView_V3.swift
//  MyApp
//
//  Created by Cong Le on 4/5/25.
//
import SwiftUI

// MARK: - Data Models

struct StoryPreview: Identifiable {
    let id = UUID()
    let imageName: String // Placeholder for thumbnail image name/URL
    var isAddButton: Bool = false // Can use this if mixing types, but AddToStoryButton is separate

    // Add properties if needed by DetailView later
    let detailImageName: String // Placeholder for detail image name
    let userName: String // Example user name for the story
    let userProfileImage: String // Placeholder profile image name for detail view
    let timestamp: String // Example timestamp for detail view
}

struct Viewer: Identifiable {
    let id = UUID()
    let name: String
    let profileImageName: String // Placeholder for image name/URL
    let source: String? // Optional subtitle like "Instagram"
}

// MARK: - Main Insights View

struct StoryInsightsView: View {
    @State private var selectedTab: Tab = .viewers
    @State private var stories: [StoryPreview] = [
        // Ensure these image names exist in your Assets
        StoryPreview(imageName: "story_placeholder_1", detailImageName: "story_placeholder_detail_1", userName: "Cong Le", userProfileImage: "profile_placeholder", timestamp: "1h"),
        StoryPreview(imageName: "story_placeholder_2", detailImageName: "story_placeholder_detail_2", userName: "Cong Le", userProfileImage: "profile_placeholder", timestamp: "4h")
    ]
    @State private var viewers: [Viewer] = [
        // Using system images as placeholders
        Viewer(name: "Anh Tran", profileImageName: "person.crop.circle.fill", source: nil),
        Viewer(name: "Khoa Le", profileImageName: "person.crop.circle.fill", source: nil),
        Viewer(name: "Hoang Mai", profileImageName: "person.crop.circle.fill", source: nil),
        Viewer(name: "Eric Nguyen", profileImageName: "person.crop.circle.fill", source: nil),
        Viewer(name: "Yen Nhi Nguyen", profileImageName: "person.crop.circle.fill", source: nil),
        Viewer(name: "Lan Giao", profileImageName: "person.crop.circle.fill", source: nil),
        Viewer(name: "timmy.cuts", profileImageName: "person.crop.circle.fill", source: "Instagram")
    ]
    // Data for Insights Tab
    @State private var uniqueAccountViews: Int = 7

    // State to manage the presentation of the Story Detail View
    @State private var selectedStory: StoryPreview? = nil // Use optional StoryPreview

    enum Tab {
        case viewers
        case insights
    }

    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    // 1. Story Previews Section
                    StoryPreviewSection(stories: stories, selectedStory: $selectedStory) // Pass the binding
                        .padding(.top) // Add some top padding if needed below nav bar

                    // 2. Tab Bar Section
                    TabBarSection(selectedTab: $selectedTab)

                    // Divider Line
                    Rectangle()
                         .frame(height: 0.5)
                         .foregroundColor(Color(.systemGray4))
                         .padding(.vertical) // Add padding above and below divider

                    // 3. Content based on Tab
                    VStack {
                        if selectedTab == .viewers {
                           ViewersListSection(viewers: viewers)
                        } else {
                           InsightsViewContent(uniqueAccountViews: uniqueAccountViews)
                        }
                    }
                    .padding(.horizontal) // Apply horizontal padding to the content area below tabs
                    .padding(.bottom) // Add padding below the content

                } // End of main VStack
            } // End of ScrollView
            .background(Color(.systemGroupedBackground)) // Match typical settings/modal background slightly better
            .navigationBarTitleDisplayMode(.inline) // Avoid large titles
            .toolbar {
                // Navigation Bar Items
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        print("Globe tapped") // Action for globe button
                    } label: {
                        Image(systemName: "globe")
                            .foregroundColor(.primary) // Adjust color as needed
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 15) {
                        Button {
                             print("History tapped") // Action for history button
                        } label: {
                            Image(systemName: "clock")
                                .foregroundColor(.primary)
                        }
                        Button {
                             print("Close tapped") // Action for close button
                        } label: {
                            Image(systemName: "xmark")
                                .foregroundColor(.primary)
                        }
                    }
                }
            }
            // .preferredColorScheme(.dark) // Uncomment to force dark mode
        }
        // Add the fullScreenCover modifier HERE
        .fullScreenCover(item: $selectedStory) { storyItem in
             StoryDetailView(story: storyItem)
        }
    }
}

// MARK: - Story Insights Subviews

struct StoryPreviewSection: View {
    let stories: [StoryPreview]
    @Binding var selectedStory: StoryPreview? // Receive binding

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                 // Prepend the "Add to Story" button
                 AddToStoryButton()

                ForEach(stories) { story in
                    // Make the thumbnail tappable
                    Button {
                        self.selectedStory = story // Set the selected story
                    } label: {
                        StoryThumbnail(imageName: story.imageName)
                    }
                    .buttonStyle(.plain) // Use plain style to avoid default button appearance
                }
            }
            .padding(.horizontal) // Add horizontal padding to the HStack content
            .padding(.bottom) // Add padding below the stories
        }
    }
}

struct AddToStoryButton: View {
     var body: some View {
         VStack {
             Image(systemName: "plus.circle.fill")
                 .font(.system(size: 30))
                 .foregroundColor(.blue) // Or systemBlue
                 .padding(.bottom, 5) // Space between icon and text

             Text("Add to\nStory") // Use \n for newline
                 .font(.caption)
                 .foregroundColor(.primary)
                 .multilineTextAlignment(.center) // Center align text
                 .lineLimit(2) // Ensure it fits in two lines
                 .fixedSize(horizontal: false, vertical: true) // Prevent text from causing excessive height

              Spacer() // Push content to top
         }
         .padding(.top, 15) // Padding from the top edge
         .padding(.bottom) // Ensure bottom padding for spacing
         .frame(width: 80, height: 120)
         .background(Color(.systemGray5)) // Background color similar to screenshot
         .cornerRadius(10)
     }
 }

struct StoryThumbnail: View {
    let imageName: String

    var body: some View {
        // Use a placeholder color/image for the story background
        ZStack {
             // Attempt to load the image, use gray background as fallback
             Image(imageName)
                 .resizable()
                 .scaledToFill()
                 .overlay(Color.black.opacity(0.1)) // Optional subtle darkening
                 .background(Color(.systemGray4)) // Fallback background

             // Optional: Add placeholder text if image loading fails or for testing
             // Text("Story")
             //     .foregroundColor(.white.opacity(0.7))
             //     .font(.caption)
        }
        .frame(width: 80, height: 120)
        .cornerRadius(10)
        .clipped() // Ensure content stays within bounds
        .overlay( // Add a subtle border if desired
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray.opacity(0.5), lineWidth: 0.5)
        )
    }
}

struct TabBarSection: View {
    @Binding var selectedTab: StoryInsightsView.Tab
    @Namespace private var namespace // Namespace for animation

    var body: some View {
        HStack(spacing: 0) {
            TabBarButton(title: "Viewers",
                         iconName: "eye",
                         isSelected: selectedTab == .viewers,
                         namespace: namespace) { // Pass namespace
                withAnimation(.spring()) {
                     selectedTab = .viewers
                }
            }

            TabBarButton(title: "Insights",
                         iconName: "chart.bar.xaxis",
                         isSelected: selectedTab == .insights,
                         namespace: namespace) { // Pass namespace
                 withAnimation(.spring()) {
                      selectedTab = .insights
                 }
            }
        }
        .padding(.horizontal) // Add padding if needed, adjust layout
        .frame(height: 50) // Define a height for the tab bar area
    }
}

struct TabBarButton: View {
    let title: String
    let iconName: String
    let isSelected: Bool
    let namespace: Namespace.ID // Receive namespace
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 5) { // Use VStack for text/icon and underline
                HStack(spacing: 5) {
                    Image(systemName: iconName)
                    Text(title)
                        .fontWeight(.medium)
                }
                // Use blue for selected, secondary for unselected
                .foregroundColor(isSelected ? Color(.systemBlue) : .secondary)

                // Underline Logic
                if isSelected {
                    Capsule()
                         // Use the standard system blue for consistency
                        .fill(Color(.systemBlue))
                        .frame(height: 3)
                        .matchedGeometryEffect(id: "underline", in: namespace) // Apply effect here
                } else {
                    Color.clear.frame(height: 3) // Placeholder for unselected
                }
            }
             .frame(maxWidth: .infinity) // Make buttons expand equally
             .contentShape(Rectangle()) // Ensure entire area is tappable
        }
        .buttonStyle(.plain) // Remove default button styling
    }
}

struct ViewersListSection: View {
    let viewers: [Viewer]

    var body: some View {
        VStack(alignment: .leading, spacing: 15) { // Add spacing between header and list
            // Header: Viewer Count & Refresh Button
            HStack {
                Text("\(viewers.count) viewers")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                Button {
                    print("Refresh tapped") // Action for refresh
                } label: {
                    Label("Refresh", systemImage: "arrow.clockwise")
                         .labelStyle(.titleAndIcon) // Show both title and icon
                        .font(.system(size: 14)) // Slightly smaller font
                }
                .buttonStyle(.bordered) // A style similar to the screenshot
                .tint(.secondary) // Adjust tint color
                .controlSize(.small) // Make button smaller
            }
            // .padding(.top) // Padding moved to divider

            // List of Viewers
            ForEach(viewers) { viewer in
                ViewerRow(viewer: viewer)
            }
        }
        // .padding(.bottom) // Padding added below content area in main view
    }
}

struct ViewerRow: View {
    let viewer: Viewer

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: viewer.profileImageName) // Use placeholder system image
                .resizable()
                .scaledToFit()
                .frame(width: 44, height: 44)
                .clipShape(Circle())
                .foregroundColor(.secondary) // Give placeholder a color

            VStack(alignment: .leading, spacing: 2) {
                Text(viewer.name)
                    .font(.subheadline)
                    .fontWeight(.regular)
                    .foregroundColor(.primary)
                if let source = viewer.source {
                    Text(source)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer() // Pushes content left and button right

            Button {
                print("Options for \(viewer.name) tapped") // Action for ellipsis button
            } label: {
                Image(systemName: "ellipsis")
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
        }
    }
}

struct InsightsViewContent: View {
    let uniqueAccountViews: Int
    @State private var showBanner: Bool = true // State to control banner visibility

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
             // 1. Dismissible Banner
             if showBanner {
                 DismissibleBannerView(showBanner: $showBanner)
                      .transition(.opacity.combined(with: .move(edge: .top))) // Add transition
             }

            // 2. "Seen by" Section
            SeenBySection(count: uniqueAccountViews)

             Spacer() // Pushes content upwards if screen is tall
        }
         // .padding(.top) // Padding moved to divider
    }
}

struct DismissibleBannerView: View {
     @Binding var showBanner: Bool

     var body: some View {
          HStack(alignment: .center, spacing: 10) {
               VStack(alignment: .leading, spacing: 2) {
                    Text("Instagram accounts are not included")
                         .font(.subheadline)
                         .fontWeight(.semibold)
                         .foregroundColor(.primary)
                    Text("You'll see insights about Facebook viewers here.")
                         .font(.caption)
                         .foregroundColor(.secondary)
               }
               Spacer() // Push button to the right
               Button {
                    withAnimation {
                         showBanner = false // Dismiss the banner
                    }
               } label: {
                    Image(systemName: "xmark")
                         .foregroundColor(.secondary)
                         .padding(8) // Increase tap area slightly
                         .background(Color.secondary.opacity(0.2)) // Subtle background like screenshot
                         .clipShape(Circle())
               }
          }
          .padding(.horizontal, 15) // Inner horizontal padding
          .padding(.vertical, 10) // Inner vertical padding
          .background(Color(.systemGray5)) // Background color for the banner
          .cornerRadius(10) // Rounded corners for the banner
     }
}

struct SeenBySection: View {
    let count: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 10) { // Align content to the leading edge
            Text("Seen by")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)

            // Center the count and subtitle horizontally
            HStack {
                Spacer() // Push content to center
                VStack(alignment: .center, spacing: 5) { // Center the text vertically
                     Text("\(count)")
                         .font(.system(size: 48, weight: .bold)) // Large, bold font for the count
                         .foregroundColor(.primary)
                     Text("Unique accounts")
                         .font(.subheadline)
                         .foregroundColor(.secondary)
                 }
                Spacer() // Push content to center
            }
            .padding(.top, 10) // Add some space above the count
        }
    }
}

// MARK: - Story Detail View

struct StoryDetailView: View {
    let story: StoryPreview // Received story data
    @Environment(\.dismiss) var dismiss // Environment variable to dismiss the modal

    // Placeholder state for demo purposes
    @State private var progress: Double = 0.3 // Example progress for the top bar
    @State private var isMuted: Bool = false

    // Helper to get safe area insets
//    private var safeAreaInsets: EdgeInsets {
//        (UIApplication.shared.connectedScenes.first as? UIWindowScene)?
//            .windows.first?.safeAreaInsets ?? EdgeInsets()
//    }

    var body: some View {
        ZStack {
            // 1. Background - Story Content (Image)
            storyContentBackground

            // 2. Dimming overlay to make foreground content more visible
            Color.black.opacity(0.15).edgesIgnoringSafeArea(.all)

            // 3. Foreground Content (Controls, Info, etc.)
            VStack(spacing: 0) {
                // Top Bar (Progress, User Info, Controls)
                StoryDetailTopBar(
                    story: story, // Pass story data
                    progress: $progress,
                    dismissAction: { dismiss() } // Use dismiss environment action
                )
//                .padding(.top, safeAreaInsets.top) // Adjust for safe area
                .padding(.horizontal)
                .padding(.bottom, 8) // Space below top bar

                Spacer() // Pushes top and bottom elements apart

                // Bottom Bar (Viewer Count, Actions)
                StoryDetailBottomBar()
                .padding(.horizontal)
                // Adjust bottom padding for safe area + extra space
//                .padding(.bottom, max(safeAreaInsets.bottom, 10))

            }
            .edgesIgnoringSafeArea(.bottom) // Allow bottom bar to go into safe area edge if needed

             // 4. Mute Button (Overlay on top) - Positioned relative to safe area
             VStack {
                 HStack {
                     Spacer() // Push mute button to the right
                     muteButton
                     .padding(.trailing)
                 }
                 Spacer() // Push mute button towards the top
             }
             // Position mute button below top bar + spacing
//             .padding(.top, safeAreaInsets.top + 60)

        }
         .background(.black) // Ensure black background behind everything
         // .statusBar(hidden: true) // Optionally hide the status bar
    }

    // Extracted background view logic
    @ViewBuilder
    private var storyContentBackground: some View {
        Image(story.detailImageName) // Use the detail image name from story data
            .resizable()
             // Use .fill to cover the screen, .fit to see the whole image
            .scaledToFill()
            .frame(maxWidth: .infinity, maxHeight: .infinity) // Ensure it fills
            .background(Color.black) // Black background behind the image
            .edgesIgnoringSafeArea(.all)
            .clipped() // Clip to bounds
    }

    // Extracted mute button logic
    private var muteButton: some View {
        Button {
           isMuted.toggle()
           // Add sound playing/muting logic here
           print("Mute toggled: \(isMuted)")
        } label: {
            Image(systemName: isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                 .font(.title2)
                 .foregroundColor(.white)
                 .padding(12)
                 .background(Color.black.opacity(0.4))
                 .clipShape(Circle())
        }
    }
}

// MARK: - Subviews for StoryDetailView

struct StoryDetailTopBar: View {
    let story: StoryPreview // Receive story data
    @Binding var progress: Double // Example binding for progress
    var dismissAction: () -> Void // Closure to dismiss

    var body: some View {
        VStack(spacing: 8) {
            // Progress Indicator (Multiple segments if you have multiple stories for a user)
            // Simplified to one segment based on binding for now
            GeometryReader { geo in
                HStack(spacing: 4) {
                     // Example: Single progress bar based on binding
                     Capsule()
                         .fill(Color.white.opacity(0.8))
                         .frame(width: max(0, geo.size.width * CGFloat(progress)), height: 3) // Filled part
                     Capsule()
                         .fill(Color.white.opacity(0.4))
                         .frame(height: 3) // Remainder
                }
            }
            .frame(height: 3) // Explicit height for the GeometryReader container

            // User Info and Controls
            HStack(spacing: 10) {
                Image(story.userProfileImage) // Use image from story data
                    .resizable()
                    .scaledToFit()
                    .frame(width: 36, height: 36)
                    .background(Color.gray) // Placeholder bg
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 1) {
                    HStack {
                         Text(story.userName) // Use name from story data
                              .font(.subheadline)
                              .fontWeight(.semibold)
                              .foregroundColor(.white)
                         Image(systemName: "checkmark.seal.fill") // Verified badge
                              .foregroundColor(.white)
                              .font(.caption)
                         Text(story.timestamp) // Use timestamp from story data
                              .font(.subheadline)
                              .foregroundColor(.white.opacity(0.8))
                    }
                    // "Tap to try" element - can be conditional
                    HStack {
                         Image(systemName: "waveform") // Placeholder icon
                         Text("Tap to try")
                         Image(systemName: "chevron.down")
                    }
                     .font(.caption)
                     .foregroundColor(.white.opacity(0.9))
                     .padding(.vertical, 2)
                     .padding(.horizontal, 5)
                     .background(Color.white.opacity(0.2))
                     .cornerRadius(5)

                }

                Spacer() // Pushes controls to the right

                Button {
                    print("More options tapped")
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.white)
                        .font(.title2)
                        .contentShape(Rectangle()) // Increase tappable area
                        .padding(5)
                }

                Button(action: dismissAction ) { // Use the dismiss closure
                    Image(systemName: "xmark")
                        .foregroundColor(.white)
                        .font(.title2)
                        .contentShape(Rectangle()) // Increase tappable area
                        .padding(5)
                }
            }
        }
    }
}

struct StoryDetailBottomBar: View {
    // Placeholder data - could be passed in if dynamic
    let viewerCount = 24
    let firstViewerName = "Quynh-Nhu Cao"
    let firstViewerImage = "person.crop.circle.fill" // Placeholder system image name

    var body: some View {
        VStack(spacing: 15) {
             // Viewer Preview
             HStack {
                 HStack(spacing: -8) { // Overlap avatars slightly if > 1
                     Image(systemName: firstViewerImage) // First viewer avatar - use system image placeholder
                         .resizable()
                          .foregroundColor(.secondary)
                          .scaledToFit()
                          .frame(width: 28, height: 28)
                          .background(Color.white)
                          .clipShape(Circle())
                          .overlay(Circle().stroke(Color.black, lineWidth: 1)) // Optional border
                      // TODO: Add more avatars here if needed (e.g., from story data)
                 }
                 Text("\(viewerCount) viewers")
                     .font(.subheadline)
                     .fontWeight(.medium)
                     .foregroundColor(.white)
                 Spacer()
             }

            // Action Buttons Toolbar
            HStack(alignment: .center, spacing: 0) {
                Spacer()
                BottomActionButton(iconName: "plus.rectangle.on.rectangle", label: "Add story") {
                    print("Add Story tapped")
                }
                Spacer()
                // Use a custom asset or a different system icon for Instagram
                BottomActionButton(iconName: "camera", label: "Instagram") {
                    print("Instagram tapped")
                }
                Spacer()
                BottomActionButton(iconName: "heart.circle", label: "Feature") {
                    print("Feature tapped")
                }
                Spacer()
            }
            .padding(.top, 5) // Add space above the action buttons
        }
         .padding(.vertical, 8)
         .padding(.horizontal, 12)
         .background(
              // Subtle gradient at the bottom
              LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.0), Color.black.opacity(0.4), Color.black.opacity(0.6)]), startPoint: .top, endPoint: .bottom)
          )
         .compositingGroup() // Helps rendering with gradient/opacity
         .shadow(color: .black.opacity(0.2), radius: 5, y: -2) // Optional subtle shadow

    }
}

struct BottomActionButton: View {
    let iconName: String
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: iconName)
                    .font(.title2)
                    .frame(height: 25) // Ensure icons have consistent height
                Text(label)
                    .font(.caption)
                    .fixedSize() // Prevent text wrapping
            }
            .foregroundColor(.white)
        }
        .frame(minWidth: 60) // Give buttons some minimum width for tapping
    }
}

// MARK: - Previews

// Preview for the main Insights/Viewers screen
//struct StoryInsightsView_Previews: PreviewProvider {
//    static var previews: some View {
//        StoryInsightsView(selectedTab: .viewers)
//             .previewDisplayName("Viewers Tab")
//
//        StoryInsightsView(selectedTab: .insights)
//            .previewDisplayName("Insights Tab")
//    }
//}

// Preview for the main Insights/Viewers screen
struct StoryInsightsView_Previews: PreviewProvider {
    static var previews: some View {
        StoryInsightsView()
             .previewDisplayName("Viewers Tab")

        StoryInsightsView()
            .previewDisplayName("Insights Tab")
    }
}

// Preview specifically for the Story Detail View
struct StoryDetailView_Previews: PreviewProvider {
    static var previews: some View {
         // Create a dummy StoryPreview for the detail view preview
         let sampleStory = StoryPreview(
             imageName: "My-meme-original", // Not used directly by detail preview bg
             detailImageName: "My-meme-heineken", // Image shown in detail bg
             userName: "Cong Le",
             userProfileImage: "profile_placeholder", // Image shown in top bar
             timestamp: "4h"
         )
         StoryDetailView(story: sampleStory)
              // To see it better in preview on light canvas
              // .preferredColorScheme(.dark)
    }
}

// MARK: - IMPORTANT Placeholders

/*
 !! Add the following image assets to your Assets.xcassets !!

 - story_placeholder_1 (for thumbnail)
 - story_placeholder_2 (for thumbnail)
 - story_placeholder_detail_1 (for detail view background)
 - story_placeholder_detail_2 (for detail view background)
 - profile_placeholder (for user avatar in detail view top bar)

 * If you don't add these, the Image views will either be empty or show
   system placeholders depending on the OS version.
 * Replace placeholder names with your actual asset names.
 * Consider using AsyncImage if loading images from URLs.
 */
