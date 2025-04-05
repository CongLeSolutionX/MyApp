//
//  PreviousOrderView.swift
//  MyApp
//
//  Created by Cong Le on 4/5/25.
//

import SwiftUI

// --- Data Structures ---
struct OrderItem: Identifiable {
    let id = UUID()
    let name: String
    let size: String
    let calories: Int
    let imageName: String // Placeholder for image name/URL
}

struct OrderGroup: Identifiable {
    let id = UUID()
    let dateString: String
    let items: [OrderItem]
}

// --- Reusable Views ---

// Row for a single order item
struct OrderItemRow: View {
    let item: OrderItem

    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: item.imageName) // Replace with actual image loading
                .resizable()
                .scaledToFill()
                .frame(width: 70, height: 70)
                .clipShape(Circle())
                .background(Circle().fill(Color(UIColor.systemGray5))) // Placeholder background

            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.system(size: 18, weight: .medium))
                Text(item.size)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text("\(item.calories) Calories")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            Spacer() // Pushes buttons to the right

            HStack(spacing: 20) {
                Button { /* Add to favorites action */ } label: {
                    Image(systemName: "heart")
                        .font(.system(size: 22))
                        .foregroundColor(.green)
                }

                Button { /* Add to order action */ } label: {
                    Image(systemName: "plus.circle")
                        .font(.system(size: 28))
                        .foregroundColor(.green)
                }
            }
            .padding(.trailing, 5) // Add some padding from the edge

        }
        .padding(.vertical, 15)
        .padding(.horizontal)
        .background(Color.white) // Ensure white background for the row
    }
}

// Header for an order group (Date)
struct DateHeader: View {
    let dateString: String

    var body: some View {
        HStack {
            Text(dateString.uppercased())
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Color(UIColor.darkGray))
                .padding(.vertical, 8)
                .padding(.horizontal)
            Spacer()
        }
        .background(Color(UIColor.systemGray6)) // Light gray background
    }
}

// Custom Segmented Control / Tab Selector
struct OrderTypeSelector: View {
    @State private var selectedTab: Int = 2 // Default to "Previous"
    let tabs = ["Menu", "Featured", "Previous", "Favorites"]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs.indices, id: \.self) { index in
                VStack(spacing: 8) {
                    Text(tabs[index])
                        .font(.system(size: 16, weight: selectedTab == index ? .bold : .regular))
                        .foregroundColor(selectedTab == index ? .primary : .secondary)
                        .frame(maxWidth: .infinity) // Takes equal width

                    // Underline for selected tab
                    Rectangle()
                        .fill(selectedTab == index ? Color.green : Color.clear)
                        .frame(height: 3)
                }
                .contentShape(Rectangle()) // Makes the whole VStack tappable
                .onTapGesture {
                    selectedTab = index
                }
            }
        }
        .padding(.horizontal) // Add padding if needed
        .frame(height: 44) // Standard height for such controls
    }
}

// Bottom bar for store availability
struct StoreAvailabilityBar: View {
     var body: some View {
         HStack {
             VStack(alignment: .leading, spacing: 2) {
                 Text("For item availability")
                     .font(.caption)
                     .foregroundColor(.white.opacity(0.8))
                 Text("Choose a store")
                     .font(.headline)
                     .fontWeight(.bold)
                     .foregroundColor(.white)
             }
             Spacer()
             Image(systemName: "chevron.down")
                 .foregroundColor(.white)
                 .font(.callout)
             Button { /* Open Cart */ } label: {
                 Image(systemName: "basket")
                     .font(.title2)
                     .foregroundColor(.white)
                     .overlay(
                         ZStack {
                             Circle()
                                .fill(.white)
                             Text("0") // Badge Count
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.black)
                         }
                         .offset(x: 12, y: -10) // Adjust badge position
                         .frame(width: 18, height: 18)
                         // Hide badge if count is 0
                         // .opacity(cartItemCount > 0 ? 1 : 0)
                     )
             }
             .padding(.leading, 15) // Spacing before bag
         }
         .padding(.horizontal)
         .padding(.vertical, 10)
         .background(Color(red: 0.11, green: 0.22, blue: 0.20)) // Starbucks dark green
     }
 }

// --- Main View ---
struct PreviousOrdersView: View {
    // Sample Data (Replace with actual data source)
    let orderGroups: [OrderGroup] = [
        OrderGroup(dateString: "Apr 3 8:50 AM • In Store", items: [
            OrderItem(name: "Iced Caramel Macchiato", size: "Venti", calories: 350, imageName: "cup.and.saucer.fill")
        ]),
        OrderGroup(dateString: "Feb 17 1:59 PM • In Store", items: [
            OrderItem(name: "Iced Caramel Macchiato", size: "Venti", calories: 350, imageName: "cup.and.saucer.fill")
        ]),
        OrderGroup(dateString: "Feb 17 4:48 AM • In Store", items: [
            OrderItem(name: "Caramel Macchiato", size: "Grande", calories: 250, imageName: "mug.fill")
        ]),
    ]

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Custom Segmented Control
                OrderTypeSelector()

                // Separator Line
                Divider().background(Color(UIColor.systemGray4))

                // Scrollable List of Orders
                ScrollView {
                    LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                        ForEach(orderGroups) { group in
                            Section(header: DateHeader(dateString: group.dateString)) {
                                ForEach(group.items) { item in
                                    OrderItemRow(item: item)
                                    // Add divider between items if needed, but not after the last one in section
                                    if item.id != group.items.last?.id {
                                       Divider().padding(.leading)
                                    }
                                }
                            }
                        }
                    }
                }
                .background(Color(UIColor.systemGroupedBackground)) // Background for the scroll area

                 // Store Availability Bar at the bottom
                StoreAvailabilityBar()
            }
            .navigationTitle("Order")
            .navigationBarTitleDisplayMode(.inline) // Centers title
            .navigationBarItems(trailing:
                Button { /* Search Action */ } label: {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.primary) // Use primary color for adaptability
                }
            )
             // Hide the default navigation bar background if needed for custom look
             // .navigationBarBackground({ Color.white }) // Requires custom modifier or iOS 16+
        }
        // Note: This NavigationView doesn't include the main app TabView.
        // The whole PreviousOrdersView would typically be placed INSIDE a TabView structure.
    }
}

// --- Main App Structure (Example showing TabView integration) ---
struct MainAppView: View {
    var body: some View {
        TabView {
            Text("Home Screen")
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }

             Text("Scan Screen")
                .tabItem {
                    Label("Scan", systemImage: "qrcode.viewfinder")
                }

            // Embed the previous orders screen here
            PreviousOrdersView()
                .tabItem {
                    Label("Order", systemImage: "cup.and.saucer.fill") // Or custom icon
                }
                .tag(2) // Assign a tag

             Text("Gift Screen")
                .tabItem {
                    Label("Gift", systemImage: "gift.fill")
                }

             Text("Offers Screen")
                .tabItem {
                     Label("Offers", systemImage: "star.fill")
                }
        }
        .accentColor(.green) // Sets the tint color for selected tab items
    }
}

// --- Preview ---
struct PreviousOrdersView_Previews: PreviewProvider {
    static var previews: some View {
        // Preview the screen itself
        PreviousOrdersView()

        // Preview how it looks within the TabView structure
        // MainAppView()
    }
}
