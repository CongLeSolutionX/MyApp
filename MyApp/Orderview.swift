////
////  Orderview.swift
////  MyApp
////
////  Created by Cong Le on 4/5/25.
////
//
//import SwiftUI
//
//// MARK: - Data Model
//struct MenuItem: Identifiable {
//    let id = UUID()
//    let name: String
//    let imageName: String // Use system names for placeholders
//}
//
//// MARK: - Reusable Components
//
//// Represents a single drink category row
//struct DrinkItemRow: View {
//    let item: MenuItem
//
//    var body: some View {
//        HStack(spacing: 15) {
//            Image(systemName: item.imageName) // Placeholder Image
//                .resizable()
//                .scaledToFit()
//                .frame(width: 60, height: 60)
//                .padding(5) // Add padding *inside* the circle background if needed
//                .background(Color.starbucksDarkGreen.opacity(0.9)) // Dark background for contrast
//                .clipShape(Circle())
//                .foregroundColor(.white) // Color for the SF Symbol
//
//            Text(item.name)
//                .font(.system(size: 18, weight: .medium))
//                .lineLimit(2) // Allow text wrapping like "Frappuccino..."
//                .fixedSize(horizontal: false, vertical: true) // Allow vertical expansion
//
//            Spacer() // Push content to the left
//        }
//        .padding(.vertical, 8)
//    }
//}
//
//// MARK: - Main Order View
//struct MainOrderView: View {
//    @State private var selectedMenuCategory: String = "Menu"
//    let menuCategories = ["Menu", "Featured", "Previous", "Favorites"]
//
//    // Sample Data
//    let drinkItems: [MenuItem] = [
//        MenuItem(name: "Hot Coffee", imageName: "cup.and.saucer.fill"),
//        MenuItem(name: "Cold Coffee", imageName: "takeoutbag.and.cup.and.straw.fill"), // Using related symbols
//        MenuItem(name: "Hot Tea", imageName: "cup.and.saucer"),
//        MenuItem(name: "Cold Tea", imageName: "mug.fill"), // Adjust symbols as needed
//        MenuItem(name: "Refreshers", imageName: "drop.fill"),
//        MenuItem(name: "Frappuccino®\nBlended Beverage", imageName: "cloud.sleet.fill") // Example multi-line
//    ]
//
//    var body: some View {
//        NavigationView {
//            VStack(spacing: 0) {
//                // Horizontal Menu Categories
//                ScrollView(.horizontal, showsIndicators: false) {
//                    HStack(spacing: 25) {
//                        ForEach(menuCategories, id: \.self) { category in
//                            VStack(spacing: 8) {
//                                Text(category)
//                                    .font(.system(size: 16, weight: .semibold))
//                                    .foregroundColor(selectedMenuCategory == category ? .primary : .secondary)
//                                    .onTapGesture {
//                                        selectedMenuCategory = category
//                                    }
//
//                                // Selection Indicator
//                                if selectedMenuCategory == category {
//                                    Capsule()
//                                        .fill(Color.starbucksGreen)
//                                        .frame(height: 3)
//                                } else {
//                                    Capsule()
//                                        .fill(Color.clear) // Placeholder to keep height consistent
//                                        .frame(height: 3)
//                                }
//                            }
//                        }
//                    }
//                    .padding(.horizontal)
//                    .padding(.top, 10) // Add some space from the nav bar
//                }
//                .frame(height: 50) // Fixed height for the menu scroll
//
//                Divider() // Separator below menu tabs
//
//                // Main Content Scroll (Drinks List)
//                ScrollView {
//                    VStack(alignment: .leading, spacing: 0) {
//                        // Drinks Section Header
//                        HStack {
//                            Text("Drinks")
//                                .font(.system(size: 24, weight: .bold))
//                            Spacer()
//                            Button("See all 127") {
//                                // Action for see all
//                            }
//                            .font(.system(size: 16, weight: .semibold))
//                            .foregroundColor(Color.starbucksGreen)
//                        }
//                        .padding(.horizontal)
//                        .padding(.top, 20)
//                        .padding(.bottom, 10)
//
//                        // Drinks List
//                        VStack(spacing: 0) {
//                            ForEach(drinkItems) { item in
//                                DrinkItemRow(item: item)
//                                    .padding(.horizontal) // Apply padding here for alignment
//                                Divider().padding(.leading, 90) // Indented divider
//                            }
//                        }
//                    }
//                }
//                 // The thin grey line on the right seems like a scroll indicator,
//                 // not a persistent UI element, so not explicitly added.
//
//            }
//            .navigationTitle("Order")
//            .navigationBarTitleDisplayMode(.large) // Matches the large title style
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button {
//                        // Action for search
//                    } label: {
//                        Image(systemName: "magnifyingglass")
//                            .foregroundColor(.primary)
//                    }
//                }
//            }
//            // Sticky Store Selector at the bottom
//            .safeAreaInset(edge: .bottom) {
//                StoreSelectorBar()
//            }
//        }
//    }
//}
//
//// MARK: - Store Selector Bar (Sticky Bottom)
//struct StoreSelectorBar: View {
//    var body: some View {
//        HStack {
//            VStack(alignment: .leading) {
//                Text("For item availability")
//                    .font(.caption)
//                    .foregroundColor(.white.opacity(0.8))
//                Text("Choose a store")
//                    .font(.headline)
//                    .fontWeight(.bold)
//                    .foregroundColor(.white)
//            }
//
//            Spacer()
//
//            Image(systemName: "chevron.down")
//                .foregroundColor(.white)
//                .padding(.trailing, 10)
//
//            Image(systemName: "bag")
//                .foregroundColor(.white)
//                .overlay(
//                    // Badge for item count
//                    ZStack {
//                        Circle()
//                            .fill(.white)
//                        Text("0") // Example count
//                            .font(.system(size: 10, weight: .bold))
//                            .foregroundColor(Color.starbucksDarkGreen)
//                    }
//                    .offset(x: 10, y: -10) // Position the badge
//                    .frame(width: 16, height: 16) // Badge size
//                    .opacity(0) // Hide badge if count is 0, as in screenshot
//                                // Set opacity to 1 and change Text to show badge
//                )
//        }
//        .padding()
//        .background(Color.starbucksDarkGreen) // Dark green background
//        .frame(height: 60) // Approximate height
//    }
//}
//
//// MARK: - Main TabView Structure
//struct OrderView: View {
//    var body: some View {
//        TabView {
//            // Placeholder Views for other tabs
//            Text("Home Tab")
//                .tabItem {
//                    Label("Home", systemImage: "house.fill")
//                }
//
//            Text("Scan Tab")
//                .tabItem {
//                    Label("Scan", systemImage: "qrcode.viewfinder")
//                }
//
//            MainOrderView() // Our implemented Order screen
//                .tabItem {
//                    Label("Order", systemImage: "cup.and.saucer.fill") // Or other suitable icon
//                }
//                .tag("Order") // Tag for potential state management
//
//            Text("Gift Tab")
//                .tabItem {
//                    Label("Gift", systemImage: "gift.fill")
//                }
//
//            Text("Offers Tab")
//                .tabItem {
//                    Label("Offers", systemImage: "star.fill")
//                }
//        }
//        .accentColor(Color.starbucksGreen) // Set the highlight color for the selected tab
//    }
//}
//
//// MARK: - Custom Colors
////extension Color {
////    static let starbucksGreen = Color(red: 0, green: 0.45, blue: 0.29) // Approximate green
////    static let starbucksDarkGreen = Color(red: 0.07, green: 0.23, blue: 0.19) // Approximate dark green for bar
////}
//
//// MARK: - Preview
//struct OrderView_Previews: PreviewProvider {
//    static var previews: some View {
//        MainOrderView()
//            .previewDisplayName("MainOrderView")
//    }
//}
//
//#Preview() {
//    OrderView()
//}
