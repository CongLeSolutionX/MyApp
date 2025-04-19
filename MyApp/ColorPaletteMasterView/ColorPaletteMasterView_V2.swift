//
//  ColorPaletteMasterView_V2.swift
//  MyApp
//
//  Created by Cong Le on 4/18/25.
//

import SwiftUI
import Combine

// MARK: - Models

struct ColorEntry: Identifiable {
    static func == (lhs: ColorEntry, rhs: ColorEntry) -> Bool {
        return true
    }
    
    let id = UUID()
    let name: String
    let color: Color
    let description: String?
    let rgbComponents: (red: Double, green: Double, blue: Double)?
    let colorSpace: String
    var isFavorite: Bool = false
    
    var hexString: String {
        guard let rgb = rgbComponents else { return "N/A" }
        func clamp(_ val: Double) -> UInt8 {
            UInt8(min(max(val, 0), 1) * 255)
        }
        let r = clamp(rgb.red)
        let g = clamp(rgb.green)
        let b = clamp(rgb.blue)
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}

struct Palette: Identifiable {
    let id = UUID()
    let title: String
    var colors: [ColorEntry]
    let description: String?
}

// MARK: - ViewModel

final class PaletteViewModel: ObservableObject {
    @Published var palettes: [Palette] = []
    @Published var searchText: String = ""
    @Published var showFavoritesOnly: Bool = false
    
    init() {
        loadComprehensivePalette()
    }
    
    func filteredPalettes() -> [Palette] {
        palettes.map { palette in
            let filteredColors = palette.colors.filter { entry in
                (!showFavoritesOnly || entry.isFavorite) &&
                (searchText.isEmpty || entry.name.localizedCaseInsensitiveContains(searchText))
            }
            return Palette(title: palette.title, colors: filteredColors, description: palette.description)
        }
        .filter { !$0.colors.isEmpty }
    }
    
    func toggleFavorite(for colorEntry: ColorEntry) {
        for (paletteIndex, palette) in palettes.enumerated() {
//            if let colorIndex = palette.colors.firstIndex(of: colorEntry) {
//                palettes[paletteIndex].colors[colorIndex].isFavorite.toggle()
//                objectWillChange.send()
//                break
//            }
        }
    }
    
    private func loadComprehensivePalette() {
        // The data is organized into palettes by color space / category
        
        palettes = [
            Palette(
                title: "Display P3 Colors",
                colors: [
                    ColorEntry(name: "P3 Vibrant Red",
                               color: Color(.displayP3, red: 1.0, green: 0.1, blue: 0.1),
                               description: "Highly saturated red in the Display P3 color space, rich and vivid.",
                               rgbComponents: (1.0, 0.1, 0.1),
                               colorSpace: "Display P3"),
                    ColorEntry(name: "P3 Lush Green",
                               color: Color(.displayP3, red: 0.1, green: 0.9, blue: 0.2),
                               description: "Strong green with Display P3 range enhancing vibrancy.",
                               rgbComponents: (0.1, 0.9, 0.2),
                               colorSpace: "Display P3"),
                    ColorEntry(name: "P3 Deep Blue",
                               color: Color(.displayP3, red: 0.05, green: 0.2, blue: 0.85),
                               description: "Deep blue that takes advantage of the wide gamut.",
                               rgbComponents: (0.05, 0.2, 0.85),
                               colorSpace: "Display P3"),
                    ColorEntry(name: "P3 Bright Magenta",
                               color: Color(.displayP3, red: 0.9, green: 0.1, blue: 0.9),
                               description: "Magenta vibrant for strong accents.",
                               rgbComponents: (0.9, 0.1, 0.9),
                               colorSpace: "Display P3"),
                    ColorEntry(name: "P3 Amber",
                               color: Color(.displayP3, red: 1.0, green: 0.75, blue: 0.0),
                               description: "Warm amber within Display P3 space.",
                               rgbComponents: (1.0, 0.75, 0.0),
                               colorSpace: "Display P3")
                ],
                description: "Wide gamut rich colors stored in Display P3 color space."
            ),
            Palette(
                title: "Standard sRGB Colors",
                colors: [
                    ColorEntry(name: "sRGB Red",
                               color: Color(red: 1, green: 0, blue: 0),
                               description: "Standard red in sRGB space.",
                               rgbComponents: (1, 0, 0),
                               colorSpace: "sRGB"),
                    ColorEntry(name: "sRGB Green",
                               color: Color(red: 0, green: 1, blue: 0),
                               description: "Standard green in sRGB space.",
                               rgbComponents: (0, 1, 0),
                               colorSpace: "sRGB"),
                    ColorEntry(name: "sRGB Blue",
                               color: Color(red: 0, green: 0, blue: 1),
                               description: "Standard blue in sRGB space.",
                               rgbComponents: (0, 0, 1),
                               colorSpace: "sRGB"),
                    ColorEntry(name: "sRGB Cyan",
                               color: Color(red: 0, green: 1, blue: 1),
                               description: "Cyan from sRGB color model.",
                               rgbComponents: (0, 1, 1),
                               colorSpace: "sRGB"),
                    ColorEntry(name: "sRGB Magenta",
                               color: Color(red: 1, green: 0, blue: 1),
                               description: "Magenta standard sRGB",
                               rgbComponents: (1, 0, 1),
                               colorSpace: "sRGB"),
                    ColorEntry(name: "sRGB Yellow",
                               color: Color(red: 1, green: 1, blue: 0),
                               description: "Bright yellow from sRGB model.",
                               rgbComponents: (1, 1, 0),
                               colorSpace: "sRGB"),
                    ColorEntry(name: "sRGB Black",
                               color: Color(red: 0, green: 0, blue: 0),
                               description: "Pure black.",
                               rgbComponents: (0, 0, 0),
                               colorSpace: "sRGB"),
                    ColorEntry(name: "sRGB White",
                               color: Color(red: 1, green: 1, blue: 1),
                               description: "Pure white.",
                               rgbComponents: (1, 1, 1),
                               colorSpace: "sRGB")
                ],
                description: "Basic colors from the standard sRGB color space."
            ),
            Palette(
                title: "Extended sRGB Range Colors",
                colors: [
                    ColorEntry(name: "Ultra White (Extended)",
                               color: Color(.sRGB, white: 1.1),
                               description: "Extended white, beyond 100% brightness, usable in HDR.",
                               rgbComponents: (1.1, 1.1, 1.1),
                               colorSpace: "Extended sRGB"),
                    ColorEntry(name: "Intense Red (Extended)",
                               color: Color(.sRGB, red: 1.2, green: 0, blue: 0),
                               description: "Red exceeding standard sRGB limit, used in HDR.",
                               rgbComponents: (1.2, 0, 0),
                               colorSpace: "Extended sRGB"),
                    ColorEntry(name: "Negative Black (Extended)",
                               color: Color(.sRGB, white: -0.1),
                               description: "Negative intensity, clamped to zero on display.",
                               rgbComponents: (0, 0, 0),
                               colorSpace: "Extended sRGB")
                ],
                description: "Colors exceeding conventional sRGB boundaries."
            ),
            Palette(
                title: "HSB (Hue-Saturation-Brightness) Colors",
                colors: [
                    ColorEntry(name: "Bright Yellow",
                               color: Color(hue: 0.15, saturation: 0.9, brightness: 1.0),
                               description: "HSB with warm yellow hue.",
                               rgbComponents: nil,
                               colorSpace: "HSB"),
                    ColorEntry(name: "Sky Blue",
                               color: Color(hue: 0.6, saturation: 0.7, brightness: 0.9),
                               description: "Soft bright blue from HSB.",
                               rgbComponents: nil,
                               colorSpace: "HSB"),
                    ColorEntry(name: "Forest Green",
                               color: Color(hue: 0.35, saturation: 0.8, brightness: 0.6),
                               description: "Deep green hue from HSB space.",
                               rgbComponents: nil,
                               colorSpace: "HSB"),
                    ColorEntry(name: "Orange",
                               color: Color(hue: 0.08, saturation: 1.0, brightness: 1.0),
                               description: "Vivid orange color with max saturation.",
                               rgbComponents: nil,
                               colorSpace: "HSB")
                ],
                description: "Colors defined by hue, saturation and brightness."
            ),
            Palette(
                title: "Grayscale Palette",
                colors: [
                    ColorEntry(name: "Light Gray",
                               color: Color(white: 0.8),
                               description: "Neutral light gray, good for backgrounds.",
                               rgbComponents: (0.8, 0.8, 0.8),
                               colorSpace: "Grayscale"),
                    ColorEntry(name: "Medium Gray",
                               color: Color(white: 0.5),
                               description: "Standard medium gray.",
                               rgbComponents: (0.5, 0.5, 0.5),
                               colorSpace: "Grayscale"),
                    ColorEntry(name: "Dark Gray",
                               color: Color(white: 0.2),
                               description: "Dark gray for text and focus elements.",
                               rgbComponents: (0.2, 0.2, 0.2),
                               colorSpace: "Grayscale"),
                    ColorEntry(name: "Near Black",
                               color: Color(white: 0.1),
                               description: "Almost black grayscale shade.",
                               rgbComponents: (0.1, 0.1, 0.1),
                               colorSpace: "Grayscale")
                ],
                description: "Various grayscale shades."
            ),
            Palette(
                title: "System Semantic Colors (Adaptive)",
                colors: [
                    ColorEntry(name: "System Background",
                               color: Color(.systemBackground),
                               description: "Base background color that adapts to light/dark mode.",
                               rgbComponents: nil,
                               colorSpace: "Semantic System Colors"),
                    ColorEntry(name: "System Label",
                               color: Color(.label),
                               description: "Primary text color that adapts to environment.",
                               rgbComponents: nil,
                               colorSpace: "Semantic System Colors"),
                    ColorEntry(name: "System Fill",
                               color: Color(.systemFill),
                               description: "Fill color for UI elements adapting to system theme.",
                               rgbComponents: nil,
                               colorSpace: "Semantic System Colors"),
                    ColorEntry(name: "Secondary Label",
                               color: Color(.secondaryLabel),
                               description: "Secondary text color with less emphasis.",
                               rgbComponents: nil,
                               colorSpace: "Semantic System Colors"),
                    ColorEntry(name: "Tertiary Label",
                               color: Color(.tertiaryLabel),
                               description: "Tertiary label color with lower emphasis.",
                               rgbComponents: nil,
                               colorSpace: "Semantic System Colors"),
                    ColorEntry(name: "Quaternary Label",
                               color: Color(.quaternaryLabel),
                               description: "Lowest emphasis label color.",
                               rgbComponents: nil,
                               colorSpace: "Semantic System Colors")
                ],
                description: "Colors that adapt automatically to different UI styles and accessibility settings."
            ),
            Palette(
                title: "CSS/Web Named Colors (Common)",
                colors: [
                    ColorEntry(name: "Alice Blue",
                               color: Color(red: 0.941, green: 0.973, blue: 1.0),
                               description: "Very pale blue with a slight tint.",
                               rgbComponents: (0.941, 0.973, 1.0),
                               colorSpace: "sRGB"),
                    ColorEntry(name: "Coral",
                               color: Color(red: 1.0, green: 0.498, blue: 0.314),
                               description: "Strong orange-pink coral color.",
                               rgbComponents: (1.0, 0.498, 0.314),
                               colorSpace: "sRGB"),
                    ColorEntry(name: "Dark Slate Gray",
                               color: Color(red: 0.184, green: 0.310, blue: 0.310),
                               description: "Dark slate gray tone.",
                               rgbComponents: (0.184, 0.310, 0.310),
                               colorSpace: "sRGB"),
                    ColorEntry(name: "Gold",
                               color: Color(red: 1.0, green: 0.843, blue: 0.0),
                               description: "Rich gold color.",
                               rgbComponents: (1.0, 0.843, 0.0),
                               colorSpace: "sRGB"),
                    ColorEntry(name: "Hot Pink",
                               color: Color(red: 1.0, green: 0.412, blue: 0.706),
                               description: "Bright hot pink.",
                               rgbComponents: (1.0, 0.412, 0.706),
                               colorSpace: "sRGB"),
                    ColorEntry(name: "Indigo",
                               color: Color(red: 0.294, green: 0.0, blue: 0.510),
                               description: "Deep indigo blue.",
                               rgbComponents: (0.294, 0.0, 0.510),
                               colorSpace: "sRGB"),
                    ColorEntry(name: "Khaki",
                               color: Color(red: 0.941, green: 0.902, blue: 0.549),
                               description: "Light khaki color.",
                               rgbComponents: (0.941, 0.902, 0.549),
                               colorSpace: "sRGB"),
                    ColorEntry(name: "Lavender",
                               color: Color(red: 0.902, green: 0.902, blue: 0.980),
                               description: "Soft lavender tone.",
                               rgbComponents: (0.902, 0.902, 0.980),
                               colorSpace: "sRGB"),
                    ColorEntry(name: "Olive",
                               color: Color(red: 0.502, green: 0.502, blue: 0.0),
                               description: "Dark olive green.",
                               rgbComponents: (0.502, 0.502, 0.0),
                               colorSpace: "sRGB"),
                    ColorEntry(name: "Tomato",
                               color: Color(red: 1.0, green: 0.388, blue: 0.278),
                               description: "Soft tomato red-orange.",
                               rgbComponents: (1.0, 0.388, 0.278),
                               colorSpace: "sRGB")
                ],
                description: "Popular named CSS/web colors supported in sRGB."
            )
        ]
    }
}

// MARK: - Views

struct ContentView: View {
    @StateObject private var viewModel = PaletteViewModel()
    @Environment(\.colorScheme) var systemColorScheme
    
    @State private var showingColorDetail: ColorEntry?
    @State private var simulateDarkMode: Bool = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 8) {
                
                Toggle(isOn: $simulateDarkMode) {
                    Text("Simulate Dark Mode")
                        .font(.headline)
                }
                .padding(.horizontal)
                .onChange(of: simulateDarkMode) {
                    // UIApplication.shared.windows.first?.overrideUserInterfaceStyle = simulateDarkMode ? .dark : .light
                    //.windows.first?.window?.overrideUserInterfaceStyle = simulateDarkMode ? .dark : .light
                }
                
                SearchBar(text: $viewModel.searchText)
                    .padding(.horizontal)
                
                Toggle(isOn: $viewModel.showFavoritesOnly) {
                    Label(viewModel.showFavoritesOnly ? "Showing Favorites Only" : "Show All Colors",
                          systemImage: viewModel.showFavoritesOnly ? "star.fill" : "star")
                }
                .padding(.horizontal)
                
                List {
                    ForEach(viewModel.filteredPalettes()) { palette in
                        Section {
                            ForEach(palette.colors) { colorEntry in
                                ColorRow(colorEntry: colorEntry)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        showingColorDetail = colorEntry
                                    }
                                    .swipeActions(edge: .trailing) {
                                        Button {
                                            viewModel.toggleFavorite(for: colorEntry)
                                        } label: {
                                            Label(colorEntry.isFavorite ? "Unfavorite" : "Favorite",
                                                  systemImage: colorEntry.isFavorite ? "star.fill" : "star")
                                        }
                                        .tint(colorEntry.isFavorite ? .yellow : .gray)
                                    }
                            }
                        } header: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(palette.title)
                                    .font(.headline)
                                if let desc = palette.description {
                                    Text(desc)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
                .navigationTitle("Color Palettes")
                .sheet(item: $showingColorDetail) { selectedColor in
                    ColorDetail(colorEntry: selectedColor)
                }
            }
        }
        .environment(\.colorScheme, simulateDarkMode ? .dark : .light)
    }
}

struct ColorRow: View {
    let colorEntry: ColorEntry
    
    var body: some View {
        HStack(spacing: 15) {
            RoundedRectangle(cornerRadius: 6)
                .fill(colorEntry.color)
                .frame(width: 44, height: 44)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.primary.opacity(0.1), lineWidth: 1)
                )
            VStack(alignment: .leading, spacing: 3) {
                Text(colorEntry.name)
                    .font(.body)
                    .foregroundColor(.primary)
                Text(colorEntry.colorSpace)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            if colorEntry.isFavorite {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
            }
        }.padding(.vertical, 6)
    }
}

struct ColorDetail: View {
    @Environment(\.dismiss) var dismiss
    let colorEntry: ColorEntry
    @State private var showCopiedAlert = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(colorEntry.color)
                    .frame(height: 150)
                    .shadow(radius: 6)
                    .padding(.horizontal)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.primary.opacity(0.1), lineWidth: 1)
                    )
                
                VStack(alignment: .leading, spacing: 12) {
                    Text(colorEntry.name)
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    if let desc = colorEntry.description {
                        Text(desc)
                            .font(.callout)
                            .foregroundColor(.secondary)
                    }
                    
                    Divider()
                    
                    HStack {
                        Label("Color Space", systemImage: "eyedropper")
                        Spacer()
                        Text(colorEntry.colorSpace)
                            .foregroundColor(.secondary)
                    }
                    
                    if let rgb = colorEntry.rgbComponents {
                        HStack {
                            Label("RGB", systemImage: "paintpalette")
                            Spacer()
                            Text("R: \(format(rgb.red))  G: \(format(rgb.green))  B: \(format(rgb.blue))")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    HStack {
                        Label("Hex Value", systemImage: "number")
                        Spacer()
                        Text(colorEntry.hexString)
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(.secondary)
                            .onTapGesture {
                                UIPasteboard.general.string = colorEntry.hexString
                                withAnimation { showCopiedAlert = true }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                                    withAnimation { showCopiedAlert = false }
                                }
                            }
                    }
                    Text("Tap hex value to copy")
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .italic()
                        .opacity(0.7)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("Color Detail")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close", action: { dismiss() })
                }
            }
            .alert(isPresented: $showCopiedAlert) {
                Alert(title: Text("Copied!"), message: Text("Hex value copied to clipboard."), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    private func format(_ val: Double) -> String {
        String(format: "%.2f", val)
    }
}

// MARK: - UIKit SearchBar Wrapper

struct SearchBar: UIViewRepresentable {
    @Binding var text: String

    class Coordinator: NSObject, UISearchBarDelegate {
        @Binding var text: String

        init(text: Binding<String>) {
            _text = text
        }

        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            text = searchText
        }
        func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
            searchBar.setShowsCancelButton(true, animated: true)
        }
        func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            searchBar.resignFirstResponder()
            searchBar.text = ""
            text = ""
            searchBar.setShowsCancelButton(false, animated: true)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }

    func makeUIView(context: Context) -> UISearchBar {
        let sb = UISearchBar(frame: .zero)
        sb.delegate = context.coordinator
        sb.searchBarStyle = .minimal
        sb.autocapitalizationType = .none
        sb.placeholder = "Search colors"
        return sb
    }
    func updateUIView(_ uiView: UISearchBar, context: Context) {
        uiView.text = text
    }
}

// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
                .preferredColorScheme(.light)
            ContentView()
                .preferredColorScheme(.dark)
        }
    }
}
