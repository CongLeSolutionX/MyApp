////
////  ColorPaletteDemoApp.swift
////  MyApp
////
////  Created by Cong Le on 4/18/25.
////
//
//import SwiftUI
//
//// MARK: - Color Definitions (as per previous code)
//struct DisplayP3Palette {
//    static let vibrantRed: Color = Color(.displayP3, red: 1.0, green: 0.1, blue: 0.1, opacity: 1.0)
//    static let lushGreen: Color = Color(.displayP3, red: 0.1, green: 0.9, blue: 0.2, opacity: 1.0)
//    static let deepBlue: Color = Color(.displayP3, red: 0.1, green: 0.2, blue: 0.95, opacity: 1.0)
//    static let brightMagenta: Color = Color(.displayP3, red: 0.95, green: 0.1, blue: 0.8, opacity: 1.0)
//}
//
//struct ExtendedRangePalette {
//    static let ultraWhite: Color = Color(.sRGB, white: 1.1, opacity: 1.0)
//    static let intenseRed: Color = Color(.sRGB, red: 1.2, green: 0, blue: 0, opacity: 1.0)
//    static let deeperThanBlack: Color = Color(.sRGB, white: -0.1, opacity: 1.0)
//}
//
//struct HSBPalette {
//    static let sunshineYellow: Color = Color(hue: 0.15, saturation: 0.9, brightness: 1.0)
//    static let skyBlue: Color = Color(hue: 0.6, saturation: 0.7, brightness: 0.9)
//    static let forestGreen: Color = Color(hue: 0.35, saturation: 0.8, brightness: 0.6)
//    static let fieryOrange: Color = Color(hue: 0.08, saturation: 1.0, brightness: 1.0)
//}
//
//struct GrayscalePalette {
//    static let lightGray: Color = Color(white: 0.8)
//    static let mediumGray: Color = Color(white: 0.5)
//    static let darkGray: Color = Color(white: 0.2)
//}
//
//// MARK: - Utilities for Color Data
//struct ColorItem: Identifiable {
//    let id = UUID()
//    let name: String
//    let color: Color
//    let hex: String
//}
//
//// Convert a Color to hex string for display (approximate, using Color extension)
//extension Color {
//    func toHex() -> String {
//        // For demonstration, return hardcoded or placeholder hex because extraction is complex
//        // In production, implement proper conversion if color components are accessible
//        return "#??????"
//    }
//}
//
//// MARK: - Main View
//struct ContentView: View {
//    // Combine all palettes into a data source
//    private let palettes: [(String, [ColorItem])] = [
//        ("Display P3 Palette", [
//            ColorItem(name: "Vibrant Red", color: DisplayP3Palette.vibrantRed, hex: "#FF1919"),
//            ColorItem(name: "Lush Green", color: DisplayP3Palette.lushGreen, hex: "#19E319"),
//            ColorItem(name: "Deep Blue", color: DisplayP3Palette.deepBlue, hex: "#1935FF"),
//            ColorItem(name: "Bright Magenta", color: DisplayP3Palette.brightMagenta, hex: "#F000CC"),
//        ]),
//        ("Extended Range Palette", [
//            ColorItem(name: "Ultra White", color: ExtendedRangePalette.ultraWhite, hex: "#F2F2F2"),
//            ColorItem(name: "Intense Red", color: ExtendedRangePalette.intenseRed, hex: "#FF0000"),
//            ColorItem(name: "Deeper Than Black", color: ExtendedRangePalette.deeperThanBlack, hex: "#000000"),
//        ]),
//        ("HSB Colors", [
//            ColorItem(name: "Sunshine Yellow", color: HSBPalette.sunshineYellow, hex: "#FFDD00"),
//            ColorItem(name: "Sky Blue", color: HSBPalette.skyBlue, hex: "#0099FF"),
//            ColorItem(name: "Forest Green", color: HSBPalette.forestGreen, hex: "#33CC33"),
//            ColorItem(name: "Fiery Orange", color: HSBPalette.fieryOrange, hex: "#FF5500"),
//        ]),
//        ("Grayscale", [
//            ColorItem(name: "Light Gray", color: GrayscalePalette.lightGray, hex: "#CCCCCC"),
//            ColorItem(name: "Medium Gray", color: GrayscalePalette.mediumGray, hex: "#808080"),
//            ColorItem(name: "Dark Gray", color: GrayscalePalette.darkGray, hex: "#333333"),
//        ])
//    ]
//    
//    @State private var selectedColor: ColorItem? = nil
//    @State private var showDetail = false
//
//    var body: some View {
//        NavigationView {
//            ScrollView {
//                VStack(alignment: .leading, spacing: 20) {
//                    ForEach(palettes, id: \.0) { palette in
//                        Section(header: Text(palette.0).font(.title2).padding(.leading)) {
//                            ScrollView(.horizontal, showsIndicators: false) {
//                                HStack {
//                                    ForEach(palette.1) { item in
//                                        ColorBox(item: item)
//                                            .onTapGesture {
//                                                selectedColor = item
//                                                showDetail = true
//                                            }
//                                    }
//                                }
//                                .padding(.horizontal)
//                            }
//                        }
//                    }
//                }
//                .navigationTitle("Color Palettes")
//                .sheet(isPresented: $showDetail) {
//                    if let colorItem = selectedColor {
//                        ColorDetailView(item: colorItem)
//                    }
//                }
//            }
//        }
//    }
//}
//
//#Preview("Content View") {
//    ContentView()
//}
//// MARK: - Color Box View
//struct ColorBox: View {
//    let item: ColorItem
//
//    var body: some View {
//        VStack {
//            Rectangle()
//                .fill(item.color)
//                .frame(width: 80, height: 80)
//                .cornerRadius(8)
//                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.5), lineWidth: 1))
//            Text(item.name)
//                .font(.caption)
//                .lineLimit(1)
//        }
//        .frame(width: 80)
//    }
//}
//#Preview("ColorBox") {
//    ColorBox(item: .init(name: "Blue", color: .blue, hex: "#007aff"))
//}
//
//// MARK: - Color Detail View
//struct ColorDetailView: View {
//    let item: ColorItem
//    @State private var showCopyAlert = false
//
//    var body: some View {
//        VStack(spacing: 20) {
//            Rectangle()
//                .fill(item.color)
//                .frame(height: 200)
//                .cornerRadius(12)
//                .padding()
//
//            Text(item.name)
//                .font(.title)
//                .bold()
//
//            HStack {
//                Text("Hex:")
//                Text(item.hex)
//                    .font(.system(.body, design: .monospaced))
//                    .padding(4)
//                    .background(Color.black.opacity(0.05))
//                    .cornerRadius(4)
//
//                Spacer()
//
//                Button(action: {
//                    UIPasteboard.general.string = item.hex
//                    showCopyAlert = true
//                }) {
//                    Image(systemName: "doc.on.doc")
//                        .padding()
//                        .background(Color.blue.opacity(0.1))
//                        .clipShape(Circle())
//                }
//                //.tooltip("Copy Hex Code")
//            }
//            .padding(.horizontal)
//
//            Spacer()
//
//            // Simulate gradient overlay
//            LinearGradient(gradient: Gradient(colors: [item.color.opacity(0.3), item.color.opacity(0.9)]),
//                           startPoint: .topLeading,
//                           endPoint: .bottomTrailing)
//                .cornerRadius(12)
//                .padding()
//
//            Button("Close") {
//                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
//            }
//            .padding()
//            .background(Color.accentColor.opacity(0.2))
//            .cornerRadius(8)
//        }
//        .padding()
//        .alert(isPresented: $showCopyAlert) {
//            Alert(title: Text("Copied!"), message: Text("Hex code \(item.hex) copied to clipboard"), dismissButton: .default(Text("OK")))
//        }
//    }
//}
//
//#Preview("ColorDetailView") {
//    ColorDetailView(item: .init(name: "Test Color", color: .blue, hex: "#007aff"))
//}
//
////
////// MARK: - App entry point
////@main
////struct ColorPaletteApp: App {
////    var body: some Scene {
////        WindowGroup {
////            ContentView()
////        }
////    }
////}
