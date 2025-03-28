//
//  V3.swift
//  MyApp
//
//  Created by Cong Le on 3/28/25.
//

import SwiftUI
// In a real app, you might need PhotosUI for the picker
// import PhotosUI

// MARK: - Main View

struct WallpaperStyleView: View {
    
    enum ColorTab {
        case wallpaper, basic
    }
    
    // --- State Variables ---
    @State private var selectedTab: ColorTab = .wallpaper
    @State private var isDarkModeEnabled: Bool = false
    
    // Wallpaper selection state
    @State private var currentWallpaperName: String = "My-meme-original" // Start with the first wallpaper
    
    // Theme selection state
    @State private var selectedWallpaperColorSetIndex: Int? = 0 // Default to first wallpaper theme
    @State private var selectedBasicColorIndex: Int? = nil // No basic color selected initially
    
    // Simulation/Data
    private let availableWallpapers = ["My-meme-original", "My-meme-with-cap-1","My-meme-with-cap-2", "My-meme-heineken","My-meme-microphone","My-meme-red-wine-glass"] // Add more image names
    private let wallpaperColors: [[Color]] = [
        // Corresponds to wallpaper_preview_1
        [.pink.opacity(0.7), .orange.opacity(0.6), .yellow.opacity(0.5), .purple.opacity(0.6)],
        // Corresponds to wallpaper_preview_2
        [.blue.opacity(0.7), .cyan.opacity(0.6), .teal.opacity(0.5), .indigo.opacity(0.6)],
        // Corresponds to wallpaper_preview_3
        [.green.opacity(0.7), .green.opacity(0.6), .yellow.opacity(0.5), .teal.opacity(0.6)]
        // Add more sets matching availableWallpapers
    ]
    private let basicColors: [Color] = [.blue, .green, .purple, .orange, .red, .gray] // Expanded basic colors

    // Computed property to determine the currently active accent color
    private var currentAccentColor: Color {
        if let index = selectedWallpaperColorSetIndex, index < wallpaperColors.count {
            // Use the first color from the selected wallpaper set as accent
            return wallpaperColors[index].first ?? .accentColor // Fallback to default accent
        } else if let index = selectedBasicColorIndex, index < basicColors.count {
            // Use the selected basic color
            return basicColors[index]
        } else {
            // Default if nothing is selected (or selection is invalid)
            return .accentColor
        }
    }
    
    // --- Body ---
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 25) { // Consistent spacing
                    
                    // Wallpaper Previews - Now uses dynamic wallpaper name
                    WallpaperPreviews(imageName: currentWallpaperName)
                        .padding(.bottom, 5)

                    // Change Wallpaper Button - Added Action
                    ChangeWallpaperButton {
                        simulateWallpaperChange()
                    }
                    .padding(.bottom, 15)

                    // Color Selection Tabs - Pass accent color for styling
                    ColorSelectionTabs(
                        selectedTab: $selectedTab,
                        accentColor: currentAccentColor // Pass the dynamic accent color
                    )
                    .padding(.bottom, 10)

                    // Color Palettes - Added tap actions and selection state
                    ColorPalettes(
                        selectedTab: $selectedTab,
                        selectedBasicColorIndex: $selectedBasicColorIndex,
                        selectedWallpaperColorSetIndex: $selectedWallpaperColorSetIndex,
                        wallpaperColors: wallpaperColors,
                        basicColors: basicColors
                    )
                    .padding(.bottom, 15)

                    // Dark Theme Toggle
                    DarkThemeToggle(isDarkModeEnabled: $isDarkModeEnabled)

                    Spacer()
                }
                .padding()
                .background(Color(.systemGroupedBackground)) // Apply background to the VStack content
            }
            .navigationTitle("Wallpaper & style")
            .navigationBarTitleDisplayMode(.large)
            .background(Color(.systemGroupedBackground).ignoresSafeArea()) // Background covers nav bar area too
        }
        .navigationViewStyle(.stack)
        .preferredColorScheme(isDarkModeEnabled ? .dark : .light)
        // Apply the accent color globally for demonstration (affects default buttons, toggles etc.)
        // In a real app, theme application might be more complex
        .accentColor(currentAccentColor)
    }
    
    // --- Action Methods ---
    private func simulateWallpaperChange() {
        guard let currentIndex = availableWallpapers.firstIndex(of: currentWallpaperName) else {
            currentWallpaperName = availableWallpapers.first ?? "wallpaper_preview_1"
            return
        }
        
        let nextIndex = (currentIndex + 1) % availableWallpapers.count
        currentWallpaperName = availableWallpapers[nextIndex]
        
        // Optional: Automatically select the corresponding wallpaper theme
         // Comment out if you want theme selection to be independent
         // selectWallpaperTheme(index: nextIndex)
        print("Changed wallpaper to: \(currentWallpaperName)")
    }
    
    // Helper method to manage theme selection logic (used by ColorPalettes)
    // This logic can be embedded directly in the tap gestures if preferred
    private func selectWallpaperTheme(index: Int) {
        withAnimation(.easeInOut(duration: 0.2)) {
            selectedWallpaperColorSetIndex = index
            selectedBasicColorIndex = nil // Deselect basic color
        }
         print("Selected Wallpaper Theme Index: \(index)")
    }
    
    private func selectBasicTheme(index: Int) {
         withAnimation(.easeInOut(duration: 0.2)) {
            selectedBasicColorIndex = index
            selectedWallpaperColorSetIndex = nil // Deselect wallpaper theme
        }
         print("Selected Basic Color Index: \(index)")
    }
}

// MARK: - Modified Subviews

struct WallpaperPreviews: View {
    let imageName: String // Now dynamically set

    var body: some View {
        HStack(spacing: 15) {
            // Left Preview with Overlay
            ZStack(alignment: .bottomLeading) {
                 // Use AsyncImage for potential future network loading
                 Image(imageName) // Assume local asset for now
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 150, height: 250)
                    .clipped()
                
                 // --- Time/Date Overlay ---
                 VStack(alignment: .leading) {
                    Text(Date(), style: .date) // Example dynamic date
                         .font(.caption)
                         .foregroundColor(.white)
                         .shadow(radius: 2)
                     Text(Date(), style: .time) // Example dynamic time
                         .font(.system(size: 50, weight: .thin))
                         .foregroundColor(.white.opacity(0.8))
                         .shadow(radius: 3)
                         // .lineSpacing(-10) // Adjust if needed
                 }
                 .padding()
                 // --- End Overlay ---
            }
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            // Add transition for image change
            .transition(.opacity.combined(with: .scale(scale: 0.95)))
             .id(imageName) // Use ID to help SwiftUI differentiate images for transitions

            // Right Preview (static or second preview)
             Image(imageName) // Use the same image name, could be different
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 150, height: 250)
                .clipped()
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
                .id(imageName + "_preview2") // Different ID if content might differ
        }
        .frame(maxWidth: .infinity)
    }
}

struct ChangeWallpaperButton: View {
    let action: () -> Void // Action closure

    var body: some View {
        Button(action: action) { // Execute the passed action
            Label("Change wallpaper", systemImage: "photo.on.rectangle.angled")
                .font(.callout) // Slightly larger than footnote
                .foregroundColor(.primary)
                .padding(.vertical, 10) // Slightly more padding
                .padding(.horizontal, 16)
                .background(Material.regular) // Use a blur material background
                .clipShape(Capsule()) // Pill shape
                 // Add a subtle border matching the material
                .overlay(Capsule().stroke(Color.gray.opacity(0.2), lineWidth: 1))
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
    }
}

struct ColorSelectionTabs: View {
    @Binding var selectedTab: WallpaperStyleView.ColorTab
    let accentColor: Color // Receive the dynamic accent color

    var body: some View {
        HStack(spacing: 10) {
            TabButton(title: "Wallpaper colors",
                      isSelected: selectedTab == .wallpaper,
                      accentColor: accentColor) { // Pass accent color
                 withAnimation { selectedTab = .wallpaper }
            }
            
            TabButton(title: "Basic colors",
                      isSelected: selectedTab == .basic,
                      accentColor: accentColor) { // Pass accent color
                 withAnimation { selectedTab = .basic }
            }
        }
        .background(Color(.systemGray5)) // Background for the tab container
        .clipShape(Capsule())
        .frame(maxWidth: .infinity) // Center the tabs
    }
}

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let accentColor: Color // Use the passed accent color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .medium) // Emphasize selected
                 // Use accent for selected text too, or keep it white/primary
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.vertical, 10)
                .padding(.horizontal, 20)
                .background(
                    // Use accentColor for the selected background
                    Capsule().fill(isSelected ? accentColor : Color.clear)
                )
        }
        .buttonStyle(.plain)
    }
}

struct ColorPalettes: View {
    // Bindings to update parent state
    @Binding var selectedTab: WallpaperStyleView.ColorTab
    @Binding var selectedBasicColorIndex: Int?
    @Binding var selectedWallpaperColorSetIndex: Int?
    
    // Data
    let wallpaperColors: [[Color]]
    let basicColors: [Color]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 18) { // Slightly more spacing
                if selectedTab == .wallpaper {
                    ForEach(0..<wallpaperColors.count, id: \.self) { index in
                        WallpaperColorSwatch(
                            colors: wallpaperColors[index],
                            isSelected: selectedWallpaperColorSetIndex == index // Pass selection state
                        )
                            .frame(width: 55, height: 55) // Slightly larger
                            .onTapGesture {
                                // Select wallpaper theme, deselect basic
                                withAnimation {
                                    selectedWallpaperColorSetIndex = index
                                    selectedBasicColorIndex = nil
                                }
                            }
                    }
                } else {
                    ForEach(0..<basicColors.count, id: \.self) { index in
                        BasicColorSwatch(
                            color: basicColors[index],
                            isSelected: selectedBasicColorIndex == index
                        )
                            .frame(width: 55, height: 55) // Slightly larger
                            .onTapGesture {
                                // Select basic theme, deselect wallpaper
                                 withAnimation {
                                    selectedBasicColorIndex = index
                                    selectedWallpaperColorSetIndex = nil
                                }
                            }
                    }
                }
            }
            .padding(.horizontal) // Padding inside ScrollView
        }
        .frame(height: 65) // Adjust height for larger swatches
    }
}

struct WallpaperColorSwatch: View {
    let colors: [Color]
    let isSelected: Bool // Added isSelected state

    var body: some View {
        ZStack {
            // Background Circle
            Circle()
                .fill(Color(.systemGray5)) // Use a system background color
                .overlay(
                    // Show border when selected
                    Circle()
                        .stroke(Color.primary.opacity(0.5), lineWidth: isSelected ? 2.5 : 0)
                        .padding(2) // Inset the border slightly
                )

            // Multi-color representation (Simplified Quarters)
             // For better visual, more complex Path drawing is needed
            GeometryReader { geo in
                 Path { path in // Top-Left Quarter
                    path.move(to: CGPoint(x: geo.size.width / 2, y: geo.size.height / 2))
                    path.addArc(center: CGPoint(x: geo.size.width / 2, y: geo.size.height / 2), radius: geo.size.width / 2, startAngle: .degrees(180), endAngle: .degrees(270), clockwise: false)
                    path.closeSubpath()
                }.fill(colors.indices.contains(0) ? colors[0] : .clear)

                 Path { path in // Top-Right Quarter
                    path.move(to: CGPoint(x: geo.size.width / 2, y: geo.size.height / 2))
                    path.addArc(center: CGPoint(x: geo.size.width / 2, y: geo.size.height / 2), radius: geo.size.width / 2, startAngle: .degrees(270), endAngle: .degrees(0), clockwise: false)
                    path.closeSubpath()
                }.fill(colors.indices.contains(1) ? colors[1] : .clear)

                 Path { path in // Bottom-Right Quarter
                    path.move(to: CGPoint(x: geo.size.width / 2, y: geo.size.height / 2))
                     path.addArc(center: CGPoint(x: geo.size.width / 2, y: geo.size.height / 2), radius: geo.size.width / 2, startAngle: .degrees(0), endAngle: .degrees(90), clockwise: false)
                    path.closeSubpath()
                }.fill(colors.indices.contains(2) ? colors[2] : .clear)

                 Path { path in // Bottom-Left Quarter
                    path.move(to: CGPoint(x: geo.size.width / 2, y: geo.size.height / 2))
                     path.addArc(center: CGPoint(x: geo.size.width / 2, y: geo.size.height / 2), radius: geo.size.width / 2, startAngle: .degrees(90), endAngle: .degrees(180), clockwise: false)
                    path.closeSubpath()
                }.fill(colors.indices.contains(3) ? colors[3] : .clear)
            }
            .clipShape(Circle())
            .padding(6) // Padding inside the background circle
        }
        .clipShape(Circle()) // Clip the whole ZStack
    }
}

struct BasicColorSwatch: View {
    let color: Color
    let isSelected: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .fill(color)
                 // More pronounced selection indication
                 .overlay(
                     Circle()
                         .stroke(Color.primary.opacity(0.6), lineWidth: isSelected ? 3 : 0) // Thicker border
                         .padding(2) // Inset border
                 )
                .overlay( // Inner shadow for depth when selected
                    Circle()
                        .stroke(Color.black.opacity(isSelected ? 0.2 : 0), lineWidth: 1)
                        .blur(radius: isSelected ? 2 : 0)
                        .padding(5)
                )

            if isSelected {
                // Checkmark can be slightly smaller or styled differently
                 Image(systemName: "checkmark")
                    .foregroundColor(.white)
                     .font(.system(size: 18, weight: .semibold)) // Adjusted size/weight
                     .shadow(radius: 1) // Subtle shadow for checkmark
            }
        }
        .clipShape(Circle())
    }
}

// DarkThemeToggle remains the same as it correctly binds to isDarkModeEnabled
struct DarkThemeToggle: View { /* ... as before ... */
     @Binding var isDarkModeEnabled: Bool
     var body: some View { HStack { Text("Dark theme").font(.body); Spacer(); Toggle("", isOn: $isDarkModeEnabled).labelsHidden() }.padding(.vertical, 8) }
}

// MARK: - Preview

struct WallpaperStyleView_Previews: PreviewProvider {
    static var previews: some View {
        // Add placeholder images "wallpaper_preview_1", "wallpaper_preview_2", etc. to Assets
        Group {
            WallpaperStyleView()
                 .previewDisplayName("Light Mode")
            
            WallpaperStyleView(startInDarkMode: true) // Use optional initializer
                 .previewDisplayName("Dark Mode")
        }
    }
}

// Optional Initializer (as before)
extension WallpaperStyleView {
     init(startInDarkMode: Bool = false) {
        _isDarkModeEnabled = State(initialValue: startInDarkMode)
        _selectedTab = State(initialValue: .wallpaper)
         // Ensure initial wallpaper name matches available list and default theme index
        let initialWallpaper = "My-meme-original"
         _currentWallpaperName = State(initialValue: initialWallpaper)
        _selectedWallpaperColorSetIndex = State(initialValue: 0) // Match first wallpaper
        _selectedBasicColorIndex = State(initialValue: nil)
    }
}
