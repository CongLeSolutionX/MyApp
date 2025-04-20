//
//  Retro_1990s_Party_Aesthetic_Theme_Look_V1.swift
//  MyApp
//
//  Created by Cong Le on 4/20/25.
//

//
//  SpotifyRetroApp.swift // Single file implementation
//  MyApp
//
//  Created by Cong Le on [Your Current Date] - Synthesized Version
//

import SwiftUI
@preconcurrency import WebKit // Ensure @preconcurrency is needed for your Xcode version
import Foundation // For URLSession, DateFormatter etc.

// MARK: - Retro 1990s Party Theme Constants & Modifiers

// -- Colors --
let retroDeepPurple = Color(hex: "240D3C") // Darker purple background
let retroMidPurple = Color(hex: "4A1B6F")
let retroNeonPink = Color(hex: "FF1F8F")    // Vibrant Pink
let retroNeonCyan = Color(hex: "1FFCFC")    // Bright Cyan/Aqua
let retroNeonLime = Color(hex: "B0FC38")    // Electric Lime Green
let retroNeonOrange = Color(hex: "FF8A1F")   // Bright Orange
let retroTextColor = Color.white            // Main text color
let retroSubtleText = Color.white.opacity(0.7) // Dimmer text

let retroGradients: [Gradient] = [
    Gradient(colors: [retroNeonPink, retroMidPurple, retroNeonCyan]),
    Gradient(colors: [retroNeonLime, retroNeonCyan, retroMidPurple]),
    Gradient(colors: [retroNeonOrange, retroNeonPink, retroDeepPurple]),
    Gradient(colors: [retroNeonCyan, retroNeonPink, retroNeonLime])
]

// -- Fonts --
// Note: Replace "YourRetroPixelFont" or "YourGraffitiFont" if you have actual custom fonts installed.
// Using system Monospaced as a reliable fallback.
func retroFont(size: CGFloat, weight: Font.Weight = .regular, design: Font.Design = .monospaced) -> Font {
    // Ideal: Use a pixelated or blocky 90s font if available
    // Font.custom("YourRetroPixelFont", size: size).weight(weight)
    // Fallback: System Monospaced often gives a retro computer vibe
    return Font.system(size: size, weight: weight, design: design)
}

func retroTitleFont(size: CGFloat) -> Font {
    // Maybe a slightly more decorative or bold monospaced for titles
    // Font.custom("YourGraffitiFont", size: size) // Example for a header
    return retroFont(size: size, weight: .bold)
}

// -- Modifiers --
struct NeonGlow: ViewModifier {
    var color: Color
    var radius: CGFloat

    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(0.6), radius: radius / 2, x: 0, y: 0) // Inner sharp glow
            .shadow(color: color.opacity(0.4), radius: radius, x: 0, y: 0)     // Mid soft glow
            .shadow(color: color.opacity(0.2), radius: radius * 1.5, x: 0, y: 0) // Outer faint glow
    }
}

extension View {
    func neonGlow(_ color: Color = retroNeonPink, radius: CGFloat = 10) -> some View {
        self.modifier(NeonGlow(color: color, radius: radius))
    }
}

// Helper for Hex Colors (Optional but useful)
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
            (a, r, g, b) = (255, 0, 0, 0) // Default to black on error
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}

// MARK: - Data Models (Unchanged Structure)

// Structures: SpotifySearchResponse, Albums, AlbumItem, Artist, SpotifyImage, ExternalUrls,
// AlbumTracksResponse, Track remain structurally the same as before.
// Include their Codable, Identifiable, Hashable conformance and helper computed properties.

struct SpotifySearchResponse: Codable, Hashable { let albums: Albums }

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
    let type: String // Should always be "album" based on search type
    let uri: String
    let artists: [Artist]

    // --- Helper computed properties ---
    var bestImageURL: URL? {
        images.first { $0.width == 640 }?.urlObject ??
        images.first { $0.width == 300 }?.urlObject ??
        images.first?.urlObject
    }
    var listImageURL: URL? {
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
                dateFormatter.dateFormat = "MMM yyyy"
                return dateFormatter.string(from: date)
            }
        case "day":
            dateFormatter.dateFormat = "yyyy-MM-dd"
            if let date = dateFormatter.date(from: release_date) {
                dateFormatter.dateFormat = "d MMM yyyy" // e.g., 8 Aug 2000
                return dateFormatter.string(from: date)
            }
        default:
            break // Intentional fallthrough
        }
        return release_date // Fallback to raw string
    }
}

struct Artist: Codable, Identifiable, Hashable {
    let id: String
    let external_urls: ExternalUrls? // Make optional as per JSON
    let href: String
    let name: String
    let type: String // Should be "artist"
    let uri: String
}

struct SpotifyImage: Codable, Hashable {
    let height: Int? // Optional because sometimes missing
    let url: String
    let width: Int? // Optional because sometimes missing
    var urlObject: URL? { URL(string: url) }
}

struct ExternalUrls: Codable, Hashable {
    let spotify: String? // Optional as per JSON
}

// Models for Album Detail Tracks
struct AlbumTracksResponse: Codable, Hashable {
    let items: [Track]
    // Other fields like href, limit, next, offset, previous, total are usually present but omitted for this example focus
}

struct Track: Codable, Identifiable, Hashable {
    let id: String
    let artists: [Artist]
    let disc_number: Int
    let duration_ms: Int
    let explicit: Bool
    let external_urls: ExternalUrls? // Optional
    let href: String
    let name: String
    let preview_url: String? // Optional
    let track_number: Int
    let type: String // Should be "track"
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
}

// MARK: - API Service (Requires Valid Token)

let placeholderSpotifyToken = "YOUR_SPOTIFY_BEARER_TOKEN_HERE" // <-- IMPORTANT: REPLACE THIS!

enum SpotifyAPIError: Error, LocalizedError {
    case invalidURL
    case networkError(Error)
    case invalidResponse(Int, String?)
    case decodingError(Error)
    case invalidToken
    case missingData

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid API URL configured."
        case .networkError(let error): return "Network connection lost! Check your internet. (\(error.localizedDescription))"
        case .invalidResponse(let code, _): return "Party foul! Server responded with error (\(code)). Try again later?"
        case .decodingError(let error): return "Whoa, busted signal! Couldn't read response data. (\(error.localizedDescription))"
        case .invalidToken: return "Access denied! Your Spotify token is expired or invalid. Check the app."
        case .missingData: return "Record skip! Expected data was missing in the response."
        }
    }
}

struct SpotifyAPIService {
    static let shared = SpotifyAPIService()
    private let session: URLSession

    init() {
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData // Avoid stale cache
        session = URLSession(configuration: configuration)
    }

    // Generic request function
    private func makeRequest<T: Decodable>(url: URL) async throws -> T {
        guard !placeholderSpotifyToken.isEmpty, placeholderSpotifyToken != "YOUR_SPOTIFY_BEARER_TOKEN_HERE" else {
            throw SpotifyAPIError.invalidToken
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(placeholderSpotifyToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 20 // Slightly longer timeout

        do {
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw SpotifyAPIError.invalidResponse(0, "Response was not HTTP.")
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                if httpResponse.statusCode == 401 { throw SpotifyAPIError.invalidToken }
                let responseBody = String(data: data, encoding: .utf8) ?? "No response body"
                print("❌ API Error: Status Code \(httpResponse.statusCode). Body: \(responseBody)")
                throw SpotifyAPIError.invalidResponse(httpResponse.statusCode, responseBody)
            }

            do {
                let decoder = JSONDecoder()
                return try decoder.decode(T.self, from: data)
            } catch {
                print("❌ Decoding Error: \(error)")
                print("Raw data: \(String(data: data, encoding: .utf8) ?? "Invalid UTF-8 data")")
                throw SpotifyAPIError.decodingError(error)
            }
        } catch let error where !(error is CancellationError) { // Don't wrap cancellation errors
            // Re-throw API errors directly, wrap others as network errors
            throw error is SpotifyAPIError ? error : SpotifyAPIError.networkError(error)
        }
    }

    // Specific endpoint functions
    func searchAlbums(query: String, limit: Int = 20, offset: Int = 0) async throws -> SpotifySearchResponse {
        var components = URLComponents(string: "https://api.spotify.com/v1/search")
        // Ensure query parameters are properly encoded
        components?.queryItems = [
            URLQueryItem(name: "q", value: query), // Let URLComponents handle encoding
            URLQueryItem(name: "type", value: "album"),
            URLQueryItem(name: "include_external", value: "audio"),
            URLQueryItem(name: "limit", value: "\(limit)"),
            URLQueryItem(name: "offset", value: "\(offset)")
        ]
        guard let url = components?.url else { throw SpotifyAPIError.invalidURL }
        print("🔍 Searching albums with URL: \(url.absoluteString)")
        return try await makeRequest(url: url)
    }

    func getAlbumTracks(albumId: String, limit: Int = 50, offset: Int = 0) async throws -> AlbumTracksResponse {
        var components = URLComponents(string: "https://api.spotify.com/v1/albums/\(albumId)/tracks")
        components?.queryItems = [
            URLQueryItem(name: "limit", value: "\(limit)"),
            URLQueryItem(name: "offset", value: "\(offset)")
        ]
        guard let url = components?.url else { throw SpotifyAPIError.invalidURL }
        print("🎵 Fetching tracks for album \(albumId) from URL: \(url.absoluteString)")
        return try await makeRequest(url: url)
    }
}

// MARK: - Spotify Embed WebView (Functionality Unchanged, Container Themed Later)

// SpotifyPlaybackState ObservableObject remains the same
final class SpotifyPlaybackState: ObservableObject {
    @Published var isPlaying: Bool = false
    @Published var currentPosition: Double = 0 // seconds
    @Published var duration: Double = 0 // seconds
    /// The URI currently *loaded* or *attempted to load* in the web player.
    @Published var currentUri: String = ""
}

// SpotifyEmbedWebView and its Coordinator remain the same
struct SpotifyEmbedWebView: UIViewRepresentable {
    @ObservedObject var playbackState: SpotifyPlaybackState
    let spotifyUri: String? // The URI to load

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIView(context: Context) -> WKWebView {
        // Configure JavaScript communication
        let userContentController = WKUserContentController()
        userContentController.add(context.coordinator, name: "spotifyController")

        let configuration = WKWebViewConfiguration()
        configuration.userContentController = userContentController
        configuration.allowsInlineMediaPlayback = true // Important for background playback
        configuration.mediaTypesRequiringUserActionForPlayback = [] // Allow programmatic play

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator // Needed for JS alerts if debugging JS
        webView.isOpaque = false // Make transparent to show SwiftUI background
        webView.backgroundColor = .clear
        webView.scrollView.isScrollEnabled = false // Disable scrolling embed

        // Load the initial HTML
        let html = generateHTML()
        webView.loadHTMLString(html, baseURL: nil) // Base URL is nil as content is self-contained

        context.coordinator.webView = webView // Keep a reference in coordinator
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        // Check if the API is ready and if the desired URI has changed
        if context.coordinator.isApiReady && context.coordinator.lastLoadedUri != spotifyUri {
            print("🔄 Spotify Embed Native: updateUIView detected URI change. Requesting loadUri for \(spotifyUri ?? "nil").")
            context.coordinator.loadUri(spotifyUri ?? "No URI")
            // Ensure the state's currentUri accurately reflects what's being loaded *now*.
            DispatchQueue.main.async { if playbackState.currentUri != spotifyUri { playbackState.currentUri = spotifyUri ?? "No URI" } }
        } else if !context.coordinator.isApiReady {
            // If API isn't ready yet, just store the desired URI so it can be loaded once ready
            context.coordinator.updateDesiredUriBeforeReady(spotifyUri ?? "No URI")
            print("⏳️ Spotify Embed Native: updateUIView called, API not ready. Storing desired URI: \(spotifyUri ?? "nil").")
        }
    }

    static func dismantleUIView(_ uiView: WKWebView, coordinator: Coordinator) {
        print("🧹 Spotify Embed Native: dismantleUIView called. Cleaning up WebView.")
        uiView.stopLoading()
        // Remove the script message handler to prevent leaks
        uiView.configuration.userContentController.removeScriptMessageHandler(forName: "spotifyController")
        coordinator.webView = nil // Break reference cycle
    }

    // Coordinator handles communication between WKWebView and SwiftUI
    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
        var parent: SpotifyEmbedWebView
        weak var webView: WKWebView?
        var isApiReady = false
        /// Tracks the URI that was *last successfully requested* to be loaded via JavaScript.
        var lastLoadedUri: String?
        /// Stores the desired URI if `updateUIView` is called before the JS API is ready.
        private var desiredUriBeforeReady: String? = nil

        init(_ parent: SpotifyEmbedWebView) {
            self.parent = parent
        }

        /// Called if updateUIView wants to load a URI before JS API signals readiness.
        func updateDesiredUriBeforeReady(_ uri: String) {
            if !isApiReady {
                desiredUriBeforeReady = uri
            }
        }

        // --- WKNavigationDelegate Methods ---
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            print("✅ Embed: HTML frame finished loading.")
            // Note: This doesn't mean the Spotify IFrame API is ready yet.
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print("❌ Embed Navigation Error: \(error.localizedDescription)")
            // Optionally update parent view state to show an error
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            print("❌ Embed Provisional Navigation Error: \(error.localizedDescription)")
            // Optionally update parent view state to show an error
        }

        // --- WKUIDelegate Method (Optional, for JS alerts) ---
         func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
             print("ℹ️ Embed JS Alert: \(message)")
             completionHandler() // Must call completion handler
         }

        // --- WKScriptMessageHandler Method ---
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            guard message.name == "spotifyController" else { return }

            // Handle 'ready' signal from initial JS
            if let bodyString = message.body as? String, bodyString == "ready" {
                handleApiReady()
                return
            }

            // Handle structured event messages from the Spotify controller
            if let bodyDict = message.body as? [String: Any], let event = bodyDict["event"] as? String {
                handleEvent(event: event, data: bodyDict["data"])
            } else {
                print("❓ Embed: Received unknown message format: \(message.body)")
            }
        }

        private func handleApiReady() {
            guard !isApiReady else { return } // Prevent double execution
            print("✅ Embed Coordinator: Spotify IFrame API is ready (received 'ready' message).")
            isApiReady = true

            // Now attempt to create the controller with the desired URI (either initial or updated)
            if let initialUri = desiredUriBeforeReady ?? parent.spotifyUri {
                print("🚀 Embed Coordinator: API ready, attempting createSpotifyController for URI: \(initialUri)")
                createSpotifyController(with: initialUri)
            } else {
                print("⚠️ Embed Coordinator: API ready, but no initial URI provided.")
                // Optionally initialize with a default or handle error state
            }
            desiredUriBeforeReady = nil // Clear the stored URI after use
        }

        private func handleEvent(event: String, data: Any?) {
            //print("收到事件：\(event)，数据：\(String(describing: data))")
            switch event {
            case "controllerCreated":
                print("✅ Embed Coordinator: JS reported Controller Created.")
                // Potentially trigger initial play or fetch state here if needed
            case "playbackUpdate":
                if let updateData = data as? [String: Any] {
                    updatePlaybackState(with: updateData)
                }
             case "error":
                 let errorMsg = (data as? [String: Any])?["message"] as? String ?? "\(data ?? "Unknown JavaScript error")"
                 print("❌ Embed JS Error Received: \(errorMsg)")
                 // You could propagate this error to the SwiftUI view if needed
                 // e.g., parent.playbackState.error = errorMsg
             // Add cases for other events like 'ready', 'account_error', etc. if needed
            default:
                print("❓ Embed Coordinator: Received unhandled event '\(event)'")
            }
        }

        private func updatePlaybackState(with data: [String: Any]) {
            // Update the parent's ObservableObject on the main thread
            DispatchQueue.main.async { [weak self] in
                 guard let self = self else { return }

                if let isPaused = data["paused"] as? Bool {
                    // Only update if the state actually changed
                    if self.parent.playbackState.isPlaying == isPaused {
                        self.parent.playbackState.isPlaying = !isPaused
                         print("▶️ Embed Playback State Changed: isPlaying = \(!isPaused)")
                    }
                }
                if let posMs = data["position"] as? Double {
                    let newPos = posMs / 1000.0 // Convert ms to seconds
                    // Only update if change is significant to avoid jitter
                    if abs(self.parent.playbackState.currentPosition - newPos) > 0.1 {
                         self.parent.playbackState.currentPosition = newPos
                    }
                }
                if let durMs = data["duration"] as? Double {
                    let newDur = durMs / 1000.0 // Convert ms to seconds
                     // Update if significantly different or if initial duration was 0
                    if abs(self.parent.playbackState.duration - newDur) > 0.1 || self.parent.playbackState.duration == 0 {
                        self.parent.playbackState.duration = newDur
                         // print("⏱️ Embed Duration Updated: \(newDur)s")
                    }
                }
                 // Update currentUri based on the event data ONLY if it differs to avoid loops
                 // This is less common in playback_update but might be present
                 if let uri = data["uri"] as? String, self.parent.playbackState.currentUri != uri {
                     print("ℹ️ Embed URI updated via playback event (uncommon): \(uri)")
                     self.parent.playbackState.currentUri = uri
                 }
            }
        }

        // Function to call the JS to create the Spotify controller instance
        func createSpotifyController(with initialUri: String) {
             guard let webView = webView else { print("❌ Embed Native: Cannot create controller, WebView is nil."); return }
            guard isApiReady else { print("❌ Embed Native: Cannot create controller, API not ready."); return }
             // Prevent re-initialization if already attempted (might need refinement for retries)
            guard lastLoadedUri == nil else {
                // If the desired URI changed *after* the first attempt but *before* success, load it now.
                if let latestDesired = desiredUriBeforeReady ?? parent.spotifyUri,
                   latestDesired != lastLoadedUri {
                     print("🔄 Spotify Embed Native (createSpotifyController): API ready, loading changed URI: \(latestDesired)")
                     loadUri(latestDesired)
                     desiredUriBeforeReady = nil // Clear after use
                 } else {
                     print("ℹ️ Spotify Embed Native (createSpotifyController): Controller already initialized or initialization attempt ongoing.")
                 }
                 return
             }

            print("🚀 Spotify Embed Native: Evaluating JS to create controller for URI: \(initialUri)")
            lastLoadedUri = initialUri // Mark as attempting initialization with this URI

            // --- JavaScript Code to Execute ---
            // This code finds the div, creates the controller, stores it globally,
            // adds listeners, and sends messages back to Swift.
             let script = """
             console.log('Spotify Embed JS: Running createSpotifyController script.');
             window.embedController = null; // Clear previous instance if any

             const element = document.getElementById('embed-iframe');
             if (!element) {
                 console.error('Spotify Embed JS Error: Could not find element embed-iframe!');
                 window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'HTML element embed-iframe not found' }});
             } else if (!window.IFrameAPI) {
                 console.error('Spotify Embed JS Error: IFrameAPI is not loaded!');
                 window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'Spotify IFrame API not loaded' }});
             } else {
                 console.log('Spotify Embed JS: Found element and IFrameAPI. Creating controller for URI: \(initialUri)');
                 const options = {
                     uri: '\(initialUri)',
                     width: '100%', // Let HTML/CSS handle size
                     height: '100%' // Let HTML/CSS handle size
                 };
                 const callback = (controller) => {
                     if (!controller) {
                         console.error('Spotify Embed JS Error: createController callback received null controller!');
                         window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'JS createController callback error (controller is null)' }});
                         // Consider resetting lastLoadedUri here to allow retry on next update? Needs care.
                         // Example: // this.lastLoadedUri = null; // Needs access back to coordinator state
                         return;
                     }
                     console.log('✅ Spotify Embed JS: Controller instance received successfully.');
                     window.embedController = controller; // Store globally for access
                     window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'controllerCreated' });

                     // --- Add Listeners ---
                     controller.addListener('ready', () => {
                         console.log('✅ Spotify Embed JS: Controller Ready event.');
                         // You might want to fetch initial state here
                         // controller.getPlaybackState().then(state => { ... });
                     });
                     controller.addListener('playback_update', e => {
                         // Send the whole data object
                         window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'playbackUpdate', data: e.data });
                     });
                     controller.addListener('account_error', e => {
                         console.warn('Spotify Embed JS: Account Error:', e.data);
                         window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'Account Error: ' + (e.data?.message ?? 'Premium required or login issue?') }});
                     });
                      controller.addListener('autoplay_failed', () => {
                          console.warn('Spotify Embed JS: Autoplay failed. Attempting play().');
                          window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'Autoplay failed' }});
                          // Optionally attempt manual play
                          // controller.play(); // Be careful with autoplay policies
                      });
                     controller.addListener('initialization_error', e => {
                         console.error('Spotify Embed JS: Initialization Error:', e.data);
                         window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'Initialization Error: ' + (e.data?.message ?? 'Failed to initialize player') }});
                          // Critical error, might reset lastLoadedUri to allow retry
                     });
                 };

                 // --- Call the API ---
                 try {
                     console.log('Spotify Embed JS: Calling IFrameAPI.createController...');
                     window.IFrameAPI.createController(element, options, callback);
                 } catch (e) {
                     console.error('Spotify Embed JS: Exception during createController call:', e);
                     window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'JS exception during createController: ' + e.message }});
                      // Resetting state might be needed here too
                 }
             }
             """

            webView.evaluateJavaScript(script) { result, error in
                if let error = error {
                    print("⚠️ Spotify Embed Native: Error evaluating JS for controller creation: \(error.localizedDescription)")
                    // If the JS evaluation itself fails, maybe reset lastLoadedUri to allow retry
                    // self.lastLoadedUri = nil // Caution: Concurrent modification risk
                } else {
                    // Result might contain return value from JS if any, usually null here
                    // print("ℹ️ Spotify Embed Native: JS controller creation script evaluated result: \(result ?? "nil")")
                }
            }
        }

        // Function to call the JS to load a new URI into the existing controller
        func loadUri(_ uri: String) {
            guard let webView = webView, isApiReady else { print("❌ Embed Native: Cannot load URI, WebView not ready or API not ready."); return }
            // Make sure a controller has been initialized (lastLoadedUri is not nil)
            // and that we are actually changing the URI
            guard lastLoadedUri != nil, lastLoadedUri != uri else {
                 if lastLoadedUri == uri { print("ℹ️ Spotify Embed Native: loadUri called with the same URI (\(uri)). Skipping JS call.") }
                 else { print("⚠️ Spotify Embed Native: loadUri called before controller initialization was attempted.") }
                 return
            }

            print("🚀 Embed Native: Evaluating JS to load URI: \(uri)")
            lastLoadedUri = uri // Update the tracked loaded URI

            // --- JavaScript Code to Execute ---
             let script = """
             if (window.embedController) {
                 console.log('Spotify Embed JS: Loading URI: \(uri)');
                 window.embedController.loadUri('\(uri)');
                 // Optionally auto-play after loading new URI
                 // window.embedController.play(); // Consider adding a delay or user action trigger
             } else {
                 console.error('Spotify Embed JS Error: Controller instance (window.embedController) not found when trying to load URI.');
                  window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'JS loadUri failed: embedController is null' }});
             }
             """

            webView.evaluateJavaScript(script) { _, error in
                if let error = error {
                    print("⚠️ Embed Native: Error evaluating JS for loadUri: \(error.localizedDescription)")
                     // If this fails, the state might be inconsistent. Reset lastLoadedUri?
                     // self.lastLoadedUri = nil // Or maybe revert to previous? Complex state management.
                }
            }
        }
    }

    // --- Helper to Generate Base HTML ---
    private func generateHTML() -> String {
        return """
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="utf-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
            <title>Spotify Embed</title>
            <style>
                html, body { margin: 0; padding: 0; width: 100%; height: 100%; overflow: hidden; background-color: transparent; }
                #embed-iframe { width: 100%; height: 100%; display: block; border: none; } /* Ensure iframe fills div */
            </style>
        </head>
        <body>
            <!-- The div where the Spotify iframe player will be embedded -->
            <div id="embed-iframe"></div>

            <!-- Load the Spotify IFrame Player API -->
            <script src="https://open.spotify.com/embed/iframe-api/v1" async></script>

            <!-- Initialize the API and communicate readiness back to Swift -->
            <script>
                 console.log('Spotify Embed JS: Initializing script.');
                 window.onSpotifyIframeApiReady = (IFrameAPI) => {
                     console.log('✅ Spotify Embed JS: onSpotifyIframeApiReady called. API is loaded.');
                     window.IFrameAPI = IFrameAPI; // Store API instance globally for later use
                     // Send message back to Swift indicating the JS API is ready
                     if (window.webkit?.messageHandlers?.spotifyController) {
                         window.webkit.messageHandlers.spotifyController.postMessage("ready");
                         console.log("✅ Spotify Embed JS: Posted 'ready' message to Swift.");
                     } else {
                         console.error('❌ Spotify Embed JS Error: Native message handler (spotifyController) not found!');
                         // Cannot communicate readiness back!
                     }
                 };

                  // Basic error handling for script loading itself
                  const scriptTag = document.querySelector('script[src*="iframe-api"]');
                  scriptTag.onerror = (event) => {
                      console.error('❌ Spotify Embed JS Error: Failed to load the Spotify IFrame API script:', event);
                       if (window.webkit?.messageHandlers?.spotifyController) {
                           window.webkit.messageHandlers.spotifyController.postMessage({
                               event: 'error',
                               data: { message: 'Failed to load Spotify IFrame API script.' } });
                       }
                  };
            </script>
        </body>
        </html>
        """
    }
}

// MARK: - SwiftUI Views (Retro 90s Party Themed)

// --- Themed Album Image View ---
struct AlbumImageView: View {
    let url: URL?

    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
                ZStack {
                    // Placeholder background with retro colors
                    LinearGradient(colors: [retroMidPurple, retroDeepPurple], startPoint: .top, endPoint: .bottom)
                        .overlay(Color.black.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 8)) // Slightly rounded corners
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: retroNeonCyan)) // Use a neon color
                }
            case .success(let image):
                image.resizable().scaledToFit() // Keep aspect ratio
                    .clipShape(RoundedRectangle(cornerRadius: 8)) // Consistent rounding
            case .failure:
                ZStack {
                    LinearGradient(colors: [retroMidPurple, retroDeepPurple], startPoint: .top, endPoint: .bottom)
                         .overlay(Color.black.opacity(0.2))
                         .clipShape(RoundedRectangle(cornerRadius: 8))
                    // Simple 90s error icon (e.g., floppy disk, broken image)
                    Image(systemName: "photo.fill.on.rectangle.fill") // Generic placeholder
                        .resizable().scaledToFit()
                        .foregroundColor(retroNeonPink.opacity(0.6)) // Use neon color
                        .padding(15) // Padding around the icon
                }
            @unknown default:
                EmptyView() // Should not happen
            }
        }
    }
}

// --- Themed Search Metadata Header ---
struct SearchMetadataHeader: View {
    let totalResults: Int
    let limit: Int
    let offset: Int

    var body: some View {
        HStack {
            // Use a retro icon? e.g., cassette tape, boombox
            Label("\(totalResults) Tracks Found", systemImage: "music.note.list")
                .foregroundColor(retroNeonLime)

            Spacer()

            if totalResults > limit {
                Text("\(offset + 1)-\(min(offset + limit, totalResults))")
                    .foregroundColor(retroSubtleText)
            }
        }
        .font(retroFont(size: 11, weight: .bold)) // Bold mono font
        .padding(.horizontal, 15)
        .padding(.vertical, 6)
        .background(Color.black.opacity(0.4)) // Dark background
        .cornerRadius(5) // Slightly blockier corners
        .overlay(
            RoundedRectangle(cornerRadius: 5)
                .stroke(retroNeonCyan.opacity(0.5), lineWidth: 1) // Neon border
        )
    }
}

// --- Themed Reusable Button ---
struct RetroButton: View {
    let text: String
    let action: () -> Void
    var primaryColor: Color = retroNeonPink
    var secondaryColor: Color = retroNeonOrange // Contrasting neon for gradient
    var iconName: String? = nil
    var textColor: Color = retroDeepPurple // Dark text on bright button

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let iconName = iconName {
                    Image(systemName: iconName)
                        .font(.body.weight(.bold))
                }
                Text(text)
                    .tracking(1.5) // Add some letter spacing for 90s feel
            }
            .font(retroFont(size: 15, weight: .bold))
            .padding(.horizontal, 25)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity) // Make button expand
            .background(LinearGradient(colors: [primaryColor, secondaryColor], startPoint: .leading, endPoint: .trailing))
            .foregroundColor(textColor)
            .clipShape(Capsule()) // Capsule shape feels slightly 90s
            .overlay(Capsule().stroke(Color.white.opacity(0.6), lineWidth: 1.5)) // Stronger white edge
            .neonGlow(primaryColor, radius: 12) // Neon glow effect
        }
        .buttonStyle(.plain) // Ensure custom styling is applied
    }
}

// --- Themed External Link Button ---
struct ExternalLinkButton: View {
    let text: String = "CHECK IT OUT ON SPOTIFY!" // More energetic text
    let url: URL
    var primaryColor: Color = retroNeonLime
    var secondaryColor: Color = retroNeonCyan // Use another neon color
    var iconName: String? = "headphones" // Maybe headphones or speakers?

    @Environment(\.openURL) var openURL

    var body: some View {
        RetroButton(
            text: text,
            action: {
                print("Attempting to open external URL: \(url)")
                openURL(url) { accepted in
                    if !accepted {
                        print("⚠️ Bummer! Couldn't open the link: \(url)")
                        // Maybe show an alert to the user
                    }
                }
            },
            primaryColor: primaryColor,
            secondaryColor: secondaryColor,
            iconName: iconName,
            textColor: retroDeepPurple // Keep dark text for contrast
        )
    }
}

// --- Themed Error Placeholder ---
struct ErrorPlaceholderView: View {
    let error: SpotifyAPIError
    let retryAction: (() -> Void)?

    var body: some View {
        VStack(spacing: 25) {
            Image(systemName: iconName)
                .font(.system(size: 70)) // Large icon
                .foregroundStyle(LinearGradient(colors: [retroNeonPink, retroNeonOrange], startPoint: .top, endPoint: .bottom))
                .neonGlow(retroNeonPink, radius: 20) // Strong neon glow
                .padding(.bottom, 10)

            Text("WHOOPS! GLITCH!") // Themed error title
                .font(retroTitleFont(size: 24))
                .foregroundColor(retroTextColor)
                .shadow(color: .black.opacity(0.4), radius: 2, y: 1)

            Text(errorMessage)
                .font(retroFont(size: 15, weight: .medium)) // Use retro font
                .foregroundColor(retroSubtleText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
                .lineSpacing(5)

//            if let retryAction = retryAction, error != .invalidToken {
//                 RetroButton(
//                     text: "TRY AGAIN, DUDE!",
//                     action: retryAction,
//                     primaryColor: retroNeonLime,
//                     secondaryColor: retroNeonCyan,
//                     iconName: "arrow.clockwise"
//                 )
//                 .padding(.top, 15)
//             } else if error == .invalidToken {
//                 // Specific message for token error
//                 Text("Your Spotify access pass is bogus.\nCheck the token in the code!")
//                     .font(retroFont(size: 12))
//                     .foregroundColor(retroNeonPink.opacity(0.8))
//                     .multilineTextAlignment(.center)
//                     .padding(.top, 10)
//             }
            Text("Your Spotify access pass is bogus.\nCheck the token in the code!")
                .font(retroFont(size: 12))
                .foregroundColor(retroNeonPink.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.top, 10)
        }
        .padding(30)
        .background(
            .ultraThinMaterial // Keep frosted glass, feels a bit 90s CD-like
                //.overlay(LinearGradient(colors: [retroMidPurple.opacity(0.2), retroDeepPurple.opacity(0.4)], startPoint: .top, endPoint: .bottom))
        )
        .cornerRadius(15) // Rounded corners for the container
        .padding(20) // Padding around the error view
    }

    // Helper for icon based on error type
    private var iconName: String {
        switch error {
        case .invalidToken: return "key.slash" // Or maybe "lock.slash.fill"
        case .networkError: return "wifi.slash" // Or "antenna.radiowaves.left.and.right.slash"
        case .invalidResponse: return "exclamationmark.triangle.fill"
        case .decodingError: return "questionmark.diamond.fill" // Or "shippingbox.fill" (corrupted package?)
        case .invalidURL: return "link.icloud.fill" // Questionable link?
        case .missingData: return "doc.text.fill" // Missing parts?
        }
    }
    // Helper for themed error messages
    private var errorMessage: String {
        error.localizedDescription // Use the descriptions defined in the enum
    }
}

// --- Themed Empty State Placeholder ---
struct EmptyStatePlaceholderView: View {
    let searchQuery: String

    var body: some View {
        VStack(spacing: 25) {
            // Use the provided meme images, they fit the retro vibe well
            Image(isInitialState ? "My-meme-microphone" : "My-meme-orange_2")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 150, height: 150) // Adjust size as needed
                .padding(.bottom, 15)
                .shadow(color: isInitialState ? retroNeonCyan.opacity(0.5) : retroNeonOrange.opacity(0.5), radius: 15)

            Text(title)
                .font(retroTitleFont(size: 26)) // Slightly larger title
                .foregroundColor(retroTextColor)
                .tracking(1.2) // Add some tracking

            Text(messageAttributedString) // Use AttributedString for potential emphasis
                .font(retroFont(size: 15)) // Use retro font
                .foregroundColor(retroSubtleText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
                .lineSpacing(6)
        }
        .padding(30)
    }

    // Logic for initial vs. no results state
    private var isInitialState: Bool { searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    private var title: String { isInitialState ? "YO! SEARCH TIME!" : "TOTAL BUMMER!" } // 90s slang
    private var messageAttributedString: AttributedString {
        var message: AttributedString
        let baseFont = retroFont(size: 15) // Base font for the message
        let boldFont = retroFont(size: 15, weight: .bold) // Bold variant
        let highlightColor = retroNeonLime // Color for emphasis

        if isInitialState {
            message = AttributedString("Type in an album or artist above,\nlike, totally find some tunes!")
        } else {
            let query = searchQuery.isEmpty ? "that" : searchQuery
            // Try creating with Markdown-like syntax for bolding
            do {
                var attributedQuery = AttributedString(query)
                attributedQuery.font = boldFont
                attributedQuery.foregroundColor = highlightColor

                message = AttributedString("No dope tracks found for ")
                message.append(attributedQuery)
                message.append(AttributedString(".\nTry some different keywords!"))
            } catch {
                // Fallback if AttributedString creation fails
                message = AttributedString("No matches for \"\(query)\".\nTry different keywords!")
            }
        }
        // Apply the base font and color to the entire message
        message.font = baseFont
        message.foregroundColor = retroSubtleText
        return message
    }
}

// --- Themed Album Card for List ---
struct RetroAlbumCard: View {
    let album: AlbumItem

    var body: some View {
         ZStack(alignment: .leading) { // Align content to leading edge
             // Background: Simple dark material with neon edge
             RoundedRectangle(cornerRadius: 10)
                 .fill(retroMidPurple.opacity(0.6)) // Semi-transparent purple
                 .background(.ultraThinMaterial) // Frosted glass effect
                 .clipShape(RoundedRectangle(cornerRadius: 10))
                 .overlay(
                     RoundedRectangle(cornerRadius: 10)
                       // .stroke(LinearGradient(colors: retroGradients.randomElement()?.colors ?? [retroNeonPink, retroNeonCyan], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 2) // Random neon gradient border
                 )
                 .shadow(color: .black.opacity(0.5), radius: 5, y: 3) // Drop shadow

             HStack(spacing: 12) {
                 // --- Album Art ---
                 AlbumImageView(url: album.listImageURL)
                     .frame(width: 80, height: 80) // Slightly smaller image
                     .clipShape(RoundedRectangle(cornerRadius: 6)) // Less rounding
                     .overlay(RoundedRectangle(cornerRadius: 6).stroke(retroTextColor.opacity(0.2), lineWidth: 1)) // Subtle border
                     .padding([.leading, .vertical], 10) // Padding around image

                 // --- Text Details ---
                 VStack(alignment: .leading, spacing: 4) {
                     Text(album.name)
                         .font(retroFont(size: 16, weight: .bold))
                         .foregroundColor(retroTextColor)
                         .lineLimit(2) // Allow two lines for album name

                     Text(album.formattedArtists)
                         .font(retroFont(size: 13, weight: .medium))
                         .foregroundColor(retroNeonLime) // Neon highlight for artist
                         .lineLimit(1)

                     Spacer() // Pushes bottom info down

                     // --- Bottom Row Info (Type, Date, Tracks) ---
                      HStack(spacing: 6) {
                          Label(album.album_type.capitalized, systemImage: iconForAlbumType(album.album_type)) // Use helper icon
                              .font(retroFont(size: 10, weight: .heavy)) // Heavier weight
                              .foregroundColor(retroSubtleText)
                              .padding(.horizontal, 6).padding(.vertical, 2)
                              .background(retroDeepPurple.opacity(0.5), in: Capsule()) // Darker capsule

                          Text("•")
                              .foregroundColor(retroSubtleText.opacity(0.5))

                          Text(album.formattedReleaseDate())
                              .font(retroFont(size: 10, weight: .heavy))
                              .foregroundColor(retroSubtleText)

                           Spacer() // Push track count to the right

                           Text("\(album.total_tracks) Tracks")
                               .font(retroFont(size: 10, weight: .heavy))
                               .foregroundColor(retroSubtleText)
                      }

                 } // End Text VStack
                 .padding(.trailing, 10)
                 .padding(.vertical, 10) // Vertical padding for text block

             } // End HStack
         } // End ZStack
         .frame(height: 100) // Fixed height for card consistency
    }

    // Helper to get a relevant SF Symbol based on album type
    private func iconForAlbumType(_ type: String) -> String {
        switch type.lowercased() {
        case "album": return "opticaldisc" // CD icon
        case "single": return "record.circle.fill" // Vinyl single icon
        case "compilation": return "music.note.list" // List icon
        default: return "music.mic" // Default music icon
        }
    }
}

// --- Themed Album Detail Header ---
struct AlbumHeaderView: View {
    let album: AlbumItem

    var body: some View {
        VStack(spacing: 15) {
            // --- Album Art with Neon Glow ---
            AlbumImageView(url: album.bestImageURL)
                .aspectRatio(1.0, contentMode: .fit) // Keep square aspect ratio
                .clipShape(RoundedRectangle(cornerRadius: 10)) // Slightly blockier
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(LinearGradient(colors: [retroNeonPink.opacity(0.7), retroNeonCyan.opacity(0.7)], startPoint: .top, endPoint: .bottom), lineWidth: 2))
                .neonGlow(retroNeonCyan, radius: 18) // Stronger glow for detail view
                .padding(.horizontal, 40) // Adjust padding

            // --- Text Info ---
            VStack(spacing: 6) {
                Text(album.name)
                    .font(retroTitleFont(size: 24)) // Larger retro title font
                    .foregroundColor(retroTextColor)
                    .multilineTextAlignment(.center)
                    .shadow(color: .black.opacity(0.6), radius: 2, y: 1) // Text shadow

                Text("By \(album.formattedArtists)")
                    .font(retroFont(size: 17, weight: .medium)) // Medium weight retro font
                    .foregroundColor(retroNeonLime) // Neon accent for artists
                    .multilineTextAlignment(.center)

                // Album Type and Release Date
                HStack(spacing: 8) {
                     Label(album.album_type.capitalized, systemImage: iconForAlbumType(album.album_type))
                         .font(retroFont(size: 12, weight: .bold))
                         .foregroundColor(retroSubtleText)
                     Text("•")
                          .foregroundColor(retroSubtleText.opacity(0.5))
                     Text(album.formattedReleaseDate())
                         .font(retroFont(size: 12, weight: .bold))
                         .foregroundColor(retroSubtleText)
                }
                .padding(.top, 5)
            }
            .padding(.horizontal)

        }
        .padding(.vertical, 25) // Vertical padding for the whole header
    }
     // Re-use the helper from RetroAlbumCard
     private func iconForAlbumType(_ type: String) -> String {
         switch type.lowercased() {
         case "album": return "opticaldisc"
         case "single": return "record.circle.fill"
         case "compilation": return "music.note.list"
         default: return "music.mic"
         }
     }
}

// --- Themed Spotify Player Container ---
struct SpotifyEmbedPlayerView: View {
    @ObservedObject var playbackState: SpotifyPlaybackState
    let spotifyUri: String

    var body: some View {
        VStack(spacing: 10) { // Add spacing
            // The WebView itself doesn't get themed, just its container
             SpotifyEmbedWebView(playbackState: playbackState, spotifyUri: spotifyUri)
                 .frame(height: 80) // Standard embed height
                 // --- Container Styling ---
                 .background(
                     ZStack {
                          // Dark semi-transparent background
                          retroDeepPurple.opacity(0.7)
                          // Subtle noise/static texture could go here (optional)
                          // Image("static_texture").resizable().blendMode(.overlay).opacity(0.05)
                     }
                    .background(.ultraThinMaterial) // Frosted backing
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    // Double neon border effect
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(retroNeonCyan.opacity(0.6), lineWidth: 1))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(retroNeonPink.opacity(0.4), lineWidth: 3).blur(radius: 2)) // Blurred outer border
                 )
                  .neonGlow(playbackState.isPlaying ? retroNeonLime : retroNeonCyan, radius: 10) // Dynamic glow
                  .padding(.horizontal, 15) // Padding around the player

            // --- Themed Playback Status Bar ---
             HStack {
                  let statusText = playbackState.isPlaying ? "PLAYIN'" : "PAUSED" // 90s slang
                  let statusColor = playbackState.isPlaying ? retroNeonLime : retroNeonOrange

                  Text(statusText)
                      .font(retroFont(size: 11, weight: .heavy)) // Heavy retro font
                      .foregroundColor(statusColor)
                      .kerning(1.5) // Letter spacing
                      .neonGlow(statusColor, radius: 5) // Glow on text
                      .frame(width: 70, alignment: .leading) // Fixed width

                  Spacer()

                   // Display time only if valid duration exists
                   if playbackState.duration > 0.1 {
                       Text("\(formatTime(playbackState.currentPosition)) / \(formatTime(playbackState.duration))")
                           .font(retroFont(size: 12, weight: .bold)) // Bold time
                           .foregroundColor(retroSubtleText)
                           .monospacedDigit() // Ensure digits take same space
                   } else {
                       Text("--:-- / --:--") // Placeholder
                           .font(retroFont(size: 12, weight: .bold))
                           .foregroundColor(retroSubtleText.opacity(0.5))
                   }
             }
             .padding(.horizontal, 25) // Align with player padding
             .padding(.top, 2) // Space above status bar
             .frame(minHeight: 15)

        } // End VStack
        .animation(.easeInOut(duration: 0.3), value: playbackState.isPlaying) // Animate glow change
    }

    // Helper to format time (MM:SS)
    private func formatTime(_ time: Double) -> String {
        let totalSeconds = max(0, Int(time)) // Ensure non-negative
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// --- Themed Track Row ---
struct TrackRowView: View {
    let track: Track
    let isSelected: Bool

    var body: some View {
         HStack(spacing: 10) { // Reduced spacing
             // --- Track Number ---
             Text("\(track.track_number)")
                 .font(retroFont(size: 12, weight: .bold)) // Bold Mono track number
                 .foregroundColor(isSelected ? retroNeonPink : retroSubtleText) // Highlight selected
                 .frame(width: 20, alignment: .center)
                 .padding(.leading, 15)

             // --- Track Info (Name & Artist) ---
             VStack(alignment: .leading, spacing: 2) {
                 Text(track.name)
                     .font(retroFont(size: 14, weight: isSelected ? .heavy : .medium)) // Heavier weight if selected
                     .foregroundColor(isSelected ? retroNeonCyan : retroTextColor) // Highlight selected name
                     .lineLimit(1)

                 Text(track.formattedArtists)
                     .font(retroFont(size: 11))
                     .foregroundColor(retroSubtleText)
                     .lineLimit(1)
             }

             Spacer() // Push duration and icon to the right

             // --- Duration ---
             Text(track.formattedDuration)
                 .font(retroFont(size: 12, weight: .medium))
                 .foregroundColor(retroSubtleText)
                 .padding(.trailing, 5)

             // --- Play/State Indicator ---
              // Use a more 90s icon? Maybe speaker or cassette?
              Image(systemName: isSelected ? "speaker.wave.3.fill" : "play.fill") // Speaker icon when selected
                  .foregroundColor(isSelected ? retroNeonLime : retroTextColor.opacity(0.8))
                  .font(.caption.weight(.bold))
                  .frame(width: 20, height: 20)
                  .padding(.trailing, 15)
                  .animation(.easeInOut(duration: 0.2), value: isSelected) // Animate icon change

         }
         .padding(.vertical, 10) // Adjusted padding
         .background(isSelected ? retroNeonPink.opacity(0.15) : Color.clear) // Subtle background highlight
         .cornerRadius(5) // Optional slight rounding for the background highlight
    }
}

// --- Themed Tracks Section Container ---
struct TracksSectionView: View {
    let tracks: [Track]
    let isLoading: Bool
    let error: SpotifyAPIError?
    @Binding var selectedTrackUri: String?
    let retryAction: () -> Void

    var body: some View {
        // Use Group to conditionally show content without extra VStack
        Group {
            if isLoading {
                HStack {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: retroNeonLime))
                    Text("Loading Tracks...")
                        .font(retroFont(size: 13, weight: .bold))
                        .foregroundColor(retroNeonLime)
                        .padding(.leading, 8)
                    Spacer()
                }
                .padding(.vertical, 30) // Give loading indicator space
            } else if let error = error {
                ErrorPlaceholderView(error: error, retryAction: retryAction)
                    .padding(.vertical, 20)
            } else if tracks.isEmpty {
                 Text("Nothin' Here! No Tracks Found.") // 90s speak
                     .font(retroFont(size: 14, weight: .medium))
                     .foregroundColor(retroSubtleText)
                     .frame(maxWidth: .infinity, alignment: .center)
                     .padding(.vertical, 30)
             } else {
                 // Display the tracks using ForEach
                 // No LazyVStack needed here as List handles laziness
                 ForEach(tracks) { track in
                      TrackRowView(
                          track: track,
                          isSelected: track.uri == selectedTrackUri
                      )
                      .contentShape(Rectangle()) // Make whole row tappable
                      .onTapGesture {
                          // Update the selected URI, parent DetailView handles player update
                           if selectedTrackUri == track.uri {
                              selectedTrackUri = nil // Allow deselecting/stopping perhaps?
                           } else {
                              selectedTrackUri = track.uri
                           }
                      }
                      // Don't add background here, do it in TrackRowView or use .listRowBackground
                      // Add a subtle separator line maybe?
                      // .overlay( Vider(), alignment: .bottom)
                           //Divider().background(retroSubtleText.opacity(0.2)).padding(.leading, 45) // Indent separator
                 }
             }
        }
    }
}

// MARK: - Main Views (Retro Themed)

// --- Retro Album Detail View ---
struct AlbumDetailView: View {
    let album: AlbumItem
    @State private var tracks: [Track] = []
    @State private var isLoadingTracks: Bool = false
    @State private var trackFetchError: SpotifyAPIError? = nil
    @State private var selectedTrackUri: String? = nil // Tracks the URI for the player
    @StateObject private var playbackState = SpotifyPlaybackState()
    
    var body: some View {
        ZStack {
            // --- Background ---
            LinearGradient(colors: [retroDeepPurple, retroMidPurple, retroDeepPurple], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            // Optional: Add a subtle retro pattern (e.g., grid, static)
            Image("retro_grid_background") // Assume you have this image asset
                .resizable()
                .scaledToFill()
                .blendMode(.overlay)
                .opacity(0.08)
                .ignoresSafeArea()

            List {
                // --- Header Section ---
                Section {
                    AlbumHeaderView(album: album) // Themed header
                }
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets()) // Remove insets for full-width feel
                .listRowBackground(Color.clear) // Make background transparent

                // --- Player Section ---
                // Conditionally show the player only when a track is selected
                 if let uriToPlay = selectedTrackUri {
                     Section {
                         SpotifyEmbedPlayerView(playbackState: playbackState, spotifyUri: uriToPlay) // Themed player container
                     }
                     .listRowSeparator(.hidden)
                     .listRowInsets(EdgeInsets(top: 15, leading: 0, bottom: 15, trailing: 0)) // Player vertical padding
                     .listRowBackground(Color.clear)
                      .id("player_\(uriToPlay)") // Add ID to help transitions?
                      .transition(.scale(scale: 0.9, anchor: .top).combined(with: .opacity)) // Simple transition
                 }

                // --- Tracks Section ---
                Section {
                    // Container view for tracks, loading, error states
                     TracksSectionView(
                         tracks: tracks,
                         isLoading: isLoadingTracks,
                         error: trackFetchError,
                         selectedTrackUri: $selectedTrackUri, // Pass binding
                         retryAction: { Task { await fetchTracks() } }
                     )
                 } header: {
                     // Themed Section Header
                     Text("TRACK LIST")
                         .font(retroTitleFont(size: 14)) // Retro title font for header
                         .kerning(2.5) // Letter spacing
                         .foregroundColor(retroNeonCyan)
                         .frame(maxWidth: .infinity, alignment: .center) // Center align
                         .padding(.vertical, 8)
                         .background(retroMidPurple.opacity(0.5)) // Darker header background
                          .overlay(Rectangle().frame(height: 1).foregroundColor(retroNeonCyan.opacity(0.5)), alignment: .bottom) // Neon underline
                 }
                 .listRowSeparator(.hidden)
                 .listRowInsets(EdgeInsets()) // Remove default track row insets if using custom separators
                 .listRowBackground(Color.clear)

                // --- External Link Section ---
                if let spotifyURL = URL(string: album.external_urls.spotify ?? "") {
                    Section {
                        ExternalLinkButton(url: spotifyURL) // Themed button
                    }
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 30, leading: 20, bottom: 30, trailing: 20)) // Add space around button
                    .listRowBackground(Color.clear)
                }

            } // End List
            .listStyle(PlainListStyle()) // Removes default List styling
            .scrollContentBackground(.hidden) // Allow ZStack background through List

        } // End ZStack
         .navigationTitle(album.name) // Use album name for title
         .navigationBarTitleDisplayMode(.inline)
         // --- Themed Navigation Bar ---
         .toolbarBackground(
             LinearGradient(colors: [retroMidPurple, retroDeepPurple], startPoint: .top, endPoint: .bottom).opacity(0.85), // Dark gradient background
             for: .navigationBar
         )
         .toolbarBackground(.visible, for: .navigationBar) // Make sure it's visible
        .toolbarColorScheme(.dark, for: .navigationBar) // Ensures nav items are light
        .task { await fetchTracks() } // Fetch tracks when view appears
        .animation(.easeInOut(duration: 0.4), value: selectedTrackUri) // Animate player appearance
        .refreshable { await fetchTracks(forceReload: true) } // Allow pull-to-refresh
    }

    // --- Fetch Tracks Logic ---
    private func fetchTracks(forceReload: Bool = false) async {
        // Fetch only if needed or forced
        guard forceReload || tracks.isEmpty || trackFetchError != nil else { return }

        await MainActor.run { // Ensure UI updates are on main thread
            isLoadingTracks = true
            trackFetchError = nil // Clear previous error on retry
        }

        do {
            let response = try await SpotifyAPIService.shared.getAlbumTracks(albumId: album.id)
            try Task.checkCancellation() // Check if task was cancelled (e.g., view disappeared)
            await MainActor.run {
                self.tracks = response.items
                self.isLoadingTracks = false
            }
        } catch is CancellationError {
            print("Track fetch cancelled.")
            await MainActor.run { isLoadingTracks = false } // Reset loading state
        } catch let apiError as SpotifyAPIError {
            print("❌ API Error fetching tracks: \(apiError.localizedDescription)")
            await MainActor.run {
                self.trackFetchError = apiError
                self.isLoadingTracks = false
                self.tracks = [] // Clear tracks on error
            }
        } catch {
            print("❌ Unexpected error fetching tracks: \(error.localizedDescription)")
            await MainActor.run {
                self.trackFetchError = .networkError(error) // Categorize unknown errors
                self.isLoadingTracks = false
                self.tracks = []
            }
        }
    }
}

// --- Retro Album List View (Main Screen) ---
struct SpotifyAlbumListView: View {
    @State private var searchQuery: String = ""
    @State private var displayedAlbums: [AlbumItem] = []
    @State private var isLoading: Bool = false
    @State private var searchInfo: Albums? = nil // To store total results, offset etc.
    @State private var currentError: SpotifyAPIError? = nil
    // State for debounce timer
    @State private var debounceTask: Task<Void, Never>? = nil

    var body: some View {
        NavigationView {
            ZStack {
                // --- Background ---
                LinearGradient(colors: [retroDeepPurple, retroMidPurple, retroDeepPurple], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                // Optional subtle background pattern
                 Image("retro_grid_background") // Assumed asset name
                      .resizable().scaledToFill().blendMode(.overlay).opacity(0.08).ignoresSafeArea()

                // --- Main Content Area ---
                Group {
                    if isLoading && displayedAlbums.isEmpty {
                        // Initial Loading Indicator
                        ProgressView()
                             .progressViewStyle(CircularProgressViewStyle(tint: retroNeonCyan))
                             .scaleEffect(1.8) // Make it larger
                             .padding(.bottom, 50)
                    } else if let error = currentError {
                        ErrorPlaceholderView(error: error) { // Themed error view
                             Task { await performSearch(query: searchQuery, immediate: true) } // Retry action
                         }
                    } else if displayedAlbums.isEmpty && !searchQuery.isEmpty {
                         // No results found state (only show if search attempted)
                         EmptyStatePlaceholderView(searchQuery: searchQuery) // Themed empty state
                    } else if displayedAlbums.isEmpty && searchQuery.isEmpty {
                         // Initial empty state (before searching)
                         EmptyStatePlaceholderView(searchQuery: searchQuery)
                    } else {
                        albumList // The list of themed album cards
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity) // Allow placeholder to center
                .transition(.opacity.animation(.easeInOut(duration: 0.3))) // Fade transitions

                // --- Ongoing Loading Header (appears when loading more/refreshing) ---
                if isLoading && !displayedAlbums.isEmpty {
                     VStack { // Position at the top
                         HStack {
                             Spacer()
                             ProgressView().tint(retroNeonLime)
                             Text("LOADING MORE HITS...")
                                 .font(retroFont(size: 12, weight: .bold))
                                 .foregroundColor(retroNeonLime)
                             Spacer()
                         }
                         .padding(.vertical, 8)
                         .padding(.horizontal, 15)
                         .background(.black.opacity(0.7), in: Capsule())
                         .overlay(Capsule().stroke(retroNeonLime.opacity(0.6), lineWidth: 1))
                         .neonGlow(retroNeonLime, radius: 8)
                         .padding(.top, 5) // Space from navigation bar
                         Spacer() // Push to top
                     }
                      .transition(.opacity.combined(with: .move(edge: .top)).animation(.easeInOut))
                 }

            } // End ZStack
            .navigationTitle("RETRO TRACK FINDER") // 90s style title
            .navigationBarTitleDisplayMode(.inline) // Keep title inline
             // --- Themed Navigation Bar ---
             .toolbarBackground(
                 LinearGradient(colors: [retroMidPurple, retroDeepPurple], startPoint: .top, endPoint: .bottom).opacity(0.85),
                 for: .navigationBar
             )
             .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar) // Light items on dark bar
            // --- Search Bar ---
             // System search bar is hard to theme deeply. Use accentColor.
             .searchable(text: $searchQuery,
                         placement: .navigationBarDrawer(displayMode: .always), // Always visible
                         prompt: Text("Search Albums, Artists...").foregroundColor(.gray))
             .accentColor(retroNeonPink) // Tints cursor, cancel button
             .onSubmit(of: .search) { // Trigger search on keyboard submit
                 debounceTask?.cancel() // Cancel any pending debounce
                 Task { await performSearch(query: searchQuery, immediate: true) }
             }
             .onChange(of: searchQuery) {
                 // Reset error when user types
                  if currentError != nil { currentError = nil }
                  // Debounce mechanism
                  debounceTask?.cancel() // Cancel previous task
                  debounceTask = Task { // Create new debounce task
                      await performDebouncedSearch(query: searchQuery)
                  }
             }

        } // End NavigationView
         .accentColor(retroNeonPink) // Global accent for tintable elements
    }

    // --- Themed Album List Content ---
    private var albumList: some View {
        List {
            // --- Metadata Header ---
            if let info = searchInfo, info.total > 0 {
                SearchMetadataHeader(totalResults: info.total, limit: info.limit, offset: info.offset)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 5, leading: 15, bottom: 10, trailing: 15)) // Padding for header
                    .listRowBackground(Color.clear)
            }

            // --- Album Cards ---
            ForEach(displayedAlbums) { album in
                 NavigationLink(destination: AlbumDetailView(album: album)) {
                     RetroAlbumCard(album: album) // Use the themed card
                         .padding(.vertical, 6) // Space between cards
                 }
                 .listRowSeparator(.hidden) // Hide default separators
                 .listRowInsets(EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 15)) // Horizontal padding for rows
                 .listRowBackground(Color.clear) // Ensure row background is clear
            }
            // Add pagination / load more logic here if desired
        }
        .listStyle(PlainListStyle())
        .background(Color.clear) // Make List background transparent
        .scrollContentBackground(.hidden) // Allow ZStack background through
        .refreshable { // Allow pull-to-refresh
             await performSearch(query: searchQuery, immediate: true)
         }
    }

    // --- Debounced Search Logic ---
     private func performDebouncedSearch(query: String) async {
         do {
             try await Task.sleep(for: .milliseconds(600)) // Wait for 600ms
             try Task.checkCancellation() // Check if cancelled by newer input
             await performSearch(query: query, immediate: true) // Perform the actual search
         } catch is CancellationError {
             print("Debounce task for '\(query)' cancelled.")
         } catch {
              print("Error during debounce sleep: \(error)") // Should not happen often
         }
     }

    // --- Actual Search Fetch Logic ---
    private func performSearch(query: String, immediate: Bool = false) async {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else {
            // Clear results if query is empty
            await MainActor.run {
                 displayedAlbums = []
                 searchInfo = nil
                 isLoading = false
                 currentError = nil
             }
            return
        }

        // Ensure UI updates happen on the main thread
        await MainActor.run { isLoading = true }

        do {
            let response = try await SpotifyAPIService.shared.searchAlbums(query: trimmedQuery, offset: 0)
            try Task.checkCancellation() // Check if cancelled before updating UI

            await MainActor.run {
                displayedAlbums = response.albums.items
                searchInfo = response.albums
                currentError = nil // Clear error on success
                isLoading = false
            }
        } catch is CancellationError {
            print("Search task for '\(trimmedQuery)' cancelled.")
              await MainActor.run { isLoading = false } // Ensure loading indicator stops
        } catch let apiError as SpotifyAPIError {
            print("❌ API Error during search: \(apiError.localizedDescription)")
            await MainActor.run {
                displayedAlbums = [] // Clear results on error
                 searchInfo = nil
                 currentError = apiError
                 isLoading = false
            }
        } catch {
            print("❌ Unexpected Error during search: \(error.localizedDescription)")
            await MainActor.run {
                 displayedAlbums = []
                 searchInfo = nil
                 currentError = .networkError(error) // Categorize unknown errors
                 isLoading = false
            }
        }
    }
}

// MARK: - App Entry Point

@main
struct SpotifyRetroApp: App {
    init() {
        // --- Initial Token Check ---
        if placeholderSpotifyToken.isEmpty || placeholderSpotifyToken == "YOUR_SPOTIFY_BEARER_TOKEN_HERE" {
            print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
            print("🚨 RADICAL WARNING: Spotify Bearer Token is MISSING or is the placeholder!")
            print("👉 You NEED to replace 'YOUR_SPOTIFY_BEARER_TOKEN_HERE' in the code.")
            print("   Get a token from https://developer.spotify.com/documentation/web-api/concepts/access-token")
            print("   App will likely crash or show errors without a valid token.")
            print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
        }
        // --- Global Appearance (Optional - can be useful for nav bar consistency) ---
         let appearance = UINavigationBarAppearance()
         // Make nav bar background slightly transparent using the retro theme colors
         appearance.configureWithTransparentBackground()
         appearance.backgroundColor = UIColor(retroDeepPurple.opacity(0.7)) // Semi-transparent purple
         // Set title text attributes
         appearance.titleTextAttributes = [
             .foregroundColor: UIColor(retroTextColor),
             .font: UIFont(name: "Menlo-Bold", size: 18) ?? UIFont.boldSystemFont(ofSize: 18) // Use retro font if possible
         ]
         // Set large title text attributes (if used, though displayMode is .inline here)
         appearance.largeTitleTextAttributes = [
              .foregroundColor: UIColor(retroTextColor),
              .font: UIFont(name: "Menlo-Bold", size: 30) ?? UIFont.boldSystemFont(ofSize: 30)
         ]

         // Apply appearance to standard and compact nav bars
         UINavigationBar.appearance().standardAppearance = appearance
         UINavigationBar.appearance().scrollEdgeAppearance = appearance
         UINavigationBar.appearance().compactAppearance = appearance // For smaller nav bars if applicable

        // Set global tint color for buttons, etc.
         UIView.appearance().tintColor = UIColor(retroNeonPink)
    }

    var body: some Scene {
        WindowGroup {
            SpotifyAlbumListView() // Start with the main retro-themed list view
                .preferredColorScheme(.dark) // Enforce dark mode for the 90s neon theme
        }
    }
}
