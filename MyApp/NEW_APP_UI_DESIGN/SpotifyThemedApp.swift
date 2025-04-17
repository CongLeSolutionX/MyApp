//
//  SpotifyThemedApp.swift
//  MyApp
//
//  Created by Cong Le on 4/17/25.
//

import SwiftUI
@preconcurrency import WebKit // Needed for WebView
import Foundation
import Combine // Needed for ThemeManager @Published etc.

// MARK: - Theme System Definition

// Enum to represent available themes
enum AppTheme: String, CaseIterable, Identifiable {
    case retro = "Retro Future"
    case vaporwave = "Vaporwave Sunset"
    case cyberpunkNight = "Cyberpunk Night"
    case system = "System Default"
    case light = "Classic Light"
    case dark = "Classic Dark"

    var id: String { self.rawValue }
}

// Struct to hold the settings for a specific theme
struct ThemeSettings: Equatable { // Conforming to Equatable for animation checks
    let name: String
    let colorScheme: ColorScheme? // nil for system-adaptive, .light or .dark otherwise
    let primaryBackgroundColor: Color
    let secondaryBackgroundColor: Color // For gradients or sections
    let cardGradient: AnyGradient // Flexible card backgrounds
    let cardStrokeColor: Color
    let primaryTextColor: Color
    let secondaryTextColor: Color
    let accentColor1: Color // Main interactive elements
    let accentColor2: Color // Secondary highlights (e.g., artist names)
    let errorColor: Color
    let successColor: Color
    let glowColor: Color? // Optional glow effect color
    let glowRadius: CGFloat
    let fontDesign: Font.Design // e.g., .monospaced, .default, .serif
    let baseFontSize: CGFloat

    // Equatable conformance
    static func == (lhs: ThemeSettings, rhs: ThemeSettings) -> Bool {
        return lhs.name == rhs.name // Compare by name for simplicity
    }
}

// MARK: - Theme Definitions

extension ThemeSettings {
    static let retroFuture = ThemeSettings(
        name: "Retro Future",
        colorScheme: .dark,
        primaryBackgroundColor: Color(red: 0.15, green: 0.05, blue: 0.25), // retroDeepPurple
        secondaryBackgroundColor: Color(red: 0.25, green: 0.12, blue: 0.4),
        cardGradient: AnyGradient(LinearGradient(
            colors: [
                Color(red: 0.25, green: 0.12, blue: 0.4).opacity(0.8), // Darker card
                Color(red: 0.55, green: 0.19, blue: 0.66).opacity(0.7)
            ],
            startPoint: .topLeading, endPoint: .bottomTrailing
        )),
        cardStrokeColor: Color(red: 0.1, green: 0.9, blue: 0.9).opacity(0.7), // retroNeonCyan
        primaryTextColor: .white,
        secondaryTextColor: .white.opacity(0.8),
        accentColor1: Color(red: 1.0, green: 0.1, blue: 0.5), // retroNeonPink
        accentColor2: Color(red: 0.7, green: 1.0, blue: 0.3), // retroNeonLime
        errorColor: Color(red: 1.0, green: 0.1, blue: 0.5), // retroNeonPink
        successColor: Color(red: 0.1, green: 0.9, blue: 0.9), // retroNeonCyan
        glowColor: Color(red: 0.1, green: 0.9, blue: 0.9), // retroNeonCyan
        glowRadius: 10,
        fontDesign: .monospaced,
        baseFontSize: 14
    )

    static let vaporwaveSunset = ThemeSettings(
        name: "Vaporwave Sunset",
        colorScheme: .dark,
        primaryBackgroundColor: Color(hex: "#0d0221"), // Very dark purple
        secondaryBackgroundColor: Color(hex: "#261447"),
        cardGradient: AnyGradient(LinearGradient(
            colors: [Color(hex: "#ff6ad5").opacity(0.7), Color(hex: "#fdc23e").opacity(0.6)], // Pink to Gold
            startPoint: .topLeading, endPoint: .bottomTrailing
        )),
        cardStrokeColor: Color(hex: "#05d9e8").opacity(0.6), // Cyan
        primaryTextColor: .white,
        secondaryTextColor: .white.opacity(0.85),
        accentColor1: Color(hex: "#05d9e8"), // Cyan
        accentColor2: Color(hex: "#fec8d8"), // Light Pink
        errorColor: Color(hex: "#ff6b6b"), // Coral Red
        successColor: Color(hex: "#4cffb0"), // Mint Green
        glowColor: Color(hex: "#ff6ad5"), // Pink glow
        glowRadius: 12,
        fontDesign: .rounded, // Softer font
        baseFontSize: 14.5
    )

    static let cyberpunkNight = ThemeSettings(
        name: "Cyberpunk Night",
        colorScheme: .dark,
        primaryBackgroundColor: Color(hex: "#0a0f2c"), // Very dark blue/black
        secondaryBackgroundColor: Color(hex: "#14183d"),
        cardGradient: AnyGradient(LinearGradient(colors: [Color.black.opacity(0.6), Color(hex:"#14183d").opacity(0.5)], startPoint: .top, endPoint: .bottom)), // Dark semi-transparent cards
        cardStrokeColor: Color(hex: "#00ff00").opacity(0.7), // Bright Green
        primaryTextColor: Color(hex: "#E0E0E0"), // Off-white
        secondaryTextColor: Color(hex: "#A0A0A0"), // Grey
        accentColor1: Color(hex: "#00ff00"), // Bright Green
        accentColor2: Color(hex: "#ff00ff"), // Magenta
        errorColor: Color(hex: "#ff4444"), // Bright Red
        successColor: Color(hex: "#33ffdd"), // Electric Blue/Cyan
        glowColor: Color(hex: "#00ff00"), // Green glow
        glowRadius: 8,
        fontDesign: .monospaced, // Tech font
        baseFontSize: 13.5
    )

    static let system = ThemeSettings(
        name: "System Default",
        colorScheme: nil, // Adapts to system
        primaryBackgroundColor: Color(.systemBackground),
        secondaryBackgroundColor: Color(.secondarySystemBackground),
        cardGradient: AnyGradient(Color(.tertiarySystemBackground)), // Card background adapts
        cardStrokeColor: Color(.separator), // Subtle border
        primaryTextColor: Color(.label),
        secondaryTextColor: Color(.secondaryLabel),
        accentColor1: .accentColor, // Use the app's main accent color
        accentColor2: Color(.systemTeal),
        errorColor: .red,
        successColor: .green,
        glowColor: nil, // No glow for system theme
        glowRadius: 0,
        fontDesign: .default,
        baseFontSize: 14
    )

    static let light = ThemeSettings(
        name: "Classic Light",
        colorScheme: .light,
        primaryBackgroundColor: Color(.systemGray6),
        secondaryBackgroundColor: .white,
        cardGradient: AnyGradient(.white), // Solid white cards
        cardStrokeColor: Color(.systemGray4),
        primaryTextColor: .black,
        secondaryTextColor: Color(.darkGray),
        accentColor1: .blue,
        accentColor2: .purple,
        errorColor: .red,
        successColor: .green,
        glowColor: nil,
        glowRadius: 0,
        fontDesign: .default,
        baseFontSize: 14
    )

    static let dark = ThemeSettings(
        name: "Classic Dark",
        colorScheme: .dark,
        primaryBackgroundColor: .black,
        secondaryBackgroundColor: Color(uiColor: .systemGray6), // Use the dark version of gray 6
        cardGradient: AnyGradient(Color(.secondarySystemBackground)), // Dark cards
        cardStrokeColor: Color(.systemGray3),
        primaryTextColor: .white,
        secondaryTextColor: Color(.lightGray),
        accentColor1: .cyan, // Brighter accent for dark mode
        accentColor2: .orange,
        errorColor: .red,
        successColor: .green.opacity(0.8), // Slightly less bright green
        glowColor: nil,
        glowRadius: 0,
        fontDesign: .default,
        baseFontSize: 14
    )
}

// Helper for hex colors (optional but convenient)
extension Color {
    // Ensure hex initializer is available
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0) // Default to black
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}

// Gradient helper (Make sure it's Equatable)
struct AnyGradient: ShapeStyle, Equatable {
    private let gradientIdentifier: String // Use a string identifier for Equatable
    private let gradientResolver: (EnvironmentValues) -> AnyShapeStyle

    init<S: ShapeStyle>(_ gradient: S) where S.Resolved == AnyShapeStyle, S: Hashable {
        // Use Hashable conformance to generate a somewhat unique identifier
        self.gradientIdentifier = String(describing: gradient.hashValue)
        self.gradientResolver = { _ in AnyShapeStyle(gradient) } // Simple capture
    }

    // Special handling for Color and standard gradients
    init(_ color: Color) {
        self.gradientIdentifier = "Color:\(color.hashValue)"
        self.gradientResolver = { _ in AnyShapeStyle(color) }
    }
     init (_ linearGradient: LinearGradient) {
         self.gradientIdentifier = "Linear:\(linearGradient.gradient.stops.map { "\($0.color.hashValue)@\($0.location)" }.joined())"
         self.gradientResolver = { _ in AnyShapeStyle(linearGradient)}
     }
     // Add similar initializers for RadialGradient, AngularGradient if needed

    func resolve(in environment: EnvironmentValues) -> AnyShapeStyle {
        gradientResolver(environment)
    }

    static func == (lhs: AnyGradient, rhs: AnyGradient) -> Bool {
        lhs.gradientIdentifier == rhs.gradientIdentifier
    }
}

// MARK: - Theme Manager

class ThemeManager: ObservableObject {
    @Published var selectedTheme: AppTheme {
        didSet {
            saveTheme(theme: selectedTheme)
            // Manually update currentTheme when selectedTheme changes
            self.currentTheme = themeSettings(for: selectedTheme)
        }
    }
    @Published var currentTheme: ThemeSettings

    private let userDefaultsKey = "selectedAppTheme"

    init() {
        // Load initial theme and set both properties
        let initialTheme = ThemeManager.loadInitialTheme()
        self.selectedTheme = initialTheme
        self.currentTheme = ThemeManager.themeSettings(for: initialTheme)
    }

    func changeTheme(to newTheme: AppTheme) {
        selectedTheme = newTheme // This will trigger didSet and update currentTheme
    }

    // Make load static so it can be used in init
    private static func loadInitialTheme() -> AppTheme {
        if let savedThemeRawValue = UserDefaults.standard.string(forKey: "selectedAppTheme"),
           let savedTheme = AppTheme(rawValue: savedThemeRawValue) {
            return savedTheme
        } else {
            // Default to system if nothing is saved
            return .system
        }
    }

    private func saveTheme(theme: AppTheme) {
        UserDefaults.standard.set(theme.rawValue, forKey: userDefaultsKey)
        print("Saved theme: \(theme.rawValue)")
    }

    // Maps the enum to the specific ThemeSettings struct (make static too if needed)
    static func themeSettings(for appTheme: AppTheme) -> ThemeSettings {
        switch appTheme {
        case .retro: return .retroFuture
        case .vaporwave: return .vaporwaveSunset
        case .cyberpunkNight: return .cyberpunkNight
        case .system: return .system
        case .light: return .light
        case .dark: return .dark
        }
    }

     // Instance method that uses the static one
     func themeSettings(for appTheme: AppTheme) -> ThemeSettings {
         return ThemeManager.themeSettings(for: appTheme)
     }
}

// MARK: - Theme Selection View

struct ThemeSelectionView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) var dismiss // To close the sheet

    var body: some View {
        let currentUITheme = themeManager.currentTheme // Use current theme for UI elements inside the sheet

        NavigationView {
            List {
                Section("Select App Theme") {
                    ForEach(AppTheme.allCases) { themeType in
                        Button {
                            themeManager.changeTheme(to: themeType)
                            // Dismissal logic might be needed depending on UX preference
                             DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                  dismiss() // Close sheet after selection
                             }
                        } label: {
                            HStack {
                                Text(themeType.rawValue)
                                     .foregroundColor(currentUITheme.primaryTextColor) // Text color from current visual theme
                                Spacer()
                                if themeManager.selectedTheme == themeType {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(currentUITheme.accentColor1) // Checkmark color from current visual theme
                                }
                            }
                             .contentShape(Rectangle()) // Make entire row tappable
                        }
                         .buttonStyle(.plain) // Ensure button style doesn't interfere
                         .listRowBackground(currentUITheme.secondaryBackgroundColor) // Themed list Row
                    }
                }
                 .listRowSeparatorTint(currentUITheme.cardStrokeColor.opacity(0.5)) // Themed separator
            }
            .navigationTitle("Theme Settings")
            .navigationBarTitleDisplayMode(.inline)
             .toolbar {
                 ToolbarItem(placement: .navigationBarTrailing) {
                     Button("Done") { dismiss() }
                         .foregroundColor(currentUITheme.accentColor1)
                 }
             }
              // Theme the list background itself
             .scrollContentBackground(.hidden)
             .background(currentUITheme.primaryBackgroundColor.ignoresSafeArea())
              .toolbarBackground(currentUITheme.secondaryBackgroundColor.opacity(0.8), for: .navigationBar)
              .toolbarBackground(.visible, for: .navigationBar)
              .toolbarColorScheme(currentUITheme.colorScheme ?? .dark, for: .navigationBar)
        }
          // Ensure sheet content also gets the theme manager
          .environmentObject(themeManager)
          // Use the theme's preferred color scheme for the sheet's own rendering
           .preferredColorScheme(currentUITheme.colorScheme)
           .tint(currentUITheme.accentColor1) // Apply tint to navigation buttons etc.

    }
}

// MARK: - Helper Theme Modifiers

extension View {
    // Apply themed glow effect
    func themedGlow(theme: ThemeSettings) -> some View {
        if let glowColor = theme.glowColor, theme.glowRadius > 0 {
            // Use multiple shadows for a better glow
            return self.shadow(color: glowColor.opacity(0.6), radius: theme.glowRadius / 2)
                       .shadow(color: glowColor.opacity(0.4), radius: theme.glowRadius)
                       .shadow(color: glowColor.opacity(0.2), radius: theme.glowRadius * 1.5)
        } else {
            // Return self directly without wrapping in AnyView
            return self
        }
    }

    // Apply themed font
    func themedFont(_ style: Font.TextStyle = .body, weight: Font.Weight = .regular, theme: ThemeSettings) -> some View {
        // Use a more robust way to calculate size based on style or keep it simple
        let size: CGFloat
        switch style {
            case .largeTitle: size = theme.baseFontSize * 2.2
            case .title: size = theme.baseFontSize * 1.8
            case .title2: size = theme.baseFontSize * 1.5
            case .title3: size = theme.baseFontSize * 1.3
            case .headline: size = theme.baseFontSize * 1.15
            case .body: size = theme.baseFontSize
            case .callout: size = theme.baseFontSize * 0.95
            case .subheadline: size = theme.baseFontSize * 0.9
            case .footnote: size = theme.baseFontSize * 0.85
            case .caption: size = theme.baseFontSize * 0.8
            case .caption2: size = theme.baseFontSize * 0.75
            default: size = theme.baseFontSize
        }
        return self.font(Font.system(size: size, weight: weight, design: theme.fontDesign))
    }

    // Apply themed primary background
     func themedBackground(theme: ThemeSettings) -> some View {
        self.background(theme.primaryBackgroundColor.ignoresSafeArea())
    }

    // Common themed card styling
    func themedCardStyle(theme: ThemeSettings) -> some View {
        self.background(theme.cardGradient)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous)) // Slightly smaller radius
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(theme.cardStrokeColor, lineWidth: 1)
            )
             .themedGlow(theme: theme) // Apply themed glow if present
    }

    // Conditional Modifiers (Keep these)
     @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
         if condition {
             transform(self)
         } else {
             self
         }
     }

     @ViewBuilder func `if`<TrueContent: View, FalseContent: View>(
         _ condition: Bool,
         @ViewBuilder then trueTransform: (Self) -> TrueContent,
         @ViewBuilder else falseTransform: (Self) -> FalseContent
     ) -> some View {
          if condition {
              trueTransform(self)
          } else {
               falseTransform(self)
          }
     }
}

// MARK: - Data Models (Unchanged)

struct SpotifySearchResponse: Codable, Hashable {
    let albums: Albums
}
struct Albums: Codable, Hashable {
    let href: String
    let limit: Int
    let next: String?
    let offset: Int
    let previous: String?
    let total: Int
    let items: [AlbumItem]
}
struct AlbumItem: Codable, Identifiable, Hashable {
    let id: String
    let album_type: String
    let total_tracks: Int
    let available_markets: [String]?
    let external_urls: ExternalUrls
    let href: String
    let images: [SpotifyImage]
    let name: String
    let release_date: String
    let release_date_precision: String
    let type: String // "album"
    let uri: String
    let artists: [Artist]

    // --- Helper computed properties ---
    var bestImageURL: URL? {
        images.first { $0.width == 640 }?.urlObject ??
        images.first { $0.width == 300 }?.urlObject ??
        images.first?.urlObject
    }
    var listImageURL: URL? {
        // Prioritize smaller image for lists
        images.first { $0.width == 300 }?.urlObject ??
        images.first { $0.width == 64 }?.urlObject ??
        bestImageURL // Fallback to best if others missing
    }
    var formattedArtists: String {
        artists.map { $0.name }.joined(separator: ", ")
    }
    func formattedReleaseDate() -> String {
        let dateFormatter = DateFormatter()
        var displayFormat = ""

        switch release_date_precision {
        case "year":
            dateFormatter.dateFormat = "yyyy"
            displayFormat = "yyyy"
        case "month":
            dateFormatter.dateFormat = "yyyy-MM"
            displayFormat = "MMM yyyy" // e.g., Aug 1959
        case "day":
            dateFormatter.dateFormat = "yyyy-MM-dd"
            displayFormat = "d MMM yyyy" // e.g., 17 Aug 1959
        default:
            return release_date // Fallback if precision is unknown
        }

        if let date = dateFormatter.date(from: release_date) {
            // Now format using the desired display format
            dateFormatter.dateFormat = displayFormat
            return dateFormatter.string(from: date)
        }

        return release_date // Fallback if date parsing fails
    }
    // Equatable based on ID
    static func == (lhs: AlbumItem, rhs: AlbumItem) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}
struct Artist: Codable, Identifiable, Hashable {
    let id: String
    let external_urls: ExternalUrls? // Make optional if sometimes missing
    let href: String
    let name: String
    let type: String // "artist"
    let uri: String
    // Equatable based on ID
    static func == (lhs: Artist, rhs: Artist) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}
struct SpotifyImage: Codable, Hashable {
    let height: Int?
    let url: String
    let width: Int?
    var urlObject: URL? { URL(string: url) }
    // Simple hash for basic comparison
     func hash(into hasher: inout Hasher) { hasher.combine(url) }
}
struct ExternalUrls: Codable, Hashable {
    let spotify: String? // Make optional if sometimes missing
     // Simple hash for basic comparison
      func hash(into hasher: inout Hasher) { hasher.combine(spotify) }
}
struct AlbumTracksResponse: Codable, Hashable {
    let items: [Track]
    // Add other fields like href, limit, next, offset, previous, total if needed
     // Simple hash for basic comparison
      func hash(into hasher: inout Hasher) { hasher.combine(items) }
}
struct Track: Codable, Identifiable, Hashable {
    let id: String
    let artists: [Artist]
    let disc_number: Int
    let duration_ms: Int
    let explicit: Bool
    let external_urls: ExternalUrls?
    let href: String
    let name: String
    let preview_url: String? // Can be null
    let track_number: Int
    let type: String // "track"
    let uri: String

    var formattedDuration: String {
        let totalSeconds = duration_ms / 1000
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    var formattedArtists: String {
        artists.map { $0.name }.joined(separator: ", ")
    }
    // Equatable based on ID
    static func == (lhs: Track, rhs: Track) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

// MARK: - API Service (Unchanged - Still uses placeholder token)

// IMPORTANT: Replace this with your actual Spotify Bearer Token
let placeholderSpotifyToken = "YOUR_SPOTIFY_BEARER_TOKEN_HERE" // <<<--- SET YOUR TOKEN HERE

enum SpotifyAPIError: Error, LocalizedError, Equatable {
    case invalidURL
    case networkError(String) // Store error description for Equatable
    case invalidResponse(Int, String?)
    case decodingError(String) // Store error description for Equatable
    case invalidToken
    case missingData

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid API URL."
        case .networkError(let desc): return "Network error: \(desc)"
        case .invalidResponse(let code, _): return "Invalid server response (\(code)). Check API or network."
        case .decodingError(let desc): return "Failed to decode response: \(desc)"
        case .invalidToken: return "Invalid or expired Spotify token."
        case .missingData: return "Missing expected data in API response."
        }
    }

    // Equatable Conformance
    static func == (lhs: SpotifyAPIError, rhs: SpotifyAPIError) -> Bool {
         switch (lhs, rhs) {
         case (.invalidURL, .invalidURL): return true
         case (.networkError(let lDesc), .networkError(let rDesc)): return lDesc == rDesc
         case (.invalidResponse(let lCode, let lMsg), .invalidResponse(let rCode, let rMsg)): return lCode == rCode && lMsg == rMsg
         case (.decodingError(let lDesc), .decodingError(let rDesc)): return lDesc == rDesc
         case (.invalidToken, .invalidToken): return true
         case (.missingData, .missingData): return true
         default: return false
         }
     }
}

struct SpotifyAPIService {
    static let shared = SpotifyAPIService()
    private let session: URLSession

    init() {
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        configuration.timeoutIntervalForRequest = 30 // Slightly longer timeout
        session = URLSession(configuration: configuration)
    }

    private func makeRequest<T: Decodable>(url: URL) async throws -> T {
        guard !placeholderSpotifyToken.isEmpty, placeholderSpotifyToken != "YOUR_SPOTIFY_BEARER_TOKEN_HERE" else {
            print("❌ API Error: Spotify Bearer Token is missing or placeholder.")
            throw SpotifyAPIError.invalidToken
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(placeholderSpotifyToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 20

        // print("🚀 Making API Request to: \(url.absoluteString)") // DEBUG

        do {
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else { throw SpotifyAPIError.invalidResponse(0, "Not HTTP response.") }

            // print("🚦 HTTP Status: \(httpResponse.statusCode)") // DEBUG
            let responseBody = String(data: data, encoding: .utf8) ?? "Could not decode response body"

            guard (200...299).contains(httpResponse.statusCode) else {
                if httpResponse.statusCode == 401 { throw SpotifyAPIError.invalidToken }
                // Add other specific error handling (404, 429 etc.) if needed
                 print("❌ Server Error Response (\(httpResponse.statusCode)) Body: \(responseBody)")
                throw SpotifyAPIError.invalidResponse(httpResponse.statusCode, responseBody)
            }

            // Handle empty data case specifically for successful responses (e.g., 204 No Content)
            // Although unlikely for GET requests returning data structures
             if data.isEmpty && T.self != Data.self { // Check if expecting data but got none
                 // This might indicate an issue or an optional response field was expected
                 // Depending on the API, this might be an error or expected behavior
                 print("⚠️ Warning: Received empty data for expected type \(T.self) from \(url.absoluteString)")
                 // If empty data is always an error for your expected types, throw here:
                 // throw SpotifyAPIError.missingData
             }

            do {
                let decoder = JSONDecoder()
                return try decoder.decode(T.self, from: data)
            } catch let decodingError {
                print("❌ Decode Error for \(T.self) from \(url.absoluteString): \(decodingError)")
                 print("   Response Body Snippet: \(responseBody.prefix(500))")
                // Provide more context in the error
                throw SpotifyAPIError.decodingError("Error decoding \(T.self): \(decodingError.localizedDescription)")
            }
        } catch let error where !(error is CancellationError) {
            print("❌ Network Error for \(url.absoluteString): \(error)")
             // Map URLSession errors to a cleaner description if possible
             let nsError = error as NSError
             if nsError.domain == NSURLErrorDomain {
                  throw SpotifyAPIError.networkError(nsError.localizedDescription) // Use localized description
             }
             // Rethrow if it's already our custom error or a general error
             throw error is SpotifyAPIError ? error : SpotifyAPIError.networkError(error.localizedDescription)
        }
    }

    func searchAlbums(query: String, limit: Int = 20, offset: Int = 0) async throws -> SpotifySearchResponse {
         let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
         guard !trimmedQuery.isEmpty else {
             // Return an empty response structure instead of throwing? Or handle upstream.
             // For now, let the view handle empty query. Throwing might be valid too.
             print("⚠️ Search query is empty.")
             // Let's throw an error for clarity upstream
              throw SpotifyAPIError.invalidURL // Or a more specific error like .emptyQuery
         }

        var components = URLComponents(string: "https://api.spotify.com/v1/search")
        components?.queryItems = [
            URLQueryItem(name: "q", value: trimmedQuery), // Use trimmed query
            URLQueryItem(name: "type", value: "album"),
            URLQueryItem(name: "include_external", value: "audio"),
            URLQueryItem(name: "limit", value: "\(limit)"),
            URLQueryItem(name: "offset", value: "\(offset)")
        ]
        guard let url = components?.url else { throw SpotifyAPIError.invalidURL }
        return try await makeRequest(url: url)
    }

    func getAlbumTracks(albumId: String, limit: Int = 50, offset: Int = 0) async throws -> AlbumTracksResponse {
         var components = URLComponents(string: "https://api.spotify.com/v1/albums/\(albumId)/tracks")
         components?.queryItems = [ URLQueryItem(name: "limit", value: "\(limit)"), URLQueryItem(name: "offset", value: "\(offset)") ]
        guard let url = components?.url else { throw SpotifyAPIError.invalidURL }
        return try await makeRequest(url: url)
    }
}

// MARK: - Spotify Embed WebView Logic (Unchanged)

final class SpotifyPlaybackState: ObservableObject {
    @Published var isPlaying: Bool = false
    @Published var currentPosition: Double = 0 // seconds
    @Published var duration: Double = 0 // seconds
    @Published var currentUri: String = "" // URI currently loaded/playing in the iframe
    @Published var playerError: String? = nil // To surface player errors
}

struct SpotifyEmbedWebView: UIViewRepresentable {
    @ObservedObject var playbackState: SpotifyPlaybackState
    let spotifyUri: String // The URI to load

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIView(context: Context) -> WKWebView {
        // --- Configuration ---
        let userContentController = WKUserContentController()
        userContentController.add(context.coordinator, name: "spotifyController")

        let configuration = WKWebViewConfiguration()
        configuration.userContentController = userContentController
        configuration.allowsInlineMediaPlayback = true // Essential for background playback?
        configuration.mediaTypesRequiringUserActionForPlayback = [] // Allow programmatic play

        // --- WebView Creation ---
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator // For JS alerts
        webView.isOpaque = false
        webView.backgroundColor = .clear // Make transparent
        webView.scrollView.isScrollEnabled = false // Disable scrolling

        // --- Load HTML ---
        let html = generateHTML()
        webView.loadHTMLString(html, baseURL: nil)

        // --- Store reference ---
        context.coordinator.webView = webView
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        // Check if the API is ready and the URI needs updating
         if context.coordinator.isApiReady,
            let currentEmbedUri = context.coordinator.lastLoadedUri,
            currentEmbedUri != spotifyUri {
             print("🔄 SpotifyEmbed: updateUIView detected URI change. Requesting load: \(spotifyUri)")
              context.coordinator.loadUri(spotifyUri)
         } else if context.coordinator.isApiReady && context.coordinator.lastLoadedUri == nil {
              // Handle case where view appears with URI *after* API became ready but coordinator hasn't loaded yet
               print("🔄 SpotifyEmbed: updateUIView found API ready but no URI loaded. Requesting initial load: \(spotifyUri)")
               context.coordinator.loadUri(spotifyUri) // Try loading the initial URI
         } else if !context.coordinator.isApiReady {
             // If the view updates with a new URI *before* the API is ready,
             // make sure the coordinator knows the *latest* desired URI.
             // print("⏳ SpotifyEmbed: updateUIView saving desired URI for later: \(spotifyUri)")
              context.coordinator.updateDesiredUriBeforeReady(spotifyUri)
         }
    }

    static func dismantleUIView(_ uiView: WKWebView, coordinator: Coordinator) {
        print("🧹 SpotifyEmbed: Dismantling WebView.")
        uiView.stopLoading()
        uiView.configuration.userContentController.removeScriptMessageHandler(forName: "spotifyController")
        coordinator.webView = nil // Break reference cycle
    }

    // --- Coordinator ---
    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
        var parent: SpotifyEmbedWebView
        weak var webView: WKWebView?
        var isApiReady = false
        var lastLoadedUri: String? = nil // The URI actually loaded into the JS controller
        private var desiredUriBeforeReady: String? = nil // Holds the URI if updateUIView is called before API is ready

        init(_ parent: SpotifyEmbedWebView) {
            self.parent = parent
             // Set the initial desired URI right away
             self.desiredUriBeforeReady = parent.spotifyUri
        }

        // --- Method to track the latest desired URI before the API is ready ---
        func updateDesiredUriBeforeReady(_ uri: String) {
            if !isApiReady {
                desiredUriBeforeReady = uri
            }
        }

        // --- WKNavigationDelegate ---
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
             print("✅ SpotifyEmbed Native: HTML content finished loading.")
             // API readiness is handled by JS message 'ready'
        }
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
             print("❌ SpotifyEmbed Native: HTML Navigation failed: \(error.localizedDescription)")
             // Report this error?
             DispatchQueue.main.async { self.parent.playbackState.playerError = "HTML load failed: \(error.localizedDescription)" }
        }
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
             print("❌ SpotifyEmbed Native: HTML Provisional navigation failed: \(error.localizedDescription)")
             DispatchQueue.main.async { self.parent.playbackState.playerError = "HTML pre-load failed: \(error.localizedDescription)" }
        }

        // --- WKUIDelegate ---
         func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
             print("ℹ️ Spotify Embed Received JS Alert: \(message)")
             completionHandler() // Complete immediately
         }

        // --- WKScriptMessageHandler ---
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            guard message.name == "spotifyController" else { return }
            DispatchQueue.main.async { // Ensure updates happen on the main thread
                 self.parent.playbackState.playerError = nil // Clear previous error on new message
            }
            if let bodyDict = message.body as? [String: Any], let event = bodyDict["event"] as? String {
                // print("📦 Spotify Embed Native: JS Event Received - '\(event)', Data: \(bodyDict["data"] ?? "nil")") // DEBUG
                handleEvent(event: event, data: bodyDict["data"])
            } else if let bodyString = message.body as? String {
                // print("📦 Spotify Embed Native: JS String Message Received - '\(bodyString)'") // DEBUG
                if bodyString == "ready" {
                    handleApiReady()
                } else {
                    print("❓ Spotify Embed Native: Received unknown string message: \(bodyString)")
                     DispatchQueue.main.async { self.parent.playbackState.playerError = "Unknown message: \(bodyString)" }
                }
            } else {
                 print("❓ Spotify Embed Native: Received message in unexpected format: \(message.body)")
                 DispatchQueue.main.async { self.parent.playbackState.playerError = "Received unexpected data format from player." }
            }
        }

        private func handleApiReady() {
            print("✅ Spotify Embed Native: Spotify IFrame API script reported ready.")
            isApiReady = true
            // When API is ready, immediately try to create the controller
            // with the *most recently desired* URI.
             let initialUri = desiredUriBeforeReady ?? parent.spotifyUri
             print("🚀 Spotify Embed Native: API Ready. Attempting initial controller creation for URI: \(initialUri)")
             createSpotifyController(with: initialUri) // Create controller immediately
             desiredUriBeforeReady = nil // Clear after use
        }

        private func handleEvent(event: String, data: Any?) {
            switch event {
            case "controllerCreated":
                print("✅ Spotify Embed Native: Embed controller successfully created by JS for URI: \(lastLoadedUri ?? "unknown").")
                 // Update playback state only if the loaded URI matches the intended one
                 if let loaded = lastLoadedUri, loaded == parent.spotifyUri {
                     DispatchQueue.main.async { self.parent.playbackState.currentUri = loaded }
                 } else {
                      print("⚠️ Spotify Embed Native: Controller created, but for a different URI (\(lastLoadedUri ?? "nil")) than currently requested (\(parent.spotifyUri)). A loadUri call should follow.")
                 }
            case "playbackUpdate":
                if let updateData = data as? [String: Any] { updatePlaybackState(with: updateData)}
            case "error":
                let errorMessage = (data as? [String: Any])?["message"] as? String ?? (data as? String) ?? "Unknown JS player error"
                print("❌ Spotify Embed JS Error: \(errorMessage)")
                 DispatchQueue.main.async { self.parent.playbackState.playerError = errorMessage }
            default:
                print("❓ Spotify Embed Native: Received unknown JS event type: \(event)")
                 DispatchQueue.main.async { self.parent.playbackState.playerError = "Unknown event: \(event)" }
            }
        }

        private func updatePlaybackState(with data: [String: Any]) {
            DispatchQueue.main.async { [weak self] in
                 guard let self = self else { return }
                 var stateChanged = false
                 // Only update if the URI matches what we *intended* to load
                 guard let currentLoaded = self.lastLoadedUri, currentLoaded == self.parent.spotifyUri else {
                     // print("ℹ️ Spotify Embed Native: Ignoring playback update for non-matching URI (\(currentLoaded ?? "nil") vs \(self.parent.spotifyUri))")
                     return
                 }

                 if let isPaused = data["paused"] as? Bool {
                     let isPlayingNow = !isPaused
                     if self.parent.playbackState.isPlaying != isPlayingNow {
                         self.parent.playbackState.isPlaying = isPlayingNow
                         stateChanged = true
                     }
                 }
                 if let posMs = data["position"] as? Double ?? data["position"] as? Int { // Handle Int or Double
                      let newPosition = Double(posMs) / 1000.0
                     if abs(self.parent.playbackState.currentPosition - newPosition) > 0.2 { // Increase tolerance slightly
                        self.parent.playbackState.currentPosition = newPosition
                        stateChanged = true
                     }
                 }
                 if let durMs = data["duration"] as? Double ?? data["duration"] as? Int { // Handle Int or Double
                      let newDuration = Double(durMs) / 1000.0
                     // Update if significantly different or initially zero
                     if abs(self.parent.playbackState.duration - newDuration) > 0.1 || self.parent.playbackState.duration == 0 {
                         self.parent.playbackState.duration = newDuration
                         stateChanged = true
                     }
                 }
                 // Update currentUri from playback state *only if* it's different and non-empty
                 if let playbackUri = data["uri"] as? String, !playbackUri.isEmpty, self.parent.playbackState.currentUri != playbackUri {
                     self.parent.playbackState.currentUri = playbackUri
                      // Might need reconciliation if playbackUri != lastLoadedUri here
                     stateChanged = true
                 }

                 if stateChanged { /* print("🔄 Playback State Updated: \(parent.playbackState.isPlaying ? "Playing":"Paused") at \(parent.playbackState.currentPosition) of \(parent.playbackState.duration) for \(parent.playbackState.currentUri)") */ }
             }
        }

        private func createSpotifyController(with initialUri: String) {
            guard let webView = webView else { print("❌ Error: Cannot create controller, WebView is nil."); return }
            guard isApiReady else { print("⏳ Error: Cannot create controller, API not ready."); return }
            // Do not create if already created for *any* URI
             guard lastLoadedUri == nil else {
                 print("ℹ️ Spotify Embed Native: Controller already exists or creation attempt pending. Will use loadUri if needed.")
                 // If the desired URI is different, load it now
                 if initialUri != lastLoadedUri {
                      print("🚀 Spotify Embed Native: Controller exists, loading different initial URI: \(initialUri)")
                     loadUri(initialUri)
                 }
                 return
             }

            print("🚀 Spotify Embed Native: JS - Attempting createController for: \(initialUri)")
             // Intentionally *do not* set lastLoadedUri here yet. Set it *only* when the `controllerCreated` message comes back.

            let script = """
            (function() {
                console.log('Spotify Embed JS: createController block running.');
                window.embedController = null; // Ensure clean state
                const element = document.getElementById('embed-iframe');
                if (!element) { console.error('Spotify Embed JS: Embed element ID not found!'); window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'HTML element embed-iframe not found' }}); return; }
                if (!window.IFrameAPI) { console.error('Spotify Embed JS: IFrameAPI is not loaded!'); window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'Spotify IFrame API not loaded' }}); return; }

                console.log('Spotify Embed JS: Creating controller for URI: \(initialUri)');
                const options = { uri: '\(initialUri)', width: '100%', height: '80' }; // Fixed height
                const callback = (controller) => {
                    if (!controller) { console.error('Spotify Embed JS: createController callback received null controller!'); window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'JS createController callback received null controller' }}); return; }
                    console.log('✅ Spotify Embed JS: Controller instance received for URI: \(initialUri).');
                    window.embedController = controller; // Store globally

                    // Add Listeners (only needs to be done once per controller instance)
                    controller.addListener('ready', () => { console.log('Spotify Embed JS: Controller Ready event.'); });
                    controller.addListener('playback_update', e => { if (e.data) window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'playbackUpdate', data: e.data }); });
                    controller.addListener('account_error', e => { console.warn('Spotify Embed JS: Account Error:', e.data); window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'Account Error: ' + (e.data?.message ?? 'Premium required or login issue?') }}); });
                    controller.addListener('autoplay_failed', () => { console.warn('Spotify Embed JS: Autoplay failed'); window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'Autoplay failed' }}); /* controller.play(); */ }); // Avoid aggressive auto-retry play
                    controller.addListener('initialization_error', e => { console.error('Spotify Embed JS: Initialization Error:', e.data); window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'Initialization Error: ' + (e.data?.message ?? 'Failed to initialize player') }}); });

                    // Notify native side AFTER listeners are set
                     window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'controllerCreated' });

                };
                try {
                    console.log('Spotify Embed JS: Calling IFrameAPI.createController...');
                    window.IFrameAPI.createController(element, options, callback);
                } catch (e) {
                    let errorMessage = (e instanceof Error) ? e.message : String(e);
                    console.error('Spotify Embed JS: Error calling createController:', errorMessage);
                    window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'JS exception during createController: ' + errorMessage }});
                }
            })();
            """
            webView.evaluateJavaScript(script) { _, error in
                if let error = error {
                    print("⚠️ Spotify Embed Native: Error *evaluating* JS for controller creation: \(error.localizedDescription)")
                    DispatchQueue.main.async { self.parent.playbackState.playerError = "Failed to run player setup: \(error.localizedDescription)" }
                }
             }
        }

         // Method to load a new URI into the existing controller
        func loadUri(_ uri: String) {
            guard let webView = webView else { return }
            guard isApiReady else { return }
            // Controller must exist (lastLoadedUri is set when controllerCreated is received)
             guard lastLoadedUri != nil else {
                  print("⏳ Spotify Embed Native: loadUri called before controller created. Will retry after creation.")
                  // Ensure the desired URI is tracked for when create finishes
                   desiredUriBeforeReady = uri
                   // Possibly attempt creation again if it failed silently? Or rely on error states.
                   // createSpotifyController(with: uri) // Be cautious with re-calling create
                   return
             }
            // Don't reload the same URI
            guard lastLoadedUri != uri else {
                 print("ℹ️ Spotify Embed Native: loadUri called with the same URI (\(uri)) already loaded.")
                 // Ensure playback state URI is correct even if not reloading
                  DispatchQueue.main.async { if self.parent.playbackState.currentUri != uri { self.parent.playbackState.currentUri = uri } }
                 return
             }

            print("🚀 Spotify Embed Native: JS - Attempting loadUri: \(uri)")
            lastLoadedUri = uri // Update the *intended* loaded URI immediately

             // Reset playback state for the new track
              DispatchQueue.main.async {
                  self.parent.playbackState.isPlaying = false // Assume stopped until update
                  self.parent.playbackState.currentPosition = 0
                  self.parent.playbackState.duration = 0
                  self.parent.playbackState.currentUri = uri // Tentatively set URI in state
                  self.parent.playbackState.playerError = nil
              }

            let script = """
            (function() {
                if (window.embedController) {
                    console.log('Spotify Embed JS: Loading URI: \(uri)');
                    window.embedController.loadUri('\(uri)');
                    window.embedController.play(); // Attempt to play immediately
                } else {
                    console.error('Spotify Embed JS: embedController not found for loadUri \(uri).');
                    window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'JS embedController not found during loadUri' }});
                }
            })();
            """
            webView.evaluateJavaScript(script) { _, error in
                if let error = error {
                    print("⚠️ Spotify Embed Native: Error evaluating JS load URI \(uri): \(error.localizedDescription)")
                     DispatchQueue.main.async { self.parent.playbackState.playerError = "Failed to load track: \(error.localizedDescription)" }
                }
            }
        }
    }

    // --- Generate HTML ---
    private func generateHTML() -> String {
        """
        <!DOCTYPE html><html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no"><title>Spotify Embed</title><style>html, body { margin: 0; padding: 0; width: 100%; height: 100%; overflow: hidden; background-color: transparent; } #embed-iframe { width: 100%; height: 100%; min-height: 80px; display: block; border: none; box-sizing: border-box; }</style></head><body><div id="embed-iframe"></div><script src="https://open.spotify.com/embed/iframe-api/v1" async></script><script> console.log('Spotify Embed JS: Initial page script running.'); window.onSpotifyIframeApiReady = (IFrameAPI) => { console.log('✅ Spotify Embed JS: API Script Loaded.'); window.IFrameAPI = IFrameAPI; if (window.webkit?.messageHandlers?.spotifyController) { console.log(' -> Notifying Native: API Ready'); window.webkit.messageHandlers.spotifyController.postMessage("ready"); } else { console.error('❌ Spotify Embed JS: Native message handler (spotifyController) not found!'); } }; const scriptTag = document.querySelector('script[src*="iframe-api"]'); if (scriptTag) { scriptTag.onerror = (event) => { console.error('❌ Spotify Embed JS: Failed to load API script:', event); window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'Failed to load Spotify iframe-api script' }}); }; } else { console.warn('⚠️ Spotify Embed JS: API script tag not found in HTML.'); } </script></body></html>
        """
    }
}

// MARK: - SwiftUI Views (Themed)

// MARK: - Main List View (Themed)
struct SpotifyAlbumListView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @State private var searchQuery: String = ""
    @State private var displayedAlbums: [AlbumItem] = []
    @State private var isLoading: Bool = false
    @State private var searchInfo: Albums? = nil
    @State private var currentError: SpotifyAPIError? = nil
    @State private var showingThemeSelector = false
    @State private var debounceTask: Task<Void, Never>? = nil

    var body: some View {
        let theme = themeManager.currentTheme // Convenience

        NavigationView {
            ZStack {
                // Use themed background modifier
                Color.clear.themedBackground(theme: theme)

                // --- Conditional Content ---
                Group {
                    if isLoading && displayedAlbums.isEmpty {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: theme.accentColor1))
                            .scaleEffect(1.5)
                            .padding(.bottom, 50)
                    } else if let error = currentError {
                         ErrorPlaceholderView(error: error) {
                             Task { await performSearch(immediate: true) }
                         }
                          .environmentObject(themeManager) // Pass theme manager down
                    } else if displayedAlbums.isEmpty && !searchQuery.isEmpty && !isLoading {
                         // Only show "No Results" if search attempted and finished
                         EmptyStatePlaceholderView(searchQuery: searchQuery)
                             .environmentObject(themeManager) // Pass theme manager down
                    } else if displayedAlbums.isEmpty && searchQuery.isEmpty && !isLoading {
                         // Show initial empty state
                         EmptyStatePlaceholderView(searchQuery: "")
                             .environmentObject(themeManager) // Pass theme manager down
                    } else {
                        albumList // Themed list content
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity) // Center content
                .transition(.opacity.animation(.easeInOut(duration: 0.4)))

                // --- Ongoing Loading Overlay (Themed) ---
                 if isLoading && !displayedAlbums.isEmpty {
                     VStack {
                         HStack {
                             Spacer()
                             ProgressView()
                                  .progressViewStyle(CircularProgressViewStyle(tint: theme.successColor))
                             Text("Loading...")
                                   .themedFont(.caption, weight: .bold, theme: theme)
                                   .foregroundColor(theme.successColor)
                                   .padding(.leading, 5)
                             Spacer()
                         }
                         .padding(.vertical, 6)
                         .padding(.horizontal, 15)
                         .background(theme.primaryBackgroundColor.opacity(0.7).blur(radius: 5)) // Themed blur bg
                         .clipShape(Capsule())
                          .overlay(Capsule().stroke(theme.successColor.opacity(0.5), lineWidth: 1))
                          .if(theme.glowColor != nil) { $0.themedGlow(theme: theme.copy(glowColor: theme.successColor)) } // Glow with success color
                          .padding(.top, 8)
                          .shadow(radius: 5) // Standard shadow for visibility
                         Spacer()
                     }
                     .transition(.opacity.animation(.easeInOut))
                  }

            } // End ZStack
            .navigationTitle("Music Search")
            .navigationBarTitleDisplayMode(.inline)
             // Toolbar theming
            .toolbarBackground(theme.secondaryBackgroundColor.opacity(0.8), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(theme.colorScheme ?? .dark, for: .navigationBar)
            .toolbar { // Toolbar Content
                 ToolbarItem(placement: .navigationBarTrailing) {
                      Button { showingThemeSelector = true } label: {
                           Label("Change Theme", systemImage: "paintbrush.fill")
                               .labelStyle(.iconOnly) // Just show the icon
                               .foregroundColor(theme.accentColor1)
                      }
                 }
             }
             .sheet(isPresented: $showingThemeSelector) {
                  ThemeSelectionView()
                      // Pass manager to sheet, it will read the theme itself
                     .environmentObject(themeManager)
             }

            // Search Bar
            .searchable(text: $searchQuery,
                        placement: .navigationBarDrawer(displayMode: .always),
                        prompt: Text("Search Albums / Artists").foregroundColor(.gray))
             .onSubmit(of: .search) { Task { await performSearch(immediate: true) } }
             .onChange(of: searchQuery) { _ /* newQuery */ in
                  // Cancel previous debounce task
                  debounceTask?.cancel()
                  // Start a new one
                  debounceTask = Task { await performSearch() }
                  // Clear error when user types
                   if currentError != nil { currentError = nil }
             }
             .tint(theme.accentColor1) // Apply theme tint to search bar interactions

        } // End NavigationView
         .tint(theme.accentColor1) // Apply global tint
    }

    // --- Themed Album List ---
    private var albumList: some View {
        let theme = themeManager.currentTheme
        return List {
             // --- Themed Metadata Header ---
             if let info = searchInfo, info.total > 0 {
                 SearchMetadataHeader(totalResults: info.total, limit: info.limit, offset: info.offset)
                     .themedFont(.caption2, weight: .bold, theme: theme)
                     .foregroundColor(theme.accentColor2)
                     .listRowSeparator(.hidden)
                     .listRowInsets(EdgeInsets(top: 5, leading: 15, bottom: 5, trailing: 15)) // Added padding
                     .listRowBackground(Color.clear)
             }

            // --- Album Cards ---
             ForEach(displayedAlbums) { album in
                 // Use ZStack to layer NavigationLink over the whole card area
                 // IMPORTANT: NavigationLink itself MUST be styled plainly, the content drives the look.
                  ZStack {
                      // Your themed card view is the visual content
                       ThemeAwareAlbumCard(album: album)
                           .padding(.vertical, 6) // Spacing between cards

                       // Invisible NavigationLink covering the card
                       NavigationLink(destination: AlbumDetailView(album: album)) {
                           EmptyView() // Link has no visible content itself
                       }
                       .opacity(0) // Make the NavigationLink chevron/label invisible
                  }
                  .listRowSeparator(.hidden)
                  .listRowInsets(EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 15))
                  .listRowBackground(Color.clear)
             }
        }
        .listStyle(PlainListStyle())
        .background(Color.clear)
        .scrollContentBackground(.hidden) // Essential for background color to show
    }

    // Debounced Search Logic
    private func performSearch(immediate: Bool = false) async {
        let trimmedQuery = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)

         // If immediate (e.g., onSubmit), proceed directly if query non-empty
         if immediate {
             guard !trimmedQuery.isEmpty else {
                 await MainActor.run { displayedAlbums = []; searchInfo = nil; isLoading = false; currentError = nil }
                 return // Don't search if empty on submit Canceled
             }
         } else {
             // Debounce logic
              do {
                  try await Task.sleep(for: .milliseconds(500)); // 500ms debounce
                  try Task.checkCancellation()
              } catch {
                  print("Search task cancelled (debounce).")
                  // Don't reset loading state here, might be starting a new search
                  return
              }
              // After debounce, check again if the query is still valid and matches current input
              guard trimmedQuery == searchQuery.trimmingCharacters(in: .whitespacesAndNewlines) else {
                  print("Search query changed during debounce. New search will trigger.")
                  return
              }
              guard !trimmedQuery.isEmpty else { // Don't search if empty after debounce
                  // Clear results if query was cleared during debounce
                    await MainActor.run { displayedAlbums = []; searchInfo = nil; isLoading = false; currentError = nil }
                  return
              }
         }

         // Proceed with the search
        await MainActor.run { isLoading = true; currentError = nil } // Clear previous error on new search
        do {
            let response = try await SpotifyAPIService.shared.searchAlbums(query: trimmedQuery, offset: 0)
             // Check for cancellation *after* the API call returns, before UI update
              try Task.checkCancellation()
             await MainActor.run {
                 displayedAlbums = response.albums.items
                 searchInfo = response.albums
                 // Error is already nil
                 isLoading = false
             }
        } catch is CancellationError {
             print("Search task cancelled (during/after API call).")
             await MainActor.run { isLoading = false } // Reset loading state
        } catch let apiError as SpotifyAPIError {
             print("❌ API Error: \(apiError.localizedDescription)")
             await MainActor.run { displayedAlbums = []; searchInfo = nil; currentError = apiError; isLoading = false }
        } catch {
             print("❌ Unexpected Error: \(error.localizedDescription)")
             // Create a specific error type if possible
             await MainActor.run { displayedAlbums = []; searchInfo = nil; currentError = .networkError(error.localizedDescription); isLoading = false }
        }
    }
}

// MARK: - Theme Aware Album Card
struct ThemeAwareAlbumCard: View {
    @EnvironmentObject var themeManager: ThemeManager
    let album: AlbumItem

    var body: some View {
        let theme = themeManager.currentTheme

        HStack(spacing: 15) { // Consistent spacing
            AlbumImageView(url: album.listImageURL, theme: theme) // Pass theme to image placeholder
                .frame(width: 80, height: 80) // Fixed size for list layout
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                 // Use card stroke color for image border too
                 .overlay(RoundedRectangle(cornerRadius: 8, style: .continuous).stroke(theme.cardStrokeColor.opacity(0.5), lineWidth: 1))
                 .if(theme.glowColor == nil) { $0.shadow(color: .black.opacity(0.2), radius: 3, y: 1) } // Standard shadow if no glow

            VStack(alignment: .leading, spacing: 4) { // Control spacing
                Text(album.name)
                    .themedFont(.headline, weight: .bold, theme: theme)
                    .foregroundColor(theme.primaryTextColor)
                    .lineLimit(2)
                     .frame(minHeight: 20) // Ensure minimum height for short titles

                Text(album.formattedArtists)
                    .themedFont(.subheadline, theme: theme)
                    .foregroundColor(theme.accentColor2) // Use accent 2
                    .lineLimit(1)

                Spacer() // Push info to top and bottom

                // Group release info
                 HStack(spacing: 6) {
                     Label(album.album_type.capitalized, systemImage: "rectangle.stack.fill")
                     Text("• \(album.formattedReleaseDate())")
                     Spacer() // Push track count to the right
                     Text("\(album.total_tracks) Trk") // Abbreviated
                 }
                 .themedFont(.caption, weight: .medium, theme: theme)
                 .foregroundColor(theme.secondaryTextColor)
                 .lineLimit(1)

            }
            .frame(maxWidth: .infinity, alignment: .leading) // Ensure VStack takes available space
        }
        .padding(12) // Padding *inside* the card
        .themedCardStyle(theme: theme) // Apply themed background/stroke/glow
        .frame(height: 105) // Maintain consistent height
    }
}

// MARK: - Themed Placeholders
struct ErrorPlaceholderView: View {
    @EnvironmentObject var themeManager: ThemeManager
    let error: SpotifyAPIError
    let retryAction: (() -> Void)?

    var body: some View {
        let theme = themeManager.currentTheme
        VStack(spacing: 20) {
            Image(systemName: iconName)
                .font(.system(size: 60))
                .foregroundColor(theme.errorColor)
                .if(theme.glowColor != nil) { $0.themedGlow(theme: theme.copy(glowColor: theme.errorColor)) } // Glow with error color

            Text("ERROR!")
                .themedFont(.title2, weight: .heavy, theme: theme)
                .foregroundColor(theme.primaryTextColor)
                .tracking(3) // Add character spacing

            Text(errorMessage)
                 .themedFont(.body, theme: theme)
                 .foregroundColor(theme.secondaryTextColor)
                 .multilineTextAlignment(.center)
                 .padding(.horizontal, 30)

            if error != .invalidToken, let retryAction = retryAction {
                 ThemedButton(text: "RETRY", action: retryAction, primaryColor: theme.accentColor1, secondaryColor: theme.accentColor2) // Use themed button
                     .padding(.top, 15)
            } else if error == .invalidToken {
                 Text("Check API Token in Code")
                     .themedFont(.footnote, theme: theme)
                     .foregroundColor(theme.errorColor.opacity(0.8))
                     .padding(.top, 10)
            }
        }
        .padding(30)
         // Subtle background using secondary theme color
          .background(theme.secondaryBackgroundColor.opacity(0.7).blur(radius: 10))
          .cornerRadius(20)
          .overlay(RoundedRectangle(cornerRadius: 20).stroke(theme.errorColor, lineWidth: 1))
          .padding(20) // Padding around the whole error view
    }

    private var iconName: String { /* ... Logic unchanged ... */
        switch error {
        case .invalidToken: return "key.slash.fill"
        case .networkError: return "wifi.exclamationmark" // More specific
        case .invalidResponse, .decodingError, .missingData: return "exclamationmark.triangle.fill"
        case .invalidURL: return "link.icloud.fill"
        }
    }
    private var errorMessage: String { /* ... Logic unchanged ... */
        error.localizedDescription // Use the built-in localized description primarily
    }
}

struct EmptyStatePlaceholderView: View {
    @EnvironmentObject var themeManager: ThemeManager
    let searchQuery: String

    var body: some View {
        let theme = themeManager.currentTheme
        VStack(spacing: 20) {
             let iconToShow = isInitialState ? "My-meme-microphone" : "My-meme-orange_2"
            // Ensure you have these images in your Assets catalog!
             Image(iconToShow)
                 .resizable()
                 .aspectRatio(contentMode: .fit)
                 .frame(maxHeight: 150)
                 .padding(.bottom, 10)
                  // Apply subtle glow based on theme
                  .if(theme.glowColor != nil) { $0.themedGlow(theme: theme.copy(glowColor: theme.accentColor1)) }

            Text(title)
                 .themedFont(.title, weight: .bold, theme: theme)
                 .foregroundColor(theme.primaryTextColor)

            Text(messageAttributedString(theme: theme)) // Pass theme for styling
                 .themedFont(.body, theme: theme) // Base styling
                 .foregroundColor(theme.secondaryTextColor)
                 .multilineTextAlignment(.center)
                 .padding(.horizontal, 30)
        }
        .padding(30)
    }
     private var isInitialState: Bool { searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
     private var title: String { isInitialState ? "Ready to Search" : "No Results Found" }
     private func messageAttributedString(theme: ThemeSettings) -> AttributedString {
         var message: AttributedString
         if isInitialState {
             message = AttributedString("Enter an album or artist name above\nto discover some tunes!")
         } else {
             // Try markdown for bolding the query
             do {
                 let query = searchQuery.isEmpty ? "your search" : searchQuery // Handle empty string case
                 // Escape potential markdown characters in the query itself (basic)
                 let escapedQuery = query.replacingOccurrences(of: "*", with: "\\*")
                                        .replacingOccurrences(of: "_", with: "\\_")

                 message = try AttributedString(markdown: "Couldn't find matches for **\(escapedQuery)**.\nTry refining your search terms.")
             } catch {
                 // Fallback if markdown fails
                  message = AttributedString("Couldn't find matches for \"\(searchQuery)\".\nTry refining your search terms.")
             }
         }
         // Apply consistent font and color to the whole attributed string
         message.font = Font.system(size: theme.baseFontSize, design: theme.fontDesign) // Apply base font/design
         message.foregroundColor = theme.secondaryTextColor
         return message
     }
}

// MARK: - Album Detail View (Themed)
struct AlbumDetailView: View {
    @EnvironmentObject var themeManager: ThemeManager
    let album: AlbumItem
    @State private var tracks: [Track] = []
    @State private var isLoadingTracks: Bool = false
    @State private var trackFetchError: SpotifyAPIError? = nil
    @State private var selectedTrackUri: String? = nil
    @StateObject private var playbackState = SpotifyPlaybackState() // Specific to this view instance

    var body: some View {
        let theme = themeManager.currentTheme
        ZStack {
            // Use themed background modifier
            Color.clear.themedBackground(theme: theme)

            List {
                // --- Header Section ---
                Section { AlbumHeaderView(album: album) }
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)

                // --- Player Section (Themed) ---
                if let uriToPlay = selectedTrackUri {
                     Section {
                          SpotifyEmbedPlayerView(playbackState: playbackState, spotifyUri: uriToPlay)
                               .environmentObject(themeManager) // Ensure player gets theme
                     }
                     .listRowSeparator(.hidden)
                     .listRowInsets(EdgeInsets(top: 15, leading: 0, bottom: 15, trailing: 0)) // Match padding
                     .listRowBackground(Color.clear)
                     .transition(.opacity.combined(with: .move(edge: .top)).animation(.easeInOut(duration: 0.4)))
                }

                // --- Tracks Section (Themed) ---
                Section {
                    TracksSectionView(
                        tracks: tracks, isLoading: isLoadingTracks, error: trackFetchError,
                        selectedTrackUri: $selectedTrackUri,
                        retryAction: { Task { await fetchTracks() } }
                    )
                     .environmentObject(themeManager) // Pass theme
                } header: {
                     Text("TRACK LIST")
                         .themedFont(.caption, weight: .bold, theme: theme)
                         .foregroundColor(theme.accentColor2) // Use accent 2 for header
                         .tracking(2)
                         .frame(maxWidth: .infinity, alignment: .leading) // Align left
                         .padding(.leading, 15) // Indent header
                         .padding(.vertical, 8)
                         .background(theme.primaryBackgroundColor) // Use primary bg to blend header row
                }
                .listRowInsets(EdgeInsets()) // Remove insets for tracks section
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)

                 // --- External Link Section (Themed) ---
                 if let spotifyURL = URL(string: album.external_urls.spotify ?? "") {
                      Section {
                          ThemedButton( // Use the themed button
                           text: "OPEN IN SPOTIFY",
                           action: { openExternalURL(spotifyURL) },
                           primaryColor: theme.successColor, // Use success color (e.g., Spotify Green-like)
                           secondaryColor: theme.successColor.opacity(0.7),
                           iconName: "arrow.up.forward.app.fill"
                          )
                      }
                          .listRowInsets(EdgeInsets(top: 20, leading: 20, bottom: 30, trailing: 20)) // Add bottom padding
                          .listRowSeparator(.hidden)
                          .listRowBackground(Color.clear)
                  }

            } // End List
            .listStyle(PlainListStyle())
            .scrollContentBackground(.hidden) // Allow ZStack background to show
             .refreshable { await fetchTracks(forceReload: true) } // Enable refresh
        } // End ZStack
        .navigationTitle(album.name)
        .navigationBarTitleDisplayMode(.inline)
         // Match nav bar theme
         .toolbarBackground(theme.secondaryBackgroundColor.opacity(0.8), for: .navigationBar)
         .toolbarBackground(.visible, for: .navigationBar)
         .toolbarColorScheme(theme.colorScheme ?? .dark, for: .navigationBar)
        .task { await fetchTracks() } // Initial track fetch
         .animation(.easeInOut, value: selectedTrackUri) // Animate player appearance/track selection
         .tint(theme.accentColor1) // Apply tint to back button etc.

    }

    // --- Fetch Tracks Logic (Unchanged) ---
    private func fetchTracks(forceReload: Bool = false) async {
        // Avoid fetching if already loading or if data exists and not forcing reload
        guard !isLoadingTracks else { return }
        guard forceReload || tracks.isEmpty || trackFetchError != nil else { return }

        await MainActor.run { isLoadingTracks = true; trackFetchError = nil }
        do {
            let response = try await SpotifyAPIService.shared.getAlbumTracks(albumId: album.id)
            // Check for cancellation *after* the API call returns
             try Task.checkCancellation()
            await MainActor.run {
                 self.tracks = response.items
                 self.isLoadingTracks = false
                 // Pre-select first track if none selected? Optional UX choice.
                 // if selectedTrackUri == nil { selectedTrackUri = tracks.first?.uri }
             }
        } catch is CancellationError { await MainActor.run { isLoadingTracks = false } }
        catch let apiError as SpotifyAPIError { await MainActor.run { self.trackFetchError = apiError; self.isLoadingTracks = false; self.tracks = [] } }
        catch { await MainActor.run { self.trackFetchError = .networkError(error.localizedDescription); self.isLoadingTracks = false; self.tracks = [] } }
    }

     // Helper to open URL
     @Environment(\.openURL) private var openURLAction
     private func openExternalURL(_ url: URL) {
         print("Attempting to open external URL: \(url)")
         openURLAction(url) { accepted in
             if !accepted {
                 print("⚠️ Warning: URL scheme \(url.scheme ?? "") could not be opened.")
                 // Consider showing user an alert here if needed
             }
         }
     }
}

// MARK: - DetailView Sub-Components (Themed)

struct AlbumHeaderView: View {
    @EnvironmentObject var themeManager: ThemeManager
    let album: AlbumItem

    var body: some View {
        let theme = themeManager.currentTheme
        VStack(spacing: 15) {
             AlbumImageView(url: album.bestImageURL, theme: theme)
                 .aspectRatio(1.0, contentMode: .fit) // Maintain aspect ratio
                 .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                  // Use gradient border matching card stroke logic
                  .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous).stroke(theme.cardStrokeColor, lineWidth: 1.5))
                  .if(theme.glowColor != nil) { $0.themedGlow(theme: theme) } // Apply theme glow
                  .else { $0.shadow(color: .black.opacity(0.25), radius: 5, y: 2) } // Or standard shadow
                  .padding(.horizontal, 60) // Adjust horizontal padding

            VStack(spacing: 5) {
                Text(album.name)
                     .themedFont(.title2, weight: .bold, theme: theme)
                     .foregroundColor(theme.primaryTextColor)
                     .multilineTextAlignment(.center)
                     .lineLimit(3) // Allow slightly more lines for long titles

                Text("by \(album.formattedArtists)")
                     .themedFont(.body, theme: theme)
                     .foregroundColor(theme.accentColor2) // Accent 2 for artist
                     .multilineTextAlignment(.center)
                     .lineLimit(2)

                Text("\(album.album_type.capitalized) • \(album.formattedReleaseDate())")
                      .themedFont(.caption, weight: .medium, theme: theme)
                      .foregroundColor(theme.secondaryTextColor)
            }
            .padding(.horizontal)

        }
        .padding(.vertical, 20) // Adjust vertical padding
    }
}

struct SpotifyEmbedPlayerView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @ObservedObject var playbackState: SpotifyPlaybackState
    let spotifyUri: String

    var body: some View {
        let theme = themeManager.currentTheme
        VStack(spacing: 8) {
             // Error Display Area
             if let error = playbackState.playerError {
                  HStack {
                      Image(systemName: "exclamationmark.triangle.fill")
                      Text(error)
                          .lineLimit(2)
                  }
                  .themedFont(.caption2, weight: .medium, theme: theme)
                  .foregroundColor(theme.errorColor)
                  .padding(.horizontal, 15)
                  .padding(.vertical, 5)
                   .background(theme.errorColor.opacity(0.1))
                   .clipShape(RoundedRectangle(cornerRadius: 6))
                  .frame(height: playbackState.playerError != nil ? .infinity : 0) // Only take height if error exists
                  .opacity(playbackState.playerError != nil ? 1 : 0)
                  .transition(.opacity.animation(.easeInOut))
              }

            SpotifyEmbedWebView(playbackState: playbackState, spotifyUri: spotifyUri)
                  .frame(height: 80) // Keep fixed height for embed iframe
                  .background(Color.clear) // Ensure transparent background for webview itself
                  .clipShape(RoundedRectangle(cornerRadius: 10)) // Clip webview slightly
                  // Themed Container background/border
                  .padding(1) // Small padding so border doesn't clip webview edges
                  .background(
                       theme.secondaryBackgroundColor.opacity(0.5) // Use secondary bg, slightly transparent
                          .overlay(.ultraThinMaterial.opacity(theme.colorScheme == .dark ? 0.5 : 0.8)) // Frosted glass stronger on light
                           .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                          .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(theme.cardStrokeColor, lineWidth: 1))
                          .if(theme.glowColor != nil) { $0.themedGlow(theme: theme.copy(glowColor: playbackState.isPlaying ? theme.successColor : theme.accentColor1, radius: 8)) } // Dynamic glow for container based on state
                   )
                  .padding(.horizontal, 15) // Horizontal padding for the container

             // --- Themed Playback Status ---
             if playbackState.duration > 0.1 { // Only show status text if duration is valid
                 HStack {
                     let statusText = playbackState.isPlaying ? "PLAYING" : "PAUSED"
                     let statusColor = playbackState.isPlaying ? theme.successColor : theme.accentColor1

                     Text(statusText)
                         .themedFont(.caption2, weight: .bold, theme: theme)
                         .foregroundColor(statusColor)
                         .tracking(1.5)
                         .if(theme.glowColor != nil) { $0.themedGlow(theme: theme.copy(glowColor: statusColor, radius: 4)) }
                         .lineLimit(1)
                         .frame(minWidth: 60, alignment: .leading)

                     Spacer()

                     Text("\(formatTime(playbackState.currentPosition)) / \(formatTime(playbackState.duration))")
                          .themedFont(.caption, weight: .medium, theme: theme)
                          .foregroundColor(theme.secondaryTextColor)
                 }
                 .padding(.horizontal, 25) // Align with player padding
                 .padding(.top, 0) // Reduce top padding
                 .frame(height: 15) // Fixed height for status line
                  .transition(.opacity.animation(.easeInOut)) // Fade in status
             } else {
                 // Placeholder or empty view if duration is 0
                 Spacer().frame(height: 15)
             }
        } // End VStack
         .animation(.easeInOut(duration: 0.4), value: playbackState.isPlaying) // Animate glow color change
         .animation(.easeInOut, value: playbackState.playerError) // Animate error appearance
    }

    private func formatTime(_ time: Double) -> String {
         let totalSeconds = max(0, Int(time))
         let minutes = totalSeconds / 60
         let seconds = totalSeconds % 60
         return String(format: "%d:%02d", minutes, seconds)
    }
}

struct TracksSectionView: View {
    @EnvironmentObject var themeManager: ThemeManager
    let tracks: [Track]
    let isLoading: Bool
    let error: SpotifyAPIError?
    @Binding var selectedTrackUri: String?
    let retryAction: () -> Void

    var body: some View {
        let theme = themeManager.currentTheme
        Group {
            if isLoading {
                 HStack {
                    Spacer()
                     ProgressView().tint(theme.accentColor1)
                     Text("Loading Tracks...")
                         .themedFont(.subheadline, theme: theme)
                         .foregroundColor(theme.accentColor1) // Use theme accent
                         .padding(.leading, 8)
                    Spacer()
                }
                .padding(.vertical, 30) // More padding when loading
            } else if let error = error {
                 ErrorPlaceholderView(error: error, retryAction: retryAction)
                      .environmentObject(themeManager) // Pass theme manager down
                      .padding(.vertical, 20)
            } else if tracks.isEmpty {
                Text("No Tracks Found for this Album")
                    .themedFont(.subheadline, theme: theme)
                     .foregroundColor(theme.secondaryTextColor)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 30)
            } else {
                // Track rows directly in the section
                 ForEach(tracks) { track in
                     TrackRowView(track: track, isSelected: track.uri == selectedTrackUri)
                          .environmentObject(themeManager) // Pass theme manager down
                          .contentShape(Rectangle()) // Make whole row tappable
                          .onTapGesture {
                              selectedTrackUri = track.uri
                          }
                          .listRowBackground(
                             track.uri == selectedTrackUri
                              ? theme.accentColor1.opacity(0.15).blur(radius: 5) // Use theme accent with blur
                              : Color.clear
                          )
                          .listRowSeparator(.hidden) // Hide individual separators
                          .padding(.horizontal, 15) // Add horizontal padding to rows
                          .padding(.vertical, 2) // Add slight vertical padding between rows
                }
                // Add a final separator visually if needed below the list
                Divider().background(theme.cardStrokeColor.opacity(0.5)).padding(.horizontal, 15)
            }
        }
         // No outer padding needed for the Group itself
    }
}

struct TrackRowView: View {
    @EnvironmentObject var themeManager: ThemeManager
    let track: Track
    let isSelected: Bool

    var body: some View {
        let theme = themeManager.currentTheme
        HStack(spacing: 12) {
             // --- Track Number ---
             Text("\(track.track_number)")
                 .themedFont(.caption, weight: .medium, theme: theme)
                 .foregroundColor(isSelected ? theme.accentColor1 : theme.secondaryTextColor)
                 .frame(width: 25, alignment: .center)

             // --- Track Info ---
             VStack(alignment: .leading, spacing: 2) { // Reduced spacing
                 Text(track.name)
                      .themedFont(.body, weight: isSelected ? .bold : .regular, theme: theme)
                      .foregroundColor(isSelected ? theme.accentColor1 : theme.primaryTextColor)
                      .lineLimit(1)

                 Text(track.formattedArtists)
                      .themedFont(.footnote, theme: theme)
                      .foregroundColor(theme.secondaryTextColor)
                      .lineLimit(1)
             }
             .frame(maxWidth: .infinity, alignment: .leading) // Let text take space

             Spacer() // Push duration and icon right

             // --- Duration ---
             Text(track.formattedDuration)
                  .themedFont(.caption, weight: .medium, theme: theme)
                  .foregroundColor(theme.secondaryTextColor)
                  .padding(.trailing, 8)

             // --- Play Indicator ---
              Image(systemName: isSelected ? "waveform" : "play.fill") // Use waveform when selected
                   .foregroundColor(isSelected ? theme.accentColor1 : theme.secondaryTextColor)
                   .themedFont(.callout, theme: theme) // Adjust size via font style
                   .frame(width: 20, height: 20, alignment: .center)
                   .animation(.easeInOut(duration: 0.2), value: isSelected)

        }
        .padding(.vertical, 8) // Adjust vertical padding for row height
    }
}

// MARK: - Other Supporting Views (Themed)

struct AlbumImageView: View {
    @EnvironmentObject var themeManager: ThemeManager // Needed for placeholder theming
    let url: URL?

    var body: some View {
        let theme = themeManager.currentTheme
        AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
                ZStack {
                     // Use theme's secondary background for placeholder
                      RoundedRectangle(cornerRadius: 8).fill(theme.secondaryBackgroundColor.opacity(0.5))
                      ProgressView().tint(theme.accentColor1)
                }
            case .success(let image):
                image.resizable()
            case .failure:
                ZStack {
                      RoundedRectangle(cornerRadius: 8).fill(theme.secondaryBackgroundColor.opacity(0.5))
                     Image(systemName: "photo.fill") // Keep system icon
                          .resizable().scaledToFit()
                          .foregroundColor(theme.secondaryTextColor.opacity(0.5)) // Use theme text color
                          .padding(10)
                }
            @unknown default: EmptyView()
            }
        }
         .scaledToFit() // Apply fit scaling by default
    }
}

struct SearchMetadataHeader: View {
    // No theme needed directly, uses themedFont modifier passed from parent
    let totalResults: Int
    let limit: Int
    let offset: Int

    var body: some View {
        HStack {
             Text("Results: \(totalResults)") // Simpler text
             Spacer()
             if totalResults > limit {
                 Text("Showing: \(offset + 1)-\(min(offset + limit, totalResults))")
             } else if totalResults > 0 {
                 Text("Showing: \(totalResults)") // Show count if <= limit
             }
        }
        // Font/Color applied by parent using .themedFont / .foregroundColor
        .padding(.bottom, 5)
    }
}

// Generic Themed Button
struct ThemedButton: View {
     @EnvironmentObject var themeManager: ThemeManager
     let text: String
     let action: () -> Void
     var primaryColor: Color? = nil // Optional override
     var secondaryColor: Color? = nil // Optional override
     var iconName: String? = nil

     var body: some View {
         let theme = themeManager.currentTheme
         let buttonPrimary = primaryColor ?? theme.accentColor1
         let buttonSecondary = secondaryColor ?? theme.accentColor2

         Button(action: action) {
             HStack(spacing: 8) {
                 if let iconName = iconName {
                     Image(systemName: iconName)
                 }
                 Text(text)
                     .tracking(1.5) // Keep letter spacing? optional
             }
             .themedFont(.callout, weight: .bold, theme: theme) // Themed font
             .padding(.horizontal, 25)
             .padding(.vertical, 12)
             .frame(maxWidth: .infinity) // Make button expand
             .background(LinearGradient(colors: [buttonPrimary, buttonSecondary], startPoint: .leading, endPoint: .trailing)) // Gradient using theme colors
             .foregroundColor(theme.primaryBackgroundColor) // Use contrasting color for text
             .clipShape(Capsule())
             .overlay(Capsule().stroke(Color.white.opacity(0.3), lineWidth: 1)) // Keep subtle edge
             .if(theme.glowColor != nil) { $0.themedGlow(theme: theme.copy(glowColor: buttonPrimary)) } // Glow with button color
             .else { $0.shadow(color: .black.opacity(0.2), radius: 4, y: 2) }
         }
         .buttonStyle(.plain) // Ensure custom background/foreground work
     }
}

// MARK: - Theme Settings Copy Helper
// Helper to easily modify a copy of theme settings, e.g., for glow color override
extension ThemeSettings {
    func copy(
        name: String? = nil,
        colorScheme: ColorScheme? = nil, // Use Optional<ColorScheme?> if you need to represent clearing the value vs. not changing it
        primaryBackgroundColor: Color? = nil,
        secondaryBackgroundColor: Color? = nil,
        cardGradient: AnyGradient? = nil,
        cardStrokeColor: Color? = nil,
        primaryTextColor: Color? = nil,
        secondaryTextColor: Color? = nil,
        accentColor1: Color? = nil,
        accentColor2: Color? = nil,
        errorColor: Color? = nil,
        successColor: Color? = nil,
        glowColor: Color?? = nil, // Double optional to allow setting to nil
        glowRadius: CGFloat? = nil,
        fontDesign: Font.Design? = nil,
        baseFontSize: CGFloat? = nil
    ) -> ThemeSettings {
        ThemeSettings(
            name: name ?? self.name,
            colorScheme: colorScheme ?? self.colorScheme, // Note: Direct Optional replacement might be needed if you want to specifically SET it to nil vs leaving it unchanged
            primaryBackgroundColor: primaryBackgroundColor ?? self.primaryBackgroundColor,
            secondaryBackgroundColor: secondaryBackgroundColor ?? self.secondaryBackgroundColor,
            cardGradient: cardGradient ?? self.cardGradient,
            cardStrokeColor: cardStrokeColor ?? self.cardStrokeColor,
            primaryTextColor: primaryTextColor ?? self.primaryTextColor,
            secondaryTextColor: secondaryTextColor ?? self.secondaryTextColor,
            accentColor1: accentColor1 ?? self.accentColor1,
            accentColor2: accentColor2 ?? self.accentColor2,
            errorColor: errorColor ?? self.errorColor,
            successColor: successColor ?? self.successColor,
            glowColor: glowColor ?? self.glowColor, // Assigns the Optional<Color?>
            glowRadius: glowRadius ?? self.glowRadius,
            fontDesign: fontDesign ?? self.fontDesign,
            baseFontSize: baseFontSize ?? self.baseFontSize
        )
    }
}

// MARK: - App Entry Point (Themed)

@main
struct SpotifyThemedApp: App {
    @StateObject private var themeManager = ThemeManager()

    init() {
        // --- Token Check ---
         if placeholderSpotifyToken == "YOUR_SPOTIFY_BEARER_TOKEN_HERE" || placeholderSpotifyToken.isEmpty {
             print("🚨🎬 FATAL STARTUP WARNING: Spotify Bearer Token is not set! API calls WILL FAIL.")
             print("👉 FIX: Replace 'YOUR_SPOTIFY_BEARER_TOKEN_HERE' in this file with a valid token.")
             // In a real app, handle this more gracefully, maybe prevent launch or go to login.
         }

        // Optional: Global Appearance (can conflict with SwiftUI settings sometimes)
        // ThemeManager handles preferredColorScheme, which is often better.
    }

    var body: some Scene {
        WindowGroup {
            SpotifyAlbumListView()
                .environmentObject(themeManager) // Inject the manager
                // Set the preferred scheme based on the *selected* theme settings
                .preferredColorScheme(themeManager.currentTheme.colorScheme)
                 // Animate theme transitions globally
                .animation(.easeInOut(duration: 0.3), value: themeManager.currentTheme) // Animate based on settings change
        }
    }
}

// MARK: - Preview Providers (Updated for Theming)

struct SpotifyAlbumListView_Previews: PreviewProvider {
    static var previews: some View {
        SpotifyAlbumListView()
             .environmentObject(ThemeManager()) // Provide a manager for preview
             // Previews often default to light, force dark if needed for specific themes
             // .preferredColorScheme(.dark) // Useful for testing dark-only themes
    }
}

struct ThemeAwareAlbumCard_Previews: PreviewProvider {
    static let mockArtist = Artist(id: "artist1", external_urls: nil, href: "", name: "Miles Davis Mock", type: "artist", uri: "")
    static let mockImage = SpotifyImage(height: 300, url: "https://i.scdn.co/image/ab67616d00001e027ab89c25093ea3787b1995b4", width: 300)
    static let mockAlbumItem = AlbumItem(id: "album1", album_type: "album", total_tracks: 5, available_markets: ["US"], external_urls: ExternalUrls(spotify: ""), href: "", images: [mockImage], name: "Kind of Blue [PREVIEW]", release_date: "1959-08-17", release_date_precision: "day", type: "album", uri: "spotify:album:1weenld61qoidwYuZ1GESA", artists: [mockArtist])

    // Preview with multiple themes
    static var previews: some View {
        Group {
             // Retro Theme Preview
             VStack {
                 Text("Retro Future Theme").font(.caption)
                 ThemeAwareAlbumCard(album: mockAlbumItem)
             }
             .padding()
             .background(ThemeSettings.retroFuture.primaryBackgroundColor)
             .environmentObject(createManager(for: .retro))

             // Vaporwave Theme Preview
             VStack {
                 Text("Vaporwave Theme").font(.caption)
                 ThemeAwareAlbumCard(album: mockAlbumItem)
             }
             .padding()
             .background(ThemeSettings.vaporwaveSunset.primaryBackgroundColor)
             .environmentObject(createManager(for: .vaporwave))

             // System Theme Preview
              VStack {
                 Text("System Theme").font(.caption)
                 ThemeAwareAlbumCard(album: mockAlbumItem)
             }
             .padding()
              // Background determined by system light/dark mode in preview
              .environmentObject(createManager(for: .system))

        }
        .previewLayout(.sizeThatFits) // Adjust layout for multiple previews
    }

    // Helper to create a themed manager for previews
    static func createManager(for theme: AppTheme) -> ThemeManager {
         let manager = ThemeManager()
         manager.changeTheme(to: theme)
         return manager
    }
}

struct AlbumDetailView_Previews: PreviewProvider {
     static let mockArtist = Artist(id: "artist1", external_urls: nil, href: "", name: "Miles Davis Mock", type: "artist", uri: "")
     static let mockImage = SpotifyImage(height: 640, url: "https://i.scdn.co/image/ab67616d0000b2737ab89c25093ea3787b1995b4", width: 640)
     static let mockAlbum = AlbumItem(id: "1weenld61qoidwYuZ1GESA", album_type: "album", total_tracks: 5, available_markets: ["US", "GB"], external_urls: ExternalUrls(spotify: "https://open.spotify.com/album/1weenld61qoidwYuZ1GESA"), href: "", images: [mockImage], name: "Kind Of Blue (Preview)", release_date: "1959-08-17", release_date_precision: "day", type: "album", uri: "spotify:album:1weenld61qoidwYuZ1GESA", artists: [mockArtist])

    static var previews: some View {
        NavigationView {
            AlbumDetailView(album: mockAlbum)
        }
        .environmentObject(ThemeManager()) // Provide default manager
         // Preview specific theme by changing the manager's default or using the helper:
         // .environmentObject(ThemeAwareAlbumCard_Previews.createManager(for: .cyberpunkNight))
    }
}

struct ThemeSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        // Preview the sheet within different themes
        Group {
             ThemeSelectionView()
                 .environmentObject(ThemeAwareAlbumCard_Previews.createManager(for: .retro))
                 .previewDisplayName("Retro Theme")

             ThemeSelectionView()
                  .environmentObject(ThemeAwareAlbumCard_Previews.createManager(for: .light))
                  .previewDisplayName("Light Theme")

             ThemeSelectionView()
                  .environmentObject(ThemeAwareAlbumCard_Previews.createManager(for: .system))
                  .previewDisplayName("System Theme")
        }
    }
}
