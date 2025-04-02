//
//  ProfileView_V2.swift
//  MyApp
//
//  Created by Cong Le on 4/2/25.
//

import SwiftUI

// Main view structure with TabView (remains the same)
struct AirbnbProfileHostView: View {
    @State private var selectedTab: Int = 4 // Default to Profile tab

    // Placeholder color approximating Airbnb's brand color
    let airbnbPink = Color(red: 255/255, green: 90/255, blue: 95/255)

    var body: some View {
        TabView(selection: $selectedTab) {
            // Placeholder views for other tabs
            Text("Explore Screen")
                .tabItem {
                    Label("Explore", systemImage: "magnifyingglass")
                }
                .tag(0)

            Text("Wishlists Screen")
                .tabItem {
                    Label("Wishlists", systemImage: "heart")
                }
                .tag(1)

            Text("Trips Screen")
                .tabItem {
                    // Using a placeholder icon as 'airbnb.logo' might not be standard
                    Label("Trips", systemImage: "airplane")
                    // In a real app, you might need a custom icon for Airbnb logo
                }
                .tag(2)

            Text("Messages Screen")
                .tabItem {
                    Label("Messages", systemImage: "message")
                    // Simple badge simulation
                        .overlay(Badge(count: 1), alignment: .topTrailing)
                }
                .tag(3)

            // The main Profile Screen content
            ProfileContentView()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
                .tag(4)
        }
        .accentColor(airbnbPink) // Sets the color for the selected tab item
    }
}

// Simple Badge view for demonstration (remains the same)
struct Badge: View {
    let count: Int
    var body: some View {
        ZStack(alignment: .topTrailing) { // Ensure ZStack takes space if needed
             Color.clear
                Circle()
                .fill(Color.red)
                .frame(width: 8, height: 8)
                // Adjust offset for better positioning on the message icon
                .offset(x: 4, y: -4)
        }
    }
}

// The Profile screen content, updated with new sections
struct ProfileContentView: View {
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) { // Keep overall spacing
                    HeaderView()
                    UserInfoView()
                    Divider().padding(.horizontal, -16) // Full width divider
                    PromoCardView()
                    SettingsSectionView()

                    // --- New Sections Start ---
                    SupportSectionView()
                    LegalSectionView()
                    LogoutButtonView()
                        .padding(.vertical) // Add some space around logout
                    VersionInfoView()
                    // --- New Sections End ---

                    // Add padding at the bottom so content doesn't hide under the floating button or tab bar
                    Spacer().frame(height: 120) // Increased spacer height
                }
                .padding(.horizontal) // Standard padding for content
                .padding(.top) // Add some space from the top edge
            }
            .coordinateSpace(name: "scroll")

            FloatingButtonView()
                .padding(.bottom, UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0 > 0 ? 5 : 15) // Adjust bottom padding based on safe area - approximate
        }
        .background(Color(.systemGroupedBackground).edgesIgnoringSafeArea(.all)) // Extend background
        // .edgesIgnoringSafeArea(.bottom) // Let ZStack handle safe area
    }
}

// MARK: - Profile Screen Components (Existing ones remain mostly the same)

struct HeaderView: View {
    var body: some View {
        HStack {
            Text("Profile")
                .font(.largeTitle)
                .fontWeight(.bold)
            Spacer()
            Button(action: { print("Notification bell tapped") }) {
                Image(systemName: "bell")
                    .font(.title2)
                    .foregroundColor(.primary)
            }
        }
    }
}

struct UserInfoView: View {
    var body: some View {
        Button(action: { print("Show profile tapped") }) {
            HStack(spacing: 16) {
                Image("profile-placeholder") // Replace with actual image loading
                    .resizable().scaledToFill().frame(width: 64, height: 64)
                    .clipShape(Circle()).overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 0.5))

                VStack(alignment: .leading) {
                    Text("Cong").font(.title2).fontWeight(.semibold) // Replace with dynamic data
                    Text("Show profile").font(.subheadline).foregroundColor(.gray)
                }
                Spacer()
                Image(systemName: "chevron.right").foregroundColor(.gray.opacity(0.5))
            }
            .foregroundColor(.primary)
        }
    }
}

struct PromoCardView: View {
     var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("Airbnb your home").font(.headline).fontWeight(.bold)
                Text("It's easy to start hosting and earn extra income.").font(.subheadline).foregroundColor(.secondary).lineLimit(2).fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
            Image("house-placeholder") // Replace with actual illustration
                .resizable().scaledToFit().frame(width: 100, height: 80).padding(.leading, 8)
        }
        .padding().background(Color.white).cornerRadius(12).shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct SettingsSectionView: View {
    let settingsItems: [(icon: String, text: String)] = [
        ("person.crop.circle", "Personal information"),
        ("creditcard", "Payments and payouts"),
        ("doc.text", "Taxes"), // Keep original icon for this section
        ("shield.lefthalf.filled", "Login & security"),
        ("gear", "Accessibility"),
        ("character.bubble", "Translation"),
        ("bell", "Notifications")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Settings")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.bottom)

            // Using ForEach with indices to avoid adding a divider after the last item explicitly
            ForEach(settingsItems.indices, id: \.self) { index in
                SettingsRow(iconName: settingsItems[index].icon, text: settingsItems[index].text)
                if index < settingsItems.count - 1 { // Add divider only between items
                    Divider().padding(.leading, 40) // Indent divider to align with text
                }
            }
        }
    }
}

// --- New Section Views ---

struct SupportSectionView: View {
    // Data for support items
    let supportItems: [(icon: String, text: String)] = [
        ("questionmark.circle", "Visit the Help Center"),
        ("figure.walk.diamond", "Get help with a safety issue"), // Different icon
        ("headphones", "Report a neighborhood concern"),
        ("info.circle", "How Airbnb works"), // Using info circle as placeholder
        ("pencil.and.outline", "Give us feedback")
    ]

    var body: some View {
        // No explicit "Support" header shown, rows start directly after Settings
        VStack(alignment: .leading, spacing: 0) {
            // Optional: Add header if desired
            // Text("Support").font(.title2).fontWeight(.semibold).padding(.bottom)

            ForEach(supportItems.indices, id: \.self) { index in
                SettingsRow(iconName: supportItems[index].icon, text: supportItems[index].text)
                if index < supportItems.count - 1 {
                    Divider().padding(.leading, 40)
                }
            }
        }
        .padding(.top) // Add space if no header is present
    }
}

struct LegalSectionView: View {
    // Data for legal items
    let legalItems: [(icon: String, text: String)] = [
        ("book.closed", "Terms of Service"), // Using book icon for legal docs
        ("book.closed", "Privacy Policy"),
        ("book.closed", "Your Privacy Choices"),
        ("book.closed", "Open source licenses")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Legal")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.bottom)

            ForEach(legalItems.indices, id: \.self) { index in
                SettingsRow(iconName: legalItems[index].icon, text: legalItems[index].text)
                if index < legalItems.count - 1 {
                    Divider().padding(.leading, 40)
                }
            }
        }
        // Spacing handled by parent VStack
    }
}

struct LogoutButtonView: View {
    var body: some View {
        Button(action: {
             print("Log out tapped")
             // Add actual logout logic here
        }) {
            Text("Log out")
                .font(.body)
                .foregroundColor(.primary) // Standard text color
                .underline() // Make it look like a link
        }
        // Align left by default in VStack
    }
}

struct VersionInfoView: View {
    var body: some View {
        Text("VERSION 25.13 (204194)") // Replace with dynamic version fetching
            .font(.caption)
            .foregroundColor(.gray)
            // Align left by default in VStack
    }
}

// SettingsRow (can be reused for all list items) - potentially indent divider
struct SettingsRow: View {
    let iconName: String
    let text: String

    var body: some View {
        Button(action: { print("\(text) tapped") }) {
            HStack(spacing: 16) {
                Image(systemName: iconName)
                    .foregroundColor(.primary.opacity(0.8))
                    .frame(width: 24, alignment: .center)

                Text(text).font(.body)
                Spacer()
                Image(systemName: "chevron.right").foregroundColor(.gray.opacity(0.5))
            }
            .padding(.vertical, 12)
        }
        .foregroundColor(.primary)
    }
}

// FloatingbuttonView (remains the same)
struct FloatingButtonView: View {
     var body: some View {
        Button(action: { print("Switch to hosting tapped") }) {
            Label("Switch to hosting", systemImage: "arrow.triangle.2.circlepath")
                .font(.headline).fontWeight(.semibold).foregroundColor(.white)
                .padding(.horizontal, 20).padding(.vertical, 12)
                .background(Color.black).clipShape(Capsule())
                .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
        }
    }
}

// MARK: - Preview Provider (remains the same)

struct AirbnbProfileHostView_Previews: PreviewProvider {
    static var previews: some View {
        AirbnbProfileHostView()
            .onAppear {
                 // Example using system images for preview without assets:
                 // Use Image(systemName: "person.circle.fill") for profile-placeholder
                 // Use Image(systemName: "house.fill") for house-placeholder
            }
    }
}

// Note: Remember to replace placeholder images and text with actual data sources.
// Check if the chosen SF Symbols match the desired look and feel.
