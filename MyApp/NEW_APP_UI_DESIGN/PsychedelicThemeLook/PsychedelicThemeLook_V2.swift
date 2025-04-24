//
//  PsychedelicThemeLook.swift
//  MyApp
//
//  Created by Cong Le on 4/18/25.
//

//  Synthesized version combining all features with Psychedelic Theme
//

import SwiftUI
@preconcurrency import WebKit
import Foundation

// MARK: - Psychedelic Theme Constants & Modifiers

let psychedelicBackgroundStart = Color(red: 0.05, green: 0.0, blue: 0.15) // Deep Indigo/Purple
let psychedelicBackgroundEnd = Color(red: 0.15, green: 0.05, blue: 0.25) // Dark Violet
let psychedelicAccentPink = Color(red: 1.0, green: 0.15, blue: 0.6)
let psychedelicAccentCyan = Color(red: 0.2, green: 0.9, blue: 0.85)
let psychedelicAccentLime = Color(red: 0.6, green: 1.0, blue: 0.3)
let psychedelicAccentOrange = Color(red: 1.0, green: 0.5, blue: 0.1)
let psychedelicPurples: [Color] = [Color(hex: "4B0082"), Color(hex: "8A2BE2"), Color(hex: "9370DB"), Color(hex: "DA70D6")]
let psychedelicVibrantGradient = Gradient(colors: [
    psychedelicAccentPink, psychedelicPurples[1], psychedelicAccentCyan, psychedelicAccentLime, psychedelicAccentOrange
])

// Font Helpers (Using system fonts for simplicity, replace with custom if available)
func psychedelicTitleFont(size: CGFloat) -> Font {
    // A more decorative/expressive font - e.g., a Script or Serif style might fit
    // Using a system Serif temporarily
    //Font.system(size: size, weight: .bold, design: .serif)
    // Example custom font: Font.custom("YourPsychedelicFontName", size: size)
    Font.custom("SuperBread", size: 36.0)
}

func psychedelicBodyFont(size: CGFloat, weight: Font.Weight = .regular) -> Font {
    // A clean, readable sans-serif
    //Font.system(size: size, weight: weight, design: .rounded) // Rounded might feel more organic
    Font.custom("Nashirafree-Regular", size: 16.0)
}

// Custom Modifier for Psychedelic Effects (Example: Subtle Bloom/Blur)
struct PsychedelicGlow: ViewModifier {
    var color: Color
    var radius: CGFloat
    
    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(0.5), radius: radius * 0.6, x: 0, y: 0) // Inner
            .shadow(color: color.opacity(0.3), radius: radius, x: 0, y: 0)       // Outer Bloom
            .blur(radius: radius * 0.05) // Very subtle blur to soften edges
    }
}

extension View {
    func psychedelicGlow(_ color: Color = psychedelicAccentPink, radius: CGFloat = 12) -> some View {
        self.modifier(PsychedelicGlow(color: color, radius: radius))
    }
}


let retroDeepPurple = Color(red: 0.15, green: 0.05, blue: 0.25) // Dark background
let retroNeonPink = Color(red: 1.0, green: 0.1, blue: 0.5)
let retroNeonCyan = Color(red: 0.1, green: 0.9, blue: 0.9)
let retroNeonLime = Color(red: 0.7, green: 1.0, blue: 0.3)
let retroGradients: [Color] = [
    Color(red: 0.25, green: 0.12, blue: 0.4), // Deep purple
    Color(red: 0.55, green: 0.19, blue: 0.66), // Mid purple/pink
    Color(red: 0.95, green: 0.29, blue: 0.56), // Neon pinkish
    Color(red: 0.18, green: 0.5, blue: 0.96)    // Neon blue
]

// Custom Font Helper (adjust font names if needed)
func retroFont(size: CGFloat, weight: Font.Weight = .regular) -> Font {
    // Example: Using Menlo (built-in monospaced)
    // return Font.system(size: size, weight: weight, design: .monospaced)
    
    // Example: Using a custom font (replace "YourRetroFontName" if you add one)
    // return Font.custom("YourRetroFontName", size: size).weight(weight)
    
    // Defaulting to system monospaced
    return Font.system(size: size, design: .monospaced).weight(weight)
}

extension View {
    // Apply consistent neon glow
    func neonGlow(_ color: Color, radius: CGFloat = 8) -> some View {
        self
            .shadow(color: color.opacity(0.6), radius: radius / 2, x: 0, y: 0) // Inner sharp glow
            .shadow(color: color.opacity(0.4), radius: radius, x: 0, y: 0)     // Mid soft glow
            .shadow(color: color.opacity(0.2), radius: radius * 1.5, x: 0, y: 0) // Outer faint glow
    }
}

// Helper for Hex Colors (Optional)
extension Color {
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
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}

// MARK: - Data Models (Unchanged)

struct SpotifySearchResponse: Codable, Hashable { let albums: Albums }
struct Albums: Codable, Hashable { /* ... */
    let href: String
    let limit: Int
    let next: String?
    let offset: Int
    let previous: String?
    let total: Int
    let items: [AlbumItem]
}
struct AlbumItem: Codable, Identifiable, Hashable { /* ... */
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
    let type: String
    let uri: String
    let artists: [Artist]
    
    // --- Helper computed properties (Unchanged) ---
    var bestImageURL: URL? { /* ... */
        images.first { $0.width == 640 }?.urlObject ??
        images.first { $0.width == 300 }?.urlObject ??
        images.first?.urlObject
    }
    var listImageURL: URL? { /* ... */
        images.first { $0.width == 300 }?.urlObject ??
        images.first { $0.width == 64 }?.urlObject ??
        images.first?.urlObject
    }
    var formattedArtists: String { /* ... */
        artists.map { $0.name }.joined(separator: ", ")
    }
    func formattedReleaseDate() -> String { /* ... Logic from previous versions ... */
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
                dateFormatter.dateFormat = "MMM yyyy" // Keep readable
                return dateFormatter.string(from: date)
            }
        case "day":
            dateFormatter.dateFormat = "yyyy-MM-dd"
            if let date = dateFormatter.date(from: release_date) {
                dateFormatter.dateFormat = "d MMM yyyy" // Keep readable
                return dateFormatter.string(from: date)
            }
        default: break
        }
        return release_date
    }
}
struct Artist: Codable, Identifiable, Hashable { /* ... */
    let id: String
    let external_urls: ExternalUrls?
    let href: String
    let name: String
    let type: String
    let uri: String
}
struct SpotifyImage: Codable, Hashable { /* ... */
    let height: Int?
    let url: String
    let width: Int?
    var urlObject: URL? { URL(string: url) }
}
struct ExternalUrls: Codable, Hashable { /* ... */
    let spotify: String?
}
struct AlbumTracksResponse: Codable, Hashable { /* ... */
    let items: [Track]
}
struct Track: Codable, Identifiable, Hashable { /* ... */
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
    let type: String
    let uri: String
    
    var formattedDuration: String { /* ... */
        let totalSeconds = duration_ms / 1000
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    var formattedArtists: String { /* ... */
        artists.map { $0.name }.joined(separator: ", ")
    }
}

// MARK: - Spotify Embed WebView (Unchanged Functionality)

final class SpotifyPlaybackState: ObservableObject { /* ... */
    @Published var isPlaying: Bool = false
    @Published var currentPosition: Double = 0 // seconds
    @Published var duration: Double = 0 // seconds
    @Published var currentUri: String = ""
}
struct SpotifyEmbedWebView: UIViewRepresentable { // Keep functional structure
    @ObservedObject var playbackState: SpotifyPlaybackState
    let spotifyUri: String?
    
    // makeCoordinator, makeUIView, updateUIView, Coordinator, generateHTML
    // should remain functionally the same as the previous versions.
    // No direct visual theming is applied to the WebView itself, only its container.
    // (Code for these methods is omitted for brevity, use the previous complete version)
    func makeCoordinator() -> Coordinator { Coordinator(self) }
    func makeUIView(context: Context) -> WKWebView { /* ... WebView setup from previous version ... */
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
        webView.backgroundColor = .clear // Important: Keep transparent
        webView.scrollView.isScrollEnabled = false
        
        let html = generateHTML()
        webView.loadHTMLString(html, baseURL: nil)
        context.coordinator.webView = webView
        return webView
    }
    func updateUIView(_ webView: WKWebView, context: Context) { /* ... JS loading logic from previous version ... */
        if context.coordinator.isApiReady && context.coordinator.lastLoadedUri != spotifyUri {
            context.coordinator.loadUri(spotifyUri ?? "No URI")
            DispatchQueue.main.async { if playbackState.currentUri != spotifyUri { playbackState.currentUri = spotifyUri ?? "No URI" } }
        } else if !context.coordinator.isApiReady {
            context.coordinator.updateDesiredUriBeforeReady(spotifyUri ?? "No URI")
        }
    }
    static func dismantleUIView(_ uiView: WKWebView, coordinator: Coordinator) { /* ... Cleanup from previous version ... */
        uiView.stopLoading()
        uiView.configuration.userContentController.removeScriptMessageHandler(forName: "spotifyController")
        coordinator.webView = nil
    }
    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler { /* ... JS communication logic from previous version ... */
        var parent: SpotifyEmbedWebView
        weak var webView: WKWebView?
        var isApiReady = false
        var lastLoadedUri: String?
        private var desiredUriBeforeReady: String? = nil
        
        init(_ parent: SpotifyEmbedWebView) { self.parent = parent }
        func updateDesiredUriBeforeReady(_ uri: String) { if !isApiReady { desiredUriBeforeReady = uri } }
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) { print("Embed: HTML loaded.") }
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) { print("Embed Fail: \(error.localizedDescription)") }
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) { print("Embed Fail Prov: \(error.localizedDescription)") }
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) { /* ... Handle JS messages like previous version ... */
            guard message.name == "spotifyController" else { return }
            if let bodyDict = message.body as? [String: Any], let event = bodyDict["event"] as? String {
                handleEvent(event: event, data: bodyDict["data"])
            } else if let bodyString = message.body as? String, bodyString == "ready" {
                handleApiReady()
            } else { print("Embed: Unknown message format: \(message.body)") }
        }
        private func handleApiReady() { /* ... */
            print("✅ Embed: API Ready.")
            isApiReady = true
            
            if let initialUri = desiredUriBeforeReady ?? parent.spotifyUri {
                createSpotifyController(with: initialUri)
                desiredUriBeforeReady = nil
            }
        }
        private func handleEvent(event: String, data: Any?) { /* ... Handle specific events like previous version ... */
            switch event {
            case "controllerCreated": print("✅ Embed: Controller Created.")
            case "playbackUpdate": if let updateData = data as? [String: Any] { updatePlaybackState(with: updateData)}
            case "error": let msg = (data as? [String: Any])?["message"] as? String ?? "\(data ?? "Unknown")"; print("❌ Embed JS Error: \(msg)")
            default: print("❓ Embed: Unknown event: \(event)")
            }
        }
        private func updatePlaybackState(with data: [String: Any]) { /* ... Update parent.playbackState like previous version ... */
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                if let isPaused = data["paused"] as? Bool { if self.parent.playbackState.isPlaying == isPaused { self.parent.playbackState.isPlaying = !isPaused } }
                if let posMs = data["position"] as? Double { let newPos = posMs/1000.0; if abs(self.parent.playbackState.currentPosition - newPos)>0.1 { self.parent.playbackState.currentPosition = newPos } }
                if let durMs = data["duration"] as? Double { let newDur = durMs/1000.0; if abs(self.parent.playbackState.duration - newDur)>0.1 || self.parent.playbackState.duration==0 { self.parent.playbackState.duration = newDur } }
                if let uri = data["uri"] as? String, self.parent.playbackState.currentUri != uri { self.parent.playbackState.currentUri = uri }
            }
        }
        
        private func createSpotifyController(with initialUri: String) { /* ... JS execution ... */
            guard let webView = webView else { return }
            guard isApiReady else { return }
            guard lastLoadedUri == nil else { // Only init once
                // If the desired URI changed before ready, load it now
                if let latestDesired = desiredUriBeforeReady ?? parent.spotifyUri,
                   latestDesired != lastLoadedUri {
                    print("🔄 Spotify Embed Native: API ready, loading changed URI: \(latestDesired)")
                    loadUri(latestDesired)
                    desiredUriBeforeReady = nil // Clear after use
                } else {
                    print("ℹ️ Spotify Embed Native: Controller already initialized or attempt pending.")
                }
                print("ℹ️ Spotify Embed Native: Controller already initialized or attempt pending.")
                return
            }
            print("🚀 Spotify Embed Native: Attempting to create controller for URI: \(initialUri)")
            lastLoadedUri = initialUri // Mark as attempting
            
            let script = """
             // ... (JavaScript code from previous version to create controller and listeners) ...
             console.log('Spotify Embed JS: Initial script block running.');
             window.embedController = null; // Ensure clean state
             const element = document.getElementById('embed-iframe');
             if (!element) { console.error('Spotify Embed JS: Could not find element embed-iframe!'); window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'HTML element embed-iframe not found' }}); }
             else if (!window.IFrameAPI) { console.error('Spotify Embed JS: IFrameAPI is not loaded!'); window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'Spotify IFrame API not loaded' }}); }
             else {
                 console.log('Spotify Embed JS: Found element and IFrameAPI. Creating controller for URI: \(initialUri)');
                 const options = { uri: '\(initialUri)', width: '100%', height: '80' }; // Standard height
                 const callback = (controller) => {
                     if (!controller) { console.error('Spotify Embed JS: createController callback received null controller!'); window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'JS createController callback received null controller' }}); return; }
                     console.log('✅ Spotify Embed JS: Controller instance received.');
                     window.embedController = controller; // Store globally for access
                     window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'controllerCreated' });
                     // Add Listeners
                     controller.addListener('ready', () => { console.log('Spotify Embed JS: Controller Ready event.'); });
                     controller.addListener('playback_update', e => { window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'playbackUpdate', data: e.data }); });
                     controller.addListener('account_error', e => { console.warn('Spotify Embed JS: Account Error:', e.data); window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'Account Error: ' + (e.data?.message ?? 'Premium required or login issue?') }}); });
                     controller.addListener('autoplay_failed', () => { console.warn('Spotify Embed JS: Autoplay failed'); window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'Autoplay failed' }}); controller.play(); }); // Try manual play on failure
                     controller.addListener('initialization_error', e => { console.error('Spotify Embed JS: Initialization Error:', e.data); window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'Initialization Error: ' + (e.data?.message ?? 'Failed to initialize player') }}); });
                 };
                 try {
                     console.log('Spotify Embed JS: Calling IFrameAPI.createController...');
                     window.IFrameAPI.createController(element, options, callback);
                 } catch (e) {
                     console.error('Spotify Embed JS: Error calling createController:', e); window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'JS exception during createController: ' + e.message }});
                     // Cannot reset lastLoadedUri here easily, as it might be set by a different thread. Rely on error state in UI.
                 }
             }
             """
            webView.evaluateJavaScript(script) { _, error in /* ... Handle JS execution error ... */
                if let error = error {
                    print("⚠️ Spotify Embed Native: Error evaluating JS controller creation: \(error.localizedDescription)")
                    // Potentially reset lastLoadedUri if JS call itself fails badly?
                    // Needs careful state management if UI could change URI concurrently.
                }
            }
        }
        func loadUri(_ uri: String) { /* ... JS execution from previous version ... */
            guard let webView = webView, isApiReady, lastLoadedUri != nil, lastLoadedUri != uri else { return }
            print("🚀 Embed Native: Loading URI: \(uri)")
            lastLoadedUri = uri
            let script = """
             if (window.embedController) { console.log('JS: Loading URI: \(uri)'); window.embedController.loadUri('\(uri)'); window.embedController.play(); } else { console.error('JS: Controller not found for loadUri.'); }
             """
            webView.evaluateJavaScript(script) { _, error in if let error = error { print("⚠️ Embed Native: Error JS loadUri: \(error)") } }
        }
        // WKUIDelegate (unchanged)
        func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) { print("ℹ️ Embed JS Alert: \(message)"); completionHandler() }
    }
    // Generate HTML (unchanged)
    private func generateHTML() -> String { /* ... HTML structure from previous version ... */
         """
         <!DOCTYPE html><html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no"><title>Spotify Embed</title><style>html, body { margin: 0; padding: 0; width: 100%; height: 100%; overflow: hidden; background-color: transparent; } #embed-iframe { width: 100%; height: 100%; box-sizing: border-box; display: block; border: none; }</style></head><body><div id="embed-iframe"></div><script src="https://open.spotify.com/embed/iframe-api/v1" async></script><script> console.log('JS: Initial script embed.js.'); window.onSpotifyIframeApiReady = (IFrameAPI) => { console.log('✅ JS: API Ready.'); window.IFrameAPI = IFrameAPI; if (window.webkit?.messageHandlers?.spotifyController) { window.webkit.messageHandlers.spotifyController.postMessage("ready"); } else { console.error('❌ JS: Native handler missing!'); } }; const scriptTag = document.querySelector('script[src*="iframe-api"]'); scriptTag.onerror = (event) => { console.error('❌ JS: Failed API script load:', event); window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'Failed API script load' }}); }; </script></body></html>
         """
    }
}

// MARK: - API Service (Use Placeholder Token)

let placeholderSpotifyToken = "YOUR_SPOTIFY_BEARER_TOKEN_HERE" // Needs replacement!

enum SpotifyAPIError: Error, LocalizedError { /* ... Enum cases ... */
    case invalidURL
    case networkError(Error)
    case invalidResponse(Int, String?)
    case decodingError(Error)
    case invalidToken
    case missingData
    
    var errorDescription: String? { /* ... Descriptions... */
        switch self {
        case .invalidURL: return "Invalid API URL."
        case .networkError(let error): return "Network error: \(error.localizedDescription)"
        case .invalidResponse(let code, _): return "Server error (\(code))."
        case .decodingError(let error): return "Error reading response: \(error.localizedDescription)"
        case .invalidToken: return "Spotify token invalid/expired."
        case .missingData: return "Missing data in response."
        }
    }
}
struct SpotifyAPIService {
    static let shared = SpotifyAPIService()
    private let session: URLSession
    
    init() { /* ... Session setup... */
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        session = URLSession(configuration: configuration)
    }
    
    private func makeRequest<T: Decodable>(url: URL) async throws -> T { /* ... Request Logic... */
        guard !placeholderSpotifyToken.isEmpty, placeholderSpotifyToken != "YOUR_SPOTIFY_BEARER_TOKEN_HERE" else { throw SpotifyAPIError.invalidToken }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(placeholderSpotifyToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 20
        do {
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else { throw SpotifyAPIError.invalidResponse(0, "Not HTTP.") }
            guard (200...299).contains(httpResponse.statusCode) else {
                if httpResponse.statusCode == 401 { throw SpotifyAPIError.invalidToken }
                throw SpotifyAPIError.invalidResponse(httpResponse.statusCode, String(data: data, encoding: .utf8))
            }
            do { return try JSONDecoder().decode(T.self, from: data) }
            catch { throw SpotifyAPIError.decodingError(error) }
        } catch let error where !(error is CancellationError) { throw error is SpotifyAPIError ? error : SpotifyAPIError.networkError(error) }
    }
    // searchAlbums, getAlbumTracks
    func searchAlbums(query: String, limit: Int = 20, offset: Int = 0) async throws -> SpotifySearchResponse {
        var components = URLComponents(string: "https://api.spotify.com/v1/search")
        components?.queryItems = [ URLQueryItem(name: "q", value: query), URLQueryItem(name: "type", value: "album"), URLQueryItem(name: "include_external", value: "audio"), URLQueryItem(name: "limit", value: "\(limit)"), URLQueryItem(name: "offset", value: "\(offset)") ]
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

// MARK: - SwiftUI Views (Themed)

struct SpotifyAlbumListView_Previews_Refactored: PreviewProvider {
    static var previews: some View {
        SpotifyAlbumListView() // Preview the refactored view
            .preferredColorScheme(.dark)
    }
}

// MARK: - Psychedelic Album Card (Themed)
struct PsychedelicAlbumCard: View {
    let album: AlbumItem
    @State private var animateGradient = false
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Background Artwork Image + Animated Gradient Overlay
            ZStack {
                AlbumImageView(url: album.listImageURL) // Use helper for consistent image loading
                    .aspectRatio(contentMode: .fill) // Fill the card space
                    .frame(height: 160) // Define card height
                    .clipped()
                // Applying the animated gradient overlay
                    .overlay(
                        animatedGradientOverlay
                            .blendMode(.overlay) // Blend gradient with image
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous)) // Organic rounding
                // Subtle animated wave background (reusing from previous concept)
                PsychedelicWave(startColor: psychedelicAccentPink, endColor: psychedelicAccentCyan)
                    .opacity(0.15) // Less intense wave
                    .blur(radius: 3)
                    .blendMode(.softLight) // Softer blending for the wave
                    .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
            }
            .shadow(color: .black.opacity(0.4), radius: 8, y: 4) // Slightly stronger shadow
            
            // Album Information Area (Bottom Layer)
            VStack(alignment: .leading, spacing: 6) {
                Text(album.name)
                    .font(psychedelicTitleFont(size: 18)) // Themed title font
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.5), radius: 1, y: 1)
                    .lineLimit(1)
                
                Text(album.formattedArtists)
                    .font(psychedelicBodyFont(size: 14, weight: .medium))
                    .foregroundColor(psychedelicAccentLime.opacity(0.9)) // Artist highlight
                    .lineLimit(1)
                
                HStack(spacing: 8) {
                    Label(album.album_type.capitalized, systemImage: iconForAlbumType(album.album_type))
                        .font(psychedelicBodyFont(size: 10, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.black.opacity(0.4).cornerRadius(3))
                    
                    Text("•")
                        .foregroundColor(.white.opacity(0.5))
                    
                    Text(album.formattedReleaseDate())
                        .font(psychedelicBodyFont(size: 10, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.top, 2)
                
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .background(
                LinearGradient(
                    colors: [.black.opacity(0.7), .black.opacity(0.3)],
                    startPoint: .bottom,
                    endPoint: .top
                )
                .blur(radius: 10) // Blurred background behind text for readability
            )
            .frame(maxWidth: .infinity, alignment: .leading) // Ensure text background spans width
            // Clip text background area to match card rounding
            .mask(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 25, style: .continuous)
            }
            
        }
        .frame(height: 160) // Ensure consistent card height
        .onAppear { // Start gradient animation
            withAnimation(.linear(duration: 6).repeatForever(autoreverses: true)) {
                animateGradient.toggle()
            }
        }
    }
    
    // Animated Gradient Overlay for the Card Background
    private var animatedGradientOverlay: some View {
        LinearGradient(gradient: psychedelicVibrantGradient,
                       startPoint: animateGradient ? .topLeading : .bottomTrailing,
                       endPoint: animateGradient ? .bottomTrailing : .topLeading)
        .opacity(0.45) // Adjust opacity for desired blend effect
    }
    
    // Icon helper for album type
    private func iconForAlbumType(_ type: String) -> String {
        switch type.lowercased() {
        case "album": return "opticaldisc"
        case "single": return "record.circle"
        case "compilation": return "list.star"
        default: return "music.note"
        }
    }
}

// Reusable Animated Wave Shape (adapted slightly for theme)
struct PsychedelicWave: View {
    @State private var phase: CGFloat = 0
    let amplitude: CGFloat = 15 // How high the waves go
    let frequency: CGFloat = 0.5 // How many waves across the width
    let speed: Double = 1.5 // How fast it moves
    
    var startColor: Color = psychedelicAccentPink
    var endColor: Color = psychedelicAccentCyan
    
    var body: some View {
        TimelineView(.animation(minimumInterval: 0.02)) { timeline in // Use TimelineView for smooth animation
            Canvas { context, size in
                let time = timeline.date.timeIntervalSinceReferenceDate * speed
                let viewWidth = size.width
                let viewHeight = size.height
                let midHeight = viewHeight / 2
                
                var path = Path()
                path.move(to: CGPoint(x: 0, y: midHeight))
                
                for x in stride(from: 0, to: viewWidth, by: 5) {
                    let relativeX = x / viewWidth // 0...1
                    let sineWave = sin((relativeX * frequency * Double.pi * 2) + time) //sin((relativeX * frequency * .pi * 2) + time)
                    let y = midHeight + sineWave * amplitude
                    path.addLine(to: CGPoint(x: x, y: y))
                }
                path.addLine(to: CGPoint(x: viewWidth, y: viewHeight))
                path.addLine(to: CGPoint(x: 0, y: viewHeight))
                path.closeSubpath()
                
                context.fill(path, with: .linearGradient(
                    Gradient(colors: [startColor, endColor]),
                    startPoint: CGPoint(x: 0, y: 0),
                    endPoint: CGPoint(x: 0, y: viewHeight)
                ))
            }
        }
        .allowsHitTesting(false) // Make it purely visual
    }
}

// Consistent Animated Background Element (Optional)
struct AnimatedPsychedelicBackgroundNoise: View {
    @State private var seed = 0 // Changes to trigger noise regeneration
    
    var body: some View {
        TimelineView(.periodic(from: .now, by: 0.1)) { _ in // Update seed periodically
            Rectangle()
                .fill(.clear) // Base transparent rectangle
                .overlay(
                    NoiseTexture(seed: seed) // Apply the noise texture
                        .blendMode(.overlay) // Blend with background
                )
                .onAppear { seed = Int.random(in: 0...100) } // Initial seed
                .onChange(of: seed) {
                    seed = Int.random(in: 0...100)
                } // Change seed
        }
        .clipped()
    }
}

// Simple Noise Texture Generator (Requires Metal or Core Image for efficiency in real app)
// This SwiftUI Canvas version is illustrative and MAY be slow
struct NoiseTexture: View {
    var seed: Int
    var density: Double = 0.05 // Adjust for more/less noise
    
    var body: some View {
        Canvas { context, size in
            var rng = SeededRandomNumberGenerator(seed: UInt64(seed)) // Use seeded RNG
            context.blendMode = .screen // Use screen or add for noise
            for _ in 0..<Int(size.width * size.height * density) {
                let x = Double.random(in: 0...size.width, using: &rng)
                let y = Double.random(in: 0...size.height, using: &rng)
                let radius = Double.random(in: 0.5...1.5, using: &rng)
                
                let randomColor = Color(
                    hue: Double.random(in: 0...1, using: &rng),
                    saturation: 0.8,
                    brightness: 1.0
                )
                context.fill(
                    Path(
                        ellipseIn: CGRect(
                            x: x - radius / 2,
                            y: y - radius / 2,
                            width: radius,
                            height: radius
                        )
                    ),
                    with: .color(
                        randomColor.opacity(
                            Double.random(in: 0.3...0.7, using: &rng)
                        )
                    )
                )
            }
        }
    }
}
struct SeededRandomNumberGenerator: RandomNumberGenerator {
    private var state: UInt64
    init(seed: UInt64) {
        state = seed == 0 ? 1 : seed
    } // Avoid zero state
    mutating func next() -> UInt64 {
        state = state &* 1103515245 &+ 12345 // Simple LCG (not cryptographically secure)
        return state
    }
}

// MARK: - Themed Placeholders (Adapted for Psychedelic Theme)

struct ErrorPlaceholderView: View {
    let error: SpotifyAPIError
    let retryAction: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 25) {
            Image(systemName: iconName)
                .font(.system(size: 70))
                .foregroundStyle(
                    LinearGradient(
                        gradient: Gradient(
                            colors: [psychedelicAccentPink, psychedelicAccentOrange]
                        ),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .psychedelicGlow(psychedelicAccentPink, radius: 20) // Stronger glow for error icon
                .padding(.bottom, 10)
            
            Text("GLITCH DETECTED") // Themed error title
                .font(psychedelicTitleFont(size: 24))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .shadow(color: .black.opacity(0.4), radius: 2, y: 1)
            
            Text(errorMessage)
                .font(psychedelicBodyFont(size: 15))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
                .lineSpacing(5)
            
            // TODO: Conformation to BinaryInteger
            //            if error != .invalidToken,
            //                let retryAction = retryAction {
            //                PsychedelicButton(
            //                    text: "RETRY SEQUENCE",
            //                    action: retryAction, // Themed button
            //                    iconName: "arrow.clockwise.circle.fill",
            //                    gradient: Gradient(colors: [psychedelicAccentLime, psychedelicAccentCyan]))
            //                .padding(.top, 15)
            //            } else if error == .invalidToken {
            Text("Token Expired / Invalid.\nRestart or Check Code.")
                .font(psychedelicBodyFont(size: 12))
                .foregroundColor(psychedelicAccentPink.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.top, 10)
            //            }
        }
        .padding(30)
        .background(
            .ultraThinMaterial.opacity(0.8) // Frosted glass background
        )
        .padding(20)
    }
    
    // Icon and message logic remains the same
    private var iconName: String { /* ... Logic from previous version ... */
        switch error {
        case .invalidToken: return "key.slash"
        case .networkError: return "wifi.exclamationmark"
        case .invalidResponse, .decodingError, .missingData: return "exclamationmark.triangle"
        case .invalidURL: return "link.badge.plus"
        }
    }
    private var errorMessage: String { /* ... Logic from previous version ... */
        switch error {
        case .invalidToken: return "Authentication warped. Check Spotify Token."
        case .networkError: return "Connection dissolving. Explore network settings."
        case .invalidResponse(let code, _): return "Server echoes error (\(code)). Try later."
        case .decodingError: return "Data stream corrupted. Cannot perceive response."
        default: return error.localizedDescription // Fallback
        }
    }
}

struct EmptyStatePlaceholderView: View {
    let searchQuery: String
    
    var body: some View {
        VStack(spacing: 25) {
            Image(isInitialState ? "My-meme-microphone" : "My-meme-orange_2") // Use the meme images
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: isInitialState ? 160 : 180) // Adjust size
                .shadow(color: isInitialState ? psychedelicAccentCyan.opacity(0.6) : psychedelicAccentOrange.opacity(0.6), radius: 15, y: 5) // Colored shadow
                .padding(.bottom, 15)
            
            Text(title)
                .font(psychedelicTitleFont(size: 24))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.3), radius: 1, y: 1)
            
            Text(messageAttributedString) // Use AttributedString for potential emphasis
                .font(psychedelicBodyFont(size: 15))
                .foregroundColor(.white.opacity(0.85))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
                .lineSpacing(5)
        }
        .padding(30)
        // No extra background needed if the main view bg is already themed
    }
    
    // Logic remains the same
    private var isInitialState: Bool { searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    private var iconName: String { isInitialState ? "My-meme-microphone" : "My-meme-orange_2" }
    private var title: String { isInitialState ? "READY TO SEARCH" : "NO RESULTS" }
    private var messageAttributedString: AttributedString {
        var message: AttributedString
        if isInitialState {
            message = AttributedString("Enter album or artist name above\nto find retro tracks...")
        } else {
            do {
                let query = searchQuery.isEmpty ? "..." : searchQuery // Handle empty string case
                message = try AttributedString(markdown: "No matches for **\(query)**.\nTry different keywords.")
            } catch {
                // Fallback if markdown fails
                message = AttributedString("No matches for \"\(searchQuery)\". Try different keywords.")
            }
        }
        // Apply consistent font to the whole attributed string
        message.font = retroFont(size: 14)
        message.foregroundColor = .white.opacity(0.8)
        // Optionally target and style the bold part (requires more complex AttributedString manipulation)
        return message
    }
}

// MARK: - Album Detail View (Themed)
struct AlbumDetailView: View {
    let album: AlbumItem
    @State private var tracks: [Track] = []
    @State private var isLoadingTracks: Bool = false
    @State private var trackFetchError: SpotifyAPIError? = nil
    @State private var selectedTrackUri: String? = nil
    @StateObject private var playbackState = SpotifyPlaybackState()
    @Environment(\.openURL) var openURL
    
    var body: some View {
        ZStack {
            // --- Retro Background ---
            retroDeepPurple.ignoresSafeArea()
            // Optional: Add subtle background pattern/noise
            Image("retro_grid_background").resizable().scaledToFit().opacity(0.1)
            
            List {
                // --- Header Section ---
                Section { AlbumHeaderView(album: album) }
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                
                // --- Player Section (Themed) ---
                if let uriToPlay = selectedTrackUri {
                    Section { SpotifyEmbedPlayerView(playbackState: playbackState, spotifyUri: uriToPlay) }
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 15, leading: 0, bottom: 15, trailing: 0))
                        .listRowBackground(Color.clear)
                        .transition(.opacity.combined(with: .scale(scale: 0.95, anchor: .top)).animation(.easeInOut(duration: 0.4)))
                }
                
                // --- Tracks Section (Themed) ---
                Section {
                    TracksSectionView(
                        tracks: tracks, isLoading: isLoadingTracks, error: trackFetchError,
                        selectedTrackUri: $selectedTrackUri,
                        retryAction: { Task { await fetchTracks() } }
                    )
                } header: {
                    Text("TRACK LIST") // Retro header style
                        .font(retroFont(size: 14, weight: .bold))
                        .foregroundColor(retroNeonLime)
                        .tracking(2)
                        .frame(maxWidth: .infinity, alignment: .center) // Center header
                        .padding(.vertical, 8)
                        .background(.black.opacity(0.3)) // Subtle background for header
                }
                .listRowInsets(EdgeInsets()) // Remove insets for tracks section
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                
                // --- External Link Section (Themed) ---
                if let spotifyURL = URL(string: album.external_urls.spotify ?? "") {
                    Section { ExternalLinkButton(url: spotifyURL, primaryColor: retroNeonLime, secondaryColor: .green) } // Use themed button
                        .listRowInsets(EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                }
                
            } // End List
            .listStyle(PlainListStyle())
            .scrollContentBackground(.hidden) // Allow ZStack background to show
        } // End ZStack
        .navigationTitle(album.name)
        .navigationBarTitleDisplayMode(.inline)
        // Match nav bar theme from List view
        .toolbarBackground(retroDeepPurple.opacity(0.8), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar) // Consistent dark theme for nav bar
        .task { await fetchTracks() }
        .animation(.easeInOut, value: selectedTrackUri) // Animate player appearance/track selection
        .refreshable { await fetchTracks(forceReload: true) }
    }
    
    // --- Fetch Tracks Logic (Unchanged) ---
    private func fetchTracks(forceReload: Bool = false) async { /* ... */
        guard forceReload || tracks.isEmpty || trackFetchError != nil else { return }
        await MainActor.run { isLoadingTracks = true; trackFetchError = nil }
        do {
            let response = try await SpotifyAPIService.shared.getAlbumTracks(albumId: album.id)
            try Task.checkCancellation()
            await MainActor.run { self.tracks = response.items; self.isLoadingTracks = false }
        } catch is CancellationError { await MainActor.run { isLoadingTracks = false } }
        catch let apiError as SpotifyAPIError { await MainActor.run { self.trackFetchError = apiError; self.isLoadingTracks = false; self.tracks = [] } }
        catch { await MainActor.run { self.trackFetchError = .networkError(error); self.isLoadingTracks = false; self.tracks = [] } }
    }
}

// MARK: - DetailView Sub-Components (Themed)

struct AlbumHeaderView: View {
    let album: AlbumItem
    
    var body: some View {
        VStack(spacing: 15) {
            AlbumImageView(url: album.bestImageURL)
                .aspectRatio(1.0, contentMode: .fit) // Keep square
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .overlay(RoundedRectangle(cornerRadius: 15).stroke(LinearGradient(colors: [retroNeonPink.opacity(0.6), retroNeonCyan.opacity(0.6)], startPoint: .top, endPoint: .bottom), lineWidth: 2))
                .neonGlow(retroNeonCyan, radius: 15) // Glow effect on album art
                .padding(.horizontal, 50)
            
            VStack(spacing: 5) {
                Text(album.name)
                    .font(retroFont(size: 22, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .shadow(color: .black.opacity(0.5), radius: 2, y: 1) // Text shadow
                
                Text("by \(album.formattedArtists)")
                    .font(retroFont(size: 16, weight: .regular))
                    .foregroundColor(retroNeonLime) // Artist accent color
                    .multilineTextAlignment(.center)
                
                Text("\(album.album_type.capitalized) • \(album.formattedReleaseDate())")
                    .font(retroFont(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(.horizontal)
            
        }
        .padding(.vertical, 25)
    }
}

struct SpotifyEmbedPlayerView: View {
    @ObservedObject var playbackState: SpotifyPlaybackState
    let spotifyUri: String
    
    var body: some View {
        VStack(spacing: 8) { // Added spacing
            SpotifyEmbedWebView(playbackState: playbackState, spotifyUri: spotifyUri)
                .frame(height: 85) // Standard embed height + buffer
            // Custom Player Frame/Background
                .background(
                    LinearGradient(colors: [.black.opacity(0.5), .black.opacity(0.2)], startPoint: .top, endPoint: .bottom)
                        .overlay(.ultraThinMaterial) // Frosted glass
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(LinearGradient(colors: [retroNeonCyan.opacity(0.4), retroNeonPink.opacity(0.4)], startPoint: .leading, endPoint: .trailing), lineWidth: 1))
                        .neonGlow(playbackState.isPlaying ? retroNeonLime : retroNeonPink, radius: 8) // Dynamic glow based on state
                )
                .padding(.horizontal)
            
            // --- Themed Playback Status ---
            HStack {
                let statusText = playbackState.isPlaying ? "PLAYING" : "PAUSED"
                let statusColor = playbackState.isPlaying ? retroNeonLime : retroNeonPink
                
                Text(statusText)
                    .font(retroFont(size: 10, weight: .bold))
                    .foregroundColor(statusColor)
                    .tracking(1.5) // Add letter spacing
                    .neonGlow(statusColor, radius: 4)
                    .lineLimit(1)
                    .frame(width: 80, alignment: .leading) // Fixed width for status
                
                Spacer()
                
                if playbackState.duration > 0.1 { // Only show if duration is valid
                    Text("\(formatTime(playbackState.currentPosition)) | \(formatTime(playbackState.duration))")
                        .font(retroFont(size: 11, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                } else {
                    Text("--:-- | --:--") // Placeholder time
                        .font(retroFont(size: 11, weight: .medium))
                        .foregroundColor(.white.opacity(0.5))
                }
            }
            .padding(.horizontal, 25) // Align with player padding
            .padding(.top, 5)
            .frame(minHeight: 15)
            
        } // End VStack
        .animation(.easeInOut, value: playbackState.isPlaying) // Animate glow color change
    }
    
    private func formatTime(_ time: Double) -> String { /* ... Unchanged ... */
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
    @Binding var selectedTrackUri: String? // Binding to update parent
    let retryAction: () -> Void
    
    var body: some View {
        // No encompassing VStack needed if used directly in List Section
        if isLoading {
            HStack { // Center progress view within the list section area
                Spacer()
                ProgressView()
                Text("Loading Tracks...")
                    .foregroundColor(.secondary)
                    .padding(.leading, 5)
                Spacer()
            }
            .padding(.vertical, 20) // Give loading indicator space
        } else if let error = error {
            // Use the new ErrorPlaceholderView
            ErrorPlaceholderView(error: error, retryAction: retryAction)
                .padding(.vertical, 20) // Give error view space
        } else if tracks.isEmpty {
            // Message for when tracks array is empty *after* successful load
            Text("No tracks found for this album.")
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 20)
        } else {
            // Use ForEach directly within the List Section
            ForEach(tracks) { track in
                TrackRowView(
                    track: track,
                    isSelected: track.uri == selectedTrackUri // Check if this track is the selected one
                )
                .contentShape(Rectangle()) // Make the whole row tappable
                .onTapGesture {
                    // Update the selected URI - animation handled by parent
                    selectedTrackUri = track.uri
                }
                // Apply background highlight directly or via listRowBackground
                .listRowBackground(track.uri == selectedTrackUri ? Color.accentColor.opacity(0.15) : Color.clear)
            }
        }
    }
}

struct TrackRowView: View {
    let track: Track
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            // --- Track Number ---
            Text("\(track.track_number)")
                .font(retroFont(size: 12, weight: .medium))
                .foregroundColor(isSelected ? retroNeonLime : .white.opacity(0.6))
                .frame(width: 25, alignment: .center)
                .padding(.leading, 10) // Ensure space from edge
            
            // --- Track Info ---
            VStack(alignment: .leading, spacing: 3) {
                Text(track.name)
                    .font(retroFont(size: 15, weight: isSelected ? .bold : .regular)) // Bold selected track
                    .foregroundColor(isSelected ? retroNeonCyan : .white)
                    .lineLimit(1)
                
                Text(track.formattedArtists)
                    .font(retroFont(size: 11))
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(1)
            }
            
            Spacer()
            
            // --- Duration ---
            Text(track.formattedDuration)
                .font(retroFont(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
                .padding(.trailing, 5)
            
            // --- Play Indicator ---
            Image(systemName: isSelected ? "waveform.path.ecg" : "play.fill") // More fitting icons
                .foregroundColor(isSelected ? retroNeonCyan : .white.opacity(0.7))
                .font(.body) // Adjust size slightly
                .frame(width: 25, height: 25)
                .animation(.easeInOut(duration: 0.2), value: isSelected)
                .padding(.trailing, 10)
            
        }
        .padding(.vertical, 12) // Increase vertical padding for tap target
        // Remove internal horizontal padding, let parent list handle row padding
        // .padding(.horizontal) NO - causes misalignment if rowBackground is used
    }
}

// MARK: - Other Supporting Views (Themed)
//
struct AlbumImageView: View { // Unchanged fundamentally, uses AsyncImage
    let url: URL?
    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
                ZStack {
                    // Themed placeholder background
                    RoundedRectangle(cornerRadius: 8).fill(LinearGradient(colors: [.gray.opacity(0.2), .black.opacity(0.3)], startPoint: .top, endPoint: .bottom))
                    ProgressView().tint(retroNeonCyan)
                }
            case .success(let image):
                image.resizable().scaledToFit()
            case .failure:
                ZStack {
                    RoundedRectangle(cornerRadius: 8).fill(LinearGradient(colors: [.gray.opacity(0.2), .black.opacity(0.3)], startPoint: .top, endPoint: .bottom))
                    Image(systemName: "photo.fill") // Keep system icon
                        .resizable().scaledToFit()
                        .foregroundColor(retroNeonPink.opacity(0.5))
                        .padding(10)
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
            Label("\(totalResults) Results Found", systemImage: "sparkles") // More thematic icon
            Spacer()
            if totalResults > limit {
                Text("Showing \(offset + 1)-\(min(offset + limit, totalResults))")
            }
        }
        .font(psychedelicBodyFont(size: 11, weight: .medium))
        .foregroundColor(psychedelicAccentLime.opacity(0.8))
        .tracking(1.2)
        .padding(.horizontal, 5) // Less padding needed if parent adds it
        .padding(.vertical, 5)
        .background(Color.white.opacity(0.2).blur(radius: 3))
        .clipShape(Capsule()) // Capsule shape for metadata
    }
}

// Generic Themed Button (Replaces ExternalLinkButton for consistency)
struct RetroButton: View {
    let text: String
    let action: () -> Void
    var primaryColor: Color = retroNeonPink
    var secondaryColor: Color = .purple // For gradient
    var iconName: String? = nil
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let iconName = iconName {
                    Image(systemName: iconName)
                }
                Text(text)
                    .tracking(1.5) // Letter spacing
            }
            .font(retroFont(size: 15, weight: .bold))
            .padding(.horizontal, 25)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity) // Make button expand
            .background(LinearGradient(colors: [primaryColor, secondaryColor], startPoint: .leading, endPoint: .trailing))
            .foregroundColor(retroDeepPurple) // Dark text on bright button
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Color.white.opacity(0.5), lineWidth: 1)) // Subtle white edge
            .neonGlow(primaryColor, radius: 12)
        }
        .buttonStyle(.plain) // Ensure custom background/foreground work
    }
}

// Re-implementation of ExternalLinkButton using RetroButton
struct ExternalLinkButton: View {
    let text: String = "OPEN IN SPOTIFY" // Default text
    let url: URL
    var primaryColor: Color = retroNeonLime
    var secondaryColor: Color = .green // Spotify Green gradient end
    var iconName: String? = "arrow.up.forward.app.fill" // More appropriate icon
    
    @Environment(\.openURL) var openURL
    
    var body: some View {
        RetroButton(
            text: text,
            action: {
                print("Attempting to open external URL: \(url)")
                openURL(url) { accepted in
                    if !accepted {
                        print("⚠️ Warning: URL scheme \(url.scheme ?? "") could not be opened.")
                        // Consider showing user an alert here
                    }
                }
            },
            primaryColor: primaryColor,
            secondaryColor: secondaryColor,
            iconName: iconName
        )
    }
}

// MARK: - Themed Button Component
struct PsychedelicButton: View {
    let text: String
    let action: () -> Void
    var iconName: String? = nil
    
    var gradient: Gradient = Gradient(
        colors: [psychedelicAccentPink, psychedelicAccentOrange]
    ) // Default gradient
    
    var textColor: Color = .white
    var glowColor: Color? = psychedelicAccentPink // Optional glow
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                if let iconName = iconName {
                    Image(systemName: iconName)
                        .font(.body.weight(.semibold)) // Slightly bolder icon
                }
                Text(text)
                    .tracking(1.8) // Wider tracking for emphasis
            }
            .font(psychedelicBodyFont(size: 15, weight: .bold))
            .padding(.horizontal, 30)
            .padding(.vertical, 14) // Slightly taller button
            .frame(maxWidth: .infinity)
            .background(LinearGradient(gradient: gradient, startPoint: .leading, endPoint: .trailing))
            .foregroundColor(textColor)
            .clipShape(Capsule()) // Capsule shape remains good
            .shadow(
                color: .black.opacity(0.3),
                radius: 5,
                y: 3
            ) // Standard shadow for depth
            .overlay( // Add subtle inner/outer border for effect
                Capsule()
                    .stroke(
                        LinearGradient(gradient: Gradient(colors: [.white.opacity(0.3), .clear]),
                                       startPoint: .top,
                                       endPoint: .center)
                        .opacity(0.5),lineWidth: 1
                    ) // Top highlight
            )
            .overlay(
                Capsule()
                    .stroke(
                        LinearGradient(gradient: Gradient(colors: [.clear, .black.opacity(0.3)]),
                                       startPoint: .center,
                                       endPoint: .bottom)
                        .opacity(0.5),
                        lineWidth: 1) // Bottom shadow
            )
            .modifier(
                ConditionalPsychedelicGlow(
                    color: glowColor ?? gradient.stops.first?.color ?? psychedelicAccentPink,
                    apply: glowColor != nil, radius: 12))
            
        }
        .buttonStyle(.plain) // Ensure customization takes precedence
    }
}

// Helper modifier to conditionally apply glow
struct ConditionalPsychedelicGlow: ViewModifier {
    let color: Color
    let apply: Bool
    let radius: CGFloat
    
    @ViewBuilder
    func body(content: Content) -> some View {
        if apply {
            content.psychedelicGlow(color, radius: radius)
        } else {
            content
        }
    }
}
struct SpotifyAlbumListView: View {
    @State private var searchQuery: String = ""
    @State private var displayedAlbums: [AlbumItem] = []
    @State private var isLoading: Bool = false
    @State private var searchInfo: Albums? = nil
    @State private var currentError: SpotifyAPIError? = nil
    
    var body: some View {
        NavigationView {
            ZStack {
                // --- Retro Background ---
                retroDeepPurple.ignoresSafeArea() // Extend background
                
                // --- Conditional Content ---
                //                Group {
                if isLoading && displayedAlbums.isEmpty {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: retroNeonCyan))
                        .scaleEffect(1.5)
                        .padding(.bottom, 50) // Offset from center
                } else if let error = currentError {
                    ErrorPlaceholderView(error: error) {
                        Task { await performDebouncedSearch() }
                    }
                } else if displayedAlbums.isEmpty {
                    EmptyStatePlaceholderView(searchQuery: searchQuery)
                } else {
                    albumList // Themed list content
                }
                //                }
                //                .frame(maxWidth: .infinity, maxHeight: .infinity)
                //                .transition(.opacity.animation(.easeInOut(duration: 0.4)))
                //
                // --- Ongoing Loading Overlay (Themed) ---
                if isLoading && !displayedAlbums.isEmpty {
                    VStack {
                        HStack {
                            Spacer()
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: retroNeonLime))
                                .padding(.trailing, 5)
                            Text("Loading...")
                                .font(retroFont(size: 12, weight: .bold))
                                .foregroundColor(retroNeonLime)
                            Spacer()
                        }
                        .padding(.vertical, 6)
                        .padding(.horizontal, 15)
                        .background(.black.opacity(0.6), in: Capsule())
                        .overlay(Capsule().stroke(retroNeonLime.opacity(0.5), lineWidth: 1))
                        .shadow(color: retroNeonLime, radius: 5)
                        .padding(.top, 8)
                        Spacer()
                    }
                    .transition(.opacity.animation(.easeInOut))
                }
                
            } // End ZStack
            .navigationTitle("Retro Spotify Search")
            .navigationBarTitleDisplayMode(.inline)
            // --- Themed Navigation Bar ---
            .toolbarBackground(retroDeepPurple.opacity(0.8), for: .navigationBar) // Translucent retro bg
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar) // Ensures white title/buttons
            
            // --- Search Bar (System Default - harder to theme deeply) ---
            .searchable(text: $searchQuery,
                        placement: .navigationBarDrawer(displayMode: .always),
                        prompt: Text("Search Albums / Artists").foregroundColor(.gray))
            .onSubmit(of: .search) { Task { await performDebouncedSearch(immediate: true) } }
            .task(id: searchQuery) { await performDebouncedSearch() }
            .onChange(of: searchQuery) { if currentError != nil { currentError = nil } }
            .accentColor(retroNeonPink) // Tint cursor/cancel button if possible
            
        } // End NavigationView
        // Apply accent color to the whole view for potential global tinting
        .accentColor(retroNeonPink)
    }
    
    // --- Themed Album List ---
    private var albumList: some View {
        List {
            // --- Themed Metadata Header ---
            if let info = searchInfo, info.total > 0 { // Only show if results exist
                SearchMetadataHeader(totalResults: info.total, limit: info.limit, offset: info.offset)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 5, trailing: 0))
                    .listRowBackground(Color.clear) // Ensure row is transparent
            }
            
            // --- Album Cards ---
            ForEach(displayedAlbums) { album in
                NavigationLink(destination: AlbumDetailView(album: album)) {
                    RetroAlbumCard(album: album) // Use the themed card
                        .padding(.vertical, 8) // Space between cards
                }
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets()) // Remove default padding
                .listRowBackground(Color.clear) // Make row transparent
            }
        }
        .listStyle(PlainListStyle())
        .background(Color.clear) // Make List background transparent
        .scrollContentBackground(.hidden) // Essential for background color to show
    }
    
    // --- Debounced Search Logic ---
    private func performDebouncedSearch(immediate: Bool = false) async { /* ... */
        let trimmedQuery = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else {
            await MainActor.run { displayedAlbums = []; searchInfo = nil; isLoading = false; currentError = nil }
            return
        }
        if !immediate {
            do { try await Task.sleep(for: .milliseconds(600)); try Task.checkCancellation() } // Increased debounce slightly
            catch { print("Search task cancelled (debounce)."); return }
        }
        await MainActor.run { isLoading = true }
        do {
            let response = try await SpotifyAPIService.shared.searchAlbums(query: trimmedQuery, offset: 0)
            try Task.checkCancellation()
            await MainActor.run {
                displayedAlbums = response.albums.items
                searchInfo = response.albums
                currentError = nil
                isLoading = false
            }
        } catch is CancellationError {
            print("Search task cancelled.")
            await MainActor.run { isLoading = false }
        } catch let apiError as SpotifyAPIError {
            print("❌ API Error: \(apiError.localizedDescription)")
            await MainActor.run { displayedAlbums = []; searchInfo = nil; currentError = apiError; isLoading = false }
        } catch {
            print("❌ Unexpected Error: \(error.localizedDescription)")
            await MainActor.run { displayedAlbums = []; searchInfo = nil; currentError = .networkError(error); isLoading = false }
        }
    }
}

// MARK: - Retro Album Card (Themed)
struct RetroAlbumCard: View {
    let album: AlbumItem
    
    var body: some View {
        ZStack {
            // Shiny background with gradient and subtle noise/texture? (Optional advanced)
            LinearGradient(
                gradient: Gradient(colors: retroGradients.shuffled()), // Shuffle for variety?
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            // Inner content blurred background (frosted glass effect)
            .overlay(.ultraThinMaterial) // Can remove if too busy
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            // Neon outline
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(retroNeonCyan.opacity(0.7), lineWidth: 1.5) // Use a consistent neon color
            )
            .neonGlow(retroNeonCyan, radius: 10) // Apply glow to the shape
            .padding(.horizontal, 5) // Padding around the card itself
            
            // --- Content ---
            HStack(spacing: 15) {
                // --- Album Art ---
                AlbumImageView(url: album.listImageURL)
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(LinearGradient(colors: [retroNeonPink.opacity(0.5), retroNeonCyan.opacity(0.5)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1))
                    .shadow(color: .black, radius: 5, y: 3) // Standard shadow for depth
                
                // --- Text Details ---
                VStack(alignment: .leading, spacing: 5) {
                    Text(album.name)
                        .font(retroFont(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(2)
                    
                    Text(album.formattedArtists)
                        .font(retroFont(size: 14, weight: .regular))
                        .foregroundColor(retroNeonLime.opacity(0.9)) // Accent color for artist
                        .lineLimit(1)
                    
                    Spacer() // Push bottom info down
                    
                    HStack {
                        Label(album.album_type.capitalized, systemImage: "rectangle.stack.fill")
                            .font(retroFont(size: 11, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(.white.opacity(0.1), in: Capsule())
                        
                        Text("•")
                            .foregroundColor(.white.opacity(0.5))
                        
                        Text(album.formattedReleaseDate())
                            .font(retroFont(size: 11, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    Text("\(album.total_tracks) Tracks")
                        .font(retroFont(size: 11, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.top, 1)
                    
                } // End Text VStack
                .frame(maxWidth: .infinity, alignment: .leading) // Allow text to take space
                
            } // End HStack
            .padding(15) // Padding inside the card
            
        } // End ZStack
        .frame(height: 130) // Fixed height for list consistency
    }
}


// MARK: - Preview Providers (Adapted for Themed Views)

struct SpotifyAlbumListView_Previews: PreviewProvider {
    static var previews: some View {
        SpotifyAlbumListView()
            .preferredColorScheme(.dark)
    }
}

struct PsychedelicAlbumCard_Previews: PreviewProvider {
    // Reusing mock data from previous previews
    static let mockArtist = Artist(
        id: "artist1",
        external_urls: nil,
        href: "",
        name: "Miles Davis Mock",
        type: "artist",
        uri: ""
    )
    static let mockImage = SpotifyImage(
        height: 300,
        url: "https://i.scdn.co/image/ab67616d00001e027ab89c25093ea3787b1995b4",
        width: 300
    )
    static let mockAlbumItem = AlbumItem(
        id: "album1",
        album_type: "album",
        total_tracks: 5,
        available_markets: ["US"],
        external_urls: ExternalUrls(spotify: ""),
        href: "",
        images: [mockImage],
        name: "Kind of Blue [Psychedelic Preview]",
        release_date: "1959-08-17",
        release_date_precision: "day",
        type: "album",
        uri: "spotify:album:1weenld61qoidwYuZ1GESA",
        artists: [mockArtist]
    )
    
    static var previews: some View {
        PsychedelicAlbumCard(album: mockAlbumItem)
            .padding()
            .background(
                LinearGradient(gradient: Gradient(colors: [psychedelicBackgroundStart, psychedelicBackgroundEnd]),
                               startPoint: .top,
                               endPoint: .bottom)
            )
            .previewLayout(.sizeThatFits)
            .preferredColorScheme(.dark)
    }
}

struct AlbumDetailView_Previews: PreviewProvider {
    static let mockArtist = Artist(id: "artist1", external_urls: nil, href: "", name: "Miles Davis Mock", type: "artist", uri: "")
    static let mockImage = SpotifyImage(height: 640, url: "https://i.scdn.co/image/ab67616d0000b2737ab89c25093ea3787b1995b4", width: 640)
    static let mockAlbum = AlbumItem(id: "1weenld61qoidwYuZ1GESA", album_type: "album", total_tracks: 5, available_markets: ["US", "GB"], external_urls: ExternalUrls(spotify: "https://open.spotify.com/album/1weenld61qoidwYuZ1GESA"), href: "", images: [mockImage], name: "Kind Of Blue (Psychedelic Preview)", release_date: "1959-08-17", release_date_precision: "day", type: "album", uri: "spotify:album:1weenld61qoidwYuZ1GESA", artists: [mockArtist])
    
    static var previews: some View {
        NavigationView {
            AlbumDetailView(album: mockAlbum)
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - App Entry Point

@main
struct SpotifyPsychedelicApp: App {
    init() {
        // --- Token Check ---
        if placeholderSpotifyToken == "YOUR_SPOTIFY_BEARER_TOKEN_HERE" {
            print("🚨🌌 FATAL STARTUP WARNING: Spotify Bearer Token missing! API calls will fail.")
            print("👉 FIX: Replace 'YOUR_SPOTIFY_BEARER_TOKEN_HERE' in your Swift file.")
        }
        // --- Global UI Appearance (Optional - Less needed with direct view styling) ---
        // Global tint could be set here if desired for elements like ActivityIndicator
        UIView.appearance().tintColor = UIColor(psychedelicAccentCyan)
    }
    
    var body: some Scene {
        WindowGroup {
            SpotifyAlbumListView() // Start with the themed list view
                .preferredColorScheme(.dark) // Enforce dark mode for theme consistency
        }
    }
}
