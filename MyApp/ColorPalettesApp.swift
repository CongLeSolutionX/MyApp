////
////  ColorPalettesApp.swift
////  MyApp
////
////  Created by Cong Le on 4/18/25.
////
//
//
//// ───────────────────────────────────────
///// ColorPalettesApp.swift
/////
//import SwiftUI
//import UniformTypeIdentifiers          // For share‑sheet export
//import Combine                          // For @Published → View updates
//
//@main
//struct ColorPalettesApp: App {
//    @StateObject private var paletteVM = PaletteViewModel()
//
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//                .environmentObject(paletteVM)
//        }
//    }
//}
//
//
//// ───────────────────────────────────────
///// Models.swift  ( Codable & Identifiable for easy JSON / SwiftData persistence)
///// 
//import SwiftUI
//
//// MARK: - Core Data Structures
//struct ColorSwatch: Identifiable, Codable, Hashable {
//    var id = UUID()
//    var name: String
//    var components: ColorComponents      // raw numeric values
//    var hex: String                      // pre‑computed hex for convenience
//
//    var swiftUIColor: Color { components.makeColor() }
//}
//
//struct Palette: Identifiable, Codable, Hashable {
//    var id = UUID()
//    var title: String
//    var info: String                     // short description
//    var swatches: [ColorSwatch]
//}
//
//// MARK: - Numeric Representation
//struct ColorComponents: Codable, Hashable {
//    var space: RGBColorSpace = .sRGB     // default
//    var red: Double
//    var green: Double
//    var blue: Double
//    var opacity: Double = 1
//
//    func makeColor() -> Color {
//        Color(space.swiftUIColorSpace,
//              red: red, green: green, blue: blue, opacity: opacity)
//    }
//
//    enum RGBColorSpace: String, Codable {
//        case sRGB, displayP3
//        var swiftUIColorSpace: Color.RGBColorSpace {
//            self == .displayP3 ? .displayP3 : .sRGB
//        }
//    }
//}
//
//
//// ───────────────────────────────────────
///// PaletteViewModel.swift  (MVVM layer, Combine, async loading)
//import SwiftUI
//import Combine
//
//@MainActor
//final class PaletteViewModel: ObservableObject {
//
//    // Published properties keep the UI in sync.
//    @Published private(set) var palettes: [Palette] = []
//    @Published var favourites: Set<UUID> = []               // id Set for quick lookup
//    @Published var preferredColorScheme: ColorScheme? = nil // nil = system
//
//    // Simulate loading from disk/network.
//    func loadPalettes() {
//        Task {
//            // Pretend we fetched JSON on a background thread.
//            try? await Task.sleep(for: .milliseconds(300))   // small delay
//            self.palettes = MockData.makeAllPalettes()
//        }
//    }
//
//    // MARK: - User actions
//    func toggleFavourite(swatch: ColorSwatch) {
//        if favourites.contains(swatch.id) {
//            favourites.remove(swatch.id)
//        } else {
//            favourites.insert(swatch.id)
//        }
//    }
//
//    func isFavourite(_ swatch: ColorSwatch) -> Bool {
//        favourites.contains(swatch.id)
//    }
//}
//
//
//// ───────────────────────────────────────
///// MockData.swift  (creates the original palettes + extras)
/////
//import SwiftUI
//
//enum MockData {
//
//    static func makeAllPalettes() -> [Palette] { [
//        Palette(title: "Display P3",
//                info: "Vibrant wide‑gamut colors",
//                swatches: [
//                    p3("Vibrant Red", 1.0, 0.1, 0.1),
//                    p3("Lush Green", 0.1, 0.9, 0.2),
//                    p3("Deep Blue",  0.1, 0.2, 0.95),
//                    p3("Bright Magenta", 0.95, 0.1, 0.8)
//                ]),
//        Palette(title: "Extended Range",
//                info: "HDR / outside 0…1",
//                swatches: [
//                    ext("Ultra White", 1.1, 1.1, 1.1),
//                    ext("Intense Red", 1.2, 0,   0),
//                    ext("Deeper Black", -0.1, -0.1, -0.1)
//                ]),
//        Palette(title: "HSB",
//                info: "Traditional HSB hues",
//                swatches: [
//                    hsb("Sunshine Yellow", 0.15, 0.9, 1),
//                    hsb("Sky Blue",        0.6,  0.7, 0.9),
//                    hsb("Forest Green",    0.35, 0.8, 0.6),
//                    hsb("Fiery Orange",    0.08, 1.0, 1.0)
//                ]),
//        Palette(title: "Grayscale",
//                info: "0 → 100 % white",
//                swatches: stride(from: 0.15, through: 0.9, by: 0.15).map {
//                    gray("Gray \((Int)($0*100))%", $0)
//                })
//    ] }
//
//    // MARK: - Factory helpers
//    private static func p3(_ name: String,_ r: Double,_ g: Double,_ b: Double) -> ColorSwatch {
//        make(name, .displayP3, r,g,b)
//    }
//    private static func ext(_ name: String,_ r: Double,_ g: Double,_ b: Double) -> ColorSwatch {
//        make(name, .sRGB, r,g,b)
//    }
//    private static func hsb(_ name: String,_ h: Double,_ s: Double,_ v: Double) -> ColorSwatch {
//        let uiColor = UIColor(hue: CGFloat(h),
//                              saturation: CGFloat(s),
//                              brightness: CGFloat(v),
//                              alpha: 1)
//        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0
//        uiColor.getRed(&r, green: &g, blue: &b, alpha: nil)
//        return make(name, .sRGB, r.double, g.double, b.double)
//    }
//    private static func gray(_ name: String,_ white: Double) -> ColorSwatch {
//        make(name, .sRGB, white, white, white)
//    }
//    private static func make(_ name: String,
//                             _ space: ColorComponents.RGBColorSpace,
//                             _ r: Double,_ g: Double,_ b: Double) -> ColorSwatch {
//        let comps = ColorComponents(space: space, red: r, green: g, blue: b)
//        return ColorSwatch(name: name, components: comps,
//                           hex: comps.toHexString())
//    }
//}
//
//// Numeric helpers
//private extension Double { var cg: CGFloat { CGFloat(self) } }
//private extension CGFloat { var double: Double { Double(self) } }
//
//// Convert to HEX (#RRGGBB)
//private extension ColorComponents {
//    func toHexString() -> String {
//        func clamp(_ v: Double) -> Int { Int(max(0, min(1, v))*255) }
//        return String(format:"#%02X%02X%02X",
//                      clamp(red), clamp(green), clamp(blue))
//    }
//}
//
//
//// ───────────────────────────────────────
///// ContentView.swift  (TabView root)
/////
//import SwiftUI
//
//struct ContentView: View {
//    @EnvironmentObject private var vm: PaletteViewModel
//
//    var body: some View {
//        TabView {
//            PaletteListView()
//                .tabItem { Label("Palettes", systemImage: "paintpalette") }
//
//            FavouriteView()
//                .tabItem { Label("Favorites", systemImage: "star.fill") }
//
//            SettingsView()
//                .tabItem { Label("Settings", systemImage: "gearshape") }
//        }
//        .preferredColorScheme(vm.preferredColorScheme)
//        .task { if vm.palettes.isEmpty { vm.loadPalettes() } }
//    }
//}
//
//
//// ───────────────────────────────────────
///// PaletteListView.swift  (Grid of palettes → detail nav)
/////
//import SwiftUI
//
//struct PaletteListView: View {
//    @EnvironmentObject private var vm: PaletteViewModel
//
//    var body: some View {
//        NavigationStack {
//            ScrollView {
//                LazyVStack(spacing: 24) {
//                    ForEach(vm.palettes) { palette in
//                        NavigationLink {
//                            PaletteDetailView(palette: palette)
//                        } label: {
//                            PaletteCard(palette: palette)
//                        }
//                        .buttonStyle(.plain)
//                    }
//                }
//                .padding()
//            }
//            .navigationTitle("Color Palettes")
//        }
//    }
//}
//
//// Compact card showing first few swatches
//private struct PaletteCard: View {
//    let palette: Palette
//    var body: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            HStack(spacing: 4) {
//                ForEach(palette.swatches.prefix(6)) { swatch in
//                    Rectangle()
//                        .fill(swatch.swiftUIColor)
//                        .frame(width: 44, height: 44)
//                        .cornerRadius(6)
//                }
//                Spacer()
//                Image(systemName: "chevron.right")
//                    .foregroundColor(.secondary)
//            }
//            .accessibilityElement(children: .ignore)
//            .accessibilityLabel(Text("\(palette.title) preview"))
//
//            Text(palette.title)
//                .font(.headline)
//            Text(palette.info)
//                .font(.subheadline)
//                .foregroundStyle(.secondary)
//        }
//        .padding()
//        .background(.regularMaterial)
//        .clipShape(RoundedRectangle(cornerRadius: 12))
//    }
//}
//
//
//// ───────────────────────────────────────
///// PaletteDetailView.swift  (Grid of swatches, share/copy/favourite, preview area)
/////
//import SwiftUI
//import UIKit
//
//struct PaletteDetailView: View {
//    @EnvironmentObject private var vm: PaletteViewModel
//    @State private var showShareSheet = false
//    @State private var shareItem: Any?
//
//    let palette: Palette
//
//    private let grid = [GridItem(.adaptive(minimum: 80), spacing: 12)]
//
//    var body: some View {
//        ScrollView {
//            VStack(alignment: .leading, spacing: 24) {
//
//                // MARK: Interactive Grid
//                LazyVGrid(columns: grid, spacing: 12) {
//                    ForEach(palette.swatches) { swatch in
//                        SwatchCell(swatch: swatch)
//                            .contextMenu { contextMenu(for: swatch) }
//                            .onTapGesture { copyToClipboard(swatch) }
//                    }
//                }
//
//                // MARK: Live Preview of palette on a fake screen
//                PreviewUI(palette: palette)
//
//            }
//            .padding()
//        }
//        .navigationTitle(palette.title)
//        .toolbar {
//            ToolbarItem(placement: .navigationBarTrailing) {
//                ShareLink(item: palette.title,
//                          preview: SharePreview(palette.title))
//            }
//        }
//    }
//
//    // MARK: - Helpers
//    private func copyToClipboard(_ swatch: ColorSwatch) {
//        UIPasteboard.general.string = swatch.hex
//        // Lightweight feedback
//        UIImpactFeedbackGenerator(style: .light).impactOccurred()
//    }
//
//    @ViewBuilder
//    private func contextMenu(for swatch: ColorSwatch) -> some View {
//        Button {
//            copyToClipboard(swatch)
//        } label: {
//            Label("Copy HEX (\(swatch.hex))", systemImage: "doc.on.doc")
//        }
//
//        Button {
//            vm.toggleFavourite(swatch: swatch)
//        } label: {
//            if vm.isFavourite(swatch) {
//                Label("Remove Favourite", systemImage: "star.slash")
//            } else {
//                Label("Add to Favourites", systemImage: "star")
//            }
//        }
//
//        ShareLink(item: swatch.hex) {
//            Label("Share HEX", systemImage: "square.and.arrow.up")
//        }
//    }
//}
//
//// MARK: - Swatch cell (shows color + hex)
//private struct SwatchCell: View {
//    @EnvironmentObject private var vm: PaletteViewModel
//    let swatch: ColorSwatch
//
//    var body: some View {
//        VStack(spacing: 6) {
//            Rectangle()
//                .fill(swatch.swiftUIColor)
//                .frame(height: 70)
//                .cornerRadius(8)
//                .overlay(alignment: .topTrailing) {
//                    if vm.isFavourite(swatch) {
//                        Image(systemName: "star.fill")
//                            .foregroundStyle(.yellow)
//                            .padding(4)
//                    }
//                }
//
//            Text(swatch.name)
//                .font(.caption2)
//                .lineLimit(1)
//            Text(swatch.hex)
//                .font(.caption2)
//                .foregroundStyle(.secondary)
//        }
//        .frame(maxWidth: .infinity)
//        .accessibilityElement(children: .combine)
//        .accessibilityLabel(Text("\(swatch.name), \(swatch.hex)"))
//    }
//}
//
//// MARK: - Fake UI to preview palette application
//private struct PreviewUI: View {
//    let palette: Palette
//
//    // pick first ~3 colors or fallback
//    private var primary: Color { palette.swatches[safe: 0]?.swiftUIColor ?? .blue }
//    private var secondary: Color { palette.swatches[safe: 1]?.swiftUIColor ?? .green }
//    private var accent: Color { palette.swatches[safe: 2]?.swiftUIColor ?? .orange }
//
//    var body: some View {
//        VStack(spacing: 16) {
//            Text("Live Preview")
//                .font(.title3.bold())
//
//            VStack(spacing: 12) {
//                Text("Title Text")
//                    .font(.title)
//                    .foregroundColor(primary)
//                Text("Body text using the selected palette for\nquick brand‑color prototyping.")
//                    .multilineTextAlignment(.center)
//                    .foregroundColor(secondary)
//
//                Button("Accent Button") { }
//                    .buttonStyle(.borderedProminent)
//                    .tint(accent)
//
//                RoundedRectangle(cornerRadius: 12)
//                    .fill(accent.opacity(0.3))
//                    .frame(height: 60)
//                    .overlay(Text("Decorative element"))
//            }
//            .padding()
//            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
//        }
//        .frame(maxWidth: .infinity)
//    }
//}
//
//// Safe subscript
//private extension Array {
//    subscript(safe index: Int) -> Element? {
//        indices.contains(index) ? self[index] : nil
//    }
//}
//
//
//
//// ───────────────────────────────────────
///// FavouriteView.swift
/////
//import SwiftUI
//
//struct FavouriteView: View {
//    @EnvironmentObject private var vm: PaletteViewModel
//
//    var body: some View {
//        NavigationStack {
//            if vm.favourites.isEmpty {
//                ContentUnavailableView(label: {
//                    Label("No favourites yet", systemImage: "star")
//                }, description: {
//                    Text("Long‑press any color to add it here.")
//                })
//            } else {
//                ScrollView {
//                    LazyVStack(spacing: 16) {
//                        ForEach(vm.palettes.flatMap(\.swatches)
//                                .filter { vm.favourites.contains($0.id) }) { swatch in
//                            SwatchRow(swatch: swatch)
//                        }
//                    }
//                    .padding()
//                }
//                .navigationTitle("Favorites")
//            }
//        }
//    }
//}
//
//private struct SwatchRow: View {
//    @EnvironmentObject private var vm: PaletteViewModel
//    let swatch: ColorSwatch
//
//    var body: some View {
//        HStack {
//            Rectangle()
//                .fill(swatch.swiftUIColor)
//                .frame(width: 44, height: 44)
//                .cornerRadius(6)
//            VStack(alignment: .leading) {
//                Text(swatch.name)
//                    .font(.headline)
//                Text(swatch.hex)
//                    .font(.caption)
//                    .foregroundStyle(.secondary)
//            }
//            Spacer()
//            Button {
//                vm.toggleFavourite(swatch: swatch)
//            } label: {
//                Image(systemName: "trash")
//                    .foregroundStyle(.red)
//            }
//        }
//        .padding()
//        .background(.quaternary.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
//    }
//}
//
//
//// ───────────────────────────────────────
///// SettingsView.swift  (simple toggles)
/////
//import SwiftUI
//
//struct SettingsView: View {
//    @EnvironmentObject private var vm: PaletteViewModel
//
//    var body: some View {
//        NavigationStack {
//            Form {
//                Section("Appearance") {
//                    Picker("Color Scheme", selection: $vm.preferredColorScheme) {
//                        Text("System").tag(ColorScheme?.none)
//                        Text("Light").tag(ColorScheme?.some(.light))
//                        Text("Dark").tag(ColorScheme?.some(.dark))
//                    }
//                    .pickerStyle(.segmented)
//                }
//
//                Section("Debug") {
//                    Button("Reload mock palettes") {
//                        vm.loadPalettes()
//                    }
//                }
//            }
//            .navigationTitle("Settings")
//        }
//    }
//}
//
