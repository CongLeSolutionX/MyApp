////
////  DarkNeumorphismThemeLook_V3.swift
////  MyApp
////
////  Created by Cong Le on 4/19/25.
////
//
//
//import SwiftUI
//@preconcurrency import WebKit // For Spotify Embed WebView
//import Foundation
//
//// MARK: - Deep Black Neumorphism Theme Constants & Helpers
//
//struct DeepBlackNeumorphicTheme {
//    /// --- Core Colors ---
//    /// Using an Extended Dynamic Range (EDR) color for the deepest black background.
//    /// Note: Behavior depends on display capabilities. On standard displays, it might clamp to black (0.0).
//    static let background = Color(.sRGB, white: -0.1, opacity: 1.0) // EDR Deep Black
//
//    /// Element background slightly lighter than the deep black for subtle contrast.
//    static let elementBackground = Color(white: 0.12) // Adjusted slightly lighter than pure black
//
//    /// --- Shadows ---
//    /// Light shadow needs slightly higher opacity to be visible against the deep black.
//    static let lightShadow = Color.white.opacity(0.18) // Increased opacity
//    /// Dark shadow remains black but might appear softer against the deep black background.
//    static let darkShadow = Color.black.opacity(0.6)   // Slightly increased opacity for contrast
//
//    /// --- Text & Accent Colors ---
//    static let primaryText = Color.white.opacity(0.9) // Slightly brighter for better contrast
//    static let secondaryText = Color(white: 0.65, opacity: 0.8) // Adjusted for clarity
//
//    /// Accent color - keeping it somewhat muted but ensuring visibility.
//    static let accentColor = Color(hue: 0.6, saturation: 0.4, brightness: 0.8) // Slightly brighter accent
//    /// Error color - keeping it muted but ensuring visibility.
//    static let errorColor = Color(hue: 0.0, saturation: 0.6, brightness: 0.8) // Slightly brighter error
//
//    /// --- Shadow Configuration ---
//    static let shadowRadius: CGFloat = 7 // Slightly increased radius might help visibility
//    static let shadowOffset: CGFloat = 5 // Slightly increased offset
//}
//
//// Font helper (using system fonts for simplicity)
//func neumorphicFont(size: CGFloat, weight: Font.Weight = .regular, design: Font.Design = .default) -> Font {
//    return Font.system(size: size, weight: weight, design: design)
//}
//
////MARK: -> Neumorphic View Modifiers / Styles
//
//// --- Outer Shadow for Extruded Elements ---
//struct NeumorphicOuterShadow: ViewModifier {
//    let cornerRadius: CGFloat = 15
//
//    func body(content: Content) -> some View {
//        content
//            .background(
//                RoundedRectangle(cornerRadius: cornerRadius)
//                    .fill(DeepBlackNeumorphicTheme.elementBackground)
//                    .shadow(color: DeepBlackNeumorphicTheme.darkShadow,
//                            radius: DeepBlackNeumorphicTheme.shadowRadius,
//                            x: DeepBlackNeumorphicTheme.shadowOffset,
//                            y: DeepBlackNeumorphicTheme.shadowOffset)
//                    .shadow(color: DeepBlackNeumorphicTheme.lightShadow,
//                            radius: DeepBlackNeumorphicTheme.shadowRadius,
//                            x: -DeepBlackNeumorphicTheme.shadowOffset,
//                            y: -DeepBlackNeumorphicTheme.shadowOffset)
//            )
//    }
//}
//
//// --- Inner Shadow for Depressed Elements (Approximation) ---
//struct NeumorphicInnerShadow: ViewModifier {
//    let cornerRadius: CGFloat = 15
//
//    func body(content: Content) -> some View {
//         // Approximation: overlaying shadows clipped to the shape's inverse
//        content
//            .padding(2) // Inset content slightly
//            .background(DeepBlackNeumorphicTheme.elementBackground) // Base color inside
//            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
//            .overlay( // Simulate the inner shadows on the container
//                RoundedRectangle(cornerRadius: cornerRadius)
//                    .stroke(DeepBlackNeumorphicTheme.background, lineWidth: 4) // Use background color, adjust thickness if needed
//                    .shadow(color: DeepBlackNeumorphicTheme.darkShadow, radius: DeepBlackNeumorphicTheme.shadowRadius - 1, x: DeepBlackNeumorphicTheme.shadowOffset - 1, y: DeepBlackNeumorphicTheme.shadowOffset - 1)
//                    .shadow(color: DeepBlackNeumorphicTheme.lightShadow, radius: DeepBlackNeumorphicTheme.shadowRadius - 1, x: -(DeepBlackNeumorphicTheme.shadowOffset - 1), y: -(DeepBlackNeumorphicTheme.shadowOffset - 1))
//                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius)) // Clip shadows to the inside edge
//                    .blendMode(.overlay) // Experiment with blend modes if needed, often not necessary
//            )
//    }
//}
//
//// --- Neumorphic Button Style ---
//struct NeumorphicButtonStyle: ButtonStyle {
//    func makeBody(configuration: Configuration) -> some View {
//        configuration.label
//            .padding(.vertical, 12)
//            .padding(.horizontal, 20)
//            .background(
//                NeumorphicButtonBackground(isPressed: configuration.isPressed)
//            )
//            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
//            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
//    }
//}
//
//// Helper for button background state
//struct NeumorphicButtonBackground: View {
//    var isPressed: Bool
//    let cornerRadius: CGFloat = 20
//
//    var body: some View {
//        ZStack {
//            RoundedRectangle(cornerRadius: cornerRadius)
//                .fill(DeepBlackNeumorphicTheme.elementBackground) // Fill color
//
//            if isPressed {
//                 // Inner Shadow effect simulated for pressed state
//                RoundedRectangle(cornerRadius: cornerRadius)
//                    .stroke(DeepBlackNeumorphicTheme.elementBackground, lineWidth: 1) // Thin stroke, subtle
//                    .shadow(color: DeepBlackNeumorphicTheme.darkShadow, radius: DeepBlackNeumorphicTheme.shadowRadius / 2, x: DeepBlackNeumorphicTheme.shadowOffset / 2, y: DeepBlackNeumorphicTheme.shadowOffset / 2)
//                    .shadow(color: DeepBlackNeumorphicTheme.lightShadow, radius: DeepBlackNeumorphicTheme.shadowRadius / 2, x: -DeepBlackNeumorphicTheme.shadowOffset / 2, y: -DeepBlackNeumorphicTheme.shadowOffset / 2)
//                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius)) // Clip shadows inward
//                    .blendMode(.overlay) // Overlay can sometimes enhance inset feel
//
//            } else {
//                // Outer Shadow (Extruded) for default state
//                RoundedRectangle(cornerRadius: cornerRadius)
//                    .fill(DeepBlackNeumorphicTheme.elementBackground) // Draw shadows on this shape
//                    .shadow(color: DeepBlackNeumorphicTheme.darkShadow,
//                            radius: DeepBlackNeumorphicTheme.shadowRadius,
//                            x: DeepBlackNeumorphicTheme.shadowOffset,
//                            y: DeepBlackNeumorphicTheme.shadowOffset)
//                    .shadow(color: DeepBlackNeumorphicTheme.lightShadow,
//                            radius: DeepBlackNeumorphicTheme.shadowRadius,
//                            x: -DeepBlackNeumorphicTheme.shadowOffset,
//                            y: -DeepBlackNeumorphicTheme.shadowOffset)
//            }
//        }
//    }
//}
//
//// MARK: - Data Models (Unchanged from previous versions)
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
//
//    var listImageURL: URL? {
//        images.first { $0.width == 300 }?.urlObject ??
//        images.first { $0.width == 64 }?.urlObject ??
//        images.first?.urlObject
//    }
//
//    var formattedArtists: String {
//        artists.map { $0.name }.joined(separator: ", ")
//    }
//
//    func formattedReleaseDate() -> String {
//        let dateFormatter = DateFormatter()
//        switch release_date_precision {
//        case "year":
//            dateFormatter.dateFormat = "yyyy"
//            if let date = dateFormatter.date(from: release_date) { return dateFormatter.string(from: date) }
//        case "month":
//            dateFormatter.dateFormat = "yyyy-MM"
//            if let date = dateFormatter.date(from: release_date) {
//                dateFormatter.dateFormat = "MMM yyyy"; return dateFormatter.string(from: date)
//            }
//        case "day":
//            dateFormatter.dateFormat = "yyyy-MM-dd"
//            if let date = dateFormatter.date(from: release_date) {
//                dateFormatter.dateFormat = "d MMM yyyy"; return dateFormatter.string(from: date)
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
//    var previewURL: URL? { if let url = preview_url { return URL(string: url)} else {return nil} }
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
//// MARK: - API Service (Unchanged, uses placeholder token)
//
//// IMPORTANT: Replace this with your actual Spotify Bearer Token
//let placeholderSpotifyToken = "YOUR_SPOTIFY_BEARER_TOKEN_HERE"
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
//        case .invalidURL: return "Invalid API URL setup."
//        case .networkError(let error): return "Network connection issue: \(error.localizedDescription)"
//        case .invalidResponse(let code, _): return "Server error (\(code)). Please try again later."
//        case .decodingError: return "Failed to understand server response."
//        case .invalidToken: return "Authentication failed. Check API Token."
//        case .missingData: return "Response missing expected data."
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
//            print("🚫 Error: Spotify Bearer Token is missing or placeholder.")
//            throw SpotifyAPIError.invalidToken
//        }
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//        request.setValue("Bearer \(placeholderSpotifyToken)", forHTTPHeaderField: "Authorization")
//        request.setValue("application/json", forHTTPHeaderField: "Accept")
//        request.timeoutInterval = 20
//
//        print("🎶 Requesting: \(url.absoluteString)")
//
//        do {
//            let (data, response) = try await session.data(for: request)
//            guard let httpResponse = response as? HTTPURLResponse else { throw SpotifyAPIError.invalidResponse(0, "Not HTTP response.") }
//
//            print("🚦 HTTP Status: \(httpResponse.statusCode)")
//            let responseBody = String(data: data, encoding: .utf8) ?? "N/A"
//
//            guard (200...299).contains(httpResponse.statusCode) else {
//                if httpResponse.statusCode == 401 { throw SpotifyAPIError.invalidToken }
//                print("❌ Server Error Body: \(responseBody)")
//                throw SpotifyAPIError.invalidResponse(httpResponse.statusCode, responseBody)
//            }
//            do {
//                let decoder = JSONDecoder()
//                return try decoder.decode(T.self, from: data)
//            } catch {
//                print("❌ Decoding Error for \(T.self): \(error)")
//                print("   Response Body: \(responseBody)")
//                throw SpotifyAPIError.decodingError(error)
//            }
//        } catch let error where !(error is CancellationError) {
//            print("❌ Network Error: \(error)")
//            throw error is SpotifyAPIError ? error : SpotifyAPIError.networkError(error)
//        }
//    }
//
//    func searchAlbums(query: String, limit: Int = 20, offset: Int = 0) async throws -> SpotifySearchResponse {
//        var components = URLComponents(string: "https://api.spotify.com/v1/search")
//        components?.queryItems = [
//            URLQueryItem(name: "q", value: query), URLQueryItem(name: "type", value: "album"),
//            URLQueryItem(name: "include_external", value: "audio"), URLQueryItem(name: "limit", value: "\(limit)"),
//            URLQueryItem(name: "offset", value: "\(offset)")
//        ]
//        guard let url = components?.url else { throw SpotifyAPIError.invalidURL }
//        return try await makeRequest(url: url)
//    }
//
//    func getAlbumTracks(albumId: String, limit: Int = 50, offset: Int = 0) async throws -> AlbumTracksResponse {
//        var components = URLComponents(string: "https://api.spotify.com/v1/albums/\(albumId)/tracks")
//        components?.queryItems = [ URLQueryItem(name: "limit", value: "\(limit)"), URLQueryItem(name: "offset", value: "\(offset)") ]
//        guard let url = components?.url else { throw SpotifyAPIError.invalidURL }
//        return try await makeRequest(url: url)
//    }
//}
//
//// MARK: - Spotify Embed WebView (Themed consistency adjustments)
//
//final class SpotifyPlaybackState: ObservableObject {
//    @Published var isPlaying: Bool = false
//    @Published var currentPosition: Double = 0
//    @Published var duration: Double = 0
//    @Published var currentUri: String = ""
//    @Published var isReady: Bool = false
//    @Published var error: String? = nil
//}
//
//struct SpotifyEmbedWebView: UIViewRepresentable {
//    @ObservedObject var playbackState: SpotifyPlaybackState
//    let spotifyUri: String?
//
//    func makeCoordinator() -> Coordinator { Coordinator(self) }
//
//    func makeUIView(context: Context) -> WKWebView {
//        let userContentController = WKUserContentController()
//        userContentController.add(context.coordinator, name: "spotifyController")
//
//        let configuration = WKWebViewConfiguration()
//        configuration.userContentController = userContentController
//        configuration.allowsInlineMediaPlayback = true
//        configuration.mediaTypesRequiringUserActionForPlayback = []
//
//        /// Applying theme transparency
//        let webView = WKWebView(frame: .zero, configuration: configuration)
//        webView.navigationDelegate = context.coordinator
//        webView.uiDelegate = context.coordinator
//        webView.isOpaque = false // Crucial for SwiftUI background to show through
//        webView.backgroundColor = .clear // Match theme background transparency
//        webView.scrollView.backgroundColor = .clear // Ensure scroll view is also transparent
//        webView.scrollView.isScrollEnabled = false
//
//        webView.loadHTMLString(generateHTML(), baseURL: nil)
//        context.coordinator.webView = webView
//        return webView
//    }
//
//    func updateUIView(_ webView: WKWebView, context: Context) {
//        print("🔄 Spotify Embed WebView: updateUIView called. API Ready: \(context.coordinator.isApiReady), Last/Current URI: \(context.coordinator.lastLoadedUri ?? "nil") / \(spotifyUri ?? "nil")")
//        if context.coordinator.isApiReady && context.coordinator.lastLoadedUri != spotifyUri {
//            print(" -> Loading URI in updateUIView.")
//            context.coordinator.loadUri(spotifyUri ?? "")
//        } else if !context.coordinator.isApiReady {
//            context.coordinator.updateDesiredUriBeforeReady(spotifyUri ?? "")
//        }
//    }
//
//    static func dismantleUIView(_ webView: WKWebView, coordinator: Coordinator) {
//        print("🧹 Spotify Embed WebView: Dismantling.")
//        webView.stopLoading()
//        webView.configuration.userContentController.removeScriptMessageHandler(forName: "spotifyController")
//        coordinator.webView = nil
//    }
//
//    // MARK: Coordinator
//    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
//        var parent: SpotifyEmbedWebView
//        weak var webView: WKWebView?
//        var isApiReady = false
//        var lastLoadedUri: String?
//        private var desiredUriBeforeReady: String? = nil
//
//        init(_ parent: SpotifyEmbedWebView) { self.parent = parent }
//
//        func updateDesiredUriBeforeReady(_ uri: String?) {
//            if !isApiReady {
//                desiredUriBeforeReady = uri
//                print("📥 Spotify Embed Coordinator: Storing desired URI before ready: \(uri ?? "nil")")
//            }
//        }
//
//        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//             print("📄 Spotify Embed WebView: HTML content finished loading.")
//             // Inject CSS to hide potential default white background flashes from iframe
//             let css = "body { background-color: transparent !important; }"
//             let js = "var style = document.createElement('style'); style.innerHTML = '\(css)'; document.head.appendChild(style);"
//             webView.evaluateJavaScript(js)
//        }
//
//        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
//            print("❌ Spotify Embed WebView: Navigation failed: \(error.localizedDescription)")
//            DispatchQueue.main.async { self.parent.playbackState.error = "WebView Navigation Failed: \(error.localizedDescription)" }
//        }
//
//        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
//            print("❌ Spotify Embed WebView: Provisional navigation failed: \(error.localizedDescription)")
//            DispatchQueue.main.async { self.parent.playbackState.error = "WebView Provisional Navigation Failed: \(error.localizedDescription)" }
//        }
//
//        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
//            guard message.name == "spotifyController" else { return }
//            if let bodyDict = message.body as? [String: Any], let event = bodyDict["event"] as? String {
//                print("📩 JS Event: '\(event)' Data: \(bodyDict["data"] ?? "nil")")
//                handleEvent(event: event, data: bodyDict["data"])
//            } else if let bodyString = message.body as? String {
//                print("📩 JS Message: '\(bodyString)'")
//                if bodyString == "ready" { handleApiReady() }
//                else { print("❓ Spotify Embed Native: Unknown JS string message: \(bodyString)") }
//            } else { print("❓ Spotify Embed Native: Unknown JS message format: \(message.body)") }
//        }
//
//        private func handleApiReady() {
//            print("✅ Spotify Embed Native: Spotify IFrame API reported READY.")
//            isApiReady = true
//            DispatchQueue.main.async { self.parent.playbackState.isReady = true }
//            if let initialUri = desiredUriBeforeReady ?? parent.spotifyUri {
//                createSpotifyController(with: initialUri)
//                desiredUriBeforeReady = nil
//             } else { print("⚠️ Spotify Embed Native: API Ready, but no initial URI.") }
//        }
//
//        private func handleEvent(event: String, data: Any?) {
//            switch event {
//            case "controllerCreated": print("✅ Spotify Embed Native: Embed controller created.")
//            case "playbackUpdate": if let updateData = data as? [String: Any] { updatePlaybackState(with: updateData) }
//            case "error":
//                let errMsg = (data as? [String: Any])?["message"] as? String ?? (data as? String) ?? "Unknown JS error"
//                print("❌ Spotify Embed JS Error: \(errMsg)")
//                DispatchQueue.main.async { self.parent.playbackState.error = errMsg }
//            default: print("❓ Spotify Embed Native: Received unknown event type: \(event)")
//            }
//        }
//
//        private func updatePlaybackState(with data: [String: Any]) {
//            DispatchQueue.main.async { [weak self] in
//                guard let self = self else { return }
//                var stateChanged = false
//                if let isPaused = data["paused"] as? Bool, self.parent.playbackState.isPlaying == isPaused {
//                    self.parent.playbackState.isPlaying = !isPaused; stateChanged = true
//                }
//                if let posMs = data["position"] as? Double, abs(self.parent.playbackState.currentPosition - (posMs / 1000.0)) > 0.1 {
//                    self.parent.playbackState.currentPosition = posMs / 1000.0; stateChanged = true
//                }
//                if let durMs = data["duration"] as? Double, abs(self.parent.playbackState.duration - (durMs / 1000.0)) > 0.1 || self.parent.playbackState.duration == 0 {
//                    self.parent.playbackState.duration = durMs / 1000.0; stateChanged = true
//                }
//                if let uri = data["uri"] as? String, self.parent.playbackState.currentUri != uri {
//                    self.parent.playbackState.currentUri = uri
//                    self.parent.playbackState.currentPosition = 0
//                    self.parent.playbackState.duration = data["duration"] as? Double ?? 0
//                    stateChanged = true
//                }
//                if stateChanged && self.parent.playbackState.error != nil { self.parent.playbackState.error = nil }
//            }
//        }
//
//        private func createSpotifyController(with initialUri: String) {
//            guard let webView = webView, isApiReady else { print("⚠️ Spotify Embed Native: Cannot create controller - WebView/API not ready."); return }
//            guard lastLoadedUri == nil else {
//                print("ℹ️ Spotify Embed Native: Controller already initialized. Desired URI: \(initialUri)")
//                if let latestDesired = desiredUriBeforeReady ?? parent.spotifyUri, latestDesired != lastLoadedUri {
//                    print(" -> Correcting URI before loading: \(latestDesired)")
//                    loadUri(latestDesired)
//                }
//                desiredUriBeforeReady = nil
//                return
//            }
//            print("🚀 Spotify Embed Native: Attempting controller creation for URI: \(initialUri)")
//            lastLoadedUri = initialUri
//            let script = getCreateControllerScript(uri: initialUri)
//            webView.evaluateJavaScript(script) { _, error in if let error = error { print("⚠️ Error evaluating JS for controller creation: \(error.localizedDescription)") } }
//        }
//
//        func loadUri(_ uri: String) {
//            guard let webView = webView, isApiReady else { return }
//            guard lastLoadedUri != uri else { print("ℹ️ Spotify Embed Native: Skipping loadUri - URI unchanged (\(uri))."); return }
//            print("🚀 Spotify Embed Native: Loading new URI via JS: \(uri)")
//            lastLoadedUri = uri
//            let script = getLoadUriScript(uri: uri)
//            webView.evaluateJavaScript(script) { _, error in if let error = error { print("⚠️ Error evaluating JS load URI \(uri): \(error.localizedDescription)") } }
//        }
//
//        // Helper for JS Scripts
//        private func getCreateControllerScript(uri: String) -> String {
//             return """
//             console.log('Spotify Embed JS: Running create controller script.');
//             window.embedController = null; // Clear old reference
//             const element = document.getElementById('embed-iframe');
//             if (!element) { console.error('JS Error: #embed-iframe not found!'); window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'HTML element embed-iframe not found' }}); }
//             else if (!window.IFrameAPI) { console.error('JS Error: IFrameAPI not loaded!'); window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'Spotify IFrame API not loaded' }}); }
//             else {
//                 console.log('JS: Found element and API. Creating controller for: \(uri)');
//                 const options = { uri: '\(uri)', width: '100%', height: '100%', theme: 'dark' }; // Force 'dark' theme for iframe
//                 const callback = (controller) => {
//                     if (!controller) { console.error('JS Error: createController callback received null!'); window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'JS callback received null controller' }}); return; }
//                     console.log('✅ JS: Controller instance received.');
//                     window.embedController = controller;
//                     window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'controllerCreated' });
//                     controller.addListener('ready', () => { console.log('🎧 JS Event: Controller Ready.'); });
//                     controller.addListener('playback_update', e => { window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'playbackUpdate', data: e.data }); });
//                     controller.addListener('account_error', e => { console.warn('💰 JS Event: Account Error:', e.data); window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'Account Error: ' + (e.data?.message ?? 'Premium/Login Required') }}); });
//                     controller.addListener('autoplay_failed', () => { console.warn('⏯️ JS Event: Autoplay failed'); window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'Autoplay Failed' }}); controller.play(); });
//                     controller.addListener('initialization_error', e => { console.error('💥 JS Event: Init Error:', e.data); window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'Initialization Error: ' + (e.data?.message ?? 'Failed to init player') }}); });
//                 };
//                 try {
//                     console.log('JS: Calling IFrameAPI.createController...');
//                     window.IFrameAPI.createController(element, options, callback);
//                 } catch (e) {
//                     console.error('💥 JS Exception during createController:', e);
//                     window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'JS Exception: ' + e.message }});
//                     lastLoadedUri = nil; // Reset on fundamental failure
//                 }
//             }
//             """
//        }
//
//        private func getLoadUriScript(uri: String) -> String {
//            return """
//            if (window.embedController) { console.log('JS: Loading URI: \(uri)'); window.embedController.loadUri('\(uri)'); window.embedController.play(); }
//            else { console.error('JS Error: embedController not found for loadUri \(uri).'); window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'JS embedController missing during loadUri' }}); }
//            """
//        }
//
//        func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
//            print("ℹ️ Spotify Embed Received JS Alert: \(message)")
//            completionHandler()
//        }
//    }
//
//    // MARK: HTML Generation
//    private func generateHTML() -> String {
//        return """
//        <!DOCTYPE html><html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no"><title>Spotify Embed</title><style>html, body { margin: 0; padding: 0; width: 100%; height: 100%; overflow: hidden; background-color: transparent !important; } #embed-iframe { width: 100%; height: 100%; box-sizing: border-box; display: block; border: none; }</style></head><body><div id="embed-iframe"></div><script src="https://open.spotify.com/embed/iframe-api/v1" async></script><script> console.log('Spotify Embed JS: Initial script.'); var apiReadyCallbackDone = false; window.onSpotifyIframeApiReady = (IFrameAPI) => { if (apiReadyCallbackDone) return; console.log('✅ Spotify Embed JS: API Ready.'); window.IFrameAPI = IFrameAPI; apiReadyCallbackDone = true; if (window.webkit?.messageHandlers?.spotifyController) { window.webkit.messageHandlers.spotifyController.postMessage("ready"); } else { console.error('❌ JS: Native message handler (spotifyController) not found!'); } }; const scriptTag = document.querySelector('script[src*="iframe-api"]'); if (scriptTag) { scriptTag.onerror = (evt) => { console.error('❌ JS: Failed to load Spotify API script:', evt); window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'Failed to load Spotify API script' }}); }; } else { console.warn('⚠️ JS: Could not find API script tag.'); } </script></body></html>
//        """
//    }
//}
//
//// MARK: - SwiftUI Views (Deep Black Neumorphism Themed)
//
//// MARK: Main List View
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
//                DeepBlackNeumorphicTheme.background.ignoresSafeArea() // Use the new deep black
//
//                VStack(spacing: 0) {
//                    Group { // Use Group for cleaner conditional logic
//                        if isLoading && displayedAlbums.isEmpty { loadingIndicator }
//                        else if let error = currentError { ErrorPlaceholderView(error: error) { Task { await performDebouncedSearch(immediate: true) } } }
//                        else if displayedAlbums.isEmpty && !searchQuery.isEmpty { EmptyStatePlaceholderView(searchQuery: searchQuery) }
//                        else if displayedAlbums.isEmpty && searchQuery.isEmpty { EmptyStatePlaceholderView(searchQuery: "") }
//                        else { albumScrollView }
//                    }
//                    .frame(maxWidth: .infinity, maxHeight: .infinity) // Ensure placeholders fill space
//                }
//            }
//            .navigationTitle("Spotify Search")
//            .navigationBarTitleDisplayMode(.large)
//            .searchable(text: $searchQuery, placement: .navigationBarDrawer(displayMode: .always), prompt: Text("Search Albums / Artists").foregroundColor(.gray))
//            .onSubmit(of: .search) { Task { await performDebouncedSearch(immediate: true) } }
//            .onChange(of: searchQuery) { _ in // Use _ if newValue isn't needed directly
//                 Task { await performDebouncedSearch() } // Standard debounce on change
//                 if currentError != nil { currentError = nil } // Clear error on new typing
//             }
//             .accentColor(DeepBlackNeumorphicTheme.accentColor) // For search bar elements
//        }
//        .navigationViewStyle(.stack)
//        .preferredColorScheme(.dark) // Reinforce dark mode preference
//    }
//
//    // --- Themed Album List ---
//    private var albumScrollView: some View {
//        ScrollView {
//            LazyVStack(spacing: 20) { // Slightly more spacing between cards
//                if let info = searchInfo, info.total > 0 {
//                    SearchMetadataHeader(totalResults: info.total, limit: info.limit, offset: info.offset)
//                        .padding(.horizontal)
//                        .padding(.top, 8)
//                }
//
//                ForEach(displayedAlbums) { album in
//                    NavigationLink(destination: AlbumDetailView(album: album)) {
//                        NeumorphicAlbumCard(album: album)
//                    }
//                    .buttonStyle(.plain)
//                }
//            }
//            .padding(.horizontal)
//            .padding(.bottom)
//        }
//        .scrollDismissesKeyboard(.interactively)
//    }
//
//    // --- Themed Loading Indicator ---
//    private var loadingIndicator: some View {
//        VStack(spacing: 12) {
//            ProgressView()
//                .progressViewStyle(CircularProgressViewStyle(tint: DeepBlackNeumorphicTheme.accentColor))
//                .scaleEffect(1.5)
//            Text("Loading...")
//                .font(neumorphicFont(size: 14))
//                .foregroundColor(DeepBlackNeumorphicTheme.secondaryText)
//        }
//    }
//
//    // --- Debounced Search Logic (Unchanged) ---
//     private func performDebouncedSearch(immediate: Bool = false) async {
//         let trimmedQuery = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
//         guard !trimmedQuery.isEmpty else {
//             await MainActor.run { displayedAlbums = []; searchInfo = nil; isLoading = false; currentError = nil }
//             return
//         }
//
//         await MainActor.run { isLoading = true; currentError = nil } // Show loading, clear previous error
//
//         if !immediate {
//             do { try await Task.sleep(for: .milliseconds(500)); try Task.checkCancellation() }
//             catch { print("Search task cancelled (debounce)."); await MainActor.run { isLoading = false }; return }
//         }
//
//         // Re-check query after potential delay
//         guard trimmedQuery == searchQuery.trimmingCharacters(in: .whitespacesAndNewlines) else {
//              print("Search query changed during debounce."); await MainActor.run { isLoading = false }; return
//         }
//
//         do {
//             print("🚀 Performing search for: \(trimmedQuery)")
//             let response = try await SpotifyAPIService.shared.searchAlbums(query: trimmedQuery, limit: 20, offset: 0)
//             try Task.checkCancellation()
//             await MainActor.run {
//                 displayedAlbums = response.albums.items
//                 searchInfo = response.albums
//                 isLoading = false
//                 print("✅ Search successful, \(response.albums.items.count) items.")
//             }
//         } catch is CancellationError { await MainActor.run { isLoading = false } }
//           catch let apiError as SpotifyAPIError { await MainActor.run { displayedAlbums = []; searchInfo = nil; currentError = apiError; isLoading = false } }
//           catch { await MainActor.run { displayedAlbums = []; searchInfo = nil; currentError = .networkError(error); isLoading = false } }
//    }
//}
//
//// MARK: Neumorphic Album Card
//struct NeumorphicAlbumCard: View {
//    let album: AlbumItem
//    private let cardCornerRadius: CGFloat = 20
//    private let imageCornerRadius: CGFloat = 12
//
//    var body: some View {
//        HStack(spacing: 15) {
//            AlbumImageView(url: album.listImageURL)
//                .frame(width: 80, height: 80)
//                .clipShape(RoundedRectangle(cornerRadius: imageCornerRadius))
//                .overlay(RoundedRectangle(cornerRadius: imageCornerRadius).stroke(DeepBlackNeumorphicTheme.elementBackground.opacity(0.3), lineWidth: 1)) // Subtle edge
//
//            VStack(alignment: .leading, spacing: 4) {
//                Text(album.name)
//                    .font(neumorphicFont(size: 15, weight: .semibold))
//                    .foregroundColor(DeepBlackNeumorphicTheme.primaryText)
//                    .lineLimit(2)
//
//                Text(album.formattedArtists)
//                    .font(neumorphicFont(size: 13))
//                    .foregroundColor(DeepBlackNeumorphicTheme.secondaryText)
//                    .lineLimit(1)
//
//                Spacer()
//
//                HStack(spacing: 8) {
//                     Text(album.album_type.capitalized)
//                         .font(neumorphicFont(size: 10, weight: .medium))
//                         .foregroundColor(DeepBlackNeumorphicTheme.secondaryText)
//                         .padding(.horizontal, 8).padding(.vertical, 3)
//                          /// Use a subtle background matching the main background for the tag
//                         .background(DeepBlackNeumorphicTheme.background.opacity(0.7), in: Capsule())
//
//                     Text("• \(album.formattedReleaseDate())")
//                         .font(neumorphicFont(size: 10, weight: .medium))
//                         .foregroundColor(DeepBlackNeumorphicTheme.secondaryText)
//                }
//                Text("\(album.total_tracks) Tracks")
//                    .font(neumorphicFont(size: 10, weight: .medium))
//                    .foregroundColor(DeepBlackNeumorphicTheme.secondaryText)
//                    .padding(.top, 1)
//            }
//            .frame(maxWidth: .infinity, alignment: .leading)
//        }
//        .padding(15)
//        .modifier(NeumorphicOuterShadow()) // Apply effect to the card background
//        .frame(height: 110)
//    }
//}
//
//// MARK: Placeholders (Deep Black Themed)
//struct ErrorPlaceholderView: View {
//    let error: SpotifyAPIError
//    let retryAction: (() -> Void)?
//    private let iconSize: CGFloat = 60
//
//    var body: some View {
//        VStack(spacing: 20) {
//            Image(systemName: iconName)
//                .font(.system(size: iconSize * 0.8)) // Adjust icon size relative to container
//                .foregroundColor(DeepBlackNeumorphicTheme.errorColor)
//                .frame(width: iconSize + 30, height: iconSize + 30) // Make container larger
//                .background(
//                    Circle()
//                        .fill(DeepBlackNeumorphicTheme.elementBackground)
//                         .shadow(color: DeepBlackNeumorphicTheme.darkShadow, radius: 8, x: 5, y: 5)
//                         .shadow(color: DeepBlackNeumorphicTheme.lightShadow, radius: 8, x: -5, y: -5)
//                )
//                .padding(.bottom, 15)
//
//            Text("Error")
//                .font(neumorphicFont(size: 20, weight: .bold))
//                .foregroundColor(DeepBlackNeumorphicTheme.primaryText)
//
//            Text(errorMessage)
//                .font(neumorphicFont(size: 14))
//                .foregroundColor(DeepBlackNeumorphicTheme.secondaryText)
//                .multilineTextAlignment(.center)
//                .padding(.horizontal, 30)
//
//            // --- Retry Button or Token Message ---
//            switch error {
//            case .invalidToken:
//                Text("Please check the API token\nin the code and restart.")
//                    .font(neumorphicFont(size: 13))
//                    .foregroundColor(DeepBlackNeumorphicTheme.errorColor.opacity(0.8))
//                    .multilineTextAlignment(.center)
//                    .padding(.horizontal, 30)
//                    .padding(.top, 10)
//            default:
//                if let action = retryAction {
//                    ThemedNeumorphicButton(text: "Retry", iconName: "arrow.clockwise", action: action)
//                        .padding(.top, 10)
//                }
//            }
//        }
//        .padding(40)
//    }
//
//    // --- Helpers ---
//     private var iconName: String {
//         switch error {
//         case .invalidToken: return "key.slash"
//         case .networkError: return "wifi.exclamationmark" // More specific network error icon
//         case .invalidResponse, .decodingError, .missingData: return "exclamationmark.triangle"
//         case .invalidURL: return "link.badge.questionmark"
//         }
//     }
//     private var errorMessage: String { error.localizedDescription }
//}
//
//struct EmptyStatePlaceholderView: View {
//    let searchQuery: String
//
//    var body: some View {
//        VStack(spacing: 20) {
//             Image(placeholderImageName)
//                 .resizable().scaledToFit().frame(height: 130)
//                 .padding(isInitialState ? 25 : 15)
//                 .background(Circle().fill(DeepBlackNeumorphicTheme.elementBackground)
//                             .shadow(color: DeepBlackNeumorphicTheme.darkShadow, radius: 8, x: 5, y: 5)
//                             .shadow(color: DeepBlackNeumorphicTheme.lightShadow, radius: 8, x: -5, y: -5))
//                 .padding(.bottom, 15)
//
//            Text(title).font(neumorphicFont(size: 20, weight: .bold)).foregroundColor(DeepBlackNeumorphicTheme.primaryText)
//            Text(messageAttributedString).font(neumorphicFont(size: 14)).foregroundColor(DeepBlackNeumorphicTheme.secondaryText)
//                .multilineTextAlignment(.center).padding(.horizontal, 40)
//        }
//        .padding(30)
//    }
//
//    // --- Helpers ---
//    private var isInitialState: Bool { searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
//    private var placeholderImageName: String { isInitialState ? "My-meme-microphone" : "My-meme-orange_2" }
//    private var title: String { isInitialState ? "Spotify Search" : "No Results Found" }
//    private var messageAttributedString: AttributedString {
//        // Using previous logic, but ensuring styling matches the theme
//        let messageText = isInitialState ? "Enter an album or artist name\nin the search bar to begin." : "No matches found for \"\(searchQuery.sanitizedForAttributedString())\".\nTry refining your search terms."
//        var attributedString = AttributedString(messageText)
//        attributedString.font = neumorphicFont(size: 14)
//        attributedString.foregroundColor = DeepBlackNeumorphicTheme.secondaryText
//        // Optional: Highlight search query
//         if !isInitialState, let range = attributedString.range(of: "\"\(searchQuery.sanitizedForAttributedString())\"") {
//              attributedString[range].foregroundColor = DeepBlackNeumorphicTheme.primaryText.opacity(0.9)
//              // attributedString[range].font = neumorphicFont(size: 14, weight: .semibold) // Optional bolding
//         }
//        return attributedString
//    }
//}
//
//// Helper to sanitize string for AttributedString/Markdown-like interpretation
//extension String {
//    func sanitizedForAttributedString() -> String {
//        self.replacingOccurrences(of: "*", with: "")
//            .replacingOccurrences(of: "_", with: "")
//            .replacingOccurrences(of: "`", with: "")
//    }
//}
//
//// MARK: Album Detail View
//struct AlbumDetailView: View {
//    let album: AlbumItem
//    @State private var tracks: [Track] = []
//    @State private var isLoadingTracks: Bool = false
//    @State private var trackFetchError: SpotifyAPIError? = nil
//    @State private var selectedTrackUri: String? = nil
//    @StateObject private var playbackState = SpotifyPlaybackState()
//
//    var body: some View {
//        ZStack {
//            DeepBlackNeumorphicTheme.background.ignoresSafeArea()
//
//            ScrollView {
//                VStack(spacing: 0) {
//                    AlbumHeaderView(album: album)
//                        .padding(.top, 10).padding(.bottom, 25)
//
//                    if selectedTrackUri != nil {
//                        SpotifyEmbedPlayerView(playbackState: playbackState, spotifyUri: selectedTrackUri)
//                            .padding(.horizontal).padding(.bottom, 25)
//                            .transition(.opacity.combined(with: .scale(scale: 0.95, anchor: .top)))
//                            .animation(.easeInOut(duration: 0.3), value: selectedTrackUri)
//                    }
//
//                    TracksSectionView(
//                        tracks: tracks, isLoading: isLoadingTracks, error: trackFetchError,
//                        selectedTrackUri: $selectedTrackUri,
//                        retryAction: { Task { await fetchTracks() } }
//                    )
//                    .padding(.bottom, 25)
//
//                    if let spotifyURL = URL(string: album.external_urls.spotify ?? "") {
//                        ExternalLinkButton(url: spotifyURL)
//                            .padding(.horizontal).padding(.bottom, 30)
//                    }
//                }
//            }
//        }
//        .navigationTitle(album.name)
//        .navigationBarTitleDisplayMode(.inline)
//        .toolbarBackground(DeepBlackNeumorphicTheme.elementBackground, for: .navigationBar)
//        .toolbarBackground(.visible, for: .navigationBar)
//        .toolbarColorScheme(.dark, for: .navigationBar) // Ensures nav item colors are light
//        .task { await fetchTracks() }
//    }
//
//    // --- Fetch Tracks Logic (Unchanged) ---
//     private func fetchTracks(forceReload: Bool = false) async {
//         guard forceReload || tracks.isEmpty || trackFetchError != nil else { return }
//         await MainActor.run { isLoadingTracks = true; trackFetchError = nil }
//         do {
//             let response = try await SpotifyAPIService.shared.getAlbumTracks(albumId: album.id)
//             try Task.checkCancellation()
//             await MainActor.run { self.tracks = response.items; self.isLoadingTracks = false }
//         } catch is CancellationError { await MainActor.run { isLoadingTracks = false } }
//           catch let apiError as SpotifyAPIError { await MainActor.run { self.trackFetchError = apiError; self.isLoadingTracks = false; self.tracks = [] } }
//           catch { await MainActor.run { self.trackFetchError = .networkError(error); self.isLoadingTracks = false; self.tracks = [] } }
//     }
//}
//
//// MARK: Detail View Sub-Components (Themed)
//
//struct AlbumHeaderView: View {
//    let album: AlbumItem
//    private let imageCornerRadius: CGFloat = 25
//
//    var body: some View {
//        VStack(spacing: 15) {
//            AlbumImageView(url: album.bestImageURL)
//                .aspectRatio(1.0, contentMode: .fit)
//                .clipShape(RoundedRectangle(cornerRadius: imageCornerRadius))
//                .background(
//                     RoundedRectangle(cornerRadius: imageCornerRadius)
//                         .fill(DeepBlackNeumorphicTheme.elementBackground)
//                         .shadow(color: DeepBlackNeumorphicTheme.darkShadow, radius: 12, x: 8, y: 8) // Slightly larger shadow for header image
//                         .shadow(color: DeepBlackNeumorphicTheme.lightShadow, radius: 12, x: -8, y: -8)
//                 )
//                .padding(.horizontal, 40)
//
//            VStack(spacing: 4) {
//                Text(album.name).font(neumorphicFont(size: 20, weight: .bold)).foregroundColor(DeepBlackNeumorphicTheme.primaryText).multilineTextAlignment(.center)
//                Text("by \(album.formattedArtists)").font(neumorphicFont(size: 15)).foregroundColor(DeepBlackNeumorphicTheme.secondaryText).multilineTextAlignment(.center)
//                Text("\(album.album_type.capitalized) • \(album.formattedReleaseDate())")
//                    .font(neumorphicFont(size: 12, weight: .medium)).foregroundColor(DeepBlackNeumorphicTheme.secondaryText.opacity(0.8))
//            }
//            .padding(.horizontal)
//        }
//    }
//}
//
//struct SpotifyEmbedPlayerView: View {
//    @ObservedObject var playbackState: SpotifyPlaybackState
//    let spotifyUri: String?
//    private let playerCornerRadius: CGFloat = 15
//
//    var body: some View {
//        VStack(spacing: 8) {
//            SpotifyEmbedWebView(playbackState: playbackState, spotifyUri: spotifyUri)
//                .frame(height: 80)
//                .clipShape(RoundedRectangle(cornerRadius: playerCornerRadius))
//                .disabled(!playbackState.isReady)
//                .overlay( webViewOverlay ) // Use helper for overlay content
//                .background(
//                    RoundedRectangle(cornerRadius: playerCornerRadius)
//                        .fill(DeepBlackNeumorphicTheme.elementBackground)
//                         .shadow(color: DeepBlackNeumorphicTheme.darkShadow, radius: 6, x: 4, y: 4) // Adjusted shadow for player depth
//                         .shadow(color: DeepBlackNeumorphicTheme.lightShadow, radius: 6, x: -4, y: -4)
//                )
//
//            // --- Playback Status ---
//            playbackStatusText
//                .padding(.horizontal, 8)
//                .frame(height: 15)
//
//        }
//    }
//
//    // --- Overlay for Loading/Error ---
//    @ViewBuilder private var webViewOverlay: some View {
//        if !playbackState.isReady {
//            ProgressView().tint(DeepBlackNeumorphicTheme.accentColor)
//        } else if let error = playbackState.error, !error.isEmpty {
//             VStack {
//                 Image(systemName: "exclamationmark.triangle").foregroundColor(DeepBlackNeumorphicTheme.errorColor)
//                 Text(error).font(.caption).foregroundColor(DeepBlackNeumorphicTheme.errorColor).lineLimit(1)
//             }.padding(5)
//        }
//    }
//
//    // --- Playback Status Text View ---
//    private var playbackStatusText: some View {
//         HStack {
//             if let error = playbackState.error, !error.isEmpty {
//                  Text("Error: \(error)").font(neumorphicFont(size: 10, weight: .medium))
//                      .foregroundColor(DeepBlackNeumorphicTheme.errorColor).lineLimit(1).frame(maxWidth: .infinity, alignment: .leading)
//              } else if !playbackState.isReady {
//                  Text("Loading Player...").font(neumorphicFont(size: 10, weight: .medium))
//                     .foregroundColor(DeepBlackNeumorphicTheme.secondaryText).frame(maxWidth: .infinity, alignment: .leading)
//             } else if playbackState.duration > 0.1 {
//                 Text(playbackState.isPlaying ? "Playing" : "Paused").font(neumorphicFont(size: 10, weight: .medium))
//                     .foregroundColor(playbackState.isPlaying ? DeepBlackNeumorphicTheme.accentColor : DeepBlackNeumorphicTheme.secondaryText)
//                 Spacer()
//                 Text("\(formatTime(playbackState.currentPosition)) / \(formatTime(playbackState.duration))")
//                     .font(neumorphicFont(size: 10, weight: .medium)).foregroundColor(DeepBlackNeumorphicTheme.secondaryText).frame(width: 90, alignment: .trailing)
//             } else {
//                  Text("Ready").font(neumorphicFont(size: 10, weight: .medium))
//                     .foregroundColor(DeepBlackNeumorphicTheme.secondaryText).frame(maxWidth: .infinity, alignment: .leading)
//              }
//         }
//    }
//
//    private func formatTime(_ time: Double) -> String { /* Unchanged */
//        let totalSeconds = max(0, Int(time)); let minutes = totalSeconds / 60; let seconds = totalSeconds % 60
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
//    private let sectionCornerRadius: CGFloat = 20
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 0) {
//             Text("Tracks").font(neumorphicFont(size: 16, weight: .semibold)).foregroundColor(DeepBlackNeumorphicTheme.primaryText)
//                 .padding(.horizontal).padding(.bottom, 10)
//
//             // --- Tracks Background Container ---
//             Group {
//                 if isLoading { loadingView }
//                 else if let error = error { ErrorPlaceholderView(error: error, retryAction: retryAction).padding(.vertical, 20) }
//                 else if tracks.isEmpty { emptyTracksView }
//                 else { tracksListView }
//             }
//             .padding(10) // Padding *inside* the neumorphic container
//             .background( // Apply neumorphic styling to the container
//                 RoundedRectangle(cornerRadius: sectionCornerRadius)
//                      .fill(DeepBlackNeumorphicTheme.elementBackground)
//                      .shadow(color: DeepBlackNeumorphicTheme.darkShadow, radius: 6, x: 4, y: 4)
//                      .shadow(color: DeepBlackNeumorphicTheme.lightShadow, radius: 6, x: -4, y: -4)
//             )
//             .padding(.horizontal) // Padding *outside* the neumorphic container
//        }
//    }
//
//     // --- Sub-views for clarity ---
//     private var loadingView: some View {
//         HStack { Spacer(); ProgressView().tint(DeepBlackNeumorphicTheme.accentColor)
//              Text("Loading Tracks...").font(neumorphicFont(size: 14)).foregroundColor(DeepBlackNeumorphicTheme.secondaryText); Spacer()
//         }.padding(.vertical, 30)
//     }
//
//     private var emptyTracksView: some View {
//          Text("No tracks found for this album.").font(neumorphicFont(size: 14)).foregroundColor(DeepBlackNeumorphicTheme.secondaryText)
//              .frame(maxWidth: .infinity, alignment: .center).padding(.vertical, 30)
//     }
//
//     private var tracksListView: some View {
//          VStack(spacing: 0) {
//              ForEach(tracks) { track in
//                   NeumorphicTrackRow(track: track, isSelected: track.uri == selectedTrackUri)
//                       .contentShape(Rectangle())
//                       .onTapGesture { selectedTrackUri = track.uri }
//                   // Optional: Subtle divider if needed
//                    Divider().background(DeepBlackNeumorphicTheme.background.opacity(0.4)).padding(.horizontal, 5)
//              }
//          }
//     }
//}
//
//struct NeumorphicTrackRow: View {
//    let track: Track
//    let isSelected: Bool
//
//    var body: some View {
//        HStack(spacing: 12) {
//             Text("\(track.track_number)").font(neumorphicFont(size: 12, weight: .medium))
//                 .foregroundColor(isSelected ? DeepBlackNeumorphicTheme.accentColor : DeepBlackNeumorphicTheme.secondaryText)
//                 .frame(width: 20, alignment: .center)
//
//             VStack(alignment: .leading, spacing: 2) {
//                 Text(track.name).font(neumorphicFont(size: 14, weight: .medium))
//                     .foregroundColor(isSelected ? DeepBlackNeumorphicTheme.primaryText : DeepBlackNeumorphicTheme.primaryText.opacity(0.9))
//                     .fontWeight(isSelected ? .semibold : .medium) // Slightly bolder selection
//                     .lineLimit(1)
//                 Text(track.formattedArtists).font(neumorphicFont(size: 11))
//                     .foregroundColor(DeepBlackNeumorphicTheme.secondaryText).lineLimit(1)
//             }
//
//             Spacer()
//
//             Text(track.formattedDuration).font(neumorphicFont(size: 12, weight: .medium))
//                 .foregroundColor(DeepBlackNeumorphicTheme.secondaryText).frame(width: 40, alignment: .trailing)
//
//             Image(systemName: isSelected ? "speaker.wave.2.fill" : "play")
//                 .font(.system(size: 12))
//                 .foregroundColor(isSelected ? DeepBlackNeumorphicTheme.accentColor : DeepBlackNeumorphicTheme.secondaryText.opacity(0.6))
//                 .frame(width: 20, alignment: .center)
//                 .animation(.easeInOut(duration: 0.2), value: isSelected)
//        }
//        .padding(.vertical, 10).padding(.horizontal, 5)
//        .background(isSelected ? DeepBlackNeumorphicTheme.accentColor.opacity(0.1) : Color.clear) // Subtle accent tint on selection
//        .cornerRadius(8)
//    }
//}
//
//// MARK: Other Supporting Views (Themed)
//
//struct AlbumImageView: View {
//    let url: URL?
//    private let placeholderCornerRadius: CGFloat = 8
//
//    var body: some View {
//        AsyncImage(url: url) { phase in
//            switch phase {
//            case .empty: placeholderView(content: ProgressView().tint(DeepBlackNeumorphicTheme.accentColor.opacity(0.7)))
//            case .success(let image): image.resizable().scaledToFit()
//            case .failure: placeholderView(content: Image(systemName: "photo").foregroundColor(DeepBlackNeumorphicTheme.secondaryText.opacity(0.5)))
//            @unknown default: EmptyView()
//            }
//        }
//    }
//
//    // Helper for consistent placeholder appearance
//    @ViewBuilder private func placeholderView<Content: View>(content: Content) -> some View {
//        ZStack {
//            RoundedRectangle(cornerRadius: placeholderCornerRadius)
//                .fill(DeepBlackNeumorphicTheme.elementBackground.opacity(0.7)) // Slightly translucent placeholder bg
//                 // Use softer shadows for placeholders
//                .shadow(color: DeepBlackNeumorphicTheme.darkShadow.opacity(0.4), radius: 4, x: 2, y: 2)
//                .shadow(color: DeepBlackNeumorphicTheme.lightShadow.opacity(0.1), radius: 4, x: -2, y: -2)
//            content.font(.system(size: 20)) // Adjust icon/progress size if needed
//        }
//    }
//}
//
//struct SearchMetadataHeader: View {
//    let totalResults: Int; let limit: Int; let offset: Int
//    var body: some View {
//         HStack {
//             Text("Results: \(totalResults)")
//             Spacer()
//             if totalResults > limit { Text("Showing: \(offset + 1)-\(min(offset + limit, totalResults))") }
//         }
//         .font(neumorphicFont(size: 11, weight: .medium)).foregroundColor(DeepBlackNeumorphicTheme.secondaryText)
//         .padding(.vertical, 5)
//    }
//}
//
//struct ThemedNeumorphicButton: View {
//    let text: String; var iconName: String? = nil; let action: () -> Void
//    var body: some View {
//        Button(action: action) {
//            HStack(spacing: 8) {
//                if let iconName = iconName { Image(systemName: iconName) }
//                Text(text)
//            }.font(neumorphicFont(size: 15, weight: .semibold))
//             .foregroundColor(DeepBlackNeumorphicTheme.accentColor)
//        }.buttonStyle(NeumorphicButtonStyle())
//    }
//}
//
//struct ExternalLinkButton: View {
//    let text: String = "Open in Spotify"; let url: URL; @Environment(\.openURL) var openURL
//    var body: some View {
//        ThemedNeumorphicButton(text: text, iconName: "arrow.up.forward.app") {
//             print("Opening external URL: \(url)")
//             openURL(url) { if !$0 { print("⚠️ Cannot open URL: \(url)") } }
//        }
//    }
//}
//
//// MARK: - Preview Providers (Using Deep Black Theme)
//
//struct SpotifyAlbumListView_Previews: PreviewProvider {
//    static var previews: some View {
//        SpotifyAlbumListView()
//            .preferredColorScheme(.dark) // Essential for EDR/Dark theme preview
//    }
//}
//
//struct NeumorphicAlbumCard_Previews: PreviewProvider {
//    static let mockArtist = Artist(id: "artist1", external_urls: nil, href: "", name: "Miles Davis Mock", type: "artist", uri: "")
//    static let mockImage = SpotifyImage(height: 300, url: "https://i.scdn.co/image/ab67616d00001e027ab89c25093ea3787b1995b4", width: 300)
//    static let mockAlbumItem = AlbumItem(id: "album1", album_type: "album", total_tracks: 5, available_markets: ["US"], external_urls: ExternalUrls(spotify: ""), href: "", images: [mockImage], name: "Kind of Blue [PREVIEW]", release_date: "1959-08-17", release_date_precision: "day", type: "album", uri: "spotify:album:1weenld61qoidwYuZ1GESA", artists: [mockArtist])
//
//    static var previews: some View {
//        NeumorphicAlbumCard(album: mockAlbumItem)
//            .padding()
//            .background(DeepBlackNeumorphicTheme.background)
//            .previewLayout(.fixed(width: 380, height: 140))
//            .preferredColorScheme(.dark)
//    }
//}
//
//struct AlbumDetailView_Previews: PreviewProvider {
//     static let mockArtist = Artist(id: "artist1", external_urls: nil, href: "", name: "Miles Davis Mock", type: "artist", uri: "")
//     static let mockImage = SpotifyImage(height: 640, url: "https://i.scdn.co/image/ab67616d0000b2737ab89c25093ea3787b1995b4", width: 640)
//     static let mockAlbum = AlbumItem(id: "1weenld61qoidwYuZ1GESA", album_type: "album", total_tracks: 5, available_markets: ["US", "GB"], external_urls: ExternalUrls(spotify: "https://open.spotify.com/album/1weenld61qoidwYuZ1GESA"), href: "", images: [mockImage], name: "Kind Of Blue (Preview)", release_date: "1959-08-17", release_date_precision: "day", type: "album", uri: "spotify:album:1weenld61qoidwYuZ1GESA", artists: [mockArtist])
//
//    static var previews: some View {
//        NavigationView { AlbumDetailView(album: mockAlbum) }
//            .preferredColorScheme(.dark)
//    }
//}
//
//// MARK: - App Entry Point
//
//@main
//struct SpotifyDeepBlackNeumorphicApp: App {
//    init() {
//        // Token Warning
//        if placeholderSpotifyToken == "YOUR_SPOTIFY_BEARER_TOKEN_HERE" { print("🚨 WARNING: Set Spotify Token!") }
//
//        // Setup Global Navigation Bar Appearance for Deep Black Theme
//        let appearance = UINavigationBarAppearance()
//        appearance.configureWithOpaqueBackground()
//        appearance.backgroundColor = UIColor(DeepBlackNeumorphicTheme.elementBackground)
//        appearance.titleTextAttributes = [.foregroundColor: UIColor(DeepBlackNeumorphicTheme.primaryText)]
//        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor(DeepBlackNeumorphicTheme.primaryText)]
//        appearance.shadowColor = .clear // Remove default separator
//
//        UINavigationBar.appearance().standardAppearance = appearance
//        UINavigationBar.appearance().scrollEdgeAppearance = appearance
//        UINavigationBar.appearance().compactAppearance = appearance
//        UINavigationBar.appearance().tintColor = UIColor(DeepBlackNeumorphicTheme.accentColor)
//    }
//
//    var body: some Scene {
//        WindowGroup {
//            SpotifyAlbumListView()
//                .preferredColorScheme(.dark) // Enforce dark mode globally
//        }
//    }
//}
