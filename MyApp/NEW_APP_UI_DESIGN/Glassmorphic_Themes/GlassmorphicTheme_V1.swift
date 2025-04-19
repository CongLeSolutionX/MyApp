//
//  GlassmorphicTheme_V1.swift
//  MyApp
//  GlassmorphismSpotifyApp.swift
//  SpotifyGlassApp
//
//  Created by AI Language Model on [Current Date]
//  Theme: Glassmorphism with mixed Apple color palettes
//

import SwiftUI
@preconcurrency import WebKit // For Spotify Embed WebView
import Foundation // For Codable, URLSession, etc.

// MARK: - Color Palettes (As provided by user)

/// Palette using the Display P3 color space for potentially more vibrant colors
/// on compatible wide-gamut displays. These are constant colors.
struct DisplayP3Palette {
    /// A vibrant red, potentially outside the standard sRGB gamut.
    static let vibrantRed: Color = Color(.displayP3, red: 1.0, green: 0.1, blue: 0.1, opacity: 1.0)
    
    /// A lush green, potentially more saturated than standard sRGB greens.
    static let lushGreen: Color = Color(.displayP3, red: 0.1, green: 0.9, blue: 0.2, opacity: 1.0)
    
    /// A deep P3 blue.
    static let deepBlue: Color = Color(.displayP3, red: 0.1, green: 0.2, blue: 0.95, opacity: 1.0)
    
    /// A bright P3 magenta.
    static let brightMagenta: Color = Color(.displayP3, red: 0.95, green: 0.1, blue: 0.8, opacity: 1.0)
}

/// Palette demonstrating the use of extended range values (outside 0.0-1.0).
/// The visual effect heavily depends on the display's capabilities and how
/// the system renders these values. These are constant colors.
struct ExtendedRangePalette {
    /// An 'ultra' white using a value greater than 1.0 (effect varies by display/context).
    /// On HDR displays, this might appear brighter than standard white.
    static let ultraWhite: Color = Color(.sRGB, white: 1.1, opacity: 1.0) // Note: Value > 1.0
                                                                          // Clamp to 1.0 for standard displays
                                                                          // static let ultraWhite: Color = Color.white
    
    /// A potentially more intense red by exceeding the 1.0 limit for the red component.
    static let intenseRed: Color = Color(.sRGB, red: 1.2, green: 0, blue: 0, opacity: 1.0) // Note: Value > 1.0
                                                                                            // Clamp to 1.0 for standard displays
                                                                                            // static let intenseRed: Color = Color(red: 1.0, green: 0, blue: 0)
    
    /// A potentially darker-than-black using a negative value (effect varies).
    /// This might just clamp to black (0.0) on standard displays.
    static let deeperThanBlack: Color = Color(.sRGB, white: -0.1, opacity: 1.0) // Note: Value < 0.0
                                                                                 // Clamp to 0.0 for standard displays
                                                                                 // static let deeperThanBlack: Color = Color.black
}

/// Standard HSB Palette for comparison and completeness (Constant Colors)
struct HSBPalette {
    static let sunshineYellow: Color = Color(hue: 0.15, saturation: 0.9, brightness: 1.0) // 54 degrees
    static let skyBlue: Color = Color(hue: 0.6, saturation: 0.7, brightness: 0.9)       // 216 degrees
    static let forestGreen: Color = Color(hue: 0.35, saturation: 0.8, brightness: 0.6)   // 126 degrees
    static let fieryOrange: Color = Color(hue: 0.08, saturation: 1.0, brightness: 1.0)   // 29 degrees
}

/// Standard Grayscale Palette (Constant Colors)
struct GrayscalePalette {
    static let lightGray: Color = Color(white: 0.8)
    static let mediumGray: Color = Color(white: 0.5)
    static let darkGray: Color = Color(white: 0.2)
    static let offWhite: Color = Color(white: 0.95)
    static let nearBlack: Color = Color(white: 0.1)
}

// MARK: - Glassmorphism Theme Constants & Helpers

struct GlassmorphicTheme {
    // --- Background ---
    // Use a vibrant gradient mixing P3 and HSB colors
    static let backgroundGradient = LinearGradient(
        gradient: Gradient(colors: [
            DisplayP3Palette.deepBlue.opacity(0.8), // Start Blue
            DisplayP3Palette.brightMagenta.opacity(0.6), // Transition Magenta
            HSBPalette.fieryOrange.opacity(0.7) // End Orange
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // --- Glass Effect ---
    static let glassBackgroundFill: Material = .thinMaterial // Use system materials for adaptive blur
    // static let glassBackgroundFill: Material = .ultraThinMaterial // Alternative thinner material
    // static let glassBackgroundColor: Color = GrayscalePalette.offWhite.opacity(0.15) // Subtle white tint if not using Material
    static let glassBorderColor: Color = GrayscalePalette.lightGray.opacity(0.25)
    static let glassCornerRadius: CGFloat = 20
    static let glassBorderWidth: CGFloat = 1.0
    
    // --- Text & Icons ---
    static let primaryText: Color = GrayscalePalette.offWhite // Use off-white for less harshness
    static let secondaryText: Color = GrayscalePalette.lightGray.opacity(0.8)
    
    // --- Accents ---
    static let accentColor: Color = HSBPalette.sunshineYellow // Bright yellow for selected items/links
    static let selectedHighlight: Color = HSBPalette.sunshineYellow.opacity(0.15) // Subtle highlight for selected rows
    static let errorColor: Color = DisplayP3Palette.vibrantRed
    
    // --- Fonts ---
    static func appFont(size: CGFloat, weight: Font.Weight = .regular, design: Font.Design = .default) -> Font {
        return Font.system(size: size, weight: weight, design: design)
    }
}

//MARK: - Glassmorphism View Modifier

struct GlassBackground: ViewModifier {
    let cornerRadius: CGFloat = GlassmorphicTheme.glassCornerRadius
    let material: Material = GlassmorphicTheme.glassBackgroundFill
    
    func body(content: Content) -> some View {
        content
        // Apply padding *inside* the background for content spacing
            .padding()
            .background(material) // Apply the material background (includes blur)
            .cornerRadius(cornerRadius)
            .overlay( // Add the subtle border
                 RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(GlassmorphicTheme.glassBorderColor, lineWidth: GlassmorphicTheme.glassBorderWidth)
             )
            // Add a subtle shadow for depth (optional)
            // .shadow(color: GrayscalePalette.nearBlack.opacity(0.15), radius: 10, x: 0, y: 5)
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
        // Prefer slightly smaller image for list view to save bandwidth
        images.first { $0.width == 300 }?.urlObject ??
        images.first { $0.width == 64 }?.urlObject ??
        images.first?.urlObject
    }
    
    var formattedArtists: String {
        artists.map { $0.name }.joined(separator: ", ")
    }
    
    func formattedReleaseDate() -> String {
        let dateFormatter = DateFormatter()
        switch release_date_precision {
        case "year":
            dateFormatter.dateFormat = "yyyy"
            if let date = dateFormatter.date(from: release_date) {
                return dateFormatter.string(from: date)
            }
        case "month":
            dateFormatter.dateFormat = "yyyy-MM"
            if let date = dateFormatter.date(from: release_date) {
                dateFormatter.dateFormat = "MMM yyyy" // e.g., Aug 1959
                return dateFormatter.string(from: date)
            }
        case "day":
            dateFormatter.dateFormat = "yyyy-MM-dd"
            if let date = dateFormatter.date(from: release_date) {
                dateFormatter.dateFormat = "d MMM yyyy" // e.g., 17 Aug 1959
                return dateFormatter.string(from: date)
            }
        default: break
        }
        return release_date // Fallback
    }
}

struct Artist: Codable, Identifiable, Hashable {
    let id: String
    let external_urls: ExternalUrls? // Make optional if sometimes missing
    let href: String
    let name: String
    let type: String // "artist"
    let uri: String
}

struct SpotifyImage: Codable, Hashable {
    let height: Int?
    let url: String
    let width: Int?
    var urlObject: URL? { URL(string: url) }
}

struct ExternalUrls: Codable, Hashable {
    let spotify: String? // Make optional if sometimes missing
}

struct AlbumTracksResponse: Codable, Hashable {
    let items: [Track]
    // Add other fields like href, limit, next, offset, previous, total if needed
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
    let preview_url: String?
    let track_number: Int
    let type: String // "track"
    let uri: String
    
    var previewURL: URL? { if let url = preview_url { return URL(string: url)} else {return nil} }
    
    var formattedDuration: String {
        let totalSeconds = duration_ms / 1000
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    var formattedArtists: String {
        artists.map { $0.name }.joined(separator: ", ")
    }
}

// MARK: - API Service (Unchanged)

// IMPORTANT: Replace this with your actual Spotify Bearer Token
let placeholderSpotifyToken = "YOUR_SPOTIFY_BEARER_TOKEN_HERE"

enum SpotifyAPIError: Error, LocalizedError {
    case invalidURL
    case networkError(Error)
    case invalidResponse(Int, String?)
    case decodingError(Error)
    case invalidToken
    case missingData
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid API URL setup."
        case .networkError(let error): return "Network connection issue: \(error.localizedDescription)"
        case .invalidResponse(let code, _): return "Server error (\(code)). Please try again later."
        case .decodingError: return "Failed to understand server response."
        case .invalidToken: return "Authentication failed. Check API Token."
        case .missingData: return "Response missing expected data."
        }
    }
}

struct SpotifyAPIService {
    static let shared = SpotifyAPIService()
    private let session: URLSession
    
    init() {
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        session = URLSession(configuration: configuration)
    }
    
    private func makeRequest<T: Decodable>(url: URL) async throws -> T {
        guard !placeholderSpotifyToken.isEmpty, placeholderSpotifyToken != "YOUR_SPOTIFY_BEARER_TOKEN_HERE" else {
            print("🚫 Error: Spotify Bearer Token is missing or placeholder.")
            throw SpotifyAPIError.invalidToken
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(placeholderSpotifyToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 20
        
        print("🎶 Requesting: \(url.absoluteString)")
        
        do {
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else { throw SpotifyAPIError.invalidResponse(0, "Not HTTP response.") }
            
            print("🚦 HTTP Status: \(httpResponse.statusCode)")
            let responseBody = String(data: data, encoding: .utf8) ?? "N/A"
            
            guard (200...299).contains(httpResponse.statusCode) else {
                if httpResponse.statusCode == 401 { throw SpotifyAPIError.invalidToken }
                print("❌ Server Error Body: \(responseBody)")
                throw SpotifyAPIError.invalidResponse(httpResponse.statusCode, responseBody)
            }
            do {
                let decoder = JSONDecoder()
                return try decoder.decode(T.self, from: data)
            } catch {
                print("❌ Decoding Error for \(T.self): \(error)")
                print("   Response Body: \(responseBody)")
                throw SpotifyAPIError.decodingError(error)
            }
        } catch let error where !(error is CancellationError) {
            print("❌ Network Error: \(error)")
            throw error is SpotifyAPIError ? error : SpotifyAPIError.networkError(error)
        }
    }
    
    func searchAlbums(query: String, limit: Int = 20, offset: Int = 0) async throws -> SpotifySearchResponse {
        var components = URLComponents(string: "https://api.spotify.com/v1/search")
        components?.queryItems = [
            URLQueryItem(name: "q", value: query), URLQueryItem(name: "type", value: "album"),
            URLQueryItem(name: "include_external", value: "audio"), URLQueryItem(name: "limit", value: "\(limit)"),
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

// MARK: - Spotify Embed WebView (Theme Adjustments)

final class SpotifyPlaybackState: ObservableObject {
    @Published var isPlaying: Bool = false
    @Published var currentPosition: Double = 0 // seconds
    @Published var duration: Double = 0 // seconds
    @Published var currentUri: String = ""
    @Published var isReady: Bool = false // Track readiness
    @Published var error: String? = nil // Track embed errors
}

struct SpotifyEmbedWebView: UIViewRepresentable {
    @ObservedObject var playbackState: SpotifyPlaybackState
    let spotifyUri: String? // URI to load
    
    func makeCoordinator() -> Coordinator { Coordinator(self) }
    
    func makeUIView(context: Context) -> WKWebView {
        let userContentController = WKUserContentController()
        userContentController.add(context.coordinator, name: "spotifyController")
        
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = userContentController
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.isOpaque = false
        webView.backgroundColor = .clear // KEEP CLEAR for glassmorphism
        webView.scrollView.backgroundColor = .clear // KEEP CLEAR
        webView.scrollView.isScrollEnabled = false
        
        webView.loadHTMLString(generateHTML(), baseURL: nil)
        context.coordinator.webView = webView
        print("🔨 Spotify Embed WebView: makeUIView completed.")
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        print("🔄 Spotify Embed WebView: updateUIView. API Ready: \(context.coordinator.isApiReady), Desired URI: \(spotifyUri ?? "nil")")
        if context.coordinator.isApiReady && context.coordinator.lastLoadedUri != spotifyUri && spotifyUri != nil {
            print(" -> Loading URI in updateUIView.")
            context.coordinator.loadUri(spotifyUri!)
        } else if !context.coordinator.isApiReady {
            context.coordinator.updateDesiredUriBeforeReady(spotifyUri)
        }
    }
    
    static func dismantleUIView(_ webView: WKWebView, coordinator: Coordinator) {
        print("🧹 Spotify Embed WebView: Dismantling.")
        webView.stopLoading()
        webView.configuration.userContentController.removeScriptMessageHandler(forName: "spotifyController")
        coordinator.webView = nil
    }
    
    // --- Coordinator Class (Mostly Unchanged Logic) ---
    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
        var parent: SpotifyEmbedWebView
        weak var webView: WKWebView?
        var isApiReady = false
        var lastLoadedUri: String?
        private var desiredUriBeforeReady: String? = nil
        
        init(_ parent: SpotifyEmbedWebView) { self.parent = parent }
        
        func updateDesiredUriBeforeReady(_ uri: String?) {
            if !isApiReady {
                desiredUriBeforeReady = uri
                print("📥 Spotify Embed Coordinator: Storing desired URI before ready: \(uri ?? "nil")")
            }
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            print("📄 Spotify Embed WebView: HTML content finished loading.")
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print("❌ Spotify Embed WebView: Nav failed: \(error.localizedDescription)")
            DispatchQueue.main.async { self.parent.playbackState.error = "Nav failed: \(error.localizedDescription)" }
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
             print("❌ Spotify Embed WebView: Provisional Nav failed: \(error.localizedDescription)")
            DispatchQueue.main.async { self.parent.playbackState.error = "Provisional Nav failed: \(error.localizedDescription)" }
        }
        
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            guard message.name == "spotifyController" else { return }
            
             if let bodyDict = message.body as? [String: Any], let event = bodyDict["event"] as? String {
                 print("📩 JS Event: '\(event)' Data: \(bodyDict)")
                 handleEvent(event: event, data: bodyDict["data"])
             } else if let bodyString = message.body as? String {
                 print("📩 JS Message: '\(bodyString)'")
                 if bodyString == "ready" { handleApiReady() }
                 else { print("❓ Spotify Embed Native: Unknown JS string message: \(bodyString)") }
             } else {
                 print("❓ Spotify Embed Native: Unknown JS message format: \(message.body)")
             }
        }
        
        private func handleApiReady() {
            print("✅ Spotify Embed Native: Spotify IFrame API reported READY.")
            isApiReady = true
            DispatchQueue.main.async { self.parent.playbackState.isReady = true }
            
            if let initialUri = desiredUriBeforeReady ?? parent.spotifyUri, !initialUri.isEmpty {
                createSpotifyController(with: initialUri)
                 desiredUriBeforeReady = nil
            } else {
                print("⚠️ Spotify Embed Native: API Ready, but no initial URI to load.")
            }
        }
        
        private func handleEvent(event: String, data: Any?) {
            switch event {
            case "controllerCreated":
                print("✅ Spotify Embed Native: Embed controller created.")
            case "playbackUpdate":
                if let updateData = data as? [String: Any] { updatePlaybackState(with: updateData) }
            case "error":
                 let errorMessage = (data as? [String: Any])?["message"] as? String ?? (data as? String) ?? "Unknown JS error"
                print("❌ Spotify Embed JS Error: \(errorMessage)")
                DispatchQueue.main.async { self.parent.playbackState.error = errorMessage }
            default:
                print("❓ Spotify Embed Native: Received unknown event type: \(event)")
            }
        }
        
        private func updatePlaybackState(with data: [String: Any]) {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                var stateChanged = false
                
                if let isPaused = data["isPaused"] as? Bool { // Note: API uses isPaused
                     if self.parent.playbackState.isPlaying == isPaused {
                         self.parent.playbackState.isPlaying = !isPaused
                         stateChanged = true
                     }
                 }
                if let posMs = data["position"] as? Double {
                    let newPosition = posMs / 1000.0
                    if abs(self.parent.playbackState.currentPosition - newPosition) > 0.1 {
                        self.parent.playbackState.currentPosition = newPosition
                        stateChanged = true
                    }
                }
                if let durMs = data["duration"] as? Double {
                    let newDuration = durMs / 1000.0
                    if abs(self.parent.playbackState.duration - newDuration) > 0.1 || self.parent.playbackState.duration == 0 {
                        self.parent.playbackState.duration = newDuration
                        stateChanged = true
                    }
                }
                if let uri = data["context_uri"] as? String ?? data["uri"] as? String, self.parent.playbackState.currentUri != uri {
                     self.parent.playbackState.currentUri = uri
                     self.parent.playbackState.currentPosition = 0
                     self.parent.playbackState.duration = data["duration"] as? Double ?? 0
                     stateChanged = true
                     print("ℹ️ Playback updated URI: \(uri)")
                 }
                
                if stateChanged && self.parent.playbackState.error != nil {
                    self.parent.playbackState.error = nil // Clear error on successful update
                     print("ℹ️ Playback state updated.")
                }
            }
        }
        
        private func createSpotifyController(with initialUri: String) {
            guard let webView = webView, isApiReady else {
                print("⚠️ Spotify Embed Native: Cannot create controller - WebView or API not ready."); return
            }
            guard lastLoadedUri == nil || lastLoadedUri != initialUri else {
                print("ℹ️ Spotify Embed Native: Controller already initialized or target URI same. Skipping."); return
            }
            
            print("🚀 Spotify Embed Native: Attempting to create controller for URI: \(initialUri)")
            lastLoadedUri = initialUri
            
            let script = """
            console.log('JS: Running create controller script.'); window.embedController = null;
            const element = document.getElementById('embed-iframe'); const options = { uri: '\(initialUri)', width: '100%', height: '100%' };
            if (!element || !window.IFrameAPI) { console.error('JS Error: Element or API missing!'); window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'HTML element or API not found' }}); return; }
            window.IFrameAPI.createController(element, options, (controller) => {
                if (!controller) { console.error('JS Error: createController callback null!'); window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'JS received null controller' }}); return; }
                console.log('✅ JS: Controller instance received.'); window.embedController = controller;
                window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'controllerCreated' });
                controller.addListener('ready', () => { console.log('🎧 JS Event: Controller Ready.'); });
                controller.addListener('playback_update', e => { window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'playbackUpdate', data: e.data }); });
                controller.addListener('error', e => { console.error('💥 JS Event: Playback Error:', e.data); window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'Playback Error: ' + (e.data?.message ?? 'Unknown Error') }}); });
            });
            """
            webView.evaluateJavaScript(script) { _, error in
                if let error = error { print("⚠️ Spotify Native: Error evaluating JS for create controller: \(error.localizedDescription)") }
            }
        }
        
        func loadUri(_ uri: String) {
            guard let webView = webView, isApiReady else { return }
            guard uri != lastLoadedUri else { print("ℹ️ Skipping loadUri, already loaded: \(uri)"); return }
            
            print("🚀 Spotify Embed Native: Loading new URI via JS: \(uri)")
            lastLoadedUri = uri
            
            let script = """
            if (window.embedController) { console.log('JS: Loading URI: \(uri)'); window.embedController.loadUri('\(uri)'); }
            else { console.error('JS Error: embedController missing for loadUri \(uri).'); window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'JS embedController missing during loadUri' }}); }
            """
            webView.evaluateJavaScript(script) { _, error in
                if let error = error { print("⚠️ Spotify Native: Error evaluating JS load URI \(uri): \(error.localizedDescription)") }
            }
        }
        
        // Optional helper
        func executeJsCommand(_ command: String) {
            guard let webView = webView, lastLoadedUri != nil else { return }
            print("▶️ Spotify Embed Native: Executing JS command: \(command)")
            let script = "if (window.embedController) { window.embedController.\(command)(); } else { console.warn('JS Warning: Controller not ready for command \(command)'); }"
            webView.evaluateJavaScript(script) { _, error in
                if let error = error { print("⚠️ Spotify Native: Error running JS command \(command): \(error.localizedDescription)") }
            }
        }
        
        func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
             print("ℹ️ JS Alert: \(message)")
             completionHandler()
         }
    }
    
    // --- Generate HTML (Unchanged) ---
    private func generateHTML() -> String {
        return """
        <!DOCTYPE html><html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no"><title>G Spot Embed</title><style>html, body { margin: 0; padding: 0; width: 100%; height: 100%; overflow: hidden; background-color: transparent; } #embed-iframe { width: 100%; height: 100%; box-sizing: border-box; display: block; border: none; }</style></head><body><div id="embed-iframe"></div><script src="https://open.spotify.com/embed/iframe-api/v1" async></script><script> console.log('JS: Initial script.'); var apiReady = false; window.onSpotifyIframeApiReady = (IFrameAPI) => { if (apiReady) return; apiReady = true; console.log('✅ JS Spot API Ready.'); window.IFrameAPI = IFrameAPI; window.webkit?.messageHandlers?.spotifyController?.postMessage("ready"); }; const scriptTag = document.querySelector('script[src*="iframe-api"]'); scriptTag.onerror = (e) => { console.error('❌ JS: Fail load Spot API script:', e); window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'Fail load Spot API script' }}); }; </script></body></html>
        """
    }
}

// MARK: - SwiftUI Views (Glassmorphism Themed)

// MARK: Main List View
struct SpotifyAlbumListView: View {
    @State private var searchQuery: String = ""
    @State private var displayedAlbums: [AlbumItem] = []
    @State private var isLoading: Bool = false
    @State private var searchInfo: Albums? = nil
    @State private var currentError: SpotifyAPIError? = nil
    
    var body: some View {
        NavigationView {
            ZStack {
                // --- Background Gradient ---
                GlassmorphicTheme.backgroundGradient.ignoresSafeArea()
                
                // --- Content Area ---
                VStack(spacing: 0) {
                    // --- Search Metadata (Subtle Text) ---
                    if let info = searchInfo, info.total > 0 {
                        SearchMetadataHeader(totalResults: info.total, limit: info.limit, offset: info.offset)
                            .padding(.horizontal)
                             .padding(.top, 5) // Space from title/margin
                    }
                    
                    // --- Conditional Content ---
                    Group {
                        if isLoading && displayedAlbums.isEmpty {
                            loadingIndicator
                        } else if let error = currentError {
                            ErrorPlaceholderView(error: error) {
                                Task { await performDebouncedSearch(immediate: true) }
                            }
                        } else if displayedAlbums.isEmpty && !searchQuery.isEmpty {
                            EmptyStatePlaceholderView(searchQuery: searchQuery)
                        } else if displayedAlbums.isEmpty && searchQuery.isEmpty {
                             EmptyStatePlaceholderView(searchQuery: "")
                        } else {
                            albumListView // Use ScrollView for custom cards
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity) // Fill remaining space
                }
                
            } // End ZStack
            .navigationTitle("Spotify Glass Search")
            .navigationBarTitleDisplayMode(.large)
            // --- Search Bar ---
            .searchable(text: $searchQuery,
                        placement: .navigationBarDrawer(displayMode: .always),
                        prompt: Text("Search albums / artists...").foregroundColor(GlassmorphicTheme.secondaryText))
            .onSubmit(of: .search) { Task { await performDebouncedSearch(immediate: true) } }
            .task(id: searchQuery) { await performDebouncedSearch() } // Debounced search
            .onChange(of: searchQuery) { if currentError != nil { currentError = nil } } // Clear error on new typing
            .accentColor(GlassmorphicTheme.accentColor) // Tint cursor/cancel button
            // --- Theme Nav Bar ---
            .toolbarBackground(.hidden, for: .navigationBar) // Make nav bar transparent
        } // End NavigationView
        .navigationViewStyle(.stack)
        // .preferredColorScheme(.dark) // Let system decide, or force dark if needed
    }
    
    // --- Glassmorphic Album List ---
    private var albumListView: some View {
        ScrollView {
            LazyVStack(spacing: 18) { // Spacing between glass cards
                ForEach(displayedAlbums) { album in
                    NavigationLink(destination: AlbumDetailView(album: album)) {
                        GlassAlbumCard(album: album)
                    }
                    .buttonStyle(.plain) // Ensure natural link behavior
                }
            }
            .padding() // Padding around the entire scroll content
        }
        .scrollDismissesKeyboard(.interactively)
        .refreshable { await performDebouncedSearch(immediate: true) } // Pull to refresh
    }
    
    // --- Loading Indicator ---
    private var loadingIndicator: some View {
        VStack(spacing: 10) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: GlassmorphicTheme.accentColor))
                .scaleEffect(1.5)
            Text("Searching Spotify...")
                .font(GlassmorphicTheme.appFont(size: 14))
                .foregroundColor(GlassmorphicTheme.secondaryText)
        }
    }
    
    // --- Debounced Search Logic (Unchanged) ---
    private func performDebouncedSearch(immediate: Bool = false) async {
        let trimmedQuery = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else {
            Task { @MainActor in displayedAlbums = []; searchInfo = nil; isLoading = false; currentError = nil }
            return
        }
        
        Task { @MainActor in isLoading = true }
        
        if !immediate {
             do { try await Task.sleep(for: .milliseconds(500)); try Task.checkCancellation() }
            catch { print("Search task cancelled (debounce)."); Task { @MainActor in isLoading = false }; return }
        }
        
        guard trimmedQuery == searchQuery.trimmingCharacters(in: .whitespacesAndNewlines) else {
             print("Search query changed, skipping."); Task { @MainActor in isLoading = false }; return
        }
        
        do {
            print("🚀 Performing search: \(trimmedQuery)")
            let response = try await SpotifyAPIService.shared.searchAlbums(query: trimmedQuery, limit: 20, offset: 0)
            try Task.checkCancellation()
            await MainActor.run {
                displayedAlbums = response.albums.items
                searchInfo = response.albums
                currentError = nil
                 isLoading = false
                print("✅ Search ok, \(response.albums.items.count) items.")
            }
        } catch is CancellationError {
            print("Search task cancelled."); await MainActor.run { isLoading = false }
        } catch let apiError as SpotifyAPIError {
            print("❌ API Error: \(apiError.localizedDescription)")
            await MainActor.run { displayedAlbums = []; searchInfo = nil; currentError = apiError; isLoading = false }
        } catch {
            print("❌ Unexpected Error: \(error.localizedDescription)")
            await MainActor.run { displayedAlbums = []; searchInfo = nil; currentError = .networkError(error); isLoading = false }
        }
    }
}

// MARK: Glass Album Card
struct GlassAlbumCard: View {
    let album: AlbumItem
    
    var body: some View {
        HStack(spacing: 15) {
            // --- Album Art ---
            AlbumImageView(url: album.listImageURL)
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 12)) // Rounded corners for image
                 // Add a very subtle inner glow/border if needed
                 // .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.1), lineWidth: 0.5))

            // --- Text Details ---
            VStack(alignment: .leading, spacing: 4) {
                Text(album.name)
                    .font(GlassmorphicTheme.appFont(size: 15, weight: .semibold))
                    .foregroundColor(GlassmorphicTheme.primaryText)
                    .lineLimit(2)
                
                Text(album.formattedArtists)
                    .font(GlassmorphicTheme.appFont(size: 13))
                    .foregroundColor(GlassmorphicTheme.secondaryText)
                    .lineLimit(1)
                
                Spacer() // Push bottom info down
                
                HStack(spacing: 8) {
                    Text(album.album_type.capitalized)
                        .font(GlassmorphicTheme.appFont(size: 10, weight: .medium))
                        .foregroundColor(GlassmorphicTheme.secondaryText)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                         // Use a subtle capsule background, maybe slightly glass-like itself
                        .background(GlassmorphicTheme.glassBackgroundFill.opacity(0.5), in: Capsule()) // Use material with opacity
                         .overlay(Capsule().stroke(GlassmorphicTheme.glassBorderColor.opacity(0.5), lineWidth: 0.5))

                    Text("• \(album.formattedReleaseDate())")
                        .font(GlassmorphicTheme.appFont(size: 10, weight: .medium))
                        .foregroundColor(GlassmorphicTheme.secondaryText)
                }
                Text("\(album.total_tracks) Tracks")
                        .font(GlassmorphicTheme.appFont(size: 10, weight: .medium))
                        .foregroundColor(GlassmorphicTheme.secondaryText)
                        .padding(.top, 1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
        } // End HStack
        // Apply glass modifier to the whole card
        .modifier(GlassBackground())
        // Make height consistent if needed (though dynamic height might be better)
        // .frame(height: 110)
    }
}

// MARK: Placeholders (Themed)
struct ErrorPlaceholderView: View {
    let error: SpotifyAPIError
    let retryAction: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 20) {
             Image(systemName: iconName)
                .font(.system(size: 50))
                .foregroundColor(GlassmorphicTheme.errorColor)
                .padding(.bottom, 15)
            
            Text("Error")
                .font(GlassmorphicTheme.appFont(size: 20, weight: .bold))
                .foregroundColor(GlassmorphicTheme.primaryText)
            
            Text(errorMessage)
                .font(GlassmorphicTheme.appFont(size: 14))
                .foregroundColor(GlassmorphicTheme.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
            
            // --- Retry Button ---
            switch error {
            case .invalidToken:
                Text("Please provide a valid API token in the code and restart the app.")
                    .font(GlassmorphicTheme.appFont(size: 13))
                    .foregroundColor(GlassmorphicTheme.errorColor.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
            default:
                if let action = retryAction {
                     Button { action() } label: {
                         Label("Try Again", systemImage: "arrow.clockwise")
                    }
                    .buttonStyle(.borderedProminent) // Standard prominent button
                    .tint(GlassmorphicTheme.accentColor.opacity(0.8)) // Use accent
                    .padding(.top, 10)
                }
            }
        }
        .padding(40)
        // Apply glass background to the error container itself
         .modifier(GlassBackground())
         .frame(maxWidth: 400) // Limit width
    }
    
    // --- Helper properties ---
    private var iconName: String {
          switch error {
          case .invalidToken: return "key.slash"
          case .networkError: return "wifi.slash"
          case .invalidResponse, .decodingError, .missingData: return "exclamationmark.triangle.fill"
          case .invalidURL: return "link.badge.questionmark"
          }
    }
    private var errorMessage: String { error.localizedDescription }
}

struct EmptyStatePlaceholderView: View {
    let searchQuery: String
    
    var body: some View {
         VStack(spacing: 20) {
             Image(placeholderImageName) // Assume these images exist
                 .resizable()
                 .aspectRatio(contentMode: .fit)
                 .frame(height: 130)
                 .opacity(0.8)
                 .padding(.bottom, 15)

            Text(title)
                .font(GlassmorphicTheme.appFont(size: 20, weight: .bold))
                .foregroundColor(GlassmorphicTheme.primaryText)

            Text(messageAttributedString)
                .font(GlassmorphicTheme.appFont(size: 14))
                .foregroundColor(GlassmorphicTheme.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .padding(30)
         // Only apply glass if it's the "No Results" state, keep initial state clean
        .modifier(GlassBackground().animation(.easeInOut(duration: 0.2)))
         //.modifier(GlassBackground(cornerRadius: 25).opacity(isInitialState ? 0 : 1))
    }
    
    // --- Helper properties ---
    private var isInitialState: Bool { searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    private var placeholderImageName: String { isInitialState ? "My-meme-microphone" : "My-meme-orange_2" } // Use provided names
    private var title: String { isInitialState ? "Spotify Glass Search" : "No Results Found" }
    
    private var messageAttributedString: AttributedString {
         var messageText: String = isInitialState ? "Enter an album or artist name\nto begin exploring..." : "No matches found for \"\(searchQuery)\". Try different keywords?"
        var attributedString = AttributedString(messageText)
        attributedString.font = GlassmorphicTheme.appFont(size: 14)
        attributedString.foregroundColor = GlassmorphicTheme.secondaryText
        
        // Highlight search query if needed
        if !isInitialState, let range = attributedString.range(of: "\"\(searchQuery)\"") {
             attributedString[range].font = GlassmorphicTheme.appFont(size: 14, weight: .semibold)
             attributedString[range].foregroundColor = GlassmorphicTheme.primaryText.opacity(0.9)
         }
        
        return attributedString
    }
}

// MARK: Album Detail View
struct AlbumDetailView: View {
    let album: AlbumItem
    @State private var tracks: [Track] = []
    @State private var isLoadingTracks: Bool = false
    @State private var trackFetchError: SpotifyAPIError? = nil
    @State private var selectedTrackUri: String? = nil
    @StateObject private var playbackState = SpotifyPlaybackState()
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            // --- Background Gradient ---
            GlassmorphicTheme.backgroundGradient.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 25) { // Consistent spacing
                    // --- Header (Not glass, sits on main background) ---
                    AlbumHeaderView(album: album)
                        .padding(.top, 10)
                    
                    // --- Player ---
                    if selectedTrackUri != nil {
                        SpotifyEmbedPlayerView(playbackState: playbackState, spotifyUri: selectedTrackUri)
                            .padding(.horizontal)
                            .transition(.opacity.combined(with: .scale(scale: 0.95, anchor: .top)))
                            .animation(.easeInOut(duration: 0.3), value: selectedTrackUri)
                    }
                    
                    // --- Tracks List (Glass container) ---
                    TracksSectionView(
                        tracks: tracks,
                        isLoading: isLoadingTracks,
                        error: trackFetchError,
                        selectedTrackUri: $selectedTrackUri,
                        retryAction: { Task { await fetchTracks() } }
                    )
                    .padding(.horizontal) // Padding around the glass element
                    
                    // --- External Link Button ---
                    if let spotifyURL = URL(string: album.external_urls.spotify ?? "") {
                        ExternalLinkButton(url: spotifyURL)
                            .padding(.horizontal, 40) // Center button more centrally
                    }
                    
                } // End Main VStack
                .padding(.bottom, 30)// Bottom padding for scroll content
            } // End ScrollView
        } // End ZStack
        .navigationTitle("") // Hide title text, let header handle it
        .navigationBarTitleDisplayMode(.inline) // Keep nav bar compact
        .navigationBarBackButtonHidden(false) // Use standard back button
        .toolbarBackground(.hidden, for: .navigationBar) // Transparent nav bar
        .tint(GlassmorphicTheme.accentColor) // Tint back button
        // --- Data Fetching Task ---
        .task { await fetchTracks() }
    }
    
    // --- Fetch Tracks Logic (Unchanged) ---
    private func fetchTracks(forceReload: Bool = false) async {
        guard forceReload || tracks.isEmpty || trackFetchError != nil else { return }
        await MainActor.run { isLoadingTracks = true; trackFetchError = nil }
        do {
            let response = try await SpotifyAPIService.shared.getAlbumTracks(albumId: album.id)
            try Task.checkCancellation()
            await MainActor.run { self.tracks = response.items; self.isLoadingTracks = false }
        } catch is CancellationError { await MainActor.run { isLoadingTracks = false } } catch let apiError as SpotifyAPIError { await MainActor.run { self.trackFetchError = apiError; self.isLoadingTracks = false; self.tracks = [] } } catch { await MainActor.run { self.trackFetchError = .networkError(error); self.isLoadingTracks = false; self.tracks = [] } }
    }
}

// MARK: Detail View Sub-Components (Themed)

struct AlbumHeaderView: View {
    let album: AlbumItem
    
    var body: some View {
        VStack(spacing: 15) {
            // --- Album Image (Large, Simple Rounded) ---
             AlbumImageView(url: album.bestImageURL)
                .aspectRatio(1.0, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: GlassmorphicTheme.glassCornerRadius))
                // Add a subtle shadow directly to the image for depth
                .shadow(color: GrayscalePalette.nearBlack.opacity(0.2), radius: 12, x: 0, y: 6)
                .padding(.horizontal, 40)

            // --- Text Details ---
            VStack(spacing: 4) {
                Text(album.name)
                    .font(GlassmorphicTheme.appFont(size: 22, weight: .bold))
                    .foregroundColor(GlassmorphicTheme.primaryText)
                    .multilineTextAlignment(.center)
                
                Text("by \(album.formattedArtists)")
                    .font(GlassmorphicTheme.appFont(size: 16))
                    .foregroundColor(GlassmorphicTheme.secondaryText)
                    .multilineTextAlignment(.center)
                
                Text("\(album.album_type.capitalized) • \(album.formattedReleaseDate())")
                    .font(GlassmorphicTheme.appFont(size: 13, weight: .medium))
                    .foregroundColor(GlassmorphicTheme.secondaryText.opacity(0.8))
            }
            .padding(.horizontal)
        }
    }
}

struct SpotifyEmbedPlayerView: View {
    @ObservedObject var playbackState: SpotifyPlaybackState
    let spotifyUri: String?
    
    var body: some View {
        VStack(spacing: 8) {
            // --- WebView Embed (Rounded) ---
            SpotifyEmbedWebView(playbackState: playbackState, spotifyUri: spotifyUri)
                .frame(height: 80)
                .clipShape(RoundedRectangle(cornerRadius: GlassmorphicTheme.glassCornerRadius - 5)) // Slightly less radius than container
                .disabled(!playbackState.isReady)
                .overlay( // Overlay directly on webview
                    Group {
                        if !playbackState.isReady {
                            ProgressView().tint(GlassmorphicTheme.accentColor)
                        } else if let error = playbackState.error {
                             VStack {
                                 Image(systemName: "exclamationmark.triangle.fill").foregroundColor(GlassmorphicTheme.errorColor)
                                Text(error).font(.caption).foregroundColor(GlassmorphicTheme.errorColor).lineLimit(1) }
                             .padding(5).background(.ultraThinMaterial) // Give error its own subtle glass
                        }
                    }
                 )
            // --- Playback Status Text ---
            HStack {
                 if let error = playbackState.error, !error.isEmpty {
                     Text("Player Error").font(GlassmorphicTheme.appFont(size: 10, weight: .medium)).foregroundColor(GlassmorphicTheme.errorColor).lineLimit(1)
                         .frame(maxWidth: .infinity, alignment: .leading)
                 } else if !playbackState.isReady {
                     Text("Loading Player...").font(GlassmorphicTheme.appFont(size: 10, weight: .medium)).foregroundColor(GlassmorphicTheme.secondaryText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else if playbackState.duration > 0.1 {
                    Text(playbackState.isPlaying ? "Playing" : "Paused")
                         .font(GlassmorphicTheme.appFont(size: 10, weight: .medium))
                         .foregroundColor(playbackState.isPlaying ? GlassmorphicTheme.accentColor : GlassmorphicTheme.secondaryText)
                    Spacer()
                    Text("\(formatTime(playbackState.currentPosition)) / \(formatTime(playbackState.duration))")
                        .font(GlassmorphicTheme.appFont(size: 10, weight: .medium))
                        .foregroundColor(GlassmorphicTheme.secondaryText)
                        .frame(width: 90, alignment: .trailing)
                } else {
                    Text("Ready").font(GlassmorphicTheme.appFont(size: 10, weight: .medium)).foregroundColor(GlassmorphicTheme.secondaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                 }
            }
            .padding(.horizontal, 8)
            .frame(height: 15)
            
        } // End VStack
        // Apply glass modifier to the whole player container
        .modifier(GlassBackground())
    }
    
    private func formatTime(_ time: Double) -> String {
        let totalSeconds = max(0, Int(time))
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

struct TracksSectionView: View {
    let tracks: [Track]
    let isLoading: Bool
    let error: SpotifyAPIError?
    @Binding var selectedTrackUri: String?
    let retryAction: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) { // Use VStack to contain header and list
            // --- Section Header ---
            Text("Tracks")
                .font(GlassmorphicTheme.appFont(size: 18, weight: .semibold))
                .foregroundColor(GlassmorphicTheme.primaryText)
                .padding(.horizontal) // Applied inside GlassBackground later
                .padding(.bottom, 10)
            
            // --- Container for Tracks/Loading/Error (Glass background applied here) ---
            VStack(spacing: 0) { // Inner stack for content
                if isLoading {
                    HStack { Spacer(); ProgressView().tint(GlassmorphicTheme.accentColor); Text("Loading Tracks..."); Spacer() }
                        .font(GlassmorphicTheme.appFont(size: 14)).foregroundColor(GlassmorphicTheme.secondaryText)
                        .padding(.vertical, 30)
                } else if let error = error {
                     ErrorPlaceholderView(error: error, retryAction: retryAction)
                        .padding(.vertical, 20)
                } else if tracks.isEmpty {
                    Text("No tracks found.")
                        .font(GlassmorphicTheme.appFont(size: 14)).foregroundColor(GlassmorphicTheme.secondaryText)
                        .frame(maxWidth: .infinity, alignment: .center).padding(.vertical, 30)
                } else {
                    // Track Rows (No divider, rely on highlight)
                    ForEach(tracks) { track in
                         SlimTrackRow(track: track, isSelected: track.uri == selectedTrackUri)
                             .contentShape(Rectangle())
                             .onTapGesture { selectedTrackUri = track.uri }
                             .background(track.uri == selectedTrackUri ? GlassmorphicTheme.selectedHighlight : Color.clear) // Subtle selection highlight
                             .cornerRadius(8) // Rounded corners for the highlight
                             .padding(.bottom, 3) // Small space between rows
                         
                    }
                }
            }
            .modifier(GlassBackground()) // Apply glass to the content container
            
        } // End Outer VStack
    }
}

// Simpler row style for tracks, less UI clutter
struct SlimTrackRow: View {
    let track: Track
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Text("\(track.track_number)")
                .font(GlassmorphicTheme.appFont(size: 12, weight: .medium))
                .foregroundColor(isSelected ? GlassmorphicTheme.accentColor : GlassmorphicTheme.secondaryText)
                .frame(width: 20, alignment: .center)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(track.name)
                    .font(GlassmorphicTheme.appFont(size: 14, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(GlassmorphicTheme.primaryText)
                    .lineLimit(1)
                Text(track.formattedArtists)
                    .font(GlassmorphicTheme.appFont(size: 11))
                    .foregroundColor(GlassmorphicTheme.secondaryText)
                    .lineLimit(1)
            }
            
            Spacer()
            
            Text(track.formattedDuration)
                .font(GlassmorphicTheme.appFont(size: 12, weight: .medium))
                .foregroundColor(GlassmorphicTheme.secondaryText)
                .frame(width: 40, alignment: .trailing)
            
            // Play Indicator
             Image(systemName: isSelected ? "waveform" : "play.fill")
                .font(.system(size: 12))
                .foregroundColor(isSelected ? GlassmorphicTheme.accentColor : GlassmorphicTheme.secondaryText.opacity(0.6))
                .frame(width: 20, alignment: .center)
                .animation(.easeInOut, value: isSelected)
        }
        .padding(.vertical, 8)  // Slightly less padding for slimmer rows
        .padding(.horizontal, 10)
    }
}

// MARK: Other Supporting Views (Themed)

struct AlbumImageView: View { // Adapted for Glassmorphism Placeholders
    let url: URL?
    private let placeholderCornerRadius: CGFloat = 12
    
    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
                // Simple ProgressView on subtle glass
                ZStack {
                     RoundedRectangle(cornerRadius: placeholderCornerRadius)
                         .fill(GlassmorphicTheme.glassBackgroundFill.opacity(0.5))
                         .overlay(RoundedRectangle(cornerRadius: placeholderCornerRadius).stroke(GlassmorphicTheme.glassBorderColor, lineWidth: 0.5))
                    ProgressView().tint(GlassmorphicTheme.accentColor.opacity(0.7))
                }
            case .success(let image):
                 image.resizable().scaledToFit()
                 // .cornerRadius(placeholderCornerRadius) // Optionally round the loaded image too
            case .failure:
                 // Simple Icon on subtle glass
                 ZStack {
                     RoundedRectangle(cornerRadius: placeholderCornerRadius)
                         .fill(GlassmorphicTheme.glassBackgroundFill.opacity(0.5))
                         .overlay(RoundedRectangle(cornerRadius: placeholderCornerRadius).stroke(GlassmorphicTheme.glassBorderColor, lineWidth: 0.5))
                     Image(systemName: "photo.fill")
                         .resizable().scaledToFit()
                         .foregroundColor(GlassmorphicTheme.secondaryText.opacity(0.5))
                         .padding(15)
                 }
            @unknown default: EmptyView()
            }
        }
    }
}

struct SearchMetadataHeader: View {
    let totalResults: Int
    let limit: Int
    let offset: Int
    
    var body: some View {
        HStack {
             Text("Found: \(totalResults)")
             Spacer()
             if totalResults > limit {
                  Text("Displaying: \(offset + 1)-\(min(offset + limit, totalResults))")
             }
         }
         .font(GlassmorphicTheme.appFont(size: 11, weight: .medium))
         .foregroundColor(GlassmorphicTheme.secondaryText)
         .padding(.vertical, 5)
         // Optional: Add a very subtle top glass bar for metadata
         // .padding(.horizontal).modifier(GlassBackground(cornerRadius: 8, material: .ultraThinMaterial))
    }
}

struct ExternalLinkButton: View {
    let text: String = "Open in Spotify"
    let url: URL
    @Environment(\.openURL) var openURL
    
    var body: some View {
        Button {
            print("Attempting to open external URL: \(url)")
             openURL(url) { accepted in if !accepted { print("⚠️ OS cannot open URL: \(url)") } }
        } label: {
            Label(text, systemImage: "arrow.up.forward.app")
        }
        .buttonStyle(.bordered) // Use bordered for a contained look
        .tint(GlassmorphicTheme.accentColor.opacity(0.9)) // Accent color
        // Optional: Apply a subtle glass background to the button itself
         .background(GlassmorphicTheme.glassBackgroundFill, in: Capsule())
         .overlay(Capsule().stroke(GlassmorphicTheme.glassBorderColor, lineWidth: 0.5))
    }
}

// MARK: - Preview Providers (Adjusted for Glassmorphism)

struct SpotifyAlbumListView_Previews: PreviewProvider {
    static var previews: some View {
        SpotifyAlbumListView()
            // .preferredColorScheme(.dark) // Test both light/dark if using adaptive materials
    }
}

struct GlassAlbumCard_Previews: PreviewProvider {
    static let mockArtist = Artist(id: "artist1", external_urls: nil, href: "", name: "Miles Davis Mock", type: "artist", uri: "")
    static let mockImage = SpotifyImage(height: 300, url: "https://i.scdn.co/image/ab67616d00001e027ab89c25093ea3787b1995b4", width: 300)
    static let mockAlbumItem = AlbumItem(id: "album1", album_type: "album", total_tracks: 5, available_markets: ["US"], external_urls: ExternalUrls(spotify: ""), href: "", images: [mockImage], name: "Kind of Glass [PREVIEW]", release_date: "1959-08-17", release_date_precision: "day", type: "album", uri: "spotify:album:1weenld61qoidwYuZ1GESA", artists: [mockArtist])
    
    static var previews: some View {
        GlassAlbumCard(album: mockAlbumItem)
            .padding()
            .background(GlassmorphicTheme.backgroundGradient)
            .previewLayout(.fixed(width: 380, height: 160)) // Adjust height if needed
    }
}

struct AlbumDetailView_Previews: PreviewProvider {
    static let mockArtist = Artist(id: "artist1", external_urls: nil, href: "", name: "Miles Davis Mock", type: "artist", uri: "")
    static let mockImage = SpotifyImage(height: 640, url: "https://i.scdn.co/image/ab67616d0000b2737ab89c25093ea3787b1995b4", width: 640)
    static let mockAlbum = AlbumItem(id: "1weenld61qoidwYuZ1GESA", album_type: "album", total_tracks: 5, available_markets: ["US", "GB"], external_urls: ExternalUrls(spotify: "https://open.spotify.com/album/1weenld61qoidwYuZ1GESA"), href: "", images: [mockImage], name: "Kind Of Glass (Preview)", release_date: "1959-08-17", release_date_precision: "day", type: "album", uri: "spotify:album:1weenld61qoidwYuZ1GESA", artists: [mockArtist])
    
    static var previews: some View {
        NavigationView {
            AlbumDetailView(album: mockAlbum)
        }
        // .preferredColorScheme(.dark)
    }
}

// MARK: - App Entry Point

@main
struct SpotifyGlassmorphicApp: App {
    init() {
        // Print Token Warning at Startup
        if placeholderSpotifyToken == "YOUR_SPOTIFY_BEARER_TOKEN_HERE" {
            print("🚨 WARNING: Spotify Bearer Token is not set! API calls will fail.")
            print("👉 FIX: Replace the placeholder token in the code.")
        }
        
        // --- Customize Navigation Bar Appearance for Transparency ---
        let appearance = UINavigationBarAppearance()
        // Configure background effects for transparency/blur
        appearance.configureWithTransparentBackground()
        // Optional: Add a background material if you want the bar itself to be glass
         appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial) // Or .systemThinMaterial etc.
        
        // Set title text attributes if needed (ensure contrast)
        appearance.titleTextAttributes = [.foregroundColor: UIColor(GlassmorphicTheme.primaryText)]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor(GlassmorphicTheme.primaryText)]
        
        // Apply the appearance
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance // Crucial for large titles
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().tintColor = UIColor(GlassmorphicTheme.accentColor) // Back button, etc.
    }
    
    var body: some Scene {
        WindowGroup {
            SpotifyAlbumListView()
                 // Let system decide theme, or force dark/light if the gradient looks better in one
                 // .preferredColorScheme(.dark)
        }
    }
}
