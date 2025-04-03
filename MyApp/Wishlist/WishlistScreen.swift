//
//  WishlistScreen.swift
//  MyApp
//
//  Created by Cong Le on 4/2/25.
//

import SwiftUI

// MARK: - Data Model

struct Wishlist: Identifiable {
    let id = UUID()
    var imageName: String? // Use name of image in Assets
    var iconName: String?  // Use SF Symbol name
    let title: String
    let subtitle: String
}

// MARK: - Sample Data

// NOTE: Replace placeholder image names ("coolPlaces", "pool", etc.)
// with actual image names added to your Assets.xcassets.
let sampleWishlists: [Wishlist] = [
    Wishlist(iconName: "clock.arrow.2.circlepath", title: "Recently viewed", subtitle: ""),
    Wishlist(imageName: "My-meme-microphone", title: "Cool places", subtitle: "3 saved"),
    Wishlist(imageName: "My-meme-red-wine-glass", title: "Places will be booked", subtitle: "5 saved"),
    Wishlist(imageName: "My-meme-heineken", title: "Place we booked", subtitle: "3 saved"),
    Wishlist(iconName: "heart", title: "Create new wishlist", subtitle: ""), // Assuming the heart represents creating a new one
    Wishlist(imageName: "My-meme-with-cap-2", title: "Experiences", subtitle: "1 saved") // Example, adjust as needed
]

// MARK: - Wishlist Item View

struct WishlistItemView: View {
    let wishlist: Wishlist
    let cornerRadius: CGFloat = 12 // Consistent corner radius

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Image or Placeholder Section
            ZStack {
                if let imageName = wishlist.imageName {
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        // The frame modifier below + aspectRatio on ZStack ensures square shape
                } else if let iconName = wishlist.iconName {
                    // Placeholder background
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(Color(.systemGray4)) // A slightly lighter gray

                    // Placeholder Icon
                    Image(systemName: iconName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50) // Adjust size as needed
                        .foregroundColor(Color(.systemGray)) // Airbnb uses a slightly darker gray for icons
                } else {
                     // Fallback: Empty gray box if neither image nor icon provided
                     RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(Color(.systemGray4))
                }
            }
            .aspectRatio(1.0, contentMode: .fit) // Makes the ZStack container square
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius)) // Apply rounding to the whole container

            // Text Section
            Text(wishlist.title)
                .font(.system(size: 16, weight: .semibold)) // Closer to Airbnb's font
                .foregroundColor(.primary)
                .lineLimit(1) // Ensure title doesn't wrap excessively

            if !wishlist.subtitle.isEmpty {
                Text(wishlist.subtitle)
                    .font(.system(size: 14)) // Closer to Airbnb's font
                    .foregroundColor(.secondary) // Use secondary color for subtitles
            }
        }
    }
}

// MARK: - Main Wishlists Screen View

struct WishlistsScreen: View {

    // Grid columns definition: 2 flexible columns with spacing
    let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    // The data for the grid
    let wishlistsData = sampleWishlists

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, alignment: .center, spacing: 24) { // Increased row spacing
                    ForEach(wishlistsData) { wishlist in
                        WishlistItemView(wishlist: wishlist)
                    }
                }
                .padding(.horizontal) // Padding for the grid side margins
                .padding(.top) // Padding above the grid
            }
            .navigationTitle("Wishlists") // Sets the large title
            .navigationBarTitleDisplayMode(.large) // Ensures large title behavior
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Edit") {
                        print("Edit button tapped")
                        // Add action for editing wishlists
                    }
                    .font(.system(size: 16, weight: .medium))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(.systemGray5)) // Matching button background
                    .foregroundColor(.primary) // Black text for the button
                    .clipShape(Capsule()) // Rounded ends like the screenshot
                }
            }
             // Conceptual Tab Bar - Not part of this specific view's body,
             // but WishlistsScreen would be placed inside a TabView in the full app.
             // .accentColor(.pink) // Set the accent color (like Airbnb's red) on the TabView itself
        }
        // Apply the accent color if needed for the NavView elements, though the TabView is more common.
        // .accentColor(.red) // Or specific Airbnb red color
    }
}

// MARK: - Preview Provider

struct WishlistsScreen_Previews: PreviewProvider {
    static var previews: some View {
        WishlistsScreen()
            // Add dummy images to Assets.xcassets named "coolPlaces", "pool", etc.
            // or the preview will show placeholders/errors for those items.
            // You might need to handle missing images gracefully in WishlistItemView for previews.
    }
}
