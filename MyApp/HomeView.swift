//
//  HomeView.swift
//  MyApp
//
//  Created by Cong Le on 4/2/25.
//

import SwiftUI

// MARK: - Data Models

struct ListingItem: Identifiable {
    let id = UUID()
    let images: [String] // Array of image names/URLs for the carousel
    let isGuestFavorite: Bool
    var isFavorite: Bool // Use @State later in the view for interaction
    let location: String
    let distance: String
    let dates: String
    let price: Int
    let priceQualifier: String // e.g., "for 5 nights"
    let rating: Double
}

struct CategoryItem: Identifiable, Hashable { // Hashable for selection tracking
    let id = UUID()
    let imageName: String
    let title: String
}

enum AirbnbTabItem: CaseIterable, Identifiable {
    case explore, wishlists, trips, messages, profile

    var id: Self { self }

    var iconName: String {
        switch self {
        case .explore: return "magnifyingglass"
        case .wishlists: return "heart"
        case .trips: return "airplane" // Using airplane as a proxy for Airbnb logo
        case .messages: return "message"
        case .profile: return "person.circle"
        }
    }

    var title: String {
        switch self {
        case .explore: return "Explore"
        case .wishlists: return "Wishlists"
        case .trips: return "Trips"
        case .messages: return "Messages"
        case .profile: return "Profile"
        }
    }

    // Placeholder views for other tabs
    @ViewBuilder
    var view: some View {
        switch self {
        case .explore:
            ExploreContentView()
        case .wishlists:
            PlaceholderTabView(title: "Wishlists", icon: "heart.fill")
        case .trips:
            PlaceholderTabView(title: "Trips", icon: "airplane")
        case .messages:
            PlaceholderTabView(title: "Messages", icon: "message.fill")
        case .profile:
            PlaceholderTabView(title: "Profile", icon: "person.fill")
        }
    }
}

// MARK: - Sample Data

let sampleCategories: [CategoryItem] = [
    CategoryItem(imageName: "house.lodge", title: "Cabins"),
    CategoryItem(imageName: "star", title: "Icons"), // Placeholder SF Symbols
    CategoryItem(imageName: "photo.artframe", title: "Amazing views"),
    CategoryItem(imageName: "figure.wave", title: "OMG!"), // Placeholder
    CategoryItem(imageName: "leaf", title: "Farms"), // Placeholder
    CategoryItem(imageName: "beach.umbrella", title: "Beach"),
    CategoryItem(imageName: "house.and.flag", title: "National parks"),
    CategoryItem(imageName: "figure.pool.swim", title: "Pools"),
]

let sampleListings: [ListingItem] = [
    ListingItem(images: ["listing_1_a", "listing_1_b", "listing_1_c","listing_1_d"], // Add these images to Assets
                isGuestFavorite: true,
                isFavorite: false,
                location: "Lake Arrowhead, California",
                distance: "54 miles away",
                dates: "Apr 14 – 19",
                price: 2077,
                priceQualifier: "for 5 nights",
                rating: 5.0),
    ListingItem(images: ["listing_2_a", "listing_2_b", "listing_2_c"], // Add these images
                isGuestFavorite: false,
                isFavorite: true,
                location: "Big Bear Lake, California",
                distance: "90 miles away",
                dates: "May 1 – 7",
                price: 1850,
                priceQualifier: "for 6 nights",
                rating: 4.8),
    ListingItem(images: ["listing_3_a"], // Add this image
                isGuestFavorite: true,
                isFavorite: false,
                location: "Joshua Tree, California",
                distance: "130 miles away",
                dates: "Apr 20 – 25",
                price: 1500,
                priceQualifier: "for 5 nights",
                rating: 4.9),
]

// MARK: - Custom Styles & Colors

extension Color {
    static let airbnbPink = Color(red: 255/255, green: 56/255, blue: 92/255)
    static let airbnbGray = Color(uiColor: .systemGray)
    static let airbnbLightGray = Color(uiColor: .systemGray4)
    static let airbnbDarkGray = Color(uiColor: .darkGray)
}

// MARK: - Placeholder View for Unimplemented Tabs

struct PlaceholderTabView: View {
    let title: String
    let icon: String

    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                Image(systemName: icon)
                    .font(.system(size: 60))
                    .foregroundColor(.airbnbLightGray)
                Text(title)
                    .font(.title)
                    .foregroundColor(.airbnbGray)
                    .padding(.top)
                Text("Content coming soon!")
                    .font(.subheadline)
                    .foregroundColor(.airbnbGray)
                Spacer()
                Spacer()
            }
            .navigationTitle(title)
            .navigationBarHidden(true) // Hide nav bar for consistency
        }
         // Important for nested navigation handling in Tabs
        .navigationViewStyle(.stack)
    }
}

// MARK: - Explore Tab Content & Sub-components

// --- Search Bar ---
struct SearchBarView: View {
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.primary) // Adapts to light/dark mode

            VStack(alignment: .leading, spacing: 2) {
                Text("Start your search") // Main placeholder text
                    .fontWeight(.semibold)
                    .font(.subheadline)
                // Optional: Add subtitle for filters if needed later
                // Text("Anywhere • Any week • Add guests")
                //    .font(.caption)
                //    .foregroundColor(.gray)
            }
            Spacer() // Pushes content left
        }
        .padding(.vertical, 10)
        .padding(.horizontal)
        .background(Color(UIColor.systemBackground)) // Use system background
        .clipShape(Capsule())
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// --- Category Filter ---
struct CategoryFilterView: View {
    let categories: [CategoryItem]
    @State private var selectedCategory: CategoryItem? = sampleCategories.first // Default selection

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 25) { // Adjust spacing as needed
                ForEach(categories) { category in
                    CategoryItemView(
                        category: category,
                        isSelected: category == selectedCategory
                    )
                    .onTapGesture {
                        // Add animation if desired
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedCategory = category
                        }
                        print("Selected category: \(category.title)")
                        // Add action here (e.g., filter listings)
                    }
                }
            }
            .padding(.horizontal) // Padding for the whole HStack
        }
    }
}

struct CategoryItemView: View {
    let category: CategoryItem
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 5) {
            Image(systemName: category.imageName)
                .font(.title2) // Adjust icon size
                .frame(height: 25) // Ensure consistent height
                .foregroundColor(isSelected ? .primary : .airbnbGray)

            Text(category.title)
                .font(.caption)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .primary : .airbnbGray)
                .lineLimit(1) // Prevent wrapping

            // Underline for selected item
            if isSelected {
                Rectangle()
                    .fill(.primary)
                    .frame(height: 2)
                    .transition(.scale(scale: 0.5, anchor: .bottom).combined(with: .opacity)) // Simple animation
            } else {
                Rectangle()
                    .fill(.clear) // Placeholder to maintain layout
                    .frame(height: 2)
            }
        }
        .frame(minWidth: 60) // Give items minimum width
    }
}

// --- Fee Info ---
struct FeeInfoView: View {
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "tag.fill")
                .foregroundColor(.airbnbPink)
            Text("Prices include all fees")
                .font(.subheadline)
                .fontWeight(.semibold)
        }
        .padding(.vertical, 8) // Add vertical padding
    }
}

// --- Image Carousel ---
struct ImageCarouselView: View {
    let imageNames: [String]
    @State private var currentIndex = 0

    var body: some View {
        GeometryReader { geometry in
            TabView(selection: $currentIndex) {
                ForEach(imageNames.indices, id: \.self) { index in
                    Image(imageNames[index]) // Make sure these images are in Assets
                        .resizable()
                        .scaledToFill()
                        // Fill the width provided by geometry, calculate height based on aspect ratio
                        .frame(width: geometry.size.width)
                        .clipped() // Clip excess parts of the image
                        .tag(index) // Tag for TabView selection
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never)) // Hide default page control
            .frame(height: geometry.size.width * 0.85) // Aspect ratio approx 4:3.3
            // Custom Page Indicator Overlay
            .overlay(
                HStack(spacing: 6) {
                    ForEach(imageNames.indices, id: \.self) { index in
                        Circle()
                             // Adjust opacity for non-selected
                            .fill(Color.white.opacity(index == currentIndex ? 1.0 : 0.5))
                            .frame(width: 6, height: 6)
                    }
                }
                .padding(.bottom, 10), // Position dots near bottom
                alignment: .bottom
            )
        }
        // Important: Adjust height based on aspect ratio of your images
        // For example, if images are 4:3, use geometry.size.width * 0.75
        .aspectRatio(4 / 3.3, contentMode: .fit) // Maintain aspect ratio for GeometryReader
    }
}

// --- Listing Card ---
struct ListingCardView: View {
    // Use @State for mutable properties like isFavorite
    @State var listing: ListingItem

    var body: some View {
        VStack(alignment: .leading, spacing: 10) { // Spacing between image and text
            // --- Image Carousel & Overlays ---
            ZStack(alignment: .topTrailing) { // Align Heart Button
                ImageCarouselView(imageNames: listing.images)
                    .clipShape(RoundedRectangle(cornerRadius: 12)) // Rounded corners for image

                // Heart (Favorite) Button
                Button {
                     withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                           listing.isFavorite.toggle()
                     }
                } label: {
                    Image(systemName: listing.isFavorite ? "heart.fill" : "heart")
                        .foregroundColor(listing.isFavorite ? .airbnbPink : .white)
                        .font(.title2)
                        .padding(8) // Padding around the icon
                        .background(Color.black.opacity(0.3)) // Subtle background
                        .clipShape(Circle())
                }
                .padding(10) // Padding from the corner

                // Guest Favorite Badge (Top Left)
                if listing.isGuestFavorite {
                    HStack {
                        Image(systemName: "trophy.fill")
                        Text("Guest favorite")
                    }
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(.white)
                    .foregroundColor(.black)
                    .clipShape(Capsule())
                    .padding([.top, .leading], 10) // Position top-left
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading) // Align overlay
                }
            }

            // --- Text Details ---
            HStack { // Location and Rating
                Text(listing.location)
                    .fontWeight(.semibold)
                Spacer()
                HStack(spacing: 3) {
                    Image(systemName: "star.fill")
                    Text(String(format: "%.1f", listing.rating))
                }
            }
            .font(.subheadline) // Apply to HStack contents

            Text(listing.distance)
                .font(.subheadline)
                .foregroundColor(.airbnbGray)

            Text(listing.dates)
                .font(.subheadline)
                .foregroundColor(.airbnbGray)

            HStack(spacing: 3) { // Price
                Text("$\(listing.price)")
                    .fontWeight(.semibold)
                Text(listing.priceQualifier)
            }
             .font(.subheadline) // Apply to HStack
             .padding(.top, 1) // Small space before price
        }
         // Apply padding around the entire card content if needed
         // .padding()
         // .background(Color(UIColor.systemBackground)) // Optional background for card
         // .cornerRadius(12) // Optional if you want background corners separate from image
    }
}

// --- Main Content View for Explore Tab ---
struct ExploreContentView: View {
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 15) { // Adjust spacing
                // --- Search Bar (Sticky Header Concept) ---
                // For a true sticky header, you'd need GeometryReader or other means.
                // This places it at the top, scrolls with content.
                SearchBarView()
                    .padding(.horizontal)
                    .padding(.top) // Add top padding if not in NavigationView

                // --- Categories ---
                 CategoryFilterView(categories: sampleCategories)
                    .padding(.vertical, 10) // Space around categories

                // --- Divider ---
                Divider()
                     .padding(.horizontal)

                // --- Fee Info ---
                FeeInfoView()
                     .padding(.horizontal)

                // --- Listings ---
                ForEach(sampleListings) { listing in
                    ListingCardView(listing: listing)
                        .padding(.horizontal) // Padding for each card
                        .padding(.bottom, 15) // Space below each card
                }

                // Add Spacing at the bottom to avoid Tab Bar overlap visually
                Spacer(minLength: 90)
            }
        }
        // Allow ScrollView background to be the edge-to-edge default
        // .background(Color(UIColor.systemBackground)) - Handled by default
        // Do NOT ignore safe area here, let ScrollView respect it initially.
    }
}

// MARK: - Tab Bar View Implementation

struct AirbnbTabBarView: View {
    @Binding var selectedTab: AirbnbTabItem
//    @Environment(\.safeAreaInsets) private var safeAreaInsets

    var body: some View {
        HStack {
            ForEach(AirbnbTabItem.allCases) { item in
                Spacer()
                VStack(spacing: 4) {
                    Image(systemName: item.iconName)
                        .font(.system(size: 22)) // Icon size
                        .symbolVariant(selectedTab == item ? .fill : .none) // Fill selected icon
                        .frame(height: 25)

                    Text(item.title)
                        .font(.system(size: 10))
                }
                // Use Airbnb pink for selected, gray for others
                .foregroundColor(selectedTab == item ? .airbnbPink : .airbnbGray)
                .padding(.top, 8) // Add padding from the top edge of the bar
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle()) // Make whole area tappable
                .onTapGesture {
                     if selectedTab != item { // Avoid redundant selection/animation
                        selectedTab = item
                     }
                }
                Spacer()
            }
        }
        .frame(height: 55) // Height of the tab bar content area
//        .padding(.bottom, safeAreaInsets.bottom > 0 ? safeAreaInsets.bottom - 10 : 0 ) // Adjust padding based on safe area
        .background(.thinMaterial)
        .overlay(Divider(), alignment: .top) // Add top border like the screenshot
       // No extra shadow needed based on screenshot
    }
}

// MARK: - Main Container View (Manages Tabs)

struct MainAirbnbTabView: View {
    @State private var selectedTab: AirbnbTabItem = .explore

    var body: some View {
        ZStack(alignment: .bottom) {
            // Content View based on selected tab
            selectedTab.view
              // Let content provide its own background (Explore uses default)

            // Floating Map Button (Example Placement)
            // Place this logically based on which view it should appear over.
            // Here it overlays the current tab's content, positioned above the Tab Bar.
             if selectedTab == .explore { // Only show on Explore tab
                 MapButtonView()
//                    .padding(.bottom, (safeAreaInsets.bottom > 0 ? safeAreaInsets.bottom : 10) + 55) // Position above tab bar + some spacing
                 .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom) // Align button container
                 .transition(.scale.combined(with: .opacity)) // Animation for appear/disappear
                 .animation(.easeInOut, value: selectedTab)
             }

            // Custom Tab Bar
            AirbnbTabBarView(selectedTab: $selectedTab)

        }
        .edgesIgnoringSafeArea(.bottom) // Allow Tab Bar background to go edge-to-edge
    }

     // Access safe area insets for positioning Map button correctly
//     @Environment(\.safeAreaInsets) private var safeAreaInsets

}

// --- Map Button (Floating) ---
struct MapButtonView: View {
    var body: some View {
         Button {
             print("Map button tapped!")
             // Add action to show map
         } label: {
             HStack(spacing: 6) {
                 Text("Map")
                 Image(systemName: "map") // Or the specific icon shown
                     .font(.subheadline)
             }
             .padding(.horizontal, 16)
             .padding(.vertical, 10)
             .background(.black)
             .foregroundColor(.white)
             .clipShape(Capsule())
             .shadow(radius: 5)
         }
    }
}

// MARK: - App Entry Point

@main
struct AirbnbCloneApp: App { // RENAME this to your project's App name
    var body: some Scene {
        WindowGroup {
            MainAirbnbTabView()
        }
    }
}

// MARK: - Previews

#Preview("Full App") {
    MainAirbnbTabView()
}

#Preview("Explore Content View") {
    ExploreContentView()
}

#Preview("Listing Card") {
    // Need to pass a @State managed variable or a constant binding for preview
    ListingCardView(listing: sampleListings[0])
        .padding()
        .background(Color.gray.opacity(0.1))
}

#Preview("Category Filter") {
    CategoryFilterView(categories: sampleCategories)
        .padding(.vertical)
        .background(Color.gray.opacity(0.1))
}

#Preview("Search Bar") {
    SearchBarView()
        .padding()
        .background(Color.gray.opacity(0.1))
}

#Preview("Tab Bar") {
     // Use .constant for bindings in previews
    AirbnbTabBarView(selectedTab: .constant(.explore))
         .background(Color.white) // Background for visibility in preview
}

#Preview("Map Button") {
    MapButtonView()
        .padding()
        .background(Color.blue.opacity(0.3))
}
