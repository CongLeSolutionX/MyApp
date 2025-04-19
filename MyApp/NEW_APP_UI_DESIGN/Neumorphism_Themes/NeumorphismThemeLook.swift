////
////  NeumorphismThemeLook.swift
////  MyApp
////
////  Created by Cong Le on 4/18/25.
////
//
////
////  SpotifyNeumorphicApp.swift
////  MyApp (Renamed concept)
////  Created: Synthesis from prior versions
////
//
//import SwiftUI
//@preconcurrency import WebKit // Needed for WebView
//import Foundation
//
//// MARK: - Neumorphism Theme Constants & Modifiers
//
//// --- Base Colors ---
//// Light Mode Base (adjust as needed)
//let neumorphicBG = Color(UIColor.systemGray6) // A common subtle off-white/light gray
//// Dark Mode can be added later by detecting color scheme or using different constants
//
//// --- Shadow/Highlight Colors ---
//// Derived from the background color
//let neumorphicShadowLight = Color.white.opacity(0.7) // Light source highlight
//let neumorphicShadowDark = Color.black.opacity(0.18) // Ambient shadow
//
//// --- Text & Accent Colors ---
//let neumorphicTextColorPrimary = Color.primary.opacity(0.8)
//let neumorphicTextColorSecondary = Color.secondary.opacity(0.7)
//let neumorphicAccentColor = Color.blue // Example accent, keep it somewhat desaturated or subtle
//
//// --- Font ---
//// Neumorphism usually pairs well with clean, sans-serif fonts
//func neumorphicFont(size: CGFloat, weight: Font.Weight = .regular) -> Font {
//    Font.system(size: size, weight: weight, design: .default)
//}
//
//// --- Neumorphic Modifiers ---
//
//extension View {
//    /// Applies the standard neumorphic extruded shadow effect.
//    func neumorphicShadow(radius: CGFloat = 8, xOffset: CGFloat = 4, yOffset: CGFloat = 4) -> some View {
//        self
//            .shadow(color: neumorphicShadowDark, radius: radius, x: xOffset, y: yOffset)
//            .shadow(color: neumorphicShadowLight, radius: radius, x: -xOffset, y: -yOffset)
//    }
//    
//    /// Applies a neumorphic pressed/indented shadow effect.
//    func neumorphicShadowPressed(radius: CGFloat = 5, intensity: CGFloat = 0.1) -> some View {
//        let darkInset = Color.black.opacity(intensity)
//        let lightInset = Color.white.opacity(intensity * 2.5) // Highlights are often stronger
//        return ZStack { // Use ZStack to layer inset shadows
//            self
//            // Inner dark shadow (top-left)
//            RoundedRectangle(cornerRadius: 15) // Match shape if possible
//                .stroke(darkInset, lineWidth: radius)
//                .blur(radius: radius / 2)
//                .offset(x: radius / 2, y: radius / 2)
//                .mask(self) // Clip shadow to the view shape
//            // Inner light shadow (bottom-right)
//            RoundedRectangle(cornerRadius: 15) // Match shape if possible
//                .stroke(lightInset, lineWidth: radius)
//                .blur(radius: radius / 2)
//                .offset(x: -radius / 2, y: -radius / 2)
//                .mask(self) // Clip shadow to the view shape
//        }
//    }
//    
//    /// Creates a base neumorphic surface (background + corner radius).
//    func neumorphicSurface(cornerRadius: CGFloat = 15) -> some View {
//        self
//            .background(neumorphicBG)
//            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
//    }
//}
//
//// MARK: - Data Models (Unchanged)
//
//struct SpotifySearchResponse: Codable, Hashable {
//    let albums: Albums
//}
//
//struct Albums: Codable, Hashable {
//    let href: String
//    let limit: Int
//    let next: String?
//    let offset: Int
//    let previous: String?
//    let total: Int
//    let items: [AlbumItem]
//}
//
//struct AlbumItem: Codable, Identifiable, Hashable {
//    let id: String
//    let album_type: String
//    let total_tracks: Int
//    let available_markets: [String]?
//    let external_urls: ExternalUrls
//    let href: String
//    let images: [SpotifyImage]
//    let name: String
//    let release_date: String
//    let release_date_precision: String
//    let type: String // "album"
//    let uri: String
//    let artists: [Artist]
//    
//    // --- Helper computed properties ---
//    var bestImageURL: URL? {
//        images.first { $0.width == 640 }?.urlObject ??
//        images.first { $0.width == 300 }?.urlObject ??
//        images.first?.urlObject
//    }
//    var listImageURL: URL? {
//        images.first { $0.width == 300 }?.urlObject ??
//        images.first { $0.width == 64 }?.urlObject ??
//        images.first?.urlObject
//    }
//    var formattedArtists: String {
//        artists.map { $0.name }.joined(separator: ", ")
//    }
//    func formattedReleaseDate() -> String {
//        let dateFormatter = DateFormatter()
//        switch release_date_precision {
//        case "year":
//            dateFormatter.dateFormat = "yyyy"
//            if let date = dateFormatter.date(from: release_date) {
//                return dateFormatter.string(from: date)
//            }
//        case "month":
//            dateFormatter.dateFormat = "yyyy-MM"
//            if let date = dateFormatter.date(from: release_date) {
//                dateFormatter.dateFormat = "MMM yyyy"
//                return dateFormatter.string(from: date)
//            }
//        case "day":
//            dateFormatter.dateFormat = "yyyy-MM-dd"
//            if let date = dateFormatter.date(from: release_date) {
//                dateFormatter.dateFormat = "d MMM yyyy" // Use system standard if preferred
//                return dateFormatter.string(from: date)
//            }
//        default: break
//        }
//        return release_date // Fallback
//    }
//}
//
//struct Artist: Codable, Identifiable, Hashable {
//    let id: String
//    let external_urls: ExternalUrls?
//    let href: String
//    let name: String
//    let type: String // "artist"
//    let uri: String
//}
//
//struct SpotifyImage: Codable, Hashable {
//    let height: Int?
//    let url: String
//    let width: Int?
//    var urlObject: URL? { URL(string: url) }
//}
//
//struct ExternalUrls: Codable, Hashable {
//    let spotify: String?
//}
//
//struct AlbumTracksResponse: Codable, Hashable {
//    let items: [Track]
//    // Add other fields if needed
//}
//
//struct Track: Codable, Identifiable, Hashable {
//    let id: String
//    let artists: [Artist]
//    let disc_number: Int
//    let duration_ms: Int
//    let explicit: Bool
//    let external_urls: ExternalUrls?
//    let href: String
//    let name: String
//    let preview_url: String?
//    let track_number: Int
//    let type: String // "track"
//    let uri: String
//    
//    var formattedDuration: String {
//        let totalSeconds = duration_ms / 1000
//        let minutes = totalSeconds / 60
//        let seconds = totalSeconds % 60
//        return String(format: "%d:%02d", minutes, seconds)
//    }
//    var formattedArtists: String {
//        artists.map { $0.name }.joined(separator: ", ")
//    }
//}
//
//// MARK: - Spotify Embed WebView (Core logic unchanged, UI container will be themed)
//
//final class SpotifyPlaybackState: ObservableObject {
//    @Published var isPlaying: Bool = false
//    @Published var currentPosition: Double = 0 // seconds
//    @Published var duration: Double = 0 // seconds
//    @Published var currentUri: String = ""
//}
//
//struct SpotifyEmbedWebView: UIViewRepresentable {
//    @ObservedObject var playbackState: SpotifyPlaybackState
//    let spotifyUri: String?
//    
//    func makeCoordinator() -> Coordinator { Coordinator(self) }
//    
//    func makeUIView(context: Context) -> WKWebView {
//        // Configuration remains the same as before
//        let userContentController = WKUserContentController()
//        userContentController.add(context.coordinator, name: "spotifyController")
//        
//        let configuration = WKWebViewConfiguration()
//        configuration.userContentController = userContentController
//        configuration.allowsInlineMediaPlayback = true
//        configuration.mediaTypesRequiringUserActionForPlayback = []
//        
//        let webView = WKWebView(frame: .zero, configuration: configuration)
//        webView.navigationDelegate = context.coordinator
//        webView.uiDelegate = context.coordinator
//        webView.isOpaque = false // Keep transparent
//        webView.backgroundColor = .clear // To allow SwiftUI background below
//        webView.scrollView.isScrollEnabled = false
//        
//        let html = generateHTML()
//        webView.loadHTMLString(html, baseURL: nil)
//        
//        context.coordinator.webView = webView
//        return webView
//    }
//    
//    func updateUIView(_ webView: WKWebView, context: Context) {
//        // Logic remains the same
//        if context.coordinator.isApiReady && context.coordinator.lastLoadedUri != spotifyUri {
//            context.coordinator.loadUri(spotifyUri ?? "")
//            DispatchQueue.main.async {
//                if playbackState.currentUri != spotifyUri {
//                    playbackState.currentUri = spotifyUri ?? ""
//                }
//            }
//        } else if !context.coordinator.isApiReady {
//            context.coordinator.updateDesiredUriBeforeReady(spotifyUri ?? "")
//        }
//    }
//    
//    static func dismantleUIView(_ uiView: WKWebView, coordinator: Coordinator) {
//        // Cleanup remains the same
//        print("Spotify Embed WebView: Dismantling.")
//        uiView.stopLoading()
//        uiView.configuration.userContentController.removeScriptMessageHandler(forName: "spotifyController")
//        coordinator.webView = nil
//    }
//    
//    // --- Coordinator ---
//    // Coordinator class (with its methods like userContentController, handleEvent, updatePlaybackState, etc.)
//    // remains EXACTLY the same as in the previous versions.
//    // No changes needed here for theming.
//    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
//        var parent: SpotifyEmbedWebView
//        weak var webView: WKWebView?
//        var isApiReady = false
//        var lastLoadedUri: String?
//        private var desiredUriBeforeReady: String? = nil
//        
//        init(_ parent: SpotifyEmbedWebView) { self.parent = parent }
//        
//        func updateDesiredUriBeforeReady(_ uri: String) {
//            if !isApiReady {
//                desiredUriBeforeReady = uri
//            }
//        }
//        
//        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//            print("Spotify Embed WebView: HTML content finished loading.")
//        }
//        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
//            print("Spotify Embed WebView: Navigation failed: \(error.localizedDescription)")
//        }
//        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
//            print("Spotify Embed WebView: Provisional navigation failed: \(error.localizedDescription)")
//        }
//        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
//            guard message.name == "spotifyController" else { return }
//            if let bodyDict = message.body as? [String: Any], let event = bodyDict["event"] as? String {
//                print("📦 Spotify Embed Native: JS Event Received - '\(event)', Data: \(bodyDict["data"] ?? "nil")") // DEBUG
//                handleEvent(event: event, data: bodyDict["data"])
//            } else if let bodyString = message.body as? String {
//                print("📦 Spotify Embed Native: JS String Message Received - '\(bodyString)'") // DEBUG
//                if bodyString == "ready" {
//                    handleApiReady()
//                } else {
//                    print("❓ Spotify Embed Native: Received unknown string message: \(bodyString)")
//                }
//            } else {
//                print("❓ Spotify Embed Native: Received message in unexpected format: \(message.body)")
//            }
//        }
//        private func handleApiReady() {
//            print("✅ Spotify Embed Native: Spotify IFrame API reported ready.")
//            isApiReady = true
//            if let initialUri = desiredUriBeforeReady ?? parent.spotifyUri {
//                createSpotifyController(with: initialUri)
//                desiredUriBeforeReady = nil // Clear it after use
//            }
//        }
//        
//        private func handleEvent(event: String, data: Any?) {
//            switch event {
//            case "controllerCreated":
//                print("✅ Spotify Embed Native: Embed controller successfully created by JS.")
//            case "playbackUpdate":
//                if let updateData = data as? [String: Any] { updatePlaybackState(with: updateData)}
//            case "error":
//                let errorMessage = (data as? [String: Any])?["message"] as? String ?? (data as? String) ?? "Unknown JS error"
//                print("❌ Spotify Embed JS Error: \(errorMessage)")
//            default:
//                print("❓ Spotify Embed Native: Received unknown event type: \(event)")
//            }
//        }
//        
//        private func updatePlaybackState(with data: [String: Any]) {
//            DispatchQueue.main.async { [weak self] in
//                guard let self = self else { return }
//                
//                if let isPaused = data["paused"] as? Bool {
//                    if self.parent.playbackState.isPlaying == isPaused { self.parent.playbackState.isPlaying = !isPaused }
//                }
//                if let posMs = data["position"] as? Double {
//                    let newPosition = posMs / 1000.0
//                    if abs(self.parent.playbackState.currentPosition - newPosition) > 0.1 { self.parent.playbackState.currentPosition = newPosition }
//                }
//                if let durMs = data["duration"] as? Double {
//                    let newDuration = durMs / 1000.0
//                    if abs(self.parent.playbackState.duration - newDuration) > 0.1 || self.parent.playbackState.duration == 0 { self.parent.playbackState.duration = newDuration }
//                }
//                if let uri = data["uri"] as? String, self.parent.playbackState.currentUri != uri {
//                    self.parent.playbackState.currentUri = uri
//                }
//            }
//        }
//        
//        private func createSpotifyController(with initialUri: String) {
//            guard let webView = webView else { print("❌ Error: WebView is nil during controller creation."); return }
//            guard isApiReady else { print("ℹ️ Info: API not ready, deferring controller creation."); return }
//            guard lastLoadedUri == nil else { // Only init once or if specifically reset
//                // If the desired URI changed before ready, load it now
//                if let latestDesired = desiredUriBeforeReady ?? parent.spotifyUri,
//                   latestDesired != lastLoadedUri {
//                    print("🔄 Spotify Embed Native: API ready, loading changed URI: \(latestDesired)")
//                    loadUri(latestDesired)
//                    desiredUriBeforeReady = nil // Clear after use
//                } else {
//                    print("ℹ️ Spotify Embed Native: Controller already initialized or attempt pending.")
//                }
//                return
//            }
//            print("🚀 Spotify Embed Native: Attempting to create controller for URI: \(initialUri)")
//            lastLoadedUri = initialUri // Mark as attempting
//            
//            let script = """
//             console.log('Spotify Embed JS: Initial script block running.');
//             window.embedController = null;
//             const element = document.getElementById('embed-iframe');
//             if (!element) { console.error('Spotify Embed JS: Could not find element embed-iframe!'); window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'HTML element embed-iframe not found' }}); }
//             else if (!window.IFrameAPI) { console.error('Spotify Embed JS: IFrameAPI is not loaded!'); window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'Spotify IFrame API not loaded' }}); }
//             else {
//                 console.log('Spotify Embed JS: Found element and IFrameAPI. Creating controller for URI: \(initialUri)');
//                 const options = { uri: '\(initialUri)', width: '100%', height: '80' };
//                 const callback = (controller) => {
//                     if (!controller) { console.error('Spotify Embed JS: createController callback received null controller!'); window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'JS createController callback received null controller' }}); return; }
//                     console.log('✅ Spotify Embed JS: Controller instance received.');
//                     window.embedController = controller;
//                     window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'controllerCreated' });
//                     // Add Listeners
//                     controller.addListener('ready', () => { console.log('Spotify Embed JS: Controller Ready event.'); });
//                     controller.addListener('playback_update', e => { window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'playbackUpdate', data: e.data }); });
//                     controller.addListener('account_error', e => { console.warn('Spotify Embed JS: Account Error:', e.data); window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'Account Error: ' + (e.data?.message ?? 'Premium required or login issue?') }}); });
//                     controller.addListener('autoplay_failed', () => { console.warn('Spotify Embed JS: Autoplay failed'); window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'Autoplay failed' }}); controller.play(); });
//                     controller.addListener('initialization_error', e => { console.error('Spotify Embed JS: Initialization Error:', e.data); window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'Initialization Error: ' + (e.data?.message ?? 'Failed to initialize player') }}); });
//                 };
//                 try {
//                     console.log('Spotify Embed JS: Calling IFrameAPI.createController...');
//                     window.IFrameAPI.createController(element, options, callback);
//                 } catch (e) {
//                     if (e instanceof Error) { console.error('Spotify Embed JS: Error calling createController:', e); window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'JS exception during createController: ' + e.message }}); } else { console.error('Spotify Embed JS: Unknown error during createController', e); window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'Unknown JS exception during createController' }}); }
//                 }
//             }
//             """
//            webView.evaluateJavaScript(script) { _, error in /* ... Handle JS execution error ... */
//                if let error = error {
//                    print("⚠️ Spotify Embed Native: Error evaluating JS controller creation: \(error.localizedDescription)")
//                    // Reset state if JS itself failed? Risky with concurrency.
//                    // DispatchQueue.main.async { [weak self] in self?.lastLoadedUri = nil } // Example reset if needed
//                }
//            }
//        }
//        
//        func loadUri(_ uri: String) {
//            guard let webView = webView else { return }
//            guard isApiReady else { return }
//            guard lastLoadedUri != nil else { // Controller must have been initialized or attempted
//                print("⚠️ Warning: loadUri called but controller not initialized.")
//                // Optionally try to initialize now if needed? createSpotifyController(with: uri)
//                return
//            }
//            guard lastLoadedUri != uri else { return } // Don't reload same URI
//            
//            print("🚀 Spotify Embed Native: Attempting to load new URI: \(uri)")
//            lastLoadedUri = uri
//            
//            let script = """
//            if (window.embedController) {
//                console.log('Spotify Embed JS: Loading URI: \(uri)');
//                window.embedController.loadUri('\(uri)');
//                window.embedController.play(); // Attempt to play immediately
//            } else { console.error('Spotify Embed JS: embedController not found for loadUri \(uri).'); window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'JS embedController not found during loadUri' }}); }
//            """
//            webView.evaluateJavaScript(script) { _, error in
//                if let error = error { print("⚠️ Spotify Embed Native: Error evaluating JS load URI \(uri): \(error.localizedDescription)") }
//            }
//        }
//        
//        // WKUIDelegate method
//        func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
//            print("ℹ️ Spotify Embed Received JS Alert: \(message)")
//            // In a real app, you might present a native alert here
//            completionHandler() // Must call completion handler
//        }
//    }
//    
//    // --- Generate HTML ---
//    // HTML structure remains the same as before.
//    private func generateHTML() -> String {
//        """
//        <!DOCTYPE html><html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no"><title>Spotify Embed</title><style>html, body { margin: 0; padding: 0; width: 100%; height: 100%; overflow: hidden; background-color: transparent; } #embed-iframe { width: 100%; height: 100%; box-sizing: border-box; display: block; border: none; }</style></head><body><div id="embed-iframe"></div><script src="https://open.spotify.com/embed/iframe-api/v1" async></script><script> console.log('Spotify Embed JS: Initial script running.'); window.onSpotifyIframeApiReady = (IFrameAPI) => { console.log('✅ Spotify Embed JS: API Ready.'); window.IFrameAPI = IFrameAPI; if (window.webkit?.messageHandlers?.spotifyController) { window.webkit.messageHandlers.spotifyController.postMessage("ready"); } else { console.error('❌ Spotify Embed JS: Native message handler not found!'); } }; const scriptTag = document.querySelector('script[src*="iframe-api"]'); if (scriptTag) { scriptTag.onerror = (event) => { console.error('❌ Spotify Embed JS: Failed to load API script:', event); window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'Failed to load Spotify API script' }}); }; } else { console.warn('⚠️ Spotify Embed JS: Could not find API script tag.'); } </script></body></html>
//        """
//    }
//}
//
//// MARK: - API Service (Unchanged)
//
//let placeholderSpotifyToken = "YOUR_SPOTIFY_BEARER_TOKEN_HERE" // Replace with your token
//
//enum SpotifyAPIError: Error, LocalizedError {
//    case invalidURL
//    case networkError(Error)
//    case invalidResponse(Int, String?)
//    case decodingError(Error)
//    case invalidToken
//    case missingData
//    
//    var errorDescription: String? {
//        switch self {
//        case .invalidURL: return "Invalid API URL."
//        case .networkError(let error): return "Network error: \(error.localizedDescription)"
//        case .invalidResponse(let code, _): return "Invalid server response (\(code))."
//        case .decodingError(let error): return "Failed to decode response: \(error.localizedDescription)"
//        case .invalidToken: return "Invalid or expired Spotify token."
//        case .missingData: return "Missing data in API response."
//        }
//    }
//}
//
//struct SpotifyAPIService {
//    static let shared = SpotifyAPIService()
//    private let session: URLSession
//    
//    init() {
//        let configuration = URLSessionConfiguration.default
//        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
//        session = URLSession(configuration: configuration)
//    }
//    
//    private func makeRequest<T: Decodable>(url: URL) async throws -> T {
//        guard !placeholderSpotifyToken.isEmpty, placeholderSpotifyToken != "YOUR_SPOTIFY_BEARER_TOKEN_HERE" else {
//            print("❌ Error: Spotify Bearer Token is missing or placeholder.")
//            throw SpotifyAPIError.invalidToken
//        }
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//        request.setValue("Bearer \(placeholderSpotifyToken)", forHTTPHeaderField: "Authorization")
//        request.setValue("application/json", forHTTPHeaderField: "Accept")
//        request.timeoutInterval = 20
//        
//        print("🚀 Making API Request to: \(url.absoluteString)")
//        
//        do {
//            let (data, response) = try await session.data(for: request)
//            guard let httpResponse = response as? HTTPURLResponse else { throw SpotifyAPIError.invalidResponse(0, "Not HTTP response.") }
//            
//            print("🚦 HTTP Status: \(httpResponse.statusCode)")
//            let responseBody = String(data: data, encoding: .utf8)
//            
//            guard (200...299).contains(httpResponse.statusCode) else {
//                if httpResponse.statusCode == 401 { throw SpotifyAPIError.invalidToken }
//                print("❌ Server Error Body: \(responseBody ?? "N/A")")
//                throw SpotifyAPIError.invalidResponse(httpResponse.statusCode, responseBody)
//            }
//            
//            do {
//                let decoder = JSONDecoder()
//                // Enable detailed decoding error logging if needed
//                // decoder.userInfo[CodingUserInfoKey(rawValue: "debugDescription")!] = { (error: Error) in print(error) }
//                return try decoder.decode(T.self, from: data)
//            } catch {
//                print("❌ Error: Failed to decode JSON for \(T.self). Error: \(error)")
//                // If you enabled userInfo logging:
//                // if let decodingError = error as? DecodingError { print("Decoding Error Details: \(decodingError)") }
//                throw SpotifyAPIError.decodingError(error)
//            }
//        } catch let error where !(error is CancellationError) {
//            print("❌ Error: Network request failed - \(error)")
//            throw error is SpotifyAPIError ? error : SpotifyAPIError.networkError(error)
//        }
//    }
//    
//    func searchAlbums(query: String, limit: Int = 20, offset: Int = 0) async throws -> SpotifySearchResponse {
//        var components = URLComponents(string: "https://api.spotify.com/v1/search")
//        components?.queryItems = [
//            URLQueryItem(name: "q", value: query),
//            URLQueryItem(name: "type", value: "album"),
//            URLQueryItem(name: "include_external", value: "audio"),
//            URLQueryItem(name: "limit", value: "\(limit)"),
//            URLQueryItem(name: "offset", value: "\(offset)")
//        ]
//        guard let url = components?.url else { throw SpotifyAPIError.invalidURL }
//        return try await makeRequest(url: url)
//    }
//    
//    func getAlbumTracks(albumId: String, limit: Int = 50, offset: Int = 0) async throws -> AlbumTracksResponse {
//        var components = URLComponents(string: "https://api.spotify.com/v1/albums/\(albumId)/tracks")
//        components?.queryItems = [
//            URLQueryItem(name: "limit", value: "\(limit)"),
//            URLQueryItem(name: "offset", value: "\(offset)")
//        ]
//        guard let url = components?.url else { throw SpotifyAPIError.invalidURL }
//        return try await makeRequest(url: url)
//    }
//}
//
//// MARK: - SwiftUI Views (Neumorphic Themed)
//
//// MARK: - Main List View
//struct SpotifyAlbumListView: View {
//    @State private var searchQuery: String = ""
//    @State private var displayedAlbums: [AlbumItem] = []
//    @State private var isLoading: Bool = false
//    @State private var searchInfo: Albums? = nil
//    @State private var currentError: SpotifyAPIError? = nil
//    
//    var body: some View {
//        NavigationView {
//            ZStack {
//                // --- Neumorphic Background ---
//                neumorphicBG.ignoresSafeArea()
//                
//                // --- Content Area ---
//                VStack(spacing: 0) { // Remove spacing for seamless list
//                    // --- Search Metadata (Subtle) ---
//                    if let info = searchInfo, !displayedAlbums.isEmpty {
//                        SearchMetadataHeader(totalResults: info.total, limit: info.limit, offset: info.offset)
//                            .padding(.horizontal)
//                            .padding(.top, 5)
//                    }
//                    
//                    // --- Main Content: List or Placeholders ---
//                    Group {
//                        if isLoading && displayedAlbums.isEmpty {
//                            Spacer() // Push loader down
//                            ProgressView()
//                                .progressViewStyle(CircularProgressViewStyle(tint: neumorphicAccentColor))
//                                .scaleEffect(1.5)
//                                .padding(.bottom, 100) // Adjust vertical position
//                            Spacer()
//                        } else if let error = currentError {
//                            NeumorphicErrorPlaceholderView(error: error) {
//                                Task { await performDebouncedSearch() }
//                            }
//                        } else if displayedAlbums.isEmpty && !searchQuery.isEmpty && !isLoading {
//                            NeumorphicEmptyStatePlaceholderView(searchQuery: searchQuery)
//                        } else if displayedAlbums.isEmpty && searchQuery.isEmpty && !isLoading {
//                            // Initial empty state (optional, could be combined with above)
//                            NeumorphicEmptyStatePlaceholderView(searchQuery: "")
//                        } else {
//                            albumScrollView // Use ScrollView for better control
//                        }
//                    }
//                    .frame(maxWidth: .infinity, maxHeight: .infinity)
//                }
//            }
//            .navigationTitle("Spotify Search")
//            .navigationBarTitleDisplayMode(.large) // Standard display
//            .toolbarBackground(neumorphicBG.opacity(0.85), for: .navigationBar) // Slightly translucent BG
//            .toolbarBackground(.visible, for: .navigationBar)
//            
//            // --- Search Bar ---
//            // searchable modifier integrates well with Neumorphism's subtle look
//            .searchable(text: $searchQuery,
//                        placement: .navigationBarDrawer(displayMode: .always),
//                        prompt: Text("Search Albums & Artists").foregroundColor(neumorphicTextColorSecondary))
//            .onSubmit(of: .search) { Task { await performDebouncedSearch(immediate: true) } }
//            .task(id: searchQuery) { await performDebouncedSearch() }
//            .onChange(of: searchQuery) { newValue in
//                if currentError != nil { currentError = nil } // Clear error on new search
//                // Optional: Reset list immediately for faster feedback
//                // if newValue.isEmpty { displayedAlbums = []; searchInfo = nil }
//            }
//            .tint(neumorphicAccentColor) // Tint search bar interactions
//            
//            // --- Loading indicator overlay (Subtle) ---
//            .overlay(alignment: .bottom) { // Place at bottom
//                if isLoading && !displayedAlbums.isEmpty {
//                    HStack {
//                        ProgressView().tint(neumorphicTextColorSecondary)
//                        Text("Loading...")
//                            .font(neumorphicFont(size: 12))
//                            .foregroundColor(neumorphicTextColorSecondary)
//                    }
//                    .padding(8)
//                    .background(.ultraThinMaterial, in: Capsule()) // Subtle blurred background
//                    .padding(.bottom, 10) // Spacing from bottom edge
//                    .transition(.opacity.animation(.easeInOut))
//                }
//            }
//        }
//        // Apply neumorphic colors globally? (Optional)
//        .foregroundColor(neumorphicTextColorPrimary) // Default text color
//        .accentColor(neumorphicAccentColor)       // Default interactive element color
//    }
//    
//    // --- Album ScrollView with Cards ---
//    private var albumScrollView: some View {
//        ScrollView {
//            LazyVStack(spacing: 20) { // Spacing between cards
//                ForEach(displayedAlbums) { album in
//                    NavigationLink(destination: AlbumDetailView(album: album)) {
//                        NeumorphicAlbumCard(album: album)
//                    }
//                    .buttonStyle(.plain) // Ensure link doesn't adopt default button styling
//                }
//            }
//            .padding(.horizontal) // Padding for the whole scroll content
//            .padding(.top, 10)
//            .padding(.bottom, 30) // Space at the bottom
//        }
//    }
//    
//    // --- Debounced Search Logic (Unchanged) ---
//    private func performDebouncedSearch(immediate: Bool = false) async {
//        let trimmedQuery = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
//        guard !trimmedQuery.isEmpty else {
//            await MainActor.run { displayedAlbums = []; searchInfo = nil; isLoading = false; currentError = nil }
//            return
//        }
//        
//        if !immediate {
//            do { try await Task.sleep(for: .milliseconds(500)); try Task.checkCancellation() }
//            catch { print("Search task cancelled (debounce)."); return }
//        }
//        
//        // Check if the query is still the same after the delay
//        let currentQuery = await MainActor.run { self.searchQuery.trimmingCharacters(in: .whitespacesAndNewlines) }
//        guard currentQuery == trimmedQuery else {
//            print("Search query changed during debounce. Aborting.")
//            return
//        }
//        
//        await MainActor.run { isLoading = true }
//        
//        do {
//            let response = try await SpotifyAPIService.shared.searchAlbums(query: trimmedQuery, offset: 0)
//            try Task.checkCancellation() // Check cancellation again after network call
//            await MainActor.run {
//                // Make sure the query hasn't changed *again* while waiting for the network
//                if self.searchQuery.trimmingCharacters(in: .whitespacesAndNewlines) == trimmedQuery {
//                    displayedAlbums = response.albums.items
//                    searchInfo = response.albums
//                    currentError = nil
//                } else {
//                    print("Search query changed after network response received. Ignoring results.")
//                }
//                isLoading = false
//            }
//        } catch is CancellationError {
//            print("Search task cancelled.")
//            await MainActor.run { isLoading = false }
//        } catch let apiError as SpotifyAPIError {
//            print("❌ API Error: \(apiError.localizedDescription)")
//            await MainActor.run { displayedAlbums = []; searchInfo = nil; currentError = apiError; isLoading = false }
//        } catch {
//            print("❌ Unexpected Error: \(error.localizedDescription)")
//            await MainActor.run { displayedAlbums = []; searchInfo = nil; currentError = .networkError(error); isLoading = false }
//        }
//    }
//}
//
//// MARK: - Neumorphic Album Card
//struct NeumorphicAlbumCard: View {
//    let album: AlbumItem
//    private let cardCornerRadius: CGFloat = 20
//    
//    var body: some View {
//        HStack(spacing: 15) {
//            // --- Album Art (Slightly inset) ---
//            AlbumImageView(url: album.listImageURL)
//                .frame(width: 80, height: 80)
//                .neumorphicSurface(cornerRadius: 12) // Apply surface styling to image container
//                .neumorphicShadowPressed(radius: 3, intensity: 0.08) // Subtle inset effect
//            
//            // --- Text Details ---
//            VStack(alignment: .leading, spacing: 4) {
//                Text(album.name)
//                    .font(neumorphicFont(size: 16, weight: .semibold))
//                    .foregroundColor(neumorphicTextColorPrimary)
//                    .lineLimit(2)
//                
//                Text(album.formattedArtists)
//                    .font(neumorphicFont(size: 14))
//                    .foregroundColor(neumorphicTextColorSecondary)
//                    .lineLimit(1)
//                
//                Spacer() // Push bottom info down
//                
//                HStack(spacing: 8) {
//                    // Subtle type tag
//                    Text(album.album_type.capitalized)
//                        .font(neumorphicFont(size: 10, weight: .medium))
//                        .foregroundColor(neumorphicTextColorSecondary)
//                        .padding(.horizontal, 8)
//                        .padding(.vertical, 3)
//                        .background(neumorphicBG) // Same as background
//                        .clipShape(Capsule())
//                        .overlay(Capsule().stroke(neumorphicBG.opacity(0.1), lineWidth: 0.5)) // Very subtle edge
//                    
//                    Text("• \(album.formattedReleaseDate())")
//                        .font(neumorphicFont(size: 11))
//                        .foregroundColor(neumorphicTextColorSecondary)
//                }
//                
//                Text("\(album.total_tracks) Tracks")
//                    .font(neumorphicFont(size: 11))
//                    .foregroundColor(neumorphicTextColorSecondary)
//                    .padding(.top, 1)
//                
//            } // End Text VStack
//            .frame(maxWidth: .infinity, alignment: .leading)
//            
//        } // End HStack
//        .padding(15) // Padding inside the card
//        .neumorphicSurface(cornerRadius: cardCornerRadius) // Base surface
//        .neumorphicShadow() // Extruded effect
//    }
//}
//
//// MARK: - Neumorphic Placeholders
//struct NeumorphicErrorPlaceholderView: View {
//    let error: SpotifyAPIError
//    let retryAction: (() -> Void)?
//    private let placeholderCornerRadius: CGFloat = 25
//    
//    var body: some View {
//        VStack(spacing: 25) {
//            Image(systemName: iconName)
//                .font(.system(size: 50, weight: .light)) // Lighter weight icon
//                .foregroundColor(neumorphicAccentColor.opacity(0.8))
//                .padding(20)
//                .background(neumorphicBG)
//                .clipShape(Circle())
//                .neumorphicShadow() // Icon itself has shadow
//            
//            VStack(spacing: 8) {
//                Text("Error")
//                    .font(neumorphicFont(size: 20, weight: .semibold))
//                    .foregroundColor(neumorphicTextColorPrimary)
//                
//                Text(errorMessage)
//                    .font(neumorphicFont(size: 14))
//                    .foregroundColor(neumorphicTextColorSecondary)
//                    .multilineTextAlignment(.center)
//                    .padding(.horizontal, 20)
//            }
//            
//            switch error {
//            case .invalidToken:
//                Text("Please check the API token in the code.")
//                    .font(neumorphicFont(size: 13))
//                    .foregroundColor(.red.opacity(0.8))
//                    .multilineTextAlignment(.center)
//                    .padding(.horizontal)
//            default:
//                Text("CHANGE ME LATER DADDY")
//            }
//            
//            //            // Only show retry button if action is provided and not a token error
//            //            if retryAction != nil && error != .invalidToken {
//            //                NeumorphicButton(text: "Retry", systemImage: "arrow.clockwise", action: retryAction ?? {})
//            //                    .padding(.horizontal, 40) // Make button wider
//            //            } else if error == .invalidToken {
//            //                 Text("Please check the API token in the code.")
//            //                     .font(neumorphicFont(size: 13))
//            //                     .foregroundColor(.red.opacity(0.8))
//            //                     .multilineTextAlignment(.center)
//            //                     .padding(.horizontal)
//            //            }
//        }
//        .padding(.vertical, 40)
//        .padding(.horizontal, 20)
//        .frame(maxWidth: .infinity)
//        .neumorphicSurface(cornerRadius: placeholderCornerRadius)
//        .neumorphicShadow() // Apply shadow to the whole container
//        .padding(30) // Padding around the error view
//    }
//    
//    // Icon and Message logic remains the same
//    private var iconName: String {
//        switch error {
//        case .invalidToken: return "key.slash"
//        case .networkError: return "wifi.slash"
//        case .invalidResponse, .decodingError, .missingData: return "exclamationmark.triangle"
//        case .invalidURL: return "link.badge.plus" // Different icon?
//        }
//    }
//    private var errorMessage: String {
//        error.localizedDescription // Use the default localized description
//    }
//}
//
//struct NeumorphicEmptyStatePlaceholderView: View {
//    let searchQuery: String
//    private let placeholderCornerRadius: CGFloat = 25
//    
//    var body: some View {
//        VStack(spacing: 25) {
//            Image(systemName: iconName) // Simple system icons
//                .font(.system(size: 60, weight: .light))
//                .foregroundColor(neumorphicTextColorSecondary.opacity(0.6))
//                .padding(20)
//                .background(neumorphicBG)
//                .clipShape(Circle())
//                .neumorphicShadow()
//            
//            VStack(spacing: 8) {
//                Text(title)
//                    .font(neumorphicFont(size: 20, weight: .semibold))
//                    .foregroundColor(neumorphicTextColorPrimary)
//                
//                Text(message)
//                    .font(neumorphicFont(size: 14))
//                    .foregroundColor(neumorphicTextColorSecondary)
//                    .multilineTextAlignment(.center)
//                    .padding(.horizontal, 30)
//            }
//        }
//        .padding(.vertical, 50)
//        .padding(.horizontal, 20)
//        .frame(maxWidth: .infinity, maxHeight: .infinity) // Allow it to take space
//        // Only apply surface/shadow if needed, might be too much visually for empty state
//        // .neumorphicSurface(cornerRadius: placeholderCornerRadius)
//        // .neumorphicShadow()
//        .padding(30) // Padding around
//    }
//    
//    private var isInitialState: Bool { searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
//    private var iconName: String { isInitialState ? "music.mic" : "magnifyingglass" } // More relevant icons
//    private var title: String { isInitialState ? "Ready to Search" : "No Results" }
//    private var message: String {
//        if isInitialState {
//            return "Enter an album or artist name in the search bar above."
//        } else {
//            return "Couldn't find any matches for \"\(searchQuery)\".\nTry refining your search terms."
//        }
//    }
//}
//
//// MARK: - Album Detail View (Neumorphic Themed)
//struct AlbumDetailView: View {
//    let album: AlbumItem
//    @State private var tracks: [Track] = []
//    @State private var isLoadingTracks: Bool = false
//    @State private var trackFetchError: SpotifyAPIError? = nil
//    @State private var selectedTrackUri: String? = nil
//    @StateObject private var playbackState = SpotifyPlaybackState()
//    
//    var body: some View {
//        // Use ScrollView for better control over neumorphic elements
//        ScrollView {
//            VStack(spacing: 25) { // Spacing between sections
//                // --- Header Section ---
//                AlbumHeaderView(album: album)
//                    .padding(.top, 10)
//                
//                // --- Player Section (if track selected) ---
//                if let uriToPlay = selectedTrackUri {
//                    NeumorphicPlayerView(playbackState: playbackState, spotifyUri: uriToPlay)
//                        .transition(.opacity.combined(with: .scale(scale: 0.95, anchor: .top)).animation(.easeInOut(duration: 0.4)))
//                        .padding(.horizontal) // Add padding
//                }
//                
//                // --- Tracks Section ---
//                TracksSectionView(
//                    tracks: tracks,
//                    isLoading: isLoadingTracks,
//                    error: trackFetchError,
//                    selectedTrackUri: $selectedTrackUri,
//                    retryAction: { Task { await fetchTracks() } }
//                )
//                .padding(.horizontal) // Add padding
//                
//                // --- External Link Section ---
//                if let spotifyURL = URL(string: album.external_urls.spotify ?? "") {
//                    NeumorphicExternalLinkButton(url: spotifyURL)
//                        .padding(.horizontal) // Add padding
//                        .padding(.bottom, 30) // Space at the very bottom
//                }
//            }
//        }
//        .background(neumorphicBG.ignoresSafeArea()) // Background for the whole detail view
//        .navigationTitle(album.name)
//        .navigationBarTitleDisplayMode(.inline) // Keep inline for clean look
//        .toolbarBackground(neumorphicBG.opacity(0.85), for: .navigationBar) // Match list view
//        .toolbarBackground(.visible, for: .navigationBar)
//        .task { await fetchTracks() }
//        .refreshable { await fetchTracks(forceReload: true) }
//        .animation(.easeInOut, value: selectedTrackUri)
//    }
//    
//    // --- Fetch Tracks Logic (Unchanged) ---
//    private func fetchTracks(forceReload: Bool = false) async {
//        // This logic remains the same as previous versions
//        guard forceReload || tracks.isEmpty || trackFetchError != nil else { return }
//        await MainActor.run { isLoadingTracks = true; trackFetchError = nil }
//        do {
//            let response = try await SpotifyAPIService.shared.getAlbumTracks(albumId: album.id)
//            try Task.checkCancellation()
//            await MainActor.run { self.tracks = response.items; self.isLoadingTracks = false }
//        } catch is CancellationError { await MainActor.run { isLoadingTracks = false } }
//        catch let apiError as SpotifyAPIError { await MainActor.run { self.trackFetchError = apiError; self.isLoadingTracks = false; self.tracks = [] } }
//        catch { await MainActor.run { self.trackFetchError = .networkError(error); self.isLoadingTracks = false; self.tracks = [] } }
//    }
//}
//
//// MARK: - DetailView Sub-Components (Neumorphic Themed)
//
//struct AlbumHeaderView: View {
//    let album: AlbumItem
//    
//    var body: some View {
//        VStack(spacing: 15) {
//            AlbumImageView(url: album.bestImageURL)
//                .aspectRatio(1.0, contentMode: .fit) // Keep square
//                .neumorphicSurface(cornerRadius: 20) // Surface for the image
//                .neumorphicShadow() // Main shadow for image
//                .padding(.horizontal, 60) // Adjust padding for desired image size
//            
//            VStack(spacing: 5) {
//                Text(album.name)
//                    .font(neumorphicFont(size: 22, weight: .semibold))
//                    .foregroundColor(neumorphicTextColorPrimary)
//                    .multilineTextAlignment(.center)
//                
//                Text("by \(album.formattedArtists)")
//                    .font(neumorphicFont(size: 16))
//                    .foregroundColor(neumorphicTextColorSecondary)
//                    .multilineTextAlignment(.center)
//                
//                Text("\(album.album_type.capitalized) • \(album.formattedReleaseDate())")
//                    .font(neumorphicFont(size: 12, weight: .medium))
//                    .foregroundColor(neumorphicTextColorSecondary)
//            }
//            .padding(.horizontal)
//        }
//    }
//}
//
//struct NeumorphicPlayerView: View {
//    @ObservedObject var playbackState: SpotifyPlaybackState
//    let spotifyUri: String
//    private let playerCornerRadius: CGFloat = 15
//    
//    var body: some View {
//        VStack(spacing: 10) {
//            // Embed WebView within a neumorphic container
//            SpotifyEmbedWebView(playbackState: playbackState, spotifyUri: spotifyUri)
//                .frame(height: 80) // Standard embed height
//            // Create slight inset look for the webview itself
//                .neumorphicSurface(cornerRadius: playerCornerRadius - 5) // Slightly smaller radius inside
//                .neumorphicShadowPressed(radius: 3, intensity: 0.06)
//                .padding(5) // Padding between webview inset and outer container
//            
//            // --- Playback Status ---
//            HStack {
//                let statusText = playbackState.isPlaying ? "Playing" : "Paused"
//                let statusColor = playbackState.isPlaying ? neumorphicAccentColor.opacity(0.8) : neumorphicTextColorSecondary
//                
//                // Simple status indicators
//                Circle()
//                    .fill(statusColor)
//                    .frame(width: 8, height: 8)
//                    .animation(.easeInOut, value: playbackState.isPlaying)
//                
//                Text(statusText)
//                    .font(neumorphicFont(size: 11, weight: .medium))
//                    .foregroundColor(statusColor)
//                    .animation(.easeInOut, value: playbackState.isPlaying)
//                
//                Spacer()
//                
//                // Time Display
//                if playbackState.duration > 0.1 {
//                    Text("\(formatTime(playbackState.currentPosition)) / \(formatTime(playbackState.duration))")
//                } else {
//                    Text("--:-- / --:--") // Placeholder
//                }
////                    .font(neumorphicFont(size: 11, weight: .medium))
////                    .foregroundColor(neumorphicTextColorSecondary)
//                
//            }
//            .padding(.horizontal, 10) // Padding inside the outer container
//            
//        } // End VStack
//        .padding(.vertical, 10) // Padding inside the outer container
//        .neumorphicSurface(cornerRadius: playerCornerRadius) // Outer container surface
//        .neumorphicShadow() // Outer container shadow
//    }
//    
//    private func formatTime(_ time: Double) -> String {
//        let totalSeconds = max(0, Int(time))
//        let minutes = totalSeconds / 60
//        let seconds = totalSeconds % 60
//        return String(format: "%d:%02d", minutes, seconds)
//    }
//}
//
//struct TracksSectionView: View {
//    let tracks: [Track]
//    let isLoading: Bool
//    let error: SpotifyAPIError?
//    @Binding var selectedTrackUri: String?
//    let retryAction: () -> Void
//    private let sectionCornerRadius: CGFloat = 15
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 0) {
//            // --- Section Header ---
//            Text("Tracks")
//                .font(neumorphicFont(size: 18, weight: .semibold))
//                .foregroundColor(neumorphicTextColorPrimary)
//                .padding(.bottom, 10)
//                .padding(.leading, 15) // Align with rows
//            
//            // --- Tracks Container ---
//            VStack(spacing: 0) { // Use spacing 0 for contiguous rows
//                if isLoading {
//                    HStack {
//                        Spacer()
//                        ProgressView().tint(neumorphicAccentColor)
//                        Text("Loading Tracks...")
//                            .font(neumorphicFont(size: 14)).foregroundColor(neumorphicTextColorSecondary)
//                            .padding(.leading, 5)
//                        Spacer()
//                    }
//                    .padding(.vertical, 30) // Give loading state some space
//                } else if let error = error {
//                    // Use Neumorphic Error View
//                    NeumorphicErrorPlaceholderView(error: error, retryAction: retryAction)
//                        .padding(.vertical, 20)
//                } else if tracks.isEmpty {
//                    Text("No tracks available for this album.")
//                        .font(neumorphicFont(size: 14)).foregroundColor(neumorphicTextColorSecondary)
//                        .frame(maxWidth: .infinity, alignment: .center)
//                        .padding(.vertical, 30)
//                } else {
//                    ForEach(tracks) { track in
//                        TrackRowView(
//                            track: track,
//                            isSelected: track.uri == selectedTrackUri
//                        )
//                        .background(track.uri == selectedTrackUri ? neumorphicAccentColor.opacity(0.08) : Color.clear) // Subtle selection highlight
//                        .contentShape(Rectangle())
//                        .onTapGesture {
//                            selectedTrackUri = track.uri
//                        }
//                        Divider().padding(.leading, 50) // Indent divider past track number
//                    }
//                }
//            }
//            .background(neumorphicBG) // Background for the track list area
//            .clipShape(RoundedRectangle(cornerRadius: sectionCornerRadius, style: .continuous)) // Clip the list area
//            .neumorphicShadowPressed() // Make the list area look slightly indented
//            
//        } // End Outer VStack
//        // No need for neumorphicSurface/shadow on the outer VStack
//        // if the inner list has the pressed effect.
//    }
//}
//
//struct TrackRowView: View {
//    let track: Track
//    let isSelected: Bool
//    
//    var body: some View {
//        HStack(spacing: 15) {
//            // --- Track Number ---
//            Text("\(track.track_number)")
//                .font(neumorphicFont(size: 13, weight: .medium))
//                .foregroundColor(neumorphicTextColorSecondary)
//                .frame(width: 25, alignment: .center)
//            
//            // --- Track Info ---
//            VStack(alignment: .leading, spacing: 2) {
//                Text(track.name)
//                    .font(neumorphicFont(size: 15, weight: isSelected ? .medium : .regular))
//                    .foregroundColor(neumorphicTextColorPrimary)
//                    .lineLimit(1)
//                
//                Text(track.formattedArtists)
//                    .font(neumorphicFont(size: 12))
//                    .foregroundColor(neumorphicTextColorSecondary)
//                    .lineLimit(1)
//            }
//            
//            Spacer()
//            
//            // --- Duration ---
//            Text(track.formattedDuration)
//                .font(neumorphicFont(size: 13, weight: .medium))
//                .foregroundColor(neumorphicTextColorSecondary)
//            
//            // --- Play Indicator (Subtle) ---
//            // Removed visual indicator to keep neumorphism cleaner, selection shown by background
//            if isSelected {
//                Image(systemName: "speaker.wave.2.fill") // Indicate playback state
//                    .font(.caption)
//                    .foregroundColor(neumorphicAccentColor)
//                    .frame(width: 20, height: 20)
//            } else {
//                Spacer().frame(width: 20, height: 20) // Placeholder to maintain layout
//            }
//            
//        }
//        .padding(.horizontal, 15)
//        .padding(.vertical, 12) // Consistent padding
//    }
//}
//
//// MARK: - Other Supporting Views (Neumorphic Themed)
//
//struct AlbumImageView: View {
//    let url: URL?
//    
//    var body: some View {
//        AsyncImage(url: url) { phase in
//            switch phase {
//            case .empty:
//                // Neumorphic Placeholder
//                ZStack {
//                    neumorphicBG // Background color
//                    ProgressView().tint(neumorphicAccentColor.opacity(0.7))
//                }
//                .transition(.opacity.animation(.easeInOut))
//            case .success(let image):
//                image.resizable().scaledToFit()
//                    .transition(.opacity.animation(.easeInOut))
//            case .failure:
//                // Neumorphic Failure State
//                ZStack {
//                    neumorphicBG
//                    Image(systemName: "photo.fill")
//                        .resizable().scaledToFit()
//                        .foregroundColor(neumorphicTextColorSecondary.opacity(0.3))
//                        .padding(10)
//                }
//                .transition(.opacity.animation(.easeInOut))
//            @unknown default:
//                EmptyView()
//            }
//        }
//        // Ensure the AsyncImage container clips (important for corner radius)
//        .clipped()
//    }
//}
//
//struct SearchMetadataHeader: View {
//    let totalResults: Int
//    let limit: Int
//    let offset: Int
//    
//    var body: some View {
//        HStack {
//            Text("Results: \(totalResults)")
//            Spacer()
//            if totalResults > limit {
//                Text("Showing: \(offset + 1)-\(min(offset + limit, totalResults))")
//            }
//        }
//        .font(neumorphicFont(size: 11, weight: .medium))
//        .foregroundColor(neumorphicTextColorSecondary)
//        .padding(.vertical, 4) // Subtle vertical padding
//    }
//}
//
//// MARK: --- Reusable Neumorphic Button ---
//struct NeumorphicButton: View {
//    let text: String
//    var systemImage: String? = nil
//    let action: () -> Void
//    
//    @GestureState private var isPressed: Bool = false // Track press state
//    
//    var body: some View {
//        Button(action: action) {
//            HStack(spacing: 8) {
//                if let systemImage = systemImage {
//                    Image(systemName: systemImage)
//                        .font(.body.weight(.medium)) // Match text weight
//                }
//                Text(text)
//                    .font(neumorphicFont(size: 15, weight: .medium))
//            }
//            .foregroundColor(isPressed ? neumorphicAccentColor : neumorphicTextColorPrimary) // Change color when pressed
//            .padding(.horizontal, 25)
//            .padding(.vertical, 12)
//            .frame(maxWidth: .infinity) // Allow button to expand
//            .background(neumorphicBG)
//            .clipShape(Capsule())
//            // Apply different shadow based on press state
//            .modifier(NeumorphicButtonShadow(isPressed: isPressed))
//            .animation(.easeInOut(duration: 0.15), value: isPressed) // Animate the shadow change
//            
//        }
//        .buttonStyle(.plain) // Required for custom background/foreground/shadows
//        // Update press state using DragGesture for immediate feedback
//        .gesture(
//            DragGesture(minimumDistance: 0)
//                .updating($isPressed) { _, state, _ in
//                    state = true
//                }
//        )
//    }
//}
//
//// Helper modifier for button shadow animation
//struct NeumorphicButtonShadow: ViewModifier {
//    let isPressed: Bool
//    
//    func body(content: Content) -> some View {
//        if isPressed {
//            content.neumorphicShadowPressed(radius: 5, intensity: 0.08) // Pressed style
//        } else {
//            content.neumorphicShadow(radius: 8, xOffset: 4, yOffset: 4) // Default extruded style
//        }
//    }
//}
//
//// MARK: --- Neumorphic External Link Button ---
//struct NeumorphicExternalLinkButton: View {
//    let url: URL
//    @Environment(\.openURL) var openURL
//    
//    var body: some View {
//        NeumorphicButton(
//            text: "Open in Spotify",
//            systemImage: "arrow.up.forward.app.fill"
//        ) {
//            print("Attempting to open external URL: \(url)")
//            openURL(url) { accepted in
//                if !accepted {
//                    print("⚠️ Warning: URL scheme \(url.scheme ?? "") could not be opened.")
//                    // Consider showing a user alert here
//                }
//            }
//        }
//        // Optional: Apply accent color specifically if needed
//        // .foregroundColor(neumorphicAccentColor)
//    }
//}
//
//// MARK: - Preview Providers (Updated for Neumorphic Views)
//
//struct SpotifyAlbumListView_Previews: PreviewProvider {
//    static var previews: some View {
//        SpotifyAlbumListView()
//        // Preview in light mode for classic neumorphism
//            .preferredColorScheme(.light)
//    }
//}
//
//struct NeumorphicAlbumCard_Previews: PreviewProvider {
//    // Mock data
//    static let mockArtist = Artist(id: "artist1", external_urls: nil, href: "", name: "Miles Davis Mock", type: "artist", uri: "")
//    static let mockImage = SpotifyImage(height: 300, url: "https://i.scdn.co/image/ab67616d00001e027ab89c25093ea3787b1995b4", width: 300)
//    static let mockAlbumItem = AlbumItem(id: "album1", album_type: "album", total_tracks: 5, available_markets: ["US"], external_urls: ExternalUrls(spotify: ""), href: "", images: [mockImage], name: "Kind of Blue [PREVIEW]", release_date: "1959-08-17", release_date_precision: "day", type: "album", uri: "spotify:album:1weenld61qoidwYuZ1GESA", artists: [mockArtist])
//    
//    static var previews: some View {
//        NeumorphicAlbumCard(album: mockAlbumItem)
//            .padding()
//            .background(neumorphicBG)
//            .previewLayout(.fixed(width: 400, height: 160)) // Adjust height if needed
//            .preferredColorScheme(.light)
//    }
//}
//
//struct AlbumDetailView_Previews: PreviewProvider {
//    static let mockArtist = Artist(id: "artist1", external_urls: nil, href: "", name: "Miles Davis Mock", type: "artist", uri: "")
//    static let mockImage = SpotifyImage(height: 640, url: "https://i.scdn.co/image/ab67616d0000b2737ab89c25093ea3787b1995b4", width: 640)
//    static let mockAlbum = AlbumItem(id: "1weenld61qoidwYuZ1GESA", album_type: "album", total_tracks: 5, available_markets: ["US", "GB"], external_urls: ExternalUrls(spotify: "https://open.spotify.com/album/1weenld61qoidwYuZ1GESA"), href: "", images: [mockImage], name: "Kind Of Blue (Preview)", release_date: "1959-08-17", release_date_precision: "day", type: "album", uri: "spotify:album:1weenld61qoidwYuZ1GESA", artists: [mockArtist])
//    
//    static var previews: some View {
//        NavigationView { // Wrap for navigation context
//            AlbumDetailView(album: mockAlbum)
//        }
//        .preferredColorScheme(.light)
//    }
//}
//
//struct NeumorphicButton_Previews: PreviewProvider {
//    static var previews: some View {
//        VStack(spacing: 30) {
//            NeumorphicButton(text: "Standard Button") {}
//            NeumorphicButton(text: "Retry", systemImage: "arrow.clockwise") {}
//            NeumorphicExternalLinkButton(url: URL(string: "https://www.spotify.com")!)
//        }
//        .padding(40)
//        .background(neumorphicBG.ignoresSafeArea())
//        .preferredColorScheme(.light)
//        
//    }
//}
//
//// MARK: - App Entry Point
//
//@main
//struct SpotifyNeumorphicApp: App {
//    init() {
//        // --- Token Check ---
//        if placeholderSpotifyToken == "YOUR_SPOTIFY_BEARER_TOKEN_HERE" || placeholderSpotifyToken.isEmpty {
//            print("🚨🎬 FATAL STARTUP WARNING: Spotify Bearer Token is not set! API calls WILL FAIL.")
//            print("👉 FIX: Replace the placeholderSpotifyToken value in the code with a valid token.")
//        }
//        
//        // --- Global Neumorphic Appearance (Optional) ---
//        // Often less necessary with direct SwiftUI styling, but could set Nav bar defaults:
//        /*
//         let appearance = UINavigationBarAppearance()
//         appearance.configureWithDefaultBackground() // Use default background style
//         appearance.backgroundColor = UIColor(neumorphicBG.opacity(0.85)) // Subtle background
//         appearance.titleTextAttributes = [.foregroundColor: UIColor(neumorphicTextColorPrimary)]
//         appearance.largeTitleTextAttributes = [.foregroundColor: UIColor(neumorphicTextColorPrimary)]
//         // Remove default shadow for neumorphic look
//         appearance.shadowColor = .clear
//         UINavigationBar.appearance().standardAppearance = appearance
//         UINavigationBar.appearance().scrollEdgeAppearance = appearance
//         UINavigationBar.appearance().compactAppearance = appearance
//         UINavigationBar.appearance().tintColor = UIColor(neumorphicAccentColor) // Back button etc.
//         */
//    }
//    
//    var body: some Scene {
//        WindowGroup {
//            SpotifyAlbumListView()
//            // Enforce light mode for classic neumorphism, or allow system theme
//                .preferredColorScheme(.light)
//        }
//    }
//}
