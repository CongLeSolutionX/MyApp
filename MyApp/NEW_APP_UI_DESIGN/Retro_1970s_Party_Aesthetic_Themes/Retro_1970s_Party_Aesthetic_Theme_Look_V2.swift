//
//  Retro_1980s_Party_Aesthetic_Theme_Look_V1.swift
//  MyApp
//
//  Created by Cong Le on 4/20/25.
//

//
//  DiscoThemeSpotifyApp.swift
//  MyApp
//
//  Created by Cong Le on 4/19/25.
//
//  Comprehensive version combining all features with 1970s Disco Theme
//

import SwiftUI
@preconcurrency import WebKit // Mark import as non-concurrent // Mark import as non-concurrent
import Foundation

// MARK: - 1970s Disco Theme Constants & Modifiers

// --- Colors ---
let discoBackgroundStart = Color(hex: "2C1B1A") // Very Dark Brown/Maroon
let discoBackgroundEnd = Color(hex: "4A2C2A") // Dark Warm Brown
let discoGold = Color(hex: "FFD700") // Classic Gold
let discoOrange = Color(hex: "F28C28") // Burnt Orange/Tangerine
let discoCream = Color(hex: "FFFDD0") // Creamy White for text
let discoSilver = Color(hex: "C0C0C0") // Silver for accents
let discoHighlightPurple = Color(hex: "703F9A") // Deep Purple highlight

let discoGradientBackground = LinearGradient(
    gradient: Gradient(colors: [discoBackgroundStart, discoBackgroundEnd]),
    startPoint: .topLeading,
    endPoint: .bottomTrailing
)

let discoAccentGradient = LinearGradient(
    gradient: Gradient(colors: [discoGold, discoOrange, discoHighlightPurple]),
    startPoint: .leading,
    endPoint: .trailing
)

// --- Fonts ---
// Using system fonts as placeholders. Replace with actual 70s-style fonts if available.
// Examples: "Funkydori", "Groovy Script", "Discoteque" etc.
func discoTitleFont(size: CGFloat) -> Font {
    // Placeholder: A rounded, bold system font
    // Font.system(.largeTitle, design: typeface(.tanhoma), weight: .heavy).italic() // Font.custom("Georama", size: 18.0)
    //Font.system(size: size, weight: .bold, design: .rounded)
    Font.custom("Funkydori", size: 24.0)
}

func discoBodyFont(size: CGFloat, weight: Font.Weight = .regular) -> Font {
    // Placeholder: A clean, slightly rounded sans-serif
    //Font.system(size: size, weight: weight, design: .serif) // Avenir Next could work
    Font.custom("Georama-Regular", size: 12.0)
}

func discoScriptFont(size: CGFloat) -> Font {
    // Placeholder: System script-like font
    //Font.system(size: size, weight: .medium, design: .serif).italic()
    Font.custom("PlaylistScript", size: 24.0)
}

// --- Modifiers ---
struct DiscoSparkleGlow: ViewModifier {
    var color: Color
    var radius: CGFloat
    
    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(0.6), radius: radius * 0.4, x: 0, y: 0) // Base glow
            .shadow(color: color.opacity(0.4), radius: radius * 0.8, x: 0, y: 0) // Softer outer glow
            .overlay( // Subtle sparkle simulation
                SparkleOverlay(color: color.opacity(0.7))
                    .blur(radius: 1) // Soften sparkles slightly
                    .blendMode(.overlay) // Blend sparkles
                    .allowsHitTesting(false)
                    .clipped() // Clip sparkles to content shape
            )
    }
}

extension View {
    func discoSparkleGlow(_ color: Color = discoGold, radius: CGFloat = 10) -> some View {
        self.modifier(DiscoSparkleGlow(color: color, radius: radius))
    }
}

// Simple Sparkle Overlay using Canvas (Illustrative, performance considerations apply)
struct SparkleOverlay: View {
    var color: Color = discoGold.opacity(0.7)
    var density: Double = 0.015 // Fewer, larger sparkles than noise
    @State private var seed: Int = Int.random(in: 0...100) // For variation
    
    var body: some View {
        Canvas { context, size in
            var rng = SeededRandomNumberGenerator(seed: UInt64(seed)) // Use seeded RNG
            context.blendMode = .screen // Make sparkles bright
            
            for _ in 0..<Int(size.width * size.height * density) {
                let x = Double.random(in: 0...size.width, using: &rng)
                let y = Double.random(in: 0...size.height, using: &rng)
                let baseSize = Double.random(in: 1.0...3.0, using: &rng)
                let flareLength = baseSize * Double.random(in: 1.5...3.0, using: &rng)
                let angle = Angle.degrees(Double.random(in: 0...360, using: &rng))
                
                // Simple star shape path
                var path = Path()
                path.move(to: CGPoint(x: x, y: y - flareLength / 2))
                path.addLine(to: CGPoint(x: x, y: y + flareLength / 2))
                path.move(to: CGPoint(x: x - flareLength / 2, y: y))
                path.addLine(to: CGPoint(x: x + flareLength / 2, y: y))
                
                context.stroke(
                    path.applying(.init(rotationAngle: CGFloat(angle.radians))),
                    with: .color(color.opacity(Double.random(in: 0.5...1.0, using: &rng))),
                    lineWidth: baseSize * 0.5 // Thickness of sparkle lines
                )
            }
        }
        .onAppear { // Ensures different sparkles on each appearance/redraw
            seed = Int.random(in: 0...100)
        }
    }
}

// --- Hex Color Extension (Unchanged) ---
extension Color {
    init(hex: String) { /* ... Hex init implementation from previous versions ... */
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

// --- Seeded RNG ---
//struct SeededRandomNumberGenerator: RandomNumberGenerator { /* ... */ }
// Simple Seeded RNG (Needed for NoiseTexture)
struct SeededRandomNumberGenerator: RandomNumberGenerator {
    private var state: UInt64
    init(seed: UInt64) { state = seed == 0 ? 1 : seed }
    mutating func next() -> UInt64 {
        state = state &* 1103515245 &+ 12345 // Simple LCG
        return state
    }
}
// MARK: - Data Models

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

//// MARK: - API Service (Use Placeholder Token)
//
//let placeholderSpotifyToken = "YOUR_SPOTIFY_BEARER_TOKEN_HERE" // Needs replacement!

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


// MARK: - API Service

let placeholderSpotifyToken = "YOUR_SPOTIFY_BEARER_TOKEN_HERE" // CRITICAL: Replace this!


// MARK: - SwiftUI Views (Disco Theme Applied)

// --- Preview ---
struct DiscoSpotifyApp_Previews: PreviewProvider {
    static var previews: some View {
        SpotifyAlbumListView()
            .preferredColorScheme(.dark)
    }
}

// --- Themed Album Card ---
struct DiscoAlbumCard: View {
    let album: AlbumItem
    @State private var animateGlow = false
    
    var body: some View {
        ZStack(alignment: .bottomLeading) { // Align text to bottom
            // Album Art as Background Layer
            AlbumImageView(url: album.listImageURL)
                .aspectRatio(contentMode: .fill)
                .frame(height: 110) // Reduced height for card style
                .clipped()
            
            // Gradient overlay for effect + readability
            LinearGradient(
                gradient: Gradient(colors: [
                    discoBackgroundStart.opacity(0.1),
                    discoBackgroundStart.opacity(0.8),
                    discoBackgroundStart.opacity(1.0)
                ]),
                startPoint: .center,
                endPoint: .bottom
            )
            
            // --- Mirrored Ball/Sparkle Effect (Subtle) ---
            Circle()
                .fill(discoSilver.opacity(0.1))
                .frame(width: 200, height: 200)
                .blur(radius: 50)
                .offset(x: -50, y: -60) // Position the "light source"
                .blendMode(.overlay)
            SparkleOverlay(color: discoSilver.opacity(0.4), density: 0.005) // Faint sparkles
                .allowsHitTesting(false)
            
            // --- Text Content ---
            HStack(spacing: 0) { // Use HStack to place image and text
                // Optional: Small version of album art at left edge
                AlbumImageView(url: album.listImageURL)
                    .frame(width: 60, height: 60)
                    .clipShape(Circle()) // Disco ball shape
                    .overlay(Circle().stroke(discoGold.opacity(0.5), lineWidth: 1))
                    .padding([.leading, .vertical], 10)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(album.name)
                        .font(discoTitleFont(size: 17))
                        .foregroundColor(discoCream)
                        .lineLimit(1)
                        .shadow(color: .black.opacity(0.5), radius: 2)
                    
                    Text(album.formattedArtists)
                        .font(discoBodyFont(size: 13, weight: .medium))
                        .foregroundColor(discoOrange.opacity(0.9)) // Artist name accent
                        .lineLimit(1)
                    
                    HStack(spacing: 6) {
                        Image(systemName: "opticaldisc") // Disco record icon
                            .foregroundColor(discoSilver.opacity(0.7))
                        Text(album.album_type.capitalized)
                        Text("•")
                            .foregroundColor(discoCream.opacity(0.5))
                        Text(album.formattedReleaseDate())
                    }
                    .font(discoBodyFont(size: 10, weight: .light))
                    .foregroundColor(discoCream.opacity(0.7))
                }
                .padding(.leading, 5)
                .padding(.vertical, 10)
                .padding(.trailing, 10)
                
                Spacer() // Push text to left
            }
        }
        .frame(height: 110) // Consistent height
        .background(discoBackgroundEnd) // Base card color
        .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous)) // Smoother corners
        .overlay( // Gold border trim
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .stroke(discoGold.opacity(0.7), lineWidth: 1)
        )
        .discoSparkleGlow(discoGold, radius: animateGlow ? 12 : 8) // Animate glow
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                animateGlow.toggle()
            }
        }
    }
}


struct EmptyStatePlaceholderView: View {
    let searchQuery: String
    
    var body: some View {
        VStack(spacing: 25) {
            Image(systemName: isInitialState ? "music.mic.circle.fill" : "questionmark.diamond.fill")
                .font(.system(size: 80))
                .foregroundStyle(
                    LinearGradient(gradient: Gradient(colors: [discoGold, discoSilver]), startPoint: .top, endPoint: .bottom)
                )
                .discoSparkleGlow(discoGold, radius: 20)
                .padding(.bottom, 15)
            
            Text(title)
                .font(discoTitleFont(size: 24))
                .foregroundColor(discoCream)
            
            Text(message)
                .font(discoBodyFont(size: 16, weight: .light))
                .foregroundColor(discoCream.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
                .lineSpacing(6)
        }
        .padding(30)
        // Background inherent from ZStack in parent view
    }
    
    // Logic remains unchanged
    private var isInitialState: Bool { searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    private var title: String { isInitialState ? "FEEL THE GROOVE" : "CAN'T FIND IT" }
    private var message: String {
        if isInitialState {
            return "What vibe are you searchin' for?\nEnter an album or artist to get started."
        } else {
            return "Nothin' matching \"\(searchQuery)\" on the dance floor.\nTry another name, cool cat."
        }
    }
}

// --- Themed Detail View ---
struct AlbumDetailView: View {
    let album: AlbumItem
    @State private var tracks: [Track] = []
    @State private var isLoadingTracks: Bool = false
    @State private var trackFetchError: SpotifyAPIError? = nil
    @State private var selectedTrackUri: String? = nil
    @StateObject private var playbackState = SpotifyPlaybackState()
    
    var body: some View {
        ZStack {
            discoGradientBackground.ignoresSafeArea() // Use disco theme gradient
            
            // Optional: Subtle animated background element
            DiscoLightsBackground().blur(radius: 50).opacity(0.3)
            
            List {
                // Header View
                Section { AlbumHeaderView(album: album) }
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                
                // Player View (Themed)
                if let uriToPlay = selectedTrackUri {
                    Section { DiscoEmbedPlayerView(playbackState: playbackState, spotifyUri: uriToPlay) }
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 15, leading: 0, bottom: 15, trailing: 0))
                        .listRowBackground(Color.clear)
                        .transition(.opacity.combined(with: .move(edge: .top)).animation(.smooth))
                }
                
                // Tracks Section (Themed)
                Section {
                    TracksSectionView(
                        tracks: tracks, isLoading: isLoadingTracks, error: trackFetchError,
                        selectedTrackUri: $selectedTrackUri,
                        retryAction: { Task { await fetchTracks() } }
                    )
                } header: {
                    Text("THE TRACK LIST") // Groovy header
                        .font(discoTitleFont(size: 15))
                        .tracking(2) // Letter spacing
                        .foregroundColor(discoGold)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 10)
                        .background(discoBackgroundStart.opacity(0.5))
                }
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                
                // External Link (Themed)
                //                if let stringURL = album.external_urls ?? "google.com",
                //                   let spotifyURL = URL(string: stringURL) {
                //                    Section { ExternalLinkDiscoButton(url: spotifyURL) }
                //                        .listRowInsets(EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20))
                //                        .listRowSeparator(.hidden)
                //                        .listRowBackground(Color.clear)
                //                }
                
                Section {
                    ExternalLinkDiscoButton(
                        url: (URL(string: "spotifyURL.com") ??
                              URL(string: "google.com"))!
                    )
                }
                .listRowInsets(EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                
            } // End List
            .listStyle(PlainListStyle())
            .scrollContentBackground(.hidden) // Allow ZStack background
        } // End ZStack
        .navigationTitle(album.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar) // Dark scheme for NavBar items
        //        .toolbarBackground( // Match background gradient in NavBard
        //            discoGradientBackground.opacity(0.8)
        //                .blur(radius: 5), // Slight blur for effect
        //            for: .navigationBar
        //        )
        .toolbarBackground(.visible, for: .navigationBar)
        .accentColor(discoGold) // Tint back button etc.
        .task { await fetchTracks() }
        .refreshable { await fetchTracks(forceReload: true) }
        .animation(.smooth(duration: 0.4), value: selectedTrackUri)
    }
    
    // Fetch Tracks Logic (Unchanged)
    private func fetchTracks(forceReload: Bool = false) async { /* ... */ }
}

// --- Detail View Sub-Components (Themed) ---

// Background for Detail View (Illustrative)
struct DiscoLightsBackground: View {
    @State private var animate = false
    let colors: [Color] = [discoGold, discoOrange, discoHighlightPurple, discoSilver]
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(0..<10) { _ in
                    Circle()
                        .fill(colors.randomElement() ?? .white)
                        .opacity(0.3)
                        .frame(width: CGFloat.random(in: 50...150), height: CGFloat.random(in: 50...150))
                        .position(
                            x: CGFloat.random(in: 0...geo.size.width),
                            y: CGFloat.random(in: 0...geo.size.height)
                        )
                        .scaleEffect(animate ? 1.1 : 0.9)
                        .animation(
                            .easeInOut(duration: Double.random(in: 2...5))
                            .repeatForever(autoreverses: true)
                            .delay(Double.random(in: 0...1)),
                            value: animate
                        )
                }
            }
        }
        .ignoresSafeArea()
        .onAppear { animate = true }
    }
}

struct AlbumHeaderView: View {
    let album: AlbumItem
    
    var body: some View {
        VStack(spacing: 15) {
            AlbumImageView(url: album.bestImageURL) // Reusable Image View
                .aspectRatio(1.0, contentMode: .fit)
                .clipShape(Circle()) // Keep it round like a record/disco ball
                .overlay(Circle().stroke(discoGold.opacity(0.8), lineWidth: 2))
                .discoSparkleGlow(discoGold, radius: 15) // Gold glow
                .padding(.horizontal, 60) // Give it space
                .padding(.top, 10)
            
            VStack(spacing: 5) {
                Text(album.name)
                    .font(discoTitleFont(size: 24).italic()) // Title font, maybe italicized
                    .foregroundColor(discoCream)
                    .multilineTextAlignment(.center)
                    .shadow(color: .black.opacity(0.4), radius: 2, y: 1)
                
                Text("by \(album.formattedArtists)")
                    .font(discoScriptFont(size: 18)) // Script-like font for artist
                    .foregroundColor(discoOrange)
                    .multilineTextAlignment(.center)
                
                Text("\(album.album_type.capitalized) • \(album.formattedReleaseDate())")
                    .font(discoBodyFont(size: 11, weight: .light))
                    .foregroundColor(discoCream.opacity(0.7))
            }
            .padding(.horizontal)
            
        }
        .padding(.bottom, 20) // Space below header
    }
}

struct DiscoEmbedPlayerView: View {
    @ObservedObject var playbackState: SpotifyPlaybackState
    let spotifyUri: String
    
    var body: some View {
        VStack(spacing: 10) {
            SpotifyEmbedWebView(playbackState: playbackState, spotifyUri: spotifyUri)
                .frame(height: 85) // Default embed height + buffer
            // Player Frame/Background: Dark base with gold accents
                .background(
                    discoBackgroundStart.opacity(0.7)
                        .overlay(.ultraThinMaterial) // Frosted glass
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous)) // Smooth corners
                        .overlay( // Gold border
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(discoGold.opacity(0.6), lineWidth: 1)
                                )
                    // .discoSparkleGlow($playbackState.isPlaying ? discoGold : discoSilver, radius: 9) // Dynamic glow color
                )
                .padding(.horizontal) // Padding around the player
            
            // Playback Status Text (Themed)
            HStack {
                // let statusText = playbackState.isPlaying ? "GROOVIN'" : "PAUSED"
                let statusText = "GROOVIN'"
                let statusColor = discoGold //playbackState.isPlaying ? discoGold : discoSilver.opacity(0.8)
                
                Text(statusText)
                    .font(discoBodyFont(size: 10, weight: .bold))
                    .foregroundColor(statusColor)
                    .tracking(1.5)
                    .discoSparkleGlow(statusColor, radius: 4) // Mini glow on status
                
                Spacer()
                
                // Time Display
                //Text(playbackState.duration > 0.1 ? "\(formatTime(playbackState.currentPosition)) / \(formatTime(playbackState.duration))" : "--:-- / --:--")
                Text("Display Time")
                    .font(discoBodyFont(size: 11, weight: .medium))
                    .foregroundColor(discoCream.opacity(0.8))
                    .monospacedDigit() // Keep time spacing consistent
            }
            .padding(.horizontal, 25) // Align with player padding
            .frame(height: 15)
            
        }
        // .animation(.easeInOut, value: $playbackState.isPlaying) // Animate glow
    }
    
    private func formatTime(_ time: Double) -> String {
        let totalSeconds = max(0, Int(time)) // Ensure non-negative
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
        if isLoading {
            HStack { // Center progress view
                Spacer()
                ProgressView().tint(discoGold) // Gold spinner
                Text("Loading Hits...")
                    .font(discoBodyFont(size: 14))
                    .foregroundColor(discoCream.opacity(0.7))
                Spacer()
            }.padding(.vertical, 25)
        } else if let error = error {
            ErrorPlaceholderView(error: error, retryAction: retryAction)
                .padding(.vertical, 20)
        } else if tracks.isEmpty {
            Text("The record's empty, man.")
                .font(discoBodyFont(size: 14))
                .foregroundColor(discoCream.opacity(0.7))
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 25)
        } else {
            ForEach(tracks) { track in
                TrackRowView(
                    track: track,
                    isSelected: track.uri == selectedTrackUri
                )
                .contentShape(Rectangle())
                .onTapGesture { selectedTrackUri = track.uri }
                .listRowBackground(
                    track.uri == selectedTrackUri
                    ? discoHighlightPurple.opacity(0.2) // Highlight color
                    : Color.clear
                )
                .listRowSeparatorTint(discoGold.opacity(0.3)) // Subtle gold separator
            }
        }
    }
}

struct TrackRowView: View {
    let track: Track
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            // Track Number (Styled)
            Text("\(track.track_number)")
                .font(discoBodyFont(size: 12, weight: .bold))
                .foregroundColor(isSelected ? discoGold : discoCream.opacity(0.6))
                .frame(width: 25, alignment: .center)
                .padding(.leading, 15)
            
            // Track Info
            VStack(alignment: .leading, spacing: 3) {
                Text(track.name)
                    .font(discoBodyFont(size: 15, weight: isSelected ? .bold : .regular))
                    .foregroundColor(isSelected ? discoOrange : discoCream)
                    .lineLimit(1)
                Text(track.formattedArtists)
                    .font(discoBodyFont(size: 11, weight: .light))
                    .foregroundColor(discoCream.opacity(0.7))
                    .lineLimit(1)
            }
            
            Spacer()
            
            // Duration
            Text(track.formattedDuration)
                .font(discoBodyFont(size: 12, weight: .medium))
                .foregroundColor(discoCream.opacity(0.7))
                .padding(.trailing, 5)
            
            // Play/Selected Indicator (Disco Ball)
            Image(systemName: isSelected ? "stop.circle.fill" : "play.circle.fill") // Changed icons
                .foregroundColor(isSelected ? discoGold : discoSilver.opacity(0.8))
                .font(isSelected ? .title3 : .title3) // Slightly larger when selected
                .discoSparkleGlow(isSelected ? discoGold : discoSilver, radius: isSelected ? 7 : 4) // More glow when selected
                .frame(width: 30, height: 30)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
                .padding(.trailing, 10)
            
        }
        .padding(.vertical, 10) // Slightly less vertical padding
    }
}

// --- Other Supporting Views (Themed) ---

struct AlbumImageView: View { // Reusable Image View - uses AsyncImage
    let url: URL?
    var placeholderColor1: Color = discoBackgroundEnd.opacity(0.5)
    var placeholderColor2: Color = discoBackgroundStart.opacity(0.5)
    var errorColor: Color = discoOrange.opacity(0.4)
    
    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
                ZStack {
                    LinearGradient(colors: [placeholderColor1, placeholderColor2], startPoint: .top, endPoint: .bottom)
                    ProgressView().tint(discoGold) // Gold tint
                }
            case .success(let image):
                image.resizable().scaledToFit()
            case .failure:
                ZStack {
                    LinearGradient(colors: [placeholderColor1, placeholderColor2], startPoint: .top, endPoint: .bottom)
                    Image(systemName: "photo.on.rectangle.angled") // Disc icon
                        .resizable().scaledToFit()
                        .foregroundColor(errorColor)
                        .padding(15)
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
            Label("\(totalResults) Grooves Found", systemImage: "music.note.list")
            Spacer()
            if totalResults > limit {
                Text("Viewing \(offset + 1)-\(min(offset + limit, totalResults))")
            }
        }
        .font(discoBodyFont(size: 10, weight: .medium))
        .foregroundColor(discoGold.opacity(0.85))
        .tracking(1.0)
        .padding(.horizontal, 12)
        .padding(.vertical, 5)
        .background(discoBackgroundStart.opacity(0.6).blur(radius: 3))
        .cornerRadius(5) // Less rounded than capsule
        .overlay(RoundedRectangle(cornerRadius: 5).stroke(discoGold.opacity(0.3), lineWidth: 0.5))
    }
}

// --- Themed Button Component ---
struct DiscoButton: View {
    let text: String
    let action: () -> Void
    var iconName: String? = nil
    var gradient: LinearGradient = discoAccentGradient // Default gradient
    var textColor: Color = discoBackgroundStart // Dark text on bright button
    var glowColor: Color = discoGold
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                if let iconName = iconName { Image(systemName: iconName) }
                Text(text)
                    .tracking(1.5) // Letter spacing
            }
            .font(discoBodyFont(size: 16, weight: .bold))
            .padding(.horizontal, 35)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(gradient)
            .foregroundColor(textColor)
            .clipShape(Capsule()) // Keep capsule shape
            .overlay(Capsule().stroke(discoCream.opacity(0.4), lineWidth: 0.5)) // Creamy edge
            .discoSparkleGlow(glowColor, radius: 12) // Disco glow
            .shadow(color: .black.opacity(0.3), radius: 4, y: 2) // Standard shadow
        }
        .buttonStyle(.plain)
    }
}

// Separate External Link Button using the DiscoButton style
struct ExternalLinkDiscoButton: View {
    let text: String = "OPEN IN SPOTIFY"
    let url: URL
    @Environment(\.openURL) var openURL
    
    var body: some View {
        DiscoButton(
            text: text,
            action: { openURL(url) },
            iconName: "arrow.up.forward.square.fill", // Spotify-like icon
            // Use specific disco colors for this button
            gradient: LinearGradient(colors: [discoGold, discoOrange], startPoint: .leading, endPoint: .trailing),
            textColor: discoBackgroundStart,
            glowColor: discoGold
        )
    }
}

// --- Main List View (Themed) ---
struct SpotifyAlbumListView: View {
    @State private var searchQuery: String = ""
    @State private var displayedAlbums: [AlbumItem] = []
    @State private var isLoading: Bool = false
    @State private var searchInfo: Albums? = nil
    @State private var currentError: SpotifyAPIError? = nil
    
    var body: some View {
        NavigationView {
            ZStack {
                // --- Disco Background ---
                discoGradientBackground.ignoresSafeArea()
                DiscoLightsBackground().blur(radius: 60).opacity(0.2) // Subtle background lights
                
                // --- Main Content Area ---
                Group {
                    if isLoading && displayedAlbums.isEmpty {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: discoGold))
                            .scaleEffect(1.8)
                    } else if let error = currentError {
                        ErrorPlaceholderView(error: error) { Task { await performDebouncedSearch() } }
                    } else if displayedAlbums.isEmpty && !searchQuery.isEmpty {
                        EmptyStatePlaceholderView(searchQuery: searchQuery)
                    } else if displayedAlbums.isEmpty && searchQuery.isEmpty {
                        EmptyStatePlaceholderView(searchQuery: searchQuery) // Show initial state
                    } else {
                        albumList // Display the themed list
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity) // Allow content to fill
                .transition(.opacity.animation(.smooth(duration: 0.4)))
                
                // --- Loading Indicator Overlay (Themed) ---
                if isLoading && !displayedAlbums.isEmpty {
                    VStack {
                        HStack {
                            Spacer()
                            ProgressView().tint(discoGold)
                            Text("Finding the Funk...")
                                .font(discoBodyFont(size: 12, weight: .bold))
                                .foregroundColor(discoGold)
                            Spacer()
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 15)
                        .background(discoBackgroundStart.opacity(0.7).blur(radius: 5))
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(discoGold.opacity(0.4), lineWidth: 0.5))
                        .shadow(color: discoGold.opacity(0.5), radius: 5)
                        .padding(.top, 8)
                        Spacer() // Push indicator to top
                    }
                    .transition(.opacity.animation(.easeInOut))
                }
                
            } // End ZStack
            .navigationTitle("Disco Spotify Finder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark)
            //            .toolbarBackground( // Gradient Navbar
            //                discoGradientBackground.opacity(0.8).blur(radius: 5),
            //                for: .navigationBar
            //            )
            .toolbarBackground(.visible, for: .navigationBar)
            
            // --- Search Bar (System default styling with accent) ---
            .searchable(text: $searchQuery,
                        placement: .navigationBarDrawer(displayMode: .always),
                        prompt: Text("Search Album/Artist...").foregroundColor(.gray))
            .onSubmit(of: .search) { Task { await performDebouncedSearch(immediate: true) } }
            .task(id: searchQuery) { await performDebouncedSearch() } // Debounced search
            .onChange(of: searchQuery) { if currentError != nil { currentError = nil } } // Clear error on new search
            .accentColor(discoGold) // Tint cursor/cancel button
            
        } // End NavigationView
        .accentColor(discoOrange) // Global accent for navigation links etc.
    }
    
    // --- Themed Album List View ---
    private var albumList: some View {
        List {
            // Themed Metadata Header
            if let info = searchInfo,
               info.total > 0 {
                SearchMetadataHeader(totalResults: info.total, limit: info.limit, offset: info.offset)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 5, leading: 10, bottom: 10, trailing: 10)) // Center header better
                    .listRowBackground(Color.clear)
            }
            
            // Album Cards
            ForEach(displayedAlbums) { album in
                NavigationLink(destination: AlbumDetailView(album: album)) {
                    DiscoAlbumCard(album: album) // Use the themed card
                        .padding(.vertical, 6) // Tighter spacing between cards
                }
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)) // Padding for cards
                .listRowBackground(Color.clear)
            }
        }
        .listStyle(PlainListStyle()) // Remove inset group styling
        .scrollContentBackground(.hidden) // Allow ZStack background through
        .background(Color.clear) // Ensure list itself is transparent
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

// MARK: - App Entry Point

@main
struct DiscoSpotifyApp: App {
    init() {
        // --- CRITICAL: Check if Spotify Token is Set ---
        if placeholderSpotifyToken.isEmpty || placeholderSpotifyToken == "YOUR_SPOTIFY_BEARER_TOKEN_HERE" {
            print("🚨🕺 FATAL STARTUP WARNING: Spotify Bearer Token is MISSING or using the placeholder!")
            print("👉 FIX: Replace 'YOUR_SPOTIFY_BEARER_TOKEN_HERE' in DiscoSpotifyApp.swift with your actual token.")
            print("👉 API calls will FAIL until this is fixed.")
            // Note: In a real app, you might fetch this dynamically or use a more robust config system.
        }
        
        // --- Global UI Appearance (Optional) ---
        // Set global tint color for elements like the back button arrow, progress views
        UIView.appearance().tintColor = UIColor(discoGold)
        
        // Customize Navigation Bar Title Appearance (Disco Style)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(discoCream),
            .font: UIFont(name: "Funkydori", size: 20) ?? UIFont.systemFont(ofSize: 20, weight: .bold), // Use disco font if available
            .kern: 1.5, // Add slight letter spacing
            .paragraphStyle: paragraphStyle,
            .shadow: { // Add subtle shadow to title text
                let shadow = NSShadow()
                shadow.shadowColor = UIColor.black.withAlphaComponent(0.4)
                shadow.shadowOffset = CGSize(width: 0, height: 1)
                shadow.shadowBlurRadius = 2
                return shadow
            }()
        ]
        UINavigationBar.appearance().titleTextAttributes = titleAttributes
        UINavigationBar.appearance().largeTitleTextAttributes = titleAttributes // For consistency if large titles were used
    }
    
    var body: some Scene {
        WindowGroup {
            SpotifyAlbumListView() // Start with the disco-themed list
                .preferredColorScheme(.dark) // Disco works best in dark mode
        }
    }
}

// IMPORTANT:
// 1.  Replace `"YOUR_SPOTIFY_BEARER_TOKEN_HERE"` with your actual Spotify API token.
// 2.  Custom Fonts: This code uses placeholders like `discoTitleFont`. To get the full effect, you'd need to:
//     *   Find and add actual 70s-style fonts (like "Funkydori", "PlaylistScript", "Georama-Regular") to your Xcode project.
//     *   Ensure they are correctly added to your app's target and listed in the `Info.plist` file under "Fonts provided by application".
//     *   Update the `discoTitleFont`, `discoBodyFont`, and `discoScriptFont` functions to use `Font.custom("YourFontName", size: size)`.
// 3.  Performance: The `SparkleOverlay` and `DiscoLightsBackground` using `Canvas` might impact performance on older devices or with very high density. For production apps, consider Metal or pre-rendered assets for such effects.
