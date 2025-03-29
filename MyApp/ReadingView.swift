//
//  ReadingView.swift
//  MyApp
//
//  Created by Cong Le on 3/28/25.
//

import SwiftUI
import Combine // Needed for ObservableObject

// Enum for different reading themes
enum ReadingTheme: String, CaseIterable, Identifiable {
    case systemDefault = "System"
    case light = "Light"
    case dark = "Dark"
    case sepia = "Sepia"
    case highContrastLight = "High Contrast Light"
    case highContrastDark = "High Contrast Dark"
    
    var id: String { self.rawValue }
    
    // Computed properties to return colors (simplified example)
    var textColor: Color {
        switch self {
        case .dark, .highContrastDark: return .white
        case .sepia: return Color(red: 0.4, green: 0.2, blue: 0.1) // Dark brown
        default: return .black
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .dark: return .black
        case .sepia: return Color(red: 0.98, green: 0.94, blue: 0.88) // Creamy
        case .highContrastLight: return .white
        case .highContrastDark: return .black // High contrast relies more on element contrast
        default: return .white
        }
    }
    
    // Suggests the preferred color scheme for the view
    var preferredColorScheme: ColorScheme? {
        switch self {
        case .light, .sepia, .highContrastLight: return .light
        case .dark, .highContrastDark: return .dark
        default: return nil // System default
        }
    }
}

// Observable object to hold reading settings
class ReadingSettings: ObservableObject {
    // @AppStorage can persist settings easily
    @AppStorage("readingTheme") var selectedTheme: ReadingTheme = .systemDefault
    @AppStorage("readingLineSpacingMultiplier") var lineSpacingMultiplier: Double = 1.5
    @AppStorage("readingColumnWidthMultiplier") var columnWidthMultiplier: Double = 1.0 // 1.0 = full width
    
    // Note: Font size is primarily handled by system Dynamic Type,
    // but you could add an additional multiplier if absolutely needed.
}


import SwiftUI

struct ReadingView: View {
    // Inject or create the settings object
    @StateObject private var settings = ReadingSettings()
    // Access system settings
    @Environment(\.sizeCategory) var sizeCategory // For Dynamic Type
    @Environment(\.colorScheme) var systemColorScheme // To resolve .systemDefault theme
    @Environment(\.accessibilityReduceTransparency) var reduceTransparency
    @Environment(\.accessibilityInvertColors) var increaseContrast
    
    let articleContent: String // The text to display
    
    // Determine the actual colors based on theme and system settings
    private var effectiveTextColor: Color {
        let theme = settings.selectedTheme
        if theme == .systemDefault {
            // Use standard system text color based on current scheme
            return Color(UIColor.label)
        } else if increaseContrast && theme == .highContrastLight {
            return .black // Ensure highest contrast
        } else if increaseContrast && theme == .highContrastDark {
            return .white // Ensure highest contrast
        }
        return theme.textColor
    }
    
    private var effectiveBackgroundColor: Color {
        let theme = settings.selectedTheme
        if theme == .systemDefault {
            // Use standard system background color
            return Color(UIColor.systemBackground)
        } else if reduceTransparency {
            // Ensure solid background if transparency reduction is on
            return theme.backgroundColor
        } else if increaseContrast && theme == .highContrastLight {
            return .white
        } else if increaseContrast && theme == .highContrastDark {
            return .black
        }
        return theme.backgroundColor
    }
    
    var body: some View {
        ScrollView {
            Text(articleContent)
            // 1. Apply Dynamic Type automatically (inherent in Text)
            // 2. Apply custom line spacing based on settings
                .lineSpacing(calculateLineSpacing())
            // 3. Apply text & background colors based on theme and system settings
                .foregroundColor(effectiveTextColor)
                .padding() // Add padding around the text block
            // 4. Control column width, centered
                .frame(maxWidth: UIScreen.main.bounds.width * settings.columnWidthMultiplier)
                .frame(maxWidth: .infinity) // Centers the content within the ScrollView
                .background(effectiveBackgroundColor) // Apply background color
        }
        .background(effectiveBackgroundColor.ignoresSafeArea()) // Ensure background fills edges
        .navigationTitle("Article Title") // Example title
        .toolbar { // Place a button to open settings
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    // Action to present the settings view (e.g., using a sheet)
                    presentSettings()
                } label: {
                    Label("Reading Settings", systemImage: "textformat.size")
                }
                .accessibilityLabel("Adjust Reading Settings")
            }
        }
        // 5. Set the preferred color scheme based on the selected theme
        .preferredColorScheme(settings.selectedTheme.preferredColorScheme)
        .environmentObject(settings) // Make settings available to presented views if needed
    }
    
    private func calculateLineSpacing() -> CGFloat {
        // Base spacing can be adjusted. Multiply by user setting.
        // Example: Base of 5 points, modified by multiplier.
        return 5.0 * settings.lineSpacingMultiplier
    }
    
    private func presentSettings() {
        // Logic to show the ReadingSettingsView, typically via .sheet
        // This requires adding a @State variable like `isShowingSettings`
        // and attaching `.sheet(isPresented: $isShowingSettings) { ReadingSettingsView() }`
        // to the ScrollView or parent container.
        print("Present Settings View Placeholder") // Placeholder
    }
}

#Preview {
    ReadingView(articleContent: "Hello, World!")
}
