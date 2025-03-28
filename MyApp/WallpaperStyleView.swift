//
//  WallpaperStyleView.swift
//  MyApp
//
//  Created by Cong Le on 3/28/25.
//

import SwiftUI

// MARK: - Main View

struct WallpaperStyleView: View {
    
    // Enum to manage the selected color tab
    enum ColorTab {
        case wallpaper, basic
    }
    
    // State variables
    @State private var selectedTab: ColorTab = .wallpaper
    @State private var selectedBasicColorIndex: Int? = 1 // Default selection for basic colors
    @State private var isDarkModeEnabled: Bool = false
    
    // Sample data (replace with actual data fetching/logic)
    let wallpaperImageName = "wallpaper_preview" // Assume an image named "wallpaper_preview" exists in assets
    let wallpaperColors: [[Color]] = [
        [.pink.opacity(0.6), .orange.opacity(0.6), .yellow.opacity(0.6), .mint.opacity(0.6)],
        [.blue.opacity(0.6), .purple.opacity(0.6), .cyan.opacity(0.6), .indigo.opacity(0.6)],
        [.green.opacity(0.6), .green.opacity(0.6), .yellow.opacity(0.6), .orange.opacity(0.6)],
        [.red.opacity(0.6), .pink.opacity(0.6), .orange.opacity(0.6), .yellow.opacity(0.6)]
    ]
    let basicColors: [Color] = [.blue, .green, .purple, .brown] // Sample basic colors

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 25) {
                    
                    // Title - Using navigation title for a more iOS-like feel
                    // Text("Wallpaper & style")
                    //     .font(.largeTitle)
                    //     .fontWeight(.medium) // Adjusted weight
                    //     .padding(.bottom, 10)
                    
                    // Wallpaper Previews
                    WallpaperPreviews(imageName: wallpaperImageName)
                        .padding(.bottom, 5) // Reduced bottom padding

                    // Change Wallpaper Button
                    ChangeWallpaperButton()
                        .padding(.bottom, 15) // Added padding below button

                    // Color Selection Tabs
                    ColorSelectionTabs(selectedTab: $selectedTab)
                        .padding(.bottom, 10)

                    // Color Palettes
                    ColorPalettes(
                        selectedTab: $selectedTab,
                        selectedBasicColorIndex: $selectedBasicColorIndex,
                        wallpaperColors: wallpaperColors,
                        basicColors: basicColors
                    )
                    .padding(.bottom, 15)

                    // Dark Theme Toggle
                    DarkThemeToggle(isDarkModeEnabled: $isDarkModeEnabled)

                    Spacer() // Pushes content up if ScrollView isn't needed
                }
                .padding()
            }
            .navigationTitle("Wallpaper & style") // iOS-style title
            .navigationBarTitleDisplayMode(.large) // Use large title
            .background(Color(.systemGroupedBackground)) // iOS system background color
        }
        .navigationViewStyle(.stack) // Use stack style for clarity
    }
}

// MARK: - Subviews

struct WallpaperPreviews: View {
    let imageName: String
    
    var body: some View {
        HStack(spacing: 15) {
            // Left Preview with Overlay
            ZStack(alignment: .bottomLeading) {
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 150, height: 250) // Approximate size
                    .clipped()
                
                VStack(alignment: .leading) {
                    Text("Thu, Sep 9") // Sample Date
                        .font(.caption)
                        .foregroundColor(.white)
                        .shadow(radius: 2)
                    Text("16\n52") // Sample Time
                        .font(.system(size: 50, weight: .thin))
                        .foregroundColor(.white.opacity(0.8))
                        .shadow(radius: 3)
                        .lineSpacing(-10) // Adjust line spacing
                }
                .padding()
            }
            .cornerRadius(20) // Rounded corners
             .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2) // Subtle shadow

            // Right Preview
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 150, height: 250)
                .clipped()
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
        .frame(maxWidth: .infinity) // Center the HStack
    }
}

struct ChangeWallpaperButton: View {
    var body: some View {
        Button(action: {
            print("Change Wallpaper Tapped")
            // Add action to change wallpaper
        }) {
            Label("Change wallpaper", systemImage: "photo.on.rectangle.angled")
                .font(.footnote) // Smaller font
                .foregroundColor(.primary) // Use primary color for adaptability
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(Color(.systemGray5)) // Subtle background
                .cornerRadius(15) // More rounded corners
        }
        .buttonStyle(.plain) // Use plain style to avoid default button styling interference
        .frame(maxWidth: .infinity) // Center the button
    }
}

struct ColorSelectionTabs: View {
    @Binding var selectedTab: WallpaperStyleView.ColorTab
    
    var body: some View {
        HStack(spacing: 10) {
            TabButton(title: "Wallpaper colors",
                      isSelected: selectedTab == .wallpaper) {
                selectedTab = .wallpaper
            }
            
            TabButton(title: "Basic colors",
                      isSelected: selectedTab == .basic) {
                selectedTab = .basic
            }
        }
        .frame(maxWidth: .infinity) // Center the tabs
    }
}

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline) // Slightly smaller font
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .primary) // Adapt text color
                .padding(.vertical, 10)
                .padding(.horizontal, 20)
                .background(isSelected ? Color.accentColor : Color(.systemGray4)) // Use accent color for selected
                .clipShape(Capsule()) // Pill shape
        }
        .buttonStyle(.plain)
    }
}

struct ColorPalettes: View {
    @Binding var selectedTab: WallpaperStyleView.ColorTab
    @Binding var selectedBasicColorIndex: Int?
    let wallpaperColors: [[Color]]
    let basicColors: [Color]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 15) { // Increased spacing
                if selectedTab == .wallpaper {
                    ForEach(0..<wallpaperColors.count, id: \.self) { index in
                        WallpaperColorSwatch(colors: wallpaperColors[index])
                            .frame(width: 50, height: 50) // Explicit size
                            // Add tap gesture if selection is needed for wallpaper colors
                    }
                } else {
                    ForEach(0..<basicColors.count, id: \.self) { index in
                        BasicColorSwatch(color: basicColors[index],
                                         isSelected: selectedBasicColorIndex == index)
                            .frame(width: 50, height: 50) // Explicit size
                            .onTapGesture {
                                selectedBasicColorIndex = index
                            }
                    }
                }
            }
            .padding(.horizontal) // Padding inside ScrollView
        }
        .frame(height: 60) // Constrain ScrollView height
    }
}

struct WallpaperColorSwatch: View {
    let colors: [Color]
    
    var body: some View {
        // Simplified representation: using overlapping circles
        // A more accurate version would involve drawing arcs (Paths)
        ZStack {
            ForEach(0..<min(colors.count, 4), id: \.self) { index in
                 Circle()
                     .fill(colors[index])
                     .frame(width: 25, height: 25) // Smaller inner circles
                     .offset(offsetForIndex(index)) // Position them
             }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity) // Expand within parent frame
        .background(Circle().fill(Color(.systemGray5))) // Background circle
        .clipShape(Circle())
    }
    
    // Helper to position the inner circles (adjust as needed for desired look)
    func offsetForIndex(_ index: Int) -> CGSize {
        let radius: CGFloat = 10
        switch index {
        case 0: return CGSize(width: -radius, height: -radius) // Top-left
        case 1: return CGSize(width: radius, height: -radius) // Top-right
        case 2: return CGSize(width: -radius, height: radius) // Bottom-left
        case 3: return CGSize(width: radius, height: radius) // Bottom-right
        default: return .zero
        }
    }
}

struct BasicColorSwatch: View {
    let color: Color
    let isSelected: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .fill(color)
                .overlay(
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: isSelected ? 0 : 1) // Subtle border if not selected
                )
            
            if isSelected {
                Circle()
                     .fill(Color.black.opacity(0.3)) // Dim overlay when selected
                Image(systemName: "checkmark")
                    .foregroundColor(.white)
                    .font(.headline) // Make checkmark slightly larger
            }
        }
        .clipShape(Circle()) // Ensure clipping
    }
}

struct DarkThemeToggle: View {
    @Binding var isDarkModeEnabled: Bool
    
    var body: some View {
        HStack {
            Text("Dark theme")
                .font(.body) // Standard body font

            Spacer()

            Toggle("", isOn: $isDarkModeEnabled)
                .labelsHidden() // Hide the default label
        }
        .padding(.vertical, 8) // Add some vertical padding
    }
}

// MARK: - Preview

struct WallpaperStyleView_Previews: PreviewProvider {
    static var previews: some View {
        // Create a placeholder image in your Assets.xcassets named "wallpaper_preview"
        // For the preview to work correctly.
        WallpaperStyleView()
            .preferredColorScheme(.light) // Preview in light mode
        
        WallpaperStyleView()
             .preferredColorScheme(.dark) // Preview in dark mode (to check toggle appearance)
    }
}
