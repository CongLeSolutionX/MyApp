//
//  NewView.swift
//  MyApp
//
//  Created by Cong Le on 4/5/25.
//

import SwiftUI

// Define Starbucks Green color for reuse
//extension Color {
//    static let starbucksGreen = Color(red: 0, green: 0.4, blue: 0.2) // Approximate
//    static let lightGrayBackground = Color(UIColor.systemGray6)
//}

// Main View Structure
struct NewHomeView: View {
    var body: some View {
        ZStack(alignment: .bottom) {
            // TabView contains the main app sections
            TabView {
                HomeView()
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }

                // Placeholder views for other tabs
                Text("Scan Screen")
                    .tabItem {
                        Label("Scan", systemImage: "qrcode")
                    }
                Text("Order Screen")
                    .tabItem {
                        Label("Order", systemImage: "cup.and.saucer.fill") // Alternative: takeoutbag.and.cup.and.straw
                    }
                Text("Gift Screen")
                    .tabItem {
                        Label("Gift", systemImage: "gift.fill")
                    }
                Text("Offers Screen")
                    .tabItem {
                        Label("Offers", systemImage: "star.fill")
                    }
            }
            .accentColor(.starbucksGreen) // Set selected tab item color

            // Floating "Scan in store" Button
            ScanInStoreButton()
                .padding(.bottom, 50) // Adjust padding to position above tab bar
        }
    }
}

// Home Screen Content
struct HomeView: View {
    var body: some View {
        VStack(spacing: 0) {
            TopBar()
            ScrollView {
                VStack(spacing: 20) {
                    PromotionCard(
                        imageName: "My-meme-original", // Use actual asset name
                        title: "Cherry meets chai",
                        description: "The new Iced Cherry Chai is where creamy cold foam with notes of cherry and our signature chai tea latte come together for a spring take on a favorite.",
                        buttonText: "Add to order"
                    )

                    PromotionCard(
                        imageName: "My-meme-heineken", // Use actual asset name
                        title: "Lavender love",
                        description: "With sweet, subtle floral notes and a smooth texture. the Iced Lavender Cream Oatmilk Matcha...", // Truncated description
                        buttonText: nil // No button inside this card per layout
                    )
                    // Add more cards as needed
                }
                .padding(.vertical) // Add padding top/bottom for the scroll content
            }
            .background(Color.lightGrayBackground) // Background for the scrollable area
        }
    }
}

// Custom Top Bar
struct TopBar: View {
    var body: some View {
        HStack(spacing: 15) {
            Button(action: {}) {
                HStack {
                    Image(systemName: "envelope")
                        .font(.title2)
                    Text("Inbox")
                }
            }

            Button(action: {}) {
                HStack {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.title2)
                    Text("Stores")
                }
            }

            Spacer() // Pushes content to the sides

            Button(action: {}) {
                // Using a Receipt-like SF Symbol - adjust if needed
                Image(systemName: "list.bullet.rectangle.portrait")
                    .font(.title2)
            }

            Button(action: {}) {
                Image(systemName: "person.circle")
                    .font(.title2)
            }
        }
        .padding()
        .foregroundColor(.black) // Set icon/text color
        .background(Color.white) // White background for the top bar
        .overlay(
            Divider(), alignment: .bottom // Adds a subtle line below the top bar
        )
    }
}

// Reusable Promotional Card View
struct PromotionCard: View {
    let imageName: String
    let title: String
    let description: String
    let buttonText: String? // Optional button text

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Image(imageName) // Load image from Assets
                .resizable()
                .aspectRatio(contentMode: .fill)
                // Adjust height as needed, maybe based on screen width?
                .frame(height: 200)
                .clipped() // Prevents image from overflowing frame

            VStack(alignment: .leading, spacing: 10) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)

                Text(description)
                    .font(.body)
                    .foregroundColor(.gray) // Slightly lighter text

                // Conditionally show the button
                if let buttonText = buttonText {
                    Button(action: {}) {
                        Text(buttonText)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .foregroundColor(.white)
                            .background(Color.starbucksGreen)
                            .clipShape(Capsule())
                    }
                    .padding(.top, 5) // Space above the button
                }
            }
            .padding() // Padding around the text/button content
        }
        .background(Color.white) // Card background
        .cornerRadius(8) // Rounded corners for the card
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2) // Subtle shadow
        .padding(.horizontal) // Add horizontal padding to inset cards from screen edge
    }
}

// Floating "Scan in store" Button
struct ScanInStoreButton: View {
    var body: some View {
        Button(action: {}) {
            Text("Scan in store")
                .font(.headline)
                .fontWeight(.bold)
                .padding(.horizontal, 30)
                .padding(.vertical, 15)
                .foregroundColor(.white)
                .background(Color.starbucksGreen)
                .clipShape(Capsule())
                .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 3) // Make shadow more pronounced
        }
    }
}

// Preview Provider
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        NewHomeView()
            // Add placeholder images to assets for preview to work
            .environment(\.colorScheme, .light) // Set preview to light mode
    }
}

// Add placeholder image names to your Assets.xcassets folder:
// - cherry_chai_image
// - lavender_latte_image
// You can use any actual image for preview purposes.
