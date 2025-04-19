//
//  ColorPalettesApp_V2.swift
//  MyApp
//
//  Created by Cong Le on 4/18/25.
//

import SwiftUI
import UIKit // Needed for UIPasteboard and UIColor conversion for hex

// --- Data Structure for Color Information ---

//struct ColorInfo: Identifiable, Equatable {
//    let id = UUID()
//    let name: String
//    let color: Color
//
//    // Store original definition for display/copy functionality
//    enum Definition {
//        case rgb(r: Double, g: Double, b: Double, space: Color.RGBColorSpace = .sRGB)
//        case hsb(h: Double, s: Double, b: Double)
//        case white(w: Double)
//    }
//    let definition: Definition
//    let opacity: Double = 1.0 // Assuming full opacity for simplicity here
//
//    // Helper to get a display string for the definition
//    var definitionString: String {
//        switch definition {
//        case .rgb(let r, let g, let b, let space):
//            let spaceStr = (space == .displayP3) ? "P3" : "sRGB"
//            return String(format: "RGB(%@ %.2f, %.2f, %.2f)", spaceStr, r, g, b)
//        case .hsb(let h, let s, let b):
//            return String(format: "HSB(%.2f, %.2f, %.2f)", h, s, b)
//        case .white(let w):
//            return String(format: "White(%.2f)", w)
//        }
//    }
//
//    // Helper to get approximate Hex string (Requires UIColor conversion)
//    var hexString: String {
//        // Attempt conversion to UIColor to get reliable RGB components
//        // Note: This might not be perfect for ALL Color types but works well for
//        // colors defined with RGB/HSB/White initializers.
//        let uiColor = UIColor(color)
//        var red: CGFloat = 0
//        var green: CGFloat = 0
//        var blue: CGFloat = 0
//        var alpha: CGFloat = 0
//
//        // getRed(_:green:blue:alpha:) returns components in the sRGB color space
//        // regardless of the original UIColor's space, which is suitable for hex.
//        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
//
//        // Handle extended range values by clamping them for standard hex representation
//        let clampedRed = min(max(0, red), 1)
//        let clampedGreen = min(max(0, green), 1)
//        let clampedBlue = min(max(0, blue), 1)
//
//        return String(format: "#%02X%02X%02X",
//                      Int(clampedRed * 255),
//                      Int(clampedGreen * 255),
//                      Int(clampedBlue * 255))
//    }
//
//    static func == (lhs: ColorInfo, rhs: ColorInfo) -> Bool {
//        lhs.id == rhs.id // Simple equality check based on ID
//    }
//}
//
//// --- Updated Palette Definitions ---
//
//struct Palettes {
//    static let displayP3: [ColorInfo] = [
//        .init(name: "P3 Vibrant Red", color: Color(.displayP3, red: 1.0, green: 0.1, blue: 0.1), definition: .rgb(r: 1.0, g: 0.1, b: 0.1, space: .displayP3)),
//        .init(name: "P3 Lush Green", color: Color(.displayP3, red: 0.1, green: 0.9, blue: 0.2), definition: .rgb(r: 0.1, g: 0.9, b: 0.2, space: .displayP3)),
//        .init(name: "P3 Deep Blue", color: Color(.displayP3, red: 0.1, green: 0.2, blue: 0.95), definition: .rgb(r: 0.1, g: 0.2, b: 0.95, space: .displayP3)),
//        .init(name: "P3 Bright Magenta", color: Color(.displayP3, red: 0.95, green: 0.1, blue: 0.8), definition: .rgb(r: 0.95, g: 0.1, b: 0.8, space: .displayP3))
//    ]
//
//    static let extendedRange: [ColorInfo] = [
//        .init(name: "Ultra White (>1)", color: Color(.sRGB, white: 1.1), definition: .white(w: 1.1)),
//        .init(name: "Intense Red (>1)", color: Color(.sRGB, red: 1.2, green: 0, blue: 0), definition: .rgb(r: 1.2, g: 0, b: 0)),
//        .init(name: "Deeper Black (<0)", color: Color(.sRGB, white: -0.1), definition: .white(w: -0.1))
//    ]
//
//    static let hsb: [ColorInfo] = [
//        .init(name: "Sunshine Yellow", color: Color(hue: 0.15, saturation: 0.9, brightness: 1.0), definition: .hsb(h: 0.15, s: 0.9, b: 1.0)),
//        .init(name: "Sky Blue", color: Color(hue: 0.6, saturation: 0.7, brightness: 0.9), definition: .hsb(h: 0.6, s: 0.7, b: 0.9)),
//        .init(name: "Forest Green", color: Color(hue: 0.35, saturation: 0.8, brightness: 0.6), definition: .hsb(h: 0.35, s: 0.8, b: 0.6)),
//        .init(name: "Fiery Orange", color: Color(hue: 0.08, saturation: 1.0, brightness: 1.0), definition: .hsb(h: 0.08, s: 1.0, b: 1.0))
//    ]
//
//    static let grayscale: [ColorInfo] = [
//        .init(name: "Light Gray", color: Color(white: 0.8), definition: .white(w: 0.8)),
//        .init(name: "Medium Gray", color: Color(white: 0.5), definition: .white(w: 0.5)),
//        .init(name: "Dark Gray", color: Color(white: 0.2), definition: .white(w: 0.2))
//    ]
//}
//
// --- Interactive UI Components ---

// Updated Palette Section with tap interaction
struct InteractivePaletteSection: View {
    let title: String
    let colors: [ColorInfo]
    @Binding var selectedColorInfo: ColorInfo? // Bind to the parent view's state

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.title2)
                .padding(.bottom, 5)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(colors) { info in
                        Button {
                            selectedColorInfo = info // Update the selection
                        } label: {
                            VStack {
                                Rectangle()
                                    .fill(info.color)
                                    .frame(width: 60, height: 60)
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(selectedColorInfo == info ? Color.blue : Color.gray.opacity(0.5), lineWidth: selectedColorInfo == info ? 3 : 1) // Highlight selected
                                    )
                                Text(info.name)
                                    .font(.caption)
                                    .foregroundColor(.primary) // Use adaptive text color
                                    .frame(width: 70, height: 35) // Fixed height for alignment
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .buttonStyle(.plain) // Use plain style to avoid default button appearance
                    }
                }
                .padding(.horizontal, 5) // Padding inside scroll view
            }
        }
    }
}

// View to show applied theme using selected color
struct ThemePreviewView: View {
    @Binding var selectedColorInfo: ColorInfo?
    @State private var progress: Double = 0.75 // Mock progress

    // Define adaptive colors for contrast demonstration
    let adaptiveTextColor = Color.primary
    let adaptiveBackgroundColor = Color(UIColor.systemBackground) // Adapts to Light/Dark Mode
    let adaptiveSecondaryBackgroundColor = Color(UIColor.secondarySystemBackground)

    var body: some View {
        VStack(alignment: .leading) {
            Text("Theme Preview")
                .font(.title2)
                .padding(.bottom, 5)

            if let info = selectedColorInfo {
                VStack(alignment: .leading, spacing: 15) {
                    // 1. Text Examples
                    Text("Primary text on adaptive background")
                        .foregroundColor(adaptiveTextColor)
                    Text("Selected color text on adaptive background")
                        .foregroundColor(info.color)
                    Text("Adaptive text on selected color background")
                        .foregroundColor(adaptiveTextColor)
                        .padding(5)
                        .background(info.color)
                        .cornerRadius(4)

                    Divider()

                    // 2. Button Examples
                    HStack {
                        Button("Tinted Button") { }
                            .buttonStyle(.borderedProminent)
                            .tint(info.color) // Use selected color as tint

                        Button("Tinted Bordered") { }
                            .buttonStyle(.bordered)
                            .tint(info.color)
                    }

                    Divider()

                    // 3. Icon and Progress
                    HStack(spacing: 20) {
                        Image(systemName: "swift")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .foregroundColor(info.color) // Icon colored with selection

                        VStack(alignment: .leading) {
                            Text("Progress Bar")
                            ProgressView(value: progress)
                                .progressViewStyle(LinearProgressViewStyle(tint: info.color))
                            Slider(value: $progress, in: 0...1) // Control the mock progress
                                .tint(info.color)
                        }
                    }

                    Divider()

                    // 4. Background Contrast Example
                    Text("Selected color on Adapting Background")
                        .font(.caption)
                        .padding(8)
                        .background(adaptiveSecondaryBackgroundColor) // Use adaptive secondary bg
                        .foregroundColor(info.color) // Selected color text
                        .cornerRadius(5)

                }
                .padding()
                .background(adaptiveBackgroundColor) // Main adaptive background
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )

            } else {
                Text("Tap a color swatch above to see a theme preview.")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            }
        }
    }
}

//// View to show color details and copy button
//struct ColorDetailView: View {
//    let colorInfo: ColorInfo? // Now takes optional ColorInfo
//
//    var body: some View {
//        VStack(alignment: .leading) {
//            Text("Color Details")
//                .font(.title2)
//                .padding(.bottom, 5)
//
//            if let info = colorInfo {
//                VStack(alignment: .leading, spacing: 8) {
//                    HStack {
//                        Rectangle()
//                            .fill(info.color)
//                            .frame(width: 30, height: 30)
//                            .cornerRadius(4)
//                            .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.gray.opacity(0.5)))
//                        Text(info.name).font(.headline)
//                    }
//
//                    Text("Definition: \(info.definitionString)")
//                    HStack {
//                        Text("Hex: \(info.hexString)")
//                        Button {
//                            copyToClipboard(info.hexString)
//                        } label: {
//                            Image(systemName: "doc.on.doc")
//                        }
//                        .buttonStyle(.borderless) // More subtle button style
//                        .help("Copy Hex Value") // Tooltip for macOS/iPadOS
//                    }
//                }
//                .font(.subheadline)
//                .padding()
//                .background(Color(UIColor.secondarySystemBackground)) // Adapting detail background
//                .cornerRadius(10)
//            } else {
//                Text("No color selected.")
//                    .foregroundColor(.secondary)
//                    .frame(maxWidth: .infinity, alignment: .center)
//                    .padding()
//            }
//        }
//    }
//
//    // Helper function to copy text
//    private func copyToClipboard(_ text: String) {
//        UIPasteboard.general.string = text
//        // Optional: Add user feedback like a temporary banner or haptic feedback
//        print("\(text) copied to clipboard")
//    }
//}
//
//// --- Main View Combining Palettes and Previews ---
//
//struct ColorPaletteShowcaseView: View {
//    @State private var selectedColorInfo: ColorInfo? = Palettes.displayP3.first // Default selection
//
//    var body: some View {
//        ScrollView {
//            VStack(alignment: .leading, spacing: 30) { // Increased spacing
//
//                // Color Selection Area
//                InteractivePaletteSection(title: "Display P3 Palette", colors: Palettes.displayP3, selectedColorInfo: $selectedColorInfo)
//                InteractivePaletteSection(title: "Extended Range Palette", colors: Palettes.extendedRange, selectedColorInfo: $selectedColorInfo)
//                InteractivePaletteSection(title: "HSB Palette", colors: Palettes.hsb, selectedColorInfo: $selectedColorInfo)
//                InteractivePaletteSection(title: "Grayscale Palette", colors: Palettes.grayscale, selectedColorInfo: $selectedColorInfo)
//
//                Divider()
//
//                // Details of Selected Color
//                ColorDetailView(colorInfo: selectedColorInfo)
//
//                Divider()
//
//                // Theme Preview of Selected Color
//                ThemePreviewView(selectedColorInfo: $selectedColorInfo)
//
//                // Explanation Footer
//                VStack(alignment: .leading) {
//                    Text("Note:")
//                        .font(.headline)
//                    Text("These palettes showcase 'constant' colors defined programmatically. They do not automatically adapt to Light/Dark mode like system semantic colors or colors defined in Asset Catalogs. Display P3 and Extended Range effects depend on display hardware.")
//                        .font(.caption)
//                        .foregroundColor(.secondary) // Use adaptive secondary text color
//                }
//                .padding(.top)
//
//            }
//            .padding() // Overall padding for the VStack content
//        }
//        .navigationTitle("Functional Color Palettes")
//        .background(Color(UIColor.systemGroupedBackground)) // Use grouped background for overall view
//    }
//}
//
//// --- App Structure & Preview ---
//
//struct ColorPalettesApp: App {
//    var body: some Scene {
//        WindowGroup {
//            NavigationView {
//                ColorPaletteShowcaseView()
//            }
//            // Add .environment(\.colorScheme, .dark) here to test Dark Mode
//        }
//    }
//}
//
//#Preview("Light Mode") {
//    NavigationView {
//         ColorPaletteShowcaseView()
//    }
//    .environment(\.colorScheme, .light)
//}
//
//#Preview("Dark Mode") {
//    NavigationView {
//         ColorPaletteShowcaseView()
//    }
//    .environment(\.colorScheme, .dark)
//}
//
//#Preview("Selected P3 Color (Dark)") {
//    NavigationView {
//        // Directly set state for preview
//        //ColorPaletteShowcaseView(selectedColorInfo: Palettes.displayP3[2])
//        ColorPaletteShowcaseView()
//            .environment(\.colorScheme, .dark)
//    }
//}
