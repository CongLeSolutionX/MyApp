//
//  StarbucksOrderView.swift
//  MyApp
//
//  Created by Cong Le on 4/2/25.
//


import SwiftUI
import MapKit // Needed for the Map view

// MARK: - Data Model (Unchanged)

struct Store: Identifiable {
    let id = UUID()
    let name: String
    let address: String
    let distance: String
    let hours: String
    let services: [ServiceType]
    var isFavorite: Bool // This determines the heart icon
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

// MARK: - Helper Views (Unchanged)

// Represents a single row in the store list (Used for Nearby/Favorites/Previous)
struct StoreRowView: View {
    let store: Store
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
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
                    .padding(.bottom, 6)
            }
            
            // Top part: Name and Action Buttons
            HStack(alignment: .top) {
                Text(store.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                
                Spacer()
                
                HStack(spacing: 18) {
                    Image(systemName: store.isFavorite ? "heart.fill" : "heart")
                        .foregroundColor(store.isFavorite ? StarbucksOrderView.starbucksGreen : .gray)
                    // Add tap gesture if needed to toggle favorite status
                    Image(systemName: "info.circle")
                        .foregroundColor(.gray)
                    // Add tap gesture for info if needed
                }
                .imageScale(.large)
            }
            
            // Address
            Text(store.address)
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.bottom, 1)
            
            // Distance and Hours
            // Note: Favorites might not always have an up-to-date distance.
            // Consider omitting it or adding a placeholder if distance isn't relevant here.
            Text("\(store.distance) ⋅ \(store.hours)")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            // Service Icons
            HStack(spacing: 15) {
                ForEach(store.services, id: \.self) { service in
                    VStack(spacing: 2) {
                        Image(systemName: service.iconName)
                            .foregroundColor(.gray)
                        Text(service.rawValue)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.top, 6)
        }
        .padding(.vertical, 10)
    }
}

// Generic View for empty states (Used for Previous/Favorites)
struct NoItemsView: View {
    let title: String
    let message: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(nil) // Allow wrapping
            Spacer()
        }
        .padding(.horizontal, 20) // Slightly more padding for isolated messages
        .padding(.top, 25)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(StarbucksOrderView.groupedBackground)
    }
}

// MARK: - Main Order View
struct StarbucksOrderView: View {
    @State private var selectedOrderType = 0
    @State private var selectedStoreListTab = 0
    @State private var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 33.74, longitude: -117.99),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )

    // Sample Data (Unchanged)
    @State private var nearbyStores: [Store] = [
        Store(name: "Brookhurst & Westminster", address: "13992 Brookhurst St, Garden Grove", distance: "0.9 mi", hours: "Open until 9:30 PM", services: [.inStore, .driveThru], isFavorite: true, bannerText: nil),
        Store(name: "Target Garden Grove 193", address: "13831 Brookhurst St, Garden Grove", distance: "0.9 mi", hours: "Open until 8:00 PM", services: [.inStore], isFavorite: false, bannerText: "Order ahead not available"),
        Store(name: "Magnolia & Trask", address: "13471 Magnolia St, Garden Grove", distance: "1.2 mi", hours: "Open until 8:30 PM", services: [.inStore, .driveThru], isFavorite: false, bannerText: nil)
    ]
    @State private var previousStores: [Store] = []
    @State private var favoriteStores: [Store] = [
        Store(name: "Brookhurst & Westminster", address: "13992 Brookhurst St, Garden Grove", distance: "0.9 mi", hours: "Open until 9:30 PM", services: [.inStore, .driveThru], isFavorite: true, bannerText: nil),
        Store(name: "Harbor & Chapman", address: "1290 S Harbor Blvd, Anaheim", distance: "2.5 mi", hours: "Open until 10:00 PM", services: [.inStore, .driveThru], isFavorite: true, bannerText: nil)
    ]

    // Constants (Unchanged)
    static let starbucksGreen = Color(red: 0, green: 0.384, blue: 0.278)
    static let groupedBackground = Color(.systemGroupedBackground)
    static let systemBackground = Color(.systemBackground)

    let orderTypes = ["Pickup", "Delivery"]
    let storeListTabs = ["Nearby", "Previous", "Favorites"]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // --- Top Bar ---
                HStack(spacing: 10) { // Reduced spacing slightly
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                        .imageScale(.large)
                        .padding(.leading, 5) // Small padding to bring closer to edge

                    Picker("Order Type", selection: $selectedOrderType.animation()) {
                        ForEach(0..<orderTypes.count, id: \.self) { index in
                            Text(orderTypes[index]).tag(index)
                        }
                    }
                    .pickerStyle(.segmented)
                    .background(Capsule().stroke(Self.starbucksGreen, lineWidth: 1))
                    .frame(maxWidth: 190) // Slightly reduced picker width allows more space

                    Spacer()

                    Button("Skip") { /* Action */ }
                        .foregroundColor(Self.starbucksGreen)
                        .fontWeight(.medium)
                        .padding(.trailing, 5) // Small padding to bring closer to edge
                }
                .padding(.horizontal, 16) // Standard edge padding
                .padding(.vertical, 10)
                .background(Self.systemBackground)

                // --- Conditional Content Area ---
                if selectedOrderType == 0 {
                    pickupView
                        .transition(.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .trailing)))
                } else {
                    DeliveryInfoView()
                        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                }
            }
            .background(selectedOrderType == 0 ? Self.groupedBackground : Self.systemBackground)
            .navigationBarHidden(true)
        }
    }

    // --- Extracted Pickup View (Padding Adjusted) ---
    private var pickupView: some View {
        VStack(spacing: 0) {
            // --- Map Area ---
            ZStack(alignment: .bottomTrailing) {
                Map(coordinateRegion: $mapRegion, showsUserLocation: true) // ... Map setup ...
                     .overlay(/* Marker */ Circle().fill(.blue).opacity(0.7).frame(width: 15, height: 15).overlay(Circle().stroke(.white, lineWidth: 2)))

                VStack(spacing: 12) {
                    Button { /* Center map */ } label: {
                        Image(systemName: "location.fill")
                            .padding(12) // Padding inside circle
                            .background(.thinMaterial)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.15), radius: 3, x: 0, y: 1)
                    }
                    Button { /* Filter */ } label: {
                        Text("Filter")
                            .fontWeight(.medium)
                            .padding(.horizontal, 25)
                            .padding(.vertical, 10) // Button height/padding
                            .background(.thinMaterial)
                            .clipShape(Capsule())
                            .shadow(color: .black.opacity(0.15), radius: 3, x: 0, y: 1)
                    }
                }
                .padding(16) // Padding from map edges
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
            .padding(.horizontal, 16) // Padding around picker
            .padding(.vertical, 12)    // Slightly more vertical padding for picker
            .background(Self.groupedBackground)

            // --- Conditional Store List/Message ---
            storeListContent
        }
        .background(Self.groupedBackground)
    }

    // --- Computed Property for Store List Content (Padding Adjusted) ---
    @ViewBuilder
    private var storeListContent: some View {
        switch selectedStoreListTab {
        case 0:
            storeListView(for: nearbyStores)
        case 1:
            if previousStores.isEmpty {
                NoItemsView(title: "No previous stores", message: "Once you order from a store, it will be here for you to choose.")
            } else {
                storeListView(for: previousStores)
            }
        case 2: // Favorites
            if favoriteStores.isEmpty {
                 NoItemsView(title: "No favorite stores", message: "Tap the heart icon on a store detail page to add it here.")
            } else {
                 storeListView(for: favoriteStores)
            }
        default:
            EmptyView()
        }
    }

    // Helper function for store list view (Padding Adjusted)
    @ViewBuilder
    private func storeListView(for stores: [Store]) -> some View {
        List {
            ForEach(stores) { store in
                StoreRowView(store: store)
                   .listRowSeparator(.hidden) // Hide default separators
                   .overlay(alignment: .bottom) { // Add custom separator
                       Divider().padding(.leading, 16) // Match leading inset
                   }
                   // Control row padding precisely:
                   .listRowInsets(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))
            }
        }
        .listStyle(.plain) // Use plain style for seamless background
        .background(Self.groupedBackground) // Important for list background
        .scrollContentBackground(.hidden) // Hide default list background
    }
}

// MARK: - Preview Provider
struct StarbucksOrderView_Previews: PreviewProvider {
    static var previews: some View {
         MainTabView()
            .environment(\.locale, .init(identifier: "en"))
            .previewDisplayName("Live Preview (Main Tab)")

         DeliveryInfoView()
            .previewDisplayName("Delivery Info View Standalone")

        StarbucksOrderView()
             .previewDisplayName("Pickup View (Forced)")

         StarbucksOrderView()
            .previewDisplayName("Delivery View (Forced)")
    }
}
// MARK: - TabView Wrapper (Main App Structure - Unchanged)
//
//struct MainTabView: View {
//    @State private var selectedTab = 2 // Default to "Order" tab (index 2)
//    
//    init() {
//        // Configure Tab Bar Appearance (Unchanged)
//        let appearance = UITabBarAppearance()
//        appearance.configureWithOpaqueBackground()
//        appearance.backgroundColor = UIColor.systemGray6 // Or your desired color
//        
//        UITabBar.appearance().standardAppearance = appearance
//        if #available(iOS 15.0, *) {
//            UITabBar.appearance().scrollEdgeAppearance = appearance
//        }
//    }
//    
//    var body: some View {
//        TabView(selection: $selectedTab) {
//            Text("Home Screen")
//                .tabItem { Label("Home", systemImage: "house.fill") }
//                .tag(0)
//            
//            Text("Scan Screen")
//                .tabItem { Label("Scan", systemImage: "qrcode.viewfinder") }
//                .tag(1)
//            
//            StarbucksOrderView() // Contains the logic for Nearby/Previous/Favorites
//                .tabItem { Label("Order", systemImage: "cup.and.saucer.fill") }
//                .tag(2)
//            
//            Text("Gift Screen")
//                .tabItem { Label("Gift", systemImage: "gift.fill") }
//                .tag(3)
//            
//            Text("Offers Screen")
//                .tabItem { Label("Offers", systemImage: "star.fill") }
//                .tag(4)
//        }
//        .tint(StarbucksOrderView.starbucksGreen) // Set the tint color for selected tab items
//    }
//}

// MARK: - App Entry Point & Preview (Unchanged)

// Main App Definition (Example)
// @main
// struct StarbucksCloneApp: App {
//     var body: some Scene {
//         WindowGroup {
//             MainTabView()
//         }
//     }
// }

//struct StarbucksOrderView_Previews: PreviewProvider {
//    static var previews: some View {
//        // Preview Pickup state
//        MainTabView()
//            .environment(\.locale, .init(identifier: "en"))
//            .previewDisplayName("Pickup View (Default)")
//
//        // Preview Delivery state (select Order tab, then Delivery)
//        // You might need to interact with the preview or force the state
//        //         StarbucksOrderView(selectedOrderType: 1)
//        StarbucksOrderView()
//            .previewDisplayName("Delivery View (Forced)")
//
//        // Preview the standalone Delivery Info View
//        DeliveryInfoView()
//            .previewDisplayName("Delivery Info View Standalone")
//
//    }
//}
//
//// MARK: - Custom Color Extension (Unchanged)
//extension Color {
//    static let starbucksGreen = Color(red: 0, green: 0.384, blue: 0.278)
//}

