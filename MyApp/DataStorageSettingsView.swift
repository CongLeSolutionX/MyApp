//
//  DataStorageSettingsView.swift
//  MyApp
//
//  Created by Cong Le on 4/9/25.
//

import SwiftUI

// --- Helper Extensions (Should ideally be in a separate file like Color+Extensions.swift) ---

//extension Color {
//    // Define rhGold here if it's needed as a default/fallback in this file too
//     static let rhGold = Color(red: 0.7, green: 0.5, blue: 0.1) // A brownish gold
//}

// Extend Color to allow saving/loading from UserDefaults/AppStorage via Data
// NOTE: This uses Codable approach, simpler than secure coding for this context.
extension Color: Codable {
    enum CodingKeys: String, CodingKey {
        case red, green, blue, opacity
    }
    
    // Custom initializer to decode Color from saved data
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        // Decode RGBA components
        let r = try container.decode(Double.self, forKey: .red)
        let g = try container.decode(Double.self, forKey: .green)
        let b = try container.decode(Double.self, forKey: .blue)
        let o = try container.decode(Double.self, forKey: .opacity)
        // Initialize the Color object
        self.init(red: r, green: g, blue: b, opacity: o)
    }
    
    // Custom encoder to save Color components
    public func encode(to encoder: Encoder) throws {
        // Attempt to get CGColor representation
        guard let cgColor = self.cgColor else {
            // Handle failure: Option 1 - Throw an error
            struct EncodingError: Error {}
            throw EncodingError()
            // Handle failure: Option 2 - Encode a default color (e.g., black)
            // var container = encoder.container(keyedBy: CodingKeys.self)
            // try container.encode(0.0, forKey: .red); try container.encode(0.0, forKey: .green)
            // try container.encode(0.0, forKey: .blue); try container.encode(1.0, forKey: .opacity)
            // return
        }
        
        // Extract RGBA components from CGColor
        // Use components property, default to black if nil (shouldn't typically happen for standard colors)
        let components = cgColor.components ?? [0, 0, 0, 1]
        // Safely access components, handling different color spaces (like grayscale) simply
        let r = components[0]
        let g = components.count > 1 ? components[1] : r // Use red component if green isn't available
        let b = components.count > 2 ? components[2] : r // Use red component if blue isn't available
        let o = cgColor.alpha // Opacity is always the alpha component
        
        // Encode the extracted components
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(Double(r), forKey: .red)
        try container.encode(Double(g), forKey: .green)
        try container.encode(Double(b), forKey: .blue)
        try container.encode(Double(o), forKey: .opacity)
    }
    
    // Helper method to convert Color to Data using JSONEncoder
    func toData() -> Data {
        do {
            // Try encoding the Color object to JSON data
            // Return empty Data if encoding fails
            return try JSONEncoder().encode(self)
        } catch {
            // If encoding fails (throws an error), print the error and return empty Data.
            print("Error encoding Color to Data: \(error)") // Optional: Log the error for debugging
            return Data() // Return empty Data as the fallback
        }
    }
    
    // Failable initializer to create Color from Data using JSONDecoder
    init?(data: Data) {
        // Try decoding a Color object from JSON data
        guard let color = try? JSONDecoder().decode(Color.self, from: data) else {
            // Return nil if decoding fails
            return nil
        }
        // Assign the decoded color to self
        self = color
    }
}


struct DataStorageSettingsView: View {
    
    // --- Settings States (Using @AppStorage for persistence) ---
    @AppStorage("downloadOnlyOnWifi") private var downloadOnlyOnWifi: Bool = true
    @AppStorage("automaticDownloadsEnabled") private var automaticDownloadsEnabled: Bool = false // e.g., download new issues automatically
    
    // --- Mock Data States (Would be calculated in a real app) ---
    @State private var totalStorageUsedMB: Double = 345.6
    @State private var appSizeMB: Double = 85.2
    @State private var downloadsSizeMB: Double = 210.4
    @State private var cacheSizeMB: Double = 50.0
    @State private var isCalculatingCache: Bool = false
    @State private var showClearCacheAlert: Bool = false
    @State private var cacheClearedMessage: String? = nil // For user feedback
    
    // --- Accent Color (Read from previous settings for consistency) ---
    // Reading the previously saved accent color
    private var accentColor: Color {
        let data = UserDefaults.standard.data(forKey: "appAccentColor") ?? Color.rhGold.toData()
        return Color(data: data) ?? .rhGold
    }
    
    var body: some View {
        Form {
            // --- Storage Usage Overview ---
            Section(header: Text("Storage Usage"),
                    footer: Text("Estimated storage used by the app, downloaded content, and temporary cache files.")) {
                
                // Simulated Usage Breakdown
                HStack {
                    Text("Total Used")
                    Spacer()
                    Text("\(totalStorageUsedMB, specifier: "%.1f") MB")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Application Size")
                    Spacer()
                    Text("\(appSizeMB, specifier: "%.1f") MB")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Downloaded Content")
                    Spacer()
                    Text("\(downloadsSizeMB, specifier: "%.1f") MB")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Cache")
                    Spacer()
                    if isCalculatingCache {
                        ProgressView()
                            .scaleEffect(0.7) // Make spinner smaller
                            .progressViewStyle(CircularProgressViewStyle(tint: accentColor))
                    } else {
                        Text("\(cacheSizeMB, specifier: "%.1f") MB")
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // --- Cache Management ---
            Section(header: Text("Cache Management")) {
                Button(role: .destructive) {
                    showClearCacheAlert = true
                } label: {
                    HStack {
                        Text("Clear Cache")
                            .foregroundColor(.red) // Explicitly color destructive action text
                        
                        Spacer()
                        
                        // Provide feedback if cache was just cleared
                        if let message = cacheClearedMessage {
                            Text(message)
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                    }
                }
                .disabled(isCalculatingCache || cacheSizeMB <= 0) // Disable if calculating or cache is empty
                .alert("Clear Cache?", isPresented: $showClearCacheAlert) {
                    Button("Cancel", role: .cancel) { }
                    Button("Clear", role: .destructive) {
                        clearCache()
                    }
                } message: {
                    Text("This will remove temporary data used to speed up the app. It won't delete your account or downloaded content.")
                }
            }
            
            // --- Download Management ---
            Section(header: Text("Downloads"),
                    footer: Text("Manage content saved for offline access.")) {
                // Navigate to a hypothetical screen to manage individual downloads
                // In a real app, this NavigationLink would lead to a list view.
                NavigationLink {
                    // Placeholder View - Replace with actual download management screen
                    Text("Download Management Screen (Placeholder)")
                        .navigationTitle("Manage Downloads")
                } label: {
                    HStack {
                        Image(systemName: "arrow.down.circle")
                            .foregroundColor(accentColor) // Use accent color
                        Text("Manage Downloaded Content")
                        Spacer()
                        Text("\(downloadsSizeMB > 0 ? String(format: "%.1f MB", downloadsSizeMB) : "Empty")")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .foregroundColor(Color(uiColor: .label)) // Ensure text color adapts
                }
            }
            
            // --- Data Usage Settings ---
            Section(header: Text("Network Usage"),
                    footer: Text("Control how the app uses mobile data for downloads.")) {
                
                Toggle(isOn: $downloadOnlyOnWifi) {
                    Label("Download only on Wi-Fi", systemImage: "wifi")
                }
                .tint(accentColor)
                
                Toggle(isOn: $automaticDownloadsEnabled) {
                    Label("Enable Automatic Downloads", systemImage: "arrow.down.app")
                }
                .tint(accentColor)
                // Potentially show more options if automatic downloads are enabled
                // if automaticDownloadsEnabled { ... }
            }
            
        }
        .navigationTitle("Data & Storage")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: calculateStorage) // Recalculate on appear
    }
    
    // --- Helper Functions ---
    
    // Simulate calculating storage (fetch sizes from disk)
    private func calculateStorage() {
        isCalculatingCache = true
        cacheClearedMessage = nil // Reset message on recalculation
        // Simulate some delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
            // In a real app, you'd query the file system for cache and download directories
            // For now, we just ensure cache isn't negative and update total
            if cacheSizeMB < 0 { cacheSizeMB = 0 } // Ensure cache isn't negative after clearing
            totalStorageUsedMB = appSizeMB + downloadsSizeMB + cacheSizeMB
            isCalculatingCache = false
            print("Storage recalculated.")
        }
    }
    
    // Simulate clearing the cache
    private func clearCache() {
        print("Attempting to clear cache...")
        isCalculatingCache = true
        // Simulate cache clearing delay/process
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            cacheSizeMB = 0 // Reset mock cache size
            totalStorageUsedMB = appSizeMB + downloadsSizeMB + cacheSizeMB // Update total
            isCalculatingCache = false
            cacheClearedMessage = "Cache Cleared" // Provide feedback
            print("Cache cleared (simulated).")
            
            // Optionally hide the success message after a few seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                cacheClearedMessage = nil
            }
        }
    }
}

// --- Previews ---
struct DataStorageSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        // Reset relevant @AppStorage keys for predictable previews
        // UserDefaults.standard.removeObject(forKey: "downloadOnlyOnWifi")
        // UserDefaults.standard.removeObject(forKey: "automaticDownloadsEnabled")
        
        Group {
            NavigationView {
                DataStorageSettingsView()
            }
            .previewDisplayName("Default State")
            
            NavigationView {
                DataStorageSettingsView()
                // Simulate state where cache is being cleared
                    .onAppear {
                        // Cannot directly modify @State from here easily for preview,
                        // but we can show a state with 0 cache as if just cleared.
                        // For more complex state simulation, consider preview-specific initializers or dedicated Preview Providers.
                    }
            }
            .previewDisplayName("Cache Cleared (Simulated)")
            // Injecting some mock data conceptually for preview
            // This is harder with @State tied to calculations.
            
            NavigationView {
                DataStorageSettingsView()
                    .environment(\.colorScheme, .dark) // Test dark mode
            }
            .previewDisplayName("Dark Mode")
            
        }
    }
}

// --- Color Extension (from previous step, assuming it's available) ---
// If not already defined globally:
/*
 extension Color {
 static let rhGold = Color(red: 0.7, green: 0.5, blue: 0.1)
 
 // toData() and init?(data: Data) methods needed here if not global
 // Add Codable conformance as defined in AppearanceSettingsView
 }
 
 extension Color: Codable { ... }
 */
