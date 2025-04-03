//
//  MessageView.swift
//  MyApp
//
//  Created by Cong Le on 4/2/25.
//

import SwiftUI

// MARK: - Data Models

struct FilterCategory: Identifiable {
    let id = UUID()
    let name: String
}

struct MessageThread: Identifiable {
    let id = UUID()
    let senderName: String
    let previewText: String
    let timestamp: String
    let imageName: String // Use system names or asset names
    let isSystemImage: Bool // Differentiate SF Symbols from asset images
    let secondaryImageName: String? // For composite avatars like Javier/Nizar
    let additionalInfo: String?
    let colorGradient: LinearGradient? // For custom avatars like Sunshine
}

// MARK: - Sample Data

let filterCategories = [
    FilterCategory(name: "All"),
    FilterCategory(name: "Hosting"),
    FilterCategory(name: "Traveling"),
    FilterCategory(name: "Superhost Ambassador")
]

let messageThreads = [
    MessageThread(senderName: "Javier", previewText: "Airbnb update: Reminder - Leave a review", timestamp: "1/21/24", imageName: "building.2", isSystemImage: true, secondaryImageName: "person.crop.circle.fill", additionalInfo: "Jan 7 – 21, 2024 · Marietta", colorGradient: nil),
    MessageThread(senderName: "Airbnb Support", previewText: "Message Javier", timestamp: "1/7/24", imageName: "airbnb.logo", isSystemImage: false, secondaryImageName: nil, additionalInfo: "Welcome", colorGradient: nil),
    MessageThread(senderName: "Airbnb Support", previewText: "Airbnb: This conversation closed because it...", timestamp: "1/5/24", imageName: "airbnb.logo", isSystemImage: false, secondaryImageName: nil, additionalInfo: "Closed", colorGradient: nil),
    MessageThread(senderName: "Nizar", previewText: "If you can't afford places because of the valu...", timestamp: "7/17/22", imageName: "house.fill", isSystemImage: true, secondaryImageName: "person.crop.circle.fill", additionalInfo: "Jul 15 – 16, 2022 · San Diego", colorGradient: nil),
    MessageThread(senderName: "Sunshine Property Management", previewText: "Hi! Just checking in to see if you need any ad...", timestamp: "5/24/22", imageName: "", isSystemImage: false, secondaryImageName: nil, additionalInfo: "Superhost Ambassador", colorGradient: LinearGradient(gradient: Gradient(colors: [.orange, .pink]), startPoint: .topLeading, endPoint: .bottomTrailing))
]

// MARK: - Reusable Views

struct AvatarView: View {
    let imageName: String
    let isSystemImage: Bool
    let secondaryImageName: String?
    let colorGradient: LinearGradient?
    let size: CGFloat = 50 // Reduced size slightly

    var body: some View {
        ZStack {
            if let gradient = colorGradient {
                // Custom gradient background with placeholder icon
                Circle()
                    .fill(gradient)
                    .frame(width: size, height: size)
                    .overlay(
                        Image(systemName: "photo.on.rectangle.angled") // Placeholder symbol
                            .foregroundColor(.white.opacity(0.7))
                            .font(.system(size: size * 0.4))
                    )
            } else {
                 // Standard Avatar logic
                Circle()
                    .fill(Color(.systemGray5)) // Background for system images or placeholders
                    .frame(width: size, height: size)

                if isSystemImage {
                    Image(systemName: imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: size * 0.5, height: size * 0.5)
                        .foregroundColor(Color(.darkGray))
                } else if imageName == "airbnb.logo" {
                    // Specific placeholder for Airbnb logo
                     Circle()
                        .fill(Color(.darkGray))
                        .frame(width: size, height: size)
                    Image(systemName: "house.lodge.fill") // Using an SF Symbol as placeholder
                        .resizable()
                        .scaledToFit()
                        .frame(width: size * 0.5, height: size * 0.5)
                        .foregroundColor(.white)

                } else {
                    // Placeholder for actual images if using assets
                     Image(systemName: "person.fill") // Generic person placeholder
                         .resizable()
                         .scaledToFit()
                         .frame(width: size * 0.5, height: size * 0.5)
                         .foregroundColor(Color(.darkGray))

                }

                 // Overlay secondary image if provided (for composite avatars)
                if let secondaryName = secondaryImageName {
                    Image(systemName: secondaryName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: size * 0.55, height: size * 0.55) // Slightly larger overlay
                        .background(Circle().fill(Color(.systemBackground))) // Background to lift it
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color(.systemBackground), lineWidth: 2)) // Border
                        .shadow(radius: 1)
                        .offset(x: size * 0.3, y: size * 0.3) // Position offset
                }
            }
        }
        .frame(width: size, height: size)
    }
}

struct FilterChipView: View {
    let category: FilterCategory
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(category.name)
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.black : Color(.systemGray5))
                .foregroundColor(isSelected ? .white : .black)
                .clipShape(Capsule())
        }
    }
}

struct MessageRowView: View {
    let thread: MessageThread

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            AvatarView(
                imageName: thread.imageName,
                isSystemImage: thread.isSystemImage,
                secondaryImageName: thread.secondaryImageName,
                colorGradient: thread.colorGradient
            )

            VStack(alignment: .leading, spacing: 4) {
                Text(thread.senderName)
                    .font(.headline)
                    .fontWeight(.semibold) // Slightly less bold than .bold

                Text(thread.previewText)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(1) // Ensure truncation

                if let info = thread.additionalInfo {
                    Text(info)
                        .font(.caption) // Smaller font for details
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
            }

            Spacer() // Pushes timestamp to the right

            Text(thread.timestamp)
                .font(.caption) // Consistent smaller font
                .foregroundColor(.gray)
                .padding(.top, 2) // Align slightly below sender name
        }
        .padding(.vertical, 8) // Add padding between rows
    }
}

// MARK: - Main View

struct AirbnbMessagesView: View {
    @State private var selectedFilter: String = "All"
    @State private var selectedTab: Int = 3 // Start with Messages tab selected

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                // Title
                Text("Messages")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                    .padding(.bottom, 8) // Spacing below title

                // Filter Chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(filterCategories) { category in
                            FilterChipView(
                                category: category,
                                isSelected: selectedFilter == category.name
                            ) {
                                selectedFilter = category.name
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 12) // Spacing below filters
                }

                // Message List
                List {
                    ForEach(messageThreads) { thread in
                        MessageRowView(thread: thread)
                            .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16)) // Adjust row padding
                            .listRowSeparator(.hidden) // Hide default separators if desired
                    }
                }
                .listStyle(.plain) // Use plain style to remove default List styling
                .padding(.top, -8) // Reduce space between filters and list
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                      // Search action
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .padding(8)
                            .background(Color(.systemGray5))
                            .clipShape(Circle())
                             .foregroundColor(.black)
                    }

                    Button {
                      // Filter action
                    } label: {
                         Image(systemName: "line.3.horizontal.decrease.circle") // A filter-like icon
                           .padding(8)
                           .background(Color(.systemGray5))
                           .clipShape(Circle())
                            .foregroundColor(.black)
                    }
                }
            }
            // .navigationTitle("Messages") // Alternative if you don't want custom large title
             .navigationBarTitleDisplayMode(.inline) // Keep nav bar compact
        }
    }
}

// MARK: - Main App Structure with TabView

struct MainTabView: View {
    @State private var selectedTab: Int = 3 // Messages tab is index 3

    init() {
         // Customize Tab Bar Appearance (Optional)
        UITabBar.appearance().unselectedItemTintColor = UIColor.gray
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            Text("Explore Screen")
                .tabItem {
                    Label("Explore", systemImage: "magnifyingglass")
                }
                .tag(0)

            Text("Wishlists Screen")
                .tabItem {
                    Label("Wishlists", systemImage: "heart")
                }
                .tag(1)

            Text("Trips Screen")
                .tabItem {
                     Label("Trips", systemImage: "airplane") // Using airplane as placeholder
                }
                .tag(2)

            AirbnbMessagesView()
                .tabItem {
                    Label {
                        Text("Messages")
                    } icon: {
                        // Add notification dot using ZStack
                        ZStack {
                            Image(systemName: "message")
                            // Red Dot Overlay
                            Circle()
                                .fill(Color.red)
                                .frame(width: 6, height: 6)
                                .offset(x: 8, y: -8) // Position dot
                        }
                    }
                }
                .tag(3)

             Text("Profile Screen")
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
                .tag(4)
        }
         .tint(.pink) // Set the selected tab item color (Airbnb Pink/Red)
    }
}

// MARK: - Preview

#Preview {
    MainTabView()
}
