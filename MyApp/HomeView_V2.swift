import SwiftUI
import UIKit

// MARK: - Data Models (Unchanged)

struct FilterChip: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let iconName: String?
}

struct VideoItem: Identifiable {
    let id = UUID()
    // Removed thumbnailName, channelIconName - will use placeholders
    let videoTitle: String
    let metadata: String // E.g., "Channel Name • 1M views • 2 days ago"
    let duration: String? // E.g., "12:34" - optional
    let isSponsored: Bool
    let sponsorInfo: String? // E.g., "Sponsored · AT&T"
    let ctaText: String? // Call to action like "thanks" button text
    let isMix: Bool
}

// MARK: - Sample Data (Adjusted for placeholders)

let filterChipsData: [FilterChip] = [
    FilterChip(title: "", iconName: "compass"), // Compass icon only
    FilterChip(title: "All", iconName: nil),
    FilterChip(title: "Podcasts", iconName: nil),
    FilterChip(title: "Music", iconName: nil),
    FilterChip(title: "News", iconName: nil),
    FilterChip(title: "Gaming", iconName: nil),
    FilterChip(title: "Live", iconName: nil),
    FilterChip(title: "Recently uploaded", iconName: nil) // Added more
]

let videoFeedData: [VideoItem] = [
    VideoItem(videoTitle: "Novelas. Now with no dead zones.", // Ad-like title
              metadata: "AT&T",
              duration: nil,
              isSponsored: true,
              sponsorInfo: "Sponsored",
              ctaText: "thanks",
              isMix: false),
    VideoItem(videoTitle: "Mix - Đạt G - Anh Tự Do Nhưng Cô Đơn | Live Music Performance", // More generic title
              metadata: "DatG Music, Best Mixes, Top Hits",
              duration: nil,
              isSponsored: false,
              sponsorInfo: nil,
              ctaText: nil,
              isMix: true),
    VideoItem(videoTitle: "Exploring SwiftUI Layout Techniques",
              metadata: "SwiftUI Masters • 50K views • 3 days ago",
              duration: "18:22",
              isSponsored: false,
              sponsorInfo: nil,
              ctaText: nil,
              isMix: false),
    VideoItem(videoTitle: "Epic Game Montage Highlights",
              metadata: "Gamer Central • 2M views • 1 day ago",
              duration: "12:05",
              isSponsored: false,
              sponsorInfo: nil,
              ctaText: nil,
              isMix: false),
]

// Sample Data for Shorts Shelf
struct ShortItem: Identifiable {
    let id = UUID()
    let title: String
    let viewCount: String
}

let shortsData: [ShortItem] = [
    ShortItem(title: "Amazing Short Clip Title", viewCount: "1.5M views"),
    ShortItem(title: "Funny Moment Captured", viewCount: "2.1M views"),
    ShortItem(title: "Quick Tutorial: iOS Tip", viewCount: "870K views"),
    ShortItem(title: "Travel Vlog Snippet", viewCount: "1.1M views"),
    ShortItem(title: "Another Cool Clip Here", viewCount: "950K views"),
]

// MARK: - Custom Styles & Colors (YouTube Theme - Unchanged)

extension Color {
    static let ytBlack = Color.black
    static let ytWhite = Color.white
    static let ytRed = Color.red
    // Adjusted grays for better contrast maybe
    static let ytGrayBackground = Color(white: 0.1) // Slightly lighter black
    static let ytGrayElement = Color(white: 0.18) // Dark background elements
    static let ytLightGrayText = Color(white: 0.65) // Lighter secondary text
    static let ytChipBackground = Color(white: 0.2) // Chip BG
    static let ytSelectedChipBackground = Color.white
    static let ytSelectedChipForeground = Color.black
    static let ytUnselectedChipForeground = Color.white
    static let ytPlaceholderGray = Color(white: 0.3) // For image placeholders
}

// MARK: - Placeholder Image View Helper

struct PlaceholderImageView: View {
    let systemName: String? // Optional icon overlay
    let width: CGFloat?
    let height: CGFloat
    let cornerRadius: CGFloat
    let color: Color = .ytPlaceholderGray
    
    var body: some View {
        Rectangle()
            .fill(color)
            .frame(width: width, height: height)
            .overlay {
                if let systemName = systemName {
                    Image(systemName: systemName)
                        .foregroundColor(Color.white.opacity(0.6))
                        .font(.system(size: height * 0.4)) // Scale icon to placeholder size
                }
            }
            .cornerRadius(cornerRadius)
            .clipped() // Ensure overlay respects corner radius
    }
}

// MARK: - Tab Bar Enum & Placeholder Views (Unchanged logic, just background color)

enum YTTabBarItem: CaseIterable, Identifiable {
    case home, shorts, create, subscriptions, you
    
    var id: Self { self }
    
    var iconName: String { // Use specific system names
        switch self {
        case .home: return "house.fill"
        case .shorts: return "play.rectangle.on.rectangle.fill" // Or a custom Shorts-like icon if available
        case .create: return "plus.circle.fill"
        case .subscriptions: return "play.square.stack.fill" // Changed from movieclapper
        case .you: return "person.circle.fill" // Use system icon now
        }
    }
    
    var title: String {
        switch self {
        case .home: return "Home"
        case .shorts: return "Shorts"
        case .create: return "" // No title for create
        case .subscriptions: return "Subscriptions"
        case .you: return "You"
        }
    }
    
}
//
//@ViewBuilder
//var customView: some View {
////    switch self {
////    case .home:
////        HomeView() // Our main implementation
//    default:
//        // Placeholder for other tabs
//        ZStack {
//            Color.ytGrayBackground.ignoresSafeArea() // Consistent background
//            VStack {
//                Spacer()
//                if self != .create {
//                    Image(systemName: iconName)
//                        .font(.system(size: 60))
//                        .foregroundColor(.ytLightGrayText.opacity(0.5))
//                    Text("\(title) Screen")
//                        .font(.title2)
//                        .foregroundColor(.ytLightGrayText)
//                } else {
//                    Text("Create Action")
//                        .font(.title2)
//                        .foregroundColor(.ytLightGrayText)
//                }
//                Spacer()
//            }
//        }
//    }
//}

// MARK: - Home Screen Components (Optimized)

// --- Top Bar ---
//struct TopBarView: View {
//    var body: some View {
//        HStack(spacing: 0) { // Reduced spacing
//            // YouTube Logo
//            HStack(spacing: 2) { // Tight spacing for logo elements
//                Image(systemName: "play.rectangle.fill")
//                    .foregroundColor(.ytRed)
//                    .font(.system(size: 28, weight: .medium)) // Slightly adjusted weight
//                Text("YouTube")
//                    .font(.system(size: 21, weight: .heavy)) // Closer to YT font weight
//                    .foregroundColor(.ytWhite)
//                    .offset(y: -1) // Fine-tune vertical alignment
//            }
//            
//            Spacer() // Pushes icons to the right
//            
//            // Action Icons - Increased spacing between icons
//            HStack(spacing: 20) { // More spacing between icons
//                Button{} label: { Image(systemName: "tv.and.hifispeaker.fill") }
//                Button{} label: { Image(systemName: "bell").overlay(NotificationBadge(count: 9)) }
//                Button{} label: { Image(systemName: "magnifyingglass") }
//            }
//            .font(.system(size: 20)) // Consistent icon size
//            .foregroundColor(.ytWhite)
//        }
//        .padding(.horizontal) // Standard horizontal padding
//        .padding(.vertical, 8) // Vertical padding
//        .background(Color.ytGrayBackground.ignoresSafeArea(edges: .top)) // Background covers status bar area
//    }
//}
//
//// Notification Badge Helper (Unchanged)
//struct NotificationBadge: View { // No changes needed here
//    let count: Int
//    var body: some View { /* ... Unchanged ... */
//        if count > 0 {
//            ZStack {
//                Circle()
//                    .fill(Color.ytRed)
//                    .frame(width: count > 9 ? 18 : 15, height: count > 9 ? 18 : 15)
//                Text(count > 9 ? "9+" : "\(count)")
//                    .foregroundColor(.white)
//                    .font(.system(size: 10, weight: .bold))
//            }
//            .offset(x: 10, y: -10)
//        } else {
//            EmptyView()
//        }
//    }
//}

// --- Filter Chip Bar ---
struct FilterChipBarView: View {
    let chips: [FilterChip]
    @State private var selectedChipId: UUID?
    
    init(chips: [FilterChip]) {
        self.chips = chips
        _selectedChipId = State(initialValue: chips.first(where: { $0.title == "All" })?.id)
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) { // Spacing between chips
                // Compass Button
                Button {} label: {
                    Image(systemName: "compass")
                        .foregroundColor(.ytWhite)
                        .frame(width: 36, height: 36) // Explicit frame for consistency
                        .background(Color.ytGrayElement) // Use consistent element BG
                        .clipShape(RoundedRectangle(cornerRadius: 8)) // Slightly less rounded corner
                }
                
                // Text Chips
                ForEach(chips.filter { $0.iconName == nil }) { chip in // Filter out icon-only chips
                    Button {
                        selectedChipId = chip.id
                    } label: {
                        Text(chip.title)
                            .font(.system(size: 14, weight: .medium))
                            .padding(.horizontal, 12) // Horizontal padding inside chip
                            .padding(.vertical, 7) // Vertical padding slightly adjusted
                            .foregroundColor(selectedChipId == chip.id ? .ytSelectedChipForeground : .ytUnselectedChipForeground)
                            .background(selectedChipId == chip.id ? Color.ytSelectedChipBackground : Color.ytChipBackground)
                            .clipShape(Capsule()) // Maintain pill shape
                    }
                }
            }
            .padding(.horizontal) // Padding for the whole scroll content
            .padding(.bottom, 10) // Space below chips
        }
        .background(Color.ytGrayBackground) // Background for the filter area
    }
}

// --- Video Card ---
struct VideoCardView: View {
    let item: VideoItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) { // Use leading alignment, no Vstack spacing
            // Thumbnail Placeholder
            ZStack(alignment: .bottomTrailing) {
                // Aspect ratio based on typical video (16:9)
                GeometryReader { geo in
                    PlaceholderImageView(systemName: item.isMix ? nil : "play.rectangle", // Icon only if not a Mix
                                         width: geo.size.width,
                                         height: geo.size.width * 9 / 16, // 16:9 ratio
                                         cornerRadius: item.isSponsored ? 0 : 10) // Sharp corners for Ads? (or keep consistent)
                }
                .aspectRatio(16/9, contentMode: .fit) // Enforce 16:9
                .padding(.bottom, item.isSponsored ? 0 : 8) // Space below thumbnail only if NOT sponsored
                
                // Duration / Mix Badge
                if !item.isSponsored { // Hide badges on sponsored for cleaner look? YT seems inconsistent.
                    if let duration = item.duration, !item.isMix {
                        BadgeView(text: duration)
                    } else if item.isMix {
                        BadgeView(text: "Mix", systemImage: "forward.fill")
                    }
                }
                
                // Ad Overlays (Position adjustments might be needed)
                if item.isSponsored {
                    VStack(spacing: 8) { // Ad elements in a VStack
                        Spacer() // Pushes content down
                        
                        // "thanks" button - Mimic style
                        if let cta = item.ctaText {
                            Button(cta) {}
                                .font(.caption.weight(.medium))
                                .foregroundColor(.ytWhite)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color.black.opacity(0.6))
                                .cornerRadius(12) // Pill-like small button
                                .padding(.trailing, 10) // Space from right edge
                        }
                        
                        // Bottom Bar Ad elements
                        HStack {
                            // Small print text removed for simplicity now
                            Spacer()
                            // Share placeholder button
                            Button {} label: {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 14))
                                    .foregroundColor(.ytWhite)
                                    .padding(8)
                                    .background(Color.black.opacity(0.5))
                                    .clipShape(Circle())
                            }
                        }
                        .padding(.horizontal, 8)
                        .padding(.bottom, 8) // Padding from bottom edge
                    }
                }
            }
            
            // Details below thumbnail
            HStack(alignment: .top, spacing: 12) { // Increased spacing
                // Channel Icon Placeholder
                Image(systemName: item.isSponsored ? "building.2.fill" : "person.circle.fill") // Different icon for sponsor?
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.ytLightGrayText)
                    .frame(width: 36, height: 36)
                    .clipShape(Circle())
                    .padding(.leading, 12) // Indent channel icon slightly
                
                VStack(alignment: .leading, spacing: 3) { // Title/metadata spacing
                    Text(item.videoTitle)
                        .font(.system(size: 15, weight: .medium)) // Slightly bolder
                        .foregroundColor(.ytWhite)
                        .lineLimit(2)
                    
                    // Sponsor/Metadata line
                    HStack(spacing: 4) { // Tight spacing within metadata
                        if item.isSponsored, let sponsorInfo = item.sponsorInfo {
                            Text(sponsorInfo)
                                .font(.caption.weight(.bold))
                                .foregroundColor(Color.yellow.opacity(0.9)) // Brighter yellow
                            // No background needed, bold text is enough
                            Text("•")
                                .foregroundColor(.ytLightGrayText)
                        }
                        Text(item.metadata)
                            .font(.caption)
                            .foregroundColor(.ytLightGrayText)
                            .lineLimit(1)
                    }
                }
                
                Spacer() // Push more button to the right
                
                // More Options Button
                Button {} label: {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.ytWhite)
                        .padding(.horizontal, 8) // Add tappable area
                }
                .padding(.trailing, 8) // Space from edge
            }
            .padding(.bottom, 16) // More space below the details section
        }
        
    }
}

// Helper Badge View for Duration/Mix
struct BadgeView: View {
    let text: String
    var systemImage: String? = nil
    
    var body: some View {
        HStack(spacing: 3) {
            if let systemImage = systemImage {
                Image(systemName: systemImage)
                    .font(.system(size: 9)) // Small icon
            }
            Text(text)
        }
        .font(.caption2.weight(.medium))
        .foregroundColor(.ytWhite)
        .padding(.horizontal, 5)
        .padding(.vertical, 3)
        .background(Color.black.opacity(0.7))
        .cornerRadius(4)
        .padding(6) // Padding around the badge
    }
}

// --- Shorts Shelf View ---
struct ShortsShelfView: View {
    let shorts: [ShortItem]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) { // Added spacing
            // Shelf Header
            HStack(spacing: 6) { // Spacing between icon and text
                // Placeholder Shorts Logo
                Image(systemName: "play.square.stack") // Placeholder icon
                    .foregroundColor(.ytRed) // Use YT Red
                    .font(.system(size: 20))
                
                Text("Shorts")
                    .font(.system(size: 18, weight: .bold)) // Slightly smaller title
                    .foregroundColor(.white)
                Spacer()
            }
            .padding(.horizontal) // Standard horizontal padding
            
            // Horizontal Scroll for Shorts
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) { // Spacing between shorts items
                    ForEach(shorts) { short in
                        ShortsThumbnailView(item: short)
                    }
                }
                .padding(.horizontal) // Padding inside scroll view
            }
        }
        .padding(.vertical, 15) // Space above/below shelf
        .background(Color.ytGrayBackground) // Consistent BG
    }
}

// --- Shorts Thumbnail View (within Shelf) ---
struct ShortsThumbnailView: View {
    let item: ShortItem
    let width: CGFloat = 100 // Fixed width for shorts
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) { // Added spacing
            // Thumbnail Placeholder
            PlaceholderImageView(systemName: "play", // Play icon overlay
                                 width: width,
                                 height: width * 1.7, // Tall aspect ratio for shorts
                                 cornerRadius: 8)
            
            Text(item.title)
                .font(.system(size: 13, weight: .medium)) // Slightly larger font
                .foregroundColor(.ytWhite)
                .lineLimit(2)
                .frame(maxWidth: width, alignment: .leading) // Ensure text wraps within width
            
            Text(item.viewCount)
                .font(.caption2)
                .foregroundColor(.ytLightGrayText)
        }
        .frame(width: width) // Constrain VStack width
    }
}

// MARK: - Home View (Main Content Area - Optimized)

struct HomeView: View {
    var body: some View {
        VStack(spacing: 0) {
            // --- Top Bar ---
//            TopBarView()
            
            // --- Main Scrollable Content ---
            ScrollView(.vertical, showsIndicators: true) { // Show scroll indicators
                LazyVStack(spacing: 0) { // No spacing managed by elements themselves
                    // --- Filter Chips ---
                    FilterChipBarView(chips: filterChipsData)
                    // Background handled inside FilterChipBarView
                    
                    // --- Video Feed ---
                    ForEach(videoFeedData) { video in
                        VideoCardView(item: video)
                            .background(Color.ytGrayBackground) // Each card has BG
                    }
                    
                    // --- Shorts Shelf ---
                    ShortsShelfView(shorts: shortsData)
                    // Background handled inside ShortsShelfView
                    
                    // --- More video cards ---
                    ForEach(videoFeedData.shuffled()) { video in // Example of more items
                        VideoCardView(item: video)
                            .background(Color.ytGrayBackground)
                    }
                    
                } // End LazyVStack
            } // End ScrollView
            .background(Color.ytGrayBackground) // BG for scrollable area
            .coordinateSpace(name: "scrollView")
        }
        .background(Color.ytGrayBackground.ignoresSafeArea()) // BG for the entire view
        // Don't ignore bottom safe area here, let TabBar handle it
    }
}

// MARK: - Custom Tab Bar (Optimized)

struct CustomTabBarView: View {
    @Binding var selectedTab: YTTabBarItem
    //    @Environment(\.safeAreaInsets) private var safeAreaInsets
    
    var body: some View {
        HStack() { // Default spacing might be okay
            ForEach(YTTabBarItem.allCases) { item in
                Spacer() // Distribute items evenly
                Button {
                    if item == .create {
                        print("Create Button Tapped (Placeholder Action)")
                        // Add action to present modal/sheet
                    } else {
                        selectedTab = item
                    }
                } label: {
                    VStack(spacing: item == .create ? 0 : 4) { // No space for create icon itself
                        if item == .create {
                            Image(systemName: item.iconName)
                                .font(.system(size: 36, weight: .thin)) // Larger, thinner plus
                                .foregroundColor(.ytWhite)
                            // Removed background circle for YT's style
                        } else {
                            Image(systemName: item.iconName)
                                .font(.system(size: 22))
                                .frame(height: 25) // Keep consistent height
                                .overlay(alignment: .topTrailing) { // Use overlay for badges
                                    if item == .subscriptions {
                                        Circle() // Simple red dot badge
                                            .fill(Color.ytRed)
                                            .frame(width: 6, height: 6)
                                            .offset(x: 2, y: 0) // Adjust position
                                    }
                                    // Removed the profile picture logic for simplicity, using system icon
                                }
                            
                            Text(item.title)
                                .font(.system(size: 10)) // Standard caption size
                        }
                    }
                    // Use standard foreground colors, selected state tints the whole button content
                    .foregroundColor(selectedTab == item && item != .create ? .ytWhite : .ytLightGrayText)
                    .frame(height: 49) // Ensure consistent tap area height
                }
                .frame(maxWidth: .infinity) // Allow buttons to expand
                Spacer()
            }
        }
        .frame(height: 50) // Overall height of the tab bar content
        //            .padding(.bottom, safeAreaInsets.bottom > 0 ? safeAreaInsets.bottom - 5 : 0) // Adjust padding for safe area notch/bar
        .background(Color.ytGrayElement) // Use element background color
        .compositingGroup()
    }
}

// MARK: - Main Container View (Optimized)
//
//struct MainTabView: View {
//    @State private var selectedTab: YTTabBarItem = .home
//    
//    init() {
//        // Optional: Configure global appearances if needed, though less relevant for custom UI
//        // e.g., UINavigationBar appearance if using NavigationView elsewhere
//    }
//    
//    var body: some View {
//        ZStack(alignment: .bottom) {
//            selectedTab.hashValue == 0 ? Text("Home") : Text("Search") // The content view for the selected tab
//            
//            Divider() // Add a subtle line above the tab bar
//                .overlay(Color.ytLightGrayText.opacity(0.3))
//                .frame(height: 0.5)
//            //                .offset(y: -50 - (safeAreaInsets.bottom > 0 ? safeAreaInsets.bottom - 5 : 0)) // Position above tab bar
//            
//            CustomTabBarView(selectedTab: $selectedTab) // Our custom tab bar
//        }
//        .preferredColorScheme(.dark) // Enforce dark mode
//        // No edgesIgnoringSafeArea needed here, let content and tab bar manage it
//    }
//    
//    // Added to access safe area insets for positioning the Divider
//    //    @Environment(\.safeAreaInsets) private var safeAreaInsets
//}

// MARK: - App Entry Point (Unchanged)

//    @main
//    struct YouTubeCloneOptimizedApp: App { // Renamed App struct
//        var body: some Scene {
//            WindowGroup {
//                MainTabView()
//            }
//        }
//    }

// MARK: - Previews (Adjusted for Placeholders)

//#Preview("Full App") {
//    MainTabView()
//}

#Preview("Home View Only") {
    HomeView()
        .preferredColorScheme(.dark)
}

#Preview("Video Card - Normal") {
    VideoCardView(item: videoFeedData[2]) // Use a non-ad, non-mix item
        .padding()
        .background(Color.ytGrayBackground)
        .preferredColorScheme(.dark)
}

#Preview("Video Card - Ad") {
    VideoCardView(item: videoFeedData[0]) // Ad item
        .padding()
        .background(Color.ytGrayBackground)
        .preferredColorScheme(.dark)
}

#Preview("Video Card - Mix") {
    VideoCardView(item: videoFeedData[1]) // Mix item
        .padding()
        .background(Color.ytGrayBackground)
        .preferredColorScheme(.dark)
}

#Preview("Shorts Shelf") {
    ShortsShelfView(shorts: shortsData)
    // .padding() // Padding is handled inside now
        .background(Color.ytGrayBackground)
        .preferredColorScheme(.dark)
}
//
//#Preview("Top Bar") {
//    TopBarView()
//        .preferredColorScheme(.dark)
//}

#Preview("Filter Chips") {
    FilterChipBarView(chips: filterChipsData)
    // .padding() // Padding handled inside
        .background(Color.ytBlack) // Use black for contrast in preview if needed
        .preferredColorScheme(.dark)
}

#Preview("Tab Bar") {
    CustomTabBarView(selectedTab: .constant(.home))
        .background(Color.ytGrayElement)
        .preferredColorScheme(.dark)
}
