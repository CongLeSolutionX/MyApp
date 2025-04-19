////
////  ColorLabApp.swift
////  MyApp
////
////  Created by Cong Le on 4/18/25.
////
////MARK: -
//import SwiftUI
//
//@main
//struct ColorLabApp: App {
//    @State private var store = ColorStore() // single source of truth
//    
//    var body: some Scene {
//        WindowGroup {
//            RootView()
//                .environment(store) // inject once
//        }
//    }
//}
////MARK: -
//import SwiftUI
//
//struct ColorSwatch: Identifiable, Hashable {
//    let id = UUID()
//    let name: String
//    let color: Color
//    
//    // Helper for sharing / copy operations
//    var hexString: String { color.hexString() }
//}
//
//struct ColorPalette: Identifiable, Hashable {
//    let id = UUID()
//    let title: String
//    let swatches: [ColorSwatch]
//}
////MARK: -
//import SwiftUI
//import Observation// iOS 17+
//
//@Observable
//final class ColorStore {
//    // MARK: - User data
//    
//    private(set) var favorites: Set<ColorSwatch> = []
//    
//    // MARK: - Configuration
//    
//    var showHexOnTile = true
//    var useGridLayout = true
//    
//    // MARK: - Pre‑defined palettes (mock data)
//    
//    let palettes: [ColorPalette] = [
//        ColorPalette(title: "Display P3", swatches: [
//            .init(name: "Vibrant Red",    color: Color(.displayP3, red: 1.0, green: 0.1, blue: 0.1, opacity: 1)),
//            .init(name: "Lush Green",     color: Color(.displayP3, red: 0.1, green: 0.9, blue: 0.2, opacity: 1)),
//            .init(name: "Deep Blue",      color: Color(.displayP3, red: 0.1, green: 0.2, blue: 0.95, opacity: 1)),
//            .init(name: "Bright Magenta", color: Color(.displayP3, red: 0.95, green: 0.1, blue: 0.8, opacity: 1))
//        ]),
//        ColorPalette(title: "Extended Range", swatches: [
//            .init(name: "Ultra White (>1)",  color: Color(.sRGB, white: 1.1, opacity: 1)),
//            .init(name: "Intense Red (>1)",  color: Color(.sRGB, red: 1.2, green: 0, blue: 0, opacity: 1)),
//            .init(name: "Below Black (<0)",  color: Color(.sRGB, white: -0.1, opacity: 1))
//        ]),
//        ColorPalette(title: "HSB", swatches: [
//            .init(name: "Sunshine Yellow", color: Color(hue: 0.15, saturation: 0.9, brightness: 1)),
//            .init(name: "Sky Blue",        color: Color(hue: 0.6,  saturation: 0.7, brightness: 0.9)),
//            .init(name: "Forest Green",    color: Color(hue: 0.35, saturation: 0.8, brightness: 0.6)),
//            .init(name: "Fiery Orange",    color: Color(hue: 0.08, saturation: 1.0, brightness: 1))
//        ]),
//        ColorPalette(title: "Grayscale", swatches: [
//            .init(name: "Light Gray",  color: Color(white: 0.8)),
//            .init(name: "Medium Gray", color: Color(white: 0.5)),
//            .init(name: "Dark Gray",   color: Color(white: 0.2))
//        ])
//    ]
//    
//    // MARK: - Intents
//    
//    func toggleFavorite(_ swatch: ColorSwatch) {
//        if favorites.contains(swatch) {
//            favorites.remove(swatch)
//        } else {
//            favorites.insert(swatch)
//        }
//    }
//}
//
////MARK: -
//import SwiftUI
//
//struct RootView: View {
//    @Environment(ColorStore.self) private var store
//    
//    var body: some View {
//        TabView {
//            PaletteGridView()               // all palettes
//                .tabItem {
//                    Label("Palettes", systemImage: "square.grid.2x2")
//                }
//            
//            FavoritesView()                 // user favorites
//                .tabItem {
//                    Label("Favorites", systemImage: "star.fill")
//                }
//            
//            SettingsView()                  // simple toggles
//                .tabItem {
//                    Label("Settings", systemImage: "gearshape")
//                }
//        }
//    }
//}
//
////MARK: -
//import SwiftUI
//
//struct PaletteGridView: View {
//    @Environment(ColorStore.self) private var store
//    @State private var path = NavigationPath()
//    
//    // simple adaptive grid
//    private var columns: [GridItem] {
//        store.useGridLayout
//        ? [GridItem(.adaptive(minimum: 90), spacing: 12)]
//        : [GridItem(.flexible())]          // one column → list style
//    }
//    
//    var body: some View {
//        NavigationStack(path: $path) {
//            List {                         // List gives search, swipe, etc.
//                ForEach(store.palettes) { palette in
//                    Section(palette.title) {
//                        LazyVGrid(columns: columns, spacing: 12) {
//                            ForEach(palette.swatches) { swatch in
//                                SwatchTile(swatch: swatch)
//                                    .onTapGesture {
//                                        path.append(swatch)      // drill‑down
//                                    }
//                            }
//                        }
//                        .padding(.vertical, 6)
//                    }
//                }
//            }
//            .navigationTitle("Color Palettes")
//            .navigationDestination(for: ColorSwatch.self) { swatch in
//                ColorDetailView(swatch: swatch)
//            }
//        }
//    }
//}
//
//// MARK: - Small tile
//
//private struct SwatchTile: View {
//    @Environment(ColorStore.self) private var store
//    let swatch: ColorSwatch
//    
//    var body: some View {
//        ZStack(alignment: .bottom) {
//            RoundedRectangle(cornerRadius: 12)
//                .fill(swatch.color)
//                .frame(height: store.useGridLayout ? 90 : 60)
//                .overlay(                       // subtle border
//                    RoundedRectangle(cornerRadius: 12)
//                        .stroke(.black.opacity(0.1), lineWidth: 0.5)
//                )
//            
//            if store.showHexOnTile {
//                Text(swatch.hexString)
//                    .font(.caption2.bold())
//                    .padding(4)
//                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 4))
//                    .padding(4)
//            }
//        }
//    }
//}
////MARK: -
//import SwiftUI
//
//struct ColorDetailView: View {
//    @Environment(ColorStore.self) private var store
//    @Environment(\.dismiss) private var dismiss
//    
//    let swatch: ColorSwatch
//    @State private var showShareSheet = false
//    @State private var copyFeedback = false
//    
//    var body: some View {
//        VStack(spacing: 24) {
//            RoundedRectangle(cornerRadius: 24)
//                .fill(swatch.color)
//                .overlay(RoundedRectangle(cornerRadius: 24)
//                    .stroke(.black.opacity(0.15), lineWidth: 1))
//                .frame(height: 220)
//                .padding()
//            
//            VStack(spacing: 8) {
//                Text(swatch.name)
//                    .font(.title2.weight(.semibold))
//                Text(swatch.hexString)
//                    .font(.subheadline.monospaced())
//                    .foregroundStyle(.secondary)
//                
//                Text("WCAG contrast against white: \(contrastWithWhite, specifier: "%.2f")")
//                    .font(.caption)
//                    .foregroundStyle(.secondary)
//            }
//            
//            HStack(spacing: 30) {
//                Button {
//                    store.toggleFavorite(swatch)
//                } label: {
//                    Label("Favorite",
//                          systemImage: store.favorites.contains(swatch) ? "star.fill" : "star")
//                }
//                
//                Button {
//                    UIPasteboard.general.string = swatch.hexString
//                    withAnimation { copyFeedback = true }
//                    Task { try? await Task.sleep(for: .seconds(1.3)); copyFeedback = false }
//                } label: {
//                    Label("Copy HEX", systemImage: "doc.on.doc")
//                }
//                
//                Button {
//                    showShareSheet = true
//                } label: {
//                    Label("Share", systemImage: "square.and.arrow.up")
//                }
//            }
//            .buttonStyle(.borderedProminent)
//            
//            if copyFeedback {
//                Text("Copied!")
//                    .font(.caption)
//                    .transition(.opacity.combined(with: .scale))
//            }
//            
//            Spacer()
//        }
//        .padding(.horizontal)
//        .navigationTitle(swatch.name)
//        .navigationBarTitleDisplayMode(.inline)
//        .sheet(isPresented: $showShareSheet) {
//            ShareSheet(items: [swatch.hexString])
//        }
//        .toolbar {
//            ToolbarItem(placement: .navigationBarTrailing) {
//                Button("Done") { dismiss() }
//            }
//        }
//    }
//    
//    private var contrastWithWhite: Double {
//        swatch.color.contrastRatio(with: .white) ?? 0
//    }
//}
//
//// MARK: - Generic UIKit wrapper for share‑sheet
//
//struct ShareSheet: UIViewControllerRepresentable {
//    let items: [Any]
//    func makeUIViewController(context: Context) -> UIActivityViewController {
//        UIActivityViewController(activityItems: items, applicationActivities: nil)
//    }
//    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
//}
//
//import SwiftUI
//
//struct FavoritesView: View {
//    @Environment(ColorStore.self) private var store
//    
//    var body: some View {
//        if store.favorites.isEmpty {
//            ContentUnavailableView("No favorites yet",
//                                   systemImage: "star",
//                                   description: Text("Tap the star on any color to save it here."))
//        } else {
//            List {
//                ForEach(Array(store.favorites)) { swatch in
//                    NavigationLink {
//                        ColorDetailView(swatch: swatch)
//                    } label: {
//                        HStack {
//                            Circle()
//                                .fill(swatch.color)
//                                .frame(width: 28, height: 28)
//                            VStack(alignment: .leading) {
//                                Text(swatch.name)
//                                Text(swatch.hexString)
//                                    .font(.caption)
//                                    .foregroundStyle(.secondary)
//                            }
//                        }
//                    }
//                }
//                //                .onDelete { indexSet in
//                //                    indexSet.forEach { store.favorites.remove(Array(store.favorites)[$0]) }
//                //                }
//            }
//            .navigationTitle("Favorites")
//        }
//    }
//}
////MARK: -
//import SwiftUI
//
//struct SettingsView: View {
//    @Environment(ColorStore.self) private var store
//    
//    var body: some View {
//        Form {
//            Toggle("Show HEX on tiles", isOn: .constant(store.showHexOnTile))
//            Toggle("Grid layout",        isOn: .constant(store.useGridLayout))
//            
//            Section("About") {
//                Text("Color Lab is a demo showcasing constant vs. adaptive colors, Display P3, and extended‑range RGB in SwiftUI.")
//            }
//        }
//        .navigationTitle("Settings")
//    }
//}
////MARK: -
//import SwiftUI
//import CoreGraphics
//
//// MARK: - HEX Conversion (sRGB only – fine for demo)
//
//extension Color {
//    func hexString() -> String {
//        guard let comps = UIColor(self).cgColor.components,
//              comps.count >= 3 else { return "#??????" }
//        let (r, g, b) = (Int(comps[0] * 255),
//                         Int(comps[1] * 255),
//                         Int(comps[2] * 255))
//        return String(format:"#%02X%02X%02X", r, g, b)
//    }
//}
//
//// MARK: - WCAG contrast (approx, sRGB)
//
//extension Color {
//    /// Returns relative luminance (0‒1) in sRGB
//    private func relativeLuminance() -> Double? {
//        guard let comps = UIColor(self).cgColor.components,
//              comps.count >= 3 else { return nil }
//        func adjust(_ v: CGFloat) -> Double {
//            let c = Double(v)
//            return c <= 0.03928 ? c / 12.92 :
//            pow((c + 0.055) / 1.055, 2.4)
//        }
//        let (r, g, b) = (adjust(comps[0]), adjust(comps[1]), adjust(comps[2]))
//        return 0.2126*r + 0.7152*g + 0.0722*b
//    }
//    
//    /// Contrast ratio vs. another Color (1–21).  Nil if conversion fails.
//    func contrastRatio(with other: Color) -> Double? {
//        guard let l1 = self.relativeLuminance(),
//              let l2 = other.relativeLuminance() else { return nil }
//        let (bright, dark) = (max(l1, l2), min(l1, l2))
//        return (bright + 0.05) / (dark + 0.05)
//    }
//}
