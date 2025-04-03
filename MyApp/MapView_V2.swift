//
//  MapView_V2.swift
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
    let iconName: String // Use SF Symbols names
}

struct MapLocation: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let price: Int?
    let hasHeart: Bool
}

// MARK: - Reusable Views

struct CategoryFilterView: View {
    let item: CategoryItem
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 6) { // Reduced spacing slightly
            Image(systemName: item.iconName)
                .font(.system(size: 22)) // Adjusted size slightly
                .foregroundColor(isSelected ? .primary : .gray) // More contrast for unselected

            Text(item.name)
                .font(.system(size: 11)) // Smaller font size
                .fontWeight(isSelected ? .medium : .regular)
                .foregroundColor(isSelected ? .primary : .gray) // Match icon color for unselected

            if isSelected {
                Capsule()
                    .frame(height: 2)
                    .foregroundColor(.primary)
                    .padding(.horizontal, 6) // Adjust underline width if needed
            } else {
                Rectangle() // Placeholder for spacing
                    .frame(height: 2)
                    .foregroundColor(.clear)
                    .padding(.horizontal, 6)
            }
        }
        .padding(.horizontal, 5) // Adjust spacing between items if needed
    }
}

struct PriceMapAnnotationView: View {
    let price: Int
    let hasHeart: Bool

    var body: some View {
        HStack(spacing: 4) {
            Text("$\(priceFormat(price))") // Use formatter for thousands separator
                .font(.system(size: 13, weight: .semibold)) // Explicit font size/weight
            if hasHeart {
                Image(systemName: "heart.fill")
                    .foregroundColor(.red)
                    .font(.system(size: 11)) // Slightly smaller heart
            }
        }
        .padding(.horizontal, 10) // Adjust padding
        .padding(.vertical, 5)   // Adjust padding
        .background(Color.white) // Explicit white background
        .clipShape(Capsule())
        .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2) // Slightly adjusted shadow
    }

    // Helper to format price
    private func priceFormat(_ number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "," // Use comma for thousands
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
}

// Helper for Simple Marker View
struct SimpleMapAnnotationView: View {
     var body: some View {
         Circle()
           .fill(.white)
           .frame(width: 15, height: 10) // Approximate shape from original
           .overlay(Circle().stroke(Color.gray, lineWidth: 1))
           .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
     }
}

// MARK: - Main ContentView

struct MapView_V2: View {
    @State private var searchText: String = ""
    @State private var selectedCategoryName: String = "Cabins" // Track selected category by name
    @State private var region = MKCoordinateRegion( // Centered closer to example annotation
        center: CLLocationCoordinate2D(latitude: 34.22, longitude: -117.45), // Approx Iron Mtn Area
        span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5) // Zoomed in slightly
    )

    // Sample Data - Using SF Symbols closer to rendered image if possible
    let categories: [CategoryItem] = [
        // Using outline variants for unselected look
        CategoryItem(name: "Cabins", iconName: "house.lodge"), // Keep filled/specific if selected
        CategoryItem(name: "Icons", iconName: "star"), // Keep simple star
        CategoryItem(name: "Amazing views", iconName: "photo.on.rectangle.angled"), // Keep this one
        CategoryItem(name: "OMG!", iconName: "figure.wave"), // Keep placeholder
        CategoryItem(name: "Farms", iconName: "carrot") // Carrot icon is fine
    ]

    // Filtered Locations based on example render
    let locations: [MapLocation] = [
        MapLocation(coordinate: CLLocationCoordinate2D(latitude: 34.2269, longitude: -117.4460), // Approx Iron Mountain annotation
                    price: 2482, hasHeart: true),
        // Add other locations from the *first* screenshot if needed for testing
        // e.g. MapLocation(coordinate: CLLocationCoordinate2D(latitude: 34.3, longitude: -117.8), price: 705, hasHeart: false),
    ]

    var body: some View {
        ZStack(alignment: .top) {
            // 1. Map View
             Map(coordinateRegion: $region, annotationItems: locations) { location in
                 MapAnnotation(coordinate: location.coordinate) {
                     if let price = location.price {
                         PriceMapAnnotationView(price: price, hasHeart: location.hasHeart)
                     } else {
                          SimpleMapAnnotationView()
                     }
                 }
             }
            .mapStyle(.standard(elevation: .realistic)) // Add standard style for better visual
            .ignoresSafeArea(edges: .top) // Allow map under status bar

            // Content layered above the map
            VStack(spacing: 0) {

                // 2. Search Bar Area (with background padding for visual separation)
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("Start your search", text: $searchText)
                }
                .padding(.horizontal)
                .padding(.vertical, 10) // Slightly reduced vertical padding
                .background(Color(.systemBackground)) // Use system background
                .clipShape(Capsule())
                .shadow(color: Color.black.opacity(0.12), radius: 5, x: 0, y: 2) // Adjusted shadow
                .padding(.horizontal)
                .padding(.top, 55) // Adjusted padding for status bar space

                // 3. Category Filter Bar
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) { // Adjust spacing between category items
                        ForEach(categories, id: \.name) { category in // Use name as ID if unique
                             let isSelected = (category.name == selectedCategoryName)
                             // Selectively choose filled icon if selected, otherwise use provided icon name
                             let iconToShow = isSelected ? filledIconName(for: category.iconName) : category.iconName
                             CategoryFilterView(item: CategoryItem(name: category.name, iconName: iconToShow),
                                                isSelected: isSelected)
                                .onTapGesture {
                                    selectedCategoryName = category.name
                                }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 12) // Padding above filters
                    .padding(.bottom, 10) // Padding below filters (before divider)
                }
                .background(Color(.systemBackground)) // Background for the filter area
                // Subtle divider/shadow below filters
                .overlay(
                    Rectangle()
                        .frame(height: 0.5)
                        .foregroundColor(Color(.systemGray4)), // Use a subtle gray
                    alignment: .bottom
                )

                Spacer() // Pushes bottom bar down
            }

            // 5. Location Button (Positioned lower)
            // Use alignment guide or explicit padding in a separate overlay ZStack layer
             ZStack(alignment: .topTrailing) { // Use ZStack for easier alignment
                 Color.clear // Takes up space

                 Button {
                     // Action for location button
                 } label: {
                     Image(systemName: "location.north.line.fill") // Or rotated paperplane
                         .font(.system(size: 18)) // Adjust icon size
                         .foregroundColor(.primary)
                         .padding(10) // Adjust padding inside button
                         .background(Color(.systemBackground))
                         .cornerRadius(8) // Slightly less rounded corners
                         .shadow(color: Color.black.opacity(0.18), radius: 4, x: 0, y: 2) // Adjust shadow
                 }
                 .padding(.trailing, 16) // Padding from right edge
                 // Adjust top padding dynamically or estimate based on controls height
                 .padding(.top, UIScreen.main.bounds.height * 0.55) // Position roughly 55% down

             }
             .ignoresSafeArea() // Ignore safe area for positioning

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
                         .font(.system(size: 16, weight: .medium)) // Adjust font
                         .padding(.bottom, 20) // Padding above home indicator

                 }
                 .frame(maxWidth: .infinity)
                 .background(Color(.systemBackground))
                 .cornerRadius(16, corners: [.topLeft, .topRight]) // Slightly less rounding?
                 .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: -4) // Adjusted shadow
                 // Add a clear material background for better interaction if needed
                 // .background(.ultraThinMaterial, in: RoundedCorner(radius: 16, corners: [.topLeft, .topRight]))

             }
             .ignoresSafeArea(.container, edges: .bottom) // Allow it to go to the screen edge

        }
        .statusBar(hidden: false) // Ensure status bar is visible
    }

    // Helper to get a 'filled' version of an SF Symbol if applicable
    func filledIconName(for baseName: String) -> String {
        // Simple logic, may need more cases
        if baseName.hasSuffix(".fill") { return baseName }
        if baseName == "house.lodge" { return "house.lodge.fill"}
        if baseName == "star" { return "star.fill"}
        if baseName == "carrot" { return "carrot.fill"}
        // Add others if needed
        return baseName // Default to base if no filled version known
    }
}

// Helper for rounding specific corners (Keep as is)
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
        MapView_V2()
            // Optional: Add device frame for better context
            // .previewDevice("iPhone 14 Pro")
    }
}
