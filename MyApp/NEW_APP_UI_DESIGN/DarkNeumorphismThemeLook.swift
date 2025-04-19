//
//  DarkNeumorphismThemeLook.swift
//  MyApp
//
//  Created by Cong Le on 4/18/25.
//

import SwiftUI
@preconcurrency import WebKit // For Spotify Embed WebView
import Foundation

// MARK: - Dark Neumorphism Theme Constants & Helpers

struct DarkNeumorphicTheme {
    static let background = Color(red: 0.14, green: 0.16, blue: 0.19) // Dark gray base
    static let elementBackground = Color(red: 0.18, green: 0.20, blue: 0.23) // Slightly lighter for elements
    static let lightShadow = Color.white.opacity(0.1) // Subtle white highlight
    static let darkShadow = Color.black.opacity(0.5)  // Deeper black shadow
    
    static let primaryText = Color.white.opacity(0.85)
    static let secondaryText = Color.gray.opacity(0.7)
    
    // Accent color (subtle) - Adjust saturation/brightness as needed
    static let accentColor = Color(hue: 0.6, saturation: 0.3, brightness: 0.7) // Muted blue/purple
    static let errorColor = Color(hue: 0.0, saturation: 0.5, brightness: 0.7) // Muted red
    
    static let shadowRadius: CGFloat = 6
    static let shadowOffset: CGFloat = 4
}

// Font helper (using system fonts for simplicity)
func neumorphicFont(size: CGFloat, weight: Font.Weight = .regular, design: Font.Design = .default) -> Font {
    return Font.system(size: size, weight: weight, design: design)
}

//MARK: -> Neumorphic View Modifiers / Styles

// --- Outer Shadow for Extruded Elements ---
struct NeumorphicOuterShadow: ViewModifier {
    var isPressed: Bool = false // Optional state for pressed look
    let cornerRadius: CGFloat = 15
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(DarkNeumorphicTheme.elementBackground)
                    .shadow(color: DarkNeumorphicTheme.darkShadow,
                            radius: DarkNeumorphicTheme.shadowRadius,
                            x: DarkNeumorphicTheme.shadowOffset,
                            y: DarkNeumorphicTheme.shadowOffset)
                    .shadow(color: DarkNeumorphicTheme.lightShadow,
                            radius: DarkNeumorphicTheme.shadowRadius,
                            x: -DarkNeumorphicTheme.shadowOffset,
                            y: -DarkNeumorphicTheme.shadowOffset)
            )
    }
}

// --- Inner Shadow for Depressed Elements (More complex) ---
// Often simulated by layering or specific button styles
struct NeumorphicInnerShadow: ViewModifier {
    let cornerRadius: CGFloat = 15
    
    func body(content: Content) -> some View {
        // This is one way to approximate inner shadow
        content
            .padding(2) // Adjust padding for inset amount
            .background(DarkNeumorphicTheme.elementBackground) // Base color inside
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay( // Simulate the inner shadows on the container
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(DarkNeumorphicTheme.background, lineWidth: 4) // Match background
                    .shadow(color: DarkNeumorphicTheme.darkShadow, radius: DarkNeumorphicTheme.shadowRadius - 1, x: DarkNeumorphicTheme.shadowOffset - 1, y: DarkNeumorphicTheme.shadowOffset - 1)
                    .shadow(color: DarkNeumorphicTheme.lightShadow, radius: DarkNeumorphicTheme.shadowRadius - 1, x: -(DarkNeumorphicTheme.shadowOffset - 1), y: -(DarkNeumorphicTheme.shadowOffset - 1))
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius)) // Clip shadows to the inside edge
            )
    }
}

// --- Neumorphic Button Style ---
struct NeumorphicButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, 12)
            .padding(.horizontal, 20)
            .background(
                NeumorphicButtonBackground(isPressed: configuration.isPressed)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0) // Subtle scale on press
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// Helper for button background state
struct NeumorphicButtonBackground: View {
    var isPressed: Bool
    let cornerRadius: CGFloat = 20 // Use a consistent radius
    
    var body: some View {
        // Use ZStack to layer shadows correctly for pressed/unpressed state
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(DarkNeumorphicTheme.elementBackground)
            
            if isPressed {
                // Simulate Inner Shadow: Apply outer shadows to an inset shape
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(DarkNeumorphicTheme.elementBackground, lineWidth: 4) // Stroke slightly darker might enhance inset
                    .shadow(color: DarkNeumorphicTheme.darkShadow, radius: DarkNeumorphicTheme.shadowRadius / 2, x: DarkNeumorphicTheme.shadowOffset / 2, y: DarkNeumorphicTheme.shadowOffset / 2)
                    .shadow(color: DarkNeumorphicTheme.lightShadow, radius: DarkNeumorphicTheme.shadowRadius / 2, x: -DarkNeumorphicTheme.shadowOffset / 2, y: -DarkNeumorphicTheme.shadowOffset / 2)
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            } else {
                // Outer Shadow (Extruded)
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(DarkNeumorphicTheme.elementBackground) // Needed again to draw shadows on
                    .shadow(color: DarkNeumorphicTheme.darkShadow,
                            radius: DarkNeumorphicTheme.shadowRadius,
                            x: DarkNeumorphicTheme.shadowOffset,
                            y: DarkNeumorphicTheme.shadowOffset)
                    .shadow(color: DarkNeumorphicTheme.lightShadow,
                            radius: DarkNeumorphicTheme.shadowRadius,
                            x: -DarkNeumorphicTheme.shadowOffset,
                            y: -DarkNeumorphicTheme.shadowOffset)
            }
        }
    }
}

// MARK: - Data Models (Unchanged from previous versions)

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

// MARK: - API Service (Unchanged, uses placeholder token)

// IMPORTANT: Replace this with your actual Spotify Bearer Token
let placeholderSpotifyToken = "BQCTSV0UBhP3ittQgvrBE3ShubwjvUvOjkIR5XvqT3-U5fK-5AtSRfRLHFwQwqxl-YfMLQQXrycH6SlNSwc808_gnpRNJ7h-J7hDb1O3jG-UN2nkW-FwRQT4OKdu95GbNwRtluhh05fc9qqXCl5p-H3CHOIdnDo_r1LpGAXI1IPo3dMm5J437dqStIqVx1ueKfkHbQMfZCOD_AbwMwKD5-4YgknRWlfUkC8GWYS1b8kBxXv4z98ABq3kEKyiJ8VXPB5Dr0LA-W2upGcjmaF2A4HrZlO-KNnrH9m56sdgH-Rj-b5BDnY5iCkfAcYgCQO5"

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

// MARK: - Spotify Embed WebView (Minor adjustments for theme consistency)

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
        // --- Configuration ---
        let userContentController = WKUserContentController()
        userContentController.add(context.coordinator, name: "spotifyController")
        
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = userContentController
        configuration.allowsInlineMediaPlayback = true // Important for embed player
        configuration.mediaTypesRequiringUserActionForPlayback = [] // Attempt auto-play
        
        // --- WebView Creation ---
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.isOpaque = false
        webView.backgroundColor = .clear // Keep transparent; SwiftUI container handles background
        webView.scrollView.isScrollEnabled = false // Disable scrolling for the embed
        
        // --- Initial Load ---
        webView.loadHTMLString(generateHTML(), baseURL: nil)
        
        // --- Store Coordinator Reference ---
        context.coordinator.webView = webView
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        print("🔄 Spotify Embed WebView: updateUIView called. API Ready: \(context.coordinator.isApiReady), Last/Current URI: \(context.coordinator.lastLoadedUri ?? "nil") / \(spotifyUri ?? "nil")")
        
        // Only load a new URI if the API is ready and the URI has actually changed.
        if context.coordinator.isApiReady && context.coordinator.lastLoadedUri != spotifyUri {
            print(" -> Loading URI in updateUIView.")
            context.coordinator.loadUri(spotifyUri ?? "")
        } else if !context.coordinator.isApiReady {
            // If updateUIView is called *before* the API is ready,
            // make sure the coordinator knows the latest desired URI.
            context.coordinator.updateDesiredUriBeforeReady(spotifyUri ?? "")
        }
    }
    
    static func dismantleUIView(_ webView: WKWebView, coordinator: Coordinator) {
        print("🧹 Spotify Embed WebView: Dismantling.")
        webView.stopLoading()
        // Safely remove the message handler
        webView.configuration.userContentController.removeScriptMessageHandler(forName: "spotifyController")
        coordinator.webView = nil // Clear coordinator's reference
    }
    
    // --- Coordinator Class ---
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
            // Don't assume API is ready here; wait for JS message.
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print("❌ Spotify Embed WebView: Navigation failed: \(error.localizedDescription)")
            DispatchQueue.main.async { self.parent.playbackState.error = "WebView Navigation Failed: \(error.localizedDescription)" }
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            print("❌ Spotify Embed WebView: Provisional navigation failed: \(error.localizedDescription)")
            DispatchQueue.main.async { self.parent.playbackState.error = "WebView Provisional Navigation Failed: \(error.localizedDescription)" }
        }
        
        // Handle messages from JavaScript
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            guard message.name == "spotifyController" else { return }
            
            if let bodyDict = message.body as? [String: Any], let event = bodyDict["event"] as? String {
                print("📩 JS Event: '\(event)' Data: \(bodyDict["data"] ?? "nil")")
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
            
            // Use the most recently desired URI when creating the controller
            if let initialUri = desiredUriBeforeReady ?? parent.spotifyUri {
                createSpotifyController(with: initialUri)
                desiredUriBeforeReady = nil // Clear it after use
            } else {
                print("⚠️ Spotify Embed Native: API Ready, but no initial URI to load.")
            }
        }
        
        private func handleEvent(event: String, data: Any?) {
            switch event {
            case "controllerCreated":
                print("✅ Spotify Embed Native: Embed controller successfully created.")
                // No state update needed here, but good for debugging.
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
                
                if let isPaused = data["paused"] as? Bool {
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
                // Update URI importantly, reset position/duration if URI changes
                if let uri = data["uri"] as? String, self.parent.playbackState.currentUri != uri {
                    self.parent.playbackState.currentUri = uri
                    self.parent.playbackState.currentPosition = 0 // Reset position on track change
                    self.parent.playbackState.duration = data["duration"] as? Double ?? 0 // Reset/update duration
                    stateChanged = true
                }
                
                // Clear error if we get a valid playback update
                if stateChanged && self.parent.playbackState.error != nil {
                    self.parent.playbackState.error = nil
                }
            }
        }
        
        private func createSpotifyController(with initialUri: String) {
            guard let webView = webView, isApiReady else {
                print("⚠️ Spotify Embed Native: Cannot create controller - WebView or API not ready.")
                return
            }
            // Prevent re-initialization if already loaded or attempted
            guard lastLoadedUri == nil else {
                print("ℹ️ Spotify Embed Native: Controller already initialized or creation pending. Desired URI: \(initialUri)")
                // If the desired URI changed *after* API ready but *before* controller creation finished
                if let latestDesired = desiredUriBeforeReady ?? parent.spotifyUri, latestDesired != lastLoadedUri {
                    print(" -> Correcting URI before loading: \(latestDesired)")
                    loadUri(latestDesired)
                }
                desiredUriBeforeReady = nil // Ensure it's cleared
                return
            }
            
            print("🚀 Spotify Embed Native: Attempting to create controller for URI: \(initialUri)")
            lastLoadedUri = initialUri // Mark as attempting/loaded
            
            // --- JavaScript for Controller Creation ---
            let script = """
            console.log('Spotify Embed JS: Running create controller script.');
            window.embedController = null; // Clear any old reference
            const element = document.getElementById('embed-iframe');
            if (!element) { console.error('JS Error: #embed-iframe not found!'); window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'HTML element embed-iframe not found' }}); }
            else if (!window.IFrameAPI) { console.error('JS Error: IFrameAPI not loaded!'); window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'Spotify IFrame API not loaded' }}); }
            else {
                console.log('JS: Found element and API. Creating controller for: \(initialUri)');
                const options = { uri: '\(initialUri)', width: '100%', height: '100%' }; // Use 100% height
                const callback = (controller) => {
                    if (!controller) { console.error('JS Error: createController callback received null!'); window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'JS callback received null controller' }}); return; }
                    console.log('✅ JS: Controller instance received.');
                    window.embedController = controller;
                    window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'controllerCreated' });
                    
                    // --- Add Listeners ---
                    controller.addListener('ready', () => { console.log('🎧 JS Event: Controller Ready.'); }); // API ready is different from controller ready
                    controller.addListener('playback_update', e => { window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'playbackUpdate', data: e.data }); });
                    controller.addListener('account_error', e => { console.warn('💰 JS Event: Account Error:', e.data); window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'Account Error: ' + (e.data?.message ?? 'Premium or Login Required') }}); });
                    controller.addListener('autoplay_failed', () => { console.warn('⏯️ JS Event: Autoplay failed'); window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'Autoplay Failed' }}); controller.play(); }); // Attempt manual play
                    controller.addListener('initialization_error', e => { console.error('💥 JS Event: Init Error:', e.data); window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'Initialization Error: ' + (e.data?.message ?? 'Failed to init player') }}); });
                };
                try {
                    console.log('JS: Calling IFrameAPI.createController...');
                    window.IFrameAPI.createController(element, options, callback);
                } catch (e) {
                    console.error('💥 JS Exception during createController:', e);
                    window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'JS Exception: ' + e.message }});
                    // Consider resetting lastLoadedUri here if the exception means creation failed fundamentally
                    lastLoadedUri = nil;
                }
            }
            """
            webView.evaluateJavaScript(script) { _, error in
                if let error = error { print("⚠️ Spotify Native: Error evaluating JS for controller creation: \(error.localizedDescription)") }
            }
        }
        
        func loadUri(_ uri: String) {
            guard let webView = webView, isApiReady else { return }
            guard let currentControllerUri = lastLoadedUri, currentControllerUri != uri else {
                print("ℹ️ Spotify Embed Native: Skipping loadUri - controller not ready or URI hasn't changed (\(lastLoadedUri ?? "nil") vs \(uri)).")
                // If URI hasn't changed, maybe just ensure it's playing?
                // if currentControllerUri == uri { executeJsCommand("play") }
                return
            }
            
            print("🚀 Spotify Embed Native: Loading new URI via JS: \(uri)")
            lastLoadedUri = uri // Update the loaded URI
            
            let script = """
            if (window.embedController) {
                console.log('JS: Loading URI: \(uri)');
                window.embedController.loadUri('\(uri)');
                window.embedController.play(); // Attempt to play immediately
            } else { console.error('JS Error: embedController not found for loadUri \(uri).'); window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'JS embedController missing during loadUri' }}); }
            """
            webView.evaluateJavaScript(script) { _, error in
                if let error = error { print("⚠️ Spotify Native: Error evaluating JS load URI \(uri): \(error.localizedDescription)") }
            }
        }
        
        // Generic JS command function (optional helper)
        func executeJsCommand(_ command: String) {
            guard let webView = webView, lastLoadedUri != nil else { return }
            print("▶️ Spotify Embed Native: Executing JS command: \(command)")
            let script = "if (window.embedController) { window.embedController.\(command)(); } else { console.warn('JS Warning: Controller not ready for command \(command)'); }"
            webView.evaluateJavaScript(script) { _, error in
                if let error = error { print("⚠️ Spotify Native: Error running JS command \(command): \(error.localizedDescription)") }
            }
        }
        
        // WKUIDelegate method (optional, for JS alerts)
        func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
            print("ℹ️ Spotify Embed Received JS Alert: \(message)")
            completionHandler() // Just dismiss the alert
        }
    }
    
    // --- Generate HTML ---
    private func generateHTML() -> String {
        // Basic HTML structure for the embed iframe
        return """
        <!DOCTYPE html><html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no"><title>Spotify Embed</title><style>html, body { margin: 0; padding: 0; width: 100%; height: 100%; overflow: hidden; background-color: transparent; } #embed-iframe { width: 100%; height: 100%; box-sizing: border-box; display: block; border: none; }</style></head><body><div id="embed-iframe"></div><script src="https://open.spotify.com/embed/iframe-api/v1" async></script><script> console.log('Spotify Embed JS: Initial script running.'); var spotifyControllerCallbackIsSet = false; window.onSpotifyIframeApiReady = (IFrameAPI) => { if (spotifyControllerCallbackIsSet) return; /* Prevent double calls */ console.log('✅ Spotify Embed JS: API Ready.'); window.IFrameAPI = IFrameAPI; spotifyControllerCallbackIsSet = true; if (window.webkit?.messageHandlers?.spotifyController) { window.webkit.messageHandlers.spotifyController.postMessage("ready"); } else { console.error('❌ JS: Native message handler (spotifyController) not found!'); } }; const scriptTag = document.querySelector('script[src*="iframe-api"]'); if (scriptTag) { scriptTag.onerror = (event) => { console.error('❌ JS: Failed to load Spotify API script:', event); window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'Failed to load Spotify API script' }}); }; } else { console.warn('⚠️ JS: Could not find API script tag.'); } </script></body></html>
        """
    }
}

// MARK: - SwiftUI Views (Dark Neumorphism Themed)

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
                // --- Neumorphic Background ---
                DarkNeumorphicTheme.background.ignoresSafeArea()
                
                // --- Content Area ---
                VStack(spacing: 0) { // Use spacing 0 for seamless look
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
                            // Initial empty state (optional customization)
                             EmptyStatePlaceholderView(searchQuery: "")
                        } else {
                            albumScrollView // Use ScrollView for custom list
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            } // End ZStack
            .navigationTitle("Spotify Search")
            .navigationBarTitleDisplayMode(.large) // Or .inline
            .toolbar {
                // Optional: Clear background for nav bar if using native large title
                // ToolbarItemGroup(placement: .navigationBarLeading) { Text("") } // Hack to potentially force background styles
            }
            // --- Search Bar ---
            .searchable(text: $searchQuery,
                        placement: .navigationBarDrawer(displayMode: .always),
                        prompt: Text("Search Albums / Artists").foregroundColor(.gray))
            .onSubmit(of: .search) { Task { await performDebouncedSearch(immediate: true) } }
            .task(id: searchQuery) { await performDebouncedSearch() } // Debounced search
             .onChange(of: searchQuery) { if currentError != nil { currentError = nil } } // Clear error on new typing
             .accentColor(DarkNeumorphicTheme.accentColor) // Tint cursor/cancel button subtly
            
        } // End NavigationView
        .navigationViewStyle(.stack) // Consistent style
        .preferredColorScheme(.dark) // Ensure dark mode context
    }
    
    // --- Themed Scrollable Album List ---
    private var albumScrollView: some View {
        ScrollView {
            LazyVStack(spacing: 18) { // Add spacing between cards
                // --- Metadata Header (Themed) ---
                if let info = searchInfo, info.total > 0 {
                    SearchMetadataHeader(totalResults: info.total, limit: info.limit, offset: info.offset)
                        .padding(.horizontal)
                        .padding(.top, 5) // Space from search bar/title
                }
                
                // --- Album Cards ---
                ForEach(displayedAlbums) { album in
                    NavigationLink(destination: AlbumDetailView(album: album)) {
                        NeumorphicAlbumCard(album: album)
                    }
                    .buttonStyle(.plain) // Prevent default link styling interfering
                }
            }
            .padding(.horizontal) // Padding for the entire scroll content
            .padding(.bottom) // Bottom padding
        }
        .scrollDismissesKeyboard(.interactively) // iOS 16+
    }
    
    // --- Themed Loading Indicator ---
    private var loadingIndicator: some View {
        VStack {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: DarkNeumorphicTheme.accentColor))
                .scaleEffect(1.5)
            Text("Loading...")
                .font(neumorphicFont(size: 14))
                .foregroundColor(DarkNeumorphicTheme.secondaryText)
                .padding(.top, 10)
        }
    }
    
    // --- Debounced Search Logic (Unchanged) ---
    private func performDebouncedSearch(immediate: Bool = false) async {
        let trimmedQuery = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else {
            Task { @MainActor in displayedAlbums = []; searchInfo = nil; isLoading = false; currentError = nil }
            return
        }
        
        Task { @MainActor in isLoading = true } // Show loading immediately
        
        if !immediate {
            do { try await Task.sleep(for: .milliseconds(500)); try Task.checkCancellation() } // Standard debounce time
            catch { print("Search task cancelled (debounce)."); Task { @MainActor in isLoading = false }; return }
        }
        
        // Check if query is still the same after debounce
        guard trimmedQuery == searchQuery.trimmingCharacters(in: .whitespacesAndNewlines) else {
             print("Search query changed during debounce, skipping.")
             Task { @MainActor in isLoading = false } // Hide loading if query changed
             return
        }
        
        do {
            print("🚀 Performing search for: \(trimmedQuery)")
            let response = try await SpotifyAPIService.shared.searchAlbums(query: trimmedQuery, limit: 20, offset: 0)
            try Task.checkCancellation()
            await MainActor.run {
                displayedAlbums = response.albums.items
                searchInfo = response.albums
                currentError = nil
                isLoading = false
                print("✅ Search successful, \(response.albums.items.count) items loaded.")
            }
        } catch is CancellationError {
            print("Search task cancelled.")
            await MainActor.run { isLoading = false } // Ensure loading is hidden
        } catch let apiError as SpotifyAPIError {
            print("❌ API Error: \(apiError.localizedDescription)")
            await MainActor.run { displayedAlbums = []; searchInfo = nil; currentError = apiError; isLoading = false }
        } catch {
            print("❌ Unexpected Error: \(error.localizedDescription)")
            await MainActor.run { displayedAlbums = []; searchInfo = nil; currentError = .networkError(error); isLoading = false }
        }
    }
}

// MARK: Neumorphic Album Card
struct NeumorphicAlbumCard: View {
    let album: AlbumItem
    private let cardCornerRadius: CGFloat = 20
    
    var body: some View {
        HStack(spacing: 15) {
            // --- Album Art (Slightly inset or with neumorphic border) ---
            AlbumImageView(url: album.listImageURL)
                .frame(width: 80, height: 80) // Smaller image for list
                .clipShape(RoundedRectangle(cornerRadius: 12))
                 // Subtle border matching element background emphasizes the shape
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(DarkNeumorphicTheme.elementBackground.opacity(0.5), lineWidth: 1))
                 // Add a very subtle outer shadow to the image itself
                // .shadow(color: DarkNeumorphicTheme.darkShadow.opacity(0.3), radius: 3, x: 2, y: 2)
                // .shadow(color: DarkNeumorphicTheme.lightShadow.opacity(0.05), radius: 3, x: -2, y: -2)

            // --- Text Details ---
            VStack(alignment: .leading, spacing: 4) {
                Text(album.name)
                    .font(neumorphicFont(size: 15, weight: .semibold))
                    .foregroundColor(DarkNeumorphicTheme.primaryText)
                    .lineLimit(2)
                
                Text(album.formattedArtists)
                    .font(neumorphicFont(size: 13))
                    .foregroundColor(DarkNeumorphicTheme.secondaryText)
                    .lineLimit(1)
                
                Spacer() // Push bottom info down
                
                HStack(spacing: 8) {
                    Text(album.album_type.capitalized)
                        .font(neumorphicFont(size: 10, weight: .medium))
                        .foregroundColor(DarkNeumorphicTheme.secondaryText)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                         // Simple background for the tag
                        .background(DarkNeumorphicTheme.background.opacity(0.6), in: Capsule())
                     
                    Text("• \(album.formattedReleaseDate())")
                        .font(neumorphicFont(size: 10, weight: .medium))
                        .foregroundColor(DarkNeumorphicTheme.secondaryText)
                }
                Text("\(album.total_tracks) Tracks")
                        .font(neumorphicFont(size: 10, weight: .medium))
                        .foregroundColor(DarkNeumorphicTheme.secondaryText)
                        .padding(.top, 1)

            } // End Text VStack
            .frame(maxWidth: .infinity, alignment: .leading)
            
        } // End HStack
        .padding(15) // Padding inside the card
        .modifier(NeumorphicOuterShadow())
        //.modifier(NeumorphicOuterShadow(cornerRadius: cardCornerRadius)) // Apply the neumorphic effect to the whole card background
        .frame(height: 110) // Consistent height for list items
    }
}

// MARK: Placeholders (Neumorphic Themed)
struct ErrorPlaceholderView: View {
    let error: SpotifyAPIError
    let retryAction: (() -> Void)?
    private let cornerRadius: CGFloat = 25
    
    var body: some View {
        VStack(spacing: 20) {
            // --- Icon with Subtle Neumorphic Treatment ---
            Image(systemName: iconName)
                .font(.system(size: 50))
                .foregroundColor(DarkNeumorphicTheme.errorColor) // Use error color
                .padding(25)
                .background(
                    Circle()
                        .fill(DarkNeumorphicTheme.elementBackground)
                        // Apply shadows to the circle background
                         .shadow(color: DarkNeumorphicTheme.darkShadow, radius: 8, x: 5, y: 5)
                         .shadow(color: DarkNeumorphicTheme.lightShadow, radius: 8, x: -5, y: -5)
                )
                .padding(.bottom, 15)
            
            // --- Text ---
            Text("Error")
                .font(neumorphicFont(size: 20, weight: .bold))
                .foregroundColor(DarkNeumorphicTheme.primaryText)
            
            Text(errorMessage)
                .font(neumorphicFont(size: 14))
                .foregroundColor(DarkNeumorphicTheme.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
            
            // --- Retry Button (Themed) ---
            
            switch error {
            case .invalidToken:
                Text("Please check the API token in the code.")
                    .font(neumorphicFont(size: 13))
                    .foregroundColor(DarkNeumorphicTheme.errorColor.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
            default:
                //TODO: CHANGE ME LATER DADDY
                Button { retryAction?() } label: {
                    Label("Retry", systemImage: "arrow.clockwise")
                        .font(neumorphicFont(size: 15, weight: .semibold))
                        .foregroundColor(DarkNeumorphicTheme.accentColor)
                }
                .buttonStyle(NeumorphicButtonStyle()) // Apply neumorphic style
                .padding(.top, 10)
            }
//            if error != .invalidToken && retryAction != nil { // Don't show retry for token error
//                Button { retryAction?() } label: {
//                    Label("Retry", systemImage: "arrow.clockwise")
//                        .font(neumorphicFont(size: 15, weight: .semibold))
//                        .foregroundColor(DarkNeumorphicTheme.accentColor)
//                }
//                .buttonStyle(NeumorphicButtonStyle()) // Apply neumorphic style
//                .padding(.top, 10)
//            } else if error == .invalidToken {
//                 Text("Please check the API token in the code.")
//                    .font(neumorphicFont(size: 13))
//                    .foregroundColor(DarkNeumorphicTheme.errorColor.opacity(0.8))
//                    .multilineTextAlignment(.center)
//                    .padding(.horizontal, 30)
//            }
        }
        .padding(40) // Padding inside the overall placeholder container
         // Optional: Add a subtle neumorphic background to the container
        // .background(DarkNeumorphicTheme.background) // Or elementBackground
        // .cornerRadius(cornerRadius)
        // .shadow... (if desired)
    }
    
    // --- Helper properties (unchanged logic, updated icons) ---
    private var iconName: String {
          switch error {
          case .invalidToken: return "key.slash" // Use non-fill for sublety
          case .networkError: return "wifi.slash"
          case .invalidResponse, .decodingError, .missingData: return "exclamationmark.triangle"
          case .invalidURL: return "link.badge.questionmark"
          }
    }
    private var errorMessage: String {
        error.localizedDescription // Use the localized description from the error enum
    }
}

struct EmptyStatePlaceholderView: View {
    let searchQuery: String
    
    var body: some View {
        VStack(spacing: 20) {
            // --- Image with Neumorphic Frame ---
            Image(placeholderImageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 130) // Adjusted size
                .padding(isInitialState ? 25 : 15) // Different padding
                .background( // Neumorphic background for the image
                     Circle()
                         .fill(DarkNeumorphicTheme.elementBackground)
                         .shadow(color: DarkNeumorphicTheme.darkShadow, radius: 8, x: 5, y: 5)
                         .shadow(color: DarkNeumorphicTheme.lightShadow, radius: 8, x: -5, y: -5)
                 )
                .padding(.bottom, 15)
            
            // --- Text ---
            Text(title)
                .font(neumorphicFont(size: 20, weight: .bold))
                .foregroundColor(DarkNeumorphicTheme.primaryText)
            
            Text(messageAttributedString) // Use AttributedString helper
                .font(neumorphicFont(size: 14))
                .foregroundColor(DarkNeumorphicTheme.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .padding(30)
    }
    
    // --- Helper properties ---
    private var isInitialState: Bool { searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    private var placeholderImageName: String { isInitialState ? "My-meme-microphone" : "My-meme-orange_2" } // Keep provided image names
    private var title: String { isInitialState ? "Spotify Search" : "No Results Found" }
    
    private var messageAttributedString: AttributedString {
        var messageText: String
        if isInitialState {
            messageText = "Enter an album or artist name\nin the search bar above to begin."
        } else {
            // Safely embed the search query
             let escapedQuery = searchQuery.replacingOccurrences(of: "*", with: "").replacingOccurrences(of: "_", with: "") // Basic sanitization for markdown/attr string
            messageText = "No matches found for \"\(escapedQuery)\".\nTry refining your search terms."
        }
        // Create AttributedString and apply base styling
        var attributedString = AttributedString(messageText)
        attributedString.font = neumorphicFont(size: 14)
        attributedString.foregroundColor = DarkNeumorphicTheme.secondaryText
        
        // Example: Highlight the query if needed (requires finding the range)
        // if !isInitialState, let range = attributedString.range(of: "\"\(escapedQuery)\"") {
        //     attributedString[range].font = neumorphicFont(size: 14, weight: .bold)
        //     attributedString[range].foregroundColor = DarkNeumorphicTheme.primaryText.opacity(0.9)
        // }
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
    
    @Environment(\.colorScheme) var colorScheme // To potentially adjust shadows based on system dark mode if needed, although we force dark.
    @Environment(\.dismiss) var dismiss // To potentially add a custom back button
    
    var body: some View {
        ZStack {
            DarkNeumorphicTheme.background.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) { // Use spacing 0 for control
                    // --- Header ---
                    AlbumHeaderView(album: album)
                        .padding(.top, 10) // Space from nav bar
                        .padding(.bottom, 25)
                    
                    // --- Player ---
                    // Shows only when a track is selected AND ready
                    if selectedTrackUri != nil {
                        SpotifyEmbedPlayerView(playbackState: playbackState, spotifyUri: selectedTrackUri)
                            .padding(.horizontal)
                            .padding(.bottom, 25)
                             // Subtle transition for player appearance
                            .transition(.opacity.combined(with: .scale(scale: 0.95, anchor: .top)))
                            .animation(.easeInOut(duration: 0.3), value: selectedTrackUri) // Animate on change
                    }
                    
                    // --- Tracks List ---
                    TracksSectionView(
                        tracks: tracks,
                        isLoading: isLoadingTracks,
                        error: trackFetchError,
                        selectedTrackUri: $selectedTrackUri,
                        retryAction: { Task { await fetchTracks() } }
                    )
                    .padding(.bottom, 25)
                    
                    // --- External Link (Themed Button) ---
                    if let spotifyURL = URL(string: album.external_urls.spotify ?? "") {
                        ExternalLinkButton(url: spotifyURL)
                            .padding(.horizontal)
                            .padding(.bottom, 30) // Extra padding at the bottom
                    }
                    
                } // End Main VStack
            } // End ScrollView
        } // End ZStack
        .navigationTitle(album.name)
        .navigationBarTitleDisplayMode(.inline) // Or .large
        // --- Navigation Bar Theming ---
        .toolbarBackground(DarkNeumorphicTheme.elementBackground, for: .navigationBar) // Slightly different bg for bar
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar) // Ensure title/buttons are light
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
    private let imageCornerRadius: CGFloat = 25
    
    var body: some View {
        VStack(spacing: 15) {
            // --- Album Image (Large, Neumorphic Frame) ---
            AlbumImageView(url: album.bestImageURL)
                .aspectRatio(1.0, contentMode: .fit) // Ensure square
                .clipShape(RoundedRectangle(cornerRadius: imageCornerRadius))
                 // Apply neumorphic shadow to the image container
                .background( // Background is needed for the shadow modifier to apply correctly to the shape
                     RoundedRectangle(cornerRadius: imageCornerRadius)
                         .fill(DarkNeumorphicTheme.elementBackground) // Base color for shadow
                         .shadow(color: DarkNeumorphicTheme.darkShadow, radius: 10, x: 6, y: 6)
                         .shadow(color: DarkNeumorphicTheme.lightShadow, radius: 10, x: -6, y: -6)
                 )
                .padding(.horizontal, 40) // Give it space
            
            // --- Text Details ---
            VStack(spacing: 4) {
                Text(album.name)
                    .font(neumorphicFont(size: 20, weight: .bold))
                    .foregroundColor(DarkNeumorphicTheme.primaryText)
                    .multilineTextAlignment(.center)
                
                Text("by \(album.formattedArtists)")
                    .font(neumorphicFont(size: 15))
                    .foregroundColor(DarkNeumorphicTheme.secondaryText)
                    .multilineTextAlignment(.center)
                
                Text("\(album.album_type.capitalized) • \(album.formattedReleaseDate())")
                    .font(neumorphicFont(size: 12, weight: .medium))
                    .foregroundColor(DarkNeumorphicTheme.secondaryText.opacity(0.8))
            }
            .padding(.horizontal)
            
        }
    }
}

struct SpotifyEmbedPlayerView: View {
    @ObservedObject var playbackState: SpotifyPlaybackState
    let spotifyUri: String?
    private let playerCornerRadius: CGFloat = 15
    
    var body: some View {
        VStack(spacing: 8) {
            // --- WebView Embed ---
            SpotifyEmbedWebView(playbackState: playbackState, spotifyUri: spotifyUri)
                .frame(height: 80) // Standard height for the embed
                .clipShape(RoundedRectangle(cornerRadius: playerCornerRadius)) // Clip the webview itself
                .disabled(!playbackState.isReady) // Disable interaction until ready
                .overlay( // Show loading/error overlay if needed
                    Group {
                        if !playbackState.isReady {
                            ProgressView().tint(DarkNeumorphicTheme.accentColor)
                        } else if let error = playbackState.error {
                            VStack {
                                Image(systemName: "exclamationmark.triangle")
                                    .foregroundColor(DarkNeumorphicTheme.errorColor)
                                Text(error)
                                    .font(.caption)
                                    .foregroundColor(DarkNeumorphicTheme.errorColor)
                                    .lineLimit(1)
                            }
                             .padding(5)
                        }
                    }
                 )
                 // --- Neumorphic Background/Frame for the player ---
                 .background(
                     RoundedRectangle(cornerRadius: playerCornerRadius)
                         .fill(DarkNeumorphicTheme.elementBackground)
                         .shadow(color: DarkNeumorphicTheme.darkShadow, radius: 5, x: 3, y: 3)
                         .shadow(color: DarkNeumorphicTheme.lightShadow, radius: 5, x: -3, y: -3)
                 )
            
            // --- Playback Status Text ---
            HStack {
                // Display error prominently if it exists
                if let error = playbackState.error, !error.isEmpty {
                     Text("Error: \(error)")
                         .font(neumorphicFont(size: 10, weight: .medium))
                         .foregroundColor(DarkNeumorphicTheme.errorColor)
                         .lineLimit(1)
                         .frame(maxWidth: .infinity, alignment: .leading)
                 } else if !playbackState.isReady {
                     Text("Loading Player...")
                         .font(neumorphicFont(size: 10, weight: .medium))
                        .foregroundColor(DarkNeumorphicTheme.secondaryText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else if playbackState.duration > 0.1 { // Show time only if duration is valid
                    Text(playbackState.isPlaying ? "Playing" : "Paused")
                        .font(neumorphicFont(size: 10, weight: .medium))
                        .foregroundColor(playbackState.isPlaying ? DarkNeumorphicTheme.accentColor : DarkNeumorphicTheme.secondaryText)
                    
                    Spacer()
                    
                    Text("\(formatTime(playbackState.currentPosition)) / \(formatTime(playbackState.duration))")
                        .font(neumorphicFont(size: 10, weight: .medium))
                        .foregroundColor(DarkNeumorphicTheme.secondaryText)
                        .frame(width: 90, alignment: .trailing) // Fixed width for time
                } else {
                     // Player ready but no duration yet (or zero duration track)
                     Text("Ready")
                         .font(neumorphicFont(size: 10, weight: .medium))
                         .foregroundColor(DarkNeumorphicTheme.secondaryText)
                         .frame(maxWidth: .infinity, alignment: .leading)
                 }
            }
            .padding(.horizontal, 8) // Small padding for status text
            .frame(height: 15) // Minimal height
            
        } // End VStack
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
    private let sectionCornerRadius: CGFloat = 20
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) { // Use VStack to contain header and list
            // --- Section Header ---
            Text("Tracks")
                .font(neumorphicFont(size: 16, weight: .semibold))
                .foregroundColor(DarkNeumorphicTheme.primaryText)
                .padding(.horizontal)
                .padding(.bottom, 10)
            
            // --- Container for Tracks/Loading/Error ---
            Group { // Group to apply common background/padding
                if isLoading {
                    HStack {
                        Spacer()
                        ProgressView().tint(DarkNeumorphicTheme.accentColor)
                        Text("Loading Tracks...")
                            .font(neumorphicFont(size: 14))
                            .foregroundColor(DarkNeumorphicTheme.secondaryText)
                        Spacer()
                    }
                    .padding(.vertical, 30) // Generous padding for loading
                } else if let error = error {
                    ErrorPlaceholderView(error: error, retryAction: retryAction)
                        .padding(.vertical, 20) // Padding around error
                } else if tracks.isEmpty {
                    Text("No tracks found for this album.")
                        .font(neumorphicFont(size: 14))
                        .foregroundColor(DarkNeumorphicTheme.secondaryText)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 30)
                } else {
                    // Divider() // Optional separator
                    // Track Rows - Use ForEach directly inside VStack
                    VStack(spacing: 0) { // Tightly packed rows
                        ForEach(tracks) { track in
                             NeumorphicTrackRow(
                                track: track,
                                isSelected: track.uri == selectedTrackUri
                             )
                             .contentShape(Rectangle()) // Make whole area tappable
                             .onTapGesture {
                                 // Update selection, triggering player/highlight
                                 selectedTrackUri = track.uri
                             }
                             // Divider().background(DarkNeumorphicTheme.background.opacity(0.5)) // Subtle dividers
                        }
                    }
                }
            }
            .padding(10) // Padding around the content inside the neumorphic shape
             // --- Neumorphic Background for the Tracks Area ---
             .background(
                 RoundedRectangle(cornerRadius: sectionCornerRadius)
                     .fill(DarkNeumorphicTheme.elementBackground)
                     .shadow(color: DarkNeumorphicTheme.darkShadow, radius: 5, x: 3, y: 3)
                     .shadow(color: DarkNeumorphicTheme.lightShadow, radius: 5, x: -3, y: -3)
             )
             .padding(.horizontal) // Padding for the neumorphic container itself
            
        } // End Outer VStack
    }
}

struct NeumorphicTrackRow: View {
    let track: Track
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            // --- Track Number (Subtle) ---
            Text("\(track.track_number)")
                .font(neumorphicFont(size: 12, weight: .medium))
                .foregroundColor(isSelected ? DarkNeumorphicTheme.accentColor : DarkNeumorphicTheme.secondaryText)
                .frame(width: 20, alignment: .center)
            
            // --- Track Info ---
            VStack(alignment: .leading, spacing: 2) {
                Text(track.name)
                    .font(neumorphicFont(size: 14, weight: .medium)) // Slightly smaller than card title
                    .foregroundColor(isSelected ? DarkNeumorphicTheme.primaryText : DarkNeumorphicTheme.primaryText.opacity(0.9))
                    .fontWeight(isSelected ? .bold : .regular) // Bold if selected
                    .lineLimit(1)
                
                Text(track.formattedArtists)
                    .font(neumorphicFont(size: 11))
                    .foregroundColor(DarkNeumorphicTheme.secondaryText)
                    .lineLimit(1)
            }
            
            Spacer()
            
            // --- Duration ---
            Text(track.formattedDuration)
                .font(neumorphicFont(size: 12, weight: .medium))
                .foregroundColor(DarkNeumorphicTheme.secondaryText)
                .frame(width: 40, alignment: .trailing) // Fixed width
            
            // --- Play Indicator (Subtle) ---
             Image(systemName: isSelected ? "speaker.wave.2.fill" : "play") // More descriptive icons
                .font(.system(size: 12)) // Smaller indicator
                .foregroundColor(isSelected ? DarkNeumorphicTheme.accentColor : DarkNeumorphicTheme.secondaryText.opacity(0.6))
                .frame(width: 20, alignment: .center)
                .animation(.easeInOut(duration: 0.2), value: isSelected)
            
        }
        .padding(.vertical, 10) // Vertical padding for tap area and spacing
        .padding(.horizontal, 5) // Horizontal padding within the row
         // Change background subtly on selection
         .background(isSelected ? DarkNeumorphicTheme.elementBackground.opacity(0.6) : Color.clear) // Use element bg with opacity
         .cornerRadius(8) // Slightly round the background highlight
    }
}

// MARK: Other Supporting Views (Themed)

struct AlbumImageView: View { // Adapted for Neumorphism Placeholders
    let url: URL?
    private let placeholderCornerRadius: CGFloat = 8
    
    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
                // Neumorphic Loading Placeholder
                ZStack {
                     RoundedRectangle(cornerRadius: placeholderCornerRadius)
                         .fill(DarkNeumorphicTheme.elementBackground)
                         // Subtle inset look for placeholder
                         .modifier(NeumorphicOuterShadow())
                         //.modifier(NeumorphicInnerShadow(cornerRadius: placeholderCornerRadius))
                    ProgressView().tint(DarkNeumorphicTheme.accentColor.opacity(0.7))
                }
            case .success(let image):
                image.resizable().scaledToFit()
            case .failure:
                 // Neumorphic Error Placeholder
                 ZStack {
                     RoundedRectangle(cornerRadius: placeholderCornerRadius)
                         .fill(DarkNeumorphicTheme.elementBackground)
                         .modifier(NeumorphicOuterShadow())
                         //.modifier(NeumorphicInnerShadow(cornerRadius: placeholderCornerRadius))
                     Image(systemName: "photo.on.rectangle.angled")
                         .resizable().scaledToFit()
                         .foregroundColor(DarkNeumorphicTheme.secondaryText.opacity(0.5))
                         .padding(15) // Padding for the icon
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
         // Keep it simple and non-neumorphic to avoid visual clutter near search bar
         HStack {
             Text("Results: \(totalResults)")
             Spacer()
             if totalResults > limit {
                  Text("Showing: \(offset + 1)-\(min(offset + limit, totalResults))")
             }
         }
         .font(neumorphicFont(size: 11, weight: .medium))
         .foregroundColor(DarkNeumorphicTheme.secondaryText)
         .padding(.vertical, 5) // Less padding
    }
}

// MARK: --> Reusable Neumorphic Button
struct ThemedNeumorphicButton: View {
    let text: String
    var iconName: String? = nil
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let iconName = iconName {
                    Image(systemName: iconName)
                }
                Text(text)
            }
            .font(neumorphicFont(size: 15, weight: .semibold))
             .foregroundColor(DarkNeumorphicTheme.accentColor) // Use accent for button text
        }
        .buttonStyle(NeumorphicButtonStyle()) // Apply the custom style
    }
}

// Specific implementation for the external link button
struct ExternalLinkButton: View {
    let text: String = "Open in Spotify" // Default text
    let url: URL
    @Environment(\.openURL) var openURL
    
    var body: some View {
        ThemedNeumorphicButton(text: text, iconName: "arrow.up.forward.app") {
            print("Attempting to open external URL: \(url)")
            openURL(url) { accepted in
                if !accepted {
                    print("⚠️ OS could not open URL: \(url)")
                    // Maybe show an alert to the user
                }
            }
        }
    }
}

// MARK: - Preview Providers (Updated for Neumorphic Views)

struct SpotifyAlbumListView_Previews: PreviewProvider {
    static var previews: some View {
        SpotifyAlbumListView()
            .preferredColorScheme(.dark)
    }
}

struct NeumorphicAlbumCard_Previews: PreviewProvider {
    static let mockArtist = Artist(id: "artist1", external_urls: nil, href: "", name: "Miles Davis Mock", type: "artist", uri: "")
    static let mockImage = SpotifyImage(height: 300, url: "https://i.scdn.co/image/ab67616d00001e027ab89c25093ea3787b1995b4", width: 300)
    static let mockAlbumItem = AlbumItem(id: "album1", album_type: "album", total_tracks: 5, available_markets: ["US"], external_urls: ExternalUrls(spotify: ""), href: "", images: [mockImage], name: "Kind of Blue [PREVIEW]", release_date: "1959-08-17", release_date_precision: "day", type: "album", uri: "spotify:album:1weenld61qoidwYuZ1GESA", artists: [mockArtist])
    
    static var previews: some View {
        NeumorphicAlbumCard(album: mockAlbumItem)
            .padding()
            .background(DarkNeumorphicTheme.background)
            .previewLayout(.fixed(width: 380, height: 140))
            .preferredColorScheme(.dark)
    }
}

struct AlbumDetailView_Previews: PreviewProvider {
    static let mockArtist = Artist(id: "artist1", external_urls: nil, href: "", name: "Miles Davis Mock", type: "artist", uri: "")
    static let mockImage = SpotifyImage(height: 640, url: "https://i.scdn.co/image/ab67616d0000b2737ab89c25093ea3787b1995b4", width: 640)
    static let mockAlbum = AlbumItem(id: "1weenld61qoidwYuZ1GESA", album_type: "album", total_tracks: 5, available_markets: ["US", "GB"], external_urls: ExternalUrls(spotify: "https://open.spotify.com/album/1weenld61qoidwYuZ1GESA"), href: "", images: [mockImage], name: "Kind Of Blue (Preview)", release_date: "1959-08-17", release_date_precision: "day", type: "album", uri: "spotify:album:1weenld61qoidwYuZ1GESA", artists: [mockArtist])
    
    static var previews: some View {
        NavigationView {
            AlbumDetailView(album: mockAlbum)
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - App Entry Point

@main
struct SpotifyNeumorphicApp: App {
    init() {
        // Print Token Warning at Startup
        if placeholderSpotifyToken == "YOUR_SPOTIFY_BEARER_TOKEN_HERE" {
            print("🚨 WARNING: Spotify Bearer Token is not set! API calls will fail.")
            print("👉 FIX: Replace the placeholder token in the code.")
        }
        
        // Optional: Apply Global Navigation Bar Appearance (Neumorphic touch)
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(DarkNeumorphicTheme.elementBackground) // Bar background
        appearance.titleTextAttributes = [.foregroundColor: UIColor(DarkNeumorphicTheme.primaryText)]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor(DarkNeumorphicTheme.primaryText)]
        
        // Remove default bottom border/shadow
        appearance.shadowColor = .clear
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance // Important for large titles
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().tintColor = UIColor(DarkNeumorphicTheme.accentColor) // Back button etc.
    }
    
    var body: some Scene {
        WindowGroup {
            SpotifyAlbumListView()
                 // Force dark mode for the entire app to match the theme
                .preferredColorScheme(.dark)
        }
    }
}
