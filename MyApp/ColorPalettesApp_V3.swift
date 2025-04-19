//
//  ColorPalettesApp_V3.swift
//  MyApp
//
//  Created by Cong Le on 4/18/25.
//

import SwiftUI
import UIKit // Needed for UIColor conversion and UIPasteboard

// MARK: - Color Information Structure

/// Represents a color with its name, SwiftUI Color object, and definition details.
struct ColorInfo: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let color: Color

    /// Enum representing how the color was originally defined.
    enum Definition {
        case rgb(r: Double, g: Double, b: Double, space: Color.RGBColorSpace = .sRGB)
        case hsb(h: Double, s: Double, b: Double)
        case white(w: Double)
        case standard(name: String) // For standard system colors like .red
    }
    let definition: Definition
    let opacity: Double = 1.0 // Assuming full opacity for simplicity here

    /// Provides a user-friendly string describing the color's definition.
    var definitionString: String {
        switch definition {
        case .rgb(let r, let g, let b, let space):
            let spaceStr = (space == .displayP3) ? "P3" : "sRGB"
            return String(format: "RGB(%@ %.2f, %.2f, %.2f)", spaceStr, r, g, b)
        case .hsb(let h, let s, let b):
            return String(format: "HSB(%.2f, %.2f, %.2f)", h, s, b)
        case .white(let w):
            return String(format: "White(%.2f)", w)
        case .standard(let name):
            return "Standard (\(name))"
        }
    }

    /// Generates an approximate Hex string representation (sRGB based).
    var hexString: String {
        // Convert to UIColor to reliably get sRGB components for Hex.
        // This handles different color initializers more consistently.
        let uiColor = UIColor(color)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        // getRed(_:green:blue:alpha:) converts to sRGB components.
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        // Clamp extended range values (like >1 or <0) to the standard 0-1 range
        // for typical #RRGGBB hex representation.
        let clampedRed = min(max(0, red), 1)
        let clampedGreen = min(max(0, green), 1)
        let clampedBlue = min(max(0, blue), 1)

        // Format as a standard 6-digit hex string.
        return String(format: "#%02X%02X%02X",
                      Int(clampedRed * 255 + 0.5), // Add 0.5 for correct rounding
                      Int(clampedGreen * 255 + 0.5),
                      Int(clampedBlue * 255 + 0.5))
    }

    // Equatable conformance based on unique ID.
    static func == (lhs: ColorInfo, rhs: ColorInfo) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Palettes Collection

/// Contains static arrays of predefined ColorInfo objects, grouped by category.
struct Palettes {

    /// Colors defined in the Display P3 color space, offering a wider gamut than sRGB.
    /// Requires a P3-capable display to see the full effect.
    static let displayP3: [ColorInfo] = [
        .init(name: "P3 Vibrant Red", color: Color(.displayP3, red: 1.0, green: 0.1, blue: 0.1), definition: .rgb(r: 1.0, g: 0.1, b: 0.1, space: .displayP3)),
        .init(name: "P3 Lush Green", color: Color(.displayP3, red: 0.1, green: 0.9, blue: 0.2), definition: .rgb(r: 0.1, g: 0.9, b: 0.2, space: .displayP3)),
        .init(name: "P3 Deep Blue", color: Color(.displayP3, red: 0.1, green: 0.2, blue: 0.95), definition: .rgb(r: 0.1, g: 0.2, b: 0.95, space: .displayP3)),
        .init(name: "P3 Bright Magenta", color: Color(.displayP3, red: 0.95, green: 0.1, blue: 0.8), definition: .rgb(r: 0.95, g: 0.1, b: 0.8, space: .displayP3)),
        .init(name: "P3 Vivid Orange", color: Color(.displayP3, red: 1.0, green: 0.5, blue: 0.0), definition: .rgb(r: 1.0, g: 0.5, b: 0.0, space: .displayP3))
    ]

    /// Colors defined with components outside the standard 0.0-1.0 range (sRGB).
    /// Primarily relevant for HDR (High Dynamic Range) displays and effects.
    /// On standard displays, these will often be clamped.
    static let extendedRange: [ColorInfo] = [
        .init(name: "Ultra White (>1)", color: Color(.sRGB, white: 1.1, opacity: 1.0), definition: .white(w: 1.1)),
        .init(name: "Intense Red (>1)", color: Color(.sRGB, red: 1.2, green: 0.1, blue: 0.1, opacity: 1.0), definition: .rgb(r: 1.2, g: 0.1, b: 0.1)),
        .init(name: "Deeper Black (<0)", color: Color(.sRGB, white: -0.1, opacity: 1.0), definition: .white(w: -0.1)),
        .init(name: "Super Bright Green", color: Color(.sRGBLinear, red: -0.2, green: 1.3, blue: 0.1, opacity: 1.0), definition: .rgb(r: -0.2, g: 1.3, b: 0.1, space: .sRGBLinear)) // Note: Linear space example
    ]

    /// Colors defined using Hue, Saturation, and Brightness components (HSB/HSV).
    /// Often intuitive for picking colors visually.
    static let hsb: [ColorInfo] = [
        .init(name: "Sunshine Yellow", color: Color(hue: 0.15, saturation: 0.9, brightness: 1.0), definition: .hsb(h: 0.15, s: 0.9, b: 1.0)),
        .init(name: "Sky Blue", color: Color(hue: 0.6, saturation: 0.7, brightness: 0.9), definition: .hsb(h: 0.6, s: 0.7, b: 0.9)),
        .init(name: "Forest Green", color: Color(hue: 0.35, saturation: 0.8, brightness: 0.6), definition: .hsb(h: 0.35, s: 0.8, b: 0.6)),
        .init(name: "Fiery Orange", color: Color(hue: 0.08, saturation: 1.0, brightness: 1.0), definition: .hsb(h: 0.08, s: 1.0, b: 1.0)),
        .init(name: "Royal Purple", color: Color(hue: 0.75, saturation: 0.8, brightness: 0.7), definition: .hsb(h: 0.75, s: 0.8, b: 0.7))
    ]

    /// Grayscale colors defined using a single white component (0.0 = black, 1.0 = white).
    static let grayscale: [ColorInfo] = [
        .init(name: "Near Black", color: Color(white: 0.1), definition: .white(w: 0.1)),
        .init(name: "Dark Gray", color: Color(white: 0.33), definition: .white(w: 0.33)),
        .init(name: "Medium Gray", color: Color(white: 0.5), definition: .white(w: 0.5)),
        .init(name: "Light Gray", color: Color(white: 0.75), definition: .white(w: 0.75)),
        .init(name: "Near White", color: Color(white: 0.95), definition: .white(w: 0.95))
    ]

    /// Examples of standard named SwiftUI colors.
    /// Note: These are constant sRGB values, unlike semantic colors like `.primary`.
    /// We use the `.standard` definition type here.
    static let standardColors: [ColorInfo] = [
        // Defining using the standard Color constants
        .init(name: "Standard Red", color: .red, definition: .standard(name: ".red")),
        .init(name: "Standard Green", color: .green, definition: .standard(name: ".green")),
        .init(name: "Standard Blue", color: .blue, definition: .standard(name: ".blue")),
        .init(name: "Standard Orange", color: .orange, definition: .standard(name: ".orange")),
        .init(name: "Standard Yellow", color: .yellow, definition: .standard(name: ".yellow")),
        .init(name: "Standard Pink", color: .pink, definition: .standard(name: ".pink")),
        .init(name: "Standard Purple", color: .purple, definition: .standard(name: ".purple")),
        .init(name: "Standard Teal", color: .teal, definition: .standard(name: ".teal")),
        .init(name: "Standard Indigo", color: .indigo, definition: .standard(name: ".indigo")),
        // You could also define them via RGB if preferred, but .standard shows the origin
        // .init(name: "Standard Red (RGB)", color: Color(.sRGB, red: 1.0, green: 0.23, blue: 0.19), definition: .rgb(r: 1.0, g: 0.23, b: 0.19)), // Example if defined via RGB
    ]

    /// System *semantic* colors adapt to Light/Dark Mode, accessibility settings, etc.
    /// They are generally used directly (`Color.primary`, `Color.accentColor`) rather than
    /// stored as constant ColorInfo, as their actual value changes.
    /// This array is for *demonstration* of their names, not for defining them as constants.
    static let semanticColorExamples: [String] = [
        ".primary", ".secondary", ".accentColor", ".link",
        ".label", ".secondaryLabel", ".tertiaryLabel", ".quaternaryLabel", // Text colors
        ".systemBackground", ".secondarySystemBackground", ".tertiarySystemBackground", // Backgrounds
        ".systemGroupedBackground", ".secondarySystemGroupedBackground", ".tertiarySystemGroupedBackground", // Grouped Backgrounds
        ".systemFill", ".secondarySystemFill", ".tertiarySystemFill", ".quaternarySystemFill", // Fills
        // Semantic tints like .systemRed, .systemBlue are also available
    ]
}

// MARK: - Helper Functions (Optional)

/// Helper function to copy text to the system clipboard.
func copyToClipboard(_ text: String) {
    UIPasteboard.general.string = text
    // Consider adding user feedback (e.g., HUD, haptic) in a real app
    print("Copied to clipboard: \(text)")
}

import SwiftUI
// No UIKit import needed here anymore if copyToClipboard is in ColorDefinitions.swift

// --- UI Components (Keep InteractivePaletteSection, ThemePreviewView, ColorDetailView as they were) ---
// (Paste the definitions for InteractivePaletteSection, ThemePreviewView, and ColorDetailView here
//  from the previous response, they don't need changes conceptually, but ColorDetailView
//  should now call the global copyToClipboard function if you defined it globally)

// Updated ColorDetailView to use global copy function (or keep it private inside)
struct ColorDetailView: View {
    let colorInfo: ColorInfo?

    var body: some View {
        VStack(alignment: .leading) {
            Text("Color Details")
                .font(.title2)
                .padding(.bottom, 5)

            if let info = colorInfo {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Rectangle()
                            .fill(info.color)
                            .frame(width: 30, height: 30)
                            .cornerRadius(4)
                            .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.gray.opacity(0.5)))
                        Text(info.name).font(.headline)
                    }

                    Text("Definition: \(info.definitionString)")
                    HStack {
                        Text("Hex: \(info.hexString)")
                        Button {
                           copyToClipboard(info.hexString) // Using the function from ColorDefinitions.swift
                        } label: {
                            Image(systemName: "doc.on.doc")
                        }
                        .buttonStyle(.borderless)
                        .help("Copy Hex Value")
                    }
                }
                .font(.subheadline)
                .padding()
                .background(Color(UIColor.secondarySystemBackground)) // Adapting detail background
                .cornerRadius(10)
            } else {
                Text("No color selected.")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            }
        }
    }
}

// --- Main View Combining Palettes and Previews ---

struct ColorPaletteShowcaseView: View {
    // Initialize with the first color from any palette, e.g., Standard Colors
    @State private var selectedColorInfo: ColorInfo? = Palettes.standardColors.first

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 30) {

                // --- Color Selection Sections ---
                InteractivePaletteSection(title: "Standard SwiftUI Colors", colors: Palettes.standardColors, selectedColorInfo: $selectedColorInfo)
                InteractivePaletteSection(title: "Display P3 Palette", colors: Palettes.displayP3, selectedColorInfo: $selectedColorInfo)
                InteractivePaletteSection(title: "Extended Range Palette", colors: Palettes.extendedRange, selectedColorInfo: $selectedColorInfo)
                InteractivePaletteSection(title: "HSB Palette", colors: Palettes.hsb, selectedColorInfo: $selectedColorInfo)
                InteractivePaletteSection(title: "Grayscale Palette", colors: Palettes.grayscale, selectedColorInfo: $selectedColorInfo)

                Divider()

                // --- Details & Preview ---
                ColorDetailView(colorInfo: selectedColorInfo)
                ThemePreviewView(selectedColorInfo: $selectedColorInfo)

                Divider()

                // --- Explanation Footer ---
                 VStack(alignment: .leading, spacing: 10) { // Added spacing
                     Text("Notes:")
                         .font(.headline)
                     Text("• These palettes showcase 'constant' colors defined programmatically. They do not automatically adapt to Light/Dark mode like *semantic* system colors (e.g., `.primary`, `.secondaryLabel`, `.systemBackground`) or colors defined in Asset Catalogs.")
                     Text("• Display P3 and Extended Range colors require compatible hardware for full effect and may appear clamped on standard displays.")
                     Text("• Semantic colors (like those listed below) *should* be used directly (e.g., `Text(\"Hi\").foregroundColor(.primary)`) for adaptive UI.")
                         .font(.callout).italic() // Italics for emphasis
                    Text("Examples of Adapting Semantic Colors: \(Palettes.semanticColorExamples.joined(separator: ", "))")
                        .font(.caption)

                 }
                 .padding(.top)
                 .foregroundColor(.secondary) // Use adaptive secondary text color
            }
            .padding() // Overall padding for the VStack content
        }
        .navigationTitle("SwiftUI Color Palettes")
        .background(Color(UIColor.systemGroupedBackground)) // Use grouped background
    }
}

// --- App Structure & Preview ---

@main // Make sure @main is on your App struct
struct ColorPalettesApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ColorPaletteShowcaseView()
            }
        }
    }
}

// --- Previews (Keep these in your View file) ---

#Preview("Light Mode") {
    NavigationView {
         ColorPaletteShowcaseView()
    }
    .environment(\.colorScheme, .light)
}

#Preview("Dark Mode") {
    NavigationView {
         ColorPaletteShowcaseView()
    }
    .environment(\.colorScheme, .dark)
}

#Preview("Selected Indigo (Light)") {
    NavigationView {
        // Find Indigo in the standard colors for preview initialization
//        let indigoInfo = Palettes.standardColors.first { $0.name == "Standard Indigo" }
        ColorPaletteShowcaseView()
            .environment(\.colorScheme, .light)
    }
}
