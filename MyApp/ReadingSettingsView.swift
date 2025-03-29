//
//  ReadingSettingsView.swift
//  MyApp
//
//  Created by Cong Le on 3/28/25.
//


import SwiftUI

struct ReadingSettingsView: View {
    @EnvironmentObject var settings: ReadingSettings // Access shared settings
    @Environment(\.dismiss) var dismiss // To close the sheet
    
    var body: some View {
        NavigationView {
            Form {
                Section("Appearance") {
                    Picker("Theme", selection: $settings.selectedTheme) {
                        ForEach(ReadingTheme.allCases) { theme in
                            Text(theme.rawValue).tag(theme)
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Line Spacing: \(settings.lineSpacingMultiplier, specifier: "%.1f")x")
                        Slider(value: $settings.lineSpacingMultiplier, in: 1.0...3.0, step: 0.1) {
                            Text("Line Spacing Slider") // Hidden label
                        } minimumValueLabel: {
                            Text("1.0x")
                        } maximumValueLabel: {
                            Text("3.0x")
                        }
                        .accessibilityLabel("Line Spacing")
                        .accessibilityValue("\(settings.lineSpacingMultiplier, specifier: "%.1f") times normal")
                    }
                }
                
                Section("Layout") {
                    VStack(alignment: .leading) {
                        Text("Content Width: \(Int(settings.columnWidthMultiplier * 100))%")
                        Slider(value: $settings.columnWidthMultiplier, in: 0.5...1.0, step: 0.1) {
                            Text("Content Width Slider") // Hidden label
                        } minimumValueLabel: {
                            Text("50%")
                        } maximumValueLabel: {
                            Text("100%")
                        }
                        .accessibilityLabel("Content Width")
                        .accessibilityValue("\(Int(settings.columnWidthMultiplier * 100)) percent")
                    }
                    .accessibilityElement(children: .combine) // Combine labels for VoiceOver
                }
            }
            .navigationTitle("Reading Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// Assuming ReadingView, ReadingSettings, and ReadingTheme are defined as in the previous response

#if DEBUG // Ensure previews are only compiled in Debug builds
struct ReadingView_Previews: PreviewProvider {
    // Sample content for previews
    static let sampleArticle = """
    This is a sample article demonstrating the reading view.
    Glaucoma affects peripheral vision and contrast sensitivity.
    Adjusting themes and spacing can significantly improve readability for users.
    This text should adapt to the selected theme settings.
    """

    static var previews: some View {
        // Group allows multiple previews
        Group {
            // --- System Default (Simulated Light Mode) ---
            previewWithTheme(.systemDefault, displayName: "System Default (Light)")
                .preferredColorScheme(.light) // Force light mode for this preview

            // --- System Default (Simulated Dark Mode) ---
            previewWithTheme(.systemDefault, displayName: "System Default (Dark)")
                .preferredColorScheme(.dark) // Force dark mode for this preview

            // --- Light Theme ---
            previewWithTheme(.light, displayName: "Light Theme")

            // --- Dark Theme ---
            previewWithTheme(.dark, displayName: "Dark Theme")

            // --- Sepia Theme ---
            previewWithTheme(.sepia, displayName: "Sepia Theme")

            // --- High Contrast Light Theme ---
            previewWithTheme(.highContrastLight, displayName: "High Contrast Light")
                 // Simulate Increase Contrast (visually approximate by theme colors)
                 // .environment(\.accessibilityIncreaseContrast, true) // Actual way

            // --- High Contrast Dark Theme ---
            previewWithTheme(.highContrastDark, displayName: "High Contrast Dark")
                 // Simulate Increase Contrast
//                  .environment(\.accessibilityIncreaseContrast, true) // Actual way
        }
    }

    // Helper function to create a configured ReadingView instance
    static func previewWithTheme(_ theme: ReadingTheme, displayName: String) -> some View {
        // Create a temporary settings object for the preview
        let settings = ReadingSettings()
        // Set the desired theme
        settings.selectedTheme = theme

        return ReadingView(
                 // Inject the configured StateObject directly into the view for preview
//                 settings: settings, // Assuming ReadingView takes settings this way
                 articleContent: sampleArticle
               )
               .previewDisplayName(displayName)
               // Wrap in a NavigationView for realistic toolbar display if needed
               // .embedInNavigation() // Example helper if you have one
    }

    // Optional: Modify ReadingView slightly for easier preview injection if needed
    // If ReadingView uses @StateObject private var settings = ReadingSettings() internally,
    // you might need a specific initializer for previews like:
    // init(settings: ReadingSettings = ReadingSettings(), articleContent: String) {
    //     _settings = StateObject(wrappedValue: settings)
    //     self.articleContent = articleContent
    // }
}

// Optional: Helper to embed view in NavigationView for preview context
// extension View {
//     func embedInNavigation() -> some View {
//         NavigationView { self }
//     }
// }

#endif
