////
////  LightNeumorphicTheme_V4.swift
////  MyApp
////
////  Created by Cong Le on 4/19/25.
////
//
////
////  UltraWhiteNeumorphismApp.swift
////  MyApp // Or your actual app name
////  Created by Cong Le on 4/18/25. // Use appropriate date
////
//
//import SwiftUI
//@preconcurrency import WebKit // For Spotify Embed WebView
//import Foundation // For URLComponents, etc.
//
//// MARK: - Ultra White Neumorphism Theme Constants & Helpers
//
//struct LightNeumorphicTheme {
//    // --- Core Colors ---
//    static let background = Color(.sRGB, white: 1.1) // The "Ultra White" extended range color
//    static let elementBackground = Color(.sRGB, white: 0.98) // Slightly less bright for elements
//
//    // --- Shadows ---
//    // Light shadow needs to be visible on the elementBackground
//    static let lightShadow = Color.white.opacity(0.7)
//    // Dark shadow needs contrast against the bright background
//    static let darkShadow = Color.black.opacity(0.12)
//
//    // --- Text ---
//    static let primaryText = Color.black.opacity(0.75) // Dark for contrast
//    static let secondaryText = Color.black.opacity(0.55) // Darker gray
//
//    // --- Accents ---
//    static let accentColor = Color(hue: 0.6, saturation: 0.4, brightness: 0.6) // Muted blue
//    static let errorColor = Color(hue: 0.0, saturation: 0.5, brightness: 0.7) // Muted red
//
//    // --- Shadow Parameters ---
//    static let shadowRadius: CGFloat = 5 // Slightly smaller radius might look better on light
//    static let shadowOffset: CGFloat = 4
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
//    var isPressed: Bool = false // Optional state for pressed look
//    let cornerRadius: CGFloat = 15
//
//    func body(content: Content) -> some View {
//        content
//            .background(
//                RoundedRectangle(cornerRadius: cornerRadius)
//                    .fill(LightNeumorphicTheme.elementBackground)
//                    .shadow(color: LightNeumorphicTheme.darkShadow,
//                            radius: LightNeumorphicTheme.shadowRadius,
//                            x: LightNeumorphicTheme.shadowOffset,
//                            y: LightNeumorphicTheme.shadowOffset)
//                    .shadow(color: LightNeumorphicTheme.lightShadow,
//                            radius: LightNeumorphicTheme.shadowRadius,
//                            x: -LightNeumorphicTheme.shadowOffset,
//                            y: -LightNeumorphicTheme.shadowOffset)
//            )
//    }
//}
//
//// --- Inner Shadow for Depressed Elements (Simulated) ---
//struct NeumorphicInnerShadow: ViewModifier {
//    let cornerRadius: CGFloat = 15
//
//    func body(content: Content) -> some View {
//         // Simulate by overlaying gradients or shadows inside the bounds
//         content
//            .padding(2)
//            .background(LightNeumorphicTheme.elementBackground) // Base color inside
//            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
//            .overlay( // Simulate the inner shadows on the container
//                RoundedRectangle(cornerRadius: cornerRadius)
//                     // Create subtle inset effect with very light gray stroke
//                    .stroke(Color.gray.opacity(0.1), lineWidth: 1)
//                     // Inner dark shadow
//                    .shadow(color: LightNeumorphicTheme.darkShadow.opacity(0.7), radius: LightNeumorphicTheme.shadowRadius-1, x: LightNeumorphicTheme.shadowOffset-1, y: LightNeumorphicTheme.shadowOffset-1)
//                     // Inner light shadow (less effective on white)
//                     .shadow(color: LightNeumorphicTheme.lightShadow.opacity(0.5), radius: LightNeumorphicTheme.shadowRadius-1, x: -(LightNeumorphicTheme.shadowOffset-1), y: -(LightNeumorphicTheme.shadowOffset-1))
//                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius)) // Clip shadows to inside
//                    .blendMode(.overlay) // Experiment with blend modes
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
//    let cornerRadius: CGFloat = 20 // Consistent radius
//
//    var body: some View {
//        ZStack {
//            RoundedRectangle(cornerRadius: cornerRadius)
//                 // Use the slightly darker element background for the button base
//                .fill(LightNeumorphicTheme.elementBackground)
//
//            if isPressed {
//                // Simulate Inner Shadow
//                RoundedRectangle(cornerRadius: cornerRadius)
//                     // Stroke slightly darker gray
//                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
//                    .shadow(color: LightNeumorphicTheme.darkShadow, radius: LightNeumorphicTheme.shadowRadius / 2, x: LightNeumorphicTheme.shadowOffset / 2, y: LightNeumorphicTheme.shadowOffset / 2)
//                    .shadow(color: LightNeumorphicTheme.lightShadow, radius: LightNeumorphicTheme.shadowRadius / 2, x: -LightNeumorphicTheme.shadowOffset / 2, y: -LightNeumorphicTheme.shadowOffset / 2)
//                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
//            } else {
//                // Outer Shadow (Extruded)
//                RoundedRectangle(cornerRadius: cornerRadius)
//                    .fill(LightNeumorphicTheme.elementBackground) // Draw shadows on this
//                    .shadow(color: LightNeumorphicTheme.darkShadow,
//                            radius: LightNeumorphicTheme.shadowRadius,
//                            x: LightNeumorphicTheme.shadowOffset,
//                            y: LightNeumorphicTheme.shadowOffset)
//                    .shadow(color: LightNeumorphicTheme.lightShadow,
//                            radius: LightNeumorphicTheme.shadowRadius,
//                            x: -LightNeumorphicTheme.shadowOffset,
//                            y: -LightNeumorphicTheme.shadowOffset)
//            }
//        }
//    }
//}
//
//// MARK: - Data Models (Consistent with previous versions)
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
//            case "year":
//                dateFormatter.dateFormat = "yyyy"
//                if let date = dateFormatter.date(from: release_date) { return dateFormatter.string(from: date) }
//            case "month":
//                dateFormatter.dateFormat = "yyyy-MM"
//                if let date = dateFormatter.date(from: release_date) { dateFormatter.dateFormat = "MMM yyyy"; return dateFormatter.string(from: date) }
//            case "day":
//                dateFormatter.dateFormat = "yyyy-MM-dd"
//                if let date = dateFormatter.date(from: release_date) { dateFormatter.dateFormat = "d MMM yyyy"; return dateFormatter.string(from: date) }
//            default: break
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
//    // Include other pagination fields if needed
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
//// MARK: - API Service (Unchanged - Remember to add your token)
//
//// IMPORTANT: Replace this with your actual Spotify Bearer Token
//let placeholderSpotifyToken = "YOUR_SPOTIFY_BEARER_TOKEN_HERE"
//
//enum SpotifyAPIError: Error, LocalizedError, Equatable {
//    static func == (lhs: SpotifyAPIError, rhs: SpotifyAPIError) -> Bool {
//        return true
//    }
//    
//    case invalidURL
//    case networkError(Error)
//    case invalidResponse(Int, String?)
//    case decodingError(Error)
//    case invalidToken
//    case missingData
//
//    var errorDescription: String? {
//        switch self {
//            case .invalidURL: return "Invalid API URL setup."
//            case .networkError(let error): return "Network connection issue: \(error.localizedDescription)"
//            case .invalidResponse(let code, _): return "Server error (\(code)). Please try again later."
//            case .decodingError: return "Failed to understand server response."
//            case .invalidToken: return "Authentication failed. Check API Token."
//            case .missingData: return "Response missing expected data."
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
//             if let urlError = error as? URLError, urlError.code == .timedOut {
//                 print("❌ Network Timeout Error: \(error)")
//                 throw SpotifyAPIError.networkError(error) // Or a specific timeout error
//             }
//             print("❌ Network Error: \(error)")
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
//// MARK: - Spotify Embed WebView (Adjusted for Light Theme Context)
//
//final class SpotifyPlaybackState: ObservableObject {
//    @Published var isPlaying: Bool = false
//    @Published var currentPosition: Double = 0 // seconds
//    @Published var duration: Double = 0 // seconds
//    @Published var currentUri: String = ""
//    @Published var isReady: Bool = false // Track readiness
//    @Published var error: String? = nil // Track embed errors
//}
//
//struct SpotifyEmbedWebView: UIViewRepresentable {
//    @ObservedObject var playbackState: SpotifyPlaybackState
//    let spotifyUri: String? // URI to load
//
//    func makeCoordinator() -> Coordinator { Coordinator(self) }
//
//    func makeUIView(context: Context) -> WKWebView {
//        // Configuration
//        let userContentController = WKUserContentController()
//        userContentController.add(context.coordinator, name: "spotifyController")
//
//        let configuration = WKWebViewConfiguration()
//        configuration.userContentController = userContentController
//        configuration.allowsInlineMediaPlayback = true
//        configuration.mediaTypesRequiringUserActionForPlayback = []
//
//        // WebView Creation
//        let webView = WKWebView(frame: .zero, configuration: configuration)
//        webView.navigationDelegate = context.coordinator
//        webView.uiDelegate = context.coordinator
//        webView.isOpaque = false
//        webView.backgroundColor = .clear // Ensure SwiftUI handles background
//        webView.scrollView.backgroundColor = .clear // Ensure scroll view bg is clear too
//        webView.scrollView.isScrollEnabled = false
//
//        // Initial Load
//        webView.loadHTMLString(generateHTML(), baseURL: nil)
//        context.coordinator.webView = webView
//        return webView
//    }
//
//    func updateUIView(_ webView: WKWebView, context: Context) {
//         print("🔄 Spotify Embed WebView: updateUIView called. API Ready: \(context.coordinator.isApiReady), Last/Current URI: \(context.coordinator.lastLoadedUri ?? "nil") / \(spotifyUri ?? "nil")")
//        if context.coordinator.isApiReady && context.coordinator.lastLoadedUri != spotifyUri {
//             print(" -> Loading URI in updateUIView.")
//            context.coordinator.loadUri(spotifyUri ?? "")
//        } else if !context.coordinator.isApiReady {
//            context.coordinator.updateDesiredUriBeforeReady(spotifyUri ?? "")
//        }
//    }
//
//    static func dismantleUIView(_ webView: WKWebView, coordinator: Coordinator) {
//        print("🧹 Spotify Embed WebView: Dismantling.")
//        webView.stopLoading()
//        // Ensure the script message handler is removed
//        DispatchQueue.main.async {
//            // Seems safer to remove on main thread if it involves UI thread resources
//            webView.configuration.userContentController.removeScriptMessageHandler(forName: "spotifyController")
//        }
//        coordinator.webView = nil
//    }
//
//    // Coordinator Class - Largely unchanged logic, only logging adjusted if needed
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
//             }
//        }
//
//        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) { print("📄 Spotify Embed WebView: HTML content finished loading.") }
//        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) { print("❌ Embed Nav Fail: \(error)"); DispatchQueue.main.async { self.parent.playbackState.error = "WebView Failed: \(error.localizedDescription)" } }
//        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) { print("❌ Embed Prov. Nav Fail: \(error)"); DispatchQueue.main.async { self.parent.playbackState.error = "WebView Failed Init: \(error.localizedDescription)" } }
//
//        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
//            guard message.name == "spotifyController" else { return }
//            if let bodyDict = message.body as? [String: Any], let event = bodyDict["event"] as? String { handleEvent(event: event, data: bodyDict["data"]) }
//            else if let bodyString = message.body as? String, bodyString == "ready" { handleApiReady() }
//            else { print("❓ Embed Unknown JS Message: \(message.body)") }
//        }
//
//        private func handleApiReady() {
//            print("✅ Spotify Embed Native: API READY.")
//            isApiReady = true
//            DispatchQueue.main.async { self.parent.playbackState.isReady = true }
//            if let initialUri = desiredUriBeforeReady ?? parent.spotifyUri { createSpotifyController(with: initialUri); desiredUriBeforeReady = nil }
//            else { print("⚠️ Embed API Ready, no URI.") }
//        }
//
//        private func handleEvent(event: String, data: Any?) {
//            print("📩 JS Event: '\(event)' Data: \(String(describing: data))")
//            switch event {
//                case "controllerCreated": print("✅ Embed Controller Created")
//                case "playbackUpdate": if let updateData = data as? [String: Any] { updatePlaybackState(with: updateData) }
//                case "error":
//                    let errorMessage = (data as? [String: Any])?["message"] as? String ?? (data as? String) ?? "Unknown JS error"
//                    print("❌ Embed JS Error: \(errorMessage)"); DispatchQueue.main.async { self.parent.playbackState.error = errorMessage }
//                default: print("❓ Embed Unknown Event: \(event)")
//            }
//        }
//
//        private func updatePlaybackState(with data: [String: Any]) {
//            DispatchQueue.main.async { [weak self] in
//                guard let self = self else { return }
//                var stateChanged = false
//                if let isPaused = data["paused"] as? Bool, self.parent.playbackState.isPlaying == isPaused { self.parent.playbackState.isPlaying = !isPaused; stateChanged = true }
//                if let posMs = data["position"] as? Double, abs(self.parent.playbackState.currentPosition - (posMs / 1000.0)) > 0.1 { self.parent.playbackState.currentPosition = posMs / 1000.0; stateChanged = true }
//                if let durMs = data["duration"] as? Double {
//                    let newDuration = durMs / 1000.0
//                     if abs(self.parent.playbackState.duration - newDuration) > 0.1 || self.parent.playbackState.duration == 0 { self.parent.playbackState.duration = newDuration; stateChanged = true }
//                 }
//                if let uri = data["uri"] as? String, self.parent.playbackState.currentUri != uri {
//                    self.parent.playbackState.currentUri = uri
//                    self.parent.playbackState.currentPosition = 0 // Reset on change
//                    self.parent.playbackState.duration = (data["duration"] as? Double ?? 0) / 1000.0
//                    stateChanged = true
//                }
//                if stateChanged && self.parent.playbackState.error != nil { self.parent.playbackState.error = nil }
//            }
//        }
//
//        private func createSpotifyController(with initialUri: String) {
//            guard let webView = webView, isApiReady else { print("⚠️ Embed Cannot create controller - Not ready."); return }
//            guard lastLoadedUri == nil else {
//                 // Correct URI if needed, before the controller potentially finishes loading the wrong one
//                 if let latestDesired = desiredUriBeforeReady ?? parent.spotifyUri, latestDesired != lastLoadedUri {
//                     print(" -> Correcting URI before loading: \(latestDesired)")
//                     loadUri(latestDesired) // Call loadUri to handle it
//                 } else {
//                      print("ℹ️ Embed Controller already initialized or pending. URI: \(initialUri)")
//                 }
//                 desiredUriBeforeReady = nil // Clear regardless
//                 return
//            }
//            print("🚀 Embed Creating controller for URI: \(initialUri)")
//            lastLoadedUri = initialUri // Optimistic: set before async JS runs
//
//            let script = """
//            console.log('JS: Running create controller script.'); window.embedController = null;
//            const element = document.getElementById('embed-iframe');
//            if (!element) { console.error('JS Error: #embed-iframe not found!'); window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: '#embed-iframe not found' }}); }
//            else if (!window.IFrameAPI) { console.error('JS Error: IFrameAPI not loaded!'); window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'IFrameAPI not loaded' }}); }
//            else {
//                console.log('JS: Creating controller for: \(initialUri)');
//                const options = { uri: '\(initialUri)', width: '100%', height: '100%' };
//                const callback = (controller) => {
//                    if (!controller) { console.error('💥 JS Error: createController callback received null!'); window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'JS callback received null controller' }}); return; }
//                    console.log('✅ JS: Controller instance received.'); window.embedController = controller;
//                    window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'controllerCreated' });
//                    controller.addListener('ready', () => console.log('🎧 JS Event: Controller Ready.'));
//                    controller.addListener('playback_update', e => window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'playbackUpdate', data: e.data }));
//                    controller.addListener('account_error', e => { console.warn('💰 JS Event: Account Error:', e.data); window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'Account Error: ' + (e.data?.message ?? 'Premium Required') }}); });
//                    controller.addListener('autoplay_failed', () => { console.warn('⏯️ JS Event: Autoplay failed'); window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'Autoplay Failed' }}); controller.play(); }); // Try manual play
//                    controller.addListener('initialization_error', e => { console.error('💥 JS Event: Init Error:', e.data); window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'Init Error: ' + (e.data?.message ?? 'Unknown Init Error') }}); });
//                };
//                try {
//                    console.log('JS: Calling IFrameAPI.createController...'); IFrameAPI.createController(element, options, callback);
//                } catch (e) {
//                    console.error('💥 JS Exception during createController:', e); window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'JS Exception: ' + e.message }});
//                     // Reset lastLoadedUri if creation failed fundamentally
//                     lastLoadedUri = nil;
//                }
//            }
//            """
//            webView.evaluateJavaScript(script) { _, error in if let error = error { print("⚠️ Embed JS Error (create): \(error)") } }
//        }
//
//        func loadUri(_ uri: String) {
//            guard let webView = webView, isApiReady else { return }
//            guard let currentControllerUri = lastLoadedUri, currentControllerUri != uri else {
//                 print("ℹ️ Embed Skipping loadUri - URI same or controller not ready. (\(lastLoadedUri ?? "nil") vs \(uri))")
//                 return
//             }
//            print("🚀 Embed Loading new URI via JS: \(uri)")
//            lastLoadedUri = uri // Update
//
//            let script = """
//            if (window.embedController) { console.log('JS: Loading URI: \(uri)'); window.embedController.loadUri('\(uri)'); window.embedController.play(); }
//            else { console.error('JS Error: embedController missing for loadUri.'); window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'JS embedController missing during loadUri' }}); }
//            """
//            webView.evaluateJavaScript(script) { _, error in if let error = error { print("⚠️ Embed JS Error (loadUri): \(error)") } }
//        }
//
//         // WKUIDelegate method
//        func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) { print("ℹ️ Embed JS Alert: \(message)"); completionHandler() }
//    }
//
//    // HTML Generation - Unchanged
//    private func generateHTML() -> String {
//        return """
//        <!DOCTYPE html><html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no"><title>Spotify Embed</title><style>html, body { margin: 0; padding: 0; width: 100%; height: 100%; overflow: hidden; background-color: transparent; } #embed-iframe { width: 100%; height: 100%; box-sizing: border-box; display: block; border: none; }</style></head><body><div id="embed-iframe"></div><script src="https://open.spotify.com/embed/iframe-api/v1" async></script><script> console.log('JS: Initial script.'); var apiReadyCallbackDone = false; window.onSpotifyIframeApiReady = (IFrameAPI) => { if (apiReadyCallbackDone) return; console.log('✅ JS: API Ready.'); window.IFrameAPI = IFrameAPI; apiReadyCallbackDone = true; if (window.webkit?.messageHandlers?.spotifyController) { window.webkit.messageHandlers.spotifyController.postMessage("ready"); } else { console.error('❌ JS: Native handler missing!'); } }; const scriptTag = document.querySelector('script[src*="iframe-api"]'); if (scriptTag) { scriptTag.onerror = (event) => { console.error('❌ JS: Failed to load API script:', event); window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'Failed to load Spotify API script' }}); }; } else { console.warn('⚠️ JS: API script tag not found.'); } </script></body></html>
//        """
//    }
//}
//
//// MARK: - SwiftUI Views (Light Neumorphism "Ultra White" Themed)
//
//// MARK: Main List View
//struct SpotifyAlbumListView: View {
//    @State private var searchQuery: String = ""
//    @State private var displayedAlbums: [AlbumItem] = []
//    @State private var isLoading: Bool = false
//    @State private var searchInfo: Albums? = nil
//    @State private var currentError: SpotifyAPIError? = nil
//    @State private var debounceTask: Task<Void, Never>? // For debouncing
//
//    var body: some View {
//        NavigationView {
//            ZStack {
//                // --- Neumorphic Background ---
//                LightNeumorphicTheme.background.ignoresSafeArea()
//
//                // --- Content Area ---
//                VStack(spacing: 0) {
//                    // --- Conditional Content ---
//                    Group {
//                        if isLoading && displayedAlbums.isEmpty { loadingIndicator }
//                        else if let error = currentError { ErrorPlaceholderView(error: error) { Task { await performSearch(immediate: true) } } }
//                        else if displayedAlbums.isEmpty && !searchQuery.isEmpty { EmptyStatePlaceholderView(searchQuery: searchQuery) }
//                        else if displayedAlbums.isEmpty && searchQuery.isEmpty { EmptyStatePlaceholderView(searchQuery: "") }
//                        else { albumScrollView }
//                    }
//                    .frame(maxWidth: .infinity, maxHeight: .infinity)
//                }
//            } // End ZStack
//            .navigationTitle("Spotify Search")
//            .navigationBarTitleDisplayMode(.large)
//            // --- Search Bar ---
//             .searchable(text: $searchQuery,
//                         placement: .navigationBarDrawer(displayMode: .always),
//                         prompt: Text("Search Albums / Artists").foregroundColor(LightNeumorphicTheme.secondaryText))
//             .onSubmit(of: .search) { Task { await performSearch(immediate: true) } }
//             .onChange(of: searchQuery) { _ in Task { await handleSearchQueryChange() } } // Trigger debounce
//             .onChange(of: currentError) { /* Can add logic if error changes */ }
//             .accentColor(LightNeumorphicTheme.accentColor) // Search cursor/cancel
//
//        } // End NavigationView
//        .navigationViewStyle(.stack)
//        .preferredColorScheme(.light) // Ensure light mode context for system elements
//    }
//
//    // --- Themed Scrollable Album List ---
//    private var albumScrollView: some View {
//        ScrollView {
//            LazyVStack(spacing: 18) {
//                // --- Metadata Header (Themed) ---
//                if let info = searchInfo, info.total > 0 {
//                    SearchMetadataHeader(totalResults: info.total, limit: info.limit, offset: info.offset)
//                        .padding(.horizontal)
//                        .padding(.top, 5)
//                }
//
//                // --- Album Cards ---
//                ForEach(displayedAlbums) { album in
//                    NavigationLink(destination: AlbumDetailView(album: album)) {
//                        NeumorphicAlbumCard(album: album)
//                    }
//                    .buttonStyle(.plain) // Prevent default link styling
//                }
//            }
//            .padding(.horizontal)
//            .padding(.bottom)
//        }
//        .scrollDismissesKeyboard(.interactively) // iOS 16+
//    }
//
//    // --- Themed Loading Indicator ---
//    private var loadingIndicator: some View {
//        VStack {
//            ProgressView()
//                .progressViewStyle(CircularProgressViewStyle(tint: LightNeumorphicTheme.accentColor))
//                .scaleEffect(1.5)
//            Text("Loading...")
//                .font(neumorphicFont(size: 14))
//                .foregroundColor(LightNeumorphicTheme.secondaryText)
//                .padding(.top, 10)
//        }
//    }
//
//    // --- Debounced Search Logic ---
//    private func handleSearchQueryChange() async {
//         if currentError != nil { await MainActor.run { currentError = nil } } // Clear error on new typing
//
//        debounceTask?.cancel() // Cancel previous task
//
//        let currentQuery = searchQuery // Capture current query
//
//        debounceTask = Task {
//             do {
//                 try await Task.sleep(for: .milliseconds(500)) // Debounce duration
//                 try Task.checkCancellation()
//
//                 // Check if query is still the same after debounce
//                 if currentQuery == searchQuery {
//                     await performSearch(immediate: true) // Perform the actual search
//                 } else {
//                      print("Search query changed during debounce, skipping.")
//                 }
//             } catch is CancellationError {
//                 print("Search debounce task cancelled.")
//             } catch {
//                  print("Error during debounce sleep: \(error)") // Should not happen often
//             }
//        }
//    }
//
//    private func performSearch(immediate: Bool = false) async {
//        let trimmedQuery = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
//
//        guard !trimmedQuery.isEmpty else {
//             await MainActor.run { displayedAlbums = []; searchInfo = nil; isLoading = false; currentError = nil }
//             return
//        }
//        
//        await MainActor.run { isLoading = true } // Show loading
//
//        do {
//            print("🚀 Performing search for: \(trimmedQuery)")
//            let response = try await SpotifyAPIService.shared.searchAlbums(query: trimmedQuery, limit: 20, offset: 0)
//            try Task.checkCancellation() // Check before updating UI
//            await MainActor.run {
//                displayedAlbums = response.albums.items
//                searchInfo = response.albums
//                currentError = nil
//                isLoading = false
//                print("✅ Search successful, \(response.albums.items.count) items loaded.")
//            }
//        } catch is CancellationError {
//            print("Search task cancelled.")
//             // Don't clear results if cancelled, just stop loading
//             await MainActor.run { isLoading = false }
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
//// MARK: Neumorphic Album Card
//struct NeumorphicAlbumCard: View {
//    let album: AlbumItem
//    private let cardCornerRadius: CGFloat = 20
//
//    var body: some View {
//        HStack(spacing: 15) {
//            // --- Album Art ---
//            AlbumImageView(url: album.listImageURL)
//                .frame(width: 80, height: 80)
//                .clipShape(RoundedRectangle(cornerRadius: 12))
//                 // Subtle border matching slightly darker element bg
//                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.15), lineWidth: 0.5))
//                .padding(2) // Tiny inset for the image
//                .background( // Neumorphic background for the image itself
//                     RoundedRectangle(cornerRadius: 14) // Slightly larger radius
//                         .fill(LightNeumorphicTheme.elementBackground)
//                         .modifier(NeumorphicOuterShadow())
//                 )
//
//            // --- Text Details ---
//            VStack(alignment: .leading, spacing: 4) {
//                Text(album.name)
//                    .font(neumorphicFont(size: 15, weight: .semibold))
//                    .foregroundColor(LightNeumorphicTheme.primaryText)
//                    .lineLimit(2)
//
//                Text(album.formattedArtists)
//                    .font(neumorphicFont(size: 13))
//                    .foregroundColor(LightNeumorphicTheme.secondaryText)
//                    .lineLimit(1)
//
//                Spacer() // Push bottom info down
//
//                HStack(spacing: 8) {
//                    Text(album.album_type.capitalized)
//                        .font(neumorphicFont(size: 10, weight: .medium))
//                        .foregroundColor(LightNeumorphicTheme.secondaryText)
//                        .padding(.horizontal, 8)
//                        .padding(.vertical, 3)
//                         // Simple background for tag, slightly darker than element bg
//                        .background(Color.gray.opacity(0.1), in: Capsule())
//
//                    Text("• \(album.formattedReleaseDate())")
//                        .font(neumorphicFont(size: 10, weight: .medium))
//                        .foregroundColor(LightNeumorphicTheme.secondaryText)
//                }
//                Text("\(album.total_tracks) Tracks")
//                        .font(neumorphicFont(size: 10, weight: .medium))
//                        .foregroundColor(LightNeumorphicTheme.secondaryText)
//                        .padding(.top, 1)
//            }
//            .frame(maxWidth: .infinity, alignment: .leading)
//
//        } // End HStack
//        .padding(15)
//        .modifier(NeumorphicOuterShadow()) // Neumorphic effect on the whole card
//        .frame(height: 120) // Adjusted height
//    }
//}
//
//// MARK: Placeholders (Light Neumorphic Themed)
//struct ErrorPlaceholderView: View {
//    let error: SpotifyAPIError
//    let retryAction: (() -> Void)?
//     private let cornerRadius: CGFloat = 25 // Keep consistent
//
//    var body: some View {
//        VStack(spacing: 20) {
//            // --- Icon framed with Neumorphism ---
//            Image(systemName: iconName)
//                 .font(.system(size: 45, weight: .light)) // Lighter weight icon
//                .foregroundColor(LightNeumorphicTheme.errorColor)
//                .padding(25)
//                .background(
//                    Circle()
//                        .fill(LightNeumorphicTheme.elementBackground)
//                        .modifier(NeumorphicOuterShadow()) // Apply to circle
//                )
//                .padding(.bottom, 15)
//
//            // --- Text ---
//            Text("Error")
//                .font(neumorphicFont(size: 20, weight: .bold))
//                .foregroundColor(LightNeumorphicTheme.primaryText)
//
//            Text(errorMessage)
//                .font(neumorphicFont(size: 14))
//                .foregroundColor(LightNeumorphicTheme.secondaryText)
//                .multilineTextAlignment(.center)
//                .padding(.horizontal, 30)
//
//            // --- Retry Button ---
//            switch error {
//            case .invalidToken:
//                 Text("Please check the API token in the code.")
//                      .font(neumorphicFont(size: 13))
//                      .foregroundColor(LightNeumorphicTheme.errorColor.opacity(0.9))
//                      .multilineTextAlignment(.center)
//                      .padding(.horizontal, 30)
//            case .networkError, .invalidResponse, .decodingError: // Allow retry for these
//                 if let retry = retryAction {
//                      ThemedNeumorphicButton(text: "Retry", iconName: "arrow.clockwise", action: retry)
//                           .padding(.top, 10)
//                 }
//             default: // Don't show retry for invalid URL etc.
//                 EmptyView()
//            }
//        }
//        .padding(40)
//    }
//
//    // --- Helper properties ---
//    private var iconName: String {
//        switch error {
//            case .invalidToken: return "key.slash"
//            case .networkError: return "wifi.slash"
//            case .invalidResponse, .decodingError, .missingData: return "exclamationmark.triangle"
//            case .invalidURL: return "link.badge.questionmark"
//        }
//    }
//    private var errorMessage: String { error.localizedDescription }
//}
//
//struct EmptyStatePlaceholderView: View {
//    let searchQuery: String
//
//    var body: some View {
//        VStack(spacing: 20) {
//             // --- Image with Neumorphic Frame ---
//            Image(placeholderImageName) // Make sure these images exist in assets
//                 .resizable()
//                 .aspectRatio(contentMode: .fit)
//                 .frame(width: 120, height: 120) // Adjusted size
//                 .padding(isInitialState ? 25 : 20)
//                 .background(
//                      Circle()
//                           .fill(LightNeumorphicTheme.elementBackground)
//                           .modifier(NeumorphicOuterShadow()) // Circular shadow
//                  )
//                 .padding(.bottom, 15)
//
//            // --- Text ---
//             Text(title)
//                 .font(neumorphicFont(size: 20, weight: .bold))
//                 .foregroundColor(LightNeumorphicTheme.primaryText)
//
//            Text(messageAttributedString) // Use AttributedString
//                .font(neumorphicFont(size: 14))
//                .foregroundColor(LightNeumorphicTheme.secondaryText)
//                .multilineTextAlignment(.center)
//                .padding(.horizontal, 40)
//        }
//        .padding(30)
//    }
//
//    // --- Helper properties ---
//    private var isInitialState: Bool { searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
//    // Ensure these asset names are correct for your project
//     private var placeholderImageName: String { isInitialState ? "placeholder_initial" : "placeholder_no_results" }
//    private var title: String { isInitialState ? "Spotify Search" : "No Results Found" }
//
//     private var messageAttributedString: AttributedString {
//         var messageText: String
//          let escapedQuery = searchQuery.replacingOccurrences(of: "*", with: "").replacingOccurrences(of: "_", with: "") // Minimal sanitization
//
//         if isInitialState {
//             messageText = "Enter an album or artist name\nin the search bar above to begin."
//         } else {
//              messageText = "No matches found for \"\(escapedQuery)\".\nTry refining your search terms."
//         }
//
//         var attributedString = AttributedString(messageText)
//          attributedString.font = neumorphicFont(size: 14)
//          attributedString.foregroundColor = LightNeumorphicTheme.secondaryText
//
//          // Highlight the query term if present
//          if !isInitialState, let range = attributedString.range(of: "\"\(escapedQuery)\"") {
//              attributedString[range].font = neumorphicFont(size: 14, weight: .semibold)
//              attributedString[range].foregroundColor = LightNeumorphicTheme.primaryText.opacity(0.9)
//          }
//         return attributedString
//     }
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
//    @Environment(\.openURL) var openURL
//
//    var body: some View {
//        ZStack {
//            LightNeumorphicTheme.background.ignoresSafeArea()
//
//            ScrollView {
//                VStack(spacing: 0) { // Use spacing 0 for control
//                    // --- Header ---
//                    AlbumHeaderView(album: album)
//                        .padding(.top, 10)
//                        .padding(.bottom, 25)
//
//                    // --- Player ---
//                    if selectedTrackUri != nil {
//                        SpotifyEmbedPlayerView(playbackState: playbackState, spotifyUri: selectedTrackUri)
//                            .padding(.horizontal)
//                            .padding(.bottom, 25)
//                            .transition(.opacity.combined(with: .scale(scale: 0.95, anchor: .top)))
//                            .animation(.easeInOut(duration: 0.3), value: selectedTrackUri)
//                    }
//
//                    // --- Tracks List ---
//                    TracksSectionView(
//                        tracks: tracks,
//                        isLoading: isLoadingTracks,
//                        error: trackFetchError,
//                        selectedTrackUri: $selectedTrackUri,
//                        retryAction: { Task { await fetchTracks() } }
//                    )
//                     .padding(.bottom, 25)
//
//                    // --- External Link Button ---
//                    if let spotifyURL = URL(string: album.external_urls.spotify ?? "") {
//                        ExternalLinkButton(url: spotifyURL)
//                            .padding(.horizontal)
//                            .padding(.bottom, 30)
//                    }
//
//                } // End Main VStack
//            } // End ScrollView
//        } // End ZStack
//        .navigationTitle(album.name)
//        .navigationBarTitleDisplayMode(.inline)
//         // Navigation Bar Theming for Light
//         .toolbarBackground(LightNeumorphicTheme.elementBackground, for: .navigationBar)
//         .toolbarBackground(.visible, for: .navigationBar)
//         .toolbarColorScheme(.light, for: .navigationBar) // Ensure title/buttons are dark
//        .task { await fetchTracks() }
//    }
//
//    // --- Fetch Tracks Logic (Unchanged) ---
//    private func fetchTracks(forceReload: Bool = false) async {
//        guard forceReload || tracks.isEmpty || trackFetchError != nil else { return }
//        await MainActor.run { isLoadingTracks = true; trackFetchError = nil }
//        do {
//            let response = try await SpotifyAPIService.shared.getAlbumTracks(albumId: album.id)
//             try Task.checkCancellation() // Check before UI update
//            await MainActor.run { self.tracks = response.items; self.isLoadingTracks = false }
//        } catch is CancellationError { await MainActor.run { isLoadingTracks = false } }
//        catch let apiError as SpotifyAPIError { await MainActor.run { self.trackFetchError = apiError; self.isLoadingTracks = false; self.tracks = [] } }
//        catch { await MainActor.run { self.trackFetchError = .networkError(error); self.isLoadingTracks = false; self.tracks = [] } }
//    }
//}
//
//// MARK: Detail View Sub-Components (Light Themed)
//
//struct AlbumHeaderView: View {
//    let album: AlbumItem
//    private let cornerRadius: CGFloat = 25
//
//    var body: some View {
//        VStack(spacing: 15) {
//            // --- Album Image ---
//            AlbumImageView(url: album.bestImageURL)
//                .aspectRatio(1.0, contentMode: .fit)
//                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
//                .background( // Background for shadow
//                     RoundedRectangle(cornerRadius: cornerRadius)
//                          .fill(LightNeumorphicTheme.elementBackground) // Base for shadow
//                          .modifier(NeumorphicOuterShadow())
//                 )
//                .padding(.horizontal, 40)
//
//            // --- Text Details ---
//            VStack(spacing: 4) {
//                Text(album.name)
//                    .font(neumorphicFont(size: 20, weight: .bold))
//                    .foregroundColor(LightNeumorphicTheme.primaryText)
//                    .multilineTextAlignment(.center)
//
//                Text("by \(album.formattedArtists)")
//                    .font(neumorphicFont(size: 15))
//                    .foregroundColor(LightNeumorphicTheme.secondaryText)
//                    .multilineTextAlignment(.center)
//
//                Text("\(album.album_type.capitalized) • \(album.formattedReleaseDate())")
//                    .font(neumorphicFont(size: 12, weight: .medium))
//                    .foregroundColor(LightNeumorphicTheme.secondaryText.opacity(0.9))
//            }
//            .padding(.horizontal)
//
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
//            // --- WebView Embed ---
//            SpotifyEmbedWebView(playbackState: playbackState, spotifyUri: spotifyUri)
//                .frame(height: 80) // Standard height
//                .clipShape(RoundedRectangle(cornerRadius: playerCornerRadius))
//                .disabled(!playbackState.isReady)
//                .overlay( // Loading/Error Overlay
//                    Group {
//                        if !playbackState.isReady { ProgressView().tint(LightNeumorphicTheme.accentColor) }
//                        else if let error = playbackState.error {
//                            VStack {
//                                Image(systemName: "exclamationmark.triangle") .foregroundColor(LightNeumorphicTheme.errorColor)
//                                Text(error).font(.caption).foregroundColor(LightNeumorphicTheme.errorColor).lineLimit(1)
//                            }.padding(5)
//                         }
//                    }
//                 )
//                 // --- Neumorphic Background/Frame ---
//                 .background(
//                     RoundedRectangle(cornerRadius: playerCornerRadius)
//                         .fill(LightNeumorphicTheme.elementBackground)
//                         .modifier(NeumorphicOuterShadow())
//                 )
//
//            // --- Playback Status Text ---
//            HStack {
//                Group { // Group to handle conditional states cleanly
//                     if let error = playbackState.error, !error.isEmpty {
//                          Text("Error: \(error)").foregroundColor(LightNeumorphicTheme.errorColor)
//                      } else if !playbackState.isReady {
//                          Text("Loading Player...").foregroundColor(LightNeumorphicTheme.secondaryText)
//                      } else if playbackState.duration > 0.1 {
//                           Text(playbackState.isPlaying ? "Playing" : "Paused")
//                                .foregroundColor(playbackState.isPlaying ? LightNeumorphicTheme.accentColor : LightNeumorphicTheme.secondaryText)
//                           Spacer()
//                           Text("\(formatTime(playbackState.currentPosition)) / \(formatTime(playbackState.duration))")
//                                .foregroundColor(LightNeumorphicTheme.secondaryText)
//                                .frame(width: 90, alignment: .trailing)
//                      } else {
//                          Text("Ready").foregroundColor(LightNeumorphicTheme.secondaryText)
//                     }
//                 }
//                 .font(neumorphicFont(size: 10, weight: .medium))
//                 .lineLimit(1)
//            }
//            .padding(.horizontal, 8)
//            .frame(height: 15)
//
//        } // End VStack
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
//    private let sectionCornerRadius: CGFloat = 20
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 0) {
//            // --- Section Header ---
//            Text("Tracks")
//                .font(neumorphicFont(size: 16, weight: .semibold))
//                .foregroundColor(LightNeumorphicTheme.primaryText)
//                .padding(.horizontal)
//                .padding(.bottom, 10)
//
//            // --- Container ---
//            Group {
//                if isLoading {
//                    HStack { Spacer(); ProgressView().tint(LightNeumorphicTheme.accentColor); Text("Loading Tracks...").font(neumorphicFont(size: 14)).foregroundColor(LightNeumorphicTheme.secondaryText); Spacer() }.padding(.vertical, 30)
//                } else if let error = error {
//                    ErrorPlaceholderView(error: error, retryAction: retryAction).padding(.vertical, 20)
//                } else if tracks.isEmpty {
//                    Text("No tracks found.").font(neumorphicFont(size: 14)).foregroundColor(LightNeumorphicTheme.secondaryText).frame(maxWidth: .infinity, alignment: .center).padding(.vertical, 30)
//                } else {
//                    // Track Rows
//                    VStack(spacing: 0) {
//                        ForEach(tracks) { track in
//                            NeumorphicTrackRow( track: track, isSelected: track.uri == selectedTrackUri )
//                                .contentShape(Rectangle())
//                                .onTapGesture { selectedTrackUri = track.uri }
//
//                            // Subtle Divider
//                            if track.id != tracks.last?.id {
//                                 Divider().background(Color.gray.opacity(0.15)).padding(.leading, 35) // Line up with text
//                            }
//                        }
//                    }
//                }
//            }
//             .padding(10) // Padding content inside neumorphic shape
//             // --- Neumorphic Background ---
//             .background(
//                 RoundedRectangle(cornerRadius: sectionCornerRadius)
//                     .fill(LightNeumorphicTheme.elementBackground)
//                     .modifier(NeumorphicOuterShadow())
//             )
//             .padding(.horizontal) // Padding for the neumorphic container
//
//        } // End Outer VStack
//    }
//}
//
//struct NeumorphicTrackRow: View {
//    let track: Track
//    let isSelected: Bool
//
//    var body: some View {
//        HStack(spacing: 12) {
//            // --- Track Number ---
//            Text("\(track.track_number)")
//                .font(neumorphicFont(size: 12, weight: .medium))
//                .foregroundColor(isSelected ? LightNeumorphicTheme.accentColor : LightNeumorphicTheme.secondaryText)
//                .frame(width: 20, alignment: .center)
//
//            // --- Track Info ---
//            VStack(alignment: .leading, spacing: 2) {
//                Text(track.name)
//                    .font(neumorphicFont(size: 14, weight: isSelected ? .semibold : .medium))
//                     .foregroundColor(LightNeumorphicTheme.primaryText) // Always dark text
//                    .lineLimit(1)
//
//                Text(track.formattedArtists)
//                    .font(neumorphicFont(size: 11))
//                    .foregroundColor(LightNeumorphicTheme.secondaryText)
//                    .lineLimit(1)
//            }
//
//            Spacer()
//
//            // --- Duration ---
//            Text(track.formattedDuration)
//                .font(neumorphicFont(size: 12, weight: .medium))
//                .foregroundColor(LightNeumorphicTheme.secondaryText)
//                .frame(width: 40, alignment: .trailing)
//
//            // --- Play Icon ---
//             Image(systemName: isSelected ? "speaker.wave.2.fill" : "play.fill") // Use filled play icon
//                 .font(.system(size: 11)) // Slightly smaller
//                 .foregroundColor(isSelected ? LightNeumorphicTheme.accentColor : LightNeumorphicTheme.secondaryText.opacity(0.6))
//                 .frame(width: 20, alignment: .center)
//                 .animation(.easeInOut, value: isSelected)
//
//        }
//        .padding(.vertical, 10)
//        .padding(.horizontal, 5)
//         // Selection Highlight: Subtle background change
//         .background(isSelected ? Color.gray.opacity(0.08) : Color.clear)
//         .cornerRadius(6)
//    }
//}
//
//// MARK: Other Supporting Views (Light Themed)
//
//struct AlbumImageView: View {
//    let url: URL?
//    private let placeholderCornerRadius: CGFloat = 8
//
//    var body: some View {
//        AsyncImage(url: url) { phase in
//            switch phase {
//            case .empty:
//                 // Light loading placeholder
//                 ZStack {
//                      RoundedRectangle(cornerRadius: placeholderCornerRadius)
//                          .fill(LightNeumorphicTheme.elementBackground.opacity(0.8)) // Slightly transparent base
//                          .modifier(NeumorphicInnerShadow()) // Inset look
//                      ProgressView().tint(LightNeumorphicTheme.accentColor.opacity(0.7))
//                  }
//            case .success(let image):
//                image.resizable().scaledToFit()
//            case .failure:
//                 // Light error placeholder
//                  ZStack {
//                       RoundedRectangle(cornerRadius: placeholderCornerRadius)
//                          .fill(LightNeumorphicTheme.elementBackground.opacity(0.8))
//                          .modifier(NeumorphicInnerShadow())
//                       Image(systemName: "photo.on.rectangle.angled")
//                           .resizable().scaledToFit()
//                           .foregroundColor(LightNeumorphicTheme.secondaryText.opacity(0.4))
//                           .padding(15)
//                   }
//            @unknown default: EmptyView()
//            }
//        }
//    }
//}
//
//struct SearchMetadataHeader: View {
//    let totalResults: Int
//    let limit: Int
//    let offset: Int
//
//    var body: some View {
//         // Simple, non-neumorphic for clarity near search
//         HStack {
//             Text("Results: \(totalResults)")
//             Spacer()
//             if totalResults > limit {
//                  Text("Showing: \(offset + 1)-\(min(offset + limit, totalResults))")
//             }
//         }
//         .font(neumorphicFont(size: 11, weight: .medium))
//         .foregroundColor(LightNeumorphicTheme.secondaryText)
//         .padding(.vertical, 5)
//    }
//}
//
//// MARK: Reusable Neumorphic Button
//struct ThemedNeumorphicButton: View {
//     let text: String
//     var iconName: String? = nil
//     let action: () -> Void
//
//     var body: some View {
//         Button(action: action) {
//             HStack(spacing: 8) {
//                 if let iconName = iconName { Image(systemName: iconName) }
//                 Text(text)
//             }
//             .font(neumorphicFont(size: 15, weight: .semibold))
//              .foregroundColor(LightNeumorphicTheme.accentColor) // Use accent for button text
//         }
//         .buttonStyle(NeumorphicButtonStyle())
//     }
//}
//
//struct ExternalLinkButton: View {
//    let text: String = "Open in Spotify"
//    let url: URL
//    @Environment(\.openURL) var openURL
//
//    var body: some View {
//        ThemedNeumorphicButton(text: text, iconName: "arrow.up.forward.app") {
//             print("Opening external URL: \(url)")
//             openURL(url) { accepted in if !accepted { print("⚠️ Failed to open URL: \(url)") } }
//        }
//    }
//}
//
//// MARK: - Preview Providers (Updated for Light Neumorphic Views)
//
//struct SpotifyAlbumListView_Previews: PreviewProvider {
//    static var previews: some View {
//        SpotifyAlbumListView()
//            .preferredColorScheme(.light) // Preview in light mode
//    }
//}
//
//struct NeumorphicAlbumCard_Previews: PreviewProvider {
//    // Using the same mock data structure as before
//    static let mockArtist = Artist(id: "artist1", external_urls: nil, href: "", name: "Miles Davis Mock", type: "artist", uri: "")
//    static let mockImage = SpotifyImage(height: 300, url: "https://i.scdn.co/image/ab67616d00001e027ab89c25093ea3787b1995b4", width: 300)
//    static let mockAlbumItem = AlbumItem(id: "album1", album_type: "album", total_tracks: 5, available_markets: ["US"], external_urls: ExternalUrls(spotify: ""), href: "", images: [mockImage], name: "Kind of Blue", release_date: "1959-08-17", release_date_precision: "day", type: "album", uri: "spotify:album:1weenld61qoidwYuZ1GESA", artists: [mockArtist])
//
//    static var previews: some View {
//        NeumorphicAlbumCard(album: mockAlbumItem)
//            .padding()
//            .background(LightNeumorphicTheme.background) // Preview on ultra-white
//            .previewLayout(.fixed(width: 380, height: 150))
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
//        NavigationView {
//            AlbumDetailView(album: mockAlbum)
//        }
//        .preferredColorScheme(.light)
//    }
//}
//
//// MARK: - App Entry Point
//
//@main
//struct UltraWhiteNeumorphicApp: App { // Renamed App struct
//    init() {
//        // Print Token Warning at Startup
//        if placeholderSpotifyToken == "YOUR_SPOTIFY_BEARER_TOKEN_HERE" {
//            print("🚨 WARNING: Spotify Bearer Token is not set! API calls will fail.")
//            print("👉 FIX: Replace the placeholder token in the code.")
//        }
//
//        // Global Navigation Bar Appearance for Light Neumorphism
//        let appearance = UINavigationBarAppearance()
//        appearance.configureWithOpaqueBackground()
//        appearance.backgroundColor = UIColor(LightNeumorphicTheme.elementBackground) // Bar background
//         // Use dark text for titles on light background
//        appearance.titleTextAttributes = [.foregroundColor: UIColor(LightNeumorphicTheme.primaryText)]
//        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor(LightNeumorphicTheme.primaryText)]
//
//        // Remove default bottom border/shadow
//        appearance.shadowColor = .clear
//
//        UINavigationBar.appearance().standardAppearance = appearance
//        UINavigationBar.appearance().scrollEdgeAppearance = appearance
//        UINavigationBar.appearance().compactAppearance = appearance
//        UINavigationBar.appearance().tintColor = UIColor(LightNeumorphicTheme.accentColor) // Back button etc.
//    }
//
//    var body: some Scene {
//        WindowGroup {
//            SpotifyAlbumListView()
//                 // Force light mode for the entire app if desired, otherwise respects system
//                 .preferredColorScheme(.light)
//        }
//    }
//}
//
//// MARK: - Placeholder Asset Names (Add these to your Assets.xcassets)
///*
// Add images named:
// - "placeholder_initial" (e.g., a music note or magnifying glass)
// - "placeholder_no_results" (e.g., a sad face or empty box)
// Update the names in `EmptyStatePlaceholderView` if you use different ones.
// */
