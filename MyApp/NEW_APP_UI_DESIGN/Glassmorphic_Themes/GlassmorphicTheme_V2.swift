//
//  GlassmorphicTheme_V2.swift
//  MyApp
//
//  Created by Cong Le on 4/19/25.
//


// Note: Ensure you replace the placeholder API token below.

import SwiftUI
@preconcurrency import WebKit // For Spotify Embed WebView
import Foundation // For Codable, URL, etc.

// MARK: - Glassmorphism Theme Constants & Helpers

struct GlassmorphismTheme {
    // Define a background that allows the blur to show through
    static let backgroundGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0.1, green: 0.0, blue: 0.3), // Deep Purple
            Color(red: 0.3, green: 0.1, blue: 0.4), // Mid Magenta
            Color(red: 0.0, green: 0.2, blue: 0.4)  // Dark Blue
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // Frost Effect - Material provides adaptive blur
    static let frostMaterial: Material = .ultraThinMaterial // Choose thin/thick/regular
    // static let frostColor = Color.white.opacity(0.10) // Alternative: Manual color + blur
    static let frostBlurRadius: CGFloat = 18 // Adjust blur intensity
    
    // Subtle border to define edges
    static let borderColor = Color.white.opacity(0.3)
    static let borderWidth: CGFloat = 1
    
    // Soft shadow for depth
    static let shadowColor = Color.black.opacity(0.15)
    static let shadowRadius: CGFloat = 8
    static let shadowOffsetY: CGFloat = 4 // Primarily vertical shadow
    
    // Consistent corner radius
    static let cornerRadius: CGFloat = 20

    // Text & Accent Colors - Ensure good contrast over blurred background
    static let primaryText = Color.white.opacity(0.95)
    static let secondaryText = Color.white.opacity(0.7)
    static let accentColor = Color(hue: 0.55, saturation: 0.8, brightness: 0.9) // Vibrant Cyan/Blue
    static let errorColor = Color(hue: 0.0, saturation: 0.7, brightness: 0.9)   // Clear Red
    
}

// Font helper (using system fonts for simplicity)
func themedFont(size: CGFloat, weight: Font.Weight = .regular, design: Font.Design = .default) -> Font {
    return Font.system(size: size, weight: weight, design: design)
}

// MARK: - Glassmorphic View Modifier

struct GlassmorphicBackground: ViewModifier {
    var cornerRadius: CGFloat = GlassmorphismTheme.cornerRadius
    
    func body(content: Content) -> some View {
        content
            .background(GlassmorphismTheme.frostMaterial) // Apply material background
            // Or use manual color: .background(GlassmorphismTheme.frostColor)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay( // Add the subtle border
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(GlassmorphismTheme.borderColor, lineWidth: GlassmorphismTheme.borderWidth)
            )
            .shadow( // Add the soft shadow
                color: GlassmorphismTheme.shadowColor,
                radius: GlassmorphismTheme.shadowRadius,
                x: 0,
                y: GlassmorphismTheme.shadowOffsetY
            )
    }
}

// MARK: - Glassmorphic Button Style

struct GlassmorphicButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, 12)
            .padding(.horizontal, 20)
            .background( // Apply Glassmorphism to the button background
                // Slightly change effect on press (optional)
                GlassmorphismTheme.frostMaterial
                    .opacity(configuration.isPressed ? 0.9 : 1.0)
                    // Or manual color: GlassmorphismTheme.frostColor.opacity(configuration.isPressed ? 0.3 : 0.2)
            )
            .clipShape(RoundedRectangle(cornerRadius: GlassmorphismTheme.cornerRadius))
            .overlay( // Border
                RoundedRectangle(cornerRadius: GlassmorphismTheme.cornerRadius)
                    .stroke(GlassmorphismTheme.borderColor.opacity(configuration.isPressed ? 0.5 : 1.0), lineWidth: GlassmorphismTheme.borderWidth)
            )
            .shadow( // Shadow
                color: GlassmorphismTheme.shadowColor.opacity(configuration.isPressed ? 0.1 : 0.15),
                radius: GlassmorphismTheme.shadowRadius,
                x: 0,
                y: GlassmorphismTheme.shadowOffsetY
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0) // Subtle scale on press
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// MARK: - Data Models (Unchanged)

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
    let external_urls: ExternalUrls?
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
let placeholderSpotifyToken = "YOUR_SPOTIFY_BEARER_TOKEN_HERE" // <-- PASTE YOUR TOKEN HERE

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

// MARK: - Spotify Embed WebView (Ensure Transparency)

final class SpotifyPlaybackState: ObservableObject {
    @Published var isPlaying: Bool = false
    @Published var currentPosition: Double = 0
    @Published var duration: Double = 0
    @Published var currentUri: String = ""
    @Published var isReady: Bool = false
    @Published var error: String? = nil
}

struct SpotifyEmbedWebView: UIViewRepresentable {
    @ObservedObject var playbackState: SpotifyPlaybackState
    let spotifyUri: String?
    
    func makeCoordinator() -> Coordinator { Coordinator(self) }
    
    func makeUIView(context: Context) -> WKWebView {
        let userContentController = WKUserContentController()
        userContentController.add(context.coordinator, name: "spotifyController")
        
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = userContentController
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        
        // --- Crucial for Glassmorphism ---
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        // --- End Crucial ---
        
        webView.scrollView.isScrollEnabled = false // Keep disabled
        webView.loadHTMLString(generateHTML(), baseURL: nil)
        context.coordinator.webView = webView
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        if context.coordinator.isApiReady && context.coordinator.lastLoadedUri != spotifyUri {
            context.coordinator.loadUri(spotifyUri ?? "")
        } else if !context.coordinator.isApiReady {
            context.coordinator.updateDesiredUriBeforeReady(spotifyUri ?? "")
        }
    }
    
    static func dismantleUIView(_ webView: WKWebView, coordinator: Coordinator) {
        webView.stopLoading()
        webView.configuration.userContentController.removeScriptMessageHandler(forName: "spotifyController")
        coordinator.webView = nil
    }
    
    // --- Coordinator Class (Mostly Unchanged from previous - only logging adjusted) ---
    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
        var parent: SpotifyEmbedWebView
        weak var webView: WKWebView?
        var isApiReady = false
        var lastLoadedUri: String?
        private var desiredUriBeforeReady: String? = nil
        
        init(_ parent: SpotifyEmbedWebView) { self.parent = parent }
        
        func updateDesiredUriBeforeReady(_ uri: String?) {
            if !isApiReady { desiredUriBeforeReady = uri }
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) { print("📄 Spotify Embed WebView: HTML finished.") }
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error){ print("❌ EmbedWV Fail: \(error)") }
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) { print("❌ EmbedWV Provisional Fail: \(error)") }
        
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            guard message.name == "spotifyController" else { return }
            if let bodyDict = message.body as? [String: Any], let event = bodyDict["event"] as? String { handleEvent(event: event, data: bodyDict["data"]) }
            else if let bodyString = message.body as? String { if bodyString == "ready" { handleApiReady() } }
            else { print("❓ EmbedWV Unknown JS message: \(message.body)") }
        }
        
        private func handleApiReady() {
            print("✅ EmbedWV: Spotify API READY.")
            isApiReady = true
            DispatchQueue.main.async { self.parent.playbackState.isReady = true }
            if let initialUri = desiredUriBeforeReady ?? parent.spotifyUri { createSpotifyController(with: initialUri); desiredUriBeforeReady = nil }
            else { print("⚠️ EmbedWV: API Ready, no initial URI.") }
        }
        
        private func handleEvent(event: String, data: Any?) {
            switch event {
            case "controllerCreated": print("✅ EmbedWV: Controller created.")
            case "playbackUpdate": if let updateData = data as? [String: Any] { updatePlaybackState(with: updateData) }
            case "error": let msg = (data as? [String: Any])?["message"] as? String ?? "JS Error"; print("❌ EmbedWV JS Error: \(msg)"); DispatchQueue.main.async { self.parent.playbackState.error = msg }
            default: print("❓ EmbedWV Unknown event: \(event)")
            }
        }
        
        private func updatePlaybackState(with data: [String: Any]) {
           DispatchQueue.main.async { [weak self] in
               guard let self = self else { return }
               var changed = false
               if let isPaused = data["paused"] as? Bool { if self.parent.playbackState.isPlaying == isPaused { self.parent.playbackState.isPlaying = !isPaused; changed = true }}
               if let pos = data["position"] as? Double { let newPos = pos/1000.0; if abs(self.parent.playbackState.currentPosition-newPos)>0.1 { self.parent.playbackState.currentPosition = newPos; changed = true }}
               if let dur = data["duration"] as? Double { let newDur = dur/1000.0; if abs(self.parent.playbackState.duration-newDur)>0.1 { self.parent.playbackState.duration = newDur; changed = true } }
               if let uri = data["uri"] as? String, self.parent.playbackState.currentUri != uri { self.parent.playbackState.currentUri = uri; self.parent.playbackState.currentPosition = 0; self.parent.playbackState.duration = data["duration"] as? Double ?? 0; changed = true }
               if changed && self.parent.playbackState.error != nil { self.parent.playbackState.error = nil }
           }
       }
        
        private func createSpotifyController(with initialUri: String) {
            guard let webView = webView, isApiReady else { return }
            guard lastLoadedUri == nil else { if let latest = desiredUriBeforeReady ?? parent.spotifyUri, latest != lastLoadedUri { print(" -> Correcting URI: \(latest)"); loadUri(latest) }; desiredUriBeforeReady = nil; return }
            print("🚀 EmbedWV: Creating controller: \(initialUri)")
            lastLoadedUri = initialUri
            let script = """
            window.embedController = null; const e = document.getElementById('embed-iframe');
            if(!e || !window.IFrameAPI) { console.error('JS Error: Element or API missing'); window.webkit?.messageHandlers?.spotifyController?.postMessage({event:'error',data:{message:!e ? 'Element missing':'API missing'}}); return; }
            const options = { uri: '\(initialUri)', width: '100%', height: '100%' };
            const cb = (c) => { if(!c){console.error('JS Error: Null controller');window.webkit?.messageHandlers?.spotifyController?.postMessage({event:'error',data:{message:'JS null controller'}});return;} window.embedController=c;window.webkit?.messageHandlers?.spotifyController?.postMessage({event:'controllerCreated'}); c.addListener('ready',()=>{});c.addListener('playback_update',e=>{window.webkit?.messageHandlers?.spotifyController?.postMessage({event:'playbackUpdate',data:e.data});}); c.addListener('error',e=>{console.error('💥 JS Error:',e.data);window.webkit?.messageHandlers?.spotifyController?.postMessage({event:'error',data:{message:(e.data?.message ?? 'Unknown JS Playback Error')}});}); };
            try { window.IFrameAPI.createController(e, options, cb); } catch(e) { console.error('💥 JS Exc:', e); window.webkit?.messageHandlers?.spotifyController?.postMessage({event:'error',data:{message:'JS Exc: '+e.message}}); lastLoadedUri=null; }
            """
            webView.evaluateJavaScript(script) { _, error in if let e = error { print("⚠️ EmbedWV Create JS Err: \(e)") } }
        }
        
        func loadUri(_ uri: String) {
            guard let webView = webView, isApiReady else { return }
            guard let currentUri = lastLoadedUri, currentUri != uri else { print("ℹ️ EmbedWV Skipping loadUri - same."); return }
            print("🚀 EmbedWV: Loading URI: \(uri)")
            lastLoadedUri = uri
            let script = "if(window.embedController){window.embedController.loadUri('\(uri)');window.embedController.play();}else{console.error('JS Error: No controller for loadUri');}"
            webView.evaluateJavaScript(script) { _, error in if let e = error { print("⚠️ EmbedWV Load JS Err: \(e)") } }
        }
        
        // JS Alert handler (optional but good practice)
        func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
           print("ℹ️ Spotify Embed JS Alert: \(message)")
           completionHandler()
       }
    }
    
    // --- Generate HTML (Unchanged) ---
    private func generateHTML() -> String {
        return """
        <!DOCTYPE html><html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no"><title>Spotify Embed</title><style>html, body { margin: 0; padding: 0; width: 100%; height: 100%; overflow: hidden; background-color: transparent; } #embed-iframe { width: 100%; height: 100%; box-sizing: border-box; display: block; border: none; }</style></head><body><div id="embed-iframe"></div><script src="https://open.spotify.com/embed/iframe-api/v1" async></script><script> console.log('Spotify Embed JS: Initial script running.'); var spotifyControllerCallbackIsSet = false; window.onSpotifyIframeApiReady = (IFrameAPI) => { if (spotifyControllerCallbackIsSet) return; console.log('✅ Spotify Embed JS: API Ready.'); window.IFrameAPI = IFrameAPI; spotifyControllerCallbackIsSet = true; if (window.webkit?.messageHandlers?.spotifyController) { window.webkit.messageHandlers.spotifyController.postMessage("ready"); } else { console.error('❌ JS: Native message handler (spotifyController) not found!'); } }; const scriptTag = document.querySelector('script[src*="iframe-api"]'); if (scriptTag) { scriptTag.onerror = (event) => { console.error('❌ JS: Failed to load Spotify API script:', event); window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'Failed to load Spotify API script' }}); }; } else { console.warn('⚠️ JS: Could not find API script tag.'); } </script></body></html>
        """
    }
}

// MARK: - SwiftUI Views (Glassmorphism Themed)

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
                // --- Glassmorphic Background ---
                GlassmorphismTheme.backgroundGradient.ignoresSafeArea()
                
                // --- Foreground Content ---
                VStack(spacing: 0) {
                    Group { // Grouping content for conditional logic
                        if isLoading && displayedAlbums.isEmpty {
                            loadingIndicator
                        } else if let error = currentError {
                            ErrorPlaceholderView(error: error) {
                                Task { await performDebouncedSearch(immediate: true) }
                            }
                        } else if displayedAlbums.isEmpty && !searchQuery.isEmpty {
                            EmptyStatePlaceholderView(searchQuery: searchQuery)
                        } else if displayedAlbums.isEmpty && searchQuery.isEmpty {
                            EmptyStatePlaceholderView(searchQuery: "") // Initial state
                        } else {
                            albumScrollView // Use ScrollView for glassmorphic list
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            } // End ZStack
            .navigationTitle("Spotify Search")
            .navigationBarTitleDisplayMode(.large)
             // --- Toolbar Theming ---
             .toolbarBackground(.visible, for: .navigationBar) // Make background area visible
             .toolbarBackground(GlassmorphismTheme.frostMaterial, for: .navigationBar) // Apply glass to toolbar
            .toolbarColorScheme(.dark, for: .navigationBar) // Ensure buttons/title are light
            
            // --- Search Bar ---
            .searchable(text: $searchQuery,
                        placement: .navigationBarDrawer(displayMode: .always),
                        prompt: Text("Search Albums / Artists").foregroundColor(GlassmorphismTheme.secondaryText))
            .onSubmit(of: .search) { Task { await performDebouncedSearch(immediate: true) } }
            .task(id: searchQuery) { await performDebouncedSearch() }
            .onChange(of: searchQuery) { if currentError != nil { currentError = nil } }
            .accentColor(GlassmorphismTheme.accentColor) // Search bar cursor/cancel
            
        } // End NavigationView
        .navigationViewStyle(.stack) // Consistent style
        .preferredColorScheme(.dark) // Maintain dark context for gradient/materials
    }
    
    // --- Themed Scrollable Album List ---
    private var albumScrollView: some View {
        ScrollView {
            LazyVStack(spacing: 18) { // Spacing between cards
                // --- Metadata Header (Simple Text) ---
                if let info = searchInfo, info.total > 0 {
                    SearchMetadataHeader(totalResults: info.total, limit: info.limit, offset: info.offset)
                        .padding(.horizontal, 25) // Align roughly with card content
                        .padding(.top, 5)
                }
                
                // --- Album Cards ---
                ForEach(displayedAlbums) { album in
                    NavigationLink(destination: AlbumDetailView(album: album)) {
                        GlassmorphicAlbumCard(album: album)
                    }
                    .buttonStyle(.plain) // Remove default link styling
                }
            }
            .padding(.horizontal) // Overall padding for the scroll content
            .padding(.bottom)
        }
        .scrollDismissesKeyboard(.interactively)
    }
    
    // --- Themed Loading Indicator ---
    private var loadingIndicator: some View {
        VStack {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: GlassmorphismTheme.accentColor))
                .scaleEffect(1.5)
            Text("Loading...")
                .font(themedFont(size: 14))
                .foregroundColor(GlassmorphismTheme.secondaryText)
                .padding(.top, 10)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity) // Center it
    }
    
    // --- Debounced Search Logic (Unchanged) ---
    private func performDebouncedSearch(immediate: Bool = false) async {
        let trimmedQuery = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else {
            Task { @MainActor in displayedAlbums = []; searchInfo = nil; isLoading = false; currentError = nil }
            return
        }
        Task { @MainActor in isLoading = true }
        if !immediate {
            do { try await Task.sleep(for: .milliseconds(500)); try Task.checkCancellation() } catch { print("Search cancelled."); Task { @MainActor in isLoading = false }; return }
        }
        guard trimmedQuery == searchQuery.trimmingCharacters(in: .whitespacesAndNewlines) else { Task { @MainActor in isLoading = false }; return }
        do {
            print("🚀 Performing search: \(trimmedQuery)")
            let response = try await SpotifyAPIService.shared.searchAlbums(query: trimmedQuery, limit: 20, offset: 0)
            try Task.checkCancellation()
            await MainActor.run { displayedAlbums = response.albums.items; searchInfo = response.albums; currentError = nil; isLoading = false; print("✅ \(response.albums.items.count) items.") }
        } catch is CancellationError { await MainActor.run { isLoading = false } } catch let apiError as SpotifyAPIError { await MainActor.run { displayedAlbums = []; searchInfo = nil; currentError = apiError; isLoading = false } } catch { await MainActor.run { displayedAlbums = []; searchInfo = nil; currentError = .networkError(error); isLoading = false } }
    }
}

// MARK: Glassmorphic Album Card
struct GlassmorphicAlbumCard: View {
    let album: AlbumItem
    
    var body: some View {
        HStack(spacing: 15) {
            // --- Album Art (Clear edge) ---
            AlbumImageView(url: album.listImageURL)
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 12)) // Slightly less rounded than card
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(GlassmorphismTheme.borderColor.opacity(0.5), lineWidth: 0.5)) // Optional subtle border on image

            // --- Text Details ---
            VStack(alignment: .leading, spacing: 4) {
                Text(album.name)
                    .font(themedFont(size: 15, weight: .semibold))
                    .foregroundColor(GlassmorphismTheme.primaryText)
                    .lineLimit(2)
                
                Text(album.formattedArtists)
                    .font(themedFont(size: 13))
                    .foregroundColor(GlassmorphismTheme.secondaryText)
                    .lineLimit(1)
                
                Spacer() // Push bottom info down
                
                // --- Tags and Date ---
                HStack(spacing: 8) {
                    Text(album.album_type.capitalized)
                        .font(themedFont(size: 10, weight: .medium))
                        .foregroundColor(GlassmorphismTheme.secondaryText)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        // Use a very subtle background for tag, slightly darker than frost
                         .background(Color.black.opacity(0.1), in: Capsule())
                         .overlay(Capsule().stroke(GlassmorphismTheme.borderColor.opacity(0.4), lineWidth: 0.5))
                     
                    Text("• \(album.formattedReleaseDate())")
                        .font(themedFont(size: 10, weight: .medium))
                        .foregroundColor(GlassmorphismTheme.secondaryText)
                }
                 Text("\(album.total_tracks) Tracks")
                         .font(themedFont(size: 10, weight: .medium))
                         .foregroundColor(GlassmorphismTheme.secondaryText)
                         .padding(.top, 1)

            } // End Text VStack
            .frame(maxWidth: .infinity, alignment: .leading)
            
        } // End HStack
        .padding(15) // Padding inside the card
        .modifier(GlassmorphicBackground()) // Apply the modifier here
        // .frame(height: 110) // Keep consistent height
    }
}

// MARK: Placeholders (Glassmorphic Themed)
struct ErrorPlaceholderView: View {
    let error: SpotifyAPIError
    let retryAction: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 20) {
            // --- Icon (Simple, Clear) ---
            Image(systemName: iconName)
                .font(.system(size: 50))
                .foregroundColor(GlassmorphismTheme.errorColor) // Use clear error color
                .padding(.bottom, 15)
            
            // --- Text ---
            Text("Error")
                .font(themedFont(size: 20, weight: .bold))
                .foregroundColor(GlassmorphismTheme.primaryText)
            
            Text(errorMessage)
                .font(themedFont(size: 14))
                .foregroundColor(GlassmorphismTheme.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
            
            // --- Retry Button (Themed) ---
            switch error {
            case .invalidToken:
                Text("Please check the API token in the code.")
                   .font(themedFont(size: 13))
                   .foregroundColor(GlassmorphismTheme.errorColor.opacity(0.8))
                   .multilineTextAlignment(.center)
                   .padding(.horizontal, 30)
            default:
                ThemedGlassmorphicButton(text: "Retry", iconName: "arrow.clockwise") { // Use themed button
                   retryAction?()
                }
                .padding(.top, 10)
            }
        }
        .padding(40) // Padding inside the placeholder
        .modifier(GlassmorphicBackground(cornerRadius: 25)) // Apply glass to the whole placeholder
    }
    
    // --- Helper properties --
    private var iconName: String { /* ... (same logic as before) ... */
         switch error { case .invalidToken: return "key.slash"; case .networkError: return "wifi.slash"; case .invalidResponse, .decodingError, .missingData: return "exclamationmark.triangle"; case .invalidURL: return "link.badge.questionmark" }
    }
    private var errorMessage: String { error.localizedDescription }
}

struct EmptyStatePlaceholderView: View {
    let searchQuery: String
    
    var body: some View {
        VStack(spacing: 20) {
            // --- Image (Simple) ---
            Image(placeholderImageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 130)
                .opacity(0.8) // Slightly transparent image
                .padding(.bottom, 15)
            
            // --- Text ---
            Text(title)
                .font(themedFont(size: 20, weight: .bold))
                .foregroundColor(GlassmorphismTheme.primaryText)
            
            Text(messageAttributedString) // Use AttributedString
                .font(themedFont(size: 14))
                .foregroundColor(GlassmorphismTheme.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .padding(30)
        .frame(maxWidth: .infinity, maxHeight: .infinity) // Center placeholder
         // Optional: Apply glass effect to the placeholder container
         .modifier(GlassmorphicBackground(cornerRadius: 25))
         .padding(30) // Padding around the glass container
    }
    
    // --- Helper properties ---
    private var isInitialState: Bool { searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    private var placeholderImageName: String { isInitialState ? "My-meme-microphone" : "My-meme-orange_2" }
    private var title: String { isInitialState ? "Spotify Search" : "No Results Found" }
    private var messageAttributedString: AttributedString { /* ... (same logic as before) ... */
         var messageText: String; if isInitialState { messageText = "Enter an album or artist name\nin the search bar above to begin." } else { let esc = searchQuery.replacingOccurrences(of:"*",with:"").replacingOccurrences(of:"_",with:""); messageText = "No matches found for \"\(esc)\".\nTry refining your search." }; var attrStr = AttributedString(messageText); attrStr.font = themedFont(size: 14); attrStr.foregroundColor = GlassmorphismTheme.secondaryText; return attrStr
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
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            // --- Main Background Gradient ---
            GlassmorphismTheme.backgroundGradient.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) { // Control spacing precisely
                    // --- Header ---
                    AlbumHeaderView(album: album)
                        .padding(.top, 10)
                        .padding(.bottom, 25)
                    
                    // --- Player ---
                    if selectedTrackUri != nil {
                        SpotifyEmbedPlayerView(playbackState: playbackState, spotifyUri: selectedTrackUri)
                            .padding(.horizontal)
                            .padding(.bottom, 25)
                            .transition(.opacity.combined(with: .scale(scale: 0.95, anchor: .top)))
                            .animation(.easeInOut(duration: 0.3), value: selectedTrackUri)
                    }
                    
                    // --- Tracks List ---
                    TracksSectionView(
                        tracks: tracks,
                        isLoading: isLoadingTracks,
                        error: trackFetchError,
                        selectedTrackUri: $selectedTrackUri,
                        retryAction: { Task { await fetchTracks() } }
                    )
                    .padding(.bottom, 25) // Padding below tracks section
                    
                    // --- External Link (Themed Button) ---
                    if let spotifyURL = URL(string: album.external_urls.spotify ?? "") {
                        ExternalLinkButton(url: spotifyURL)
                            .padding(.horizontal)
                            .padding(.bottom, 30)
                    }
                    
                } // End Main VStack
            } // End ScrollView
        } // End ZStack
        .navigationTitle(album.name)
        .navigationBarTitleDisplayMode(.inline)
         // --- Toolbar Theming ---
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(GlassmorphismTheme.frostMaterial, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar) // Keep text light
        // --- Data Fetching ---
        .task { await fetchTracks() }
    }
    
    // --- Fetch Tracks Logic (Unchanged) ---
    private func fetchTracks(forceReload: Bool = false) async { /* ... (same logic as before) ... */
         guard forceReload || tracks.isEmpty || trackFetchError != nil else { return }; await MainActor.run { isLoadingTracks = true; trackFetchError = nil }; do { let response = try await SpotifyAPIService.shared.getAlbumTracks(albumId: album.id); try Task.checkCancellation(); await MainActor.run { self.tracks = response.items; self.isLoadingTracks = false } } catch is CancellationError { await MainActor.run { isLoadingTracks = false } } catch let apiError as SpotifyAPIError { await MainActor.run { self.trackFetchError = apiError; self.isLoadingTracks = false; self.tracks = [] } } catch { await MainActor.run { self.trackFetchError = .networkError(error); self.isLoadingTracks = false; self.tracks = [] } }
     }
}

// MARK: Detail View Sub-Components (Themed)

struct AlbumHeaderView: View {
    let album: AlbumItem
    
    var body: some View {
        VStack(spacing: 15) {
            // --- Album Image (Large, clear edges) ---
            AlbumImageView(url: album.bestImageURL)
                .aspectRatio(1.0, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: GlassmorphismTheme.cornerRadius)) // Match theme rounding
                // Add a subtle shadow directly to image if desired, or let it float "above" background
                .shadow(color: GlassmorphismTheme.shadowColor.opacity(0.5), radius: 10, x: 0, y: 5)
                .padding(.horizontal, 40)
            
            // --- Text Details ---
            VStack(spacing: 4) {
                Text(album.name)
                    .font(themedFont(size: 20, weight: .bold))
                    .foregroundColor(GlassmorphismTheme.primaryText)
                    .multilineTextAlignment(.center)
                
                Text("by \(album.formattedArtists)")
                    .font(themedFont(size: 15))
                    .foregroundColor(GlassmorphismTheme.secondaryText)
                    .multilineTextAlignment(.center)
                
                Text("\(album.album_type.capitalized) • \(album.formattedReleaseDate())")
                    .font(themedFont(size: 12, weight: .medium))
                    .foregroundColor(GlassmorphismTheme.secondaryText.opacity(0.8))
            }
            .padding(.horizontal)
            // Optionally wrap text block in glass
            // .padding(.vertical, 15)
            // .modifier(GlassmorphicBackground(cornerRadius: 15))
            // .padding(.horizontal, 20) // Padding around the glass text block
            
        }
    }
}

struct SpotifyEmbedPlayerView: View {
    @ObservedObject var playbackState: SpotifyPlaybackState
    let spotifyUri: String?
    
    var body: some View {
        VStack(spacing: 8) {
            // --- WebView Embed ---
            SpotifyEmbedWebView(playbackState: playbackState, spotifyUri: spotifyUri)
                .frame(height: 80) // Standard height
                .clipShape(RoundedRectangle(cornerRadius: GlassmorphismTheme.cornerRadius)) // Clip webview
                .disabled(!playbackState.isReady)
                 .overlay( // Loading/Error State
                     Group {
                         if !playbackState.isReady {
                             ProgressView().tint(GlassmorphismTheme.accentColor)
                         } else if let error = playbackState.error {
                             VStack { /* Error icon + text (same as neumorphic) */ Image(systemName: "exclamationmark.triangle").foregroundColor(GlassmorphismTheme.errorColor); Text(error).font(.caption).foregroundColor(GlassmorphismTheme.errorColor).lineLimit(1) }.padding(5) }
                     }
                  )
                 // --- Apply Glassmorphic Background ---
                  .modifier(GlassmorphicBackground()) // Apply to the container
            
            // --- Playback Status Text (Keep simple) ---
             HStack {
                 if let error = playbackState.error, !error.isEmpty { Text("Error: \(error)").lineLimit(1) }
                 else if !playbackState.isReady { Text("Loading Player...") }
                 else if playbackState.duration > 0.1 { Text(playbackState.isPlaying ? "Playing" : "Paused"); Spacer(); Text("\(formatTime(playbackState.currentPosition)) / \(formatTime(playbackState.duration))") }
                 else { Text("Ready") }
             }
             .font(themedFont(size: 10, weight: .medium))
             .foregroundColor(playbackState.error != nil ? GlassmorphismTheme.errorColor : GlassmorphismTheme.secondaryText)
             .padding(.horizontal, 8).frame(height: 15)
            
        } // End VStack
    }
    
    private func formatTime(_ time: Double) -> String { /* ... (same as before) ... */ let totalSeconds = max(0, Int(time)); let minutes = totalSeconds / 60; let seconds = totalSeconds % 60; return String(format: "%d:%02d", minutes, seconds) }
}

struct TracksSectionView: View {
    let tracks: [Track]
    let isLoading: Bool
    let error: SpotifyAPIError?
    @Binding var selectedTrackUri: String?
    let retryAction: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) { // Add spacing between header and glass container
            // --- Section Header (Simple Text) ---
            Text("Tracks")
                .font(themedFont(size: 16, weight: .semibold))
                .foregroundColor(GlassmorphismTheme.primaryText)
                .padding(.horizontal)
            
            // --- Container for Tracks/Loading/Error with Glass Effect ---
            Group { // Group needed to apply modifier once
                if isLoading {
                    HStack { Spacer(); ProgressView().tint(GlassmorphismTheme.accentColor); Text("Loading Tracks..."); Spacer() } .padding(.vertical, 30)
                } else if let error = error {
                    ErrorPlaceholderView(error: error, retryAction: retryAction) // Error placeholder already has glass
                        .padding(.vertical, 20)
                } else if tracks.isEmpty {
                    Text("No tracks found.") .frame(maxWidth: .infinity).padding(.vertical, 30)
                } else {
                    // --- Track Rows ---
                    VStack(spacing: 0) { // Tightly packed track rows inside glass
                        ForEach(tracks) { track in
                             GlassmorphicTrackRow( // Use new track row style
                                track: track,
                                isSelected: track.uri == selectedTrackUri
                             )
                             .contentShape(Rectangle())
                             .onTapGesture { selectedTrackUri = track.uri }
                             Divider().background(GlassmorphismTheme.borderColor.opacity(0.2)) // Subtle divider matching border
                        }
                    }
                }
            }
            .padding(10) // Padding *inside* the glass container
             .modifier(GlassmorphicBackground()) // Apply glass to the whole tracks area
             .padding(.horizontal) // Padding *outside* the glass container
            
        } // End Outer VStack
    }
}

struct GlassmorphicTrackRow: View {
    let track: Track
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            // --- Track Number ---
             Text("\(track.track_number)")
                .font(themedFont(size: 12, weight: .medium))
                .foregroundColor(isSelected ? GlassmorphismTheme.accentColor : GlassmorphismTheme.secondaryText)
                .frame(width: 20, alignment: .center)
            
            // --- Track Info ---
            VStack(alignment: .leading, spacing: 2) {
                Text(track.name)
                    .font(themedFont(size: 14, weight: .medium))
                    .foregroundColor(GlassmorphismTheme.primaryText) // Always primary for readability
                    .fontWeight(isSelected ? .bold : .regular)
                    .lineLimit(1)
                
                Text(track.formattedArtists)
                    .font(themedFont(size: 11))
                    .foregroundColor(GlassmorphismTheme.secondaryText)
                    .lineLimit(1)
            }
            
            Spacer()
            
            // --- Duration ---
             Text(track.formattedDuration)
                .font(themedFont(size: 12, weight: .medium))
                .foregroundColor(GlassmorphismTheme.secondaryText)
                .frame(width: 40, alignment: .trailing)
            
            // --- Play Indicator ---
             Image(systemName: isSelected ? "speaker.wave.2.fill" : "play.fill") // Use filled play icon
                .font(.system(size: 11)) // Smaller
                .foregroundColor(isSelected ? GlassmorphismTheme.accentColor : GlassmorphismTheme.secondaryText.opacity(0.6))
                .frame(width: 20, alignment: .center)
                .animation(.easeInOut, value: isSelected) // Keep animation
            
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 8) // Padding within the row
         // Subtle Background Highlight on Selection
         .background(isSelected ? GlassmorphismTheme.accentColor.opacity(0.15) : Color.clear)
         .cornerRadius(8) // Round the highlight
    }
}

// MARK: Other Supporting Views (Themed)

struct AlbumImageView: View { // Adjusted for Glassmorphism Placeholders
    let url: URL?
    let cornerRadius: CGFloat = 12 // Define corner radius for consistency
    
    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
                // Loading Placeholder with subtle frost
                 ZStack {
                     RoundedRectangle(cornerRadius: cornerRadius).fill(GlassmorphismTheme.frostMaterial.opacity(0.5))
                      .overlay(RoundedRectangle(cornerRadius: cornerRadius).stroke(GlassmorphismTheme.borderColor.opacity(0.3), lineWidth: 0.5))
                     ProgressView().tint(GlassmorphismTheme.accentColor.opacity(0.8))
                 }
            case .success(let image):
                image.resizable().scaledToFit()
            case .failure:
                 // Error Placeholder with subtle frost
                 ZStack {
                     RoundedRectangle(cornerRadius: cornerRadius).fill(GlassmorphismTheme.frostMaterial.opacity(0.5))
                     .overlay(RoundedRectangle(cornerRadius: cornerRadius).stroke(GlassmorphismTheme.borderColor.opacity(0.3), lineWidth: 0.5))
                     Image(systemName: "photo.fill") // Use filled icon
                         .resizable().scaledToFit()
                         .foregroundColor(GlassmorphismTheme.secondaryText.opacity(0.6))
                         .padding(15)
                 }
            @unknown default: EmptyView()
            }
        }
         // Apply corner radius to the AsyncImage container itself
         .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}

struct SearchMetadataHeader: View { // Keep simple
    let totalResults: Int
    let limit: Int
    let offset: Int
    
    var body: some View {
         HStack { /* ... (same content as before) ... */ Text("Results: \(totalResults)"); Spacer(); if totalResults>limit { Text("Showing: \(offset+1)-\(min(offset+limit, totalResults))") } }
         .font(themedFont(size: 11, weight: .medium))
          // Use secondary text, clear against potential gradient/blur
         .foregroundColor(GlassmorphismTheme.secondaryText)
         .padding(.vertical, 5)
    }
}

// MARK: -> Reusable Glassmorphic Button
struct ThemedGlassmorphicButton: View {
    let text: String
    var iconName: String? = nil
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let iconName = iconName { Image(systemName: iconName) }
                Text(text)
            }
            .font(themedFont(size: 15, weight: .semibold))
             .foregroundColor(GlassmorphismTheme.accentColor) // Use accent color for button text/icon
        }
        .buttonStyle(GlassmorphicButtonStyle()) // Apply the custom glass style
    }
}

// Specific implementation for the external link button
struct ExternalLinkButton: View {
    let text: String = "Open in Spotify"
    let url: URL
    @Environment(\.openURL) var openURL
    
    var body: some View {
        ThemedGlassmorphicButton(text: text, iconName: "arrow.up.forward.app") { // Use new themed button
            openURL(url) { accepted in if !accepted { print("⚠️ OS failed to open URL: \(url)") } }
        }
    }
}

// MARK: - Preview Providers (No changes needed, will use new styles)

struct SpotifyAlbumListView_Previews: PreviewProvider { static var previews: some View { SpotifyAlbumListView() } }
struct GlassmorphicAlbumCard_Previews: PreviewProvider { /* ...(Set up mock data)... */
    static var previews: some View { GlassmorphicAlbumCard(album: mockAlbumItem).padding().background(GlassmorphismTheme.backgroundGradient).previewLayout(.fixed(width:380, height:140)) }; static let mockArtist = Artist(id: "artist1", external_urls: nil, href: "", name: "Miles Davis Mock", type: "artist", uri: ""); static let mockImage = SpotifyImage(height: 300, url: "https://i.scdn.co/image/ab67616d00001e027ab89c25093ea3787b1995b4", width: 300); static let mockAlbumItem = AlbumItem(id: "album1", album_type: "album", total_tracks: 5, available_markets: ["US"], external_urls: ExternalUrls(spotify: ""), href: "", images: [mockImage], name: "Kind of Blue [PREVIEW]", release_date: "1959-08-17", release_date_precision: "day", type: "album", uri: "spotify:album:1weenld61qoidwYuZ1GESA", artists: [mockArtist]); }
struct AlbumDetailView_Previews: PreviewProvider { /* ...(Set up mock data)... */ static var previews: some View { NavigationView{ AlbumDetailView(album: mockAlbum) } }
    static let mockArtist = Artist(id: "artist1", external_urls: nil, href: "", name: "Miles Davis Mock", type: "artist", uri: ""); static let mockImage = SpotifyImage(height: 640, url: "https://i.scdn.co/image/ab67616d0000b2737ab89c25093ea3787b1995b4", width: 640); static let mockAlbum = AlbumItem(id: "1weenld61qoidwYuZ1GESA", album_type: "album", total_tracks: 5, available_markets: ["US", "GB"], external_urls: ExternalUrls(spotify: "https://open.spotify.com/album/1weenld61qoidwYuZ1GESA"), href: "", images: [mockImage], name: "Kind Of Blue (Preview)", release_date: "1959-08-17", release_date_precision: "day", type: "album", uri: "spotify:album:1weenld61qoidwYuZ1GESA", artists: [mockArtist]);}

// MARK: - App Entry Point

@main
struct SpotifyGlassmorphismApp: App {
    init() {
        // Token Warning
        if placeholderSpotifyToken == "YOUR_SPOTIFY_BEARER_TOKEN_HERE" {
            print("🚨 WARNING: Spotify Bearer Token is not set! API calls will fail.")
            print("👉 FIX: Replace the placeholder token in the code.")
        }
        
        // --- Global Navigation Bar Appearance for Glassmorphism ---
        let appearance = UINavigationBarAppearance()
        
        // Configure with a background material (maps to UIKit materials)
        appearance.configureWithTransparentBackground() // Start transparent
        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial) // Apply blur effect
        
        // Or configure with semi-transparent color:
        // appearance.configureWithOpaqueBackground()
        // appearance.backgroundColor = UIColor(GlassmorphismTheme.frostColor) // Example if using color
        
        appearance.titleTextAttributes = [.foregroundColor: UIColor(GlassmorphismTheme.primaryText)]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor(GlassmorphismTheme.primaryText)]
        
        // Remove the default bottom border/shadow
        appearance.shadowColor = .clear
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance // Use same for large titles
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().tintColor = UIColor(GlassmorphismTheme.accentColor) // Back button color
    }
    
    var body: some Scene {
        WindowGroup {
            SpotifyAlbumListView()
                .preferredColorScheme(.dark) // Keep dark mode for theme visuals
        }
    }
}
