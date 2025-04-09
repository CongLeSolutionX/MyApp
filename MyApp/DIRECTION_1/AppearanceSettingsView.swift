////
////  AppearanceSettingsView.swift
////  MyApp
////
////  Created by Cong Le on 4/9/25.
////
//
//import SwiftUI
//
//// Enum to represent theme options clearly
//enum AppTheme: String, CaseIterable, Identifiable {
//    case system = "System Default"
//    case light = "Light"
//    case dark = "Dark"
//    
//    var id: String { self.rawValue }
//    
//    // Helper to convert enum to ColorScheme (optional, used for applying theme)
//    var colorScheme: ColorScheme? {
//        switch self {
//        case .light:
//            return .light
//        case .dark:
//            return .dark
//        case .system:
//            return nil // nil means follow system
//        }
//    }
//}
//
//struct AppearanceSettingsView: View {
//    
//    // --- Persisted Settings ---
//    // Using @AppStorage for easy local persistence in this example
//    // Keys should be constants in a real app
//    @AppStorage("appTheme") private var selectedTheme: AppTheme = .system
//    @AppStorage("appAccentColor") private var accentColorData: Data = Color.rhGold.toData() // Store as Data
//    @AppStorage("appTextScale") private var textScale: Double = 1.0 // 1.0 = default
//    
//    // --- Local State for Color Picker ---
//    // Needs a Color state variable to bind to ColorPicker
//    @State private var chosenAccentColor: Color
//    
//    // --- Initializer ---
//    // Initialize the @State variable from the @AppStorage Data
//    init() {
//        // Decode the stored color, default to rhGold if decoding fails
//        let decodedColor = Color(data: UserDefaults.standard.data(forKey: "appAccentColor") ?? Color.rhGold.toData()) ?? Color.rhGold
//        _chosenAccentColor = State(initialValue: decodedColor)
//    }
//    
//    var body: some View {
//        Form {
//            // --- Theme Selection ---
//            Section(header: Text("Theme"),
//                    footer: Text("Choose how the app looks. 'System Default' matches your device settings.")) {
//                Picker("Appearance", selection: $selectedTheme) {
//                    ForEach(AppTheme.allCases) { theme in
//                        Text(theme.rawValue).tag(theme)
//                    }
//                }
//                // Optional: Apply changes immediately to the window scene
//                // .onChange(of: selectedTheme) { newTheme in
//                //     applyTheme(newTheme)
//                // }
//            }
//            
//            // --- Accent Color ---
//            Section(header: Text("Accent Color"),
//                    footer: Text("Select a color used for buttons and highlights.")) {
//                ColorPicker("Primary Accent", selection: $chosenAccentColor, supportsOpacity: false)
//                    .onChange(of: chosenAccentColor) {
//                        // Save the chosen color back to @AppStorage as Data
//                        accentColorData = chosenAccentColor.toData()
//                        print("Accent Color changed and saved.")
//                        // In a real app, trigger UI update via EnvironmentObject or similar
//                    }
//            }
//            
//            // --- Text Size ---
//            Section(header: Text("Text Size"),
//                    footer: Text("Adjust the size of text within the app. Relies on system Dynamic Type settings.")) {
//                
//                // Option 1: Slider for custom scaling (less ideal for accessibility)
//                VStack(alignment: .leading) {
//                    Text("App Text Scale: \(textScale, specifier: "%.1fx")")
//                        .font(.subheadline)
//                    Slider(value: $textScale, in: 0.8...1.5, step: 0.1) {
//                        Text("Text Scale Slider") // Accessibility label
//                    } minimumValueLabel: {
//                        Image(systemName: "textformat.size.smaller")
//                    } maximumValueLabel: {
//                        Image(systemName: "textformat.size.larger")
//                    }
//                    .tint(Color(data: accentColorData) ?? .rhGold)
//                    .onChange(of: textScale) {
//                        print("Text Scale changed: \(textScale)")
//                        // Need EnvironmentObject or similar to apply globally
//                    }
//                    Text("Note: For best results, adjust text size in your device's Accessibility settings.")
//                        .font(.caption2)
//                        .foregroundColor(.gray)
//                }
//                
//                // Option 2: Link to System Settings (Better for Accessibility)
//                Button {
//                    openAccessibilitySettings()
//                } label: {
//                    HStack {
//                        Image(systemName: "textformat.size")
//                            .foregroundColor(Color(data: accentColorData) ?? .rhGold)
//                        Text("Open Accessibility Settings")
//                        Spacer()
//                        Image(systemName: "arrow.up.right.square")
//                            .font(.caption)
//                            .foregroundColor(.gray)
//                    }
//                    .foregroundColor(Color(uiColor: .label))
//                }
//            }
//            
//            // --- Accessibility Quick Links ---
//            Section(header: Text("Accessibility Enhancements")) {
//                Button("Open Display & Text Size Settings") {
//                    openAccessibilitySettings(path: "DISPLAY_AND_TEXT") // Specific path if known
//                }
//                .foregroundColor(Color(uiColor: .label))
//                
//                Button("Open Motion Settings") {
//                    openAccessibilitySettings(path: "MOTION") // Specific path
//                }
//                .foregroundColor(Color(uiColor: .label))
//            }
//            
//        }
//        .navigationTitle("Appearance")
//        .navigationBarTitleDisplayMode(.inline)
//        // Apply the accent color from storage to this view
//        .tint(Color(data: accentColorData) ?? .rhGold)
//        // Attempt to apply the theme to this view's preview
//        .preferredColorScheme(selectedTheme.colorScheme)
//        .onAppear {
//            // Ensure the @State color picker variable matches @AppStorage on appear
//            chosenAccentColor = Color(data: accentColorData) ?? .rhGold
//            print("AppearanceSettingsView appeared. Theme: \(selectedTheme.rawValue), Accent: \(chosenAccentColor), TextScale: \(textScale)")
//        }
//    }
//    
//    // --- Helper Functions ---
//    
//    // Function to attempt opening specific accessibility settings paths
//    // Note: Exact URL paths can change between iOS versions and might not be officially supported.
//    // Using the general settings URL is more robust.
//    private func openAccessibilitySettings(path: String? = nil) {
//        // Base URL for general settings app opening
//        var urlString = UIApplication.openSettingsURLString // "app-settings:"
//        
//        // More specific, but less reliable paths:
//        // For testing, you might try URLs like:
//        // "App-Prefs:root=ACCESSIBILITY&path=DISPLAY_AND_TEXT"
//        // "App-Prefs:root=ACCESSIBILITY&path=MOTION"
//        // HOWEVER, these are not guaranteed APIs. The safest is the main settings URL.
//        
//        // For this example, we'll stick to the reliable general settings link.
//        // If you *need* deeper links, extensive testing across iOS versions is required.
//        print("Attempting to open Settings. Path hint: \(path ?? "General")")
//        if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
//            UIApplication.shared.open(url)
//        } else {
//            print("Could not open Settings URL.")
//        }
//    }
//    
//    // Example function placeholder for applying theme globally
//    // In a real app, this would modify the window scene's preferredColorScheme
//    // private func applyTheme(_ theme: AppTheme) {
//    //     guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
//    //     windowScene.windows.forEach { window in
//    //         window.overrideUserInterfaceStyle = theme.userInterfaceStyle
//    //     }
//    //    print("Theme applied: \(theme.rawValue)")
//    // }
//}
//
//// --- Helper Extensions (Should be in a separate file) ---
//
//// Extend Color to allow saving/loading from UserDefaults/AppStorage via Data
//// NOTE: This uses Codable approach, simpler than secure coding for this context.
//extension Color: Codable {
//    enum CodingKeys: String, CodingKey {
//        case red, green, blue, opacity
//    }
//    
//    public init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        let r = try container.decode(Double.self, forKey: .red)
//        let g = try container.decode(Double.self, forKey: .green)
//        let b = try container.decode(Double.self, forKey: .blue)
//        let o = try container.decode(Double.self, forKey: .opacity)
//        self.init(red: r, green: g, blue: b, opacity: o)
//    }
//    
//    public func encode(to encoder: Encoder) throws {
//        guard let cgColor = self.cgColor else {
//            // Handle cases where CGColor conversion fails (e.g., invalid color)
//            // Option 1: Throw an error
//            struct EncodingError: Error {}
//            throw EncodingError()
//            // Option 2: Encode default values (e.g., black)
//            // var container = encoder.container(keyedBy: CodingKeys.self)
//            // try container.encode(0.0, forKey: .red)
//            // try container.encode(0.0, forKey: .green)
//            // try container.encode(0.0, forKey: .blue)
//            // try container.encode(1.0, forKey: .opacity)
//            // return
//        }
//        
//        let components = cgColor.components ?? [0, 0, 0, 1] // Default to black if components are nil
//        let r = components[0]
//        let g = components.count > 1 ? components[1] : r // Handle grayscale or other color spaces simply
//        let b = components.count > 2 ? components[2] : r
//        let o = cgColor.alpha
//        
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(Double(r), forKey: .red)
//        try container.encode(Double(g), forKey: .green)
//        try container.encode(Double(b), forKey: .blue)
//        try container.encode(Double(o), forKey: .opacity)
//    }
//    
//    
//    // Helper to convert Color to Data
//    func toData() -> Data {
//        do {
//            // Attempt to encode. If successful, return the data.
//            return try JSONEncoder().encode(self)
//        } catch {
//            // If encoding fails (throws an error), print the error and return empty Data.
//            print("Error encoding Color to Data: \(error)") // Optional: Log the error for debugging
//            return Data() // Return empty Data as the fallback
//        }
//    }
//    
//    // Helper to initialize Color from Data
//    init?(data: Data) {
//        guard let color = try? JSONDecoder().decode(Color.self, from: data) else {
//            return nil
//        }
//        self = color
//    }
//}
//
//// --- Optional: UIUserInterfaceStyle mapping for theme application ---
//extension AppTheme {
//    var userInterfaceStyle: UIUserInterfaceStyle {
//        switch self {
//        case .light: return .light
//        case .dark: return .dark
//        case .system: return .unspecified
//        }
//    }
//}
//
//// --- Dummy Color placeholder ---
////extension Color {
////     static let rhGold = Color(red: 0.7, green: 0.5, blue: 0.1) // A brownish gold
//// }
//
//// --- Previews ---
//struct AppearanceSettingsView_Previews: PreviewProvider {
//    static var previews: some View {
//        // Clean up AppStorage before previews if needed
//        // UserDefaults.standard.removeObject(forKey: "appTheme")
//        // UserDefaults.standard.removeObject(forKey: "appAccentColor")
//        // UserDefaults.standard.removeObject(forKey: "appTextScale")
//        
//        Group {
//            NavigationView {
//                AppearanceSettingsView()
//            }
//            .previewDisplayName("Light Mode (System Default)")
//            .preferredColorScheme(.light) // Simulate system being light
//            
//            NavigationView {
//                AppearanceSettingsView()
//                // Simulate user choosing Dark theme override
//                    .onAppear { UserDefaults.standard.set(AppTheme.dark.rawValue, forKey: "appTheme") }
//            }
//            .previewDisplayName("Dark Mode (User Override)")
//            .preferredColorScheme(.dark) // Simulate system being dark (or light, doesn't matter for override)
//            
//            NavigationView {
//                AppearanceSettingsView()
//                // Simulate user choosing a different accent color
//                    .onAppear {
//                        UserDefaults.standard.set(Color.blue.toData(), forKey: "appAccentColor")
//                        UserDefaults.standard.set(AppTheme.light.rawValue, forKey: "appTheme") // Set light for clarity
//                    }
//            }
//            .previewDisplayName("Light Mode - Blue Accent")
//            .preferredColorScheme(.light)
//        }
//        
//    }
//}
