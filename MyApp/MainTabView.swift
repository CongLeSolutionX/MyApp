//
//  MainTabView.swift
//  MyApp
//
//  Created by Cong Le on 4/2/25.
//


import SwiftUI

// MARK: - Data Model

struct PromoItem: Identifiable {
    let id = UUID()
    let imageName: String
    let title: String
    let description: String
    let buttonText: String
}

// MARK: - Sample Data

let promoItemsData: [PromoItem] = [
    PromoItem(imageName: "My-meme-red-wine-glass", title: "Chill Blends, Chiller Prices", description: "Recharge with a $4 Venti Cold Brew or Nitro Cold Brew after 12 p.m.**", buttonText: "Order now"),
    PromoItem(imageName: "My-meme-heineken", title: "Buy One Get One is Back!", description: "Enjoy a BOGO handcrafted drink every Wednesday in June from 2–6 p.m.", buttonText: "Find a store"),
    PromoItem(imageName: "My-meme-microphone", title: "Earn Double Stars", description: "Earn 2★ per $1 spent when you pay with a linked PayPal account May 29–June 4.*", buttonText: "Learn more")
]

// MARK: - Custom Styles & Colors

struct StarbucksButtonStyle: ButtonStyle {
    let foregroundColor: Color
    let backgroundColor: Color
    let borderColor: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .foregroundColor(foregroundColor) // Use passed foreground color
            .background(backgroundColor)      // Use passed background color
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(borderColor, lineWidth: 1) // Use passed border color
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

extension Color {
    static let starbucksGreen = Color(red: 0, green: 0.4, blue: 0.2) // Approximation
    static let starbucksLightGreen = Color(red: 0.8, green: 0.9, blue: 0.85) // Lighter green for backgrounds
    static let starbucksCream = Color(red: 0.98, green: 0.97, blue: 0.95) // Off-white
}

// MARK: - Tab Bar Enum Definition

enum TabBarItem: CaseIterable, Identifiable {
    case home, scan, order, offers

    var id: Self { self }

    var iconName: String {
        switch self {
        case .home: return "house.fill"
        case .scan: return "qrcode.viewfinder"
        case .order: return "cup.and.saucer.fill"
        case .offers: return "star.fill"
        }
    }

    var title: String {
        switch self {
        case .home: return "Home"
        case .scan: return "Scan"
        case .order: return "Order"
        case .offers: return "Offers"
        }
    }

    // The associated view for each tab
    @ViewBuilder
    var view: some View {
        switch self {
        case .home:
            HomeContentView()
        case .scan:
            ScanView()
        case .order:
            OrderView()
        case .offers:
            OffersView()
        }
    }
}

// MARK: - Placeholder Content Views (Scan, Order, Offers)

struct ScanView: View {
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemGroupedBackground).ignoresSafeArea() // Example background
                VStack {
                    Spacer()
                    Image(systemName: "qrcode")
                        .font(.system(size: 100))
                        .foregroundColor(.gray)
                    Text("Scan Feature Coming Soon!")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    Spacer()
                    Spacer()
                }
            }
            .navigationTitle("Scan")
        }
        .navigationViewStyle(.stack) // Recommended for iOS 16+ tab views
    }
}

struct OrderView: View {
    var body: some View {
        NavigationView {
             ZStack {
                Color(UIColor.systemGroupedBackground).ignoresSafeArea()
                 VStack {
                     Spacer()
                     Image(systemName: "cup.and.saucer")
                         .font(.system(size: 100))
                         .foregroundColor(.gray)
                     Text("Order Feature Coming Soon!")
                         .font(.title2)
                         .foregroundColor(.secondary)
                     Spacer()
                     Spacer()
                 }
             }
            .navigationTitle("Order")
        }
        .navigationViewStyle(.stack)
    }
}

struct OffersView: View {
    var body: some View {
        NavigationView {
             ZStack {
                Color(UIColor.systemGroupedBackground).ignoresSafeArea()
                 VStack {
                     Spacer()
                     Image(systemName: "star.square.on.square")
                         .font(.system(size: 100))
                         .foregroundColor(.gray)
                     Text("Offers Feature Coming Soon!")
                         .font(.title2)
                         .foregroundColor(.secondary)
                     Spacer()
                    Spacer()
                 }
             }
            .navigationTitle("Offers")
        }
        .navigationViewStyle(.stack)
    }
}

// MARK: - Home Tab Content View & Sub-components

// --- Greeting ---
struct GreetingView: View {
    let name: String
    var body: some View {
        HStack {
            Text("Good Afternoon, \(name)!")
                .font(.largeTitle)
                .fontWeight(.bold)
            Spacer()
        }
    }
}

// --- Quick Actions ---
struct QuickActionsView: View {
    var body: some View {
        HStack(spacing: 20) {
            QuickActionItem(iconName: "star", label: "Rewards")
            QuickActionItem(iconName: "location", label: "Stores")
            QuickActionItem(iconName: "giftcard", label: "Gift Cards")
            Spacer()
            QuickActionItem(iconName: "ellipsis", label: "More")
        }
    }
}

struct QuickActionItem: View {
    let iconName: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: iconName)
                .font(.title2)
                .foregroundColor(.starbucksGreen)
                .frame(width: 50, height: 50) // Consistent size
                .background(Color.starbucksLightGreen)
                .clipShape(Circle())
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// --- Rewards Section ---
struct RewardsSection: View {
    let starBalance: Int
    let currentStars: Int // Assuming max is 50 for one reward, adjust as needed
    let maxStars = 50

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Rewards")
                    .font(.headline)
                Spacer()
                Text("\(starBalance) ★") // Total stars
                    .font(.headline)
                    .foregroundColor(.starbucksGreen)
            }
            Text("Just \(maxStars - currentStars) ★ away from your next Reward!")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.bottom, 5)

            // Progress Bar
            RewardsProgressView(currentStars: currentStars, maxStars: maxStars)
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground)) // Slightly different bg
        .cornerRadius(10)
    }
}

struct RewardsProgressView: View {
    let currentStars: Int
    let maxStars: Int

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 8)

                Capsule()
                    .fill(Color.starbucksGreen)
                    .frame(width: calculateWidth(geometry: geometry), height: 8)
                    .animation(.linear, value: currentStars) // Animate progress change

                // Star icon at the end of progress
                 Image(systemName: "star.fill")
                     .foregroundColor(Color.yellow) // Use a contrasting color
                     .font(.system(size: 14)) // Slightly larger than the bar
                     .position(x: calculateWidth(geometry: geometry), y: geometry.size.height / 2)
                     .shadow(radius: 1)
            }
        }
        .frame(height: 15) // Ensure GeometryReader has height
    }

    private func calculateWidth(geometry: GeometryProxy) -> CGFloat {
        let progress = CGFloat(currentStars) / CGFloat(maxStars)
        // Clamp the progress between 0 and 1 to avoid over/underflow issues
        let clampedProgress = max(0, min(progress, 1))
        return geometry.size.width * clampedProgress
    }
}

// --- Featured Card ---
struct FeaturedCardView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Image("My-meme-original") // featured_promo // Replace with your actual image name
                .resizable()
                .aspectRatio(contentMode: .fill) // Fill width, adjust height
                .frame(maxWidth: .infinity)
                .frame(height: 180) // Define a height
                .clipped() // Clip image excess

            VStack(alignment: .leading, spacing: 8) {
                Text("Bonus Star Bingo is Back")
                    .font(.headline)
                    .fontWeight(.semibold)
                Text("Play for your chance to win up to 10,000 Stars, drinks and food.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                 Button("Play now") {
                     print("Featured Play tapped")
                 }
                 .buttonStyle(StarbucksButtonStyle(foregroundColor: .white, backgroundColor: .starbucksGreen, borderColor: .starbucksGreen))
                 .padding(.top, 5)
            }
            .padding() // Padding inside the text section
        }
        .background(Color(UIColor.systemBackground)) // Use system background for contrast
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// --- Promo Card ---
struct PromoCardView: View {
    let item: PromoItem

    var body: some View {
        HStack(spacing: 15) {
            Image(item.imageName) // Ensure you have these images in Assets
                .resizable()
                .scaledToFill() // Use fill for better look in fixed frame
                .frame(width: 100, height: 100)
                .cornerRadius(8)
                 .clipped() // Important when using scaledToFill

            VStack(alignment: .leading, spacing: 5) {
                Text(item.title)
                    .font(.headline)
                    .lineLimit(2) // Allow title to wrap slightly

                Text(item.description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(3) // Limit description lines

                Spacer() // Push button to bottom

                Button(item.buttonText) {
                    print("Promo button tapped: \(item.title)")
                }
                .buttonStyle(StarbucksButtonStyle(foregroundColor: .starbucksGreen, backgroundColor: .clear, borderColor: .starbucksGreen))
                // Use clear background and green border/text
            }
            .frame(height: 120) // Give VStack a fixed height to align button
        }
        .padding() // Add padding around the HStack content
        .background(Color(UIColor.systemBackground))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 1)
    }
}

// --- The actual content view for the Home Tab ---
struct HomeContentView: View {
    var body: some View {
        ScrollView {
             // Use a LazyVStack for performance with many items
            LazyVStack(alignment: .leading, spacing: 20) { // Increased spacing
                // --- Greeting ---
                GreetingView(name: "Cong")
                    .padding(.horizontal)
                    .padding(.top) // Add top padding

                // --- Quick Actions ---
                QuickActionsView()
                    .padding(.horizontal)

                // --- Divider ---
                Divider()
                    .padding(.horizontal)
                    .padding(.vertical, 5) // Add some vertical space around divider

                // --- Rewards Section ---
                RewardsSection(starBalance: 46, currentStars: 46) // Example data
                    .padding(.horizontal)

                // --- Initial Featured Card ---
                FeaturedCardView()
                    .padding(.horizontal)

                // --- Section Title for Promos ---
                Text("More to Discover")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .padding(.horizontal)
                    .padding(.top) // Add padding above this title

                 // --- Additional Promo Cards ---
                 ForEach(promoItemsData) { item in
                     PromoCardView(item: item)
                         .padding(.horizontal) // Padding for each card
                 }

                // --- Bottom Spacer ---
                // Add space so the last item doesn't sit right against the tab bar
                 Spacer(minLength: 90) // Height should be > TabBar height + padding
            }
            // No top padding on LazyVStack needed if Greeting has it
        }
        // Use systemGroupedBackground for the ScrollView's background
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
        // Important: No .edgesIgnoringSafeArea here for the ScrollView itself
    }
}

// MARK: - Tab Bar View Implementation

struct TabBarView: View {
    @Binding var selectedTab: TabBarItem
//    @Environment(\.safeAreaInsets) private var safeAreaInsets // Get safe area

    var body: some View {
        HStack {
            ForEach(TabBarItem.allCases) { item in
                Spacer()
                VStack(spacing: 4) {
                    Image(systemName: item.iconName)
                        .font(.system(size: 22)) // Consistent icon size
                        .frame(height: 25) // Ensure icon area has consistent height

                    Text(item.title)
                        .font(.system(size: 10)) // Smaller caption size
                }
                .foregroundColor(selectedTab == item ? .starbucksGreen : .gray)
                .padding(.vertical, 8) // Padding inside each item
                .frame(maxWidth: .infinity) // Allow items to expand
                .contentShape(Rectangle()) // Make the whole area tappable
                .onTapGesture {
                    selectedTab = item // Update state on tap
                }
                Spacer()
            }
        }
        // .padding(.horizontal) Don't need if Spacer distributes evenly
        .frame(height: 55) // Define a fixed height for the tab bar content area
//        .padding(.bottom, safeAreaInsets.bottom) // Add padding ONLY at the bottom equal to the safe area
        .background(.thinMaterial) // Use blurred material background
        .compositingGroup() // Helps with rendering complex backgrounds/shadows
        .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: -2) // Subtle top shadow
    }
}

// MARK: - Main Container View

struct MainTabView: View {
    @State private var selectedTab: TabBarItem = .home

    init() {
         // Optional: Customize Tab Bar appearance globally if needed
         // UITabBar.appearance().isHidden = true // If using system TabView, but we are custom.
         // Note: For custom tab bars, global appearance settings might not apply.
    }

    var body: some View {
        // Use ZStack to overlay the content and the custom tab bar
        ZStack(alignment: .bottom) {
            // Display the view associated with the selected tab
            selectedTab.view
                 // Let the content view decide its own background and safe area handling.
                 // HomeContentView uses .systemGroupedBackground. Others might use different ones.

            // Custom Tab Bar View is placed on top at the bottom
            TabBarView(selectedTab: $selectedTab)
        }
        // IMPORTANT: Ignore bottom safe area for the ZStack container ONLY.
        // This allows the TabBarView's background material to extend into the safe area.
        .edgesIgnoringSafeArea(.bottom)
        // No background needed on the ZStack itself, as content views provide their own.
    }
}

// MARK: - App Entry Point

//@main
//struct StarbucksCloneApp: App { // Replace with your actual App name
//    var body: some Scene {
//        WindowGroup {
//            MainTabView() // Start the app with the main tab container
//        }
//    }
//}

// MARK: - Previews

#Preview() {
    MainTabView()
        // You can inject environment objects or sample data here if needed for preview
        // .environmentObject(SomeViewModel())
}

// Add specific previews if helpful for isolated component testing
#Preview("Home Content") {
    HomeContentView()
}

#Preview("Featured Card") {
    FeaturedCardView()
        .padding()
        .background(Color.gray.opacity(0.1))
}

#Preview("Promo Card") {
    PromoCardView(item: promoItemsData[0])
        .padding()
        .background(Color.gray.opacity(0.1))
}

#Preview("Tab Bar") {
    // Provide a constant binding for previewing TabBarView
    TabBarView(selectedTab: .constant(.home))
        .padding(.horizontal) // Add padding for visual clarity in preview
        .background(Color.white) // Background to see it clearly
}

#Preview("Rewards Section") {
    RewardsSection(starBalance: 123, currentStars: 35)
        .padding()
        .background(Color.gray.opacity(0.1))
}
