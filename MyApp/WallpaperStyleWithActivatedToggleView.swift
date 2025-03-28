//
//  WallpaperStyleWithActivatedToggleView.swift
//  MyApp
//
//  Created by Cong Le on 3/28/25.
//


import SwiftUI

// MARK: - Main View

struct WallpaperStyleWithActivatedToggleView: View {
    
    // Enum to manage the selected color tab
    enum ColorTab {
        case wallpaper, basic
    }
    
    // State variables
    @State private var selectedTab: ColorTab = .wallpaper
    @State private var selectedBasicColorIndex: Int? = 1 // Default selection for basic colors
    @State private var isDarkModeEnabled: Bool = false // State to control dark mode
    
    // Sample data (replace with actual data fetching/logic)
    let wallpaperImageName = "My-meme-original" // Assume an image named "wallpaper_preview" exists in assets
    let wallpaperColors: [[Color]] = [
        [.pink.opacity(0.6), .orange.opacity(0.6), .yellow.opacity(0.6), .mint.opacity(0.6)],
        [.blue.opacity(0.6), .purple.opacity(0.6), .cyan.opacity(0.6), .indigo.opacity(0.6)],
        [.green.opacity(0.6), .green.opacity(0.6), .yellow.opacity(0.6), .orange.opacity(0.6)],
        [.red.opacity(0.6), .pink.opacity(0.6), .orange.opacity(0.6), .yellow.opacity(0.6)]
    ]
    let basicColors: [Color] = [.blue, .green, .purple, .brown] // Sample basic colors
    
    var body: some View {
        // Apply preferredColorScheme based on the state variable
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 25) {
                    
                    // Wallpaper Previews
                    WallpaperStyleWithActivatedTogglePreviews(imageName: wallpaperImageName)
                        .padding(.bottom, 5)
                    
                    // Change Wallpaper Button
                    WallpaperStyleWithActivatedToggleView_ChangeWallpaperButton()
                        .padding(.bottom, 15)
                    
                    // Color Selection Tabs
                    WallpaperStyleWithActivatedToggleView_ColorSelectionTabs(selectedTab: $selectedTab)
                        .padding(.bottom, 10)
                    
                    // Color Palettes
                    WallpaperStyleWithActivatedToggleView_ColorPalettes(
                        selectedTab: $selectedTab,
                        selectedBasicColorIndex: $selectedBasicColorIndex,
                        wallpaperColors: wallpaperColors,
                        basicColors: basicColors
                    )
                    .padding(.bottom, 15)
                    
                    // Dark Theme Toggle - Binds to isDarkModeEnabled
                    WallpaperStyleWithActivatedToggleView_DarkThemeToggle(isDarkModeEnabled: $isDarkModeEnabled)
                    
                    Spacer()
                }
                .padding()
                // Moved background setting inside ScrollView's content for better scope
                .background(Color(.systemGroupedBackground))
            }
            .navigationTitle("Wallpaper & style")
            .navigationBarTitleDisplayMode(.large)
            // Set the background of the ScrollView itself, which often contains the nav bar area too
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
        }
        .navigationViewStyle(.stack)
        // ***** THIS IS THE KEY CHANGE *****
        // Apply the color scheme based on the toggle state
        .preferredColorScheme(isDarkModeEnabled ? .dark : .light)
        // **********************************
    }
}

// MARK: - Subviews (Keep previous definitions for WallpaperPreviews, ChangeWallpaperButton, ColorSelectionTabs, TabButton, ColorPalettes, WallpaperColorSwatch, BasicColorSwatch)

// No changes needed in DarkThemeToggle itself, as the @Binding handles the state update
struct WallpaperStyleWithActivatedToggleView_DarkThemeToggle: View {
    @Binding var isDarkModeEnabled: Bool
    
    var body: some View {
        HStack {
            Text("Dark theme")
                .font(.body)
            
            Spacer()
            
            Toggle("", isOn: $isDarkModeEnabled)
                .labelsHidden()
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Preview (No changes needed here, it already showed both states)

struct WallpaperStyleWithActivatedToggleView_Previews: PreviewProvider {
    static var previews: some View {
        // This preview will now start in light mode, but the toggle will work
        WallpaperStyleWithActivatedToggleView()
        
        // You could force one preview to start dark if needed for testing initial state:
        // WallpaperStyleView(isDarkModeEnabled: true) // Custom initializer needed for this
        // .previewDisplayName("Dark Mode Start")
    }
}

// MARK: - Add initializer to set initial dark mode state for preview (Optional)
extension WallpaperStyleWithActivatedToggleView {
    // If you want to force a preview to start in dark mode,
    // you need an initializer like this:
    init(startInDarkMode: Bool = false) {
        _isDarkModeEnabled = State(initialValue: startInDarkMode)
        // Initialize other state variables if needed, though defaults might suffice
        _selectedTab = State(initialValue: .wallpaper)
        _selectedBasicColorIndex = State(initialValue: 1)
    }
}

// --- Keep other subview structs (WallpaperPreviews, ChangeWallpaperButton, etc.) as they were defined previously ---
// --- They don't need modification for the theme toggle functionality ---

// Example Placeholder Subviews (if you didn't copy them from the previous response)

struct WallpaperStyleWithActivatedTogglePreviews: View { /* ... as before ... */
    let imageName: String
    
    var body: some View {
        HStack(spacing: 15) {
            ZStack(alignment: .bottomLeading) {
                Image(imageName)
                    .resizable().aspectRatio(contentMode: .fill).frame(width: 150, height: 250).clipped()
                VStack(alignment: .leading) { Text("Thu, Sep 9").font(.caption).foregroundColor(.white).shadow(radius: 2); Text("16\n52").font(.system(size: 50, weight: .thin)).foregroundColor(.white.opacity(0.8)).shadow(radius: 3).lineSpacing(-10) }.padding()
            }.cornerRadius(20).shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            Image(imageName).resizable().aspectRatio(contentMode: .fill).frame(width: 150, height: 250).clipped().cornerRadius(20).shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        }.frame(maxWidth: .infinity)
    }
}
struct WallpaperStyleWithActivatedToggleView_ChangeWallpaperButton: View { /* ... as before ... */
    var body: some View {
        Button(action: { print("Change Wallpaper Tapped") }) {
            Label("Change wallpaper", systemImage: "photo.on.rectangle.angled").font(.footnote).foregroundColor(.primary).padding(.vertical, 8).padding(.horizontal, 12).background(Color(.systemGray5)).cornerRadius(15)
        }.buttonStyle(.plain).frame(maxWidth: .infinity)
    }
}
struct WallpaperStyleWithActivatedToggleView_ColorSelectionTabs: View { /* ... as before ... */
    @Binding var selectedTab: WallpaperStyleWithActivatedToggleView.ColorTab
    var body: some View { HStack(spacing: 10) { WallpaperStyleWithActivatedToggleView_TabButton(title: "Wallpaper colors", isSelected: selectedTab == .wallpaper) { selectedTab = .wallpaper }; WallpaperStyleWithActivatedToggleView_TabButton(title: "Basic colors", isSelected: selectedTab == .basic) { selectedTab = .basic } }.frame(maxWidth: .infinity) }
}
struct WallpaperStyleWithActivatedToggleView_TabButton: View { /* ... as before ... */
    let title: String; let isSelected: Bool; let action: () -> Void
    var body: some View { Button(action: action) { Text(title).font(.subheadline).fontWeight(.medium).foregroundColor(isSelected ? .white : .primary).padding(10).background(isSelected ? Color.accentColor : Color(.systemGray4)).clipShape(Capsule()) }.buttonStyle(.plain) }
}
struct WallpaperStyleWithActivatedToggleView_ColorPalettes: View { /* ... as before ... */
    @Binding var selectedTab: WallpaperStyleWithActivatedToggleView.ColorTab; @Binding var selectedBasicColorIndex: Int?; let wallpaperColors: [[Color]]; let basicColors: [Color]
    var body: some View { ScrollView(.horizontal, showsIndicators: false) { HStack(spacing: 15) { if selectedTab == .wallpaper { ForEach(0..<wallpaperColors.count, id: \.self) { index in WallpaperStyleWithActivatedToggleView_WallpaperColorSwatch(colors: wallpaperColors[index]).frame(width: 50, height: 50) } } else { ForEach(0..<basicColors.count, id: \.self) { index in WallpaperStyleWithActivatedToggleView_BasicColorSwatch(color: basicColors[index], isSelected: selectedBasicColorIndex == index).frame(width: 50, height: 50).onTapGesture { selectedBasicColorIndex = index } } } }.padding(.horizontal) }.frame(height: 60) }
}
struct WallpaperStyleWithActivatedToggleView_WallpaperColorSwatch: View { /* ... as before ... */
    let colors: [Color]
    var body: some View { ZStack { ForEach(0..<min(colors.count, 4), id: \.self) { index in Circle().fill(colors[index]).frame(width: 25, height: 25).offset(offsetForIndex(index)) } }.frame(maxWidth: .infinity, maxHeight: .infinity).background(Circle().fill(Color(.systemGray5))).clipShape(Circle()) }
    func offsetForIndex(_ index: Int) -> CGSize { let radius: CGFloat = 10; switch index { case 0: return CGSize(width: -radius, height: -radius); case 1: return CGSize(width: radius, height: -radius); case 2: return CGSize(width: -radius, height: radius); case 3: return CGSize(width: radius, height: radius); default: return .zero } }
}
struct WallpaperStyleWithActivatedToggleView_BasicColorSwatch: View { /* ... as before ... */
    let color: Color; let isSelected: Bool
    var body: some View { ZStack { Circle().fill(color).overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: isSelected ? 0 : 1)); if isSelected { Circle().fill(Color.black.opacity(0.3)); Image(systemName: "checkmark").foregroundColor(.white).font(.headline) } }.clipShape(Circle()) }
}
