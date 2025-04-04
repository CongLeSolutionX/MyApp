//
//  OfferView.swift
//  MyApp
//
//  Created by Cong Le on 4/2/25.
//

import SwiftUI

// MARK: - Main Content View with Tab Bar

struct OfferView: View {
    @State private var selectedTab: Int = 4 // Start with Offers selected

    // Define the Starbucks green color
    let starbucksGreen = Color(red: 0, green: 0.4, blue: 0.2)

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

            Text("Order Screen")
                .tabItem {
                    Label("Order", systemImage: "cup.and.saucer")
                }
                .tag(2)

            Text("Gift Screen")
                .tabItem {
                    Label("Gift", systemImage: "gift")
                }
                .tag(3)

            OffersScreenView()
                .tabItem {
                    // Use star.fill when selected, star otherwise
                    Label("Offers", systemImage: selectedTab == 4 ? "star.fill" : "star")
                }
                .tag(4)
        }
        // Apply the accent color for the selected tab item
        .accentColor(starbucksGreen)
    }
}

// MARK: - Offers Screen View

struct OffersScreenView: View {
    let starbucksGreen = Color(red: 0, green: 0.4, blue: 0.2)
    let lightGreenBackground = Color(red: 0.8, green: 0.95, blue: 0.8) // Approximate

    var body: some View {
        NavigationView { // Use NavigationView for the large title style
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    CouponOfferView(starbucksGreen: starbucksGreen)
                        .padding(.horizontal)

                    SpecialOfferView(
                        starbucksGreen: starbucksGreen,
                        lightGreenBackground: lightGreenBackground
                    )
                    .padding(.horizontal)

                    Spacer() // Pushes content up if scroll view isn't full
                }
                .padding(.top) // Add padding above the first card
            }
            .background(Color(.systemGray6)) // Light gray background for the scrollable area
            .navigationTitle("Offers") // Large title
        }
        // Prevent the NavigationView from changing the tab bar color
        .navigationViewStyle(.stack)
    }
}

// MARK: - Coupon Offer Card View

struct CouponOfferView: View {
    let starbucksGreen: Color

    var body: some View {
        HStack(spacing: 15) {
            // Placeholder for the coupon icon
            Image(systemName: "ticket")
                .resizable()
                .scaledToFit()
                .padding(12)
                .frame(width: 60, height: 60)
                .background(Color(red: 0.9, green: 0.95, blue: 0.9)) // Placeholder background
                .foregroundColor(starbucksGreen)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 5) {
                Text("BÌNH MINH ƠI DẬY CHƯA?")
                    .font(.headline)
                    .fontWeight(.semibold)

                Text("Coupon Code-4292: $3 for any handcrafted drink Expires 4/3/25.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(2) // Allow text to wrap

                Spacer(minLength: 10) // Push button down slightly

                Button("Details") {
                    // Action for details
                    print("Coupon Details tapped")
                }
                .buttonStyle(StarbucksButton(style: .filled, color: starbucksGreen))
            }
            Spacer() // Push content to the left
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Special Offer Card View

struct SpecialOfferView: View {
    let starbucksGreen: Color
    let lightGreenBackground: Color

    var body: some View {
        VStack(spacing: 0) { // No spacing between image and text area
            // Image Area - Placeholder
            ZStack {
                lightGreenBackground // Background color

                // Placeholder stars (consider using actual image assets)
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow.opacity(0.7))
                    .font(.title)
                    .offset(x: 80, y: -30)
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow.opacity(0.6))
                    .font(.headline)
                    .offset(x: 90, y: 0)
                 Image(systemName: "star.fill")
                    .foregroundColor(.yellow.opacity(0.7))
                    .font(.largeTitle)
                    .offset(x: -80, y: 20)

                 // Placeholder for the drink image
                 Image(systemName: "cup.and.saucer.fill") // Placeholder
                     .resizable()
                     .aspectRatio(contentMode: .fit)
                     .frame(height: 180) // Adjust height as needed
                     .foregroundColor(.brown) // Placeholder color
                     .shadow(radius: 5)

            }
            .frame(height: 200) // Fixed height for the image area
            .clipped() // Clip contents like image and stars

            // Text and Button Area
            VStack(alignment: .leading, spacing: 10) {
                Text("Cà phê sáng với tôi được không?")
                    .font(.title3)
                    .fontWeight(.semibold)

                Text("A $3 drink is waiting just for you.")
                    .font(.body)
                    .foregroundColor(.secondary) // Slightly lighter text

                HStack(spacing: 15) {
                    Button("Details") {
                        // Action for details
                         print("Special Offer Details tapped")
                    }
                    .buttonStyle(StarbucksButton(style: .filled, color: starbucksGreen))

                    Button("Messages") {
                        // Action for messages
                         print("Special Offer Messages tapped")
                    }
                     .buttonStyle(StarbucksButton(style: .outlined, color: starbucksGreen))

                    Spacer() // Push buttons to the left if needed
                }
                .padding(.top, 5) // Add a little space above buttons
            }
            .padding() // Padding inside the text area
        }
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .clipped() // Clip the entire card to the corner radius
    }
}

// MARK: - Reusable Button Style

struct StarbucksButton: ButtonStyle {
    enum Style { case filled, outlined }
    let style: Style
    let color: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .fontWeight(.semibold)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(style == .filled ? color : Color.clear)
            .foregroundColor(style == .filled ? .white : color)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(color, lineWidth: style == .outlined ? 1.5 : 0)
            )
            .cornerRadius(20)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0) // Subtle press effect
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Preview

#Preview("Offer View") {
    OfferView()
}
