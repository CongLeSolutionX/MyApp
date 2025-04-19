////
////  ColorTool_V2.swift
////  MyApp
////
////  Created by Cong Le on 4/18/25.
////
//
//import SwiftUI
//import UIKit // Required for UIColor conversions and Pasteboard
//
//// MARK: - Color Information Data Structure
//
///// Holds information about a specific color, including its name, SwiftUI Color object,
///// component values (for constant colors), and whether it's adaptive.
//struct ColorInfo: Identifiable, Hashable {
//    let id = UUID()
//    let name: String
//    let color: Color
//    /// RGB components (0.0-1.0 range). Nil for adaptive colors or those not defined by RGB.
//    let rgb: (r: Double, g: Double, b: Double)?
//    /// HSB components (Hue 0.0-1.0, Saturation 0.0-1.0, Brightness 0.0-1.0). Nil for adaptive colors or those not defined by HSB.
//    let hsb: (h: Double, s: Double, b: Double)?
//    /// Flag indicating if the color's appearance changes with system settings (Light/Dark mode, etc.).
//    let isAdaptive: Bool
//
//    // --- Initializers ---
//
//    /// Initializer for constant colors defined by RGB.
//    init(name: String, color: Color, r: Double, g: Double, b: Double) {
//        self.name = name
//        self.color = color
//        self.rgb = (r, g, b)
//        // Attempt basic HSB conversion for display (may lack perfect precision)
//        let uiColor = UIColor(red: CGFloat(r), green: CGFloat(g), blue: CGFloat(b), alpha: 1.0)
//        var hue: CGFloat = 0, saturation: CGFloat = 0, brightness: CGFloat = 0, alpha: CGFloat = 0
//        if uiColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
//            self.hsb = (Double(hue), Double(saturation), Double(brightness))
//        } else {
//            self.hsb = nil // Conversion might fail for out-of-gamut sRGB etc.
//        }
//        self.isAdaptive = false
//    }
//
//    /// Initializer for constant colors defined by HSB.
//    init(name: String, color: Color, h: Double, s: Double, b: Double) {
//        self.name = name
//        self.color = color
//        self.hsb = (h, s, b)
//        // Attempt basic RGB conversion for display (may lack perfect precision)
//        let uiColor = UIColor(hue: CGFloat(h), saturation: CGFloat(s), brightness: CGFloat(b), alpha: 1.0)
//        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
//        if uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
//            self.rgb = (Double(red), Double(green), Double(blue))
//        } else {
//            self.rgb = nil
//        }
//        self.isAdaptive = false
//    }
//
//     /// Initializer for constant colors defined by White value (Grayscale).
//    init(name: String, color: Color, white: Double) {
//        self.name = name
//        self.color = color
//        // Grayscale implies R=G=B=White
//        self.rgb = (white, white, white)
//         // Basic HSB conversion for grayscale (H is undefined, S is 0)
//        self.hsb = (0.0, 0.0, white)
//        self.isAdaptive = false
//    }
//
//    /// Initializer for adaptive colors (Standard SwiftUI, System UI, etc.).
//    /// RGB/HSB components are nil as they vary.
//    init(name: String, adaptiveColor: Color) {
//        self.name = name
//        self.color = adaptiveColor
//        self.rgb = nil
//        self.hsb = nil
//        self.isAdaptive = true
//    }
//
//    // --- Computed Properties for Display ---
//
//    /// Provides the HEX string representation (e.g., #FF0000) for constant colors.
//    var hexString: String? {
//        guard let rgb = rgb, !isAdaptive else { return nil }
//        // Clamp values to valid 0-255 range before conversion
//        let rInt = Int(max(0, min(255, (rgb.r * 255).rounded())))
//        let gInt = Int(max(0, min(255, (rgb.g * 255).rounded())))
//        let bInt = Int(max(0, min(255, (rgb.b * 255).rounded())))
//        return String(format: "#%02X%02X%02X", rInt, gInt, bInt)
//    }
//
//    /// Provides the RGB string representation (e.g., "R:255 G:0 B:0") for constant colors.
//    var rgbString: String? {
//        guard let rgb = rgb, !isAdaptive else { return nil }
//        // Clamp values to valid 0-255 range before conversion
//        let rInt = Int(max(0, min(255, (rgb.r * 255).rounded())))
//        let gInt = Int(max(0, min(255, (rgb.g * 255).rounded())))
//        let bInt = Int(max(0, min(255, (rgb.b * 255).rounded())))
//        return "R:\(rInt) G:\(gInt) B:\(bInt)"
//    }
//
//    /// Provides the HSB string representation (e.g., "H:0° S:100% B:100%") for constant colors.
//    var hsbString: String? {
//        guard let hsb = hsb, !isAdaptive else { return nil }
//        // Convert Hue to degrees, Sat/Bri to percentages
//        let hDeg = Int((hsb.h * 360).rounded())
//        let sPercent = Int((hsb.s * 100).rounded())
//        let bPercent = Int((hsb.b * 100).rounded())
//        return "H:\(hDeg)° S:\(sPercent)% B:\(bPercent)%"
//    }
//
//    // --- Hashable Conformance ---
//     static func == (lhs: ColorInfo, rhs: ColorInfo) -> Bool {
//         lhs.id == rhs.id
//     }
//
//     func hash(into hasher: inout Hasher) {
//         hasher.combine(id)
//     }
//}
//
//// MARK: - Color Catalog
//
///// A catalog containing various collections of predefined `ColorInfo` instances
///// representing different types of colors available in SwiftUI and UIKit.
//struct ColorCatalog {
//
//    // --- Adaptive Colors (Recommended for most UI) ---
//
//    /// Core adaptive colors for foreground content. Adjust automatically.
//    static let coreAdaptive: [ColorInfo] = [
//        .init(name: "Primary", adaptiveColor: .primary),
//        .init(name: "Secondary", adaptiveColor: .secondary),
//        .init(name: "Tertiary", adaptiveColor: Color(uiColor: .tertiaryLabel)), // SwiftUI doesn't have .tertiary directly
//        .init(name: "Quaternary", adaptiveColor: Color(uiColor: .quaternaryLabel)), // SwiftUI doesn't have .quaternary directly
//        .init(name: "Accent", adaptiveColor: .accentColor),
//    ]
//
//    /// Standard named SwiftUI colors. These adapt to light/dark mode etc.
//    static let standardSwiftUI: [ColorInfo] = [
//        .init(name: "Red", adaptiveColor: .red),
//        .init(name: "Orange", adaptiveColor: .orange),
//        .init(name: "Yellow", adaptiveColor: .yellow),
//        .init(name: "Green", adaptiveColor: .green),
//        .init(name: "Mint", adaptiveColor: .mint),
//        .init(name: "Teal", adaptiveColor: .teal),
//        .init(name: "Cyan", adaptiveColor: .cyan),
//        .init(name: "Blue", adaptiveColor: .blue),
//        .init(name: "Indigo", adaptiveColor: .indigo),
//        .init(name: "Purple", adaptiveColor: .purple),
//        .init(name: "Pink", adaptiveColor: .pink),
//        .init(name: "Brown", adaptiveColor: .brown),
//        .init(name: "Gray", adaptiveColor: .gray), // Standard gray
//        .init(name: "Black", adaptiveColor: .black), // Adapts slightly
//        .init(name: "White", adaptiveColor: .white), // Adapts slightly
//        .init(name: "Clear", adaptiveColor: .clear),
//    ]
//
//    /// Semantic System UI colors (from UIColor). Provide context-aware adaptive colors.
//    static let systemUI: [ColorInfo] = [
//        // Backgrounds
//        .init(name: "System Background", adaptiveColor: Color(uiColor: .systemBackground)),
//        .init(name: "Secondary System Background", adaptiveColor: Color(uiColor: .secondarySystemBackground)),
//        .init(name: "Tertiary System Background", adaptiveColor: Color(uiColor: .tertiarySystemBackground)),
//        // Grouped Backgrounds
//        .init(name: "System Grouped Background", adaptiveColor: Color(uiColor: .systemGroupedBackground)),
//        .init(name: "Secondary System Grouped Background", adaptiveColor: Color(uiColor: .secondarySystemGroupedBackground)),
//        .init(name: "Tertiary System Grouped Background", adaptiveColor: Color(uiColor: .tertiarySystemGroupedBackground)),
//        // Fill Colors
//        .init(name: "System Fill", adaptiveColor: Color(uiColor: .systemFill)),
//        .init(name: "Secondary System Fill", adaptiveColor: Color(uiColor: .secondarySystemFill)),
//        .init(name: "Tertiary System Fill", adaptiveColor: Color(uiColor: .tertiarySystemFill)),
//        .init(name: "Quaternary System Fill", adaptiveColor: Color(uiColor: .quaternarySystemFill)),
//        // Label Colors (Primary/Secondary/etc. covered in coreAdaptive)
//        .init(name: "Label (Primary)", adaptiveColor: Color(uiColor: .label)),
//        .init(name: "Secondary Label", adaptiveColor: Color(uiColor: .secondaryLabel)),
//        .init(name: "Tertiary Label", adaptiveColor: Color(uiColor: .tertiaryLabel)),
//        .init(name: "Quaternary Label", adaptiveColor: Color(uiColor: .quaternaryLabel)),
//        // Other Semantic Colors
//        .init(name: "Link", adaptiveColor: Color(uiColor: .link)),
//        .init(name: "Separator", adaptiveColor: Color(uiColor: .separator)),
//        .init(name: "Opaque Separator", adaptiveColor: Color(uiColor: .opaqueSeparator)),
//        // System Colors (tint colors)
//        .init(name: "System Red", adaptiveColor: Color(uiColor: .systemRed)),
//        .init(name: "System Orange", adaptiveColor: Color(uiColor: .systemOrange)),
//        .init(name: "System Yellow", adaptiveColor: Color(uiColor: .systemYellow)),
//        .init(name: "System Green", adaptiveColor: Color(uiColor: .systemGreen)),
//        .init(name: "System Mint", adaptiveColor: Color(uiColor: .systemMint)),
//        .init(name: "System Teal", adaptiveColor: Color(uiColor: .systemTeal)),
//        .init(name: "System Cyan", adaptiveColor: Color(uiColor: .systemCyan)),
//        .init(name: "System Blue", adaptiveColor: Color(uiColor: .systemBlue)),
//        .init(name: "System Indigo", adaptiveColor: Color(uiColor: .systemIndigo)),
//        .init(name: "System Purple", adaptiveColor: Color(uiColor: .systemPurple)),
//        .init(name: "System Pink", adaptiveColor: Color(uiColor: .systemPink)),
//        .init(name: "System Brown", adaptiveColor: Color(uiColor: .systemBrown)),
//        .init(name: "System Gray", adaptiveColor: Color(uiColor: .systemGray)), // Semantic Gray
//        .init(name: "System Gray 2", adaptiveColor: Color(uiColor: .systemGray2)),
//        .init(name: "System Gray 3", adaptiveColor: Color(uiColor: .systemGray3)),
//        .init(name: "System Gray 4", adaptiveColor: Color(uiColor: .systemGray4)),
//        .init(name: "System Gray 5", adaptiveColor: Color(uiColor: .systemGray5)),
//        .init(name: "System Gray 6", adaptiveColor: Color(uiColor: .systemGray6)),
//    ]
//
//    // --- Constant Color Examples (Use Sparingly) ---
//
//    /// Examples of constant colors defined in the Display P3 color space.
//    /// These colors may appear more vibrant on compatible displays but won't adapt.
//    static let displayP3Examples: [ColorInfo] = [
//        .init(name: "P3 Red", color: Color(.displayP3, red: 1.0, green: 0.1, blue: 0.1, opacity: 1.0), r: 1.0, g: 0.1, b: 0.1),
//        .init(name: "P3 Green", color: Color(.displayP3, red: 0.1, green: 0.9, blue: 0.2, opacity: 1.0), r: 0.1, g: 0.9, b: 0.2),
//        .init(name: "P3 Blue", color: Color(.displayP3, red: 0.1, green: 0.2, blue: 0.95, opacity: 1.0), r: 0.1, g: 0.2, b: 0.95),
//        .init(name: "P3 Magenta", color: Color(.displayP3, red: 0.95, green: 0.1, blue: 0.8, opacity: 1.0), r: 0.95, g: 0.1, b: 0.8)
//    ]
//
//    /// Examples of constant colors defined using Hue, Saturation, and Brightness (HSB).
//    static let hsbExamples: [ColorInfo] = [
//        .init(name: "Sunshine Yellow", color: Color(hue: 0.15, saturation: 0.9, brightness: 1.0), h: 0.15, s: 0.9, b: 1.0),
//        .init(name: "Sky Blue", color: Color(hue: 0.6, saturation: 0.7, brightness: 0.9), h: 0.6, s: 0.7, b: 0.9),
//        .init(name: "Forest Green", color: Color(hue: 0.35, saturation: 0.8, brightness: 0.6), h: 0.35, s: 0.8, b: 0.6),
//        .init(name: "Fiery Orange", color: Color(hue: 0.08, saturation: 1.0, brightness: 1.0), h: 0.08, s: 1.0, b: 1.0)
//    ]
//
//    /// Examples of constant grayscale colors defined using a single white value.
//    static let grayscaleExamples: [ColorInfo] = [
//        .init(name: "Light Gray (0.8)", color: Color(white: 0.8), white: 0.8),
//        .init(name: "Medium Gray (0.5)", color: Color(white: 0.5), white: 0.5),
//        .init(name: "Dark Gray (0.2)", color: Color(white: 0.2), white: 0.2),
//        .init(name: "Near Black (0.05)", color: Color(white: 0.05), white: 0.05),
//    ]
//
//     /// Examples of colors defined using the extended sRGB color space.
//     /// These components can go outside the typical 0.0-1.0 range for standard displays,
//     /// achieving effects like brighter-than-white on HDR displays.
//     /// Note: Displaying precise numeric values for these is less meaningful without context.
//     static let extendedRangeExamples: [ColorInfo] = [
//         .init(name: "Ultra White (>1)", color: Color(.sRGBLinear, white: 1.1, opacity: 1.0), r: 1.1, g: 1.1, b: 1.1), // Use RGB init for simplicity
//         .init(name: "Intense Red (>1)", color: Color(.sRGBLinear, red: 1.2, green: 0, blue: 0, opacity: 1.0), r: 1.2, g: 0.0, b: 0.0),
//         .init(name: "Deeper Black (<0)", color: Color(.sRGBLinear, white: -0.1, opacity: 1.0), r: -0.1, g: -0.1, b: -0.1), // Use RGB init for simplicity
//     ]
//
//    // --- Add more categories as needed ---
//}
//
//// MARK: - Helper Extensions (Optional)
//
//// Example: Add Hex Initializer (Place outside primary structs if preferred)
//extension Color {
//    init?(hex: String) {
//        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
//        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
//
//        var rgb: UInt64 = 0
//
//        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else {
//            return nil
//        }
//
//        let length = hexSanitized.count
//        let r, g, b, a: Double
//        if length == 6 {
//            r = Double((rgb & 0xFF0000) >> 16) / 255.0
//            g = Double((rgb & 0x00FF00) >> 8) / 255.0
//            b = Double(rgb & 0x0000FF) / 255.0
//            a = 1.0
//        } else if length == 8 {
//            r = Double((rgb & 0xFF000000) >> 24) / 255.0
//            g = Double((rgb & 0x00FF0000) >> 16) / 255.0
//            b = Double((rgb & 0x0000FF00) >> 8) / 255.0
//            a = Double(rgb & 0x000000FF) / 255.0
//        } else {
//            return nil // Invalid length
//        }
//
//        self.init(.sRGB, red: r, green: g, blue: b, opacity: a)
//    }
//}
//
//import SwiftUI
//import UIKit // Needed for Pasteboard in ColorDetailView
//
//// --- Interactive UI Components (ColorSwatch, ColorDetailView, PaletteSectionView) ---
//// (Keep the definitions from the previous response for these views exactly as they were)
//
//struct ColorSwatch: View {
//    let info: ColorInfo
//    let isSelected: Bool
//    let action: () -> Void
//
//    var body: some View {
//        VStack {
//            Rectangle()
//                .fill(info.color)
//                .frame(width: 50, height: 50)
//                .cornerRadius(8)
//                .overlay(
//                    RoundedRectangle(cornerRadius: 8)
//                        .stroke(isSelected ? Color.primary.opacity(0.8) : Color.gray.opacity(0.5), lineWidth: isSelected ? 3 : 1)
//                )
//                .padding(isSelected ? 0 : 2)
//                .animation(.easeInOut(duration: 0.1), value: isSelected)
//                .onTapGesture(perform: action)
//
//            Text(info.name)
//                .font(.caption)
//                .lineLimit(2)
//                .frame(width: 60, height: 30, alignment: .top) // Align text top for consistency
//                .multilineTextAlignment(.center)
//        }
//    }
//}
//
//struct ColorDetailView: View {
//    let info: ColorInfo?
//    @State private var showCopiedMessage: Bool = false
//    @State private var copiedValueType: String = ""
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 10) {
//            Text("Details & Preview")
//                .font(.title2)
//                .padding(.bottom, 5)
//
//            if let info = info {
//                // --- Preview Area ---
//                VStack(alignment: .leading, spacing: 15) {
//                     Text("Applied Preview:")
//                        .font(.headline)
//
//                     // Consistent preview elements
//                    HStack {
//                        Text("Sample Text")
//                            .font(.title3)
//                            .foregroundStyle(info.color)
//                        Spacer()
//                        Image(systemName: "star.fill")
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: 30, height: 30)
//                             .foregroundStyle(info.color)
//                    }
//
//                    Button("Sample Button") { }
//                        .buttonStyle(.borderedProminent)
//                        .tint(info.color)
//
//                    ProgressView(value: 0.75)
//                      .tint(info.color) // Use tint for ProgressView
//
//                    Rectangle()
//                        .fill(info.color.opacity(0.3))
//                        .frame(height: 40)
//                        .overlay(Text("Background (\(info.isAdaptive ? "Adaptive" : "Constant"))").font(.caption))
//                         .cornerRadius(5)
//                }
//                .padding(.bottom)
//
//                 // --- Details ---
//                 Text("Color Values (\(info.isAdaptive ? "Adaptive" : "Constant")):")
//                     .font(.headline)
//
//                if info.isAdaptive {
//                    Text("Values adapt based on system settings (Light/Dark Mode, Accessibility, etc.). Fixed components not applicable.")
//                        .font(.caption)
//                        .foregroundColor(.gray)
//                        .fixedSize(horizontal: false, vertical: true) // Allow wrapping
//                } else {
//                    detailRow(label: "HEX", value: info.hexString)
//                    detailRow(label: "RGB", value: info.rgbString)
//                    detailRow(label: "HSB", value: info.hsbString)
//                }
//
//            } else {
//                Text("Tap a color swatch above to see its details and a preview.")
//                    .foregroundColor(.secondary)
//                    .padding(.vertical)
//            }
//
//            // --- Copied Confirmation ---
//             if showCopiedMessage {
//                 Text("\(copiedValueType) copied!")
//                     .font(.caption)
//                     .foregroundColor(.green)
//                     .transition(.opacity.combined(with: .scale(scale: 0.8)))
//                     .id("CopiedMessage") // Add ID for transition stability
//                     .onAppear {
//                         DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
//                             withAnimation(.easeInOut) {
//                                 showCopiedMessage = false
//                             }
//                         }
//                     }
//                     .frame(height: 20) // Reserve space to prevent layout shift
//             } else {
//                 Spacer().frame(height: 20) // Reserve space when message is hidden
//             }
//        }
//        .frame(maxWidth: .infinity, alignment: .leading)
//        .padding()
//        .background(Color(.systemGray6))
//        .cornerRadius(12)
//        .animation(.default, value: info) // Animate changes when info changes
//    }
//
//     // Helper for detail rows with copy button
//    @ViewBuilder
//    private func detailRow(label: String, value: String?) -> some View {
//        if let value = value {
//            HStack {
//                Text("\(label):")
//                    .font(.callout).bold()
//                    .frame(width: 50, alignment: .leading)
//                Text(value)
//                    .font(.system(.body, design: .monospaced))
//                    .textSelection(.enabled) // Allow selecting text
//                Spacer()
//                Button {
//                    copyToClipboard(value: value, type: label)
//                } label: {
//                    Image(systemName: "doc.on.doc")
//                }
//                .buttonStyle(.borderless)
//                .help("Copy \(label) value") // Add tooltip for macOS/iPadOS
//            }
//        } // Don't show row if value is nil
//    }
//
//    private func copyToClipboard(value: String, type: String) {
//        UIPasteboard.general.string = value
//        copiedValueType = type
//        if !showCopiedMessage { // Prevent animation overlap if already showing
//            withAnimation(.spring()) {
//                showCopiedMessage = true
//            }
//        }
//    }
//}
//
//struct PaletteSectionView: View {
//    let title: String
//    let description: String? // Optional description for sections
//    let colors: [ColorInfo]
//    @Binding var selectedColorInfo: ColorInfo?
//
//    private let gridItemLayout = [GridItem(.adaptive(minimum: 75))] // Slightly wider minimum
//
//    var body: some View {
//         VStack(alignment: .leading, spacing: 8) { // Reduced spacing
//            Text(title)
//                .font(.title3.weight(.semibold)) // Slightly bolder title
//
//             if let description = description {
//                 Text(description)
//                     .font(.caption)
//                     .foregroundColor(.secondary)
//                     .padding(.bottom, 4)
//             }
//
//            LazyVGrid(columns: gridItemLayout, spacing: 15) {
//                 ForEach(colors) { info in
//                     ColorSwatch(
//                         info: info,
//                         isSelected: info == selectedColorInfo
//                     ) {
//                         withAnimation(.snappy) { // Add animation to selection change
//                             selectedColorInfo = info
//                         }
//                     }
//                 }
//             }
//        }
//    }
//}
//
//// --- Main Content View (Using ColorCatalog) ---
//
//struct ContentView: View {
//    // Default to primary adaptive color
//    @State private var selectedColorInfo: ColorInfo? = ColorCatalog.coreAdaptive.first
//
//    var body: some View {
//        ScrollView {
//            VStack(alignment: .leading, spacing: 25) { // Adjusted spacing
//
//                // --- Interactive Detail and Preview View ---
//                ColorDetailView(info: selectedColorInfo)
//                    .padding(.horizontal) // Add horizontal padding
//
//                // --- Explanation ---
//                VStack(alignment: .leading, spacing: 8) {
//                    Text("Understanding Color Types")
//                        .font(.headline)
//                    Text("• **Adaptive Colors** (like Primary, System Background, Blue, etc.) automatically adjust for Light/Dark Mode and accessibility settings. **Use these for most UI elements.**")
//                        .font(.callout) // Slightly larger font
//                       .fixedSize(horizontal: false, vertical: true)
//
//                    Text("• **Constant Colors** (Display P3, HSB, Grayscale examples) always stay the same. Use them for specific branding, illustrations, or when a fixed color is essential.")
//                         .font(.callout)
//                         .fixedSize(horizontal: false, vertical: true)
//                }
//                .padding(.horizontal)
//
//                 Divider().padding(.vertical, 10)
//
//                // --- Palette Sections using ColorCatalog ---
//
//                 Group { // Group sections logically
//                    PaletteSectionView(
//                        title: "Core Adaptive Colors",
//                        description: "Fundamental foreground colors.",
//                        colors: ColorCatalog.coreAdaptive,
//                        selectedColorInfo: $selectedColorInfo
//                    )
//
//                    PaletteSectionView(
//                        title: "Standard SwiftUI Colors",
//                        description: "Common named colors, also adaptive.",
//                        colors: ColorCatalog.standardSwiftUI,
//                        selectedColorInfo: $selectedColorInfo
//                    )
//
//                    PaletteSectionView(
//                         title: "Semantic System UI Colors",
//                         description: "Context-aware adaptive colors from UIKit.",
//                         colors: ColorCatalog.systemUI,
//                         selectedColorInfo: $selectedColorInfo
//                     )
//                 }
//                 .padding(.horizontal)
//
//                 Divider().padding(.vertical, 10)
//
//                 Group {
//                     PaletteSectionView(
//                         title: "Constant: Display P3 Examples",
//                         description: "Wider gamut, fixed colors.",
//                         colors: ColorCatalog.displayP3Examples,
//                         selectedColorInfo: $selectedColorInfo
//                     )
//
//                     PaletteSectionView(
//                         title: "Constant: HSB Examples",
//                         description: "Defined by Hue, Saturation, Brightness.",
//                         colors: ColorCatalog.hsbExamples,
//                         selectedColorInfo: $selectedColorInfo
//                     )
//
//                     PaletteSectionView(
//                          title: "Constant: Grayscale Examples",
//                          description: "Defined by white level.",
//                          colors: ColorCatalog.grayscaleExamples,
//                          selectedColorInfo: $selectedColorInfo
//                      )
//
//                     // Optional: Extended Range
////                      PaletteSectionView(
////                          title: "Constant: Extended Range Examples",
////                          description: "For HDR displays (>1 or <0 components).",
////                          colors: ColorCatalog.extendedRangeExamples,
////                          selectedColorInfo: $selectedColorInfo
////                      )
//                 }
//                 .padding(.horizontal)
//
//            }
//            .padding(.vertical) // Add padding to the main VStack
//        }
//        .navigationTitle("Swift Color Catalog")
//        .background(Color(.systemGroupedBackground)) // Use adaptive background for the overall view
//    }
//}
//
//// --- App Structure & Preview ---
//
//// Assuming you have an App struct like this:
///*
// @main
// struct InteractiveColorsApp: App {
//     var body: some Scene {
//         WindowGroup {
//             NavigationView {
//                 ContentView()
//             }
//         }
//     }
// }
// */
//
//#Preview("Light Mode") {
//    NavigationView {
//        ContentView()
//            .environment(\.colorScheme, .light)
//    }
//}
//
//#Preview("Dark Mode") {
//    NavigationView {
//        ContentView()
//             .environment(\.colorScheme, .dark)
//    }
//}
