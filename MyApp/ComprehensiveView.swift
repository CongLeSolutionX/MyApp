////
////  ComprehensiveView.swift
////  MyApp
////
////  Created by Cong Le on 4/11/25.
////
//
//import SwiftUI
//import MapKit       // For Map view and coordinates
//import CoreLocation // For CLLocationCoordinate2D
//
//// MARK: - 1. Data Models
//
///// Data for the place detail sheet
//struct PlaceInfo: Identifiable {
//    let id = UUID() // Required for Identifiable (used by .sheet(item:))
//    let imageName: String
//    let name: String
//    let type: String
//    let status: String
//    let distance: String
//    let location: String
//    var initialLikeCount: Int
//    let driveTime: String
//    let galleryImageNames: [String]
//    // Maybe add coordinate if needed directly in the sheet
//    // let coordinate: CLLocationCoordinate2D?
//}
//
///// Data for a Point of Interest annotation on the map
//struct MockPOI: Identifiable {
//    let id = UUID()
//    let name: String
//    let coordinate: CLLocationCoordinate2D
//    let iconName: String // SF Symbol name
//    let color: SwiftUI.Color
//    // Add fields needed to convert to PlaceInfo if tapped
//    let type: String
//    let status: String
//    let placeholderDistance: String
//    let placeholderLocation: String
//    let placeholderDriveTime: String
//}
//
///// Data for a Friend annotation on the map
//struct MockFriendLocation: Identifiable {
//    let id = UUID()
//    let name: String
//    let coordinate: CLLocationCoordinate2D
//    let avatarAssetName: String
//}
//
//// MARK: - 2. Mock Data Provider
//
//struct MapMockData {
//    static let pois: [MockPOI] = [
//        MockPOI(
//            name: "DD Cafe (Mock)",
//            coordinate: CLLocationCoordinate2D(latitude: 33.7879, longitude: -117.8531), // Approx. Anaheim, CA center
//            iconName: "",
//            color: .brown,
//            type: "Coffee Shop",
//            status: "Open",
//            placeholderDistance: "1.2 mi",
//            placeholderLocation: "Anaheim, CA",
//            placeholderDriveTime: "5 min"
//        ),
//        MockPOI(
//            name: "Park (Mock)",
//             coordinate: CLLocationCoordinate2D(latitude: 33.8000, longitude: -117.8600), // Slightly NW
//             iconName: "leaf.fill",
//             color: .green,
//             type: "Park",
//             status: "Open",
//             placeholderDistance: "2.5 mi",
//             placeholderLocation: "Anaheim, CA",
//             placeholderDriveTime: "10 min"
//        ),
//        MockPOI(
//            name: "Tech Hub (Mock)",
//             coordinate: CLLocationCoordinate2D(latitude: 33.7750, longitude: -117.8450), // Slightly SE
//             iconName: "laptopcomputer",
//             color: .blue,
//             type: "Office",
//             status: "Closed",
//             placeholderDistance: "0.8 mi",
//             placeholderLocation: "Orange, CA",
//             placeholderDriveTime: "3 min"
//        ),
//        MockPOI(
//            name: "Gym (Mock)",
//            coordinate: CLLocationCoordinate2D(latitude: 33.7950, longitude: -117.8480), // NE area
//            iconName: "figure.run",
//            color: .orange,
//            type: "Fitness Center",
//            status: "Closing Soon",
//            placeholderDistance: "1.8 mi",
//            placeholderLocation: "Anaheim, CA",
//            placeholderDriveTime: "7 min"
//        )
//    ]
//
//    static let friends: [MockFriendLocation] = [
//        MockFriendLocation(
//            name: "Kevin Nguyen",
//            coordinate: CLLocationCoordinate2D(latitude: 33.7920, longitude: -117.8580), // Upper-leftish area
//            avatarAssetName: "My-meme-orange_2"
//        ),
//        MockFriendLocation(
//            name: "Alex Nguyen",
//             coordinate: CLLocationCoordinate2D(latitude: 33.7850, longitude: -117.8490), // Center-rightish
//             avatarAssetName: "My-meme-red-wine-glass"
//        ),
//        MockFriendLocation(
//            name: "Có ai đi ăn Phở không?",
//             coordinate: CLLocationCoordinate2D(latitude: 33.7780, longitude: -117.8620), // Lower-leftish
//             avatarAssetName: "My-meme-heineken"
//        )
//    ]
//
//    // Define a default region centered roughly around the mock data
//    static let defaultRegion = MKCoordinateRegion(
//        center: CLLocationCoordinate2D(latitude: 33.7879, longitude: -117.8531), // Center on DD Cafe
//        span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03) // Adjust zoom level as needed
//    )
//
//    // Helper to convert POI to PlaceInfo when needed
//    static func convertPoiToPlaceInfo(_ poi: MockPOI) -> PlaceInfo {
//        // Use a generic icon for profile or derive from poi.iconName/color
//        let profileIcon: String
//        switch poi.iconName {
//            case "cup.and.saucer.fill": profileIcon = "dd-cafe-profile" // Assuming you have this asset
//            case "leaf.fill": profileIcon = "park-profile" // Need asset
//            case "laptopcomputer": profileIcon = "tech-profile" // Need asset
//            case "figure.run": profileIcon = "gym-profile" // Need asset
//            default: profileIcon = "default-poi-profile" // Need asset or use system image placeholder
//        }
//
//        return PlaceInfo(
//            imageName: profileIcon,
//            name: poi.name,
//            type: poi.type,
//            status: poi.status,
//            distance: poi.placeholderDistance, // Use placeholder data
//            location: poi.placeholderLocation, // Use placeholder data
//            initialLikeCount: Int.random(in: 5...50), // Random likes for demo
//            driveTime: poi.placeholderDriveTime, // Use placeholder data
//            galleryImageNames: ["gallery1", "gallery2", "gallery3", "gallery4"] // Default gallery
//        )
//    }
//}
//
//// MARK: - 3. Main Application View & Tab Management
//
//// Enum for Tab Identification
//enum Tab {
//    case map, chat, camera, friends, stories
//}
//
//struct MainContentView: View {
//    @State private var selectedTab: Tab = .map // Default tab
//
//    // State to control sheet presentation using the Identifiable PlaceInfo
//    @State private var presentingPlace: PlaceInfo? = nil
//
//    var body: some View {
//        TabView(selection: $selectedTab) {
//            MapTabView(presentingPlace: $presentingPlace) // Pass the binding
//                .tabItem {
//                    Label("Map", systemImage: "map.fill") // Using map.fill
//                }
//                .tag(Tab.map)
//
//            PlaceholderTabView(title: "Chat", iconName: "message.fill")
//                .tabItem {
//                    Label("Chat", systemImage: "message.fill")
//                }
//                .tag(Tab.chat)
//                .badge(3)
//
//            PlaceholderTabView(title: "Camera", iconName: "camera.fill")
//                .tabItem {
//                     Label("Camera", systemImage: "camera.fill")
//                }
//                .tag(Tab.camera)
//
//            PlaceholderTabView(title: "Friends", iconName: "person.2.fill")
//                .tabItem {
//                    Label("Friends", systemImage: "person.2.fill")
//                }
//                .tag(Tab.friends)
//
//            PlaceholderTabView(title: "Stories", iconName: "play.rectangle.on.rectangle.fill") // Updated icon
//                .tabItem {
//                     Label("Stories", systemImage: "play.rectangle.on.rectangle.fill")
//                }
//                .tag(Tab.stories)
//                .badge("!") // Simulate update
//        }
//        // Use the item identifier version of .sheet
//        .sheet(item: $presentingPlace) { place in
//            // Pass the binding to allow the sheet to dismiss itself
//            PlaceDetailSheetView(place: place, isPresented: $presentingPlace)
//             // Optional: Customize sheet presentation detents (iOS 15+)
//              .presentationDetents([.fraction(0.6), .large]) // Example detents
//        }
//    }
//}
//
//// MARK: - 4. Tab Content Views
//
///// The View for the Map Tab, containing the actual MapKit view
//struct MapTabView: View {
//    @Binding var presentingPlace: PlaceInfo? // Receive binding to control sheet
//
//    var body: some View {
//        // Embed the RealMapView, passing the binding down
//        //RealMapView(presentingPlace: $presentingPlace)
//        RealMapView()
//    }
//}
//
///// Placeholder for other tabs
//struct PlaceholderTabView: View {
//    let title: String
//    let iconName: String
//
//    var body: some View {
//        ZStack {
//            Color(.systemGroupedBackground).ignoresSafeArea() // Use system grouped bg
//            VStack {
//                 Image(systemName: iconName)
//                    .font(.system(size: 60, weight: .thin))
//                    .foregroundColor(.secondary)
//                 Text(title)
//                    .font(.largeTitle.weight(.light))
//                    .foregroundColor(.secondary)
//            }
//        }
//    }
//}
//
//// MARK: - 5. MapKit View Implementation
////struct RealMapView: View {
////    @Binding var presentingPlace: PlaceInfo? // Binding to trigger the sheet
////
////    // State variable to hold the map's visible region.
////    @State private var region = MapMockData.defaultRegion
////
////    // Access the mock data
////    private let pois = MapMockData.pois
////    private let friends = MapMockData.friends
////
////    var body: some View {
////        // Use the Map initializer that takes a coordinateRegion binding
////        // and a trailing closure for the MapContent (@ViewBuilder).
////        Map(coordinateRegion: $region,
////            interactionModes: .all,        // Allow all interactions
////            showsUserLocation: true        // Show the user's blue dot (requires permissions)
////            // userTrackingMode: .constant(.none) // Optional: control user tracking explicitly
////        ) {_ in 
////            // ---- Annotation Content Goes Here ----
////
////            // Display Friend Annotations
////            ForEach(friends) { friend in
////                // MapAnnotation renders a custom SwiftUI view at a coordinate
////                MapAnnotation(coordinate: friend.coordinate) {
////                    FriendAvatarView(friend: friend) // Your custom view for friend pins
////                        .shadow(color: .black.opacity(0.3), radius: 3, y: 2)
////                        .onTapGesture {
////                            print("Tapped on friend: \(friend.name)")
////                            // Action for tapping a friend pin (e.g., show profile)
////                            // You might present a different sheet or popover here.
////                        }
////                }
////            } // End ForEach friends
////
////            // Display POI Annotations
////            ForEach(pois) { poi in
////                // MapAnnotation renders a custom SwiftUI view at a coordinate
////                MapAnnotation(coordinate: poi.coordinate) {
////                   POIMarkerView(poi: poi) // Your custom view for POI pins
////                        .shadow(color: .black.opacity(0.3), radius: 3, y: 2)
////                         .onTapGesture {
////                            print("Tapped on POI: \(poi.name)")
////                            // Convert the tapped POI to PlaceInfo and set the binding
////                            // This triggers the detail sheet presentation.
////                            self.presentingPlace = MapMockData.convertPoiToPlaceInfo(poi)
////                         }
////                }
////            } // End ForEach pois
////
////            // You could also add Overlays (like MapCircle, MapPolygon) here if needed.
////
////        } // ---- End of Map Content Closure ----
////        .ignoresSafeArea(edges: .top) // Allow map content under status bar
////        .mapStyle(.standard(elevation: .realistic)) // Set map appearance
////
////        // Optional Map Controls (can be added using .mapControls modifier if needed)
////        // .mapControls {
////        //     MapCompass()
////        //     MapPitchToggle()
////        //     MapUserLocationButton()
////        // }
////    }
////}
////
////struct RealMapView: View {
////    @Binding var presentingPlace: PlaceInfo? // Binding to trigger the sheet
////
////    // State variable to hold the map's visible region.
////    @State private var region = MapMockData.defaultRegion
////
////    // Access the mock data (could also be @State or from a ViewModel)
////    private let pois = MapMockData.pois
////    private let friends = MapMockData.friends
////
////    var body: some View {
////        Map(coordinateRegion: $region,
////            interactionModes: .all,
////            showsUserLocation: true // Requires location permissions configured
////        ) {_ in 
////            // Display Friend Annotations
////            ForEach(friends) { friend in
////                MapAnnotation(coordinate: friend.coordinate) {
////                    FriendAvatarView(friend: friend) // Use the custom view
////                        .shadow(color: .black.opacity(0.3), radius: 3, y: 2)
////                        .onTapGesture {
////                            print("Tapped on friend: \(friend.name)")
////                            // Could potentially show a simpler profile pop-up here
////                            // or navigate to a friend detail view if needed.
////                        }
////                }
////            }
////
////            // Display POI Annotations
////            ForEach(pois) { poi in
////                MapAnnotation(coordinate: poi.coordinate) {
////                    POIMarkerView(poi: poi) // Use the custom view
////                        .shadow(color: .black.opacity(0.3), radius: 3, y: 2)
////                         .onTapGesture {
////                            print("Tapped on POI: \(poi.name)")
////                            // Convert the tapped POI to PlaceInfo and set the binding
////                            self.presentingPlace = MapMockData.convertPoiToPlaceInfo(poi)
////                         }
////                }
////            }
////        } // End of Map View
////        .ignoresSafeArea(edges: .top) // Allow map to go under the notch/status bar
////        .mapStyle(.standard(elevation: .realistic)) // Example map style
////         // Optional Map Controls (iOS 17+)
////        // .mapControls {
////        //     MapCompass()
////        //     MapPitchToggle() // Allow changing pitch
////        //     MapUserLocationButton()
////        // }
////    }
////}
//
//// MARK: - 6. Annotation Views (for MapKit)
//
//struct POIMarkerView: View {
//    let poi: MockPOI
//
//    var body: some View {
//        VStack(spacing: 2) {
//            Image(systemName: poi.iconName)
//                .font(.system(size: 18)) // Slightly smaller icon
//                .foregroundColor(.white)
//                .padding(10) // Adjust padding
//                .background(poi.color)
//                .clipShape(Circle())
//                .overlay(Circle().stroke(Color.white.opacity(0.7), lineWidth: 1.5))
//
//            Text(poi.name)
//                .font(.caption.weight(.semibold)) // Bold caption
//                .padding(.horizontal, 8)
//                .padding(.vertical, 3)
//                .background(.ultraThinMaterial)
//                .clipShape(Capsule())
//                .foregroundColor(.primary) // Ensure text is readable
//        }
//         .accessibilityElement(children: .combine)
//         .accessibilityLabel("Point of interest: \(poi.name)")
//    }
//}
//
//struct FriendAvatarView: View {
//    let friend: MockFriendLocation
//
//    var body: some View {
//        VStack(spacing: 2) {
//            Image(friend.avatarAssetName) // Assumes asset exists
//                .resizable()
//                .scaledToFill()
//                .frame(width: 45, height: 45)
//                .clipShape(Circle())
//                // Subtle ring style
//                .overlay(Circle().stroke(LinearGradient(gradient: Gradient(colors: [.blue.opacity(0.3), .purple.opacity(0.5)]), startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 2))
//                .overlay(Circle().stroke(Color.white, lineWidth: 1))
//
//            Text(friend.name)
//                .font(.caption.weight(.semibold))
//                .padding(.horizontal, 8)
//                .padding(.vertical, 3)
//                .background(.ultraThinMaterial)
//                .clipShape(Capsule())
//                .foregroundColor(.primary)
//        }
//        .accessibilityElement(children: .combine)
//        .accessibilityLabel("Friend location: \(friend.name)")
//    }
//}
//
//// MARK: - 7. Place Detail Sheet View
//
//struct PlaceDetailSheetView: View {
//    let place: PlaceInfo
//    @Binding var isPresented: PlaceInfo? // Use the bound PlaceInfo? to dismiss
//
//    // Internal state for the sheet's content
//    @State private var isLiked: Bool = false
//    @State private var currentLikeCount: Int
//    @State private var showingTagAlert = false
//    @State private var showingDirectionsAlert = false
//    @State private var showingGalleryAlert = false
//    @State private var selectedGalleryItemName: String? = nil
//
//    // Environment variable to dismiss if needed programmatically (alternative to binding)
//    // @Environment(\.dismiss) private var dismiss
//
//    init(place: PlaceInfo, isPresented: Binding<PlaceInfo?>) {
//        self.place = place
//        self._isPresented = isPresented // Connect binding
//        // Initialize internal state based on the passed place data
//        self._currentLikeCount = State(initialValue: place.initialLikeCount)
//        // In a real app, `isLiked` state might also come from `place` or fetched data
//    }
//
//    var body: some View {
//        // No need for outer NavigationView if not navigating *within* the sheet
//        VStack(spacing: 0) {
//            HandleIndicator()
//                .padding(.vertical, 6)
//
//            ScrollView(.vertical, showsIndicators: false) {
//                 VStack(alignment: .leading, spacing: 16) { // Increased spacing slightly
//                    HeaderSection(place: place) {
//                        // Dismiss action for the close button uses the binding
//                        isPresented = nil
//                         // Alternatively: dismiss() // Using environment dismiss
//                    }
//
//                    TagButton { showingTagAlert = true }
//
//                    ActionsRow(
//                        isLiked: $isLiked,
//                        likeCount: $currentLikeCount,
//                        driveTime: place.driveTime,
//                        likeAction: {
//                            isLiked.toggle()
//                            currentLikeCount += isLiked ? 1 : -1
//                        },
//                        directionsAction: { showingDirectionsAlert = true }
//                    )
//
//                    GalleryScrollView(imageNames: place.galleryImageNames) { imageName in
//                         selectedGalleryItemName = imageName
//                         showingGalleryAlert = true
//                    }
//                }
//                .padding(.horizontal)
//                .padding(.bottom, 20) // Ensure padding at the bottom of scroll content
//            }
//        }
//        .background(Color(.secondarySystemBackground)) // Use a slightly different background
//        .cornerRadius(20, corners: [.topLeft, .topRight]) // Round only top corners
//        // Alerts triggered by button actions
//        .alert("Tag Place", isPresented: $showingTagAlert, actions: {
//            Button("Done", role: .cancel) { }
//        }, message: { Text("Tagging functionality not implemented for \(place.name).") })
//
//        .alert("Get Directions", isPresented: $showingDirectionsAlert, actions: {
//             Button("Open Maps App", role: .destructive) { print("Simulating opening maps...") }
//             Button("Cancel", role: .cancel) { }
//        }, message: { Text("Navigate to \(place.name)?") })
//
//        .alert("View Image", isPresented: $showingGalleryAlert, actions: {
//              Button("Close", role: .cancel) { }
//        }, message: { Text("Would open image: \(selectedGalleryItemName ?? "N/A").") })
//    }
//}
//
//// Helper for rounding specific corners
//struct RoundedCorner: Shape {
//    var radius: CGFloat = .infinity
//    var corners: UIRectCorner = .allCorners
//
//    func path(in rect: CGRect) -> Path {
//        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
//        return Path(path.cgPath)
//    }
//}
//
//extension View {
//    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
//        clipShape(RoundedCorner(radius: radius, corners: corners))
//    }
//}
//
//// MARK: - 8. Detail Sheet Sub-Components
//
//struct HandleIndicator: View {
//    var body: some View {
//        RoundedRectangle(cornerRadius: 3)
//            .fill(Color.gray.opacity(0.4))
//            .frame(width: 40, height: 6)
//    }
//}
//
//struct HeaderSection: View {
//    let place: PlaceInfo
//    let closeAction: () -> Void // Closure to dismiss the sheet
//
//    var body: some View {
//        HStack(alignment: .center, spacing: 15) {
//            Image(place.imageName) // Assumes asset exists or uses placeholder logic
//                .resizable()
//                .scaledToFill()
//                .frame(width: 65, height: 65)
//                .clipShape(Circle())
//                .overlay(Circle().stroke(Color.blue.opacity(0.4), lineWidth: 3))
//                .overlay(Circle().stroke(Color(.systemBackground), lineWidth: 1.5)) // Use bg color
//                .accessibilityLabel("\(place.name) profile picture")
//
//            VStack(alignment: .leading, spacing: 3) {
//                Text(place.name)
//                    .font(.title2)
//                    .fontWeight(.semibold) // Slightly bolder
//                Text(place.type)
//                    .font(.callout) // Larger subheadline
//                    .foregroundColor(.secondary)
//                HStack(spacing: 5) {
//                    Text(place.status)
//                         .font(.caption)
//                         .fontWeight(.medium)
//                         .foregroundColor(statusColor(place.status))
//                         .padding(.horizontal, 6)
//                         .padding(.vertical, 2)
//                         .background(statusColor(place.status).opacity(0.15))
//                         .clipShape(Capsule())
//                    Text("• \(place.distance) • \(place.location)")
//                        .font(.caption)
//                        .foregroundColor(.secondary)
//                }
//            }
//
//            Spacer()
//
//            CloseButton(action: closeAction)
//        }
//    }
//
//    // Helper for status color
//    private func statusColor(_ status: String) -> Color {
//        switch status.lowercased() {
//            case "open": return .green
//            case "closed": return .red
//            case "closing soon": return .orange
//            default: return .gray
//        }
//    }
//}
//
//struct CloseButton: View {
//    let action: () -> Void
//
//    var body: some View {
//        Button(action: action) {
//            Image(systemName: "xmark")
//                .font(.system(size: 12, weight: .heavy)) // Smaller, heavier icon
//                .foregroundColor(.secondary)
//                .padding(10) // Slightly larger tap area
//                .background(Color(.quaternarySystemFill)) // Use a fill color
//                .clipShape(Circle())
//        }
//        .buttonStyle(.plain) // Ensure background is applied correctly
//        .accessibilityLabel("Close details")
//    }
//}
//
//struct TagButton: View {
//    let action: () -> Void
//
//    var body: some View {
//        Button(action: action) {
//            HStack(spacing: 6) {
//                Image(systemName: "plus.circle.fill") // Changed icon
//                Text("Tag this place")
//            }
//            .font(.footnote)
//            .fontWeight(.medium)
//            .foregroundColor(.primary) // Use primary color
//            .padding(.horizontal, 12)
//            .padding(.vertical, 8)
//            .background(Color(.systemGray5)) // Slightly darker gray
//            .clipShape(Capsule())
//            .shadow(color: .black.opacity(0.05), radius: 2, y: 1) // Subtle shadow
//        }
//        .buttonStyle(.plain)
//        .accessibilityHint("Opens interface to add tags")
//    }
//}
//
//struct ActionsRow: View {
//    @Binding var isLiked: Bool
//    @Binding var likeCount: Int
//    let driveTime: String
//
//    let likeAction: () -> Void
//    let directionsAction: () -> Void
//
//    var body: some View {
//        HStack(spacing: 10) {
//            Button(action: likeAction) {
//                HStack(spacing: 4) {
//                    Image(systemName: isLiked ? "heart.fill" : "heart")
//                        .foregroundColor(isLiked ? .red : .primary)
//                        .imageScale(.medium)
//                    Text("\(likeCount)")
//                }
//            }
//            .buttonStyle(ActionCapsuleButtonStyle(isLiked: isLiked)) // Custom style
//            .accessibilityLabel(isLiked ? "Unlike place" : "Like place")
//            .accessibilityValue("\(likeCount) likes")
//
//            Button { /* Drive time info action (optional) */ } label: {
//                HStack(spacing: 4) {
//                    Image(systemName: "car.fill")
//                        .imageScale(.medium)
//                    Text(driveTime)
//                }
//            }
//            .buttonStyle(ActionCapsuleButtonStyle())
//            .accessibilityLabel("Estimated drive time")
//            .accessibilityValue(driveTime)
//
//            Spacer()
//
//            DirectionsButton(action: directionsAction)
//        }
//    }
//}
//
//// Custom button style for action row items
//struct ActionCapsuleButtonStyle: ButtonStyle {
//    var isLiked: Bool = false // Only relevant for like button styling
//
//    func makeBody(configuration: Configuration) -> some View {
//        configuration.label
//            .font(.subheadline)
//            .fontWeight(.medium)
//            .foregroundColor(isLiked ? .red : .primary)
//            .padding(.horizontal, 15)
//            .padding(.vertical, 10)
//            .background(Color(.systemGray5))
//            .clipShape(Capsule())
//            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
//            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
//    }
//}
//
//struct DirectionsButton: View {
//    let action: () -> Void
//
//    var body: some View {
//        Button(action: action) {
//            Image(systemName: "arrow.triangle.turn.up.right.diamond.fill")
//                .font(.title3)
//                 .foregroundColor(.white)
//                 .padding(.horizontal, 25)
//                 .padding(.vertical, 10)
//                 .background(Color.blue)
//                .clipShape(Capsule())
//                .shadow(color: .blue.opacity(0.4), radius: 4, y: 2)
//         }
//        .buttonStyle(.plain)
//        .accessibilityLabel("Get directions")
//    }
//}
//
//struct GalleryScrollView: View {
//    let imageNames: [String]
//    let itemAction: (String) -> Void
//
//    var body: some View {
//        VStack (alignment: .leading) {
//            Text("Photos") // Add section title
//                .font(.headline)
//                .padding(.bottom, 5)
//
//            ScrollView(.horizontal, showsIndicators: false) {
//                HStack(spacing: 12) { // Increased H spacing
//                    ForEach(imageNames, id: \.self) { imageName in
//                        GalleryItem(imageName: imageName)
//                            .onTapGesture { itemAction(imageName) }
//                    }
//                }
//                .padding(.horizontal, 2) // Small padding to avoid clipping shadows
//            }
//            .frame(height: 210) // Slightly increased height
//        }
//    }
//}
//
//struct GalleryItem: View {
//    let imageName: String
//
//    var body: some View {
//        ZStack(alignment: .bottomLeading) {
//             Image(imageName) // Use placeholder name
//                .resizable()
//                .scaledToFill()
//                .frame(width: 130, height: 210) // Slightly wider
//                .cornerRadius(12) // More rounding
//                .clipped()
//                .accessibilityLabel("Gallery image")
//
//            LinearGradient(gradient: Gradient(colors: [.clear, .clear, .black.opacity(0.8)]),
//                           startPoint: .top, endPoint: .bottom)
//                 .cornerRadius(12)
//
//             VStack(alignment: .leading) {
//                 Text("Garden") // Example tag
//                    .font(.caption2.weight(.bold))
//                    .foregroundColor(.white.opacity(0.9))
//                    .padding(.vertical, 3)
//                    .padding(.horizontal, 7)
//                    .background(Color.black.opacity(0.3))
//                    .clipShape(Capsule())
//
//                 // Add another example tag
//                 Text("Popular")
//                     .font(.caption2.weight(.bold))
//                     .foregroundColor(.white.opacity(0.9))
//                     .padding(.vertical, 3)
//                     .padding(.horizontal, 7)
//                     .background(Color.blue.opacity(0.5))
//                     .clipShape(Capsule())
//             }
//             .padding(8)
//             .accessibilityHidden(true)
//        }
//        .shadow(color: .black.opacity(0.15), radius: 5, y: 3) // Added shadow
//    }
//}
//
//// MARK: - 9. Preview Provider
//
//struct MainContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        MainContentView()
//            // Add preferred color scheme for testing
//            // .preferredColorScheme(.dark)
//    }
//}
//
//// MARK: - 10. Placeholder Assets Reminder (Essential)
///*
// === IMPORTANT: ===
// Add required placeholder images to your Assets.xcassets:
//
// **Friend Avatars:**
// - alex-avatar-placeholder
// - sarah-avatar-placeholder
// - ben-avatar-placeholder
//
// **POI Profile Images (or use default logic):**
// - dd-cafe-profile
// - park-profile
// - tech-profile
// - gym-profile
// - default-poi-profile (fallback)
//
// **Gallery Images:**
// - gallery1
// - gallery2
// - gallery3
// - gallery4
//
// You can use solid color rectangles or simple icons from SF Symbols exported as images
// for these placeholders if you don't have specific graphics. Failure to add assets
// with these *exact names* will result in runtime crashes or missing images.
// =================
// */
