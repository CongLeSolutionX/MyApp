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
//struct Article: Identifiable {
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
//
//    var id: String { self.rawValue }
//}
//
//// MARK: - Sample Data
//
//let sampleArticles: [Article] = [
//    Article(isPinned: true,
//            authorName: "Cong Le",
//            authorImageName: "My-meme-original", // Replace with your asset
//            title: "Don't Get Left Behind: iOS Development Trends Shaping 2025",
//            subtitle: "The essential skills and tech you NEED to master to stay relevant, competitiv...",
//            thumbnailImageName: "article_thumb_1", // Replace with your asset
//            datePublished: "Jan 1",
//            clapCount: 94,
//            isBookmarked: false),
//    Article(isPinned: true,
//            authorName: "Cong Le",
//            authorImageName: "My-meme-original", // Replace with your asset
//            title: "Conquer Navigation Chaos in SwiftUI with the Coordinator Pattern",
//            subtitle: "Discover how the Coordinator pattern can tame complex navigation flows...",
//            thumbnailImageName: "article_thumb_2", // Replace with your asset
//            datePublished: "Dec 15",
//            clapCount: 120,
//            isBookmarked: true)
//    // Add more sample articles if needed
//]
//
//// MARK: - Custom Styles & Colors
//
//// Define custom colors if needed (using system colors for simplicity here)
//extension Color {
//    static let mediumBlack = Color.black
//    static let mediumGrayText = Color(UIColor.lightGray) // Slightly lighter gray
//    static let mediumDarkGray = Color(UIColor.darkGray) // For secondary elements
//    static let mediumLightGray = Color(UIColor.systemGray4) // For buttons bg
//    static let mediumGreen = Color.green // For FAB
//    static let mediumWhite = Color.white
//}
//
//// Custom Button Style for "Edit Profile" (Outlined)
//struct OutlineButtonStyle: ButtonStyle {
//    func makeBody(configuration: Configuration) -> some View {
//        configuration.label
//            .font(.system(size: 15, weight: .semibold))
//            .padding(.horizontal, 16)
//            .padding(.vertical, 10)
//            .foregroundColor(.mediumWhite)
//            .background(
//                Capsule()
//                    .stroke(Color.mediumDarkGray, lineWidth: 1) // Outline
//            )
//            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
//            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
//    }
//}
//
//// Custom Button Style for "View Stats" (Filled)
//struct FilledButtonStyle: ButtonStyle {
//    let backgroundColor: Color
//
//    func makeBody(configuration: Configuration) -> some View {
//        configuration.label
//            .font(.system(size: 15, weight: .semibold))
//            .padding(.horizontal, 16)
//            .padding(.vertical, 10)
//            .foregroundColor(.black) // Text color on light gray bg
//            .background(Capsule().fill(backgroundColor))
//            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
//            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
//    }
//}
//
//// MARK: - Reusable Components
//
//// --- Profile Header ---
//struct ProfileHeaderView: View {
//    var body: some View {
//        VStack(alignment: .leading, spacing: 12) {
//            HStack(spacing: 15) {
//                Image("My-meme-original") // Replace with your large profile pic asset
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
//}
//
//// --- Profile Content Tabs (Stories, Lists, About) ---
//struct ProfileTabView: View {
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
//
//// --- Filter Dropdown ---
//struct FilterDropdownView: View {
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
//
//// --- Article Card ---
//struct ArticleCardView: View {
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
//
//// --- Floating Action Button ---
//struct FloatingActionButton: View {
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
//
//// MARK: - Main Profile Content View (Scrollable Part)
//
//struct MediumProfileContentView: View {
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
//// MARK: - Main Tab View (Using System TabView)
//
//struct MediumTabView: View {
//    @State private var selectedSystemTab = 3 // Index for profile tab
//
//    init() {
//        // Customize TabBar Appearance (Globally)
//        let appearance = UITabBarAppearance()
//        appearance.configureWithOpaqueBackground()
//        appearance.backgroundColor = UIColor(Color.mediumBlack.opacity(0.9)) // Slightly transparent black
//
//        // Item colors
//        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.darkGray
//        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.darkGray]
//        appearance.stackedLayoutAppearance.selected.iconColor = UIColor.white
//        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.white]
//
//        UITabBar.appearance().standardAppearance = appearance
//        if #available(iOS 15.0, *) {
//            UITabBar.appearance().scrollEdgeAppearance = appearance
//        }
//    }
//
//    var body: some View {
//        TabView(selection: $selectedSystemTab) {
//            Text("Home Tab")
//                .tag(0)
//                .tabItem {
//                    Label("Home", systemImage: "house")
//                }
//                .toolbarBackground(.black, for: .tabBar) // Ensure background consistency
//
//            Text("Search Tab")
//                .tag(1)
//                .tabItem {
//                    Label("Search", systemImage: "magnifyingglass")
//                }
//                 .toolbarBackground(.black, for: .tabBar)
//
//            Text("Bookmarks Tab")
//                .tag(2)
//                .tabItem {
//                    Label("Bookmarks", systemImage: "bookmark")
//                }
//                 .toolbarBackground(.black, for: .tabBar)
//
//            // --- Profile Tab Content ---
//            MediumProfileContentView() // Embed the profile screen here
//                .tag(3)
//                .tabItem {
//                     // Custom Label for Profile - Circle indicator is complex, using standard icon
//                     Label("Profile", systemImage: "person.crop.circle")
//                 }
//                 .toolbarBackground(.black, for: .tabBar) // Important for consistency
//        }
//        // Apply preferred color scheme if needed, although design is inherently dark
//         .preferredColorScheme(.dark)
//    }
//}
//
//// MARK: - App Entry Point
//
////@main
////struct MediumProfileApp: App { // Rename if needed
////    var body: some Scene {
////        WindowGroup {
////            MediumTabView()
////                // Set preferred color scheme for the entire app
////                .preferredColorScheme(.dark)
////        }
////    }
////}
//
//// MARK: - Previews
//
//#Preview("Main Tab View") {
//    MediumTabView()
//}
//
//#Preview("Profile Content View") {
//    MediumProfileContentView()
//        .preferredColorScheme(.dark)
//}
//
//#Preview("Article Card") {
//    ArticleCardView(article: sampleArticles[0])
//        .padding()
//        .background(Color.mediumBlack)
//        .preferredColorScheme(.dark)
//}
//
//#Preview("Profile Header") {
//    ProfileHeaderView()
//        .padding()
//        .background(Color.mediumBlack)
//        .preferredColorScheme(.dark)
//}
//
//#Preview("Profile Tabs") {
//    // Need a state variable for preview
//    struct PreviewWrapper: View {
//        @State var tab: ProfileTab = .stories
//        var body: some View { ProfileTabView(selectedTab: $tab) }
//    }
//    return PreviewWrapper()
//        .background(Color.mediumBlack)
//        .preferredColorScheme(.dark)
//}
