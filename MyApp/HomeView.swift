////
////  HomeView.swift
////  MyApp
////
////  Created by Cong Le on 4/2/25.
////
//
//import SwiftUI
//
//// MARK: - Data Models
//
//struct FilterChip: Identifiable, Hashable {
//    let id = UUID()
//    let title: String
//    let iconName: String? // Optional icon (like the compass)
//}
//
//struct VideoItem: Identifiable {
//    let id = UUID()
//    let thumbnailName: String
//    let channelIconName: String
//    let videoTitle: String
//    let metadata: String // E.g., "Channel Name • 1M views • 2 days ago"
//    let duration: String? // E.g., "12:34" - optional
//    let isSponsored: Bool
//    let sponsorInfo: String? // E.g., "Sponsored · AT&T"
//    let ctaText: String? // Call to action like "thanks" button text
//    let isMix: Bool
//}
//
//// MARK: - Sample Data
//
//let filterChipsData: [FilterChip] = [
//    FilterChip(title: "", iconName: "compass"), // Compass icon only
//    FilterChip(title: "All", iconName: nil),
//    FilterChip(title: "Podcasts", iconName: nil),
//    FilterChip(title: "Music", iconName: nil),
//    FilterChip(title: "News", iconName: nil),
//    FilterChip(title: "Startup companies", iconName: nil),
//    FilterChip(title: "Gaming", iconName: nil), // Added more examples
//    FilterChip(title: "Live", iconName: nil)
//]
//
//let videoFeedData: [VideoItem] = [
//    VideoItem(thumbnailName: "yt_ad_thumbnail", // Replace with actual asset names
//              channelIconName: "att_logo",
//              videoTitle: "Live like a GIGillionaire℠",
//              metadata: "AT&T", // Simplified for example
//              duration: nil,
//              isSponsored: true,
//              sponsorInfo: "Sponsored",
//              ctaText: "thanks",
//              isMix: false),
//    VideoItem(thumbnailName: "yt_video_thumbnail",
//              channelIconName: "datg_logo", // Use a placeholder if needed
//              videoTitle: "Mix - Đạt G - Anh Tự Do Nhưng Cô Đơn | Live at #DearOcean @DatGMusic",
//              metadata: "DatG Music, QUÂN A.P, Nguyen Tran Trung Quan, and more",
//              duration: nil, // Example: "3:45:12" if available
//              isSponsored: false,
//              sponsorInfo: nil,
//              ctaText: nil,
//              isMix: true),
//    VideoItem(thumbnailName: "yt_placeholder_2", // Add more placeholders
//              channelIconName: "placeholder_channel",
//              videoTitle: "Another Interesting Video Title Goes Here",
//              metadata: "Awesome Channel • 1.2M views • 1 week ago",
//              duration: "15:01",
//              isSponsored: false,
//              sponsorInfo: nil,
//              ctaText: nil,
//              isMix: false),
//]
//
//// MARK: - Custom Styles & Colors (YouTube Theme)
//
//extension Color {
//    static let ytBlack = Color.black
//    static let ytWhite = Color.white
//    static let ytRed = Color.red
//    static let ytGray = Color(white: 0.18) // Dark gray background elements
//    static let ytLightGray = Color(white: 0.5) // Secondary text
//    static let ytChipBackground = Color(white: 0.15)
//    static let ytSelectedChipBackground = Color.white
//    static let ytSelectedChipForeground = Color.black
//    static let ytUnselectedChipForeground = Color.white
//}
//
//// Placeholder for Shorts Thumbnail View
//struct ShortsThumbnailView: View {
//     let imageName: String
//     let title: String
//
//     var body: some View {
//         VStack(alignment: .leading, spacing: 4) {
//             Image(imageName) // Use placeholder name
//                 .resizable()
//                 .aspectRatio(contentMode: .fill)
//                 .frame(width: 100, height: 160) // Typical Shorts aspect ratio
//                 .clipped()
//                 .cornerRadius(8)
//
//             Text(title)
//                 .font(.caption)
//                 .fontWeight(.medium)
//                 .foregroundColor(.ytWhite)
//                 .lineLimit(2)
//
//             Text("1.5M views") // Example metadata
//                 .font(.caption2)
//                 .foregroundColor(.ytLightGray)
//         }
//         .frame(width: 100)
//     }
// }
//
//// MARK: - Tab Bar Enum & Placeholder Views
//
//enum YTTabBarItem: CaseIterable, Identifiable {
//    case home, shorts, create, subscriptions, you
//
//    var id: Self { self }
//
//    var iconName: String {
//        switch self {
//        case .home: return "house.fill"
//        case .shorts: return "play.rectangle.on.rectangle.fill" // Example icon
//        case .create: return "plus.circle.fill"
//        case .subscriptions: return "play.square.stack.fill"
//        case .you: return "person.circle.fill"         }
//    }
//
//    var title: String {
//        switch self {
//        case .home: return "Home"
//        case .shorts: return "Shorts"
//        case .create: return "" // No title for create
//        case .subscriptions: return "Subscriptions"
//        case .you: return "You"
//        }
//    }
//
//    @ViewBuilder
//    var view: some View {
//        switch self {
//        case .home:
//            HomeView() // Our main implementation
//        default:
//            // Placeholder for other tabs
//            ZStack {
//                Color.ytBlack.ignoresSafeArea() // Consistent background
//                VStack {
//                    Spacer()
//                    if self != .create { // Create usually opens a modal/sheet
//                        Image(systemName: iconName)
//                            .font(.system(size: 60))
//                            .foregroundColor(.ytLightGray.opacity(0.5))
//                        Text("\(title) Screen")
//                            .font(.title2)
//                            .foregroundColor(.ytLightGray)
//                    } else {
//                        Text("Create Action")
//                            .font(.title2)
//                            .foregroundColor(.ytLightGray)
//                    }
//                    Spacer()
//                }
//            }
//        }
//    }
//}
//
//// MARK: - Home Screen Components
//
//// --- Top Bar ---
//struct TopBarView: View {
//    var body: some View {
//        HStack(spacing: 15) {
//            // YouTube Logo (use a placeholder image ideally)
//            HStack(spacing: 2) {
//                Image(systemName: "play.rectangle.fill") // System symbol placeholder
//                    .foregroundColor(.ytRed)
//                    .font(.system(size: 28))
//                 Text("YouTube")
//                    .font(.system(size: 20, weight: .bold)) // Custom font resembles YT logo
//                    .foregroundColor(.ytWhite)
//             }
//
//            Spacer()
//
//            // Action Icons
//            Button {} label: {
//                Image(systemName: "tv.and.hifispeaker.fill")
//            }
//
//            Button {} label: {
//                Image(systemName: "bell")
//                    .overlay(NotificationBadge(count: 9)) // Pass the count
//            }
//
//            Button {} label: {
//                Image(systemName: "magnifyingglass")
//            }
//        }
//        .font(.system(size: 20)) // Default size for icons
//        .foregroundColor(.ytWhite)
//        .padding(.horizontal)
//        .padding(.vertical, 8)
//        .background(Color.ytBlack) // Top bar sticks
//    }
//}
//
//// Notification Badge Helper
//struct NotificationBadge: View {
//    let count: Int
//
//    var body: some View {
//        if count > 0 {
//            ZStack {
//                Circle()
//                    .fill(Color.ytRed)
//                    // Adjust size based on count digits? Simple fixed size for now.
//                    .frame(width: count > 9 ? 18 : 15, height: count > 9 ? 18 : 15) // Slightly larger for 9+
//
//                Text(count > 9 ? "9+" : "\(count)")
//                    .foregroundColor(.white)
//                    .font(.system(size: 10, weight: .bold))
//            }
//            // Position the badge (adjust offsets as needed)
//            .offset(x: 10, y: -10)
//        } else {
//             EmptyView()
//         }
//    }
//}
//
//// --- Filter Chip Bar ---
//struct FilterChipBarView: View {
//    let chips: [FilterChip]
//    @State private var selectedChipId: UUID?
//
//    init(chips: [FilterChip]) {
//        self.chips = chips
//        // Set initial selection to "All" if present
//        _selectedChipId = State(initialValue: chips.first(where: { $0.title == "All" })?.id)
//    }
//
//    var body: some View {
//        ScrollView(.horizontal, showsIndicators: false) {
//            HStack(spacing: 8) {
//                // Compass Button (special case)
//                Button {} label: {
//                    Image(systemName: "compass")
//                        .foregroundColor(.ytWhite)
//                        .padding(10)
//                        .background(Color.ytGray) // Slightly different background
//                        .clipShape(RoundedRectangle(cornerRadius: 8)) // More rectangular
//                }
//
//                // Text Chips
//                ForEach(chips.filter { !$0.title.isEmpty }) { chip in // Exclude the compass chip data
//                    Button {
//                        selectedChipId = chip.id
//                    } label: {
//                        Text(chip.title)
//                            .font(.system(size: 14, weight: .medium))
//                            .padding(.horizontal, 12)
//                            .padding(.vertical, 8)
//                            .foregroundColor(selectedChipId == chip.id ? .ytSelectedChipForeground : .ytUnselectedChipForeground)
//                            .background(selectedChipId == chip.id ? Color.ytSelectedChipBackground : Color.ytChipBackground)
//                            .cornerRadius(18) // Pill shape
//                    }
//                }
//            }
//            .padding(.horizontal)
//            .padding(.bottom, 8) // Space below chips
//        }
//        // Ensure bar sticks // No, it scrolls with content in YT
//        // .background(Color.ytBlack)
//    }
//}
//
//// --- Video Card ---
//struct VideoCardView: View {
//    let item: VideoItem
//
//    var body: some View {
//        VStack(spacing: 0) {
//            // Thumbnail
//            ZStack(alignment: .bottomTrailing) {
//                Image(item.thumbnailName) // Use placeholder name
//                    .resizable()
//                    .aspectRatio(contentMode: .fit) // Fit width
//                    .frame(maxWidth: .infinity)
//                   // .clipped() // No clipping needed with .fit
//
//                // Duration / Mix Badge
//                if let duration = item.duration, !item.isMix {
//                    Text(duration)
//                        .font(.caption2)
//                        .foregroundColor(.ytWhite)
//                        .padding(4)
//                        .background(Color.black.opacity(0.7))
//                        .cornerRadius(4)
//                        .padding(6)
//                } else if item.isMix {
//                    HStack(spacing: 4) {
//                        Image(systemName: "forward.fill") // Example mix icon
//                        Text("Mix")
//                    }
//                    .font(.caption2)
//                    .foregroundColor(.ytWhite)
//                    .padding(4)
//                    .background(Color.black.opacity(0.7))
//                    .cornerRadius(4)
//                    .padding(6)
//
//                }
//
//                // Additional overlays for Ad (example)
//                if item.isSponsored {
//                     VStack(alignment: .trailing, spacing: 8) {
//                         Spacer() // Push to bottom
//
//                         if let cta = item.ctaText {
//                             Button(cta) {}
//                                .font(.caption)
//                                .foregroundColor(.black)
//                                 .padding(.horizontal, 10)
//                                 .padding(.vertical, 5)
//                                 .background(Color.white.opacity(0.8))
//                                 .cornerRadius(5)
//                         }
//
//                         HStack {
//                             Text("Requires AT&T Extended Wi-Fi coverage service for an additional monthly charge.")
//                                .font(.system(size: 8))
//                                .foregroundColor(.white.opacity(0.7))
//                                .padding(.leading, 5) // Indent a bit
//                            Spacer()
//                            Button {} label: {
//                                Image(systemName: "square.and.arrow.up")
//                                     .foregroundColor(.white)
//                                     .padding(8)
//                                     .background(Color.black.opacity(0.5))
//                                     .clipShape(Circle())
//                             }
//                         }
//                         .padding(.bottom, 5)
//                         .padding(.trailing, 5)
//                     }
//                     .padding(.horizontal, 5) // Overall horizontal padding for overlays
//                     .padding(.bottom, 5) // Padding from bottom edge
//
//                    // Separate Overlays for CC/Mute if needed (add buttons)
//                    // ...
//                }
//
//            }
//
//            // Details below thumbnail
//            HStack(alignment: .top, spacing: 12) {
//                Image(item.channelIconName) // Channel Icon
//                    .resizable()
//                    .scaledToFit()
//                    .frame(width: 36, height: 36)
//                    .clipShape(Circle())
//
//                VStack(alignment: .leading, spacing: 2) {
//                    Text(item.videoTitle)
//                        .font(.system(size: 15, weight:.medium))
//                        .foregroundColor(.ytWhite)
//                        .lineLimit(2) // Limit title lines
//
//                    HStack(spacing: 4) {
//                         if item.isSponsored, let sponsorInfo = item.sponsorInfo {
//                            Text(sponsorInfo)
//                                .font(.caption)
//                                .foregroundColor(Color.yellow.opacity(0.8)) // Sponsored label style
//                                .padding(.horizontal, 4)
//                                .background(Color.yellow.opacity(0.2))
//                                .cornerRadius(3)
//                            Text("•")
//                                .foregroundColor(.ytLightGray)
//                        }
//                         Text(item.metadata)
//                             .font(.caption)
//                            .foregroundColor(.ytLightGray)
//                             .lineLimit(1) // Limit metadata line
//                     }
//                }
//
//                Spacer() // Push more button to the right
//
//                // More Options Button
//                Button {} label: {
//                    Image(systemName: "ellipsis")
//                        .foregroundColor(.ytWhite)
//                }
//            }
//            .padding(.horizontal, 12)
//            .padding(.vertical, 10)
//        }
//         .padding(.bottom, 15) // Space between video cards
//    }
//}
//
//// --- Shorts Shelf View ---
//struct ShortsShelfView: View {
//    var body: some View {
//         VStack(alignment: .leading) {
//             // Shelf Header
//            HStack(spacing: 4) {
//                 Image("shorts_logo") // Replace with actual Shorts logo asset
//                     .resizable()
//                     .scaledToFit()
//                     .frame(height: 20)
//                 Text("Shorts")
//                     .font(.title3)
//                     .fontWeight(.bold)
//                     .foregroundColor(.white)
//                Spacer()
//             }
//             .padding(.horizontal)
//             .padding(.bottom, 5)
//
//             // Horizontal Scroll for Shorts
//            ScrollView(.horizontal, showsIndicators: false) {
//                 HStack(spacing: 10) {
//                     // Example Shorts Thumbnails
//                    ShortsThumbnailView(imageName: "yt_placeholder_1", title: "Amazing Short Clip Title")
//                    ShortsThumbnailView(imageName: "yt_placeholder_2", title: "Funny Moment Captured")
//                    ShortsThumbnailView(imageName: "yt_placeholder_3", title: "Quick Tutorial")
//                    ShortsThumbnailView(imageName: "yt_placeholder_1", title: "Travel Vlog Snippet")
//                    ShortsThumbnailView(imageName: "yt_placeholder_2", title: "Another Clip")
//                 }
//                 .padding(.horizontal)
//             }
//        }
//        .padding(.vertical, 10) // Space above/below shelf
//    }
//}
//
//// MARK: - Home View (Main Content Area)
//
//struct HomeView: View {
//    var body: some View {
//        VStack(spacing: 0) {
//            // --- Top Bar ---
//            TopBarView()
//
//            // --- Main Scrollable Content ---
//            ScrollView(.vertical, showsIndicators: false) {
//                LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
//                    // --- Filter Chips ---
//                    // Needs to be a Section Header to be pinnable if desired,
//                    // but YT's doesn't pin, it scrolls *with* content.
//                    // So, just include it directly in LazyVStack.
//                    FilterChipBarView(chips: filterChipsData)
//                        .padding(.top, 5) // Space below top bar
//                        .background(Color.ytBlack) // Match background
//
//                    // --- Video Feed ---
//                    ForEach(videoFeedData) { video in
//                        VideoCardView(item: video)
//                    }
//
//                    // --- Shorts Shelf ---
//                    ShortsShelfView()
//
//                   // --- Add more video cards or other sections ---
//                   ForEach(videoFeedData.shuffled()) { video in // Add some variety
//                       VideoCardView(item: video)
//                   }
//
//                } // End LazyVStack
//            } // End ScrollView
//            .coordinateSpace(name: "scrollView") // Needed? Maybe for parallax later.
//        }
//        .background(Color.ytBlack.ignoresSafeArea()) // Background for the entire HomeView
//        .edgesIgnoringSafeArea(.bottom) // Let content go under custom tab bar
//    }
//}
//
//// MARK: - Custom Tab Bar
//
//struct CustomTabBarView: View {
//    @Binding var selectedTab: YTTabBarItem
////    @Environment(\.safeAreaInsets) private var safeAreaInsets
//
//    var body: some View {
//        HStack(alignment: .bottom) { // Align items to bottom edge
//            ForEach(YTTabBarItem.allCases) { item in
//                Spacer()
//                 Button {
//                     // Handle create action (e.g., show a sheet/modal)
//                     if item == .create {
//                         print("Create Button Tapped")
//                         // Typically you'd trigger state change to show a modal here
//                     } else {
//                         selectedTab = item // Update state on tap for other tabs
//                     }
//                 } label: {
//                     VStack(spacing: 4) {
//                         // Custom "+"" Button Styling
//                         if item == .create {
//                             Image(systemName: item.iconName)
//                                 .font(.system(size: 24, weight: .semibold)) // Thicker plus
//                                 .foregroundColor(.ytBlack) // Icon color inside circle
//                                 .frame(width: 40, height: 40) // Size of circle
//                                 .background(Color.ytWhite)
//                                 .clipShape(Circle())
//                                 // No label for Create button
//                         } else {
//                             // Standard Icons
//                             Image(systemName: item.iconName)
//                                 .font(.system(size: item == .you ? 20 : 22)) // Slightly smaller 'You' icon if needed
//                                 .frame(height: 25) // Consistent icon area height
//                                  .overlay( // Badges for Subscriptions/You
//                                     VStack { // Use VStack for positioning
//                                         if item == .subscriptions {
//                                             // Red dot badge for subscriptions
//                                            Circle()
//                                                 .fill(Color.ytRed)
//                                                 .frame(width: 5, height: 5)
//                                                 .offset(x: 10, y: -2) // Adjust position
//                                         } else if item == .you {
//                                              // Replace person.circle.fill with Profile Image
//                                             // Example Profile Image
//                                             Image("profile_placeholder") // Add this to assets
//                                                   .resizable()
//                                                   .scaledToFit()
//                                                   .frame(width: 24, height: 24)
//                                                   .clipShape(Circle())
//                                                   .padding(.bottom, 2) // Adjust spacing slightly
//                                                   // Remove the system icon if using profile image
//                                                   .colorMultiply(.clear) // Hide original icon
//                                         }
//                                     }
//                                      , alignment: .topTrailing // Align badge container
//                                  )
//
//                             Text(item.title)
//                                 .font(.system(size: 10))
//                         }
//
//                     }
//                     .foregroundColor(selectedTab == item && item != .create ? .ytWhite : .ytLightGray) // Selected/Unselected colors
//                 }
//                 // Give tappable area priority to 'Create' button if needed
//                 .zIndex(item == .create ? 1 : 0)
//                Spacer()
//            }
//        }
//        .frame(height: 50) // Define height for the tab bar content area
////        .padding(.bottom, safeAreaInsets.bottom > 0 ? safeAreaInsets.bottom - 8 : 0) // Adjust padding slightly for safe area curve
//        .background(Color.ytBlack) // Background for tab bar
//        .compositingGroup()
//        // No top shadow needed for YT dark theme
//    }
//}
//
//// MARK: - Main Container View
//
//struct MainTabView: View {
//    @State private var selectedTab: YTTabBarItem = .home
//
//    var body: some View {
//        ZStack(alignment: .bottom) {
//            // Display the selected tab's view
//            selectedTab.view
//                .background(Color.ytBlack) // Ensure background consistency if view doesn't set it
//
//            // Custom Tab Bar on top
//            CustomTabBarView(selectedTab: $selectedTab)
//
//        }
//         .preferredColorScheme(.dark) // Force dark mode for YT theme
//         .edgesIgnoringSafeArea(.bottom) // Let tab bar extend into safe area
//    }
//}
//
//// MARK: - App Entry Point
//
//@main
//struct YouTubeCloneApp: App { // Make sure this matches your project App name
//    var body: some Scene {
//        WindowGroup {
//            MainTabView()
//        }
//    }
//}
//
//// MARK: - Previews
//
//#Preview("Full App") {
//    MainTabView()
//}
//
//#Preview("Home View Only") {
//    HomeView()
//        .preferredColorScheme(.dark)
//}
//
//#Preview("Video Card") {
//    VideoCardView(item: videoFeedData[1])
//        .padding()
//        .background(Color.ytBlack)
//        .preferredColorScheme(.dark)
//}
//
//#Preview("Ad Card") {
//    VideoCardView(item: videoFeedData[0])
//        .padding()
//        .background(Color.ytBlack)
//        .preferredColorScheme(.dark)
//}
//
//#Preview("Shorts Shelf") {
//     ShortsShelfView()
//         .padding()
//         .background(Color.ytBlack)
//         .preferredColorScheme(.dark)
// }
//
//#Preview("Top Bar") {
//    TopBarView()
//        .preferredColorScheme(.dark)
//}
//
//#Preview("Filter Chips") {
//    FilterChipBarView(chips: filterChipsData)
//        .padding()
//        .background(Color.ytBlack)
//        .preferredColorScheme(.dark)
//}
//
//#Preview("Tab Bar") {
//    CustomTabBarView(selectedTab: .constant(.home))
//        .background(Color.ytBlack)
//        .preferredColorScheme(.dark)
//}
