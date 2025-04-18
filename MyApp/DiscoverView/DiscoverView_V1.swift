//
//  DiscoverView_V1.swift
//  MyApp
//
//  Created by Cong Le on 4/17/25.
//

import SwiftUI

// MARK: - Data Model

struct Assistant: Identifiable {
    let id = UUID()
    let title: String
    let authorIconName: String // System name or asset name for author icon
    let authorName: String
    let date: String
    let description: String
    let tagIconName: String // System name for tag icon
    let tagText: String
    let bannerGradient: Gradient
    let bannerIconName: String // Asset name for the banner icon (e.g., "icon_academic", "icon_cron", "icon_french")

    // Sample Data (Replace with actual data)
    static let sampleData: [Assistant] = [
        Assistant(
            title: "学术论文综述专家",
            authorIconName: "person.circle.fill", // Placeholder
            authorName: "arvinxx",
            date: "2025-03-11",
            description: "擅长高质量文献检索与分析的学术研究助手",
            tagIconName: "graduationcap.fill", // Placeholder SF Symbol
            tagText: "Academic",
            bannerGradient: Gradient(colors: [Color.green.opacity(0.8), Color.cyan.opacity(0.6)]), // Example Gradient
            bannerIconName: "icon_academic" // Needs an image asset named "icon_academic"
        ),
        Assistant(
            title: "Cron Expression Assistant",
            authorIconName: "moonphase.waning.crescent", // Placeholder
            authorName: "edgesider",
            date: "2025-02-17",
            description: "Crontab Expression Generator",
            tagIconName: "terminal.fill", // Placeholder SF Symbol
            tagText: "Programming",
            bannerGradient: Gradient(colors: [Color.pink.opacity(0.7), Color.purple.opacity(0.8)]), // Example Gradient
            bannerIconName: "icon_cron"       // Needs an image asset named "icon_cron"
        ),
        Assistant(
            title: "Xiao Zhi French Translation As...",
            authorIconName: "globe.europe.africa.fill", // Placeholder
            authorName: "WeR-Best",
            date: "2025-02-10",
            description: "A friendly guide for translation & exploration.", // Added example description
            tagIconName: "character.bubble.fill", // Placeholder SF Symbol
            tagText: "Language", // Example tag
            bannerGradient: Gradient(colors: [Color.blue.opacity(0.8), Color.red.opacity(0.7)]), // Example Gradient
            bannerIconName: "icon_french"     // Needs an image asset named "icon_french"
        )
    ]
}

// MARK: - Main Content View (Tab Structure)

struct ContentView: View {
    @State private var selectedTab = 1 // Discover tab is initially selected

    init() {
        // Customize TabView appearance globally
        UITabBar.appearance().backgroundColor = UIColor(Color(white: 0.1)) // Dark background for tab bar
        UITabBar.appearance().unselectedItemTintColor = UIColor.gray // Color for unselected items
        // Customize Navigation Bar appearance globally
         let appearance = UINavigationBarAppearance()
         appearance.configureWithOpaqueBackground()
         appearance.backgroundColor = UIColor.black // Black background for nav bar
         appearance.titleTextAttributes = [.foregroundColor: UIColor.white] // White title
         appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white] // White large title (if used)

         UINavigationBar.appearance().standardAppearance = appearance
         UINavigationBar.appearance().scrollEdgeAppearance = appearance
         UINavigationBar.appearance().compactAppearance = appearance // For smaller nav bar

    }

    var body: some View {
        NavigationView {
            TabView(selection: $selectedTab) {
                // --- Chat Tab ---
                Text("Chat View Placeholder")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.ignoresSafeArea())
                    .foregroundColor(.white)
                    .tabItem {
                        Label("Chat", systemImage: "message")
                    }
                    .tag(0)

                // --- Discover Tab ---
                DiscoverView(assistants: Assistant.sampleData)
                    .tabItem {
                        Label("Discover", systemImage: "safari") // Using safari as placeholder
                    }
                    .tag(1)

                // --- Me Tab ---
                Text("Me View Placeholder")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.ignoresSafeArea())
                    .foregroundColor(.white)
                    .tabItem {
                        Label("Me", systemImage: "person")
                    }
                    .tag(2)
            }
            // Use .inline for the title style shown in screenshot
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button {
                    // Hamburger menu action
                } label: {
                    Image(systemName: "line.3.horizontal")
                        .foregroundColor(.white)
                },
                trailing: Button{
                    // Search action
                } label: {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.white)
                }
            )
             // Ensure nav bar background stays black even during scroll
             .toolbarBackground(.black, for: .navigationBar)
             .toolbarBackground(.visible, for: .navigationBar)
             .toolbarColorScheme(.dark, for: .navigationBar) // Ensure system items are white
        }
        .accentColor(.yellow) // Sets the tint for the selected tab item
    }
}

// MARK: - Discover View

struct DiscoverView: View {
    let assistants: [Assistant]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) { // Reduced spacing slightly
                // --- Featured Assistants Header ---
                HStack {
                    Text("Featured Assistants")
                        .font(.title2)
                        .fontWeight(.bold)
                    Spacer()
                    Button {
                        // Discover More Action
                    } label: {
                       HStack(spacing: 4) {
                            Text("Discover More")
                                .font(.subheadline)
                            Image(systemName: "chevron.right")
                                .font(.caption.weight(.bold)) // Make chevron bolder/smaller
                       }
                       .foregroundColor(.gray) // Grayish color for the link
                    }
                }
                .padding(.horizontal)
                .padding(.top) // Add padding at the top

                // --- Assistant Cards ---
                ForEach(assistants) { assistant in
                    AssistantCardView(assistant: assistant)
                        .padding(.horizontal) // Padding for each card
                }
                .padding(.bottom) // Padding at the bottom of the list
            }
        }
        .background(Color.black.ignoresSafeArea()) // Main background for the discover view
        .foregroundColor(.white) // Default text color for this view
    }
}

// MARK: - Assistant Card View

struct AssistantCardView: View {
    let assistant: Assistant
    let cardCornerRadius: CGFloat = 15
    let bannerHeight: CGFloat = 85 // Adjusted banner height

    var body: some View {
        ZStack(alignment: .topTrailing) { // Use ZStack for layering banner/icon

             // --- Main Content ---
             VStack(alignment: .leading, spacing: 8) { // Adjusted spacing
                 // Spacer to push content below the banner area
                 Spacer()
                     .frame(height: bannerHeight * 0.7) // Adjust spacer height

                 Text(assistant.title)
                     .font(.headline)
                     .fontWeight(.semibold) // Slightly less bold
                     .lineLimit(1) // Ensure title is single line

                 HStack(spacing: 6) {
                     // Use system name unless it's a custom asset
                     Image(systemName: assistant.authorIconName)
                         .resizable()
                         .scaledToFit()
                         .frame(width: 18, height: 18)
                         .foregroundColor(.gray) // Match screenshot tone
                         .clipShape(Circle()) // Assuming default icons might need clipping

                     Text(assistant.authorName)
                     Text(assistant.date)
                 }
                 .font(.caption)
                 .foregroundColor(.gray) // Gray text for author/date

                 Text(assistant.description)
                     .font(.subheadline)
                     .foregroundColor(.secondary) // Lighter gray for description
                     .lineLimit(2) // Limit description lines
                     .fixedSize(horizontal: false, vertical: true) // Allow text wrap

                 HStack(spacing: 5) {
                     Image(systemName: assistant.tagIconName)
                         .font(.caption2) // Make icon smaller
                     Text(assistant.tagText)
                 }
                 .font(.caption) // Slightly larger tag text
                 .padding(.horizontal, 8)
                 .padding(.vertical, 4)
                 .background(Color.white.opacity(0.15)) // Darker, translucent background for tag
                 .cornerRadius(5)
                 .foregroundColor(Color.white.opacity(0.8)) // Off-white tag text

                 Spacer() // Add spacer at the bottom if needed for consistent card height
             }
             .padding(EdgeInsets(top: 10, leading: 15, bottom: 15, trailing: 15)) // Fine-tuned padding
             .frame(maxWidth: .infinity, alignment: .leading)
             .background(Color(white: 0.12)) // Slightly different dark background for card
             .cornerRadius(cardCornerRadius)

             // --- Banner and Icon Layer ---
             ZStack(alignment: .bottomTrailing) {
                  // Banner Gradient
                  LinearGradient(gradient: assistant.bannerGradient, startPoint: .leading, endPoint: .trailing)
                       .frame(height: bannerHeight)
                       // Clip only *top* corners for the banner gradient visual
                       .clipShape(
                            .rect(
                                topLeadingRadius: cardCornerRadius,
                                topTrailingRadius: cardCornerRadius
                            )
                       )

                   // Banner Icon (Loaded from Assets)
                   Image(assistant.bannerIconName) // Assumes you have image assets with these names
                       .resizable()
                       .aspectRatio(contentMode: .fit)
                       .frame(width: 55, height: 55) // Adjusted icon size
                       .shadow(color: .black.opacity(0.3) ,radius: 4, x: 0, y: 2) // Subtle shadow
                       // Offset to make it hang over the edge
                       .offset(x: -15, y: 15)

             }
              .frame(height: bannerHeight) // Ensure ZStack matches banner height
              .allowsHitTesting(false) // Banner shouldn't block interaction with content below

        }
        .fixedSize(horizontal: false, vertical: true) // Allow card height to adapt to content
    }
}

// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark) // Ensure preview is in dark mode
    }
}
