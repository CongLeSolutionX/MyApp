//
//  HomeView.swift
//  MyApp
//
//  Created by Cong Le on 4/2/25.
//

import SwiftUI

// --- Main View ---

struct HomeView: View {
    var body: some View {
//        ZStack(alignment: .bottom) {
            // Main scrolling content
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    GreetingView(name: "Cong")
                        .padding(.horizontal)

                    QuickActionsView()
                        .padding(.horizontal)

                    Divider()
                        .padding(.horizontal) // Apply padding to divider itself

                    RewardsSection(starBalance: 46, currentStars: 46)
                        .padding(.horizontal)

                    FeaturedCardView()
                        .padding(.horizontal)
                        .padding(.bottom, 80) // Add padding to avoid overlap with TabView
                }
                .padding(.top) // Padding for the top of the scroll content
                // .border(Color.red) // REMOVE THIS DEBUG BORDER
            }
            .background(Color(UIColor.systemGray6)) // Background for the scrollable area
            // .border(Color.blue) // REMOVE THIS DEBUG BORDER

//            // Custom Tab Bar View
//            TabBarView()
//        }
        .edgesIgnoringSafeArea(.bottom) // Allow TabView to sit at the very bottom
    }
}

#Preview() {
    HomeView()
}

// --- Reusable Components & Sections ---

struct GreetingView: View {
    let name: String

    var body: some View {
        Text("Hello again, \(name)")
            .font(.largeTitle)
            .fontWeight(.bold)
    }
}

#Preview("Greeting View") {
    GreetingView(name: "Cong")
}

struct QuickActionItem: View {
    let systemName: String
    let label: String

    var body: some View {
        HStack {
            Image(systemName: systemName)
                .foregroundColor(.secondary)
            Text(label)
                .font(.footnote)
                .fontWeight(.medium)
        }
    }
}

struct QuickActionsView: View {
    var body: some View {
        HStack(spacing: 20) {
            QuickActionItem(systemName: "envelope", label: "Inbox")
            QuickActionItem(systemName: "location", label: "Stores")
            Spacer()
            Image(systemName: "doc.text.viewfinder") // Placeholder for receipt/scan
                .foregroundColor(.secondary)
            Image(systemName: "person.circle")
                .foregroundColor(.secondary)
                .imageScale(.large)
        }
    }
}
#Preview("Quick Actions View") {
    QuickActionsView()
}

struct RewardsSection: View {
    let starBalance: Int
    let currentStars: Int // Use this for the progress indicator

    // Define reward tiers
    let rewardTiers: [Int] = [25, 100, 200, 300, 400]
    let maxStars = 400 // Based on the highest tier shown

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text("\(starBalance)")
                            .font(.system(size: 36, weight: .bold))
                        Image(systemName: "star.fill")
                            .foregroundColor(Color(hex: "#cba258")) // Approx gold
                            .font(.title2)
                    }
                    Text("Star balance")
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
                Spacer()
                Button {
                    // Action for rewards options
                } label: {
                    HStack {
                        Text("Rewards options")
                            .font(.footnote)
                            .fontWeight(.medium)
                        Image(systemName: "chevron.down")
                            .imageScale(.small)
                    }
                    .foregroundColor(.primary) // Default text color
                }
            }

            RewardsProgressView(currentValue: currentStars, maxValue: maxStars, tiers: rewardTiers)
                 .frame(height: 60) // Give the progress view some height

            HStack(spacing: 12) {
                Button("Details") { /* Action */ }
                    .buttonStyle(StarbucksButtonStyle(isFilled: false, foregroundColor: .black, backgroundColor: .clear, borderColor: .gray))

                Button("Redeem") { /* Action */ }
                    .buttonStyle(StarbucksButtonStyle(isFilled: true, foregroundColor: .white, backgroundColor: .black))
            }
            .frame(maxWidth: .infinity) // Center the buttons if needed, or adjust spacing
        }
    }
}
#Preview("Rewards Section") {
    RewardsSection(starBalance: 10, currentStars: 15)
}

struct RewardsProgressView: View {
    let currentValue: Int
    let maxValue: Int
    let tiers: [Int]

    // Approximate Starbucks Green color
    let starbucksGreen = Color(red: 0, green: 0.4, blue: 0.2) // Approximation

    var body: some View {
         GeometryReader { geometry in
             let width = geometry.size.width
             let progress = min(max(0.0, CGFloat(currentValue) / CGFloat(maxValue)), 1.0)
             let indicatorPosition = progress * width

             ZStack(alignment: .leading) {
                 // Track
                 Capsule()
                     .fill(Color.gray.opacity(0.3))
                     .frame(height: 6)

                 // Progress Fill
                 Capsule()
                     .fill(Color(hex: "#cba258")) // Approx Gold
                     .frame(width: indicatorPosition, height: 6)

                 // Tiers Markers and Labels
                 ForEach(tiers, id: \.self) { tier in
                     let tierPosition = CGFloat(tier) / CGFloat(maxValue) * width
                     VStack(spacing: 4) {
                         Circle()
                             .fill(Color.gray.opacity(0.3))
                             .frame(width: 12, height: 12)
                             .overlay(
                                 Circle()
                                     .stroke(Color.white, lineWidth: 2) // White border effect
                             )
                             .position(x: tierPosition, y: geometry.size.height / 4) // Position circle on the line

                         Text("\(tier)")
                             .font(.caption)
                             .foregroundColor(.gray)
                             .position(x: tierPosition, y: geometry.size.height * 0.8) // Position text below
                     }
                 }

                 // Current Value Indicator (Teardrop)
                  Image(systemName: "mappin.circle.fill") // Using system icon as placeholder
                      .resizable()
                      .scaledToFit()
                      .frame(width: 20, height: 20)
                      .foregroundColor(starbucksGreen)
                      .background(Color.white.clipShape(Circle())) // White background circle
                      .position(x: indicatorPosition, y: geometry.size.height / 4) // Position indicator on the line
             }
         }
    }
}
#Preview("RewardsProgressView") {
    RewardsProgressView(currentValue: 10, maxValue: 100, tiers: [0,10,20,30,40,50,60,70,80,90,100])
}

struct FeaturedCardView: View {
    let starbucksGreen = Color(red: 0, green: 0.4, blue: 0.2) // Approximation

    var body: some View {
        VStack(spacing: 0) {
            // Placeholder for the image
            Image("My-meme-red-wine-glass") // placeholder-drink-food // Replace with actual image loading
                .resizable()
                .aspectRatio(contentMode: .fill)
                // Give the image a reasonable height or aspect ratio
                 .frame(height: 200)
                 .clipped() // Clip the image to the frame bounds

            VStack(alignment: .leading, spacing: 12) {
                Text("Refresh your routine")
                    .font(.headline)
                    .fontWeight(.semibold)

                Text("Enjoy feel-good beverage and food options this spring that will keep you satisfied longer, like an Iced Shaken Espresso or Jalapeño Chicken Pocket.")
                    .font(.footnote)
                    .foregroundColor(.gray)

                HStack(spacing: 12) {
                    Button("Order now") { /* Action */ }
                        .buttonStyle(StarbucksButtonStyle(isFilled: false, foregroundColor: starbucksGreen, backgroundColor: .clear, borderColor: starbucksGreen))

                    Button("Scan in store") { /* Action */ }
                        .buttonStyle(StarbucksButtonStyle(isFilled: true, foregroundColor: .white, backgroundColor: starbucksGreen))
                }
            }
            .padding()
        }
        .background(Color.white) // Card background
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2) // Subtle shadow
    }
}
#Preview("Featured Card View") {
    FeaturedCardView()
}
// --- Tab Bar ---
struct TabBarView: View {
    let starbucksGreen = Color(red: 0, green: 0.4, blue: 0.2) // Approximation
    // Removed the SwiftUI unselectedGray definition from here as it's not directly used below

    @State private var selectedTab = 0 // State to track selected tab

    var body: some View {
        TabView(selection: $selectedTab) {
            // ... (Tab Items remain the same) ...
             Color.clear // Placeholder content for each tab
                 .tabItem {
                     Label("Home", systemImage: selectedTab == 0 ? "house.fill" : "house")
                 }.tag(0)

             Color.clear
                 .tabItem {
                     Label("Scan", systemImage: "qrcode.viewfinder")
                 }.tag(1)

              Color.clear
                  .tabItem {
                      Label("Order", systemImage: "cup.and.saucer") // Using a filled version if selected
                  }.tag(2)

             Color.clear
                 .tabItem {
                     Label("Gift", systemImage: "gift") // Using a filled version if selected
                 }.tag(3)

             Color.clear
                 .tabItem {
                     Label("Offers", systemImage: selectedTab == 4 ? "star.fill" : "star")
                 }.tag(4)
        }
        .accentColor(starbucksGreen) // Color for the selected tab item
        .onAppear {
             // Customize Tab Bar appearance using UIKit types
             let appearance = UITabBarAppearance()
             appearance.configureWithOpaqueBackground() // Standard appearance
             appearance.backgroundColor = UIColor.systemGray6 // Light background

             // Set unselected item color using UIColor (THE FIX)
             appearance.stackedLayoutAppearance.normal.iconColor = UIColor.systemGray
             appearance.stackedLayoutAppearance.normal.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.systemGray]

              // Apply the appearance to standard and scroll edge states
             UITabBar.appearance().standardAppearance = appearance
             if #available(iOS 15.0, *) {
                 UITabBar.appearance().scrollEdgeAppearance = appearance
             } else {
                 // ---- Alternatively, for simpler pre-iOS 15 style: ----
                  UITabBar.appearance().backgroundColor = UIColor.systemGray6
                  UITabBar.appearance().unselectedItemTintColor = UIColor.systemGray
             }
        }
    }
}

#Preview("TabBar View") {
    TabBarView()
}

// --- Custom Button Style ---

struct StarbucksButtonStyle: ButtonStyle {
    let isFilled: Bool
    let foregroundColor: Color
    let backgroundColor: Color
    var borderColor: Color? = nil // Optional border color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.footnote)
            .fontWeight(.semibold)
            .padding(.vertical, 10)
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity) // Make buttons expand
            .foregroundColor(foregroundColor)
            .background(isFilled ? backgroundColor : Color.clear)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(borderColor ?? (isFilled ? Color.clear : backgroundColor), lineWidth: 1.5)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0) // Subtle press effect
    }
}

// --- Helper Extension for Hex Colors ---
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// --- Preview ---
//
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        HomeView()
//    }
//}
