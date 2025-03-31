//
//  FollowingView.swift
//  MyApp
//
//  Created by Cong Le on 3/30/25.
//

import SwiftUI

// --- Data Models (Updated for Following Screen) ---

// Model for items in the "Recently followed" horizontal scroll
enum FollowedItemType {
    case library, saved, topic, search
}

struct FollowedItem: Identifiable {
    let id = UUID()
    let name: String
    let imageName: String? // For topics/searches with images
    let iconName: String? // For Library/Saved Stories
    let type: FollowedItemType
}

// Renamed and Simplified Article Model for this screen context
struct FollowingArticle: Identifiable {
    let id = UUID()
    let source: NewsSource // Re-use NewsSource model
    let headline: String
    let timeAgo: String
    let imageName: String // Thumbnail image name
}

// Model for grouping articles by a followed topic
struct FollowedTopicGroup: Identifiable {
    let id = UUID()
    let topicName: String
    let topicImageName: String // Image for the topic header
    var articles: [FollowingArticle]
}


// NEW: View for individual items in the "Recently followed" scroll
struct FollowedItemView: View {
    let item: FollowedItem

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.secondary.opacity(0.2))
                    .frame(width: 60, height: 60)

                if let imageName = item.imageName {
                    Image(imageName) // Load topic/search image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else if let iconName = item.iconName {
                    Image(systemName: iconName) // Load icon
                        .font(.system(size: 24))
                        .foregroundColor(.gray)
                } else if item.type == .search { // Specific icon for search type if no image
                     Image(systemName: "magnifyingglass")
                        .font(.system(size: 24))
                        .foregroundColor(.gray)
                }
            }

            Text(item.name)
                .font(.caption)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(width: 60) // Match width for text wrapping
        }
    }
}

// NEW: View for the "Recently followed" horizontal section
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
                .padding(.horizontal)
                .padding(.bottom, 8)
            }
             Divider() // Divider below the scroll view
                .padding(.top, 4)
        }
        .padding(.top) // Padding above the section title
    }
}

// NEW: Header view for each followed topic group
struct TopicHeaderView: View {
    let group: FollowedTopicGroup
    @State private var isFollowed: Bool = true // Example state

    var body: some View {
        HStack {
            Image(group.topicImageName) // Image for the topic
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
                .cornerRadius(4)

            Text(group.topicName)
                .font(.headline)
                .fontWeight(.medium)

            Spacer()

            Button {
                isFollowed.toggle()
                // Add action to follow/unfollow
            } label: {
                Image(systemName: isFollowed ? "star.fill" : "star")
                    .foregroundColor(isFollowed ? .blue : .gray) // Use accent color
                    .font(.title3)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
    }
}


// NEW: Article Card specific to the Following screen layout
struct FollowingArticleCardView: View {
    let article: FollowingArticle

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 12) { // Main content alignment
                // Left side: Source, Headline, Time
                VStack(alignment: .leading, spacing: 6) {
                    // Source Row
                    HStack(spacing: 4) {
                        Image(article.source.logoName) // Use NewsSource model
                            .resizable()
                            .frame(width: 16, height: 16)
                            .cornerRadius(3)
                        Text(article.source.name)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }

                    // Headline
                    Text(article.headline)
                        .font(.subheadline) // Slightly smaller headline? Check image. Looks like subheadline or callout.
                        .fontWeight(.regular) // Regular weight seems appropriate
                        .lineLimit(3) // Allow up to 3 lines

                    Spacer(minLength: 4) // Push timestamp down

                     // Bottom Row within Left VStack: Time, Spacer, Actions
                     HStack {
                         Text(article.timeAgo)
                             .font(.caption2)
                             .foregroundColor(.gray)
                         Spacer()
                         // Action Icons - place at bottom right of the entire card conceptually, but layout pushes them here
                         HStack(spacing: 16) {
                             Image(systemName: "doc.text.image") // Full coverage icon
                                 .font(.callout)
                                 .foregroundColor(.gray)
                              Image(systemName: "ellipsis") // Options icon
                                 .font(.callout)
                                 .foregroundColor(.gray)
                         }
                     }

                } // End Left VStack

                Spacer() // Pushes image to the right

                // Right side: Thumbnail Image
                Image(article.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 80) // Adjust size as needed
                    .cornerRadius(8)

            } // End Main HStack
            .padding(.horizontal)
            .padding(.vertical, 12)

            // Divider below each article within a group
            Divider()
                .padding(.leading) // Indent divider slightly

        } // End main VStack for the card cell
    }
}

// NEW: Floating Action Button
struct AddFollowButton: View {
    var body: some View {
        Button(action: {
            // Action to add a new followed topic/source
            print("Add Follow Tapped")
        }) {
            Image(systemName: "plus")
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(Color.blue) // Use accent color
                .clipShape(Circle())
                .shadow(radius: 4, x: 0, y: 2)
        }
    }
}


// --- Main Content View (Updated for Following Screen) ---

struct FollowingView: View {
    @State private var currentTab: Int = 2 // Default to Following tab (index 2)

    // Placeholder Data
    let recentlyFollowedItems = [
        FollowedItem(name: "Library", imageName: nil, iconName: "books.vertical.fill", type: .library),
        FollowedItem(name: "Saved Stories", imageName: nil, iconName: "bookmark.fill", type: .saved),
        FollowedItem(name: "Marietta", imageName: "marietta_placeholder", iconName: nil, type: .topic),
        FollowedItem(name: "unlock iphone...", imageName: nil, iconName: "magnifyingglass", type: .search), // Use icon for search
        FollowedItem(name: "Syria", imageName: "syria_placeholder", iconName: nil, type: .topic)
    ]

    let followedTopicGroups = [
        FollowedTopicGroup(
            topicName: "Syria",
            topicImageName: "syria_placeholder",
            articles: [
                FollowingArticle(source: NewsSource(name: "The New York Times", logoName: "nyt_logo"), headline: "Syria’s Leader, Ahmed al-Shara, Names Transitional Government", timeAgo: "13 hours ago", imageName: "syria_nyt_thumb"),
                FollowingArticle(source: NewsSource(name: "ABC News", logoName: "abc_logo"), headline: "US embassy in Syria tells Americans to leave, warns of ‘potential imminent attacks’", timeAgo: "Yesterday", imageName: "syria_abc_thumb"),
                FollowingArticle(source: NewsSource(name: "Haaretz", logoName: "haaretz_logo"), headline: "‘We Went Through Horrors in Syria, but What They’re Going Through in Gaza Is a Hundred Times Worse’ - Israel News", timeAgo: "13 hours ago", imageName: "syria_haaretz_thumb")
            ]
        ),
         FollowedTopicGroup( // Example for another group
            topicName: "Technology",
            topicImageName: "tech_placeholder", // Add a placeholder image
            articles: [
                FollowingArticle(source: NewsSource(name: "The Verge", logoName: "verge_logo"), headline: "New AI Model Challenges Existing Benchmarks", timeAgo: "2 hours ago", imageName: "tech_verge_thumb"),
                FollowingArticle(source: NewsSource(name: "Wired", logoName: "wired_logo"), headline: "The Future of Quantum Computing: Hype vs. Reality", timeAgo: "5 hours ago", imageName: "tech_wired_thumb")
            ]
        )
        // Add more topic groups...
    ]

    var body: some View {
        ZStack(alignment: .bottomTrailing) { // ZStack for FAB overlay
            VStack(spacing: 0) {
                TopBarView(title: "Following")

                ScrollView {
                    // Use LazyVStack for potentially long lists
                    LazyVStack(alignment: .leading, spacing: 0, pinnedViews: []) {

                        // Recently Followed Section (not part of the LazyVStack data)
                        RecentlyFollowedView(items: recentlyFollowedItems)
                           // .padding(.bottom, 8) // Add space below divider if needed

                        // Loop through followed topic groups
                        ForEach(followedTopicGroups) { group in
                            // Section Header
                            TopicHeaderView(group: group)
                               // .background(Color.black) // Keep header background solid

                            // Articles within the group
                            ForEach(group.articles) { article in
                                FollowingArticleCardView(article: article)
                            }

                            // Thick Divider between topic groups
                            Divider()
                                .frame(height: 8) // Make divider thicker
                                .background(Color.gray.opacity(0.2)) // Give it a background color to appear thick
                                .padding(.vertical, 8)
                        }
                    } // End LazyVStack
                } // End ScrollView
                 // Ensure scroll view content goes behind tab bar
                .padding(.bottom, 50) // Adjust if tab bar height changes

                Spacer(minLength: 0) // Pushes TabBar down (potentially redundant with padding above)

                TabBarView(selectedTab: $currentTab) // Use binding
            } // End Main VStack


            // Floating Action Button
            AddFollowButton()
                .padding(.bottom, 65) // Position above the tab bar
                .padding(.trailing)

        } // End ZStack
        .background(Color.black.ignoresSafeArea())
        .foregroundColor(.white)
        .ignoresSafeArea(.keyboard)
        .tint(.blue) // Set accent color for buttons/stars
    }
}

// --- Placeholder Image Assets ---
// Add: "profile_placeholder", "marietta_placeholder", "syria_placeholder",
// "nyt_logo", "abc_logo", "haaretz_logo", "syria_nyt_thumb",
// "syria_abc_thumb", "syria_haaretz_thumb", "tech_placeholder", "verge_logo",
// "wired_logo", "tech_verge_thumb", "tech_wired_thumb"




// // Updated TabBarView to handle the blue selected background specifically
// struct TabBarView: View {
//     @Binding var selectedTab: Int
//
//     var body: some View {
//         VStack(spacing: 0) {
//             Divider()
//             HStack {
//                 TabBarItem(icon: "arrow.up.forward.app.fill", text: "For you", isSelected: selectedTab == 0)
//                     .onTapGesture { selectedTab = 0 }
//
//                 TabBarItem(icon: "globe", text: "Headlines", isSelected: selectedTab == 1)
//                      .onTapGesture { selectedTab = 1 }
//
//                 // Following Tab with special styling
//                 TabBarItem(icon: "star.fill", text: "Following", isSelected: selectedTab == 2)
//                      .onTapGesture { selectedTab = 2 }
//
//                 TabBarItem(icon: "list.bullet.rectangle.portrait", text: "Newsstand", isSelected: selectedTab == 3)
//                      .onTapGesture { selectedTab = 3 }
//             }
//             .frame(height: 50)
//             .padding(.bottom, 8)
//             .background(Color(UIColor.systemGray6).opacity(0.95).ignoresSafeArea(edges: .bottom))
//         }
//     }
// }


// --- Preview ---

#Preview {
    FollowingView()
        .preferredColorScheme(.dark)
       // Provide necessary dummy data if needed for preview
       // .environmentObject(YourDataService())
}
