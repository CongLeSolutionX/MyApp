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
        VStack(alignment: .leading, spacing: 5) { // Reduced spacing slightly
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
                    .padding(.bottom, 6) // Slightly more spacing below banner
            }

            // Top part: Name and Action Buttons
            HStack(alignment: .top) {
                Text(store.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .lineLimit(1) // Prevent wrapping if name is too long

                Spacer()

                HStack(spacing: 18) { // Slightly increased spacing
                    Image(systemName: store.isFavorite ? "heart.fill" : "heart")
                        .foregroundColor(store.isFavorite ? .starbucksGreen : .gray)
                    Image(systemName: "info.circle")
                        .foregroundColor(.gray)
                }
                .imageScale(.large)
            }

            // Address
            Text(store.address)
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.bottom, 1) // Minimal padding below address

            // Distance and Hours
            Text("\(store.distance) ⋅ \(store.hours)")
                .font(.subheadline)
                .foregroundColor(.gray)

            // Service Icons
            HStack(spacing: 15) {
                ForEach(store.services, id: \.self) { service in
                    VStack(spacing: 2) { // Reduced spacing in icon VStack
                        Image(systemName: service.iconName)
                            .foregroundColor(.gray)
                        Text(service.rawValue)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.top, 6) // Adjusted padding above icons
        }
        .padding(.vertical, 10) // Standard vertical padding for the row content
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
    // Use system gray for better light/dark mode adaptability
    static let groupedBackground = Color(.systemGroupedBackground)
    static let systemBackground = Color(.systemBackground)

    let orderTypes = ["Pickup", "Delivery"]
    let storeListTabs = ["Nearby", "Previous", "Favorites"]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // --- Top Bar ---
                HStack(spacing: 12) { // Adjusted spacing in top bar
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                        .imageScale(.large)

                    // Custom Segmented Control Look
                    Picker("Order Type", selection: $selectedOrderType) {
                        ForEach(0..<orderTypes.count, id: \.self) { index in
                             // We apply styling on the Picker, not individual Texts here
                            Text(orderTypes[index]).tag(index)
                        }
                    }
                    .pickerStyle(.segmented)
                    // Apply the border using background/clipShape for better control
                    .background(
                         Capsule().stroke(Self.starbucksGreen, lineWidth: 1)
                    )
                    .frame(maxWidth: 200) // Constrain width if needed

                    Spacer() // Pushes Skip button to the right

                    Button("Skip") {
                        // TODO: Handle Skip action
                    }
                    .foregroundColor(Self.starbucksGreen)
                    .fontWeight(.medium)
                }
                .padding(.horizontal, 16) // Standard horizontal padding
                .padding(.vertical, 10)  // Standard vertical padding
                .background(Self.systemBackground) // Use system background

                // --- Map Area ---
                ZStack(alignment: .bottomTrailing) {
                    Map(coordinateRegion: $mapRegion, showsUserLocation: true)
                         .overlay( // Simple overlay to mimic blue dot if needed for demo
                             Circle()
                                 .fill(.blue)
                                 .opacity(0.7)
                                 .frame(width: 15, height: 15)
                                 .overlay(Circle().stroke(.white, lineWidth: 2))
                                 // Position this precisely if needed, MapKit handles the real one
                         )

                    // Overlay Buttons on Map
                    VStack(spacing: 12) { // Adjusted spacing between map buttons
                        Button {
                            // TODO: Center map on user location
                        } label: {
                            Image(systemName: "location.fill")
                                .padding(12) // Adjusted padding inside circle
                                .background(.thinMaterial) // Use thinMaterial for better look
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.15), radius: 3, x: 0, y: 1) // Subtle shadow
                        }

                        Button {
                            // TODO: Show Filter options
                        } label: {
                             Text("Filter")
                                .fontWeight(.medium)
                                .padding(.horizontal, 25) // More horizontal padding
                                .padding(.vertical, 10)
                                .background(.thinMaterial) // Use thinMaterial
                                .clipShape(Capsule())
                                .shadow(color: .black.opacity(0.15), radius: 3, x: 0, y: 1) // Subtle shadow
                        }
                    }
                    .padding(16) // Standard padding for the VStack containing buttons
                    .foregroundColor(Self.starbucksGreen)
                }
                .frame(height: 250)

                // --- Store List Tabs ---
                Picker("Stores", selection: $selectedStoreListTab) {
                   ForEach(0..<storeListTabs.count, id: \.self) { index in
                       Text(storeListTabs[index]).tag(index)
                   }
               }
               .pickerStyle(.segmented)
               .padding(.horizontal, 16) // Standard horizontal padding
               .padding(.vertical, 10)   // Standard vertical padding
               .background(Self.groupedBackground) // Use grouped background

                // --- Store List ---
                List {
                    ForEach(stores) { store in
                        StoreRowView(store: store)
                           .listRowSeparator(.hidden) // Hide default separators
                           // Add custom divider precisely
                           .overlay(alignment: .bottom) {
                               // Ensure divider aligns with content padding
                               Divider().padding(.leading, 16)
                           }
                           // Standard row insets
                           .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                    }
                }
                .listStyle(.plain) // Use plain style
                .background(Self.groupedBackground) // Match tab background
                // Add top padding to separate list from picker visually if needed
                // .padding(.top, 1) // Optional: subtle space
            }
             // Only ignore bottom safe area if TabView handles top
             .ignoresSafeArea(edges: .bottom)
             .background(Self.groupedBackground) // Set overall background
             .navigationBarHidden(true)
        }
    }
}

// MARK: - TabView Wrapper (Main App Structure)

struct MainTabView: View {
    @State private var selectedTab = 2 // Default to "Order" tab (index 2)

    init() {
       // Customize Tab Bar appearance globally (ensure done only once)
       let appearance = UITabBarAppearance()
       appearance.configureWithOpaqueBackground()
       appearance.backgroundColor = UIColor.systemGray6 // Match typical tab bar background

       // Apply appearance settings
       UITabBar.appearance().standardAppearance = appearance
       if #available(iOS 15.0, *) {
           UITabBar.appearance().scrollEdgeAppearance = appearance
       }
       // Optional: Customize segmented control appearance globally
//       UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(StarbucksOrderView.starbucksGreen)
//       UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
//       UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.label], for: .normal)
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

            StarbucksOrderView()
                .tabItem {
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
        .tint(StarbucksOrderView.starbucksGreen) // Apply tint for selected item icon/text
    }
}

// MARK: - App Entry Point & Preview

// Main App Struct simulation
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
        MainTabView()
           // Remove ignoresSafeArea from preview if MainTabView handles it.
           // Test different states if needed
           // .preferredColorScheme(.dark)
    }
}
//
//// Custom Color Extension (Keep for consistency)
//extension Color {
//    static let starbucksGreen = Color(red: 0, green: 0.384, blue: 0.278) // #006241
//    // Add other custom Starbucks colors if necessary
//}
