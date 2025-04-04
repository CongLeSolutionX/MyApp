//
//  StarbucksGiftCardView.swift
//  MyApp
//
//  Created by Cong Le on 4/2/25.
//

import SwiftUI

// MARK: - Main View Structure

struct StarbucksGiftCardView: View {
    // State to manage the selected tab, defaulting to 'Gift'
    @State private var selectedTab: Tab = .gift

    // Enum for Tab Bar items
    enum Tab {
        case home, scan, order, gift, offers
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            // Placeholder views for other tabs
            Text("Home Screen").tabItem { Label("Home", systemImage: "house") }.tag(Tab.home)
            Text("Scan Screen").tabItem { Label("Scan", systemImage: "qrcode") }.tag(Tab.scan)
            Text("Order Screen").tabItem { Label("Order", systemImage: "cup.and.saucer") }.tag(Tab.order)

            // Gift Card Screen Content
            GiftCardContentView()
                .tabItem { Label("Gift", systemImage: "gift.fill") } // Use filled icon for selected state
                .tag(Tab.gift)

            Text("Offers Screen").tabItem { Label("Offers", systemImage: "star") }.tag(Tab.offers)
        }
        // Accent color for the selected tab item
        .accentColor(Color(red: 0, green: 0.4, blue: 0.2)) // Starbucks Green Approximation
    }
}

// MARK: - Gift Card Screen Content

struct GiftCardContentView: View {
    var body: some View {
        NavigationView { // Add NavigationView for the title and top icon
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    addCardSection()
                        .padding(.horizontal)

                    groupGiftingSection()
                        .padding(.horizontal)

                    featuredSection()
                        // No horizontal padding for full-width scroll

                    birthdaySection()
                        // No horizontal padding for full-width scroll

                    // Add more sections if needed (e.g., Thank You, Celebration)
                    Spacer() // Pushes content to the top
                }
                .padding(.top) // Add some padding below the navigation title
            }
            .navigationTitle("Gift cards")
            .navigationBarItems(trailing: Button(action: {
                // Action for the receipt icon
                print("Receipt icon tapped")
            }) {
                Image(systemName: "list.bullet.rectangle.portrait") // SF Symbol for receipt/list
                    .foregroundColor(.primary) // Use primary color for adaptability
            })
            .background(Color(.systemGray6)) // Background color similar to the screenshot
        }
        .navigationViewStyle(StackNavigationViewStyle()) // Use Stack style for standard behavior
    }

    // MARK: - Section Views

    @ViewBuilder
    private func addCardSection() -> some View {
        HStack(spacing: 15) {
            Image(systemName: "creditcard") // Placeholder icon
                .font(.title2)
                .foregroundColor(.secondary)

            VStack(alignment: .leading) {
                Text("Got a gift card? Add it here")
                    .font(.headline)
                    .fontWeight(.medium)
                Text("Earns 2★ per $1")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .bold() // Make the star text bold like the screenshot
            }
            Spacer() // Pushes content to the left
        }
        .padding()
        .background(Color(.systemBackground)) // White/Black background
        .cornerRadius(10)
    }

    @ViewBuilder
    private func groupGiftingSection() -> some View {
        HStack(spacing: 15) {
             Image(systemName: "giftcard.fill") // Placeholder icon (or use a custom image)
                 .font(.largeTitle)
                 .foregroundColor(Color(red: 0, green: 0.4, blue: 0.2)) // Starbucks Green
                 // .renderingMode(.template) // If using a custom monochrome image asset

            VStack(alignment: .leading, spacing: 8) {
                Text("Effortlessly send up to 10 eGifts per purchase on Starbucks.com")
                    .font(.subheadline)
                    .lineLimit(nil) // Allow text wrapping

                Button("Start group gifting") {
                    // Action for the button
                    print("Start group gifting tapped")
                }
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.vertical, 10)
                .padding(.horizontal, 20)
                .background(Color.black)
                .clipShape(Capsule())
            }
             Spacer() // Pushes content to the left
        }
        .padding()
        .background(Color(.systemBackground)) // White/Black background
        .cornerRadius(10)
    }

    @ViewBuilder
    private func featuredSection() -> some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Featured")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Button("See all 8") {
                     // Action for see all
                    print("See all Featured tapped")
                }
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(Color(red: 0, green: 0.4, blue: 0.2)) // Starbucks Green
            }
            .padding(.horizontal) // Add padding only to the header

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    // Placeholder cards - replace with actual data/images
                    GiftCardImage(imageName: "My-meme-red-wine-glass", isLarge: true)
                    GiftCardImage(imageName: "My-meme-heineken", isLarge: true)
                    GiftCardImage(imageName: "My-meme-microphone", isLarge: true)
                }
                .padding(.horizontal) // Padding for the content inside scroll view
                .padding(.bottom) // Padding below the scroll view
            }
        }
    }

     @ViewBuilder
     private func birthdaySection() -> some View {
         VStack(alignment: .leading) {
             Text("BIRTHDAY")
                 .font(.caption)
                 .fontWeight(.medium)
                 .foregroundColor(.secondary)
                 .padding(.horizontal) // Add padding only to the header

             ScrollView(.horizontal, showsIndicators: false) {
                 HStack(spacing: 15) {
                     // Placeholder cards - replace with actual data/images
                     GiftCardImage(imageName: "My-meme-red-wine-glass", isLarge: false)
                     GiftCardImage(imageName: "My-meme-heineken", isLarge: false)
                     GiftCardImage(imageName: "My-meme-microphone", isLarge: false)
                 }
                 .padding(.horizontal) // Padding for the content inside scroll view
                 .padding(.bottom) // Padding below the scroll view
             }
         }
     }
}

// MARK: - Reusable Gift Card Image View

struct GiftCardImage: View {
    let imageName: String
    let isLarge: Bool // To adjust size and logo position/size

    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Placeholder using system background or a loaded image
            Image(imageName) // Assume you have these images in your assets
                .resizable()
                .aspectRatio(contentMode: .fill) // Use fill to mimic card look
                .background(Color.gray.opacity(0.3)) // Background if image fails
                .frame(width: isLarge ? 280 : 180, height: isLarge ? 180 : 110)
                .clipped() // Clip the image to the frame

            Image("My-meme-original") // starbucks_logo_white // Assume a white logo asset exists
                .resizable()
                .scaledToFit()
                .frame(width: isLarge ? 35 : 25, height: isLarge ? 35 : 25)
                .padding(isLarge ? 12 : 8) // Adjust padding based on size
        }
        .cornerRadius(10) // Apply corner radius to the ZStack
        .shadow(radius: 3, x: 2, y: 2) // Subtle shadow
    }
}

// MARK: - Preview Provider

#Preview("Starbucks Gift Card View") {
    StarbucksGiftCardView()
        // Add mock image assets to the preview environment if needed
        // .environment(\.imageProvider, MockImageProvider())
}

// Note: You would need to add placeholder images named:
// "placeholder_flower_card", "placeholder_yellow_card", "placeholder_generic_card",
// "placeholder_birthday_cake_card", "placeholder_happy_bday_card", "placeholder_generic_card_small",
// and "starbucks_logo_white" to your Asset Catalog for this preview to work visually.
// You'd also replace system icons like "creditcard" and "giftcard.fill" with actual image assets
// from Starbucks for a perfect match.
