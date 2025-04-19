//
//  ColorTool.swift
//  MyApp
//
//  Created by Cong Le on 4/18/25.
//

import SwiftUI
import UIKit // Needed for UIColor conversion and Pasteboard

// --- Data Structure for Color Information ---

struct ColorInfo: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let color: Color
    // Store components for easy access, especially for constant colors
    let rgb: (r: Double, g: Double, b: Double)?
    let hsb: (h: Double, s: Double, b: Double)?
    let isAdaptive: Bool // Flag to know if details can be reliably shown

    // Convenience Initializers for different color types
    init(name: String, color: Color, r: Double, g: Double, b: Double) {
        self.name = name
        self.color = color
        self.rgb = (r, g, b)
        // Basic conversion for display (can be improved for precision)
        let uiColor = UIColor(red: r, green: g, blue: b, alpha: 1.0)
        var hue: CGFloat = 0, saturation: CGFloat = 0, brightness: CGFloat = 0, alpha: CGFloat = 0
        uiColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        self.hsb = (Double(hue), Double(saturation), Double(brightness))
        self.isAdaptive = false
    }

    init(name: String, color: Color, h: Double, s: Double, b: Double) {
        self.name = name
        self.color = color
        self.hsb = (h, s, b)
         // Basic conversion for display (can be improved for precision)
        let uiColor = UIColor(hue: h, saturation: s, brightness: b, alpha: 1.0)
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        self.rgb = (Double(red), Double(green), Double(blue))
        self.isAdaptive = false
    }

    init(name: String, adaptiveColor: Color) {
        self.name = name
        self.color = adaptiveColor
        self.rgb = nil // Adaptive colors change, components aren't fixed
        self.hsb = nil // Adaptive colors change, components aren't fixed
        self.isAdaptive = true
    }

    // --- Computed Properties for Display ---
    var hexString: String? {
        guard let rgb = rgb, !isAdaptive else { return nil }
        let rInt = Int(max(0, min(255, rgb.r * 255)))
        let gInt = Int(max(0, min(255, rgb.g * 255)))
        let bInt = Int(max(0, min(255, rgb.b * 255)))
        return String(format: "#%02X%02X%02X", rInt, gInt, bInt)
    }

    var rgbString: String? {
        guard let rgb = rgb, !isAdaptive else { return nil }
        let rInt = Int(max(0, min(255, rgb.r * 255)))
        let gInt = Int(max(0, min(255, rgb.g * 255)))
        let bInt = Int(max(0, min(255, rgb.b * 255)))
        return "R:\(rInt) G:\(gInt) B:\(bInt)"
    }

    var hsbString: String? {
        guard let hsb = hsb, !isAdaptive else { return nil }
         // Convert Hue to degrees
        let hDeg = Int((hsb.h * 360).rounded())
        let sPercent = Int((hsb.s * 100).rounded())
        let bPercent = Int((hsb.b * 100).rounded())
        return "H:\(hDeg)° S:\(sPercent)% B:\(bPercent)%"
    }

    // --- Hashable Conformance ---
     static func == (lhs: ColorInfo, rhs: ColorInfo) -> Bool {
         lhs.id == rhs.id
     }

     func hash(into hasher: inout Hasher) {
         hasher.combine(id)
     }
}

// --- Updated Palettes using ColorInfo ---

struct Palettes {
    static let displayP3: [ColorInfo] = [
        .init(name: "Vibrant Red", color: Color(.displayP3, red: 1.0, green: 0.1, blue: 0.1, opacity: 1.0), r: 1.0, g: 0.1, b: 0.1),
        .init(name: "Lush Green", color: Color(.displayP3, red: 0.1, green: 0.9, blue: 0.2, opacity: 1.0), r: 0.1, g: 0.9, b: 0.2),
        .init(name: "Deep Blue", color: Color(.displayP3, red: 0.1, green: 0.2, blue: 0.95, opacity: 1.0), r: 0.1, g: 0.2, b: 0.95),
        .init(name: "Bright Magenta", color: Color(.displayP3, red: 0.95, green: 0.1, blue: 0.8, opacity: 1.0), r: 0.95, g: 0.1, b: 0.8)
    ]

    static let extendedRange: [ColorInfo] = [
        // Note: Displaying exact components for extended range is less meaningful as they map differently.
        // We'll use the defined values but acknowledge the complexity. Use standard RGB init for ColorInfo.
        .init(name: "Ultra White (>1)", color: Color(.sRGB, white: 1.1, opacity: 1.0), r: 1.1, g: 1.1, b: 1.1),
        .init(name: "Intense Red (>1)", color: Color(.sRGB, red: 1.2, green: 0, blue: 0, opacity: 1.0), r: 1.2, g: 0.0, b: 0.0),
        .init(name: "Deeper Black (<0)", color: Color(.sRGB, white: -0.1, opacity: 1.0), r: -0.1, g: -0.1, b: -0.1),
    ]

    static let hsb: [ColorInfo] = [
        .init(name: "Sunshine Yellow", color: Color(hue: 0.15, saturation: 0.9, brightness: 1.0), h: 0.15, s: 0.9, b: 1.0),
        .init(name: "Sky Blue", color: Color(hue: 0.6, saturation: 0.7, brightness: 0.9), h: 0.6, s: 0.7, b: 0.9),
        .init(name: "Forest Green", color: Color(hue: 0.35, saturation: 0.8, brightness: 0.6), h: 0.35, s: 0.8, b: 0.6),
        .init(name: "Fiery Orange", color: Color(hue: 0.08, saturation: 1.0, brightness: 1.0), h: 0.08, s: 1.0, b: 1.0)
    ]

    static let grayscale: [ColorInfo] = [
        .init(name: "Light Gray", color: Color(white: 0.8), r: 0.8, g: 0.8, b: 0.8),
        .init(name: "Medium Gray", color: Color(white: 0.5), r: 0.5, g: 0.5, b: 0.5),
        .init(name: "Dark Gray", color: Color(white: 0.2), r: 0.2, g: 0.2, b: 0.2)
    ]

    static let adaptiveSystem: [ColorInfo] = [
        .init(name: "Primary", adaptiveColor: .primary),
        .init(name: "Secondary", adaptiveColor: .secondary),
        .init(name: "Accent", adaptiveColor: .accentColor), // accentColor is adaptive
        .init(name: "System Blue", adaptiveColor: .blue), // .blue is adaptive
        .init(name: "Teal", adaptiveColor: .teal)          // .teal is adaptive
    ]
}

// --- Interactive UI Components ---

struct ColorSwatch: View {
    let info: ColorInfo
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        VStack {
            Rectangle()
                .fill(info.color)
                .frame(width: 50, height: 50)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isSelected ? Color.primary.opacity(0.8) : Color.gray.opacity(0.5), lineWidth: isSelected ? 3 : 1)
                )
                .padding(isSelected ? 0 : 2) // Adjust padding slightly for selection border
                .animation(.easeInOut(duration: 0.1), value: isSelected) // Subtle animation
                .onTapGesture(perform: action)

            Text(info.name)
                .font(.caption)
                .lineLimit(2) // Allow two lines for names
                .frame(width: 60, height: 30) // Fixed height for alignment
                .multilineTextAlignment(.center)
        }
    }
}

struct ColorDetailView: View {
    let info: ColorInfo?
    @State private var showCopiedMessage: Bool = false
    @State private var copiedValueType: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Details & Preview")
                .font(.title2)

            if let info = info {
                // --- Preview Area ---
                VStack(alignment: .leading, spacing: 15) {
                     Text("Applied Preview:")
                        .font(.headline)

                    HStack {
                        Text("Sample Text")
                            .font(.title3)
                            .foregroundStyle(info.color) // Use modern foregroundStyle
                        Spacer()
                        Image(systemName: "star.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                             .foregroundStyle(info.color)
                    }

                    Button("Sample Button") { }
                        .buttonStyle(.borderedProminent)
                        .tint(info.color) // Tints the button background

                    ProgressView(value: 0.75)
                        .tint(info.color) // Tints the progress bar

                    Rectangle()
                        .fill(info.color.opacity(0.3)) // Use transparency for background example
                        .frame(height: 40)
                        .overlay(Text("Background (Opacity 0.3)").font(.caption))
                         .cornerRadius(5)

                }
                .padding(.vertical)

                 // --- Details ---
                 Text("Color Values:")
                     .font(.headline)

                if info.isAdaptive {
                     Text("Details not available for adaptive colors as their values change based on system settings (Light/Dark Mode, Accessibility).")
                        .font(.caption)
                        .foregroundColor(.gray)
                } else {
                    detailRow(label: "HEX", value: info.hexString)
                    detailRow(label: "RGB", value: info.rgbString)
                    detailRow(label: "HSB", value: info.hsbString)
                }

            } else {
                Text("Tap a color swatch above to see its details and a preview.")
                    .foregroundColor(.secondary)
                    .padding(.vertical)
            }

            // --- Copied Confirmation ---
             if showCopiedMessage {
                 Text("\(copiedValueType) copied!")
                     .font(.caption)
                     .foregroundColor(.green)
                     .transition(.opacity.combined(with: .scale(scale: 0.8)))
                     .onAppear {
                         DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                             withAnimation {
                                 showCopiedMessage = false
                             }
                         }
                     }
             }
        }
        .frame(maxWidth: .infinity, alignment: .leading) // Take full width
        .padding()
        .background(Color(.systemGray6)) // Subtle background
        .cornerRadius(12)
    }

    // Helper for detail rows with copy button
    @ViewBuilder
    private func detailRow(label: String, value: String?) -> some View {
        if let value = value {
            HStack {
                Text("\(label):")
                    .font(.callout).bold()
                    .frame(width: 50, alignment: .leading) // Align labels
                Text(value)
                    .font(.system(.body, design: .monospaced)) // Monospaced for consistency
                Spacer()
                Button {
                    copyToClipboard(value: value, type: label)
                } label: {
                    Image(systemName: "doc.on.doc")
                }
                .buttonStyle(.borderless) // Less intrusive button style
            }
        } else {
             HStack {
                Text("\(label):")
                    .font(.callout).bold()
                     .frame(width: 50, alignment: .leading)
                Text("N/A")
                    .font(.callout)
                    .foregroundColor(.gray)
                Spacer()
            }
        }
    }

    private func copyToClipboard(value: String, type: String) {
        UIPasteboard.general.string = value
        copiedValueType = type
        withAnimation {
            showCopiedMessage = true
        }
    }
}

struct PaletteSectionView: View {
    let title: String
    let colors: [ColorInfo]
    @Binding var selectedColorInfo: ColorInfo?

    // Use adaptive grid layout
    private let gridItemLayout = [GridItem(.adaptive(minimum: 70))]

    var body: some View {
         VStack(alignment: .leading) {
            Text(title)
                .font(.title3)
                .padding(.bottom, 5)

            LazyVGrid(columns: gridItemLayout, spacing: 15) {
                 ForEach(colors) { info in
                     ColorSwatch(
                         info: info,
                         isSelected: info == selectedColorInfo
                     ) {
                         selectedColorInfo = info // Update selection on tap
                     }
                 }
             }
        }
    }
}

// --- Main Content View ---

struct ContentView: View {
    @State private var selectedColorInfo: ColorInfo? = Palettes.adaptiveSystem.first // Default selection

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 30) {

                // --- Interactive Detail and Preview View ---
                ColorDetailView(info: selectedColorInfo)

                // --- Explanation ---
                VStack(alignment: .leading, spacing: 5) {
                    Text("Understanding Color Types")
                        .font(.headline)
                    Text("• **Adaptive Colors** (like Primary, Accent) automatically adjust for Light/Dark Mode and accessibility settings. Use these for most UI elements for a consistent user experience.")
                        .font(.caption)
                       .fixedSize(horizontal: false, vertical: true) // Allow text wrapping

                    Text("• **Constant Colors** (like the palettes below) always stay the same. Use them for specific branding, illustrations, or when you need a fixed color independent of system appearance.")
                         .font(.caption)
                         .fixedSize(horizontal: false, vertical: true) // Allow text wrapping
                }
                .padding(.horizontal)

                 Divider()

                // --- Palette Sections ---
                PaletteSectionView(
                    title: "Adaptive System Colors (Recommended)",
                    colors: Palettes.adaptiveSystem,
                    selectedColorInfo: $selectedColorInfo
                )

                PaletteSectionView(
                    title: "Display P3 Palette (Constant)",
                    colors: Palettes.displayP3,
                    selectedColorInfo: $selectedColorInfo
                )

                PaletteSectionView(
                    title: "HSB Palette (Constant)",
                    colors: Palettes.hsb,
                    selectedColorInfo: $selectedColorInfo
                )

                PaletteSectionView(
                     title: "Grayscale Palette (Constant)",
                     colors: Palettes.grayscale,
                     selectedColorInfo: $selectedColorInfo
                 )

                // Commenting out Extended Range by default as it's less common & can be confusing
                 /*
                 PaletteSectionView(
                     title: "Extended Range Palette (Constant)",
                     colors: Palettes.extendedRange,
                     selectedColorInfo: $selectedColorInfo
                 )
                 */

            }
            .padding()
        }
        .navigationTitle("Interactive Color Palettes")
    }
}

// --- App Structure & Preview ---

struct InteractiveColorsApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
        }
    }
}

#Preview {
    NavigationView {
        ContentView()
            // Force dark mode for preview testing:
            // .environment(\.colorScheme, .dark)
    }
}
