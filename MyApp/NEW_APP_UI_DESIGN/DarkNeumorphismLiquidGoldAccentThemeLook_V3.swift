////
////  DarkNeumorphismLiquidGoldAccentThemeLook_V3.swift
////  MyApp
////
////  Created by Cong Le on 4/18/25.
////
//
//import SwiftUI
//@preconcurrency import WebKit // For Spotify Embed WebView
//import Foundation
//
//// MARK: - Theme: Deep Dark Neumorphism & Liquid Gold Accent
//
//struct NeumorphicTheme {
//    static let darkBackground = Color(red: 0.12, green: 0.13, blue: 0.15) // Very dark grey/blue
//    static let elementBackground = Color(red: 0.12, green: 0.13, blue: 0.15) // Same as background for pure neumorphism
//    
//    static let lightShadow = Color.white.opacity(0.1)  // Subtle light shadow
//    static let darkShadow = Color.black.opacity(0.5)   // Deeper dark shadow
//
//    // Liquid Gold Gradient & Accent
//    static let goldGradient = LinearGradient(
//        gradient: Gradient(colors: [
//            Color(red: 0.9, green: 0.7, blue: 0.3), // Lighter Gold
//            Color(red: 0.8, green: 0.6, blue: 0.2), // Mid Gold
//            Color(red: 0.7, green: 0.5, blue: 0.1)  // Deeper Gold/Bronze
//        ]),
//        startPoint: .topLeading,
//        endPoint: .bottomTrailing
//    )
//    static let goldAccent = Color(red: 0.85, green: 0.65, blue: 0.25) // A representative solid gold
//
//    static let primaryText = Color(white: 0.9)   // Off-white for primary text
//    static let secondaryText = Color(white: 0.6) // Grey for secondary text
//    static let errorColor = Color(red: 0.8, green: 0.2, blue: 0.2) // Muted red for errors
//
//    // Standard neumorphic styling parameters
//    static let cornerRadius: CGFloat = 18
//    static let shadowRadius: CGFloat = 6
//    static let shadowOffset: CGFloat = 4 // Symmetric offset
//}
//
//// Font helper (Using system fonts for simplicity)
//func neumorphicFont(size: CGFloat, weight: Font.Weight = .regular, design: Font.Design = .default) -> Font {
//    return Font.system(size: size, weight: weight, design: design)
//}
//
//// MARK: - Neumorphic View Modifier & Styles
//
//// Applies the standard outset neumorphic shadow
//extension View {
//    func neumorphicShadow(
//        bgColor: Color = NeumorphicTheme.elementBackground,
//        cornerRadius: CGFloat = NeumorphicTheme.cornerRadius,
//        shadowRadius: CGFloat = NeumorphicTheme.shadowRadius,
//        shadowOffset: CGFloat = NeumorphicTheme.shadowOffset
//    ) -> some View {
//        self
//            .background(bgColor)
//            .cornerRadius(cornerRadius)
//            .shadow(color: NeumorphicTheme.lightShadow, radius: shadowRadius, x: -shadowOffset, y: -shadowOffset)
//            .shadow(color: NeumorphicTheme.darkShadow, radius: shadowRadius, x: shadowOffset, y: shadowOffset)
//            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
//    }
//}
//
//// Custom ButtonStyle for Neumorphic Buttons
//struct NeumorphicButtonStyle: ButtonStyle {
//    var isGold: Bool = false // Determines if gold accent should be used
//
//    func makeBody(configuration: Configuration) -> some View {
//        configuration.label
//            .font(neumorphicFont(size: 15, weight: .medium))
//            .padding(.vertical, 12)
//            .padding(.horizontal, 20)
//            .frame(maxWidth: .infinity)
//            .foregroundStyle(isGold ? NeumorphicTheme.goldGradient : LinearGradient(colors: [NeumorphicTheme.primaryText], startPoint: .top, endPoint: .bottom))
//            .background(
//                // Apply inset effect when pressed
//                RoundedRectangle(cornerRadius: NeumorphicTheme.cornerRadius, style: .continuous)
//                    .fill(NeumorphicTheme.elementBackground)
//                    .overlay(
//                        // Dark inner shadow (top/left)
//                        RoundedRectangle(cornerRadius: NeumorphicTheme.cornerRadius, style: .continuous)
//                            .stroke(NeumorphicTheme.darkShadow, lineWidth: configuration.isPressed ? 2 : 0) // Scale intensity based on press
//                            .blur(radius: configuration.isPressed ? 2 : 0)
//                            .offset(x: configuration.isPressed ? 1 : 0, y: configuration.isPressed ? 1 : 0)
//                            .mask(RoundedRectangle(cornerRadius: NeumorphicTheme.cornerRadius, style: .continuous))
//                             .opacity(configuration.isPressed ? 1 : 0)
//                    )
//                    .overlay(
//                        // Light inner shadow (bottom/right)
//                        RoundedRectangle(cornerRadius: NeumorphicTheme.cornerRadius, style: .continuous)
//                            .stroke(NeumorphicTheme.lightShadow, lineWidth: configuration.isPressed ? 2 : 0)
//                            .blur(radius: configuration.isPressed ? 2 : 0)
//                            .offset(x: configuration.isPressed ? -1 : 0, y: configuration.isPressed ? -1 : 0)
//                            .mask(RoundedRectangle(cornerRadius: NeumorphicTheme.cornerRadius, style: .continuous))
//                            .opacity(configuration.isPressed ? 1 : 0)
//                    )
//                    // Apply standard outer shadow when not pressed
//                    .shadow(color: NeumorphicTheme.lightShadow, radius: configuration.isPressed ? 0 : NeumorphicTheme.shadowRadius, x: configuration.isPressed ? 0 : -NeumorphicTheme.shadowOffset, y: configuration.isPressed ? 0 : -NeumorphicTheme.shadowOffset)
//                    .shadow(color: NeumorphicTheme.darkShadow, radius: configuration.isPressed ? 0 : NeumorphicTheme.shadowRadius, x: configuration.isPressed ? 0 : NeumorphicTheme.shadowOffset, y: configuration.isPressed ? 0 : NeumorphicTheme.shadowOffset)
//            )
//            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: configuration.isPressed)
//    }
//}
//
//// MARK: - Data Models (Unchanged - Core Spotify Structures)
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
//    // Computed properties for image URLs and formatted text
//    var bestImageURL: URL? { images.first(where: { $0.width == 640 })?.urlObject ?? images.first?.urlObject }
//    var listImageURL: URL? { images.first(where: { $0.width == 300 })?.urlObject ?? images.first(where: { $0.width == 64 })?.urlObject ?? images.first?.urlObject }
//    var formattedArtists: String { artists.map { $0.name }.joined(separator: ", ") }
//
//    func formattedReleaseDate() -> String {
//        let dateFormatter = DateFormatter()
//        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // Consistent parsing
//
//        switch release_date_precision {
//        case "year":
//            dateFormatter.dateFormat = "yyyy"
//            if let date = dateFormatter.date(from: release_date) { return dateFormatter.string(from: date) }
//        case "month":
//            dateFormatter.dateFormat = "yyyy-MM"
//            if let date = dateFormatter.date(from: release_date) { dateFormatter.dateFormat = "MMM yyyy"; return dateFormatter.string(from: date) }
//        case "day":
//            dateFormatter.dateFormat = "yyyy-MM-dd"
//            if let date = dateFormatter.date(from: release_date) { dateFormatter.dateStyle = .medium; dateFormatter.timeStyle = .none; return dateFormatter.string(from: date) }
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
//    let preview_url: String? // Note: Embed player often requires full track URI, not preview
//    let track_number: Int
//    let type: String // "track"
//    let uri: String
//
//    var formattedDuration: String {
//        let totalSeconds = duration_ms / 1000
//        return String(format: "%d:%02d", totalSeconds / 60, totalSeconds % 60)
//    }
//    var formattedArtists: String { artists.map { $0.name }.joined(separator: ", ") }
//}
//
//// MARK: - Spotify Embed WebView & State Management
//
//final class SpotifyPlaybackState: ObservableObject {
//    @Published var isPlaying: Bool = false
//    @Published var currentPosition: Double = 0 // seconds
//    @Published var duration: Double = 0 // seconds
//    @Published var currentUri: String = ""
//    @Published var isReady: Bool = false // Tracks if the embed API itself is ready
//    @Published var error: String? = nil // Stores embed-specific errors
//}
//
//struct SpotifyEmbedWebView: UIViewRepresentable {
//    @ObservedObject var playbackState: SpotifyPlaybackState
//    let spotifyUri: String? // URI to load initially or update to
//
//    func makeCoordinator() -> Coordinator { Coordinator(self) }
//
//    func makeUIView(context: Context) -> WKWebView {
//        // --- Configuration ---
//        let userContentController = WKUserContentController()
//        userContentController.add(context.coordinator, name: "spotifyController") // Bridge for JS -> Swift
//
//        let configuration = WKWebViewConfiguration()
//        configuration.userContentController = userContentController
//        configuration.allowsInlineMediaPlayback = true // Essential for embed
//        configuration.mediaTypesRequiringUserActionForPlayback = [] // Attempt autoplay
//
//        // --- WebView Creation ---
//        let webView = WKWebView(frame: .zero, configuration: configuration)
//        webView.navigationDelegate = context.coordinator
//        webView.uiDelegate = context.coordinator // Handles JS alerts etc.
//        webView.isOpaque = false
//        webView.backgroundColor = .clear // Let SwiftUI handle background
//        webView.scrollView.isScrollEnabled = false // Disable scrolling within embed
//
//        // --- Load Initial HTML ---
//        webView.loadHTMLString(generateHTML(), baseURL: nil)
//        context.coordinator.webView = webView // Store reference in coordinator
//        return webView
//    }
//
//    func updateUIView(_ webView: WKWebView, context: Context) {
//        // Only load a new URI if the API is ready and the URI has actually changed.
//        // This prevents redundant calls when the view updates for other reasons.
//        if context.coordinator.isApiReady && context.coordinator.lastLoadedUri != spotifyUri {
//            context.coordinator.loadUri(spotifyUri)
//        } else if !context.coordinator.isApiReady {
//            // Store the desired URI if the view updates *before* the JS API is ready
//            context.coordinator.updateDesiredUriBeforeReady(spotifyUri)
//        }
//    }
//
//    static func dismantleUIView(_ webView: WKWebView, coordinator: Coordinator) {
//        print("🧹 Spotify Embed WebView: Dismantling.")
//        webView.stopLoading()
//        // Important: Safely remove the message handler to prevent leaks/crashes
//        webView.configuration.userContentController.removeScriptMessageHandler(forName: "spotifyController")
//        // No need to nil out coordinator.webView here, view struct might be recreated
//    }
//
//    // --- Coordinator Class (Handles WKWebView Delegate methods & JS communication) ---
//    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
//        var parent: SpotifyEmbedWebView
//        weak var webView: WKWebView?
//        var isApiReady = false // Tracks if the Spotify IFrame JS API has loaded
//        var lastLoadedUri: String? // The last URI successfully told to load
//        private var desiredUriBeforeReady: String? = nil // Holds URI if updateUIView is called before API ready
//
//        init(_ parent: SpotifyEmbedWebView) { self.parent = parent }
//
//        func updateDesiredUriBeforeReady(_ uri: String?) {
//            if !isApiReady { desiredUriBeforeReady = uri }
//        }
//
//        // WKNavigationDelegate Methods
//        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//            print("📄 Spotify Embed: HTML finished loading.")
//            // Don't assume API is ready here, wait for JS callback 'onSpotifyIframeApiReady'
//        }
//        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) { // HTML loading failed
//            print("❌ Spotify Embed: HTML Navigation failed: \(error.localizedDescription)")
//            updateErrorState("WebView Navigation Failed: \(error.localizedDescription)")
//        }
//        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) { // Initial request failed
//            print("❌ Spotify Embed: Provisional Navigation failed: \(error.localizedDescription)")
//            updateErrorState("WebView Provisional Navigation Failed: \(error.localizedDescription)")
//        }
//
//        // WKScriptMessageHandler Method (Receives messages from JavaScript)
//        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
//            guard message.name == "spotifyController" else { return }
//
//            if let bodyDict = message.body as? [String: Any], let event = bodyDict["event"] as? String {
//                handleEvent(event: event, data: bodyDict["data"])
//            } else if let bodyString = message.body as? String {
//                if bodyString == "ready" { handleApiReady() } // API script loaded and called back
//            }
//        }
//
//        // --- Private Helper Methods for Coordinator ---
//        private func handleApiReady() {
//            if isApiReady { return } // Prevent double calls
//            print("✅ Spotify Embed Native: Spotify IFrame API reported READY.")
//            isApiReady = true
//            DispatchQueue.main.async { self.parent.playbackState.isReady = true }
//
//            // Load the initial or most recently requested URI
//            if let initialUri = desiredUriBeforeReady ?? parent.spotifyUri {
//                createSpotifyController(with: initialUri)
//            }
//            desiredUriBeforeReady = nil // Clear after use
//        }
//
//        private func handleEvent(event: String, data: Any?) {
//            print("📬 JS Event: \(event), Data: \(data ?? "nil")") // Debug log
//            switch event {
//            case "controllerCreated":
//                print("✅ Spotify Embed Native: Embed controller created successfully.")
//                clearErrorState()
//            case "playbackUpdate":
//                if let updateData = data as? [String: Any] { updatePlaybackState(with: updateData) }
//            case "error":
//                let errorMessage = extractErrorMessage(from: data)
//                print("❌ Spotify Embed JS Error: \(errorMessage)")
//                updateErrorState(errorMessage)
//            default: break // Ignore unknown events
//            }
//        }
//
//        private func updatePlaybackState(with data: [String: Any]) {
//            DispatchQueue.main.async { // Ensure UI updates on main thread
//                var stateChanged = false
//                if let isPaused = data["paused"] as? Bool, self.parent.playbackState.isPlaying == isPaused {
//                    self.parent.playbackState.isPlaying = !isPaused; stateChanged = true
//                }
//                if let posMs = data["position"] as? Double, abs(self.parent.playbackState.currentPosition - (posMs / 1000.0)) > 0.1 {
//                    self.parent.playbackState.currentPosition = posMs / 1000.0; stateChanged = true
//                }
//                if let durMs = data["duration"] as? Double {
//                    let newDuration = durMs / 1000.0
//                    if abs(self.parent.playbackState.duration - newDuration) > 0.1 || self.parent.playbackState.duration == 0 {
//                        self.parent.playbackState.duration = newDuration; stateChanged = true
//                    }
//                }
//                if let uri = data["uri"] as? String, self.parent.playbackState.currentUri != uri {
//                    self.parent.playbackState.currentUri = uri
//                    self.parent.playbackState.currentPosition = 0 // Reset position on track change
//                    stateChanged = true
//                }
//
//                // Clear error on successful update
//                if stateChanged && self.parent.playbackState.error != nil { self.clearErrorState() }
//            }
//        }
//
//        private func createSpotifyController(with initialUri: String) {
//            guard let webView = webView, isApiReady else { return }
//            // Prevent re-initialization if already loaded
//            guard lastLoadedUri == nil else {
//                // Ixf URI changed while API was loading, load the new one now
//                if let finalDesired = desiredUriBeforeReady ?? parent.spotifyUri, finalDesired != lastLoadedUri {
//                    loadUri(finalDesired)
//                }
//                desiredUriBeforeReady = nil
//                return
//            }
//
//            print("🚀 Spotify Embed Native: Creating controller for URI: \(initialUri)")
//            lastLoadedUri = initialUri // Mark as attempting/loaded
//
//            // JavaScript to create the controller and add listeners
//            let script = """
//            // ... (Full JS script from previous correct version) ...
//            console.log('JS: Running create controller script.');
//            window.embedController = null;
//            const element = document.getElementById('embed-iframe');
//            if (!element || !window.IFrameAPI) {
//                const errorMsg = !element ? 'HTML embed-iframe not found' : 'Spotify IFrame API not loaded';
//                console.error('JS Error:', errorMsg);
//                window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: errorMsg }});
//                return;
//            }
//            console.log('JS: Creating controller for:', '\(initialUri)');
//            const options = { uri: '\(initialUri)', width: '100%', height: '100%' };
//            const callback = (controller) => {
//                if (!controller) { console.error('JS Error: createController callback null!'); window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'JS createController callback null' }}); return; }
//                console.log('✅ JS: Controller instance received.');
//                window.embedController = controller;
//                window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'controllerCreated' });
//                controller.addListener('ready', () => console.log('🎧 JS Event: Controller Ready.'));
//                controller.addListener('playback_update', e => window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'playbackUpdate', data: e.data }));
//                // Add other error listeners here...
//            };
//            try { window.IFrameAPI.createController(element, options, callback); }
//            catch (e) { console.error('💥 JS Exception:', e); window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'JS Exception: ' + e.message }}); lastLoadedUri = nil; /* Reset if creation failed */ }
//            """
//            evaluateJavaScript(script)
//        }
//
//        func loadUri(_ uri: String?) {
//            guard let webView = webView,
//                    isApiReady,
//                    lastLoadedUri != nil,
//                    let newUri = uri,
//                    lastLoadedUri != newUri else {
//                // Don't load if not ready, controller not created, URI is nil, or URI hasn't changed
//                return
//            }
//            print("🚀 Spotify Embed Native: Loading new URI via JS: \(newUri)")
//            lastLoadedUri = newUri // Update the loaded URI
//
//            // JavaScript to load the new URI and attempt play
//            let script = """
//            if (window.embedController) { console.log('JS: Loading URI: \(newUri)'); window.embedController.loadUri('\(newUri)'); window.embedController.play(); }
//            else { console.error('JS Error: Controller not found for loadUri'); window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'JS controller missing during loadUri' }}); }
//            """
//            evaluateJavaScript(script)
//        }
//        
//        // Helper to update playback state error
//        private func updateErrorState(_ message: String) {
//            DispatchQueue.main.async { self.parent.playbackState.error = message }
//        }
//        private func clearErrorState() {
//            DispatchQueue.main.async { if self.parent.playbackState.error != nil { self.parent.playbackState.error = nil } }
//        }
//        // Helper to extract error message from JS data
//        private func extractErrorMessage(from data: Any?) -> String {
//            return (data as? [String: Any])?["message"] as? String ?? (data as? String) ?? "Unknown player error"
//        }
//        // Helper to run JS safely
//        private func evaluateJavaScript(_ script: String) {
//            webView?.evaluateJavaScript(script) { _, error in
//                if let error = error {
//                    print("⚠️ Spotify Native JS Eval Error: \(error.localizedDescription)")
//                    // Potentially updateErrorState here if eval fails
//                }
//            }
//        }
//
//        // WKUIDelegate Method (Handles JS alert panels)
//        func webView(_ webView: WKWebView,
//                     runJavaScriptAlertPanelWithMessage message: String,
//                     initiatedByFrame frame: WKFrameInfo,
//                     completionHandler: @escaping () -> Void
//        ) {
//            print("ℹ️ Spotify Embed JS Alert: \(message)")
//            // Map common alerts to error state
//            if message.lowercased().contains("premium required") {
//                updateErrorState("Spotify Premium required.")
//            } else if message.lowercased().contains("login required") {
//                 updateErrorState("Spotify login required.")
//            }
//            completionHandler() // Always call completion handler
//        }
//    }
//
//    // --- Generate HTML ---
//    private func generateHTML() -> String {
//        // Robust HTML with error handling for API script loading
//        return """
//        <!DOCTYPE html><html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no"><title>Spotify Embed</title><style>html, body { margin: 0; padding: 0; width: 100%; height: 100%; overflow: hidden; background-color: transparent; } #embed-iframe { width: 100%; height: 100%; border: none; }</style></head><body><div id="embed-iframe"></div><script src="https://open.spotify.com/embed/iframe-api/v1" async></script><script>console.log('JS: Initial script.'); var apiReadyCbCalled = false; window.onSpotifyIframeApiReady = (IFrameAPI) => { if(apiReadyCbCalled) return; apiReadyCbCalled = true; console.log('✅ JS: API Ready.'); window.IFrameAPI = IFrameAPI; window.webkit?.messageHandlers?.spotifyController?.postMessage("ready"); }; const scriptTag = document.querySelector('script[src*="iframe-api"]'); if(scriptTag) { scriptTag.onerror = (e) => { console.error('❌ JS: Failed to load Spotify API script:', e); window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'Failed to load Spotify API script' }}); }; } else { console.warn('⚠️ JS: Could not find API script tag.'); window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'Could not find Spotify API script tag in HTML.' }}); } </script></body></html>
//        """
//    }
//}
//
//// MARK: - API Service (Token Required)
//
//// <<----- IMPORTANT: PASTE YOUR VALID SPOTIFY BEARER TOKEN HERE ----->>
//let spotifyBearerToken = "YOUR_SPOTIFY_BEARER_TOKEN_HERE" // Replace or use a secure method!
//// <<-------------------------------------------------------------------->>
//
//enum SpotifyAPIError: Error, LocalizedError {
//    case invalidURL, invalidToken, missingData
//    case networkError(Error)
//    case invalidResponse(Int, String?) // Status code, optional body
//    case decodingError(Error)
//
//    var errorDescription: String? { // User-facing messages
//        switch self {
//        case .invalidURL: return "Internal error: Invalid API URL."
//        case .networkError: return "Network connection issue. Please check your internet."
//        case .invalidResponse(401, _): return "Authentication failed. Invalid API Token."
//        case .invalidResponse(let code, _): return "Server error (\(code)). Please try again later."
//        case .decodingError: return "Error reading server response."
//        case .invalidToken: return "Authentication Token is invalid or missing."
//        case .missingData: return "Incomplete data received from server."
//        }
//    }
//    // Keep detailedDescription for debugging if needed...
//}
//
//struct SpotifyAPIService {
//    static let shared = SpotifyAPIService()
//    private let session: URLSession
//
//    init() {
//        session = URLSession(configuration: .default)
//    }
//
//    private func makeRequest<T: Decodable>(url: URL) async throws -> T {
//        guard !spotifyBearerToken.isEmpty, spotifyBearerToken != "YOUR_SPOTIFY_BEARER_TOKEN_HERE" else {
//            throw SpotifyAPIError.invalidToken
//        }
//        
//        var request = URLRequest(url: url)
//        request.setValue("Bearer \(spotifyBearerToken)", forHTTPHeaderField: "Authorization")
//        request.setValue("application/json", forHTTPHeaderField: "Accept")
//        request.timeoutInterval = 20
//
//        print("🚀 API Request: \(url.absoluteString)")
//        let (data, response) = try await session.data(for: request)
//
//        guard let httpResponse = response as? HTTPURLResponse else {
//            throw SpotifyAPIError.invalidResponse(0, "Not HTTP response.")
//        }
//        print("🚦 API Status: \(httpResponse.statusCode)")
//
//        guard (200...299).contains(httpResponse.statusCode) else {
//            throw SpotifyAPIError.invalidResponse(
//                httpResponse.statusCode,
//                String(data: data, encoding: .utf8)
//            )
//        }
//
//        do {
//            return try JSONDecoder().decode(T.self, from: data)
//        } catch {
//            print("❌ Decode Error: \(error)")
//            throw SpotifyAPIError.decodingError(error)
//        }
//    }
//
//    func searchAlbums(
//        query: String,
//        limit: Int = 20,
//        offset: Int = 0
//    ) async throws -> SpotifySearchResponse {
//        var components = URLComponents(string: "https://api.spotify.com/v1/search")!
//        components.queryItems = [ /* ... query items ... */
//            URLQueryItem(name: "q", value: query),
//            URLQueryItem(name: "type", value: "album"),
//            URLQueryItem(name: "limit", value: "\(limit)"),
//            URLQueryItem(name: "offset", value: "\(offset)")
//        ]
//        guard let url = components.url else {
//            throw SpotifyAPIError.invalidURL
//        }
//        return try await makeRequest(url: url)
//    }
//
//    func getAlbumTracks(
//        albumId: String,
//        limit: Int = 50,
//        offset: Int = 0
//    ) async throws -> AlbumTracksResponse {
//        var components = URLComponents(string: "https://api.spotify.com/v1/albums/\(albumId)/tracks")!
//        components.queryItems = [ /* ... query items ... */
//            URLQueryItem(name: "limit", value: "\(limit)"),
//            URLQueryItem(name: "offset", value: "\(offset)")
//        ]
//        guard let url = components.url else {
//            throw SpotifyAPIError.invalidURL
//        }
//        return try await makeRequest(url: url)
//    }
//}
//
//// MARK: - SwiftUI Views (Themed & Optimized)
//
//// MARK: Main List View
//struct SpotifyAlbumListView: View {
//    @State private var searchQuery: String = ""
//    @State private var displayedAlbums: [AlbumItem] = []
//    @State private var isLoading: Bool = false
//    @State private var searchInfo: Albums? = nil // Holds total count etc.
//    @State private var currentError: SpotifyAPIError? = nil
//    @State private var searchTask: Task<Void, Never>? = nil
//
//    var body: some View {
//        NavigationView {
//            ZStack {
//                NeumorphicTheme.darkBackground.ignoresSafeArea()
//
//                // --- Content ---
//                VStack(spacing: 0) {
//                    albumListOrPlaceholder
//                }
//                .navigationTitle("Album Search")
//                .navigationBarTitleDisplayMode(.large)
//                .toolbarBackground(NeumorphicTheme.darkBackground, for: .navigationBar)
//                .toolbarBackground(.visible, for: .navigationBar)
//                .toolbarColorScheme(.dark, for: .navigationBar)
//
//                // --- Search Bar ---
//                .searchable(
//                    text: $searchQuery,
//                    placement: .navigationBarDrawer(displayMode: .always),
//                    prompt: Text("Search Albums & Artists")
//                        .foregroundColor(NeumorphicTheme.secondaryText)
//                )
//                .onSubmit(of: .search) { triggerSearch(immediate: true) }
//                .onChange(of: searchQuery) {
//                    currentError = nil // Clear error on new typing
//                    triggerSearch() // Trigger debounced search
//                }
//                .tint(NeumorphicTheme.goldAccent) // Search bar cursor/cancel tint
//            } // End ZStack
//        } // End NavigationView
//        .accentColor(NeumorphicTheme.goldAccent) // Back button etc.
//    }
//
//    // Extracted placeholder/list logic
//    @ViewBuilder
//    private var albumListOrPlaceholder: some View {
//        if isLoading && displayedAlbums.isEmpty && currentError == nil {
//            Spacer()
//            NeumorphicLoadingIndicator()
//            Spacer()
//        } else if let error = currentError {
//            Spacer()
//            ErrorPlaceholderView(error: error) { triggerSearch(immediate: true) }
//            Spacer()
//        } else if displayedAlbums.isEmpty && !isLoading {
//            Spacer()
//            EmptyStatePlaceholderView(searchQuery: searchQuery)
//            Spacer()
//        } else {
//            albumList // Actual list content
//        }
//    }
//
//    // Themed List View
//    private var albumList: some View {
//        List {
//            // --- Album Cards ---
//            ForEach(displayedAlbums) { album in
//                ZStack { // Use ZStack for NavLink to avoid blue arrow
//                    NavigationLink(destination: AlbumDetailView(album: album)) { EmptyView() }.opacity(0)
//                     NeumorphicAlbumCard(album: album)
//                }
//                .listRowSeparator(.hidden)
//                .listRowInsets(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15))
//                .listRowBackground(NeumorphicTheme.darkBackground)
//            }
//             // Optional: Progress Indicator for loading more pages
//        }
//        .listStyle(.plain)
//        .scrollContentBackground(.hidden)
//        .overlay(alignment: .bottom) { // Subtle loading indicator for subsequent loads
//            if isLoading && !displayedAlbums.isEmpty {
//                 NeumorphicLoadingIndicator(size: 30, text: "Loading...")
//                     .padding(.bottom, 15)
//                     .transition(.opacity.animation(.easeInOut))
//            }
//        }
//    }
//
//    // --- Debounced Search Logic ---
//    private func triggerSearch(immediate: Bool = false) {
//        searchTask?.cancel() // Cancel previous search task
//
//        let currentQuery = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
//
//        // Handle empty query immediately if forced, or within the task if debounced
//        guard !currentQuery.isEmpty || !immediate else {
//            if immediate && currentQuery.isEmpty { // Explicit clear only if immediate submit is empty
//                Task { await MainActor.run { displayedAlbums = []; searchInfo = nil; isLoading = false; currentError = nil } }
//            }
//            return // Don't start a task for empty query unless debounced
//        }
//
//        searchTask = Task {
//            // If the query became empty during the debounce period
//            if currentQuery.isEmpty {
//                 await MainActor.run { displayedAlbums = []; searchInfo = nil; isLoading = false; currentError = nil }
//                 return
//            }
//            
//            if !immediate { // Apply debounce delay
//                do { try await Task.sleep(for: .milliseconds(500)); try Task.checkCancellation() }
//                catch { print("Search task cancelled (debounce)."); return }
//            }
//
//            await MainActor.run { isLoading = true }
//
//            do {
//                print("⚡️ Performing search for: '\(currentQuery)'")
//                let response = try await SpotifyAPIService.shared.searchAlbums(query: currentQuery)
//                try Task.checkCancellation()
//
//                await MainActor.run {
//                    displayedAlbums = response.albums.items
//                    searchInfo = response.albums
//                    currentError = nil
//                    isLoading = false
//                }
//            } catch is CancellationError {
//                 print("Search task cancelled.")
//                 // Don't resetisLoading if cancelled, the next task will handle it
//                 await MainActor.run { if !Task.isCancelled { isLoading = false } }
//            } catch let error as SpotifyAPIError {
//                print("❌ Search API Error: \(error.localizedDescription)")
//                await MainActor.run { currentError = error; isLoading = false; displayedAlbums = []; searchInfo = nil }
//            } catch {
//                 print("❌ Unexpected Search Error: \(error)")
//                 await MainActor.run { currentError = .networkError(error); isLoading = false; displayedAlbums = []; searchInfo = nil }
//            }
//        }
//    }
//}
//
//// MARK: - Neumorphic Album Card View
//struct NeumorphicAlbumCard: View {
//    let album: AlbumItem
//
//    var body: some View {
//        HStack(spacing: 15) {
//            AlbumImageView(url: album.listImageURL)
//                .frame(width: 70, height: 70)
//                // Apply shadow directly to the image view container
//                .neumorphicShadow(cornerRadius: 10, shadowRadius: 4, shadowOffset: 3)
//
//            VStack(alignment: .leading, spacing: 4) {
//                Text(album.name)
//                    .font(neumorphicFont(size: 16, weight: .semibold))
//                    .foregroundColor(NeumorphicTheme.primaryText)
//                    .lineLimit(2)
//
//                Text(album.formattedArtists)
//                    .font(neumorphicFont(size: 13))
//                    .foregroundColor(NeumorphicTheme.secondaryText)
//                    .lineLimit(1)
//
//                Spacer(minLength: 4) // Min space before bottom info
//
//                HStack(spacing: 6) { // Album Type & Release Date
//                    Image(systemName: album.album_type == "album" ? "opticaldisc" : "rectangle.stack")
//                        .font(.system(size: 10))
//                    Text(album.album_type.capitalized)
//                    Text("•")
//                    Text(album.formattedReleaseDate())
//                }
//                .font(neumorphicFont(size: 11))
//                .foregroundColor(NeumorphicTheme.secondaryText)
//            }
//            .frame(maxWidth: .infinity, alignment: .leading)
//            .padding(.vertical, 5) // Internal padding for text Vstack
//        }
//        .padding(12) // Padding inside the card surface
//        .background(NeumorphicTheme.elementBackground)
//        .neumorphicShadow(cornerRadius: 15) // Shadow for the entire card background
//    }
//}
//
//// MARK: - Album Detail View
//struct AlbumDetailView: View {
//    let album: AlbumItem
//    @State private var tracks: [Track] = []
//    @State private var isLoadingTracks: Bool = false
//    @State private var trackFetchError: SpotifyAPIError? = nil
//    @State private var selectedTrackUri: String? = nil // Holds the URI of the track tapped
//    @StateObject private var playbackState = SpotifyPlaybackState() // Manages embed player state
//    @Environment(\.openURL) var openURL
//
//    var body: some View {
//        ZStack {
//            NeumorphicTheme.darkBackground.ignoresSafeArea()
//
//            List {
//                // --- Header: Album Art & Info ---
//                Section { AlbumHeaderView(album: album) }
//                    .listRowInsets(EdgeInsets())
//                    .listRowSeparator(.hidden)
//                    .listRowBackground(Color.clear)
//
//                // --- Player Section (Shows only when a track is selected or error) ---
//                if selectedTrackUri != nil || playbackState.error != nil {
//                    Section {
//                         NeumorphicPlayerContainerView(playbackState: playbackState, spotifyUri: selectedTrackUri)
//                             .transition(.opacity.combined(with: .scale(scale: 0.95))) // Smooth appear/disappear
//                    }
//                    .listRowInsets(EdgeInsets(top: 10, leading: 15, bottom: 15, trailing: 15))
//                    .listRowSeparator(.hidden)
//                    .listRowBackground(Color.clear)
//                }
//
//                // --- Tracks List Section ---
//                 Section { TracksListView(tracks: tracks, isLoading: isLoadingTracks, error: trackFetchError, selectedTrackUri: $selectedTrackUri, retryAction: { Task { await fetchTracks() } }) }
//                     header: { SectionHeaderTextView(title: "Tracks") }
//                     .listRowInsets(EdgeInsets()) // Remove default group padding
//                     .listRowSeparator(.hidden)
//                     .listRowBackground(Color.clear)
//
//                // --- External Link Button ---
//                if let spotifyURL = URL(string: album.external_urls.spotify ?? "") {
//                     Section { NeumorphicButton(action: { openURL(spotifyURL) }, label: { HStack { Image(systemName: "arrow.up.forward.app.fill"); Text("Open in Spotify") } }, isGold: true) // Gold accent for primary action
//                     }
//                     .listRowInsets(EdgeInsets(top: 25, leading: 20, bottom: 30, trailing: 20))
//                     .listRowSeparator(.hidden)
//                     .listRowBackground(Color.clear)
//                 }
//
//            } // End List
//            .listStyle(.plain)
//            .scrollContentBackground(.hidden) // Allow ZStack background through
//            .animation(.easeInOut, value: selectedTrackUri) // Animate player appearance based on selection
//            .animation(.easeInOut, value: playbackState.error) // Animate embed error display
//        } // End ZStack
//        .navigationTitle(album.name)
//        .navigationBarTitleDisplayMode(.inline)
//        .toolbarBackground(NeumorphicTheme.darkBackground, for: .navigationBar)
//        .toolbarBackground(.visible, for: .navigationBar)
//        .toolbarColorScheme(.dark, for: .navigationBar)
//        .task { await fetchTracks() } // Load tracks on appear
//        .refreshable { await fetchTracks(forceReload: true) } // Support pull-to-refresh
//    }
//
//    // --- Fetch Tracks Logic ---
//    private func fetchTracks(forceReload: Bool = false) async {
//        guard forceReload || tracks.isEmpty || trackFetchError != nil else { return } // Avoid refetching needlessly
//
//        await MainActor.run { isLoadingTracks = true; trackFetchError = nil }
//        do {
//            let response = try await SpotifyAPIService.shared.getAlbumTracks(albumId: album.id)
//            try Task.checkCancellation()
//            await MainActor.run { self.tracks = response.items; self.isLoadingTracks = false }
//            // Optionally auto-select first track:
//            // if selectedTrackUri == nil && !response.items.isEmpty { selectedTrackUri = response.items.first?.uri }
//        } catch is CancellationError { await MainActor.run { isLoadingTracks = false } }
//        catch let error as SpotifyAPIError { print("❌ Fetch Tracks Error: \(error.localizedDescription)"); await MainActor.run { self.trackFetchError = error; self.isLoadingTracks = false; tracks = [] } }
//        catch { print("❌ Unexpected Tracks Error: \(error)"); await MainActor.run { self.trackFetchError = .networkError(error); self.isLoadingTracks = false; tracks = [] } }
//    }
//}
//
//// MARK: - Detail View Sub-Components (Header, Player Container, Tracks List)
//
//struct AlbumHeaderView: View {
//    let album: AlbumItem
//
//    var body: some View {
//        VStack(spacing: 18) {
//            AlbumImageView(url: album.bestImageURL)
//                .aspectRatio(1.0, contentMode: .fit)
//                .padding(8) // Padding *inside* the neumorphic frame
//                // Prominent shadow for the main image
//                .neumorphicShadow(cornerRadius: 25, shadowRadius: 8, shadowOffset: 5)
//                .padding(.horizontal, 40)
//
//            VStack(spacing: 5) {
//                Text(album.name)
//                    .font(neumorphicFont(size: 22, weight: .bold))
//                    .foregroundColor(NeumorphicTheme.primaryText)
//                    .multilineTextAlignment(.center)
//
//                Text("by \(album.formattedArtists)")
//                    .font(neumorphicFont(size: 16))
//                    .foregroundStyle(NeumorphicTheme.goldGradient) // Gold accent
//                    .multilineTextAlignment(.center)
//
//                Text("\(album.album_type.capitalized) • \(album.formattedReleaseDate())")
//                    .font(neumorphicFont(size: 12))
//                    .foregroundColor(NeumorphicTheme.secondaryText)
//            }
//            .padding(.horizontal)
//        }
//        .padding(.vertical, 25)
//    }
//}
//
//// Neumorphic container for the player and its status line
//struct NeumorphicPlayerContainerView: View {
//    @ObservedObject var playbackState: SpotifyPlaybackState
//    let spotifyUri: String? // Can be nil if only showing error
//
//    var body: some View {
//        VStack(spacing: 10) {
//            // Embed WebView or Error Message Area
//            ZStack { // Use ZStack to overlay loading/error states if needed
//                // Embed itself (if available)
//                if let uri = spotifyUri, playbackState.error == nil {
//                    SpotifyEmbedWebView(playbackState: playbackState, spotifyUri: uri)
//                        .clipShape(RoundedRectangle(cornerRadius: 12)) // Clip webview inside
//                } else {
//                     // Placeholder/Error background
//                     RoundedRectangle(cornerRadius: 12)
//                        .fill(NeumorphicTheme.darkBackground.opacity(0.3)) // Darker inset look
//                }
//                
//                // Loading Indicator Overlay
//                if !playbackState.isReady && playbackState.error == nil {
//                     HStack { ProgressView().tint(NeumorphicTheme.goldAccent); Text("Loading Player...").font(.caption) }
//                        .foregroundColor(NeumorphicTheme.secondaryText)
//                        .padding(8)
//                        .background(.ultraThinMaterial, in: Capsule())
//                }
//                
//                // Error Message Overlay
//                if let error = playbackState.error {
//                    VStack {
//                        Image(systemName: "exclamationmark.triangle.fill")
//                            .foregroundColor(NeumorphicTheme.errorColor)
//                        Text(error)
//                             .font(neumorphicFont(size: 11))
//                             .foregroundColor(NeumorphicTheme.errorColor)
//                             .lineLimit(2)
//                             .multilineTextAlignment(.center).padding(.horizontal, 5)
//                     }
//                     .padding(10)
//                 }
//             }
//             .frame(height: 80) // Standard height for the embed
//
//            // --- Playback Status & Time ---
//            HStack {
//                Text(statusText)
//                    .font(neumorphicFont(size: 11, weight: .medium))
//                    .foregroundStyle(statusColor)
//                    .animation(.easeInOut, value: playbackState.isPlaying)
//
//                Spacer()
//
//                Text(timeText)
//                    .font(neumorphicFont(size: 11, weight: .regular, design: .monospaced)) // Monospaced for time
//                    .foregroundColor(NeumorphicTheme.secondaryText)
//            }
//            .padding(.top, 4) // Space between embed and status line
//            .opacity(playbackState.error == nil ? 1 : 0) // Hide status if error is shown
//
//        } // End VStack
//        .padding(12) // Padding inside the container
//        .background(NeumorphicTheme.elementBackground)
//        .neumorphicShadow(cornerRadius: 15) // Neumorphic container
//    }
//
//    // Helper computed properties for status display
//    private var statusText: String {
//        guard playbackState.error == nil else { return "" } // No status if error
//        guard playbackState.isReady else { return "" } // No status until ready
//        return playbackState.isPlaying ? "Playing" : "Paused"
//    }
//
//    private var statusColor: LinearGradient {
//        playbackState.isPlaying ? NeumorphicTheme.goldGradient : LinearGradient(colors: [NeumorphicTheme.secondaryText], startPoint: .top, endPoint: .bottom)
//    }
//    
//    private var timeText: String {
//        guard playbackState.isReady, playbackState.duration > 0.1 else { return "--:-- / --:--" }
//        
//        let current = formatTime(playbackState.currentPosition)
//        let total = formatTime(playbackState.duration)
//        return "\(current) / \(total)"
//    }
//
//    private func formatTime(_ time: Double) -> String {
//        let totalSeconds = max(0, Int(time))
//        return String(format: "%d:%02d", totalSeconds / 60, totalSeconds % 60)
//    }
//}
//
//// View specifically for the list of tracks within the detail view
//struct TracksListView: View {
//    let tracks: [Track]
//    let isLoading: Bool
//    let error: SpotifyAPIError?
//    @Binding var selectedTrackUri: String? // Binding to update the detail view's state
//    let retryAction: () -> Void
//
//    var body: some View {
//        VStack(spacing: 0) { // Use VStack for background/shadow
//            if isLoading {
//                 NeumorphicLoadingIndicator(text: "Loading Tracks...").padding(.vertical, 30)
//            } else if let error = error {
//                 VStack { ErrorPlaceholderView(error: error, retryAction: retryAction) }.padding(.vertical, 20)
//            } else if tracks.isEmpty {
//                 Text("No Tracks Found").foregroundColor(NeumorphicTheme.secondaryText).padding(.vertical, 30)
//            } else {
//                ForEach(tracks) { track in
//                    TrackRowView(track: track, isSelected: track.uri == selectedTrackUri)
//                        .contentShape(Rectangle())
//                        .onTapGesture { if selectedTrackUri != track.uri { selectedTrackUri = track.uri } }
//                    // Optional subtle divider
//                    if track.id != tracks.last?.id {
//                         Divider().background(NeumorphicTheme.darkShadow.opacity(0.2)).padding(.leading, 45)
//                    }
//                }
//            }
//        }
//        .padding(.vertical, 5) // Internal padding
//        .background(NeumorphicTheme.elementBackground)
//        .neumorphicShadow(cornerRadius: NeumorphicTheme.cornerRadius) // Apply effect to the whole list area
//        .padding(.horizontal, 15) // Padding B/W list area and screen edge
//    }
//}
//
//// Individual Track Row (stateless display)
//struct TrackRowView: View {
//    let track: Track
//    let isSelected: Bool
//
//    var body: some View {
//        HStack(spacing: 12) {
//            // Track Number or Playing Indicator
//            ZStack {
//                if isSelected { Image(systemName: "waveform").foregroundStyle(NeumorphicTheme.goldGradient) } // Gold indicator
//                else { Text("\(track.track_number)").foregroundColor(NeumorphicTheme.secondaryText) }
//            }
//            .font(neumorphicFont(size: isSelected ? 14 : 12, weight: .medium))
//            .frame(width: 25, alignment: .center)
//
//            // Track Name & Artist
//            VStack(alignment: .leading, spacing: 3) {
//                Text(track.name).lineLimit(1)
//                    .font(neumorphicFont(size: 15, weight: .medium))
//                    .foregroundColor(NeumorphicTheme.primaryText)
//                Text(track.formattedArtists).lineLimit(1)
//                    .font(neumorphicFont(size: 12))
//                    .foregroundColor(NeumorphicTheme.secondaryText)
//            }
//
//            Spacer()
//
//            // Optional: Explicit Badge
//            if track.explicit { Text("E").explicitBadgeStyle() }
//
//            // Duration
//            Text(track.formattedDuration)
//                 .font(neumorphicFont(size: 12, design: .monospaced))
//                 .foregroundColor(NeumorphicTheme.secondaryText)
//                 .frame(width: 40, alignment: .trailing)
//        }
//        .padding(.vertical, 14)
//        .padding(.horizontal, 15)
//        // Subtle background highlight for selected row
//        .background(isSelected ? NeumorphicTheme.darkBackground.opacity(0.5) : Color.clear)
//        .animation(.easeInOut(duration: 0.2), value: isSelected)
//    }
//}
//
//// Helper modifier for the Explicit badge styling
//extension Text {
//    func explicitBadgeStyle() -> some View {
//        self.font(neumorphicFont(size: 10, weight: .bold))
//            .padding(.horizontal, 4).padding(.vertical, 1)
//            .background(NeumorphicTheme.secondaryText.opacity(0.3), in: RoundedRectangle(cornerRadius: 3))
//            .foregroundColor(NeumorphicTheme.secondaryText)
//    }
//}
//
//// MARK: - Other Supporting Views (Loading, Placeholders, Headers)
//
//struct NeumorphicLoadingIndicator: View {
//    var size: CGFloat = 50
//    var text: String? = nil
//
//    var body: some View {
//        VStack(spacing: 15) {
//             ProgressView()
//                 .progressViewStyle(.circular).tint(NeumorphicTheme.goldAccent)
//                 .scaleEffect(size / 40)
//                 .frame(width: size, height: size) // Frame for ProgressView itself
//                 .padding(size * 0.25) // Padding around ProgressView
//                 .background(NeumorphicTheme.elementBackground)
//                 .neumorphicShadow(cornerRadius: (size + size * 0.5) / 2) // Circular shadow based on total size
//
//            if let text = text {
//                Text(text).font(neumorphicFont(size: 13)).foregroundColor(NeumorphicTheme.secondaryText)
//            }
//        }
//    }
//}
//
//struct ErrorPlaceholderView: View {
//    let error: SpotifyAPIError
//    let retryAction: (() -> Void)?
//
//    var body: some View {
//        VStack(spacing: 18) {
//             Image(systemName: iconName)
//                 .font(.system(size: 45, weight: .light))
//                 .foregroundStyle(NeumorphicTheme.goldGradient) // Gold icon
//                 .padding(20)
//                 .background(NeumorphicTheme.elementBackground)
//                 .neumorphicShadow(cornerRadius: 35, shadowRadius: 8, shadowOffset: 5) // Circular
//
//             Text("Error").font(neumorphicFont(size: 18, weight: .semibold)).foregroundColor(NeumorphicTheme.primaryText)
//             Text(error.localizedDescription).font(neumorphicFont(size: 13)).foregroundColor(NeumorphicTheme.secondaryText)
//                 .multilineTextAlignment(.center).padding(.horizontal, 20)
//
//            if case .invalidToken = error { // Specific guidance for token errors
//                 Text("Check Spotify Bearer Token in code.").font(neumorphicFont(size: 11)).foregroundColor(NeumorphicTheme.errorColor).multilineTextAlignment(.center).padding(.horizontal, 20)
//            }
//
//            // Retry Button (if action provided and not a token error)
//            if let retryAction = retryAction, !isTokenError {
//                 NeumorphicButton(action: retryAction, label: { Text("Retry") }, isGold: true)
//                     .padding(.top, 10).frame(width: 150)
//            }
//        }
//        .padding(30) // Inside container
//        .background(NeumorphicTheme.elementBackground)
//        .neumorphicShadow(cornerRadius: 25) // Container shadow
//        .padding(20) // Around container
//    }
//
//    private var isTokenError: Bool { if case .invalidToken = error { return true } else { return false } }
//    private var iconName: String {
//        switch error {
//        case .invalidToken: return "key.slash"
//        case .networkError: return "wifi.slash"
//        default: return "exclamationmark.triangle.fill"
//        }
//    }
//}
//
//struct EmptyStatePlaceholderView: View {
//     let searchQuery: String
//
//     var body: some View {
//        VStack(spacing: 18) {
//             Image(systemName: iconName)
//                 .font(.system(size: 50, weight: .thin))
//                 .foregroundStyle(NeumorphicTheme.goldGradient)// Gold icon
//                 .padding(25)
//                 .background(NeumorphicTheme.elementBackground)
//                 .neumorphicShadow(cornerRadius: 42.5, shadowRadius: 8, shadowOffset: 5) // Circular
//
//             Text(title).font(neumorphicFont(size: 18, weight: .semibold)).foregroundColor(NeumorphicTheme.primaryText)
//             Text(message).font(neumorphicFont(size: 13)).foregroundColor(NeumorphicTheme.secondaryText)
//                 .multilineTextAlignment(.center).padding(.horizontal, 20)
//        }
//         .padding(30) // Inside container
//         .background(NeumorphicTheme.elementBackground)
//         .neumorphicShadow(cornerRadius: 25) // Container shadow
//         .padding(20) // Around container
//    }
//
//     private var isInitialState: Bool { searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
//     private var iconName: String { isInitialState ? "magnifyinglass" : "questionmark.circle" }
//     private var title: String { isInitialState ? "Spotify Album Search" : "No Results Found" }
//     private var message: String {
//         isInitialState ? "Enter an album or artist name above." : "No matches found for \"\(searchQuery)\". Try different keywords."
//     }
//}
//
//// Generic button using the NeumorphicButtonStyle
//struct NeumorphicButton<Label: View>: View {
//    let action: () -> Void
//    @ViewBuilder let label: () -> Label // Use @ViewBuilder for flexible label content
//    var isGold: Bool = false
//
//    var body: some View {
//        Button(action: action) { label() }
//            .buttonStyle(NeumorphicButtonStyle(isGold: isGold))
//    }
//}
//
//// Reusable Section Header Text
//struct SectionHeaderTextView: View {
//    let title: String
//    var body: some View {
//        Text(title.uppercased())
//            .font(neumorphicFont(size: 12, weight: .medium))
//            .foregroundColor(NeumorphicTheme.secondaryText)
//            .tracking(1.5) // Letter spacing
//            .frame(maxWidth: .infinity, alignment: .leading)
//            .padding(.leading, 20).padding(.bottom, 5).padding(.top, 10)
//    }
//}
//
//// Reusable Image View with themed placeholder/error states
//struct AlbumImageView: View {
//    let url: URL?
//
//    var body: some View {
//        AsyncImage(url: url) { phase in
//            switch phase {
//            case .empty: neumorphicPlaceholder(content: ProgressView().tint(NeumorphicTheme.goldAccent))
//            case .success(let image): image.resizable().scaledToFit()
//            case .failure: neumorphicPlaceholder(content: Image(systemName: "photo.fill").foregroundColor(NeumorphicTheme.secondaryText.opacity(0.5)))
//            @unknown default: EmptyView()
//            }
//        }
//    }
//
//    // Helper for consistent neumorphic placeholder background
//    @ViewBuilder private func neumorphicPlaceholder<Content: View>(content: Content) -> some View {
//        ZStack {
//            NeumorphicTheme.elementBackground
//            content
//        }
//    }
//}
//
//// MARK: - App Entry Point
//
//@main
//struct SpotifyNeumorphicApp: App {
//    init() {
//        // --- Critical Startup Token Check ---
//        if spotifyBearerToken.isEmpty || spotifyBearerToken == "YOUR_SPOTIFY_BEARER_TOKEN_HERE" {
//            print("\n🚨🎬 FATAL STARTUP WARNING: Spotify Bearer Token is MISSING or is the placeholder!")
//            print("👉 FIX: Replace 'YOUR_SPOTIFY_BEARER_TOKEN_HERE' in the `spotifyBearerToken` constant with a *valid* token obtained from Spotify Developer Dashboard.\n")
//            // Consider adding a mechanism to prevent the app from fully launching without a token in a real scenario.
//        }
//
//        // --- Configure Global Navigation Bar Appearance ---
//        let appearance = UINavigationBarAppearance()
//        appearance.configureWithOpaqueBackground()
//        appearance.backgroundColor = UIColor(NeumorphicTheme.darkBackground) // Consistent background
//        // Title styling
//        appearance.titleTextAttributes = [.foregroundColor: UIColor(NeumorphicTheme.primaryText)]
//        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor(NeumorphicTheme.primaryText)]
//        // Button (back button etc.) styling
//        let buttonAppearance = UIBarButtonItemAppearance()
//        buttonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(NeumorphicTheme.goldAccent)]
//        appearance.buttonAppearance = buttonAppearance
//        appearance.doneButtonAppearance = buttonAppearance // Style "Done" buttons too
//        // Assign appearance
//        UINavigationBar.appearance().standardAppearance = appearance
//        UINavigationBar.appearance().scrollEdgeAppearance = appearance
//        UINavigationBar.appearance().compactAppearance = appearance
//        // Global tint for items like back arrow
//        UINavigationBar.appearance().tintColor = UIColor(NeumorphicTheme.goldAccent)
//    }
//
//    var body: some Scene {
//        WindowGroup {
//            SpotifyAlbumListView()
//                .preferredColorScheme(.dark) // Enforce dark mode for theme consistency
//        }
//    }
//}
