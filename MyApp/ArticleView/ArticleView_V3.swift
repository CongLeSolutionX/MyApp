//
//  ArticleView_V3.swift
//  MyApp
//
//  Created by Cong Le on 4/13/25.
//

import SwiftUI

struct Article_ContentView: View {
    var body: some View {
        // Apply dark mode preference for the entire UI
        TabView {
            ArticleView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            Text("Search Placeholder")
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }

            Text("Bookmarks Placeholder")
                .tabItem {
                    Label("Bookmarks", systemImage: "bookmark.fill")
                }

            Text("Profile Placeholder")
                .tabItem {
                    Label("Profile", systemImage: "person.circle.fill")
                }
        }
        .preferredColorScheme(.dark) // Enforce dark mode like the screenshot
    }
}

struct ArticleView: View {
    // Sample text content matching the style
    let subtitle = "Charting a clear path: From disruption to smooth skies — an illustration created by the author using DALL·E 3 and GPT-4o assistance."
    let title = "The SwiftUI Navigation Airspace: Calm or Chaos?"
    let paragraph1 = "Building a new feature in your app often feels like scheduling a flight at a small regional airport. With only a handful of runways and a few planes to manage, everything runs like clockwork."
    let paragraph2 = #"Navigation in SwiftUI mirrors this simplicity when building lightweight apps: just a few `NavigationDestination` closures, and all the "flights" (views) land safely where they're supposed to."#
    let paragraph3 = "But as your app expands, so does your..." // Truncated

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Placeholder for the top image
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 200)
                        .overlay(
                            Image(systemName: "photo.fill") // Placeholder symbol
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.gray)
                        )

                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.horizontal)

                    Text(title)
                        .font(.system(.largeTitle, design: .serif, weight: .bold)) // Using Serif for title
                        .padding(.horizontal)

                    // Use AttributedString for potential code formatting
                    Text(makeAttributedString(from: paragraph1))
                        .font(.system(.body, design: .serif)) // Using Serif Design
                        .lineSpacing(6)
                        .padding(.horizontal)

                    Text(makeAttributedString(from: paragraph2))
                        .font(.system(.body, design: .serif)) // Using Serif Design
                        .lineSpacing(6)
                        .padding(.horizontal)
                    
                    Text(makeAttributedString(from: paragraph3))
                        .font(.system(.body, design: .serif)) // Using Serif Design
                        .lineSpacing(6)
                        .padding(.horizontal)

                    Spacer(minLength: 20) // Add space before interaction bar

                    // --- Bottom Interaction Bar ---
                    // Placed inside the scroll view for simplicity.
                    // A true floating bar would require ZStack/overlay.
                    HStack(spacing: 20) {
                        Spacer() // Push content towards the center/right
                        HStack(spacing: 5) {
                            Image(systemName: "hands.clap")
                                .foregroundColor(.gray)
                            Text("48")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        HStack(spacing: 5) {
                            Image(systemName: "bubble.left")
                                .foregroundColor(.gray)
                            Text("2")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        Image(systemName: "bookmark")
                            .foregroundColor(.gray)
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(.gray)
                        Spacer() // Balance the spacing
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 20)
                    .background(Color.gray.opacity(0.2))
                    .clipShape(Capsule())
                    .padding(.horizontal) // Padding for the capsule itself
                    .padding(.bottom) // Space below the capsule
                    
                }
            }
            // Customize the Navigation Bar appearance
            .navigationBarTitleDisplayMode(.inline) // Keep title area small
            .toolbar {
                // Leading Button (Back Arrow)
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        // Action for back button
                        print("Back button tapped")
                    } label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white) // Ensure visibility in dark mode
                    }
                }

                // Trailing Buttons (Play and Ellipsis)
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Button {
                            // Action for play button
                            print("Play button tapped")
                        } label: {
                            Image(systemName: "play.circle")
                                .foregroundColor(.white)
                        }
                        Button {
                            // Action for ellipsis button
                            print("More options tapped")
                        } label: {
                            Image(systemName: "ellipsis")
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            .background(Color.black) // Set background for the content area if needed
        }
    }
    
    // Helper function to create AttributedString, enabling potential formatting
    func makeAttributedString(from string: String) -> AttributedString {
        // Basic implementation, can be extended to parse markdown or specific tags
        if let range = string.range(of: "`NavigationDestination`") {
            var attributedString = AttributedString(string)
            if let swiftRange = AttributedString.Range(range, in: attributedString) {
                 attributedString[swiftRange].foregroundColor = .yellow // Example highlight
                 attributedString[swiftRange].font = .system(.body, design: .monospaced)
                 attributedString[swiftRange].backgroundColor = .gray.opacity(0.3)
            }
             return attributedString

        } else {
            return AttributedString(string)
        }
    }
}

#Preview {
    Article_ContentView()
}
