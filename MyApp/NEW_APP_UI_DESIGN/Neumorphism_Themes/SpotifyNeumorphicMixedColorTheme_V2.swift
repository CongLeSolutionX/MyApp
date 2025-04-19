////
////  SpotifyNeumorphicMixedColorTheme_V2.swift
////  MyApp
////
////  Created by Cong Le on 4/19/25.
////
//
////
////  SpotifyNeumorphicAppHSBP3.swift
//
//
//import SwiftUI
//@preconcurrency import WebKit // For Spotify Embed WebView
//import Foundation
//
//// MARK: - Provided Color Palettes (For Reference & Use)
//
///// Palette using the Display P3 color space for potentially more vibrant colors
///// on compatible wide-gamut displays. These are constant colors.
//struct DisplayP3Palette {
//    /// A vibrant red, potentially outside the standard sRGB gamut.
//    static let vibrantRed: Color = Color(.displayP3, red: 1.0, green: 0.1, blue: 0.1, opacity: 1.0)
//    
//    /// A lush green, potentially more saturated than standard sRGB greens.
//    static let lushGreen: Color = Color(.displayP3, red: 0.1, green: 0.9, blue: 0.2, opacity: 1.0)
//    
//    /// A deep P3 blue.
//    static let deepBlue: Color = Color(.displayP3, red: 0.1, green: 0.2, blue: 0.95, opacity: 1.0)
//    
//    /// A bright P3 magenta.
//    static let brightMagenta: Color = Color(.displayP3, red: 0.95, green: 0.1, blue: 0.8, opacity: 1.0)
//}
//
///// Palette demonstrating the use of extended range values (outside 0.0-1.0).
///// The visual effect heavily depends on the display's capabilities and how
///// the system renders these values. These are constant colors.
//struct ExtendedRangePalette {
//    /// An 'ultra' white using a value greater than 1.0 (effect varies by display/context).
//    /// On HDR displays, this might appear brighter than standard white.
//    static let ultraWhite: Color = Color(.sRGB, white: 1.1, opacity: 1.0) // Note: Value > 1.0
//    
//    /// A potentially more intense red by exceeding the 1.0 limit for the red component.
//    static let intenseRed: Color = Color(.sRGB, red: 1.2, green: 0, blue: 0, opacity: 1.0) // Note: Value > 1.0
//    
//    /// A potentially darker-than-black using a negative value (effect varies).
//    /// This might just clamp to black (0.0) on standard displays.
//    static let deeperThanBlack: Color = Color(.sRGB, white: -0.1, opacity: 1.0) // Nste: Value < 0.0
//}
//
///// Standard HSB Palette for comparison and completeness (Constant Colors)
//struct HSBPalette {
//    static let sunshineYellow: Color = Color(hue: 0.15, saturation: 0.9, brightness: 1.0) // 54 degrees
//    static let skyBlue: Color = Color(hue: 0.6, saturation: 0.7, brightness: 0.9)       // 216 degrees
//    static let forestGreen: Color = Color(hue: 0.35, saturation: 0.8, brightness: 0.6)   // 126 degrees
//    static let fieryOrange: Color = Color(hue: 0.08, saturation: 1.0, brightness: 1.0)   // 29 degrees
//}
//
///// Standard Grayscale Palette (Constant Colors)
//struct GrayscalePalette {
//    static let lightGray: Color = Color(white: 0.8)
//    static let mediumGray: Color = Color(white: 0.5)
//    static let darkGray: Color = Color(white: 0.2)
//}
//
//// MARK: - Dark Neumorphism Theme Constants & Helpers (UPDATED with Palette Colors)
//
//struct DarkNeumorphicTheme {
//    // Core Neumorphic Structure Colors (Kept Dark)
//    static let background = Color(red: 0.14, green: 0.16, blue: 0.19) // Dark gray base
//    static let elementBackground = Color(red: 0.18, green: 0.20, blue: 0.23) // Slightly lighter for elements
//    static let lightShadow = Color.white.opacity(0.1) // Subtle white highlight
//    static let darkShadow = Color.black.opacity(0.5)  // Deeper black shadow
//    
//    // Text Colors (Standard Dark Theme Contrast)
//    static let primaryText = Color.white.opacity(0.85)
//    static let secondaryText = Color.gray.opacity(0.8) // Slightly increased opacity
//    
//    // --- Accent Colors from Provided Palettes ---
//    
//    /// Primary Accent Color for interactive elements, selections, etc.
//    /// Using HSBPalette.skyBlue
//    static let accentColor: Color = HSBPalette.skyBlue
//    
//    /// Error Color for placeholders, alerts, etc.
//    /// Using DisplayP3Palette.vibrantRed (may appear different based on display gamut)
//    static let errorColor: Color = DisplayP3Palette.vibrantRed
//    
//    // Shadow Parameters (Unchanged)
//    static let shadowRadius: CGFloat = 6
//    static let shadowOffset: CGFloat = 4
//}
//
//// Font helper (using system fonts for simplicity)
//func neumorphicFont(
//    size: CGFloat,
//    weight: Font.Weight = .regular,
//    design: Font.Design = .default
//) -> Font {
//    return Font.system(size: size, weight: weight, design: design)
//}
//
////MARK: -> Neumorphic View Modifiers / Styles (Unchanged Logic)
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
//                    .fill(DarkNeumorphicTheme.elementBackground)
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
//// --- Inner Shadow for Depressed Elements (More complex) ---
//struct NeumorphicInnerShadow: ViewModifier {
//    let cornerRadius: CGFloat = 15
//    
//    func body(content: Content) -> some View {
//        // Approximation
//        content
//            .padding(2)
//            .background(DarkNeumorphicTheme.elementBackground)
//            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
//            .overlay(
//                RoundedRectangle(cornerRadius: cornerRadius)
//                    .stroke(DarkNeumorphicTheme.background, lineWidth: 4)
//                    .shadow(color: DarkNeumorphicTheme.darkShadow,
//                            radius: DarkNeumorphicTheme.shadowRadius - 1,
//                            x: DarkNeumorphicTheme.shadowOffset - 1,
//                            y: DarkNeumorphicTheme.shadowOffset - 1)
//                    .shadow(color: DarkNeumorphicTheme.lightShadow,
//                            radius: DarkNeumorphicTheme.shadowRadius - 1,
//                            x: -(DarkNeumorphicTheme.shadowOffset - 1),
//                            y: -(DarkNeumorphicTheme.shadowOffset - 1))
//                    .clipShape(
//                        RoundedRectangle(cornerRadius: cornerRadius)
//                    )
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
//            .animation(
//                .spring(
//                    response: 0.3,
//                    dampingFraction: 0.6),
//                value: configuration.isPressed
//            )
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
//                .fill(DarkNeumorphicTheme.elementBackground)
//            
//            if isPressed {
//                RoundedRectangle(cornerRadius: cornerRadius)
//                    .stroke(DarkNeumorphicTheme.elementBackground, lineWidth: 4)
//                    .shadow(color: DarkNeumorphicTheme.darkShadow,
//                            radius: DarkNeumorphicTheme.shadowRadius / 2,
//                            x: DarkNeumorphicTheme.shadowOffset / 2,
//                            y: DarkNeumorphicTheme.shadowOffset / 2
//                    )
//                    .shadow(color: DarkNeumorphicTheme.lightShadow,
//                            radius: DarkNeumorphicTheme.shadowRadius / 2,
//                            x: -DarkNeumorphicTheme.shadowOffset / 2,
//                            y: -DarkNeumorphicTheme.shadowOffset / 2
//                    )
//                    .clipShape(RoundedRectangle(
//                        cornerRadius: cornerRadius)
//                    )
//            } else {
//                RoundedRectangle(cornerRadius: cornerRadius)
//                    .fill(DarkNeumorphicTheme.elementBackground)
//                    .shadow(color: DarkNeumorphicTheme.darkShadow,
//                            radius: DarkNeumorphicTheme.shadowRadius,
//                            x: DarkNeumorphicTheme.shadowOffset,
//                            y: DarkNeumorphicTheme.shadowOffset)
//                    .shadow(color: DarkNeumorphicTheme.lightShadow,
//                            radius: DarkNeumorphicTheme.shadowRadius,
//                            x: -DarkNeumorphicTheme.shadowOffset,
//                            y: -DarkNeumorphicTheme.shadowOffset
//                    )
//            }
//        }
//    }
//}
//
//// MARK: - Data Models
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
//    let id: String; let album_type: String; let total_tracks: Int
//    let available_markets: [String]?; let external_urls: ExternalUrls; let href: String
//    let images: [SpotifyImage]; let name: String; let release_date: String
//    let release_date_precision: String; let type: String; let uri: String
//    let artists: [Artist]
//    
//    var bestImageURL: URL? {
//        images.first { $0.width == 640 }?.urlObject ?? images.first { $0.width == 300 }?.urlObject ?? images.first?.urlObject
//    }
//    
//    var listImageURL: URL? {
//        images.first {
//            $0.width == 300
//        }?.urlObject ?? images.first {
//            $0.width == 64
//        }?.urlObject ?? images.first?.urlObject
//    }
//    
//    var formattedArtists: String {
//        artists.map {
//            $0.name
//        }.joined(separator: ", ")
//    }
//    
//    func formattedReleaseDate() -> String {
//        let dateFormatter = DateFormatter()
//        
//        switch release_date_precision {
//        case "year": 
//            dateFormatter.dateFormat = "yyyy"
//        case "month": 
//            dateFormatter.dateFormat = "yyyy-MM"
//            break // Format below
//        case "day": 
//            dateFormatter.dateFormat = "yyyy-MM-dd"
//            break // Format below
//        default:
//            return release_date
//        }
//        
//        guard let date = dateFormatter.date(from: release_date) else {
//            return release_date
//        }
//        
//        switch release_date_precision {
//        case "month": 
//            dateFormatter.dateFormat = "MMM yyyy"
//        case "day": 
//            dateFormatter.dateFormat = "d MMM yyyy"
//        default:
//            break // Year already handled
//        }
//        
//        return dateFormatter.string(from: date)
//    }
//}
//
//struct Artist: Codable, Identifiable, Hashable {
//    let id: String
//    let external_urls: ExternalUrls?
//    let href: String
//    let name: String
//    let type: String
//    let uri: String
//}
//
//struct SpotifyImage: Codable, Hashable {
//    let height: Int?
//    let url: String
//    let width: Int?
//    
//    var urlObject: URL? {
//        URL(string: url)
//    }
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
//    let type: String
//    let uri: String
//    
//    var previewURL: URL? {
//        if let url = preview_url {
//            return URL(string: url)
//        } else {
//            return nil
//        }
//    }
//    
//    var formattedDuration: String {
//        let s = duration_ms/1000
//        return String(format: "%d:%02d", s/60, s%60)
//    }
//    
//    var formattedArtists: String {
//        artists.map{ $0.name }.joined(separator: ", ")
//    }
//}
//
//// MARK: - API Service
//
//let placeholderSpotifyToken = "BQDecdEfP8UGT4NcbxCd1a-nWba4uLylowQ49dRj-1VGUXB4usjTny9JEL_2860Z9GGlEJL5bw21buTdu8asCC8i88Lto_A_YUmmRWa985Lsh7qOFoNcGDp64inY5y_jpk0dPdoZV_nBCeMkjuu4hGXQSshy7kvnI-UVcQKZldODuQkeQr_j1lCD1_uVkvk85ljemhUFqvD6kUqPQVo51tSbO_4zQyK2BSdEK-x5S3sLc_MYs1tG49DhjjH9Na2NYzIcjHmo8-V9MHw1imf0LJQBtOsYXxvYuziOG5mMyMr2VHocSd-ns28YyqienLT5" // <-- IMPORTANT: REPLACE THIS
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
//        case .invalidURL:
//            return "Invalid API URL."
//        case .networkError(let err):
//            return "Network issue: \(err.localizedDescription)"
//        case .invalidResponse(let code, _):
//            return "Server error (\(code))."
//        case .decodingError:
//            return "Failed to understand server response."
//        case .invalidToken:
//            return "Authentication failed. Check Token."
//        case .missingData:
//            return "Response missing data."
//        }
//    }
//}
//
//struct SpotifyAPIService {
//    static let shared = SpotifyAPIService()
//    private let session: URLSession
//    
//    init() {
//        let config = URLSessionConfiguration.default
//        config.requestCachePolicy = .reloadIgnoringLocalCacheData
//        session = URLSession(configuration: config)
//    }
//    
//    private func makeRequest<T: Decodable>(url: URL) async throws -> T {
//        guard !placeholderSpotifyToken.isEmpty,
//              placeholderSpotifyToken != "YOUR_SPOTIFY_BEARER_TOKEN_HERE" else {
//            throw SpotifyAPIError.invalidToken
//        }
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//        
//        request.setValue(
//            "Bearer \(placeholderSpotifyToken)",
//            forHTTPHeaderField: "Authorization"
//        )
//        
//        request.setValue(
//            "application/json",
//            forHTTPHeaderField: "Accept"
//        )
//        
//        request.timeoutInterval = 20
//        
//        print("🎶 Requesting: \(url.absoluteString)")
//        
//        do {
//            let (data, response) = try await session.data(for: request)
//            
//            guard let http = response as? HTTPURLResponse else {
//                throw SpotifyAPIError.invalidResponse(0, "Not HTTP.")
//            }
//            print("🚦 HTTP Status: \(http.statusCode)")
//            
//            let body = String(data: data, encoding: .utf8) ?? "N/A"
//            
//            guard (200...299).contains(http.statusCode) else {
//                if http.statusCode == 401 {
//                    throw SpotifyAPIError.invalidToken
//                }
//                print("❌ Server Error Body: \(body)")
//                
//                throw SpotifyAPIError.invalidResponse(http.statusCode, body)
//            }
//            
//            do {
//                return try JSONDecoder().decode(T.self, from: data)
//            } catch {
//                print("❌ Decoding Error for \(T.self): \(error)\n   Body: \(body)")
//                throw SpotifyAPIError.decodingError(error)
//            }
//        } catch let error where !(error is CancellationError) {
//            print("❌ Network Error: \(error)")
//            throw error is SpotifyAPIError ? error : SpotifyAPIError.networkError(error)
//        }
//    }
//    
//    func searchAlbums(
//        query: String,
//        limit: Int = 20,
//        offset: Int = 0
//    ) async throws -> SpotifySearchResponse {
//        var comp = URLComponents(string: "https://api.spotify.com/v1/search")
//        
//        comp?.queryItems = [
//            URLQueryItem(name: "q", value: query),
//            URLQueryItem(name: "type", value: "album"),
//            URLQueryItem(name: "include_external", value: "audio"),
//            URLQueryItem(name: "limit", value: "\(limit)"),
//            URLQueryItem(name: "offset", value: "\(offset)")
//        ]
//        
//        guard let url = comp?.url else {
//            throw SpotifyAPIError.invalidURL
//        }
//        
//        return try await makeRequest(url: url)
//    }
//    
//    func getAlbumTracks(
//        albumId: String,
//        limit: Int = 50,
//        offset: Int = 0
//    ) async throws -> AlbumTracksResponse {
//        var comp = URLComponents(string: "https://api.spotify.com/v1/albums/\(albumId)/tracks")
//        
//        comp?.queryItems = [
//            URLQueryItem(name: "limit", value: "\(limit)"),
//            URLQueryItem(name: "offset", value: "\(offset)")
//        ]
//        
//        guard let url = comp?.url else {
//            throw SpotifyAPIError.invalidURL
//        }
//        
//        return try await makeRequest(url: url)
//    }
//}
//
//// MARK: - Spotify Embed WebView
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
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//    
//    func makeUIView(context: Context) -> WKWebView {
//        let userCC = WKUserContentController()
//        userCC.add(context.coordinator, name: "spotifyController")
//        
//        let config = WKWebViewConfiguration()
//        config.userContentController = userCC
//        config.allowsInlineMediaPlayback = true
//        config.mediaTypesRequiringUserActionForPlayback = []
//        
//        let webView = WKWebView(frame: .zero, configuration: config)
//        webView.navigationDelegate = context.coordinator
//        webView.uiDelegate = context.coordinator
//        webView.isOpaque = false
//        webView.backgroundColor = .clear
//        webView.scrollView.isScrollEnabled = false
//        webView.loadHTMLString(generateHTML(), baseURL: nil)
//        context.coordinator.webView = webView
//        
//        return webView
//    }
//    
//    func updateUIView(_ webView: WKWebView, context: Context) {
//        if context.coordinator.isApiReady &&
//            context.coordinator.lastLoadedUri != spotifyUri {
//            context.coordinator.loadUri(spotifyUri ?? "")
//        } else if !context.coordinator.isApiReady {
//            context.coordinator.updateDesiredUriBeforeReady(spotifyUri ?? "")
//        }
//    }
//    
//    static func dismantleUIView(_ webView: WKWebView, coordinator: Coordinator) {
//        webView.stopLoading()
//        webView.configuration.userContentController.removeScriptMessageHandler(forName: "spotifyController")
//        coordinator.webView = nil
//    }
//    
//    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
//        var parent: SpotifyEmbedWebView
//        weak var webView: WKWebView?
//        var isApiReady = false
//        var lastLoadedUri: String?
//        private var desiredUriBeforeReady: String? = nil
//        
//        init(_ p: SpotifyEmbedWebView) {
//            parent = p
//        }
//        
//        func updateDesiredUriBeforeReady(_ u: String?) {
//            if !isApiReady {
//                desiredUriBeforeReady = u
//            }
//        }
//        
//        func webView(_ wV: WKWebView, didFinish n: WKNavigation!) {
//            print("📄 Embed HTML loaded.")
//        }
//        
//        func webView(_ Wv: WKWebView,
//                     didFail n: WKNavigation!,
//                     withError e: Error
//        ) {
//            print("❌ Embed Nav failed: \(e)")
//            
//            DispatchQueue.main.async{
//                self.parent.playbackState.error = "WebView Nav Fail"
//            }
//        }
//        
//        func webView(_ wV: WKWebView,
//                     didFailProvisionalNavigation n: WKNavigation!,
//                     withError e: Error
//        ) {
//            print("❌ Embed Prov Nav failed: \(e)")
//            DispatchQueue.main.async{
//                self.parent.playbackState.error = "WebView Prov Nav Fail"
//            }
//        }
//        
//        func userContentController(_ uCC: WKUserContentController,
//                                   didReceive m: WKScriptMessage
//        ) {
//            guard m.name == "spotifyController" else {
//                return
//            }
//            
//            if let body = m.body as? [String: Any],
//               let event = body["event"] as? String {
//                handleEvent(event: event, data: body["data"])
//            } else if let body = m.body as? String {
//                if body == "ready" { handleApiReady()
//                }
//            } else {
//                print("❓ Embed Unknown JS msg: \(m.body)")
//            }
//        }
//        
//        private func handleApiReady() {
//            print("✅ Embed API Ready.")
//            isApiReady = true
//            DispatchQueue.main.async {
//                self.parent.playbackState.isReady = true
//            }
//            
//            if let uri = desiredUriBeforeReady ?? parent.spotifyUri {
//                createSpotifyController(with: uri)
//                desiredUriBeforeReady = nil
//            }
//        }
//        
//        private func handleEvent(event: String, data: Any?) {
//            switch event {
//            case "controllerCreated":
//                print("✅ Embed Controller Created.")
//            case "playbackUpdate":
//                if let d = data as? [String: Any] {
//                    updatePlaybackState(with: d)
//                }
//            case "error":
//                let msg = (data as? [String: Any])?["message"] as? String ??
//                (data as? String) ??
//                "JS error"
//                
//                print("❌ Embed JS Error: \(msg)")
//                
//                DispatchQueue.main.async {
//                    self.parent.playbackState.error = msg
//                }
//                
//            default:
//                print("❓ Embed Unknown event: \(event)")
//            }
//        }
//        
//        private func updatePlaybackState(with d: [String: Any]) {
//            DispatchQueue.main.async { [weak self] in
//                guard let self = self else { return }
//                var changed = false
//                
//                if let p = d["paused"] as? Bool,
//                   self.parent.playbackState.isPlaying == p {
//                    self.parent.playbackState.isPlaying = !p
//                    changed = true
//                }
//                
//                if let pos = d["position"] as? Double,
//                   abs(self.parent.playbackState.currentPosition - pos/1000.0) > 0.1 {
//                    self.parent.playbackState.currentPosition = pos/1000.0
//                    changed = true
//                }
//                
//                if let dur = d["duration"] as? Double,
//                   abs(self.parent.playbackState.duration - dur/1000.0) > 0.1 ||
//                    self.parent.playbackState.duration == 0 {
//                    self.parent.playbackState.duration = dur/1000.0
//                    
//                    changed = true
//                }
//                
//                if let uri = d["uri"] as? String,
//                   self.parent.playbackState.currentUri != uri {
//                    self.parent.playbackState.currentUri = uri
//                    self.parent.playbackState.currentPosition = 0
//                    self.parent.playbackState.duration = d["duration"] as? Double ?? 0
//                    
//                    changed = true
//                }
//                
//                if changed && self.parent.playbackState.error != nil {
//                    self.parent.playbackState.error = nil
//                }
//            }
//        }
//        
//        private func createSpotifyController(with u: String) {
//            
//            guard let wV = webView, isApiReady else {
//                return
//            }
//            
//            guard lastLoadedUri == nil else {
//                if let latest = desiredUriBeforeReady ?? parent.spotifyUri,
//                   
//                    latest != lastLoadedUri {
//                    loadUri(latest)
//                }
//                
//                desiredUriBeforeReady = nil
//                
//                return
//            }
//            
//            print("🚀 Embed Creating controller: \(u)")
//            
//            lastLoadedUri = u
//            
//            let script = """
//            window.embedController=null;const el=document.getElementById('embed-iframe');
//            if(!el || !window.IFrameAPI){ console.error('JS Err: El/API missing'); window.webkit?.messageHandlers?.spotifyController?.postMessage({event:'error',data:{message:'DOM/API Error'}}); return; }
//            const options={uri:'\(u)',width:'100%',height:'100%'};
//            const cb=(c)=>{if(!c){console.error('JS Err: null controller');window.webkit?.messageHandlers?.spotifyController?.postMessage({event:'error',data:{message:'Null Controller'}});return;} window.embedController=c;window.webkit?.messageHandlers?.spotifyController?.postMessage({event:'controllerCreated'});c.addListener('ready',()=>{});c.addListener('playback_update',e=>{window.webkit?.messageHandlers?.spotifyController?.postMessage({event:'playbackUpdate',data:e.data});});c.addListener('account_error',e=>{window.webkit?.messageHandlers?.spotifyController?.postMessage({event:'error',data:{message:'Account Error: '+(e.data?.message??'Premium/Login Required')}});});c.addListener('autoplay_failed',()=>{c.play();});c.addListener('initialization_error',e=>{window.webkit?.messageHandlers?.spotifyController?.postMessage({event:'error',data:{message:'Init Error: '+(e.data?.message??'Failed to init')}});});};
//            try{window.IFrameAPI.createController(el,options,cb);}catch(e){console.error('JS Create Err:',e);window.webkit?.messageHandlers?.spotifyController?.postMessage({event:'error',data:{message:'JS Ex: '+e.message}}); lastLoadedUri=null;}
//            """
//            
//            wV.evaluateJavaScript(script) {_, e in
//                if let e = e {
//                    print("⚠️ Embed JS Eval Err (create): \(e)")
//                }
//            }
//        }
//        
//        func loadUri(_ uri: String) {
//            guard let wV = webView, isApiReady else {
//                return
//            }
//            
//            guard let loaded = lastLoadedUri, loaded != uri else {
//                return
//            } // Check if already loaded
//            
//            print("🚀 Embed Loading new URI: \(uri)")
//            
//            lastLoadedUri = uri
//            
//            let script = "if(window.embedController){window.embedController.loadUri('\(uri)');window.embedController.play();}else{console.error('JS Err: No controller for loadUri \(uri)');window.webkit?.messageHandlers?.spotifyController?.postMessage({event:'error',data:{message:'JS Controller Missing'}});}"
//            
//            
//            wV.evaluateJavaScript(script) { _, e in
//                if let e = e {
//                    print("⚠️ Embed JS Eval Err (load): \(e)")
//                }
//            }
//        }
//        func webView(_ wV: WKWebView,
//                     runJavaScriptAlertPanelWithMessage m: String,
//                     initiatedByFrame f: WKFrameInfo,
//                     completionHandler: @escaping () -> Void
//        ) {
//            print("ℹ️ Embed JS Alert: \(m)")
//            
//            completionHandler()
//        }
//    }
//    
//    private func generateHTML() -> String { // Minified HTML structure
//        return """
//        <!DOCTYPE html><html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1,maximum-scale=1,user-scalable=no"><title>Embed</title><style>html,body{margin:0;padding:0;width:100%;height:100%;overflow:hidden;background:transparent}#embed-iframe{width:100%;height:100%;display:block;border:none}</style></head><body><div id="embed-iframe"></div><script src="https://open.spotify.com/embed/iframe-api/v1" async></script><script>var cbSet=false;window.onSpotifyIframeApiReady=I=>{if(cbSet)return;window.IFrameAPI=I;cbSet=true;if(window.webkit?.messageHandlers?.spotifyController)window.webkit.messageHandlers.spotifyController.postMessage("ready");else console.error('JS Err: Handler missing')};const s=document.querySelector('script[src*="iframe-api"]');if(s)s.onerror=e=>{console.error('JS Err: API script load fail:',e);window.webkit?.messageHandlers?.spotifyController?.postMessage({event:'error',data:{message:'API Script Load Fail'}})}</script></body></html>
//        """
//    }
//}
//
//// MARK: - SwiftUI Views (Dark Neumorphism Themed with HSB/P3 Accents)
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
//                DarkNeumorphicTheme.background.ignoresSafeArea()
//                
//                VStack(spacing: 0) {
//                    Group { // Content switcher
//                        if isLoading && displayedAlbums.isEmpty {
//                            loadingIndicator
//                        } else if let error = currentError {
//                            ErrorPlaceholderView(error: error) {
//                                Task {
//                                    await performDebouncedSearch(immediate: true)
//                                }
//                            }
//                        } else if displayedAlbums.isEmpty && !searchQuery.isEmpty {
//                            EmptyStatePlaceholderView(searchQuery: searchQuery)
//                        } else if displayedAlbums.isEmpty && searchQuery.isEmpty {
//                            EmptyStatePlaceholderView(searchQuery: "")
//                        } else { albumScrollView
//                        }
//                    }
//                    .frame(maxWidth: .infinity, maxHeight: .infinity)
//                }
//            }
//            .navigationTitle("Spotify Search")
//            .navigationBarTitleDisplayMode(.large)
//            .toolbarBackground(
//                DarkNeumorphicTheme.elementBackground,
//                for: .navigationBar
//            ) // Themed nav bar BG
//            .toolbarBackground(.visible, for: .navigationBar)
//            .toolbarColorScheme(.dark, for: .navigationBar) // Ensures title/buttons are light
//            // Search Bar
//            .searchable(
//                text: $searchQuery,
//                placement: .navigationBarDrawer(displayMode: .always),
//                prompt: Text("Search Albums / Artists").foregroundColor(.gray)
//            )
//            .onSubmit(of: .search) {
//                Task {
//                    await performDebouncedSearch(immediate: true)
//                }
//            }
//            .task(id: searchQuery) {
//                await performDebouncedSearch()
//            }
//            .onChange(of: searchQuery) {
//                if currentError != nil {
//                    currentError = nil
//                }
//            }
//            .accentColor(DarkNeumorphicTheme.accentColor) // Use the new theme accent color
//        }
//        .navigationViewStyle(.stack)
//        .preferredColorScheme(.dark) // Ensure dark mode for the theme
//    }
//    
//    // Themed Scrollable Album List
//    private var albumScrollView: some View {
//        ScrollView {
//            LazyVStack(spacing: 18) {
//                if let info = searchInfo, info.total > 0 {
//                    SearchMetadataHeader(
//                        totalResults: info.total,
//                        limit: info.limit,
//                        offset: info.offset
//                    )
//                    .padding(.horizontal)
//                    .padding(.top, 5)
//                }
//                ForEach(displayedAlbums) { album in
//                    NavigationLink(destination: AlbumDetailView(album: album)) {
//                        NeumorphicAlbumCard(album: album)
//                    }.buttonStyle(.plain)
//                }
//            }
//            .padding(.horizontal)
//            .padding(.bottom)
//        }
//        .scrollDismissesKeyboard(.interactively)
//    }
//    
//    // Themed Loading Indicator
//    private var loadingIndicator: some View {
//        VStack {
//            ProgressView().progressViewStyle(
//                CircularProgressViewStyle(
//                    tint: DarkNeumorphicTheme.accentColor
//                )
//            ).scaleEffect(1.5) // Use theme accent
//            
//            
//            Text("Loading...")
//                .font(neumorphicFont(size: 14))
//                .foregroundColor(DarkNeumorphicTheme.secondaryText)
//                .padding(.top, 10)
//        }
//    }
//    
//    // Debounced Search Logic (Unchanged)
//    private func performDebouncedSearch(immediate: Bool = false) async {
//        
//        let query = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
//        
//        guard !query.isEmpty else {
//            await MainActor.run {
//                displayedAlbums = []
//                searchInfo = nil
//                isLoading = false
//                currentError = nil
//            }
//            return
//        }
//        
//        await MainActor.run {
//            isLoading = true
//        }
//        
//        if !immediate {
//            do {
//                try await Task.sleep(for: .milliseconds(500))
//                try Task.checkCancellation()
//            } catch {
//                await MainActor.run {
//                    isLoading = false
//                }
//                return
//            }
//        }
//        
//        guard query == searchQuery.trimmingCharacters(in: .whitespacesAndNewlines) else {
//            await MainActor.run {
//                isLoading = false
//            }
//            
//            return
//        }
//        
//        do {
//            print("🚀 Search: \(query)")
//            let resp = try await SpotifyAPIService.shared.searchAlbums(query: query)
//            try Task.checkCancellation()
//            
//            await MainActor.run {
//                displayedAlbums = resp.albums.items
//                searchInfo = resp.albums
//                
//                currentError = nil
//                isLoading = false
//                
//                print("✅ Loaded \(resp.albums.items.count)")
//            }
//        } catch is CancellationError {
//            await MainActor.run {
//                isLoading = false
//            }
//        } catch let apiError as SpotifyAPIError {
//            print("❌ API Err: \(apiError)")
//            
//            await MainActor.run {
//                displayedAlbums=[]
//                
//                searchInfo=nil
//                
//                currentError=apiError
//                
//                isLoading=false
//            }
//        } catch {
//            print("❌ Other Err: \(error)")
//            await MainActor.run {
//                displayedAlbums=[]
//                searchInfo=nil
//                currentError = .networkError(error)
//                
//                isLoading=false
//            }
//        }
//    }
//}
//
//// MARK: Neumorphic Album Card (Themed)
//struct NeumorphicAlbumCard: View {
//    let album: AlbumItem; private let cardCornerRadius: CGFloat = 20
//    var body: some View {
//        HStack(spacing: 15) {
//            AlbumImageView(url: album.listImageURL).frame(width: 80, height: 80).clipShape(RoundedRectangle(cornerRadius: 12))
//                .overlay(RoundedRectangle(cornerRadius: 12).stroke(DarkNeumorphicTheme.elementBackground.opacity(0.5), lineWidth: 1))
//            VStack(alignment: .leading, spacing: 4) {
//                Text(album.name).font(neumorphicFont(size: 15, weight: .semibold)).foregroundColor(DarkNeumorphicTheme.primaryText).lineLimit(2)
//                Text(album.formattedArtists).font(neumorphicFont(size: 13)).foregroundColor(DarkNeumorphicTheme.secondaryText).lineLimit(1)
//                Spacer()
//                HStack(spacing: 8) {
//                    Text(album.album_type.capitalized).font(neumorphicFont(size: 10, weight: .medium)).foregroundColor(DarkNeumorphicTheme.secondaryText).padding(.horizontal, 8).padding(.vertical, 3).background(DarkNeumorphicTheme.background.opacity(0.6), in: Capsule())
//                    Text("• \(album.formattedReleaseDate())").font(neumorphicFont(size: 10, weight: .medium)).foregroundColor(DarkNeumorphicTheme.secondaryText)
//                }
//                Text("\(album.total_tracks) Tracks").font(neumorphicFont(size: 10, weight: .medium)).foregroundColor(DarkNeumorphicTheme.secondaryText).padding(.top, 1)
//            }.frame(maxWidth: .infinity, alignment: .leading)
//        }.padding(15).modifier(NeumorphicOuterShadow()).frame(height: 110)
//    }
//}
//
//// MARK: Placeholders (Neumorphic Themed - Using new Accent/Error Colors)
//struct ErrorPlaceholderView: View {
//    let error: SpotifyAPIError
//    let retryAction: (() -> Void)?
//    
//    private let cornerRadius: CGFloat = 25
//    var body: some View {
//        VStack(spacing: 20) {
//            Image(systemName: iconName)
//                .font(.system(size: 50))
//                .foregroundColor(DarkNeumorphicTheme.errorColor) // Use P3 Red
//                .padding(25)
//                .background(
//                    Circle()
//                        .fill(DarkNeumorphicTheme.elementBackground)
//                        .shadow(
//                            color: DarkNeumorphicTheme.darkShadow,
//                            radius: 8,
//                            x: 5,
//                            y: 5
//                        ).shadow(
//                            color: DarkNeumorphicTheme.lightShadow,
//                            radius: 8,
//                            x: -5,
//                            y: -5
//                        )
//                ).padding(.bottom, 15)
//            
//            Text("Error")
//                .font(neumorphicFont(size: 20, weight: .bold))
//                .foregroundColor(DarkNeumorphicTheme.primaryText)
//            
//            Text(errorMessage)
//                .font(neumorphicFont(size: 14))
//                .foregroundColor(DarkNeumorphicTheme.secondaryText)
//                .multilineTextAlignment(.center)
//                .padding(.horizontal, 30)
//            
//            // --- Retry Button ---
//            switch error {
//            case .invalidToken:
//                Text("Please check the API token in the code.")
//                    .font(neumorphicFont(size: 13))
//                    .foregroundColor(DarkNeumorphicTheme.errorColor.opacity(0.9))
//                    .multilineTextAlignment(.center)
//                    .padding(.horizontal, 30) // Brighter error subtext
//            default:
//                if retryAction != nil {
//                    Button {
//                        retryAction?()
//                    } label: {
//                        
//                        Label("Retry", systemImage: "arrow.clockwise")
//                        .font(neumorphicFont(size: 15, weight: .semibold))
//                        .foregroundColor(DarkNeumorphicTheme.accentColor) } // Use HSB Blue
//                        .buttonStyle(NeumorphicButtonStyle())
//                        .padding(.top, 10)
//                }
//            }
//        }.padding(40)
//    }
//    private var iconName: String {
//        switch error {
//        case .invalidToken:
//            return "key.slash"
//        case .networkError:
//            return "wifi.slash"
//        case .invalidResponse, .decodingError, .missingData:
//            return "exclamationmark.triangle"
//        case .invalidURL:
//            return "link.badge.questionmark"
//        }
//    }
//    
//    private var errorMessage: String {
//        error.localizedDescription
//    }
//}
//
//struct EmptyStatePlaceholderView: View {
//    let searchQuery: String
//    var body: some View {
//        VStack(spacing: 20) {
//            Image(placeholderImageName)
//                .resizable()
//                .aspectRatio(contentMode: .fit)
//                .frame(height: 130)
//                .padding(isInitialState ? 25 : 15)
//                .background(Circle()
//                    .fill(DarkNeumorphicTheme.elementBackground)
//                    .shadow(color: DarkNeumorphicTheme.darkShadow, radius: 8, x: 5, y: 5)
//                    .shadow(color: DarkNeumorphicTheme.lightShadow, radius: 8, x: -5, y: -5))
//                .padding(.bottom, 15)
//            
//            Text(title)
//                .font(neumorphicFont(size: 20, weight: .bold))
//                .foregroundColor(DarkNeumorphicTheme.primaryText)
//            
//            Text(messageAttributedString)
//                .font(neumorphicFont(size: 14))
//                .foregroundColor(DarkNeumorphicTheme.secondaryText)
//                .multilineTextAlignment(.center)
//                .padding(.horizontal, 40)
//            
//        }.padding(30)
//    }
//    private var isInitialState: Bool {
//        searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
//    }
//    
//    private var placeholderImageName: String {
//        isInitialState ? "My-meme-microphone" : "My-meme-orange_2"
//    }
//    
//    private var title: String {
//        isInitialState ? "Spotify Search" : "No Results Found"
//    }
//    
//    private var messageAttributedString: AttributedString {
//        
//        var msg = isInitialState ?
//        "Enter an album or artist name\nin the search bar above to begin." :
//        "No matches found for \"\(searchQuery.replacingOccurrences(of: "*", with: "").replacingOccurrences(of: "_", with: ""))\".\nTry refining your search terms."
//        
//        var attr = AttributedString(msg)
//        attr.font = neumorphicFont(size: 14)
//        attr.foregroundColor = DarkNeumorphicTheme.secondaryText
//        
//        return attr
//    }
//}
//
//// MARK: Album Detail View (Themed)
//struct AlbumDetailView: View {
//    let album: AlbumItem
//    @State private var tracks: [Track] = []
//    @State private var isLoadingTracks: Bool = false
//    @State private var trackFetchError: SpotifyAPIError? = nil
//    @State private var selectedTrackUri: String? = nil
//    @StateObject private var playbackState = SpotifyPlaybackState()
//    @Environment(\.dismiss) var dismiss
//    
//    var body: some View {
//        ZStack {
//            DarkNeumorphicTheme.background.ignoresSafeArea()
//            ScrollView {
//                VStack(spacing: 0) {
//                    AlbumHeaderView(album: album)
//                        .padding(.top, 10)
//                        .padding(.bottom, 25)
//                    if selectedTrackUri != nil {
//                        SpotifyEmbedPlayerView(
//                            playbackState: playbackState,
//                            spotifyUri: selectedTrackUri
//                        )
//                        .padding(.horizontal)
//                        .padding(.bottom, 25)
//                        .transition(
//                            .opacity
//                                .combined(
//                                    with: .scale(
//                                        scale: 0.95,
//                                        anchor: .top
//                                    )
//                                )
//                        ).animation(
//                            .easeInOut(duration: 0.3),
//                            value: selectedTrackUri
//                        )
//                    }
//                    
//                    TracksSectionView(
//                        tracks: tracks,
//                        isLoading: isLoadingTracks,
//                        error: trackFetchError,
//                        selectedTrackUri: $selectedTrackUri,
//                        retryAction: {
//                            Task {
//                                await fetchTracks()
//                            }
//                        }
//                    ).padding(.bottom, 25)
//                    
//                    if let url = URL(string: album.external_urls.spotify ?? "") {
//                        ExternalLinkButton(url: url)
//                            .padding(.horizontal)
//                            .padding(.bottom, 30)
//                    }
//                }
//            }
//        }
//        .navigationTitle(album.name).navigationBarTitleDisplayMode(.inline)
//        .toolbarBackground(DarkNeumorphicTheme.elementBackground, for: .navigationBar)
//        .toolbarBackground(.visible, for: .navigationBar)
//        .toolbarColorScheme(.dark, for: .navigationBar) // Title/buttons light
//        .task {
//            await fetchTracks()
//        }
//    }
//    
//    // Fetch Tracks Logic (Unchanged)
//    private func fetchTracks(force: Bool = false) async { guard force || tracks.isEmpty || trackFetchError != nil else { return }; await MainActor.run { isLoadingTracks = true; trackFetchError = nil }; do { let r = try await SpotifyAPIService.shared.getAlbumTracks(albumId: album.id); try Task.checkCancellation(); await MainActor.run { self.tracks = r.items; self.isLoadingTracks = false } } catch is CancellationError { await MainActor.run { isLoadingTracks = false } } catch let e as SpotifyAPIError { await MainActor.run { self.trackFetchError = e; self.isLoadingTracks=false; self.tracks=[] } } catch { await MainActor.run { self.trackFetchError = .networkError(error); self.isLoadingTracks=false; self.tracks=[] } } }
//}
//
//// MARK: Detail View Sub-Components (Themed)
//
//struct AlbumHeaderView: View {
//    let album: AlbumItem; private let imageCornerRadius: CGFloat = 25
//    var body: some View {
//        VStack(spacing: 15) {
//            AlbumImageView(url: album.bestImageURL).aspectRatio(1.0, contentMode: .fit).clipShape(RoundedRectangle(cornerRadius: imageCornerRadius))
//                .background(RoundedRectangle(cornerRadius: imageCornerRadius).fill(DarkNeumorphicTheme.elementBackground).shadow(color: DarkNeumorphicTheme.darkShadow, radius: 10, x: 6, y: 6).shadow(color: DarkNeumorphicTheme.lightShadow, radius: 10, x: -6, y: -6)).padding(.horizontal, 40)
//            VStack(spacing: 4) {
//                Text(album.name).font(neumorphicFont(size: 20, weight: .bold)).foregroundColor(DarkNeumorphicTheme.primaryText).multilineTextAlignment(.center)
//                Text("by \(album.formattedArtists)").font(neumorphicFont(size: 15)).foregroundColor(DarkNeumorphicTheme.secondaryText).multilineTextAlignment(.center)
//                Text("\(album.album_type.capitalized) • \(album.formattedReleaseDate())").font(neumorphicFont(size: 12, weight: .medium)).foregroundColor(DarkNeumorphicTheme.secondaryText.opacity(0.8))
//            }.padding(.horizontal)
//        }
//    }
//}
//
////struct SpotifyEmbedPlayerView: View {
////    @ObservedObject var playbackState: SpotifyPlaybackState; let spotifyUri: String?; private let radius: CGFloat = 15
////    var body: some View {
////        VStack(spacing: 8) {
////            SpotifyEmbedWebView(playbackState: playbackState, spotifyUri: spotifyUri).frame(height: 80).clipShape(RoundedRectangle(cornerRadius: radius)).disabled(!playbackState.isReady)
////                .overlay(Group { if !playbackState.isReady { ProgressView().tint(DarkNeumorphicTheme.accentColor) } else if let e = playbackState.error { VStack{Image(systemName:"exclamationmark.triangle").foregroundColor(DarkNeumorphicTheme.errorColor);Text(e).font(.caption).foregroundColor(DarkNeumorphicTheme.errorColor).lineLimit(1)}.padding(5) } })
////                .background(RoundedRectangle(cornerRadius: radius).fill(DarkNeumorphicTheme.elementBackground).shadow(color: DarkNeumorphicTheme.darkShadow, radius: 5, x: 3, y: 3).shadow(color: DarkNeumorphicTheme.lightShadow, radius: 5, x: -3, y: -3))
////            HStack { // Status Text
////                if let e = playbackState.error, !e.isEmpty { Text("Error: \(e)").font(neumorphicFont(size:10,weight:.medium)).foregroundColor(DarkNeumorphicTheme.errorColor).lineLimit(1).frame(maxWidth:.infinity,alignment:.leading) }
////                else if !playbackState.isReady { Text("Loading Player...").font(neumorphicFont(size:10,weight:.medium)).foregroundColor(DarkNeumorphicTheme.secondaryText).frame(maxWidth:.infinity,alignment:.leading) }
////                else if playbackState.duration > 0.1 { Text(playbackState.isPlaying ? "Playing":"Paused").font(neumorphicFont(size:10,weight:.medium)).foregroundColor(playbackState.isPlaying ? DarkNeumorphicTheme.accentColor:DarkNeumorphicTheme.secondaryText); Spacer(); Text("\(formatTime(playbackState.currentPosition)) / \(formatTime(playbackState.duration))").font(neumorphicFont(size:10,weight:.medium)).foregroundColor(DarkNeumorphicTheme.secondaryText).frame(width:90,alignment:.trailing) }
////                else { Text("Ready").font(neumorphicFont(size:10,weight:.medium)).foregroundColor(DarkNeumorphicTheme.secondaryText).frame(maxWidth:.infinity,alignment:.leading) }
////            }.padding(.horizontal, 8).frame(height: 15)
////        }
////    }
////    private func formatTime(_ t: Double) -> String { let s = max(0,Int(t)); return String(format:"%d:%02d",s/60,s%60) }
////}
//struct SpotifyEmbedPlayerView: View {
//    @ObservedObject var playbackState: SpotifyPlaybackState
//    let spotifyUri: String?
//    private let playerCornerRadius: CGFloat = 15
//    
//    var body: some View {
//        VStack(spacing: 8) {
//            // --- WebView Embed ---
//            SpotifyEmbedWebView(playbackState: playbackState, spotifyUri: spotifyUri)
//                .frame(height: 80) // Standard height for the embed
//                .clipShape(RoundedRectangle(cornerRadius: playerCornerRadius)) // Clip the webview itself
//                .disabled(!playbackState.isReady) // Disable interaction until ready
//                .overlay( // Show loading/error overlay if needed
//                    Group {
//                        if !playbackState.isReady {
//                            ProgressView().tint(DarkNeumorphicTheme.accentColor)
//                        } else if let error = playbackState.error {
//                            VStack {
//                                Image(systemName: "exclamationmark.triangle")
//                                    .resizable().scaledToFit().frame(height: 15)
//                                    .foregroundColor(DarkNeumorphicTheme.errorColor)
//                                Text(error)
//                                    .font(.caption)
//                                    .foregroundColor(DarkNeumorphicTheme.errorColor)
//                                    .lineLimit(1)
//                                    .minimumScaleFactor(0.7)
//                            }
//                            .padding(5)
//                        }
//                    }
//                )
//            // --- Neumorphic Background/Frame for the player ---
//                .background(
//                    RoundedRectangle(cornerRadius: playerCornerRadius)
//                        .fill(DarkNeumorphicTheme.elementBackground)
//                        .shadow(color: DarkNeumorphicTheme.darkShadow, radius: 5, x: 3, y: 3)
//                        .shadow(color: DarkNeumorphicTheme.lightShadow, radius: 5, x: -3, y: -3)
//                )
//            
//            // --- Playback Status Text ---
//            HStack {
//                // Display error prominently if it exists
//                if let error = playbackState.error, !error.isEmpty {
//                    Text("Error: \(error)")
//                        .font(neumorphicFont(size: 10, weight: .medium))
//                        .foregroundColor(DarkNeumorphicTheme.errorColor)
//                        .lineLimit(1)
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                } else if !playbackState.isReady {
//                    Text("Loading Player...")
//                        .font(neumorphicFont(size: 10, weight: .medium))
//                        .foregroundColor(DarkNeumorphicTheme.secondaryText)
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                } else if playbackState.duration > 0.1 { // Show time only if duration is valid
//                    Text(playbackState.isPlaying ? "Playing" : "Paused")
//                        .font(neumorphicFont(size: 10, weight: .medium))
//                        .foregroundColor(playbackState.isPlaying ? DarkNeumorphicTheme.accentColor : DarkNeumorphicTheme.secondaryText)
//                    
//                    Spacer()
//                    
//                    Text("\(formatTime(playbackState.currentPosition)) / \(formatTime(playbackState.duration))")
//                        .font(neumorphicFont(size: 10, weight: .medium))
//                        .foregroundColor(DarkNeumorphicTheme.secondaryText)
//                        .frame(width: 90, alignment: .trailing) // Fixed width for time
//                    // Add monospaced digit font variant if needed for stability
//                    // .font(.system(size: 10, weight: .medium, design: .monospaced))
//                } else {
//                    // Player ready but no duration yet (or zero duration track)
//                    Text("Ready")
//                        .font(neumorphicFont(size: 10, weight: .medium))
//                        .foregroundColor(DarkNeumorphicTheme.secondaryText)
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                }
//            }
//            .padding(.horizontal, 8) // Small padding for status text
//            .frame(height: 15) // Minimal height
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
//    let tracks: [Track]; let isLoading: Bool; let error: SpotifyAPIError?
//    @Binding var selectedTrackUri: String?; let retryAction: () -> Void
//    private let radius: CGFloat = 20
//    var body: some View {
//        VStack(alignment: .leading, spacing: 0) {
//            Text("Tracks").font(neumorphicFont(size: 16, weight: .semibold)).foregroundColor(DarkNeumorphicTheme.primaryText).padding(.horizontal).padding(.bottom, 10)
//            Group { // Content container
//                if isLoading { HStack{Spacer();ProgressView().tint(DarkNeumorphicTheme.accentColor);Text("Loading Tracks...").font(neumorphicFont(size:14)).foregroundColor(DarkNeumorphicTheme.secondaryText);Spacer()}.padding(.vertical, 30) }
//                else if let e = error { ErrorPlaceholderView(error: e, retryAction: retryAction).padding(.vertical, 20) }
//                else if tracks.isEmpty { Text("No tracks found.").font(neumorphicFont(size:14)).foregroundColor(DarkNeumorphicTheme.secondaryText).frame(maxWidth:.infinity,alignment:.center).padding(.vertical, 30) }
//                else { VStack(spacing: 0) { ForEach(tracks) { track in NeumorphicTrackRow(track: track, isSelected: track.uri == selectedTrackUri).contentShape(Rectangle()).onTapGesture { selectedTrackUri = track.uri } } } }
//            }.padding(10)
//                .background(RoundedRectangle(cornerRadius: radius).fill(DarkNeumorphicTheme.elementBackground).shadow(color: DarkNeumorphicTheme.darkShadow, radius: 5, x: 3, y: 3).shadow(color: DarkNeumorphicTheme.lightShadow, radius: 5, x: -3, y: -3)).padding(.horizontal)
//        }
//    }
//}
//
//struct NeumorphicTrackRow: View {
//    let track: Track; let isSelected: Bool
//    var body: some View {
//        HStack(spacing: 12) {
//            Text("\(track.track_number)").font(neumorphicFont(size: 12, weight: .medium)).foregroundColor(isSelected ? DarkNeumorphicTheme.accentColor : DarkNeumorphicTheme.secondaryText).frame(width: 20, alignment: .center) // Accent color for selected track number
//            VStack(alignment: .leading, spacing: 2) {
//                Text(track.name).font(neumorphicFont(size: 14, weight: .medium)).foregroundColor(isSelected ? DarkNeumorphicTheme.primaryText : DarkNeumorphicTheme.primaryText.opacity(0.9)).fontWeight(isSelected ? .bold : .regular).lineLimit(1)
//                Text(track.formattedArtists).font(neumorphicFont(size: 11)).foregroundColor(DarkNeumorphicTheme.secondaryText).lineLimit(1)
//            }
//            Spacer()
//            Text(track.formattedDuration).font(neumorphicFont(size: 12, weight: .medium)).foregroundColor(DarkNeumorphicTheme.secondaryText).frame(width: 40, alignment: .trailing)
//            Image(systemName: isSelected ? "speaker.wave.2.fill" : "play").font(.system(size: 12)).foregroundColor(isSelected ? DarkNeumorphicTheme.accentColor : DarkNeumorphicTheme.secondaryText.opacity(0.6)).frame(width: 20, alignment: .center).animation(.easeInOut(duration: 0.2), value: isSelected) // Accent color for speaker icon
//        }
//        .padding(.vertical, 10).padding(.horizontal, 5)
//        .background(isSelected ? DarkNeumorphicTheme.elementBackground.opacity(0.6) : Color.clear).cornerRadius(8)
//    }
//}
//
//// MARK: Other Supporting Views (Themed)
//
//struct AlbumImageView: View { // Now uses theme accent/error colors for placeholders
//    let url: URL?; private let radius: CGFloat = 8
//    var body: some View {
//        AsyncImage(url: url) { phase in
//            switch phase {
//            case .empty: ZStack{RoundedRectangle(cornerRadius: radius)
//                    .fill(DarkNeumorphicTheme.elementBackground)
//                    .modifier(NeumorphicOuterShadow())
//                
//                ProgressView().tint(DarkNeumorphicTheme.accentColor.opacity(0.7))} // Accent color
//                
//            case .success(let img):
//                img.resizable().scaledToFit()
//            case .failure:
//                ZStack{
//                    RoundedRectangle(cornerRadius: radius)
//                        .fill(DarkNeumorphicTheme.elementBackground)
//                        .modifier(NeumorphicOuterShadow())
//                    
//                    Image(systemName:"photo.on.rectangle.angled")
//                        .resizable()
//                        .scaledToFit()
//                        .foregroundColor(DarkNeumorphicTheme.secondaryText.opacity(0.5)).padding(15)
//                }
//            @unknown default: EmptyView()
//            }
//        }
//    }
//}
//
//struct SearchMetadataHeader: View { // Kept simple
//    let totalResults: Int; let limit: Int; let offset: Int
//    var body: some View {
//        HStack{Text("Results: \(totalResults)");Spacer();if totalResults>limit{Text("Showing: \(offset+1)-\(min(offset+limit,totalResults))")}}
//            .font(neumorphicFont(size:11,weight:.medium)).foregroundColor(DarkNeumorphicTheme.secondaryText).padding(.vertical, 5)
//    }
//}
//struct ThemedNeumorphicButton: View { // Uses theme accent color
//    let text: String; var iconName: String? = nil; let action: () -> Void
//    var body: some View {
//        Button(action: action) { HStack(spacing:8){if let i=iconName{Image(systemName:i)};Text(text)}.font(neumorphicFont(size:15,weight:.semibold)).foregroundColor(DarkNeumorphicTheme.accentColor) } // Theme accent color
//            .buttonStyle(NeumorphicButtonStyle())
//    }
//}
//struct ExternalLinkButton: View { // Uses themed button
//    let text: String = "Open in Spotify"; let url: URL
//    @Environment(\.openURL) var openURL
//    var body: some View { ThemedNeumorphicButton(text: text, iconName: "arrow.up.forward.app") { openURL(url) { accepted in if !accepted { print("⚠️ Failed to open URL: \(url)") } } } }
//    
//    // MARK: - Preview Providers (Updated for Neumorphic Views)
//    
//    // Creating Mock Data statically for easier previewing
//    struct MockData {
//        static let artist = Artist(id: "artist1", external_urls: nil, href: "", name: "Miles Davis Mock", type: "artist", uri: "")
//        static let image300 = SpotifyImage(height: 300, url: "https://i.scdn.co/image/ab67616d00001e027ab89c25093ea3787b1995b4", width: 300)
//        static let image640 = SpotifyImage(height: 640, url: "https://i.scdn.co/image/ab67616d0000b2737ab89c25093ea3787b1995b4", width: 640)
//        static let albumItem = AlbumItem(id: "album1", album_type: "album", total_tracks: 5, available_markets: ["US"], external_urls: ExternalUrls(spotify: ""), href: "", images: [image300], name: "Kind of Blue [PREVIEW]", release_date: "1959-08-17", release_date_precision: "day", type: "album", uri: "spotify:album:1weenld61qoidwYuZ1GESA", artists: [artist])
//        static let albumDetail = AlbumItem(id: "1weenld61qoidwYuZ1GESA", album_type: "album", total_tracks: 5, available_markets: ["US", "GB"], external_urls: ExternalUrls(spotify: "https://open.spotify.com/album/1weenld61qoidwYuZ1GESA"), href: "", images: [image640], name: "Kind Of Blue (Preview)", release_date: "1959-08-17", release_date_precision: "day", type: "album", uri: "spotify:album:1weenld61qoidwYuZ1GESA", artists: [artist])
//        static let track1 = Track(id:"t1", artists:[artist], disc_number:1, duration_ms: 355000, explicit: false, external_urls:nil, href:"", name:"So What", preview_url:nil, track_number:1, type:"track", uri:"spotify:track:t1")
//        static let track2 = Track(id:"t2", artists:[artist], disc_number:1, duration_ms: 565000, explicit: false, external_urls:nil, href:"", name:"Freddie Freeloader", preview_url:nil, track_number:2, type:"track", uri:"spotify:track:t2")
//    }
//    
//    struct SpotifyAlbumListView_Previews: PreviewProvider {
//        static var previews: some View { SpotifyAlbumListView().preferredColorScheme(.dark) }
//    }
//    
//    struct NeumorphicAlbumCard_Previews: PreviewProvider {
//        static var previews: some View {
//            NeumorphicAlbumCard(album: MockData.albumItem).padding().background(DarkNeumorphicTheme.background).previewLayout(.fixed(width: 380, height: 140)).preferredColorScheme(.dark)
//        }
//    }
//    
//    struct AlbumDetailView_Previews: PreviewProvider {
//        static var previews: some View { NavigationView{AlbumDetailView(album: MockData.albumDetail)}.preferredColorScheme(.dark) }
//    }
//    struct NeumorphicTrackRow_Previews: PreviewProvider {
//        static var previews: some View {
//            VStack {
//                NeumorphicTrackRow(track: MockData.track1, isSelected: false)
//                NeumorphicTrackRow(track: MockData.track2, isSelected: true)
//            }
//            .padding().background(DarkNeumorphicTheme.elementBackground)
//            .previewLayout(.sizeThatFits)
//            .preferredColorScheme(.dark)
//        }
//    }
//    struct ErrorPlaceholderView_Previews: PreviewProvider {
//        static var previews: some View {
//            Group {
//                ErrorPlaceholderView(error: .invalidToken, retryAction: nil)
//                ErrorPlaceholderView(error: .networkError(URLError(.timedOut)), retryAction: {})
//            }
//            .padding().background(DarkNeumorphicTheme.background)
//            .previewLayout(.sizeThatFits)
//            .preferredColorScheme(.dark)
//        }
//    }
//    struct EmptyStatePlaceholderView_Previews: PreviewProvider {
//        static var previews: some View {
//            Group {
//                EmptyStatePlaceholderView(searchQuery: "")
//                EmptyStatePlaceholderView(searchQuery: "NonExistentAlbumName")
//            }
//            .padding()
//            .background(DarkNeumorphicTheme.background)
//            .previewLayout(.sizeThatFits)
//            .preferredColorScheme(.dark)
//        }
//    }
//    
//    // MARK: - App Entry Point
//    
//    @main
//    struct SpotifyNeumorphicHSBP3App: App {
//        init() {
//            if placeholderSpotifyToken == "YOUR_SPOTIFY_BEARER_TOKEN_HERE" { print("🚨 WARNING: Spotify Bearer Token not set! Search will fail.") }
//            
//            // Apply Global Navigation Bar Appearance
//            let appearance = UINavigationBarAppearance()
//            appearance.configureWithOpaqueBackground()
//            appearance.backgroundColor = UIColor(DarkNeumorphicTheme.elementBackground)
//            appearance.titleTextAttributes = [.foregroundColor: UIColor(DarkNeumorphicTheme.primaryText)]
//            appearance.largeTitleTextAttributes = [.foregroundColor: UIColor(DarkNeumorphicTheme.primaryText)]
//            appearance.shadowColor = .clear // Remove bottom border
//            UINavigationBar.appearance().standardAppearance = appearance
//            UINavigationBar.appearance().scrollEdgeAppearance = appearance
//            UINavigationBar.appearance().compactAppearance = appearance
//            UINavigationBar.appearance().tintColor = UIColor(DarkNeumorphicTheme.accentColor) // Use theme accent for back button etc.
//            
//            // Optional: Update Search Bar Appearance (May need more specific targeting)
//            // UISearchBar.appearance().tintColor = UIColor(DarkNeumorphicTheme.accentColor)
//            // UISearchTextField.appearance().backgroundColor = UIColor(DarkNeumorphicTheme.background.opacity(0.5))
//            // UISearchTextField.appearance().textColor = UIColor(DarkNeumorphicTheme.primaryText)
//        }
//        
//        var body: some Scene {
//            WindowGroup {
//                SpotifyAlbumListView()
//                // Force dark mode for the entire app
//                    .preferredColorScheme(.dark)
//            }
//        }
//    }
//}
