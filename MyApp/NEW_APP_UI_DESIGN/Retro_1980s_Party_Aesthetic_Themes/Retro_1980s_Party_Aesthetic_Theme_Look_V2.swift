//
//  Retro_1980s_Party_Aesthetic_Theme_Look_V1.swift
//  MyApp
//
//  Created by Cong Le on 4/20/25.
//


//  SpotifyRetroPartyApp.swift
//  MyApp // Or your actual App name
//
//  Created on: [Current Date]
//  Synthesized single-file version with Retro 1980s Party Theme
//

import SwiftUI
@preconcurrency import WebKit // Needed for SpotifyEmbedWebView
import Foundation // Needed for URLSession, Codable, etc.

// MARK: - Retro 1980s Party Aesthetic Theme Constants & Helpers

let retroDeepPurple = Color(red: 0.15, green: 0.05, blue: 0.25) // Dark background
let retroNeonPink = Color(red: 1.0, green: 0.1, blue: 0.5)
let retroNeonCyan = Color(red: 0.1, green: 0.9, blue: 0.9)
let retroNeonLime = Color(red: 0.7, green: 1.0, blue: 0.3)
let retroNeonOrange = Color(red: 1.0, green: 0.5, blue: 0.1)
let retroElectricBlue = Color(red: 0.18, green: 0.5, blue: 0.96)

let retroGradients: [Color] = [
    retroNeonPink,
    retroNeonOrange,
    retroNeonLime,
    retroNeonCyan,
    retroElectricBlue
]

// Custom Font Helper (Using system monospaced as a placeholder)
func retroFont(size: CGFloat, weight: Font.Weight = .regular) -> Font {
    // Replace "RetroFontName" with your actual custom font if you have one
    // Example: return Font.custom("RetroFontName", size: size).weight(weight)
    Font.system(size: size, design: .monospaced).weight(weight)
}

// Neon Glow View Modifier Extension
extension View {
    func neonGlow(_ color: Color, radius: CGFloat = 8) -> some View {
        self
            .shadow(color: color.opacity(0.6), radius: radius / 2, x: 0, y: 0) // Inner sharp glow
            .shadow(color: color.opacity(0.4), radius: radius, x: 0, y: 0)     // Mid soft glow
            .shadow(color: color.opacity(0.2), radius: radius * 1.5, x: 0, y: 0) // Outer faint glow
    }
}

// Helper for Hex Colors (Optional but can be useful)
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

// MARK: - Data Models (Structurally Unchanged)

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
    let type: String
    let uri: String
    let artists: [Artist]
    
    // --- Helper computed properties (Unchanged) ---
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
                dateFormatter.dateFormat = "MMM yyyy" // e.g., Nov 1985
                return dateFormatter.string(from: date)
            }
        case "day":
            dateFormatter.dateFormat = "yyyy-MM-dd"
            if let date = dateFormatter.date(from: release_date) {
                dateFormatter.dateFormat = "d MMM yyyy" // e.g., 17 Aug 1989
                return dateFormatter.string(from: date)
            }
        default: break
        }
        return release_date // Fallback
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

// Models for Album Tracks
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
    let preview_url: String? // Note: Preview might not work in embed
    let track_number: Int
    let type: String
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

// MARK: - Spotify Embed WebView (Functionally Unchanged, relies on themed container)

// Observable object to track playback state from the WebView
final class SpotifyPlaybackState: ObservableObject {
    @Published var isPlaying: Bool = false
    @Published var currentUri: String = "" // To track which track/album is loaded
    // Optional: Add position/duration if needed, requires more JS communication
    @Published var currentPosition: Double = 0 // seconds
    @Published var duration: Double = 0 // seconds
    @Published var error: String? = nil // To surface errors from the embed
}

struct SpotifyEmbedWebView: UIViewRepresentable {
    @ObservedObject var playbackState: SpotifyPlaybackState
    let spotifyUri: String? // The URI to load (e.g., "spotify:track:...")
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        // Configure user controller for JS communication
        let userContentController = WKUserContentController()
        userContentController.add(context.coordinator, name: "spotifyController") // Native -> JS bridge
        
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = userContentController
        configuration.allowsInlineMediaPlayback = true // Important for player
        configuration.mediaTypesRequiringUserActionForPlayback = [] // Allow autoplay if possible
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator // Handle JS alerts, etc.
        webView.isOpaque = false
        webView.backgroundColor = .clear // Crucial: Make WebView transparent
        webView.scrollView.backgroundColor = .clear
        webView.scrollView.isScrollEnabled = false // Disable scrolling within embed fixed frame
        
        // Load the initial HTML structure
        let html = generateHTML()
        webView.loadHTMLString(html, baseURL: nil)
        
        context.coordinator.webView = webView // Hold reference in coordinator
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        // Logic to load or update the URI when the view updates or API becomes ready
        if context.coordinator.isApiReady {
            if context.coordinator.lastLoadedUri != spotifyUri {
                context.coordinator.loadUri(spotifyUri ?? "No URI")
                // Update state immediately if URI changes programmatically
                DispatchQueue.main.async { if playbackState.currentUri != spotifyUri { playbackState.currentUri = spotifyUri ?? "No URI" } }
            }
        } else {
            // If API not ready, store the desired URI to load once it is
            context.coordinator.updateDesiredUriBeforeReady(spotifyUri ?? "No URI")
        }
    }
    
    static func dismantleUIView(_ uiView: WKWebView, coordinator: Coordinator) {
        // Clean up: remove script message handler and stop loading
        uiView.stopLoading()
        uiView.configuration.userContentController.removeScriptMessageHandler(forName: "spotifyController")
        coordinator.webView = nil // Release weak reference
        print("Embed: WebView dismantled.")
    }
    
    // Generates the basic HTML for the Spotify Embed IFrame API
    private func generateHTML() -> String {
         """
         <!DOCTYPE html><html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no"><title>Spotify Embed</title><style>html, body { margin: 0; padding: 0; width: 100%; height: 100%; overflow: hidden; background-color: transparent; } #embed-iframe { width: 100%; height: 100%; box-sizing: border-box; display: block; border: none; }</style></head><body><div id="embed-iframe"></div><script src="https://open.spotify.com/embed/iframe-api/v1" async></script><script> console.log('JS: Initial script embed.js.'); window.onSpotifyIframeApiReady = (IFrameAPI) => { console.log('✅ JS: API Ready.'); window.IFrameAPI = IFrameAPI; if (window.webkit?.messageHandlers?.spotifyController) { window.webkit.messageHandlers.spotifyController.postMessage("ready"); } else { console.error('❌ JS: Native handler missing!'); } }; const scriptTag = document.querySelector('script[src*="iframe-api"]'); scriptTag.onerror = (event) => { console.error('❌ JS: Failed API script load:', event); window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'Failed API script load' }}); }; </script></body></html>
         """
    }
    
    // --- Coordinator Class ---
    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
        var parent: SpotifyEmbedWebView
        weak var webView: WKWebView?
        var isApiReady = false
        var lastLoadedUri: String? = nil
        private var desiredUriBeforeReady: String? = nil // Store URI if API isn't ready yet
        
        init(_ parent: SpotifyEmbedWebView) {
            self.parent = parent
        }
        
        func updateDesiredUriBeforeReady(_ uri: String) {
            // Only store if API is not yet ready
            if !isApiReady {
                desiredUriBeforeReady = uri
            }
        }
        
        // --- WKNavigationDelegate Methods ---
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            print("Embed: HTML structure loaded.")
            // HTML finished loading, but IFrame API might still be loading via its async script.
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print("❌ Embed Navigation Error: \(error.localizedDescription)")
            DispatchQueue.main.async { self.parent.playbackState.error = "Failed to load Spotify embed: \(error.localizedDescription)" }
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            print("❌ Embed Provisional Navigation Error: \(error.localizedDescription)")
            DispatchQueue.main.async { self.parent.playbackState.error = "Failed to start loading Spotify embed: \(error.localizedDescription)" }
        }
        
        // --- WKUIDelegate Methods ---
        // Handle JavaScript alerts (useful for debugging JS)
        func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
            print("ℹ️ Embed JS Alert: \(message)")
            completionHandler()
        }
        
        // --- WKScriptMessageHandler ---
        // Handle messages sent from JavaScript using `window.webkit.messageHandlers.spotifyController.postMessage(...)`
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            guard message.name == "spotifyController" else { return }
            
            // Check if the message is the "ready" signal
            if let bodyString = message.body as? String, bodyString == "ready" {
                handleApiReady()
            }
            // Check if the message is a dictionary (for events like playback state)
            else if let bodyDict = message.body as? [String: Any], let event = bodyDict["event"] as? String {
                let data = bodyDict["data"] // Data associated with the event
                handleEvent(event: event, data: data)
            } else {
                print("❓ Embed: Received unknown message format: \(message.body)")
            }
        }
        
        // --- Helper Methods for JS Interaction ---
        
        // Called when the IFrame API script signals readiness
        private func handleApiReady() {
            print("✅ Embed Native: API Ready signal received from JS.")
            isApiReady = true
            
            // If a URI was set *before* the API was ready, attempt to load it now.
            // Otherwise, use the current URI from the parent view state.
            if let initialUri = desiredUriBeforeReady ?? parent.spotifyUri {
                // Attempt to create the controller *once* the API is ready
                createSpotifyController(with: initialUri)
                // Clear the stored URI after attempting to use it
                desiredUriBeforeReady = nil
            } else {
                print("ℹ️ Embed Native: API ready, but no initial URI specified.")
            }
        }
        
        // Handles specific events forwarded from the JS embed controller
        private func handleEvent(event: String, data: Any?) {
            // Update playback state based on events
            switch event {
            case "controllerCreated":
                print("✅ Embed Native: Controller instance created.") // Log success
            case "playbackUpdate":
                if let updateData = data as? [String: Any] {
                    updatePlaybackState(with: updateData)
                }
            case "error":
                let errorMessage = (data as? [String: Any])?["message"] as? String ?? "\(data ?? "Unknown Embed Error")"
                print("❌ Embed JS Error Reported: \(errorMessage)")
                DispatchQueue.main.async { self.parent.playbackState.error = errorMessage }
            default:
                print("❓ Embed Native: Received unknown JS event: \(event)")
            }
        }
        
        // Updates the parent's observable state object
        private func updatePlaybackState(with data: [String: Any]) {
            DispatchQueue.main.async { [weak self] in // Ensure UI updates on main thread
                guard let self = self else { return }
                if let isPaused = data["paused"] as? Bool {
                    // Only update if the state genuinely changed or is first update
                    if self.parent.playbackState.isPlaying == isPaused {
                        self.parent.playbackState.isPlaying = !isPaused
                    }
                }
                if let posMs = data["position"] as? Double {
                    let newPos = posMs / 1000.0
                    // Update if significantly different or first update
                    if abs(self.parent.playbackState.currentPosition - newPos) > 0.1 {
                        self.parent.playbackState.currentPosition = newPos
                    }
                }
                if let durMs = data["duration"] as? Double {
                    let newDur = durMs / 1000.0
                    if abs(self.parent.playbackState.duration - newDur) > 0.1 || self.parent.playbackState.duration == 0 {
                        self.parent.playbackState.duration = newDur
                    }
                }
                if let uri = data["uri"] as? String {
                    if self.parent.playbackState.currentUri != uri {
                        self.parent.playbackState.currentUri = uri
                        self.lastLoadedUri = uri // Keep coordinator in sync
                    }
                }
                // Clear previous errors on successful playback update
                if self.parent.playbackState.error != nil { self.parent.playbackState.error = nil }
            }
        }
        
        // Executes JS to create the Spotify IFrame Controller
        private func createSpotifyController(with initialUri: String) {
            guard let webView = webView else { print("Error: WebView reference missing."); return }
            guard isApiReady else { print("Error: API not ready, cannot create controller."); return }
            // Prevent re-initialization if already attempted or created
            guard lastLoadedUri == nil else {
                // If the desired URI changed *after* initial attempt but *before* controller was confirmed created, load it now.
                if let latestDesired = desiredUriBeforeReady ?? parent.spotifyUri, latestDesired != lastLoadedUri {
                    print("🔄 Spotify Embed Native: Controller likely initialized or pending, loading changed URI: \(latestDesired)")
                    loadUri(latestDesired)
                    desiredUriBeforeReady = nil // Clear after use
                } else {
                    print("ℹ️ Spotify Embed Native: Controller already initialized or initialization attempt pending.")
                }
                return
            }
            
            print("🚀 Spotify Embed Native: Attempting to create controller for URI: \(initialUri)")
            lastLoadedUri = initialUri // Mark as attempting to load this URI
            
            let script = """
             // --- JS to Create Spotify Controller ---
             console.log('Spotify Embed JS: Initial script block running.');
             window.embedController = null; // Ensure clean state
             const element = document.getElementById('embed-iframe');
             if (!element) { console.error('Spotify Embed JS: Could not find element embed-iframe!'); window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'HTML element embed-iframe not found' }}); }
             else if (!window.IFrameAPI) { console.error('Spotify Embed JS: IFrameAPI is not loaded!'); window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'Spotify IFrame API not loaded' }}); }
             else {
                 console.log('Spotify Embed JS: Found element and IFrameAPI. Creating controller for URI: \(initialUri)');
                 const options = { uri: '\(initialUri)', width: '100%', height: '80' }; // Fixed height for standard embed widget
                 const callback = (controller) => {
                     if (!controller) { console.error('Spotify Embed JS: createController callback received null controller!'); window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'JS createController callback received null controller' }}); return; }
                     console.log('✅ Spotify Embed JS: Controller instance received.');
                     window.embedController = controller; // Store globally in JS window object for access
                     window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'controllerCreated' }); // Notify native code
                     
                     // --- Add Event Listeners ---
                     controller.addListener('ready', () => { console.log('Spotify Embed JS: Controller Ready event.'); });
                     controller.addListener('playback_update', e => { window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'playbackUpdate', data: e.data }); });
                     controller.addListener('account_error', e => { console.warn('Spotify Embed JS: Account Error:', e.data); window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'Account Error: ' + (e.data?.message ?? 'Premium required or login issue?') }}); });
                     controller.addListener('autoplay_failed', () => { console.warn('Spotify Embed JS: Autoplay failed'); window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'Autoplay failed' }}); controller.play(); }); // Attempt manual play on failure? (Might not always work)
                     controller.addListener('initialization_error', e => { console.error('Spotify Embed JS: Initialization Error:', e.data); window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'Initialization Error: ' + (e.data?.message ?? 'Failed to initialize player') }}); });
                     
                     // Attempt to play immediately after creation if possible
                     controller.play();
                     
                 }; // End of callback function
                 
                 // --- Execute IFrameAPI.createController ---
                 try {
                     console.log('Spotify Embed JS: Calling IFrameAPI.createController...');
                     window.IFrameAPI.createController(element, options, callback);
                 } catch (e) {
                     console.error('Spotify Embed JS: Error calling createController:', e); window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'JS exception during createController: ' + e.message }});
                     // Reset state to allow retry? Needs careful thought if URI updated concurrently.
                     //lastLoadedUri = nil; // Maybe not - could cause rapid retry loops. Let error state handle it.
                 }
             } // End of else block
             """ // End of JS script string
            
            webView.evaluateJavaScript(script) { result, error in
                if let error = error {
                    print("⚠️ Spotify Embed Native: Error evaluating JS for controller creation: \(error.localizedDescription)")
                    // Potentially reset lastLoadedUri if JS call itself fails badly? Depends on recovery strategy.
                    //lastLoadedUri = nil;
                } else {
                    // JS execution started, but creation is async via the callback.
                }
            }
        }
        
        // Executes JS to load a new URI into the existing controller
        func loadUri(_ uri: String) {
            guard let webView = webView else { return }
            guard isApiReady else { return }
            // Only load if the URI is actually different and controller creation was attempted
            guard lastLoadedUri != nil, lastLoadedUri != uri else { return }
            
            print("🚀 Embed Native: Loading new URI via JS: \(uri)")
            lastLoadedUri = uri // Update the last *attempted* load URI
            // Also update the parent state's current URI *immediately* for responsiveness
            DispatchQueue.main.async { self.parent.playbackState.currentUri = uri }
            
            let script = """
              if (window.embedController) {
                  console.log('JS: Loading URI: \(uri)');
                  window.embedController.loadUri('\(uri)');
                  // Attempt to play immediately after loading
                  setTimeout(() => { window.embedController.play(); }, 100); // Small delay might help
              } else {
                  console.error('JS: Controller not found when trying to load URI.');
                  window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'JS Controller not found for loadUri operation' }});
              }
              """ // End of JS script string
            
            webView.evaluateJavaScript(script) { _, error in
                if let error = error { print("⚠️ Embed Native: Error evaluating JS for loadUri: \(error)") }
            }
        }
    } // End Coordinator Class
}

// MARK: - API Service (Use Placeholder Token)

let placeholderSpotifyToken = "YOUR_SPOTIFY_BEARER_TOKEN_HERE" // Needs replacement!

// Custom Error Enum for API Service
enum SpotifyAPIError: Error, LocalizedError {
    case invalidURL
    case networkError(Error)
    case invalidResponse(Int, String?) // Include status code and optional body
    case decodingError(Error)
    case invalidToken // Specific error for 401 Unauthorized
    case missingData
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "The API URL was invalid."
        case .networkError(let error): return "Network request failed: \(error.localizedDescription)"
        case .invalidResponse(let code, let body): return "Server returned an error (\(code)).\(body != nil ? " Body: \(body!)" : "")"
        case .decodingError(let error): return "Failed to decode the server response: \(error.localizedDescription)"
        case .invalidToken: return "Invalid or expired Spotify API token. Please check your credentials."
        case .missingData: return "Expected data was missing in the response."
        }
    }
}

// Singleton Service for Spotify API Calls
struct SpotifyAPIService {
    static let shared = SpotifyAPIService()
    private let session: URLSession
    
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData // Avoid stale cache
        session = URLSession(configuration: configuration)
    }
    
    // Generic Request Function
    private func makeRequest<T: Decodable>(url: URL) async throws -> T {
        // --- Token Check ---
        guard !placeholderSpotifyToken.isEmpty, placeholderSpotifyToken != "YOUR_SPOTIFY_BEARER_TOKEN_HERE" else {
            print("❌ ERROR: Spotify token is missing or is the placeholder.")
            throw SpotifyAPIError.invalidToken
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(placeholderSpotifyToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 20 // 20 seconds timeout
        
        do {
            print("🚀 Performing API Request to: \(url.absoluteString)") // Log request URL
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw SpotifyAPIError.invalidResponse(0, "Response was not HTTP.")
            }
            
            print("⬇️ API Response Status Code: \(httpResponse.statusCode)") // Log status code
            
            // --- Handle HTTP Status Codes ---
            guard (200...299).contains(httpResponse.statusCode) else {
                if httpResponse.statusCode == 401 { throw SpotifyAPIError.invalidToken }
                // Try to read error body for other error codes
                let errorBody = String(data: data, encoding: .utf8)
                print("❌ API Error Response Body: \(errorBody ?? "N/A")")
                throw SpotifyAPIError.invalidResponse(httpResponse.statusCode, errorBody)
            }
            
            // --- Decode Successful Response ---
            do {
                // Uncomment to debug raw JSON response:
                // print("✅ API Success JSON: \(String(data: data, encoding: .utf8) ?? "Invalid UTF8")")
                let decoder = JSONDecoder()
                return try decoder.decode(T.self, from: data)
            } catch {
                print("❌ Decoding Error: \(error)")
                throw SpotifyAPIError.decodingError(error)
            }
        } catch let error where !(error is CancellationError) {
            // Don't treat task cancellation as a network error
            print("❌ Network/Request Error: \(error)")
            // Re-throw API specific errors directly, wrap others
            throw error is SpotifyAPIError ? error : SpotifyAPIError.networkError(error)
        }
    }
    
    // MARK: Specific API Endpoints
    
    func searchAlbums(query: String, limit: Int = 20, offset: Int = 0) async throws -> SpotifySearchResponse {
        var components = URLComponents(string: "https://api.spotify.com/v1/search")
        components?.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "type", value: "album"),
            URLQueryItem(name: "include_external", value: "audio"), // Usually not needed for albums
            URLQueryItem(name: "limit", value: "\(limit)"),
            URLQueryItem(name: "offset", value: "\(offset)")
        ]
        guard let url = components?.url else { throw SpotifyAPIError.invalidURL }
        return try await makeRequest(url: url)
    }
    
    func getAlbumTracks(albumId: String, limit: Int = 50, offset: Int = 0) async throws -> AlbumTracksResponse {
        var components = URLComponents(string: "https://api.spotify.com/v1/albums/\(albumId)/tracks")
        // Add market query item? Spotify suggests it for track relinking/availability.
        // Let's omit it for now for simplicity, API might default based on token region.
        components?.queryItems = [
            URLQueryItem(name: "limit", value: "\(limit)"),
            URLQueryItem(name: "offset", value: "\(offset)")
        ]
        guard let url = components?.url else { throw SpotifyAPIError.invalidURL }
        return try await makeRequest(url: url)
    }
}

// MARK: - SwiftUI Views (Themed: Retro 1980s Party)

// MARK: Main List View
struct SpotifyAlbumListView: View {
    @State private var searchQuery: String = ""
    @State private var displayedAlbums: [AlbumItem] = []
    @State private var isLoading: Bool = false
    @State private var searchInfo: Albums? = nil // To store total results, offset, etc.
    @State private var currentError: SpotifyAPIError? = nil
    @State private var debounceTask: Task<Void, Never>? = nil
    
    var body: some View {
        NavigationView {
            ZStack {
                // --- Retro Background ---
                retroDeepPurple.ignoresSafeArea() // Base color
                
                // Optional: Subtle Grid Pattern Overlay
                LinearGradient(colors: [.black.opacity(0.1), .clear], startPoint: .top, endPoint: .bottom)
                    .blendMode(.overlay)
                    .overlay (
                        Image("retro_grid_background") // Assuming you have this image
                            .resizable()
                            .scaledToFill()
                            .blendMode(.screen)
                            .opacity(0.08)
                    )
                    .ignoresSafeArea()
                
                
                // --- Conditional Content Area ---
                Group {
                    if isLoading && displayedAlbums.isEmpty {
                        // Initial Loading Indicator
                        ProgressView {
                            Text("LOADING RAD TUNES...")
                                .font(retroFont(size: 14, weight: .bold))
                                .foregroundColor(retroNeonLime)
                        }
                        .progressViewStyle(CircularProgressViewStyle(tint: retroNeonCyan))
                        .scaleEffect(1.8)
                        .padding(.bottom, 50)
                        .neonGlow(retroNeonCyan, radius: 15)
                    } else if let error = currentError {
                        // Error Display
                        ErrorPlaceholderView(error: error) {
                            // Retry Action
                            Task { await performSearch(query: searchQuery, immediate: true) }
                        }
                    } else if displayedAlbums.isEmpty && !searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        // No Results Found
                        EmptyStatePlaceholderView(searchQuery: searchQuery, state: .noResults)
                    } else if displayedAlbums.isEmpty {
                        // Initial Empty State
                        EmptyStatePlaceholderView(searchQuery: searchQuery, state: .initial)
                    }
                    else {
                        // Themed Album List
                        albumList
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity) // Center content
                .transition(.opacity.animation(.easeInOut(duration: 0.3)))
                
                // --- Ongoing Loading Indicator (Top) ---
                if isLoading && !displayedAlbums.isEmpty {
                    VStack {
                        HStack {
                            Spacer()
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: retroNeonLime))
                                .padding(.trailing, 5)
                            Text("LOADING MORE...")
                                .font(retroFont(size: 11, weight: .bold))
                                .foregroundColor(retroNeonLime)
                                .tracking(1.5) // Add tracking
                            Spacer()
                        }
                        .padding(.vertical, 6)
                        .padding(.horizontal, 15)
                        .background(.black.opacity(0.7)) // Darker capsule
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(retroNeonLime.opacity(0.6), lineWidth: 1))
                        .neonGlow(retroNeonLime, radius: 8)
                        .padding(.top, 5) // Push down slightly from Nav Bar
                        Spacer()
                    }
                    .transition(.opacity.animation(.easeInOut))
                }
                
            } // End ZStack
            .navigationTitle("80s Spotify Search") // Themed Title
            .navigationBarTitleDisplayMode(.inline)
            // --- Themed Navigation Bar ---
            .toolbarBackground(retroDeepPurple.opacity(0.9), for: .navigationBar) // Dark, slightly translucent
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar) // Ensure title/buttons are light
            
            // --- Search Bar ---
            .searchable(text: $searchQuery,
                        placement: .navigationBarDrawer(displayMode: .always),
                        prompt: Text("Search Albums or Artists...").foregroundColor(.gray))
            .onSubmit(of: .search) { // Perform search immediately on submit
                debounceTask?.cancel() // Cancel any pending debounce
                Task { await performSearch(query: searchQuery, immediate: true) }
            }
            .onChange(of: searchQuery) {
                // Reset error on new input
                if currentError != nil { currentError = nil }
                // Setup or reset debounce task
                debounceTask?.cancel()
                debounceTask = Task { await performSearch(query: searchQuery) }
            }
            .accentColor(retroNeonPink) // Tints cursor, cancel button
            
        } // End NavigationView
        .accentColor(retroNeonPink) // Set global accent for potential other uses
    }
    
    // --- Computed View for the List ---
    private var albumList: some View {
        List {
            // Optional: Section header if needed, but SearchMetadataHeader might suffice
            // --- Metadata Header ---
            if let info = searchInfo, info.total > 0 {
                SearchMetadataHeader(totalResults: info.total, limit: info.limit, offset: info.offset)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 0, leading: 15, bottom: 8, trailing: 15)) // Add standard padding
                    .listRowBackground(Color.clear)
            }
            
            // --- Album Cards ---
            ForEach(displayedAlbums) { album in
                // Use NavigationLink to push Detail View
                NavigationLink(destination: AlbumDetailView(album: album)) {
                    RetroAlbumCard(album: album) // Themed card view
                        .padding(.vertical, 6) // Space between cards
                }
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 15)) // Standard padding
                .listRowBackground(Color.clear) // Make rows transparent
            }
            
            // TODO: Add pagination / "Load More" functionality here if needed
            // Example: Check if info.next is not nil and show a button/indicator
        }
        .listStyle(PlainListStyle()) // Remove default List styling
        .background(Color.clear) // Make List background transparent
        .scrollContentBackground(.hidden) // Required for ZStack background to show
    }
    
    // --- Search Function with Debounce ---
    private func performSearch(query: String, immediate: Bool = false) async {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedQuery.isEmpty else {
            await MainActor.run { displayedAlbums = []; searchInfo = nil; isLoading = false; currentError = nil }
            return
        }
        
        // Debounce logic
        if !immediate {
            do {
                try await Task.sleep(for: .milliseconds(500)) // 500ms debounce
                try Task.checkCancellation() // Ensure task wasn't cancelled during sleep
            } catch {
                print("Search task cancelled (debounce).")
                return // Exit if cancelled
            }
        }
        
        // Check if the query is still the same after the debounce period
        guard trimmedQuery == searchQuery.trimmingCharacters(in: .whitespacesAndNewlines) else {
            print("Query changed during debounce, skipping API call.")
            return
        }
        
        
        await MainActor.run { isLoading = true } // Set loading state
        
        do {
            let response = try await SpotifyAPIService.shared.searchAlbums(query: trimmedQuery, offset: 0)
            try Task.checkCancellation() // Check cancellation after API call
            
            await MainActor.run {
                displayedAlbums = response.albums.items
                searchInfo = response.albums
                currentError = nil // Clear previous error
                isLoading = false
            }
        } catch is CancellationError {
            print("Search task cancelled.")
            await MainActor.run { isLoading = false } // Ensure loading state is reset
        } catch let apiError as SpotifyAPIError {
            print("❌ API Error: \(apiError.localizedDescription)")
            await MainActor.run {
                displayedAlbums = []
                searchInfo = nil
                currentError = apiError
                isLoading = false
            }
        } catch {
            print("❌ Unexpected Error: \(error.localizedDescription)")
            await MainActor.run {
                displayedAlbums = []
                searchInfo = nil
                currentError = .networkError(error) // Categorize unexpected errors
                isLoading = false
            }
        }
    }
}

// MARK: Album Detail View
struct AlbumDetailView: View {
    let album: AlbumItem
    @State private var tracks: [Track] = []
    @State private var isLoadingTracks: Bool = false
    @State private var trackFetchError: SpotifyAPIError? = nil
    @State private var selectedTrackUri: String? = nil // Store the URI of the track to play
    @StateObject private var playbackState = SpotifyPlaybackState() // State for the embed player
    @Environment(\.dismiss) var dismiss // To potentially close view on error
    
    var body: some View {
        ZStack {
            // --- Retro Background ---
            retroDeepPurple.ignoresSafeArea() // Base color
            LinearGradient(colors: [.black.opacity(0.2), .clear], startPoint: .top, endPoint: .bottom)
                .blendMode(.overlay)
                .overlay (
                    Image("retro_grid_background") // Assuming you have this image
                        .resizable()
                        .scaledToFill()
                        .blendMode(.screen)
                        .opacity(0.1) // Make grid more subtle
                )
                .ignoresSafeArea()
            
            List {
                // --- Header Section ---
                Section { AlbumHeaderView(album: album) }
                    .listRowInsets(EdgeInsets()) // Fill width
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear) // Transparent row
                
                // --- Player Section (Shows when a track is selected) ---
                if let uriToPlay = selectedTrackUri {
                    Section {
                        SpotifyEmbedPlayerView(playbackState: playbackState, spotifyUri: uriToPlay)
                            .padding(.horizontal, 15) // Add padding around player
                    }
                    .listRowInsets(EdgeInsets(top: 15, leading: 0, bottom: 15, trailing: 0))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    // Smooth appearance/disappearance
                    .transition(.opacity.combined(with: .scale(scale: 0.95, anchor: .top)))
                }
                
                // --- Tracks Section ---
                // Inside AlbumDetailView's body -> List -> Section for tracks:
                Section {
                    TracksSectionView( // Use the refactored parent view
                        tracks: tracks,
                        isLoading: isLoadingTracks,
                        error: trackFetchError,
                        selectedTrackUri: $selectedTrackUri, // Pass binding
                        retryAction: { Task { await fetchTracks() } }
                    )
                } header: {
                    // --- Tracks Section Header ---
                    Text("TRACKLIST")
                        .font(retroFont(size: 12, weight: .bold))
                        // ... rest of header styling ...
                }
                .listRowInsets(EdgeInsets()) // Apply to the Section
                .listRowSeparator(.hidden)   // Apply to the Section
                .listRowBackground(Color.clear) // Apply to the Section
                
                // --- External Link Section ---
                if let spotifyURL = URL(string: album.external_urls.spotify ?? "") {
                    Section {
                        ExternalLinkButton( // Uses RetroButton internally
                            text: "BLAST ON SPOTIFY",
                            url: spotifyURL,
                            primaryColor: retroNeonLime,
                            secondaryColor: .green // Spotify green accent
                        )
                    }
                    .listRowInsets(EdgeInsets(top: 20, leading: 15, bottom: 20, trailing: 15))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }
                
            } // End List
            .listStyle(PlainListStyle())
            .scrollContentBackground(.hidden) // Allow ZStack background
            .refreshable { await fetchTracks(forceReload: true) } // Pull-to-refresh
            
        } // End ZStack
        .navigationTitle(album.name)
        .navigationBarTitleDisplayMode(.inline)
        // Consistent Nav Bar Theme
        .toolbarBackground(retroDeepPurple.opacity(0.9), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .task { await fetchTracks() } // Fetch tracks when view appears
        .animation(.easeInOut(duration: 0.3), value: selectedTrackUri) // Animate player appearance smoothly
        //        .onChange(of: trackFetchError) { error in // Handle fatal track errors
        //            if error == .invalidToken {
        //                // Optionally dismiss the view or show a more prominent error if token fails here
        //                print("Error: Invalid token while fetching tracks.")
        //                // dismiss() // Example: Close detail view on token error
        //            }
        //        }
    }
    
    // --- Fetch Tracks Logic ---
    private func fetchTracks(forceReload: Bool = false) async {
        // If already loading, don't start another request
        guard !isLoadingTracks else { return }
        // Only fetch if forced, or if tracks are empty, or if there was a previous error
        guard forceReload || tracks.isEmpty || trackFetchError != nil else { return }
        
        print("Fetching tracks for Album ID: \(album.id)")
        await MainActor.run {
            isLoadingTracks = true
            trackFetchError = nil // Clear previous error on retry/reload
        }
        
        do {
            let response = try await SpotifyAPIService.shared.getAlbumTracks(albumId: album.id)
            try Task.checkCancellation()
            await MainActor.run { self.tracks = response.items; self.isLoadingTracks = false }
        } catch is CancellationError {
            print("Track fetch cancelled.")
            await MainActor.run { isLoadingTracks = false }
        } catch let apiError as SpotifyAPIError {
            print("❌ API Error fetching tracks: \(apiError.localizedDescription)")
            await MainActor.run { self.trackFetchError = apiError; self.isLoadingTracks = false; self.tracks = [] }
        } catch {
            print("❌ Unexpected Error fetching tracks: \(error.localizedDescription)")
            await MainActor.run { self.trackFetchError = .networkError(error); self.isLoadingTracks = false; self.tracks = [] }
        }
    }
}


// MARK: - List View Sub-Components (Themed)

struct RetroAlbumCard: View {
    let album: AlbumItem
    
    var body: some View {
        HStack(spacing: 15) {
            // --- Album Art ---
            AlbumImageView(url: album.listImageURL) // Uses themed placeholder logic
                .frame(width: 80, height: 80) // Slightly smaller for list
                .clipShape(RoundedRectangle(cornerRadius: 8)) // Less rounded
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(LinearGradient(colors: [retroNeonPink.opacity(0.4), retroNeonCyan.opacity(0.4)], startPoint: .top, endPoint: .bottom), lineWidth: 1))
                .shadow(color: .black.opacity(0.4), radius: 4, y: 2)
            
            // --- Text Details ---
            VStack(alignment: .leading, spacing: 4) {
                Text(album.name)
                    .font(retroFont(size: 15, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(2) // Allow two lines for name
                
                Text(album.formattedArtists)
                    .font(retroFont(size: 13))
                    .foregroundColor(retroNeonLime) // Artist accent
                    .lineLimit(1)
                
                Spacer() // Push bottom info down
                
                HStack(spacing: 6) {
                    // Simplified Type/Date display
                    Label(album.album_type.capitalized, systemImage: iconForAlbumType(album.album_type))
                        .font(retroFont(size: 10, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(1)
                    
                    Text("•")
                        .foregroundColor(.white.opacity(0.5))
                    
                    Text( "Released: \(album.formattedReleaseDate())")
                        .font(retroFont(size: 10, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(1)
                    
                    Spacer() // Push track count right
                    
                    Text("\(album.total_tracks) Tracks")
                        .font(retroFont(size: 10, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                    
                }
            } // End Text VStack
            .frame(maxWidth: .infinity, alignment: .leading) // Allow text to take space
            
        } // End HStack
        .padding(12) // Padding inside the card
        // --- Card Background ---
        .background(
            LinearGradient(colors: [.black.opacity(0.4), .black.opacity(0.1)], startPoint: .top, endPoint: .bottom) // Subtle gradient
                .overlay(.ultraThinMaterial.opacity(0.5)) // Frosted glass effect
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous)) // Use continuous for smoother curves
                .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(retroNeonCyan.opacity(0.3), lineWidth: 1)) // Fainter outline
        )
        .frame(height: 110) // Slightly taller card
    }
    
    // Helper for album type icon
    private func iconForAlbumType(_ type: String) -> String {
        switch type.lowercased() {
        case "album": return "opticaldisc" // CD icon
        case "single": return "record.circle"
        case "compilation": return "rectangle.stack.fill" // Stack icon
        default: return "music.note"
        }
    }
}


struct AlbumImageView: View {
    let url: URL?
    
    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
                // Themed Loading Placeholder
                ZStack {
                    RoundedRectangle(cornerRadius: 8) // Match card rounding
                        .fill(LinearGradient(colors: [retroDeepPurple.opacity(0.5), .black.opacity(0.4)], startPoint: .top, endPoint: .bottom))
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(retroNeonPink.opacity(0.2), lineWidth: 1))
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: retroNeonCyan))
                        .scaleEffect(0.8) // Smaller progress view
                }
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill) // Fill the frame
            case .failure:
                // Themed Failure Placeholder
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(LinearGradient(colors: [retroDeepPurple.opacity(0.5), .black.opacity(0.4)], startPoint: .top, endPoint: .bottom))
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(retroNeonPink.opacity(0.5), lineWidth: 1)) // Error outline
                    Image(systemName: "photo.on.rectangle.angled") // More descriptive icon
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(retroNeonPink.opacity(0.6))
                        .padding(15) // Padding around icon
                }
            @unknown default:
                EmptyView() // Should not happen
            }
        }
    }
}

struct SearchMetadataHeader: View {
    let totalResults: Int
    let limit: Int
    let offset: Int
    
    private var showingRange: String {
        guard totalResults > 0 else { return "" }
        let start = offset + 1
        let end = min(offset + limit, totalResults)
        return "\(start)-\(end) of \(totalResults)"
    }
    
    var body: some View {
        HStack {
            Label("TOTALLY \(totalResults) RESULTS!", systemImage: "sparkle.magnifyingglass") // Retro themed icon and text
            Spacer()
            if totalResults > limit {
                Text("SHOWING \(showingRange)")
            }
        }
        .font(retroFont(size: 10, weight: .bold)) // Bold header text
        .foregroundColor(retroNeonLime.opacity(0.9))
        .tracking(1.5) // Add letter spacing
        .padding(.horizontal, 12)
        .padding(.vertical, 5)
        .background(.black.opacity(0.5), in: Capsule()) // Darker, themed background
        .overlay(Capsule().stroke(retroNeonLime.opacity(0.4), lineWidth: 1))
    }
}

// MARK: - Detail View Sub-Components (Themed)

struct AlbumHeaderView: View {
    let album: AlbumItem
    
    var body: some View {
        VStack(spacing: 15) {
            // --- Album Art ---
            AlbumImageView(url: album.bestImageURL)
                .aspectRatio(1.0, contentMode: .fit) // Keep it square
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .overlay(
                    // Subtle gradient border
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(LinearGradient(colors: [retroNeonPink.opacity(0.6), retroNeonCyan.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 2)
                )
                .neonGlow(retroNeonCyan, radius: 18) // Stronger glow for header image
                .padding(.horizontal, 50) // Give it space
                .padding(.top, 10) // Add top padding
            
            // --- Text Info Below Art ---
            VStack(spacing: 5) {
                Text(album.name)
                    .font(retroFont(size: 22, weight: .bold)) // Larger, bold title
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .shadow(color: .black.opacity(0.6), radius: 2, y: 1) // Text shadow for readability
                
                Text("by \(album.formattedArtists)")
                    .font(retroFont(size: 16))
                    .foregroundColor(retroNeonLime) // Artist accent color
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 5) // Add space after artist
                
                // Album Type & Release Date
                Text("\(album.album_type.capitalized) • Released \(album.formattedReleaseDate())")
                    .font(retroFont(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.75)) // Slightly brighter secondary text
            }
            .padding(.horizontal) // Padding for text block
            
        }
        .padding(.vertical, 25) // Vertical padding for the whole header section
    }
}

struct SpotifyEmbedPlayerView: View {
    @ObservedObject var playbackState: SpotifyPlaybackState
    let spotifyUri: String // URI is passed in, not optional here
    
    var body: some View {
        VStack(spacing: 8) {
            // --- WebView Embed ---
            SpotifyEmbedWebView(playbackState: playbackState, spotifyUri: spotifyUri)
                .frame(height: 85) // Standard embed height + small buffer
            // Player Frame/Background
                .background(
                    // Darker background with gradient overlay
                    LinearGradient(colors: [.black.opacity(0.6), .black.opacity(0.3)], startPoint: .top, endPoint: .bottom)
                        .overlay( // Add a slight material blur for effect
                            .ultraThinMaterial.opacity(0.6)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12)) // Rounded corners
                    // Neon stroke outline that changes with play state
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(LinearGradient(colors: [playbackState.isPlaying ? retroNeonLime.opacity(0.7) : retroNeonPink.opacity(0.6), retroNeonCyan.opacity(0.5)], startPoint: .leading, endPoint: .trailing), lineWidth: 1.5)
                        )
                        .neonGlow(playbackState.isPlaying ? retroNeonLime : retroNeonPink, radius: 10) // Dynamic glow
                )
                .padding(.horizontal) // Padding added by parent DetailView section
            
            // --- Themed Playback Status Text and Time ---
            HStack {
                let statusText = playbackState.isPlaying ? "NOW PLAYING" : (playbackState.currentPosition > 0.1 ? "PAUSED" : "READY")
                let statusColor = playbackState.isPlaying ? retroNeonLime : (playbackState.currentPosition > 0.1 ? retroNeonOrange : retroNeonPink)
                
                // Status Text
                Text(statusText)
                    .font(retroFont(size: 10, weight: .bold))
                    .foregroundColor(statusColor)
                    .tracking(1.5) // Letter spacing
                    .neonGlow(statusColor, radius: 5) // Subtle glow on text
                    .lineLimit(1)
                    .frame(width: 100, alignment: .leading) // Fixed width for status text
                
                Spacer()
                
                // Time Display
                if playbackState.duration > 0.1 {
                    Text("\(formatTime(playbackState.currentPosition)) / \(formatTime(playbackState.duration))")
                        .font(retroFont(size: 10, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                } else {
                    Text("--:-- / --:--") // Placeholder if duration not loaded
                        .font(retroFont(size: 10, weight: .medium))
                        .foregroundColor(.white.opacity(0.5))
                }
            }
            .padding(.horizontal, 25) // Align with player frame padding
            .padding(.top, 2) // Small space above status line
            .frame(minHeight: 15) // Ensure height even if time is missing
            
            // --- Error Display ---
            if let error = playbackState.error {
                Text("Player Error: \(error)")
                    .font(retroFont(size: 9))
                    .foregroundColor(retroNeonPink)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal, 20)
                    .padding(.top, 4)
            }
            
        } // End VStack
        .animation(.easeInOut(duration: 0.4), value: playbackState.isPlaying) // Animate play state changes
        .animation(.easeInOut, value: playbackState.error) // Animate error display
    }
    
    private func formatTime(_ time: Double) -> String {
        let totalSeconds = max(0, Int(time)) // Ensure non-negative
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
// MARK: - Tracks Section (Refactored Parent View) -
//
//struct TracksSectionView: View {
//    // Inputs remain the same
//    let tracks: [Track]
//    let isLoading: Bool
//    let error: SpotifyAPIError?
//    @Binding var selectedTrackUri: String? // Binding to update parent
//    let retryAction: () -> Void
//    
//    var body: some View {
//        // The main view now simply switches between the specialized sub-views
//        Group {
//            if isLoading {
//                TrackLoadingView() // Specific view for loading state
//            } else if let error = error {
//                TrackErrorView(error: error, retryAction: retryAction) // Specific view for error state
//            } else if tracks.isEmpty {
//                TrackEmptyView() // Specific view for empty state (after loading)
//            } else {
//                // Specific view for displaying the list of tracks
//                TrackListView(tracks: tracks, selectedTrackUri: $selectedTrackUri)
//            }
//        }
//        // Modifiers like listRowBackground, listRowInsets, etc.,
//        // are typically applied by the parent List Section containing this view.
//        // So, no padding or background specific to the *section* itself is needed here.
//    }
//}

// MARK: - Tracks Section Sub-Views -

// 1. View for the Loading State
struct TrackLoadingView: View {
    var body: some View {
        HStack { // Center the loading indicator within the row/section space
            Spacer()
            ProgressView {
                Text("Loading Tracks...")
                    .font(retroFont(size: 12))
                    .foregroundColor(retroNeonCyan.opacity(0.8))
             }
            .progressViewStyle(CircularProgressViewStyle(tint: retroNeonCyan))
            Spacer()
        }
        .frame(height: 100) // Give the loading indicator some vertical space
        // Use listRowBackground(.clear) on the Section in the parent if needed
        .padding(.vertical, 20) // Add padding within the loading view itself
    }
}

// 2. View for the Error State
struct TrackErrorView: View {
    let error: SpotifyAPIError
    let retryAction: () -> Void
    
    var body: some View {
        // Use the existing themed ErrorPlaceholderView
         ErrorPlaceholderView(error: error, retryAction: retryAction)
            // Padding might be needed depending on how it's used in the List
            .padding(.vertical, 20)
    }
}

// 3. View for the Empty State (After Successful Load)
struct TrackEmptyView: View {
    var body: some View {
        Text("This album seems to be empty!\nNo tracks found.")
            .font(retroFont(size: 13))
            .foregroundColor(.white.opacity(0.6))
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.vertical, 30) // Give the message space
    }
}

// 4. View for Displaying the List of Tracks
//struct TrackListView: View {
//    let tracks: [Track]
//    @Binding var selectedTrackUri: String? // Needs binding to update selection
//    
//    var body: some View {
//        Text("TrackListView")
//    }
//    
////    var body: some View {
////        // The ForEach loop containing the actual track rows
////        // This doesn't need to be a List itself, as it will be placed *inside* a List Section.
////        ForEach(tracks) { track in
////            TrackRowView( // Using the existing TrackRowView
////                track: track,
////                isSelected: track.uri == selectedTrackUri // Pass selection state
////            )
////            .contentShape(Rectangle()) // Ensure the whole row area is tappable
////            .onTapGesture {
////                // Update the binding when a row is tapped
////                selectedTrackUri = track.uri
////                print("Selected track URI (from TrackListView): \(track.uri)")
////            }
////            // Apply visual selection state using row background
////            // This modifier *is* relevant here as it applies per-row based on selection
////            .listRowBackground(
////                track.uri == selectedTrackUri
////                // Subtle gradient highlight for the selected row
////                 ? LinearGradient(colors: [retroNeonPink.opacity(0.15), retroNeonCyan.opacity(0.1)], startPoint: .leading, endPoint: .trailing)
////                        .blur(radius: 5)
////                        .transition(.opacity.animation(.easeInOut)) // Animate background change
////                : Color.clear // Transparent background normally
////            )
////        }
////    }
//}


// MARK: - Tracks Section Sub-Views (Continued Refactoring) -

// 4. View for Displaying the List of Tracks (Parent Container)
struct TrackListView: View {
    let tracks: [Track]
    @Binding var selectedTrackUri: String? // Pass binding down

    var body: some View {
        // This ForEach now generates TappableTrackRow for each track
        ForEach(tracks) { track in
            TappableTrackRow(
                track: track,
                selectedTrackUri: $selectedTrackUri // Pass the binding
            )
        }
        // Modifiers like listRowSeparator, listRowInsets are applied to the *Section*
        // containing this TrackListView in the parent view (AlbumDetailView).
    }
}

// 5. New View: Represents a single tappable track row with selection logic
struct TappableTrackRow: View {
    let track: Track
    @Binding var selectedTrackUri: String? // Binding to update the selection

    // Computed property to determine if *this specific* row is selected
    private var isSelected: Bool {
        track.uri == selectedTrackUri
    }

    var body: some View {
        // Use the existing view for the row's visual content
        TrackRowView(
            track: track,
            isSelected: isSelected // Pass the computed selection state
        )
        .contentShape(Rectangle()) // Make the entire rendered area tappable
        .onTapGesture {
            // Update the selected URI binding when tapped
            selectedTrackUri = track.uri
            print("Selected track URI (from TappableTrackRow): \(track.uri)")
        }
        // Apply the conditional background modifier based on selection state
        .listRowBackground(
            isSelected
            ? Color.yellow.opacity(0.5)// Use helper for selected background
             : Color.clear        // Transparent background otherwise
        )
        // Ensure list row separators and insets are handled by the parent List/Section
    }

    // Helper computed property for the selected background view
    private var selectedBackground: some View {
        LinearGradient(
             colors: [retroNeonPink.opacity(0.15), retroNeonCyan.opacity(0.1)],
             startPoint: .leading,
             endPoint: .trailing
        )
        .blur(radius: 5) // Apply blur for a softer highlight
        .transition(.opacity.animation(.easeInOut)) // Animate the background change
    }
}

// MARK: - Existing TrackRowView (Still Unchanged) -
// This view remains purely presentational
//
//struct TrackRowView: View {
//    let track: Track
//    let isSelected: Bool
//
//    var body: some View {
//        HStack(spacing: 12) {
//            // --- Track Number ---
//            Text("\(track.track_number)")
//                .font(retroFont(size: 12, weight: .medium))
//                .foregroundColor(isSelected ? retroNeonLime : .white.opacity(0.6))
//                .frame(width: 25, alignment: .center)
//                .padding(.leading, 15)
//
//            // --- Track Info (Name & Artist) ---
//            VStack(alignment: .leading, spacing: 2) {
//                Text(track.name)
//                    .font(retroFont(size: 15, weight: isSelected ? .bold : .regular))
//                    .foregroundColor(isSelected ? retroNeonCyan : .white)
//                    .lineLimit(1)
//
//                Text(track.formattedArtists)
//                    .font(retroFont(size: 11))
//                    .foregroundColor(.white.opacity(0.7))
//                    .lineLimit(1)
//            }
//
//            Spacer() // Push duration and icon to the right
//
//            // --- Duration ---
//            Text(track.formattedDuration)
//                .font(retroFont(size: 12, weight: .medium))
//                .foregroundColor(.white.opacity(0.7))
//                .padding(.trailing, 5)
//
//            // --- Play / Selected Indicator Icon ---
//            Image(systemName: isSelected ? "waveform.and.magnifyingglass" : "play.circle")
//                .foregroundColor(isSelected ? retroNeonLime : .white.opacity(0.7))
//                .font(.body.weight(.semibold))
//                .frame(width: 25, height: 25)
//                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
//                .padding(.trailing, 15)
//        }
//        .padding(.vertical, 12)
//        .background( // Subtle separator line visually
//            VStack {
//                Spacer()
//                Divider().background(Color.white.opacity(0.1)).padding(.leading, 50)
//            }
//                .opacity(isSelected ? 0 : 1) // Hide divider for selected row
//        )
//    }
//}

// MARK: - Reminder: Parent TracksSectionView and other sub-views -
// The definitions for TracksSectionView, TrackLoadingView, TrackErrorView,
// and TrackEmptyView created previously should still be present.

// Example of TracksSectionView using the updated TrackListView
struct TracksSectionView: View {
    let tracks: [Track]
    let isLoading: Bool
    let error: SpotifyAPIError?
    @Binding var selectedTrackUri: String?
    let retryAction: () -> Void

    var body: some View {
        Group {
            if isLoading {
                TrackLoadingView()
            } else if let error = error {
                TrackErrorView(error: error, retryAction: retryAction)
            } else if tracks.isEmpty {
                TrackEmptyView()
            } else {
                // Use the TrackListView which now generates TappableTrackRow internally
                 TrackListView(tracks: tracks, selectedTrackUri: $selectedTrackUri)
            }
        }
    }
}

// Other sub-views (TrackLoadingView, TrackErrorView, TrackEmptyView)
// should remain as defined in the previous step.


// MARK: - Existing TrackRowView (No changes needed to this specific view) -
//
//struct TrackRowView: View {
//    let track: Track
//    let isSelected: Bool
//
//    var body: some View {
//        HStack(spacing: 12) {
//            // --- Track Number ---
//            Text("\(track.track_number)")
//                .font(retroFont(size: 12, weight: .medium))
//                .foregroundColor(isSelected ? retroNeonLime : .white.opacity(0.6))
//                .frame(width: 25, alignment: .center)
//                .padding(.leading, 15)
//
//            // --- Track Info (Name & Artist) ---
//            VStack(alignment: .leading, spacing: 2) {
//                Text(track.name)
//                    .font(retroFont(size: 15, weight: isSelected ? .bold : .regular))
//                    .foregroundColor(isSelected ? retroNeonCyan : .white)
//                    .lineLimit(1)
//
//                Text(track.formattedArtists)
//                    .font(retroFont(size: 11))
//                    .foregroundColor(.white.opacity(0.7))
//                    .lineLimit(1)
//            }
//
//            Spacer() // Push duration and icon to the right
//
//            // --- Duration ---
//            Text(track.formattedDuration)
//                .font(retroFont(size: 12, weight: .medium))
//                .foregroundColor(.white.opacity(0.7))
//                .padding(.trailing, 5)
//
//            // --- Play / Selected Indicator Icon ---
//            Image(systemName: isSelected ? "waveform.and.magnifyingglass" : "play.circle")
//                .foregroundColor(isSelected ? retroNeonLime : .white.opacity(0.7))
//                .font(.body.weight(.semibold))
//                .frame(width: 25, height: 25)
//                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
//                .padding(.trailing, 15)
//
//        }
//        .padding(.vertical, 12)
//        .background( // Subtle separator line visually (optional)
//            VStack {
//                Spacer()
//                Divider().background(Color.white.opacity(0.1)).padding(.leading, 50)
//            }
//                .opacity(isSelected ? 0 : 1) // Hide divider for selected row
//        )
//        // Modifiers like listRowBackground are applied by the parent (TrackListView)
//        // No horizontal padding here; handled by list row insets in the parent List
//    }
//}

//
//struct TracksSectionView: View {
//    let tracks: [Track]
//    let isLoading: Bool
//    let error: SpotifyAPIError?
//    @Binding var selectedTrackUri: String? // Binding to update selected track in parent
//    let retryAction: () -> Void
//    
//    var body: some View {
//        Text("Track Section View")
//    }
//    
//    //    var body: some View {
//    //        // Group to contain the conditional logic, used within a List Section
//    //        Group {
//    //            if isLoading {
//    //                // Centered Loading Indicator for Tracks
//    //                HStack {
//    //                    Spacer()
//    //                    ProgressView {
//    //                        Text("Loading Tracks...")
//    //                            .font(retroFont(size: 12))
//    //                            .foregroundColor(retroNeonCyan.opacity(0.8))
//    //                     }
//    //                    .progressViewStyle(CircularProgressViewStyle(tint: retroNeonCyan))
//    //                    Spacer()
//    //                }
//    //                .frame(height: 100) // Give it some space
//    //            } else if let error = error {
//    //                // Use ErrorPlaceholderView for track loading errors
//    //                 ErrorPlaceholderView(error: error, retryAction: retryAction)
//    //                    // No extra padding needed if row insets handle it
//    //            } else if tracks.isEmpty {
//    //                 // Specific message if tracks loaded successfully but none were found
//    //                Text("This album seems to be empty!\nNo tracks found.")
//    //                    .font(retroFont(size: 13))
//    //                    .foregroundColor(.white.opacity(0.6))
//    //                    .multilineTextAlignment(.center)
//    //                    .frame(maxWidth: .infinity, alignment: .center)
//    //                    .padding(.vertical, 30) // Give empty message space
//    //            } else {
//    //                // Display Track Rows
//    //                ForEach(tracks) { track in
//    //                    TrackRowView(
//    //                        track: track,
//    //                        isSelected: track.uri == selectedTrackUri // Highlight based on binding
//    //                    )
//    //                    .contentShape(Rectangle()) // Make whole row tappable
//    //                    .onTapGesture {
//    //                        // Update the binding when a row is tapped
//    //                        selectedTrackUri = track.uri
//    //                        print("Selected track URI: \(track.uri)")
//    //                    }
//    //                    // Apply visual selection state using row background
//    //                    .listRowBackground(
//    //                        track.uri == selectedTrackUri
//    //                         ? LinearGradient(colors: [retroNeonPink.opacity(0.15), retroNeonCyan.opacity(0.1)], startPoint: .leading, endPoint: .trailing).blur(radius: 5) // Subtle gradient background for selected
//    //                        : Color.clear // Transparent background otherwise
//    //                    )
//    //                }
//    //            }
//    //        }
//    //    }
//}

struct TrackRowView: View {
    let track: Track
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            // --- Track Number ---
            Text("\(track.track_number)")
                .font(retroFont(size: 12, weight: .medium))
            // Highlight number color if selected
                .foregroundColor(isSelected ? retroNeonLime : .white.opacity(0.6))
                .frame(width: 25, alignment: .center)
                .padding(.leading, 15) // Indent track number
            
            // --- Track Info (Name & Artist) ---
            VStack(alignment: .leading, spacing: 2) { // Reduced spacing
                Text(track.name)
                    .font(retroFont(size: 15, weight: isSelected ? .bold : .regular)) // Bold selected track name
                    .foregroundColor(isSelected ? retroNeonCyan : .white) // Highlight selected name
                    .lineLimit(1)
                
                Text(track.formattedArtists)
                    .font(retroFont(size: 11))
                    .foregroundColor(.white.opacity(0.7)) // Standard artist color
                    .lineLimit(1)
            }
            
            Spacer() // Push duration and icon to the right
            
            // --- Duration ---
            Text(track.formattedDuration)
                .font(retroFont(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
                .padding(.trailing, 5)
            
            // --- Play / Selected Indicator Icon ---
            Image(systemName: isSelected ? "waveform.and.magnifyingglass" : "play.circle") // Retro-ish icons
                .foregroundColor(isSelected ? retroNeonLime : .white.opacity(0.7))
                .font(.body.weight(.semibold)) // Make icon slightly bolder
                .frame(width: 25, height: 25)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected) // Bouncy animation
                .padding(.trailing, 15) // Space from right edge
            
        }
        .padding(.vertical, 12) // Comfortable tap height
        // No horizontal padding here; handled by list row insets
        .background( // Add subtle separator line visually (optional)
            VStack {
                Spacer()
                Divider().background(Color.white.opacity(0.1)).padding(.leading, 50) // Indented divider like classic lists
            }
                .opacity(isSelected ? 0 : 1) // Hide divider for selected row
        )
    }
}

// MARK: - Generic Themed Button Component

struct RetroButton: View {
    let text: String
    let action: () -> Void
    var primaryColor: Color = retroNeonPink // Default neon color
    var secondaryColor: Color = retroNeonOrange // Default gradient end
    var iconName: String? = nil
    
    // Button State for Pressed Effect
    @State private var isPressed: Bool = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) { // Increased spacing
                if let iconName = iconName {
                    Image(systemName: iconName)
                        .font(.body.weight(.bold)) // Bold icon
                }
                Text(text)
                    .tracking(2.0) // Wider letter spacing
            }
            .font(retroFont(size: 15, weight: .bold))
            .padding(.horizontal, 30) // More horizontal padding
            .padding(.vertical, 14) // Taller button
            .frame(maxWidth: .infinity) // Expand to fill width
            .background(
                // Use primary/secondary for gradient
                LinearGradient(colors: [primaryColor, secondaryColor], startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .foregroundColor(retroDeepPurple) // Dark text contrasts well
            .clipShape(Capsule())
            // Subtle white top edge highlight
            .overlay(Capsule().stroke(Color.white.opacity(0.6), lineWidth: 1).blur(radius: 1).padding(1).offset(y:-1).mask(Capsule()))
            // Subtle dark bottom edge shadow
            .overlay(Capsule().stroke(Color.black.opacity(0.4), lineWidth: 1).blur(radius: 1).padding(1).offset(y: 1).mask(Capsule()))
            .neonGlow(primaryColor, radius: isPressed ? 6 : 12) // Reduce glow when pressed
            .scaleEffect(isPressed ? 0.97 : 1.0) // Scale down slightly when pressed
        }
        .buttonStyle(PlainButtonStyle()) // Use PlainButtonStyle to enable full customization
        // --- Add Press Gesture ---
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged({ _ in if !isPressed { withAnimation(.easeInOut(duration: 0.1)) { isPressed = true } }})
                .onEnded({ _ in withAnimation(.easeInOut(duration: 0.2)) { isPressed = false }})
        )
    }
}

// --- ExternalLinkButton (Using RetroButton) ---
struct ExternalLinkButton: View {
    let text: String // Allow custom text
    let url: URL
    var primaryColor: Color = retroNeonLime
    var secondaryColor: Color = .green // Spotify green accent
    var iconName: String? = "arrow.up.right.square.fill" // Fitting icon for external link
    
    @Environment(\.openURL) var openURL
    
    var body: some View {
        RetroButton(
            text: text,
            action: {
                print("ACTION: Opening external URL: \(url)")
                openURL(url) { accepted in
                    if !accepted {
                        print("⚠️ WARNING: Could not open URL: \(url)")
                        // Ideally, show an alert to the user here
                    }
                }
            },
            primaryColor: primaryColor,
            secondaryColor: secondaryColor,
            iconName: iconName
        )
    }
}

// MARK: - Placeholder Views (Themed)

struct ErrorPlaceholderView: View {
    let error: SpotifyAPIError
    let retryAction: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 25) {
            // --- Error Icon ---
            Image(systemName: iconNameForError(error))
                .font(.system(size: 70, weight: .light)) // Large, light icon
                .foregroundStyle(
                    LinearGradient(
                        gradient: Gradient(colors: [retroNeonPink, retroNeonOrange]), // Pink/Orange gradient for error
                        startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .neonGlow(retroNeonPink, radius: 20) // Strong pink glow for error
                .padding(.bottom, 10)
            
            // --- Error Title ---
            Text("SYSTEM ERROR!") // Classic error message style
                .font(retroFont(size: 24, weight: .bold))
                .foregroundColor(.white)
                .tracking(2.0) // Tracking for title
                .shadow(color: .black.opacity(0.5), radius: 2, y: 1)
            
            // --- Error Message ---
            Text(errorMessageForError(error))
                .font(retroFont(size: 15))
                .foregroundColor(.white.opacity(0.85))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
                .lineSpacing(5)
            
            // --- Retry Button (Conditional) ---
            //            if error != .invalidToken, // Don't show retry for token error
            //                let retryAction = retryAction {
            //                RetroButton(
            //                    text: "RETRY",
            //                    action: retryAction,
            //                    primaryColor: retroNeonLime,
            //                    secondaryColor: retroNeonCyan, // Green/Cyan gradient for retry
            //                    iconName: "arrow.clockwise"
            //                )
            //                .padding(.top, 15)
            //            } else if error == .invalidToken {
            //                // Specific message for token error
            //                 Text("Invalid Spotify Token!\nCheck your API Key in the code.")
            //                    .font(retroFont(size: 12))
            //                    .foregroundColor(retroNeonPink)
            //                    .multilineTextAlignment(.center)
            //                    .padding(.top, 10)
            //            }
            Text("Invalid Spotify Token!\nCheck your API Key in the code.")
                .font(retroFont(size: 12))
                .foregroundColor(retroNeonPink)
                .multilineTextAlignment(.center)
                .padding(.top, 10)
        }
        .padding(30)
        .frame(maxWidth: .infinity, maxHeight: .infinity) // Take available space
        // Use a material background for the placeholder container
//        .background(
//           // .ultraThinMaterial.opacity(0.8)
//            .background(retroDeepPurple.opacity(0.5)) // Tint the material
//                .clipShape(RoundedRectangle(cornerRadius: 20))
//                .overlay(RoundedRectangle(cornerRadius: 20).stroke(retroNeonPink.opacity(0.3), lineWidth: 1))
//               // .shadow(color: .black.opacity(0.3), radius: 10, y: 5)
//        )
        .padding(20) // Padding around the frosted glass container
    }
    
    // --- Helper functions for Error Display ---
    private func iconNameForError(_ error: SpotifyAPIError) -> String {
        switch error {
        case .invalidToken: return "key.slash" // Key symbol with slash
        case .networkError: return "wifi.exclamationmark" // Wifi symbol with alert
        case .invalidResponse: return "server.rack" // Server icon
        case .decodingError: return "doc.text.magnifyingglass" // Document inspection icon
        case .missingData: return "questionmark.folder" // Question mark folder
        case .invalidURL: return "link.badge.plus" // Link icon with issue badge
        }
    }
    
    private func errorMessageForError(_ error: SpotifyAPIError) -> String {
        switch error {
        case .invalidToken: return "Authentication failure. Your Spotify access token is invalid or expired."
        case .networkError: return "Cound not connect to the network. Check your internet connection."
        case .invalidResponse(let code, _): return "Received an unexpected response from the server (Code: \(code)). Please try again later."
        case .decodingError: return "Failed to understand the data received from the server."
        case .missingData: return "Some expected data was missing in the server response."
        case .invalidURL: return "The request URL was malformed." // Should ideally not happen
        }
    }
}

enum EmptyState { case initial, noResults }

struct EmptyStatePlaceholderView: View {
    let searchQuery: String
    let state: EmptyState
    
    var body: some View {
        VStack(spacing: 25) {
            // --- Icon/Image ---
            Image(systemName: iconName) // Use SFSymbols for easier theming
                .font(.system(size: 80, weight: .thin)) // Large, thin icon
                .foregroundStyle(
                    LinearGradient(
                        gradient: Gradient(colors: gradientColors),
                        startPoint: .top, endPoint: .bottom)
                )
                .neonGlow(glowColor, radius: 20)
                .padding(.bottom, 15)
            
            // --- Title ---
            Text(title)
                .font(retroFont(size: 24, weight: .bold))
                .foregroundColor(.white)
                .tracking(1.5)
                .shadow(color: .black.opacity(0.4), radius: 1, y: 1)
            
            /// --- Message (Using AttributedString for potential Markdown) ---
            Text(messageAttributedString)
                .font(retroFont(size: 15)) // Ensure consistent font
                .foregroundColor(.white.opacity(0.85))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
                .lineSpacing(5)
        }
        .padding(30)
        .frame(maxWidth: .infinity, maxHeight: .infinity) // Center placeholder
        // No extra background needed if main view has themed background
    }
    
    // --- Computed properties based on state ---
    private var iconName: String {
        state == .initial ? "music.mic.circle" : "magnifyingglass.circle"
    }
    
    private var title: String {
        state == .initial ? "READY TO ROCK!" : "NO HITS FOUND"
    }
    
    private var gradientColors: [Color] {
        state == .initial ? [retroNeonCyan, retroElectricBlue] : [retroNeonOrange, retroNeonPink]
    }
    
    private var glowColor: Color {
        state == .initial ? retroNeonCyan : retroNeonOrange
    }
    
    private var messageAttributedString: AttributedString {
        var message: AttributedString
        if state == .initial {
            message = AttributedString("Dial in an album or artist\nin the search bar above!")
        } else {
            // Using AttributedString's Markdown capability for bolding the query
            do {
                let query = searchQuery.isEmpty ? "that search" : searchQuery // Handle empty string case
                message = try AttributedString(markdown: "Zilch found for **\(query)**.\nTry rewinding and searching again!")
            } catch {
                // Fallback if markdown fails (shouldn't usually happen for simple bold)
                message = AttributedString("Zilch found for \"\(searchQuery)\". Try rewinding and searching again!")
            }
        }
        // Apply consistent styling to the entire attributed string
        message.font = retroFont(size: 15)
        message.foregroundColor = .white.opacity(0.85)
        // Optional: Further styling specific parts if needed
        // e.g., message.range(of: searchQuery)?.foregroundColor = retroNeonLime
        
        return message
    }
}

#Preview("SpotifyAlbumListView") {
    SpotifyAlbumListView()
}
// MARK: - App Entry Point

@main
struct SpotifyRetroPartyApp: App {
    init() {
        // --- CRITICAL TOKEN CHECK ---
        if placeholderSpotifyToken == "YOUR_SPOTIFY_BEARER_TOKEN_HERE" {
            print("🚨🚨🚨 WICKED WARNING: Spotify Bearer Token is MISSING! 🚨🚨🚨")
            print("➡️ FIX IT: Open the Swift file and replace 'YOUR_SPOTIFY_BEARER_TOKEN_HERE' with your actual token.")
            print("➡️ API calls will FAIL until fixed!")
        }
        
        // --- Optional Global UI Appearance (Less critical with SwiftUI theming) ---
        // Example: Setting a global tint color (affects some standard controls)
        // UIView.appearance().tintColor = UIColor(retroNeonPink)
        
        // Example: Customizing Navigation Bar appearance globally (can be overridden)
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(retroDeepPurple.opacity(0.9)) // Match nav bar background
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont(name: "Menlo-Bold", size: 18) ?? UIFont.boldSystemFont(ofSize: 18) // Use retro font
        ]
        appearance.largeTitleTextAttributes = [ // If using large titles
            .foregroundColor: UIColor.white,
            .font: UIFont(name: "Menlo-Bold", size: 34) ?? UIFont.boldSystemFont(ofSize: 34)
        ]
        appearance.shadowColor = .clear // Remove default separator line
        
        // Apply appearances
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance // For landscape/compact
        UINavigationBar.appearance().tintColor = UIColor(retroNeonPink) // Back button / bar button items color
    }
    
    var body: some Scene {
        WindowGroup {
            SpotifyAlbumListView() // Start with the main list view
                .preferredColorScheme(.dark) // Force dark mode for theme
        }
    }
}
