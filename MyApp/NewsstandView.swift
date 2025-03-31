//
//  NewsstandView.swift
//  MyApp
//
//  Created by Cong Le on 3/30/25.
//

import SwiftUI

// --- Data Models (Updated for Newsstand Screen) ---

// Model for an article specifically within the News Showcase card
struct ShowcaseArticle: Identifiable {
    let id = UUID()
    let context: String? // e.g., "Roosevelt served a 3rd term"
    let headline: String
    let imageName: String // Thumbnail
    let topicTag: String? // e.g., "UNITED STATES" - Optional tag above the row
}

// Model for a single card in the "News Showcase" horizontal scroll
struct NewsShowcaseSource: Identifiable {
    let id = UUID()
    let source: NewsSource
    var articles: [ShowcaseArticle]
    let timeAgo: String // e.g., "2h" for the footer
}

// Model for a category section like "Entertainment"
struct NewsSourceCategory: Identifiable {
    let id = UUID()
    let name: String
    var sources: [NewsSource] // List of sources in this category
}

// --- Reusable Views (Some modified, some new) ---

// NEW: Top Bar specifically for Newsstand with Subtitle
struct TopBarNewsstand: View {
    var body: some View {
        VStack(spacing: 4) { // Add spacing for subtitle
            HStack {
                Image(systemName: "magnifyingglass")
                    .font(.title2)

                Spacer()

                Text("Newsstand")
                    .font(.title2)
                    .fontWeight(.bold)

                Spacer()

                Image("profile_placeholder") // Placeholder
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.gray, lineWidth: 0.5))
            }
            .padding(.horizontal)
            .frame(height: 44)

            // Subtitle
            Text("Suggested Sources")
                .font(.caption)
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, alignment: .center) // Center align subtitle
                .padding(.bottom, 5) // Add padding below subtitle

        }
    }
}

// NEW: Header for the News Showcase section
struct NewsShowcaseSectionHeader: View {
    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text("News Showcase")
                    .font(.title3) // Slightly larger font
                    .fontWeight(.semibold)
                Text("Stories selected by newsroom editors")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()
            Button {
                // Action for arrow button
                print("News Showcase All Tapped")
            } label: {
                Image(systemName: "arrow.right")
                    .font(.title3)
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal)
        .padding(.top) // Add padding above the showcase header
    }
}


// NEW: Individual Article Row within the Showcase Card
struct ShowcaseArticleRowView: View {
    let article: ShowcaseArticle

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Optional Topic Tag
            if let topic = article.topicTag {
                 Text(topic)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Color.gray.opacity(0.4))
                    .cornerRadius(4)
                    .padding(.bottom, 6) // Space below tag
            }

            HStack(alignment: .top) { // Align text and image tops
                VStack(alignment: .leading, spacing: 2) {
                    if let context = article.context {
                        Text(context)
                            .font(.caption)
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }
                    Text(article.headline)
                        .font(.subheadline) // Or .callout based on visual density
                        .fontWeight(.regular) // Regular weight seems okay
                        .lineLimit(3)        // Allow up to 3 lines
                }
                Spacer()
                Image(article.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 70, height: 70) // Smaller images
                    .cornerRadius(8)
            }
        }
        .padding(.vertical, 10) // Padding top/bottom of the row
    }
}


// NEW: The main card view for the News Showcase
struct NewsShowcaseCardView: View {
    let showcase: NewsShowcaseSource
    @State private var isFollowed: Bool = false // Example state

    var body: some View {
        VStack(alignment: .leading, spacing: 0) { // No spacing between internal elements unless specified
            // Card Header: Source + Follow Button
            HStack {
                Image(showcase.source.logoName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 18) // Adjust logo size
                Text(showcase.source.name)
                    .font(.caption)
                    .fontWeight(.medium)

                Spacer()

                Button {
                    isFollowed.toggle()
                     // Action to Follow/Unfollow Source
                } label: {
                    Label(isFollowed ? "Following" : "Follow", systemImage: "star")
                        .font(.caption)
                       // .labelStyle(.iconOnly) // For only icon? No, text is present.
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .foregroundColor(isFollowed ? .white : .gray)
                        .background(isFollowed ? Color.blue.opacity(0.7) : Color.secondary.opacity(0.3)) // Adjust background
                        .clipShape(Capsule())
                }
            }
            .padding([.horizontal, .top], 12) // Padding inside the card for header
            .padding(.bottom, 8)

            // Article List
            VStack(spacing: 0) {
                ForEach(showcase.articles.indices, id: \.self) { index in
                    ShowcaseArticleRowView(article: showcase.articles[index])
                        .padding(.horizontal, 12) // Padding for article content

                    // Add divider except after the last item
                    if index < showcase.articles.count - 1 {
                        Divider()
                            .padding(.leading, 12) // Indent divider
                    }
                }
            }

            // Card Footer: Showcase Label, Time, Options
            HStack {
                Text("SHOWCASE")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.gray)
                Text("· \(showcase.timeAgo)")
                    .font(.caption2)
                    .foregroundColor(.gray)

                Spacer()

                Button {
                   // Action for Ellipsis button
                   print("Showcase Options Tapped")
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8) // Padding for footer

        }
        .background(Color.secondary.opacity(0.2)) // Card background color
        .cornerRadius(16) // Card corner radius
        .frame(width: 300) // Fixed width for showcase cards
    }
}


// NEW: Header for source category sections (e.g., Entertainment)
struct SourceCategorySectionHeader: View {
    let categoryName: String

    var body: some View {
        HStack {
            Button {
                 // Action to navigate to category page
                 print("\(categoryName) Category Tapped")
            } label: {
                HStack(spacing: 4) {
                     Text(categoryName)
                          .font(.title3)
                          .fontWeight(.semibold)
                     Image(systemName: "chevron.right") // Use chevron
                          .font(.callout) // Make chevron smaller
                          .foregroundColor(.gray)
                }
                .foregroundColor(.white) // Ensure text color is white
            }
            Spacer()
        }
        .padding(.horizontal)
        .padding(.top, 20) // Space above category headers
        .padding(.bottom, 8) // Space below category header
    }
}


// NEW: View for the square source logo tiles
struct SourceTileView: View {
    let source: NewsSource

    var body: some View {
        Image(source.logoName)
            .resizable()
            .scaledToFit() // Fit logo within the frame
            .padding(8) // Add padding around the logo inside the background
            .frame(width: 90, height: 90) // Square frame
            .background(Color.secondary.opacity(0.2)) // Tile background
            .cornerRadius(12) // Tile corner radius
            .onTapGesture {
                // Action when tapping a source tile
                print("\(source.name) Tile Tapped")
            }
    }
}


// --- Main Content View (Updated for Newsstand Screen) ---

struct NewsstandView: View {
    @State private var currentTab: Int = 3 // Default to Newsstand tab (index 3)

    // Placeholder Data
    let showcaseSources = [
        NewsShowcaseSource(
            source: NewsSource(name: "Reuters", logoName: "reuters_logo_white"), // Use white logo for dark bg
            articles: [
                 ShowcaseArticle(context: "Roosevelt served a 3rd term", headline: "Trump says he is not joking about third presidential term", imageName: "trump_small_ap", topicTag: "UNITED STATES"),
                 ShowcaseArticle(context: "'We determine our own future'", headline: "Greenland's prime minister says the US will not get the island", imageName: "greenland_thumb", topicTag: nil),
                 ShowcaseArticle(context: "'Cuts need to exceed $2tn'", headline: "Ron Johnson: Advancing Trump agenda depends on spending cuts", imageName: "ron_johnson_thumb", topicTag: nil)
            ],
            timeAgo: "2h"
        ),
        NewsShowcaseSource( // Add another source for horizontal scroll
            source: NewsSource(name: "Barron's", logoName: "barrons_logo_white"),
             articles: [
                 ShowcaseArticle(context: "Congress", headline: "This Accounting Rule Change Could Rattle Stock Buybacks", imageName: "barrons_thumb1", topicTag: "POLITICS"),
                 ShowcaseArticle(context: "Agencies", headline: "Tax Rules for Digital Assets Are in Flux", imageName: "barrons_thumb2", topicTag: nil),
                 ShowcaseArticle(context: "Consumers", headline: "IRS Voluntary Disclosure Program for ERC Draws Underpayments", imageName: "barrons_thumb3", topicTag: nil)
             ],
             timeAgo: "4h"
        )
        // Add more showcase sources...
    ]

    let sourceCategories = [
        NewsSourceCategory(
            name: "Entertainment",
            sources: [
                 NewsSource(name: "EW", logoName: "ew_logo"),
                 NewsSource(name: "InStyle", logoName: "instyle_logo"), // Assuming 'IS' is InStyle
                 NewsSource(name: "Page Six", logoName: "pagesix_logo"),
                 NewsSource(name: "US Weekly", logoName: "usweekly_logo"),
                 NewsSource(name: "E! News", logoName: "enews_logo")
            ]
        )
        // Add more categories...
    ]

    var body: some View {
        VStack(spacing: 0) {
            TopBarNewsstand()

            ScrollView {
                LazyVStack(alignment: .leading, spacing: 10) { // Add some spacing between sections

                    // News Showcase Section
                    NewsShowcaseSectionHeader()
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) { // Spacing between showcase cards
                            ForEach(showcaseSources) { showcase in
                                NewsShowcaseCardView(showcase: showcase)
                            }
                        }
                        .padding(.horizontal) // Padding for the scroll view content
                        .padding(.bottom) // Padding below showcase scroll view
                    }

                    // Loop through Source Categories
                    ForEach(sourceCategories) { category in
                        SourceCategorySectionHeader(categoryName: category.name)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) { // Spacing between source tiles
                                ForEach(category.sources) { source in
                                     SourceTileView(source: source)
                                }
                            }
                            .padding(.horizontal) // Padding for the tile scroll view content
                            .padding(.bottom) // Padding below tile scroll view
                        }
                    }

                    // Add more sections here...

                } // End LazyVStack
            } // End ScrollView

            Spacer(minLength: 0) // Pushes TabBar down

            TabBarView(selectedTab: $currentTab) // Use binding
        } // End Main VStack
        .background(Color.black.ignoresSafeArea()) // Use black background
        .foregroundColor(.white) // Default text color
        .ignoresSafeArea(.keyboard)
         .tint(.blue) // Set accent color for buttons / selected tab
    }
}

 struct TabBarView: View {
     @Binding var selectedTab: Int

     var body: some View {
         VStack(spacing: 0) {
             Divider()
                 .background(Color.gray.opacity(0.5)) // Make divider slightly visible

             HStack {
                 TabBarItem(icon: "arrow.up.forward.app.fill", text: "For you", isSelected: selectedTab == 0, isSpecial: selectedTab == 0) // Regular selection look
                     .onTapGesture { selectedTab = 0 }

                 TabBarItem(icon: "globe", text: "Headlines", isSelected: selectedTab == 1, isSpecial: selectedTab == 1) // Regular selection look
                      .onTapGesture { selectedTab = 1 }

                 TabBarItem(icon: "star", text: "Following", isSelected: selectedTab == 2, isSpecial: selectedTab == 2) // Regular selection look (star might be filled if selected)
                      .onTapGesture { selectedTab = 2 }

                 // Newsstand Tab with special styling
                 TabBarItem(icon: "chart.bar.fill", text: "Newsstand", isSelected: selectedTab == 3, isSpecial: true) // Special blue capsule
                      .onTapGesture { selectedTab = 3 }
             }
             .frame(height: 50)
             .padding(.bottom, 8) // Bottom padding for safe area etc.
              // Use a slightly darker/less transparent background for the tab bar itself
             .background(Color(UIColor.systemGray5).opacity(0.9).ignoresSafeArea(edges: .bottom))
            // .background(Color.black.opacity(0.9).ignoresSafeArea(edges: .bottom)) // Alternative very dark bg
         }
     }
 }


// --- Preview ---

#Preview {
    NewsstandView()
        .preferredColorScheme(.dark)
}
