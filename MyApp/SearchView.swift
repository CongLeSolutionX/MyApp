////
////  ExploreView.swift
////  MyApp
////
////  Created by Cong Le on 4/2/25.
////
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
// MARK: - Existing Custom Styles & Colors

extension Color { /* ... Keep existing ... */
    static let mediumBlack = Color.black
    static let mediumGrayText = Color(UIColor.lightGray)
    static let mediumDarkGray = Color(UIColor.darkGray)
    static let mediumLightGray = Color(UIColor.systemGray4) // Good for search bar background
    static let mediumGreen = Color.green
    static let mediumWhite = Color.white
    static let mediumBlue = Color.blue // For verified checkmark
    static let mediumYellow = Color.yellow // For member star
    static let searchBarGray = Color(UIColor.systemGray2) // Darker gray for search bar background
    static let libraryCardBackground = Color(UIColor.systemGray6).opacity(0.15) // Subtle dark background for cards
}

struct OutlineButtonStyle: ButtonStyle { /* ... Keep existing ... */
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 15, weight: .semibold))
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .foregroundColor(.mediumWhite)
            .background(
                Capsule()
                    .stroke(Color.mediumDarkGray, lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}
struct FilledButtonStyle: ButtonStyle { /* ... Keep existing ... */
    let backgroundColor: Color
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 15, weight: .semibold))
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .foregroundColor(.black)
            .background(Capsule().fill(backgroundColor))
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Existing Reusable Components (Profile & Home)

struct ProfileHeaderView: View { /* ... Keep existing ... */
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 15) {
                Image("profile_pic_large") // Replace with your large profile pic asset
                    .resizable()
                    .scaledToFill()
                    .frame(width: 70, height: 70)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.mediumDarkGray, lineWidth: 0.5)) // Subtle border

                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .firstTextBaseline, spacing: 5) { // Align name and pronoun
                        Text("Cong Le")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(.mediumWhite)
                        Text("he/him")
                            .font(.caption)
                            .foregroundColor(.mediumGrayText)
                            .padding(.top, 5) // Adjust vertical alignment if needed
                    }

                    HStack(spacing: 4) {
                         Text("199")
                             .fontWeight(.semibold)
                         Text("Followers")
                         Text("·")
                         Text("111")
                             .fontWeight(.semibold)
                         Text("Following")
                    }
                    .font(.system(size: 14))
                    .foregroundColor(.mediumGrayText)
                }
                Spacer() // Pushes content left
            }

            HStack(spacing: 10) {
                Button("View stats") {
                    print("View Stats tapped")
                }
                .buttonStyle(FilledButtonStyle(backgroundColor: .mediumLightGray))

                Button("Edit your profile") {
                    print("Edit Profile tapped")
                }
                .buttonStyle(OutlineButtonStyle())
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 10) // Add some vertical padding
    }
}
struct ProfileTabView: View { /* ... Keep existing ... */
    @Binding var selectedTab: ProfileTab
    @Namespace private var animation

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 25) {
                ForEach(ProfileTab.allCases) { tab in
                    VStack(spacing: 8) { // Add spacing for underline
                        Text(tab.rawValue)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(selectedTab == tab ? .mediumWhite : .mediumGrayText)
                            .contentShape(Rectangle()) // Makes the text area tappable
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
                                .matchedGeometryEffect(id: "underline", in: animation) // Animate underline transition
                        } else {
                            Rectangle()
                                .fill(Color.clear) // Placeholder for layout
                                .frame(height: 2)
                        }
                    }
                }
                Spacer() // Push tabs to the left
            }
            .padding(.horizontal)
            .frame(height: 44) // Standard tap height

            Divider()
                .background(Color.mediumDarkGray) // Make divider visible
        }
    }
}
struct FilterDropdownView: View { /* ... Keep existing ... */
    var body: some View {
        Button {
            print("Filter tapped")
            // Add action to show dropdown options
        } label: {
            HStack {
                Text("Public")
                Spacer()
                Image(systemName: "chevron.down")
            }
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(.mediumGrayText)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .stroke(Color.mediumDarkGray, lineWidth: 1)
            )
        }
        .padding(.horizontal)
        .padding(.top, 10) // Space from the divider
        .padding(.bottom, 15) // Space before first article
    }
}
struct ArticleCardView: View { /* ... Keep existing ... */
    let article: Article
    @State private var isBookmarked: Bool // Manage bookmark state locally

    init(article: Article) {
        self.article = article
        self._isBookmarked = State(initialValue: article.isBookmarked)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Pinned Indicator
            if article.isPinned {
                HStack(spacing: 5) {
                    Image(systemName: "pin.fill")
                        .font(.caption)
                        .rotationEffect(.degrees(45))
                    Text("Pinned")
                        .font(.caption)
                }
                .foregroundColor(.mediumGrayText)
            }

            // Author Info
            HStack(spacing: 8) {
                Image(article.authorImageName) // Use asset name
                    .resizable()
                    .scaledToFill()
                    .frame(width: 24, height: 24)
                    .clipShape(Circle())
                Text(article.authorName)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.mediumWhite)
            }

            // Main Content (Title, Subtitle, Image)
            HStack(alignment: .top, spacing: 15) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(article.title)
                         .font(.system(size: 20, weight: .bold))
                         .foregroundColor(.mediumWhite)
                         .lineLimit(3) // Allow title to wrap

                     Text(article.subtitle)
                         .font(.system(size: 15))
                         .foregroundColor(.mediumGrayText)
                         .lineLimit(2) // Limit subtitle lines
                }
                Spacer() // Pushes text left

                Image(article.thumbnailImageName) // Use asset name
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 80)
                    .clipped() // Clip image to frame
                    .cornerRadius(4) // Slight rounding
            }

            // Metadata and Actions
            HStack(spacing: 15) {
                 // Membership Star (Optional - Assuming always shown for now)
                 Image(systemName: "star.fill")
                     .foregroundColor(.yellow.opacity(0.8))
                     .font(.caption)

                 Text(article.datePublished)
                     .font(.caption)
                     .foregroundColor(.mediumGrayText)

                 HStack(spacing: 3) {
                      // Using thumbsup as approximation for clap
                      Image(systemName: "hand.thumbsup.fill")
                      Text("\(article.clapCount)")
                 }
                 .font(.caption)
                 .foregroundColor(.mediumGrayText)

                 Spacer() // Pushes metadata left

                 // Bookmark Button
                 Button {
                     isBookmarked.toggle()
                     print("Bookmark tapped: \(article.title)")
                 } label: {
                     Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                         .font(.system(size: 18))
                         .foregroundColor(isBookmarked ? .mediumWhite : .mediumGrayText)
                 }

                 // More Button
                 Button {
                     print("More options tapped: \(article.title)")
                 } label: {
                     Image(systemName: "ellipsis")
                         .font(.system(size: 18))
                         .foregroundColor(.mediumGrayText)
                 }
            }
            .padding(.top, 5) // Space above metadata/actions
        }
        .padding(.horizontal)
        .padding(.vertical, 15) // Padding around the entire card content
    }
}
struct FloatingActionButton: View { /* ... Keep existing ... */
    var action: () -> Void // Closure for button action

    var body: some View {
        Button(action: action) {
            Image(systemName: "pencil.line") // Changed icon to match screenshot better
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(Color.mediumGreen)
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 3)
        }
    }
}
struct MediumProfileContentView: View { /* ... Keep existing ... */
    @State private var selectedProfileTab: ProfileTab = .stories

    var body: some View {
         ZStack(alignment: .bottomTrailing) { // ZStack for ScrollView + FAB
            ScrollView {
                VStack(alignment: .leading, spacing: 0) { // Main vertical stack

                    // Top Settings Button (appears to be part of scrollable content)
                    HStack {
                        Spacer()
                        Button {
                            print("Settings tapped")
                        } label: {
                            Image(systemName: "gearshape")
                                .font(.system(size: 20))
                                .foregroundColor(.mediumGrayText)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 5) // Adjust to clear status bar if needed

                    // Profile Header
                    ProfileHeaderView()
                         .padding(.bottom, 15) // Space after header

                    // Content Tabs (Stories, Lists, About)
                    ProfileTabView(selectedTab: $selectedProfileTab)
                        .padding(.bottom, 5) // Space after tabs/divider

                    // Content based on selected tab
                    switch selectedProfileTab {
                    case .stories:
                         // Filter Dropdown
                         FilterDropdownView()

                         // Article List
                         ForEach(sampleArticles) { article in
                             ArticleCardView(article: article)
                             Divider().background(Color.mediumDarkGray).padding(.horizontal) // Separator
                         }
                         // Add padding at the bottom so FAB doesn't overlap last item too much
                         Spacer(minLength: 80)

                    case .lists:
                        Text("Lists Content Placeholder")
                            .foregroundColor(.mediumWhite)
                            .padding()
                            .frame(maxWidth: .infinity, maxHeight: .infinity) // Fill space
//                        Spacer() // Push placeholder up

                    case .about:
                        Text("About Content Placeholder")
                             .foregroundColor(.mediumWhite)
                             .padding()
                             .frame(maxWidth: .infinity, maxHeight: .infinity) // Fill space
//                        Spacer() // Push placeholder up
                     }
                }
            }
            // .background(Color.mediumBlack.ignoresSafeArea()) // Background for the ScrollView content area
             .ignoresSafeArea(edges: .bottom) // Allow content to scroll under FAB

            // Floating Action Button
             FloatingActionButton {
                 print("FAB Tapped!")
             }
             .padding(.trailing, 20)
             .padding(.bottom, 10) // Position above the system tab bar area

         } // End ZStack
        .background(Color.mediumBlack.ignoresSafeArea()) // Apply background to the ZStack container
        .navigationBarHidden(true) // Hide the nav bar for the profile screen as it has its own header
    }
}
struct HomeNavigationBar: View { /* ... Keep existing ... */
    var body: some View {
        HStack {
            Text("Home")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.mediumWhite)

            Spacer()

            Button {
                print("Notifications Tapped")
            } label: {
                Image(systemName: "bell")
                    .font(.title2)
                    .foregroundColor(.mediumGrayText)
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 5) // Add a little space below the nav bar
        // This content will be placed in the .navigationBarItems or .toolbar
    }
}
struct TopicScrollView: View { /* ... Keep existing ... */
    let topics: [Topic]
    @Binding var selectedTopic: Topic? // Use optional binding
    @Namespace private var animation // For underline animation

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    // Plus Button
                    Button {
                        print("Add Topic Tapped")
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.mediumGrayText)
                            .frame(width: 40, height: 40) // Ensure consistent tap area
                             .contentShape(Rectangle())
                    }

                    // Topic Tabs
                    ForEach(topics) { topic in
                        TopicTab(topic: topic, isSelected: selectedTopic == topic, animation: animation)
                             .onTapGesture {
                                 withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                     selectedTopic = topic
                                 }
                             }
                    }
                }
                .padding(.horizontal) // Padding for the HStack content
            }
            .frame(height: 44) // Define height for the scroll view

            Divider().background(Color.mediumDarkGray) // Divider below tabs
        }
    }
}
struct TopicTab: View { /* ... Keep existing ... */
    let topic: Topic
    let isSelected: Bool
    var animation: Namespace.ID // Pass namespace for animation

    var body: some View {
        VStack(spacing: 8) {
            Text(topic.name)
                .font(.system(size: 15, weight: isSelected ? .bold : .regular)) // Bold if selected
                .foregroundColor(isSelected ? .mediumWhite : .mediumGrayText)
                .fixedSize() // Prevent text from truncating horizontally too early

            // Underline
            if isSelected {
                Rectangle()
                    .fill(Color.mediumWhite)
                    .frame(height: 2)
                    .matchedGeometryEffect(id: "topicUnderline", in: animation)
            } else {
                Rectangle()
                    .fill(Color.clear)
                    .frame(height: 2)
            }
        }
        .contentShape(Rectangle()) // Make entire VStack tappable
    }
}
struct HomeArticleCardView: View { /* ... Keep existing ... */
    let article: HomeArticle

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Publication & Author Info
            HStack(spacing: 8) {
                Image(systemName: article.publicationIconName) // Use system name or asset name
                     .resizable()
                     .scaledToFit()
                      // Add specific icons/images for publications later
                     .frame(width: 20, height: 20)
                     .foregroundColor(.mediumGrayText) // Default color, adjust if needed
                     .padding(5)
                     .background(Color.mediumDarkGray.opacity(0.5))
                     .clipShape(RoundedRectangle(cornerRadius: 4))

                Text("In \(article.publicationName)")
                     .font(.system(size: 13, weight: .medium))
                     .foregroundColor(.mediumWhite)
                 Text("by \(article.authorName)")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.mediumGrayText) // Subtler author name

                 // Verified Badge
                 if article.isAuthorVerified {
                     Image(systemName: "checkmark.seal.fill")
                         .font(.caption)
                         .foregroundColor(.mediumBlue)
                 }
                 Spacer()
            }

            // Main Content (Title, Subtitle, Image)
            HStack(alignment: .top, spacing: 15) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(article.title)
                         .font(.system(size: 20, weight: .bold))
                         .foregroundColor(.mediumWhite)
                         .lineLimit(3)

                     Text(article.subtitle)
                         .font(.system(size: 15))
                         .foregroundColor(.mediumGrayText)
                         .lineLimit(2)
                }
                Spacer() // Pushes text column left

                Image(article.thumbnailImageName) // Use asset name
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 80)
                    .clipped()
                    .cornerRadius(4)
            }

            // Metadata and Actions
            HStack(spacing: 15) {
                 // Membership Star
                 if article.isMemberOnly {
                     Image(systemName: "star.fill")
                         .foregroundColor(Color.mediumYellow.opacity(0.8))
                         .font(.caption)
                 }

                 Text(article.datePublished)
                     .font(.caption)
                     .foregroundColor(.mediumGrayText)

                 // Claps
                 HStack(spacing: 3) {
                      Image(systemName: "hand.thumbsup") // Outline version maybe? Or fill
                      Text("\(article.clapCount)")
                 }
                 .font(.caption)
                 .foregroundColor(.mediumGrayText)

                // Comments
                if article.commentCount > 0 {
                    HStack(spacing: 3) {
                        Image(systemName: "message") // Chat bubble
                        Text("\(article.commentCount)")
                    }
                    .font(.caption)
                    .foregroundColor(.mediumGrayText)
                }

                 Spacer() // Pushes metadata left

                 // Hide/Less Button
                 Button {
                     print("Hide/Less tapped: \(article.title)")
                 } label: {
                     Image(systemName: "minus.circle") // Hide icon
                         .font(.system(size: 18))
                         .foregroundColor(.mediumGrayText)
                 }

                 // More Button
                 Button {
                     print("More options tapped: \(article.title)")
                 } label: {
                     Image(systemName: "ellipsis")
                         .font(.system(size: 18))
                         .foregroundColor(.mediumGrayText)
                 }
            }
            .padding(.top, 5)
        }
        .padding(.horizontal)
        .padding(.vertical, 15)
    }
}
struct MediumHomeContentView: View { /* ... Keep existing ... */
    @State private var selectedTopic: Topic? = sampleTopics.first // Default selection

    var body: some View {
        NavigationView { // Use NavigationView for easy title & toolbar items
            ZStack(alignment: .bottomTrailing) {
                // Main scrollable content
                ScrollView {
                     LazyVStack(alignment: .leading, spacing: 0, pinnedViews: [.sectionHeaders]) {

                        // Pinned Topic Scroll View Header
                        Section {
                             // Article List
                             ForEach(sampleHomeArticles) { article in
                                 HomeArticleCardView(article: article)
                                 Divider().background(Color.mediumDarkGray.opacity(0.8)).padding(.horizontal)
                             }
                            // Add spacer for FAB clearance if FAB is desired on this screen too
                            Spacer(minLength: 80) // Add Spacer to push content up if list is short
                        } header: {
                            // Sticky Topic Header
                             TopicScrollView(topics: sampleTopics, selectedTopic: $selectedTopic)
                                 .background(Material.bar) // Use Material for background when sticky
                        }
                     } // End LazyVStack
                 } // End ScrollView
                 .background(Color.mediumBlack.ignoresSafeArea())
                 .navigationBarTitleDisplayMode(.inline) // Keep title small
                 .toolbar {
                      // Use .principal for custom title view content
                      ToolbarItem(placement: .principal) {
                          HomeNavigationBar() // Our custom HStack for title/bell
                      }
                 }
                .ignoresSafeArea(edges: .bottom) // Allow content under FAB

                // --- Floating Action Button (Optional - uncomment if needed on Home) ---
                 /*
                 FloatingActionButton {
                     print("FAB Tapped on Home!")
                 }
                 .padding(.trailing, 20)
                 .padding(.bottom, 10) // Position above the system tab bar area
                 */

            } // End ZStack
            .background(Color.mediumBlack.ignoresSafeArea()) // Background for the entire NavigationView content area
        } // End NavigationView
         .navigationViewStyle(.stack) // Use stack style for standard navigation
    }
}

// MARK: --- NEW Search Screen Components ---

// --- Search Bar ---
struct SearchBarView: View {
    @Binding var searchText: String

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.mediumGrayText)

            TextField("Search Medium", text: $searchText)
                .foregroundColor(.mediumWhite)
                .tint(.mediumWhite) // Sets cursor color

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.mediumGrayText)
                }
                .padding(.trailing, 5)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color.searchBarGray)
        .cornerRadius(8)
    }
}

// --- Search Topic Scroll View (Simpler Chip Style) ---
struct SearchTopicScrollView: View {
    let topics: [SearchTopic]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(topics) { topic in
                    SearchTopicChip(topic: topic)
                }
            }
            .padding(.horizontal) // Padding for the HStack content
        }
        .frame(height: 44) // Define height for the scroll view
    }
}

// --- Individual Search Topic Chip ---
struct SearchTopicChip: View {
    let topic: SearchTopic

    var body: some View {
        Button {
            print("Search Topic tapped: \(topic.name)")
            // Add action, e.g., perform search with this topic
        } label: {
             Text(topic.name)
                 .font(.system(size: 14, weight: .medium))
                 .foregroundColor(.mediumWhite) // Text color
                 .padding(.horizontal, 16)
                 .padding(.vertical, 8)
                 .background(Color.mediumDarkGray) // Chip background
                 .clipShape(Capsule()) // Rounded ends
        }
    }
}

// --- Trending Article Row View ---
struct TrendingArticleRowView: View {
    let article: TrendingArticle

    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            // Rank Number
            Text(String(format: "%02d", article.rank)) // Format with leading zero if desired, or just "\(article.rank)"
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.mediumDarkGray) // Muted rank color
                .frame(width: 30, alignment: .leading) // Fixed width for alignment

            // Article Info
            VStack(alignment: .leading, spacing: 6) {
                 // Author/Publication Info Row
                 HStack(spacing: 8) {
                     // Decide which icon to show (priority to publication if both exist?)
                     if let pubIcon = article.publicationIconName {
                         Image(pubIcon) // Use Asset Name
                            .resizable()
                            .scaledToFill()
                            .frame(width: 20, height: 20)
                            // Apply appropriate clipping (square, circle?)
                            .clipShape(RoundedRectangle(cornerRadius: 3))

                        Text("In \(article.publicationName ?? "")")
                             .font(.system(size: 13, weight: .medium))
                             .foregroundColor(.mediumWhite)
                              + Text(" by \(article.primaryAuthorNameForDisplay)") // Combine text
                             .font(.system(size: 13, weight: .medium))
                             .foregroundColor(.mediumGrayText)

                     } else if let authorIcon = article.authorImageName {
                         Image(authorIcon) // Use Asset Name
                            .resizable()
                            .scaledToFill()
                            .frame(width: 20, height: 20)
                             .clipShape(Circle())
                          Text(article.primaryAuthorNameForDisplay) // Just show author name
                             .font(.system(size: 13, weight: .medium))
                             .foregroundColor(.mediumWhite)
                     } else {
                          // Fallback if no icon/name provided
                           Text(article.primaryAuthorNameForDisplay)
                             .font(.system(size: 13, weight: .medium))
                             .foregroundColor(.mediumWhite)
                     }
                      Spacer() // Push info left
                 }
                 .lineLimit(1) // Prevent wrapping

                 // Title
                 Text(article.title)
                     .font(.system(size: 17, weight: .bold))
                     .foregroundColor(.mediumWhite)
                     .lineLimit(3) // Allow title wrapping

                 // Date
                 Text(article.datePublished)
                     .font(.caption)
                     .foregroundColor(.mediumGrayText)
                     .padding(.top, 2)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 12) // Padding for the row
    }
}

// MARK: - Main Search Screen Content View

struct MediumSearchContentView: View {
    @State private var searchText: String = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                // Explore Title
                Text("Explore")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(.mediumWhite)
                    .padding(.horizontal)
                    .padding(.top) // Add padding from the top safe area

                // Search Bar
                SearchBarView(searchText: $searchText)
                    .padding(.horizontal)

                // Search Topics
                SearchTopicScrollView(topics: sampleSearchTopics)
                     // No horizontal padding needed here as SearchTopicScrollView handles it

                // Trending Section Title
                Text("Trending on Medium")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.mediumWhite)
                    .padding(.horizontal)
                    .padding(.top, 10) // Space above trending title

                // Trending Articles List
                LazyVStack(spacing: 0) { // Use LazyVStack if list can be long
                    ForEach(sampleTrendingArticles) { article in
                        TrendingArticleRowView(article: article)
                        Divider().background(Color.mediumDarkGray.opacity(0.5)).padding(.leading, 65) // Indent divider
                    }
                }
                Spacer(minLength: 80) // Spacer for TAB bar clearance
            }
        }
         .background(Color.mediumBlack.ignoresSafeArea())
         .navigationBarHidden(true) // Hide the default navigation bar
         .ignoresSafeArea(edges: .bottom) // Allow content to scroll under tab bar
    }
}

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
//        TabView(selection: $selectedSystemTab) {
//            // --- Home Tab ---
//            MediumHomeContentView()
//                .tag(0)
//                .tabItem {
//                    Label("Home", systemImage: "house")
//                }
//
//            // --- Search Tab ---
//            MediumSearchContentView() // Use the new Search Screen View
//                .tag(1)
//                .tabItem {
//                    Label("Search", systemImage: "magnifyingglass")
//                }
//
//            // --- Bookmarks Tab (Placeholder) ---
//             Text("Bookmarks Tab Content")
//                 .frame(maxWidth: .infinity, maxHeight: .infinity)
//                 .background(Color.mediumBlack.ignoresSafeArea())
//                 .foregroundColor(.white)
//                .tag(2)
//                .tabItem {
//                    Label("Bookmarks", systemImage: "bookmark")
//                }
//
//            // --- Profile Tab ---
//             // Wrap Profile in NavigationView to potentially handle settings navigation later
//             NavigationView {
//                 MediumProfileContentView()
//             }
//             .navigationViewStyle(.stack) // IMPORTANT: Apply here for Profile
//             .tag(3)
//             .tabItem {
//                  Label("Profile", systemImage: "person.crop.circle")
//              }
//        }
//         .accentColor(.white) // Sets the tint color for selected tab items
//         .preferredColorScheme(.dark) // Enforce dark mode
//    }
//}
//
//// MARK: - App Entry Point
////
////@main
////struct MediumCloneApp: App {
////    var body: some Scene {
////        WindowGroup {
////            MediumTabView()
////        }
////    }
////}
//
//// MARK: - Previews
//
//#Preview("Main Tab View (Search Selected)") {
//    // Create a wrapper or modified init to select the tab for preview
//    struct PreviewWrapper: View {
//        @State var selectedTab = 1 // Start on Search tab
//        var body: some View {
//            MediumTabView(selectedSystemTab: selectedTab)
//        }
//    }
//    return PreviewWrapper()
//}
//
//#Preview("Search Content View") {
//    MediumSearchContentView()
//        .preferredColorScheme(.dark)
//}
//
//#Preview("Search Bar") {
//    SearchBarView(searchText: .constant("Flutter"))
//        .padding()
//        .background(Color.mediumBlack)
//        .preferredColorScheme(.dark)
//}
//
//#Preview("Search Topic Scroll View") {
//    SearchTopicScrollView(topics: sampleSearchTopics)
//        .background(Color.mediumBlack)
//        .preferredColorScheme(.dark)
//}
//
//#Preview("Trending Article Row") {
//    TrendingArticleRowView(article: sampleTrendingArticles[3]) // Netflix example
//        .background(Color.mediumBlack)
//        .preferredColorScheme(.dark)
//}
//
//// Add a custom init to TabView preview helper if needed
//extension MediumTabView {
//    init(selectedSystemTab: Int) {
//       self.init() // Call the original init first
//       self._selectedSystemTab = State(initialValue: selectedSystemTab)
//    }
//}
