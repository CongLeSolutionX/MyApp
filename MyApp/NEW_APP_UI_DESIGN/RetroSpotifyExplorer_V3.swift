//
//  Retro_V3.swift
//  MyApp
//
//  Created by Cong Le on 4/18/25.
//

import SwiftUI
@preconcurrency import WebKit // Needed for WebView
import Foundation

// MARK: - Theme Constants & Modifiers

let retroDeepPurple = Color(red: 0.15, green: 0.05, blue: 0.25) // Dark background
let retroNeonPink = Color(red: 1.0, green: 0.1, blue: 0.5)
let retroNeonCyan = Color(red: 0.1, green: 0.9, blue: 0.9)
let retroNeonLime = Color(red: 0.7, green: 1.0, blue: 0.3)
let retroGradients: [Color] = [
    Color(red: 0.25, green: 0.12, blue: 0.4), // Deep purple
    Color(red: 0.55, green: 0.19, blue: 0.66), // Mid purple/pink
    Color(red: 0.95, green: 0.29, blue: 0.56), // Neon pinkish
    Color(red: 0.18, green: 0.5, blue: 0.96)    // Neon blue
]

// Custom Font Helper (adjust font names if needed)
func retroFont(size: CGFloat, weight: Font.Weight = .regular) -> Font {
    // Example: Using Menlo (built-in monospaced)
    // return Font.system(size: size, weight: weight, design: .monospaced)
    
    // Example: Using a custom font (replace "YourRetroFontName" if you add one)
    // return Font.custom("YourRetroFontName", size: size).weight(weight)
    
    // Defaulting to system monospaced
    return Font.system(size: size, design: .monospaced).weight(weight)
}

extension View {
    // Apply consistent neon glow
    func neonGlow(_ color: Color, radius: CGFloat = 8) -> some View {
        self
            .shadow(color: color.opacity(0.6), radius: radius / 2, x: 0, y: 0) // Inner sharp glow
            .shadow(color: color.opacity(0.4), radius: radius, x: 0, y: 0)     // Mid soft glow
            .shadow(color: color.opacity(0.2), radius: radius * 1.5, x: 0, y: 0) // Outer faint glow
    }
}

// MARK: - Data Models (Unchanged from previous versions)

struct SpotifySearchResponse: Codable, Hashable { /* ... */
    let albums: Albums
}
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
                // Use shortened month for a slightly more retro feel maybe?
                dateFormatter.dateFormat = "d MMM yyyy" // e.g., 17 Aug 1959
                return dateFormatter.string(from: date)
                // Or keep using system long format:
                // return date.formatted(date: .long, time: .omitted)
            }
        default: break
        }
        return release_date // Fallback
    }
}
struct Artist: Codable, Identifiable, Hashable { /* ... */
    let id: String
    let external_urls: ExternalUrls? // Make optional if sometimes missing
    let href: String
    let name: String
    let type: String // "artist"
    let uri: String
}
struct SpotifyImage: Codable, Hashable { /* ... */
    let height: Int?
    let url: String
    let width: Int?
    var urlObject: URL? { URL(string: url) }
}
struct ExternalUrls: Codable, Hashable { /* ... */
    let spotify: String? // Make optional if sometimes missing
}
struct AlbumTracksResponse: Codable, Hashable { /* ... */
    let items: [Track]
    // Add other fields like href, limit, next, offset, previous, total if needed
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
    let type: String // "track"
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

// MARK: - Spotify Embed WebView (Unchanged, kept from previous versions)

final class SpotifyPlaybackState: ObservableObject { /* ... */
    @Published var isPlaying: Bool = false
    @Published var currentPosition: Double = 0 // seconds
    @Published var duration: Double = 0 // seconds
    @Published var currentUri: String = ""
}
struct SpotifyEmbedWebView: UIViewRepresentable { /* ... */
    @ObservedObject var playbackState: SpotifyPlaybackState
    let spotifyUri: String?
    
    func makeCoordinator() -> Coordinator { Coordinator(self) }
    func makeUIView(context: Context) -> WKWebView { /* ... WebView setup ... */
        // --- Configuration ---
        let userContentController = WKUserContentController()
        userContentController.add(context.coordinator, name: "spotifyController")
        
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = userContentController
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        
        // --- WebView Creation ---
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.isOpaque = false
        webView.backgroundColor = .clear // Keep transparent
        webView.scrollView.isScrollEnabled = false
        
        // --- Load HTML ---
        let html = generateHTML() // Uses the helper below
        webView.loadHTMLString(html, baseURL: nil)
        
        // --- Store reference ---
        context.coordinator.webView = webView
        return webView
    }
    func updateUIView(_ webView: WKWebView, context: Context) { /* ... JS loading logic ... */
        // Check if the API is ready and the URI needs updating
        if context.coordinator.isApiReady && context.coordinator.lastLoadedUri != spotifyUri {
            context.coordinator.loadUri(spotifyUri ?? "")
            DispatchQueue.main.async {
                if playbackState.currentUri != spotifyUri {
                    playbackState.currentUri = spotifyUri ?? ""
                }
            }
        } else if !context.coordinator.isApiReady {
            // If the view updates with a new URI *before* the API is ready,
            // make sure the coordinator knows the *latest* desired URI.
            context.coordinator.updateDesiredUriBeforeReady(spotifyUri ?? "")
        }
    }
    static func dismantleUIView(_ uiView: WKWebView, coordinator: Coordinator) { /* ... Cleanup ... */
        print("Spotify Embed WebView: Dismantling.")
        uiView.stopLoading()
        uiView.configuration.userContentController.removeScriptMessageHandler(forName: "spotifyController")
        coordinator.webView = nil
    }
    
    // --- Coordinator ---
    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler { /* ... JS communication logic ... */
        var parent: SpotifyEmbedWebView
        weak var webView: WKWebView?
        var isApiReady = false
        var lastLoadedUri: String?
        private var desiredUriBeforeReady: String? = nil // Holds the URI if updateUIView is called before API is ready
        
        init(_ parent: SpotifyEmbedWebView) { self.parent = parent }
        
        // --- Method to update the desired URI before the API is ready ---
        func updateDesiredUriBeforeReady(_ uri: String) {
            if !isApiReady {
                desiredUriBeforeReady = uri
            }
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) { /* ... */
            print("Spotify Embed WebView: HTML content finished loading.")
        }
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) { /* ... */
            print("Spotify Embed WebView: Navigation failed: \(error.localizedDescription)")
        }
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) { /* ... */
            print("Spotify Embed WebView: Provisional navigation failed: \(error.localizedDescription)")
        }
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) { /* ... Handle JS messages ... */
            guard message.name == "spotifyController" else { return }
            if let bodyDict = message.body as? [String: Any], let event = bodyDict["event"] as? String {
                print("📦 Spotify Embed Native: JS Event Received - '\(event)', Data: \(bodyDict["data"] ?? "nil")") // DEBUG
                handleEvent(event: event, data: bodyDict["data"])
            } else if let bodyString = message.body as? String {
                print("📦 Spotify Embed Native: JS String Message Received - '\(bodyString)'") // DEBUG
                if bodyString == "ready" {
                    handleApiReady()
                } else {
                    print("❓ Spotify Embed Native: Received unknown string message: \(bodyString)")
                }
            } else {
                print("❓ Spotify Embed Native: Received message in unexpected format: \(message.body)")
            }
        }
        private func handleApiReady() { /* ... */
            print("✅ Spotify Embed Native: Spotify IFrame API reported ready.")
            isApiReady = true
            // Use the most recently desired URI when creating the controller
            if let initialUri = desiredUriBeforeReady ?? parent.spotifyUri {
                createSpotifyController(with: initialUri)
                desiredUriBeforeReady = nil // Clear it after use
            }
            
        }
        private func handleEvent(event: String, data: Any?) { /* ... Handle specific events ... */
            switch event {
            case "controllerCreated": /* ... */
                print("✅ Spotify Embed Native: Embed controller successfully created by JS.")
            case "playbackUpdate": /* ... */
                if let updateData = data as? [String: Any] { updatePlaybackState(with: updateData)}
            case "error": /* ... */
                let errorMessage = (data as? [String: Any])?["message"] as? String ?? (data as? String) ?? "Unknown JS error"
                print("❌ Spotify Embed JS Error: \(errorMessage)")
            default: /* ... */
                print("❓ Spotify Embed Native: Received unknown event type: \(event)")
            }
        }
        private func updatePlaybackState(with data: [String: Any]) { /* ... Update parent.playbackState ... */
            DispatchQueue.main.async { [weak self] in // Use weak self to avoid potential cycles
                guard let self = self else { return } // Ensure self is available
                
                if let isPaused = data["paused"] as? Bool {
                    if self.parent.playbackState.isPlaying == isPaused { self.parent.playbackState.isPlaying = !isPaused }
                }
                if let posMs = data["position"] as? Double {
                    let newPosition = posMs / 1000.0
                    if abs(self.parent.playbackState.currentPosition - newPosition) > 0.1 { self.parent.playbackState.currentPosition = newPosition }
                }
                if let durMs = data["duration"] as? Double {
                    let newDuration = durMs / 1000.0
                    if abs(self.parent.playbackState.duration - newDuration) > 0.1 || self.parent.playbackState.duration == 0 { self.parent.playbackState.duration = newDuration }
                }
                if let uri = data["uri"] as? String, self.parent.playbackState.currentUri != uri {
                    self.parent.playbackState.currentUri = uri
                }
            }
        }
        private func createSpotifyController(with initialUri: String) { /* ... JS execution ... */
            guard let webView = webView else { /* ... */ return }
            guard isApiReady else { /* ... */ return }
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
        func loadUri(_ uri: String) { /* ... JS execution ... */
            guard let webView = webView else { return }
            guard isApiReady else { return }
            guard lastLoadedUri != nil else { return } // Controller must exist
            guard lastLoadedUri != uri else { return } // Don't reload same URI
            
            print("🚀 Spotify Embed Native: Attempting to load new URI: \(uri)")
            lastLoadedUri = uri
            
            let script = """
            if (window.embedController) {
                console.log('Spotify Embed JS: Loading URI: \(uri)');
                window.embedController.loadUri('\(uri)');
                window.embedController.play(); // Attempt to play immediately after load
            } else { console.error('Spotify Embed JS: embedController not found for loadUri \(uri).'); window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'JS embedController not found during loadUri' }}); }
            """
            webView.evaluateJavaScript(script) { _, error in /* ... Handle JS execution error ... */
                if let error = error { print("⚠️ Spotify Embed Native: Error evaluating JS load URI \(uri): \(error.localizedDescription)") }
            }
        }
        // WKUIDelegate methods (like runJavaScriptAlertPanelWithMessage) unchanged...
        func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
            print("ℹ️ Spotify Embed Received JS Alert: \(message)")
            completionHandler() // Complete immediately in this context
        }
    }
    
    // --- Generate HTML ---
    private func generateHTML() -> String { /* ... HTML structure ... */
        """
        <!DOCTYPE html><html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no"><title>Spotify Embed</title><style>html, body { margin: 0; padding: 0; width: 100%; height: 100%; overflow: hidden; background-color: transparent; } #embed-iframe { width: 100%; height: 100%; box-sizing: border-box; display: block; border: none; }</style></head><body><div id="embed-iframe"></div><script src="https://open.spotify.com/embed/iframe-api/v1" async></script><script> console.log('Spotify Embed JS: Initial script running.'); window.onSpotifyIframeApiReady = (IFrameAPI) => { console.log('✅ Spotify Embed JS: API Ready.'); window.IFrameAPI = IFrameAPI; if (window.webkit?.messageHandlers?.spotifyController) { window.webkit.messageHandlers.spotifyController.postMessage("ready"); } else { console.error('❌ Spotify Embed JS: Native message handler not found!'); } }; const scriptTag = document.querySelector('script[src*="iframe-api"]'); if (scriptTag) { scriptTag.onerror = (event) => { console.error('❌ Spotify Embed JS: Failed to load API script:', event); window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'Failed to load Spotify API script' }}); }; } else { console.warn('⚠️ Spotify Embed JS: Could not find API script tag.'); } </script></body></html>
        """
    }
}

// MARK: - API Service (Unchanged, uses placeholder token)

// IMPORTANT: Replace this with your actual Spotify Bearer Token
let placeholderSpotifyToken = "YOUR_SPOTIFY_BEARER_TOKEN_HERE"

enum SpotifyAPIError: Error, LocalizedError { /* ... Enum cases ... */
    case invalidURL
    case networkError(Error)
    case invalidResponse(Int, String?)
    case decodingError(Error)
    case invalidToken
    case missingData
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid API URL."
        case .networkError(let error): return "Network error: \(error.localizedDescription)"
        case .invalidResponse(let code, _): return "Invalid server response (\(code))."
        case .decodingError(let error): return "Failed to decode response: \(error.localizedDescription)"
        case .invalidToken: return "Invalid or expired Spotify token."
        case .missingData: return "Missing data in API response."
        }
    }
}
struct SpotifyAPIService { /* ... Singleton, makeRequest, searchAlbums, getAlbumTracks ... */
    static let shared = SpotifyAPIService()
    private let session: URLSession
    
    init() {
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        session = URLSession(configuration: configuration)
    }
    
    private func makeRequest<T: Decodable>(url: URL) async throws -> T {
        guard !placeholderSpotifyToken.isEmpty, placeholderSpotifyToken != "YOUR_SPOTIFY_BEARER_TOKEN_HERE" else {
            print("❌ Error: Spotify Bearer Token is missing or placeholder.")
            throw SpotifyAPIError.invalidToken
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(placeholderSpotifyToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 20
        
        print("🚀 Making API Request to: \(url.absoluteString)") // DEBUG
        
        do {
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else { throw SpotifyAPIError.invalidResponse(0, "Not HTTP response.") }
            
            print("🚦 HTTP Status: \(httpResponse.statusCode)") // DEBUG
            let responseBody = String(data: data, encoding: .utf8)
            
            guard (200...299).contains(httpResponse.statusCode) else {
                if httpResponse.statusCode == 401 { throw SpotifyAPIError.invalidToken }
                // Add other specific error handling (404, 429 etc.) if needed
                print("❌ Server Error Body: \(responseBody ?? "N/A")")
                throw SpotifyAPIError.invalidResponse(httpResponse.statusCode, responseBody)
            }
            do {
                let decoder = JSONDecoder()
                return try decoder.decode(T.self, from: data)
            } catch {
                print("❌ Error: Failed to decode JSON for \(T.self).")
                // More detailed decoding error logging can be helpful here (see previous example)
                throw SpotifyAPIError.decodingError(error)
            }
        } catch let error where !(error is CancellationError) {
            print("❌ Error: Network request failed - \(error)")
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

// MARK: - SwiftUI Views

// MARK: - Main List View (Themed)
struct SpotifyAlbumListView: View {
    @State private var searchQuery: String = ""
    @State private var displayedAlbums: [AlbumItem] = []
    @State private var isLoading: Bool = false
    @State private var searchInfo: Albums? = nil
    @State private var currentError: SpotifyAPIError? = nil
    
    var body: some View {
        NavigationView {
            ZStack {
                // --- Retro Background ---
                retroDeepPurple.ignoresSafeArea() // Extend background
                
                // --- Conditional Content ---
                //                Group {
                if isLoading && displayedAlbums.isEmpty {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: retroNeonCyan))
                        .scaleEffect(1.5)
                        .padding(.bottom, 50) // Offset from center
                } else if let error = currentError {
                    ErrorPlaceholderView(error: error) {
                        Task { await performDebouncedSearch() }
                    }
                } else if displayedAlbums.isEmpty {
                    EmptyStatePlaceholderView(searchQuery: searchQuery)
                } else {
                    albumList // Themed list content
                }
                //                }
                //                .frame(maxWidth: .infinity, maxHeight: .infinity)
                //                .transition(.opacity.animation(.easeInOut(duration: 0.4)))
                //
                // --- Ongoing Loading Overlay (Themed) ---
                if isLoading && !displayedAlbums.isEmpty {
                    VStack {
                        HStack {
                            Spacer()
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: retroNeonLime))
                                .padding(.trailing, 5)
                            Text("Loading...")
                                .font(retroFont(size: 12, weight: .bold))
                                .foregroundColor(retroNeonLime)
                            Spacer()
                        }
                        .padding(.vertical, 6)
                        .padding(.horizontal, 15)
                        .background(.black.opacity(0.6), in: Capsule())
                        .overlay(Capsule().stroke(retroNeonLime.opacity(0.5), lineWidth: 1))
                        .shadow(color: retroNeonLime, radius: 5)
                        .padding(.top, 8)
                        Spacer()
                    }
                    .transition(.opacity.animation(.easeInOut))
                }
                
            } // End ZStack
            .navigationTitle("Retro Spotify Search")
            .navigationBarTitleDisplayMode(.inline)
            // --- Themed Navigation Bar ---
            .toolbarBackground(retroDeepPurple.opacity(0.8), for: .navigationBar) // Translucent retro bg
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar) // Ensures white title/buttons
            
            // --- Search Bar (System Default - harder to theme deeply) ---
            .searchable(text: $searchQuery,
                        placement: .navigationBarDrawer(displayMode: .always),
                        prompt: Text("Search Albums / Artists").foregroundColor(.gray))
            .onSubmit(of: .search) { Task { await performDebouncedSearch(immediate: true) } }
            .task(id: searchQuery) { await performDebouncedSearch() }
            .onChange(of: searchQuery) { if currentError != nil { currentError = nil } }
            .accentColor(retroNeonPink) // Tint cursor/cancel button if possible
            
        } // End NavigationView
        // Apply accent color to the whole view for potential global tinting
        .accentColor(retroNeonPink)
    }
    
    // --- Themed Album List ---
    private var albumList: some View {
        List {
            // --- Themed Metadata Header ---
            if let info = searchInfo, info.total > 0 { // Only show if results exist
                SearchMetadataHeader(totalResults: info.total, limit: info.limit, offset: info.offset)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 5, trailing: 0))
                    .listRowBackground(Color.clear) // Ensure row is transparent
            }
            
            // --- Album Cards ---
            ForEach(displayedAlbums) { album in
                NavigationLink(destination: AlbumDetailView(album: album)) {
                    RetroAlbumCard(album: album) // Use the themed card
                        .padding(.vertical, 8) // Space between cards
                }
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets()) // Remove default padding
                .listRowBackground(Color.clear) // Make row transparent
            }
        }
        .listStyle(PlainListStyle())
        .background(Color.clear) // Make List background transparent
        .scrollContentBackground(.hidden) // Essential for background color to show
    }
    
    // --- Debounced Search Logic (Unchanged) ---
    private func performDebouncedSearch(immediate: Bool = false) async { /* ... */
        let trimmedQuery = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else {
            await MainActor.run { displayedAlbums = []; searchInfo = nil; isLoading = false; currentError = nil }
            return
        }
        if !immediate {
            do { try await Task.sleep(for: .milliseconds(600)); try Task.checkCancellation() } // Increased debounce slightly
            catch { print("Search task cancelled (debounce)."); return }
        }
        await MainActor.run { isLoading = true }
        do {
            let response = try await SpotifyAPIService.shared.searchAlbums(query: trimmedQuery, offset: 0)
            try Task.checkCancellation()
            await MainActor.run {
                displayedAlbums = response.albums.items
                searchInfo = response.albums
                currentError = nil
                isLoading = false
            }
        } catch is CancellationError {
            print("Search task cancelled.")
            await MainActor.run { isLoading = false }
        } catch let apiError as SpotifyAPIError {
            print("❌ API Error: \(apiError.localizedDescription)")
            await MainActor.run { displayedAlbums = []; searchInfo = nil; currentError = apiError; isLoading = false }
        } catch {
            print("❌ Unexpected Error: \(error.localizedDescription)")
            await MainActor.run { displayedAlbums = []; searchInfo = nil; currentError = .networkError(error); isLoading = false }
        }
    }
}

// MARK: - Retro Album Card (Themed)
struct RetroAlbumCard: View {
    let album: AlbumItem
    
    var body: some View {
        ZStack {
            // Shiny background with gradient and subtle noise/texture? (Optional advanced)
            LinearGradient(
                gradient: Gradient(colors: retroGradients.shuffled()), // Shuffle for variety?
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            // Inner content blurred background (frosted glass effect)
            .overlay(.ultraThinMaterial) // Can remove if too busy
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            // Neon outline
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(retroNeonCyan.opacity(0.7), lineWidth: 1.5) // Use a consistent neon color
            )
            .neonGlow(retroNeonCyan, radius: 10) // Apply glow to the shape
            .padding(.horizontal, 5) // Padding around the card itself
            
            // --- Content ---
            HStack(spacing: 15) {
                // --- Album Art ---
                AlbumImageView(url: album.listImageURL)
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(LinearGradient(colors: [retroNeonPink.opacity(0.5), retroNeonCyan.opacity(0.5)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1))
                    .shadow(color: .black, radius: 5, y: 3) // Standard shadow for depth
                
                // --- Text Details ---
                VStack(alignment: .leading, spacing: 5) {
                    Text(album.name)
                        .font(retroFont(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(2)
                    
                    Text(album.formattedArtists)
                        .font(retroFont(size: 14, weight: .regular))
                        .foregroundColor(retroNeonLime.opacity(0.9)) // Accent color for artist
                        .lineLimit(1)
                    
                    Spacer() // Push bottom info down
                    
                    HStack {
                        Label(album.album_type.capitalized, systemImage: "rectangle.stack.fill")
                            .font(retroFont(size: 11, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(.white.opacity(0.1), in: Capsule())
                        
                        Text("•")
                            .foregroundColor(.white.opacity(0.5))
                        
                        Text(album.formattedReleaseDate())
                            .font(retroFont(size: 11, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    Text("\(album.total_tracks) Tracks")
                        .font(retroFont(size: 11, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.top, 1)
                    
                } // End Text VStack
                .frame(maxWidth: .infinity, alignment: .leading) // Allow text to take space
                
            } // End HStack
            .padding(15) // Padding inside the card
            
        } // End ZStack
        .frame(height: 130) // Fixed height for list consistency
    }
}

// MARK: - Themed Placeholders (Similar to previous versions, but themed)

struct ErrorPlaceholderView: View {
    let error: SpotifyAPIError
    let retryAction: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: iconName)
                .font(.system(size: 60))
                .foregroundColor(retroNeonPink) // Error color
                .neonGlow(retroNeonPink, radius: 15)
            
            Text("ERROR") // Retro error text
                .font(retroFont(size: 24, weight: .heavy))
                .foregroundColor(.white)
                .tracking(3) // Add character spacing
            
            Text(errorMessage)
                .font(retroFont(size: 14))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
            
            switch error {
            case .invalidToken:
                Text("Check API Token in Code")
                    .font(retroFont(size: 14))
                    .foregroundColor(retroNeonPink.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
            default:
                Button("RETRY") {
                    Text("RETRY")
                        .font(retroFont(size: 16, weight: .bold))
                        .padding(.horizontal, 30)
                        .padding(.vertical, 10)
                        .background(LinearGradient(colors: [retroNeonPink, .orange], startPoint: .leading, endPoint: .trailing))
                        .foregroundColor(retroDeepPurple)
                        .clipShape(Capsule())
                        .neonGlow(.orange, radius: 10)
                }
            }
        }
        .padding(30)
        //         .background(.black.opacity(0.4).blur(radius: 10)) // Optional blurred background
        .cornerRadius(20)
        .padding(20) // Padding around the whole error view
    }
    
    private var iconName: String { /* ... Logic from previous ... */
        switch error {
        case .invalidToken: return "key.slash.fill" // Use filled icon
        case .networkError: return "wifi.slash"
        case .invalidResponse, .decodingError, .missingData: return "exclamationmark.triangle.fill"
        case .invalidURL: return "link.icloud.fill"
        }
    }
    private var errorMessage: String { /* ... Logic from previous ... */
        switch error {
        case .invalidToken: return "AUTH FAILED. Spotify Token Invalid/Expired."
        case .networkError: return "CONNECTION LOST. Check Internet."
        case .invalidResponse(let code, _): return "SERVER ERROR (\(code)). Try Again Later."
        case .decodingError: return "DATA CORRUPT. Failed to read response."
        default: return error.localizedDescription // Fallback
        }
    }
}

struct EmptyStatePlaceholderView: View {
    let searchQuery: String
    
    var body: some View {
        VStack(spacing: 20) {
            // Use the meme Images as planned
            Image(iconName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 150) // Adjust size as needed
            // Add a subtle glow to the image too
                .shadow(color: isInitialState ? retroNeonCyan.opacity(0.5) : retroNeonPink.opacity(0.5), radius: 10)
                .padding(.bottom, 10)
            
            Text(title)
                .font(retroFont(size: 22, weight: .bold))
                .foregroundColor(.white)
            
            // Use AttributedString for potential bolding/styling
            Text(messageAttributedString)
                .font(retroFont(size: 14))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
        }
        .padding(30)
    }
    
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
        message.font = retroFont(size: 14)
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
            // --- Retro Background ---
            retroDeepPurple.ignoresSafeArea()
            // Optional: Add subtle background pattern/noise
            // Image("retro_grid_background").resizable().scaledToFill().opacity(0.1).ignoresSafeArea()
            
            List {
                // --- Header Section ---
                Section { AlbumHeaderView(album: album) }
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                
                // --- Player Section (Themed) ---
                if let uriToPlay = selectedTrackUri {
                    Section { SpotifyEmbedPlayerView(playbackState: playbackState, spotifyUri: uriToPlay) }
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 15, leading: 0, bottom: 15, trailing: 0))
                        .listRowBackground(Color.clear)
                        .transition(.opacity.combined(with: .scale(scale: 0.95, anchor: .top)).animation(.easeInOut(duration: 0.4)))
                }
                
                // --- Tracks Section (Themed) ---
                Section {
                    TracksSectionView(
                        tracks: tracks, isLoading: isLoadingTracks, error: trackFetchError,
                        selectedTrackUri: $selectedTrackUri,
                        retryAction: { Task { await fetchTracks() } }
                    )
                } header: {
                    Text("TRACK LIST") // Retro header style
                        .font(retroFont(size: 14, weight: .bold))
                        .foregroundColor(retroNeonLime)
                        .tracking(2)
                        .frame(maxWidth: .infinity, alignment: .center) // Center header
                        .padding(.vertical, 8)
                        .background(.black.opacity(0.3)) // Subtle background for header
                }
                .listRowInsets(EdgeInsets()) // Remove insets for tracks section
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                
                // --- External Link Section (Themed) ---
                if let spotifyURL = URL(string: album.external_urls.spotify ?? "") {
                    Section { ExternalLinkButton(url: spotifyURL, primaryColor: retroNeonLime, secondaryColor: .green) } // Use themed button
                        .listRowInsets(EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                }
                
            } // End List
            .listStyle(PlainListStyle())
            .scrollContentBackground(.hidden) // Allow ZStack background to show
        } // End ZStack
        .navigationTitle(album.name)
        .navigationBarTitleDisplayMode(.inline)
        // Match nav bar theme from List view
        .toolbarBackground(retroDeepPurple.opacity(0.8), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar) // Consistent dark theme for nav bar
        .task { await fetchTracks() }
        .animation(.easeInOut, value: selectedTrackUri) // Animate player appearance/track selection
        .refreshable { await fetchTracks(forceReload: true) }
    }
    
    // --- Fetch Tracks Logic (Unchanged) ---
    private func fetchTracks(forceReload: Bool = false) async { /* ... */
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
        VStack(spacing: 15) {
            AlbumImageView(url: album.bestImageURL)
                .aspectRatio(1.0, contentMode: .fit) // Keep square
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .overlay(RoundedRectangle(cornerRadius: 15).stroke(LinearGradient(colors: [retroNeonPink.opacity(0.6), retroNeonCyan.opacity(0.6)], startPoint: .top, endPoint: .bottom), lineWidth: 2))
                .neonGlow(retroNeonCyan, radius: 15) // Glow effect on album art
                .padding(.horizontal, 50)
            
            VStack(spacing: 5) {
                Text(album.name)
                    .font(retroFont(size: 22, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .shadow(color: .black.opacity(0.5), radius: 2, y: 1) // Text shadow
                
                Text("by \(album.formattedArtists)")
                    .font(retroFont(size: 16, weight: .regular))
                    .foregroundColor(retroNeonLime) // Artist accent color
                    .multilineTextAlignment(.center)
                
                Text("\(album.album_type.capitalized) • \(album.formattedReleaseDate())")
                    .font(retroFont(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(.horizontal)
            
        }
        .padding(.vertical, 25)
    }
}

struct SpotifyEmbedPlayerView: View {
    @ObservedObject var playbackState: SpotifyPlaybackState
    let spotifyUri: String
    
    var body: some View {
        VStack(spacing: 8) { // Added spacing
            SpotifyEmbedWebView(playbackState: playbackState, spotifyUri: spotifyUri)
                .frame(height: 85) // Standard embed height + buffer
            // Custom Player Frame/Background
                .background(
                    LinearGradient(colors: [.black.opacity(0.5), .black.opacity(0.2)], startPoint: .top, endPoint: .bottom)
                        .overlay(.ultraThinMaterial) // Frosted glass
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(LinearGradient(colors: [retroNeonCyan.opacity(0.4), retroNeonPink.opacity(0.4)], startPoint: .leading, endPoint: .trailing), lineWidth: 1))
                        .neonGlow(playbackState.isPlaying ? retroNeonLime : retroNeonPink, radius: 8) // Dynamic glow based on state
                )
                .padding(.horizontal)
            
            // --- Themed Playback Status ---
            HStack {
                let statusText = playbackState.isPlaying ? "PLAYING" : "PAUSED"
                let statusColor = playbackState.isPlaying ? retroNeonLime : retroNeonPink
                
                Text(statusText)
                    .font(retroFont(size: 10, weight: .bold))
                    .foregroundColor(statusColor)
                    .tracking(1.5) // Add letter spacing
                    .neonGlow(statusColor, radius: 4)
                    .lineLimit(1)
                    .frame(width: 80, alignment: .leading) // Fixed width for status
                
                Spacer()
                
                if playbackState.duration > 0.1 { // Only show if duration is valid
                    Text("\(formatTime(playbackState.currentPosition)) | \(formatTime(playbackState.duration))")
                        .font(retroFont(size: 11, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                } else {
                    Text("--:-- | --:--") // Placeholder time
                        .font(retroFont(size: 11, weight: .medium))
                        .foregroundColor(.white.opacity(0.5))
                }
            }
            .padding(.horizontal, 25) // Align with player padding
            .padding(.top, 5)
            .frame(minHeight: 15)
            
        } // End VStack
        .animation(.easeInOut, value: playbackState.isPlaying) // Animate glow color change
    }
    
    private func formatTime(_ time: Double) -> String { /* ... Unchanged ... */
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
    //        Group { // Use Group to apply padding once if needed
    //            if isLoading {
    //                 HStack {
    //                    Spacer()
    //                     ProgressView().tint(retroNeonCyan)
    //                     Text("Loading Tracks...")
    //                        .font(retroFont(size: 14))
    //                        .foregroundColor(retroNeonCyan)
    //                        .padding(.leading, 8)
    //                    Spacer()
    //                }
    //                .padding(.vertical, 25)
    //            } else if let error = error {
    //                ErrorPlaceholderView(error: error, retryAction: retryAction)
    //                     .padding(.vertical, 25) // Add padding around error view
    //            } else if tracks.isEmpty {
    //                Text("Track Information Unavailable")
    //                    .font(retroFont(size: 14))
    //                    .foregroundColor(.white.opacity(0.6))
    //                    .frame(maxWidth: .infinity, alignment: .center)
    //                    .padding(.vertical, 25)
    //            } else {
    //                // Track rows directly in the section
    //                 ForEach(tracks) { track in
    //                     TrackRowView(track: track, isSelected: track.uri == selectedTrackUri)
    //                         .contentShape(Rectangle())
    //                         .onTapGesture {
    //                             selectedTrackUri = track.uri
    //                         }
    //                         // Themed selection background
    //                          .listRowBackground(
    //                             track.uri == selectedTrackUri
    //                              ? LinearGradient(colors: [retroNeonCyan.opacity(0.2), retroNeonPink.opacity(0.2), .clear], startPoint: .leading, endPoint: .trailing)
    //                                 .blur(radius: 5) // Soft blurred background highlight
    //                              : Color.clear
    //                          )
    //                }
    //            }
    //        }
    //         // Apply common modifiers to the Group if needed, e.g., .padding(.horizontal)
    //    }
}

struct TrackRowView: View {
    let track: Track
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            // --- Track Number ---
            Text("\(track.track_number)")
                .font(retroFont(size: 12, weight: .medium))
                .foregroundColor(isSelected ? retroNeonLime : .white.opacity(0.6))
                .frame(width: 25, alignment: .center)
                .padding(.leading, 10) // Ensure space from edge
            
            // --- Track Info ---
            VStack(alignment: .leading, spacing: 3) {
                Text(track.name)
                    .font(retroFont(size: 15, weight: isSelected ? .bold : .regular)) // Bold selected track
                    .foregroundColor(isSelected ? retroNeonCyan : .white)
                    .lineLimit(1)
                
                Text(track.formattedArtists)
                    .font(retroFont(size: 11))
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(1)
            }
            
            Spacer()
            
            // --- Duration ---
            Text(track.formattedDuration)
                .font(retroFont(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
                .padding(.trailing, 5)
            
            // --- Play Indicator ---
            Image(systemName: isSelected ? "waveform.path.ecg" : "play.fill") // More fitting icons
                .foregroundColor(isSelected ? retroNeonCyan : .white.opacity(0.7))
                .font(.body) // Adjust size slightly
                .frame(width: 25, height: 25)
                .animation(.easeInOut(duration: 0.2), value: isSelected)
                .padding(.trailing, 10)
            
        }
        .padding(.vertical, 12) // Increase vertical padding for tap target
        // Remove internal horizontal padding, let parent list handle row padding
        // .padding(.horizontal) NO - causes misalignment if rowBackground is used
    }
}

// MARK: - Other Supporting Views (Themed)

struct AlbumImageView: View { // Unchanged fundamentally, uses AsyncImage
    let url: URL?
    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
                ZStack {
                    // Themed placeholder background
                    RoundedRectangle(cornerRadius: 8).fill(LinearGradient(colors: [.gray.opacity(0.2), .black.opacity(0.3)], startPoint: .top, endPoint: .bottom))
                    ProgressView().tint(retroNeonCyan)
                }
            case .success(let image):
                image.resizable().scaledToFit()
            case .failure:
                ZStack {
                    RoundedRectangle(cornerRadius: 8).fill(LinearGradient(colors: [.gray.opacity(0.2), .black.opacity(0.3)], startPoint: .top, endPoint: .bottom))
                    Image(systemName: "photo.fill") // Keep system icon
                        .resizable().scaledToFit()
                        .foregroundColor(retroNeonPink.opacity(0.5))
                        .padding(10)
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
        HStack {
            Text("FOUND: \(totalResults)") // Retro style
            Spacer()
            if totalResults > limit {
                Text("VIEW: \(offset + 1)-\(min(offset + limit, totalResults))")
            }
        }
        .font(retroFont(size: 10, weight: .bold))
        .foregroundColor(retroNeonLime.opacity(0.8))
        .tracking(1) // Letter spacing
        .padding(.horizontal, 15) // Consistent padding
        .padding(.bottom, 5)
    }
}

// Generic Themed Button (Replaces ExternalLinkButton for consistency)
struct RetroButton: View {
    let text: String
    let action: () -> Void
    var primaryColor: Color = retroNeonPink
    var secondaryColor: Color = .purple // For gradient
    var iconName: String? = nil
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let iconName = iconName {
                    Image(systemName: iconName)
                }
                Text(text)
                    .tracking(1.5) // Letter spacing
            }
            .font(retroFont(size: 15, weight: .bold))
            .padding(.horizontal, 25)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity) // Make button expand
            .background(LinearGradient(colors: [primaryColor, secondaryColor], startPoint: .leading, endPoint: .trailing))
            .foregroundColor(retroDeepPurple) // Dark text on bright button
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Color.white.opacity(0.5), lineWidth: 1)) // Subtle white edge
            .neonGlow(primaryColor, radius: 12)
        }
        .buttonStyle(.plain) // Ensure custom background/foreground work
    }
}

// Re-implementation of ExternalLinkButton using RetroButton
struct ExternalLinkButton: View {
    let text: String = "OPEN IN SPOTIFY" // Default text
    let url: URL
    var primaryColor: Color = retroNeonLime
    var secondaryColor: Color = .green // Spotify Green gradient end
    var iconName: String? = "arrow.up.forward.app.fill" // More appropriate icon
    
    @Environment(\.openURL) var openURL
    
    var body: some View {
        RetroButton(
            text: text,
            action: {
                print("Attempting to open external URL: \(url)")
                openURL(url) { accepted in
                    if !accepted {
                        print("⚠️ Warning: URL scheme \(url.scheme ?? "") could not be opened.")
                        // Consider showing user an alert here
                    }
                }
            },
            primaryColor: primaryColor,
            secondaryColor: secondaryColor,
            iconName: iconName
        )
    }
}

// MARK: - Preview Providers (Updated for Themed Views)

struct SpotifyAlbumListView_Previews: PreviewProvider {
    static var previews: some View {
        SpotifyAlbumListView()
            .preferredColorScheme(.dark) // Preview in dark mode
    }
}

struct RetroAlbumCard_Previews: PreviewProvider {
    // Reusing mock data from previous previews
    static let mockArtist = Artist(id: "artist1", external_urls: nil, href: "", name: "Miles Davis Mock", type: "artist", uri: "")
    static let mockImage = SpotifyImage(height: 300, url: "https://i.scdn.co/image/ab67616d00001e027ab89c25093ea3787b1995b4", width: 300) // Use 300px image
    static let mockAlbumItem = AlbumItem(id: "album1", album_type: "album", total_tracks: 5, available_markets: ["US"], external_urls: ExternalUrls(spotify: ""), href: "", images: [mockImage], name: "Kind of Blue [PREVIEW]", release_date: "1959-08-17", release_date_precision: "day", type: "album", uri: "spotify:album:1weenld61qoidwYuZ1GESA", artists: [mockArtist])
    
    static var previews: some View {
        RetroAlbumCard(album: mockAlbumItem)
            .padding()
            .background(retroDeepPurple)
            .previewLayout(.fixed(width: 400, height: 180))
            .preferredColorScheme(.dark)
        
    }
}

struct AlbumDetailView_Previews: PreviewProvider {
    static let mockArtist = Artist(id: "artist1", external_urls: nil, href: "", name: "Miles Davis Mock", type: "artist", uri: "")
    // Use 640px image for detail view
    static let mockImage = SpotifyImage(height: 640, url: "https://i.scdn.co/image/ab67616d0000b2737ab89c25093ea3787b1995b4", width: 640)
    static let mockAlbum = AlbumItem(id: "1weenld61qoidwYuZ1GESA", album_type: "album", total_tracks: 5, available_markets: ["US", "GB"], external_urls: ExternalUrls(spotify: "https://open.spotify.com/album/1weenld61qoidwYuZ1GESA"), href: "", images: [mockImage], name: "Kind Of Blue (Preview)", release_date: "1959-08-17", release_date_precision: "day", type: "album", uri: "spotify:album:1weenld61qoidwYuZ1GESA", artists: [mockArtist])
    
    static var previews: some View {
        NavigationView { // Wrap in NavigationView for realistic preview
            AlbumDetailView(album: mockAlbum)
        }
        .preferredColorScheme(.dark) // Essential for retro theme
    }
}

// MARK: - App Entry Point

@main
struct SpotifyEmbedIntegrationApp: App {
    init() {
        // --- Token Check ---
        if placeholderSpotifyToken == "YOUR_SPOTIFY_BEARER_TOKEN_HERE" {
            print("🚨🎬 FATAL STARTUP WARNING: Spotify Bearer Token is not set! API calls WILL FAIL.")
            print("👉 FIX: Replace 'YOUR_SPOTIFY_BEARER_TOKEN_HERE' in SpotifyRetroApp.swift with a valid token.")
            // Note: In a real app, you'd have a proper login flow or secure token storage.
        }
        
        // --- Global UI Appearance (Optional) ---
        // You could set global navigation bar appearance here if desired,
        // but we're doing it directly in the views for more control.
        // Example:
        /*
         let appearance = UINavigationBarAppearance()
         appearance.configureWithOpaqueBackground()
         appearance.backgroundColor = UIColor(retroDeepPurple.opacity(0.8)) // Convert SwiftUI Color
         appearance.titleTextAttributes = [.foregroundColor: UIColor.white, .font: UIFont.monospacedSystemFont(ofSize: 18, weight: .bold)]
         appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white, .font: UIFont.monospacedSystemFont(ofSize: 30, weight: .bold)]
         UINavigationBar.appearance().standardAppearance = appearance
         UINavigationBar.appearance().scrollEdgeAppearance = appearance
         UINavigationBar.appearance().compactAppearance = appearance
         UINavigationBar.appearance().tintColor = UIColor(retroNeonPink) // Back button color etc.
         */
    }
    
    var body: some Scene {
        WindowGroup {
            SpotifyAlbumListView() // Start with the themed list view
                .preferredColorScheme(.dark) // Force dark scheme for the retro theme
        }
    }
}
