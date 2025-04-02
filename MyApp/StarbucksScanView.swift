//
//  StarbucksScanView.swift
//  MyApp
//
//  Created by Cong Le on 4/2/25.
//


import SwiftUI

// Define custom colors for reusability (replace with actual Starbucks brand colors)
extension Color {
    static let starbucksGreen = Color(red: 0, green: 0.4, blue: 0.2) // Approximate
    static let starbucksLightGray = Color(UIColor.systemGray5)
    static let starbucksGold = Color(red: 0.8, green: 0.6, blue: 0.2) // Approximate
}

struct StarbucksScanView: View {
    // State to manage the selected tab ("Scan & pay" or "Scan only")
    @State private var selectedScanMode = 0 // 0 for "Scan & pay", 1 for "Scan only"
    let scanModes = ["Scan & pay", "Scan only"]

    // State for the bottom tab bar selection
    @State private var selectedTab = 1 // Default to "Scan" tab

    // State for the card carousel (though we only show one card visually here)
    @State private var currentCardIndex = 0
    let totalCards = 5 // Example number of cards

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Custom Segmented Control (Tab Bar)
                ScanModeSelector(selectedScanMode: $selectedScanMode, modes: scanModes)

                // Main Content Area - Swipable Cards (using TabView for paging effect)
                TabView(selection: $currentCardIndex) {
                    ForEach(0..<totalCards, id: \.self) { index in
                        // Adding padding around the card scroll area
                        VStack {
                            Spacer(minLength: 20) // Space above the card
                            StarbucksCardView()
                            Spacer() // Pushes card up
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never)) // Use paging, hide default index dots
                .frame(height: 550) // Adjust height as needed for card visibility

                // Custom Page Indicator
                PageIndicator(currentIndex: $currentCardIndex, pageCount: totalCards)
                    .padding(.bottom) // Add some space below the dots

                Spacer() // Pushes everything above the bottom tab bar

                // Custom Bottom Tab Bar
                CustomBottomTabBar(selectedTab: $selectedTab)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Top Navigation Bar Content
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack {
                        Text("46")
                            .fontWeight(.bold)
                        Image(systemName: "star.fill")
                            .foregroundColor(.starbucksGold) // Use gold color
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
                            .foregroundColor(.black) // Or appropriate color
                    }
                }
            }
        }
        // Ensure the Navigation View doesn't take over the entire screen height unnecessarily
        // by managing the stack behavior if needed in a larger app context.
        // For this single screen, it should be fine.
    }
}

// MARK: - Subviews

struct ScanModeSelector: View {
    @Binding var selectedScanMode: Int
    let modes: [String]

    // 1. Declare the Namespace using the @Namespace property wrapper
    @Namespace private var underlineNamespace

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                ForEach(0..<modes.count, id: \.self) { index in
                    VStack(spacing: 8) {
                        Button(modes[index]) {
                            withAnimation(.spring()) { // Added a specific animation type
                                selectedScanMode = index
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .foregroundColor(selectedScanMode == index ? .primary : .secondary)

                        // Underline indicator
                        if selectedScanMode == index {
                            Color.starbucksGreen
                                .frame(height: 2)
                                // 2. Pass the declared namespace ID here
                                .matchedGeometryEffect(id: "underline", in: underlineNamespace)
                        } else {
                            Color.clear
                                .frame(height: 2)
                        }
                    }
                }
            }
            .padding(.horizontal)
            Divider() // Separator line below tabs
        }
    }
}

struct StarbucksCardView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            // Card Image Area
            ZStack(alignment: .topTrailing) {
                Image("starbucks-thank-you-card") // Placeholder image name
                    .resizable()
                    .aspectRatio(contentMode: .fill) // Fill the frame
                    .frame(height: 180) // Fixed height for the image part
                    .clipped() // Clip the image to the frame bounds

                Image("starbucks-logo") // Placeholder logo name
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .background(Color.white.opacity(0.8)) // Semi-transparent white circle background
                    .clipShape(Circle())
                    .padding(8) // Padding from the corner
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
            .frame(maxWidth: .infinity) // Center the balance info

            // Barcode Section
            VStack(spacing: 5) {
                // Placeholder for Barcode - In a real app, use a barcode generation library
                Image(systemName: "barcode") // System barcode icon as placeholder
                    .resizable()
                    .scaledToFit()
                    .frame(height: 60)
                    .padding(.horizontal, 30) // Match approximate padding

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
            .padding(.bottom, 15) // Padding at the bottom of the card content
        }
        .background(Color.white) // Card background
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4) // Card shadow
        .padding(.horizontal, 20) // Padding around the card itself
    }
}

struct CardActionButton: View {
    let iconName: String
    let label: String

    var body: some View {
        Button {
            // Action for the button
        } label: {
            VStack(spacing: 5) {
                Image(systemName: iconName)
                    .font(.title2)
                Text(label)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .foregroundColor(.gray) // Or specific brand color
        }
        .buttonStyle(.plain) // Use plain style to avoid default button appearance
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
                    .scaleEffect(index == currentIndex ? 1.1 : 1.0) // Slightly larger effect for current
                    .animation(.spring(), value: currentIndex)
            }
        }
    }
}

struct CustomBottomTabBar: View {
    @Binding var selectedTab: Int
    let tabs: [(icon: String, selectedIcon: String, label: String)] = [
        ("house", "house.fill", "Home"),
        ("squareshape.split.2x2", "squareshape.split.2x2.fill", "Scan"), // Assuming 'Scan' uses this kind of icon
        ("cup.and.saucer", "cup.and.saucer.fill", "Order"),
        ("gift", "gift.fill", "Gift"),
        ("star", "star.fill", "Offers")
    ]

    var body: some View {
        VStack(spacing: 0) {
            Divider() // Line above tab bar
            HStack {
                ForEach(0..<tabs.count, id: \.self) { index in
                    Spacer()
                    Button {
                        selectedTab = index
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: selectedTab == index ? tabs[index].selectedIcon : tabs[index].icon)
                                .font(.system(size: 22)) // Adjust icon size
                                .foregroundColor(selectedTab == index ? .starbucksGreen : .gray)
                            Text(tabs[index].label)
                                .font(.caption)
                                .foregroundColor(selectedTab == index ? .starbucksGreen : .gray)
                        }
                    }
                    .buttonStyle(.plain) // Avoid default button styling
                    Spacer()
                }
            }
            .padding(.top, 5) // Padding above icons/text
            .background(Color.starbucksLightGray.edgesIgnoringSafeArea(.bottom)) // Background extending slightly
        }
    }
}

// MARK: - Preview

struct StarbucksScanView_Previews: PreviewProvider {
    static var previews: some View {
        StarbucksScanView()
    }
}
