//
//  ExploreView.swift
//  MyApp
//
//  Created by Cong Le on 4/2/25.
//

import SwiftUI
//
//// MARK: - Existing Data Models (From Profile & Home Screens)
//
//struct Article: Identifiable { /* ... Keep existing ... */
//    let id = UUID()
//    let isPinned: Bool
//    let authorName: String
//    let authorImageName: String // Use system names or asset names
//    let title: String
//    let subtitle: String
//    let thumbnailImageName: String // Use system names or asset names
//    let datePublished: String // e.g., "Jan 1"
//    let clapCount: Int
//    let isBookmarked: Bool // State for bookmark icon
//}
//
//enum ProfileTab: String, CaseIterable, Identifiable { /* ... Keep existing ... */
//    case stories = "Stories"
//    case lists = "Lists"
//    case about = "About"
//    var id: String { self.rawValue }
//}
//
//struct HomeArticle: Identifiable { /* ... Keep existing ... */
//    let id = UUID()
//    let publicationName: String
//    let publicationIconName: String // System name or asset
//    let authorName: String
//    let isAuthorVerified: Bool // For the blue checkmark
//    let title: String
//    let subtitle: String
//    let thumbnailImageName: String
//    let datePublished: String // e.g., "5d ago", "Mar 26"
//    let clapCount: Int
//    let commentCount: Int
//    let isMemberOnly: Bool // For the yellow star
//}
//
//struct Topic: Identifiable, Hashable { /* ... Keep existing ... */
//    let id = UUID()
//    let name: String
//}
//
//// MARK: --- NEW Data Models for Search Screen ---
//
//struct SearchTopic: Identifiable {
//    let id = UUID()
//    let name: String
//}
//
//struct TrendingArticle: Identifiable {
//    let id = UUID()
//    let rank: Int
//    // Either author or publication info will be present
//    let authorName: String?
//    let authorImageName: String? // Can be nil if publication is primary
//    let publicationName: String?
//    let publicationIconName: String? // Can be nil if author is primary
//    let primaryAuthorNameForDisplay: String // The name shown after "by" or standalone
//
//    let title: String
//    let datePublished: String // e.g., "8 hours ago", "Yesterday"
//}
//
//// MARK: - Sample Data (Existing and New)
//
//let sampleArticles: [Article] = [ /* ... Keep existing ... */
//    Article(isPinned: true,
//            authorName: "Cong Le",
//            authorImageName: "profile_pic_cong",
//            title: "Don't Get Left Behind: iOS Development Trends Shaping 2025",
//            subtitle: "The essential skills and tech you NEED to master to stay relevant, competitiv...",
//            thumbnailImageName: "article_thumb_1", // Add this asset
//            datePublished: "Jan 1",
//            clapCount: 94,
//            isBookmarked: false),
//    Article(isPinned: true,
//            authorName: "Cong Le",
//            authorImageName: "profile_pic_cong",
//            title: "Conquer Navigation Chaos in SwiftUI with the Coordinator Pattern",
//            subtitle: "Discover how the Coordinator pattern can tame complex navigation flows...",
//            thumbnailImageName: "article_thumb_2", // Add this asset
//            datePublished: "Dec 15",
//            clapCount: 120,
//            isBookmarked: true)
//]
//
//let sampleHomeArticles: [HomeArticle] = [ /* ... Keep existing ... */
//    HomeArticle(publicationName: "Level Up Coding",
//                publicationIconName: "swift", // Placeholder icon
//                authorName: "Michael Long",
//                isAuthorVerified: false,
//                title: "Why AsyncStream Doesn't Replace Combine",
//                subtitle: "Find out why the latest and greatest hammer in the Swift toolbox might no...",
//                thumbnailImageName: "home_thumb_1", // Replace with asset
//                datePublished: "5d ago",
//                clapCount: 127,
//                commentCount: 4,
//                isMemberOnly: true),
//    HomeArticle(publicationName: "Generative AI",
//                publicationIconName: "brain.head.profile", // Placeholder icon
//                authorName: "Jim Clyde Monge",
//                isAuthorVerified: true, // Has blue checkmark
//                title: "GPT-4o's Native Image Generation",
//                subtitle: "GPT-4o with native image generation allows you to generate images, edit a...",
//                thumbnailImageName: "home_thumb_2", // Replace with asset
//                datePublished: "Mar 26",
//                clapCount: 430,
//                commentCount: 5,
//                isMemberOnly: true),
//    HomeArticle(publicationName: "CodeCrecker",
//                publicationIconName: "hammer", // Placeholder icon
//                authorName: "Dhaval Jasoliya",
//                isAuthorVerified: false,
//                title: "Applying SOLID Principles in iOS Development with SwiftUI",
//                subtitle: "Learn how to implement SOLID principles practically within your SwiftUI projects...",
//                thumbnailImageName: "home_thumb_3", // Replace with asset
//                datePublished: "Mar 14",
//                clapCount: 7,
//                commentCount: 0, // Assuming 0 if not shown
//                isMemberOnly: true)
//]
//
//let sampleTopics: [Topic] = [ /* ... Keep existing ... */
//    Topic(name: "For you"),
//    Topic(name: "Following"),
//    Topic(name: "Featured"),
//    Topic(name: "Large Language Models"),
//    Topic(name: "iOS Development"),
//    Topic(name: "Programming"),
//    Topic(name: "Technology")
//]
//
//// --- NEW Sample Data for Search ---
//let sampleSearchTopics: [SearchTopic] = [
//    SearchTopic(name: "AI"),
//    SearchTopic(name: "Architecture"),
//    SearchTopic(name: "Flutter Widget"),
//    SearchTopic(name: "Programming Languages"),
//    SearchTopic(name: "SwiftUI"),
//    SearchTopic(name: "iOS")
//]
//
//let sampleTrendingArticles: [TrendingArticle] = [
//    TrendingArticle(rank: 1,
//                    authorName: nil, // Publication primary
//                    authorImageName: nil,
//                    publicationName: "Flutter",
//                    publicationIconName: "flutter_icon", // Add asset
//                    primaryAuthorNameForDisplay: "Michael Thomsen",
//                    title: "Flutter 2025 roadmap update",
//                    datePublished: "8 hours ago"),
//    TrendingArticle(rank: 2,
//                    authorName: nil, // Publication primary
//                    authorImageName: nil,
//                    publicationName: "DoublePulsar",
//                    publicationIconName: "pulsar_icon", // Add asset
//                    primaryAuthorNameForDisplay: "Kevin Beaumont",
//                    title: "Oracle attempt to hide serious cybersecurity incident from customers in Oracle SaaS service",
//                    datePublished: "2 days ago"),
//    TrendingArticle(rank: 3,
//                    authorName: "Fotis Adamakis",
//                    authorImageName: "author_fotis", // Add asset
//                    publicationName: nil, // Author primary
//                    publicationIconName: nil,
//                    primaryAuthorNameForDisplay: "Fotis Adamakis",
//                    title: "RIP Styled-Components. Now What?",
//                    datePublished: "Yesterday"),
//    TrendingArticle(rank: 4,
//                   authorName: nil, // Publication primary
//                   authorImageName: nil,
//                    publicationName: "Netflix TechBlog",
//                    publicationIconName: "netflix_icon", // Add asset
//                    primaryAuthorNameForDisplay: "Netflix Technology Blog", // Pub name repeated?
//                   title: "Globalizing Productions with Netflix's Media Production Suite",
//                   datePublished: "2 days ago")
//    // Add more sample articles as needed
//]
//
//
//// MARK: - Main Tab View (Updated)
//
//struct MediumTabView: View {
//     // Keep state and init from previous response
//    @State private var selectedSystemTab = 0 // START ON HOME TAB
//
//    init() {
//        // --- Tab Bar Appearance ---
//        let appearance = UITabBarAppearance()
//        appearance.configureWithOpaqueBackground()
//        appearance.backgroundColor = UIColor(Color.mediumBlack.opacity(0.97)) // Dark background
//
//        // Normal (Unselected)
//        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.darkGray
//        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.darkGray, .font: UIFont.systemFont(ofSize: 10)]
//        // Selected
//        appearance.stackedLayoutAppearance.selected.iconColor = UIColor.white
//        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.white, .font: UIFont.systemFont(ofSize: 10)]
//
//        UITabBar.appearance().standardAppearance = appearance
//        if #available(iOS 15.0, *) {
//            UITabBar.appearance().scrollEdgeAppearance = appearance
//        }
//        // --- Navigation Bar Appearance (Consistent black, for Home Screen) ---
//          let navBarAppearance = UINavigationBarAppearance()
//          navBarAppearance.configureWithOpaqueBackground()
//          navBarAppearance.backgroundColor = UIColor.black
//          navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]       // For small titles
//          navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white] // For large titles
//          UINavigationBar.appearance().standardAppearance = navBarAppearance
//          UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
//          UINavigationBar.appearance().compactAppearance = navBarAppearance // For landscape
//          UINavigationBar.appearance().tintColor = .white // For back button, etc.
//    }
//
//    var body: some View {
//            TabView(selection: $selectedSystemTab) {
//                // --- Home Tab ---
//                MediumHomeContentView()
//                    .tag(0)
//                    .tabItem { Label("Home", systemImage: "house") }
//
//                // --- Search Tab ---
//                MediumSearchContentView() // This now includes the loading state logic
//                    .tag(1)
//                    .tabItem { Label("Search", systemImage: "magnifyingglass") }
//
//                // --- Bookmarks Tab ---
//                 Text("Bookmarks Tab Content")
//                     /* ... styling ... */
//                    .tag(2)
//                    .tabItem { Label("Bookmarks", systemImage: "bookmark") }
//                    .toolbarBackground(Color.mediumBlack.opacity(0.97), for: .tabBar) // Ensure tab bar background applies
//
//                // --- Profile Tab ---
//                 NavigationView { MediumProfileContentView() }
//                     .navigationViewStyle(.stack)
//                     .tag(3)
//                     .tabItem { Label("Profile", systemImage: "person.crop.circle") }
//                     .toolbarBackground(Color.mediumBlack.opacity(0.97), for: .tabBar) // Ensure tab bar background applies
//
//            }
//             .accentColor(.white)
//             .preferredColorScheme(.dark)
//        }
//}

// MARK: - App Entry Point
//
//@main
//struct MediumCloneApp: App {
//    var body: some Scene {
//        WindowGroup {
//            MediumTabView()
//        }
//    }
//}

// MARK: - Previews

#Preview("Main Tab View (Search Selected)") {
    // Create a wrapper or modified init to select the tab for preview
    struct PreviewWrapper: View {
        @State var selectedTab = 1 // Start on Search tab
        var body: some View {
            MediumTabView(selectedSystemTab: selectedTab)
        }
    }
    return PreviewWrapper()
}

#Preview("Search Content View") {
    MediumSearchContentView()
        .preferredColorScheme(.dark)
}

#Preview("Search Bar") {
    SearchBarView(searchText: .constant("Flutter"))
        .padding()
        .background(Color.mediumBlack)
        .preferredColorScheme(.dark)
}
