////
////  ColorPaletteShowcaseView.swift
////  MyApp
////
////  Created by Cong Le on 4/18/25.
////
//
//import SwiftUI
//
//// --- Color Palettes Leveraging Unique Apple Color System Features ---
//
///// Palette using the Display P3 color space for potentially more vibrant colors
///// on compatible wide-gamut displays. These are constant colors.
//struct DisplayP3Palette {
//    /// A vibrant red, potentially outside the standard sRGB gamut.
//    static let vibrantRed: Color = Color(.displayP3, red: 1.0, green: 0.1, blue: 0.1, opacity: 1.0)
//
//    /// A lush green, potentially more saturated than standard sRGB greens.
//    static let lushGreen: Color = Color(.displayP3, red: 0.1, green: 0.9, blue: 0.2, opacity: 1.0)
//
//    /// A deep P3 blue.
//    static let deepBlue: Color = Color(.displayP3, red: 0.1, green: 0.2, blue: 0.95, opacity: 1.0)
//
//    /// A bright P3 magenta.
//    static let brightMagenta: Color = Color(.displayP3, red: 0.95, green: 0.1, blue: 0.8, opacity: 1.0)
//}
//
///// Palette demonstrating the use of extended range values (outside 0.0-1.0).
///// The visual effect heavily depends on the display's capabilities and how
///// the system renders these values. These are constant colors.
//struct ExtendedRangePalette {
//    /// An 'ultra' white using a value greater than 1.0 (effect varies by display/context).
//    /// On HDR displays, this might appear brighter than standard white.
//    static let ultraWhite: Color = Color(.sRGB, white: 1.1, opacity: 1.0) // Note: Value > 1.0
//
//    /// A potentially more intense red by exceeding the 1.0 limit for the red component.
//    static let intenseRed: Color = Color(.sRGB, red: 1.2, green: 0, blue: 0, opacity: 1.0) // Note: Value > 1.0
//
//    /// A potentially darker-than-black using a negative value (effect varies).
//    /// This might just clamp to black (0.0) on standard displays.
//    static let deeperThanBlack: Color = Color(.sRGB, white: -0.1, opacity: 1.0) // Note: Value < 0.0
//
//    // Note: Using extended range values requires careful testing on target devices.
//    // Extreme values might not produce intuitive results or could be clamped.
//    // Best used subtly or for specific HDR content scenarios.
//}
//
///// Standard HSB Palette for comparison and completeness (Constant Colors)
//struct HSBPalette {
//    static let sunshineYellow: Color = Color(hue: 0.15, saturation: 0.9, brightness: 1.0) // 54 degrees
//    static let skyBlue: Color = Color(hue: 0.6, saturation: 0.7, brightness: 0.9)       // 216 degrees
//    static let forestGreen: Color = Color(hue: 0.35, saturation: 0.8, brightness: 0.6)   // 126 degrees
//    static let fieryOrange: Color = Color(hue: 0.08, saturation: 1.0, brightness: 1.0)   // 29 degrees
//}
//
///// Standard Grayscale Palette (Constant Colors)
//struct GrayscalePalette {
//    static let lightGray: Color = Color(white: 0.8)
//    static let mediumGray: Color = Color(white: 0.5)
//    static let darkGray: Color = Color(white: 0.2)
//}
//
//// --- Example Usage View ---
//
//struct ColorPaletteShowcaseView: View {
//    var body: some View {
//        ScrollView {
//            VStack(alignment: .leading, spacing: 20) {
//
//                PaletteSection(title: "Display P3 Palette", colors: [
//                    ("Vibrant Red", DisplayP3Palette.vibrantRed),
//                    ("Lush Green", DisplayP3Palette.lushGreen),
//                    ("Deep Blue", DisplayP3Palette.deepBlue),
//                    ("Bright Magenta", DisplayP3Palette.brightMagenta)
//                ])
//
//                PaletteSection(title: "Extended Range Palette", colors: [
//                    ("Ultra White (>1.0)", ExtendedRangePalette.ultraWhite),
//                    ("Intense Red (>1.0)", ExtendedRangePalette.intenseRed),
//                    ("Deeper Than Black (<0.0)", ExtendedRangePalette.deeperThanBlack)
//                ])
//
//                PaletteSection(title: "HSB Palette", colors: [
//                    ("Sunshine Yellow", HSBPalette.sunshineYellow),
//                    ("Sky Blue", HSBPalette.skyBlue),
//                    ("Forest Green", HSBPalette.forestGreen),
//                    ("Fiery Orange", HSBPalette.fieryOrange)
//                ])
//
//                PaletteSection(title: "Grayscale Palette", colors: [
//                    ("Light Gray", GrayscalePalette.lightGray),
//                    ("Medium Gray", GrayscalePalette.mediumGray),
//                    ("Dark Gray", GrayscalePalette.darkGray)
//                ])
//
//                Divider()
//
//                Text("Note:")
//                    .font(.headline)
//                Text("These colors are 'constant' and won't adapt to Light/Dark mode automatically. Display P3 and Extended Range effects are most noticeable on compatible hardware (wide-gamut / HDR displays).")
//                    .font(.caption)
//                    .foregroundColor(.gray)
//
//            }
//            .padding()
//        }
//        .navigationTitle("Color Palettes") // Add a title if used in NavigationView
//    }
//}
//
//// Helper View for displaying a palette section
//struct PaletteSection: View {
//    let title: String
//    let colors: [(String, Color)]
//
//    var body: some View {
//        VStack(alignment: .leading) {
//            Text(title)
//                .font(.title2)
//                .padding(.bottom, 5)
//            HStack(spacing: 10) {
//                ForEach(colors, id: \.0) { name, color in
//                    VStack {
//                        Rectangle()
//                            .fill(color)
//                            .frame(width: 60, height: 60)
//                            .cornerRadius(8)
//                            .overlay(
//                                RoundedRectangle(cornerRadius: 8)
//                                    .stroke(Color.gray, lineWidth: 0.5) // Add thin border
//                            )
//                        Text(name)
//                            .font(.caption)
//                            .frame(width: 70) // Allow text wrapping
//                            .multilineTextAlignment(.center)
//                    }
//                }
//                Spacer() // Push colors to the left
//            }
//        }
//    }
//}
//
//// --- App Structure (for preview and running) ---
//
//struct ColorPalettesApp: App {
//    var body: some Scene {
//        WindowGroup {
//            NavigationView { // Optional: Wrap in NavigationView for title
//                ColorPaletteShowcaseView()
//            }
//        }
//    }
//}
//
//// --- Preview Provider ---
//
//#Preview {
//    NavigationView { // Match the App structure for consistent preview
//         ColorPaletteShowcaseView()
//    }
//}
