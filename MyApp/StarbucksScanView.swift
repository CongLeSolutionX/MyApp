//
//  StarbucksScanView.swift
//  MyApp
//
//  Created by Cong Le on 4/2/25.
//

import SwiftUI

// Define custom colors for reusability (replace with actual Starbucks brand colors)
extension Color {
//    static let starbucksGreen = Color(red: 0, green: 0.4, blue: 0.2) // Approximate
    static let starbucksDarkGreen = Color(red: 0.1, green: 0.3, blue: 0.2) // Approximate for Scan Only card
    static let starbucksLightGray = Color(UIColor.systemGray5)
    static let starbucksGold = Color(red: 0.8, green: 0.6, blue: 0.2) // Approximate
}

struct StarStruckScanView: View {
    // State to manage the selected tab ("Scan & pay" or "Scan only")
    @State private var selectedScanMode = 1 // Default to "Scan only" based on the request
    let scanModes = ["Scan & pay", "Scan only"]

    // State for the bottom tab bar selection
    @State private var selectedTab = 1 // Default to "Scan" tab

    // State for the card carousel
    @State private var currentCardIndex = 0
    let totalCardsScanPay = 5 // Example number for "Scan & pay"
    let totalCardsScanOnly = 3 // Example number for "Scan only" (can be 1 if only one card)

    // Determine total cards based on selected mode
    var totalCards: Int {
        selectedScanMode == 0 ? totalCardsScanPay : totalCardsScanOnly
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Custom Segmented Control (Tab Bar)
                ScanModeSelector(selectedScanMode: $selectedScanMode, modes: scanModes)
                    // Reset card index when mode changes
                    .onChange(of: selectedScanMode) { _ in currentCardIndex = 0 }

                // Main Content Area - Swipable Cards (using TabView for paging effect)
                TabView(selection: $currentCardIndex) {
                    // Dynamically choose which card view to display based on mode
                    if selectedScanMode == 0 {
                        // Content for "Scan & pay"
                        ForEach(0..<totalCardsScanPay, id: \.self) { index in
                            VStack {
                                Spacer(minLength: 20)
                                StarbucksScanPayCardView() // Renamed original card view
                                Spacer()
                            }
                            .tag(index)
                        }
                    } else {
                        // Content for "Scan only"
                        ForEach(0..<totalCardsScanOnly, id: \.self) { index in
                              VStack {
                                Spacer(minLength: 20)
                                StarbucksScanOnlyCardView() // New card view for Scan Only
                                Spacer()
                              }
                              .tag(index)
                        }
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never)) // Use paging, hide default index dots
                .frame(height: 550) // Adjust height as needed

                // Custom Page Indicator (Dynamically updates based on selected mode)
                PageIndicator(currentIndex: $currentCardIndex, pageCount: totalCards)
                    .padding(.bottom)

                Spacer() // Pushes everything above the bottom tab bar

                // Custom Bottom Tab Bar
                CustomBottomTabBar(selectedTab: $selectedTab)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Top Navigation Bar Content (Remains the same)
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack {
                        Text("46")
                            .fontWeight(.bold)
                        Image(systemName: "star.fill")
                            .foregroundColor(.starbucksGold)
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("Cong L.")
                        .font(.headline)
                        .fontWeight(.bold)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        // Action for plus button
                    } label: {
                        Image(systemName: "plus.circle")
                            .font(.title2)
                            .foregroundColor(.black)
                    }
                }
            }
        }
    }
}

// MARK: - Subviews

struct ScanModeSelector: View {
    @Binding var selectedScanMode: Int
    let modes: [String]
    // Create a namespace for the geometry effect
    @Namespace private var underlineNamespace

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                ForEach(0..<modes.count, id: \.self) { index in
                    VStack(spacing: 8) {
                        Button(modes[index]) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { // Add smooth animation
                                selectedScanMode = index
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .foregroundColor(selectedScanMode == index ? .primary : .secondary)

                        // Underline indicator
                        if selectedScanMode == index {
                            Color.starbucksGreen
                                .frame(height: 2)
                                // Use the namespace for the effect
                                .matchedGeometryEffect(id: "underline", in: underlineNamespace)
                        } else {
                            Color.clear
                                .frame(height: 2)
                        }
                    }
                }
            }
            .padding(.horizontal)
            Divider()
        }
    }
}

// Renamed original card view
struct StarbucksScanPayCardView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            // Card Image Area
            ZStack(alignment: .topTrailing) {
                Image("starbucks-thank-you-card") // Placeholder image name
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 180)
                    .clipped()

                Image("My-meme-red-wine-glass") // Placeholder logo name
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .background(Color.yellow.opacity(0.8))
                    .clipShape(Circle())
                    .padding(8)
            }

            // Balance Section
            VStack(spacing: 5) {
                Text("$15.11")
                    .font(.system(size: 34, weight: .bold))

                HStack(spacing: 4) {
                    Text("Earns 2")
                    Image(systemName: "star.fill")
                        .foregroundColor(.starbucksGold)
                    Text("per $1")
                }
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.starbucksGold, lineWidth: 1)
                )
            }
            .frame(maxWidth: .infinity)

            // Barcode Section
            VStack(spacing: 5) {
                Image(systemName: "barcode") // Barcode for Scan & Pay
                    .resizable()
                    .scaledToFit()
                    .frame(height: 60)
                    .padding(.horizontal, 30)

                Text("6164 6541 3266 7668")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity)

            Divider().padding(.horizontal)

            // Action Buttons Section
            HStack {
                Spacer()
                CardActionButton(iconName: "gearshape", label: "Manage")
                Spacer()
                CardActionButton(iconName: "dollarsign.circle", label: "Add funds")
                Spacer()
            }
            .padding(.bottom, 15)
        }
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
        .padding(.horizontal, 20)
    }
}

// New card view for "Scan only" mode
struct StarbucksScanOnlyCardView: View {
     var body: some View {
        VStack(alignment: .center, spacing: 20) { // Center alignment for content
            // Card Image Area
            Image("My-meme-original") // Placeholder for the dark green card image
                .resizable()
                .aspectRatio(contentMode: .fill) // Or .fit depending on the asset
                .frame(height: 200)
                .background(Color.starbucksDarkGreen) // Background color if image is transparent/smaller
                .clipped() // Clip to bounds

            // Scan to Earn Section
            VStack(spacing: 8) {
                Text("Scan to earn Stars")
                    .font(.headline)
                    .fontWeight(.medium)

                HStack(spacing: 4) {
                    Text("Earns 1") // Updated text
                    Image(systemName: "star.fill")
                        .foregroundColor(.starbucksGold)
                    Text("per $1")
                }
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.starbucksGold, lineWidth: 1)
                )
            }
            .frame(maxWidth: .infinity)

            // QR Code Section
            VStack(spacing: 10) {
                Image(systemName: "qrcode") // QR Code for Scan Only
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120) // Adjust size as needed

            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10) // Spacing around QR code

             Spacer() // Pushes the Make Default button down

            // Make Default Button
             Button {
                 // Action for Make Default
             } label: {
                 HStack {
                     Image(systemName: "checkmark.circle")
                         .foregroundColor(.gray)
                     Text("Make default")
                         .font(.callout)
                         .foregroundColor(.primary) // Use primary color for text
                 }
                 .padding(.bottom, 20) // Add padding below the button
             }
             .buttonStyle(.plain)

        }
        .frame(height: 500) // Adjust overall height to fit content
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
        .padding(.horizontal, 20)
    }
}

struct CardActionButton: View { // Reusable for Scan & Pay
    let iconName: String
    let label: String

    var body: some View {
        Button {
            // Action
        } label: {
            VStack(spacing: 5) {
                Image(systemName: iconName)
                    .font(.title2)
                Text(label)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .foregroundColor(.gray)
        }
        .buttonStyle(.plain)
    }
}

struct PageIndicator: View {
    @Binding var currentIndex: Int
    let pageCount: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<pageCount, id: \.self) { index in
                Circle()
                    .fill(index == currentIndex ? Color.primary : Color.gray.opacity(0.5))
                    .frame(width: 8, height: 8)
                    .scaleEffect(index == currentIndex ? 1.1 : 1.0)
                    // Add explicit animation trigger
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentIndex == index)
            }
        }
        // Ensure indicator updates smoothly when pageCount changes
        .id(pageCount) // Recreate the HStack if pageCount changes
    }
}

struct CustomBottomTabBar: View { // Remains the same
    @Binding var selectedTab: Int
    let tabs: [(icon: String, selectedIcon: String, label: String)] = [
        ("house", "house.fill", "Home"),
        ("squareshape.split.2x2", "squareshape.split.2x2.fill", "Scan"),
        ("cup.and.saucer", "cup.and.saucer.fill", "Order"),
        ("gift", "gift.fill", "Gift"),
        ("star", "star.fill", "Offers")
    ]

    var body: some View {
        VStack(spacing: 0) {
            Divider()
            HStack {
                ForEach(0..<tabs.count, id: \.self) { index in
                    Spacer()
                    Button {
                        selectedTab = index
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: selectedTab == index ? tabs[index].selectedIcon : tabs[index].icon)
                                .font(.system(size: 22))
                                .foregroundColor(selectedTab == index ? .starbucksGreen : .gray)
                            Text(tabs[index].label)
                                .font(.caption)
                                .foregroundColor(selectedTab == index ? .starbucksGreen : .gray)
                        }
                    }
                    .buttonStyle(.plain)
                    Spacer()
                }
            }
            .padding(.top, 5)
            .background(Color.starbucksLightGray.edgesIgnoringSafeArea(.bottom))
        }
    }
}

// MARK: - Preview

struct StarbucksScanView_Previews: PreviewProvider {
    static var previews: some View {
        StarStruckScanView()
        // Preview showing Scan Only mode by default
//        StarbucksScanView(selectedScanMode: 1)

        // You can add another preview for Scan & Pay if needed
        // StarbucksScanView(selectedScanMode: 0)
        //    .previewDisplayName("Scan & Pay")
    }
}
