//
//  CategoryTabView.swift
//  MyApp
//
//  Created by Cong Le on 4/5/25.
//

import SwiftUI

// MARK: - Data Models

struct MenuItem: Identifiable {
    let id = UUID()
    let name: String
    let imageName: String // Use SF Symbols or asset names
}

struct MenuSection: Identifiable {
    let id = UUID()
    let title: String
    let items: [MenuItem]
    let itemCount: Int // To display in "See all X"
}

// MARK: - Helper Views

// Represents the horizontal list of categories (Menu, Featured, etc.)
struct CategoryTabView: View {
    let categories = ["Menu", "Featured", "Previous", "Favorites"]
    @State private var selectedIndex = 1 // "Featured" is selected initially

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                ForEach(categories.indices, id: \.self) { index in
                    VStack {
                        Text(categories[index])
                            .font(.headline)
                            .fontWeight(selectedIndex == index ? .bold : .regular)
                            .foregroundColor(selectedIndex == index ? .primary : .gray)
                            .onTapGesture {
                                selectedIndex = index
                            }

                        if selectedIndex == index {
                            Color.starbucksGreen // Underline for selected tab
                                .frame(height: 2)
                                .padding(.horizontal, -5) // Adjust padding as needed
                        } else {
                            Color.clear.frame(height: 2) // Placeholder for alignment
                                 .padding(.horizontal, -5)
                        }
                    }
                }
            }
            .padding(.horizontal) // Padding for the whole HStack
        }
        .frame(height: 40) // Give the category tab view a defined height
    }
}

// Represents a single item card (Image + Text)
struct ItemCardView: View {
    let item: MenuItem

    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            ZStack {
                 Circle()
                    .fill(Color.starbucksDarkGreen) // Background for the circle image area
                    .frame(width: 100, height: 100) // Size of the circle background

                // Use actual image name or SF Symbol placeholder
                Image(systemName: item.imageName) // Replace with Image(item.imageName) for assets
                    .resizable()
                    .scaledToFit() // Use scaledToFit to avoid distortion if not square
                    .foregroundColor(.white) // Color for SF Symbol placeholder
                    // .scaledToFill() // Use if images are meant to fill the circle
                    .frame(width: 80, height: 80) // Adjust image size within circle
                    // .clipShape(Circle()) // Clip the image itself if needed, ZStack clip is primary
            }
            .clipShape(Circle()) // Clip the ZStack to ensure circular shape

            Text(item.name)
                .font(.subheadline)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .frame(width: 100, height: 40) // Fixed frame to handle text wrapping
        }
        .padding(.bottom) // Add padding below the text
    }
}

// Represents a full section (Title, See All, Horizontal ScrollView of Items)
struct SectionView: View {
    let section: MenuSection

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(section.title)
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Button("See all \(section.itemCount)") {
                    print("Navigate to see all \(section.title)")
                    // Action for "See all" button
                }
                .font(.headline)
                .foregroundColor(.starbucksGreen)
            }
            .padding(.horizontal)
            .padding(.top) // Add padding above the section header

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 15) { // Align items to the top
                    ForEach(section.items) { item in
                        ItemCardView(item: item)
                    }
                }
                .padding(.horizontal) // Padding inside the scroll view
                .padding(.bottom) // Padding below the scrollview contents
            }
        }
    }
}

// Represents the bottom bar for store selection
struct ChooseStoreBar: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("For item availability")
                    .font(.caption)
                Text("Choose a store")
                    .font(.headline)
                    .fontWeight(.bold)
            }

            Spacer()

            Image(systemName: "chevron.down")
                .font(.headline)

            Spacer().frame(width: 20) // Spacing before bag icon

            ZStack(alignment: .topTrailing) {
                 Image(systemName: "bag")
                    .font(.title2)

                 Text("0")
                    .font(.caption2)
                    .foregroundColor(.white)
                    .padding(4)
                    .background(Color.starbucksGreen)
                    .clipShape(Circle())
                    .offset(x: 8, y: -8) // Adjust badge position
            }
        }
        .padding()
        .background(Color.starbucksDarkGreen)
        .foregroundColor(.white) // Default text color for this bar
    }
}

// MARK: - Main Order View

struct OrderView: View {
    // Sample Data
    let sections: [MenuSection] = [
        MenuSection(title: "Spring Favorites", items: [
            MenuItem(name: "Iced Lavender Cream Oatmilk Matcha", imageName: "cup.and.saucer"), // Placeholder icon
            MenuItem(name: "Lavender Oatmilk Latte", imageName: "mug"),
            MenuItem(name: "Blonde Roast - Sunsera", imageName: "cup.and.saucer.fill"),
            MenuItem(name: "Something Else", imageName: "takeoutbag.and.cup.and.straw")
        ], itemCount: 7),
        MenuSection(title: "Vegetarian Selections", items: [
            MenuItem(name: "Spicy Falafel Pocket", imageName: "bagel"), // Placeholder icon
            MenuItem(name: "Egg, Pesto & Mozzarella Sandwich", imageName: "sandwich"),
            MenuItem(name: "Potato, Cheddar & Chive Bakes", imageName: "muffin"),
             MenuItem(name: "Impossible™ Breakfast Sandwich", imageName: "leaf")
        ], itemCount: 8)
    ]

    var body: some View {
        // Using VStack instead of NavigationView to have more control over layout
        // and avoid large title behavior issues combined with custom elements below it.
        VStack(spacing: 0) {
            // Custom Navigation Area
             HStack {
                Spacer() // Pushes title to center if needed, adjust if title is leading
                Text("Order")
                   .font(.title) // Or .headline for a smaller nav-bar like title
                   .fontWeight(.semibold)
                   .padding(.leading) // Add leading padding in case search icon pushes it
                Spacer()
                 Button {
                    // Search action
                 } label: {
                    Image(systemName: "magnifyingglass")
                        .font(.title2)
                        .foregroundColor(.primary)
                 }
             }
             .padding(.horizontal)
             .padding(.top, 5) // Minimal top padding
             .padding(.bottom, 10) // Padding below title/search row

            CategoryTabView() // The horizontal category selector

            Divider() // Optional divider below categories

            // Main Scrollable Content
            ScrollView(.vertical, showsIndicators: false) {
                 VStack(spacing: 0) { // Use spacing 0 if SectionView manages its own top padding
                    ForEach(sections) { section in
                        SectionView(section: section)
                        Divider().padding(.horizontal) // Optional divider between sections
                    }
                 }
            }
            .background(Color(UIColor.systemGray6)) // Light background for scroll area

            // Fixed Bottom Bar
            ChooseStoreBar()
        }
        .edgesIgnoringSafeArea(.bottom) // Allow ChooseStoreBar to go to screen bottom edge
                                       // before TabView takes over.

    }
}

// MARK: - Root View (TabView Holder)

struct FeaturedOrderContentView: View {
    @State private var selectedTab = 2 // Start with "Order" selected

    init() {
         // Customize TabView appearance if needed (e.g., background color)
         UITabBar.appearance().backgroundColor = UIColor.systemGray5 // Example background color
         UITabBar.appearance().unselectedItemTintColor = UIColor.gray // Example unselected color
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            Text("Home Screen")
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .tag(0)

            Text("Scan Screen")
                .tabItem {
                    Label("Scan", systemImage: "qrcode.viewfinder")
                }
                .tag(1)

            // Embed the OrderView here
            OrderView()
                .tabItem {
                    Label("Order", systemImage: "cup.and.saucer.fill") // Use appropriate icon
                }
                .tag(2)

             Text("Gift Screen")
                .tabItem {
                    Label("Gift", systemImage: "gift")
                }
                .tag(3)

            Text("Offers Screen")
                .tabItem {
                    Label("Offers", systemImage: "star")
                }
                .tag(4)
        }
        .accentColor(.starbucksGreen) // Sets the selected tab item color
    }
}

// MARK: - Custom Colors (Add to Asset Catalog or Define Here)

//extension Color {
//    static let starbucksGreen = Color(red: 0, green: 0.43, blue: 0.29) // Approximate RGB
//    static let starbucksDarkGreen = Color(red: 0.1, green: 0.25, blue: 0.2) // Approximate Darker Shade
//}

// MARK: - Preview

struct FeaturedOrderContentViews_Previews: PreviewProvider {
    static var previews: some View {
        FeaturedOrderContentView()
    }
}
