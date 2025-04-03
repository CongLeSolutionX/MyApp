////
////  AirbnbProfileHostView.swift
////  MyApp
////
////  Created by Cong Le on 4/2/25.
////
//
//import SwiftUI
//
//// Main view structure with TabView
//struct AirbnbProfileHostView: View {
//    @State private var selectedTab: Int = 4 // Default to Profile tab
//
//    // Placeholder color approximating Airbnb's brand color
//    let airbnbPink = Color(red: 255/255, green: 90/255, blue: 95/255)
//
//    var body: some View {
//        TabView(selection: $selectedTab) {
//            // Placeholder views for other tabs
//            Text("Explore Screen")
//                .tabItem {
//                    Label("Explore", systemImage: "magnifyingglass")
//                }
//                .tag(0)
//
//            Text("Wishlists Screen")
//                .tabItem {
//                    Label("Wishlists", systemImage: "heart")
//                }
//                .tag(1)
//
//            Text("Trips Screen")
//                .tabItem {
//                    // Using a placeholder icon as 'airbnb.logo' might not be standard
//                    Label("Trips", systemImage: "airplane")
//                }
//                .tag(2)
//
//            Text("Messages Screen")
//                .tabItem {
//                    Label("Messages", systemImage: "message")
//                    // Simple badge simulation - real implementation might need overlays
//                        .overlay(Badge(count: 1), alignment: .topTrailing)
//                }
//                .tag(3)
//
//            // The main Profile Screen content
//            ProfileContentView()
//                .tabItem {
//                    Label("Profile", systemImage: "person.crop.circle")
//                }
//                .tag(4)
//        }
//        .accentColor(airbnbPink) // Sets the color for the selected tab item
//    }
//}
//
//// Simple Badge view for demonstration
//struct Badge: View {
//    let count: Int
//    var body: some View {
//        ZStack(alignment: .topTrailing) {
//             Color.clear //Takes up space
//                Circle()
//                .fill(Color.red)
//                .frame(width: 8, height: 8)
//                // Adjust offset for better positioning on the message icon
//                .offset(x: 4, y: -4)
//        }
//    }
//}
//
//// The Profile screen content, structured as seen in the screenshot
//struct ProfileContentView: View {
//    var body: some View {
//        ZStack(alignment: .bottom) {
//            ScrollView {
//                VStack(alignment: .leading, spacing: 24) { // Adjusted spacing
//                    HeaderView()
//                    UserInfoView()
//                    Divider().padding(.horizontal, -16) // Make divider full width relative to padding
//                    PromoCardView()
//                    SettingsSectionView()
//
//                    // Add padding at the bottom so content doesn't hide under the floating button or tab bar
//                    Spacer().frame(height: 100)
//                }
//                .padding(.horizontal) // Standard padding for content
//                .padding(.top) // Add some space from the top edge if not using Navigation Bar
//            }
//            .coordinateSpace(name: "scroll") // Needed if we want scroll-dependent effects later
//
//            FloatingButtonView()
//                .padding(.bottom, 15) // Position above the tab bar area
//        }
//        .background(Color(.systemGroupedBackground)) // Match background if needed, or .white
//        .edgesIgnoringSafeArea(.bottom) // Allow content to potentially go under tab bar visually if needed, but padding prevents overlap
//    }
//}
//
//// MARK: - Profile Screen Components
//
//struct HeaderView: View {
//    var body: some View {
//        HStack {
//            Text("Profile")
//                .font(.largeTitle)
//                .fontWeight(.bold)
//
//            Spacer()
//
//            Button(action: {
//                print("Notification bell tapped")
//            }) {
//                Image(systemName: "bell")
//                    .font(.title2)
//                    .foregroundColor(.primary) // Use primary color for icons usually
//            }
//        }
//        // Removed bottom padding here, handled by VStack spacing
//    }
//}
//
//struct UserInfoView: View {
//    var body: some View {
//        Button(action: {
//            print("Show profile tapped")
//        }) {
//            HStack(spacing: 16) {
//                Image("profile-placeholder") // Replace with actual image loading logic
//                    .resizable()
//                    .scaledToFill()
//                    .frame(width: 64, height: 64)
//                    .clipShape(Circle())
//                    .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 0.5)) // Subtle border like screenshot
//
//                VStack(alignment: .leading) {
//                    Text("Cong") // Replace with dynamic data
//                        .font(.title2)
//                        .fontWeight(.semibold)
//                    Text("Show profile")
//                        .font(.subheadline)
//                        .foregroundColor(.gray)
//                }
//
//                Spacer()
//
//                Image(systemName: "chevron.right")
//                    .foregroundColor(.gray.opacity(0.5))
//            }
//            .foregroundColor(.primary) // Make sure text inside button is standard color
//        }
//        // Removed bottom padding here, handled by VStack spacing and Divider presence
//    }
//}
//
//struct PromoCardView: View {
//    var body: some View {
//        HStack {
//            VStack(alignment: .leading, spacing: 8) {
//                Text("Airbnb your home")
//                    .font(.headline)
//                    .fontWeight(.bold)
//                Text("It's easy to start hosting and earn extra income.")
//                    .font(.subheadline)
//                    .foregroundColor(.secondary) // Use secondary for less emphasis
//                    .lineLimit(2)
//                    .fixedSize(horizontal: false, vertical: true) // Allow text to wrap
//            }
//
//            Spacer()
//
//            Image("house-placeholder") // Replace with actual illustration
//                .resizable()
//                .scaledToFit()
//                .frame(width: 100, height: 80) // Approximate size
//                .padding(.leading, 8)
//        }
//        .padding()
//        .background(Color.white) // Card background
//        .cornerRadius(12)
//        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2) // Subtle shadow
//    }
//}
//
//struct SettingsSectionView: View {
//    // Data for settings items (could be moved to a ViewModel)
//    let settingsItems: [(icon: String, text: String)] = [
//        ("person.crop.circle", "Personal information"),
//        ("creditcard", "Payments and payouts"),
//        ("doc.text", "Taxes"),
//        ("shield.lefthalf.filled", "Login & security"),
//        ("gear", "Accessibility"),
//        ("character.bubble", "Translation"), // Using a representative icon
//        ("bell", "Notifications")
//    ]
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 0) { // Zero spacing, let SettingsRow handle padding/divider
//            Text("Settings")
//                .font(.title2)
//                .fontWeight(.semibold)
//                .padding(.bottom)
//
//            ForEach(settingsItems, id: \.text) { item in
//                SettingsRow(iconName: item.icon, text: item.text)
//                Divider() // Add divider after each row
//            }
//        }
//        // Remove horizontal padding if the parent VStack already has it
//    }
//}
//
//struct SettingsRow: View {
//    let iconName: String
//    let text: String
//
//    var body: some View {
//        Button(action: {
//            print("\(text) tapped")
//        }) {
//            HStack(spacing: 16) {
//                Image(systemName: iconName)
//                    .foregroundColor(.primary.opacity(0.8)) // Slightly muted icon color
//                    .frame(width: 24, alignment: .center) // Align icons
//
//                Text(text)
//                    .font(.body)
//
//                Spacer()
//
//                Image(systemName: "chevron.right")
//                    .foregroundColor(.gray.opacity(0.5))
//            }
//            .padding(.vertical, 12) // Vertical padding for tap area and spacing
//        }
//        .foregroundColor(.primary) // Ensure button text color is standard
//    }
//}
//
//struct FloatingButtonView: View {
//    var body: some View {
//        Button(action: {
//             print("Switch to hosting tapped")
//        }) {
//            Label("Switch to hosting", systemImage: "arrow.triangle.2.circlepath")
//                .font(.headline)
//                .fontWeight(.semibold)
//                .foregroundColor(.white)
//                .padding(.horizontal, 20)
//                .padding(.vertical, 12)
//                .background(Color.black) // Dark background
//                .clipShape(Capsule()) // Rounded shape
//                .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4) // Stronger shadow
//        }
//         // Padding applied in the parent ZStack to position it
//    }
//}
//
//// MARK: - Preview Provider
//
//struct AirbnbProfileHostView_Previews: PreviewProvider {
//    static var previews: some View {
//        // Inject placeholder images for preview if using assets
//        AirbnbProfileHostView()
//            // You might want to add mock data sources or specific states for previews
//            .onAppear {
//                 // Load placeholder images or setup mock environment if needed
//                 // E.g., replace "profile-placeholder" and "house-placeholder"
//                 // with system images for basic preview function:
//                 // Image(systemName: "person.fill") for profile
//                 // Image(systemName: "house.fill") for house
//            }
//    }
//}
//
//// Note: Replace "profile-placeholder" and "house-placeholder" with actual image names
//// in your project's asset catalog or use network image loading libraries.
//// For the preview to work without assets, you could temporarily use system images:
//// Image(systemName: "person.circle.fill") instead of Image("profile-placeholder")
//// Image(systemName: "house.fill") instead of Image("house-placeholder")
