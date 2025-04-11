//
//  SnapchatMapsDetailView.swift
//  MyApp
//
//  Created by Cong Le on 4/11/25.
//

import SwiftUI

// MARK: - Data Model (Placeholder)

struct PlaceInfo {
    let imageName: String // Placeholder for actual image loading
    let name: String
    let type: String
    let status: String
    let distance: String
    let location: String
    let likeCount: Int
    let driveTime: String
    let galleryImageNames: [String] // Placeholder for gallery images
}

// MARK: - Main Content View

struct SnapchatMapsDetailView: View {
    // Mock data for the place
    let place = PlaceInfo(
        imageName: "dd-cafe-profile", // Assume this image exists in Assets
        name: "DD Cafe",
        type: "Coffee Shop",
        status: "Closed",
        distance: "2.6 miles",
        location: "Garden Grove, CA",
        likeCount: 17,
        driveTime: "9 min",
        galleryImageNames: ["gallery1", "gallery2", "gallery3", "gallery4"] // Assume these exist
    )

    var body: some View {
        ZStack(alignment: .bottom) {
            // 1. Map View Placeholder
            MapViewPlaceholder()
                .ignoresSafeArea()

            // 2. Place Detail Sheet (Simplified as overlay)
            PlaceDetailSheetView(place: place)
                // In a real app, this would be presented using .sheet or similar
                // For this example, we overlay it directly with some offset
                .padding(.bottom, 50) // Approximate space for the bottom nav bar

            // 3. Bottom Navigation Bar
            BottomNavBarView()
        }
    }
}

// MARK: - Placeholder Views

struct MapViewPlaceholder: View {
    var body: some View {
        Color.gray.opacity(0.3) // Simple representation of the map
            .overlay(
                Text("Map Area Placeholder")
                    .foregroundColor(.white)
                    .padding(5)
                    .background(.black.opacity(0.5))
                    .cornerRadius(5)
            )
    }
}

// MARK: - Place Detail Sheet Components

struct PlaceDetailSheetView: View {
    let place: PlaceInfo

    var body: some View {
        VStack(spacing: 0) {
            HandleIndicator()
                .padding(.vertical, 5)

            SheetContent(place: place)
        }
        .background(Color(.systemBackground)) // Use system background for light/dark mode adaptability
        .cornerRadius(20) // Rounded corners for the sheet
        .shadow(radius: 10)
        .padding(.horizontal) // Add some horizontal padding away from screen edges
    }
}

struct HandleIndicator: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 2.5)
            .fill(Color.gray.opacity(0.5))
            .frame(width: 40, height: 5)
    }
}

struct SheetContent: View {
    let place: PlaceInfo

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HeaderSection(place: place)
            TagButton()
            ActionsRow(place: place)
            GalleryScrollView(imageNames: place.galleryImageNames)
        }
        .padding(.horizontal)
        .padding(.bottom) // Add padding at the bottom of the content
    }
}

struct HeaderSection: View {
    let place: PlaceInfo

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(place.imageName) // Use the placeholder name
                .resizable()
                .scaledToFill()
                .frame(width: 60, height: 60)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.blue.opacity(0.5), lineWidth: 3)) // Simulate border
                .overlay(Circle().stroke(Color.white, lineWidth: 1)) // Inner white border

            VStack(alignment: .leading, spacing: 2) {
                Text(place.name)
                    .font(.title2)
                    .fontWeight(.bold)
                Text(place.type)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text("\(place.status) • \(place.distance) • \(place.location)")
                    .font(.caption)
                    .foregroundColor(place.status == "Closed" ? .red : .gray) // Conditional color
            }

            Spacer() // Push close button to the right

            CloseButton()
        }
    }
}

struct CloseButton: View {
    var body: some View {
        Button(action: {
            // Action to close the sheet
            print("Close button tapped")
        }) {
            Image(systemName: "xmark")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.primary) // Adapts to light/dark mode
                .padding(8)
                .background(Color(.systemGray5)) // Use system color
                .clipShape(Circle())
        }
    }
}

struct TagButton: View {
    var body: some View {
        Button(action: {
            // Action to tag the place
            print("Tag button tapped")
        }) {
            HStack {
                Image(systemName: "plus")
                Text("Tag this place")
            }
            .font(.footnote)
            .fontWeight(.medium)
            .foregroundColor(.primary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(.systemGray6))
            .clipShape(Capsule())
        }
        .buttonStyle(.plain) // Remove default button styling
    }
}

struct ActionsRow: View {
    let place: PlaceInfo

    var body: some View {
        HStack(spacing: 10) {
            ActionButton(iconName: "heart.fill", text: "\(place.likeCount)") // Use string interpolation
            ActionButton(iconName: "car.fill", text: place.driveTime)
            Spacer() // Push directions button to the right
            DirectionsButton()
        }
    }
}

struct ActionButton: View {
    let iconName: String
    let text: String

    var body: some View {
        Button(action: {
            print("\(text) Action tapped")
        }) {
            HStack(spacing: 5) {
                Image(systemName: iconName)
                Text(text)
            }
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundColor(.primary)
            .padding(.horizontal, 15)
            .padding(.vertical, 10)
            .background(Color(.systemGray5))
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

struct DirectionsButton: View {
    var body: some View {
        Button(action: {
            print("Directions tapped")
        }) {
            Image(systemName: "play.fill") // Using SFSymbol as placeholder for triangle
                .font(.title3)
                .foregroundColor(.white)
                .padding(.horizontal, 25)
                .padding(.vertical, 10)
                .background(Color.blue) // Bright blue color
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

struct GalleryScrollView: View {
    let imageNames: [String]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(imageNames, id: \.self) { imageName in
                    GalleryItem(imageName: imageName)
                }
            }
        }
        // Give the scroll view a fixed height
         .frame(height: 200)
    }
}

struct GalleryItem: View {
    let imageName: String

    var body: some View {
        ZStack(alignment: .bottom) {
            Image(imageName) // Use placeholder name
                .resizable()
                .scaledToFill()
                .frame(width: 120, height: 200) // Aspect ratio based on screenshot
                .cornerRadius(10)
                .clipped() // Clip the image within the rounded rectangle bounds

            // Placeholder for the "garden" overlay
            Text("garden")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
                .background(.black.opacity(0.6))
                .clipShape(Capsule()) // Approximate shape
                .padding(.bottom, 8)
        }
    }
}

// MARK: - Bottom Navigation Bar

struct BottomNavBarView: View {
    var body: some View {
        HStack {
            Spacer()
            NavBarItem(iconName: "location.fill", isActive: true) // Placeholder for current location
            Spacer()
            NavBarItem(iconName: "message.fill", badgeCount: 3) // Chat icon with badge
            Spacer()
            NavBarItem(iconName: "camera.fill") // Camera icon
            Spacer()
            NavBarItem(iconName: "person.2.fill") // People icon
            Spacer()
            NavBarItem(iconName: "play.rectangle.fill", hasNotification: true) // Stories icon with notification dot
            Spacer()
        }
        .frame(height: 50) // Standard height for tab bar area
        .padding(.bottom, UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0) // Adjust for safe area
        .background(.thinMaterial) // Apply a material background
    }
}

struct NavBarItem: View {
    let iconName: String
    var isActive: Bool = false
    var badgeCount: Int? = nil
    var hasNotification: Bool = false

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Image(systemName: iconName)
                .font(.system(size: 24))
                .foregroundColor(isActive ? .primary : .gray) // Active state color

            if let count = badgeCount, count > 0 {
                Text("\(count)")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white)
                    .padding(5)
                    .background(Color.red)
                    .clipShape(Circle())
                    .offset(x: 12, y: -8) // Adjust badge position
            } else if hasNotification {
                 Circle()
                    .fill(Color.red)
                    .frame(width: 8, height: 8)
                    .offset(x: 10, y: -3) // Adjust notification dot position
            }
        }
    }
}

// MARK: - Preview

struct SnapchatMapsDetailView_Previews: PreviewProvider {
    static var previews: some View {
        SnapchatMapsDetailView()
    }
}
