//
//  StarbucksOrderView.swift
//  MyApp
//
//  Created by Cong Le on 4/2/25.
//

import SwiftUI
import MapKit // Needed for the Map view

// MARK: - Data Model

struct Store: Identifiable {
    let id = UUID()
    let name: String
    let address: String
    let distance: String
    let hours: String
    let services: [ServiceType]
    var isFavorite: Bool
    let bannerText: String?

    enum ServiceType: String {
        case inStore = "In store"
        case driveThru = "Drive-thru"
        // Add other types if needed

        var iconName: String {
            switch self {
            case .inStore: "door.left.hand.open"
            case .driveThru: "car.fill"
            }
        }
    }
}

// MARK: - Helper Views

// Represents a single row in the store list
struct StoreRowView: View {
    let store: Store

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Optional Banner
            if let banner = store.bannerText {
                Text(banner)
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.yellow.opacity(0.3))
                    .foregroundColor(.orange.opacity(0.9))
                    .cornerRadius(10)
                    .padding(.bottom, 4) // Add spacing below banner
            }

            // Top part: Name and Action Buttons
            HStack(alignment: .top) {
                Text(store.name)
                    .font(.headline)
                    .fontWeight(.semibold)

                Spacer()

                HStack(spacing: 15) {
                    Image(systemName: store.isFavorite ? "heart.fill" : "heart")
                        .foregroundColor(store.isFavorite ? .starbucksGreen : .gray)
                    Image(systemName: "info.circle")
                        .foregroundColor(.gray)
                }
                .imageScale(.large) // Make icons slightly larger
            }

            // Address
            Text(store.address)
                .font(.subheadline)
                .foregroundColor(.gray)

            // Distance and Hours
            Text("\(store.distance) ⋅ \(store.hours)")
                .font(.subheadline)
                .foregroundColor(.gray)

            // Service Icons
            HStack(spacing: 15) {
                ForEach(store.services, id: \.self) { service in
                    VStack {
                        Image(systemName: service.iconName)
                            .foregroundColor(.gray)
                        Text(service.rawValue)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.top, 4)
        }
        .padding(.vertical, 8) // Add padding inside the row
    }
}

// MARK: - Main Order View

struct StarbucksOrderView: View {
    // State variables
    @State private var selectedOrderType = 0 // 0: Pickup, 1: Delivery
    @State private var selectedStoreListTab = 0 // 0: Nearby, 1: Previous, 2: Favorites
    @State private var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 33.74, longitude: -117.99), // Approx. Garden Grove
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var stores: [Store] = [ // Sample Data
        Store(name: "Brookhurst & Westminster", address: "13992 Brookhurst St, Garden Grove", distance: "0.9 mi", hours: "Open until 9:30 PM", services: [.inStore, .driveThru], isFavorite: true, bannerText: nil),
        Store(name: "Target Garden Grove 193", address: "13831 Brookhurst St, Garden Grove", distance: "0.9 mi", hours: "Open until 8:00 PM", services: [.inStore], isFavorite: false, bannerText: "Order ahead not available"),
        Store(name: "Magnolia & Trask", address: "13471 Magnolia St, Garden Grove", distance: "1.2 mi", hours: "Open until 8:30 PM", services: [.inStore, .driveThru], isFavorite: false, bannerText: nil)
        // Add more stores here...
    ]

    // Constants for colors
    static let starbucksGreen = Color(red: 0, green: 0.384, blue: 0.278) // #006241

    let orderTypes = ["Pickup", "Delivery"]
    let storeListTabs = ["Nearby", "Previous", "Favorites"]

    var body: some View {
        NavigationStack { // Use NavigationStack for potential future navigation
            VStack(spacing: 0) {
                // --- Top Bar ---
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                        .imageScale(.large)

                    Picker("Order Type", selection: $selectedOrderType) {
                        ForEach(0..<orderTypes.count, id: \.self) { index in
                            Text(orderTypes[index]).tag(index)
                        }
                    }
                    .pickerStyle(.segmented)
                    .background(
                        Capsule()
                            .stroke(Self.starbucksGreen, lineWidth: 1) // Capsule border
                    )
                    .padding(.horizontal) // Add spacing around picker

                    Spacer() // Pushes Skip button to the right

                    Button("Skip") {
                        // TODO: Handle Skip action
                    }
                    .foregroundColor(Self.starbucksGreen)
                    .fontWeight(.medium)
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color(.systemBackground)) // Use system background for light/dark mode

                // --- Map Area ---
                ZStack(alignment: .bottomTrailing) {
                    // The actual Map View
                    Map(coordinateRegion: $mapRegion, showsUserLocation: true)
                        // Add a blue dot overlay simulating current location (MapKit does this with showsUserLocation)
                        .overlay( // Simple overlay to mimic blue dot if needed for demo
                             Circle()
                                 .fill(.blue)
                                 .opacity(0.7)
                                 .frame(width: 15, height: 15)
                                 .overlay(Circle().stroke(.white, lineWidth: 2))
                                 // Position this precisely if needed, MapKit handles the real one
                                 // .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                         )

                    // Overlay Buttons on Map
                    VStack(spacing: 10) {
                        Button {
                            // TODO: Center map on user location
                        } label: {
                            Image(systemName: "location.fill") // Changed icon slightly
                                .padding()
                                .background(.background) // Use background material
                                .clipShape(Circle())
                                .shadow(radius: 3)
                        }

                        Button {
                            // TODO: Show Filter options
                        } label: {
                             Text("Filter")
                                .fontWeight(.medium)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(.background)
                                .clipShape(Capsule())
                                .shadow(radius: 3)
                        }
                    }
                    .padding() // Padding for the VStack containing buttons
                    .foregroundColor(Self.starbucksGreen) // Color for buttons
                }
                .frame(height: 250) // Fixed height for the map area

                // --- Store List Tabs ---
                Picker("Stores", selection: $selectedStoreListTab) {
                   ForEach(0..<storeListTabs.count, id: \.self) { index in
                       Text(storeListTabs[index]).tag(index)
                   }
               }
               .pickerStyle(.segmented)
               .padding(.horizontal)
               .padding(.vertical, 8)
               .background(Color(.systemGroupedBackground)) // Slightly off-white background

                // --- Store List ---
                List {
                    ForEach(stores) { store in
                        StoreRowView(store: store)
                           // Remove default List separators if needed and use custom Dividers
                           .listRowSeparator(.hidden) // Hide default separators
                           .overlay(Divider().padding(.leading), alignment: .bottom) // Add custom divider with padding
                           .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)) // Adjust list row padding
                    }
                }
                .listStyle(.plain) // Use plain style to remove default List background/insets
                .background(Color(.systemGroupedBackground)) // Match tab background
            }
            .ignoresSafeArea(edges: .top) // Let content go under status bar if needed, adjust as required
            // .navigationTitle("Order") // Optional: Add a title if needed later
             .navigationBarHidden(true) // Hide the default navigation bar if desired
        }
    }
}

// MARK: - TabView Wrapper (Main App Structure)

struct MainTabView: View {
    @State private var selectedTab = 2 // Default to "Order" tab (index 2)
    
    // Use init to customize tab bar appearance globally if needed
    init() {
       // Example: Customize Tab Bar appearance (optional)
       // UITabBar.appearance().backgroundColor = UIColor.systemGray6
       // UITabBar.appearance().unselectedItemTintColor = UIColor.gray
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            Text("Home Screen")
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)

            Text("Scan Screen")
                .tabItem {
                    Label("Scan", systemImage: "qrcode.viewfinder")
                }
                .tag(1)

            StarbucksOrderView() // Embed the main Order view here
                .tabItem {
                     // Use custom Color Literal if exact green is needed and asset not available
                    Label("Order", systemImage: "cup.and.saucer.fill")
                }
                .tag(2)

            Text("Gift Screen")
                .tabItem {
                    Label("Gift", systemImage: "gift.fill")
                }
                .tag(3)

            Text("Offers Screen")
                .tabItem {
                    Label("Offers", systemImage: "star.fill")
                }
                .tag(4)
        }
        // Apply accent color for the selected tab item
         .tint(StarbucksOrderView.starbucksGreen)
    }
}

// MARK: - App Entry Point & Preview

// Main App Struct (if this is the entry point)
// @main
// struct StarbucksAppCloneApp: App {
//     var body: some Scene {
//         WindowGroup {
//             MainTabView()
//         }
//     }
// }

// Preview Provider
struct StarbucksOrderView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView() // Preview the entire TabView structure
            .ignoresSafeArea(edges: .all)
//            .preferredColorScheme(.dark) // Optional: Preview in dark mode
    }
}

// Custom Color Extension (if needed)
//extension Color {
//    static let starbucksGreen = Color(red: 0, green: 0.384, blue: 0.278) // #006241
//    // Add other custom Starbucks colors if necessary
//}
