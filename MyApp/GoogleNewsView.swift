//
//  GoogleNewsView.swift
//  MyApp
//
//  Created by Cong Le on 3/30/25.
//

import SwiftUI

// --- Data Models (Placeholders) ---

struct NewsSource: Identifiable {
    let id = UUID()
    let name: String
    let logoName: String // Placeholder for image asset name
}

struct NewsArticle: Identifiable {
    let id = UUID()
    let source: NewsSource
    let headline: String
    let imageName: String // Placeholder for image asset name
    let timeAgo: String
    let isLargeCard: Bool // Differentiate card types
    let smallImageName: String? // Optional smaller image for list view
}

// --- Reusable Views ---

// Top Bar View
struct TopBarView: View {
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .font(.title2)

            Spacer()

            Text("Google News")
                .font(.title3)
                .fontWeight(.bold)

            Spacer()

            Image("profile_placeholder") // Replace with actual image loading
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.gray, lineWidth: 0.5)) // Optional border
        }
        .padding(.horizontal)
        .frame(height: 44) // Standard navigation bar-like height
    }
}

// Weather Widget View
struct WeatherWidget: View {
    var body: some View {
        HStack(spacing: 6) {
            Text("65°F")
                .fontWeight(.medium)
            Image(systemName: "cloud.sun.fill") // Example icon
                 .renderingMode(.original) // Use original colors if multi-colored
                 .font(.title3)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color.secondary.opacity(0.3)) // Semi-transparent background
        .cornerRadius(20)
    }
}

// Header Section View
struct HeaderView: View {
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Your briefing")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Text("Sunday, March 30") // Use actual date formatting
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
            WeatherWidget()
        }
        .padding(.horizontal)
        .padding(.top)
    }
}

// "Top stories" Link View
struct TopStoriesLinkView: View {
    var body: some View {
         Button(action: {
             // Action for tapping "Top stories"
             print("Top stories tapped")
         }) {
             HStack(spacing: 4) {
                 Text("Top stories")
                    .font(.headline)
                    .fontWeight(.medium)
                 Image(systemName: "chevron.right")
                     .font(.caption.weight(.bold))
             }
             .foregroundColor(.accentColor) // Use the app's accent color
         }
         .padding([.horizontal, .top])
         .padding(.bottom, 8) // Add some space before the news card
    }
}


// Large Main News Card View
struct MainNewsCardView: View {
    let article: NewsArticle

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(article.imageName) // Replace with actual image loading
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 200) // Adjust height as needed
                .clipped()
                .cornerRadius(10)
                .padding(.bottom, 4)

            HStack(spacing: 6) {
                Image(article.source.logoName) // Replace with actual image loading
                    .resizable()
                    .frame(width: 20, height: 20)
                    .cornerRadius(4) // Slight rounding for logos
                Text(article.source.name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.gray)
            }

            Text(article.headline)
                .font(.title3)
                .fontWeight(.semibold) // Slightly bolder headline
                .lineLimit(3) // Limit lines to prevent excessive height

            HStack {
                Text(article.timeAgo)
                    .font(.caption)
                    .foregroundColor(.gray)
                Spacer()
                // Using placeholder icons matching the screenshot style
                Image(systemName: "doc.text.image") // Placeholder for 'Full Coverage' or similar
                    .font(.callout)
                    .foregroundColor(.gray)
                Image(systemName: "ellipsis")
                    .font(.callout)
                    .foregroundColor(.gray)
            }
            .padding(.top, 2) // Add a little space above icons/time

            Divider()
                .padding(.top, 8) // Space before divider
        }
        .padding(.horizontal)
        .padding(.bottom) // Space after the card
    }
}

// Smaller News Card View for List Items
struct SmallNewsCardView: View {
    let article: NewsArticle

    var body: some View {
        VStack(spacing: 0) { // No spacing between HStack and Divider
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    // Source Row
                    HStack(spacing: 6) {
                        Image(article.source.logoName) // Replace with actual image loading
                            .resizable()
                            .frame(width: 16, height: 16)
                            .cornerRadius(3) // Smaller rounding
                        Text(article.source.name)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.gray)
                    }
                    // Headline
                    Text(article.headline)
                        .font(.headline)
                        .fontWeight(.regular) // Less bold than main card
                        .lineLimit(3)

                    // Meta Row (Time & Icons)
                    HStack {
                        Text(article.timeAgo)
                            .font(.caption)
                            .foregroundColor(.gray)
                        Spacer()
                        Image(systemName: "doc.text.image")
                            .font(.callout) // Slightly smaller icons
                            .foregroundColor(.gray)
                        Image(systemName: "ellipsis")
                            .font(.callout)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 2)
                }

                Spacer() // Pushes image to the right

                // Small Thumbnail Image
                Image(article.smallImageName ?? article.imageName) // Use specific small image if available
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 80) // Standard small image size
                    .clipped()
                    .cornerRadius(8)
            }
            .padding(.vertical, 12) // Padding within the card content
            .padding(.horizontal) // Padding within the card content

            Divider()
        }
    }
}


// Tab Bar Item View
struct TabBarItem: View {
    let icon: String
    let text: String
    var isSelected: Bool = false

    var body: some View {
        VStack(spacing: 2) {
             Image(systemName: icon)
                 .font(.system(size: 22)) // Adjust icon size
             Text(text)
                 .font(.caption2) // Smaller text for tab labels
        }
        .foregroundColor(isSelected ? Color.accentColor : Color.gray) // Highlight selected tab
        .frame(maxWidth: .infinity) // Allow items to expand equally
    }
}

// Tab Bar View
struct TabBarView: View {
    @State private var selectedTab: Int = 0 // State to track selection

    var body: some View {
        VStack(spacing: 0) {
             Divider() // Divider above the tab bar
             HStack {
                 TabBarItem(icon: "arrow.up.forward.app.fill", text: "For you", isSelected: selectedTab == 0)
                     .onTapGesture { selectedTab = 0 }

                 TabBarItem(icon: "globe", text: "Headlines", isSelected: selectedTab == 1)
                      .onTapGesture { selectedTab = 1 }

                 TabBarItem(icon: "star", text: "Following", isSelected: selectedTab == 2)
                      .onTapGesture { selectedTab = 2 }

                 TabBarItem(icon: "list.bullet.rectangle.portrait", text: "Newsstand", isSelected: selectedTab == 3)
                      .onTapGesture { selectedTab = 3 }
             }
             .frame(height: 50) // Standard tab bar height
             .padding(.bottom, 8) // Padding for home indicator area if needed
             .background(Color(UIColor.systemGray6).opacity(0.95).ignoresSafeArea(edges: .bottom)) // System-like background
        }
    }
}


// --- Main Content View ---

struct GoogleNewsView: View {

    // Placeholder Data
    let mainArticle = NewsArticle(
        source: NewsSource(name: "Al Jazeera English", logoName: "aljazeera_logo"),
        headline: "Trump ‘angry’ with Putin and threatens tariffs on Russian oil over Ukraine",
        imageName: "trump_large",
        timeAgo: "5h",
        isLargeCard: true,
        smallImageName: nil
    )

    let otherArticles = [
        NewsArticle(
            source: NewsSource(name: "The Associated Press", logoName: "ap_logo"),
            headline: "Trump says he’s considering ways to serve a third term as president",
            imageName: "trump_small_ap",
            timeAgo: "3h",
            isLargeCard: false,
            smallImageName: "trump_small_ap"
        ),
        NewsArticle(
            source: NewsSource(name: "The New York Times", logoName: "nyt_logo"),
            headline: "Trump’s U.S.A.I.D. Cuts Hobble Earthquake Response in Myanmar", // Example text
            imageName: "disaster_small_nyt",
            timeAgo: "2h",
            isLargeCard: false,
            smallImageName: "disaster_small_nyt"
        )
        // Add more articles...
    ]

    var body: some View {
        VStack(spacing: 0) {
            TopBarView()

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    HeaderView()
                    TopStoriesLinkView()
                    MainNewsCardView(article: mainArticle)

                    // List of smaller articles
                    ForEach(otherArticles) { article in
                        SmallNewsCardView(article: article)
                    }
                }
            }
             // Use .safeAreaInset to place the TabBar outside the ScrollView's content area
             // but still allow content to scroll underneath it.
             // This is often preferred over placing it directly in the VStack
             // after the ScrollView for better handling of safe areas.
             // However, for simplicity and direct structure match to screenshot,
             // placing it after the ScrollView in the main VStack works too.

            Spacer(minLength: 0) // Pushes TabBar to bottom if not using safeAreaInset

            TabBarView()
        }
        .background(Color.black.ignoresSafeArea()) // Dark mode background
        .foregroundColor(.white) // Default text color for dark mode
        .ignoresSafeArea(.keyboard) // Prevent keyboard overlaps
    }
}

// --- Placeholder Image Assets ---
// In a real project, add image assets named:
// "profile_placeholder.png", "aljazeera_logo.png", "trump_large.jpg",
// "ap_logo.png", "trump_small_ap.jpg", "nyt_logo.png", "disaster_small_nyt.jpg"
// For the preview to work visually, you might need to create dummy Color views
// or SF Symbols as placeholders if you don't add actual image assets.

extension Image {
    // Simple placeholder if image asset is missing (for preview)
    init(_ name: String) {
        // In a real app, you'd just use Image(name)
        // This is a workaround for #Preview without assets
        if UIImage(named: name) != nil {
            self.init(name)
        } else {
            // Provide a fallback SF Symbol or Color Rectangle
            switch name {
                case "profile_placeholder": self.init(systemName: "person.crop.circle.fill")
                case "aljazeera_logo", "ap_logo", "nyt_logo": self.init(systemName: "newspaper")
                case "trump_large", "trump_small_ap", "disaster_small_nyt": self.init(systemName: "photo")
                default: self.init(systemName: "questionmark.square.dashed")
            }
        }
    }
}


// --- Preview ---

#Preview {
    GoogleNewsView()
       .preferredColorScheme(.dark) // Preview in dark mode
}
