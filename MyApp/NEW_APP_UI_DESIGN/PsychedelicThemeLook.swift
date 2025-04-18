//
//  PsychedelicThemeLook.swift
//  MyApp
//
//  Created by Cong Le on 4/18/25.
//

//  Synthesized version combining all features with Psychedelic Theme
//

import SwiftUI
@preconcurrency import WebKit // Needed for WebView
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
    Font.system(size: size, weight: .bold, design: .serif)
    // Example custom font: Font.custom("YourPsychedelicFontName", size: size)
}

func psychedelicBodyFont(size: CGFloat, weight: Font.Weight = .regular) -> Font {
    // A clean, readable sans-serif
    Font.system(size: size, weight: weight, design: .rounded) // Rounded might feel more organic
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
        //        private func createSpotifyController(with initialUri: String) { /* ... JS execution from previous version ... */
        //            guard let webView = webView, isApiReady else { return }
        ////            guard lastLoadedUri == nil else { // Only init once
        ////                if let latestDesired = desiredUriBeforeReady ?? parent.spotifyUri,
        ////                    latestDesired != lastLoadedUri {
        ////                    loadUri(latestDesired)
        ////                    desiredUriBeforeReady = nil
        ////                }
        ////                return
        ////            }
        //            print("🚀 Embed Native: Creating controller for URI: \(initialUri)")
        //            lastLoadedUri = initialUri
        //            let script = """
        //             console.log('JS: Initial creation script.'); window.embedController = null; const element = document.getElementById('embed-iframe');
        //             if (!element || !window.IFrameAPI) { console.error('JS: Element or API missing!'); window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: 'Element or API missing' }); return; }
        //             console.log('JS: Creating controller for \(initialUri)'); const options = { uri: '\(initialUri)', width: '100%', height: '80' };
        //             const callback = (controller) => { if (!controller) { console.error('JS: Null controller!'); window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: 'Null JS controller' }); return; }
        //             console.log('✅ JS: Controller received.'); window.embedController = controller; window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'controllerCreated' });
        //             controller.addListener('ready', () => console.log('JS: Controller Ready event.'));
        //             controller.addListener('playback_update', e => window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'playbackUpdate', data: e.data }));
        //             controller.addListener('error', e => { console.error('JS Error:', e.data); window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: e.data }); }); };
        //             try { window.IFrameAPI.createController(element, options, callback); } catch (e) { console.error('JS Error calling createController:', e); }
        //             """
        //            webView.evaluateJavaScript(script) { _, error in if let error = error { print("⚠️ Embed Native: Error JS creation: \(error)") } }
        //        }
        
        
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

// MARK: - API Service (Unchanged Functionality, Use Placeholder Token)

let placeholderSpotifyToken = "YOUR_SPOTIFY_BEARER_TOKEN_HERE" // Needs replacement!

enum SpotifyAPIError: Error, LocalizedError { /* ... Enum cases (Unchanged) ... */
    case invalidURL
    case networkError(Error)
    case invalidResponse(Int, String?)
    case decodingError(Error)
    case invalidToken
    case missingData
    
    var errorDescription: String? { /* ... Descriptions (Unchanged) ... */
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
struct SpotifyAPIService { // Unchanged Functionality
    static let shared = SpotifyAPIService()
    private let session: URLSession
    
    init() { /* ... Session setup (Unchanged) ... */
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        session = URLSession(configuration: configuration)
    }
    
    private func makeRequest<T: Decodable>(url: URL) async throws -> T { /* ... Request Logic (Unchanged) ... */
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
    // searchAlbums, getAlbumTracks (Unchanged)
    func searchAlbums(query: String, limit: Int = 20, offset: Int = 0) async throws -> SpotifySearchResponse { /* ... */
        var components = URLComponents(string: "https://api.spotify.com/v1/search")
        components?.queryItems = [ URLQueryItem(name: "q", value: query), URLQueryItem(name: "type", value: "album"), URLQueryItem(name: "include_external", value: "audio"), URLQueryItem(name: "limit", value: "\(limit)"), URLQueryItem(name: "offset", value: "\(offset)") ]
        guard let url = components?.url else { throw SpotifyAPIError.invalidURL }
        return try await makeRequest(url: url)
    }
    func getAlbumTracks(albumId: String, limit: Int = 50, offset: Int = 0) async throws -> AlbumTracksResponse { /* ... */
        var components = URLComponents(string: "https://api.spotify.com/v1/albums/\(albumId)/tracks")
        components?.queryItems = [ URLQueryItem(name: "limit", value: "\(limit)"), URLQueryItem(name: "offset", value: "\(offset)") ]
        guard let url = components?.url else { throw SpotifyAPIError.invalidURL }
        return try await makeRequest(url: url)
    }
}

// MARK: - SwiftUI Views (Themed)

// MARK: - Main List View (Themed)
struct SpotifyAlbumListView: View {
    // --- State Variables (Unchanged) ---
    @State private var searchQuery: String = ""
    @State private var displayedAlbums: [AlbumItem] = []
    @State private var isLoading: Bool = false
    @State private var searchInfo: Albums? = nil
    @State private var currentError: SpotifyAPIError? = nil
    
    // --- Main Body ---
    var body: some View {
        NavigationView {
            ZStack {
                // Build the background view
                viewBackground()
                
                // Build the main content area (handles loading/error/empty/list states)
                mainContentContainer()
                
                // Build the loading overlay (shown on top when loading *more*)
                loadingIndicatorOverlay()
            }
            // --- Modifiers applied to the ZStack's container (NavigationView) ---
            .navigationTitle("Psychedelic Search") // Keep title setup here
            .navigationBarTitleDisplayMode(.large)
            .toolbar { toolbarContent() } // Extracted Toolbar Content
            //.toolbarBackground(toolbarBackground(), for: .navigationBar) // Extracted Toolbar Background
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .searchable(text: $searchQuery, placement: .navigationBarDrawer(displayMode: .always)) {
                // Suggestions view can be added here if desired
            }
            .onSubmit(of: .search) { Task { await performDebouncedSearch(immediate: true) } }
            .task(id: searchQuery) { await performDebouncedSearch() } // Debounce on query change
            .onChange(of: searchQuery) { if currentError != nil { currentError = nil } } // Reset error on new search
        }
        .accentColor(psychedelicAccentPink) // Apply accent color to the whole navigation view
        .onAppear { styleSearchPlaceholderAppearance() } // Attempt placeholder styling on appear
    }
    
    // MARK: - @ViewBuilder Sub-Components
    
    // Builds the primary background gradient and noise effect
    @ViewBuilder
    private func viewBackground() -> some View {
        LinearGradient(gradient: Gradient(colors: [psychedelicBackgroundStart, psychedelicBackgroundEnd]), startPoint: .top, endPoint: .bottom)
            .overlay(AnimatedPsychedelicBackgroundNoise().opacity(0.08))
            .ignoresSafeArea()
    }
    
    // Builds the main content: switches between loading, error, empty, or the album list
    @ViewBuilder
    private func mainContentContainer() -> some View {
        Group { // Group is necessary for the conditional logic within @ViewBuilder
            if isLoading && displayedAlbums.isEmpty {
                initialLoadingView() // Extracted initial loading indicator
            } else if let error = currentError {
                ErrorPlaceholderView(error: error) { Task { await performDebouncedSearch() } }
            } else if displayedAlbums.isEmpty && !searchQuery.isEmpty { // Show empty state only after a search attempt
                EmptyStatePlaceholderView(searchQuery: searchQuery)
            } else if displayedAlbums.isEmpty && searchQuery.isEmpty { // Show initial prompt
                EmptyStatePlaceholderView(searchQuery: searchQuery) // Or a dedicated initial view
            } else {
                albumList() // Show the actual list
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity) // Ensure content area fills space
        .transition(.opacity.animation(.easeOut(duration: 0.4))) // Fade transition
    }
    
    // Builds the initial loading indicator (when the list is empty)
    @ViewBuilder
    private func initialLoadingView() -> some View {
        ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: psychedelicAccentCyan))
            .scaleEffect(1.8)
            .shadow(color: psychedelicAccentCyan.opacity(0.6), radius: 8)
    }
    
    // Builds the overlay loading indicator (shown when fetching more/refreshing)
    @ViewBuilder
    private func loadingIndicatorOverlay() -> some View {
        // Only show this overlay if we are loading *and* there are already albums displayed
        if isLoading && !displayedAlbums.isEmpty {
            VStack {
                HStack {
                    Spacer()
                    ProgressView().tint(psychedelicAccentLime)
                    Text("LOADING...")
                        .font(psychedelicBodyFont(size: 11, weight: .bold))
                        .foregroundColor(psychedelicAccentLime)
                        .tracking(1.5)
                    Spacer()
                }
                .padding(.vertical, 5)
                .padding(.horizontal, 15)
                // .background(.black.opacity(0.7).blur(radius: 5))
                .clipShape(Capsule())
                .overlay(Capsule().stroke(psychedelicAccentLime.opacity(0.4), lineWidth: 1))
                .shadow(color: psychedelicAccentLime, radius: 5)
                .padding(.top, 10) // Position it from the top
                .transition(.opacity.animation(.easeInOut))
                Spacer() // Pushes the indicator to the top
            }
        } else {
            EmptyView() // Return EmptyView when the condition is false
        }
    }
    
    // Builds the scrollable list of album cards
    @ViewBuilder
    private func albumList() -> some View {
        ScrollView {
            LazyVStack(spacing: 0) { // spacing: 0; padding added to the card itself
                // --- Search Metadata Header ---
                if let info = searchInfo, info.total > 0 {
                    SearchMetadataHeader(totalResults: info.total, limit: info.limit, offset: info.offset)
                        .padding(.horizontal)
                        .padding(.bottom, 10)
                }
                
                // --- Album Cards ---
                ForEach(displayedAlbums) { album in
                    NavigationLink(destination: AlbumDetailView(album: album)) {
                        PsychedelicAlbumCard(album: album)
                            .padding(.vertical, 12)
                            .padding(.horizontal) // Padding around each card
                    }
                    .buttonStyle(.plain) // Remove default NavLink styling
                }
                
                // TODO: Add pagination / load more indicator here if needed
            }
            .padding(.top, 10) // Padding above the first item in the list
        }
        .scrollDismissesKeyboard(.interactively) // Dismiss keyboard on scroll
    }
    
    // Builds the content for the navigation bar's toolbar
    @ViewBuilder
    private func toolbarContent() -> some View {
        //        ToolbarItem(placement: .automatic) { // Use .principal for centered large title area
        Text("Psychedelic Search")
            .font(Font.custom("Papyrus", size: 26).weight(.bold)) // Example expressive font
            .foregroundStyle(
                LinearGradient(gradient: psychedelicVibrantGradient, startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .shadow(color: .black.opacity(0.3), radius: 1, y: 1)
        //        }
        // Add other toolbar items if needed (e.g., Filter button)
        // ToolbarItem(placement: .navigationBarTrailing) { Button("Filter") {} }
    }
    
    // Builds the background view for the toolbar
    @ViewBuilder
    private func toolbarBackground() -> some View {
        LinearGradient(colors: [psychedelicBackgroundEnd.opacity(0.9), psychedelicBackgroundStart.opacity(0.8)], startPoint: .top, endPoint: .bottom)
            .blur(radius: 8)
    }
    
    // --- Helper Methods ---
    
    // Placeholder styling (Keep implementation attempt)
    private func styleSearchPlaceholderAppearance() {
        // Attempt to style search bar placeholder via UIKit appearance
        // Note: This can be fragile and might break in future iOS versions.
        let placeholderAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(psychedelicAccentPink.opacity(0.7)),
            .font: UIFont.systemFont(ofSize: 17, weight: .regular) // Adjust font as needed
        ]
        UISearchTextField.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).attributedPlaceholder = NSAttributedString(string: "Search vibes...", attributes: placeholderAttributes)
    }
    
    // --- Debounced Search Logic (Unchanged) ---
    private func performDebouncedSearch(immediate: Bool = false) async {
        let trimmedQuery = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // If query is empty, clear results immediately
        guard !trimmedQuery.isEmpty else {
            await MainActor.run {
                displayedAlbums = []
                searchInfo = nil
                isLoading = false
                currentError = nil
            }
            return
        }
        
        // Debounce logic
        if !immediate {
            do {
                try await Task.sleep(for: .milliseconds(600))
                try Task.checkCancellation() // Check if task was cancelled (e.g., user typed again)
            } catch {
                print("Search task cancelled (debounce).")
                return // Exit if cancelled
            }
        }
        
        // Start loading state
        await MainActor.run { isLoading = true }
        
        // Perform API call
        do {
            let response = try await SpotifyAPIService.shared.searchAlbums(query: trimmedQuery, offset: 0) // Reset offset for new search
            try Task.checkCancellation() // Check again after API call
            
            // Update UI on main thread
            await MainActor.run {
                displayedAlbums = response.albums.items
                searchInfo = response.albums
                currentError = nil
                isLoading = false
            }
        } catch is CancellationError {
            print("Search task cancelled.")
            await MainActor.run { isLoading = false } // Ensure loading stops if cancelled during API call
        } catch let apiError as SpotifyAPIError {
            print("❌ API Error: \(apiError.localizedDescription)")
            await MainActor.run { displayedAlbums = []; searchInfo = nil; currentError = apiError; isLoading = false }
        } catch {
            print("❌ Unexpected Error: \(error.localizedDescription)")
            await MainActor.run { displayedAlbums = []; searchInfo = nil; currentError = .networkError(error); isLoading = false }
        }
    }
}

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
                    //                        .background(.black.opacity(0.4).blur(radius: 3), in: Capsule()) // Blurred capsule
                    
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
                LinearGradient(colors: [.black.opacity(0.7), .black.opacity(0.3)], startPoint: .bottom, endPoint: .top)
                    .blur(radius: 10) // Blurred background behind text for readability
            )
            .frame(maxWidth: .infinity, alignment: .leading) // Ensure text background spans width
            // Clip text background area to match card rounding
            .mask(alignment: .bottom) { RoundedRectangle(cornerRadius: 25, style: .continuous) }
            
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
                let randomColor = Color(hue: Double.random(in: 0...1, using: &rng), saturation: 0.8, brightness: 1.0)
                context.fill(
                    Path(ellipseIn: CGRect(x: x - radius / 2, y: y - radius / 2, width: radius, height: radius)),
                    with: .color(randomColor.opacity(Double.random(in: 0.3...0.7, using: &rng)))
                )
            }
        }
    }
}
struct SeededRandomNumberGenerator: RandomNumberGenerator {
    private var state: UInt64
    init(seed: UInt64) { state = seed == 0 ? 1 : seed } // Avoid zero state
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
                    LinearGradient(gradient: Gradient(colors: [psychedelicAccentPink, psychedelicAccentOrange]), startPoint: .topLeading, endPoint: .bottomTrailing)
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
            //.overlay(psychedelicPurples[2].opacity(0.1)) // Subtle purple tint
            //.clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
            //.overlay(RoundedRectangle(cornerRadius: 30, style: .continuous).stroke(LinearGradient(gradient: psychedelicVibrantGradient, startPoint: .topLeading, endPoint: .bottomTrailing).opacity(0.3), lineWidth: 1))
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
        // message.font = retroFont(size: 14)
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
            // --- Psychedelic Background (Consistent) ---
            LinearGradient(gradient: Gradient(colors: [psychedelicBackgroundStart, psychedelicBackgroundEnd]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .overlay(AnimatedPsychedelicBackgroundNoise().opacity(0.05)) // Subtle noise
                .ignoresSafeArea()
            
            ScrollView { // Use ScrollView for content
                VStack(spacing: 0) { // Use VStack within ScrollView
                    // --- Header Section (Themed) ---
                    AlbumHeaderView(album: album) // Themed Header
                        .padding(.bottom, 25)
                    
                    // --- Player Section (Themed) ---
                    if let uriToPlay = selectedTrackUri {
                        SpotifyEmbedPlayerView(playbackState: playbackState, spotifyUri: uriToPlay) // Themed Player container
                            .padding(.horizontal) // Padding around player
                            .padding(.bottom, 25)
                            .transition(.opacity.combined(with: .scale(scale: 0.95, anchor: .top)).animation(.spring(response: 0.4, dampingFraction: 0.7))) // Spring animation
                    }
                    
                    // --- Tracks Section (Themed) ---
                    TracksSectionView(
                        tracks: tracks, isLoading: isLoadingTracks, error: trackFetchError,
                        selectedTrackUri: $selectedTrackUri,
                        retryAction: { Task { await fetchTracks() } }
                    ) // Themed tracks section
                    .padding(.bottom, 25)
                    
                    // --- External Link Section (Themed) ---
                    if let spotifyURLString = album.external_urls.spotify, let url = URL(string: spotifyURLString) {
                        PsychedelicButton(text: "EXPLORE ON SPOTIFY", action: { openURL(url) },
                                          iconName: "arrow.up.right.circle.fill",
                                          gradient: Gradient(colors: [psychedelicAccentLime, psychedelicAccentCyan])) // Themed button
                        .padding(.horizontal)
                        .padding(.bottom, 30) // Extra padding at bottom
                    }
                }
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .navigationTitle(album.name)
        .navigationBarTitleDisplayMode(.inline)
        // Consistent Themed Navigation Bar
        //        .toolbarBackground(
        //            LinearGradient(colors: [psychedelicBackgroundEnd.opacity(0.9), psychedelicBackgroundStart.opacity(0.8)], startPoint: .top, endPoint: .bottom)
        //                .blur(radius: 8),
        //            for: .navigationBar
        //        )
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .task { await fetchTracks() }
        .refreshable { await fetchTracks(forceReload: true) }
    }
    
    // --- Fetch Tracks Logic (Unchanged) ---
    private func fetchTracks(forceReload: Bool = false) async { /* ... Logic from previous versions ... */
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
        VStack(spacing: 18) {
            AlbumImageView(url: album.bestImageURL)
                .aspectRatio(1.0, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous)) // More rounded
                .overlay(
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .stroke(
                            AngularGradient(gradient: psychedelicVibrantGradient, center: .center, angle: .degrees(90))
                                .opacity(0.5), // Use angular gradient for border
                            lineWidth: 2
                        )
                )
                .psychedelicGlow(psychedelicAccentCyan, radius: 25) // Stronger glow for main art
                .padding(.horizontal, 40) // More padding around art
            
            VStack(spacing: 8) {
                Text(album.name)
                    .font(psychedelicTitleFont(size: 26))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .shadow(color: .black.opacity(0.4), radius: 2, y: 1)
                
                Text("by \(album.formattedArtists)")
                    .font(psychedelicBodyFont(size: 17, weight: .semibold ))
                    .foregroundStyle( // Gradient text for artist
                        LinearGradient(gradient: Gradient(colors:[psychedelicAccentLime, psychedelicAccentCyan]), startPoint: .leading, endPoint: .trailing)
                    )
                    .multilineTextAlignment(.center)
                
                Text("\(album.album_type.capitalized) • \(album.formattedReleaseDate())")
                    .font(psychedelicBodyFont(size: 13, weight: .regular))
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(.horizontal)
            
        }
        .padding(.top, 20) // Padding above the header content
    }
}

struct SpotifyEmbedPlayerView: View {
    @ObservedObject var playbackState: SpotifyPlaybackState
    let spotifyUri: String
    
    var body: some View {
        EmptyView()
    }
    
    //    var body: some View {
    //        VStack(spacing: 10) { // Increased spacing
    //            SpotifyEmbedWebView(playbackState: playbackState, spotifyUri: spotifyUri)
    //                .frame(height: 85) // Slightly more vertical space for player
    //                .background(
    //                    ZStack { // Layered background for depth
    //                        LinearGradient(gradient: Gradient(colors: [psychedelicPurples[0].opacity(0.5), .black.opacity(0.6)]), startPoint: .top, endPoint: .bottom)
    //                        PsychedelicWave(startColor: psychedelicAccentCyan.opacity(0.1), endColor: psychedelicAccentPink.opacity(0.1)) // Faint wave in bg
    //                            .blur(radius: 5)
    //                    }
    //                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous)) // Rounded container
    //                        .overlay(
    //                            RoundedRectangle(cornerRadius: 20, style: .continuous)
    //                                .stroke( // Animated border based on playback
    //                                    LinearGradient(gradient: Gradient(colors: playbackState.isPlaying ? [psychedelicAccentLime, psychedelicAccentCyan] : [psychedelicAccentPink, psychedelicPurples[1]]), startPoint: .leading, endPoint: .trailing),
    //                                    lineWidth: 1.5
    //                                       )
    //                                .opacity(playbackState.isPlaying ? 1.0 : 0.6) // Fade border when paused
    //                        )
    //                )
    //                .psychedelicGlow(playbackState.isPlaying ? psychedelicAccentLime : psychedelicAccentPink, radius: 15) // Dynamic glow
    //                .animation(.easeInOut (duration: 0.5), value: playbackState.isPlaying) // Smooth animation for glow/border
    //
    //            // --- Themed Playback Status ---
    //            HStack {
    //                let statusText = playbackState.isPlaying ? "TRANSMITTING" : "PAUSED"
    //                let statusColor = playbackState.isPlaying ? psychedelicAccentLime : psychedelicAccentPink
    //
    //                Text(statusText)
    //                    .font(psychedelicBodyFont(size: 11, weight: .bold))
    //                    .foregroundColor(statusColor)
    //                    .tracking(2.0) // Wider letter spacing for psychedelic feel
    //                    .shadow(color: statusColor.opacity(0.5), radius: 3)
    //                    .lineLimit(1)
    //                    .frame(minWidth: 100, alignment: .leading) // Ensure minimum width
    //
    //                Spacer()
    //
    //                if playbackState.duration > 0.1 {
    //                    Text("\(formatTime(playbackState.currentPosition)) / \(formatTime(playbackState.duration))")
    //                        .font(psychedelicBodyFont(size: 12, weight: .medium))
    //                        .foregroundColor(.white.opacity(0.85))
    //                } else {
    //                    Text("--:-- / --:--")
    //                        .font(psychedelicBodyFont(size: 12, weight: .medium))
    //                        .foregroundColor(.white.opacity(0.6))
    //                }
    //            }
    //            .padding(.horizontal, 10) // Less horizontal padding for status bar
    //
    //        }
    //    }
    
    // Format time (Unchanged)
    private func formatTime(_ time: Double) -> String { /* ... */
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
        EmptyView()
    }
    
    //    var body: some View {
    //        VStack(alignment: .leading, spacing: 0) { // Use VStack, remove Section for custom header
    //            // --- Custom Section Header ---
    //            Text("TRACKLIST FREQUENCIES")
    //                .font(psychedelicBodyFont(size: 14, weight: .bold))
    //                .foregroundStyle(LinearGradient(gradient: Gradient(colors: [psychedelicAccentCyan, psychedelicAccentLime]), startPoint: .leading, endPoint: .trailing))
    //                .tracking(2.5) // Wider tracking
    //                .padding(.horizontal)
    //                .padding(.bottom, 15)
    //                .frame(maxWidth: .infinity, alignment: .center)
    //
    //            // --- Content Area with Themed Background ---
    //            Group { // Group content to apply background/padding once
    //                if isLoading {
    //                    HStack { Spacer(); ProgressView().tint(psychedelicAccentCyan); Text("Scanning...") .font(psychedelicBodyFont(size: 14)); Spacer() }
    //                        .padding(.vertical, 30)
    //                } else if let error = error {
    //                    ErrorPlaceholderView(error: error, retryAction: retryAction) // Use themed error view
    //                        .padding(.vertical, 20)
    //                } else if tracks.isEmpty {
    //                    Text("Signal Lost - No Tracks Found")
    //                        .font(psychedelicBodyFont(size: 14))
    //                        .foregroundColor(.white.opacity(0.6))
    //                        .frame(maxWidth: .infinity, alignment: .center)
    //                        .padding(.vertical, 30)
    //                } else {
    //                    ForEach(tracks) { track in
    //                        TrackRowView(track: track, isSelected: track.uri == selectedTrackUri)
    //                            .contentShape(Rectangle())
    //                            .onTapGesture { selectedTrackUri = track.uri }
    //                        // --- Themed Selection Background ---
    //                            .background(
    //                                track.uri == selectedTrackUri
    //                                ? LinearGradient(gradient: Gradient(colors: [psychedelicAccentCyan.opacity(0.25), psychedelicAccentPink.opacity(0.15)]), startPoint: .leading, endPoint: .trailing)
    //                                    .blur(radius: 8) // Slightly more pronounced blur
    //                                : Color.clear
    //                            )
    //                            .listRowSeparator(.hidden) // Hide separators if needed
    //                        Divider().background(Color.white.opacity(0.1)).padding(.leading) // Subtle custom divider
    //                    }
    //                }
    //            }
    //            .padding(.horizontal) // Apply horizontal padding to content within the background
    //            .background(
    //                .black.opacity(0.2) // Dark, semi-transparent background for the track list area
    //                    .blur(radius: 5)
    //            )
    //            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous)) // Rounded background for track list
    //            .padding(.horizontal) // Padding around the track list background
    //
    //        }
    //    }
}

struct TrackRowView: View {
    let track: Track
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 15) { // Increased spacing
            // --- Track Number ---
            Text("\(track.track_number)")
                .font(psychedelicBodyFont(size: 14, weight: .medium))
                .foregroundColor(isSelected ? psychedelicAccentLime : .white.opacity(0.6))
                .frame(width: 25, alignment: .center)
                .shadow(color: isSelected ? psychedelicAccentLime.opacity(0.5) : .clear, radius: 3)
            
            // --- Track Info ---
            VStack(alignment: .leading, spacing: 4) { // Increased spacing
                Text(track.name)
                    .font(psychedelicBodyFont(size: 16, weight: isSelected ? .bold : .regular))
                    .foregroundColor(isSelected ? .white : .white.opacity(0.9)) // Brighter white when selected
                    .lineLimit(1)
                Text(track.formattedArtists)
                    .font(psychedelicBodyFont(size: 12, weight: .light)) // Lighter weight for artist
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(1)
            }
            Spacer()
            // --- Duration ---
            Text(track.formattedDuration)
                .font(psychedelicBodyFont(size: 13, weight: .regular)) // Slightly larger duration font
                .foregroundColor(.white.opacity(0.7))
                .padding(.trailing, 5)
            
            // --- Play Indicator ---
            Image(systemName: isSelected ? "waveform.path.ecg" : "play.circle.fill") // Use filled play icon
                .font(.system(size: 20)) // Larger icon
                .foregroundColor(isSelected ? psychedelicAccentCyan : .white.opacity(0.6))
                .shadow(color: isSelected ? psychedelicAccentCyan.opacity(0.6): .clear, radius: 5)
                .symbolEffect(.variableColor.reversing.cumulative, options: .speed(1).repeat(isSelected ? 3 : 0) , value: isSelected) // Example subtle animation
                .animation(.easeInOut, value: isSelected) // Smooth transition
            
        }
        .padding(.vertical, 15) // More vertical padding
        .padding(.horizontal, 10) // Adjust horizontal padding if needed
        // Remove listRowBackground here, apply it in TracksSectionView's ForEach
    }
}

// MARK: - Other Supporting Views (Themed)

struct AlbumImageView: View { // Keep fundamental AsyncImage logic
    let url: URL?
    var cornerRadius: CGFloat = 15 // Default corner radius
    
    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .empty: // Placeholder while loading
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius).fill(psychedelicBackgroundEnd.opacity(0.5))
                    ProgressView().tint(psychedelicAccentCyan)
                }
            case .success(let image):
                image.resizable()
                    .scaledToFit() // Can be .fit or .fill depending on usage
                    .transition(.opacity.animation(.easeIn))
            case .failure: // Placeholder on error
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius).fill(psychedelicBackgroundEnd.opacity(0.5))
                    Image(systemName: "exclamationmark.triangle.fill") // More prominent error icon
                        .resizable().scaledToFit()
                        .foregroundColor(psychedelicAccentPink.opacity(0.7))
                        .padding(15) // Larger padding
                }
            @unknown default: EmptyView()
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)) // Consistent rounding
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
        //.background(.black.opacity(0.2).blur(radius: 3))
        .clipShape(Capsule()) // Capsule shape for metadata
    }
}

// MARK: - Themed Button Component
struct PsychedelicButton: View {
    let text: String
    let action: () -> Void
    var iconName: String? = nil
    var gradient: Gradient = Gradient(colors: [psychedelicAccentPink, psychedelicAccentOrange]) // Default gradient
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
            .shadow(color: .black.opacity(0.3), radius: 5, y: 3) // Standard shadow for depth
            .overlay( // Add subtle inner/outer border for effect
                Capsule()
                    .stroke(LinearGradient(gradient: Gradient(colors: [.white.opacity(0.3), .clear]), startPoint: .top, endPoint: .center).opacity(0.5), lineWidth: 1) // Top highlight
            )
            .overlay(
                Capsule()
                    .stroke(LinearGradient(gradient: Gradient(colors: [.clear, .black.opacity(0.3)]), startPoint: .center, endPoint: .bottom).opacity(0.5), lineWidth: 1) // Bottom shadow
            )
            .modifier(ConditionalPsychedelicGlow(color: glowColor ?? gradient.stops.first?.color ?? psychedelicAccentPink, apply: glowColor != nil, radius: 12))
            
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

// MARK: - Preview Providers (Adapted for Themed Views)

struct SpotifyAlbumListView_Previews: PreviewProvider {
    static var previews: some View {
        SpotifyAlbumListView()
            .preferredColorScheme(.dark)
    }
}

struct PsychedelicAlbumCard_Previews: PreviewProvider {
    // Reusing mock data from previous previews
    static let mockArtist = Artist(id: "artist1", external_urls: nil, href: "", name: "Miles Davis Mock", type: "artist", uri: "")
    static let mockImage = SpotifyImage(height: 300, url: "https://i.scdn.co/image/ab67616d00001e027ab89c25093ea3787b1995b4", width: 300)
    static let mockAlbumItem = AlbumItem(id: "album1", album_type: "album", total_tracks: 5, available_markets: ["US"], external_urls: ExternalUrls(spotify: ""), href: "", images: [mockImage], name: "Kind of Blue [Psychedelic Preview]", release_date: "1959-08-17", release_date_precision: "day", type: "album", uri: "spotify:album:1weenld61qoidwYuZ1GESA", artists: [mockArtist])
    
    static var previews: some View {
        PsychedelicAlbumCard(album: mockAlbumItem)
            .padding()
            .background(LinearGradient(gradient: Gradient(colors: [psychedelicBackgroundStart, psychedelicBackgroundEnd]), startPoint: .top, endPoint: .bottom))
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
struct SpotifyPsychedelicApp: App { // Renamed App struct
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
