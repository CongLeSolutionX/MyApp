
import SwiftUI
import UIKit // Needed for UIApplication and UIWindowScene

// MARK: - Main App Entry (Assume App entry point is defined elsewhere)
struct MainTabView: View {
    @State private var selectedTab: Int = 0 // manages active tab

    // Computed property to determine if a generic top bar is needed
    private var currentTopBarTitle: String? {
        switch selectedTab {
        case 0: return nil         // ForYouView manages its own header
        case 1: return "Headlines"
        case 2: return "Following"
        case 3: return nil         // NewsstandView manages its own top bar
        default: return nil
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Conditionally display a generic TopBar for tabs that need it
            if let title = currentTopBarTitle {
                TopBarView(title: title)
                    .background(Color.black) // Explicit background for TopBar
            } // No EmptyView needed here, handled by nil return from currentTopBarTitle

            // Content view with overlaid TabBar
            ZStack(alignment: .bottom) {
                currentContentView
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                TabBarView(selectedTab: $selectedTab)
                    .background(.thinMaterial) // Apply background to TabBar only
            }
        }
        .background(Color.black.ignoresSafeArea()) // Background for the whole tab view container
        .foregroundColor(.white) // Default text color
        .tint(.blue) // Default accent color for buttons, etc.
        .ignoresSafeArea(.keyboard)
    }

    @ViewBuilder
    private var currentContentView: some View {
        switch selectedTab {
        case 0:
            ForYouView()
        case 1:
            HeadlinesView()
        case 2:
            FollowingView()
        case 3:
            NewsstandView()
        default:
            ForYouView() // Fallback to default view
        }
    }
}

// MARK: - Reusable UI Components

// Generic Top Bar for Headlines and Following
struct TopBarView: View {
    let title: String
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .font(.title2)
            Spacer()
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
            Spacer()
             // Use the custom initializer correctly
            Image(name: "profile_placeholder", defaultSymbol: "person.crop.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.gray, lineWidth: 0.5))
        }
        .padding(.horizontal)
        .frame(height: 44) // Standard navigation bar height
    }
}

// Special Top Bar for Newsstand with subtitle
struct TopBarNewsstand: View {
    var body: some View {
        VStack(spacing: 4) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .font(.title2)
                Spacer()
                Text("Newsstand")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                // Placeholder to balance the layout like TopBarView
                Color.clear.frame(width: 30, height: 30)
            }
            .padding(.horizontal)
            .frame(height: 44)

            Text("Suggested Sources")
                .font(.caption)
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 5)
        }
        // Height will be determined by content, slightly more than 44
    }
}

// Weather Widget for ForYou header
struct WeatherWidget: View {
    var body: some View {
        HStack(spacing: 6) {
            Text("65°F") // Placeholder weather
                .fontWeight(.medium)
            Image(systemName: "cloud.sun.fill")
                .renderingMode(.original) // Keep original colors
                .font(.title3)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color.secondary.opacity(0.3))
        .cornerRadius(20)
    }
}

// Header for ForYou screen
struct HeaderView: View {
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Your briefing")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Text(Date(), style: .date) // Display current date
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
            WeatherWidget()
        }
        .padding(.horizontal)
        .padding(.top) // Add padding at the top
    }
}

// "Top stories" Link button for ForYou screen
struct TopStoriesLinkView: View {
    var action: () -> Void = { print("Top stories tapped") } // Default action
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text("Top stories")
                    .font(.headline)
                    .fontWeight(.medium)
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
            }
            .foregroundColor(.accentColor) // Use the global accent color
        }
        .padding([.horizontal, .top])
        .padding(.bottom, 8)
    }
}

// Category selector for Headlines screen
struct CategorySelectorView: View {
    let categories = ["Latest", "U.S.", "World", "Business", "Technology", "Entertainment", "Sports", "Science", "Health"]
    @Binding var selectedCategory: String
    var categorySelectedAction: (String) -> Void = { category in print("Selected category: \(category)") }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                ForEach(categories, id: \.self) { category in
                    CategoryTab(text: category, isSelected: selectedCategory == category)
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.2)) { // Smooth animation
                                selectedCategory = category
                            }
                            categorySelectedAction(category) // Perform action after state change
                        }
                }
            }
            .padding(.horizontal)
            .frame(height: 40) // Fixed height for the selector
        }
        .background(Color.black) // Background for the category bar itself
    }
}

// Individual category tab for Headlines screen
struct CategoryTab: View {
    let text: String
    var isSelected: Bool
    var body: some View {
        VStack(spacing: 4) {
            Text(text)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .accentColor : .gray)
            Rectangle() // Underline indicator
                .frame(height: 3)
                .foregroundColor(isSelected ? .accentColor : .clear)
                .cornerRadius(1.5)
                .padding(.horizontal, 4) // Adjust padding for underline width
        }
        .animation(.easeInOut(duration: 0.2), value: isSelected) // Animate changes based on isSelected
    }
}

// Main News Card view for ForYou screen
struct MainNewsCardView: View {
    let article: NewsArticle
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
             // Use custom image initializer
            Image(name: article.imageName, defaultSymbol: "photo.fill")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 200)
                .clipped()
                .cornerRadius(10)
                .padding(.bottom, 4)

            HStack(spacing: 6) {
                 // Use custom image initializer
                Image(name: article.source.logoName, defaultSymbol: "newspaper")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .cornerRadius(4)
                Text(article.source.name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.gray)
            }
            Text(article.headline)
                .font(.title3)
                .fontWeight(.semibold)
                .lineLimit(3) // Limit headline length

            HStack {
                Text(article.timeAgo)
                    .font(.caption)
                    .foregroundColor(.gray)
                Spacer()
                // Action Icons (placeholders)
                Image(systemName: "doc.text.image") // Example action
                    .font(.callout)
                    .foregroundColor(.gray)
                Image(systemName: "ellipsis") // More options
                    .font(.callout)
                    .foregroundColor(.gray)
            }
            .padding(.top, 2)

            Divider() // Visual separator
                .padding(.top, 8)
        }
        .padding(.horizontal)
        .padding(.bottom)
    }
}

// Small News Card view for ForYou list
struct SmallNewsCardView: View {
    let article: NewsArticle
    var body: some View {
        VStack(spacing: 0) { // Use spacing 0 for seamless Divider
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                         // Use custom image initializer
                        Image(name: article.source.logoName, defaultSymbol: "newspaper")
                            .resizable()
                            .frame(width: 16, height: 16)
                            .cornerRadius(3)
                        Text(article.source.name)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.gray)
                    }
                    Text(article.headline)
                        .font(.headline) // Slightly larger font for small card headline
                        .lineLimit(3)
                    HStack {
                        Text(article.timeAgo)
                            .font(.caption)
                            .foregroundColor(.gray)
                        Spacer()
                        // Action Icons
                        Image(systemName: "doc.text.image")
                            .font(.callout)
                            .foregroundColor(.gray)
                        Image(systemName: "ellipsis")
                            .font(.callout)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 2)
                }
                Spacer() // Pushes image to the right
                 // Use custom image initializer (prioritize smallImageName)
                Image(name: article.smallImageName ?? article.imageName, defaultSymbol: "photo.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fill) // Fill the frame
                    .frame(width: 80, height: 80) // Standard small image size
                    .clipped()
                    .cornerRadius(8)
            }
            .padding(.vertical, 12)
            .padding(.horizontal)

            Divider() // Separator (inset slightly if needed)
        }
    }
}

// Full Coverage Button for Headlines screen
struct FullCoverageButton: View {
    var action: () -> Void = { print("Full Coverage tapped") }
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: "doc.text.image")
                    .font(.callout)
                Text("Full Coverage of this story")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .foregroundColor(.white)
            .padding(.vertical, 10)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, alignment: .center) // Button takes full width
            .background(Color.secondary.opacity(0.3))
            .cornerRadius(20) // Pill shape
        }
        .buttonStyle(.plain) // Remove default button styling
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

// Related Story Card for Headlines screen
struct RelatedStoryCardView: View {
    let relatedArticle: RelatedArticle
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                 // Use custom image initializer
                Image(name: relatedArticle.source.logoName, defaultSymbol: "newspaper")
                    .resizable()
                    .frame(width: 16, height: 16)
                    .cornerRadius(3)
                Text(relatedArticle.source.name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.gray)
            }
            Text(relatedArticle.headline)
                .font(.footnote) // Smaller font for related story
                .lineLimit(3)
            HStack {
                Text(relatedArticle.timeAgo)
                    .font(.caption2) // Even smaller font for time
                    .foregroundColor(.gray)
                Spacer()
                Image(systemName: "ellipsis") // More options
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(10)
        .frame(width: 180) // Fixed width for horizontal scroll
        .background(Color.secondary.opacity(0.2))
        .cornerRadius(8)
    }
}

// Headline Story Block in Headlines screen, including related stories and full coverage button
struct HeadlineStoryBlockView: View {
    let article: HeadlineArticle
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
             // Use custom image initializer
            Image(name: article.imageName, defaultSymbol: "photo.fill")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 200)
                .clipped()
                .padding(.bottom, 12)

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                     // Use custom image initializer
                    Image(name: article.source.logoName, defaultSymbol: "newspaper")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .cornerRadius(4)
                    Text(article.source.name)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.gray)
                }
                Text(article.headline)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .lineLimit(3)
                HStack {
                    Text(article.timeAgo)
                        .font(.caption)
                        .foregroundColor(.gray)
                    Spacer()
                    Image(systemName: "ellipsis") // More options
                        .font(.callout)
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 16)

            // Related Articles Section (if any)
            if !article.relatedArticles.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(article.relatedArticles) { related in
                            RelatedStoryCardView(relatedArticle: related)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                }
                .frame(height: 120) // Adjust height based on RelatedStoryCardView size
            }

            FullCoverageButton() // Add the full coverage button

            Divider() // Separator
                .padding(.top, 12)
        }
        .padding(.bottom) // Bottom padding for the whole block
    }
}

// Followed Item view for Following screen (recently followed section)
struct FollowedItemView: View {
    let item: FollowedItem
    var body: some View {
        VStack(spacing: 6) {
            ZStack { // Layer background and image/icon
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.secondary.opacity(0.2))
                    .frame(width: 60, height: 60)

                // Display Image or Icon based on FollowedItem data
                if let imageName = item.imageName {
                     // Use custom image initializer
                    Image(name: imageName, defaultSymbol: "photo.on.rectangle.angled")
                        .resizable()
                        .scaledToFill() // Fill the frame
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else if let iconName = item.iconName {
                    Image(systemName: iconName)
                        .font(.system(size: 24))
                        .foregroundColor(.gray)
                } else if item.type == .search { // Special case for search icon
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 24))
                        .foregroundColor(.gray)
                }
            }
            Text(item.name)
                .font(.caption)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(width: 60) // Limit text width to match image/icon
        }
    }
}

// Recently Followed Section for Following screen
struct RecentlyFollowedView: View {
    let items: [FollowedItem]
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Recently followed")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.gray)
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(items) { item in
                        FollowedItemView(item: item)
                    }
                }
                .padding(.horizontal) // Padding for the scroll content
            }
            Divider() // Separator below the scroll view
                .padding(.top, 12)
        }
        .padding(.top) // Padding above the section
    }
}

// Topic Header for Following screen
struct TopicHeaderView: View {
    let group: FollowedTopicGroup
    @State private var isFollowed: Bool = true // Assume initially followed for placeholder
    var followToggleAction: (Bool) -> Void = { _ in print("Follow toggled") } // Placeholder action
    var body: some View {
        HStack {
             // Use custom image initializer
            Image(name: group.topicImageName, defaultSymbol: "photo.on.rectangle.angled")
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
                .cornerRadius(4)
            Text(group.topicName)
                .font(.headline)
                .fontWeight(.medium)
            Spacer()
            Button { // Follow/Unfollow Button
                isFollowed.toggle()
                followToggleAction(isFollowed)
            } label: {
                Image(systemName: isFollowed ? "star.fill" : "star")
                    .foregroundColor(isFollowed ? Color.accentColor : .gray)
                    .font(.title3)
            }
            .buttonStyle(.plain) // Use plain style for custom interaction area
        }
        .padding(.horizontal)
        .padding(.vertical, 10) // Vertical padding for the header
    }
}

// Following Article Card for Following screen list
struct FollowingArticleCardView: View {
    let article: FollowingArticle
    var body: some View {
        VStack(spacing: 0) { // Use spacing 0 for seamless Divider
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 4) {
                         // Use custom image initializer
                        Image(name: article.source.logoName, defaultSymbol: "newspaper")
                            .resizable()
                            .frame(width: 16, height: 16)
                            .cornerRadius(3)
                        Text(article.source.name)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.gray)
                            .lineLimit(1) // Prevent long source names from wrapping badly
                    }
                    Text(article.headline)
                        .font(.subheadline) // Slightly smaller than small news card
                        .lineLimit(3)
                    Spacer(minLength: 4) // Push content down slightly if needed
                    HStack {
                        Text(article.timeAgo)
                            .font(.caption2) // Smaller time font
                            .foregroundColor(.gray)
                        Spacer()
                        // Action Icons
                        HStack(spacing: 16) {
                            Image(systemName: "doc.text.image")
                                .font(.callout)
                                .foregroundColor(.gray)
                            Image(systemName: "ellipsis")
                                .font(.callout)
                                .foregroundColor(.gray)
                        }
                    }
                }
                Spacer()
                 // Use custom image initializer
                Image(name: article.imageName, defaultSymbol: "photo.fill")
                    .resizable()
                    .scaledToFill() // Use fill to ensure it covers the frame
                    .frame(width: 80, height: 80)
                    .cornerRadius(8)
                    .clipped() // Clip excess image content
            }
            .padding(.horizontal)
            .padding(.vertical, 12)

            Divider() // Separator (optional: add leading padding)
                 .padding(.leading) // Indent divider slightly
        }
    }
}

// Floating Action Button in Following screen
struct AddFollowButton: View {
    var action: () -> Void = { print("Add Follow Tapped") }
    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(Color.accentColor) // Use global accent color
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2) // Add shadow
        }
         .buttonStyle(.plain) // Ensure the whole area is tappable without default styling
    }
}

// News Showcase Section Header for Newsstand
struct NewsShowcaseSectionHeader: View {
    var seeAllAction: () -> Void = { print("News Showcase All Tapped") }
    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text("News Showcase")
                    .font(.title3)
                    .fontWeight(.semibold)
                Text("Stories selected by newsroom editors")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()
            Button(action: seeAllAction) {
                Image(systemName: "arrow.right") // Simple right arrow for "See All"
                    .font(.title3)
                    .foregroundColor(.gray)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal)
        .padding(.top) // Top padding for the section
    }
}


// Showcase Article Row for Newsstand card
struct ShowcaseArticleRowView: View {
    let article: ShowcaseArticle
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Optional Topic Tag
            if let topic = article.topicTag {
                Text(topic)
                    .font(.caption2.weight(.medium))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Color.gray.opacity(0.4)) // Muted background
                    .cornerRadius(4)
                    .padding(.bottom, 6) // Space below tag
            }

            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    // Optional Context
                    if let context = article.context {
                        Text(context)
                            .font(.caption)
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }
                    Text(article.headline)
                        .font(.subheadline)
                        .fontWeight(.regular) // Regular weight for showcase article
                        .lineLimit(3)
                }
                Spacer()
                 // Use custom image initializer
                Image(article.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 70, height: 70) // Slightly smaller image for row
                    .cornerRadius(8)
                    .clipped()
            }
        }
        .padding(.vertical, 10) // Vertical padding for the row
    }
}

// News Showcase Card for Newsstand horizontal scroll
struct NewsShowcaseCardView: View {
    let showcase: NewsShowcaseSource
    @State private var isFollowed: Bool = false // Local state for follow button
    var followToggleAction: (Bool) -> Void = { _ in print("Showcase Follow Toggled") }
    var optionsAction: () -> Void = { print("Showcase Options Tapped") }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header of the card
            HStack {
                 // Use custom image initializer
                Image(name: showcase.source.logoName, defaultSymbol: "newspaper")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 18) // Fixed height for logo
                Text(showcase.source.name)
                    .font(.caption)
                    .fontWeight(.medium)
                Spacer()
                Button { // Follow/Unfollow Button
                    isFollowed.toggle()
                    followToggleAction(isFollowed)
                } label: {
                    Text(isFollowed ? "Following" : "Follow")
                        .font(.caption.weight(.medium))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .foregroundColor(isFollowed ? .white : .accentColor)
                        .background(isFollowed ? Color.accentColor.opacity(0.7) : Color.secondary.opacity(0.3))
                        .clipShape(Capsule()) // Pill shaped button
                }
                .buttonStyle(.plain) // Remove default styling
            }
            .padding([.horizontal, .top], 12)
            .padding(.bottom, 8) // Space below header

            // List of Articles
            VStack(spacing: 0) {
                ForEach(showcase.articles.indices, id: \.self) { index in
                    ShowcaseArticleRowView(article: showcase.articles[index])
                        .padding(.horizontal, 12) // Padding within the card
                    // Add Divider between articles
                    if index < showcase.articles.count - 1 {
                        Divider().padding(.leading, 12) // Indented divider
                    }
                }
            }

            // Footer of the card
            HStack {
                Text("SHOWCASE")
                    .font(.caption2.weight(.bold))
                    .foregroundColor(.gray)
                Text("· \(showcase.timeAgo)")
                    .font(.caption2)
                    .foregroundColor(.gray)
                Spacer()
                Button(action: optionsAction) { // More options button
                    Image(systemName: "ellipsis")
                        .foregroundColor(.gray)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8) // Padding for the footer
        }
        .background(Color.secondary.opacity(0.2)) // Background for the card
        .cornerRadius(16) // Rounded corners for the card
        .frame(width: 300) // Fixed width for horizontal scroll element
    }
}

// Source Tile for Newsstand
struct SourceTileView: View {
    let source: NewsSource
    var tileTapAction: () -> Void = { print("Source Tile Tapped") }
    var body: some View {
        Button(action: tileTapAction) {
             // Use custom image initializer
            Image(name: source.logoName, defaultSymbol: "newspaper")
                .resizable()
                .scaledToFit() // Fit logo within the tile
                .padding(8) // Padding around the logo
                .frame(width: 90, height: 90) // Square tile size
                .background(Color.secondary.opacity(0.2)) // Tile background
                .cornerRadius(12) // Rounded corners for the tile
        }
        .buttonStyle(.plain) // Make the entire tile tappable
    }
}

// TabBar Item view used in TabBar
struct TabBarItem: View {
    let icon: String
    let text: String
    var isSelected: Bool = false
    var isSpecial: Bool = false // For the Newsstand button style

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                 // Adjust icon size and position for special state
                .font(.system(size: isSelected && isSpecial ? 20 : 22))
                .offset(y: isSelected && isSpecial ? -2 : 0)
            Text(text)
                .font(.caption)
                 // Adjust text position for special state
                .offset(y: isSelected && isSpecial ? 2 : 0)
        }
        .foregroundColor(isSelected ? (isSpecial ? .white : .accentColor) : .gray)
        .frame(maxWidth: .infinity) // Allow item to expand
        .frame(height: 48) // Fixed height for tab items
        .background(
            ZStack { // Background for the special selected state (Newsstand)
                if isSelected && isSpecial {
                    Capsule()
                        .fill(Color.accentColor)
                        .frame(width: 65, height: 32) // Size of the capsule background
                         // Animate the capsule appearance
                        .transition(.opacity.combined(with: .scale(scale: 0.8)))
                }
            }
        )
         // Animate overall changes based on the special selected state
        .animation(.easeInOut(duration: 0.2), value: isSelected && isSpecial)
    }
}


// TabBar View at the bottom of the screen
struct TabBarView: View {
    @Binding var selectedTab: Int

    // Helper to get bottom safe area inset
    private var safeAreaBottom: CGFloat {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let safeAreaInsets = windowScene.windows.first?.safeAreaInsets else {
            return 0
        }
        return safeAreaInsets.bottom
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                TabBarItem(icon: "arrow.up.forward.app.fill", text: "For you", isSelected: selectedTab == 0, isSpecial: false)
                    .contentShape(Rectangle()) // Ensure whole area is tappable
                    .onTapGesture { selectedTab = 0 }
                TabBarItem(icon: "globe", text: "Headlines", isSelected: selectedTab == 1, isSpecial: false)
                    .contentShape(Rectangle())
                    .onTapGesture { selectedTab = 1 }
                TabBarItem(icon: "star", text: "Following", isSelected: selectedTab == 2, isSpecial: false)
                    .contentShape(Rectangle())
                    .onTapGesture { selectedTab = 2 }
                TabBarItem(icon: "chart.bar.fill", text: "Newsstand", isSelected: selectedTab == 3, isSpecial: true) // Mark as special
                    .contentShape(Rectangle())
                    .onTapGesture { selectedTab = 3 }
            }
            .frame(height: 50) // Height of the icon/text area
             // Adjust bottom padding based on safe area
            .padding(.bottom, safeAreaBottom > 0 ? 0 : 8) // Add padding only if no safe area
        }
        // Animate tab changes
        .animation(.easeInOut(duration: 0.2), value: selectedTab)
    }
}


// Profile Settings Sheet (Presented from Newsstand)
struct ProfileSettingsView: View {
    @Environment(\.dismiss) var dismiss // Environment value to dismiss the sheet

    var body: some View {
        NavigationView { // Embed in NavigationView for title and toolbar
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Profile Info Section
                    HStack(spacing: 15) {
                        ZStack(alignment: .bottomTrailing) {
                            // Use custom image initializer
                            Image(name: "profile_placeholder", defaultSymbol: "person.crop.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 45, height: 45)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.gray, lineWidth: 1))

                            // Camera icon overlay (non-functional placeholder)
                            Image(systemName: "camera.circle.fill")
                                .font(.system(size: 16))
                                .background(Circle().fill(Color.white.opacity(0.8))) // Make background slightly transparent
                                .offset(x: 5, y: 5)
                                .foregroundColor(.black) // Ensure icon is visible
                        }
                        VStack(alignment: .leading) {
                            Text("Cong Le") // Placeholder Name
                                .font(.headline)
                                .foregroundColor(.white)
                            Text("longchik@gmail.com") // Placeholder Email
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        // Down arrow icon (non-functional placeholder)
                        Image(systemName: "chevron.down.circle.fill")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                    .padding() // Padding around the profile info

                    // Manage Account Button
                    Button("Manage your Google Account") { /* Add action */ }
                        .buttonStyle(.bordered) // Use bordered style
                        .tint(.gray) // Gray tint for the button
                        .frame(maxWidth: .infinity) // Make button full width
                        .padding(.horizontal)
                        .padding(.bottom)

                    Divider().background(Color.gray.opacity(0.5)) // Use Divider with background

                    // Action Rows Section 1
                    VStack(alignment: .leading, spacing: 0) {
                        actionRow(icon: "bell", text: "Notifications & shared") { /* Add action */ }
                        actionRow(icon: "clock.arrow.circlepath", text: "My Activity") { /* Add action */ }
                    }

                    Divider().background(Color.gray.opacity(0.5))

                    // Action Rows Section 2
                    VStack(alignment: .leading, spacing: 0) {
                        actionRow(icon: "gearshape", text: "News settings") { /* Add action */ }
                        actionRow(icon: "questionmark.circle", text: "Help & feedback") { /* Add action */ }
                    }

                    Divider().background(Color.gray.opacity(0.5))

                    // Footer Section
                    HStack {
                        Button("Privacy Policy") { /* Add action */ }
                            .buttonStyle(PlainButtonStyle()) // Remove default styling
                        Text("·") // Separator dot
                            .foregroundColor(.gray)
                        Button("Terms of Service") { /* Add action */ }
                            .buttonStyle(PlainButtonStyle())
                    }
                    .font(.caption)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .center) // Center align footer links
                    .padding(.vertical)
                }
            }
            .background(Color(UIColor.systemGray6).ignoresSafeArea()) // Use system background color
            .foregroundColor(.white) // Set default text color for the sheet content
            .navigationTitle("Google") // Title for the sheet
            .navigationBarTitleDisplayMode(.inline) // Inline title style
            .toolbar { // Add toolbar items
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { dismiss() } label: { // Dismiss button
                        Image(systemName: "xmark")
                            .font(.body.weight(.semibold))
                            .foregroundColor(.white) // Ensure close button is visible
                    }
                }
            }
        }
        .accentColor(.white) // Set accent color for the NavigationView
        .preferredColorScheme(.dark) // Force dark mode for this sheet
    }

    // Reusable helper view for action rows in the profile sheet
    @ViewBuilder
    private func actionRow(icon: String, text: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 20) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.gray)
                    .frame(width: 25, alignment: .center) // Align icons
                Text(text)
                    .foregroundColor(.white) // Ensure text is white
                Spacer() // Push text to the left
            }
            .padding() // Padding inside the button row
            .contentShape(Rectangle()) // Make the whole row tappable
        }
        .buttonStyle(.plain) // Remove default button chrome
    }
}


// MARK: - Feature Views

// ForYou View (formerly GoogleNewsView)
struct ForYouView: View {
    // Placeholder Data
    let mainArticle = NewsArticle.placeholder
    let otherArticles = [NewsArticle.placeholderSmall, NewsArticle.placeholderSmall, NewsArticle.placeholderSmall]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                HeaderView()                  // Custom header for this tab
                TopStoriesLinkView()          // Link below header
                MainNewsCardView(article: mainArticle) // First main article
                ForEach(otherArticles) { article in // List of smaller articles
                    SmallNewsCardView(article: article)
                }
            }
            .padding(.bottom, 60) // Padding at the bottom to avoid TabBar overlap
        }
         .background(Color.black) // Ensure background is black for this view
    }
}

// Headlines View
struct HeadlinesView: View {
    @State private var selectedCategory: String = "Latest" // State for category selection
    // Placeholder Data
    let headlineStories = [HeadlineArticle.placeholder, HeadlineArticle.placeholderUS]

    var body: some View {
        VStack(spacing: 0) {
            CategorySelectorView(selectedCategory: $selectedCategory) // Category tabs
            ScrollView {
                VStack(spacing: 0) {
                    // Filter stories based on selected category or show all for "Latest"
                    let filteredStories = headlineStories.filter { $0.category == selectedCategory || selectedCategory == "Latest" }

                    if filteredStories.isEmpty {
                        Text("No stories found for \(selectedCategory).")
                            .foregroundColor(.gray)
                            .padding()
                            .frame(maxWidth: .infinity, maxHeight: .infinity) // Center message if no stories
                    } else {
                        ForEach(filteredStories) { article in
                            HeadlineStoryBlockView(article: article) // Display filtered stories
                        }
                    }
                }
                .padding(.bottom, 60) // Padding at the bottom
            }
             .background(Color.black) // Background for the scroll content
        }
        // No separate background needed for VStack if ScrollView has it
    }
}

// Following View
struct FollowingView: View {
    // Placeholder Data
    let recentlyFollowedItems = [FollowedItem.placeholderLibrary, FollowedItem.placeholderSaved, FollowedItem.placeholderTopic, FollowedItem.placeholderSearch]
    let followedTopicGroups = [FollowedTopicGroup.placeholder, FollowedTopicGroup.placeholderTech]

    var body: some View {
        ZStack(alignment: .bottomTrailing) { // Use ZStack for Floating Action Button
            ScrollView {
                 // Use LazyVStack for potentially long lists of followed topics/articles
                LazyVStack(alignment: .leading, spacing: 0, pinnedViews: [.sectionHeaders]) {
                    RecentlyFollowedView(items: recentlyFollowedItems) // Recently followed carousel

                    ForEach(followedTopicGroups) { group in
                        Section { // Use Section for better structure and header pinning
                            ForEach(group.articles) { article in
                                FollowingArticleCardView(article: article) // Articles within the group
                            }
                        } header: {
                            TopicHeaderView(group: group) // Header for the topic group
                                .background(Color.black) // Ensure header background matches
                        }

                        // Separator between topic groups
                        Divider()
                            .frame(height: 1)
                            .background(Color.gray.opacity(0.4))
                            .padding(.vertical, 10)
                    }
                }
                .padding(.bottom, 80) // Extra bottom padding for FAB visibility
            }
            .background(Color.black) // Background for the scrollable content

            AddFollowButton() // Floating action button
                .padding(.trailing) // Padding from the edge
                .padding(.bottom, 65) // Padding from the bottom (above TabBar)
        }
    }
}

// Newsstand View
struct NewsstandView: View {
    @State private var showingProfileSheet = false // State to control profile sheet presentation
    // Placeholder Data
    let showcaseSources = [NewsShowcaseSource.placeholder, NewsShowcaseSource.placeholderBarrons]
    let sourceCategories = [NewsSourceCategory.placeholder, NewsSourceCategory.placeholderTech]

    var body: some View {
        VStack(spacing: 0) {
            // Custom Top Bar for Newsstand with Profile button overlay
            HStack {
                TopBarNewsstand() // Contains title and subtitle
            }
            .frame(minHeight: 70) // Ensure enough height for title and subtitle
            .overlay(alignment: .topTrailing) {
                 // Profile picture button to show the sheet
                 // Use custom image initializer
                Image(name: "profile_placeholder", defaultSymbol: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.gray, lineWidth: 0.5))
                    .padding(.trailing)
                    .padding(.top, 7) // Adjust top padding to align with TopBarNewsstand
                    .contentShape(Circle()) // Make the circle area tappable
                    .onTapGesture { showingProfileSheet = true }
            }
            .background(Color.black) // Background for the top bar area

            // Main content scroll view
            ScrollView {
                 // LazyVStack for performance with multiple sections/carousels
                LazyVStack(alignment: .leading, spacing: 10) {
                    NewsShowcaseSectionHeader() // Header for Showcase section
                    // Horizontal scroll view for Showcase cards
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(showcaseSources) { showcase in
                                NewsShowcaseCardView(showcase: showcase) // Individual showcase card
                            }
                        }
                        .padding(.horizontal) // Padding for the carousel content
                        .padding(.bottom) // Space below the carousel
                    }

                    // Sections for different source categories
                    ForEach(sourceCategories) { category in
                        SourceCategorySectionHeader(categoryName: category.name)// Header for the category
                        // Horizontal scroll view for Source tiles in the category
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(category.sources) { source in
                                    SourceTileView(source: source) // Individual source tile
                                }
                            }
                            .padding(.horizontal) // Padding for the tile carousel
                            .padding(.bottom) // Space below the tiles
                        }
                    }
                }
                .padding(.bottom, 60) // Padding at the bottom of the main scroll view
            }
             .background(Color.black) // Background for the scrollable content
        }
        .sheet(isPresented: $showingProfileSheet) { // Present the profile sheet
            ProfileSettingsView()
        }
    }
}
// Source Category Section Header for Newsstand
struct SourceCategorySectionHeader: View {
    let categoryName: String
    var categoryTapAction: () -> Void = { print("Category Tapped") }
    var body: some View {
        HStack {
            Button(action: categoryTapAction) {
                HStack(spacing: 4) {
                    Text(categoryName)
                        .font(.title3)
                        .fontWeight(.semibold)
                    Image(systemName: "chevron.right")
                        .font(.callout.weight(.semibold))
                        .foregroundColor(.gray)
                }
            }
            .buttonStyle(.plain) // Make the text tappable
            .foregroundColor(.white) // Ensure text color is white
            Spacer()
        }
        .padding(.horizontal)
        .padding(.top, 20) // More top padding for category sections
        .padding(.bottom, 8) // Space below header
    }
}

// MARK: - Data Models & Extensions

enum FollowedItemType {
    case library, saved, topic, search
}

// --- Corrected Data Models with Initializers Moved Inside ---

struct NewsSource: Identifiable {
    let id: UUID
    let name: String
    let logoName: String

    init(id: UUID = UUID(), name: String, logoName: String) {
        self.id = id
        self.name = name
        self.logoName = logoName
    }

    // Static examples remain accessible
    static let ap = NewsSource(name: "Associated Press", logoName: "ap_logo")
    static let cnn = NewsSource(name: "CNN", logoName: "cnn_logo")
    static let nyt = NewsSource(name: "New York Times", logoName: "nyt_logo")
    static let reuters = NewsSource(name: "Reuters", logoName: "reuters_logo_white")
    static let ew = NewsSource(name: "Entertainment Weekly", logoName: "ew_logo")
    static let instyle = NewsSource(name: "InStyle", logoName: "instyle_logo")
    static let verge = NewsSource(name: "The Verge", logoName: "verge_logo")
    static let wired = NewsSource(name: "Wired", logoName: "wired_logo")
    static let abc = NewsSource(name: "ABC News", logoName: "abc_logo")
    static let haaretz = NewsSource(name: "Haaretz", logoName: "haaretz_logo")
    static let barrons = NewsSource(name: "Barron's", logoName: "barrons_logo_white")
    static let placeholderSource = NewsSource(name: "Placeholder Source", logoName: "newspaper")
}

struct NewsArticle: Identifiable {
    let id: UUID
    let source: NewsSource
    let headline: String
    let imageName: String
    let timeAgo: String
    let isLargeCard: Bool // Consider if needed, currently not used for layout decisions
    let smallImageName: String?

    init(id: UUID = UUID(), source: NewsSource, headline: String, imageName: String, timeAgo: String, isLargeCard: Bool, smallImageName: String? = nil) {
        self.id = id
        self.source = source
        self.headline = headline
        self.imageName = imageName
        self.timeAgo = timeAgo
        self.isLargeCard = isLargeCard
        self.smallImageName = smallImageName ?? imageName // Fallback to main image if small is nil
    }

    static var placeholder: NewsArticle {
        NewsArticle(source: .ap, headline: "Major Event Unfolds: Placeholder Headline for Main Card View", imageName: "trump_large", timeAgo: "1h ago", isLargeCard: true)
    }
    static var placeholderSmall: NewsArticle {
        NewsArticle(source: .nyt, headline: "Smaller Story: Placeholder text for a list item card", imageName: "disaster_small_nyt", timeAgo: "2h ago", isLargeCard: false)
    }
}

struct HeadlineArticle: Identifiable {
    let id: UUID
    let category: String
    let source: NewsSource
    let headline: String
    let imageName: String
    let timeAgo: String
    var relatedArticles: [RelatedArticle]

    init(id: UUID = UUID(), category: String, source: NewsSource, headline: String, imageName: String, timeAgo: String, relatedArticles: [RelatedArticle]) {
        self.id = id
        self.category = category
        self.source = source
        self.headline = headline
        self.imageName = imageName
        self.timeAgo = timeAgo
        self.relatedArticles = relatedArticles
    }

    static var placeholder: HeadlineArticle {
        HeadlineArticle(category: "Latest", source: .ap, headline: "Top Headline: Trump Administration Makes New Move", imageName: "trump_small_ap", timeAgo: "1h ago", relatedArticles: [RelatedArticle.placeholderCNN, RelatedArticle.placeholderNYT])
    }
    static var placeholderUS: HeadlineArticle {
        HeadlineArticle(category: "U.S.", source: .cnn, headline: "US Politics: Biden Announces Infrastructure Plan", imageName: "biden_large", timeAgo: "3h ago", relatedArticles: [RelatedArticle.placeholderNYT])
    }
}

struct RelatedArticle: Identifiable {
    let id: UUID
    let source: NewsSource
    let headline: String
    let timeAgo: String

    init(id: UUID = UUID(), source: NewsSource, headline: String, timeAgo: String) {
        self.id = id
        self.source = source
        self.headline = headline
        self.timeAgo = timeAgo
    }

    static var placeholderCNN: RelatedArticle {
        RelatedArticle(source: .cnn, headline: "Related: CNN Analysis on the situation", timeAgo: "2h ago")
    }
    static var placeholderNYT: RelatedArticle {
        RelatedArticle(source: .nyt, headline: "Related: NYT Opinion piece adds context", timeAgo: "90m ago")
    }
}

struct FollowedItem: Identifiable {
    let id: UUID
    let name: String
    let imageName: String?
    let iconName: String?
    let type: FollowedItemType

    init(id: UUID = UUID(), name: String, imageName: String? = nil, iconName: String? = nil, type: FollowedItemType) {
        self.id = id
        self.name = name
        self.imageName = imageName
        self.iconName = iconName
        self.type = type
    }

    static var placeholderLibrary: FollowedItem { FollowedItem(name: "Library", iconName: "books.vertical.fill", type: .library) }
    static var placeholderSaved: FollowedItem { FollowedItem(name: "Saved stories", iconName: "bookmark.fill", type: .saved) }
    static var placeholderTopic: FollowedItem { FollowedItem(name: "Syria Conflict", imageName: "syria_placeholder", type: .topic) } // Example image name
    static var placeholderSearch: FollowedItem { FollowedItem(name: "Recent search...", type: .search) }
}

struct FollowingArticle: Identifiable {
    let id: UUID
    let source: NewsSource
    let headline: String
    let timeAgo: String
    let imageName: String

    init(id: UUID = UUID(), source: NewsSource, headline: String, timeAgo: String, imageName: String) {
        self.id = id
        self.source = source
        self.headline = headline
        self.timeAgo = timeAgo
        self.imageName = imageName
    }

    static var placeholderNYT: FollowingArticle { FollowingArticle(source: .nyt, headline: "Following: Article from NYT on developments in Syria", timeAgo: "13h ago", imageName: "syria_nyt_thumb") }
    static var placeholderABC: FollowingArticle { FollowingArticle(source: .abc, headline: "Following: ABC News covers humanitarian aid efforts", timeAgo: "1d ago", imageName: "syria_abc_thumb") }
    static var placeholderHaaretz: FollowingArticle { FollowingArticle(source: .haaretz, headline: "Following: Regional perspective from Haaretz", timeAgo: "18h ago", imageName: "syria_haaretz_thumb") }
}

struct FollowedTopicGroup: Identifiable {
    let id: UUID
    let topicName: String
    let topicImageName: String
    var articles: [FollowingArticle]

    init(id: UUID = UUID(), topicName: String, topicImageName: String, articles: [FollowingArticle]) {
        self.id = id
        self.topicName = topicName
        self.topicImageName = topicImageName
        self.articles = articles
    }

    static var placeholder: FollowedTopicGroup {
        FollowedTopicGroup(topicName: "Syria", topicImageName: "syria_placeholder", articles: [FollowingArticle.placeholderNYT, FollowingArticle.placeholderABC, FollowingArticle.placeholderHaaretz])
    }
    static var placeholderTech: FollowedTopicGroup {
        FollowedTopicGroup(topicName: "Technology", topicImageName: "tech_placeholder", articles: []) // Example tech topic
    }
}

struct ShowcaseArticle: Identifiable {
    let id: UUID
    let context: String?
    let headline: String
    let imageName: String
    let topicTag: String?

    init(id: UUID = UUID(), context: String? = nil, headline: String, imageName: String, topicTag: String? = nil) {
        self.id = id
        self.context = context
        self.headline = headline
        self.imageName = imageName
        self.topicTag = topicTag
    }

    static var placeholderReuters1: ShowcaseArticle { ShowcaseArticle(context: "Global Markets", headline: "Showcase: Market reacts to latest economic data", imageName: "greenland_thumb", topicTag: "BUSINESS") }
    static var placeholderReuters2: ShowcaseArticle { ShowcaseArticle(headline: "Showcase: Political shifts impact international relations", imageName: "ron_johnson_thumb", topicTag: "WORLD") }
    static var placeholderBarrons1: ShowcaseArticle { ShowcaseArticle(context: "Investment Strategy", headline: "Showcase: Top stock picks for the quarter", imageName: "barrons_thumb1", topicTag: "FINANCE") }
    static var placeholderBarrons2: ShowcaseArticle { ShowcaseArticle(headline: "Showcase: Analysis of recent IPO performance", imageName: "barrons_thumb2", topicTag: "FINANCE") }
}

struct NewsShowcaseSource: Identifiable {
    let id: UUID
    let source: NewsSource
    var articles: [ShowcaseArticle]
    let timeAgo: String

    init(id: UUID = UUID(), source: NewsSource, articles: [ShowcaseArticle], timeAgo: String) {
        self.id = id
        self.source = source
        self.articles = articles
        self.timeAgo = timeAgo
    }

    static var placeholder: NewsShowcaseSource { NewsShowcaseSource(source: .reuters, articles: [ShowcaseArticle.placeholderReuters1, ShowcaseArticle.placeholderReuters2], timeAgo: "2h ago") }
    static var placeholderBarrons: NewsShowcaseSource { NewsShowcaseSource(source: .barrons, articles: [ShowcaseArticle.placeholderBarrons1, ShowcaseArticle.placeholderBarrons2], timeAgo: "1h ago") }
}

struct NewsSourceCategory: Identifiable {
    let id: UUID
    let name: String
    var sources: [NewsSource]

    init(id: UUID = UUID(), name: String, sources: [NewsSource]) {
        self.id = id
        self.name = name
        self.sources = sources
    }

    static var placeholder: NewsSourceCategory { NewsSourceCategory(name: "Entertainment", sources: [.ew, .instyle, NewsSource(name: "Page Six", logoName: "pagesix_logo"), NewsSource(name: "Us Weekly", logoName: "usweekly_logo"), NewsSource(name: "E! News", logoName: "enews_logo")]) }
    static var placeholderTech: NewsSourceCategory { NewsSourceCategory(name: "Technology", sources: [.verge, .wired]) }
}

// --- End Corrected Data Models ---


// Extension for Image loading with default fallback
extension Image {
    // Corrected Initializer using 'name' label
    init(name: String, defaultSymbol: String = "questionmark.square.dashed") {
        #if os(watchOS)
        // watchOS doesn't use UIImage, directly initialize with systemName as fallback
        self.init(systemName: defaultSymbol)
        #else
        // Check if the image exists in the asset catalog
        if UIImage(named: name) != nil {
            self.init(name) // Use the asset image
        } else {
             // If asset not found, determine an appropriate SF Symbol fallback
            let symbol: String
            switch name {
                // --- Add specific fallbacks for known asset names ---
                case "profile_placeholder": symbol = "person.crop.circle.fill"
                // Logos
                case "ap_logo", "cnn_logo", "nyt_logo", "reuters_logo", "newspaper": symbol = "newspaper.fill"
                case "reuters_logo_white", "barrons_logo_white": symbol = "newspaper" // White bg versions might need different symbol on light mode?
                case "ew_logo", "instyle_logo", "pagesix_logo", "usweekly_logo", "enews_logo": symbol = "tv.music.note.fill"
                case "verge_logo", "wired_logo": symbol = "desktopcomputer"
                // Article/Topic Images
                case "trump_large", "trump_small_ap", "disaster_small_nyt", "biden_large": symbol = "photo.fill"
                case "syria_nyt_thumb", "syria_abc_thumb", "syria_haaretz_thumb": symbol = "photo.fill"
                case "greenland_thumb", "ron_johnson_thumb", "barrons_thumb1", "barrons_thumb2": symbol = "photo.fill"
                // Placeholder Images
                case "syria_placeholder", "tech_placeholder": symbol = "photo.on.rectangle.angled"

                default: symbol = defaultSymbol // Use the provided or default fallback symbol
            }
            self.init(systemName: symbol) // Initialize with the determined SF Symbol
        }
        #endif
    }
}


// MARK: - SwiftUI Previews
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group { // Use Group for multiple previews
            MainTabView()
                .previewDisplayName("Main Tab View - Dark")
                .preferredColorScheme(.dark) // Preview in dark mode

            MainTabView()
                .previewDisplayName("Main Tab View - Light")
                .preferredColorScheme(.light) // Preview in light mode


            ProfileSettingsView()
                .previewDisplayName("Profile Sheet")
                .preferredColorScheme(.dark) // Profile sheet is designed for dark mode
        }
    }
}
