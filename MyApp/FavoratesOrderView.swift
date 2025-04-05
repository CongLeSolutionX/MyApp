//
//  FavoratesOrderView.swift
//  MyApp
//
//  Created by Cong Le on 4/5/25.
//

import SwiftUI

// Define Starbucks colors for easy reuse
extension Color {
//    static let starbucksGreen = Color(red: 0/255, green: 112/255, blue: 74/255) // #00704A
//    static let starbucksDarkGreen = Color(red: 30/255, green: 57/255, blue: 50/255) // #1E3932
//    static let starbucksLightGray = Color(white: 0.95)
    static let starbucksMediumGray = Color(white: 0.6)
    static let starbucksDarkGray = Color(white: 0.3)
}

struct StarbucksFavoritesView: View {
    // State to manage selected tabs
    @State private var selectedTopTab: String = "Favorites"
    @State private var selectedBottomTab: String = "Order"

    let topTabs = ["Menu", "Featured", "Previous", "Favorites"]

    var body: some View {
        VStack(spacing: 0) {
            // 1. Custom Top Bar (Mimicking Navigation Bar)
            HStack {
                Spacer() // Pushes title to center
                Text("Order")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer() // Pushes search button to right
                Button {
                    // Search action
                } label: {
                    Image(systemName: "magnifyingglass")
                        .font(.title2)
                        .foregroundColor(.starbucksDarkGray)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
            .background(Color.white) // Or .starbucksLightGray if slightly off-white

            // 2. Top Tabs (Custom Segmented Control)
            HStack(spacing: 15) {
                ForEach(topTabs, id: \.self) { tab in
                    VStack(spacing: 8) {
                        Text(tab)
                            .font(.headline)
                            .fontWeight(selectedTopTab == tab ? .semibold : .regular)
                            .foregroundColor(selectedTopTab == tab ? .starbucksGreen : .starbucksMediumGray)
                            .onTapGesture {
                                selectedTopTab = tab
                            }

                        if selectedTopTab == tab {
                            Capsule()
                                .fill(Color.starbucksGreen)
                                .frame(height: 3)
                                //.matchedGeometryEffect(id: "underline", in: namespace) // Animation optional
                        } else {
                            Color.clear.frame(height: 3) // Placeholder for spacing
                        }
                    }
                }
                Spacer() // Pushes tabs to the left if needed
            }
            .padding(.horizontal)
            .padding(.top, 5)
            .background(Color.white) // Background for the tab area

            Divider() // Line below tabs

            // 3. Content Area
            ScrollView { // Make content scrollable if it exceeds screen height
                VStack(spacing: 15) {
                    // Placeholder for the illustration
                    Image(systemName: "photo") // Ensure you have this image asset
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200) // Adjust height as needed
                        .padding(.vertical, 30)

                    Text("Favorite items")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.starbucksDarkGray)

                    Text("Use the heart to save customizations. Your favorites will appear here to order again.")
                        .font(.subheadline)
                        .foregroundColor(.starbucksMediumGray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .lineSpacing(4)

                }
                .padding(.top, 20) // Spacing below the divider
                .frame(maxWidth: .infinity) // Center content horizontally
            }
            .background(Color.starbucksLightGray) // Background for the content area

            Spacer(minLength: 0) // Pushes Store Selector Bar to the bottom

            // 4. Store Selector Bar
            HStack(spacing: 15) {
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

                Button {
                    // Bag action
                } label: {
                    HStack(spacing: 2) {
                        Image(systemName: "bag")
                            .foregroundColor(.starbucksDarkGreen)
                        Text("0")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.starbucksDarkGreen)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(Color.white)
                    .cornerRadius(4)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
            .background(Color.starbucksDarkGreen)

            // 5. Bottom Tab View
            TabView(selection: $selectedBottomTab) {
                Text("Home Screen")
                    .tabItem { Label("Home", systemImage: "house") }
                    .tag("Home")

                Text("Scan Screen")
                    .tabItem { Label("Scan", systemImage: "squareshape.split.2x2") }
                    .tag("Scan")

                // This view's content would be embedded here in a real app
                Text("Order Screen (Placeholder)")
                    .tabItem { Label("Order", systemImage: "cup.and.saucer.fill") }
                    .tag("Order")

                Text("Gift Screen")
                    .tabItem { Label("Gift", systemImage: "gift") }
                    .tag("Gift")

                Text("Offers Screen")
                    .tabItem { Label("Offers", systemImage: "star.fill") }
                    .tag("Offers")
            }
            .accentColor(.starbucksGreen)
            // Set explicit height for the TabView *bar* itself if needed,
            // but usually automatic sizing works well.
             .frame(height: 50) // Standard tab bar height approx
        }
        .edgesIgnoringSafeArea(.bottom) // Allow Store Bar and TabView to extend to screen bottom
        .background(Color.starbucksLightGray.edgesIgnoringSafeArea(.all)) // Base background
    }
}

// Placeholder image for the preview
struct PlaceholderImage: View {
    var body: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.3))
            .overlay(Text("Illustration").foregroundColor(.gray))
    }
}

// Add this extension to your project if you need to load the image from Assets
//extension Image {
//    // Simple initializer for the placeholder
//    init(_ name: String, ifNotFoundUsePlaceholder placeholder: Bool = true) {
//        // In a real app, you'd use UIImage(named: name) != nil to check existence
//        // For this example, we assume "cassette_tapes_placeholder" doesn't exist
//        // and always show the placeholder visually in the code.
//        if name == "cassette_tapes_placeholder" && placeholder {
//             self = Image(systemName: "photo.artframe") // Or use a custom placeholder View
//                 // Adjust systemName or use a custom placeholder view if needed
//                 .resizable()
////                 .foregroundColor(.gray)
//
//        }
//        else {
//            self.init(name) // Attempt to load the actual image
//        }
//    }
//}

struct StarbucksFavoritesView_Previews: PreviewProvider {
    static var previews: some View {
        StarbucksFavoritesView()
    }
}
