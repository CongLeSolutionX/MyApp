//
//  PlantCareListView.swift
//  MyApp
//
//  Created by Cong Le on 3/28/25.
//

import SwiftUI

// MARK: - Data Models

struct PlantCareItem: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let imageName: String
    let isNew: Bool = false // Example: Can be toggled
}

struct PlantDetail {
    let id = UUID()
    let name: String
    let imageName: String // Can reuse or have a specific detail image
    let careInstructions: [String]
    let aboutInfo: [(icon: String, text: String)]
}

// MARK: - Theme Definition

// Represents the colors for a specific mode (light/dark)
struct ColorSchemePalette {
    let primary: Color
    let onPrimary: Color
    let secondary: Color
    let onSecondary: Color
    let tertiary: Color
    let onTertiary: Color
    let background: Color
    let onBackground: Color
    let surface: Color // Used for card backgrounds, etc.
    let onSurface: Color
    let surfaceVariant: Color // Subtle variants
    let onSurfaceVariant: Color
    let outline: Color // Borders, dividers
}

// Holds both light and dark palettes
struct PlantTheme {
    let light: ColorSchemePalette
    let dark: ColorSchemePalette

    // Helper to get the correct palette based on system color scheme
    func currentPalette(for scheme: ColorScheme) -> ColorSchemePalette {
        scheme == .dark ? dark : light
    }
}

// MARK: - Theme Environment Injection

struct PlantThemeKey: EnvironmentKey {
    // Define a default theme based visually on the screenshots (Green primary)
    static let defaultValue: PlantTheme = PlantTheme(
        light: ColorSchemePalette(
            primary: Color(hex: "67866A"), // Main Green
            onPrimary: Color.white,
            secondary: Color(hex: "E8D4CC"), // Pinkish Beige
            onSecondary: Color(hex: "442F27"),
            tertiary: Color(hex: "E3E4AE"), // Yellowish Green
            onTertiary: Color(hex: "3A3C10"),
            background: Color(hex: "F9FAF8"), // Off-white
            onBackground: Color(hex: "1A1C19"),
            surface: Color(hex: "E6F0E5"), // Light green for cards/tabs
            onSurface: Color(hex: "1A1C19"),
            surfaceVariant: Color(hex: "DEE5D9"),
            onSurfaceVariant: Color(hex: "424940"),
            outline: Color(hex: "727970")
        ),
        dark: ColorSchemePalette(
            primary: Color(hex: "8FD48F"), // Brighter Green for Dark Mode
            onPrimary: Color(hex: "003910"),
            secondary: Color(hex: "CBB8AF"), // Muted Pinkish Beige
            onSecondary: Color(hex: "2F1511"),
            tertiary: Color(hex: "C7C893"), // Muted Yellowish Green
            onTertiary: Color(hex: "252600"),
            background: Color(hex: "1A1C19"), // Dark Gray/Green
            onBackground: Color(hex: "E2E3DD"),
            surface: Color(hex: "2E4F3A"), // Darker Green for cards/tabs
            onSurface: Color(hex: "E2E3DD"),
            surfaceVariant: Color(hex: "424940"),
            onSurfaceVariant: Color(hex: "C2C9BE"),
            outline: Color(hex: "8C9389")
        )
    )
}

extension EnvironmentValues {
    var plantTheme: PlantTheme {
        get { self[PlantThemeKey.self] }
        set { self[PlantThemeKey.self] = newValue }
    }
}

// Helper extension for Color initialization from hex
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
            (a, r, g, b) = (255, 0, 0, 0) // Default to black
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}

// MARK: - Reusable Views

struct CardView: View {
    let item: PlantCareItem
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.plantTheme) var theme

    private var currentPalette: ColorSchemePalette {
        theme.currentPalette(for: colorScheme)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Image(item.imageName) // Assume images are in Assets
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 150)
                .clipped()
                .overlay(alignment: .topTrailing) {
                    if item.isNew {
                        Text("NEW")
                            .font(.caption.bold())
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(currentPalette.tertiary) // Using tertiary as an example for badge
                            .foregroundColor(currentPalette.onTertiary)
                            .clipShape(Capsule())
                            .padding(8)
                    }
                }

            VStack(alignment: .leading) {
                Text(item.title)
                    .font(.headline)
                    .foregroundColor(currentPalette.onSurface)
                Text(item.subtitle)
                    .font(.subheadline)
                    .foregroundColor(currentPalette.onSurfaceVariant)
            }
            .padding()
        }
        .background(currentPalette.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: currentPalette.outline.opacity(0.2), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Screen Views

struct PlantCareListView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.plantTheme) var theme
    @State private var selectedTab: Int = 1 // Default to Plants tab

    private var currentPalette: ColorSchemePalette {
        theme.currentPalette(for: colorScheme)
    }

    // Sample Data
//    let careItems: [PlantCareItem] = [
//        PlantCareItem(title: "Indoor Houseplant Care Basics", subtitle: "Monday, Sep 17", imageName: "plant_succulents",
//        PlantCareItem(title: "Hoya Plant Care", subtitle: "Monday, Sep 17", imageName: "plant_cacti"),
//        PlantCareItem(title: "Watering Your Fiddle Leaf Fig", subtitle: "Friday, Sep 14", imageName: "plant_watering"),
//    ]
    
    let careItems: [PlantCareItem] = [
        PlantCareItem(title: "Indoor Houseplant Care Basics", subtitle: "Monday, Sep 17", imageName: "My-meme-with-cap-1"),
        PlantCareItem(title: "Hoya Plant Care", subtitle: "Monday, Sep 17", imageName: "My-meme-heineken"),
        PlantCareItem(title: "Watering Your Fiddle Leaf Fig", subtitle: "Friday, Sep 14", imageName: "My-meme-with-cap-2"),
    ]

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                 // Main Content Area
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                         Text("Plant Care")
                             .font(.largeTitle.bold())
                             .foregroundColor(currentPalette.onBackground)
                             .padding(.horizontal)
                             .padding(.top)

                        ForEach(careItems) { item in
                            NavigationLink(destination: PlantDetailView(plant: samplePlantDetail)) { // Pass appropriate detail data
                                CardView(item: item)
                            }
                            .buttonStyle(.plain) // Removes default button styling like blue tint
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom) // Space before tab bar overlap
                 }

                 // Custom Tab Bar Area (mimicking the look)
                 Divider().background(currentPalette.outline)
                 HStack {
//                     TabBarButton(icon: "calendar", label: "Today", tag: 0, selectedTab: $selectedTab, palette: currentPalette)
                     TabBarButton(icon: "leaf", label: "Plants", tag: 1, selectedTab: $selectedTab, palette: currentPalette)
                     TabBarButton(icon: "heart.circle", label: "Care", tag: 2, selectedTab: $selectedTab, palette: currentPalette)
                 }
                 .padding(.horizontal)
                 .padding(.top, 8)
//                 .padding(.bottom, UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0 > 0 ? 0 : 10) // Handle safe area better if needed // Use UIWindowScene.windows
//                 .padding(.bottom, UIWindowScene.windows.first?.safeAreaInsets.bottom ?? 0)
                 .background(currentPalette.background.edgesIgnoringSafeArea(.bottom)) // Extend background to bottom edge
            }
            .background(currentPalette.background.edgesIgnoringSafeArea(.all))
            .navigationBarHidden(true) // Hide default nav bar as we have a custom title
        }
        // Apply the overall background color from the theme
        .background(currentPalette.background.edgesIgnoringSafeArea(.all))
        // Need to set accent color if using default TabView for icon tinting
        // .accentColor(currentPalette.primary)
    }
}

// Simple Tab Bar Button Helper
struct TabBarButton: View {
    let icon: String
    let label: String
    let tag: Int
    @Binding var selectedTab: Int
    let palette: ColorSchemePalette

    var isSelected: Bool { tag == selectedTab }

    var body: some View {
        Button {
            selectedTab = tag
        } label: {
            VStack(spacing: 4) {
                Image(systemName: isSelected ? "\(icon).fill" : icon)
                    .font(.system(size: 22))
                Text(label)
                    .font(.caption)
            }
            .foregroundColor(isSelected ? palette.onPrimary : palette.onSurfaceVariant)
            .padding(.vertical, 6)
            .frame(maxWidth: .infinity)
            .background(isSelected ? palette.primary : Color.clear) // Or palette.surface for active state
            .clipShape(Capsule())
        }
    }
}

struct PlantDetailView: View {
    let plant: PlantDetail
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.plantTheme) var theme
    @Environment(\.presentationMode) var presentationMode // To dismiss the view

    private var currentPalette: ColorSchemePalette {
        theme.currentPalette(for: colorScheme)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Custom Navigation Area
                HStack {
                    Button { presentationMode.wrappedValue.dismiss() } label: {
                        Image(systemName: "chevron.backward")
                            .font(.title2)
                            .foregroundColor(currentPalette.onBackground)
                    }
                    Spacer()
                    Text(plant.name)
                        .font(.title2.bold())
                        .foregroundColor(currentPalette.onBackground)
                        // Add the wavy underline effect if desired (requires custom drawing or overlay)
                        // .overlay(alignment: .bottom) {
                        //     Rectangle().frame(height: 1).foregroundColor(currentPalette.primary) // Simple underline
                        // }
                    Spacer()
                    Button {} label: { // Placeholder for More button
                        Image(systemName: "ellipsis")
                           .font(.title2)
                           .foregroundColor(currentPalette.onBackground)
                    }
                }
                .padding(.horizontal)
                .padding(.top)

                Image(plant.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 200, height: 200)
                    .clipShape(Circle()) // Matches the screenshot
                    .padding(.top)

                VStack(alignment: .leading, spacing: 15) {
                    Text("Care")
                        .font(.headline)
                        .foregroundColor(currentPalette.primary) // Use primary for section titles

                    ForEach(plant.careInstructions, id: \.self) { instruction in
                        HStack {
                            Image(systemName: "drop.fill") // Example icon
                                .foregroundColor(currentPalette.secondary)
                            Text(instruction)
                                .foregroundColor(currentPalette.onBackground)
                        }
                    }

                    Divider().background(currentPalette.outline)

                    Text("About")
                        .font(.headline)
                        .foregroundColor(currentPalette.primary)

                    ForEach(plant.aboutInfo, id: \.text) { info in
                        HStack {
                            Image(systemName: info.icon)
                                .foregroundColor(currentPalette.secondary)
                            Text(info.text)
                                .foregroundColor(currentPalette.onBackground)
                        }
                    }
                }
                .padding(.horizontal)

                Spacer(minLength: 30)

                Button {
                    // Add to collection action
                } label: {
                    Text("Add to collection")
                        .font(.headline)
                        .foregroundColor(currentPalette.onPrimary)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(currentPalette.primary)
                        .clipShape(Capsule())
                }
                .padding(.horizontal)

                // Decorative elements at the bottom (requires custom drawing or image overlay)
                // Image("bottom_leaves").resizable().scaledToFit()

            } // End Main VStack
        } // End ScrollView
        .background(currentPalette.background.edgesIgnoringSafeArea(.all))
        .navigationBarHidden(true) // Using custom navigation elements
    }
}

// MARK: - Sample Data

let samplePlantDetail = PlantDetail(
    name: "Monstera Unique",
    imageName: "plant_monstera",
    careInstructions: [
        "Water every Tuesday",
        "Feed once monthly"
    ],
    aboutInfo: [
        (icon: "sun.max.fill", text: "Moderate light"),
        (icon: "humidity.fill", text: "Slightly dry, well-draining soil"),
        (icon: "house.fill", text: "Office windowsill")
    ]
)

// MARK: - Main App

@main
struct PlantApp: App {
    // Optionally, allow theme swapping later by making this a @StateObject
    private let theme = PlantThemeKey.defaultValue

    var body: some Scene {
        WindowGroup {
            PlantCareListView()
                // Inject the theme into the environment
                .environment(\.plantTheme, theme)
                // Add placeholder images to Assets:
                // plant_succulents.jpg, plant_cacti.jpg, plant_watering.jpg, plant_monstera.jpg
        }
    }
}

//#Preview {
//    // Optionally, allow theme swapping later by making this a @StateObject
//    let theme = PlantThemeKey.defaultValue
//    let samplePlantDetail = PlantDetail(
//        name: "Monstera Unique",
//        imageName: "plant_monstera",
//        careInstructions: [
//            "Water every Tuesday",
//            "Feed once monthly"
//        ],
//        aboutInfo: [
//            (icon: "sun.max.fill", text: "Moderate light"),
//            (icon: "humidity.fill", text: "Slightly dry, well-draining soil"),
//            (icon: "house.fill", text: "Office windowsill")
//        ]
//    )
//    
//    PlantCareListView()
//        // Inject the theme into the environment
//        .environment(\.plantTheme, theme)
//}
