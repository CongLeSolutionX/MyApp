//
//  MapView.swift
//  MyApp
//
//  Created by Cong Le on 4/2/25.
//

import SwiftUI
import MapKit // Import MapKit for potential map integration later

// MARK: - Data Structures (for demonstration)

struct CategoryItem: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let iconName: String
}

struct MapLocation: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let price: Int?
    let hasHeart: Bool // Add logic if needed
}

// MARK: - Reusable Views

struct CategoryFilterView: View {
    let item: CategoryItem
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: item.iconName)
                .font(.title2)
                .foregroundColor(isSelected ? .primary : .secondary)

            Text(item.name)
                .font(.caption)
                .fontWeight(isSelected ? .medium : .regular)
                .foregroundColor(isSelected ? .primary : .secondary)

            if isSelected {
                Capsule()
                    .frame(height: 2)
                    .foregroundColor(.primary)
                    .padding(.horizontal, 4) // Adjust width slightly
            } else {
                Rectangle() // Placeholder for spacing
                    .frame(height: 2)
                    .foregroundColor(.clear)
                    .padding(.horizontal, 4)
            }
        }
        .padding(.horizontal, 8) // Spacing between items
    }
}

struct PriceMapAnnotationView: View {
    let price: Int
    let hasHeart: Bool

    var body: some View {
        HStack(spacing: 4) {
            Text("$\(price)")
                .font(.caption)
                .fontWeight(.semibold)
            if hasHeart {
                Image(systemName: "heart.fill")
                    .foregroundColor(.red)
                    .font(.caption) // Adjust size if needed
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.white)
        .clipShape(Capsule())
        .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 1)
    }
}

// MARK: - Main ContentView

struct MapView: View {
    @State private var searchText: String = ""
    @State private var selectedCategory: CategoryItem? // Track selected category
    @State private var region = MKCoordinateRegion( // Example region
        center: CLLocationCoordinate2D(latitude: 34.0522, longitude: -118.2437),
        span: MKCoordinateSpan(latitudeDelta: 1.5, longitudeDelta: 1.5)
    )

    // Sample Data
    let categories: [CategoryItem] = [
        CategoryItem(name: "Cabins", iconName: "house.lodge"),
        CategoryItem(name: "Icons", iconName: "star"), // Placeholder icons
        CategoryItem(name: "Amazing views", iconName: "photo.on.rectangle.angled"),
        CategoryItem(name: "OMG!", iconName: "figure.wave"), // Placeholder, needs better icon
        CategoryItem(name: "Farms", iconName: "carrot") // Placeholder, needs better icon
    ]

    let locations: [MapLocation] = [ // Example locations
        MapLocation(coordinate: CLLocationCoordinate2D(latitude: 34.3, longitude: -117.8), price: 705, hasHeart: false),
        MapLocation(coordinate: CLLocationCoordinate2D(latitude: 34.31, longitude: -117.75), price: 2077, hasHeart: true),
        MapLocation(coordinate: CLLocationCoordinate2D(latitude: 34.28, longitude: -117.7), price: 2482, hasHeart: true),
        MapLocation(coordinate: CLLocationCoordinate2D(latitude: 34.1, longitude: -117.2), price: 1628, hasHeart: false),
        MapLocation(coordinate: CLLocationCoordinate2D(latitude: 34.08, longitude: -117.15), price: 1080, hasHeart: false), // Price slightly obscured
        MapLocation(coordinate: CLLocationCoordinate2D(latitude: 34.25, longitude: -117.5), price: nil, hasHeart: false), // Simple marker
        MapLocation(coordinate: CLLocationCoordinate2D(latitude: 34.26, longitude: -117.48), price: nil, hasHeart: false),
        MapLocation(coordinate: CLLocationCoordinate2D(latitude: 34.24, longitude: -117.52), price: nil, hasHeart: false),
        MapLocation(coordinate: CLLocationCoordinate2D(latitude: 34.0, longitude: -117.0), price: nil, hasHeart: false),
        MapLocation(coordinate: CLLocationCoordinate2D(latitude: 33.98, longitude: -116.98), price: nil, hasHeart: false),
        MapLocation(coordinate: CLLocationCoordinate2D(latitude: 33.99, longitude: -117.02), price: nil, hasHeart: false),
    ]

    init() {
        // Set the default selected category
        _selectedCategory = State(initialValue: categories.first)
    }

    var body: some View {
        ZStack(alignment: .top) {
            // 1. Map View (Placeholder or actual MapKit Map)
            // Replace Color with Map view for actual implementation
             Map(coordinateRegion: $region, annotationItems: locations) { location in
                 MapAnnotation(coordinate: location.coordinate) {
                     if let price = location.price {
                         PriceMapAnnotationView(price: price, hasHeart: location.hasHeart)
                     } else {
                         // Simple Marker (Ellipse like in screenshot)
                         Circle()
                           .fill(.white)
                           .frame(width: 15, height: 10) // Approximate shape
                           .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                           .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                     }
                 }
             }
            .ignoresSafeArea(edges: .top) // Allow map under status bar initially

            // Content layered above the map
            VStack(spacing: 0) {
                // 2. Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("Start your search", text: $searchText)
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
                .background(Color(.systemBackground)) // Use system background for light/dark mode adaptability
                .clipShape(Capsule())
                .shadow(color: Color.black.opacity(0.15), radius: 5, x: 0, y: 3)
                .padding(.horizontal)
                .padding(.top, 50) // Adjust padding to avoid overlapping status bar

                // 3. Category Filter Bar
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) { // Increased spacing for better tap targets
                        ForEach(categories, id: \.self) { category in
                            CategoryFilterView(item: category, isSelected: category == selectedCategory)
                                .onTapGesture {
                                    selectedCategory = category
                                }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10) // Add vertical padding
                }
                .background(Color(.systemBackground)) // Ensure background covers under scroll
                .overlay( // Add bottom border shadow
                    Divider().offset(y: 1), // Position depends on exact layout needs
                    alignment: .bottom
                )

                Spacer() // Pushes bottom bar down
            }

            // 5. Location Button (Top Right)
             VStack {
                 Spacer() // Push button down slightly if needed from top edge
                 HStack {
                     Spacer() // Push button to the right
                     Button {
                         // Action for location button
                     } label: {
                         Image(systemName: "location.north.line.fill") // Or "paperplane.fill" rotated
                             .font(.title3)
                             .foregroundColor(.primary)
                             .padding(12)
                             .background(Color(.systemBackground))
                             .cornerRadius(10)
                             .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
                     }
                     .padding(.trailing)
                     .padding(.top, 130) // Adjust padding from top to position correctly below filters
                 }
                 Spacer() // Takes remaining vertical space
             }

            // 6. Bottom Summary Bar
             VStack {
                 Spacer() // Pushes the bar to the bottom
                 VStack(spacing: 5) {
                     // Drag Handle
                     Capsule()
                         .fill(Color.gray.opacity(0.5))
                         .frame(width: 40, height: 5)
                         .padding(.top, 8)

                     Text("Over 1,000 cabins")
                         .font(.headline)
                         .padding(.bottom, 20) // Padding above home indicator

                 }
                 .frame(maxWidth: .infinity)
                 .background(Color(.systemBackground))
                 .cornerRadius(20, corners: [.topLeft, .topRight]) // Rounded top corners
                 .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: -5)

             }
             .ignoresSafeArea(.container, edges: .bottom) // Allow it to go to the screen edge

        }
        .statusBar(hidden: false) // Ensure status bar is visible
    }
}

// Helper for rounding specific corners
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}
