//
//  WishlistView.swift
//  MyApp
//
//  Created by Cong Le on 4/2/25.
//

import SwiftUI

// MARK: - Data Model (Required by WishlistItemView)

struct Wishlist: Identifiable {
    let id = UUID()
    var imageName: String? // Use name of image in Assets
    var iconName: String?  // Use SF Symbol name
    let title: String
    let subtitle: String
}

// MARK: - Wishlist Item View (Renamed to WishlistView as requested)

struct WishlistView: View { // Renamed from WishlistItemView
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

// MARK: - Preview Provider for WishlistView

struct WishlistView_Previews: PreviewProvider {
    // Sample data for previewing just the item view
        // Example with Image
    static let sampleImageItem = Wishlist(imageName: "My-meme-original", title: "Cool places", subtitle: "3 saved")
        // Example with Icon
    static let sampleIconItem = Wishlist(iconName: "clock.arrow.2.circlepath", title: "Recently viewed", subtitle: "")
        // Example with Missing Data (Fallback)
    static let sampleMissingItem = Wishlist(title: "Empty Item", subtitle: "No data")

    static var previews: some View {
        Group {
            WishlistView(wishlist: sampleImageItem)
                .previewLayout(.fixed(width: 80, height: 20)) // Adjust size for typical grid item
                .padding()
                .previewDisplayName("Image Item")

            WishlistView(wishlist: sampleIconItem)
                .previewLayout(.fixed(width: 180, height: 220))
                .padding()
                .previewDisplayName("Icon Item")

            WishlistView(wishlist: sampleMissingItem)
                .previewLayout(.fixed(width: 180, height: 220))
                .padding()
                .previewDisplayName("Fallback Item")

        }
        // Remember to add a placeholder image named "coolPlaces" to Assets for the preview.
    }
}
