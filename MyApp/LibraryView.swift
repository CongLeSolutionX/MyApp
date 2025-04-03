//
//  LibraryView.swift
//  MyApp
//
//  Created by Cong Le on 4/2/25.
//

import SwiftUI

// MARK: - Existing Data Models (Keep All Previous)

struct Article: Identifiable { /* ... Keep existing ... */
    let id = UUID()
    let isPinned: Bool
    let authorName: String
    let authorImageName: String // Use system names or asset names
    let title: String
    let subtitle: String
    let thumbnailImageName: String // Use system names or asset names
    let datePublished: String // e.g., "Jan 1"
    let clapCount: Int
    let isBookmarked: Bool // State for bookmark icon
}

enum ProfileTab: String, CaseIterable, Identifiable { /* ... Keep existing ... */
    case stories = "Stories"
    case lists = "Lists"
    case about = "About"
    var id: String { self.rawValue }
}

struct HomeArticle: Identifiable { /* ... Keep existing ... */
    let id = UUID()
    let publicationName: String
    let publicationIconName: String // System name or asset
    let authorName: String
    let isAuthorVerified: Bool // For the blue checkmark
    let title: String
    let subtitle: String
    let thumbnailImageName: String
    let datePublished: String // e.g., "5d ago", "Mar 26"
    let clapCount: Int
    let commentCount: Int
    let isMemberOnly: Bool // For the yellow star
}

struct Topic: Identifiable, Hashable { /* ... Keep existing ... */
    let id = UUID()
    let name: String
}

struct SearchTopic: Identifiable { /* ... Keep existing ... */
    let id = UUID()
    let name: String
}

struct TrendingArticle: Identifiable { /* ... Keep existing ... */
    let id = UUID()
    let rank: Int
    let authorName: String?
    let authorImageName: String?
    let publicationName: String?
    let publicationIconName: String?
    let primaryAuthorNameForDisplay: String
    let title: String
    let datePublished: String
}

// MARK: --- NEW Data Models for Library Screen ---

enum LibraryTab: String, CaseIterable, Identifiable {
    case yourLists = "Your lists"
    case savedLists = "Saved lists"
    case highlighted = "Highlighted"
    case readingHistory = "Reading history"
    var id: String { self.rawValue }
}

struct ReadingListItem: Identifiable {
    let id = UUID()
    let authorName: String
    let authorImageName: String // Asset name
    let listTitle: String
    let storyCount: Int
    let isPrivate: Bool
    let thumbnailImageNames: [String] // Array of asset names for the previews
}

// MARK: - Sample Data (Keep All Previous + New Library Data)

let sampleArticles: [Article] = [ /* ... Keep existing ... */
    Article(isPinned: true, authorName: "Cong Le", authorImageName: "profile_pic_cong", title: "Don't Get Left Behind: iOS Development Trends Shaping 2025", subtitle: "The essential skills and tech you NEED to master to stay relevant, competitiv...", thumbnailImageName: "article_thumb_1", datePublished: "Jan 1", clapCount: 94, isBookmarked: false),
    Article(isPinned: true, authorName: "Cong Le", authorImageName: "profile_pic_cong", title: "Conquer Navigation Chaos in SwiftUI with the Coordinator Pattern", subtitle: "Discover how the Coordinator pattern can tame complex navigation flows...", thumbnailImageName: "article_thumb_2", datePublished: "Dec 15", clapCount: 120, isBookmarked: true)
]

let sampleHomeArticles: [HomeArticle] = [ /* ... Keep existing ... */
    HomeArticle(publicationName: "Level Up Coding", publicationIconName: "swift", authorName: "Michael Long", isAuthorVerified: false, title: "Why AsyncStream Doesn't Replace Combine", subtitle: "Find out why the latest and greatest hammer in the Swift toolbox might no...", thumbnailImageName: "home_thumb_1", datePublished: "5d ago", clapCount: 127, commentCount: 4, isMemberOnly: true),
    HomeArticle(publicationName: "Generative AI", publicationIconName: "brain.head.profile", authorName: "Jim Clyde Monge", isAuthorVerified: true, title: "GPT-4o's Native Image Generation", subtitle: "GPT-4o with native image generation allows you to generate images, edit a...", thumbnailImageName: "home_thumb_2", datePublished: "Mar 26", clapCount: 430, commentCount: 5, isMemberOnly: true),
    HomeArticle(publicationName: "CodeCrecker", publicationIconName: "hammer", authorName: "Dhaval Jasoliya", isAuthorVerified: false, title: "Applying SOLID Principles in iOS Development with SwiftUI", subtitle: "Learn how to implement SOLID principles practically within your SwiftUI projects...", thumbnailImageName: "home_thumb_3", datePublished: "Mar 14", clapCount: 7, commentCount: 0, isMemberOnly: true)
]

let sampleTopics: [Topic] = [ /* ... Keep existing ... */
    Topic(name: "For you"), Topic(name: "Following"), Topic(name: "Featured"), Topic(name: "Large Language Models"), Topic(name: "iOS Development"), Topic(name: "Programming"), Topic(name: "Technology")
]

let sampleSearchTopics: [SearchTopic] = [ /* ... Keep existing ... */
    SearchTopic(name: "AI"), SearchTopic(name: "Architecture"), SearchTopic(name: "Flutter Widget"), SearchTopic(name: "Programming Languages"), SearchTopic(name: "SwiftUI"), SearchTopic(name: "iOS")
]

let sampleTrendingArticles: [TrendingArticle] = [ /* ... Keep existing ... */
    TrendingArticle(rank: 1, authorName: nil, authorImageName: nil, publicationName: "Flutter", publicationIconName: "flutter_icon", primaryAuthorNameForDisplay: "Michael Thomsen", title: "Flutter 2025 roadmap update", datePublished: "8 hours ago"),
    TrendingArticle(rank: 2, authorName: nil, authorImageName: nil, publicationName: "DoublePulsar", publicationIconName: "pulsar_icon", primaryAuthorNameForDisplay: "Kevin Beaumont", title: "Oracle attempt to hide serious cybersecurity incident from customers in Oracle SaaS service", datePublished: "2 days ago"),
    TrendingArticle(rank: 3, authorName: "Fotis Adamakis", authorImageName: "author_fotis", publicationName: nil, publicationIconName: nil, primaryAuthorNameForDisplay: "Fotis Adamakis", title: "RIP Styled-Components. Now What?", datePublished: "Yesterday"),
    TrendingArticle(rank: 4, authorName: nil, authorImageName: nil, publicationName: "Netflix TechBlog", publicationIconName: "netflix_icon", primaryAuthorNameForDisplay: "Netflix Technology Blog", title: "Globalizing Productions with Netflix's Media Production Suite", datePublished: "2 days ago")
]

// --- NEW Sample Data for Library ---
let sampleReadingLists: [ReadingListItem] = [
    ReadingListItem(authorName: "Cong Le",
                    authorImageName: "profile_pic_cong", // Use your profile pic asset
                    listTitle: "Reading list",
                    storyCount: 2,
                    isPrivate: true,
                    thumbnailImageNames: ["list_thumb_1", "list_thumb_2", "list_thumb_3"]), // Add these assets
    ReadingListItem(authorName: "Cong Le",
                     authorImageName: "profile_pic_cong",
                     listTitle: "SwiftUI",
                     storyCount: 4,
                     isPrivate: false,
                     thumbnailImageNames: ["list_thumb_4", "list_thumb_5", "list_thumb_6"]) // Add these assets
    // Add more lists as needed
]

// MARK: - Existing Custom Styles & Colors (Keep All Previous)

//extension Color { /* ... Keep existing ... */
//    static let mediumBlack = Color.black
//    static let mediumGrayText = Color(UIColor.lightGray)
//    static let mediumDarkGray = Color(UIColor.darkGray)
//    static let mediumLightGray = Color(UIColor.systemGray4)
//    static let mediumGreen = Color(red: 0.1, green: 0.7, blue: 0.1) // Adjusted green
//    static let mediumWhite = Color.white
//    static let mediumBlue = Color.blue
//    static let mediumYellow = Color.yellow
//    static let searchBarGray = Color(UIColor.systemGray2)
//    static let libraryCardBackground = Color(UIColor.systemGray6).opacity(0.15) // Subtle dark background for cards
//}

//struct OutlineButtonStyle: ButtonStyle { /* ... Keep existing ... */ /*...*/ }
//struct FilledButtonStyle: ButtonStyle { /* ... Keep existing ... */ /*...*/ }
// --- NEW Green Button Style for "New List" ---
struct GreenFilledButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 15, weight: .semibold))
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .foregroundColor(.mediumWhite) // White text on green
            .background(Capsule().fill(Color.mediumGreen))
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Existing Reusable Components (Keep All Previous)
//
//struct ProfileHeaderView: View { /* ... Keep existing ... */ /*...*/ }
//struct ProfileTabView: View { /* ... Keep existing ... */ /*...*/ }
//struct FilterDropdownView: View { /* ... Keep existing ... */ /*...*/ }
//struct ArticleCardView: View { /* ... Keep existing ... */ /*...*/ }
//struct FloatingActionButton: View { /* ... Keep existing ... */ /*...*/ }
//struct MediumProfileContentView: View { /* ... Keep existing ... */ /*...*/ }
//struct HomeNavigationBar: View { /* ... Keep existing ... */ /*...*/ }
//struct TopicScrollView: View { /* ... Keep existing ... */ /*...*/ }
//struct TopicTab: View { /* ... Keep existing ... */ /*...*/ }
//struct HomeArticleCardView: View { /* ... Keep existing ... */ /*...*/ }
//struct MediumHomeContentView: View { /* ... Keep existing ... */ /*...*/ }
//struct SearchBarView: View { /* ... Keep existing ... */ /*...*/ }
//struct SearchTopicScrollView: View { /* ... Keep existing ... */ /*...*/ }
//struct SearchTopicChip: View { /* ... Keep existing ... */ /*...*/ }
//struct TrendingArticleRowView: View { /* ... Keep existing ... */ /*...*/ }
//struct MediumSearchContentView: View { /* ... Keep existing ... */ /*...*/ }

// MARK: --- NEW Library Screen Components ---

// --- Library Header (Title + New List Button) ---
struct LibraryHeaderView: View {
    var newListAction: () -> Void

    var body: some View {
        HStack {
            Text("Your library")
                .font(.system(size: 34, weight: .bold))
                .foregroundColor(.mediumWhite)

            Spacer()

            Button("New list", action: newListAction)
                .buttonStyle(GreenFilledButtonStyle())
        }
        .padding(.horizontal)
        .padding(.top) // Add padding from the top safe area
        .padding(.bottom, 5) // Space below the header
    }
}

// --- Library Tab View (Similar to Profile/Home Tabs) ---
struct LibraryTabView: View {
    @Binding var selectedTab: LibraryTab
    @Namespace private var animation

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 25) { // Adjust spacing as needed
                    ForEach(LibraryTab.allCases) { tab in
                        VStack(spacing: 8) { // Add spacing for underline
                            Text(tab.rawValue)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(selectedTab == tab ? .mediumWhite : .mediumGrayText)
                                .fixedSize() // Prevent text wrapping unnecesarily
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        selectedTab = tab
                                    }
                                }

                            // Underline
                            if selectedTab == tab {
                                Rectangle()
                                    .fill(Color.mediumWhite)
                                    .frame(height: 2)
                                    .matchedGeometryEffect(id: "libraryUnderline", in: animation)
                            } else {
                                Rectangle()
                                    .fill(Color.clear)
                                    .frame(height: 2)
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
            .frame(height: 44) // Standard tap height

            Divider()
                .background(Color.mediumDarkGray)
        }
    }
}

// --- Reading List Card View ---
struct ReadingListCardView: View {
    let item: ReadingListItem
    let thumbnailSize: CGFloat = 100 // Size for the square thumbnails

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Author Info
            HStack(spacing: 8) {
                Image(item.authorImageName) // Use asset name
                    .resizable()
                    .scaledToFill()
                    .frame(width: 24, height: 24)
                    .clipShape(Circle())
                Text(item.authorName)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.mediumWhite)
            }

            // List Title
            Text(item.listTitle)
                .font(.system(size: 24, weight: .bold)) // Larger title
                .foregroundColor(.mediumWhite)
                .padding(.top, 2) // Small space above title

            // Metadata (Story Count & Privacy)
            HStack(spacing: 8) {
                Text("\(item.storyCount) stories")
                     .font(.system(size: 14))
                     .foregroundColor(.mediumGrayText)

                if item.isPrivate {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 12)) // Smaller lock icon
                        .foregroundColor(.mediumGrayText)
                }

                 Spacer() // Pushes metadata left, leaving space for buttons

                // Action Buttons (Download & More) - Pushed right
                Button {
                    print("Download tapped: \(item.listTitle)")
                    // Add download action
                } label: {
                    Image(systemName: "arrow.down.circle") // Download icon
                        .font(.system(size: 20))
                        .foregroundColor(.mediumGrayText)
                }
                .padding(.horizontal, 5) // Add padding around button

                Button {
                    print("More options tapped: \(item.listTitle)")
                    // Add more options action
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 20))
                        .foregroundColor(.mediumGrayText)
                }
                 .padding(.leading, 5) // Add padding around button
            }
            .padding(.bottom, 10) // Space between metadata/actions and images

            // Thumbnail ScrollView
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 5) { // Spacing between thumbnails
                    ForEach(item.thumbnailImageNames, id: \.self) { imageName in
                         Image(imageName) // Use asset name
                             .resizable()
                             .scaledToFill()
                             .frame(width: thumbnailSize, height: thumbnailSize)
                             .clipped() // Clip to bounds
                             .background(Color.mediumDarkGray) // Placeholder bg if image loads slow
                             .cornerRadius(4) // Slight rounding
                    }
                    // Add placeholder rectangles if needed for layout consistency
                    // ForEach(0..<(3 - item.thumbnailImageNames.count), id: \.self) { _ in
                    //      Rectangle()
                    //          .fill(Color.mediumDarkGray.opacity(0.5))
                    //          .frame(width: thumbnailSize, height: thumbnailSize)
                    //          .cornerRadius(4)
                    // }
                }
                // No horizontal padding needed inside if ScrollView has padding
            }
            // .frame(height: thumbnailSize) // Constrain ScrollView height
        }
        .padding() // Padding inside the card
        .background(Color.libraryCardBackground) // Use the defined subtle background
        .cornerRadius(8) // Rounded corners for the card itself
    }
}

// MARK: - Main Library Screen Content View

struct MediumLibraryContentView: View {
    @State private var selectedLibraryTab: LibraryTab = .yourLists

    // Filtered lists based on the selected tab (Placeholder Logic)
    private var displayedLists: [ReadingListItem] {
        switch selectedLibraryTab {
        case .yourLists:
            // Assume sampleReadingLists are the user's lists for now
            return sampleReadingLists
        case .savedLists:
            return [] // Placeholder - Fetch/filter saved lists
        case .highlighted:
            return [] // Placeholder - Fetch/filter lists with highlights
        case .readingHistory:
            return [] // Placeholder - Fetch/filter reading history lists/articles
        }
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 15, pinnedViews: [.sectionHeaders]) { // Pin the header+tabs

                 // Pinned Header Section
                 Section {
                      // List of Reading List Cards
                      if displayedLists.isEmpty {
                           Text("No lists found in \(selectedLibraryTab.rawValue).")
                               .foregroundColor(.mediumGrayText)
                               .padding()
                               .frame(maxWidth: .infinity, alignment: .center)
                      } else {
                           ForEach(displayedLists) { item in
                               ReadingListCardView(item: item)
                                    .padding(.horizontal) // Padding around cards
                           }
                           Spacer(minLength: 80) // Spacer for TAB bar clearance
                      }

                 } header: {
                      // Sticky Header (Title + Tabs)
                       VStack(spacing: 0) {
                           LibraryHeaderView {
                               print("New List Button Tapped")
                               // Add action to create a new list
                           }
                           LibraryTabView(selectedTab: $selectedLibraryTab)
                       }
                         .background(Material.bar) // Use Material for background when sticky
                  }
            }
        }
        .background(Color.mediumBlack.ignoresSafeArea())
        .navigationBarHidden(true) // Hide the default navigation bar
        .ignoresSafeArea(edges: .bottom) // Allow content to scroll under tab bar
    }
}

// MARK: - Main Tab View (Updated to Include Library)

struct MediumTabView: View {
    @State private var selectedSystemTab = 0 // Default to Home

    init() {
        // --- Tab Bar Appearance ---
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color.mediumBlack.opacity(0.97))
        // Normal (Unselected)
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.darkGray
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.darkGray, .font: UIFont.systemFont(ofSize: 10)]
        // Selected
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor.white
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.white, .font: UIFont.systemFont(ofSize: 10)]
        UITabBar.appearance().standardAppearance = appearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }

        // --- Navigation Bar Appearance ---
         let navBarAppearance = UINavigationBarAppearance()
         navBarAppearance.configureWithOpaqueBackground()
         navBarAppearance.backgroundColor = UIColor.black
         navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
         navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
         UINavigationBar.appearance().standardAppearance = navBarAppearance
         UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
         UINavigationBar.appearance().compactAppearance = navBarAppearance
         UINavigationBar.appearance().tintColor = .white
    }

    var body: some View {
        TabView(selection: $selectedSystemTab) {
            // --- Home Tab ---
            MediumHomeContentView()
                .tag(0)
                .tabItem {
                    Label("Home", systemImage: "house")
                }

            // --- Search Tab ---
            MediumSearchContentView()
                .tag(1)
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }

            // --- Library/Bookmarks Tab ---
            MediumLibraryContentView() // Use the new Library Screen View
                .tag(2)
                .tabItem {
                    Label("Library", systemImage: "bookmark") // Changed label
                }

            // --- Profile Tab ---
             NavigationView { // Keep Profile in its own NavigationView
                 MediumProfileContentView()
             }
             .navigationViewStyle(.stack)
             .tag(3)
             .tabItem {
                  Label("Profile", systemImage: "person.crop.circle")
              }
        }
         .accentColor(.white)
         .preferredColorScheme(.dark)
    }
}

// MARK: - App Entry Point

//@main
//struct MediumCloneApp: App {
//    var body: some Scene {
//        WindowGroup {
//            MediumTabView()
//        }
//    }
//}

// MARK: - Previews

#Preview("Main Tab View (Library Selected)") {
    // Helper to select the Library tab
    struct PreviewWrapper: View {
        @State var selectedTab = 2 // Start on Library tab
        var body: some View {
            MediumTabView(selectedSystemTab: selectedTab)
        }
    }
    return PreviewWrapper()
}

#Preview("Library Content View") {
    MediumLibraryContentView()
        .preferredColorScheme(.dark)
}

#Preview("Library Header View") {
    LibraryHeaderView(newListAction: {})
        .background(Color.mediumBlack)
        .preferredColorScheme(.dark)
}

#Preview("Library Tab View") {
    LibraryTabView(selectedTab: .constant(.yourLists))
        .background(Color.mediumBlack)
        .preferredColorScheme(.dark)
}

#Preview("Reading List Card View") {
    ReadingListCardView(item: sampleReadingLists[0])
        .padding()
        .background(Color.mediumBlack)
        .preferredColorScheme(.dark)
}

// Add init to TabView preview helper if not already present
extension MediumTabView {
    init(selectedSystemTab: Int) {
       self.init() // Call the original init first
       self._selectedSystemTab = State(initialValue: selectedSystemTab)
    }
}
