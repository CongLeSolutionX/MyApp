//
//  HomeView.swift
//  MyApp
//
//  Created by Cong Le on 4/2/25.
//

import SwiftUI

// MARK: - Data Models

struct Story: Identifiable {
    let id = UUID()
    let userName: String? // Optional for "Create Story"
    let profileImageName: String? // Optional for "Create Story"
    let storyImageName: String
    let isCreateStory: Bool = false
}

struct FeedPost: Identifiable {
    let id = UUID()
    let userName: String
    let profileImageName: String
    let timestamp: String
    let postText: String
    let postImageNames: [String] // Can have multiple images
    // Add counts later if needed:
     let likeCount: Int
     let commentCount: Int
     let shareCount: Int
}

// Enum for Tab Bar Items
enum FBTabBarItem: String, CaseIterable, Identifiable {
    case home, friends, video, feeds, notifications, menu

    var id: String { self.rawValue }

    var title: String {
        return self.rawValue.capitalized
    }

    var iconName: String {
        switch self {
        case .home: return "house"
        case .friends: return "person.2"
        case .video: return "play.tv"
        case .feeds: return "list.bullet.rectangle.portrait" // Approximation
        case .notifications: return "bell"
        case .menu: return "line.3.horizontal" // Standard menu icon
        }
    }

    var selectedIconName: String {
        switch self {
        case .home: return "house.fill"
        case .friends: return "person.2.fill"
        case .video: return "play.tv.fill"
        case .feeds: return "list.bullet.rectangle.portrait.fill"
        case .notifications: return "bell.fill"
        case .menu: return "line.3.horizontal" // Often doesn't change or uses profile pic
        }
    }

     // Placeholder views for each tab
     @ViewBuilder
     var view: some View {
         // For this example, all tabs except Home show a placeholder
         // In a real app, each would have its own content view structure.
         switch self {
         case .home:
             // The main content we are building
             FacebookHomeFeedView() // Renamed for clarity
         default:
             // Generic Placeholder View
             PlaceholderTabView(title: self.title)
         }
     }
}

// MARK: - Sample Data

let storiesData: [Story] = [
    Story(userName: nil, profileImageName: "profile_cong", storyImageName: "story_create_bg"), // Special "Create Story"
    Story(userName: "Your story", profileImageName: "profile_cong", storyImageName: "story_cong"),
    Story(userName: "Amelia Tran", profileImageName: "profile_amelia", storyImageName: "story_amelia"),
    Story(userName: "Phuong", profileImageName: "profile_phuong", storyImageName: "story_phuong"),
    Story(userName: "Another User", profileImageName: "person.circle", storyImageName: "placeholder_image_1") // Placeholder
]

let feedPostsData: [FeedPost] = [
    FeedPost(userName: "Raymond de Lacaze", profileImageName: "profile_raymond", timestamp: "17m", postText: "Don't Believe the Vibe: Best Practices for Coding with AI Agents (Pascal Biese, April 2025)... See more", postImageNames: ["post_ai_1", "post_ai_2"], likeCount: 10000, commentCount: 1000, shareCount: 10),
    FeedPost(userName: "Jane Doe", profileImageName: "person.crop.circle.fill", timestamp: "1h", postText: "Just enjoying a beautiful sunset! #nofilter", postImageNames: ["placeholder_image_1"], likeCount: 10000, commentCount: 1000, shareCount: 10),
     FeedPost(userName: "John Appleseed", profileImageName: "person.circle", timestamp: "3h", postText: "Thinking about the weekend.", postImageNames: [], likeCount: 10000, commentCount: 1000, shareCount: 10) // Text only post
]

// MARK: - Reusable & Component Views

// --- Navigation Bar ---
struct FacebookNavigationBar: View {
     @Binding var messengerBadgeCount: Int // Allow updating badge

    var body: some View {
        HStack(spacing: 12) {
            Text("facebook")
                .font(.system(size: 30, weight: .bold))
                .foregroundColor(Color.blue) // Facebook Blue

            Spacer()

            HStack(spacing: 15) { // Slightly more spacing between icons
                NavBarIcon(systemName: "plus")
                NavBarIcon(systemName: "magnifyingglass")
                 NavBarIcon(systemName: "message.fill", badgeCount: $messengerBadgeCount) // Pass binding
            }
        }
        .padding(.horizontal)
        .frame(height: 44) // Standard nav bar height
    }
}

struct NavBarIcon: View {
    let systemName: String
    @Binding var badgeCount: Int // Use binding to receive updates

    // Initializer to make badgeCount optional
    init(systemName: String, badgeCount: Binding<Int> = .constant(0)) {
        self.systemName = systemName
        self._badgeCount = badgeCount // Set the binding
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Button {
                print("\(systemName) tapped")
            } label: {
                Image(systemName: systemName)
                    .font(.system(size: 18, weight: .bold)) // Slightly bolder
                    .foregroundColor(.primary) // Match system dark/light mode
                    .frame(width: 36, height: 36)
                    .background(Color(UIColor.systemGray5)) // Lighter gray
                    .clipShape(Circle())
            }

            // Badge logic
             if badgeCount > 0 {
                 Text("\(badgeCount)")
                     .font(.system(size: 10, weight: .bold))
                     .foregroundColor(.white)
                     .padding(EdgeInsets(top: 2, leading: 4, bottom: 2, trailing: 4)) // Smaller padding
                     .background(Color.red)
                     .clipShape(Capsule()) // Use Capsule for varied lengths
                     .offset(x: 5, y: -5) // Adjust offset
                     // Prevent badge from being clipped
                     .zIndex(1)
             }
        }
    }
}

// --- Status Update Prompt ---
struct StatusUpdateView: View {
    let profileImageName: String

    var body: some View {
        HStack(spacing: 12) {
            Image(profileImageName) // Use user's profile pic
                .resizable()
                .scaledToFill()
                .frame(width: 40, height: 40)
                .clipShape(Circle())

            Text("What's on your mind?")
                .foregroundColor(.secondary)

            Spacer()

            Image(systemName: "photo.on.rectangle.angled")
                .font(.title2)
                .foregroundColor(.green) // Facebook uses green for photo icon
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
    }
}

// --- Stories Section ---
struct StoriesScrollView: View {
    let stories: [Story]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) { // Reduced spacing
                ForEach(stories) { story in
                    StoryCardView(story: story)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 10) // Add vertical padding to the container
        }
        // Give the ScrollView a background to separate it visually
        .background(Color(UIColor.systemBackground)) // Ensures contrast
    }
}

struct StoryCardView: View {
    let story: Story

    var body: some View {
        ZStack(alignment: story.isCreateStory ? .center : .bottomLeading) {
            // Background Image for all cards
             Image(story.storyImageName)
                .resizable()
                .scaledToFill() // Fill the frame
                .frame(width: 110, height: 190) // Fixed size for story card
                .clipShape(RoundedRectangle(cornerRadius: 12)) // Clip the image itself

            // Dark overlay for better text/icon visibility
             LinearGradient(gradient: Gradient(colors: [.clear, .black.opacity(0.1), .black.opacity(story.isCreateStory ? 0.4 : 0.6)]), startPoint: .top, endPoint: .bottom)
                  .frame(width: 110, height: 190) // Match frame
                  .clipShape(RoundedRectangle(cornerRadius: 12)) // Clip the gradient too

            if story.isCreateStory {
                // "Create Story" specific layout
                 VStack(spacing: 8) {
                     Spacer() // Push content down

                     Button {
                         print("Create Story tapped")
                     } label: {
                         Image(systemName: "plus")
                             .font(.system(size: 20, weight: .bold))
                             .foregroundColor(.white)
                             .frame(width: 40, height: 40)
                             .background(Color.blue)
                             .clipShape(Circle())
                             .overlay(
                                 Circle().stroke(Color(UIColor.systemBackground), lineWidth: 3) // White border
                             )
                     }
                    .offset(y: 20) // Shift button slightly down to overlap bottom edge

                    // Text below the card area (common pattern in FB)
                     Text("Create\nstory")
                         .font(.system(size: 13, weight: .semibold))
                         .foregroundColor(.primary)
                         .multilineTextAlignment(.center)
                         .padding(.top, 25) // Space above text, accounts for button offset
                         .frame(width: 110) // Match card width for alignment
                         .background(Color(UIColor.secondarySystemGroupedBackground)) // Background for text part
                         // Specific bottom corners rounded
                         .clipShape(RoundedCorner(radius: 12, corners: [.bottomLeft, .bottomRight]))

                 }
                 .frame(width: 110, height: 190 + 50) // Total container height including text area

            } else {
                // Regular Story layout
                 VStack(alignment: .leading, spacing: 4) {
                     // Profile Image with border
                     if let profileImg = story.profileImageName {
                         Image(profileImg)
                             .resizable()
                             .scaledToFill()
                             .frame(width: 36, height: 36)
                             .clipShape(Circle())
                             .overlay(
                                 Circle().stroke(Color.blue, lineWidth: 2.5) // Blue border for active stories
                             )
                     }

                     // User Name
                     if let name = story.userName {
                         Text(name)
                             .font(.system(size: 13, weight: .semibold))
                             .foregroundColor(.white)
                             .lineLimit(1)
                             .shadow(radius: 2) // Text shadow for readability
                     }
                 }
                 .padding(8) // Padding inside the ZStack
            }
        }
        // Important: Create Story card needs different frame height
         .frame(width: 110, height: story.isCreateStory ? 190 + 50 : 190) // Adjust height conditionally
         // Apply clipping and background *after* potential height change
          .background(story.isCreateStory ? Color.clear : Color(UIColor.systemGray4)) // Fallback BG for non-create
          .cornerRadius(12)

    }
}

// Helper for rounding specific corners
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

// --- Feed Post Components ---
struct PostHeaderView: View {
    let post: FeedPost

    var body: some View {
        HStack(spacing: 8) {
            Image(post.profileImageName)
                .resizable()
                .scaledToFill()
                .frame(width: 40, height: 40)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(post.userName)
                    .font(.headline)
                    .fontWeight(.medium) // Slightly less bold
                HStack(spacing: 4) {
                    Text(post.timestamp)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Image(systemName: "globe.americas.fill") // Assuming public post
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            Button { print("More tapped") } label: {
                Image(systemName: "ellipsis")
                    .foregroundColor(.secondary)
                    .font(.headline) // Make tap target reasonable
                     .frame(width: 30, height: 30) // Ensure tappable area
            }
            Button { print("Close tapped") } label: {
                Image(systemName: "xmark")
                    .foregroundColor(.secondary)
                     .font(.headline)
                     .frame(width: 30, height: 30)
            }
        }
        .padding(.horizontal)
        .padding(.top, 12) // Padding above header
    }
}

struct PostContentView: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 16)) // Standard body font size
            .lineSpacing(4) // Slightly more line spacing
             .frame(maxWidth: .infinity, alignment: .leading) // Ensure text aligns left
            .padding(.horizontal)
            .padding(.vertical, 8) // Padding above/below text
    }
}

struct PostMediaView: View {
    let imageNames: [String]

    var body: some View {
        // Handle no images, one image, or multiple images
        if imageNames.isEmpty {
            EmptyView() // No media, show nothing
        } else if imageNames.count == 1 {
            Image(imageNames[0])
                .resizable()
                .scaledToFit() // Fit ensures whole image is visible
                .frame(maxWidth: .infinity) // Occupy full width
                .clipped() // Clip if aspect ratio doesn't match space
        } else {
            // For multiple images, use an HStack (basic case)
            // A GeometryReader + dynamic grid would be needed for complex FB layouts
            HStack(spacing: 2) { // Minimal spacing
                ForEach(imageNames, id: \.self) { imageName in
                    Image(imageName)
                        .resizable()
                        .scaledToFill()
                         // Divide width equally - need GeometryReader for precision
                         // For now, approximate with fixed height
                         .frame(height: 250) // Example fixed height
                        .clipped()
                }
            }
             .frame(maxWidth: .infinity) // Occupy full width
             .clipped() // Clip the HStack container
        }
    }
}

struct PostActionsView: View {
    var body: some View {
        VStack(spacing: 0) {
            // Optional: Add reaction counts here later
              HStack {
                  Image(systemName: "hand.thumbsup.fill").foregroundColor(.blue)
                  Text("123")
                  Spacer()
                  Text("45 Comments")
              }
              .font(.caption)
              .foregroundColor(.secondary)
              .padding(.horizontal)
              .padding(.top, 8)

            Divider() // Divider above action buttons
                 .padding(.vertical, 8) // Space around divider

            HStack {
                 ActionButton(systemName: "hand.thumbsup", label: "Like")
                 Spacer()
                 ActionButton(systemName: "message", label: "Comment") // Use comment icon
                 Spacer()
                 ActionButton(systemName: "arrowshape.turn.up.forward", label: "Share") // Standard share icon
                 // Note: FB uses WhatsApp icon "Send" in some regions/versions. Using Comment/Share for general case.
            }
            .padding(.horizontal, 25) // More horizontal padding for actions
            .padding(.bottom, 10) // Padding below actions
        }
    }
}

struct ActionButton: View {
    let systemName: String
    let label: String

    var body: some View {
        Button {
            print("\(label) button tapped")
        } label: {
            HStack(spacing: 5) {
                Image(systemName: systemName)
                Text(label)
            }
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundColor(.secondary) // Standard action button color
        }
    }
}

// -- Generic Placeholder for other Tabs ---
 struct PlaceholderTabView: View {
     let title: String
     var body: some View {
         NavigationView { // Each tab often has its own navigation
             ZStack {
                 Color(UIColor.systemGroupedBackground).ignoresSafeArea()
                 VStack {
                     Spacer()
                     Text("\(title) Screen")
                         .font(.largeTitle)
                         .foregroundColor(.secondary)
                     Text("(Content goes here)")
                         .foregroundColor(.accentColor)
                     Spacer()
                     Spacer()
                 }
             }
             .navigationTitle(title)
             .navigationBarHidden(true) // Hide inner navigation bar if needed
         }
         .navigationViewStyle(.stack) // Use stack style
     }
 }

// --- Feed Post Container ---
struct FeedPostView: View {
    let post: FeedPost

    var body: some View {
        VStack(alignment: .leading, spacing: 0) { // No spacing, handled by padding within components
            PostHeaderView(post: post)
            PostContentView(text: post.postText)
            // Add media view only if images exist
            if !post.postImageNames.isEmpty {
                PostMediaView(imageNames: post.postImageNames)
                     // Add top padding only if there are images
                     .padding(.top, 8)
             }
            PostActionsView()
        }
        .background(Color(UIColor.systemBackground)) // Each post on white/dark background
        // Add separator or rely on ScrollView spacing
    }
}

// MARK: - Main Home Feed View

struct FacebookHomeFeedView: View {
     @State private var messengerBadgeCount: Int = 5 // State for the badge

    var body: some View {
        VStack(spacing: 0) { // No spacing between primary sections
             FacebookNavigationBar(messengerBadgeCount: $messengerBadgeCount) // Pass binding

            ScrollView {
                LazyVStack(spacing: 0) { // Use LazyVStack for performance
                    StatusUpdateView(profileImageName: "profile_cong") // User's profile pic

                     Divider() // Divider below status

                     StoriesScrollView(stories: storiesData)
                         .padding(.bottom, 8) // Space below stories

                    // Feed Section - Divider above feed
                    Divider()
                         .padding(.top, 4) // Small space before first post

                    ForEach(feedPostsData) { post in
                        FeedPostView(post: post)
                        // Thick Divider between posts
                         Rectangle()
                             .fill(Color(UIColor.systemGray4)) // Thicker separator color
                             .frame(height: 8)
                    }

                    // Add spacer at the bottom if needed, considering tab bar height
                    Spacer(minLength: 80)
                }
            }
            .background(Color(UIColor.secondarySystemGroupedBackground)) // Overall feed background
            .refreshable {
                 // Add pull-to-refresh logic here
                 print("Refreshing feed...")
                 // Simulate network call
                 try? await Task.sleep(nanoseconds: 1_500_000_000)
                  // Example: Update badge count after refresh
                   messengerBadgeCount = Int.random(in: 0...10)
                 print("Feed refreshed!")
            }
        }
        .background(Color(UIColor.systemBackground)) // Nav bar background area
    }
}

// MARK: - Custom Tab Bar View

struct FacebookTabBarView: View {
    @Binding var selectedTab: FBTabBarItem
//    @Environment(\.safeAreaInsets) private var safeAreaInsets
    let menuProfileImageName: String = "profile_cong" // User's profile image for menu

    var body: some View {
         HStack {
            ForEach(FBTabBarItem.allCases) { item in
                Spacer()
                 Button {
                    selectedTab = item
                } label: {
                     VStack(spacing: 3) { // Reduced spacing
                         // Special case for Menu tab to show profile picture
                         if item == .menu {
                              Image(menuProfileImageName)
                                  .resizable()
                                  .scaledToFill()
                                  .frame(width: 26, height: 26) // Slightly smaller for fitting
                                  .clipShape(Circle())
                                  // Add ring if selected (optional FB style)
                                  .overlay(
                                       Circle().stroke(selectedTab == item ? Color.blue : Color.clear, lineWidth: 1.5)
                                  )

                         } else {
                             Image(systemName: selectedTab == item ? item.selectedIconName : item.iconName)
                                 .font(.system(size: 24)) // Icon size
                                 .frame(height: 26) // Fixed height for alignment
                         }

                         Text(item.title)
                             .font(.system(size: 10))
                    }
                    .foregroundColor(selectedTab == item ? .blue : .secondary) // Blue if selected
                 }
                Spacer()
            }
         }
         .frame(height: 50) // Fixed height for tab bar content
//         .padding(.bottom, safeAreaInsets.bottom > 0 ? safeAreaInsets.bottom - 8 : 0) // Adjust padding based on safe area, reduce slightly if notch exists
         .background(.thinMaterial) // Material background
         .compositingGroup()
         .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: -1) // Softer shadow
    }
}

// MARK: - Main Container View

struct FacebookMainView: View {
    @State private var selectedTab: FBTabBarItem = .home

    init() {
        // Optional: Hide the system tab bar if you were embedding in a TabView
         UITabBar.appearance().isHidden = true
    }

    var body: some View {
        ZStack(alignment: .bottom) {
             // Display the selected tab's content view
              selectedTab.view
                 // Let content views manage their own backgrounds

             // Overlay the custom tab bar
             FacebookTabBarView(selectedTab: $selectedTab)
                 // Optional: Add slight animation on tab change
                 .transition(.opacity) // Fade in/out slightly
                 .animation(.easeInOut(duration: 0.1), value: selectedTab)
         }
         .edgesIgnoringSafeArea(.bottom) // Allow tab bar to extend into safe area
    }
}

// MARK: - App Entry Point

@main
struct FacebookCloneApp: App { // RENAME this to your project name
    var body: some Scene {
        WindowGroup {
            FacebookMainView()
        }
    }
}

// MARK: - Previews

#Preview("Full Screen") {
    FacebookMainView()
}

#Preview("Home Feed Only") {
    FacebookHomeFeedView()
}

#Preview("Story Card - Create") {
    StoryCardView(story: Story(userName: nil, profileImageName: "profile_cong", storyImageName: "story_create_bg"))
         .padding()
         .background(Color.gray.opacity(0.2))
}

#Preview("Story Card - Regular") {
    StoryCardView(story: storiesData[1])
        .padding()
        .background(Color.gray.opacity(0.2))
}

#Preview("Feed Post - Multi Image") {
    FeedPostView(post: feedPostsData[0])
        .padding(.vertical)
        .background(Color(UIColor.secondarySystemGroupedBackground))
}

#Preview("Feed Post - Single Image") {
     FeedPostView(post: feedPostsData[1])
         .padding(.vertical)
         .background(Color(UIColor.secondarySystemGroupedBackground))
}

#Preview("Feed Post - Text Only") {
     FeedPostView(post: feedPostsData[2])
         .padding(.vertical)
         .background(Color(UIColor.secondarySystemGroupedBackground))
}

#Preview("Navigation Bar") {
     FacebookNavigationBar(messengerBadgeCount: .constant(5))
         .padding()
         .background(Color(UIColor.systemBackground))
}

#Preview("Tab Bar") {
     FacebookTabBarView(selectedTab: .constant(.home))
         .padding()
         .background(Color(UIColor.systemBackground))
}
