////
////  RealMapView.swift
////  MyApp
////
////  Created by Cong Le on 4/11/25.
////
//
//// MapMockData.swift
//
//import Foundation
//import CoreLocation // Import CoreLocation for coordinates
//import SwiftUI     // Import SwiftUI for Color
//
//// MARK: - Mock Data Structures (Updated Coordinate Type)
//
//struct MockPOI: Identifiable {
//    let id = UUID()
//    let name: String
//    /// Use real-world coordinates
//    let coordinate: CLLocationCoordinate2D
//    let iconName: String // SF Symbol name
//    let color: SwiftUI.Color
//}
//
//struct MockFriendLocation: Identifiable {
//    let id = UUID()
//    let name: String
//    /// Use real-world coordinates
//    let coordinate: CLLocationCoordinate2D
//    let avatarAssetName: String
//}
//
//// MARK: - Mock Data Instances (Updated with CLLocationCoordinate2D)
//
//struct MapMockData {
//    static let pois: [MockPOI] = [
//        MockPOI(
//            name: "DD Cafe (Mock)",
//            coordinate: CLLocationCoordinate2D(latitude: 33.7879, longitude: -117.8531), // Approx. Anaheim, CA center
//            iconName: "cup.and.saucer.fill",
//            color: .brown
//        ),
//        MockPOI(
//            name: "Park (Mock)",
//             coordinate: CLLocationCoordinate2D(latitude: 33.8000, longitude: -117.8600), // Slightly NW
//             iconName: "leaf.fill",
//             color: .green
//        ),
//        MockPOI(
//            name: "Tech Hub (Mock)",
//             coordinate: CLLocationCoordinate2D(latitude: 33.7750, longitude: -117.8450), // Slightly SE
//             iconName: "laptopcomputer",
//             color: .blue
//        ),
//        MockPOI(
//            name: "Gym (Mock)",
//            coordinate: CLLocationCoordinate2D(latitude: 33.7950, longitude: -117.8480), // NE area
//            iconName: "figure.run",
//            color: .orange
//        )
//    ]
//
//    static let friends: [MockFriendLocation] = [
//        MockFriendLocation(
//            name: "Alex",
//            coordinate: CLLocationCoordinate2D(latitude: 33.7920, longitude: -117.8580), // Upper-leftish area
//            avatarAssetName: "alex-avatar-placeholder"
//        ),
//        MockFriendLocation(
//            name: "Sarah",
//             coordinate: CLLocationCoordinate2D(latitude: 33.7850, longitude: -117.8490), // Center-rightish
//             avatarAssetName: "sarah-avatar-placeholder"
//        ),
//        MockFriendLocation(
//            name: "Ben",
//             coordinate: CLLocationCoordinate2D(latitude: 33.7780, longitude: -117.8620), // Lower-leftish
//             avatarAssetName: "ben-avatar-placeholder"
//        )
//    ]
//
//    // Define a default region centered roughly around the mock data
//    static let defaultRegion = MKCoordinateRegion(
//        center: CLLocationCoordinate2D(latitude: 33.7879, longitude: -117.8531), // Center on DD Cafe
//        span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03) // Adjust zoom level as needed
//    )
//}
//
//// MARK: - Placeholder Assets Reminder (Keep this comment)
///*
// Add placeholder images to your Assets.xcassets named:
// - "alex-avatar-placeholder"
// - "sarah-avatar-placeholder"
// - "ben-avatar-placeholder"
// */
//
//import SwiftUI
//import MapKit // Import MapKit
//
//struct RealMapView: View {
//    // State variable to hold the map's visible region.
//    // Initialize with the default region from our mock data.
//    @State private var region = MapMockData.defaultRegion
//
//    // Access the mock data
//    private let pois = MapMockData.pois
//    private let friends = MapMockData.friends
//
//    var body: some View {
//        // Use the SwiftUI Map view
//        Map(coordinateRegion: $region,
//            interactionModes: .all, // Allow pan, zoom, etc.
//            showsUserLocation: true, // Optionally show the user's blue dot
//            annotationItems: friends) { friend in
//            // Use MapAnnotation for custom SwiftUI views as markers
//            MapAnnotation(coordinate: friend.coordinate) {
//                FriendAvatarView(friend: friend) // Reuse our existing avatar view
//                     .shadow(radius: 3) // Add shadow for visibility
//                     .onTapGesture { // Make annotations interactive
//                        print("Tapped on friend: \(friend.name)")
//                        // Here you could trigger showing details, etc.
//                     }
//            }
//        }
//        // --- Overlay POIs using ZStack/Overlay (Alternative to multiple annotationItems) ---
//        // Since Map only takes one `annotationItems`, we overlay the POIs.
//        // Alternatively, create a unified annotation model.
//        .overlay(
//             GeometryReader { geometry in
//                 ForEach(pois) { poi in
//                     // We need to convert CLLocationCoordinate2D back to CGPoint
//                     // within the current map view's context. This requires
//                     // a MapReader (iOS 17+) or more complex calculations.
//                     //
//                     // **Simpler Approach for Demo:** Use ZStack layering with
//                     // MapAnnotation directly within the Map view is cleaner if
//                     // separate sources are needed. Reverting to that style:
//
//                     // Let's adjust the Map initializer to use MapAnnotation directly
//                     // This example will be restructured below. This overlay approach
//                     // is more complex than needed for basic annotations.
//                     EmptyView() // Placeholder for the overlay logic removal
//                 }
//             }
//        )
//         // --- Corrected Approach using MapAnnotation for both ---
//         // Replace the above Map structure with this:
//         /*
//         Map(coordinateRegion: $region,
//             interactionModes: .all,
//             showsUserLocation: true
//         ) {
//             // Display Friend Annotations
//             ForEach(friends) { friend in
//                 MapAnnotation(coordinate: friend.coordinate) {
//                     FriendAvatarView(friend: friend)
//                         .shadow(radius: 3)
//                         .onTapGesture {
//                             print("Tapped on friend: \(friend.name)")
//                         }
//                 }
//             }
//
//             // Display POI Annotations
//             ForEach(pois) { poi in
//                 MapAnnotation(coordinate: poi.coordinate) {
//                     POIMarkerView(poi: poi) // Reuse our existing POI marker view
//                         .shadow(radius: 3)
//                          .onTapGesture {
//                             print("Tapped on POI: \(poi.name)")
//                             // You could set state here to show the PlaceDetailSheetView
//                             // e.g., @Binding var presentingPlace: PlaceInfo?
//                             // self.presentingPlace = convertPoiToPlaceInfo(poi)
//                         }
//                 }
//             }
//         } // End of Map View
//         */
//        .ignoresSafeArea(edges: .top) // Allow map to go under the notch/status bar
//        // Add other modifiers if needed, like specific map controls
//        // .mapControls {
//        //     MapCompass()
//        //     MapScaleView()
//        //     MapUserLocationButton()
//        // }
//    }
//
//     // Helper function if you need to trigger your detail sheet from a POI tap
//     // func convertPoiToPlaceInfo(_ poi: MockPOI) -> PlaceInfo {
//     //     // Create a PlaceInfo object based on the POI data
//     //     // This will require adding more fields to MockPOI or using defaults
//     //     return PlaceInfo(
//     //         imageName: "default-poi-icon", // Or derive from poi.iconName
//     //         name: poi.name,
//     //         type: "Point of Interest", // Default type
//     //         status: "Unknown",
//     //         distance: "N/A",
//     //         location: "From Map",
//     //         initialLikeCount: 0,
//     //         driveTime: "N/A",
//     //         galleryImageNames: ["gallery1"] // Default gallery
//     //         // id will be generated automatically
//     //     )
//     // }
//}
//
//// MARK: - Reusable Annotation Views (Ensure these are available)
//
//// POIMarkerView struct (copied from previous response for completeness)
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
//                .overlay(Circle().stroke(Color.white.opacity(0.8), lineWidth: 1.5))
//
//            Text(poi.name)
//                .font(.caption)
//                .fontWeight(.medium)
//                .padding(.horizontal, 6)
//                .padding(.vertical, 2)
//                .background(.ultraThinMaterial)
//                .clipShape(Capsule())
//                .foregroundColor(.primary)
//        }
//         .accessibilityElement(children: .combine)
//         .accessibilityLabel("Point of interest: \(poi.name)")
//    }
//}
//
//// FriendAvatarView struct (copied from previous response for completeness)
//struct FriendAvatarView: View {
//    let friend: MockFriendLocation
//
//    var body: some View {
//        VStack(spacing: 2) {
//            Image(friend.avatarAssetName)
//                .resizable()
//                .scaledToFill()
//                .frame(width: 45, height: 45)
//                .clipShape(Circle())
//                .overlay(Circle().stroke(Color.blue.opacity(0.6), lineWidth: 2.5))
//                .overlay(Circle().stroke(Color.white, lineWidth: 1))
//
//            Text(friend.name)
//                .font(.caption)
//                .fontWeight(.medium)
//                 .padding(.horizontal, 6)
//                 .padding(.vertical, 2)
//                 .background(.ultraThinMaterial)
//                 .clipShape(Capsule())
//                 .foregroundColor(.primary)
//        }
//        .accessibilityElement(children: .combine)
//        .accessibilityLabel("Friend location: \(friend.name)")
//    }
//}
//
//// MARK: - Preview
//
//struct RealMapView_Previews: PreviewProvider {
//    static var previews: some View {
//        RealMapView()
//    }
//}
