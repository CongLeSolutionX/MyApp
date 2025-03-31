////
////  V2.swift
////  MyApp
////
////  Created by Cong Le on 3/30/25.
////
//
//import SwiftUI
//
//// New model for related articles
//struct RelatedArticle: Identifiable {
//    let id = UUID()
//    let source: NewsSource
//    let headline: String
//    let timeAgo: String
//}
//
//
//// NEW: Category Selector View
//struct CategorySelectorView: View {
//    let categories = ["Latest", "U.S.", "World", "Business", "Technology", "Entertainment", "Sports", "Science", "Health"]
//    @State private var selectedCategory: String = "Latest" // State to track selection
//
//    var body: some View {
//        ScrollView(.horizontal, showsIndicators: false) {
//            HStack(spacing: 20) {
//                ForEach(categories, id: \.self) { category in
//                    CategoryTab(text: category, isSelected: selectedCategory == category)
//                        .onTapGesture {
//                            selectedCategory = category
//                            // Add action to reload news for this category
//                            print("Selected category: \(category)")
//                        }
//                }
//            }
//            .padding(.horizontal)
//            .frame(height: 40) // Height for the category bar
//        }
//        .background(Color.black) // Match dark background
//    }
//}
//
//// NEW: Individual Category Tab
//struct CategoryTab: View {
//    let text: String
//    var isSelected: Bool
//
//    var body: some View {
//        VStack(spacing: 4) {
//            Text(text)
//                .font(.subheadline)
//                .fontWeight(.medium)
//                .foregroundColor(isSelected ? .accentColor : .gray) // Highlight selected
//
//            if isSelected {
//                RoundedRectangle(cornerRadius: 1.5)
//                    .frame(height: 3)
//                    .foregroundColor(.accentColor)
//                    .padding(.horizontal, 4) // Make indicator slightly narrower than text
//            } else {
//                Color.clear.frame(height: 3) // Keep space consistent
//            }
//        }
//    }
//}
//
//// NEW: Related Story Card (for horizontal scroll)
//struct RelatedStoryCardView: View {
//    let relatedArticle: RelatedArticle
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 6) {
//            HStack(spacing: 6) {
//                Image(relatedArticle.source.logoName) // Replace with actual image
//                    .resizable()
//                    .frame(width: 16, height: 16)
//                    .cornerRadius(3)
//                Text(relatedArticle.source.name)
//                    .font(.caption)
//                    .fontWeight(.medium)
//                    .foregroundColor(.gray)
//            }
//
//            Text(relatedArticle.headline)
//                .font(.footnote) // Smaller font for related headlines
//                .lineLimit(3)
//
//             HStack {
//                Text(relatedArticle.timeAgo)
//                    .font(.caption2) // Even smaller time
//                    .foregroundColor(.gray)
//                Spacer()
//                Image(systemName: "ellipsis")
//                    .font(.caption) // Smaller icon
//                    .foregroundColor(.gray)
//            }
//        }
//        .padding(10) // Padding inside the card
//        .frame(width: 180) // Fixed width for horizontal scrolling items
//        .background(Color.secondary.opacity(0.2)) // Distinct background for related cards
//        .cornerRadius(8)
//    }
//}
//
//// NEW: Full Coverage Button
//struct FullCoverageButton: View {
//    var body: some View {
//        Button(action: {
//            // Action for Full Coverage
//            print("Full Coverage tapped")
//        }) {
//            HStack(spacing: 8) {
//                Image(systemName: "doc.text.image") // Icon from screenshot
//                    .font(.callout)
//                Text("Full Coverage of this story")
//                    .font(.subheadline)
//                    .fontWeight(.medium)
//            }
//            .foregroundColor(.white) // Text color on button
//            .padding(.vertical, 10)
//            .padding(.horizontal, 16)
//            .frame(maxWidth: .infinity, alignment: .center) // Center horizontally
//            .background(Color.secondary.opacity(0.3)) // Background color of button
//            .cornerRadius(20)
//        }
//        .padding(.horizontal) // Padding around the button
//        .padding(.vertical, 8) // Space above/below button
//    }
//}
//
//// MODIFIED: Main Story Card structure for Headlines
//struct HeadlineStoryBlockView: View {
//    let article: HeadlineArticle
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 0) { // Reduced main spacing
//            // Image
//            Image(article.imageName) // Replace with actual image loading
//                .resizable()
//                .aspectRatio(contentMode: .fill)
//                .frame(height: 200)
//                .clipped()
//                .cornerRadius(0) // No corner radius edge-to-edge
//                .padding(.bottom, 12)
//
//            // Source & Headline section
//            VStack(alignment: .leading, spacing: 6) {
//                HStack(spacing: 6) {
//                    Image(article.source.logoName)
//                        .resizable()
//                        .frame(width: 20, height: 20)
//                        .cornerRadius(4)
//                    Text(article.source.name)
//                        .font(.caption)
//                        .fontWeight(.medium)
//                        .foregroundColor(.gray)
//                }
//
//                Text(article.headline)
//                    .font(.title3)
//                    .fontWeight(.semibold)
//                    .lineLimit(3)
//
//                HStack {
//                    Text(article.timeAgo)
//                        .font(.caption)
//                        .foregroundColor(.gray)
//                    Spacer()
//                    Image(systemName: "ellipsis") // Options icon for main story
//                        .font(.callout)
//                        .foregroundColor(.gray)
//                }
//            }
//            .padding(.horizontal) // Add horizontal padding for text content
//            .padding(.bottom, 16) // Space before related stories
//
//
//            // Related Stories Horizontal Scroll
//            if !article.relatedArticles.isEmpty {
//                ScrollView(.horizontal, showsIndicators: false) {
//                    HStack(spacing: 12) {
//                        ForEach(article.relatedArticles) { related in
//                            RelatedStoryCardView(relatedArticle: related)
//                        }
//                    }
//                    .padding(.horizontal) // Padding for the scroll content
//                    .padding(.bottom, 8) // Space after related stories
//                }
//                .frame(height: 120) // Constrain height of related stories section
//            }
//
//            // Full Coverage Button
//            FullCoverageButton()
//
//            Divider()
//                .padding(.top, 12) // Space before divider
//        }
//        .padding(.bottom) // Space after the entire block
//    }
//}
//
//// --- Main Content View (Renamed and Updated for Headlines) ---
//
//struct HeadlinesView: View {
//     @State private var currentTab: Int = 1 // Default to Headlines tab
//
//    // Placeholder Data (Needs updating for Headlines structure)
//     let headlineStories = [
//          HeadlineArticle(
//               category: "Latest",
//               source: NewsSource(name: "The Associated Press", logoName: "ap_logo"),
//               headline: "Trump says he’s considering ways to serve a third term as president",
//               imageName: "trump_small_ap", // Use appropriate image
//               timeAgo: "1 hour ago",
//               relatedArticles: [
//                    RelatedArticle(source: NewsSource(name: "CNN", logoName: "cnn_logo"), headline: "Trump says ‘there are methods’ for seeking a third term, adding that he’s ‘not joking’", timeAgo: "2 hours ago"),
//                    RelatedArticle(source: NewsSource(name: "Reuters", logoName: "reuters_logo"), headline: "Analysis: Trump's third term comments stir constitutional debate", timeAgo: "45 mins ago"),
//                     RelatedArticle(source: NewsSource(name: "Fox News", logoName: "fox_logo"), headline: "Supporters cheer as Trump hints at extended presidency", timeAgo: "1 hour ago")
//               ]
//          ),
//          HeadlineArticle(
//                category: "Latest", // Or another category
//                source: NewsSource(name: "The New York Times", logoName: "nyt_logo"),
//                headline: "Biden Administration Announces New Sanctions Amid Global Tensions",
//                imageName: "biden_large", // Placeholder image name
//                timeAgo: "3 hours ago",
//                relatedArticles: [
//                     RelatedArticle(source: NewsSource(name: "BBC News", logoName: "bbc_logo"), headline: "Global markets react to latest round of U.S. sanctions", timeAgo: "4 hours ago"),
//                     RelatedArticle(source: NewsSource(name: "Wall Street Journal", logoName: "wsj_logo"), headline: "Economic impact of new sanctions assessed by experts", timeAgo: "2 hours ago")
//                ]
//           )
//        // Add more headline articles...
//    ]
//
//    var body: some View {
//        VStack(spacing: 0) {
//            TopBarView(title: "Headlines") // Pass the title
//            CategorySelectorView()
//
//            ScrollView {
//                VStack(spacing: 0) { // No spacing between story blocks inherently
//                    ForEach(headlineStories) { article in
//                         // TODO: Filter articles based on selected category from CategorySelectorView
//                         HeadlineStoryBlockView(article: article)
//                    }
//                }
//            }
//            .background(Color.black) // Ensure scroll view background is black
//
//            Spacer(minLength: 0)
//
//            TabBarView(selectedTab: $currentTab) // Pass binding for selection
//        }
//        .background(Color.black.ignoresSafeArea())
//        .foregroundColor(.white)
//        .ignoresSafeArea(.keyboard)
//    }
//}
//
//// --- Placeholder Image Assets ---
//// Add needed assets: "profile_placeholder", "ap_logo", "trump_small_ap",
//// "cnn_logo", "reuters_logo", "fox_logo", "nyt_logo", "biden_large", "bbc_logo", "wsj_logo"
//
//
//// --- Preview ---
//
//#Preview {
//    HeadlinesView()
//       .preferredColorScheme(.dark)
//        // You might need to provide dummy data or mock services for a proper preview
//        // depending on how data fetching is implemented.
//       .tint(.blue) // Set accent color similar to screenshot
//}
