////
////  Psychedelic Theme.swift
////  MyApp
////
////  Created by Cong Le on 4/19/25.
//
//
////  SpotifyRetroApp.swift
////  MyApp
////  (Combined Single File Version with Psychedelic Theme)
////
////  Created by Cong Le based on Spotify API and Psychedelic Theme Concept
////
//
//import SwiftUI
//@preconcurrency import WebKit // Needed for WebView
//import Foundation
//
//// MARK: - Psychedelic Theme Constants & Modifiers
//
//let retroDeepPurple = Color(red: 0.15, green: 0.05, blue: 0.25) // Dark background
//let retroNeonPink = Color(red: 1.0, green: 0.1, blue: 0.5)
//let retroNeonCyan = Color(red: 0.1, green: 0.9, blue: 0.9)
//let retroNeonLime = Color(red: 0.7, green: 1.0, blue: 0.3)
//let retroGradients: [Color] = [
//    Color(red: 0.25, green: 0.12, blue: 0.4), // Deep purple
//    Color(red: 0.55, green: 0.19, blue: 0.66), // Mid purple/pink
//    Color(red: 0.95, green: 0.29, blue: 0.56), // Neon pinkish
//    Color(red: 0.18, green: 0.5, blue: 0.96)    // Neon blue
//]
//
//// Custom Font Helper (using built-in monospaced as fallback)
//// If you add a custom retro font to your project, update the name here.
//func retroFont(size: CGFloat, weight: Font.Weight = .regular) -> Font {
//    // Option 1: Use a specific built-in monospaced font
//     return Font.system(size: size, weight: weight, design: .monospaced)
//
//    // Option 2: Use a custom font (replace "YourRetroFontName" if added)
//    // return Font.custom("YourRetroFontName-Regular", size: size).weight(weight) // Adjust naming as needed
//
//    // Defaulting to system monospaced as a safe fallback
//    // return Font.system(size: size, design: .monospaced).weight(weight)
//}
//
//// Neon Glow Effect Modifier
//extension View {
//    func neonGlow(_ color: Color, radius: CGFloat = 8) -> some View {
//        self
//            .shadow(color: color.opacity(0.6), radius: radius / 2, x: 0, y: 0) // Inner sharp glow
//            .shadow(color: color.opacity(0.4), radius: radius, x: 0, y: 0)     // Mid soft glow
//            .shadow(color: color.opacity(0.2), radius: radius * 1.5, x: 0, y: 0) // Outer faint glow
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
//    let id: String
//    let album_type: String
//    let total_tracks: Int
//    let available_markets: [String]?
//    let external_urls: ExternalUrls
//    let href: String
//    let images: [SpotifyImage]
//    let name: String
//    let release_date: String
//    let release_date_precision: String
//    let type: String // "album"
//    let uri: String
//    let artists: [Artist]
//
//    // --- Helper computed properties ---
//    var bestImageURL: URL? {
//        images.first { $0.width == 640 }?.urlObject ??
//        images.first { $0.width == 300 }?.urlObject ??
//        images.first?.urlObject
//    }
//
//    var listImageURL: URL? {
//        images.first { $0.width == 300 }?.urlObject ??
//        images.first { $0.width == 64 }?.urlObject ??
//        images.first?.urlObject
//    }
//
//    var formattedArtists: String {
//        artists.map { $0.name }.joined(separator: ", ")
//    }
//
//    func formattedReleaseDate() -> String {
//        let dateFormatter = DateFormatter()
//        switch release_date_precision {
//        case "year":
//            dateFormatter.dateFormat = "yyyy"
//            if let date = dateFormatter.date(from: release_date) {
//                return dateFormatter.string(from: date)
//            }
//        case "month":
//            dateFormatter.dateFormat = "yyyy-MM"
//            if let date = dateFormatter.date(from: release_date) {
//                dateFormatter.dateFormat = "MMM yyyy" // e.g., Aug 1959
//                return dateFormatter.string(from: date)
//            }
//        case "day":
//            dateFormatter.dateFormat = "yyyy-MM-dd"
//            if let date = dateFormatter.date(from: release_date) {
//                // Use shortened month for a slightly more retro feel
//                dateFormatter.dateFormat = "d MMM yyyy" // e.g., 17 Aug 1959
//                return dateFormatter.string(from: date)
//            }
//        default: break
//        }
//        return release_date // Fallback
//    }
//}
//
//struct Artist: Codable, Identifiable, Hashable {
//    let id: String
//    let external_urls: ExternalUrls? // Made optional as it might be missing
//    let href: String
//    let name: String
//    let type: String // "artist"
//    let uri: String
//}
//
//struct SpotifyImage: Codable, Hashable {
//    let height: Int?
//    let url: String
//    let width: Int?
//    var urlObject: URL? { URL(string: url) }
//}
//
//struct ExternalUrls: Codable, Hashable {
//    let spotify: String? // Made optional as it might be missing
//}
//
//struct AlbumTracksResponse: Codable, Hashable {
//    let items: [Track]
//    // Add other fields like href, limit, next, offset, previous, total if needed
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
//    let type: String // "track"
//    let uri: String
//
//    var formattedDuration: String {
//        let totalSeconds = duration_ms / 1000
//        let minutes = totalSeconds / 60
//        let seconds = totalSeconds % 60
//        return String(format: "%d:%02d", minutes, seconds)
//    }
//    var formattedArtists: String {
//        artists.map { $0.name }.joined(separator: ", ")
//    }
//}
//
//// MARK: - Spotify Embed WebView & State
//
//final class SpotifyPlaybackState: ObservableObject {
//    @Published var isPlaying: Bool = false
//    @Published var currentPosition: Double = 0 // seconds
//    @Published var duration: Double = 0 // seconds
//    @Published var currentUri: String = ""
//}
//
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
//        configuration.allowsInlineMediaPlayback = true // Crucial for background apps
//        configuration.mediaTypesRequiringUserActionForPlayback = [] // Allow autoplay potentially
//
//        // --- WebView Creation ---
//        let webView = WKWebView(frame: .zero, configuration: configuration)
//        webView.navigationDelegate = context.coordinator
//        webView.uiDelegate = context.coordinator // Needed for JS alerts
//        webView.isOpaque = false // Transparent background
//        webView.backgroundColor = .clear
//        webView.scrollView.isScrollEnabled = false
//
//        // --- Load HTML ---
//        let html = generateHTML()
//        webView.loadHTMLString(html, baseURL: nil)
//
//        context.coordinator.webView = webView
//        return webView
//    }
//
//    func updateUIView(_ webView: WKWebView, context: Context) {
//        // Update the URI if it changes *after* the API is ready
//        if context.coordinator.isApiReady && context.coordinator.lastLoadedUri != spotifyUri {
//             context.coordinator.loadUri(spotifyUri ?? "")
//            // Update playback state's URI immediately on change attempt
//            DispatchQueue.main.async {
//                if playbackState.currentUri != spotifyUri {
//                    playbackState.currentUri = spotifyUri ?? ""
//                }
//            }
//        } else if !context.coordinator.isApiReady {
//            // If the view updates with a new URI *before* the API is ready,
//            // let the coordinator know the *latest* desired URI.
//            context.coordinator.updateDesiredUriBeforeReady(spotifyUri ?? "")
//        }
//    }
//
//    static func dismantleUIView(_ uiView: WKWebView, coordinator: Coordinator) {
//        print("Spotify Embed WebView: Dismantling.")
//        uiView.stopLoading()
//        // Cleanly remove the message handler
//        uiView.configuration.userContentController.removeScriptMessageHandler(forName: "spotifyController")
//        coordinator.webView = nil // Break potential retain cycle
//    }
//
//    // --- Coordinator Class (Handles JS communication) ---
//    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
//        var parent: SpotifyEmbedWebView
//        weak var webView: WKWebView?
//        var isApiReady = false
//        var lastLoadedUri: String?
//        private var desiredUriBeforeReady: String? = nil // Holds the URI if updateUIView is called before API is ready
//
//        init(_ parent: SpotifyEmbedWebView) {
//            self.parent = parent
//        }
//
//        // --- Method to update the desired URI before the API is ready ---
//        func updateDesiredUriBeforeReady(_ uri: String) {
//             if !isApiReady {
//                 desiredUriBeforeReady = uri
//             }
//         }
//
//
//        // --- WKNavigationDelegate Methods ---
//        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//            print("Spotify Embed WebView: HTML content finished loading.")
//            // JS should post "ready" message when its API is ready
//        }
//
//        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
//            print("❌ Spotify Embed WebView: Navigation failed: \(error.localizedDescription)")
//            // Optionally, notify the main view about the failure
//        }
//
//        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
//            print("❌ Spotify Embed WebView: Provisional navigation failed: \(error.localizedDescription)")
//            // Optionally, notify the main view about the failure
//        }
//
//        // --- WKUIDelegate Method (for JS alerts) ---
//        func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
//            print("ℹ️ Spotify Embed Received JS Alert: \(message)")
//            completionHandler() // Must call completion handler
//        }
//
//        // --- WKScriptMessageHandler Method ---
//        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
//             guard message.name == "spotifyController" else { return }
//
//            if let bodyDict = message.body as? [String: Any], let event = bodyDict["event"] as? String {
//                print("📦 Spotify Embed Native: JS Event Received - '\(event)', Data: \(bodyDict["data"] ?? "nil")") // More detailed log
//                 handleEvent(event: event, data: bodyDict["data"])
//             } else if let bodyString = message.body as? String {
//                 print("📦 Spotify Embed Native: JS String Message Received - '\(bodyString)'") // Log string messages too
//                 if bodyString == "ready" {
//                     handleApiReady()
//                 } else {
//                     print("❓ Spotify Embed Native: Received unknown string message: \(bodyString)")
//                 }
//             }
//            else
//            {
//                print("❓ Spotify Embed Native: Received message in unexpected format: \(message.body)")
//            }
//         }
//
//        // --- Helper Methods for JS Communication ---
//        private func handleApiReady() {
//            print("✅ Spotify Embed Native: Spotify IFrame API reported ready.")
//             isApiReady = true
//             // Use the most recently desired URI when creating the controller
//             if let initialUri = desiredUriBeforeReady ?? parent.spotifyUri {
//                 createSpotifyController(with: initialUri)
//                 desiredUriBeforeReady = nil // Clear it after use
//             } else {
//                 print("⚠️ Spotify Embed Native: API Ready but no initial URI provided.")
//                 // Optionally create controller without URI or wait for updateUIView
//             }
//        }
//
//        private func handleEvent(event: String, data: Any?) {
//            switch event {
//            case "controllerCreated":
//                print("✅ Spotify Embed Native: Embed controller successfully created by JS.")
//                // Now we are sure the controller exists in JS land.
//            case "playbackUpdate":
//                if let updateData = data as? [String: Any] {
//                    updatePlaybackState(with: updateData)
//                } else {
//                    print("⚠️ Spotify Embed Native: Received playbackUpdate with invalid data format.")
//                }
//            case "error":
//                let errorMessage = (data as? [String: Any])?["message"] as? String ?? (data as? String) ?? "Unknown JS error"
//                print("❌ Spotify Embed JS Error: \(errorMessage)")
//                // You might want to propagate this error to the UI
//            default:
//                print("❓ Spotify Embed Native: Received unknown event type: \(event)")
//            }
//        }
//
//        private func updatePlaybackState(with data: [String: Any]) {
//            // Update the observable object on the main thread
//             DispatchQueue.main.async { [weak self] in // Use weak self
//                 guard let self = self else { return } // Check if self is still valid
//
//                 if let isPaused = data["paused"] as? Bool {
//                     // Only update if the state actually changed
//                     if self.parent.playbackState.isPlaying == isPaused {
//                         self.parent.playbackState.isPlaying = !isPaused
//                     }
//                 }
//                 if let posMs = data["position"] as? Double {
//                     let newPosition = posMs / 1000.0 // Convert ms to seconds
//                     // Only update if significantly different to avoid rapid UI updates
//                     if abs(self.parent.playbackState.currentPosition - newPosition) > 0.1 {
//                         self.parent.playbackState.currentPosition = newPosition
//                     }
//                 }
//                 if let durMs = data["duration"] as? Double {
//                     let newDuration = durMs / 1000.0
//                     // Update if different or initial value
//                     if abs(self.parent.playbackState.duration - newDuration) > 0.1 || self.parent.playbackState.duration == 0 {
//                         self.parent.playbackState.duration = newDuration
//                     }
//                 }
//                  if let uri = data["uri"] as? String, self.parent.playbackState.currentUri != uri {
//                     self.parent.playbackState.currentUri = uri
//                 }
//            }
//        }
//
//        // Execute JS to create the controller
//        func createSpotifyController(with initialUri: String) {
//            guard let webView = webView else { print("❌ Error: WebView not available for controller creation."); return }
//            guard isApiReady else { print("⚠️ Warning: API not ready, delaying controller creation."); return }
//            guard lastLoadedUri == nil else { // Ensure we initialize only once unless forced
//                 // If the desired URI changed before ready, load it now instead of the potentially stale one
//                 if let latestDesired = desiredUriBeforeReady ?? parent.spotifyUri,
//                    latestDesired != lastLoadedUri {
//                     print("🔄 Spotify Embed Native: API ready, loading changed URI: \(latestDesired)")
//                     loadUri(latestDesired)
//                     desiredUriBeforeReady = nil // Consume the desired URI
//                 } else {
//                     print("ℹ️ Spotify Embed Native: Controller already initialized or attempt pending. Initial URI: \(initialUri), Last Loaded: \(lastLoadedUri ?? "nil")")
//                 }
//                return
//             }
//
//             print("🚀 Spotify Embed Native: Attempting to create controller for URI: \(initialUri)")
//             lastLoadedUri = initialUri // Mark as attempting BEFORE evaluating JS
//
//            let script = """
//            console.log('Spotify Embed JS: Initial script block running.');
//            window.embedController = null; // Ensure clean state
//            const element = document.getElementById('embed-iframe');
//            if (!element) {
//                console.error('Spotify Embed JS: Could not find element embed-iframe!');
//                window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'HTML element embed-iframe not found' }});
//            } else if (!window.IFrameAPI) {
//                console.error('Spotify Embed JS: IFrameAPI is not loaded!');
//                window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'Spotify IFrame API not loaded' }});
//            }
//            else {
//                console.log('Spotify Embed JS: Found element and IFrameAPI. Creating controller for URI: \(initialUri)');
//                const options = {
//                    uri: '\(initialUri)',
//                    width: '100%', // Use 100% for responsiveness
//                    height: '80'   // Standard height
//                };
//                const callback = (controller) => {
//                     // Important: Check if a controller was actually returned
//                    if (!controller) {
//                        console.error('Spotify Embed JS: createController callback received null controller!');
//                        window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'JS createController callback received null controller' }});
//                        return; // Do not proceed
//                    }
//                    console.log('✅ Spotify Embed JS: Controller instance received.');
//                    window.embedController = controller; // Store globally in JS for access
//
//                    // Notify native side that controller is created
//                    window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'controllerCreated' });
//
//                    // --- Add Listeners ---
//                    controller.addListener('ready', () => {
//                        console.log('Spotify Embed JS: Controller Ready event.');
//                        // We could try playing here if needed, e.g., controller.play();
//                    });
//                    controller.addListener('playback_update', e => {
//                        // Send the entire event data object
//                        window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'playbackUpdate', data: e.data });
//                    });
//                     // Error Listeners
//                    controller.addListener('account_error', e => {
//                        console.warn('Spotify Embed JS: Account Error:', e.data);
//                        window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'Account Error: ' + (e.data?.message ?? 'Premium required or login issue?') }});
//                    });
//                    controller.addListener('autoplay_failed', () => {
//                        console.warn('Spotify Embed JS: Autoplay failed');
//                        window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'Autoplay failed' }});
//                         // Maybe try a delayed play or notify user?
//                         // controller.play(); // Might be too aggressive
//                    });
//                     controller.addListener('initialization_error', e => {
//                        console.error('Spotify Embed JS: Initialization Error:', e.data);
//                        window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'Initialization Error: ' + (e.data?.message ?? 'Failed to initialize player') }});
//                    });
//                     // --- End Listeners ---
//                };
//
//                // --- Call createController ---
//                try {
//                    console.log('Spotify Embed JS: Calling IFrameAPI.createController...');
//                    window.IFrameAPI.createController(element, options, callback);
//                 } catch (e) {
//                    console.error('Spotify Embed JS: Error calling createController:', e);
//                    window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'JS exception during createController: ' + e.message }});
//                    // Consider resetting lastLoadedUri here if the call throws, allowing retry?
//                    // self.lastLoadedUri = nil // Be careful with concurrent access if UI changes URI
//                }
//            }
//            """
//            webView.evaluateJavaScript(script) { result, error in
//                if let error = error {
//                     print("⚠️ Spotify Embed Native: Error evaluating JS controller creation script: \(error.localizedDescription)")
//                     // JS evaluation failed, controller likely wasn't created. Reset state?
//                      // self.lastLoadedUri = nil // Allow retry? Needs careful consideration.
//                 } else {
//                     // JS executed, rely on JS-native message for creation success/failure.
//                     print("ℹ️ Spotify Embed Native: JS controller creation script evaluated (result: \(result ?? "nil")). Waiting for JS callback.")
//                 }
//            }
//        }
//
//        // Execute JS to load a new URI
//        func loadUri(_ uri: String) {
//            guard let webView = webView else { print("❌ Error: WebView not available for loadUri."); return }
//            guard isApiReady else { print("⚠️ Warning: API not ready, not loading URI \(uri)."); return }
//            guard lastLoadedUri != nil else { print("⚠️ Warning: Controller not initialized, cannot load URI \(uri)."); return } // Controller must exist
//             guard lastLoadedUri != uri else { print("ℹ️ Info: URI \(uri) is already the last loaded one."); return } // Avoid redundant loads
//
//            print("🚀 Spotify Embed Native: Attempting to load new URI: \(uri)")
//            lastLoadedUri = uri // Update last loaded URI *before* evaluating JS
//
//            let script = """
//            if (window.embedController) {
//                console.log('Spotify Embed JS: Loading URI: \(uri)');
//                window.embedController.loadUri('\(uri)');
//                window.embedController.play(); // Attempt to play immediately after load
//            } else {
//                console.error('Spotify Embed JS: embedController not found for loadUri \(uri).');
//                window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'JS embedController not found during loadUri' }});
//            }
//            """
//            webView.evaluateJavaScript(script) { _, error in
//                 if let error = error {
//                     print("⚠️ Spotify Embed Native: Error evaluating JS load URI script for \(uri): \(error.localizedDescription)")
//                 }
//            }
//        }
//    }
//
//    // --- Generate HTML string ---
//    private func generateHTML() -> String {
//        """
//        <!DOCTYPE html>
//        <html>
//        <head>
//            <meta charset="utf-8">
//            <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
//            <title>Spotify Embed</title>
//            <style>
//                html, body { margin: 0; padding: 0; width: 100%; height: 100%; overflow: hidden; background-color: transparent; }
//                #embed-iframe { width: 100%; height: 100%; box-sizing: border-box; display: block; border: none; }
//            </style>
//        </head>
//        <body>
//            <div id="embed-iframe"></div>
//            <script src="https://open.spotify.com/embed/iframe-api/v1" async></script>
//            <script>
//                console.log('Spotify Embed JS: Initial script running.');
//                window.onSpotifyIframeApiReady = (IFrameAPI) => {
//                    console.log('✅ Spotify Embed JS: API Ready.');
//                    // Store the API object globally within the JS context
//                    window.IFrameAPI = IFrameAPI;
//                    // Notify the native app that the API is ready
//                    if (window.webkit?.messageHandlers?.spotifyController) {
//                         window.webkit.messageHandlers.spotifyController.postMessage("ready");
//                    } else {
//                         console.error('❌ Spotify Embed JS: Native message handler (spotifyController) not found!');
//                    }
//                };
//                 // Add error handling specifically for the API script load itself
//                 const scriptTag = document.querySelector('script[src*="iframe-api"]');
//                 if (scriptTag) {
//                     scriptTag.onerror = (event) => {
//                         console.error('❌ Spotify Embed JS: Failed to load iframe-api script:', event);
//                         window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'Failed to load Spotify API script' }});
//                     };
//                 } else {
//                     console.warn('⚠️ Spotify Embed JS: Could not find the iframe-api script tag.');
//                 }
//            </script>
//        </body>
//        </html>
//        """
//    }
//}
//
//// MARK: - API Service (Requires Valid Token)
//
//// IMPORTANT: Replace this placeholder with YOUR actual Spotify Bearer Token.
//// Get one from: https://developer.spotify.com/documentation/web-api/concepts/access-token
//// For testing, you can manually generate one from the Spotify Web API Console.
//// In a real app, implement a proper OAuth 2.0 flow.
//let placeholderSpotifyToken = "YOUR_SPOTIFY_BEARER_TOKEN_HERE"
//
//enum SpotifyAPIError: Error, LocalizedError {
//    case invalidURL
//    case networkError(Error)
//    case invalidResponse(Int, String?) // Include status code and optional body
//    case decodingError(Error)
//    case invalidToken // Specific error for 401
//    case missingData
//
//    var errorDescription: String? {
//        switch self {
//        case .invalidURL: return "Invalid API URL constructed."
//        case .networkError(let error): return "Network connection failed: \(error.localizedDescription)"
//        case .invalidResponse(let code, _): return "Server returned an error (Status \(code))."
//        case .decodingError(let error): return "Failed to parse server response: \(error.localizedDescription)"
//        case .invalidToken: return "Invalid or expired Spotify API token."
//        case .missingData: return "Expected data was missing in the API response."
//        }
//    }
//}
//
//struct SpotifyAPIService {
//    static let shared = SpotifyAPIService()
//    private let session: URLSession
//
//    private init() { // Make init private for singleton
//        let configuration = URLSessionConfiguration.default
//        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData // Avoid stale cache during testing
//        session = URLSession(configuration: configuration)
//    }
//
//    private func makeRequest<T: Decodable>(url: URL) async throws -> T {
//        // --- Token Check ---
//        guard !placeholderSpotifyToken.isEmpty && placeholderSpotifyToken != "YOUR_SPOTIFY_BEARER_TOKEN_HERE" else {
//            print("❌ FATAL ERROR: Spotify Bearer Token is missing or placeholder.")
//            // Post a notification or use other mechanism to alert the UI if needed
//            throw SpotifyAPIError.invalidToken
//        }
//
//        // --- Request Setup ---
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//        request.setValue("Bearer \(placeholderSpotifyToken)", forHTTPHeaderField: "Authorization")
//        request.setValue("application/json", forHTTPHeaderField: "Accept")
//        request.timeoutInterval = 20 // 20-second timeout
//
//        print("🚀 Making API Request to: \(url.absoluteString)")
//
//        // --- Network Call ---
//        do {
//            let (data, response) = try await session.data(for: request)
//
//            guard let httpResponse = response as? HTTPURLResponse else {
//                throw SpotifyAPIError.invalidResponse(0, "Response was not HTTP.")
//            }
//
//            print("🚦 HTTP Status: \(httpResponse.statusCode)")
//            let responseBodyForDebug = String(data: data, encoding: .utf8) ?? "N/A"
//
//            // --- Response Handling ---
//            guard (200...299).contains(httpResponse.statusCode) else {
//                if httpResponse.statusCode == 401 {
//                    print("❌ Authorization Error (401). Token is likely invalid or expired.")
//                    throw SpotifyAPIError.invalidToken // Throw specific token error
//                }
//                // Add handling for other common errors like 404, 429 (Rate Limiting) if needed
//                print("❌ Server Error (\(httpResponse.statusCode)). Body: \(responseBodyForDebug)")
//                throw SpotifyAPIError.invalidResponse(httpResponse.statusCode, responseBodyForDebug)
//            }
//
//            // --- Decoding ---
//            do {
//                let decoder = JSONDecoder()
//                return try decoder.decode(T.self, from: data)
//            } catch let decodingError {
//                print("❌ Decoding Error for \(T.self): \(decodingError)")
//                print("📄 Response Body causing error: \(responseBodyForDebug)")
//                throw SpotifyAPIError.decodingError(decodingError)
//            }
//        } catch let error where error is CancellationError {
//            print("🔶 Network request cancelled.")
//            throw error // Re-throw cancellation errors
//        } catch let error as SpotifyAPIError {
//            // Re-throw known API errors
//            throw error
//        } catch {
//            // Catch other network errors (connectivity, timeout, etc.)
//            print("❌ Unknown Network Error: \(error)")
//            throw SpotifyAPIError.networkError(error)
//        }
//    }
//
//    // --- Public API Methods ---
//    func searchAlbums(query: String, limit: Int = 20, offset: Int = 0) async throws -> SpotifySearchResponse {
//        var components = URLComponents(string: "https://api.spotify.com/v1/search")
//        components?.queryItems = [
//            URLQueryItem(name: "q", value: query),
//            URLQueryItem(name: "type", value: "album"),
//            URLQueryItem(name: "include_external", value: "audio"), // Include playable links if available
//            URLQueryItem(name: "limit", value: "\(limit)"),
//            URLQueryItem(name: "offset", value: "\(offset)")
//        ]
//        guard let url = components?.url else { throw SpotifyAPIError.invalidURL }
//        return try await makeRequest(url: url)
//    }
//
//    func getAlbumTracks(albumId: String, limit: Int = 50, offset: Int = 0) async throws -> AlbumTracksResponse {
//        // Adjust limit if needed (Spotify max is usually 50 for tracks)
//        let effectiveLimit = min(limit, 50)
//        var components = URLComponents(string: "https://api.spotify.com/v1/albums/\(albumId)/tracks")
//        components?.queryItems = [
//            URLQueryItem(name: "limit", value: "\(effectiveLimit)"),
//            URLQueryItem(name: "offset", value: "\(offset)")
//        ]
//        guard let url = components?.url else { throw SpotifyAPIError.invalidURL }
//        return try await makeRequest(url: url)
//    }
//}
//
//// MARK: - SwiftUI Views
//
//// MARK: -- Main List View (Themed)
//struct SpotifyAlbumListView: View {
//    @State private var searchQuery: String = "Miles Davis Steamin'" // Default search for preview
//    @State private var displayedAlbums: [AlbumItem] = []
//    @State private var isLoading: Bool = false
//    @State private var searchInfo: Albums? = nil
//    @State private var currentError: SpotifyAPIError? = nil
//    @State private var debounceTask: Task<Void, Never>? = nil
//
//    var body: some View {
//        NavigationView {
//            ZStack {
//                // --- Retro Background ---
//                LinearGradient(
//                    gradient: Gradient(colors: [retroDeepPurple, Color.black]), // Dark gradient
//                    startPoint: .top, endPoint: .bottom
//                )
//                .ignoresSafeArea()
//                // Optional: Add a subtle grid overlay
//                 Image("retro_grid_background").resizable().scaledToFill().opacity(0.08).ignoresSafeArea()
//
//
//                // --- Main Content Area ---
//                VStack(spacing: 0) { // Remove spacing for seamless list
//                    // --- Themed List ---
//                    albumListOrPlaceholder
//                }
//
//
//                // --- Ongoing Loading Overlay (Bottom Right) ---
//                if isLoading && !displayedAlbums.isEmpty {
//                    VStack {
//                        Spacer() // Push to bottom
//                        HStack {
//                            Spacer() // Push to right
//                            ProgressView()
//                                .progressViewStyle(CircularProgressViewStyle(tint: retroNeonLime))
//                                .padding(.trailing, 5)
//                            Text("SYNCING...") // Retro term
//                                .font(retroFont(size: 10, weight: .bold))
//                                .foregroundColor(retroNeonLime)
//                                .tracking(1)
//                        }
//                        .padding(.vertical, 5)
//                        .padding(.horizontal, 12)
//                        .background(Color.black.opacity(0.7), in: Capsule())
//                        .overlay(Capsule().stroke(retroNeonLime.opacity(0.4), lineWidth: 1))
//                        .neonGlow(retroNeonLime, radius: 5) // Subtle glow
//                        .padding(.trailing) // Padding from edge
//                        .padding(.bottom, 8) // Padding from bottom bar / safe area
//                    }
//                    .transition(.opacity.animation(.easeInOut))
//                }
//
//            } // End ZStack
//            .navigationTitle("RETRO WAVE MUSIC")
//            .navigationBarTitleDisplayMode(.inline)
//            // --- Themed Navigation Bar ---
//            .toolbarBackground(retroDeepPurple.opacity(0.85), for: .navigationBar) // Slighly more opaque
//            .toolbarBackground(.visible, for: .navigationBar)
//            .toolbarColorScheme(.dark, for: .navigationBar) // Ensure white title/buttons
//
//            // --- Search Bar ---
//            .searchable(text: $searchQuery,
//                        placement: .navigationBarDrawer(displayMode: .always),
//                        prompt: Text("Search Albums / Artists").foregroundColor(.gray))
//            .onSubmit(of: .search) { startSearch(immediate: true) }
//            .onChange(of: searchQuery) { startSearch() } // Trigger debounced search on change
//            .onAppear { startSearch(immediate: true) } // Initial search on appear with default query
//            .accentColor(retroNeonPink) // Tint cursor/cancel button
//
//        } // End NavigationView
//        .accentColor(retroNeonPink) // Apply accent to the whole hierarchy
//    }
//
//    // --- Conditionally Display List or Placeholder ---
//    @ViewBuilder
//    private var albumListOrPlaceholder: some View {
//        // Group applying transitions to swap between states
//        Group {
//            if isLoading && displayedAlbums.isEmpty {
//                themedProgressView
//            } else if let error = currentError {
//                ErrorPlaceholderView(error: error) {
//                    startSearch(immediate: true) // Retry action
//                }
//            } else if displayedAlbums.isEmpty && !searchQuery.isEmpty {
//                // Only show "No Results" if a search was actually performed
//                EmptyStatePlaceholderView(searchQuery: searchQuery)
//            } else if displayedAlbums.isEmpty && searchQuery.isEmpty {
//                 // Initial empty state before any search
//                 EmptyStatePlaceholderView(searchQuery: "")
//            } else {
//                albumList // Themed list content
//            }
//        }
//        .transition(.opacity.animation(.easeInOut(duration: 0.3)))
//        .frame(maxWidth: .infinity, maxHeight: .infinity) // Ensure placeholders fill space
//    }
//
//
//    // --- Themed Progress View (for initial load) ---
//        private var themedProgressView: some View {
//           VStack {
//               ProgressView()
//                   .progressViewStyle(CircularProgressViewStyle(tint: retroNeonCyan))
//                   .scaleEffect(1.8) // Slightly larger
//               Text("LOADING DATA...")
//                   .font(retroFont(size: 12, weight: .bold))
//                   .foregroundColor(retroNeonCyan)
//                   .padding(.top, 15)
//                    .tracking(1.5)
//            }
//        }
//
//
//    // --- Themed Album List ---
//    private var albumList: some View {
//        List {
//            // Optional: Header for Search Metadata
//            if let info = searchInfo, info.total > 0 {
//                SearchMetadataHeader(totalResults: info.total, limit: info.limit, offset: info.offset)
//                    .listRowSeparator(.hidden)
//                    .listRowInsets(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0)) // Adjust spacing
//                    .listRowBackground(Color.clear)
//            }
//
//            // Album Cards
//            ForEach(displayedAlbums) { album in
//                // Use ZStack for more control over background/tap area
//                ZStack {
//                    // Navigation link logic (invisible)
//                    NavigationLink(destination: AlbumDetailView(album: album)) {
//                         EmptyView() // Content is provided by RetroAlbumCard
//                     }
//                    .opacity(0) // Make the link itself invisible
//
//                    // Visible Card Content
//                    RetroAlbumCard(album: album)
//                         .padding(.vertical, 6) // Reduced vertical padding
//                }
//                .listRowSeparator(.hidden)
//                .listRowInsets(EdgeInsets()) // Full width tap
//                .listRowBackground(Color.clear)
//            }
//        }
//        .listStyle(PlainListStyle())
//        .background(Color.clear)
//        .scrollContentBackground(.hidden) // Crucial for background visibility
//    }
//
//    // --- Debounced Search Logic ---
//    private func startSearch(immediate: Bool = false) {
//        debounceTask?.cancel() // Cancel any existing debounce task
//
//        let currentQuery = searchQuery // Capture current query
//
//        debounceTask = Task {
//            // Debounce Delay (unless immediate)
//            if !immediate {
//                do {
//                    try await Task.sleep(for: .milliseconds(600)) // Adjust delay as needed
//                    try Task.checkCancellation()
//                } catch {
//                    print("Search task cancelled (debounce)."); return
//                }
//            }
//
//            // Proceed with search if task wasn't cancelled
//            await performSearch(query: currentQuery)
//        }
//    }
//
//    private func performSearch(query: String) async {
//        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
//
//        // Don't search if query is empty after trimming (unless it was initially empty)
//        guard !trimmedQuery.isEmpty || query.isEmpty else {
//             await MainActor.run { // Update UI on main thread
//                 displayedAlbums = []
//                 searchInfo = nil
//                 isLoading = false
//                 currentError = nil
//            }
//             return
//         }
//
//        // If the query IS empty (initial state), just reset
//          if trimmedQuery.isEmpty {
//             await MainActor.run {
//                 displayedAlbums = []
//                 searchInfo = nil
//                 isLoading = false
//                 currentError = nil
//             }
//             return
//        }
//
//
//        await MainActor.run { isLoading = true; currentError = nil } // Set loading state
//
//        do {
//            print("Performing search for: \(trimmedQuery)")
//            let response = try await SpotifyAPIService.shared.searchAlbums(query: trimmedQuery, offset: 0)
//            try Task.checkCancellation() // Check if task was cancelled during API call
//            await MainActor.run {
//                displayedAlbums = response.albums.items
//                searchInfo = response.albums
//                isLoading = false
//                 print("Search completed. Found \(response.albums.total) albums.")
//            }
//        } catch is CancellationError {
//            print("Search task cancelled during/after API call.")
//            // Don't reset isLoading here if a new search is likely starting
//        } catch let apiError as SpotifyAPIError {
//            print("❌ API Error: \(apiError.localizedDescription)")
//             await MainActor.run { displayedAlbums = []; searchInfo = nil; currentError = apiError; isLoading = false }
//        } catch {
//            print("❌ Unexpected Error: \(error.localizedDescription)")
//             await MainActor.run { displayedAlbums = []; searchInfo = nil; currentError = .networkError(error); isLoading = false }
//        }
//    }
//}
//
//// MARK: -- Retro Album Card (Themed List Item)
//struct RetroAlbumCard: View {
//    let album: AlbumItem
//
//    var body: some View {
//        ZStack {
//            // --- Background with Gradient & Material ---
//            LinearGradient( // Use a diagonal gradient
//                gradient: Gradient(colors: [retroDeepPurple.opacity(0.8), retroNeonPink.opacity(0.3), retroDeepPurple.opacity(0.9)]),
//                startPoint: .topLeading,
//                endPoint: .bottomTrailing
//            )
//            .overlay(.black.opacity(0.2)) // Darken slightly
//            .blur(radius: 2) // Subtle blur for depth
//             // Frosted glass effect
//            .overlay(.ultraThinMaterial.opacity(0.6))
//            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous)) // Slightly rounder
//
//            // --- Neon Outline ---
//            .overlay(
//                RoundedRectangle(cornerRadius: 18, style: .continuous)
//                   .stroke(LinearGradient(colors: [retroNeonCyan.opacity(0.7), retroNeonPink.opacity(0.7)], startPoint: .leading, endPoint: .trailing), lineWidth: 1.5) // Gradient stroke
//            )
//            .neonGlow(retroNeonCyan, radius: 8) // Consistent cyan glow for cards
//            .padding(.horizontal, 10) // Padding around the card itself
//
//            // --- Content ---
//            HStack(spacing: 12) { // Reduced spacing
//                // Album Art
//                AlbumImageView(url: album.listImageURL)
//                    .frame(width: 90, height: 90) // Slightly smaller
//                    .clipShape(RoundedRectangle(cornerRadius: 10)) // Less rounded corners for image
//                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white.opacity(0.1), lineWidth: 1)) // Faint edge
//                    .shadow(color: .black.opacity(0.6), radius: 5, y: 3)
//
//                // Text Details
//                VStack(alignment: .leading, spacing: 4) { // Reduced spacing
//                    Text(album.name)
//                        .font(retroFont(size: 15, weight: .bold)) // Slightly smaller bold
//                        .foregroundColor(.white)
//                        .lineLimit(2)
//
//                    Text(album.formattedArtists)
//                        .font(retroFont(size: 13)) // Normal weight, slightly smaller
//                        .foregroundColor(retroNeonLime.opacity(0.9))
//                        .lineLimit(1)
//
//                    Spacer() // Push bottom info down
//
//                    // Type & Date Row
//                    HStack(spacing: 6) { // Reduced spacing
//                        Label {
//                            Text(album.album_type.capitalized)
//                        } icon: {
//                            Image(systemName: iconForAlbumType(album.album_type))
//                                .font(.system(size: 9)) // Smaller icon
//                        }
//                        .font(retroFont(size: 10, weight: .medium))
//                        .foregroundColor(.white.opacity(0.8))
//                        .padding(.horizontal, 6)
//                        .padding(.vertical, 2)
//                        .background(Color.white.opacity(0.1), in: Capsule())
//
//                        Text("•").foregroundColor(.white.opacity(0.4))
//
//                        Text(album.formattedReleaseDate())
//                              .font(retroFont(size: 10, weight: .medium))
//                            .foregroundColor(.white.opacity(0.8))
//                    }
//
//                    // Track Count
//                    Text("\(album.total_tracks) Tracks")
//                        .font(retroFont(size: 10, weight: .medium))
//                        .foregroundColor(.white.opacity(0.7))
//                        .padding(.top, 1)
//
//                } // End Text VStack
//                .frame(maxWidth: .infinity, alignment: .leading) // Allow text to take space
//
//            } // End HStack
//            .padding(EdgeInsets(top: 12, leading: 15, bottom: 12, trailing: 15)) // Adjusted padding
//
//
//        } // End ZStack
//         .frame(height: 120) // Adjusted fixed height
//    }
//
//    // Helper for icon based on album type
//    private func iconForAlbumType(_ type: String) -> String {
//        switch type.lowercased() {
//        case "album": return "play.rectangle.on.rectangle.fill"
//        case "single": return "play.rectangle.fill"
//        case "compilation": return "rectangle.stack.fill.badge.person.crop"
//        default: return "questionmark.diamond.fill"
//        }
//    }
//}
//
//// MARK: -- Themed Placeholders
//struct ErrorPlaceholderView: View {
//    let error: SpotifyAPIError
//    let retryAction: (() -> Void)?
//
//    var body: some View {
//        VStack(spacing: 18) { // Slightly reduced spacing
//            Image(systemName: iconName)
//                .font(.system(size: 55)) // Slightly smaller icon
//                .foregroundColor(retroNeonPink)
//                .neonGlow(retroNeonPink, radius: 12)
//                .padding(.bottom, 10)
//
//            Text("SYSTEM ERROR") // More retro term
//                .font(retroFont(size: 22, weight: .heavy)) // Slightly smaller
//                .foregroundColor(.white)
//                .tracking(3) // Keep tracking
//
//            Text(errorMessage)
//                .font(retroFont(size: 14))
//                .foregroundColor(.white.opacity(0.8))
//                .multilineTextAlignment(.center)
//                .padding(.horizontal, 30)
//                .lineSpacing(4) // Add line spacing for readability
//
//            // Use the styled RetroButton for retrying
////            if error != .invalidToken, let retryAction = retryAction {
////                 Spacer().frame(height: 10) // Add space before button
////                 RetroButton(text: "RETRY", action: retryAction, primaryColor: retroNeonLime, secondaryColor: .teal)
////                     .padding(.horizontal, 40) // Make button slightly narrower
////            } else if error == .invalidToken {
//                Text("Token Expired/Invalid.\nCheck `SpotifyAPIService.swift`")
//                     .font(retroFont(size: 12))
//                     .foregroundColor(retroNeonPink.opacity(0.8))
//                     .multilineTextAlignment(.center)
//                     .padding(.horizontal, 30)
//                     .padding(.top, 10)
////            }
//        }
//        .padding(EdgeInsets(top: 30, leading: 20, bottom: 30, trailing: 20))
//        // Themed background for the placeholder itself
//        .background(
//             LinearGradient(colors: [retroDeepPurple.opacity(0.9), .black.opacity(0.7)], startPoint: .top, endPoint: .bottom)
//                .overlay(.ultraThinMaterial.opacity(0.5)) // More subtle material
//                 .clipShape(RoundedRectangle(cornerRadius: 25)) // Rounder corners
//                 .overlay(RoundedRectangle(cornerRadius: 25).stroke(retroNeonPink.opacity(0.4), lineWidth: 1.5))
//                 .shadow(color: .black, radius: 15, y: 5) // More prominent shadow
//        )
//        .padding(25) // Padding around the whole placeholder container
//    }
//
//    // Icon and Message Logic (slightly refined)
//    private var iconName: String {
//        switch error {
//        case .invalidToken: return "lock.shield.fill" // More security focused
//        case .networkError: return "wifi.exclamationmark"
//        case .invalidResponse: return "server.rack" // Represents server issue
//        case .decodingError, .missingData: return "doc.text.magnifyingglass" // Data related issue
//        case .invalidURL: return "link.badge.plus" // URL construction issue
//        }
//    }
//    private var errorMessage: String {
//        switch error {
//        case .invalidToken: return "ACCESS DENIED. TOKEN INVALID."
//        case .networkError: return "NETWORK OFFLINE. CHECK CONNECTION."
//        case .invalidResponse(let code, _): return "SERVER RESPONSE ERROR [\(code)]. PLEASE TRY AGAIN LATER."
//        case .decodingError: return "DATA ERROR. UNABLE TO READ RESPONSE."
//        case .missingData: return "INCOMPLETE DATA RECEIVED."
//        case .invalidURL: return "INTERNAL ERROR. INVALID REQUEST URL."
//        }
//    }
//}
//
//struct EmptyStatePlaceholderView: View {
//    let searchQuery: String
//
//    var body: some View {
//        VStack(spacing: 20) {
//            // Retro Image (e.g., cassette tape, synthesizer icon)
//            // Replace "retro_icon_placeholder" with your actual image asset name
//            Image(iconName) // Assuming you have these assets
//                .resizable()
//                .renderingMode(.template) // Allow tinting
//                .foregroundColor(isInitialState ? retroNeonCyan : retroNeonPink)
//                .aspectRatio(contentMode: .fit)
//                .frame(height: 120) // Adjust size
//                 .neonGlow(isInitialState ? retroNeonCyan : retroNeonPink, radius: 15)
//                .padding(.bottom, 10)
//
//            Text(title)
//                .font(retroFont(size: 22, weight: .bold))
//                .foregroundColor(.white)
//                .tracking(2) // Add tracking
//
//            Text(messageAttributedString)
//                 .font(retroFont(size: 14))
//                .foregroundColor(.white.opacity(0.8))
//                .multilineTextAlignment(.center)
//                .padding(.horizontal, 30)
//                 .lineSpacing(4) // Improve readability
//        }
//        .padding(30)
//        // No extra background needed, relies on parent ZStack background
//    }
//
//    private var isInitialState: Bool { searchQuery.isEmpty }
//    private var iconName: String { isInitialState ? "My-meme-microphone" : "My-meme-orange_2" } // Use your asset names
//    private var title: String { isInitialState ? "READY TO SCAN" : "NO SIGNAL" } // Themed titles
//    private var messageAttributedString: AttributedString {
//        var message: AttributedString
//        if isInitialState {
//             message = AttributedString("Use the search above to find albums\nand tune into the retro wave.")
//        } else {
//            do {
//                // Create markdown string safely
//                let query = searchQuery.isEmpty ? "that frequency" : searchQuery // Handle edge case
//                message = try AttributedString(markdown: "No signal detected for **\(query)**.\nAdjust your search parameters.")
//            } catch {
//                // Fallback to plain string if markdown fails
//                message = AttributedString("No signal detected for \"\(searchQuery)\". Adjust your search parameters.")
//            }
//        }
//        // Apply consistent styling
//         message.font = retroFont(size: 14)
//        message.foregroundColor = .white.opacity(0.8)
//        // Find and style the bold part (requires range finding if not using markdown)
//        if let range = message.range(of: searchQuery), !searchQuery.isEmpty {
//            message[range].font = retroFont(size: 14, weight: .bold)
//            message[range].foregroundColor = retroNeonLime // Highlight query
//        }
//        return message
//    }
//}
//
//// MARK: -- Album Detail View (Themed)
//struct AlbumDetailView: View {
//    let album: AlbumItem
//    @State private var tracks: [Track] = []
//    @State private var isLoadingTracks: Bool = false
//    @State private var trackFetchError: SpotifyAPIError? = nil
//    @State private var selectedTrackUri: String? = nil
//    @StateObject private var playbackState = SpotifyPlaybackState() // State for the player
//    @Environment(\.openURL) var openURL // For external link
//
//    var body: some View {
//        ZStack {
//            // --- Themed Background ---
//            LinearGradient(
//                gradient: Gradient(colors: [retroDeepPurple, Color.black]),
//                startPoint: .top, endPoint: .bottom
//            ).ignoresSafeArea()
//              Image("retro_grid_background").resizable().scaledToFill().opacity(0.1).ignoresSafeArea().blur(radius: 2)
//
//
//            // --- Main Scrolling Content ---
//            List {
//                // --- Header Section ---
//                 Section { AlbumHeaderView(album: album) }
//                      .listRowInsets(EdgeInsets())
//                     .listRowSeparator(.hidden)
//                     .listRowBackground(Color.clear)
//
//                 // --- Player Section (Appears when track selected) ---
//                 if let uriToPlay = selectedTrackUri {
//                     Section { SpotifyEmbedPlayerView(playbackState: playbackState, spotifyUri: uriToPlay) }
//                          .listRowSeparator(.hidden)
//                         .listRowInsets(EdgeInsets(top: 15, leading: 0, bottom: 15, trailing: 0))
//                         .listRowBackground(Color.clear)
//                         .id("playerSection") // Add ID for potential ScrollViewReader
//                         .transition(.opacity.combined(with: .scale(scale: 0.95, anchor: .top)).animation(.easeInOut(duration: 0.4)))
//                 }
//
//                 // --- Tracks Section ---
//                 Section {
//                     TracksSectionView(
//                         tracks: tracks,
//                         isLoading: isLoadingTracks,
//                         error: trackFetchError,
//                         selectedTrackUri: $selectedTrackUri, // Pass binding
//                         retryAction: { Task { await fetchTracks() } } // Retry fetch
//                     )
//                 } header: {
//                     // --- Themed Tracks Header ---
//                     Text("TRACK LISTING")
//                         .font(retroFont(size: 13, weight: .bold))
//                         .foregroundColor(retroNeonLime)
//                         .tracking(2.5) // Wider tracking
//                         .frame(maxWidth: .infinity, alignment: .center)
//                         .padding(.vertical, 10)
//                         .background(Color.black.opacity(0.4)) // Subtle dark bg
//                          // Add underline effect
//                          .overlay(alignment: .bottom) {
//                             Rectangle().frame(height: 1).foregroundColor(retroNeonLime.opacity(0.5))
//                                 .offset(y: -2) // Position underline slightly above bottom edge
//                         }
//                 }
//                  .listRowInsets(EdgeInsets()) // Remove padding around tracks section
//                 .listRowSeparator(.hidden)
//                 .listRowBackground(Color.clear)
//
//                 // --- External Link Section ---
//                if let spotifyURL = URL(string: album.external_urls.spotify ?? "") {
//                     Section {
//                         ExternalLinkButton(url: spotifyURL, primaryColor: retroNeonLime, secondaryColor: .green)
//                     }
//                     .listRowInsets(EdgeInsets(top: 25, leading: 20, bottom: 30, trailing: 20)) // More padding
//                     .listRowSeparator(.hidden)
//                     .listRowBackground(Color.clear)
//                 }
//
//             } // End List
//            .listStyle(PlainListStyle())
//            .scrollContentBackground(.hidden) // Essential for ZStack background
//            .refreshable { await fetchTracks(forceReload: true) } // Pull-to-refresh tracks
//
//        } // End ZStack
//        .navigationTitle("") // Clear title text, header provides it
//        .navigationBarTitleDisplayMode(.inline)
//        // Match nav bar theme from List view
//        .toolbarBackground(retroDeepPurple.opacity(0.85), for: .navigationBar)
//        .toolbarBackground(.visible, for: .navigationBar)
//        .toolbarColorScheme(.dark, for: .navigationBar)
//        .task { await fetchTracks() } // Load tracks on appear
//        // Animate player appearance/track selection smoothly
//        .animation(.easeInOut(duration: 0.3), value: selectedTrackUri)
//        .animation(.easeInOut(duration: 0.3), value: isLoadingTracks)
//       //  .animation(.easeInOut(duration: 0.3), value: trackFetchError)
//    }
//
//    // --- Fetch Tracks Logic ---
//    private func fetchTracks(forceReload: Bool = false) async {
//         // Avoid fetching if already loaded, unless forced
//         guard forceReload || tracks.isEmpty || trackFetchError != nil else { return }
//
//         await MainActor.run { isLoadingTracks = true; trackFetchError = nil }
//         do {
//             let response = try await SpotifyAPIService.shared.getAlbumTracks(albumId: album.id)
//             try Task.checkCancellation() // Check before updating state
//             await MainActor.run {
//                 self.tracks = response.items
//                 self.isLoadingTracks = false
//             }
//         } catch is CancellationError {
//             print("🔶 Track fetch cancelled.")
//             // Only set loading to false if we were actually loading and are now cancelled
//             await MainActor.run { if isLoadingTracks { isLoadingTracks = false } }
//        } catch let apiError as SpotifyAPIError {
//             print("❌ Track Fetch API Error: \(apiError.localizedDescription)")
//             await MainActor.run { self.trackFetchError = apiError; self.isLoadingTracks = false; self.tracks = [] }
//         } catch {
//             print("❌ Track Fetch Unexpected Error: \(error.localizedDescription)")
//             await MainActor.run { self.trackFetchError = .networkError(error); self.isLoadingTracks = false; self.tracks = [] }
//         }
//    }
//}
//
//// MARK: -- DetailView Sub-Components (Themed)
//
//struct AlbumHeaderView: View {
//    let album: AlbumItem
//
//    var body: some View {
//        VStack(spacing: 18) { // Increased spacing
//            AlbumImageView(url: album.bestImageURL) // Use larger image
//                .aspectRatio(1.0, contentMode: .fit)
//                 .clipShape(RoundedRectangle(cornerRadius: 12)) // Softer corners
//                .overlay( // Gradient border
//                    RoundedRectangle(cornerRadius: 12)
//                        .stroke(LinearGradient(colors: [retroNeonPink.opacity(0.7), retroNeonCyan.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 2)
//                )
//                .neonGlow(retroNeonCyan, radius: 18) // Stronger glow for main image
//                .padding(.horizontal, 60) // More horizontal padding
//                 .padding(.top, 10) // Padding from top
//
//            // Text Information VStack
//            VStack(spacing: 6) {
//                Text(album.name)
//                     .font(retroFont(size: 24, weight: .bold)) // Larger title
//                    .foregroundColor(.white)
//                     .multilineTextAlignment(.center)
//                     .shadow(color: .black.opacity(0.6), radius: 3, y: 1) // Slightly stronger shadow
//
//                Text("by \(album.formattedArtists)")
//                     .font(retroFont(size: 17)) // Larger artist text
//                    .foregroundColor(retroNeonLime)
//                    .multilineTextAlignment(.center)
//
//                 // Album Type & Date HStack
//                HStack(spacing: 8) {
//                    Text(album.album_type.capitalized)
//                    Text("•")
//                    Text(album.formattedReleaseDate())
//                 }
//                 .font(retroFont(size: 13))
//                 .foregroundColor(.white.opacity(0.75)) // More visible
//            }
//            .padding(.horizontal)
//
//        }
//         .padding(.bottom, 20) // Padding below header before tracks/player
//    }
//}
//
//
//struct SpotifyEmbedPlayerView: View {
//    @ObservedObject var playbackState: SpotifyPlaybackState
//    let spotifyUri: String
//
//    var body: some View {
//        VStack(spacing: 10) { // Increased spacing
//            // --- WebView Embed ---
//            SpotifyEmbedWebView(playbackState: playbackState, spotifyUri: spotifyUri)
//                .frame(height: 80) // Standard embed height
//                 // --- Themed Frame ---
//                 .background(
//                    LinearGradient(colors: [.black.opacity(0.6), .black.opacity(0.3)], startPoint: .top, endPoint: .bottom)
//                          .overlay(.ultraThinMaterial.opacity(0.7)) // More pronounced material
//                         .clipShape(RoundedRectangle(cornerRadius: 14))
//                         .overlay( // Dynamic border based on playback
//                             RoundedRectangle(cornerRadius: 14)
//                                 .stroke(LinearGradient(colors: playbackState.isPlaying ? [retroNeonLime.opacity(0.8), retroNeonCyan.opacity(0.5)] : [retroNeonPink.opacity(0.8), retroDeepPurple.opacity(0.5)], startPoint: .leading, endPoint: .trailing), lineWidth: 1.5)
//                         )
//                          .neonGlow(playbackState.isPlaying ? retroNeonLime : retroNeonPink, radius: 10) // Dynamic glow
//                )
//                .padding(.horizontal, 15) // Padding around player
//
//            // --- Playback Status & Time ---
//            HStack {
//                let statusText = playbackState.isPlaying ? "PLAYING" : (playbackState.duration > 0.1 ? "PAUSED" : "LOADING ") // Show loading if no duration yet
//                let statusColor = playbackState.isPlaying ? retroNeonLime : (playbackState.duration > 0.1 ? retroNeonPink : retroNeonCyan)
//
//                Text(statusText)
//                     .font(retroFont(size: 11, weight: .bold))
//                    .foregroundColor(statusColor)
//                    .tracking(1.5)
//                    .neonGlow(statusColor, radius: 5)
//                     .lineLimit(1)
//                    .frame(width: 70, alignment: .leading) // Ensure space for "LOADING"
//
//                Spacer()
//
//                // Time Display (only if duration known)
//                if playbackState.duration > 0.1 {
//                    Text("\(formatTime(playbackState.currentPosition)) / \(formatTime(playbackState.duration))")
//                         .font(retroFont(size: 11, weight: .medium))
//                         .foregroundColor(.white.opacity(0.85))
//                } else if !statusText.contains("LOADING") { // Don't show placeholder if loading
//                     Text("--:-- / --:--")
//                         .font(retroFont(size: 11, weight: .medium))
//                         .foregroundColor(.white.opacity(0.5))
//                 }
//             }
//             .padding(.horizontal, 25) // Align with player padding
//             .frame(height: 15) // Reserve space for time display
//
//        } // End VStack
//        .animation(.easeInOut(duration: 0.4), value: playbackState.isPlaying) // Animate glow/border color change
//         .animation(.easeInOut, value: playbackState.duration) // Animate time appearance
//    }
//
//     // Time Formatting Helper
//    private func formatTime(_ time: Double) -> String {
//        let totalSeconds = max(0, Int(time))
//         let minutes = totalSeconds / 60
//         let seconds = totalSeconds % 60
//        return String(format: "%d:%02d", minutes, seconds)
//     }
//}
//
//
//struct TracksSectionView: View {
//    let tracks: [Track]
//    let isLoading: Bool
//    let error: SpotifyAPIError?
//    @Binding var selectedTrackUri: String? // Binding to update parent
//    let retryAction: () -> Void
//    
//    var body: some View {
//        EmptyView()
//    }
//
////    var body: some View {
////        // No encompassing VStack/Group needed when used directly in List Section
////        if isLoading {
////            HStack { // Centered loading indicator
////                Spacer()
////                 ProgressView().tint(retroNeonCyan)
////                 Text("Loading Tracks...")
////                     .font(retroFont(size: 14))
////                     .foregroundColor(retroNeonCyan.opacity(0.8))
////                    .padding(.leading, 8)
////                 Spacer()
////            }
////            .padding(.vertical, 30) // Give loading indicator ample space
////        } else if let error = error {
////            // Use the themed ErrorPlaceholderView
////            ErrorPlaceholderView(error: error, retryAction: retryAction)
////                 .padding(.vertical, 30) // Give error view space
////        } else if tracks.isEmpty {
////            // Message for when tracks array is empty *after* successful load
////             Text("No tracks found for this album.")
////                 .font(retroFont(size: 14))
////                 .foregroundColor(.white.opacity(0.6))
////                 .frame(maxWidth: .infinity, alignment: .center)
////                 .padding(.vertical, 30)
////        } else {
////            // Use ForEach directly within the List Section for track rows
////             ForEach(tracks) { track in
////                TrackRowView(
////                    track: track,
////                    isSelected: track.uri == selectedTrackUri // Check if this track is the selected one
////                 )
////                 .contentShape(Rectangle()) // Make the whole row tappable
////                 .onTapGesture {
////                     // Update the selected URI - triggers animation in parent
////                     selectedTrackUri = track.uri
////                 }
////                 // Apply themed background highlight directly using listRowBackground
////                 .listRowBackground(
////                     track.uri == selectedTrackUri
////                        ? LinearGradient(colors: [retroNeonCyan.opacity(0.25), retroNeonPink.opacity(0.15)], startPoint: .leading, endPoint: .trailing).blur(radius: 3) // More visible highlight
////                        : Color.clear // Default transparent background
////                  )
////            }
////        }
////    }
////
//}
//
//
//struct TrackRowView: View {
//    let track: Track
//    let isSelected: Bool
//
//    var body: some View {
//        HStack(spacing: 12) { // Consistent spacing
//            // --- Track Number ---
//            Text("\(track.track_number)")
//                 .font(retroFont(size: 12, weight: .semibold)) // Slightly bolder
//                .foregroundColor(isSelected ? retroNeonLime : .white.opacity(0.6)) // Highlight selected number
//                .frame(width: 28, alignment: .trailing) // Align right for neatness
//                .padding(.leading, 15) // Padding from screen edge
//
//            // --- Track Info (Name & Artist) ---
//            VStack(alignment: .leading, spacing: 3) { // Reduced spacing
//                Text(track.name)
//                    // Slightly larger, bold when selected
//                    .font(retroFont(size: 15, weight: isSelected ? .bold : .regular))
//                    .foregroundColor(isSelected ? .white : .white.opacity(0.9)) // Brighter white when selected
//                    .lineLimit(1)
//
//                Text(track.formattedArtists)
//                     .font(retroFont(size: 12)) // Slightly larger artist font
//                    .foregroundColor(isSelected ? retroNeonLime.opacity(0.9) : .white.opacity(0.7)) // Highlight artist when selected
//                    .lineLimit(1)
//            }
//
//            Spacer() // Push duration and icon to the right
//
//            // --- Duration ---
//            Text(track.formattedDuration)
//                .font(retroFont(size: 12, weight: .medium))
//                .foregroundColor(.white.opacity(0.7))
//                 .padding(.trailing, 8) // Space before icon
//
//            // --- Play/Playing Indicator ---
//            Image(systemName: isSelected ? "speaker.wave.2.fill" : "play.circle") // More descriptive icons
//                .foregroundColor(isSelected ? retroNeonCyan : .white.opacity(0.8))
//                .font(.system(size: 16)) // Adjust icon size
//                 .frame(width: 25, height: 25, alignment: .center) // Consistent frame
//                .animation(.easeInOut, value: isSelected) // Animate icon change
//                .padding(.trailing, 15) // Padding from screen edge
//
//        }
//        .padding(.vertical, 14) // Increased vertical padding for easier tapping
//    }
//}
//
//// MARK: -- Other Supporting Views (Themed)
//
//struct AlbumImageView: View { // Primarily uses AsyncImage, theming in placeholder
//    let url: URL?
//    var cornerRadius: CGFloat = 8 // Allow customization if needed
//
//    var body: some View {
//        AsyncImage(url: url) { phase in
//            switch phase {
//            case .empty:
//                 // --- Themed Loading Placeholder ---
//                ZStack {
//                    RoundedRectangle(cornerRadius: cornerRadius)
//                         .fill(LinearGradient(colors: [retroDeepPurple.opacity(0.5), .black.opacity(0.6)], startPoint: .top, endPoint: .bottom))
//                         .overlay(RoundedRectangle(cornerRadius: cornerRadius).stroke(retroNeonCyan.opacity(0.2), lineWidth: 1))
//
//                    ProgressView().tint(retroNeonCyan)
//                }
//            case .success(let image):
//                // --- Display Loaded Image ---
//                 image.resizable().scaledToFit()
//                     // Add subtle inner shadow for depth (optional)
//                     // .shadow(color: .black.opacity(0.4), radius: 3, x: 0, y: 1)
//            case .failure:
//                 // --- Themed Error Placeholder ---
//                ZStack {
//                    RoundedRectangle(cornerRadius: cornerRadius)
//                        .fill(LinearGradient(colors: [retroDeepPurple.opacity(0.5), .black.opacity(0.6)], startPoint: .top, endPoint: .bottom))
//                        .overlay(RoundedRectangle(cornerRadius: cornerRadius).stroke(retroNeonPink.opacity(0.3), lineWidth: 1)) // Error border color
//
//                    Image(systemName: "photo.fill.on.rectangle.fill") // More fitting icon
//                         .resizable().scaledToFit()
//                         .foregroundColor(retroNeonPink.opacity(0.6)) // Error tint
//                         .padding(10) // Padding around icon
//                }
//            @unknown default:
//                EmptyView() // Should not happen with current AsyncImage
//            }
//        }
//    }
//}
//
//
//struct SearchMetadataHeader: View {
//    let totalResults: Int
//    let limit: Int
//    let offset: Int
//
//    var body: some View {
//        HStack {
//            Text("TOTAL: \(totalResults)")
//            Spacer()
//            if totalResults > limit { // Show range only if more than one page potentially exists
//                Text("DISPLAYING: \(offset + 1)-\(min(offset + limit, totalResults))")
//            }
//        }
//        .font(retroFont(size: 11, weight: .bold)) // Slightly larger
//        .foregroundColor(retroNeonLime.opacity(0.85)) // Brighter
//        .tracking(1.5) // More spacing
//        .padding(.horizontal, 15)
//        .padding(.vertical, 8) // Add vertical padding
//        .background(Color.black.opacity(0.25)) // Subtle background bar
//        // Add subtle top/bottom border lines
////         .overlay(VStack(spacing: 0) {
////             Rectangle().frame(height: 0.5).foregroundColor(retroNeonLime.opacity(0.3))
////             Spacer()
////             Rectangle().frame(height: 0.5).foregroundColor(retroNeonLime.opacity(0.3))
////         })
//    }
//}
//
//
//// Generic Themed Button
//struct RetroButton: View {
//    let text: String
//    let action: () -> Void
//    var primaryColor: Color = retroNeonPink
//    var secondaryColor: Color = .purple // For gradient end
//    var iconName: String? = nil
//    @State private var isPressed: Bool = false // For press effect
//
//    var body: some View {
//        Button(action: action) {
//            HStack(spacing: 10) { // Increased spacing
//                if let iconName = iconName {
//                    Image(systemName: iconName)
//                         .font(.system(size: 16, weight: .semibold)) // Slightly larger icon
//                }
//                Text(text)
//                    .tracking(2) // Wider tracking
//            }
//            .font(retroFont(size: 16, weight: .bold)) // Larger font
//            .padding(.horizontal, 30)
//            .padding(.vertical, 13)
//            .frame(maxWidth: .infinity)
//            // --- Themed Background & Foreground ---
//            .background(
//                 LinearGradient(colors: [primaryColor, secondaryColor], startPoint: .leading, endPoint: .trailing)
//                     // Darken slightly when pressed
//                     .brightness(isPressed ? -0.15 : 0)
//                     .animation(.easeInOut(duration: 0.05), value: isPressed)
//            )
//             .foregroundColor(isPressed ? retroDeepPurple.opacity(0.8) : retroDeepPurple) // Dark text, slightly dimmer when pressed
//            .clipShape(Capsule())
//             // --- Themed Border & Glow ---
//             .overlay(
//                 Capsule()
//                      .stroke(LinearGradient(colors: [.white.opacity(0.6), .white.opacity(0.2)], startPoint: .top, endPoint: .bottom), lineWidth: 1.5) // Beveled edge effect
//                      .brightness(isPressed ? -0.2 : 0) // Dim border on press
//                      .animation(.easeInOut(duration: 0.05), value: isPressed)
//            )
//             .neonGlow(primaryColor, radius: isPressed ? 8 : 12) // Reduce glow on press
//             .scaleEffect(isPressed ? 0.98 : 1.0) // Scale down slightly on press
//             .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed) // Spring animation for press
//
//        }
//         .buttonStyle(.plain) // Remove default button styling
//         // --- Press Gesture Handling ---
//         .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
//             withAnimation { isPressed = pressing }
//         }, perform: {})
//    }
//}
//
//
//// Wrapper for External Link using RetroButton
//struct ExternalLinkButton: View {
//    let text: String = "OPEN IN SPOTIFY"
//    let url: URL
//    var primaryColor: Color = retroNeonLime
//    var secondaryColor: Color = .green // Spotify Greenish
//    // Updated icon for external link
//    var iconName: String? = "arrow.up.forward.app.fill"
//
//    @Environment(\.openURL) var openURL
//
//    var body: some View {
//        RetroButton(
//            text: text,
//            action: {
//                print("Opening external Spotify URL: \(url)")
//                openURL(url) { accepted in
//                    if !accepted {
//                        print("⚠️ Failed to open URL: \(url). OS blocked or no app installed.")
//                        // Optional: Show an alert to the user here
//                    }
//                }
//            },
//            primaryColor: primaryColor,
//            secondaryColor: secondaryColor,
//            iconName: iconName
//        )
//    }
//}
//
//// MARK: - Preview Providers (Optional but Recommended)
//
//struct SpotifyAlbumListView_Previews: PreviewProvider {
//    static var previews: some View {
//        SpotifyAlbumListView()
//             .preferredColorScheme(.dark) // Preview in dark scheme
//    }
//}
//
//// Mock data for previews
//private struct MockData {
//    static let artist = Artist(id: "1", external_urls: nil, href: "", name: "Retro Wave Masters", type: "artist", uri: "")
//    static let image = SpotifyImage(height: 300, url: "https://via.placeholder.com/300/FF1493/FFFFFF?text=ALBUMART", width: 300) // Placeholder pink image
//     static let album = AlbumItem(id: "retro1", album_type: "album", total_tracks: 12, available_markets: ["US"], external_urls: ExternalUrls(spotify: "https://example.spotify.com"), href: "", images: [image], name: "Neon Nights Drive", release_date: "1984", release_date_precision: "year", type: "album", uri: "spotify:album:retro1", artists: [artist])
//      static let track = Track(id: "track1", artists: [artist], disc_number: 1, duration_ms: 245000, explicit: false, external_urls: nil, href: "", name: "Sunset Grid", preview_url: nil, track_number: 1, type: "track", uri: "spotify:track:track1")
//}
//
//struct RetroAlbumCard_Previews: PreviewProvider {
//    static var previews: some View {
//        RetroAlbumCard(album: MockData.album)
//            .padding()
//             .background(retroDeepPurple) // Show on themed background
//            .previewLayout(.fixed(width: 400, height: 160)) // Adjust preview size
//            .preferredColorScheme(.dark)
//    }
//}
//
//struct AlbumDetailView_Previews: PreviewProvider {
//    static let detailImage = SpotifyImage(height: 640, url: "https://via.placeholder.com/640/00FFFF/000000?text=ALBUM+DETAIL", width: 640) // Placeholder cyan image
//    static let detailAlbum = AlbumItem(id: "retro1", album_type: "album", total_tracks: 12, available_markets: ["US"], external_urls: ExternalUrls(spotify: "https://example.spotify.com"), href: "", images: [detailImage], name: "Neon Nights Drive", release_date: "1984", release_date_precision: "year", type: "album", uri: "spotify:album:retro1", artists: [MockData.artist])
//
//    static var previews: some View {
//        NavigationView {
//             AlbumDetailView(album: detailAlbum) // Pass some mock tracks
//        }
//        .preferredColorScheme(.dark)
//    }
//}
//
//// MARK: - App Entry Point
////
////@main
////struct SpotifyRetroApp: App {
////    init() {
////        // --- Token Check on Startup ---
////        if placeholderSpotifyToken == "YOUR_SPOTIFY_BEARER_TOKEN_HERE" {
////             print("🚨🎬 FATAL STARTUP WARNING: Spotify Bearer Token is not set! API calls WILL FAIL.")
////             print("👉 FIX: Replace 'YOUR_SPOTIFY_BEARER_TOKEN_HERE' in this file with a valid token.")
////             // Consider a more user-facing alert in a real app
////         }
////
////        // --- Optional Global UI Appearance Tuning ---
////         // Example: Tint color for system elements if needed
////         // UIView.appearance().tintColor = UIColor(retroNeonPink)
////    }
////
////    var body: some Scene {
////        WindowGroup {
////             SpotifyAlbumListView() // Start with the main list view
////                 .preferredColorScheme(.dark) // Force dark scheme for the retro theme
////        }
////    }
////}
////
