////
////  DarkNeumorphismLiquidGoldAccentThemeLook.swift
////  MyApp
////
////  Created by Cong Le on 4/18/25.
////
//
//
////  Single-file implementation of a Spotify album browser with Dark Neumorphism theme
////  and a Liquid Gold accent.
////
//
//import SwiftUI
//@preconcurrency import WebKit // For Spotify Embed WebView
//import Foundation
//
//// MARK: - Color Hex Helper
//
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
//        
//        self.init(
//            .sRGB,
//            red: Double(r) / 255,
//            green: Double(g) / 255,
//            blue: Double(b) / 255,
//            opacity: Double(a) / 255
//        )
//    }
//    
//    // Convenience property to get UIColor
//    var uiColor: UIColor { UIColor(self) }
//}
//
//// MARK: - Dark Neumorphism Theme Constants & Helpers (with Liquid Gold)
//
//struct DarkNeumorphicTheme {
//    static let background = Color(hex: "#24282F") // Slightly different dark base: 0.14, 0.16, 0.19
//    static let elementBackground = Color(hex: "#2E333A") // Slightly lighter element: 0.18, 0.20, 0.23
//    static let lightShadow = Color.white.opacity(0.08) // Reduced light shadow intensity
//    static let darkShadow = Color.black.opacity(0.6)  // Slightly stronger dark shadow
//    
//    static let primaryText = Color.white.opacity(0.9) // Slightly brighter primary
//    static let secondaryText = Color(hex: "#8A919E") // Specific gray: 0.54, 0.57, 0.62
//    
//    // --- Liquid Gold Accent ---
//    static let goldBase = Color(hex: "#E1AC41")         // Main gold color
//    static let goldHighlight = Color(hex: "#F0D880")   // Lighter gold for gradients/highlights
//    static let goldShadow = Color(hex: "#C08820")      // Darker gold for depth
//    
//    static let accentColor = goldBase // Use base gold for general accents (text, icons)
//    
//    // Gradient for buttons/highlights
//    static let liquidGoldGradient = LinearGradient(
//        gradient: Gradient(colors: [goldHighlight, goldBase, goldShadow]),
//        startPoint: .topLeading,
//        endPoint: .bottomTrailing
//    )
//    
//    // --- Other Colors ---
//    static let errorColor = Color(hex: "#D44C4C") // Muted red (e.g., 0.83, 0.3, 0.3)
//    
//    static let shadowRadius: CGFloat = 7 // Slightly larger radius
//    static let shadowOffset: CGFloat = 5 // Slightly larger offset
//}
//
//// Font helper (using system fonts for simplicity)
//func neumorphicFont(size: CGFloat, weight: Font.Weight = .regular, design: Font.Design = .default) -> Font {
//    return Font.system(size: size, weight: weight, design: design)
//}
//
////MARK: -> Neumorphic View Modifiers / Styles (Adjusted for Gold Accent)
//
//// --- Outer Shadow for Extruded Elements ---
//struct NeumorphicOuterShadow: ViewModifier {
//    let cornerRadius: CGFloat = 15
//    
//    func body(content: Content) -> some View {
//        content
//            .background(
//                RoundedRectangle(cornerRadius: cornerRadius)
//                    .fill(DarkNeumorphicTheme.elementBackground) // Apply to the shape itself
//                    .shadow(color: DarkNeumorphicTheme.darkShadow,
//                            radius: DarkNeumorphicTheme.shadowRadius,
//                            x: DarkNeumorphicTheme.shadowOffset,
//                            y: DarkNeumorphicTheme.shadowOffset)
//                    .shadow(color: DarkNeumorphicTheme.lightShadow,
//                            radius: DarkNeumorphicTheme.shadowRadius,
//                            x: -DarkNeumorphicTheme.shadowOffset,
//                            y: -DarkNeumorphicTheme.shadowOffset)
//            )
//    }
//}
//
//// --- Inner Shadow for Depressed Elements (Simulated) ---
//struct NeumorphicInnerShadow: ViewModifier {
//    let cornerRadius: CGFloat = 15
//    
//    func body(content: Content) -> some View {
//        // Approximation via overlay shadows on a stroke
//        content
//            .padding(2)
//            .background(DarkNeumorphicTheme.elementBackground)
//            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
//            .overlay(
//                RoundedRectangle(cornerRadius: cornerRadius)
//                    .stroke(DarkNeumorphicTheme.background, lineWidth: 4)
//                    .shadow(color: DarkNeumorphicTheme.darkShadow, radius: DarkNeumorphicTheme.shadowRadius - 2, x: DarkNeumorphicTheme.shadowOffset - 1, y: DarkNeumorphicTheme.shadowOffset - 1)
//                    .shadow(color: DarkNeumorphicTheme.lightShadow, radius: DarkNeumorphicTheme.shadowRadius - 2, x: -(DarkNeumorphicTheme.shadowOffset - 1), y: -(DarkNeumorphicTheme.shadowOffset - 1))
//                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius)) // Clip shadows to inner edge
//            )
//    }
//}
//
//// --- Neumorphic Button Style (Applying Gold Gradient) ---
//struct NeumorphicButtonStyle: ButtonStyle {
//    func makeBody(configuration: Configuration) -> some View {
//        configuration.label
//            .padding(.vertical, 12)
//            .padding(.horizontal, 20)
//            .background(
//                NeumorphicButtonBackground(isPressed: configuration.isPressed) // Uses the gradient background
//            )
//            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
//            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
//    }
//}
//
//// Helper for button background state (WITH GRADIENT)
//struct NeumorphicButtonBackground: View {
//    var isPressed: Bool
//    let cornerRadius: CGFloat = 20
//    
//    var body: some View {
//        ZStack {
//            if isPressed {
//                // Pressed State: Darker background with inner shadow simulation
//                RoundedRectangle(cornerRadius: cornerRadius)
//                    .fill(DarkNeumorphicTheme.background) // Use main background for inset
//                    .overlay(
//                        RoundedRectangle(cornerRadius: cornerRadius)
//                            .stroke(DarkNeumorphicTheme.elementBackground, lineWidth: 2) // Subtle border
//                    )
//                    .shadow(color: DarkNeumorphicTheme.darkShadow, radius: DarkNeumorphicTheme.shadowRadius / 2, x: DarkNeumorphicTheme.shadowOffset / 2, y: DarkNeumorphicTheme.shadowOffset / 2)
//                    .shadow(color: DarkNeumorphicTheme.lightShadow, radius: DarkNeumorphicTheme.shadowRadius / 2, x: -DarkNeumorphicTheme.shadowOffset / 2, y: -DarkNeumorphicTheme.shadowOffset / 2)
//                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius)) // Clip shadows inwards
//                
//            } else {
//                // Unpressed State: Apply Liquid Gold Gradient as background
//                RoundedRectangle(cornerRadius: cornerRadius)
//                    .fill(DarkNeumorphicTheme.liquidGoldGradient) // Use the gradient fill
//                    .shadow(color: DarkNeumorphicTheme.darkShadow,
//                            radius: DarkNeumorphicTheme.shadowRadius,
//                            x: DarkNeumorphicTheme.shadowOffset,
//                            y: DarkNeumorphicTheme.shadowOffset)
//                    .shadow(color: DarkNeumorphicTheme.lightShadow,
//                            radius: DarkNeumorphicTheme.shadowRadius,
//                            x: -DarkNeumorphicTheme.shadowOffset,
//                            y: -DarkNeumorphicTheme.shadowOffset)
//                
//            }
//        }
//    }
//}
//#Preview("NeumorphicButtonBackground") {
//    NeumorphicButtonBackground(isPressed: true)
//    
//}
//
//// MARK: - Data Models (Unchanged)
//
//struct SpotifySearchResponse: Codable, Hashable { let albums: Albums }
//struct Albums: Codable, Hashable { let href: String; let limit: Int; let next: String?; let offset: Int; let previous: String?; let total: Int; let items: [AlbumItem] }
//struct AlbumItem: Codable, Identifiable, Hashable { let id: String; let album_type: String; let total_tracks: Int; let available_markets: [String]?; let external_urls: ExternalUrls; let href: String; let images: [SpotifyImage]; let name: String; let release_date: String; let release_date_precision: String; let type: String; let uri: String; let artists: [Artist]; var bestImageURL: URL? { images.first { $0.width == 640 }?.urlObject ?? images.first { $0.width == 300 }?.urlObject ?? images.first?.urlObject }; var listImageURL: URL? { images.first { $0.width == 300 }?.urlObject ?? images.first { $0.width == 64 }?.urlObject ?? images.first?.urlObject }; var formattedArtists: String { artists.map { $0.name }.joined(separator: ", ") }; func formattedReleaseDate() -> String { let dateFormatter = DateFormatter(); switch release_date_precision { case "year": dateFormatter.dateFormat = "yyyy"; if let date = dateFormatter.date(from: release_date) { return dateFormatter.string(from: date) }; case "month": dateFormatter.dateFormat = "yyyy-MM"; if let date = dateFormatter.date(from: release_date) { dateFormatter.dateFormat = "MMM yyyy"; return dateFormatter.string(from: date) }; case "day": dateFormatter.dateFormat = "yyyy-MM-dd"; if let date = dateFormatter.date(from: release_date) { dateFormatter.dateFormat = "d MMM yyyy"; return dateFormatter.string(from: date) }; default: break }; return release_date } }
//struct Artist: Codable, Identifiable, Hashable { let id: String; let external_urls: ExternalUrls?; let href: String; let name: String; let type: String; let uri: String }
//struct SpotifyImage: Codable, Hashable { let height: Int?; let url: String; let width: Int?; var urlObject: URL? { URL(string: url) } }
//struct ExternalUrls: Codable, Hashable { let spotify: String? }
//struct AlbumTracksResponse: Codable, Hashable { let items: [Track] }
//struct Track: Codable, Identifiable, Hashable { let id: String; let artists: [Artist]; let disc_number: Int; let duration_ms: Int; let explicit: Bool; let external_urls: ExternalUrls?; let href: String; let name: String; let preview_url: String?; let track_number: Int; let type: String; let uri: String; var previewURL: URL? { if let url = preview_url { return URL(string: url)} else {return nil} }; var formattedDuration: String { let totalSeconds = duration_ms / 1000; let minutes = totalSeconds / 60; let seconds = totalSeconds % 60; return String(format: "%d:%02d", minutes, seconds) }; var formattedArtists: String { artists.map { $0.name }.joined(separator: ", ") } }
//
//// MARK: - API Service (Unchanged, needs real token)
//
//let placeholderSpotifyToken = "YOUR_SPOTIFY_BEARER_TOKEN_HERE" // <-- IMPORTANT: REPLACE ME
//enum SpotifyAPIError: Error, LocalizedError { case invalidURL; case networkError(Error); case invalidResponse(Int, String?); case decodingError(Error); case invalidToken; case missingData; var errorDescription: String? { switch self { case .invalidURL: "Invalid API URL"; case .networkError(let e): "Network: \(e.localizedDescription)"; case .invalidResponse(let c, _): "Server (\(c))"; case .decodingError: "Parsing Failed"; case .invalidToken: "Auth Failed"; case .missingData: "Missing Data" } } }
//struct SpotifyAPIService { static let shared = SpotifyAPIService(); private let session: URLSession = { let c = URLSessionConfiguration.default; c.requestCachePolicy = .reloadIgnoringLocalCacheData; return URLSession(configuration: c) }(); private func makeRequest<T: Decodable>(url: URL) async throws -> T { guard !placeholderSpotifyToken.isEmpty, placeholderSpotifyToken != "YOUR_SPOTIFY_BEARER_TOKEN_HERE" else { throw SpotifyAPIError.invalidToken } ; var request = URLRequest(url: url); request.httpMethod = "GET"; request.setValue("Bearer \(placeholderSpotifyToken)", forHTTPHeaderField: "Authorization"); request.timeoutInterval = 20; do { let (data, response) = try await session.data(for: request); guard let httpResponse = response as? HTTPURLResponse else { throw SpotifyAPIError.invalidResponse(0, "Not HTTP") }; guard (200...299).contains(httpResponse.statusCode) else { if httpResponse.statusCode == 401 { throw SpotifyAPIError.invalidToken }; throw SpotifyAPIError.invalidResponse(httpResponse.statusCode, String(data:data, encoding: .utf8)) }; return try JSONDecoder().decode(T.self, from: data) } catch let error where !(error is CancellationError) { throw error is SpotifyAPIError ? error : SpotifyAPIError.networkError(error) } }; func searchAlbums(query: String, limit: Int = 20, offset: Int = 0) async throws -> SpotifySearchResponse { var c = URLComponents(string: "https://api.spotify.com/v1/search"); c?.queryItems = [URLQueryItem(name: "q", value: query), URLQueryItem(name: "type", value: "album"), URLQueryItem(name: "limit", value: "\(limit)"), URLQueryItem(name: "offset", value: "\(offset)")]; guard let url = c?.url else { throw SpotifyAPIError.invalidURL }; return try await makeRequest(url: url) }; func getAlbumTracks(albumId: String, limit: Int = 50, offset: Int = 0) async throws -> AlbumTracksResponse { var c = URLComponents(string: "https://api.spotify.com/v1/albums/\(albumId)/tracks"); c?.queryItems = [URLQueryItem(name: "limit", value: "\(limit)") ]; guard let url = c?.url else { throw SpotifyAPIError.invalidURL }; return try await makeRequest(url: url) } }
//
//// MARK: - Spotify Embed WebView & State (Unchanged logic)
//
//final class SpotifyPlaybackState: ObservableObject { @Published var isPlaying: Bool = false; @Published var currentPosition: Double = 0; @Published var duration: Double = 0; @Published var currentUri: String = ""; @Published var isReady: Bool = false; @Published var error: String? = nil }
//struct SpotifyEmbedWebView: UIViewRepresentable { @ObservedObject var playbackState: SpotifyPlaybackState; let spotifyUri: String?; func makeCoordinator() -> Coordinator { Coordinator(self) }; func makeUIView(context: Context) -> WKWebView { let ucc = WKUserContentController(); ucc.add(context.coordinator, name: "spotifyController"); let config = WKWebViewConfiguration(); config.userContentController = ucc; config.allowsInlineMediaPlayback = true; config.mediaTypesRequiringUserActionForPlayback = []; let webView = WKWebView(frame: .zero, configuration: config); webView.navigationDelegate = context.coordinator; webView.uiDelegate = context.coordinator; webView.isOpaque = false; webView.backgroundColor = .clear; webView.scrollView.isScrollEnabled = false; webView.loadHTMLString(generateHTML(), baseURL: nil); context.coordinator.webView = webView; return webView }; func updateUIView(_ webView: WKWebView, context: Context) { print("🔄 WebView Update: API Ready=\(context.coordinator.isApiReady), URI=\(context.coordinator.lastLoadedUri ?? "nil") vs \(spotifyUri ?? "nil")"); if context.coordinator.isApiReady && context.coordinator.lastLoadedUri != spotifyUri { context.coordinator.loadUri(spotifyUri ?? "") } else if !context.coordinator.isApiReady { context.coordinator.updateDesiredUriBeforeReady(spotifyUri ?? "") } }; static func dismantleUIView(_ webView: WKWebView, coordinator: Coordinator) { print("🧹 WebView Dismantle"); webView.stopLoading(); webView.configuration.userContentController.removeScriptMessageHandler(forName: "spotifyController"); coordinator.webView = nil }; class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler { var parent: SpotifyEmbedWebView; weak var webView: WKWebView?; var isApiReady = false; var lastLoadedUri: String?; private var desiredUriBeforeReady: String? = nil; init(_ p: SpotifyEmbedWebView) { parent = p }; func updateDesiredUriBeforeReady(_ uri: String?) { if !isApiReady { desiredUriBeforeReady = uri; print("📥 Stored URI: \(uri ?? "nil")") } }; func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) { print("📄 WebView Load Finish") }; func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) { handleWebViewError("Navigation", error) }; func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) { handleWebViewError("Provisional Nav", error) }; func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) { guard message.name == "spotifyController" else { return }; if let bodyDict = message.body as? [String: Any], let event = bodyDict["event"] as? String { handleEvent(event: event, data: bodyDict["data"]) } else if let bodyString = message.body as? String, bodyString == "ready" { handleApiReady() } else { print("❓ JS Unknown Msg: \(message.body)") } }; private func handleApiReady() { print("✅ API Ready (Native)"); isApiReady = true; DispatchQueue.main.async { self.parent.playbackState.isReady = true }; if let initialUri = desiredUriBeforeReady ?? parent.spotifyUri { createSpotifyController(with: initialUri); desiredUriBeforeReady = nil } }; private func handleEvent(event: String, data: Any?) { switch event { case "controllerCreated": print("✅ Controller Created"); case "playbackUpdate": if let d = data as? [String: Any] { updatePlaybackState(with: d) }; case "error": let msg = (data as? [String: Any])?["message"] as? String ?? (data as? String) ?? "Unknown JS Err"; print("❌ JS Error: \(msg)"); DispatchQueue.main.async { self.parent.playbackState.error = msg }; default: print("❓ Unknown Event: \(event)") } }; private func updatePlaybackState(with data: [String: Any]) { DispatchQueue.main.async { [weak self] in guard let self = self else { return }; var changed = false; if let p = data["paused"] as? Bool, self.parent.playbackState.isPlaying == p { self.parent.playbackState.isPlaying = !p; changed = true }; if let pos = data["position"] as? Double, abs(self.parent.playbackState.currentPosition - pos/1000.0) > 0.1 { self.parent.playbackState.currentPosition = pos/1000.0; changed = true }; if let dur = data["duration"] as? Double, abs(self.parent.playbackState.duration - dur/1000.0) > 0.1 || self.parent.playbackState.duration == 0 { self.parent.playbackState.duration = dur/1000.0; changed = true }; if let uri = data["uri"] as? String, self.parent.playbackState.currentUri != uri { self.parent.playbackState.currentUri = uri; self.parent.playbackState.currentPosition = 0; self.parent.playbackState.duration = (data["duration"] as? Double ?? 0)/1000.0; changed = true }; if changed && self.parent.playbackState.error != nil { self.parent.playbackState.error = nil } } }; private func createSpotifyController(with initialUri: String) { guard let webView = webView, isApiReady else { print("⚠️ Cannot create controller - Webview/API not ready."); return }; guard lastLoadedUri == nil else { print("ℹ️ Skipping createController - already attempted/loaded (\(lastLoadedUri ?? "nil")). Req: \(initialUri)"); return }; print("🚀 Creating Controller: \(initialUri)"); lastLoadedUri = initialUri; let script = #" console.log('JS: Creating controller for: \#(initialUri)'); window.embedController = null; const el = document.getElementById('embed-iframe'); if (!el || !window.IFrameAPI) { console.error('JS Err: Element or API missing!'); window.webkit?.messageHandlers?.spotifyController?.postMessage({event:'error', data:'Embed el/API missing'}); return; } const opt = { uri: '\#(initialUri)', width:'100%', height:'100%' }; const cb = (c) => { if (!c) { console.error('JS Err: Null controller!'); window.webkit?.messageHandlers?.spotifyController?.postMessage({event:'error', data:'Null JS Contr'}); return; } window.embedController = c; window.webkit?.messageHandlers?.spotifyController?.postMessage({event:'controllerCreated'}); c.addListener('playback_update', e => window.webkit?.messageHandlers?.spotifyController?.postMessage({event:'playbackUpdate',data:e.data})); c.addListener('error', e => window.webkit?.messageHandlers?.spotifyController?.postMessage({event:'error',data:e.data})); /* Add other listeners as needed */ }; try { window.IFrameAPI.createController(el,opt,cb); } catch(e) { console.error('JS Excep:', e); window.webkit?.messageHandlers?.spotifyController?.postMessage({event:'error',data:'JS Ex: '+e.message}); lastLoadedUri = nil; } "#; webView.evaluateJavaScript(script) { _, e in if let e = e { print("⚠️ JS Eval Err (Create): \(e)") } } }; func loadUri(_ uri: String) { guard let webView = webView, isApiReady else { return }; guard lastLoadedUri != uri else { print("ℹ️ Skipping loadUri - same URI (\(uri))."); executeJsCommand("play"); return}; print("🚀 Loading URI: \(uri)"); lastLoadedUri = uri; let script = #" if(window.embedController){window.embedController.loadUri('\#(uri)'); window.embedController.play();}else{console.error('JS Err: No controller for loadUri');} "#; webView.evaluateJavaScript(script) {_,e in if let e = e { print("⚠️ JS Eval Err (Load): \(e)") } } }; func executeJsCommand(_ cmd: String) { guard let webView = webView, lastLoadedUri != nil else { return }; let script = "if(window.embedController){window.embedController.\(cmd)();}else{console.warn('JS Warn: No ctrl for cmd \(cmd)');}"; webView.evaluateJavaScript(script) }; func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) { print("ℹ️ JS Alert: \(message)"); completionHandler() }; private func handleWebViewError(_ context: String, _ error: Error) { print("❌ WebView Err (\(context)): \(error.localizedDescription)"); DispatchQueue.main.async { self.parent.playbackState.error = "\(context) Failed" } } }; private func generateHTML() -> String { return #"<!DOCTYPE html><html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no"><title>Embed</title><style>html,body{margin:0;padding:0;width:100%;height:100%;overflow:hidden;background:transparent;}#embed-iframe{width:100%;height:100%;display:block;border:none;}</style></head><body><div id="embed-iframe"></div><script src="https://open.spotify.com/embed/iframe-api/v1" async></script><script>var apiRdyCbSet=false;window.onSpotifyIframeApiReady=(IFrameAPI)=>{if(apiRdyCbSet)return;console.log('✅ JS: API Ready');window.IFrameAPI=IFrameAPI;apiRdyCbSet=true;if(window.webkit?.messageHandlers?.spotifyController){window.webkit.messageHandlers.spotifyController.postMessage("ready")}else{console.error('❌ JS: Handler Missing!')}};const sTag=document.querySelector('script[src*="iframe-api"]');if(sTag){sTag.onerror=(e)=>{console.error('❌ JS: API Load Fail:', e);window.webkit?.messageHandlers?.spotifyController?.postMessage({event:'error',data:'API Script Load Failed'})}}else{console.warn('⚠️ JS: No API script tag?')}</script></body></html>"# } }
//
//// MARK: - SwiftUI Views (Dark Neumorphism + Liquid Gold Themed)
////
////// MARK: Main List View
////struct SpotifyAlbumListView: View {
////    @State private var searchQuery: String = ""
////    @State private var displayedAlbums: [AlbumItem] = []
////    @State private var isLoading: Bool = false
////    @State private var searchInfo: Albums? = nil
////    @State private var currentError: SpotifyAPIError? = nil
////
////    var body: some View {
////        NavigationView {
////            ZStack {
////                DarkNeumorphicTheme.background.ignoresSafeArea()
////
////                VStack(spacing: 0) {
////                    Group { // Content switcher
////                        if isLoading && displayedAlbums.isEmpty {loadingIndicator}
////                        else if let error = currentError { ErrorPlaceholderView(error: error) { Task { await performDebouncedSearch(immediate: true) } } }
////                        else if displayedAlbums.isEmpty && !searchQuery.isEmpty { EmptyStatePlaceholderView(searchQuery: searchQuery) }
////                        else if displayedAlbums.isEmpty && searchQuery.isEmpty { EmptyStatePlaceholderView(searchQuery: "") }
////                        else { albumScrollView }
////                    }
////                    .frame(maxWidth: .infinity, maxHeight: .infinity)
////                }
////            }
////            .navigationTitle("Spotify Search") // Title is styled by global appearance
////            .navigationBarTitleDisplayMode(.large)
////            // Search bar customization below
////            .searchable(text: $searchQuery, placement: .navigationBarDrawer(displayMode: .always), prompt: Text("Search Albums / Artists").foregroundColor(DarkNeumorphicTheme.secondaryText)) // Prompt color
////            .onSubmit(of: .search) { Task { await performDebouncedSearch(immediate: true) } }
////            .task(id: searchQuery) { await performDebouncedSearch() }
////            .onChange(of: searchQuery) { if currentError != nil { currentError = nil } }
////            .accentColor(DarkNeumorphicTheme.accentColor) // Gold cursor/cancel button
////
////        }
////        .navigationViewStyle(.stack)
////        .preferredColorScheme(.dark) // Essential for theme consistency
////    }
////
////    private var albumScrollView: some View {
////        ScrollView {
////            LazyVStack(spacing: 18) {
////                if let info = searchInfo, info.total > 0 {
////                    SearchMetadataHeader(totalResults: info.total, limit: info.limit, offset: info.offset)
////                        .padding(.horizontal)
////                        .padding(.top, 5)
////                }
////
////                ForEach(displayedAlbums) { album in
////                    NavigationLink(destination: AlbumDetailView(album: album)) {
////                        NeumorphicAlbumCard(album: album)
////                    }
////                    .buttonStyle(.plain)
////                }
////            }
////            .padding(.horizontal)
////            .padding(.bottom)
////        }
////        .scrollDismissesKeyboard(.interactively)
////        .refreshable { // Pull-to-refresh
////            await performDebouncedSearch(immediate: true)
////        }
////    }
////
////    private var loadingIndicator: some View {
////        VStack {
////            ProgressView()
////                .progressViewStyle(CircularProgressViewStyle(tint: DarkNeumorphicTheme.accentColor)) // Use gold accent
////                .scaleEffect(1.5)
////            Text("Loading...")
////                .font(neumorphicFont(size: 14))
////                .foregroundColor(DarkNeumorphicTheme.secondaryText)
////                .padding(.top, 10)
////        }
////    }
////
////    private func performDebouncedSearch(immediate: Bool = false) async { // Logic unchanged
////        let trimmedQuery = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
////        guard !trimmedQuery.isEmpty else { Task { @MainActor in displayedAlbums = []; searchInfo = nil; isLoading = false; currentError = nil }; return }
////        Task { @MainActor in isLoading = true }
////        if !immediate { do { try await Task.sleep(for: .milliseconds(500)); try Task.checkCancellation() } catch { print("Search cancel (debounce)."); Task { @MainActor in isLoading = false }; return } }
////        guard trimmedQuery == searchQuery.trimmingCharacters(in: .whitespacesAndNewlines) else { print("Query changed."); Task { @MainActor in isLoading = false }; return }
////        do { print("🚀 Search: \(trimmedQuery)"); let response = try await SpotifyAPIService.shared.searchAlbums(query: trimmedQuery); try Task.checkCancellation(); await MainActor.run { displayedAlbums = response.albums.items; searchInfo = response.albums; currentError = nil; isLoading = false; print("✅ Loaded \(response.albums.items.count)") } } catch is CancellationError { print("Search cancel."); await MainActor.run { isLoading = false } } catch let apiError as SpotifyAPIError { print("❌ API Err: \(apiError)"); await MainActor.run { displayedAlbums = []; searchInfo = nil; currentError = apiError; isLoading = false } } catch { print("❌ Err: \(error)"); await MainActor.run { displayedAlbums = []; searchInfo = nil; currentError = .networkError(error); isLoading = FALSE } }
////    }
////}
////
////// MARK: Neumorphic Album Card (Gold Themed)
////struct NeumorphicAlbumCard: View {
////    let album: AlbumItem
////    private let cardCornerRadius: CGFloat = 20
////
////    var body: some View {
////        HStack(spacing: 15) {
////            //            AlbumImageView(url: album.listImageURL)
////            //                .frame(width: 80, height: 80)
////            //                .clipShape(RoundedRectangle(cornerRadius: 12))
////            //            // Subtle darker border for definition
////            //                .overlay(RoundedRectangle(cornerRadius: 12).stroke(DarkNeumorphicTheme.background.opacity(0.5), lineWidth: 1))
////            //
////            VStack(alignment: .leading, spacing: 4) {
////                Text(album.name)
////                    .font(neumorphicFont(size: 15, weight: .semibold))
////                    .foregroundColor(DarkNeumorphicTheme.primaryText)
////                    .lineLimit(2)
////
////                Text(album.formattedArtists)
////                    .font(neumorphicFont(size: 13))
////                    .foregroundColor(DarkNeumorphicTheme.secondaryText)
////                    .lineLimit(1)
////
////                Spacer()
////
////                HStack(spacing: 8) {
////                    // Type Tag - subtle background
////                    Text(album.album_type.capitalized)
////                        .font(neumorphicFont(size: 10, weight: .medium))
////                        .foregroundColor(DarkNeumorphicTheme.secondaryText)
////                        .padding(.horizontal, 8)
////                        .padding(.vertical, 3)
////                        .background(DarkNeumorphicTheme.background.opacity(0.7), in: Capsule())
////
////                    Text("• \(album.formattedReleaseDate())")
////                        .font(neumorphicFont(size: 10, weight: .medium))
////                        .foregroundColor(DarkNeumorphicTheme.secondaryText)
////                }
////                Text("\(album.total_tracks) Tracks")
////                    .font(neumorphicFont(size: 10, weight: .medium))
////                    .foregroundColor(DarkNeumorphicTheme.secondaryText)
////                    .padding(.top, 1)
////
////            }
////            .frame(maxWidth: .infinity, alignment: .leading)
////
////        }
////        .padding(15)
////        .modifier(NeumorphicOuterShadow(cornerRadius: cardCornerRadius)) // Main card shadow
////        .frame(height: 110)
////    }
////}
////
////// MARK: Placeholders (Gold Themed Buttons/Accents)
////struct ErrorPlaceholderView: View {
////    let error: SpotifyAPIError
////    let retryAction: (() -> Void)?
////    private let cornerRadius: CGFloat = 25
////
////    var body: some View {
////        VStack(spacing: 20) {
////            Image(systemName: iconName)
////                .font(.system(size: 50))
////                .foregroundColor(DarkNeumorphicTheme.errorColor) // Keep error color distinct
////                .padding(25)
////                .background(Circle().fill(DarkNeumorphicTheme.elementBackground).modifier(NeumorphicOuterShadow(cornerRadius: 50))) // Neumorphic circle
////                .padding(.bottom, 15)
////
////            Text("Error")
////                .font(neumorphicFont(size: 20, weight: .bold))
////                .foregroundColor(DarkNeumorphicTheme.primaryText)
////
////            Text(errorMessage)
////                .font(neumorphicFont(size: 14))
////                .foregroundColor(DarkNeumorphicTheme.secondaryText)
////                .multilineTextAlignment(.center)
////                .padding(.horizontal, 30)
////
////            // Retry Button uses gold theme
////            if error != .invalidToken && retryAction != nil {
////                ThemedNeumorphicButton(text: "Retry", iconName: "arrow.clockwise", action: retryAction ?? {})
////                    .padding(.top, 10)
////            } else if error == .invalidToken {
////                Text("Check API token in code.")
////                    .font(neumorphicFont(size: 13))
////                    .foregroundColor(DarkNeumorphicTheme.errorColor.opacity(0.8))
////                    .multilineTextAlignment(.center)
////                    .padding(.horizontal, 30)
////            }
////        }
////        .padding(40)
////    }
////
////    // --- Helper properties (unchanged logic) ---
////    private var iconName: String { switch error { case .invalidToken: "key.slash"; case .networkError: "wifi.slash"; case .invalidResponse, .decodingError, .missingData: "exclamationmark.triangle"; case .invalidURL: "link.badge.questionmark" } }
////    private var errorMessage: String { error.localizedDescription ?? "An unknown error occurred." }
////}
////
////struct EmptyStatePlaceholderView: View { // Unchanged appearance, already themed
////    let searchQuery: String
////    var body: some View { VStack(spacing: 20) { Image(placeholderImageName) .resizable() .aspectRatio(contentMode: .fit) .frame(height: 130) .padding(isInitialState ? 25 : 15) .background(Circle().fill(DarkNeumorphicTheme.elementBackground).modifier(NeumorphicOuterShadow(cornerRadius: 99))) .padding(.bottom, 15); Text(title) .font(neumorphicFont(size: 20, weight: .bold)) .foregroundColor(DarkNeumorphicTheme.primaryText); Text(messageAttributedString) .font(neumorphicFont(size: 14)) .foregroundColor(DarkNeumorphicTheme.secondaryText) .multilineTextAlignment(.center) .padding(.horizontal, 40) }.padding(30) }
////    private var isInitialState: Bool { searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
////    private var placeholderImageName: String { isInitialState ? "My-meme-microphone" : "My-meme-orange_2" }
////    private var title: String { isInitialState ? "Spotify Search" : "No Results Found" }
////    private var messageAttributedString: AttributedString { var msg = isInitialState ? "Enter an album or artist name\nin the search bar above to begin." : "No matches found for \"\(searchQuery.replacingOccurrences(of: "*", with: "").replacingOccurrences(of: "_", with: ""))\".\nTry refining your search terms."; var attrStr = AttributedString(msg); attrStr.font = neumorphicFont(size: 14); attrStr.foregroundColor = DarkNeumorphicTheme.secondaryText; return attrStr }
////}
////
////// MARK: Album Detail View (Gold Themed)
////struct AlbumDetailView: View {
////    let album: AlbumItem
////    @State private var tracks: [Track] = []
////    @State private var isLoadingTracks: Bool = false
////    @State private var trackFetchError: SpotifyAPIError? = nil
////    @State private var selectedTrackUri: String? = nil
////    @StateObject private var playbackState = SpotifyPlaybackState()
////
////    var body: some View {
////        ZStack {
////            DarkNeumorphicTheme.background.ignoresSafeArea()
////
////            ScrollView {
////                VStack(spacing: 0) {
////                    AlbumHeaderView(album: album)
////                        .padding(.top, 10).padding(.bottom, 25)
////
////                    if selectedTrackUri != nil {
////                        SpotifyEmbedPlayerView(playbackState: playbackState, spotifyUri: selectedTrackUri)
////                            .padding(.horizontal).padding(.bottom, 25)
////                            .transition(.opacity.combined(with: .scale(scale: 0.95, anchor: .top)))
////                            .animation(.easeInOut(duration: 0.3), value: selectedTrackUri)
////                    }
////
////                    //                    TracksSectionView(
////                    //                        tracks: tracks, isLoading: isLoadingTracks, error: trackFetchError,
////                    //                        selectedTrackUri: $selectedTrackUri,
////                    //                        retryAction: { Task { await fetchTracks() } }
////                    //                    )
////                    //                    .padding(.bottom, 25)
////                    //
////                    //                    // External Link uses gold button theme
////                    //                    if let spotifyURL = URL(string: album.external_urls.spotify ?? "") {
////                    //                        ExternalLinkButton(url: spotifyURL)
////                    //                            .padding(.horizontal).padding(.bottom, 30)
////                    //                    }
////                }
////            }
////        }
////        .navigationTitle(album.name)
////        .navigationBarTitleDisplayMode(.inline)
////        .toolbarBackground(DarkNeumorphicTheme.elementBackground, for: .navigationBar) // Keep nav bar background subtle
////        .toolbarBackground(.visible, for: .navigationBar)
////        .toolbarColorScheme(.dark, for: .navigationBar) // Ensures light title/buttons on dark bg
////        .task { await fetchTracks() }
////        .refreshable { await fetchTracks(forceReload: true) } // Allow force reload
////    }
////
////    private func fetchTracks(forceReload: Bool = false) async { // Logic unchanged
////        guard forceReload || tracks.isEmpty || trackFetchError != nil else { return }
////        await MainActor.run { isLoadingTracks = true; trackFetchError = nil }
////        do { let response = try await SpotifyAPIService.shared.getAlbumTracks(albumId: album.id); try Task.checkCancellation(); await MainActor.run { self.tracks = response.items; self.isLoadingTracks = false } } catch is CancellationError { await MainActor.run { isLoadingTracks = false } } catch let apiError as SpotifyAPIError { await MainActor.run { self.trackFetchError = apiError; self.isLoadingTracks = false; self.tracks = [] } } catch { await MainActor.run { self.trackFetchError = .networkError(error); self.isLoadingTracks = false; self.tracks = [] } }
////    }
////}
////
////// MARK: Detail View Sub-Components (Gold Themed)
////
////struct AlbumHeaderView: View { // Unchanged appearance logic, uses theme constants
////    let album: AlbumItem; private let imageCornerRadius: CGFloat = 25
////    var body: some View { VStack(spacing: 15) { AlbumImageView(url: album.bestImageURL) .aspectRatio(1.0, contentMode: .fit) .clipShape(RoundedRectangle(cornerRadius: imageCornerRadius)) .background(RoundedRectangle(cornerRadius: imageCornerRadius).fill(DarkNeumorphicTheme.elementBackground).modifier(NeumorphicOuterShadow(cornerRadius: imageCornerRadius))) .padding(.horizontal, 40); VStack(spacing: 4) { Text(album.name) .font(neumorphicFont(size: 20, weight: .bold)) .foregroundColor(DarkNeumorphicTheme.primaryText) .multilineTextAlignment(.center); Text("by \(album.formattedArtists)") .font(neumorphicFont(size: 15)) .foregroundColor(DarkNeumorphicTheme.secondaryText) .multilineTextAlignment(.center); Text("\(album.album_type.capitalized) • \(album.formattedReleaseDate())") .font(neumorphicFont(size: 12, weight: .medium)) .foregroundColor(DarkNeumorphicTheme.secondaryText.opacity(0.8)) }.padding(.horizontal) } }
////}
////
////struct SpotifyEmbedPlayerView: View { // Uses gold accent for tint/status
////    @ObservedObject var playbackState: SpotifyPlaybackState; let spotifyUri: String?; private let playerCornerRadius: CGFloat = 15
////    var body: some View { VStack(spacing: 8) { SpotifyEmbedWebView(playbackState: playbackState, spotifyUri: spotifyUri) .frame(height: 80) .clipShape(RoundedRectangle(cornerRadius: playerCornerRadius)) .disabled(!playbackState.isReady) .overlay(Group { if !playbackState.isReady { ProgressView().tint(DarkNeumorphicTheme.accentColor) } else if let error = playbackState.error { VStack { Image(systemName: "exclamationmark.triangle").foregroundColor(DarkNeumorphicTheme.errorColor); Text(error).font(.caption).foregroundColor(DarNeumorphicTheme.errorColor).lineLimit(1) }.padding(5) } }) .background(RoundedRectangle(cornerRadius: playerCornerRadius).fill(DarkNeumorphicTheme.elementBackground).modifier(NeumorphicOuterShadow(cornerRadius: playerCornerRadius))); HStack { if let error = playbackState.error, !error.isEmpty { Text("Error:\(error)").font(neumorphicFont(size: 10, weight: .medium)).foregroundColor(DarkNeumorphicTheme.errorColor).lineLimit(1).frame(maxWidth: .infinity, alignment: .leading) } else if !playbackState.isReady { Text("Loading Player...").font(neumorphicFont(size: 10)).foregroundColor(DarkNeumorphicTheme.secondaryText).frame(maxWidth: .infinity, alignment: .leading) } else if playbackState.duration > 0.1 { Text(playbackState.isPlaying ? "Playing" : "Paused").font(neumorphicFont(size: 10)).foregroundColor(playbackState.isPlaying ? DarkNeumorphicTheme.accentColor : DarkNeumorphicTheme.secondaryText); Spacer(); Text("\(formatTime(playbackState.currentPosition)) / \(formatTime(playbackState.duration))").font(neumorphicFont(size: 10)).foregroundColor(DarkNeumorphicTheme.secondaryText).frame(width: 90, alignment: .trailing) } else { Text("Ready").font(neumorphicFont(size: 10)).foregroundColor(DarkNeumorphicTheme.secondaryText).frame(maxWidth: .infinity, alignment: .leading) } }.padding(.horizontal, 8).frame(height: 15) } private func formatTime(_ time: Double) -> String { let t = max(0, Int(time)); return String(format: "%d:%02d", t/60, t%60) }
////    }
////
////    struct TracksSectionView: View { // Uses gold accent for selected state
////        let tracks: [Track]; let isLoading: Bool; let error: SpotifyAPIError?; @Binding var selectedTrackUri: String?; let retryAction: () -> Void; private let sectionCornerRadius: CGFloat = 20
////        var body: some View { VStack(alignment: .leading, spacing: 0) { Text("Tracks") .font(neumorphicFont(size: 16, weight: .semibold)) .foregroundColor(DarkNeumorphicTheme.primaryText) .padding([.horizontal, .bottom], 10); Group { if isLoading { HStack { Spacer(); ProgressView().tint(DarkNeumorphicTheme.accentColor); Text("Loading...").font(neumorphicFont(size:14)).foregroundColor(DarkNeumorphicTheme.secondaryText); Spacer() }.padding(.vertical, 30) } else if let error = error { ErrorPlaceholderView(error: error, retryAction: retryAction).padding(.vertical, 20) } else if tracks.isEmpty { Text("No tracks").font(neumorphicFont(size:14)).foregroundColor(DarkNeumorphicTheme.secondaryText).frame(maxWidth: .infinity).padding(.vertical, 30) } else { VStack(spacing: 0) { ForEach(tracks) { track in NeumorphicTrackRow(track: track, isSelected: track.uri == selectedTrackUri) .contentShape(Rectangle()) .onTapGesture { selectedTrackUri = track.uri } Divider().background(DarkNeumorphicTheme.background.opacity(0.5)).padding(.horizontal, 5) } } } }.padding(10) .background(RoundedRectangle(cornerRadius: sectionCornerRadius).fill(DarkNeumorphicTheme.elementBackground).modifier(NeumorphicOuterShadow(cornerRadius: sectionCornerRadius))) .padding(.horizontal) }
////        }
////
////        struct NeumorphicTrackRow: View { // Uses gold accent for selected state
////            let track: Track
////            let isSelected: Bool
////
////            var body: some View {
////                HStack(spacing: 12) {
////                    Text("\(track.track_number)")
////                        .font(neumorphicFont(size: 12, weight: .medium))
////                        .foregroundColor(isSelected ? DarkNeumorphicTheme.accentColor : DarkNeumorphicTheme.secondaryText) // Gold if selected
////                        .frame(width: 20, alignment: .center)
////
////                    VStack(alignment: .leading, spacing: 2) {
////                        Text(track.name)
////                            .font(neumorphicFont(size: 14, weight: isSelected ? .semibold : .medium)) // Bolder if selected
////                            .foregroundColor(DarkNeumorphicTheme.primaryText) // Still white for readability
////                            .lineLimit(1)
////
////                        Text(track.formattedArtists)
////                            .font(neumorphicFont(size: 11))
////                            .foregroundColor(DarkNeumorphicTheme.secondaryText)
////                            .lineLimit(1)
////                    }
////
////                    Spacer()
////
////                    Text(track.formattedDuration)
////                        .font(neumorphicFont(size: 12, weight: .medium))
////                        .foregroundColor(DarkNeumorphicTheme.secondaryText)
////                        .frame(width: 40, alignment: .trailing)
////
////                    // Play Indicator uses gold
////                    Image(systemName: isSelected ? "speaker.wave.2.fill" : "play.fill") // Filled play icon for consistency
////                        .font(.system(size: 12))
////                        .foregroundColor(isSelected ? DarkNeumorphicTheme.accentColor : DarkNeumorphicTheme.secondaryText.opacity(0.6)) // Gold if selected
////                        .frame(width: 20, alignment: .center)
////                        .animation(.easeInOut(duration: 0.2), value: isSelected)
////
////                }
////                .padding(.vertical, 10)
////                .padding(.horizontal, 5)
////                .background(isSelected ? DarkNeumorphicTheme.accentColor.opacity(0.15) : Color.clear) // Subtle gold background highlight
////                .cornerRadius(6) // Slightly round the highlight
////            }
////        }
////
////        // MARK: Other Supporting Views (Themed)
////
////        //        struct AlbumImageView: View { // Uses gold accent for loading/error
////        //            let url: URL?; private let placeholderCornerRadius: CGFloat = 8
////        //            var body: some View { AsyncImage(url: url) { phase in switch phase { case .empty: ZStack { RoundedRectangle(cornerRadius: placeholderCornerRadius).fill(DarkNeumorphicTheme.elementBackground).modifier(NeumorphicInnerShadow(cornerRadius: placeholderCornerRadius)); ProgressView().tint(DarkNeumorphicTheme.accentColor.opacity(0.8)) }; case .success(let i): i.resizable().scaledToFit(); case .failure: ZStack { RoundedRectangle(cornerRadius: placeholderCornerRadius).fill(DarkNeumorphicTheme.elementBackground).modifier(NeumorphicInnerShadow(cornerRadius: placeholderCornerRadius)); Image(systemName: "photo.fill.on.rectangle.fill").resizable().scaledToFit().foregroundColor(DarkNeumorphicTheme.secondaryText.opacity(0.4)).padding(15) }; @unknown default: EmptyView() } } }
////        //        }
////
////        struct SearchMetadataHeader: View { // Unchanged appearance logic
////            let totalResults: Int; let limit: Int; let offset: Int
////            var body: some View { HStack { Text("Results: \(totalResults)"); Spacer(); if totalResults > limit { Text("Showing: \(offset+1)-\(min(offset+limit, totalResults))") } }.font(neumorphicFont(size:11)).foregroundColor(DarkNeumorphicTheme.secondaryText).padding(.vertical, 5) }
////        }
////
////        // MARK: --> Reusable Neumorphic Button (Gold Themed)
////        struct ThemedNeumorphicButton: View {
////            let text: String
////            var iconName: String? = nil
////            let action: () -> Void
////
////            var body: some View {
////                Button(action: action) {
////                    HStack(spacing: 8) {
////                        if let iconName = iconName {
////                            Image(systemName: iconName)
////                        }
////                        Text(text)
////                    }
////                    .font(neumorphicFont(size: 15, weight: .semibold))
////                    .foregroundColor(DarkNeumorphicTheme.background) // Dark text on gold gradient button
////                }
////                .buttonStyle(NeumorphicButtonStyle()) // Applies the style with gradient background
////            }
////        }
////
////        // Specific implementation for the external link button
////        struct ExternalLinkButton: View {
////            let text: String = "Open in Spotify"
////            let url: URL
////            @Environment(\.openURL) var openURL
////
////            var body: some View {
////                ThemedNeumorphicButton(text: text, iconName: "arrow.up.forward.app") {
////                    openURL(url) { accepted in if !accepted { print("⚠️ OS Cannot open URL: \(url)") } }
////                }
////            }
////        }
////
////        // MARK: - Preview Providers (Updated for Gold Theme)
////
////        struct SpotifyAlbumListView_Previews: PreviewProvider { static var previews: some View { SpotifyAlbumListView().preferredColorScheme(.dark) } }
////        struct NeumorphicAlbumCard_Previews: PreviewProvider { static let mockArtist = Artist(id: "a1", external_urls: nil, href: "", name: "Miles (Preview)", type: "artist", uri: ""); static let mockImage = SpotifyImage(height: 300, url: "https://i.scdn.co/image/ab67616d00001e027ab89c25093ea3787b1995b4", width: 300); static let mockAlbumItem = AlbumItem(id: "b1", album_type: "album", total_tracks: 5, available_markets: ["US"], external_urls: ExternalUrls(spotify: ""), href: "", images: [mockImage], name: "Kind of Blue [PREVIEW]", release_date: "1959-08-17", release_date_precision: "day", type: "album", uri: "spotify:album:1weenld61qoidwYuZ1GESA", artists: [mockArtist]); static var previews: some View { NeumorphicAlbumCard(album: mockAlbumItem).padding().background(DarkNeumorphicTheme.background).previewLayout(.fixed(width: 380, height: 140)).preferredColorScheme(.dark) } }
////        struct AlbumDetailView_Previews: PreviewProvider { static let mockArtist = Artist(id: "a1", external_urls: nil, href: "", name: "Miles Davis Preview", type: "artist", uri: ""); static let mockImage = SpotifyImage(height: 640, url: "https://i.scdn.co/image/ab67616d0000b2737ab89c25093ea3787b1995b4", width: 640); static let mockAlbum = AlbumItem(id: "1weenld61qoidwYuZ1GESA", album_type: "album", total_tracks: 5, available_markets: ["US"], external_urls: ExternalUrls(spotify: "https://open.spotify.com/album/1weenld61qoidwYuZ1GESA"), href: "", images: [mockImage], name: "Kind Of Blue (Preview)", release_date: "1959-08-17", release_date_precision: "day", type: "album", uri: "spotify:album:1weenld61qoidwYuZ1GESA", artists: [mockArtist]); static var previews: some View { NavigationView { AlbumDetailView(album: mockAlbum) }.preferredColorScheme(.dark) } }
////    }
////}
////
//
//// MARK: - App Entry Point
//
//@main
//struct SpotifyNeumorphicApp: App {
//    init() {
//        if placeholderSpotifyToken == "YOUR_SPOTIFY_BEARER_TOKEN_HERE" { print("🚨 WARNING: Spotify Bearer Token is NOT SET!") }
//        
//        // Global Navigation Bar Appearance (Dark Neumorphic + Gold Tint)
//        let appearance = UINavigationBarAppearance()
//        appearance.configureWithOpaqueBackground()
//        appearance.backgroundColor = DarkNeumorphicTheme.elementBackground.uiColor // Bar background
//        appearance.titleTextAttributes = [.foregroundColor: DarkNeumorphicTheme.primaryText.uiColor]
//        appearance.largeTitleTextAttributes = [.foregroundColor: DarkNeumorphicTheme.primaryText.uiColor]
//        appearance.shadowColor = .clear // No default line
//        
//        UINavigationBar.appearance().standardAppearance = appearance
//        UINavigationBar.appearance().scrollEdgeAppearance = appearance
//        UINavigationBar.appearance().compactAppearance = appearance
//        UINavigationBar.appearance().tintColor = DarkNeumorphicTheme.accentColor.uiColor // Gold back button, etc.
//    }
//    
//    var body: some Scene {
//        WindowGroup {
//            EmptyView()
//            //            SpotifyAlbumListView()
//            //                .preferredColorScheme(.dark) // Enforce dark mode
//        }
//    }
//}
