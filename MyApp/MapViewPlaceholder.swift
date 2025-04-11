////
////  MapViewPlaceholder.swift
////  MyApp
////
////  Created by Cong Le on 4/11/25.
////
//
//// MapMockData.swift
import SwiftUI
//import Foundation
//import CoreGraphics // Needed for CGPoint
//
//// MARK: - Mock Data Structures
//
///// Represents a Point of Interest (POI) on the map.
//struct MockPOI: Identifiable {
//    let id = UUID()
//    let name: String
//    /// Relative coordinate within the map view's bounds (0.0 to 1.0).
//    /// (0.0, 0.0) is top-left, (1.0, 1.0) is bottom-right.
//    let coordinate: CGPoint
//    let iconName: String // SF Symbol name for the POI
//    let color: SwiftUI.Color // Color associated with the POI icon
//}
//
///// Represents a friend's location marker on the map.
//struct MockFriendLocation: Identifiable {
//    let id = UUID()
//    let name: String
//    /// Relative coordinate within the map view's bounds (0.0 to 1.0).
//    let coordinate: CGPoint
//    /// Name of the image asset for the friend's avatar (e.g., a placeholder Bitmoji)
//    let avatarAssetName: String
//}
//
//// MARK: - Mock Data Instances
//
//struct MapMockData {
//    static let pois: [MockPOI] = [
//        MockPOI(
//            name: "DD Cafe",
//            coordinate: CGPoint(x: 0.5, y: 0.45), // Slightly above center
//            iconName: "cup.and.saucer.fill",
//            color: .brown
//        ),
//        MockPOI(
//            name: "Central Park",
//             coordinate: CGPoint(x: 0.3, y: 0.6), // Left-ish, below center
//             iconName: "leaf.fill",
//             color: .green
//        ),
//        MockPOI(
//            name: "Tech Hub",
//             coordinate: CGPoint(x: 0.75, y: 0.7), // Right, lower area
//             iconName: "laptopcomputer",
//             color: .blue
//        ),
//        MockPOI(
//            name: "Gym",
//            coordinate: CGPoint(x: 0.6, y: 0.2), // Upper right area
//            iconName: "figure.run", // Changed symbol for better representation
//            color: .orange
//        )
//    ]
//
//    static let friends: [MockFriendLocation] = [
//        MockFriendLocation(
//            name: "Alex",
//            coordinate: CGPoint(x: 0.4, y: 0.3), // Upper left area
//            avatarAssetName: "alex-avatar-placeholder" // Needs asset
//        ),
//        MockFriendLocation(
//            name: "Sarah",
//             coordinate: CGPoint(x: 0.65, y: 0.55), // Slightly right, below center
//             avatarAssetName: "sarah-avatar-placeholder" // Needs asset
//        ),
//        MockFriendLocation(
//            name: "Ben",
//             coordinate: CGPoint(x: 0.25, y: 0.8), // Lower left corner area
//             avatarAssetName: "ben-avatar-placeholder" // Needs asset
//        )
//    ]
//}
//
//// MARK: - Add Placeholder Assets
///*
// Add placeholder images to your Assets.xcassets named:
// - "alex-avatar-placeholder"
// - "sarah-avatar-placeholder"
// - "ben-avatar-placeholder"
// (These can be simple colored circles or actual placeholder images if you have them)
// */
//
//import SwiftUI
//
//// Map View Placeholder (Enhanced with Mock Data)
//struct MapViewPlaceholder: View {
//    // Access the mock data (could also be passed in)
//    private let pois = MapMockData.pois
//    private let friends = MapMockData.friends
//
//    var body: some View {
//        GeometryReader { geometry in
//            ZStack {
//                // Base map background
//                Color.gray.opacity(0.3)
//
//                // --- Place Friend Avatars ---
//                ForEach(friends) { friend in
//                    FriendAvatarView(friend: friend)
//                        .position(
//                            x: geometry.size.width * friend.coordinate.x,
//                            y: geometry.size.height * friend.coordinate.y
//                        )
//                        .shadow(radius: 3) // Add shadow for depth
//                }
//
//                // --- Place POI Markers ---
//                ForEach(pois) { poi in
//                    POIMarkerView(poi: poi)
//                        .position(
//                            x: geometry.size.width * poi.coordinate.x,
//                            y: geometry.size.height * poi.coordinate.y
//                        )
//                         .shadow(radius: 3) // Add shadow for depth
//                }
//
//                // Optionally keep the text overlay or remove it
//                 Text("Interactive Map Area Placeholder")
//                    .foregroundColor(.white)
//                    .padding(5)
//                    .background(.black.opacity(0.5))
//                    .cornerRadius(5)
//                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2) // Center text
//            }
//        }
//        .ignoresSafeArea() // Ensure it goes edge-to-edge
//    }
//}
//
//// MARK: - Subviews for Map Items
//
//struct POIMarkerView: View {
//    let poi: MockPOI
//
//    var body: some View {
//        VStack(spacing: 2) {
//            Image(systemName: poi.iconName)
//                .font(.title2)
//                .foregroundColor(.white)
//                .padding(8)
//                .background(poi.color)
//                .clipShape(Circle())
//                .overlay(Circle().stroke(Color.white.opacity(0.8), lineWidth: 1.5)) // Add border
//
//            Text(poi.name)
//                .font(.caption)
//                .fontWeight(.medium)
//                .padding(.horizontal, 6)
//                .padding(.vertical, 2)
//                .background(.ultraThinMaterial) // Use material for background
//                .clipShape(Capsule())
//                .foregroundColor(.primary) // Ensure text is readable
//        }
//         .accessibilityElement(children: .combine) // Combine elements for accessibility
//         .accessibilityLabel("Point of interest: \(poi.name)")
//    }
//}
//
struct FriendAvatarView: View {
    let friend: MockFriendLocation

    var body: some View {
        VStack(spacing: 2) {
            Image(friend.avatarAssetName) // Assumes you have these assets
                .resizable()
                .scaledToFill()
                .frame(width: 45, height: 45)
                .clipShape(Circle())
                // Add a subtle ring like Snapchat often does
                .overlay(Circle().stroke(Color.blue.opacity(0.6), lineWidth: 2.5))
                .overlay(Circle().stroke(Color.white, lineWidth: 1)) // Inner white border

            Text(friend.name)
                .font(.caption)
                .fontWeight(.medium)
                 .padding(.horizontal, 6)
                 .padding(.vertical, 2)
                 .background(.ultraThinMaterial) // Use material for background
                 .clipShape(Capsule())
                 .foregroundColor(.primary) // Ensure text is readable
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Friend location: \(friend.name)")
    }
}

//// MARK: - Preview (Optional, for isolating MapViewPlaceholder)
//
//struct MapViewPlaceholder_Previews: PreviewProvider {
//    static var previews: some View {
//        MapViewPlaceholder()
//            // Add a fixed frame in preview for better visualization
//            .frame(height: 400)
//    }
//}
