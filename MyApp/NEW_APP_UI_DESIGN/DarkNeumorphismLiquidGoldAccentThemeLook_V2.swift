//
//  DarkNeumorphismLiquidGoldAccentThemeLook_V2.swift
//  MyApp
//
//  Created by Cong Le on 4/18/25.
//

//  Created by Cong Le on // <Date, eg., 4/19/25>
//  Single File Implementation: Deep Dark Neumorphism with Liquid Gold Accent
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

// MARK: - Theme: Deep Dark Neumorphism & Liquid Gold Accent

struct NeumorphicTheme {
    static let darkBackground = Color(red: 0.12, green: 0.13, blue: 0.15) // Very dark grey/blue
    static let elementBackground = Color(red: 0.12, green: 0.13, blue: 0.15) // Same as background for pure neumorphism
    // Slightly lighter/darker versions for subtle variations if needed later
    // static let elementBackgroundSlightlyLighter = Color(red: 0.14, green: 0.15, blue: 0.17)

    static let lightShadow = Color.white.opacity(0.1)  // Subtle light shadow
    static let darkShadow = Color.black.opacity(0.5)   // Deeper dark shadow

    // Liquid Gold Gradient
    static let goldGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0.9, green: 0.7, blue: 0.3), // Lighter Gold
            Color(red: 0.8, green: 0.6, blue: 0.2), // Mid Gold
            Color(red: 0.7, green: 0.5, blue: 0.1)  // Deeper Gold/Bronze
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    static let goldAccent = Color(red: 0.85, green: 0.65, blue: 0.25) // A representative solid gold

    static let primaryText = Color(white: 0.9)   // Off-white for primary text
    static let secondaryText = Color(white: 0.6) // Grey for secondary text
    static let errorColor = Color(red: 0.8, green: 0.2, blue: 0.2) // Muted red for errors

    // Standard neumorphic styling parameters
    static let cornerRadius: CGFloat = 18
    static let shadowRadius: CGFloat = 6
    static let shadowOffset: CGFloat = 4 // Symmetric offset
}

// MARK: - Neumorphic View Modifier/Style

// Option 1: View Modifier
extension View {
    func neumorphicShadow(
        bgColor: Color = NeumorphicTheme.elementBackground,
        lightShadow: Color = NeumorphicTheme.lightShadow,
        darkShadow: Color = NeumorphicTheme.darkShadow,
        cornerRadius: CGFloat = NeumorphicTheme.cornerRadius,
        shadowRadius: CGFloat = NeumorphicTheme.shadowRadius,
        shadowOffset: CGFloat = NeumorphicTheme.shadowOffset
    ) -> some View {
        self
            .background(bgColor)
            .cornerRadius(cornerRadius) // Apply corner radius before shadows
            .shadow(color: lightShadow, radius: shadowRadius, x: -shadowOffset, y: -shadowOffset)
            .shadow(color: darkShadow, radius: shadowRadius, x: shadowOffset, y: shadowOffset)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)) // Clip again to ensure smooth edges
    }

    // Inset Neumorphic Style (for pressed states or selection)
    func neumorphicInset(
        level: CGFloat = 1, // How deep the inset is
        cornerRadius: CGFloat = NeumorphicTheme.cornerRadius
    ) -> some View {
        ZStack {
            // Mimic inset shadows with inner gradients
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(NeumorphicTheme.elementBackground) // Base color
                .overlay(
                    // Dark inner shadow (top/left)
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(NeumorphicTheme.darkShadow.opacity(0.5 * level), lineWidth: NeumorphicTheme.shadowOffset * level)
                        .blur(radius: NeumorphicTheme.shadowRadius * 0.5 * level)
                        .offset(x: NeumorphicTheme.shadowOffset * 0.5 * level, y: NeumorphicTheme.shadowOffset * 0.5 * level)
                        .mask(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                )
                .overlay(
                    // Light inner shadow (bottom/right)
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(NeumorphicTheme.lightShadow.opacity(0.6 * level), lineWidth: NeumorphicTheme.shadowOffset * level)
                        .blur(radius: NeumorphicTheme.shadowRadius * 0.5 * level)
                        .offset(x: -NeumorphicTheme.shadowOffset * 0.5 * level, y: -NeumorphicTheme.shadowOffset * 0.5 * level)
                        .mask(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                )
            self // The content goes on top
        }
    }
}

// Option 2: Neumorphic Surface Struct (More flexible for complex backgrounds)
struct NeumorphicSurface<Content: View>: View {
    let content: Content
    let cornerRadius: CGFloat
    let isInset: Bool

    init(cornerRadius: CGFloat = NeumorphicTheme.cornerRadius, isInset: Bool = false, @ViewBuilder content: () -> Content) {
        self.cornerRadius = cornerRadius
        self.isInset = isInset
        self.content = content()
    }

    var body: some View {
        content
            .padding() // Add padding *inside* the surface
            .background(
                Group { // Use Group to conditionally apply modifiers
                    if isInset {
                        // Apply inset effect logic here (similar to the modifier)
                        ZStack {
                            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous).fill(NeumorphicTheme.elementBackground)
                            // Add inner shadow overlays here... (complex)
                            // Or simplify using the modifier approach on the background itself:
                             RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                                .fill(NeumorphicTheme.elementBackground)
                            // This is slightly different conceptually than the modifier version
                                .overlay(
                                    // Dark top/left (slightly adjusted)
                                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                                        .stroke(NeumorphicTheme.darkShadow, lineWidth: 1)
                                        .blur(radius: 3)
                                        .offset(x: 1, y: 1)
                                        .mask(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                                )
                                .overlay(
                                    // Light bottom/right (slightly adjusted)
                                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                                        .stroke(NeumorphicTheme.lightShadow, lineWidth: 1)
                                        .blur(radius: 3)
                                        .offset(x: -1, y: -1)
                                        .mask(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                                )
                        }
                    } else {
                         RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                           .fill(NeumorphicTheme.elementBackground)
                           .neumorphicShadow(cornerRadius: cornerRadius) // Use the modifier
                    }
                }
            )
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
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // Ensure consistent parsing

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
                dateFormatter.dateStyle = .medium // e.g., Aug 17, 1959
                dateFormatter.timeStyle = .none
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

// MARK: - Spotify Embed WebView (Largely Unchanged Internally)
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

// IMPORTANT: The Spotify Embed itself cannot easily be styled with Neumorphism.
// We will style its *container* using Neumorphism.

//final class SpotifyPlaybackState: ObservableObject {
//    @Published var isPlaying: Bool = false
//    @Published var currentPosition: Double = 0 // seconds
//    @Published var duration: Double = 0 // seconds
//    @Published var currentUri: String = ""
//    @Published var isReady: Bool = false
//    @Published var error: String? = nil
//}

//struct SpotifyEmbedWebView: UIViewRepresentable {
//    @ObservedObject var playbackState: SpotifyPlaybackState
//    let spotifyUri: String?
//
//    func makeCoordinator() -> Coordinator { Coordinator(self) }
//
//    func makeUIView(context: Context) -> WKWebView {
//        // --- Configuration ---
//        let userContentController = WKUserContentController()
//        userContentController.add(context.coordinator, name: "spotifyController")
//
//        let configuration = WKWebViewConfiguration()
//        configuration.userContentController = userContentController
//        configuration.allowsInlineMediaPlayback = true
//        configuration.mediaTypesRequiringUserActionForPlayback = []
//
//        // --- WebView Creation ---
//        let webView = WKWebView(frame: .zero, configuration: configuration)
//        webView.navigationDelegate = context.coordinator
//        webView.uiDelegate = context.coordinator
//        webView.isOpaque = false
//        webView.backgroundColor = .clear // <-- Keep transparent for SwiftUI background
//        webView.scrollView.isScrollEnabled = false // Prevent scrolling within embed
//
//        // --- Load HTML ---
//        let html = generateHTML()
//        webView.loadHTMLString(html, baseURL: nil)
//
//        // --- Store reference ---
//        context.coordinator.webView = webView
//        return webView
//    }
//
//    func updateUIView(_ webView: WKWebView, context: Context) {
//        // Check if the API is ready and the URI needs updating
//        if context.coordinator.isApiReady && context.coordinator.lastLoadedUri != spotifyUri {
//            context.coordinator.loadUri(spotifyUri ?? "")
//            DispatchQueue.main.async {
//                if playbackState.currentUri != spotifyUri { playbackState.currentUri = spotifyUri ?? "" }
//                playbackState.error = nil // Clear error on new URI load attempt
//            }
//        } else if !context.coordinator.isApiReady {
//            context.coordinator.updateDesiredUriBeforeReady(spotifyUri ?? "")
//        }
//    }
//
//    static func dismantleUIView(_ uiView: WKWebView, coordinator: Coordinator) {
//        print("Spotify Embed WebView: Dismantling.")
//        uiView.stopLoading()
//        uiView.configuration.userContentController.removeScriptMessageHandler(forName: "spotifyController")
//        coordinator.webView = nil
//    }
//
//    // --- Coordinator ---
//    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
//        var parent: SpotifyEmbedWebView
//        weak var webView: WKWebView?
//        var isApiReady = false
//        var lastLoadedUri: String?
//        private var desiredUriBeforeReady: String? = nil
//
//        init(_ parent: SpotifyEmbedWebView) { self.parent = parent }
//
//        func updateDesiredUriBeforeReady(_ uri: String) {
//            if !isApiReady { desiredUriBeforeReady = uri }
//        }
//
//        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//            print("Spotify Embed WebView: HTML content finished loading.")
//        }
//        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
//            print("❌ Spotify Embed WebView Provisional Load Error: \(error.localizedDescription)")
//            DispatchQueue.main.async { self.parent.playbackState.error = "Failed to load player resources." }
//        }
//        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
//            print("❌ Spotify Embed WebView Load Error: \(error.localizedDescription)")
//            DispatchQueue.main.async { self.parent.playbackState.error = "Player navigation failed." }
//        }
//        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
//            guard message.name == "spotifyController" else { return }
//            if let bodyDict = message.body as? [String: Any], let event = bodyDict["event"] as? String {
//                print("📦 Spotify Native Received Event: '\(event)', Data: \(bodyDict)")
//                handleEvent(event: event, data: bodyDict["data"])
//            } else if let bodyString = message.body as? String {
//                print("📦 Spotify Native Received String: '\(bodyString)'")
//                if bodyString == "ready" { handleApiReady() }
//            } else { print("❓ Spotify Native Received Unknown: \(message.body)") }
//        }
//
//        private func handleApiReady() {
//            if isApiReady { return } // Prevent double calls
//            print("✅ Spotify Embed Native: API Ready.")
//            isApiReady = true
//             DispatchQueue.main.async { self.parent.playbackState.isReady = true }
//            // Use the most recently desired URI when creating the controller
//            if let initialUri = desiredUriBeforeReady ?? parent.spotifyUri {
//                createSpotifyController(with: initialUri)
//            }
//            desiredUriBeforeReady = nil // Clear it after use
//        }
//
//        private func handleEvent(event: String, data: Any?) {
//            switch event {
//            case "controllerCreated":
//                print("✅ Spotify Embed Native: Controller Created.")
//                DispatchQueue.main.async { self.parent.playbackState.error = nil } // Clear error if success
//            case "playbackUpdate":
//                if let updateData = data as? [String: Any] { updatePlaybackState(with: updateData) }
//            case "error":
//                let errorMessage = (data as? [String: Any])?["message"] as? String ?? (data as? String) ?? "Unknown player error"
//                print("❌ Spotify Embed JS Error: \(errorMessage)")
//                 DispatchQueue.main.async { self.parent.playbackState.error = errorMessage }
//            default:
//                print("❓ Spotify Embed Native: Received unknown event: \(event)")
//            }
//        }
//
//        private func updatePlaybackState(with data: [String: Any]) {
//            DispatchQueue.main.async { [weak self] in
//                guard let self = self else { return }
//                if let isPaused = data["paused"] as? Bool {
//                    if self.parent.playbackState.isPlaying == isPaused { self.parent.playbackState.isPlaying = !isPaused }
//                }
//                if let posMs = data["position"] as? Double {
//                    let newPosition = posMs / 1000.0
//                    // Add tolerance check if updates are too frequent
//                    self.parent.playbackState.currentPosition = newPosition
//                }
//                if let durMs = data["duration"] as? Double {
//                    let newDuration = durMs / 1000.0
//                     if abs(self.parent.playbackState.duration - newDuration) > 0.1 || self.parent.playbackState.duration == 0 {
//                        self.parent.playbackState.duration = newDuration
//                    }
//                }
//                 if let uri = data["uri"] as? String, self.parent.playbackState.currentUri != uri {
//                     self.parent.playbackState.currentUri = uri
//                 }
//                self.parent.playbackState.error = nil // Clear error on successful update
//            }
//        }
//
//        private func createSpotifyController(with initialUri: String) {
//            guard let webView = webView, isApiReady else { print("⚠️ Spotify Embed Native: createSpotifyController called too early or webView missing."); return }
//             guard lastLoadedUri == nil else {
//                 print("ℹ️ Spotify Embed Native: Controller already initialized or attempt pending.")
//                 // Reload if URI changed *while* API was loading
//                 if let finalDesiredUri = desiredUriBeforeReady ?? parent.spotifyUri, finalDesiredUri != lastLoadedUri {
//                     loadUri(finalDesiredUri)
//                     desiredUriBeforeReady = nil
//                 }
//                 return
//             }
//            print("🚀 Spotify Embed Native: Creating controller for URI: \(initialUri)")
//            lastLoadedUri = initialUri // Mark as attempting
//
//            let script = "// ... JS code for creating controller & adding listeners (same as previous version) ..."
//            webView.evaluateJavaScript(script) { _, error in
//                if let error = error {
//                    print("⚠️ Spotify Embed Native: Error evaluating JS controller creation: \(error.localizedDescription)")
//                    DispatchQueue.main.async { self.parent.playbackState.error = "Failed to initialize player (JS error)." }
//                }
//            }
//        }
//
//        func loadUri(_ uri: String) {
//            guard let webView = webView, isApiReady, lastLoadedUri != nil else { return } // Must be ready & initialized
//            guard lastLoadedUri != uri else { return }
//            print("🚀 Spotify Embed Native: Loading new URI: \(uri)")
//            lastLoadedUri = uri // Update the last loaded URI
//
//             let script = "// ... JS code for loading URI (same as previous version) ..."
//            webView.evaluateJavaScript(script) { _, error in
//                if let error = error {
//                    print("⚠️ Spotify Embed Native: Error evaluating JS load URI \(uri): \(error.localizedDescription)")
//                    DispatchQueue.main.async { self.parent.playbackState.error = "Failed to load track (JS error)." }
//                }
//            }
//        }
//        
//        // --- WKUIDelegate (Alert Panel Handling) ---
//         func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
//             print("ℹ️ Spotify Embed Received JS Alert: \(message)")
//             // Handle specific alerts if needed, e.g., "Premium required"
//             if message.lowercased().contains("premium required") {
//                 DispatchQueue.main.async { self.parent.playbackState.error = "Spotify Premium required for playback." }
//             }
//             completionHandler()
//         }
//    }
//
//    // --- Generate HTML (Ensure API script has error handling) ---
//    private func generateHTML() -> String {
//        """
//        <!DOCTYPE html><html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no"><title>Spotify Embed</title><style>html, body { margin: 0; padding: 0; width: 100%; height: 100%; overflow: hidden; background-color: transparent; } #embed-iframe { width: 100%; height: 100%; box-sizing: border-box; display: block; border: none; }</style></head><body><div id="embed-iframe"></div><script src="https://open.spotify.com/embed/iframe-api/v1" async></script><script> console.log('Spotify Embed JS: Initial script running.'); window.onSpotifyIframeApiReady = (IFrameAPI) => { console.log('✅ Spotify Embed JS: API Ready.'); window.IFrameAPI = IFrameAPI; if (window.webkit?.messageHandlers?.spotifyController) { window.webkit.messageHandlers.spotifyController.postMessage("ready"); } else { console.error('❌ Spotify Embed JS: Native message handler not found!'); } }; const scriptTag = document.querySelector('script[src*="iframe-api"]'); if (scriptTag) { scriptTag.onerror = (event) => { console.error('❌ Spotify Embed JS: Failed to load API script:', event); window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'Failed to load Spotify API script' }}); }; } else { console.warn('⚠️ Spotify Embed JS: Could not find API script tag.'); } </script></body></html>
//        """
//    }
//}

// MARK: - API Service (Unchanged - Requires Token)

// <<----- IMPORTANT: PASTE YOUR BEARER TOKEN HERE ----->>
let spotifyBearerToken = "TOKEN_HERE" // Replace or use a secure method!
// <<----------------------------------------------------->>

enum SpotifyAPIError: Error, LocalizedError {
    case invalidURL
    case networkError(Error)
    case invalidResponse(Int, String?) // Include optional response body for debugging
    case decodingError(Error)
    case invalidToken
    case missingData // Generic error if expected data isn't there

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Could not create a valid API request URL."
        case .networkError(let error): return "Network connection failed: \(error.localizedDescription)"
        case .invalidResponse(let code, _):
            return code == 401 ? "Authentication failed. Check API token." : "Server returned an error (Code: \(code))."
        case .decodingError: return "Could not parse the server response." // Keep simple for user
        case .invalidToken: return "Spotify API Token is invalid or expired."
        case .missingData: return "Response received, but expected data was missing."
        }
    }

    var detailedDescription: String { // For debugging
        switch self {
        case .invalidURL: return "Invalid URL generated for API request."
        case .networkError(let error): return "Network Error: \(error)"
        case .invalidResponse(let code, let body): return "Invalid Response: Code \(code), Body: \(body ?? "N/A")"
        case .decodingError(let error): // Provide more decoding context
            if let decodingError = error as? DecodingError {
                 switch decodingError {
                     case .typeMismatch(let type, let context): return "Decoding Error: Type mismatch for type \(type) - \(context.codingPath): \(context.debugDescription)"
                     case .valueNotFound(let type, let context): return "Decoding Error: Value not found for type \(type) - \(context.codingPath): \(context.debugDescription)"
                     case .keyNotFound(let key, let context): return "Decoding Error: Key not found '\(key)' - \(context.codingPath): \(context.debugDescription)"
                     case .dataCorrupted(let context): return "Decoding Error: Data corrupted - \(context.codingPath): \(context.debugDescription)"
                     @unknown default: return "Decoding Error: Unknown decoding error - \(error.localizedDescription)"
                 }
            } else {
                return "Decoding Error: \(error.localizedDescription)"
            }
        case .invalidToken: return "Invalid Token: Bearer token rejected by Spotify API."
        case .missingData: return "Missing Data: The API response structure did not contain expected fields."
        }
    }
}

struct SpotifyAPIService {
    static let shared = SpotifyAPIService()
    private let session: URLSession

    init() {
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData // Avoid stale cache issues
        session = URLSession(configuration: configuration)
    }

    private func makeRequest<T: Decodable>(url: URL) async throws -> T {
        // Token Check (moved from @main for clarity)
        guard !spotifyBearerToken.isEmpty, spotifyBearerToken != "YOUR_SPOTIFY_BEARER_TOKEN_HERE" else {
            print("❌ API Error: Spotify Bearer Token is missing or placeholder.")
            throw SpotifyAPIError.invalidToken
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(spotifyBearerToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 20 // Reasonable timeout

        print("🚀 Making API Request to: \(url.absoluteString)")

        do {
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw SpotifyAPIError.invalidResponse(0, "Response was not HTTP.")
            }

            print("🚦 HTTP Status: \(httpResponse.statusCode)")

            guard (200...299).contains(httpResponse.statusCode) else {
                let responseBody = String(data: data, encoding: .utf8)
                print("❌ Server Error Body: \(responseBody ?? "N/A")")
                if httpResponse.statusCode == 401 { throw SpotifyAPIError.invalidToken }
                throw SpotifyAPIError.invalidResponse(httpResponse.statusCode, responseBody)
            }

            do {
                let decoder = JSONDecoder()
                return try decoder.decode(T.self, from: data)
            } catch {
                print("❌ Decode Error: \(error)")
                print("Raw Data: \(String(data: data, encoding: .utf8) ?? "Unable to decode data")")
                throw SpotifyAPIError.decodingError(error)
            }
        } catch let error where !(error is CancellationError) {
            print("❌ Network/API Error: \(error.localizedDescription)")
            // Re-throw specific API errors, wrap others
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
        // Add market parameter if needed: URLQueryItem(name: "market", value: "US")
        guard let url = components?.url else { throw SpotifyAPIError.invalidURL }
        return try await makeRequest(url: url)
    }
}

// MARK: - SwiftUI Views (Themed)

// MARK: Main List View
struct SpotifyAlbumListView: View {
    @State private var searchQuery: String = ""
    @State private var displayedAlbums: [AlbumItem] = []
    @State private var isLoading: Bool = false
    @State private var searchInfo: Albums? = nil
    @State private var currentError: SpotifyAPIError? = nil
    @State private var searchTask: Task<Void, Never>? = nil

    var body: some View {
        NavigationView {
            ZStack {
                // --- Background ---
                NeumorphicTheme.darkBackground.ignoresSafeArea()

                // --- Content ---
                VStack(spacing: 0) { // Remove default spacing
                    if isLoading && displayedAlbums.isEmpty {
                        Spacer()
                        NeumorphicLoadingIndicator()
                        Spacer()
                    } else if let error = currentError {
                        Spacer()
                        ErrorPlaceholderView(error: error) {
                            triggerSearch(immediate: true)
                        }
                        Spacer()
                    } else {
                        albumListContent // The main list or empty state
                    }
                }
            }
            .navigationTitle("Album Search")
            .navigationBarTitleDisplayMode(.large) // Change if desired
            .toolbarBackground(NeumorphicTheme.darkBackground, for: .navigationBar) // Dark background for nav bar
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar) // Ensure title/buttons are light

            // --- Search Bar ---
            // System searchable is hard to style deeply with neumorphism.
            // Keep it functional.
            .searchable(text: $searchQuery,
                        placement: .navigationBarDrawer(displayMode: .always),
                        prompt: Text("Search Albums & Artists").foregroundColor(NeumorphicTheme.secondaryText))
            .onSubmit(of: .search) { triggerSearch(immediate: true) }
            .onChange(of: searchQuery) {
                currentError = nil // Clear error on new search
                triggerSearch() // Trigger debounced search
            }
            // Use gold for the search bar's tint color (cursor, cancel button)
             .tint(NeumorphicTheme.goldAccent)
        }
        .accentColor(NeumorphicTheme.goldAccent) // General accent for things like back button
    }

    // Extracted list content view
    @ViewBuilder
    private var albumListContent: some View {
        if displayedAlbums.isEmpty && !isLoading && currentError == nil {
            // Show empty state only if not loading and no error
            Spacer()
            EmptyStatePlaceholderView(searchQuery: searchQuery)
            Spacer()
        } else {
            List {
                 // --- Header (Optional) ---
                 if let info = searchInfo, info.total > 0 {
                     SearchMetadataHeader(totalResults: info.total, limit: info.limit, offset: info.offset)
                         .listRowInsets(EdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 20)) // Adjust padding
                         .listRowSeparator(.hidden)
                         .listRowBackground(Color.clear)
                 }

                // --- Album Cards ---
                ForEach(displayedAlbums) { album in
                    NavigationLink(destination: AlbumDetailView(album: album)) {
                        NeumorphicAlbumCard(album: album)
                    }
                    .listRowSeparator(.hidden) // Hide default separators
                    .listRowInsets(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15)) // Padding *around* the row/card
                    .listRowBackground(NeumorphicTheme.darkBackground) // Ensure row background matches main background
                }

                 // --- Loading More Indicator ---
                 // Add logic here if you implement pagination
            }
            .listStyle(.plain) // Plain style to allow background color
            .scrollContentBackground(.hidden) // Crucial for background color
            .overlay { // Subtle loading indicator for subsequent loads
                 if isLoading && !displayedAlbums.isEmpty {
                     VStack {
                         Spacer()
                         NeumorphicLoadingIndicator(size: 30, text: "Loading...")
                             .padding(.bottom, 10)
                     }
                     .transition(.opacity.animation(.easeInOut))
                 }
            }
        }
    }

    
    // --- Debounced Search Logic ---
    private func triggerSearch(immediate: Bool = false) {
        searchTask?.cancel() // Cancel previous task
        
        let currentQuery = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !immediate || !currentQuery.isEmpty else {
            // If immediate and empty, clear results. If debounced and empty, handled inside task.
            if immediate {
                Task { await MainActor.run { displayedAlbums = []; searchInfo = nil; isLoading = false; currentError = nil } }
            }
            return
        }

        searchTask = Task {
            // Handle empty query after debounce delay
            if currentQuery.isEmpty {
                 await MainActor.run { displayedAlbums = []; searchInfo = nil; isLoading = false; currentError = nil }
                return
            }
            
            if !immediate {
                do {
                    try await Task.sleep(for: .milliseconds(500)) // Debounce delay
                    try Task.checkCancellation()
                } catch {
                    print("Search task cancelled (debounce).")
                    return
                }
            }
            
            await MainActor.run { isLoading = true /* Don't clear albums here for loading indicator overlay */ }
            
            do {
                print("Executing search for: \(currentQuery)")
                let response = try await SpotifyAPIService.shared.searchAlbums(query: currentQuery, offset: 0)
                try Task.checkCancellation() // Check again before UI update
                await MainActor.run {
                    displayedAlbums = response.albums.items
                    searchInfo = response.albums
                    currentError = nil
                    isLoading = false
                    print("Search successful, \(response.albums.items.count) items loaded.")
                }
            } catch is CancellationError {
                print("Search task explicitly cancelled.")
                // Don't change isLoading state if cancelled, might interfere with new task
                await MainActor.run { if !Task.isCancelled { isLoading = false } } // Only reset if *this* task wasn't immediately replaced
            } catch let apiError as SpotifyAPIError {
                print("❌ API Error: \(apiError.detailedDescription)")
                await MainActor.run { currentError = apiError; isLoading = false; displayedAlbums = []; searchInfo = nil }
            } catch {
                print("❌ Unexpected Search Error: \(error)")
                await MainActor.run { currentError = .networkError(error); isLoading = false; displayedAlbums = []; searchInfo = nil }
            }
        }
    }
}

// MARK: Neumorphic Album Card
struct NeumorphicAlbumCard: View {
    let album: AlbumItem

    var body: some View {
        HStack(spacing: 15) {
            // --- Album Art ---
            AlbumImageView(url: album.listImageURL) // Use the standard image view
                .frame(width: 70, height: 70) // Slightly smaller for list view
                .neumorphicShadow(cornerRadius: 10, shadowRadius: 4, shadowOffset: 3) // Neumorphic frame for image

            // --- Text Details ---
            VStack(alignment: .leading, spacing: 4) {
                Text(album.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(NeumorphicTheme.primaryText)
                    .lineLimit(2)

                Text(album.formattedArtists)
                    .font(.system(size: 13))
                    .foregroundColor(NeumorphicTheme.secondaryText)
                    .lineLimit(1)

                Spacer() // Push bottom info down

                HStack(spacing: 6) {
                    Image(systemName: album.album_type == "album" ? "opticaldisc" : "rectangle.stack")
                        .font(.system(size: 10))
                        .foregroundColor(NeumorphicTheme.secondaryText)
                    Text(album.album_type.capitalized)
                        .font(.system(size: 11))
                        .foregroundColor(NeumorphicTheme.secondaryText)

                    Text("•")
                        .foregroundColor(NeumorphicTheme.secondaryText.opacity(0.5))

                    Text(album.formattedReleaseDate())
                        .font(.system(size: 11))
                        .foregroundColor(NeumorphicTheme.secondaryText)
                }
                .padding(.top, 2)

            } // End Text VStack
            .frame(maxWidth: .infinity, alignment: .leading) // Take available space
            .padding(.vertical, 5) // Add some vertical padding to text block

        } // End HStack
        .padding(12) // Padding inside the card surface
        .background(NeumorphicTheme.elementBackground) // Base color
        // Apply neumorphic shadow to the entire HStack background
        .neumorphicShadow(cornerRadius: 15, shadowRadius: 5, shadowOffset: 4)
    }
}

// MARK: - Album Detail View
struct AlbumDetailView: View {
    let album: AlbumItem
    @State private var tracks: [Track] = []
    @State private var isLoadingTracks: Bool = false
    @State private var trackFetchError: SpotifyAPIError? = nil
    @State private var selectedTrackUri: String? = nil
    @StateObject private var playbackState = SpotifyPlaybackState()

    var body: some View {
        ZStack {
            NeumorphicTheme.darkBackground.ignoresSafeArea()

            List {
                // --- Header Section ---
                Section { AlbumHeaderView(album: album) }
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)

                // --- Player Section (Themed Container) ---
                Section {
                    if let uriToPlay = selectedTrackUri {
                        NeumorphicPlayerView(playbackState: playbackState, spotifyUri: uriToPlay)
                            .transition(.opacity.combined(with: .scale(scale: 0.95, anchor: .top)).animation(.easeInOut(duration: 0.3)))
                    } else if playbackState.error != nil {
                         // Show player container with error
                         NeumorphicPlayerView(playbackState: playbackState, spotifyUri: nil)
                    }
                }
                .listRowInsets(EdgeInsets(top: 10, leading: 15, bottom: 15, trailing: 15)) // Padding around player container
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)

                // --- Tracks Section ---
                Section {
                    TracksSectionView(
                        tracks: tracks,
                        isLoading: isLoadingTracks,
                        error: trackFetchError,
                        selectedTrackUri: $selectedTrackUri,
                        retryAction: { Task { await fetchTracks() } }
                    )
                } header: {
                    Text("Tracks")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(NeumorphicTheme.secondaryText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 20).padding(.bottom, 5).padding(.top, 10)
                }
                .listRowInsets(EdgeInsets()) // Remove section insets
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear) // Ensure section background is clear

                // --- External Link Section ---
                if let spotifyURL = URL(string: album.external_urls.spotify ?? "") {
                    Section {
                        NeumorphicButton(
                            action: { openURL(spotifyURL) },
                            label: {
                                HStack {
                                    Image(systemName: "arrow.up.forward.app.fill")
                                    Text("Open in Spotify")
                                }
                            },
                            isGold: true // Use gold accent for this prominent action
                        )
                    }
                    .listRowInsets(EdgeInsets(top: 20, leading: 20, bottom: 30, trailing: 20))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }

            } // End List
            .listStyle(.plain)
            .scrollContentBackground(.hidden)

        } // End ZStack
        .navigationTitle(album.name) // Keep navigation title
        .navigationBarTitleDisplayMode(.inline) // Or .large
        .toolbarBackground(NeumorphicTheme.darkBackground, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .task { await fetchTracks() }
        .animation(.easeInOut(duration: 0.3), value: selectedTrackUri) // Animate player appearance
        .animation(.easeInOut, value: playbackState.error) // Animate error appearance
         .refreshable { await fetchTracks(forceReload: true) } // Pull to refresh tracks
    }

    // --- Helper to open URL ---
    @Environment(\.openURL) var openURL

    // --- Fetch Tracks Logic ---
    private func fetchTracks(forceReload: Bool = false) async {
        // Only fetch if forced, or if tracks are empty/error occurred
        guard forceReload || tracks.isEmpty || trackFetchError != nil else { return }

        await MainActor.run { isLoadingTracks = true; trackFetchError = nil } // Clear previous error on retry
        do {
            let response = try await SpotifyAPIService.shared.getAlbumTracks(albumId: album.id)
            try Task.checkCancellation()
            await MainActor.run {
                 self.tracks = response.items;
                 self.isLoadingTracks = false
                 // Auto-select first track if desired (optional)
                 // if selectedTrackUri == nil, selectedTrackUri = tracks.first?.uri
            }
        } catch is CancellationError {
            await MainActor.run { isLoadingTracks = false } // Reset loading if cancelled
        } catch let apiError as SpotifyAPIError {
             print("❌ Fetch Tracks API Error: \(apiError.detailedDescription)")
            await MainActor.run { self.trackFetchError = apiError; self.isLoadingTracks = false; self.tracks = [] }
        } catch {
            print("❌ Unexpected Fetch Tracks Error: \(error)")
            await MainActor.run { self.trackFetchError = .networkError(error); self.isLoadingTracks = false; self.tracks = [] }
        }
    }
}

// MARK: - DetailView Sub-Components (Themed)

struct AlbumHeaderView: View {
    let album: AlbumItem

    var body: some View {
        VStack(spacing: 18) {
            AlbumImageView(url: album.bestImageURL)
                .aspectRatio(1.0, contentMode: .fit)
                .padding(8) // Padding *inside* the neumorphic frame
                .neumorphicShadow(cornerRadius: 25, shadowRadius: 8, shadowOffset: 5) // Larger radius/offset for header image
                .padding(.horizontal, 40) // Spacing from screen edges

            VStack(spacing: 5) {
                Text(album.name)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(NeumorphicTheme.primaryText)
                    .multilineTextAlignment(.center)

                // Use gold accent for artist name
                Text("by \(album.formattedArtists)")
                    .font(.system(size: 16))
                    .foregroundStyle(NeumorphicTheme.goldGradient) // Apply gradient to text
                    .multilineTextAlignment(.center)

                Text("\(album.album_type.capitalized) • \(album.formattedReleaseDate())")
                    .font(.system(size: 12))
                    .foregroundColor(NeumorphicTheme.secondaryText)
            }
            .padding(.horizontal)

        }
        .padding(.vertical, 25) // Overall padding for the header section
    }
}

// Renamed from SpotifyEmbedPlayerView for clarity
struct NeumorphicPlayerView: View {
    @ObservedObject var playbackState: SpotifyPlaybackState
    let spotifyUri: String? // Can be nil if just showing error

    var body: some View {
        VStack(spacing: 10) {
             // Embed WebView or Error Message
             if let error = playbackState.error {
                 HStack {
                     Image(systemName: "exclamationmark.triangle.fill")
                         .foregroundColor(NeumorphicTheme.errorColor)
                     Text(error)
                         .font(.system(size: 12))
                         .foregroundColor(NeumorphicTheme.errorColor)
                         .lineLimit(2)
                     Spacer()
                 }
                 .padding(.horizontal)
                 .frame(height: 80) // Match height of player
             } else if let uri = spotifyUri {
                 SpotifyEmbedWebView(playbackState: playbackState, spotifyUri: uri)
                     .frame(height: 80) // Standard embed height
                     .disabled(!playbackState.isReady) // Disable interaction until ready
                      .overlay { // Show loading overlay until ready
                          if !playbackState.isReady {
                              ZStack {
                                  NeumorphicTheme.elementBackground.opacity(0.8) // Semi-transparent overlay
                                   HStack {
                                      ProgressView().tint(NeumorphicTheme.goldAccent)
                                      Text("Loading Player...")
                                         .font(.caption)
                                         .foregroundColor(NeumorphicTheme.secondaryText)
                                  }
                              }
                          }
                      }
             } else {
                 // Placeholder if no URI and no error (shouldn't normally happen
                 // if parent view logic is correct, but good fallback)
                 Text("Select a track to play.")
                     .font(.system(size: 12))
                     .foregroundColor(NeumorphicTheme.secondaryText)
                     .frame(height: 80)
             }

            // --- Playback Status & Time ---
            HStack {
                // Use gold gradient for status when playing
                Text(playbackState.isPlaying ? "Playing" : "Paused")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(playbackState.isPlaying ? NeumorphicTheme.goldGradient : LinearGradient(colors: [NeumorphicTheme.secondaryText], startPoint: .top, endPoint: .bottom))
                    .animation(.easeInOut, value: playbackState.isPlaying)

                Spacer()

                // Time display
                if playbackState.duration > 0.1 && playbackState.error == nil {
                    Text("\(formatTime(playbackState.currentPosition)) / \(formatTime(playbackState.duration))")
                        .font(.system(size: 11, weight: .regular, design: .monospaced)) // Monospaced for time
                        .foregroundColor(NeumorphicTheme.secondaryText)
                } else {
                    Text("--:-- / --:--")
                        .font(.system(size: 11, weight: .regular, design: .monospaced))
                        .foregroundColor(NeumorphicTheme.secondaryText.opacity(0.5))
                }
            }
            .padding(.top, 4) // Space between embed and status line

        } // End VStack
        .padding(.vertical, 12) // Padding inside the surface
        .padding(.horizontal, 10)
        .background(NeumorphicTheme.elementBackground)
        .neumorphicShadow(cornerRadius: 15) // Apply neumorphism to the container
        .animation(.easeInOut, value: playbackState.error) // Animate error appearance
    }

    private func formatTime(_ time: Double) -> String {
        let totalSeconds = max(0, Int(time))
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

#Preview("NeumorphicPlayerView") {
    NeumorphicPlayerView(playbackState: .init(), spotifyUri: "spotify:album:1weenld61qoidwYuZ1GESA")
}

struct TracksSectionView: View {
    let tracks: [Track]
    let isLoading: Bool
    let error: SpotifyAPIError?
    @Binding var selectedTrackUri: String?
    let retryAction: () -> Void

    var body: some View {
        VStack(spacing: 0) { // Use VStack to apply background/shadow to the whole section
            if isLoading {
                 NeumorphicLoadingIndicator(text: "Loading Tracks...")
                     .padding(.vertical, 30)
            } else if let error = error {
                 VStack { // Add VStack for padding around error
                    ErrorPlaceholderView(error: error, retryAction: retryAction)
                 }.padding(.vertical, 20)
            } else if tracks.isEmpty {
                Text("No Tracks Found")
                    .foregroundColor(NeumorphicTheme.secondaryText)
                    .padding(.vertical, 30)
            } else {
                 // Apply neumorphic effect to each track row individually
                ForEach(tracks) { track in
                    TrackRowView(
                        track: track,
                        isSelected: track.uri == selectedTrackUri
                    )
                    .contentShape(Rectangle()) // Make whole row tappable
                    .onTapGesture {
                        if selectedTrackUri != track.uri { // Only update if different
                            selectedTrackUri = track.uri
                        }
                    }
                    // Add divider subtly (optional)
                    Divider()
                      .background(NeumorphicTheme.darkShadow.opacity(0.3))
                      .padding(.leading, 45) // Indent divider
                      .opacity(track.id == tracks.last?.id ? 0 : 1) // Hide last divider
                }
            }
        }
         // Apply neumorphic shadow to the whole list background area
         .padding(.vertical, 5) // Padding inside the tracks container
         .background(NeumorphicTheme.elementBackground)
         .neumorphicShadow(cornerRadius: NeumorphicTheme.cornerRadius)
         .padding(.horizontal, 15) // Padding *around* the tracks container
    }
}

struct TrackRowView: View {
    let track: Track
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 12) {
            // --- Track Number/Indicator ---
            ZStack {
                // Show play icon if selected, otherwise track number
                if isSelected {
                    Image(systemName: "waveform") // Use waveform for selected/playing
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(NeumorphicTheme.goldGradient) // Gold accent
                } else {
                    Text("\(track.track_number)")
                        .font(.system(size: 12, weight: .regular, design: .monospaced))
                        .foregroundColor(NeumorphicTheme.secondaryText)
                }
            }
            .frame(width: 25, alignment: .center)

            // --- Track Info ---
            VStack(alignment: .leading, spacing: 3) {
                Text(track.name)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(NeumorphicTheme.primaryText)
                    .lineLimit(1)

                Text(track.formattedArtists)
                    .font(.system(size: 12))
                    .foregroundColor(NeumorphicTheme.secondaryText)
                    .lineLimit(1)
            }

            Spacer()

            // --- Explicit Badge (Optional) ---
            if track.explicit {
                Text("E")
                    .font(.system(size: 10, weight: .bold))
                    .padding(.horizontal, 4)
                    .padding(.vertical, 1)
                    .background(NeumorphicTheme.secondaryText.opacity(0.3), in: RoundedRectangle(cornerRadius: 3))
                    .foregroundColor(NeumorphicTheme.secondaryText)
            }

            // --- Duration ---
            Text(track.formattedDuration)
                .font(.system(size: 12, weight: .regular, design: .monospaced))
                .foregroundColor(NeumorphicTheme.secondaryText)
                .frame(width: 40, alignment: .trailing) // Fixed width for alignment
        }
        .padding(.vertical, 14) // Increase tap height
        .padding(.horizontal, 15) // Padding within the row
        .background(isSelected ? NeumorphicTheme.darkBackground.opacity(0.5) : Color.clear) // Subtle selected background
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

// MARK: - Neumorphic Button
struct NeumorphicButton<Label: View>: View {
    let action: () -> Void
    let label: () -> Label
    var isGold: Bool = false // Whether to use gold accent

    @State private var isPressed: Bool = false

    var body: some View {
        Button(action: {
            action()
            // Optional: haptic feedback
            // UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }) {
            label()
                .font(.system(size: 15, weight: .medium))
                .padding(.vertical, 12)
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity) // Expand to fill width
                .foregroundStyle(isGold ? NeumorphicTheme.goldGradient : LinearGradient(colors: [NeumorphicTheme.primaryText], startPoint: .top, endPoint: .bottom)) // Conditional foreground
                .background(
                    Group { // Apply inset effect when pressed
                        if isPressed {
                            RoundedRectangle(cornerRadius: NeumorphicTheme.cornerRadius, style: .continuous)
                                .fill(NeumorphicTheme.elementBackground)
                                .neumorphicInset(level: 1.5, cornerRadius: NeumorphicTheme.cornerRadius) // Deeper inset
                        } else {
                             RoundedRectangle(cornerRadius: NeumorphicTheme.cornerRadius, style: .continuous)
                                .fill(NeumorphicTheme.elementBackground)
                                .neumorphicShadow() // Standard shadow
                        }
                    }
                )
                .animation(.spring(response: 0.2, dampingFraction: 0.7), value: isPressed) // Smooth press animation
        }
        .buttonStyle(PlainButtonStyle()) // Use PlainButtonStyle to allow custom background/foreground
//        .pressEvent { pressing in // Custom modifier to track press state
//            isPressed = pressing
//        }
    }
}

// Custom Press Event Modifier
struct PressActions: ViewModifier {
    var onPress: () -> Void
    var onRelease: () -> Void

    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged({ _ in onPress() })
                    .onEnded({ _ in onRelease() })
            )
    }
}

extension View {
    func pressEvent(onPress: @escaping (() -> Void), onRelease: @escaping (() -> Void)) -> some View {
        modifier(PressActions(onPress: { onPress() }, onRelease: { onRelease() }))
    }
    // Convenience for state binding
    func pressEvent(pressing: Binding<Bool>) -> some View {
        modifier(PressActions(onPress: { pressing.wrappedValue = true }, onRelease: { pressing.wrappedValue = false }))
    }
}

// MARK: Other Supporting Views (Themed)

struct AlbumImageView: View { // Uses standard AsyncImage, placeholder is themed
    let url: URL?

    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
                // Neumorphic placeholder
                ZStack {
                    NeumorphicTheme.elementBackground
                    ProgressView()
                        .tint(NeumorphicTheme.goldAccent) // Gold loading indicator
                }
            case .success(let image):
                image.resizable().scaledToFit()
            case .failure:
                // Neumorphic error placeholder
                ZStack {
                     NeumorphicTheme.elementBackground
                    Image(systemName: "photo.fill")
                        .resizable().scaledToFit().padding()
                        .foregroundColor(NeumorphicTheme.secondaryText.opacity(0.5))
                }
            @unknown default: EmptyView()
            }
        }
        // Apply neumorphic shadow to the AsyncImage frame itself
         .neumorphicShadow(cornerRadius: 10, shadowRadius: 4, shadowOffset: 3) // Moved to card/header view
    }
}

struct SearchMetadataHeader: View {
    let totalResults: Int
    let limit: Int
    let offset: Int

    var body: some View {
        HStack {
            Text("Results: \(totalResults)")
            Spacer()
            if totalResults > limit {
                Text("Showing: \(offset + 1)-\(min(offset + limit, totalResults))")
            }
        }
        .font(.system(size: 11, weight: .regular))
        .foregroundColor(NeumorphicTheme.secondaryText)
    }
}

struct NeumorphicLoadingIndicator: View {
    var size: CGFloat = 50
    var text: String? = nil
    
    var body: some View {
        VStack(spacing: 15) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .tint(NeumorphicTheme.goldAccent) // Gold accent
                .scaleEffect(size / 40) // Scale based on default ≈40pt size
                // Apply neumorphic look *around* the ProgressView
                .frame(width: size * 1.5, height: size * 1.5)
                .background(NeumorphicTheme.elementBackground)
                .neumorphicShadow(cornerRadius: (size * 1.5) / 2) // Circular shadow

            if let text = text {
                Text(text)
                    .font(.system(size: 13))
                    .foregroundColor(NeumorphicTheme.secondaryText)
            }
        }
    }
}

struct ErrorPlaceholderView: View {
    let error: SpotifyAPIError
    let retryAction: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 18) {
            Image(systemName: iconName)
                 .font(.system(size: 45, weight: .light))
                 .foregroundStyle(NeumorphicTheme.goldGradient) // Gold icon
                 .padding(20)
                 .background(NeumorphicTheme.elementBackground)
                 // Make the icon container neumorphic
                 .neumorphicShadow(cornerRadius: 35, shadowRadius: 8, shadowOffset: 5) // Circular

            Text("Error")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(NeumorphicTheme.primaryText)

            Text(error.localizedDescription) // User-friendly error message
                .font(.system(size: 13))
                .foregroundColor(NeumorphicTheme.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)

            // Show detailed message for token errors
            if case .invalidToken = error {
                 Text("Please ensure a valid Spotify Bearer Token is set in the code.")
                    .font(.system(size: 11))
                    .foregroundColor(NeumorphicTheme.errorColor)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }

            // Retry Button (only if action provided and not a token error)
            if let retryAction = retryAction,
               case .invalidToken = error {} else if let retryAction = retryAction {
                NeumorphicButton(
                    action: retryAction,
                    label: { Text("Retry") },
                    isGold: true // Use gold for retry action
                )
                .padding(.top, 10)
                .frame(width: 150) // Make retry button smaller
            }
        }
        .padding(30) // Padding inside the overall container
        .background(NeumorphicTheme.elementBackground)
        .neumorphicShadow(cornerRadius: 25) // Neumorphic container for the error message
        .padding(20) // Padding around the container
    }

    private var iconName: String {
        switch error {
        case .invalidToken: return "key.slash"
        case .networkError: return "wifi.slash"
        case .invalidResponse, .decodingError, .missingData: return "exclamationmark.triangle.fill"
        case .invalidURL: return "link.circle.fill"
        }
    }
}

struct EmptyStatePlaceholderView: View {
     let searchQuery: String
    
     var body: some View {
        VStack(spacing: 18) {
            Image(systemName: iconName)
                .font(.system(size: 50, weight: .thin)) // Thinner icon
                .foregroundStyle(NeumorphicTheme.goldGradient) // Gold icon
                .padding(25)
                .background(NeumorphicTheme.elementBackground)
                .neumorphicShadow(cornerRadius: 42.5, shadowRadius: 8, shadowOffset: 5) // Circular

            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(NeumorphicTheme.primaryText)

            Text(message)
                .font(.system(size: 13))
                .foregroundColor(NeumorphicTheme.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
         .padding(30) // Padding inside the overall container
         .background(NeumorphicTheme.elementBackground)
         .neumorphicShadow(cornerRadius: 25) // Neumorphic container
         .padding(20) // Padding around the container
    }
    
     private var isInitialState: Bool { searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
     private var iconName: String { isInitialState ? "music.magnifyingglass" : "questionmark.circle" }
     private var title: String { isInitialState ? "Spotify Search" : "No Results" }
     private var message: String {
         if isInitialState {
             return "Enter an album or artist name above to begin your search."
         } else {
             // Use AttributedString for potential bolding if needed
             // let boldQuery = AttributedString(searchQuery, attributes: .init
             return "Could not find any albums matching \"\(searchQuery)\".\nTry refining your search terms."
         }
     }
}

#Preview("SpotifyAlbumListView") {
    SpotifyAlbumListView()
}

// MARK: - App Entry Point

@main
struct SpotifyNeumorphicApp: App {
    init() {
        // --- Critical Startup Check ---
        if spotifyBearerToken.isEmpty || spotifyBearerToken == "YOUR_SPOTIFY_BEARER_TOKEN_HERE" {
            print("🚨🎬 FATAL STARTUP WARNING: Spotify Bearer Token is not set!")
            print("👉 FIX: Replace the placeholder token in the `spotifyBearerToken` constant.")
            // In a real app, you'd likely prevent the UI from loading or show a login screen.
        }
        
        // --- Global UI Appearance (Optional, but useful for consistency) ---
        // Apply neumorphic background globally if possible (less reliable than ZStack)
        // UIView.appearance().backgroundColor = UIColor(NeumorphicTheme.darkBackground)
        // UITableView.appearance().backgroundColor = UIColor.clear // Make list backgrounds transparent

        // Customize Navigation Bar globally (more consistent)
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(NeumorphicTheme.darkBackground) // Use theme color
        appearance.titleTextAttributes = [.foregroundColor: UIColor(NeumorphicTheme.primaryText)]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor(NeumorphicTheme.primaryText)]

        // Set button colors (back button, etc.)
        let buttonAppearance = UIBarButtonItemAppearance()
        buttonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(NeumorphicTheme.goldAccent)]
        appearance.buttonAppearance = buttonAppearance
        appearance.doneButtonAppearance = buttonAppearance // For "Done" buttons

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance // Use same appearance when scrolled
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().tintColor = UIColor(NeumorphicTheme.goldAccent) // Back button arrow color
    }

    var body: some Scene {
        WindowGroup {
            SpotifyAlbumListView()
                .preferredColorScheme(.dark) // Enforce dark mode for the theme
        }
    }
}
