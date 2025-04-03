////
////  HomeView.swift
////  MyApp
////
////  Created by Cong Le on 4/2/25.
////
//
//import SwiftUI
//
//// MARK: - Existing Data Models (From Profile Screen Implementation)
//
//struct Article: Identifiable { // Kept for Profile Screen - Might rename later if needed
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
//enum ProfileTab: String, CaseIterable, Identifiable {
//    case stories = "Stories"
//    case lists = "Lists"
//    case about = "About"
//    var id: String { self.rawValue }
//}
//
//// MARK: --- NEW Data Models for Home Screen ---
//
//struct HomeArticle: Identifiable {
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
//    // Add other relevant fields like read time, tags etc. if needed
//}
//
//struct Topic: Identifiable, Hashable { // Hashable for ForEach selection
//    let id = UUID()
//    let name: String
//}
//
//// MARK: - Sample Data (Existing and New)
//
//let sampleArticles: [Article] = [ // From profile screen
//    Article(isPinned: true,
//            authorName: "Cong Le",
//            authorImageName: "profile_pic_cong",
//            title: "Don't Get Left Behind: iOS Development Trends Shaping 2025",
//            subtitle: "The essential skills and tech you NEED to master to stay relevant, competitiv...",
//            thumbnailImageName: "article_thumb_1",
//            datePublished: "Jan 1",
//            clapCount: 94,
//            isBookmarked: false),
//    Article(isPinned: true,
//            authorName: "Cong Le",
//            authorImageName: "profile_pic_cong",
//            title: "Conquer Navigation Chaos in SwiftUI with the Coordinator Pattern",
//            subtitle: "Discover how the Coordinator pattern can tame complex navigation flows...",
//            thumbnailImageName: "article_thumb_2",
//            datePublished: "Dec 15",
//            clapCount: 120,
//            isBookmarked: true)
//]
//
//// --- NEW Sample Data for Home ---
//let sampleHomeArticles: [HomeArticle] = [
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
//let sampleTopics: [Topic] = [
//    Topic(name: "For you"),
//    Topic(name: "Following"),
//    Topic(name: "Featured"),
//    Topic(name: "Large Language Models"),
//    Topic(name: "iOS Development"),
//    Topic(name: "Programming"),
//    Topic(name: "Technology")
//]
//
//// MARK: - Existing Custom Styles & Colors
//
//extension Color {
//    static let mediumBlack = Color.black
//    static let mediumGrayText = Color(UIColor.lightGray)
//    static let mediumDarkGray = Color(UIColor.darkGray)
//    static let mediumLightGray = Color(UIColor.systemGray4)
//    static let mediumGreen = Color.green
//    static let mediumWhite = Color.white
//    static let mediumBlue = Color.blue // For verified checkmark
//    static let mediumYellow = Color.yellow // For member star
//}
//
//struct OutlineButtonStyle: ButtonStyle { // From profile screen
//    func makeBody(configuration: Configuration) -> some View {
//        configuration.label
//            .font(.system(size: 15, weight: .semibold))
//            .padding(.horizontal, 16)
//            .padding(.vertical, 10)
//            .foregroundColor(.mediumWhite)
//            .background(
//                Capsule()
//                    .stroke(Color.mediumDarkGray, lineWidth: 1)
//            )
//            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
//            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
//    }
//}
//
//struct FilledButtonStyle: ButtonStyle { // From profile screen
//    let backgroundColor: Color
//    func makeBody(configuration: Configuration) -> some View {
//        configuration.label
//            .font(.system(size: 15, weight: .semibold))
//            .padding(.horizontal, 16)
//            .padding(.vertical, 10)
//            .foregroundColor(.black)
//            .background(Capsule().fill(backgroundColor))
//            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
//            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
//    }
//}
//
//// MARK: - Existing Reusable Components (Profile)
//
//struct ProfileHeaderView: View { /* ... Copy from previous response ... */
//    var body: some View {
//        VStack(alignment: .leading, spacing: 12) {
//            HStack(spacing: 15) {
//                Image("profile_pic_large") // Replace with your large profile pic asset
//                    .resizable()
//                    .scaledToFill()
//                    .frame(width: 70, height: 70)
//                    .clipShape(Circle())
//                    .overlay(Circle().stroke(Color.mediumDarkGray, lineWidth: 0.5)) // Subtle border
//
//                VStack(alignment: .leading, spacing: 4) {
//                    HStack(alignment: .firstTextBaseline, spacing: 5) { // Align name and pronoun
//                        Text("Cong Le")
//                            .font(.system(size: 26, weight: .bold))
//                            .foregroundColor(.mediumWhite)
//                        Text("he/him")
//                            .font(.caption)
//                            .foregroundColor(.mediumGrayText)
//                            .padding(.top, 5) // Adjust vertical alignment if needed
//                    }
//
//                    HStack(spacing: 4) {
//                         Text("199")
//                             .fontWeight(.semibold)
//                         Text("Followers")
//                         Text("·")
//                         Text("111")
//                             .fontWeight(.semibold)
//                         Text("Following")
//                    }
//                    .font(.system(size: 14))
//                    .foregroundColor(.mediumGrayText)
//                }
//                Spacer() // Pushes content left
//            }
//
//            HStack(spacing: 10) {
//                Button("View stats") {
//                    print("View Stats tapped")
//                }
//                .buttonStyle(FilledButtonStyle(backgroundColor: .mediumLightGray))
//
//                Button("Edit your profile") {
//                    print("Edit Profile tapped")
//                }
//                .buttonStyle(OutlineButtonStyle())
//            }
//        }
//        .padding(.horizontal)
//        .padding(.vertical, 10) // Add some vertical padding
//    }
// }
//struct ProfileTabView: View { /* ... Copy from previous response ... */
//    @Binding var selectedTab: ProfileTab
//    @Namespace private var animation
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 0) {
//            HStack(spacing: 25) {
//                ForEach(ProfileTab.allCases) { tab in
//                    VStack(spacing: 8) { // Add spacing for underline
//                        Text(tab.rawValue)
//                            .font(.system(size: 15, weight: .semibold))
//                            .foregroundColor(selectedTab == tab ? .mediumWhite : .mediumGrayText)
//                            .contentShape(Rectangle()) // Makes the text area tappable
//                            .onTapGesture {
//                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
//                                    selectedTab = tab
//                                }
//                            }
//
//                        // Underline
//                        if selectedTab == tab {
//                            Rectangle()
//                                .fill(Color.mediumWhite)
//                                .frame(height: 2)
//                                .matchedGeometryEffect(id: "underline", in: animation) // Animate underline transition
//                        } else {
//                            Rectangle()
//                                .fill(Color.clear) // Placeholder for layout
//                                .frame(height: 2)
//                        }
//                    }
//                }
//                Spacer() // Push tabs to the left
//            }
//            .padding(.horizontal)
//            .frame(height: 44) // Standard tap height
//
//            Divider()
//                .background(Color.mediumDarkGray) // Make divider visible
//        }
//    }
//}
//struct FilterDropdownView: View { /* ... Copy from previous response ... */
//    var body: some View {
//        Button {
//            print("Filter tapped")
//            // Add action to show dropdown options
//        } label: {
//            HStack {
//                Text("Public")
//                Spacer()
//                Image(systemName: "chevron.down")
//            }
//            .font(.system(size: 14, weight: .medium))
//            .foregroundColor(.mediumGrayText)
//            .padding(.horizontal, 12)
//            .padding(.vertical, 8)
//            .background(
//                Capsule()
//                    .stroke(Color.mediumDarkGray, lineWidth: 1)
//            )
//        }
//        .padding(.horizontal)
//        .padding(.top, 10) // Space from the divider
//        .padding(.bottom, 15) // Space before first article
//    }
//}
//struct ArticleCardView: View { /* ... Copy from previous response ... */
//    let article: Article
//    @State private var isBookmarked: Bool // Manage bookmark state locally
//
//    init(article: Article) {
//        self.article = article
//        self._isBookmarked = State(initialValue: article.isBookmarked)
//    }
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 10) {
//            // Pinned Indicator
//            if article.isPinned {
//                HStack(spacing: 5) {
//                    Image(systemName: "pin.fill")
//                        .font(.caption)
//                        .rotationEffect(.degrees(45))
//                    Text("Pinned")
//                        .font(.caption)
//                }
//                .foregroundColor(.mediumGrayText)
//            }
//
//            // Author Info
//            HStack(spacing: 8) {
//                Image(article.authorImageName)
//                    .resizable()
//                    .scaledToFill()
//                    .frame(width: 24, height: 24)
//                    .clipShape(Circle())
//                Text(article.authorName)
//                    .font(.system(size: 14, weight: .medium))
//                    .foregroundColor(.mediumWhite)
//            }
//
//            // Main Content (Title, Subtitle, Image)
//            HStack(alignment: .top, spacing: 15) {
//                VStack(alignment: .leading, spacing: 6) {
//                    Text(article.title)
//                         .font(.system(size: 20, weight: .bold))
//                         .foregroundColor(.mediumWhite)
//                         .lineLimit(3) // Allow title to wrap
//
//                     Text(article.subtitle)
//                         .font(.system(size: 15))
//                         .foregroundColor(.mediumGrayText)
//                         .lineLimit(2) // Limit subtitle lines
//                }
//                Spacer() // Pushes text left
//
//                Image(article.thumbnailImageName)
//                    .resizable()
//                    .scaledToFill()
//                    .frame(width: 80, height: 80)
//                    .clipped() // Clip image to frame
//                    .cornerRadius(4) // Slight rounding
//            }
//
//            // Metadata and Actions
//            HStack(spacing: 15) {
//                 // Membership Star (Optional - Assuming always shown for now)
//                 Image(systemName: "star.fill")
//                     .foregroundColor(.yellow.opacity(0.8))
//                     .font(.caption)
//
//                 Text(article.datePublished)
//                     .font(.caption)
//                     .foregroundColor(.mediumGrayText)
//
//                 HStack(spacing: 3) {
//                      // Using thumbsup as approximation for clap
//                      Image(systemName: "hand.thumbsup.fill")
//                      Text("\(article.clapCount)")
//                 }
//                 .font(.caption)
//                 .foregroundColor(.mediumGrayText)
//
//                 Spacer() // Pushes metadata left
//
//                 // Bookmark Button
//                 Button {
//                     isBookmarked.toggle()
//                     print("Bookmark tapped: \(article.title)")
//                 } label: {
//                     Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
//                         .font(.system(size: 18))
//                         .foregroundColor(isBookmarked ? .mediumWhite : .mediumGrayText)
//                 }
//
//                 // More Button
//                 Button {
//                     print("More options tapped: \(article.title)")
//                 } label: {
//                     Image(systemName: "ellipsis")
//                         .font(.system(size: 18))
//                         .foregroundColor(.mediumGrayText)
//                 }
//            }
//            .padding(.top, 5) // Space above metadata/actions
//        }
//        .padding(.horizontal)
//        .padding(.vertical, 15) // Padding around the entire card content
//    }
//}
//struct FloatingActionButton: View { /* ... Copy from previous response ... */
//    var action: () -> Void // Closure for button action
//
//    var body: some View {
//        Button(action: action) {
//            Image(systemName: "pencil.line") // Changed icon to match screenshot better
//                .font(.system(size: 24, weight: .semibold))
//                .foregroundColor(.white)
//                .frame(width: 56, height: 56)
//                .background(Color.mediumGreen)
//                .clipShape(Circle())
//                .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 3)
//        }
//    }
//}
//struct MediumProfileContentView: View { /* ... Copy from previous response ... */
//    @State private var selectedProfileTab: ProfileTab = .stories
//
//    var body: some View {
//         ZStack(alignment: .bottomTrailing) { // ZStack for ScrollView + FAB
//            ScrollView {
//                VStack(alignment: .leading, spacing: 0) { // Main vertical stack
//
//                    // Top Settings Button (appears to be part of scrollable content)
//                    HStack {
//                        Spacer()
//                        Button {
//                            print("Settings tapped")
//                        } label: {
//                            Image(systemName: "gearshape")
//                                .font(.system(size: 20))
//                                .foregroundColor(.mediumGrayText)
//                        }
//                    }
//                    .padding(.horizontal)
//                    .padding(.top, 5) // Adjust to clear status bar if needed
//
//                    // Profile Header
//                    ProfileHeaderView()
//                         .padding(.bottom, 15) // Space after header
//
//                    // Content Tabs (Stories, Lists, About)
//                    ProfileTabView(selectedTab: $selectedProfileTab)
//                        .padding(.bottom, 5) // Space after tabs/divider
//
//                    // Content based on selected tab
//                    switch selectedProfileTab {
//                    case .stories:
//                         // Filter Dropdown
//                         FilterDropdownView()
//
//                         // Article List
//                         ForEach(sampleArticles) { article in
//                             ArticleCardView(article: article)
//                             Divider().background(Color.mediumDarkGray).padding(.horizontal) // Separator
//                         }
//                         // Add padding at the bottom so FAB doesn't overlap last item too much
//                         Spacer(minLength: 80)
//
//                    case .lists:
//                        Text("Lists Content Placeholder")
//                            .foregroundColor(.mediumWhite)
//                            .padding()
//                        Spacer() // Push placeholder up
//
//                    case .about:
//                        Text("About Content Placeholder")
//                             .foregroundColor(.mediumWhite)
//                             .padding()
//                        Spacer() // Push placeholder up
//                     }
//                }
//            }
//            // .background(Color.mediumBlack.ignoresSafeArea()) // Background for the ScrollView content area
//             .ignoresSafeArea(edges: .bottom) // Allow content to scroll under FAB
//
//            // Floating Action Button
//             FloatingActionButton {
//                 print("FAB Tapped!")
//             }
//             .padding(.trailing, 20)
//             .padding(.bottom, 10) // Position above the system tab bar area
//
//         } // End ZStack
//        .background(Color.mediumBlack.ignoresSafeArea()) // Apply background to the ZStack container
//    }
//}
//
//// MARK: --- NEW Home Screen Components ---
//
//// --- Home Navigation Bar Content ---
//struct HomeNavigationBar: View {
//    var body: some View {
//        HStack {
//            Text("Home")
//                .font(.largeTitle)
//                .fontWeight(.bold)
//                .foregroundColor(.mediumWhite)
//
//            Spacer()
//
//            Button {
//                print("Notifications Tapped")
//            } label: {
//                Image(systemName: "bell")
//                    .font(.title2)
//                    .foregroundColor(.mediumGrayText)
//            }
//        }
//        .padding(.horizontal)
//        .padding(.bottom, 5) // Add a little space below the nav bar
//        // This content will be placed in the .navigationBarItems or .toolbar
//    }
//}
//
//// --- Topic Scroll View ---
//struct TopicScrollView: View {
//    let topics: [Topic]
//    @Binding var selectedTopic: Topic? // Use optional binding
//    @Namespace private var animation // For underline animation
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 0) {
//            ScrollView(.horizontal, showsIndicators: false) {
//                HStack(spacing: 20) {
//                    // Plus Button
//                    Button {
//                        print("Add Topic Tapped")
//                    } label: {
//                        Image(systemName: "plus")
//                            .font(.system(size: 16, weight: .semibold))
//                            .foregroundColor(.mediumGrayText)
//                            .frame(width: 40, height: 40) // Ensure consistent tap area
//                             .contentShape(Rectangle())
//                    }
//
//                    // Topic Tabs
//                    ForEach(topics) { topic in
//                        TopicTab(topic: topic, isSelected: selectedTopic == topic, animation: animation)
//                             .onTapGesture {
//                                 withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
//                                     selectedTopic = topic
//                                 }
//                             }
//                    }
//                }
//                .padding(.horizontal) // Padding for the HStack content
//            }
//            .frame(height: 44) // Define height for the scroll view
//
//            Divider().background(Color.mediumDarkGray) // Divider below tabs
//        }
//    }
//}
//
//// --- Individual Topic Tab ---
//struct TopicTab: View {
//    let topic: Topic
//    let isSelected: Bool
//    var animation: Namespace.ID // Pass namespace for animation
//
//    var body: some View {
//        VStack(spacing: 8) {
//            Text(topic.name)
//                .font(.system(size: 15, weight: isSelected ? .bold : .regular)) // Bold if selected
//                .foregroundColor(isSelected ? .mediumWhite : .mediumGrayText)
//                .fixedSize() // Prevent text from truncating horizontally too early
//
//            // Underline
//            if isSelected {
//                Rectangle()
//                    .fill(Color.mediumWhite)
//                    .frame(height: 2)
//                    .matchedGeometryEffect(id: "topicUnderline", in: animation)
//            } else {
//                Rectangle()
//                    .fill(Color.clear)
//                    .frame(height: 2)
//            }
//        }
//        .contentShape(Rectangle()) // Make entire VStack tappable
//    }
//}
//
//// --- Article Card for Home Feed ---
//struct HomeArticleCardView: View {
//    let article: HomeArticle
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 10) {
//            // Publication & Author Info
//            HStack(spacing: 8) {
//                Image(systemName: article.publicationIconName) // Use system name or asset name
//                     .resizable()
//                     .scaledToFit()
//                     .frame(width: 20, height: 20)
//                     .foregroundColor(.mediumGrayText) // Default color, adjust if needed
//                     .padding(5)
//                     .background(Color.mediumDarkGray.opacity(0.5))
//                     .clipShape(RoundedRectangle(cornerRadius: 4))
//
//                Text("In \(article.publicationName)")
//                     .font(.system(size: 13, weight: .medium))
//                     .foregroundColor(.mediumWhite)
//                 Text("by \(article.authorName)")
//                    .font(.system(size: 13, weight: .medium))
//                    .foregroundColor(.mediumGrayText) // Subtler author name
//
//                 // Verified Badge
//                 if article.isAuthorVerified {
//                     Image(systemName: "checkmark.seal.fill")
//                         .font(.caption)
//                         .foregroundColor(.mediumBlue)
//                 }
//                 Spacer()
//            }
//
//            // Main Content (Title, Subtitle, Image)
//            HStack(alignment: .top, spacing: 15) {
//                VStack(alignment: .leading, spacing: 6) {
//                    Text(article.title)
//                         .font(.system(size: 20, weight: .bold))
//                         .foregroundColor(.mediumWhite)
//                         .lineLimit(3)
//
//                     Text(article.subtitle)
//                         .font(.system(size: 15))
//                         .foregroundColor(.mediumGrayText)
//                         .lineLimit(2)
//                }
//                Spacer() // Pushes text column left
//
//                Image(article.thumbnailImageName) // Use asset name
//                    .resizable()
//                    .scaledToFill()
//                    .frame(width: 80, height: 80)
//                    .clipped()
//                    .cornerRadius(4)
//            }
//
//            // Metadata and Actions
//            HStack(spacing: 15) {
//                 // Membership Star
//                 if article.isMemberOnly {
//                     Image(systemName: "star.fill")
//                         .foregroundColor(Color.mediumYellow.opacity(0.8))
//                         .font(.caption)
//                 }
//
//                 Text(article.datePublished)
//                     .font(.caption)
//                     .foregroundColor(.mediumGrayText)
//
//                 // Claps
//                 HStack(spacing: 3) {
//                      Image(systemName: "hand.thumbsup") // Outline version maybe? Or fill
//                      Text("\(article.clapCount)")
//                 }
//                 .font(.caption)
//                 .foregroundColor(.mediumGrayText)
//
//                // Comments
//                if article.commentCount > 0 {
//                    HStack(spacing: 3) {
//                        Image(systemName: "message") // Chat bubble
//                        Text("\(article.commentCount)")
//                    }
//                    .font(.caption)
//                    .foregroundColor(.mediumGrayText)
//                }
//
//                 Spacer() // Pushes metadata left
//
//                 // Hide/Less Button
//                 Button {
//                     print("Hide/Less tapped: \(article.title)")
//                 } label: {
//                     Image(systemName: "minus.circle") // Hide icon
//                         .font(.system(size: 18))
//                         .foregroundColor(.mediumGrayText)
//                 }
//
//                 // More Button
//                 Button {
//                     print("More options tapped: \(article.title)")
//                 } label: {
//                     Image(systemName: "ellipsis")
//                         .font(.system(size: 18))
//                         .foregroundColor(.mediumGrayText)
//                 }
//            }
//            .padding(.top, 5)
//        }
//        .padding(.horizontal)
//        .padding(.vertical, 15)
//    }
//}
//
//// MARK: - Main Home Screen Content View
//
//struct MediumHomeContentView: View {
//    @State private var selectedTopic: Topic? = sampleTopics.first // Default selection
//
//    var body: some View {
//        NavigationView { // Use NavigationView for easy title & toolbar items
//            ZStack(alignment: .bottomTrailing) {
//                // Main scrollable content
//                ScrollView {
//                     LazyVStack(alignment: .leading, spacing: 0, pinnedViews: [.sectionHeaders]) {
//
//                        // Pinned Topic Scroll View Header
//                        Section {
//                             // Article List
//                             ForEach(sampleHomeArticles) { article in
//                                 HomeArticleCardView(article: article)
//                                 Divider().background(Color.mediumDarkGray.opacity(0.8)).padding(.horizontal)
//                             }
//                            // Add spacer for FAB clearance if FAB is desired on this screen too
//                             Spacer(minLength: 80)
//                        } header: {
//                            // Sticky Topic Header
//                             TopicScrollView(topics: sampleTopics, selectedTopic: $selectedTopic)
//                                 .background(Color.mediumBlack) // Ensure background for sticky header
//                        }
//                     } // End LazyVStack
//                 } // End ScrollView
//                 .background(Color.mediumBlack.ignoresSafeArea())
//                 .navigationBarTitleDisplayMode(.inline) // Keep title small
//                 .toolbar {
//                      // Use .principal for custom title view content
//                      ToolbarItem(placement: .principal) {
//                          HomeNavigationBar() // Our custom HStack for title/bell
//                      }
//                 }
//                .ignoresSafeArea(edges: .bottom) // Allow content under FAB
//
//                // --- Floating Action Button (Optional - uncomment if needed on Home) ---
//                 /*
//                 FloatingActionButton {
//                     print("FAB Tapped on Home!")
//                 }
//                 .padding(.trailing, 20)
//                 .padding(.bottom, 10) // Position above the system tab bar area
//                 */
//
//            } // End ZStack
//            .background(Color.mediumBlack.ignoresSafeArea()) // Background for the entire NavigationView content area
//        } // End NavigationView
//         .navigationViewStyle(.stack) // Use stack style for standard navigation
//    }
//}
//
//// MARK: - Main Tab View (Updated)
//
//struct MediumTabView: View {
//     // Keep state and init from previous response
//    @State private var selectedSystemTab = 0 // START ON HOME TAB
//
//    init() {
//        let appearance = UITabBarAppearance()
//        appearance.configureWithOpaqueBackground()
//        appearance.backgroundColor = UIColor(Color.mediumBlack.opacity(0.95)) // Slightly more opaque
//
//        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.darkGray
//        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.darkGray, .font: UIFont.systemFont(ofSize: 10)]
//        appearance.stackedLayoutAppearance.selected.iconColor = UIColor.white
//        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.white, .font: UIFont.systemFont(ofSize: 10)]
//
//        UITabBar.appearance().standardAppearance = appearance
//        if #available(iOS 15.0, *) {
//            UITabBar.appearance().scrollEdgeAppearance = appearance
//        }
//         // Appearance for Navigation Bar (consistent black)
//          let navBarAppearance = UINavigationBarAppearance()
//          navBarAppearance.configureWithOpaqueBackground()
//          navBarAppearance.backgroundColor = UIColor.black
//          navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
//          navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
//          UINavigationBar.appearance().standardAppearance = navBarAppearance
//          UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
//          UINavigationBar.appearance().compactAppearance = navBarAppearance // For landscape
//    }
//
//    var body: some View {
//        TabView(selection: $selectedSystemTab) {
//            // --- Home Tab ---
//            MediumHomeContentView() // Use the new Home Screen View
//                .tag(0)
//                .tabItem {
//                    Label("Home", systemImage: "house")
//                }
//                // Toolbar background handled by UINavigationBar appearance
//
//            // --- Search Tab (Placeholder) ---
//            Text("Search Tab Content")
//                 .frame(maxWidth: .infinity, maxHeight: .infinity)
//                 .background(Color.mediumBlack.ignoresSafeArea())
//                 .foregroundColor(.white)
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
//             MediumProfileContentView() // Existing Profile Screen View
//                .tag(3)
//                .tabItem {
//                    Label("Profile", systemImage: "person.crop.circle")
//                 }
//        }
//         .accentColor(.white) // Sets the tint color for selected tab items
//         .preferredColorScheme(.dark) // Enforce dark mode
//    }
//}
//
//// MARK: - App Entry Point
////
////@main
////struct MediumCloneApp: App { // Renamed for clarity
////    var body: some Scene {
////        WindowGroup {
////            MediumTabView()
////                // No need to set preferredColorScheme here if set on TabView
////        }
////    }
////}
//
//// MARK: - Previews
//
//#Preview("Main Tab View (Home Selected)") {
//    MediumTabView()
//}
//
//#Preview("Home Content View") {
//    MediumHomeContentView()
//        .preferredColorScheme(.dark)
//}
//
//#Preview("Home Article Card") {
//    HomeArticleCardView(article: sampleHomeArticles[1]) // Article with verified check
//        .padding()
//        .background(Color.mediumBlack)
//        .preferredColorScheme(.dark)
//}
//
//#Preview("Topic Scroll View") {
//    // Need a state variable for preview
//    struct PreviewWrapper: View {
//        @State var topic: Topic? = sampleTopics[0]
//        var body: some View { TopicScrollView(topics: sampleTopics, selectedTopic: $topic) }
//    }
//    return PreviewWrapper()
//        .background(Color.mediumBlack)
//        .preferredColorScheme(.dark)
//}
