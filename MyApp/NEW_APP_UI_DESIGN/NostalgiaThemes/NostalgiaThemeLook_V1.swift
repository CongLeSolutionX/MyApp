//
//  NostalgiaThemeLook_V1.swift
//  MyApp
//
//  Created by Cong Le on 4/20/25.
//

//
//  SpotifyNostalgiaApp.swift
//  MyApp
//
//  Created by AI Synthesizer on Today
//  Comprehensive single-file implementation with a Nostalgia Theme
//

import SwiftUI
@preconcurrency import WebKit // For Spotify Embed
import Foundation

// MARK: - Nostalgia Theme Constants & Helpers

// Color Palette (Muted, retro feel - think faded photos, old tech)
let nostalgiaBackground = Color(hex: "F0EFEB") // Off-white, paper-like
let nostalgiaPrimaryText = Color(hex: "4A4A4A") // Dark Gray, not pure black
let nostalgiaSecondaryText = Color(hex: "78756E") // Muted Gray/Brown
let nostalgiaAccentTeal = Color(hex: "77A6A1") // Faded Teal
let nostalgiaAccentOrange = Color(hex: "DDAF7B") // Muted Orange/Tan
let nostalgiaAccentRose = Color(hex: "C8A7A8") // Dusty Rose
let nostalgiaHighlight = Color(hex: "FFF9E3") // Creamy highlight for selected items

// Font Helpers (Using system fonts - adjust if custom fonts like pixel/script are added)
func nostalgiaTitleFont(size: CGFloat) -> Font {
    // A slightly softer or classic font. Rounded system font can work.
    // Or consider a serif like .system(size:, weight:, design: .serif)
    Font.system(size: size, weight: .bold, design: .rounded)
    // Example Custom: Font.custom("YourNostalgiaSerif", size: size)
}

func nostalgiaBodyFont(size: CGFloat, weight: Font.Weight = .regular) -> Font {
    Font.system(size: size, weight: weight, design: .default) // Standard readable font
    // Example Custom Pixel Font: Font.custom("YourPixelFont", size: size)
}

// Subtle Grain/Noise Modifier (Illustrative - requires better implementation for performance)
struct SubtleGrainView: View {
    @State private var seed = 0
    var opacity: Double = 0.04 // Very subtle

    var body: some View {
        TimelineView(.periodic(from: .now, by: 0.15)) { _ in
            Rectangle()
                .fill(.clear)
                .overlay(
                    NoiseTexture_Nostalgia(seed: seed, density: 0.1, baseColor: nostalgiaPrimaryText)
                        .opacity(opacity)
                        .blendMode(.multiply) // Multiply blend often looks like grain
                )
                .onAppear { seed = Int.random(in: 0...100) }
                .onChange(of: seed) { seed = Int.random(in: 0...100) } // Change seed
        }
        .allowsHitTesting(false)
        .clipped()
    }
}

// Modified Noise Texture for Grain Effect
struct NoiseTexture_Nostalgia: View {
    var seed: Int
    var density: Double
    var baseColor: Color

    var body: some View {
        Canvas { context, size in
            var rng = SeededRandomNumberGenerator_Nostalgia(seed: UInt64(seed))
            for _ in 0..<Int(size.width * size.height * density) {
                let x = Double.random(in: 0...size.width, using: &rng)
                let y = Double.random(in: 0...size.height, using: &rng)
                // Use small, same-color dots for grain
                context.fill(Path(ellipseIn: CGRect(x: x, y: y, width: 1, height: 1)),
                             with: .color(baseColor.opacity(Double.random(in: 0.1...0.5))))
            }
        }
    }
}

// Simple Seeded RNG (Needed for NoiseTexture)
struct SeededRandomNumberGenerator_Nostalgia: RandomNumberGenerator {
    private var state: UInt64
    init(seed: UInt64) { state = seed == 0 ? 1 : seed }
    mutating func next() -> UInt64 {
        state = state &* 1103515245 &+ 12345 // Simple LCG
        return state
    }
}

// Extension for Hex Colors (Standard Helper)
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}

// MARK: - Data Models (Complete & Unchanged)

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
    let type: String
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
                dateFormatter.dateStyle = .medium // e.g., Aug 17, 1959
                dateFormatter.timeStyle = .none
                return dateFormatter.string(from: date)
            }
        default: break
        }
        return release_date
    }
}
struct Artist: Codable, Identifiable, Hashable {
    let id: String
    let external_urls: ExternalUrls?
    let href: String
    let name: String
    let type: String
    let uri: String
}
struct SpotifyImage: Codable, Hashable {
    let height: Int?
    let url: String
    let width: Int?
    var urlObject: URL? { URL(string: url) }
}
struct ExternalUrls: Codable, Hashable {
    let spotify: String?
}
struct AlbumTracksResponse: Codable, Hashable {
    let items: [Track]
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
    let type: String
    let uri: String

    var formattedDuration: String {
        let totalSeconds = "\(duration_ms) / _ \(1000)"
        let minutes = "\(totalSeconds) /_ \(60)"
        let seconds = "\(totalSeconds) %_ \(60)"
        return String(format: "%d:%02d", minutes, seconds)
    }
    var formattedArtists: String {
        artists.map { $0.name }.joined(separator: ", ")
    }
}

// MARK: - API Service (Complete & Unchanged - Placeholder Token)

let placeholderSpotifyToken = "" // !! REPLACE THIS !!

enum SpotifyAPIError: Error, LocalizedError {
    case invalidURL
    case networkError(Error)
    case invalidResponse(Int, String?)
    case decodingError(Error)
    case invalidToken
    case missingData

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid API URL constructed."
        case .networkError(let error): return "Network connectivity issue: \(error.localizedDescription)"
        case .invalidResponse(let code, _): return "Server returned an error (\(code)). Check request or token."
        case .decodingError(let error): return "Failed to decode response data: \(error.localizedDescription)"
        case .invalidToken: return "Spotify API token is invalid or expired. Please replace the placeholder."
        case .missingData: return "Response data was missing expected fields."
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
            throw SpotifyAPIError.invalidToken
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(placeholderSpotifyToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 20
        do {
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw SpotifyAPIError.invalidResponse(0, "Response was not HTTP.")
            }
            guard (200...299).contains(httpResponse.statusCode) else {
                if httpResponse.statusCode == 401 { throw SpotifyAPIError.invalidToken }
                throw SpotifyAPIError.invalidResponse(httpResponse.statusCode, String(data: data, encoding: .utf8))
            }
            do {
                return try JSONDecoder().decode(T.self, from: data)
            } catch {
                throw SpotifyAPIError.decodingError(error)
            }
        } catch let error where !(error is CancellationError) {
            throw error is SpotifyAPIError ? error : SpotifyAPIError.networkError(error)
        }
    }

    func searchAlbums(query: String, limit: Int = 20, offset: Int = 0) async throws -> SpotifySearchResponse {
        var components = URLComponents(string: "https://api.spotify.com/v1/search")
        components?.queryItems = [
            URLQueryItem(name: "q", value: query),
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
        components?.queryItems = [
            URLQueryItem(name: "limit", value: "\(limit)"),
            URLQueryItem(name: "offset", value: "\(offset)")
        ]
        guard let url = components?.url else { throw SpotifyAPIError.invalidURL }
        return try await makeRequest(url: url)
    }
}

// MARK: - Spotify Embed WebView (Functionally Unchanged)

final class SpotifyPlaybackState: ObservableObject {
    @Published var isPlaying: Bool = false
    @Published var currentPosition: Double = 0 // seconds
    @Published var duration: Double = 0 // seconds
    @Published var currentUri: String = "" // Keep track of what's loaded
}

struct SpotifyEmbedWebView: UIViewRepresentable {
    @ObservedObject var playbackState: SpotifyPlaybackState
    let spotifyUri: String? // Which track/album to load

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIView(context: Context) -> WKWebView {
        let userContentController = WKUserContentController()
        // Attach the script message handler
        userContentController.add(context.coordinator, name: "spotifyController")

        let configuration = WKWebViewConfiguration()
        configuration.userContentController = userContentController
        configuration.allowsInlineMediaPlayback = true // Allow playing without fullscreen
        configuration.mediaTypesRequiringUserActionForPlayback = [] // Allow autoplay potentially

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator // For JS alerts/popups
        webView.isOpaque = false // Make transparent
        webView.backgroundColor = .clear
        webView.scrollView.isScrollEnabled = false // Disable scrolling

        // Load initial HTML
        let html = generateHTML()
        webView.loadHTMLString(html, baseURL: nil) // No base URL needed
        context.coordinator.webView = webView // Store reference in coordinator
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        // If the API is ready and the desired URI changed OR it was never loaded
        if context.coordinator.isApiReady && (context.coordinator.lastLoadedUri != spotifyUri || context.coordinator.lastLoadedUri == nil) {
            context.coordinator.loadUri(spotifyUri ?? "invalid:uri")
            // Update playback state's current URI immediately for UI consistency
            DispatchQueue.main.async { if playbackState.currentUri != spotifyUri { playbackState.currentUri = spotifyUri ?? "" } }
        } else if !context.coordinator.isApiReady {
            // If API not ready, store the desired URI to load when it becomes ready
            context.coordinator.updateDesiredUriBeforeReady(spotifyUri ?? "")
        }
    }

    static func dismantleUIView(_ uiView: WKWebView, coordinator: Coordinator) {
        // Clean up resources
        uiView.stopLoading()
        uiView.navigationDelegate = nil
        uiView.uiDelegate = nil
        uiView.configuration.userContentController.removeScriptMessageHandler(forName: "spotifyController")
        coordinator.webView = nil // Release coordinator's reference
        print("Embed: WebView dismantled.")
    }

    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
        var parent: SpotifyEmbedWebView
        weak var webView: WKWebView?
        var isApiReady = false // Flag to track if Spotify IFrame API is ready
        var lastLoadedUri: String? = nil // Track loaded URI to prevent redundant loads
        private var desiredUriBeforeReady: String? = nil // Store URI if updateUIView is called before ready

        init(_ parent: SpotifyEmbedWebView) {
            self.parent = parent
        }

        func updateDesiredUriBeforeReady(_ uri: String) {
            if !isApiReady { desiredUriBeforeReady = uri }
        }

        // --- WKNavigationDelegate Methods ---
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            print("Embed: HTML loaded.")
            // HTML itself doesn't guarantee API is ready, JS Bridge will tell us
        }
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print("Embed Error: Failed navigation - \(error.localizedDescription)")
        }
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            print("Embed Error: Failed provisional navigation - \(error.localizedDescription)")
        }

        // --- WKUIDelegate Method ---
        func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
            print("Embed JS Alert: \(message)")
            completionHandler() // Must call completion handler
        }

        // --- WKScriptMessageHandler Method ---
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            guard message.name == "spotifyController" else { return }

            if let bodyDict = message.body as? [String: Any], let event = bodyDict["event"] as? String {
                // Handle structured event messages
                handleEvent(event: event, data: bodyDict["data"])
            } else if let bodyString = message.body as? String, bodyString == "ready" {
                // Handle the simple "ready" message from the JS 'onSpotifyIframeApiReady'
                handleApiReady()
            } else {
                print("Embed Warning: Received unknown message format: \(message.body)")
            }
        }

        // --- Event Handling Logic ---
        private func handleApiReady() {
            print("✅ Embed: Spotify IFrame API is ready (received 'ready' message).")
            isApiReady = true

            // If there was a URI waiting from updateUIView, load it now
            if let initialUri = desiredUriBeforeReady ?? parent.spotifyUri, !initialUri.isEmpty {
                print("🚀 Embed Native: API ready, proceeding to create controller for initial/pending URI: \(initialUri)")
                createSpotifyController(with: initialUri)
                 desiredUriBeforeReady = nil // Clear pending URI
            } else {
                 print("ℹ️ Embed Native: API ready, but no initial URI provided or pending.")
            }
        }

        private func handleEvent(event: String, data: Any?) {
            // print("Embed Received JS Event: \(event), Data: \(String(describing: data))")
            switch event {
            case "controllerCreated":
                print("✅ Embed: Controller Created successfully via JS.")
                // Potentially update UI or state if needed
            case "playbackUpdate":
                if let updateData = data as? [String: Any] {
                    updatePlaybackState(with: updateData)
                } else {
                    print("Embed Warning: Invalid playbackUpdate data format: \(String(describing: data))")
                }
            case "error":
                let errorMsg = (data as? [String: Any])?["message"] as? String ?? "\(String(describing: data))"
                print("❌ Embed JS Error Received: \(errorMsg)")
                 // TODO: Propagate this error to the UI if needed
            default:
                print("Embed Info: Received unhandled JS event: \(event)")
            }
        }

        private func updatePlaybackState(with data: [String: Any]) {
            // Update the parent's ObservableObject on the main thread
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }

                if let isPaused = data["isPaused"] as? Bool {
                    // Check if state actually changed to avoid redundant updates
                    if self.parent.playbackState.isPlaying == isPaused {
                        self.parent.playbackState.isPlaying = !isPaused
                    }
                }
                if let positionMs = data["position"] as? Double {
                    let newPosition = positionMs / 1000.0
                    // Small threshold to avoid jittery updates
                    if abs(self.parent.playbackState.currentPosition - newPosition) > 0.1 {
                         self.parent.playbackState.currentPosition = newPosition
                    }
                }
                if let durationMs = data["duration"] as? Double {
                    let newDuration = durationMs / 1000.0
                     // Only update if significantly different or initial load
                    if abs(self.parent.playbackState.duration - newDuration) > 0.1 || self.parent.playbackState.duration == 0 {
                       self.parent.playbackState.duration = newDuration
                    }
                }
                 // Also update currentUri based on playback update if necessary
                 if let uri = data["uri"] as? String, self.parent.playbackState.currentUri != uri {
                     self.parent.playbackState.currentUri = uri
                 }
            }
        }

        // --- JS Execution ---
        func createSpotifyController(with initialUri: String) {
            guard let webView = webView else { print("Embed Error: WebView missing for createSpotifyController"); return }
            guard isApiReady else { print("Embed Warning: Attempted createSpotifyController before API ready."); desiredUriBeforeReady = initialUri; return } // Store URI if called too early
            guard lastLoadedUri == nil else {
                 print("Embed Info: Controller instance already exists or creation pending. Last attempted URI: \(lastLoadedUri ?? "None")")

                 // Allow re-loading if the desired URI really changed *after* initial setup was attempted
                 if let latestDesired = desiredUriBeforeReady ?? parent.spotifyUri,
                     latestDesired != lastLoadedUri,
                    !latestDesired.isEmpty {
                     print("🔄 Embed Native: Controller exists, but desired URI changed. Loading new URI: \(latestDesired)")
                     loadUri(latestDesired)
                     desiredUriBeforeReady = nil // Clear pending
                 }
                 return
             }

            print("🚀 Embed Native: Attempting JS createController for URI: \(initialUri)")
            lastLoadedUri = initialUri // Mark as attempting

            // JavaScript to create the controller
            let script = """
            console.log('Spotify Embed JS: createController script running.');
            window.spotifyEmbedController = null; // Ensure clean state
            const embedElement = document.getElementById('embed-iframe');

            if (!embedElement) {
                console.error('Spotify Embed JS: Critical - Element #embed-iframe not found!');
                window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'HTML element #embed-iframe not found.' }});
            } else if (!window.SpotifyIframeApi) { // Corrected API object name
                 console.error('Spotify Embed JS: Critical - SpotifyIframeApi is not available!');
                 window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'Spotify Iframe API object not loaded/available.' }});
            } else {
                console.log('Spotify Embed JS: Found element and API object. Proceeding to create controller for URI: \(initialUri)');
                const controllerOptions = {
                    uri: '\(initialUri)',
                    width: '100%',
                    height: '80' // Standard embed height
                };
                const controllerCallback = (controllerInstance) => {
                    if (!controllerInstance) {
                         console.error('Spotify Embed JS: createController callback received null controller instance!');
                         window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'JS createController callback resulted in null controller.' }});
                         return;
                    }
                    console.log('✅ Spotify Embed JS: Controller instance received successfully.');
                    window.spotifyEmbedController = controllerInstance; // Store globally if needed
                    window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'controllerCreated' });

                    // ----- Attach Listeners -----
                    controllerInstance.addListener('ready', () => {
                        console.log('Spotify Embed JS Event: Controller Ready.');
                        // Optionally post 'ready' state to native if needed beyond the initial setup
                    });
                    controllerInstance.addListener('playback_update', event => {
                        // Post the full event data object
                        window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'playbackUpdate', data: event.data });
                    });
                    controllerInstance.addListener('account_error', event => {
                        console.warn('Spotify Embed JS Event: Account Error -', event.data?.message ?? 'Details unavailable.');
                        window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'Account Error: ' + (event.data?.message ?? 'Premium may be required or login issue.') }});
                    });
                    controllerInstance.addListener('autoplay_failed', () => {
                        console.warn('Spotify Embed JS Event: Autoplay Failed.');
                        window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'Autoplay was blocked by browser.' }});
                        // Optional: Attempt manual play or show UI hint
                         // controllerInstance.play(); // Risky, might also fail
                    });
                     controllerInstance.addListener('initialization_error', event => {
                         console.error('Spotify Embed JS Event: Initialization Error -', event.data?.message ?? 'Details unavailable.');
                         window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'Initialization Error: ' + (event.data?.message ?? 'Failed to initialize player component.') }});
                         // Possibly reset lastLoadedUri here to allow retry? Careful state management needed.
                         // lastLoadedUri = nil; // Problematic if multiple updates happen concurrently
                     });
                     // ----- End Listeners -----

                     // Optional: Start playback immediately after creation?
                     // controllerInstance.play();

                }; // End of callback function

                try {
                    console.log('Spotify Embed JS: Calling SpotifyIframeApi.createController...');
                    window.SpotifyIframeApi.createController(embedElement, controllerOptions, controllerCallback);
                } catch (e) {
                     console.error('Spotify Embed JS: Exception during SpotifyIframeApi.createController call:', e);
                     window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'JS Exception during createController call: ' + (e.message || 'Unknown error') }});
                    // Consider resetting state if the call itself throws synchronously
                     // lastLoadedUri = nil; // Again, careful with concurrent state
                }
            }
            """
            webView.evaluateJavaScript(script) { result, error in
                if let error = error {
                    print("⚠️ Embed Native Error: Evaluating JS for controller creation failed: \(error.localizedDescription)")
                     // If the JS evaluation fails, it's likely the controller wasn't created. Resetting lastLoadedUri might be safer here.
                     self.lastLoadedUri = nil
                } else {
                    // JS executed, but success depends on the asynchronous callback within the JS
                     // print("Embed Native Info: JS for controller creation evaluated. Result: \(String(describing: result))")
                }
            }
        }

        func loadUri(_ uri: String) {
            guard let webView = webView else { print("Embed Error: WebView missing for loadUri"); return }
            guard isApiReady else { print("Embed Warning: Attempted loadUri before API ready."); return }
            guard lastLoadedUri != nil else { print("Embed Warning: Attempted loadUri before controller initialized."); return }
            guard lastLoadedUri != uri else { print("Embed Info: Attempted to load same URI (\(uri)). Skipping."); return } // Don't reload same URI

            print("🚀 Embed Native: Loading new URI via JS: \(uri)")
            lastLoadedUri = uri // Update tracking

            let script = """
            if (window.spotifyEmbedController) {
                console.log('Spotify Embed JS: Loading URI -> \(uri)');
                window.spotifyEmbedController.loadUri('\(uri)');
                // Optionally add .then/.catch promises if the API supports them for loadUri
                // window.spotifyEmbedController.play(); // Start playing new URI immediately? May be unwanted.
            } else {
                console.error('Spotify Embed JS Error: Controller instance not found when trying to load URI.');
                window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'JS controller instance missing during loadUri call.' }});
            }
            """
            webView.evaluateJavaScript(script) { _, error in
                if let error = error {
                    print("⚠️ Embed Native Error: Evaluating JS for loadUri failed: \(error.localizedDescription)")
                    // Should we reset lastLoadedUri here? If JS fails, load didn't happen.
                    // But need context. Maybe the *next* loadUri call will succeed.
                }
            }
        }
    } // End Coordinator

    // Generate HTML (Unchanged)
    private func generateHTML() -> String {
        """
        <!DOCTYPE html><html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no"><title>Spotify Embed</title><style>html, body { margin: 0; padding: 0; width: 100%; height: 100%; overflow: hidden; background-color: transparent; } #embed-iframe { width: 100%; height: 100%; box-sizing: border-box; display: block; border: none; }</style></head><body><div id="embed-iframe"></div><script src="https://open.spotify.com/embed/iframe-api/v1" async></script><script> console.log('Spotify Embed JS: Initial embed.js script running.'); window.onSpotifyIframeApiReady = (IFrameAPI) => { console.log('✅ Spotify Embed JS: onSpotifyIframeApiReady called.'); /* Store API object globally */ window.SpotifyIframeApi = IFrameAPI; /* Notify native app */ if (window.webkit?.messageHandlers?.spotifyController) { window.webkit.messageHandlers.spotifyController.postMessage("ready"); } else { console.error('❌ Spotify Embed JS: Native message handler (spotifyController) is missing!'); } }; /* Error handling for script load */ const scriptTag = document.querySelector('script[src*="iframe-api"]'); scriptTag.onerror = (event) => { console.error('❌ Spotify Embed JS: Failed to load the Spotify IFrame API script:', event); window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'Failed to load Spotify IFrame API script resource.' }}); }; </script></body></html>
        """
    }

} // End SpotifyEmbedWebView

// MARK: - SwiftUI Views (Nostalgia Theme)

// --- Main List View ---
struct SpotifyAlbumListView_Nostalgia: View {
    @State private var searchQuery: String = ""
    @State private var displayedAlbums: [AlbumItem] = []
    @State private var isLoading: Bool = false
    @State private var searchInfo: Albums? = nil
    @State private var currentError: SpotifyAPIError? = nil

    var body: some View {
        NavigationView {
            ZStack {
                // --- Nostalgia Background ---
                nostalgiaBackground.ignoresSafeArea()
                SubtleGrainView() // Add subtle grain texture

                // --- Content Area ---
                VStack(spacing: 0) { // Remove spacing for tighter control
                    contentBody // Main content (list or placeholders)
                }
            } // End ZStack
            .navigationTitle("Music Archive") // Nostalgic title
            .navigationBarTitleDisplayMode(.inline)
            // --- Themed Navigation Bar ---
            .toolbarBackground(nostalgiaBackground.opacity(0.8), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar { // Custom title view for font
                ToolbarItem(placement: .principal) {
                    Text("Music Archive")
                        .font(nostalgiaTitleFont(size: 18))
                        .foregroundColor(nostalgiaPrimaryText)
                }
            }
            // --- Search Bar Styling ---
            .searchable(text: $searchQuery,
                        placement: .navigationBarDrawer(displayMode: .always),
                        prompt: Text("Search albums, artists...").foregroundColor(nostalgiaSecondaryText))
             .onSubmit(of: .search) { Task { await performDebouncedSearch(immediate: true) } }
             .task(id: searchQuery) { await performDebouncedSearch() }
             .onChange(of: searchQuery) { if currentError != nil { currentError = nil } }
             .accentColor(nostalgiaAccentOrange) // Tint for cursor/cancel button

             // --- Loading Indicator (Themed) ---
             .overlay(alignment: .top) {
                if isLoading && !displayedAlbums.isEmpty { // Show only if loading more
                     ProgressView()
                          .progressViewStyle(CircularProgressViewStyle(tint: nostalgiaAccentTeal))
                          .padding(.top, 8) // Position below search bar
                          .transition(.opacity.animation(.easeInOut))
                }
             }

        } // End NavigationView
        .environment(\.colorScheme, .light) // Force light scheme for nostalgia bg
        .tint(nostalgiaAccentOrange) // Global tint for interactive elements like back button
    }

    @ViewBuilder
    private var contentBody: some View {
        if isLoading && displayedAlbums.isEmpty {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: nostalgiaAccentTeal))
                .scaleEffect(1.5)
                .frame(maxHeight: .infinity) // Center vertically
        } else if let error = currentError {
            ErrorPlaceholderView_Nostalgia(error: error) {
                Task { await performDebouncedSearch() }
            }
             .frame(maxHeight: .infinity) // Center vertically
        } else if displayedAlbums.isEmpty {
            EmptyStatePlaceholderView_Nostalgia(searchQuery: searchQuery)
             .frame(maxHeight: .infinity) // Center vertically
        } else {
            albumList_Nostalgia // Themed list
        }
    }

    // --- Themed Album List ---
    private var albumList_Nostalgia: some View {
        List {
            // --- Themed Metadata Header ---
            if let info = searchInfo, info.total > 0 {
                SearchMetadataHeader_Nostalgia(totalResults: info.total, limit: info.limit, offset: info.offset)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 5, leading: 15, bottom: 5, trailing: 15))
                    .listRowBackground(Color.clear)
            }

            // --- Album Cards ---
            ForEach(displayedAlbums) { album in
                NavigationLink { // Use lazy navigation if detail view is heavy
                    AlbumDetailView_Nostalgia(album: album)
                } label: {
                   NostalgiaAlbumCard(album: album)
                      // Add slight padding between cards within the list row background
                      .padding(.vertical, 6)
                }
                 .listRowSeparator(.hidden)
                 .listRowInsets(EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 15)) // Row padding
                 .listRowBackground(Color.clear) // Make row bg transparent
            }
            // TODO: Add pagination / load more indicator here if needed
        }
        .listStyle(PlainListStyle()) // Remove default styling
        .background(Color.clear)
        .scrollContentBackground(.hidden) // Let ZStack bg show through
    }

    // --- Debounced Search Logic (Unchanged) ---
    private func performDebouncedSearch(immediate: Bool = false) async { /* ... */
        let trimmedQuery = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else {
            await MainActor.run { displayedAlbums = []; searchInfo = nil; isLoading = false; currentError = nil }
            return
        }
        if !immediate {
            do { try await Task.sleep(for: .milliseconds(500)); try Task.checkCancellation() }
            catch { print("Search task cancelled (debounce)."); return }
        }
        // Start loading only if query hasn't changed during debounce
        guard trimmedQuery == searchQuery.trimmingCharacters(in: .whitespacesAndNewlines) else { return }

        await MainActor.run { isLoading = true }
        print("⚡️ Performing search for: \(trimmedQuery)")
        do {
            let response = try await SpotifyAPIService.shared.searchAlbums(query: trimmedQuery, offset: 0)
            try Task.checkCancellation()
            await MainActor.run {
                displayedAlbums = response.albums.items
                searchInfo = response.albums
                currentError = nil
                isLoading = false
                print("✅ Search success: \(response.albums.items.count) items loaded.")
            }
        } catch is CancellationError {
            print("Search task cancelled.")
            await MainActor.run { isLoading = false } // Reset loading if cancelled
        } catch let apiError as SpotifyAPIError {
            print("❌ Search API Error: \(apiError.localizedDescription) for query '\(trimmedQuery)'")
            await MainActor.run { displayedAlbums = []; searchInfo = nil; currentError = apiError; isLoading = false }
        } catch {
            print("❌ Search Unexpected Error: \(error.localizedDescription) for query '\(trimmedQuery)'")
            await MainActor.run { displayedAlbums = []; searchInfo = nil; currentError = .networkError(error); isLoading = false }
        }
    }

}

// --- Album Card (Nostalgia Theme) ---
struct NostalgiaAlbumCard: View {
    let album: AlbumItem

    var body: some View {
        HStack(spacing: 15) {
            // --- Album Art ---
            AlbumImageView_Nostalgia(url: album.listImageURL)
                .frame(width: 80, height: 80) // Slightly smaller for list view
                 // Simple border instead of complex overlay
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(nostalgiaSecondaryText.opacity(0.2), lineWidth: 1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                 // No shadow for a flatter, more vintage look

            // --- Text Details ---
            VStack(alignment: .leading, spacing: 4) { // Adjusted spacing
                Text(album.name)
                    .font(nostalgiaTitleFont(size: 16)) // Use themed title font
                    .foregroundColor(nostalgiaPrimaryText)
                    .lineLimit(2) // Allow two lines for longer names

                Text(album.formattedArtists)
                    .font(nostalgiaBodyFont(size: 14))
                    .foregroundColor(nostalgiaAccentTeal) // Accent for artist
                    .lineLimit(1)

                Spacer() // Pushes content up slightly

                HStack(spacing: 8) {
                    // Simple Tag for Type
                    Text(album.album_type.capitalized)
                         .font(nostalgiaBodyFont(size: 10, weight: .medium))
                         .foregroundColor(nostalgiaPrimaryText)
                         .padding(.horizontal, 6)
                         .padding(.vertical, 3)
                         .background(nostalgiaAccentRose.opacity(0.3)) // Tag background
                         .clipShape(Capsule())

                    Text("• \(album.formattedReleaseDate())")
                        .font(nostalgiaBodyFont(size: 11))
                        .foregroundColor(nostalgiaSecondaryText)
                }
                .padding(.top, 2)

                // Adding track count at the bottom
                 Text("\(album.total_tracks) Tracks")
                    .font(nostalgiaBodyFont(size: 11))
                    .foregroundColor(nostalgiaSecondaryText)
                    .padding(.top, 1)

            } // End Text VStack
            .frame(maxWidth: .infinity, alignment: .leading)

        } // End HStack
        .padding(12) // Padding inside the card background
        .background(
            nostalgiaHighlight // Use the creamy highlight as background
             .clipShape(RoundedRectangle(cornerRadius: 12)) // Consistent rounding
             // Add subtle outer border
             .overlay(RoundedRectangle(cornerRadius: 12).stroke(nostalgiaSecondaryText.opacity(0.15), lineWidth: 1))
        )
    }
}

// --- Album Detail View (Nostalgia Theme) ---
struct AlbumDetailView_Nostalgia: View {
    let album: AlbumItem
    @State private var tracks: [Track] = []
    @State private var isLoadingTracks: Bool = false
    @State private var trackFetchError: SpotifyAPIError? = nil
    @State private var selectedTrackUri: String? = nil
    @StateObject private var playbackState = SpotifyPlaybackState()

    // Use system back button color
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Text("Nostalgia Theme")
    }

//    var body: some View {
//        ZStack {
//            // --- Nostalgia Background ---
//            nostalgiaBackground.ignoresSafeArea()
//            SubtleGrainView()
//
//            List {
//                // --- Header Section ---
//                Section {
//                    AlbumHeaderView_Nostalgia(album: album)
//                }
//                .listRowInsets(EdgeInsets())
//                .listRowSeparator(.hidden)
//                .listRowBackground(Color.clear)
//
//                // --- Player Section (Themed) ---
//                if let uriToPlay = selectedTrackUri, !uriToPlay.isEmpty {
//                    Section {
//                        SpotifyEmbedPlayerView_Nostalgia(playbackState: playbackState, spotifyUri: uriToPlay)
//                    }
//                    .listRowSeparator(.hidden)
//                    .listRowInsets(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15))
//                    .listRowBackground(Color.clear)
//                    .transition(.opacity.combined(with: .move(edge: .top)).animation(.easeOut(duration: 0.3)))
//                }
//
//                // --- Tracks Section (Themed) ---
//                Section {
//                      TracksSectionView_Nostalgia(
//                          tracks: tracks,
//                          isLoading: isLoadingTracks,
//                          error: trackFetchError,
//                          selectedTrackUri: $selectedTrackUri,
//                          retryAction: { Task { await fetchTracks() } }
//                      )
//                 } header: {
//                      Text("Tracks") // Simpler header
//                          .font(nostalgiaTitleFont(size: 14))
//                          .foregroundColor(nostalgiaSecondaryText)
//                          .padding(.leading, 15) // Align with row content
//                          .padding(.top, 10)
//                          .padding(.bottom, 5)
//                          .textCase(nil) // Prevent uppercasing
//                 }
//                 .listRowInsets(EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 15)) // Padding for rows
//                 .listRowSeparatorTint(nostalgiaSecondaryText.opacity(0.2)) // Faded separator
//                 .listRowBackground(Color.clear)
//
//                 // --- External Link Section (Themed) ---
//                 if let spotifyURL = URL(string: album.external_urls.spotify ?? "") {
//                      Section {
//                           ExternalLinkButton_Nostalgia(url: spotifyURL)
//                      }
//                      .listRowInsets(EdgeInsets(top: 20, leading: 15, bottom: 20, trailing: 15))
//                      .listRowSeparator(.hidden)
//                      .listRowBackground(Color.clear)
//                 }
//
//            } // End List
//            .listStyle(PlainListStyle())
//              .background(Color.clear)
//              .scrollContentBackground(.hidden)
//              .animation(.default, value: selectedTrackUri) // Animate player appearance
//
//        } // End ZStack
//        // --- Navigation Bar Styling ---
//          .navigationTitle(album.name) // Keep album name
//          .navigationBarTitleDisplayMode(.inline)
//          .toolbar { // Apply font to inline title
//               ToolbarItem(placement: .principal) {
//                    Text(album.name)
//                         .font(nostalgiaTitleFont(size: 17))
//                         .foregroundColor(nostalgiaPrimaryText)
//                         .lineLimit(1)
//               }
//          }
//          .toolbarBackground(nostalgiaBackground.opacity(0.8), for: .navigationBar)
//          .toolbarBackground(.visible, for: .navigationBar)
//          // System handles back button color based on scheme, tint set globally
//
//           .task { await fetchTracks() }
//           .refreshable { await fetchTracks(forceReload: true) }
//    }

    // --- Fetch Tracks Logic (Unchanged) ---
    private func fetchTracks(forceReload: Bool = false) async {
        // Don't fetch if already loaded unless forced
        guard forceReload || tracks.isEmpty || trackFetchError != nil else { return }

        await MainActor.run { isLoadingTracks = true; trackFetchError = nil }
        print("🎵 Fetching tracks for album ID: \(album.id)")
        do {
            let response = try await SpotifyAPIService.shared.getAlbumTracks(albumId: album.id)
             try Task.checkCancellation() // Check before updating state
            await MainActor.run {
                self.tracks = response.items
                self.isLoadingTracks = false
                print("✅ Tracks loaded: \(response.items.count)")
                 // If first load and tracks exist, maybe pre-select the first one?
                 // if forceReload == false && !response.items.isEmpty && selectedTrackUri == nil {
                 //     selectedTrackUri = response.items.first?.uri ?? ""
                 // }
            }
        } catch is CancellationError {
            print("Track fetch cancelled.")
            await MainActor.run { isLoadingTracks = false }
        } catch let apiError as SpotifyAPIError {
            print("❌ Tracks API Error: \(apiError.localizedDescription)")
            await MainActor.run { self.trackFetchError = apiError; self.isLoadingTracks = false; self.tracks = [] }
        } catch {
            print("❌ Tracks Unexpected Error: \(error.localizedDescription)")
            await MainActor.run { self.trackFetchError = .networkError(error); self.isLoadingTracks = false; self.tracks = [] }
        }
    }

}

// --- Detail View Sub-Components (Nostalgia Theme) ---

struct AlbumHeaderView_Nostalgia: View {
    let album: AlbumItem

    var body: some View {
        VStack(spacing: 15) { // More spacing for a relaxed feel
            AlbumImageView_Nostalgia(url: album.bestImageURL)
                .aspectRatio(1.0, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 12)) // Slightly more rounding
                 .overlay(RoundedRectangle(cornerRadius: 12).stroke(nostalgiaSecondaryText.opacity(0.15), lineWidth: 1)) // Subtle border
                .padding(.horizontal, 60) // Center the image more

            VStack(spacing: 6) {
                Text(album.name)
                    .font(nostalgiaTitleFont(size: 20))
                    .foregroundColor(nostalgiaPrimaryText)
                    .multilineTextAlignment(.center)

                Text("by \(album.formattedArtists)")
                    .font(nostalgiaBodyFont(size: 15)) // Slightly smaller
                    .foregroundColor(nostalgiaAccentTeal) // Use Teal accent
                    .multilineTextAlignment(.center)

                Text("\(album.album_type.capitalized) • \(album.formattedReleaseDate())")
                    .font(nostalgiaBodyFont(size: 12, weight: .medium))
                    .foregroundColor(nostalgiaSecondaryText) // Muted text color
            }
            .padding(.horizontal)

        }
        .padding(.vertical, 30) // More vertical padding
    }
}

struct SpotifyEmbedPlayerView_Nostalgia: View {
    @ObservedObject var playbackState: SpotifyPlaybackState
    let spotifyUri: String

    var body: some View {
        VStack(spacing: 8) {
            SpotifyEmbedWebView(playbackState: playbackState, spotifyUri: spotifyUri)
                .frame(height: 85) // Keep standard height
                // --- Themed Player Background ---
                .background(
                     nostalgiaHighlight // Use highlight color for player background
                      .clipShape(RoundedRectangle(cornerRadius: 10))
                      .overlay(RoundedRectangle(cornerRadius: 10).stroke(nostalgiaSecondaryText.opacity(0.15), lineWidth: 1))
                      .shadow(color: nostalgiaSecondaryText.opacity(0.1), radius: 3, y: 2) // Subtle shadow
                )

             // --- Themed Playback Status ---
             HStack {
                   let statusText = playbackState.isPlaying ? "PLAYING" : "PAUSED"
                   let statusColor = playbackState.isPlaying ? nostalgiaAccentTeal : nostalgiaAccentOrange

                   Text(statusText)
                       .font(nostalgiaBodyFont(size: 10, weight: .bold))
                       .foregroundColor(statusColor)
                       .tracking(1.2) // Less extreme tracking
                       .lineLimit(1)
                       .frame(width: 60, alignment: .leading) // Shorter width

                   Spacer()

                   if playbackState.duration > 0.1 {
                       Text("\(formatTime(playbackState.currentPosition)) / \(formatTime(playbackState.duration))")
                           .font(nostalgiaBodyFont(size: 11, weight: .medium))
                           .foregroundColor(nostalgiaSecondaryText)
                   } else {
                       Text("--:-- / --:--")
                           .font(nostalgiaBodyFont(size: 11, weight: .medium))
                           .foregroundColor(nostalgiaSecondaryText.opacity(0.6))
                   }
             }
             .padding(.horizontal, 10) // Adjust padding to match tighter look
             .padding(.top, 4)
             .frame(minHeight: 15)

        } // End VStack

    }

    // Format time (Unchanged)
    private func formatTime(_ time: Double) -> String {
        let totalSeconds = max(0, Int(time))
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

struct TracksSectionView_Nostalgia: View {
    let tracks: [Track]
    let isLoading: Bool
    let error: SpotifyAPIError?
    @Binding var selectedTrackUri: String?
    let retryAction: () -> Void

    var body: some View {
        // No encompassing VStack needed if used directly in List Section
        if isLoading {
            HStack {
                Spacer()
                ProgressView().tint(nostalgiaAccentTeal)
                Text("Loading Tracks...")
                    .font(nostalgiaBodyFont(size: 14))
                    .foregroundColor(nostalgiaSecondaryText)
                    .padding(.leading, 5)
                Spacer()
            }
            .padding(.vertical, 20)
        } else if let error = error {
            ErrorPlaceholderView_Nostalgia(error: error, retryAction: retryAction)
                .padding(.vertical, 20)
        } else if tracks.isEmpty {
            Text("No tracks found for this album.")
                .font(nostalgiaBodyFont(size: 14))
                .foregroundColor(nostalgiaSecondaryText)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 20)
        } else {
            // ForEach iterates through tracks, building rows
            ForEach(tracks) { track in
                TrackRowView_Nostalgia(
                    track: track,
                    isSelected: track.uri == selectedTrackUri
                )
                .contentShape(Rectangle()) // Tappable area
                .onTapGesture {
                    selectedTrackUri = track.uri // Update selection
                }
                // Apply background highlight using listRowBackground in parent List
                .listRowBackground(track.uri == selectedTrackUri ? nostalgiaHighlight.opacity(0.7) : Color.clear)
                .padding(.vertical, 2) // Small padding between rows
            }
        }
    }
}

struct TrackRowView_Nostalgia: View {
    let track: Track
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 12) {
            // --- Track Number ---
            Text("\(track.track_number)")
                .font(nostalgiaBodyFont(size: 12, weight: .medium))
                .foregroundColor(isSelected ? nostalgiaAccentOrange : nostalgiaSecondaryText) // Orange if selected
                .frame(width: 25, alignment: .center)

            // --- Track Info ---
            VStack(alignment: .leading, spacing: 2) { // Tighter spacing
                Text(track.name)
                    .font(nostalgiaBodyFont(size: 15, weight: isSelected ? .medium : .regular)) // Subtle weight change
                    .foregroundColor(nostalgiaPrimaryText)
                    .lineLimit(1)

                Text(track.formattedArtists)
                    .font(nostalgiaBodyFont(size: 12))
                    .foregroundColor(nostalgiaSecondaryText) // Muted artist color
                    .lineLimit(1)
            }

            Spacer()

            // --- Duration ---
            Text(track.formattedDuration)
                .font(nostalgiaBodyFont(size: 12, weight: .medium))
                .foregroundColor(nostalgiaSecondaryText)
                .padding(.trailing, 5)

            // --- Play Indicator ---
            // More subtle indicator
            Image(systemName: isSelected ? "speaker.wave.2.fill" : "play.fill") // Speaker or Play icon
                .foregroundColor(isSelected ? nostalgiaAccentTeal : nostalgiaSecondaryText.opacity(0.7)) // Teal if selected
                .font(.footnote) // Smaller icon
                .frame(width: 20, height: 20, alignment: .center)
                .animation(.easeInOut(duration: 0.2), value: isSelected)

        }
        .padding(.vertical, 10) // Standard vertical padding
    }
}

// --- Other Supporting Views (Nostalgia Theme) ---

struct AlbumImageView_Nostalgia: View {
    let url: URL?

    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
                ZStack {
                    // Placeholder background
                    RoundedRectangle(cornerRadius: 8).fill(nostalgiaSecondaryText.opacity(0.1))
                    ProgressView().tint(nostalgiaAccentOrange)
                }
            case .success(let image):
                image.resizable()
                    .aspectRatio(contentMode: .fill) // Fill the frame
                    // Apply a subtle nostalgic filter (optional)
                    // .saturation(0.85) // Slightly desaturate
                    // .contrast(0.9)    // Reduce contrast slightly
                    // .overlay(Color.black.opacity(0.03)) // Very subtle dark overlay

            case .failure:
                ZStack {
                    RoundedRectangle(cornerRadius: 8).fill(nostalgiaSecondaryText.opacity(0.1))
                    Image(systemName: "photo.on.rectangle.angled") // Generic placeholder icon
                        .resizable().scaledToFit()
                        .foregroundColor(nostalgiaSecondaryText.opacity(0.4))
                        .padding(15) // Padding for the icon
                }
            @unknown default:
                EmptyView()
            }
        }
    }
}

struct SearchMetadataHeader_Nostalgia: View {
    let totalResults: Int
    let limit: Int
    let offset: Int

    var body: some View {
        HStack {
            Text("\(totalResults) found") // Simpler text
            Spacer()
            if totalResults > limit {
                Text("Showing \(offset + 1)-\(min(offset + limit, totalResults))")
            }
        }
        .font(nostalgiaBodyFont(size: 11, weight: .medium))
        .foregroundColor(nostalgiaSecondaryText)
        .padding(.vertical, 4) // Less vertical padding
    }
}

struct ErrorPlaceholderView_Nostalgia: View {
    let error: SpotifyAPIError
    let retryAction: (() -> Void)?

    var body: some View {
        VStack(spacing: 20) { // Adjusted spacing
             Image(systemName: iconName) // Keep system icons for clarity
                .font(.system(size: 50))
                .foregroundColor(nostalgiaAccentRose) // Use Rose accent for errors
                .padding(.bottom, 10)

            Text("Oops! Something went wrong...")
                .font(nostalgiaTitleFont(size: 18))
                .foregroundColor(nostalgiaPrimaryText)
                .multilineTextAlignment(.center)

             Text(errorMessage)
                .font(nostalgiaBodyFont(size: 14))
                .foregroundColor(nostalgiaSecondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
                .lineSpacing(4)

//            if error as? SpotifyAPIError != .invalidToken, let retryAction = retryAction {
//                 NostalgiaButton(text: "Try Again", action: retryAction, iconName: "arrow.clockwise")
//                     .padding(.top, 15)
//            } else if error as? SpotifyAPIError == .invalidToken {
//                // Special message for token error
//                Text("Please check your Spotify API token in the code and restart.")
//                     .font(nostalgiaBodyFont(size: 12))
//                     .foregroundColor(nostalgiaAccentOrange)
//                     .multilineTextAlignment(.center)
//                     .padding(.top, 10)
//            }
            Text("Please check your Spotify API token in the code and restart.")
                .font(nostalgiaBodyFont(size: 12))
                .foregroundColor(nostalgiaAccentOrange)
                .multilineTextAlignment(.center)
                .padding(.top, 10)
        }
        .padding(30)
    }

     // Icon and message logic (Unchanged)
     private var iconName: String {
          switch error {
          case .invalidToken: return "key.slash"
          case .networkError: return "wifi.slash" // "Slash" feels more vintage error
          case .invalidResponse, .decodingError, .missingData: return "exclamationmark.triangle"
          case .invalidURL: return "link.badge.xmark" // XMark for invalid
          }
     }
     private var errorMessage: String {
          error.localizedDescription // Use the error's own description
     }
}

struct EmptyStatePlaceholderView_Nostalgia: View {
     let searchQuery: String

     var body: some View {
        VStack(spacing: 20) {
            Image(systemName: iconName)
                .font(.system(size: 60))
                .foregroundColor(nostalgiaSecondaryText.opacity(0.5)) // Muted icon
                .padding(.bottom, 15)

            Text(title)
                .font(nostalgiaTitleFont(size: 18))
                .foregroundColor(nostalgiaPrimaryText)

             Text(messageAttributedString)
                .font(nostalgiaBodyFont(size: 14))
                .foregroundColor(nostalgiaSecondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
                .lineSpacing(4)
        }
        .padding(30)
     }

     // Logic remains the same
     private var isInitialState: Bool { searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
     private var iconName: String { isInitialState ? "music.note.list" : "magnifyingglass" } // Simple icons
     private var title: String { isInitialState ? "Ready to Browse" : "No Matches" }
     private var messageAttributedString: AttributedString {
         var message: AttributedString
         if isInitialState {
              message = AttributedString("Start typing above to search the music archive.")
         } else {
              do {
                   let query = searchQuery.isEmpty ? "your search" : searchQuery
                   message = try AttributedString(markdown: "Couldn't find anything matching **\(query)**. Try different keywords?")
              } catch {
                   message = AttributedString("Couldn't find anything matching \"\(searchQuery)\". Try different keywords?")
              }
         }
          // Apply consistent font/color
          message.font = nostalgiaBodyFont(size: 14)
          message.foregroundColor = nostalgiaSecondaryText
         return message
     }
}

// --- Themed Button Component ---
struct NostalgiaButton: View {
    let text: String
    let action: () -> Void
    var primaryColor: Color = nostalgiaAccentTeal // Default Teal
    var textColor: Color = .white
    var iconName: String? = nil

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let iconName = iconName {
                    Image(systemName: iconName)
                        .font(.body.weight(.medium)) // Match text weight
                }
                Text(text)
            }
            .font(nostalgiaBodyFont(size: 15, weight: .medium))
            .padding(.horizontal, 20)
            .padding(.vertical, 10) // Standard button padding
            .frame(maxWidth: .infinity)
            .background(primaryColor)
            .foregroundColor(textColor)
            .clipShape(RoundedRectangle(cornerRadius: 8)) // Rounded rect instead of capsule
             // Subtle shadow for depth
            .shadow(color: nostalgiaSecondaryText.opacity(0.2), radius: 3, y: 2)
        }
        .buttonStyle(.plain) // Ensure custom background/foreground work
    }
}

 // --- Themed External Link Button ---
 struct ExternalLinkButton_Nostalgia: View {
     let text: String = "Open in Spotify"
     let url: URL
     @Environment(\.openURL) var openURL

     var body: some View {
         NostalgiaButton(
             text: text,
             action: { openURL(url) },
             primaryColor: Color(hex: "1DB954"), // Spotify Green
             textColor: .white,
             iconName: "arrow.up.forward.app" // Spotify-like icon
         )
     }
 }

#Preview("SpotifyAlbumListView_Nostalgia") {
    SpotifyAlbumListView_Nostalgia()
}

// MARK: - App Entry Point

@main
struct SpotifyNostalgiaApp: App {
    init() {
        // --- Token Check ---
        if placeholderSpotifyToken == "YOUR_SPOTIFY_BEARER_TOKEN_HERE" {
            print("🚨📼 WARNING: Spotify Bearer Token missing! API calls will fail.")
            print("👉 FIX: Replace 'YOUR_SPOTIFY_BEARER_TOKEN_HERE' in SpotifyAPIService.swift")
        }
        // You could apply some global UINavigationBar appearance here if needed,
        // but direct modifiers in views are often preferred in SwifUI.
    }

    var body: some Scene {
        WindowGroup {
            SpotifyAlbumListView_Nostalgia()
                // Set preferred scheme if needed, but theme aims for light mode feel
                // .preferredColorScheme(.light)
        }
    }
}
