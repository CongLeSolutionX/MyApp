////
////  SynthwaveThemeLoook_V1.swift
////  MyApp
////
////  Created by Cong Le on 4/20/25.
////
//
//
////  SynthwaveSpotifyApp.swift
////  MyAppSynthesized
////  Created by Cong Le on 4/19/25.
////  Synthesized single-file version with Synthwave Theme
////
//
//import SwiftUI
//@preconcurrency import WebKit // for the embedded player
//import Foundation
//
//// MARK: - Synthwave Theme Constants & Helpers
//
//let synthwaveDeepPurple = Color(red: 0.08, green: 0.02, blue: 0.18) // Very dark purple/blue base
//let synthwaveMidPurple = Color(red: 0.25, green: 0.12, blue: 0.4)  // Mider purple for gradients/accents
//let synthwaveNeonPink = Color(red: 1.0, green: 0.15, blue: 0.65) // Vibrant Pink
//let synthwaveNeonCyan = Color(red: 0.2, green: 0.9, blue: 0.95)   // Bright Cyan
//let synthwaveNeonLime = Color(red: 0.6, green: 1.0, blue: 0.3)    // Electric Lime
//let synthwaveAccentOrange = Color(red: 1.0, green: 0.5, blue: 0.1) // Optional accent
//
//let synthwaveBackgroundGradient = LinearGradient(
//    gradient: Gradient(colors: [synthwaveDeepPurple, Color(hex: "2a0a4e"), synthwaveDeepPurple]), // Dark Purple gradient
//    startPoint: .topLeading,
//    endPoint: .bottomTrailing
//)
//
//// Helper for Hex Colors (Optional but useful)
//extension Color {
//    init(hex: String) {
//        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
//        var int: UInt64 = 0
//        Scanner(string: hex).scanHexInt64(&int)
//        let a, r, g, b: UInt64
//        switch hex.count {
//        case 3: // RGB (12-bit)
//            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
//        case 6: // RGB (24-bit)
//            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
//        case 8: // ARGB (32-bit)
//            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
//        default:
//            (a, r, g, b) = (255, 0, 0, 0) // Default to black on error
//        }
//        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
//    }
//}
//
//// Font Helper (Using system monospaced, replace if custom Synthwave fonts available)
//func synthwaveFont(size: CGFloat, weight: Font.Weight = .regular) -> Font {
//    Font.system(size: size, weight: weight, design: .monospaced)
//    // Example Custom: Font.custom("YourSynthwaveFontName", size: size).weight(weight)
//}
//
//// Custom Modifier for Neon Glow Effect
//struct NeonGlow: ViewModifier {
//    var color: Color
//    var radius: CGFloat
//
//    func body(content: Content) -> some View {
//        content
//            .shadow(color: color.opacity(0.6), radius: radius * 0.5, x: 0, y: 0) // Inner sharp glow
//            .shadow(color: color.opacity(0.4), radius: radius, x: 0, y: 0)       // Mid bloom
//            .shadow(color: color.opacity(0.2), radius: radius * 1.5, x: 0, y: 0) // Outer softer bloom
//    }
//}
//
//extension View {
//    func neonGlow(_ color: Color = synthwaveNeonPink, radius: CGFloat = 10) -> some View {
//        self.modifier(NeonGlow(color: color, radius: radius))
//    }
//}
//
//// MARK: - Data Models (Unchanged)
//
//struct SpotifySearchResponse: Codable, Hashable { let albums: Albums }
//struct Albums: Codable, Hashable {
//    let href: String
//    let limit: Int
//    let next: String?
//    let offset: Int
//    let previous: String?
//    let total: Int
//    let items: [AlbumItem]
//}
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
//    let type: String
//    let uri: String
//    let artists: [Artist]
//
//    // --- Helper computed properties (Unchanged) ---
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
//                dateFormatter.dateFormat = "MMM yyyy" // Keep readable
//                return dateFormatter.string(from: date)
//            }
//        case "day":
//            dateFormatter.dateFormat = "yyyy-MM-dd"
//            if let date = dateFormatter.date(from: release_date) {
//                dateFormatter.dateFormat = "d MMM yyyy" // Keep readable
//                return dateFormatter.string(from: date)
//            }
//        default: break
//        }
//        return release_date // Fallback to original string
//    }
//}
//struct Artist: Codable, Identifiable, Hashable {
//    let id: String
//    let external_urls: ExternalUrls?
//    let href: String
//    let name: String
//    let type: String
//    let uri: String
//}
//struct SpotifyImage: Codable, Hashable {
//    let height: Int?
//    let url: String
//    let width: Int?
//    var urlObject: URL? { URL(string: url) }
//}
//struct ExternalUrls: Codable, Hashable {
//    let spotify: String?
//}
//struct AlbumTracksResponse: Codable, Hashable {
//    let items: [Track]
//}
//struct Track: Codable, Identifiable, Hashable {
//    let id: String
//    let artists: [Artist]
//    let disc_number: Int
//    let duration_ms: Int
//    let explicit: Bool
//    let external_urls: ExternalUrls?
//    let href: String
//    let name: String
//    let preview_url: String? // Typically 30s preview, might need embed player
//    let track_number: Int
//    let type: String
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
//// MARK: - API Service (Placeholder Token Reminder)
//
//// 🚨 REMINDER: Replace this placeholder token with your actual Spotify Bearer Token!
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
//        case .invalidURL: return "Invalid API URL constructed."
//        case .networkError(let error): return "Network Communication Error: \(error.localizedDescription)"
//        case .invalidResponse(let code, _): return "Invalid Server Response (Code: \(code))."
//        case .decodingError(let error): return "Data Decoding Error: \(error.localizedDescription)"
//        case .invalidToken: return "Spotify authentication token is invalid or expired."
//        case .missingData: return "Expected data was missing in the API response."
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
//        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData // Avoid stale cache
//        session = URLSession(configuration: configuration)
//    }
//
//    private func makeRequest<T: Decodable>(url: URL) async throws -> T {
//        // --- CRITICAL TOKEN CHECK ---
//        guard !placeholderSpotifyToken.isEmpty, placeholderSpotifyToken != "YOUR_SPOTIFY_BEARER_TOKEN_HERE" else {
//            print("❌ FATAL Error: Spotify Token is missing or still placeholder!")
//            throw SpotifyAPIError.invalidToken
//        }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//        request.setValue("Bearer \(placeholderSpotifyToken)", forHTTPHeaderField: "Authorization")
//        request.setValue("application/json", forHTTPHeaderField: "Accept")
//        request.timeoutInterval = 20 // Reasonable timeout
//
//        do {
//            let (data, response) = try await session.data(for: request)
//
//            guard let httpResponse = response as? HTTPURLResponse else {
//                throw SpotifyAPIError.invalidResponse(0, "Not an HTTP response.")
//            }
//
//            guard (200...299).contains(httpResponse.statusCode) else {
//                if httpResponse.statusCode == 401 { throw SpotifyAPIError.invalidToken } // Specific 401 handling
//                let responseBody = String(data: data, encoding: .utf8) ?? "No details"
//                print("Server Error \(httpResponse.statusCode): \(responseBody)")
//                throw SpotifyAPIError.invalidResponse(httpResponse.statusCode, responseBody)
//            }
//
//            do {
//                return try JSONDecoder().decode(T.self, from: data)
//            } catch {
//                print("JSON Decoding Error: \(error)")
//                throw SpotifyAPIError.decodingError(error)
//            }
//        } catch let error where !(error is CancellationError) {
//            // Re-throw specific API errors, wrap others
//            throw error is SpotifyAPIError ? error : SpotifyAPIError.networkError(error)
//        }
//    }
//
//    // Specific API Endpoints
//    func searchAlbums(query: String, limit: Int = 20, offset: Int = 0) async throws -> SpotifySearchResponse {
//        var components = URLComponents(string: "https://api.spotify.com/v1/search")
//        components?.queryItems = [
//            URLQueryItem(name: "q", value: query),
//            URLQueryItem(name: "type", value: "album"),
//            URLQueryItem(name: "include_external", value: "audio"), // As per original request
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
//// MARK: - Spotify Embed WebView (Unchanged Functionality
//final class SpotifyPlaybackState: ObservableObject {
//    @Published var isPlaying: Bool = false
//    @Published var currentPosition: Double = 0 // seconds
//    @Published var duration: Double = 0 // seconds
//    @Published var currentUri: String = "" // Track which URI is active
//}
//
//struct SpotifyEmbedWebView: UIViewRepresentable {
//    @ObservedObject var playbackState: SpotifyPlaybackState
//    let spotifyUri: String? // The specific track/album URI to load
//
//    func makeCoordinator() -> Coordinator { Coordinator(self) }
//
//    func makeUIView(context: Context) -> WKWebView {
//        // Configure JavaScript message handling
//        let userContentController = WKUserContentController()
//        userContentController.add(context.coordinator, name: "spotifyController") // Native -> JS bridge
//
//        let configuration = WKWebViewConfiguration()
//        configuration.userContentController = userContentController
//        configuration.allowsInlineMediaPlayback = true // Essential for JS control
//        configuration.mediaTypesRequiringUserActionForPlayback = [] // Allow autoplay if possible
//
//        let webView = WKWebView(frame: .zero, configuration: configuration)
//        webView.navigationDelegate = context.coordinator
//        webView.uiDelegate = context.coordinator // For JS alerts etc.
//        webView.isOpaque = false // Make transparent for Synthwave background
//        webView.backgroundColor = .clear
//        webView.scrollView.isScrollEnabled = false // Prevent scrolling embed
//
//        // Load the initial HTML containing the Spotify IFrame API script
//        let html = generateHTML()
//        //print("Loading HTML into WebView:\n\(html)") // Debug
//        webView.loadHTMLString(html, baseURL: nil)
//        context.coordinator.webView = webView // Link coordinator to webView
//        return webView
//    }
//
//    func updateUIView(_ webView: WKWebView, context: Context) {
//        // Load the specific Spotify URI once the JS API is ready
//        if context.coordinator.isApiReady && context.coordinator.lastLoadedUri != spotifyUri {
//             // Only load if URI changes and API is ready
//            context.coordinator.loadUri(spotifyUri ?? "No URI")
//            // Update state immediately if URI changes (even before JS confirms)
//             DispatchQueue.main.async {
//                if playbackState.currentUri != spotifyUri {
//                    playbackState.currentUri = spotifyUri ?? "No URI"
//                }
//            }
//        } else if !context.coordinator.isApiReady {
//            // Track desired URI if API loads *after* updateUIView is called
//            context.coordinator.updateDesiredUriBeforeReady(spotifyUri ?? "No URI")
//        }
//    }
//
//    static func dismantleUIView(_ uiView: WKWebView, coordinator: Coordinator) {
//        // Clean up when the view is removed
//        uiView.stopLoading()
//        uiView.configuration.userContentController.removeScriptMessageHandler(forName: "spotifyController")
//        coordinator.webView = nil
//    }
//
//    // --- Coordinator for WebView Delegate Methods & JS Communication ---
//    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
//        var parent: SpotifyEmbedWebView
//        weak var webView: WKWebView?
//        var isApiReady = false // Flag when Spotify JS API signals ready
//        var lastLoadedUri: String? = nil // Track the last URI sent to JS to prevent reloads
//        private var desiredUriBeforeReady: String? = nil // Handle race condition on startup
//
//        init(_ parent: SpotifyEmbedWebView) {
//            self.parent = parent
//        }
//
//        func updateDesiredUriBeforeReady(_ uri: String) {
//            // If updateUIView is called before the webview is ready, store the uri
//            if !isApiReady {
//                desiredUriBeforeReady = uri
//            }
//        }
//
//        // WKNavigationDelegate Methods
//        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//            print("Embed: Base HTML loaded successfully.")
//            // JS will post 'ready' when Spotify API is ready
//        }
//
//        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
//            print("Embed Fail (Navigation): \(error.localizedDescription)")
//        }
//
//        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
//            print("Embed Fail (Provisional Navigation): \(error.localizedDescription)")
//        }
//
//        // WKUIDelegate Methods (Optional: Handle JS alerts/prompts)
//        func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
//            print("ℹ️ Embed JS Alert: \(message)")
//            completionHandler() // Must call handler
//        }
//
//        // WKScriptMessageHandler: Receive messages from JavaScript
//        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
//            guard message.name == "spotifyController" else { return }
//
//            if let bodyDict = message.body as? [String: Any], let event = bodyDict["event"] as? String {
//                // Handle structured events {event: "...", data: {...}}
//                handleEvent(event: event, data: bodyDict["data"])
//            } else if let bodyString = message.body as? String, bodyString == "ready" {
//                // Handle simple 'ready' message from JS API callback
//                handleApiReady()
//            } else {
//                print("Embed: Received unknown message format: \(message.body)")
//            }
//        }
//
//        // Custom Message Handlers
//        private func handleApiReady() {
//            print("✅ Embed: Spotify IFrame API Ready.")
//            isApiReady = true
//
//             // If a URI was desired before API load, initialize controller now
//            if let initialUri = desiredUriBeforeReady ?? parent.spotifyUri {
//                 createSpotifyController(with: initialUri)
//                 desiredUriBeforeReady = nil // Clear it after use
//            }
//        }
//
//        private func handleEvent(event: String, data: Any?) {
//            // Process specific events sent from JS
//            // print("Embed JS Event: \(event), Data: \(String(describing: data))") // Verbose logging
//            switch event {
//            case "controllerCreated":
//                print("✅ Embed: JS Controller instance created.")
//            case "playbackUpdate":
//                if let updateData = data as? [String: Any] {
//                    updatePlaybackState(with: updateData)
//                }
//            case "error":
//                let errorMessage = (data as? [String: Any])?["message"] as? String ?? "\(data ?? "Unknown JS Error")"
//                print("❌ Embed JS Error: \(errorMessage)")
//                // Maybe update UI state to show player error
//            default:
//                print("❓ Embed: Unhandled JS event: \(event)")
//            }
//        }
//
//        private func updatePlaybackState(with data: [String: Any]) {
//             // Update the observable object on the main thread
//            DispatchQueue.main.async { [weak self] in
//                 // Ensure parent and state still exist
//                guard let self = self else { return }
//
//                if let isPaused = data["paused"] as? Bool {
//                    // Update playing state only if it differs
//                     if self.parent.playbackState.isPlaying == isPaused {
//                        self.parent.playbackState.isPlaying = !isPaused
//                    }
//                }
//                if let positionMilliseconds = data["position"] as? Double {
//                    let newPositionSeconds = positionMilliseconds / 1000.0
//                    // Update position only if it differs significantly to avoid jitter
//                    if abs(self.parent.playbackState.currentPosition - newPositionSeconds) > 0.1 {
//                        self.parent.playbackState.currentPosition = newPositionSeconds
//                    }
//                }
//                if let durationMilliseconds = data["duration"] as? Double {
//                    let newDurationSeconds = durationMilliseconds / 1000.0
//                    // Update duration if it differs or hasn't been set
//                    if abs(self.parent.playbackState.duration - newDurationSeconds) > 0.1 || self.parent.playbackState.duration == 0 {
//                        self.parent.playbackState.duration = newDurationSeconds
//                    }
//                }
//                 // Update current URI if JS reports a different one playing
//                 if let uri = data["uri"] as? String, self.parent.playbackState.currentUri != uri {
//                     self.parent.playbackState.currentUri = uri
//                 }
//            }
//        }
//
//        // --- Functions to Execute JavaScript ---
//
//        private func createSpotifyController(with initialUri: String) {
//            guard let webView = webView else { return }
//            guard isApiReady else {
//                print("⚠️ Spotify Embed Native: Tried to create controller before API was ready. URI stored: \(initialUri)")
//                updateDesiredUriBeforeReady(initialUri)
//                 return
//            }
//
//            guard lastLoadedUri == nil else { // Prevent multiple initializations
//                // If the desired URI changed *after* init started but *before* API ready, load it now
//                if let latestDesired = desiredUriBeforeReady ?? parent.spotifyUri,
//                   latestDesired != lastLoadedUri {
//                    print("🔄 Spotify Embed Native: API ready, loading changed URI: \(latestDesired)")
//                    loadUri(latestDesired)
//                    desiredUriBeforeReady = nil // Clear after use
//                } else {
//                    print("ℹ️ Spotify Embed Native: Controller already initialized or initialization attempt pending.")
//                }
//                return
//            }
//
//            print("🚀 Spotify Embed Native: Attempting to create controller for URI: \(initialUri)")
//            lastLoadedUri = initialUri // Mark as attempting to initialize
//
//            // JavaScript to create the embed controller instance
//            let script = """
//            console.log('Spotify Embed JS: Initial script block running.');
//            window.embedController = null; // Ensure clean state
//            const element = document.getElementById('embed-iframe');
//
//            if (!element) {
//                console.error('Spotify Embed JS: Could not find element embed-iframe!');
//                window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'HTML element embed-iframe not found' }});
//            } else if (!window.IFrameAPI) {
//                console.error('Spotify Embed JS: IFrameAPI is not loaded!');
//                window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'Spotify IFrame API not loaded' }});
//            } else {
//                console.log('Spotify Embed JS: Found element and IFrameAPI. Creating controller for URI: \(initialUri)');
//                // Options: width/height don't matter much if container sized in Swift
//                const options = { uri: '\(initialUri)', width: '100%', height: '80' };
//                const callback = (controller) => {
//                    // This callback is invoked by the Spotify API when the controller is ready
//                    if (!controller) {
//                         console.error('Spotify Embed JS: createController callback received null controller!');
//                         window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'JS createController callback received null controller' }});
//                         return; // Do not proceed
//                    }
//                    console.log('✅ Spotify Embed JS: Controller instance received.');
//                    window.embedController = controller; // Store globally in JS context
//                    window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'controllerCreated' });
//
//                    // --- Add Event Listeners ---
//                    controller.addListener('ready', () => {
//                        console.log('Spotify Embed JS: Controller Ready event.');
//                        // Optional: controller.play(); // Start playback immediately?
//                    });
//                    controller.addListener('playback_update', e => {
//                        // Send playback state (paused, position, duration, uri) to Swift
//                        window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'playbackUpdate', data: e.data });
//                    });
//                    // Error Listeners
//                    controller.addListener('account_error', e => {
//                         console.warn('Spotify Embed JS: Account Error:', e.data);
//                         window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'Account Error: ' + (e.data?.message ?? 'Premium required or login issue?') }});
//                    });
//                    controller.addListener('autoplay_failed', () => {
//                         console.warn('Spotify Embed JS: Autoplay failed');
//                         window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'Autoplay failed' }});
//                         controller.play(); // Attempt manual play if autoplay fails
//                    });
//                    controller.addListener('initialization_error', e => {
//                         console.error('Spotify Embed JS: Initialization Error:', e.data);
//                         window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'Initialization Error: ' + (e.data?.message ?? 'Failed to initialize player') }});
//                    });
//                };
//
//                try {
//                    console.log('Spotify Embed JS: Calling IFrameAPI.createController...');
//                    window.IFrameAPI.createController(element, options, callback);
//                } catch (e) {
//                     console.error('Spotify Embed JS: Error calling createController:', e);
//                     window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'JS exception during createController: ' + e.message }});
//                     // Cannot easily reset lastLoadedUri here due to potential concurrent changes.
//                     // Error state handling in UI will be important.
//                }
//            }
//            """
//            webView.evaluateJavaScript(script) { result, error in
//                if let error = error {
//                    print("⚠️ Spotify Embed Native: Error evaluating JS controller creation: \(error.localizedDescription)")
//                    // If the JS call fails, it might be a deeper issue.
//                    // Consider resetting lastLoadedUri to allow retry? Needs careful state management.
//                    // self.lastLoadedUri = nil // Potential retry, CAREFUL
//                } else {
//                    //print("JS Evaluation Result (createController): \(String(describing: result))") // Debug
//                }
//            }
//        }
//
//        func loadUri(_ uri: String) {
//             // Load a new track/album into the existing controller
//            guard let webView = webView, isApiReady, lastLoadedUri != nil, lastLoadedUri != uri else {
//                 //print("Embed Native: Load URI skipped. \(isApiReady), \(lastLoadedUri), \(uri)") // Debug why skipped
//                return
//            }
//            print("🚀 Embed Native: Loading URI: \(uri)")
//            lastLoadedUri = uri // Update the tracked URI immediately
//            let script = """
//            if (window.embedController) {
//                console.log('JS: Loading URI: \(uri)');
//                window.embedController.loadUri('\(uri)');
//                // Optional: Automatically play after loading new URI
//                 window.embedController.play();
//            } else {
//                console.error('JS: Controller instance (window.embedController) not found for loadUri.');
//                window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'JS: Controller instance not found for loadUri' }});
//            }
//            """
//            webView.evaluateJavaScript(script) { _, error in
//                if let error = error { print("⚠️ Embed Native: Error evaluating JS loadUri: \(error)") }
//            }
//        }
//    } // End Coordinator
//
//    // --- Generate Initial HTML ---
//    private func generateHTML() -> String {
//        """
//        <!DOCTYPE html>
//        <html>
//        <head>
//            <meta charset="utf-8">
//            <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
//            <title>Spotify Embed</title>
//            <style>
//                html, body { margin: 0; padding: 0; width: 100%; height: 100%; overflow: hidden; background-color: transparent; }
//                #embed-iframe { width: 100%; height: 100%; box-sizing: border-box; display: block; border: none; }
//            </style>
//        </head>
//        <body>
//            <!-- The div where the Spotify player will be embedded -->
//            <div id="embed-iframe"></div>
//
//            <!-- Load the Spotify IFrame Player API asynchronously -->
//            <script src="https://open.spotify.com/embed/iframe-api/v1" async></script>
//
//            <!-- Script to initialize the API and communicate with Swift -->
//            <script>
//                console.log('JS: Initial script loading.');
//                // This function will be called once the API script is loaded and ready
//                window.onSpotifyIframeApiReady = (IFrameAPI) => {
//                    console.log('✅ JS: Spotify IFrame API Ready.');
//                    window.IFrameAPI = IFrameAPI; // Store API object globally for access
//                    // Send message to Swift that the JS API is ready
//                    if (window.webkit?.messageHandlers?.spotifyController) {
//                        window.webkit.messageHandlers.spotifyController.postMessage("ready");
//                    } else {
//                        console.error('❌ JS: Native message handler (spotifyController) not found!');
//                    }
//                };
//
//                // Error handling if the API script itself fails to load
//                const scriptTag = document.querySelector('script[src*="iframe-api"]');
//                scriptTag.onerror = (event) => {
//                    console.error('❌ JS: Failed to load Spotify IFrame API script:', event);
//                    window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'Failed to load Spotify IFrame API script' }});
//                };
//            </script>
//        </body>
//        </html>
//        """
//    }
//}
//
//// MARK: - SwiftUI Views (Synthwave Themed)
//
//struct SpotifyAlbumListView: View {
//    @State private var searchQuery: String = ""
//    @State private var displayedAlbums: [AlbumItem] = []
//    @State private var isLoading: Bool = false
//    @State private var searchInfo: Albums? = nil // Holds pagination info + total
//    @State private var currentError: SpotifyAPIError? = nil
//    @State private var searchTask: Task<Void, Never>? // Task handle for debounce
//
//    var body: some View {
//        NavigationView {
//            ZStack {
//                // --- Synthwave Background ---
//                synthwaveBackgroundGradient.ignoresSafeArea() // Extend behind nav bar
//                // Optional: Add static grid lines or animated elements
//                Image("synthwave_grid_background") // Assumes you have this image asset
//                    .resizable()
//                    .scaledToFill()
//                    .opacity(0.08)
//                    .blendMode(.overlay) // Blend subtly
//                    .ignoresSafeArea()
//
//                // --- Main Content Area ---
//                VStack(spacing: 0) { // No vertical spacing for VStack
//                    // Optional: Header if needed, otherwise List takes full space
//                    // --- Content Area ---
//                    Group {
//                        if isLoading && displayedAlbums.isEmpty {
//                             ProgressView("Loading Grid...")
//                                .progressViewStyle(CircularProgressViewStyle(tint: synthwaveNeonCyan))
//                                .font(synthwaveFont(size: 14))
//                                .foregroundColor(synthwaveNeonCyan)
//                                .frame(maxHeight: .infinity) // Center vertically
//                        } else if let error = currentError {
//                             ErrorPlaceholderView(error: error) {
//                                Task { await performSearch(query: searchQuery, immediate: true) }
//                            }
//                            .frame(maxHeight: .infinity) // Center vertically
//                        } else if displayedAlbums.isEmpty {
//                             EmptyStatePlaceholderView(searchQuery: searchQuery)
//
//                                .frame(maxHeight: .infinity) // Center vertically
//                        } else {
//                             albumList // Display the themed list
//                        }
//                    } // End Group for conditional content
//                } // End VStack
//
//                // --- Ongoing Loading Indicator (Overlay for subsequent loads) ---
//                if isLoading && !displayedAlbums.isEmpty {
//                    VStack {
//                        HStack {
//                             Spacer()
//                             ProgressView()
//                                .progressViewStyle(CircularProgressViewStyle(tint: synthwaveNeonLime))
//                                .padding(.trailing, 8)
//                             Text("Syncing Data...")
//                                .font(synthwaveFont(size: 12, weight: .bold))
//                                .foregroundColor(synthwaveNeonLime)
//                             Spacer()
//                        }
//                        .padding(.vertical, 8)
//                        .padding(.horizontal, 20)
//                       // .background(.black.opacity(0.7).blur(radius: 5)) // Blurred background
//                        .clipShape(Capsule())
//                        .overlay(Capsule().stroke(synthwaveNeonLime.opacity(0.6), lineWidth: 1))
//                        .neonGlow(synthwaveNeonLime, radius: 8)
//                        .padding(.top, 8) // Position below navigation bar
//                        Spacer() // Push to top
//                    }
//                    .transition(.opacity.animation(.easeInOut))
//                }
//
//            } // End ZStack
//            .navigationTitle("SYNTHWAVE FM") // Themed Title
//            .navigationBarTitleDisplayMode(.inline)
//            // --- Themed Navigation Bar ---
//            .toolbarBackground(synthwaveDeepPurple.opacity(0.7), for: .navigationBar) // Translucent effect
//            .toolbarBackground(.visible, for: .navigationBar)
//            .toolbarColorScheme(.dark, for: .navigationBar) // Ensure white title/system items
//            .safeAreaInset(edge: .top) { Color.clear.frame(height: 0) } // Prevent large title overlap issues slightly
//
//            // --- Search Bar ---
//            .searchable(text: $searchQuery,
//                        placement: .navigationBarDrawer(displayMode: .always),
//                        prompt: Text("Enter Artist / Album...").foregroundColor(.gray.opacity(0.8)))
//            .onSubmit(of: .search) { Task { await performSearch(query: searchQuery, immediate: true) } }
//            .onChange(of: searchQuery) { newValue in
//                // Apply debounce logic
//                searchTask?.cancel() // Cancel previous task
//                currentError = nil // Clear error on new input
//                searchTask = Task {
//                    await performSearch(query: newValue) // Calls debounced version
//                }
//            }
//            .accentColor(synthwaveNeonPink) // Tint cursor/cancel button
//
//        } // End NavigationView
//        .accentColor(synthwaveNeonPink) // Global Tint for interactive elements
//    }
//
//    // --- Themed Album List View ---
//    private var albumList: some View {
//        List {
//            // --- Optional Themed Metadata Header ---
//            if let info = searchInfo, info.total > 0 {
//                SearchMetadataHeader(totalResults: info.total, limit: info.limit, offset: info.offset)
//                    .padding(.horizontal) // Horizontal padding
//                    .padding(.bottom, 5) // Space below header
//                    .listRowSeparator(.hidden)
//                    .listRowInsets(EdgeInsets())
//                    .listRowBackground(Color.clear)
//            }
//
//            // --- Album Cards ---
//            ForEach(displayedAlbums) { album in
//                NavigationLink(destination: AlbumDetailView(album: album)) {
//                     SynthwaveAlbumCard(album: album)
//                }
//                .listRowSeparator(.hidden)
//                .listRowInsets(EdgeInsets(top: 8, leading: 10, bottom: 8, trailing: 10)) // Consistent padding around cards
//                .listRowBackground(Color.clear) // Ensure row itself is transparent
//            }
//
//            // --- Pagination Loading Indicator ---
//            if let nextUrlString = searchInfo?.next, !nextUrlString.isEmpty {
//                 ProgressView()
//                    .progressViewStyle(CircularProgressViewStyle(tint: synthwaveNeonCyan))
//                    .frame(maxWidth: .infinity, alignment: .center)
//                    .padding(.vertical, 15)
//                    .listRowSeparator(.hidden)
//                    .listRowInsets(EdgeInsets())
//                    .listRowBackground(Color.clear)
//                    .onAppear {
//                         // TODO: Implement actual pagination fetch logic
//                        print("End of list reached, next URL: \(nextUrlString)")
//                        // Task { await loadMoreAlbums() }
//                    }
//            }
//        }
//        .listStyle(PlainListStyle()) // Remove default separators/insets
//        .background(Color.clear) // List background is transparent
//        .scrollContentBackground(.hidden) // Essential for ZStack background to show
//        //.refreshable { /* Optional: Add pull-to-refresh */ }
//    }
//
//    // --- Debounced Search Logic ---
//    private func performSearch(query: String, immediate: Bool = false) async {
//        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
//
//        // Handle empty query: Clear results
//        guard !trimmedQuery.isEmpty else {
//            await MainActor.run { displayedAlbums = []; searchInfo = nil; isLoading = false; currentError = nil }
//            return
//        }
//
//        // Apply debounce delay unless immediate flag is set
//        if !immediate {
//            do {
//                try await Task.sleep(for: .milliseconds(500)) // 500ms debounce
//                try Task.checkCancellation() // Ensure task wasn't cancelled during sleep
//            } catch {
//                print("Search task cancelled (debounce).")
//                return // Exit if cancelled
//            }
//        }
//
//        // Start loading state
//        await MainActor.run { isLoading = true }
//
//        do {
//            // Perform API call
//            let response = try await SpotifyAPIService.shared.searchAlbums(query: trimmedQuery, offset: 0) // Start from offset 0 for new search
//            try Task.checkCancellation() // Check again after network call
//
//            // Update UI on main thread
//            await MainActor.run {
//                displayedAlbums = response.albums.items
//                searchInfo = response.albums // Store pagination info
//                currentError = nil // Clear previous errors
//                isLoading = false
//            }
//        } catch is CancellationError {
//            print("Search task cancelled (during/after fetch).")
//            await MainActor.run { isLoading = false } // Ensure loading state is reset
//        } catch let apiError as SpotifyAPIError {
//            print("❌ API Error: \(apiError.localizedDescription)")
//            await MainActor.run {
//                displayedAlbums = [] // Clear results on error
//                searchInfo = nil
//                currentError = apiError
//                isLoading = false
//            }
//        } catch {
//            print("❌ Unexpected Error: \(error.localizedDescription)")
//            await MainActor.run {
//                displayedAlbums = []
//                searchInfo = nil
//                currentError = .networkError(error) // Wrap other errors
//                isLoading = false
//            }
//        }
//    }
//    // Placeholder for pagination - needs implementation
//    // private func loadMoreAlbums() async { ... }
//
//}
//
//// MARK: - Album Detail View (Themed)
//struct AlbumDetailView: View {
//    let album: AlbumItem
//    @State private var tracks: [Track] = []
//    @State private var isLoadingTracks: Bool = false
//    @State private var trackFetchError: SpotifyAPIError? = nil
//    @State private var selectedTrackUri: String? = nil // URI of the track selected for playback
//    @StateObject private var playbackState = SpotifyPlaybackState() // State for embedded player
//    @Environment(\.openURL) var openURL // For external link button
//
//    var body: some View {
//        ZStack {
//            // --- Synthwave Background ---
//            synthwaveBackgroundGradient.ignoresSafeArea()
//            Image("synthwave_grid_background") // Re-use grid backdrop if available
//                .resizable()
//                .scaledToFill()
//                .opacity(0.08)
//                .blendMode(.overlay)
//                .ignoresSafeArea()
//
//            List { // Use List for scrollable content
//                // --- Header Section ---
//                Section { SynthwaveAlbumHeaderView(album: album) }
//                    .listRowInsets(EdgeInsets()) // Remove default padding
//                    .listRowSeparator(.hidden)
//                    .listRowBackground(Color.clear)
//
//                // --- Player Section (Shows when a track is selected) ---
//                if let uriToPlay = selectedTrackUri {
//                    Section { SynthwaveEmbedPlayerView(playbackState: playbackState, spotifyUri: uriToPlay) }
//                        .listRowSeparator(.hidden)
//                        .listRowInsets(EdgeInsets(top: 15, leading: 0, bottom: 15, trailing: 0)) // Center player
//                        .listRowBackground(Color.clear)
//                        // Add transition for appearance
//                        .transition(.opacity.combined(with: .scale(scale: 0.95, anchor: .top)).animation(.easeInOut(duration: 0.35)))
//                }
//
//                // --- Tracks Section ---
//                Section {
//                    SynthwaveTracksSectionView(
//                        tracks: tracks,
//                        isLoading: isLoadingTracks,
//                        error: trackFetchError,
//                        selectedTrackUri: $selectedTrackUri, // Pass binding down
//                        retryAction: { Task { await fetchTracks() } }
//                    )
//                } header: { // Themed Section Header
//                    Text("T R A C K L I S T") // Spaced out text
//                        .font(synthwaveFont(size: 14, weight: .bold))
//                        .foregroundColor(synthwaveNeonLime)
//                        .tracking(3) // Letter spacing for retro feel
//                        .neonGlow(synthwaveNeonLime, radius: 6)
//                        .frame(maxWidth: .infinity, alignment: .center)
//                        .padding(.vertical, 10)
//                         .background(synthwaveDeepPurple.opacity(0.5).blur(radius: 3)) // Subtle bg
//                }
//                .listRowInsets(EdgeInsets()) // Remove default padding for track rows
//                .listRowSeparator(.hidden)
//                .listRowBackground(Color.clear)
//
//                // --- External Link Section ---
//                if let spotifyURL = URL(string: album.external_urls.spotify ?? "") {
//                    Section {
//                        SynthwaveButton( // Use themed button
//                            text: "OPEN IN SPOTIFY",
//                            action: { openExternalUrl(spotifyURL) },
//                            primaryColor: synthwaveNeonLime,
//                            secondaryColor: Color.green // Spotify-ish green
//                        )
//                        .padding(.horizontal) // Add padding around button inside section
//                    }
//                    .listRowInsets(EdgeInsets(top: 20, leading: 0, bottom: 20, trailing: 0))
//                    .listRowSeparator(.hidden)
//                    .listRowBackground(Color.clear)
//                }
//
//            } // End List
//            .listStyle(PlainListStyle())
//            .background(Color.clear) // List itself is transparent
//            .scrollContentBackground(.hidden) // Ensure ZStack background shows
//
//        } // End ZStack
//        .navigationTitle(album.name)
//        .navigationBarTitleDisplayMode(.inline)
//        // Consistent Synthwave Navigation Bar Theme
//        .toolbarBackground(synthwaveDeepPurple.opacity(0.7), for: .navigationBar)
//        .toolbarBackground(.visible, for: .navigationBar)
//        .toolbarColorScheme(.dark, for: .navigationBar)
//        .task { await fetchTracks() } // Fetch tracks on appear
//        .animation(.easeInOut(duration: 0.3), value: selectedTrackUri) // Animate player appearance change
//        .refreshable { await fetchTracks(forceReload: true) } // Allow pull-to-refresh
//    }
//
//    // --- Fetch Tracks Logic (Unchanged functionally) ---
//    private func fetchTracks(forceReload: Bool = false) async {
//        // Only load if forced, or if tracks are empty/errored
//        guard forceReload || tracks.isEmpty || trackFetchError != nil else { return }
//
//        await MainActor.run { isLoadingTracks = true; trackFetchError = nil }
//        do {
//            let response = try await SpotifyAPIService.shared.getAlbumTracks(albumId: album.id)
//            try Task.checkCancellation()
//            await MainActor.run {
//                self.tracks = response.items.sorted { $0.disc_number < $1.disc_number || ($0.disc_number == $1.disc_number && $0.track_number < $1.track_number) } // Sort tracks
//                self.isLoadingTracks = false
//            }
//        } catch is CancellationError {
//            await MainActor.run { isLoadingTracks = false } // Reset loading on cancellation
//        } catch let apiError as SpotifyAPIError {
//            await MainActor.run {
//                self.trackFetchError = apiError
//                self.isLoadingTracks = false
//                self.tracks = [] // Clear tracks on error
//            }
//        } catch {
//            await MainActor.run {
//                self.trackFetchError = .networkError(error)
//                self.isLoadingTracks = false
//                self.tracks = []
//            }
//        }
//    }
//
//    // --- Helper to Open External URL ---
//    private func openExternalUrl(_ url: URL) {
//        print("Attempting to open external URL: \(url)")
//        openURL(url) { accepted in
//            if !accepted {
//                print("⚠️ Warning: URL scheme \(url.scheme ?? "") could not be opened.")
//                // Consider showing an alert to the user in a real app
//            }
//        }
//    }
//}
//
//// MARK: - Reusable Themed Components
//
//struct AlbumImageView: View { // Added slight Synthwave touch
//    let url: URL?
//
//    var body: some View {
//        AsyncImage(url: url) { phase in
//            ZStack { // Use ZStack to layer placeholder styling
//                // Background for empty/failure states
//                RoundedRectangle(cornerRadius: 8)
//                    .fill(LinearGradient(colors: [synthwaveMidPurple.opacity(0.3), synthwaveDeepPurple.opacity(0.5)], startPoint: .top, endPoint: .bottom))
//                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(synthwaveNeonCyan.opacity(0.3), lineWidth: 1)) // Subtle border
//
//                // Content based on phase
//                switch phase {
//                case .empty:
//                    ProgressView().tint(synthwaveNeonCyan)
//                case .success(let image):
//                    image.resizable()
//                        .aspectRatio(contentMode: .fill) // Ensure image fills the frame before clipping
//                case .failure:
//                    Image(systemName: "wifi.exclamationmark") // Icon indicating load failure
//                        .resizable().scaledToFit()
//                        .foregroundColor(synthwaveNeonPink.opacity(0.6))
//                        .padding(15) // Padding around icon
//                @unknown default:
//                    EmptyView()
//                }
//            }
//        }
//        .clipShape(RoundedRectangle(cornerRadius: 8)) // Clip the final view (including image)
//    }
//}
//
//struct SearchMetadataHeader: View { // Themed Header
//    let totalResults: Int
//    let limit: Int
//    let offset: Int
//
//    var body: some View {
//        HStack {
//            // Use a more retro icon, maybe 'number' or 'list.bullet'
//            Label("\(totalResults) Results", systemImage: "number")
//            Spacer()
//            if totalResults > limit {
//                // Display showing range (e.g., 1-20)
//                Text("Showing \(offset + 1)-\(min(offset + limit, totalResults))")
//            }
//        }
//        .font(synthwaveFont(size: 11, weight: .medium))
//        .foregroundColor(synthwaveNeonCyan.opacity(0.85))
//        .padding(.horizontal, 15)
//        .padding(.vertical, 6)
//        //.background(.black.opacity(0.2).blur(radius: 3)) // Subtle dark background
//        .clipShape(Capsule())
//        .overlay(Capsule().stroke(synthwaveNeonCyan.opacity(0.4), lineWidth: 1)) // Neon outline
//    }
//}
//
//// --- Synthwave Themed Button ---
//struct SynthwaveButton: View {
//    let text: String
//    let action: () -> Void
//    var primaryColor: Color = synthwaveNeonPink
//    var secondaryColor: Color = synthwaveMidPurple // Gradient end color
//    var iconName: String? = nil
//
//    @State private var isPressed: Bool = false // For press effect
//
//    var body: some View {
//        Button(action: action) {
//            HStack(spacing: 10) {
//                if let iconName = iconName {
//                    Image(systemName: iconName)
//                        .font(.body.weight(.semibold))
//                }
//                Text(text)
//                    .tracking(1.5) // Letter spacing
//            }
//            .font(synthwaveFont(size: 15, weight: .bold))
//            .padding(.horizontal, 25)
//            .padding(.vertical, 12)
//            .frame(maxWidth: .infinity) // Expand horizontally
//            .background(
//                LinearGradient(colors: [primaryColor, secondaryColor], startPoint: .leading, endPoint: .trailing)
//                    .overlay( // Add subtle grid overlay
//                        Image("scanlines_overlay") // Assumes you have this transparent PNG
//                            .resizable()
//                            .scaledToFill()
//                            .blendMode(.overlay)
//                            .opacity(0.1)
//                    )
//            )
//            .foregroundColor(synthwaveDeepPurple) // Dark text contrasts well
//            .clipShape(Capsule())
//            .overlay(Capsule().stroke(Color.white.opacity(0.4), lineWidth: 1)) // Highlight edge
//            .scaleEffect(isPressed ? 0.97 : 1.0) // Scale down on press
//            .neonGlow(primaryColor, radius: isPressed ? 15 : 10) // Increase glow on press
//        }
//        .buttonStyle(PlainButtonStyle()) // Use Plain style to allow custom background/effects
//        // Add gesture for press effect
//        .gesture(
//            DragGesture(minimumDistance: 0)
//                .onChanged { _ in isPressed = true }
//                .onEnded { _ in isPressed = false }
//        )
//        .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed) // Bouncy animation
//    }
//}
//
//// --- Synthwave Album List Card ---
//struct SynthwaveAlbumCard: View {
//    let album: AlbumItem
//
//    var body: some View {
//        ZStack {
//            // Background Layer: Dark base with subtle gradient/noise
//            RoundedRectangle(cornerRadius: 15, style: .continuous)
//                .fill(synthwaveDeepPurple.opacity(0.8)) // Slightly transparent base
//                .background(.ultraThinMaterial) // Frosted glass effect
//                .overlay( // Optional subtle pattern/noise
//                    Image("subtle_noise_pattern") // Assume you have this asset
//                        .resizable().scaledToFill().opacity(0.05).blendMode(.overlay)
//                )
//                .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
//            // Neon Outline
//                .overlay(
//                    RoundedRectangle(cornerRadius: 15, style: .continuous)
//                        .stroke(LinearGradient(colors: [synthwaveNeonCyan.opacity(0.7), synthwaveNeonPink.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1.5)
//                )
//                .neonGlow(synthwaveNeonCyan, radius: 8) // Subtle glow
//
//            // Content Layer
//            HStack(spacing: 15) {
//                AlbumImageView(url: album.listImageURL) // Use themed image view
//                    .frame(width: 85, height: 85) // Consistent size
//                    // No extra border needed if AlbumImageView has one
//
//                VStack(alignment: .leading, spacing: 6) {
//                    Text(album.name)
//                        .font(synthwaveFont(size: 15, weight: .bold))
//                        .foregroundColor(.white)
//                        .lineLimit(2) // Allow two lines for longer names
//
//                    Text(album.formattedArtists)
//                        .font(synthwaveFont(size: 13))
//                        .foregroundColor(synthwaveNeonLime.opacity(0.9)) // Accent for artist
//                        .lineLimit(1)
//
//                    Spacer() // Push info to top and bottom
//
//                    HStack(spacing: 8) {
//                        // Album Type Label
//                        Label(album.album_type.capitalized, systemImage: iconForAlbumType(album.album_type))
//                            .font(synthwaveFont(size: 10, weight: .medium))
//                            .foregroundColor(.white.opacity(0.7))
//                            .padding(.horizontal, 8)
//                            .padding(.vertical, 3)
//                            .background(Color.white.opacity(0.1), in: Capsule()) // Subtle capsule
//
//                        Text("•")
//                             .foregroundColor(.white.opacity(0.5))
//
//                        Text(album.formattedReleaseDate())
//                            .font(synthwaveFont(size: 10, weight: .medium))
//                            .foregroundColor(.white.opacity(0.7))
//                    }
//                    // Optional: Track Count - might make card too busy
//                    // Text("\(album.total_tracks) Tracks")
//                    //    .font(synthwaveFont(size: 10)).foregroundColor(.white.opacity(0.6))
//
//                } // End Text VStack
//                .frame(maxWidth: .infinity, alignment: .leading) // Allow text col to expand
//
//            } // End HStack
//            .padding(12) // Padding inside the card
//
//        } // End ZStack
//        .frame(height: 110) // Define fixed height for list consistency
//    }
//
//    // Helper for icons based on album type
//    private func iconForAlbumType(_ type: String) -> String {
//        switch type.lowercased() {
//        case "album": return "opticaldisc" // Keep standard icons
//        case "single": return "record.circle"
//        case "compilation": return "list.star"
//        default: return "music.note"
//        }
//    }
//}
//
//// --- Synthwave Detail View Header ---
//struct SynthwaveAlbumHeaderView: View {
//    let album: AlbumItem
//
//    var body: some View {
//        VStack(spacing: 18) {
//            AlbumImageView(url: album.bestImageURL)
//                .aspectRatio(1.0, contentMode: .fit) // Keep album art square
//                .clipShape(RoundedRectangle(cornerRadius: 15)) // Match card rounding
//                .overlay( // Add a stronger neon gradient border
//                    RoundedRectangle(cornerRadius: 15)
//                        .stroke(LinearGradient(colors: [synthwaveNeonPink, synthwaveNeonCyan], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 2)
//                )
//                .neonGlow(synthwaveNeonPink, radius: 18) // Stronger glow for main image
//                .padding(.horizontal, 60) // More padding to center smaller image
//                .shadow(color: .black.opacity(0.4), radius: 10, y: 5) // Add shadow
//
//            // --- Text Details ---
//            VStack(spacing: 6) {
//                Text(album.name.uppercased()) // Uppercase for retro feel
//                    .font(synthwaveFont(size: 24, weight: .heavy)) // Heavier weight
//                    .tracking(1.5) // Letter spacing
//                    .foregroundColor(.white)
//                    .multilineTextAlignment(.center)
//                    .shadow(color: .black.opacity(0.6), radius: 3, y: 2) // More pronounced shadow
//
//                Text("BY \(album.formattedArtists.uppercased())")
//                    .font(synthwaveFont(size: 16, weight: .bold))
//                    .foregroundColor(synthwaveNeonLime) // Use lime accent
//                    .tracking(1)
//                    .multilineTextAlignment(.center)
//
//                // Combined Type and Date
//                Text("\(album.album_type.uppercased()) • \(album.formattedReleaseDate()) • \(album.total_tracks) TRACKS")
//                    .font(synthwaveFont(size: 12, weight: .medium))
//                    .foregroundColor(.white.opacity(0.75))
//                    .tracking(0.8)
//            }
//            .padding(.horizontal)
//
//        }
//        .padding(.vertical, 30) // Generous vertical padding for header section
//    }
//}
//
//// --- Synthwave Embedded Player Container ---
//struct SynthwaveEmbedPlayerView: View {
//    @ObservedObject var playbackState: SpotifyPlaybackState
//    let spotifyUri: String
//
//    var body: some View {
//        VStack(spacing: 10) { // Space between WebView and status
//            SpotifyEmbedWebView(playbackState: playbackState, spotifyUri: spotifyUri)
//                .frame(height: 80) // Standard embed height
//                // Player Frame Styling
//                .background(
//                    synthwaveDeepPurple.opacity(0.6) // Dark background
//                        .overlay(.ultraThinMaterial) // Frosted glass
//                        .clipShape(RoundedRectangle(cornerRadius: 12))
//                        // Neon border that changes with play state
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 12)
//                                .stroke(LinearGradient(colors: gradientColors, startPoint: .leading, endPoint: .trailing), lineWidth: 1.5)
//                        )
//                        .neonGlow(glowColor, radius: 10) // Glow color based on state
//                )
//                .padding(.horizontal) // Padding around the player
//
//            // --- Playback Status Bar ---
//            HStack {
//                let statusText = playbackState.isPlaying ? "PLAYING ▶" : "PAUSED ⏸" // Use symbols
//                let statusColor = playbackState.isPlaying ? synthwaveNeonLime : synthwaveNeonPink
//
//                Text(statusText)
//                    .font(synthwaveFont(size: 11, weight: .bold))
//                    .foregroundColor(statusColor)
//                    .tracking(1.5)
//                    .neonGlow(statusColor, radius: 5)
//                    .frame(width: 90, alignment: .leading) // Fixed width
//
//                Spacer()
//
//                // Time Display
//                if playbackState.duration > 0.1 {
//                    Text("\(formatTime(playbackState.currentPosition)) / \(formatTime(playbackState.duration))")
//                        .font(synthwaveFont(size: 11, weight: .medium))
//                        .foregroundColor(.white.opacity(0.8))
//                } else {
//                     Text("--:-- / --:--") // Placeholder time
//                        .font(synthwaveFont(size: 11, weight: .medium))
//                        .foregroundColor(.white.opacity(0.6))
//                }
//            }
//            .padding(.horizontal, 25) // Align with player padding
//
//        } // End VStack
//        .animation(.easeInOut(duration: 0.3), value: playbackState.isPlaying) // Animate glow/color changes
//    }
//
//    // Helper for dynamic border/glow based on play state
//    private var gradientColors: [Color] {
//        playbackState.isPlaying ? [synthwaveNeonLime, synthwaveNeonCyan] : [synthwaveNeonPink, synthwaveMidPurple]
//    }
//    private var glowColor: Color {
//        playbackState.isPlaying ? synthwaveNeonLime : synthwaveNeonPink
//    }
//
//    // Time formatting helper (unchanged)
//    private func formatTime(_ time: Double) -> String {
//        let totalSeconds = max(0, Int(time))
//        let minutes = totalSeconds / 60
//        let seconds = totalSeconds % 60
//        return String(format: "%d:%02d", minutes, seconds)
//    }
//}
//
//// --- Synthwave Tracks Section View ---
//struct SynthwaveTracksSectionView: View {
//    let tracks: [Track]
//    let isLoading: Bool
//    let error: SpotifyAPIError?
//    @Binding var selectedTrackUri: String? // Binding to update selection
//    let retryAction: () -> Void
//
//    var body: some View {
//        // Content depends on loading/error state
//        if isLoading {
//            HStack { // Center progress view
//                Spacer()
//                ProgressView()
//                    .progressViewStyle(CircularProgressViewStyle(tint: synthwaveNeonCyan))
//                Text("Loading Tracks...")
//                    .font(synthwaveFont(size: 12))
//                    .foregroundColor(synthwaveNeonCyan.opacity(0.8))
//                    .padding(.leading, 5)
//                Spacer()
//            }
//            .padding(.vertical, 30) // Give loading indicator space
//        } else if let error = error {
//            ErrorPlaceholderView(error: error, retryAction: retryAction)
//                .padding(.vertical, 20)
//        } else if tracks.isEmpty {
//             Text("A L B U M   E M P T Y")
//                .font(synthwaveFont(size: 14, weight: .bold))
//                .foregroundColor(synthwaveNeonPink.opacity(0.7))
//                .tracking(2)
//                .frame(maxWidth: .infinity, alignment: .center)
//                .padding(.vertical, 30)
//        } else {
//            // Display track rows using ForEach directly in the List Section
//            // No extra VStack needed here
//            ForEach(tracks) { track in
//                 SynthwaveTrackRowView(
//                    track: track,
//                    isSelected: track.uri == selectedTrackUri // Determine if row is selected
//                )
//                .contentShape(Rectangle()) // Make entire row tappable
//                .onTapGesture {
//                    // Update the selected URI (triggers player update via binding)
//                    selectedTrackUri = track.uri
//                }
//                 // Subtle background highlight for the selected track
//                 .listRowBackground(
//                    track.uri == selectedTrackUri ? synthwaveNeonCyan.opacity(0.1) : Color.clear
//                 )
//            }
//        }
//    }
//}
//
//// --- Synthwave Track Row View ---
//struct SynthwaveTrackRowView: View {
//    let track: Track
//    let isSelected: Bool
//
//    var body: some View {
//        HStack(spacing: 12) {
//            // --- Track Number or Play Icon ---
//             // Show waveform if selected, else track number
//             // Show play icon if selected AND playing (requires playbackState access)
//             // Simplified: Show waveform if selected
//            Image(systemName: isSelected ? "waveform" : "\(track.track_number).circle") // Use SF Symbols
//                .font(.system(size: isSelected ? 18 : 14)) // Larger icon when selected
//                .foregroundColor(isSelected ? synthwaveNeonCyan : .white.opacity(0.6))
//                .frame(width: 30, alignment: .center)
//                .padding(.leading, 5) // Adjust leading padding
//
//            // --- Track Info ---
//            VStack(alignment: .leading, spacing: 3) {
//                Text(track.name)
//                    .font(synthwaveFont(size: 15, weight: isSelected ? .bold : .regular))
//                    .foregroundColor(isSelected ? synthwaveNeonCyan : .white) // Highlight selected track name
//                    .lineLimit(1)
//
//                Text(track.formattedArtists)
//                    .font(synthwaveFont(size: 12))
//                    .foregroundColor(.white.opacity(0.7))
//                    .lineLimit(1)
//            }
//
//            Spacer() // Push duration to the right
//
//            // --- Duration ---
//            Text(track.formattedDuration)
//                .font(synthwaveFont(size: 12, weight: .medium))
//                .foregroundColor(isSelected ? .white : .white.opacity(0.7)) // Slightly brighter duration if selected
//                .frame(width: 45, alignment: .trailing) // Fixed width for alignment
//                .padding(.trailing, 15)
//
//        } // End HStack
//        .padding(.vertical, 10) // Vertical padding for row height and tap area
//        .padding(.horizontal, 5) // Horizontal padding within the row
//         // Add subtle bottom border for separation, highlight if selected
//         .overlay(alignment: .bottom) {
//             Rectangle()
//                 .frame(height: 0.5)
//                 .foregroundColor(isSelected ? synthwaveNeonCyan.opacity(0.5) : Color.white.opacity(0.1))
//                 .padding(.leading, 45) // Align border start after icon/number
//         }
//        .animation(.easeInOut(duration: 0.2), value: isSelected) // Animate selection changes
//    }
//}
//
//// MARK: - Themed Placeholder Views
//
//struct ErrorPlaceholderView: View { // Synthwave Themed
//    let error: SpotifyAPIError
//    let retryAction: (() -> Void)?
//
//    var body: some View {
//        VStack(spacing: 25) {
//            Image(systemName: iconName) // Use dynamic icon based on error
//                .font(.system(size: 70))
//                .foregroundStyle( // Apply neon gradient
//                    LinearGradient(
//                        gradient: Gradient(colors: [synthwaveNeonPink, synthwaveAccentOrange]),
//                        startPoint: .topLeading,
//                        endPoint: .bottomTrailing
//                    )
//                )
//                .neonGlow(synthwaveNeonPink, radius: 20) // Strong glow
//                .padding(.bottom, 10)
//
//            Text("SYSTEM ERROR") // Themed title
//                .font(synthwaveFont(size: 26, weight: .heavy))
//                .tracking(2)
//                .foregroundColor(.white)
//                .shadow(color: .black.opacity(0.5), radius: 2, y: 1)
//
//            Text(errorMessage) // Use dynamic message
//                .font(synthwaveFont(size: 15))
//                .foregroundColor(.white.opacity(0.8))
//                .multilineTextAlignment(.center)
//                .padding(.horizontal, 20)
//                .lineSpacing(5)
//
//            // Show retry button only if applicable
////            if error != .invalidToken, let retry = retryAction {
////                SynthwaveButton( // Use themed button
////                    text: "REINITIALIZE",
////                    action: retry,
////                    primaryColor: synthwaveNeonLime,
////                    secondaryColor: synthwaveNeonCyan,
////                    iconName: "arrow.clockwise.circle.fill"
////                )
////                .padding(.top, 15)
////            } else if error == .invalidToken {
//                 Text("ACCESS DENIED: Check Spotify Token.")
//                    .font(synthwaveFont(size: 12))
//                    .foregroundColor(synthwaveNeonPink.opacity(0.8))
//                    .multilineTextAlignment(.center)
//                    .padding(.top, 10)
////            }
//        }
//        .padding(30)
//         // Add a subtle background container for the error message
//         .background(
//            RoundedRectangle(cornerRadius: 15)
//                .fill(synthwaveDeepPurple.opacity(0.5))
//                .overlay(.ultraThinMaterial) // Frosted glass
//                .overlay(RoundedRectangle(cornerRadius: 15).stroke(synthwaveNeonPink.opacity(0.4), lineWidth: 1))
//         )
//        .padding(20) // Padding around the container
//    }
//
//    // --- Dynamic Icon and Message Logic (Unchanged) ---
//    private var iconName: String {
//        switch error {
//        case .invalidToken: return "key.slash.fill" // More filled look
//        case .networkError: return "wifi.exclamationmark"
//        case .invalidResponse, .decodingError, .missingData: return "exclamationmark.triangle.fill"
//        case .invalidURL: return "link.badge.plus" // Keep this icon
//        }
//    }
//    private var errorMessage: String {
//        switch error {
//        case .invalidToken: return "Authentication Corrupted. Verify Spotify Access Token."
//        case .networkError: return "Network Signal Lost. Check Connection."
//        case .invalidResponse(let code, _): return "Server Transmission Error (\(code)). Retry Sequence Later."
//        case .decodingError: return "Data Stream Unreadable. Response Structure Compromised."
//        case .missingData: return "Core Data Fragments Missing From Response."
//        default: return error.localizedDescription // General fallback
//        }
//    }
//}
//
//struct EmptyStatePlaceholderView: View { // Synthwave Themed
//    let searchQuery: String
//
//    var body: some View {
//        VStack(spacing: 25) {
//            // Use a more thematic icon or image
//            Image(systemName: isInitialState ? "music.mic.circle.fill" : "magnifyingglass.circle.fill")
//                 .font(.system(size: 90))
//                 .foregroundStyle(
//                     LinearGradient(
//                        colors: [synthwaveNeonCyan, synthwaveNeonLime],
//                        startPoint: .topLeading,
//                        endPoint: .bottomTrailing
//                     )
//                 )
//                 .neonGlow(synthwaveNeonCyan, radius: 20)
//                 .padding(.bottom, 15)
//
//            Text(title)
//                .font(synthwaveFont(size: 26, weight: .heavy))
//                .tracking(2)
//                .foregroundColor(.white)
//                .shadow(color: .black.opacity(0.4), radius: 2, y: 1)
//
//            Text(messageAttributedString) // Use AttributedString for potential emphasis
//                .font(synthwaveFont(size: 15))
//                .foregroundColor(.white.opacity(0.85))
//                .multilineTextAlignment(.center)
//                .padding(.horizontal, 30)
//                .lineSpacing(5)
//        }
//        .padding(30)
//        // No extra background needed if main view background is themed
//    }
//
//    // --- Dynamic Content Logic (Unchanged except Attributed String) ---
//    private var isInitialState: Bool { searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
//    // Icon name updated in body directly
//    private var title: String { isInitialState ? "AWAITING INPUT" : "NO SIGNAL" } // Themed Titles
//
//    private var messageAttributedString: AttributedString {
//        var message: AttributedString
//        if isInitialState {
//            message = AttributedString("Engage terminal: Input album or artist query above...")
//        } else {
//            // Use AttributedString's Markdown capabilities for bold query
//            do {
//                let query = searchQuery.isEmpty ? "TARGET" : searchQuery // Handle empty query
//                // Use backticks for inline code/query feel
//                message = try AttributedString(markdown: "Signal lost for `\(query)`.\nModify search parameters and re-scan.")
//            } catch {
//                // Fallback if markdown fails
//                message = AttributedString("Signal lost for \"\(searchQuery)\". Modify search parameters and re-scan.")
//            }
//        }
//        // Apply consistent font and color to the entire string
//        message.font = synthwaveFont(size: 15)
//        message.foregroundColor = .white.opacity(0.85)
//        // Optionally target and style the bold part or backticks for more emphasis if needed
//        // (Requires more complex AttributedString range manipulation)
//        return message
//    }
//}
//
//// MARK: - App Entry Point
//
////@main
////struct SynthwaveSpotifyApp: App {
////    init() {
////        // --- Critical Token Check on Startup ---
////        if placeholderSpotifyToken == "YOUR_SPOTIFY_BEARER_TOKEN_HERE" {
////            print("🚨🌃 FATAL STARTUP WARNING: Spotify Bearer Token missing!")
////            print("👉 FIX: Replace 'YOUR_SPOTIFY_BEARER_TOKEN_HERE' in SynthwaveSpotifyApp.swift")
////            print("👉 API calls will fail until this is corrected.")
////        }
////
////        // --- Global UI Appearance (Optional - for elements not directly styled) ---
////        // Set global tint color for things like system alerts, context menus, etc.
////        // UIView.appearance().tintColor = UIColor(synthwaveNeonPink) // Using UIKit appearance bridge
////
////        // Customize Navigation Bar Appearance Globally (if preferred over modifier)
////        let appearance = UINavigationBarAppearance()
////        appearance.configureWithOpaqueBackground()
////        appearance.backgroundColor = UIColor(synthwaveDeepPurple.opacity(0.7)) // Translucent look
////        appearance.titleTextAttributes = [
////            .foregroundColor: UIColor.white,
////            .font: UIFont(name: "Menlo-Bold", size: 18) ?? UIFont.boldSystemFont(ofSize: 18) // Synthwave font
////        ]
////        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white] // For large titles if used
////        // Apply blur effect
////        appearance.backgroundEffect = UIBlurEffect(style: .dark)
////
////        // Apply the appearance settings
////        UINavigationBar.appearance().standardAppearance = appearance
////        UINavigationBar.appearance().scrollEdgeAppearance = appearance // For scrolled state
////        UINavigationBar.appearance().compactAppearance = appearance
////        UINavigationBar.appearance().tintColor = UIColor(synthwaveNeonPink) // System button colors
////    }
////
////    var body: some Scene {
////        WindowGroup {
////            SpotifyAlbumListView()
////                .preferredColorScheme(.dark) // Enforce dark mode for theme
////        }
////    }
////}
//
//// MARK: - Preview Providers (Adapted for Themed Views)
//
//struct SpotifyAlbumListView_Synthwave_Previews: PreviewProvider {
//    static var previews: some View {
//        SpotifyAlbumListView()
//            .preferredColorScheme(.dark)
//    }
//}
//
//struct SynthwaveAlbumCard_Previews: PreviewProvider {
//    // Reusing mock data
//    static let mockArtist = Artist(id: "artist1", external_urls: nil, href: "", name: "Kraftwerk Mock", type: "artist", uri: "")
//    static let mockImage = SpotifyImage(height: 300, url: "https://i.scdn.co/image/ab67616d00001e02d5edef6af5d6b7038715843c", width: 300) // Example Kraftwerk image
//    static let mockAlbumItem = AlbumItem(id: "album1", album_type: "album", total_tracks: 8, available_markets: ["US"], external_urls: ExternalUrls(spotify: ""), href: "", images: [mockImage], name: "The Man-Machine [Synthwave Preview]", release_date: "1978", release_date_precision: "year", type: "album", uri: "spotify:album:3P6rmpgqbG556QdRBPZzA6", artists: [mockArtist])
//
//    static var previews: some View {
//        SynthwaveAlbumCard(album: mockAlbumItem)
//            .padding()
//            .background(synthwaveBackgroundGradient)
//            .previewLayout(.fixed(width: 380, height: 150)) // Adjust size to fit card
//            .preferredColorScheme(.dark)
//    }
//}
//
//struct AlbumDetailView_Synthwave_Previews: PreviewProvider {
//    static let mockArtist = Artist(id: "artist1", external_urls: nil, href: "", name: "Miles Davis Retro", type: "artist", uri: "")
//    static let mockImage = SpotifyImage(height: 640, url: "https://i.scdn.co/image/ab67616d0000b2737ab89c25093ea3787b1995b4", width: 640) // Kind of Blue
//    static let mockAlbum = AlbumItem(id: "1weenld61qoidwYuZ1GESA", album_type: "album", total_tracks: 5, available_markets: ["US", "GB"], external_urls: ExternalUrls(spotify: "https://open.spotify.com/album/1weenld61qoidwYuZ1GESA"), href: "", images: [mockImage], name: "Kind Of Blue (Synthwave)", release_date: "1959-08-17", release_date_precision: "day", type: "album", uri: "spotify:album:1weenld61qoidwYuZ1GESA", artists: [mockArtist])
//
//    static var previews: some View {
//        NavigationView { // Embed in NavView for realistic preview
//            AlbumDetailView(album: mockAlbum)
//        }
//        .preferredColorScheme(.dark)
//    }
//}
//
//// Add previews for other themed components if desired (Button, Placeholders etc.)
//// Example for Button:
//struct SynthwaveButton_Previews: PreviewProvider {
//    static var previews: some View {
//        VStack(spacing: 20) {
//            SynthwaveButton(text: "PRIMARY ACTION", action: {}, primaryColor: synthwaveNeonPink, secondaryColor: synthwaveMidPurple, iconName: "play.fill")
//            SynthwaveButton(text: "SECONDARY", action: {}, primaryColor: synthwaveNeonCyan, secondaryColor: Color.blue, iconName: "info.circle")
//            SynthwaveButton(text: "RETRY", action: {}, primaryColor: synthwaveNeonLime, secondaryColor: Color.green, iconName: "arrow.clockwise")
//        }
//        .padding()
//        .background(synthwaveBackgroundGradient)
//        .previewLayout(.sizeThatFits)
//        .preferredColorScheme(.dark)
//    }
//}
//
//// Add placeholder image assets to your project:
//// - "synthwave_grid_background.png" (a tileable grid pattern)
//// - "subtle_noise_pattern.png" (a subtle noise texture)
//// - "scanlines_overlay.png" (transparent scanlines effect)
