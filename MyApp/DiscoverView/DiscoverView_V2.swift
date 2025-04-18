//
//  DiscoverView_V2.swift
//  MyApp
//
//  Created by Cong Le on 4/17/25.
//

import SwiftUI

// MARK: - Data Model (No changes needed from previous)

struct Assistant: Identifiable, Hashable { // Add Hashable for NavigationLink value
    let id = UUID()
    let title: String
    let authorIconName: String
    let authorName: String
    let date: String
    let description: String
    let tagIconName: String
    let tagText: String
    let bannerGradient: Gradient
    let bannerIconName: String

    // Sample Data (Replace with actual data)
    static let sampleData: [Assistant] = [
        // ... (Keep the same sample data as before)
         Assistant(
            title: "学术论文综述专家",
            authorIconName: "person.circle.fill",
            authorName: "Le",
            date: "2025-03-11",
            description: "擅长高质量文献检索与分析的学术研究助手",
            tagIconName: "graduationcap.fill",
            tagText: "Academic",
            bannerGradient: Gradient(colors: [Color.green.opacity(0.8), Color.cyan.opacity(0.6)]),
            bannerIconName: "My-meme-heineken"
        ),
        Assistant(
            title: "Cron Expression Assistant",
            authorIconName: "moonphase.waning.crescent",
            authorName: "Nguyen",
            date: "2025-02-17",
            description: "Crontab Expression Generator",
            tagIconName: "terminal.fill",
            tagText: "Programming",
            bannerGradient: Gradient(colors: [Color.pink.opacity(0.7), Color.purple.opacity(0.8)]),
            bannerIconName: "My-meme-microphone"
        ),
        Assistant(
            title: "Xiao Zhi French Translation As...",
            authorIconName: "globe.europe.africa.fill",
            authorName: "Khoa",
            date: "2025-02-10",
            description: "A friendly guide for translation & exploration.",
            tagIconName: "character.bubble.fill",
            tagText: "Language",
            bannerGradient: Gradient(colors: [Color.blue.opacity(0.8), Color.red.opacity(0.7)]),
            bannerIconName: "My-meme-red-wine-glass"
        )
    ]
}

// MARK: - Main Content View (Tab Structure)

struct ContentView: View {
    @State private var selectedTab = 1 // Discover tab is initially selected
    @State private var isShowingSideMenu = false
    @State private var isShowingSearchView = false

    init() {
        // --- Appearance Setup ---
        // Tab Bar
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor(Color(white: 0.1))
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance // For large titles
        UITabBar.appearance().unselectedItemTintColor = UIColor.gray

        // Navigation Bar
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.backgroundColor = UIColor.black
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]

        // Assign appearance to standard, compact, and scroll edge states
        UINavigationBar.appearance().standardAppearance = navBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
        UINavigationBar.appearance().compactAppearance = navBarAppearance // For smaller nav bar when scrolling

        // Optional: Set button colors if needed globally
        UINavigationBar.appearance().tintColor = .yellow
    }

    var body: some View {
        // Use NavigationStack for programmatic navigation if needed later,
        // but NavigationView works fine for simple link-based navigation here.
        NavigationView {
            TabView(selection: $selectedTab) {
                // --- Chat Tab ---
                ChatView() // Replace placeholder
                    .tabItem { Label("Chat", systemImage: "message") }
                    .tag(0)

                // --- Discover Tab ---
                DiscoverView(assistants: Assistant.sampleData)
                    .tabItem { Label("Discover", systemImage: "safari") } // Use actual icon
                    .tag(1)

                // --- Me Tab ---
                ProfileView() // Replace placeholder
                    .tabItem { Label("Me", systemImage: "person") }
                    .tag(2)
            }
            // Navigation Bar Configuration
            .navigationTitle(navigationTitle) // Dynamic title based on tab
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.black, for: .navigationBar) // Keep black background
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar) // Ensures system items are white
            .navigationBarItems(
                leading: Button {
                    isShowingSideMenu = true // Show side menu sheet
                } label: {
                    Image(systemName: "line.3.horizontal")
                        .foregroundColor(.white)
                },
                trailing: Button {
                    isShowingSearchView = true // Show search sheet
                } label: {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.white)
                }
            )
            // --- Modal Sheets ---
            .sheet(isPresented: $isShowingSideMenu) {
                SideMenuView() // Present the Side Menu View
            }
            .sheet(isPresented: $isShowingSearchView) {
                SearchView() // Present the Search View
            }
        }
        .accentColor(.yellow) // Tint for selected tab item & nav links if not styled otherwise
    }

    // Helper to determine navigation title based on selected tab
    private var navigationTitle: String {
        switch selectedTab {
        case 0: return "Chat"
        case 1: return "Home" // As per screenshot for Discover tab
        case 2: return "Profile"
        default: return "App"
        }
    }
}

// MARK: - Placeholder Views for Tabs

struct ChatView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            Text("Chat Functionality Here")
                .foregroundColor(.white)
        }
        // To make it navigable FROM (if needed), embed in Nav Stack or Nav View
        // For now, it's just the content of the tab.
    }
}

struct ProfileView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            Text("User Profile / Settings Here")
                .foregroundColor(.white)
        }
    }
}

// MARK: - Discover View (Handles Navigation)

struct DiscoverView: View {
    let assistants: [Assistant]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                // --- Featured Assistants Header ---
                HStack {
                    Text("Featured Assistants")
                        .font(.title2)
                        .fontWeight(.bold)
                    Spacer()
                    // --- NavigationLink for "Discover More" ---
                    NavigationLink(destination: AllAssistantsView()) { // Navigate to All Assistants view
                         HStack(spacing: 4) {
                              Text("Discover More")
                                  .font(.subheadline)
                              Image(systemName: "chevron.right")
                                  .font(.caption.weight(.bold))
                         }
                         .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal)
                .padding(.top)

                // --- Assistant Cards ---
                ForEach(assistants) { assistant in
                    // --- NavigationLink for each Card ---
                    NavigationLink(destination: AssistantDetailView(assistant: assistant)) {
                        AssistantCardView(assistant: assistant)
                    }
                    // Apply plain button style to remove default NavigationLink styling (blue tint)
                    .buttonStyle(.plain)
                    .padding(.horizontal) // Padding for each card link area
                }
                .padding(.bottom)
            }
        }
        .background(Color.black.ignoresSafeArea())
        .foregroundColor(.white)
    }
}

// MARK: - Assistant Card View (Mostly Styling - No major changes)

struct AssistantCardView: View {
    let assistant: Assistant
    let cardCornerRadius: CGFloat = 15
    let bannerHeight: CGFloat = 85

    var body: some View {
         ZStack(alignment: .topTrailing) {
             // --- Main Content ---
             VStack(alignment: .leading, spacing: 8) {
                 Spacer().frame(height: bannerHeight * 0.7)
                 Text(assistant.title).font(.headline).fontWeight(.semibold).lineLimit(1)
                 HStack(spacing: 6) {
                     Image(systemName: assistant.authorIconName)
                         .resizable().scaledToFit().frame(width: 18, height: 18)
                         .foregroundColor(.gray).clipShape(Circle())
                     Text(assistant.authorName)
                     Text(assistant.date)
                 }
                 .font(.caption).foregroundColor(.gray)
                 Text(assistant.description).font(.subheadline).foregroundColor(.secondary).lineLimit(2).fixedSize(horizontal: false, vertical: true)
                 HStack(spacing: 5) {
                     Image(systemName: assistant.tagIconName).font(.caption2)
                     Text(assistant.tagText)
                 }
                 .font(.caption).padding(.horizontal, 8).padding(.vertical, 4)
                 .background(Color.white.opacity(0.15)).cornerRadius(5)
                 .foregroundColor(Color.white.opacity(0.8))
                 Spacer()
             }
             .padding(EdgeInsets(top: 10, leading: 15, bottom: 15, trailing: 15))
             .frame(maxWidth: .infinity, alignment: .leading)
             .background(Color(white: 0.12))
             .cornerRadius(cardCornerRadius)

             // --- Banner and Icon Layer ---
             ZStack(alignment: .bottomTrailing) {
                  LinearGradient(gradient: assistant.bannerGradient, startPoint: .leading, endPoint: .trailing)
                       .frame(height: bannerHeight)
                       .clipShape(.rect(topLeadingRadius: cardCornerRadius, topTrailingRadius: cardCornerRadius))
                   Image(assistant.bannerIconName)
                       .resizable().aspectRatio(contentMode: .fit).frame(width: 55, height: 55)
                       .shadow(color: .black.opacity(0.3) ,radius: 4, x: 0, y: 2)
                       .offset(x: -15, y: 15)
             }
              .frame(height: bannerHeight)
              .allowsHitTesting(false)

        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

// MARK: - Destination & Modal Views (Placeholders)

struct AssistantDetailView: View {
    let assistant: Assistant

    var body: some View {
        ScrollView { // Allow content to scroll if it gets long
            VStack(alignment: .leading, spacing: 20) {
                // Re-use banner or create a new header
                 LinearGradient(gradient: assistant.bannerGradient, startPoint: .leading, endPoint: .trailing)
                    .frame(height: 150) // Larger banner for detail
                    .overlay(
                        Image(assistant.bannerIconName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 100)
                            .shadow(radius: 5)
                    )

                VStack(alignment: .leading, spacing: 10) {
                    Text(assistant.title)
                       .font(.largeTitle)
                       .fontWeight(.bold)

                    HStack {
                       Image(systemName: assistant.authorIconName)
                           .foregroundColor(.gray).clipShape(Circle())
                       Text("By \(assistant.authorName)")
                       Spacer()
                       Text(assistant.date)
                    }.font(.subheadline).foregroundColor(.gray)

                    Divider()

                    Text("Description")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.top)

                    Text(assistant.description)
                        .font(.body)

                    // Add more details as needed (e.g., usage examples, related assistants)
                    Text("Tag: \(assistant.tagText)")
                        .font(.caption)
                        .padding(5)
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(5)

                    Spacer() // Pushes content up

                }
                .padding() // Padding around the text content

            }
        }
        .background(Color.black.ignoresSafeArea()) // Background for the detail view
        .foregroundColor(.white) // Default text color
        .navigationTitle(assistant.title) // Show assistant title in Nav Bar
        .navigationBarTitleDisplayMode(.inline) // Keep inline style consistency
    }
}

struct AllAssistantsView: View {
    var body: some View {
        ZStack {
             Color.black.ignoresSafeArea()
             Text("List of All Assistants would go here.")
                 .foregroundColor(.white)
        }
        .navigationTitle("All Assistants")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SideMenuView: View {
    @Environment(\.dismiss) var dismiss // To close the sheet

    var body: some View {
        NavigationView { // Add NavigationView for a title bar in the sheet
             ZStack {
                Color(white: 0.08).ignoresSafeArea() // Slightly lighter dark background for sheet
                 VStack(alignment: .leading, spacing: 20) {
                     Text("Settings").font(.title3)
                     Text("Profile").font(.title3)
                     Text("About").font(.title3)
                     Spacer()
                     Button("Logout (Placeholder)") {
                         // Add logout logic
                         dismiss() // Close sheet on action
                     }.foregroundColor(.red)
                 }
                 .padding()
                 .foregroundColor(.white)
             }
             .navigationTitle("Menu")
             .navigationBarTitleDisplayMode(.inline)
             .toolbar {
                 ToolbarItem(placement: .navigationBarTrailing) {
                     Button("Done") {
                         dismiss() // Close the sheet
                     }
                     .foregroundColor(.yellow) // Match accent
                 }
             }
             .toolbarBackground(.visible, for: .navigationBar) // Ensure toolbar is visible
             .toolbarBackground(Color(white: 0.15), for: .navigationBar) // Sheet navbar color
             .toolbarColorScheme(.dark, for: .navigationBar)
        }

    }
}

struct SearchView: View {
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""

    var body: some View {
         NavigationView {
             ZStack {
                 Color(white: 0.08).ignoresSafeArea()
                 VStack {
                     Text("Implement Search UI Here")
                         .foregroundColor(.gray)
                         .padding()

                     // Add a basic search bar if needed immediately
                     // Note: Real search requires more logic (filtering data)
                     TextField("Search assistants...", text: $searchText)
                         .padding(10)
                         .background(Color(white: 0.2))
                         .cornerRadius(8)
                         .foregroundColor(.white)
                         .padding(.horizontal)

                     Spacer()
                 }
                 .foregroundColor(.white)
             }
             .navigationTitle("Search Assistants")
             .navigationBarTitleDisplayMode(.inline)
             .toolbar {
                  ToolbarItem(placement: .navigationBarTrailing) {
                     Button("Cancel") {
                         dismiss()
                     }
                     .foregroundColor(.yellow)
                  }
             }
             .toolbarBackground(.visible, for: .navigationBar)
             .toolbarBackground(Color(white: 0.15), for: .navigationBar)
             .toolbarColorScheme(.dark, for: .navigationBar)
         }
    }
}

// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}
