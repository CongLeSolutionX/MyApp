////
////  ColorPaletteMasterView.swift
////  MyApp
////
////  Created by Cong Le on 4/18/25.
////
//
//import SwiftUI
//import UIKit
//
//// MARK: - Color Model To Support Metadata
//
//struct PaletteColor: Identifiable {
//    let id = UUID()
//    let name: String
//    let color: Color
//    let description: String
//    let colorSpace: String
//    let componentsDescription: String
//    let isExtendedRange: Bool
//}
//
//// Helpers for extracting hex and RGB components
//
//extension UIColor {
//    // Get RGBA components as tuple (values 0...1)
//    func rgbaComponents() -> (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat)? {
//        var r: CGFloat=0, g: CGFloat=0, b: CGFloat=0, a: CGFloat=0
//        guard self.getRed(&r, green: &g, blue: &b, alpha: &a) else { return nil }
//        return (r,g,b,a)
//    }
//
//    // Convert UIColor to hex string
//    func toHexString(includeAlpha: Bool = false) -> String? {
//        guard let components = rgbaComponents() else { return nil }
//        let r = Int(components.r * 255)
//        let g = Int(components.g * 255)
//        let b = Int(components.b * 255)
//        if includeAlpha {
//            let a = Int(components.a * 255)
//            return String(format: "#%02X%02X%02X%02X", r,g,b,a)
//        } else {
//            return String(format: "#%02X%02X%02X", r,g,b)
//        }
//    }
//}
//
//extension Color {
//    // Convert SwiftUI Color to UIColor
//    func toUIColor() -> UIColor {
//        let scanner = Mirror(reflecting: self).children
//        // This is a bit hacky due to SwiftUI internals changing; fallback:
//        // safest way: use UIColor(self)
//        return UIColor(self)
//    }
//
//    // Hex string of the color
//    func hexString(includeAlpha: Bool = false) -> String? {
//        return toUIColor().toHexString(includeAlpha: includeAlpha)
//    }
//
//    // RGB components 0-255
//    func rgbComponentsInt() -> (r: Int, g: Int, b: Int, a: Int)? {
//        guard let components = toUIColor().rgbaComponents() else { return nil }
//        return (Int(components.r * 255), Int(components.g * 255), Int(components.b * 255), Int(components.a * 255))
//    }
//}
//
//// MARK: - Expanded Palettes with metadata
//
//struct Palettes {
//
//    // Display P3 Colors (constant colors, known color space, simple example here)
//    static let displayP3Palette: [PaletteColor] = [
//        PaletteColor(
//            name: "Vibrant Red",
//            color: Color(.displayP3, red: 1.0, green: 0.1, blue: 0.1),
//            description: "A vibrant red using Display P3 color space. Great for branding or warning colors on wide-gamut displays.",
//            colorSpace: "Display P3",
//            componentsDescription: "R=1.00, G=0.10, B=0.10",
//            isExtendedRange: false
//        ),
//        PaletteColor(
//            name: "Lush Green",
//            color: Color(.displayP3, red: 0.1, green: 0.9, blue: 0.2),
//            description: "Lush green vibrant color with Display P3 support.",
//            colorSpace: "Display P3",
//            componentsDescription: "R=0.10, G=0.90, B=0.20",
//            isExtendedRange: false
//        ),
//        PaletteColor(
//            name: "Deep Blue",
//            color: Color(.displayP3, red: 0.1, green: 0.2, blue: 0.95),
//            description: "Deep blue color using Display P3 wide color gamut.",
//            colorSpace: "Display P3",
//            componentsDescription: "R=0.10, G=0.20, B=0.95",
//            isExtendedRange: false
//        ),
//        PaletteColor(
//            name: "Bright Magenta",
//            color: Color(.displayP3, red: 0.95, green: 0.10, blue: 0.80),
//            description: "Bright magenta with potential enhanced vibrancy on compatible screens.",
//            colorSpace: "Display P3",
//            componentsDescription: "R=0.95, G=0.10, B=0.80",
//            isExtendedRange: false
//        )
//    ]
//
//    // Extended Range Palette - constants with values outside traditional 0-1 range
//    static let extendedRangePalette: [PaletteColor] = [
//        PaletteColor(
//            name: "Ultra White (>1.0)",
//            color: Color(.sRGB, white: 1.1),
//            description: "White value exceeds 1.0 using sRGB extended range. May appear brighter or clipped depending on display.",
//            colorSpace: "sRGB Extended Range",
//            componentsDescription: "White = 1.10",
//            isExtendedRange: true
//        ),
//        PaletteColor(
//            name: "Intense Red (>1.0)",
//            color: Color(.sRGB, red: 1.2, green: 0, blue: 0),
//            description: "Red component above 1.0 for possibly more vivid color on capable devices.",
//            colorSpace: "sRGB Extended Range",
//            componentsDescription: "R=1.20, G=0.00, B=0.00",
//            isExtendedRange: true
//        ),
//        PaletteColor(
//            name: "Deeper Than Black (<0.0)",
//            color: Color(.sRGB, white: -0.1),
//            description: "Negative white value; may clamp to black or behave unexpectedly on standard displays.",
//            colorSpace: "sRGB Extended Range",
//            componentsDescription: "White = -0.10",
//            isExtendedRange: true
//        )
//    ]
//
//    // HSB Palette - simpler but useful
//    static let hsbPalette: [PaletteColor] = [
//        PaletteColor(
//            name: "Sunshine Yellow",
//            color: Color(hue: 0.15, saturation: 0.9, brightness: 1.0),
//            description: "Bright yellow based on HSB color model, pleasing for highlights or accents.",
//            colorSpace: "HSB (No explicit space)",
//            componentsDescription: "Hue=0.15, Sat=0.90, Bri=1.00",
//            isExtendedRange: false
//        ),
//        PaletteColor(
//            name: "Sky Blue",
//            color: Color(hue: 0.6, saturation: 0.7, brightness: 0.9),
//            description: "Soft sky blue great for backgrounds or calm UI elements.",
//            colorSpace: "HSB (No explicit space)",
//            componentsDescription: "Hue=0.60, Sat=0.70, Bri=0.90",
//            isExtendedRange: false
//        ),
//        PaletteColor(
//            name: "Forest Green",
//            color: Color(hue: 0.35, saturation: 0.8, brightness: 0.6),
//            description: "Earthy forest green, ideal for natural-themed UI elements.",
//            colorSpace: "HSB (No explicit space)",
//            componentsDescription: "Hue=0.35, Sat=0.80, Bri=0.60",
//            isExtendedRange: false
//        ),
//        PaletteColor(
//            name: "Fiery Orange",
//            color: Color(hue: 0.08, saturation: 1.0, brightness: 1.0),
//            description: "Bright orange suitable for urgent buttons or warnings.",
//            colorSpace: "HSB (No explicit space)",
//            componentsDescription: "Hue=0.08, Sat=1.00, Bri=1.00",
//            isExtendedRange: false
//        )
//    ]
//
//    // Grayscale Palette - useful for simple accents and backgrounds
//    static let grayscalePalette: [PaletteColor] = [
//        PaletteColor(
//            name: "Light Gray",
//            color: Color(white: 0.8),
//            description: "Light gray useful for backgrounds and borders.",
//            colorSpace: "Grayscale (sRGB)",
//            componentsDescription: "White = 0.80",
//            isExtendedRange: false
//        ),
//        PaletteColor(
//            name: "Medium Gray",
//            color: Color(white: 0.5),
//            description: "Neutral gray great for secondary elements.",
//            colorSpace: "Grayscale (sRGB)",
//            componentsDescription: "White = 0.50",
//            isExtendedRange: false
//        ),
//        PaletteColor(
//            name: "Dark Gray",
//            color: Color(white: 0.2),
//            description: "Dark gray suitable for text or contrast elements.",
//            colorSpace: "Grayscale (sRGB)",
//            componentsDescription: "White = 0.20",
//            isExtendedRange: false
//        )
//    ]
//
//    // Return all palettes grouped for iteration
//    static let allPalettes: [(title: String, colors: [PaletteColor])] = [
//        ("Display P3 Palette", displayP3Palette),
//        ("Extended Range Palette", extendedRangePalette),
//        ("HSB Palette", hsbPalette),
//        ("Grayscale Palette", grayscalePalette)
//    ]
//}
//
//// MARK: - Main View with Selecting & Detail Preview
//
//struct ColorPaletteMasterView: View {
//    // Current selected color
//    @State private var selectedColor: PaletteColor?
//    // Toggle for dark/light mode simulation
//    @State private var useDarkMode: Bool = false
//
//    var body: some View {
//        NavigationView {
//            VStack {
//                // Toggle Light/Dark Mode simulation
//                Toggle("Dark Mode", isOn: $useDarkMode)
//                    .padding(.horizontal)
//
//                List {
//                    ForEach(Palettes.allPalettes, id: \.title) { paletteGroup in
//                        Section(header: Text(paletteGroup.title).font(.headline)) {
//                            ScrollView(.horizontal, showsIndicators: false) {
//                                HStack(spacing: 15) {
//                                    ForEach(paletteGroup.colors) { paletteColor in
//                                        ColorSwatchView(paletteColor: paletteColor)
//                                            .onTapGesture {
//                                                withAnimation {
//                                                    selectedColor = paletteColor
//                                                }
//                                            }
//                                            .overlay(
//                                                RoundedRectangle(cornerRadius: 10)
//                                                    .stroke(selectedColor?.id == paletteColor.id ? Color.accentColor : .clear, lineWidth: 3)
//                                            )
//                                    }
//                                }
//                                .padding(.horizontal, 10)
//                                .padding(.vertical, 5)
//                            }
//                        }
//                    }
//                }
//                .listStyle(.insetGrouped)
//                .navigationTitle("Color Palettes")
//                .environment(\.colorScheme, useDarkMode ? .dark : .light)
//
//                Divider()
//
//                // Detail and Usage preview for selected color
//                if let selected = selectedColor {
//                    ColorDetailView(selectedColor: selected)
//                        .frame(maxHeight: 280)
//                        .padding()
//                        .background(
//                            RoundedRectangle(cornerRadius: 15)
//                                .fill(Color(UIColor.secondarySystemBackground))
//                                .shadow(radius: 5)
//                        )
//                        .padding()
//                        .transition(.move(edge: .bottom).combined(with: .opacity))
//                } else {
//                    Text("Tap a color swatch above to see details and usage.")
//                        .font(.callout).foregroundColor(.secondary)
//                        .padding()
//                }
//            }
//        }
//    }
//}
//
//// MARK: - Individual Color Swatch View
//
//struct ColorSwatchView: View {
//    let paletteColor: PaletteColor
//
//    var body: some View {
//        VStack(spacing: 5) {
//            Rectangle()
//                .fill(paletteColor.color)
//                .frame(width: 60, height: 60)
//                .cornerRadius(10)
//                .shadow(radius: 2)
//                .accessibilityLabel("\(paletteColor.name) color swatch")
//            Text(paletteColor.name)
//                .font(.footnote)
//                .lineLimit(2)
//                .multilineTextAlignment(.center)
//                .frame(width: 70)
//        }
//        .padding(5)
//    }
//}
//
//// MARK: - Color Detail View with Usage Preview & Copy Buttons
//
//struct ColorDetailView: View {
//    let selectedColor: PaletteColor
//    @State private var isCopiedMessageVisible = false
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 12) {
//            Text(selectedColor.name)
//                .font(.title2)
//                .bold()
//
//            // Sample usage preview with contrast text and color background
//            ZStack {
//                RoundedRectangle(cornerRadius: 12)
//                    .fill(selectedColor.color)
//                    .frame(height: 120)
//                    .shadow(radius: 4)
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 12)
//                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
//                    )
//
//                Text("Sample Text on Color")
//                    .font(.headline)
//                    .foregroundColor(contrastColor(for: selectedColor.color))
//                    .padding()
//                    .minimumScaleFactor(0.5)
//            }
//
//            // Descriptions + meta info
//            Text(selectedColor.description)
//                .font(.body)
//
//            Group {
//                Text("Color Space: \(selectedColor.colorSpace)")
//                    .font(.subheadline)
//                    .foregroundColor(.secondary)
//                Text("Components: \(selectedColor.componentsDescription)")
//                    .font(.subheadline)
//                    .foregroundColor(.secondary)
//                if selectedColor.isExtendedRange {
//                    Text("⚠️ Note: This color uses extended range values and may behave unexpectedly on some devices.")
//                        .font(.footnote)
//                        .foregroundColor(.orange)
//                }
//            }
//
//            HStack {
//                // Provide hex code and RGB values with copy functionality
//
//                if let hexCode = selectedColor.color.hexString() {
//                    CopyableTextButton(
//                        label: "Hex: \(hexCode)",
//                        copiedMessage: "Hex code copied!"
//                    ) {
//                        UIPasteboard.general.string = hexCode
//                    }
//                }
//
//                if let components = selectedColor.color.rgbComponentsInt() {
//                    let rgbString = "RGB: \(components.r), \(components.g), \(components.b)"
//                    CopyableTextButton(
//                        label: rgbString,
//                        copiedMessage: "RGB values copied!"
//                    ) {
//                        UIPasteboard.general.string = rgbString
//                    }
//                }
//            }
//        }
//        .padding()
//    }
//
//    // Determine contrasting color (black/white) for accessibility
//    func contrastColor(for color: Color) -> Color {
//        let uiColor = UIColor(color)
//        guard let components = uiColor.rgbaComponents() else {
//            return .black
//        }
//
//        // Calculate luminance (Rec. 709)
//        let luminance = 0.2126 * components.r + 0.7152 * components.g + 0.0722 * components.b
//
//        return luminance < 0.5 ? .white : .black
//    }
//}
//
//// MARK: - Copyable Text Button
//
//struct CopyableTextButton: View {
//    let label: String
//    let copiedMessage: String
//    let action: () -> Void
//
//    @State private var showCopied = false
//
//    var body: some View {
//        Button(action: {
//            action()
//            withAnimation {
//                showCopied = true
//            }
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
//                withAnimation {
//                    showCopied = false
//                }
//            }
//        }) {
//            Text(label)
//                .font(.caption)
//                .padding(8)
//                .background(Color(UIColor.systemGray5))
//                .cornerRadius(8)
//        }
//        .overlay(
//            Group {
//                if showCopied {
//                    Text(copiedMessage)
//                        .font(.caption2)
//                        .foregroundColor(.green)
//                        .padding(6)
//                        .background(Color(.systemBackground))
//                        .cornerRadius(8)
//                        .transition(.opacity)
//                        .offset(y: -40)
//                }
//            }
//        )
//    }
//}
//
//// MARK: - Preview
//
//#Preview {
//    ColorPaletteMasterView()
//}
