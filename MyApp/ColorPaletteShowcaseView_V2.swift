////
////  ColorPaletteShowcaseView_V2.swift
////  MyApp
////
////  Created by Cong Le on 4/18/25.
////
//
//import SwiftUI
//
//// --- Enhanced Functionality and Practical Application ---
//
///// Represents a color with metadata for use in the palette.
//struct ColorInfo: Identifiable {
//    static func == (lhs: ColorInfo, rhs: ColorInfo) -> Bool {
//        return true
//    }
//    
//    let id = UUID() // Unique identifier
//    let name: String
//    let color: Color
//    let rgbValues: (red: Double, green: Double, blue: Double) // RGB as doubles
//    let hex: String // Hexadecimal representation for easy copying
//}
//
///// A wrapper for managing themes and user-selected colors.
//class ColorPaletteViewModel: ObservableObject {
//    @Published var selectedColor: ColorInfo? // Currently selected color
//    @Published var customTheme: [ColorInfo] = [] // User-customized theme
//    @Published var savedThemes: [[ColorInfo]] = [] // Mock saved themes for presets
//
//    init() {
//        // Load some mock saved themes
//        savedThemes = [
//            [
//                ColorInfo(name: "Vibrant Red", color: DisplayP3Palette.vibrantRed, rgbValues: (1.0, 0.1, 0.1), hex: "#FF1919"),
//                ColorInfo(name: "Lush Green", color: DisplayP3Palette.lushGreen, rgbValues: (0.1, 0.9, 0.2), hex: "#19E633"),
//                ColorInfo(name: "Deep Blue", color: DisplayP3Palette.deepBlue, rgbValues: (0.1, 0.2, 0.95), hex: "#1933F2")
//            ],
//            [
//                ColorInfo(name: "Sunshine Yellow", color: HSBPalette.sunshineYellow, rgbValues: (1.0, 0.9, 0.1), hex: "#FFE619"),
//                ColorInfo(name: "Sky Blue", color: HSBPalette.skyBlue, rgbValues: (0.0, 0.6, 0.7), hex: "#73BDF5")
//            ]
//        ]
//    }
//
//    func addToCustomTheme(_ colorInfo: ColorInfo) {
//        guard !customTheme.contains(where: { $0.id == colorInfo.id }) else { return } // Avoid duplicates
//        customTheme.append(colorInfo)
//    }
//
//    func resetCustomTheme() {
//        customTheme.removeAll()
//    }
//
//    func saveCurrentTheme() {
//        savedThemes.append(customTheme)
//        resetCustomTheme()
//    }
//}
//
///// Palette using Display P3 colors.
//struct DisplayP3Palette {
//    static let vibrantRed: Color = Color(.displayP3, red: 1.0, green: 0.1, blue: 0.1, opacity: 1.0)
//    static let lushGreen: Color = Color(.displayP3, red: 0.1, green: 0.9, blue: 0.2, opacity: 1.0)
//    static let deepBlue: Color = Color(.displayP3, red: 0.1, green: 0.2, blue: 0.95, opacity: 1.0)
//    static let brightMagenta: Color = Color(.displayP3, red: 0.95, green: 0.1, blue: 0.8, opacity: 1.0)
//}
//
///// Palette using HSB colors.
//struct HSBPalette {
//    static let sunshineYellow: Color = Color(hue: 0.15, saturation: 0.9, brightness: 1.0)
//    static let skyBlue: Color = Color(hue: 0.6, saturation: 0.7, brightness: 0.9)
//    static let forestGreen: Color = Color(hue: 0.35, saturation: 0.8, brightness: 0.6)
//    static let fieryOrange: Color = Color(hue: 0.08, saturation: 1.0, brightness: 1.0)
//}
//
///// Main application view.
//struct ColorPaletteShowcaseView: View {
//    @StateObject private var viewModel = ColorPaletteViewModel()
//
//    var body: some View {
//        NavigationView {
//            VStack(alignment: .leading, spacing: 20) {
//                // Preview area
//                if let selectedColor = viewModel.selectedColor {
//                    VStack {
//                        Text("Selected Color")
//                            .font(.headline)
//                        Rectangle()
//                            .fill(selectedColor.color)
//                            .cornerRadius(12)
//                            .frame(height: 80)
//                        Text("Name: \(selectedColor.name)")
//                        Text("RGB: \(selectedColor.rgbValues.red, specifier: "%.2f"), \(selectedColor.rgbValues.green, specifier: "%.2f"), \(selectedColor.rgbValues.blue, specifier: "%.2f")")
//                        Text("Hex: \(selectedColor.hex)")
//                    }
//                    .padding()
//                    .background(Color.secondary.opacity(0.1))
//                    .cornerRadius(12)
//                }
//
//                // Custom theme area
//                VStack {
//                    Text("Custom Theme")
//                        .font(.headline)
//                    ScrollView(.horizontal, showsIndicators: false) {
//                        HStack {
//                            ForEach(viewModel.customTheme) { colorInfo in
//                                Circle()
//                                    .fill(colorInfo.color)
//                                    .frame(width: 50, height: 50)
//                                    .overlay(Circle().stroke(Color.gray, lineWidth: 1))
//                            }
//                        }
//                    }
//                    if !viewModel.customTheme.isEmpty {
//                        HStack {
//                            Button("Save Theme") {
//                                viewModel.saveCurrentTheme()
//                            }
//                            .buttonStyle(.borderedProminent)
//
//                            Button("Reset Theme") {
//                                viewModel.resetCustomTheme()
//                            }
//                            .buttonStyle(.bordered)
//                        }
//                    }
//                }
//                .padding()
//
//                // Saved themes
//                VStack(alignment: .leading) {
//                    Text("Saved Themes")
//                        .font(.headline)
//                    ScrollView {
////                        ForEach(viewModel.savedThemes, id: \.self) { theme in
////                            HStack {
////                                ForEach(theme) { colorInfo in
////                                    Circle()
////                                        .fill(colorInfo.color)
////                                        .frame(width: 20, height: 20)
////                                }
////                                Spacer()
////                            }
////                        }
//                    }
//                }
//
//                // Palette selection area
//                PaletteSection(title: "Display P3 Palette", colors: [
//                    ColorInfo(name: "Vibrant Red", color: DisplayP3Palette.vibrantRed, rgbValues: (1.0, 0.1, 0.1), hex: "#FF1919"),
//                    ColorInfo(name: "Lush Green", color: DisplayP3Palette.lushGreen, rgbValues: (0.1, 0.9, 0.2), hex: "#19E633"),
//                    ColorInfo(name: "Deep Blue", color: DisplayP3Palette.deepBlue, rgbValues: (0.1, 0.2, 0.95), hex: "#1933F2"),
//                    ColorInfo(name: "Bright Magenta", color: DisplayP3Palette.brightMagenta, rgbValues: (0.95, 0.1, 0.8), hex: "#F219CC")
//                ], selectedColor: $viewModel.selectedColor, onAddToTheme: viewModel.addToCustomTheme)
//            }
//            .padding()
//            .navigationBarTitle("Color Palette Showcase")
//        }
//    }
//}
//
///// Displays a section of the palette with tappable color swatches.
//struct PaletteSection: View {
//    let title: String
//    let colors: [ColorInfo]
//    @Binding var selectedColor: ColorInfo?
//    let onAddToTheme: (ColorInfo) -> Void
//
//    var body: some View {
//        VStack(alignment: .leading) {
//            Text(title)
//                .font(.headline)
//                .padding(.bottom, 5)
//            ScrollView(.horizontal, showsIndicators: false) {
//                HStack(spacing: 16) {
//                    ForEach(colors) { colorInfo in
//                        VStack {
//                            Rectangle()
//                                .fill(colorInfo.color)
//                                .frame(width: 60, height: 60)
//                                .cornerRadius(12)
//                                .onTapGesture {
//                                    selectedColor = colorInfo
//                                }
//                            Button(action: {
//                                onAddToTheme(colorInfo)
//                            }) {
//                                Text("Select")
//                                    .font(.caption)
//                            }
//                        }
//                    }
//                }
//            }
//        }
//        .padding(.vertical)
//    }
//}
//
//// --- Preview ---
//
//#Preview {
//    ColorPaletteShowcaseView()
//}
