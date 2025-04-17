////
////  SearchForItemAPIDocDemoView_V6.swift
////  MyApp
////
////  Created by Cong Le on 4/16/25.
////
//
//import SwiftUI
//// Needed for WebView
//@preconcurrency import WebKit
//import Foundation // Keep for URLSession etc.
//
//// MARK: - Data Models (Unchanged)
//// ... (SpotifySearchResponse, Albums, AlbumItem, Artist, SpotifyImage, ExternalUrls remain the same) ...
//// MARK: - Spotify Search Response Wrapper
//struct SpotifySearchResponse: Codable, Hashable {
//    let albums: Albums
//}
//
//// MARK: - Albums Container
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
//// MARK: - Album Item
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
//    // --- Helper computed properties (Unchanged) ---
//    var bestImageURL: URL? {
//        images.first { $0.width == 640 }?.urlObject ??
//        images.first { $0.width == 300 }?.urlObject ??
//        images.first?.urlObject
//    }
//    var listImageURL: URL? {
//        images.first { $0.width == 300 }?.urlObject ??
//        images.first { $0.width == 64 }?.urlObject ??
//        images.first?.urlObject
//    }
//    var formattedArtists: String {
//        artists.map { $0.name }.joined(separator: ", ")
//    }
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
//                dateFormatter.dateFormat = "MMM yyyy"
//                return dateFormatter.string(from: date)
//            }
//        case "day":
//            dateFormatter.dateFormat = "yyyy-MM-dd"
//            if let date = dateFormatter.date(from: release_date) {
//                return date.formatted(date: .long, time: .omitted)
//            }
//        default: break
//        }
//        return release_date
//    }
//}
//
//// MARK: - Artist - Unchanged
//struct Artist: Codable, Identifiable, Hashable {
//    let id: String
//    let external_urls: ExternalUrls? // Make optional if sometimes missing
//    let href: String
//    let name: String
//    let type: String // "artist"
//    let uri: String
//}
//
//// MARK: - Image
//struct SpotifyImage: Codable, Hashable {
//    let height: Int?
//    let url: String
//    let width: Int?
//
//    var urlObject: URL? { URL(string: url) }
//}
//
//// MARK: - External URLs
//struct ExternalUrls: Codable, Hashable {
//    let spotify: String? // Make optional if sometimes missing
//}
//
//// MARK: - Track Models (Unchanged)
//// ... (AlbumTracksResponse, Track remain the same) ...
//struct AlbumTracksResponse: Codable, Hashable {
//    let items: [Track]
//    // Add other fields like href, limit, next, offset, previous, total if needed
//}
//
//struct Track: Codable, Identifiable, Hashable {
//    let id: String
//    let artists: [Artist]
//    // let available_markets: [String]? // Optional, might not be needed for playback
//    let disc_number: Int
//    let duration_ms: Int
//    let explicit: Bool
//    let external_urls: ExternalUrls?
//    let href: String
//    let name: String
//    let preview_url: String? // URL for 30s preview, might be null
//    let track_number: Int
//    let type: String // "track"
//    let uri: String // The crucial URI for the embed player
//
//    // Helper for formatted duration
//    var formattedDuration: String {
//        let totalSeconds = duration_ms / 1000
//        let minutes = totalSeconds / 60
//        let seconds = totalSeconds % 60
//        return String(format: "%d:%02d", minutes, seconds)
//    }
//
//    // Helper for formatted artist names
//    var formattedArtists: String {
//        artists.map { $0.name }.joined(separator: ", ")
//    }
//}
//
//// MARK: - Spotify Embed WebView and Related Code (Unchanged)
//// ... (SpotifyPlaybackState, SpotifyEmbedWebView, Coordinator, generateHTML) ...
//final class SpotifyPlaybackState: ObservableObject {
//    @Published var isPlaying: Bool = false
//    @Published var currentPosition: Double = 0 // seconds
//    @Published var duration: Double = 0 // seconds
//    @Published var currentUri: String = ""
//}
//
//// MARK: - SpotifyEmbedWebView (UIViewRepresentable)
//
//struct SpotifyEmbedWebView: UIViewRepresentable {
//    @ObservedObject var playbackState: SpotifyPlaybackState
//    let spotifyUri: String // This will be the track URI we want to play
//
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//
//    func makeUIView(context: Context) -> WKWebView {
//        // --- Configuration ---
//        let userContentController = WKUserContentController()
//        // Register the coordinator to handle messages from JavaScript
//        userContentController.add(context.coordinator, name: "spotifyController")
//
//        let configuration = WKWebViewConfiguration()
//        configuration.userContentController = userContentController
//        // Allow media playback without user gestures & inline playback
//        configuration.allowsInlineMediaPlayback = true
//        configuration.mediaTypesRequiringUserActionForPlayback = []
//
//        // --- WebView Creation ---
//        let webView = WKWebView(frame: .zero, configuration: configuration)
//        webView.navigationDelegate = context.coordinator
//        webView.uiDelegate = context.coordinator // Needed for JS alerts/prompts
//        webView.isOpaque = false
//        webView.backgroundColor = .clear // Make background transparent
//        webView.scrollView.isScrollEnabled = false // Disable scrolling in the embed frame
//
//        // --- Load HTML ---
//        let html = generateHTML()
//        webView.loadHTMLString(html, baseURL: nil)
//
//        // --- Store reference in Coordinator ---
//        context.coordinator.webView = webView
//        return webView
//    }
//
//    func updateUIView(_ webView: WKWebView, context: Context) {
//        // Check if the API is ready and the URI needs updating
//        if context.coordinator.isApiReady && context.coordinator.lastLoadedUri != spotifyUri {
//            context.coordinator.loadUri(spotifyUri)
//            // Update published state if needed, though Coordinator handles lastLoadedUri
//            DispatchQueue.main.async {
//                 if playbackState.currentUri != spotifyUri {
//                     playbackState.currentUri = spotifyUri // Keep playbackState syncd
//                 }
//            }
//        }
//    }
//
//    static func dismantleUIView(_ uiView: WKWebView, coordinator: Coordinator) {
//        print("Spotify Embed WebView: Dismantling.")
//        uiView.stopLoading()
//        // VERY Important: Remove the message handler to prevent memory leaks/crashes
//        uiView.configuration.userContentController.removeScriptMessageHandler(forName: "spotifyController")
//        coordinator.webView = nil // Break potential retain cycle
//    }
//
//    // MARK: - Coordinator
//
//    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
//        var parent: SpotifyEmbedWebView
//        weak var webView: WKWebView? // Use weak to avoid retain cycles
//
//        var isApiReady = false
//        var lastLoadedUri: String?
//
//        init(_ parent: SpotifyEmbedWebView) {
//            self.parent = parent
//        }
//
//        // --- WKNavigationDelegate Methods ---
//        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//            print("Spotify Embed WebView: HTML content finished loading.")
//            // The actual controller setup happens after the JS API signals readiness
//        }
//
//        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
//            print("Spotify Embed WebView: Navigation failed: \(error.localizedDescription)")
//            // Handle failure, maybe show an error state in the UI
//        }
//
//        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
//            print("Spotify Embed WebView: Provisional navigation failed: \(error.localizedDescription)")
//            // Handle initial loading failure
//        }
//
//        // --- WKScriptMessageHandler Method ---
//        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
//            guard message.name == "spotifyController" else { return }
//            // Use structured logging for clarity
//            if let bodyDict = message.body as? [String: Any], let event = bodyDict["event"] as? String {
//                print("📦 Spotify Embed Native: JS Event Received - '\(event)', Data: \(bodyDict["data"] ?? "nil")")
//                handleEvent(event: event, data: bodyDict["data"])
//            } else if let bodyString = message.body as? String {
//                 print("📦 Spotify Embed Native: JS String Message Received - '\(bodyString)'")
//                if bodyString == "ready" {
//                    handleApiReady()
//                } else {
//                    print("❓ Spotify Embed Native: Received unknown string message: \(bodyString)")
//                }
//            } else {
//                 print("❓ Spotify Embed Native: Received message in unexpected format: \(message.body)")
//            }
//        }
//
//        // --- Split Message Handling Logic ---
//        private func handleApiReady() {
//             print("✅ Spotify Embed Native: Spotify IFrame API reported ready.")
//             isApiReady = true
//             // Now that API is ready, attempt to create the controller with the initial URI.
//             // updateUIView might have already set the desired URI if it was called before the API was ready.
//             createSpotifyController(with: parent.spotifyUri)
//        }
//
//        private func handleEvent(event: String, data: Any?) {
//             switch event {
//             case "controllerCreated":
//                 print("✅ Spotify Embed Native: Embed controller successfully created by JS.")
//                 // Post-creation actions if needed
//
//             case "playbackUpdate":
//                 // print("🔄 Spotify Embed Native: Received playback update.") // Less verbose logging
//                 if let updateData = data as? [String: Any] {
//                     updatePlaybackState(with: updateData)
//                 } else {
//                      print("⚠️ Spotify Embed Native: Playback update data missing or invalid format.")
//                 }
//
//             case "error":
//                 let errorMessage = (data as? [String: Any])?["message"] as? String ?? (data as? String) ?? "Unknown JS error"
//                 print("❌ Spotify Embed JS Error: \(errorMessage)")
//                 // Propagate error to UI if needed (e.g., via another @Published property or callback)
//
//             default:
//                 print("❓ Spotify Embed Native: Received unknown event type: \(event)")
//             }
//        }
//
//        private func updatePlaybackState(with data: [String: Any]) {
//            DispatchQueue.main.async { [self] in
//                 if let isPaused = data["paused"] as? Bool {
//                      // Only update if the state actually changed to avoid needless view refreshes
//                     if parent.playbackState.isPlaying == isPaused {
//                         parent.playbackState.isPlaying = !isPaused
//                     }
//                 }
//                 if let posMs = data["position"] as? Double {
//                     let newPosition = posMs / 1000.0
//                     // Add a small tolerance to avoid rapid updates for minor position changes
//                     if abs(parent.playbackState.currentPosition - newPosition) > 0.1 {
//                           parent.playbackState.currentPosition = newPosition
//                     }
//                 }
//                 if let durMs = data["duration"] as? Double {
//                      let newDuration = durMs / 1000.0
//                     // Update duration only if it's significantly different or zero
//                      if abs(parent.playbackState.duration - newDuration) > 0.1 || newDuration == 0 {
//                         parent.playbackState.duration = newDuration
//                      }
//                 }
//                  if let uri = data["uri"] as? String, parent.playbackState.currentUri != uri {
//                     parent.playbackState.currentUri = uri
//                 }
//             }
//        }
//
//        // --- Helper to Execute JS for Creating the Embed Controller ---
//        private func createSpotifyController(with initialUri: String) {
//             guard let webView = webView else {
//                  print("⚠️ Spotify Embed Native: WebView is nil, cannot create controller.")
//                  return
//             }
//             guard isApiReady else {
//                  print("⏳ Spotify Embed Native: API not ready, deferring controller creation.")
//                  return
//             }
//            // Only initialize if it hasn't been initialized yet OR if the URI changed *before* ready
//            guard lastLoadedUri == nil else {
//                print("ℹ️ Spotify Embed Native: Controller initialization already attempted or completed.")
//                // If the initial URI changed between view creation and API ready, load it now
////                if let currentDesiredUri = parent.spotifyUri, currentDesiredUri != lastLoadedUri {
////                     print("🔄 Spotify Embed Native: URI changed before controller ready, loading new URI: \(currentDesiredUri)")
////                    loadUri(currentDesiredUri)
////                }
//                return
//            }
//
//             print("🚀 Spotify Embed Native: Attempting to create controller for URI: \(initialUri)")
//             lastLoadedUri = initialUri // Mark as attempting to load/create
//
//             // JavaScript to find the div and create the Spotify controller
//             let script = """
//             console.log('Spotify Embed JS: Entering script to create controller...');
//             const element = document.getElementById('embed-iframe');
//             if (!element) {
//                 console.error('Spotify Embed JS: Could not find element with id embed-iframe!');
//                 window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'HTML element embed-iframe not found' }});
//             } else if (!window.IFrameAPI) {
//                 console.error('Spotify Embed JS: IFrameAPI is not loaded!');
//                 window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'Spotify IFrame API not loaded' }});
//             } else {
//                 console.log('Spotify Embed JS: Found element and IFrameAPI. Creating controller for URI: \(initialUri)');
//                 const options = { uri: '\(initialUri)', width: '100%', height: '100%' };
//
//                 const callback = (controller) => {
//                     console.log('Spotify Embed JS: createController callback executed.');
//                     if (!controller) {
//                          console.error('Spotify Embed JS: createController callback received null controller!');
//                          window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'JS createController callback received null controller' }});
//                          return;
//                     }
//                     console.log('Spotify Embed JS: Controller instance received.');
//                     window.embedController = controller; // Store globally
//
//                     window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'controllerCreated' });
//
//                     // --- Add Listeners ---
//                     controller.addListener('ready', () => {
//                         console.log('Spotify Embed JS: Controller Ready event.');
//                         // Potential race condition: Sometimes 'ready' fires before 'playback_update' with initial state.
//                         // Fetch initial state manually if needed, though playback_update should fire.
//                         // Example: controller.getPlaybackState().then(state => { ... });
//                     });
//
//                     controller.addListener('playback_update', e => {
//                         // console.log('Spotify Embed JS: Playback :', e.data); // Verbose
//                         window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'playbackUpdate', data: e.data });
//                     });
//
//                     controller.addListener('account_error', (e) => {
//                         console.warn('Spotify Embed JS: Account Error:', e.data);
//                         window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'Account Error: ' + (e.data?.message ?? 'Premium required or login issue?') }});
//                     });
//                     controller.addListener('autoplay_failed', () => {
//                         console.warn('Spotify Embed JS: Autoplay failed');
//                         window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'Autoplay failed (browser restriction?)' }});
//                         // Maybe try controller.play() here to see if manual play works after failure?
//                         controller.play();
//                     });
//                     controller.addListener('initialization_error', (e) => {
//                         console.error('Spotify Embed JS: Initialization Error:', e.data);
//                         window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'Initialization Error: ' + (e.data?.message ?? 'Failed to initialize player') }});
//                     });
//                 };
//
//                 // --- Create the Controller ---
//                 try {
//                     console.log('Spotify Embed JS: Calling IFrameAPI.createController...');
//                     window.IFrameAPI.createController(element, options, callback);
//                     console.log('Spotify Embed JS: Call to createController completed without throwing.');
//                 } catch (e) {
//                     console.error('Spotify Embed JS: Error calling createController:', e);
//                     window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'JS exception during createController: ' + e.message }});
//                     // Reset state if creation failed fundamentally
//                     self.parent.lastLoadedUri = nil; // Use parent property
//                 }
//             }
//             """
//             // Execute the JavaScript
//             webView.evaluateJavaScript(script) { result, error in
//                 if let error = error {
//                     print("⚠️ Spotify Embed Native: Error evaluating JS for controller creation: \(error.localizedDescription)")
//                     // Reset state if JS execution failed
//                     self.lastLoadedUri = nil
//                 } else {
//                      // console.log("Spotify Embed Native: JS for controller creation evaluated. Result: \(result ?? "nil")") // Verbose
//                 }
//             }
//        }
//
//        // --- Helper to Execute JS for Loading a New URI ---
//        func loadUri(_ uri: String) {
//            guard let webView = webView else {
//                print("⚠️ Spotify Embed Native: WebView is nil, cannot load URI.")
//                return
//            }
//            guard isApiReady else {
//                print("⏳ Spotify Embed Native: API not ready, cannot load URI \(uri). Will try when ready.")
//                // Do not update lastLoadedUri yet, let create handle it.
//                return
//            }
//            guard lastLoadedUri != nil else {
//                 print("⏳ Spotify Embed Native: Controller not yet created, cannot load URI \(uri). Will be loaded on creation.")
//                // Don't set lastLoadedUri here, let create handle the initial load.
//                 return
//            }
//             guard lastLoadedUri != uri else {
//                 print("ℹ️ Spotify Embed Native: URI \(uri) is already loaded or being loaded.")
//                 // Optional: Force reload if necessary, but usually not needed.
//                 // E.g., window.embedController.loadUri('\(uri)');
//                 return
//            }
//
//            print("🚀 Spotify Embed Native: Attempting to load new URI: \(uri)")
//            lastLoadedUri = uri // Update the tracker *before* calling JS
//
//            let script = """
//            if (window.embedController) {
//                console.log('Spotify Embed JS: Loading URI: \(uri)');
//                window.embedController.loadUri('\(uri)');
//                // Optional: Add immediate play command if desired after load
//                // window.embedController.play();
//            } else {
//                console.error('Spotify Embed JS: embedController not found when trying to load URI \(uri).');
//                 window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'JS embedController not found during loadUri' }});
//            }
//            """
//            webView.evaluateJavaScript(script) { _, error in
//                if let error = error {
//                    print("⚠️ Spotify Embed Native: Error evaluating JS for loading URI \(uri): \(error.localizedDescription)")
//                     // Revert lastLoadedUri if JS call failed? Maybe not, JS state is unknown.
//                    // self.lastLoadedUri = self.parent.spotifyPlaybackState.currentUri // Revert to current actual uri
//                } else {
//                     // console.log("Spotify Embed Native: JS for loading URI \(uri) evaluated.") // Verbose
//                }
//            }
//        }
//
//        // --- WKUIDelegate Method (Optional but good practice) ---
//        // Handle simple JavaScript alert() calls from the web page
//        func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
//            print("ℹ️ Spotify Embed Received JS Alert: \(message)")
//            // In a real app, you might show a native alert view controlled by a delegate or state.
//            // Here, we just print it and complete immediately.
//            completionHandler()
//        }
//
//         // Add stubs for other WKUIDelegate methods if needed (confirm panels, prompts)
//         // func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) { ... }
//         // func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) { ... }
//    }
//
//     // --- Helper to Generate the Initial HTML for the WebView ---
//    // Updated to add more console logging in JS
//    private func generateHTML() -> String {
//         """
//        <!DOCTYPE html>
//        <html>
//        <head>
//            <meta charset="utf-8">
//            <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
//            <title>Spotify Embed</title> <!-- Added title -->
//            <style>
//                html, body { margin: 0; padding: 0; width: 100%; height: 100%; overflow: hidden; background-color: transparent; }
//                #embed-iframe { width: 100%; height: 100%; box-sizing: border-box; display: block; border: none; } /* Added border: none */
//            </style>
//        </head>
//        <body>
//            <div id="embed-iframe"></div>
//            <script src="https://open.spotify.com/embed/iframe-api/v1" async></script>
//            <script>
//                console.log('Spotify Embed JS: Initial script block running.');
//                window.onSpotifyIframeApiReady = (IFrameAPI) => {
//                    console.log('✅ Spotify Embed JS: onSpotifyIframeApiReady triggered.');
//                    window.IFrameAPI = IFrameAPI;
//                    if (window.webkit?.messageHandlers?.spotifyController) {
//                        console.log('➡️ Spotify Embed JS: Posting "ready" message to native.');
//                        window.webkit.messageHandlers.spotifyController.postMessage("ready");
//                    } else {
//                        console.error('❌ Spotify Embed JS: Native message handler not found!');
//                    }
//                };
//                // Error handling for the API script itself
//                const scriptTag = document.querySelector('script[src*="iframe-api"]');
//                if (scriptTag) {
//                    scriptTag.onerror = (event) => {
//                         console.error('❌ Spotify Embed JS: Failed to load Spotify API script:', event);
//                         window.webkit?.messageHandlers?.spotifyController?.postMessage({ event: 'error', data: { message: 'Failed to load Spotify API script' }});
//                    };
//                } else {
//                    console.warn('⚠️ Spotify Embed JS: Could not find Spotify API script tag for error handler.');
//                }
//            </script>
//        </body>
//        </html>
//        """
//    }
//}
//
//// MARK: - API Service Helper (Unchanged)
//// ... (SpotifyAPIError, SpotifyAPIService including placeholder token warning, makeRequest, searchAlbums, getAlbumTracks) ...
//let placeholderSpotifyToken = "BQC3Hv-5ccCuhexiRRruxtO79MQ4eP7jS7Ep1w0dhDFmMdXfCZ-FCOTZM6D1khnObW07TwNpdJqNv0pcpM8-gfxjgMnRMWf2kPjsms04y40W8o1Oy2cphjLwHihbS4c4yoIhrZS8AaX1jJIDBtzTUWTK_Dximn7RQyjILTqoKjbxzGT0TAzxVjzF6Q4Sxu1r174UdN8phIonAeEwr4He32P-vlPyHjtIsZc3dt0bpZ8QfZ7kmpD1Gfi0uuR51CsNWoBjQt3YqfHGWVnbmCXQDsBPdPoVWNUObuK6j9oeEE-RBNEyTEGyGqwV7Y8IGvCC"
//
//enum SpotifyAPIError: Error, LocalizedError {
//    case invalidURL
//    case networkError(Error)
//    case invalidResponse(Int, String?) // Includes status code and body if available
//    case decodingError(Error)
//    case invalidToken // Specific error for token issues
//    case missingData
//
//    var errorDescription: String? {
//        switch self {
//        case .invalidURL: return "The API endpoint URL was invalid."
//        case .networkError(let error): return "Network error: \(error.localizedDescription)"
//        case .invalidResponse(let statusCode, let body):
//             var message = "Received an invalid server response (Status Code: \(statusCode))."
//             if let body = body, !body.isEmpty { message += "\nDetails: \(body)" }
//             return message
//        case .decodingError(let error): return "Failed to decode the server response: \(error.localizedDescription)"
//        case .invalidToken: return "Invalid or expired Spotify API token. Please refresh or re-authenticate."
//        case .missingData: return "Expected data was missing from the API response."
//        }
//    }
//}
//
//struct SpotifyAPIService {
//    static let shared = SpotifyAPIService()
//    private let session: URLSession
//
//    init() {
//        // Configure session if needed (e.g., caching policy)
//        let configuration = URLSessionConfiguration.default
//        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData // Good for testing
//        session = URLSession(configuration: configuration)
//    }
//
//    // Helper to make requests and handle common errors
//    private func makeRequest<T: Decodable>(url: URL) async throws -> T {
//         // 1. Validate Token (Basic Check)
//        guard !placeholderSpotifyToken.isEmpty, placeholderSpotifyToken != "YOUR_SPOTIFY_BEARER_TOKEN_HERE" else {
//            print("❌ Error: Spotify Bearer Token is missing or is the placeholder value.")
//            throw SpotifyAPIError.invalidToken
//        }
//
//        // 2. Create URLRequest with Authentication Header
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//        request.setValue("Bearer \(placeholderSpotifyToken)", forHTTPHeaderField: "Authorization")
//        request.setValue("application/json", forHTTPHeaderField: "Accept") // Good practice
//        request.timeoutInterval = 20 // Slightly longer timeout
//
//        print("🚀 Making API Request to: \(url.absoluteString)")
//
//        // 3. Perform Network Request
//        do {
//            let (data, response) = try await session.data(for: request) // Use configured session
//
//            // 4. Validate HTTP Response
//            guard let httpResponse = response as? HTTPURLResponse else {
//                throw SpotifyAPIError.invalidResponse(0, "Response was not an HTTPURLResponse.")
//            }
//
//            print("🚦 HTTP Status Code: \(httpResponse.statusCode)")
//
//            // Attempt to read body for error context regardless of status code initially
//            let responseBody = String(data: data, encoding: .utf8)
//
//            guard (200...299).contains(httpResponse.statusCode) else {
//                // Handle specific auth errors
//                if httpResponse.statusCode == 401 {
//                    throw SpotifyAPIError.invalidToken
//                }
//                // Handle rate limiting
//                if httpResponse.statusCode == 429 {
//                     print("⚠️ Rate Limited. Headers: \(httpResponse.allHeaderFields)")
//                     // Implement retry logic based on 'Retry-After' header if needed
//                }
//                print("❌ Server Error Body: \(responseBody ?? "Unable to read body")")
//                throw SpotifyAPIError.invalidResponse(httpResponse.statusCode, responseBody)
//            }
//
//            // 5. Decode JSON Response
//            do {
//                let decoder = JSONDecoder()
//                let decodedObject = try decoder.decode(T.self, from: data)
//                // print("✅ Successfully decoded response of type \(T.self)") // Less verbose logging
//                return decodedObject
//            } catch {
//                print("❌ Error: Failed to decode JSON for type \(T.self).")
//                if let jsonString = String(data: data, encoding: .utf8) {
//                    print("📄 Received JSON String: \(jsonString)")
//                }
//                // Print detailed decoding error
//                if let decodingError = error as? DecodingError {
//                     switch decodingError {
//                     case .typeMismatch(let type, let context):
//                         print("🔧 Decoding typeMismatch: \(type), Context: \(context.codingPath) - \(context.debugDescription)")
//                     case .valueNotFound(let type, let context):
//                          print("🔧 Decoding valueNotFound: \(type), Context: \(context.codingPath) - \(context.debugDescription)")
//                     case .keyNotFound(let key, let context):
//                          print("🔧 Decoding keyNotFound: \(key), Context: \(context.codingPath) - \(context.debugDescription)")
//                     case .dataCorrupted(let context):
//                          print("🔧 Decoding dataCorrupted: Context: \(context.codingPath) - \(context.debugDescription)")
//                     @unknown default:
//                           print("🔧 Decoding unknown error: \(error.localizedDescription)")
//                     }
//                }
//                throw SpotifyAPIError.decodingError(error)
//            }
//        } catch let error where !(error is CancellationError) {
//            print("❌ Error: Network request failed - \(error)")
//            // Throw specific API errors if already typed, otherwise wrap
//            throw error is SpotifyAPIError ? error : SpotifyAPIError.networkError(error)
//        }
//    }
//
//    // --- Search for Albums (Unchanged logic, uses helper) ---
//    func searchAlbums(query: String, limit: Int = 20, offset: Int = 0) async throws -> SpotifySearchResponse {
//        var components = URLComponents(string: "https://api.spotify.com/v1/search")
//        components?.queryItems = [
//            URLQueryItem(name: "q", value: query),
//            URLQueryItem(name: "type", value: "album"),
//            URLQueryItem(name: "include_external", value: "audio"),
//            URLQueryItem(name: "limit", value: String(limit)),
//            URLQueryItem(name: "offset", value: String(offset))
//        ]
//
//        guard let url = components?.url else {
//            throw SpotifyAPIError.invalidURL
//        }
//        return try await makeRequest(url: url)
//    }
//
//    // --- NEW: Fetch Tracks for a Specific Album ---
//    func getAlbumTracks(albumId: String, limit: Int = 50, offset: Int = 0) async throws -> AlbumTracksResponse {
//         var components = URLComponents(string: "https://api.spotify.com/v1/albums/\(albumId)/tracks")
//         components?.queryItems = [
//             URLQueryItem(name: "limit", value: String(limit)),
//             URLQueryItem(name: "offset", value: String(offset))
//             // Add market if needed: URLQueryItem(name: "market", value: "US")
//         ]
//
//        guard let url = components?.url else {
//            throw SpotifyAPIError.invalidURL
//        }
//        return try await makeRequest(url: url)
//    }
//}
//
//// MARK: - SwiftUI Views
//
//// MARK: - Main List View with Search (*** UPDATED ***)
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
//                // Conditional Content: Loading, Error, Empty, or List
//                Group {
//                    if isLoading && displayedAlbums.isEmpty {
//                        ProgressView("Searching...")
//                            .scaleEffect(1.2) // Make progress view slightly larger
//                            .tint(.accentColor)
//                    } else if let error = currentError {
//                        // --- NEW Enhanced Error View ---
//                        ErrorPlaceholderView(error: error) {
//                             // Retry Action
//                             Task { await performDebouncedSearch() }
//                         }
//                    } else if displayedAlbums.isEmpty {
//                        // --- NEW Enhanced Empty View (Handles initial & no-results) ---
//                        EmptyStatePlaceholderView(searchQuery: searchQuery)
//                    } else {
//                        albumList // Extracted list view
//                    }
//                }
//                .frame(maxWidth: .infinity, maxHeight: .infinity) // Center placeholders
//                .transition(.opacity.animation(.easeInOut(duration: 0.3))) // Smooth transitions
//
//                // Separate overlay for ongoing loading indicator (doesn't hide list)
//                if isLoading && !displayedAlbums.isEmpty {
//                    VStack {
//                        HStack {
//                           Spacer()
//                            ProgressView()
//                                .padding(.trailing, 5)
//                            Text("Loading more...") // Or just "Loading..."
//                                .font(.caption)
//                                .foregroundColor(.secondary)
//                            Spacer()
//                        }
//                        .padding(.vertical, 6)
//                         .padding(.horizontal, 12)
//                         .background(.ultraThickMaterial, in: Capsule())
//                         .shadow(radius: 2)
//                         .padding(.top, 8)
//                        Spacer()
//                    }
//                    .transition(.opacity.animation(.easeInOut))
//                 }
//            }
//            .navigationTitle("Spotify Album Search")
//            .searchable(text: $searchQuery,
//                        placement: .navigationBarDrawer(displayMode: .always),
//                        prompt: "Search Albums or Artists")
//            .onSubmit(of: .search) { // Run search when user taps 'Search' button
//                Task { await performDebouncedSearch(immediate: true) }
//            }
//            .task(id: searchQuery) { // Debounced search as user types
//                await performDebouncedSearch()
//            }
//            .onChange(of: searchQuery) { _ in
//                 // Clear error immediately when user types something new
//                 if currentError != nil {
//                     currentError = nil
//                 }
//             }
//        }
//    }
//
//    // Extracted List View for clarity (Unchanged)
//    private var albumList: some View {
//        List {
//            if let info = searchInfo {
//                SearchMetadataHeader(totalResults: info.total, limit: info.limit, offset: info.offset)
//                    .listRowSeparator(.hidden)
//                    .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 5, trailing: 16))
//            }
//
//            ForEach(displayedAlbums) { album in
//                NavigationLink(destination: AlbumDetailView(album: album)) {
//                    AlbumRow(album: album)
//                }
//                 .listRowSeparator(.hidden)
//                 .padding(.vertical, 4)
//                 .listRowInsets(EdgeInsets(top: 5, leading: 16, bottom: 5, trailing: 16)) // Consistent padding
//            }
//
//            // Optional: Add pagination logic/button here if searchInfo indicates more results
//        }
//        .listStyle(PlainListStyle()) // Use PlainListStyle for less default formatting
//    }
//
//    // Async search function (Added `immediate` flag for onSubmit)
//    private func performDebouncedSearch(immediate: Bool = false) async {
//        let trimmedQuery = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
//        guard !trimmedQuery.isEmpty else {
//            // Clear results instantly if query becomes empty
//            await MainActor.run {
//                 displayedAlbums = []
//                 searchInfo = nil
//                 isLoading = false
//                 currentError = nil // Ensure error is cleared too
//            }
//            return
//        }
//
//        if !immediate {
//            do { try await Task.sleep(for: .milliseconds(500)) } // Debounce duration
//            catch { print("Search task cancelled (debounce)."); return }
//        }
//
//         await MainActor.run { // Update loading state on main thread before API call
//             isLoading = true
//              // Don't clear the *current* error here, only on success or new typing
//         }
//
//        do {
//            // Reset offset for new search
//            let response = try await SpotifyAPIService.shared.searchAlbums(query: trimmedQuery, offset: 0)
//
//             // Check for cancellation *after* await (important!)
//             try Task.checkCancellation()
//
//             await MainActor.run { // Ensure UI updates are on main thread
//                 displayedAlbums = response.albums.items
//                 searchInfo = response.albums
//                 currentError = nil // <<< Clear error on successful search
//                 isLoading = false // <<< Stop loading on success
//             }
//
//        } catch is CancellationError {
//            print("Search task cancelled (during/after API call).")
//            // Don't change loading state here, might still be processing if cancelled late
//             await MainActor.run { isLoading = false } // Ensure loading stops if cancelled
//        } catch let apiError as SpotifyAPIError {
//            print("❌ API Error: \(apiError.localizedDescription)")
//             await MainActor.run {
//                 displayedAlbums = [] // Clear results on error
//                 searchInfo = nil
//                 currentError = apiError
//                 isLoading = false // <<< Stop loading on error
//             }
//        } catch {
//             print("❌ Unexpected Error: \(error.localizedDescription)")
//             await MainActor.run {
//                 displayedAlbums = [] // Clear results on error
//                 searchInfo = nil
//                 currentError = .networkError(error)
//                 isLoading = false // <<< Stop loading on error
//            }
//        }
//        // Ensure isLoading is false after any outcome (already handled in catch blocks now)
//        // Moved into mainactor blocks above
//    }
//}
//
//// MARK: - Enhanced Placeholder Views
//
//// Placeholder for Error States
//struct ErrorPlaceholderView: View {
//    let error: SpotifyAPIError
//    let retryAction: (() -> Void)?
//
//    var body: some View {
//        VStack(spacing: 15) {
//            Image(systemName: iconName) // Dynamic Icon
//                .font(.system(size: 50))
//                .foregroundColor(.orange) // Keep consistent error color
//
//            Text("Search Error")
//                .font(.title2.weight(.semibold))
//
//            Text(errorMessage) // Dynamic Message
//                .font(.callout)
//                .foregroundColor(.secondary)
//                .multilineTextAlignment(.center)
//                .padding(.horizontal)
//
//            // Show retry button unless it's a token error (user needs to fix config)
////            if error != .invalidToken, let retryAction = retryAction {
////                Button("Retry", action: retryAction)
////                    .buttonStyle(.borderedProminent)
////                    .tint(.orange) // Match icon color
////                    .padding(.top)
////            }
//        }
//        .padding()
//    }
//
//    // Determine icon and message based on the error type
//    private var iconName: String {
//        switch error {
//        case .invalidToken:
//            return "key.slash"
//        case .networkError:
//            return "wifi.exclamationmark"
//        case .invalidResponse, .decodingError, .missingData:
//            return "exclamationmark.triangle.fill"
//        case .invalidURL:
//            return "link.badge.plus" // Should ideally not happen w/ components
//        }
//    }
//
//    private var errorMessage: String {
//        switch error {
//        case .invalidToken:
//            return "Authentication failed. Please check your Spotify API token configuration."
//        case .networkError:
//            return "Could not connect to the network. Please check your internet connection and try again."
//        case .invalidResponse(let code, _):
//             if (500...599).contains(code) {
//                 return "The Spotify server encountered an issue (Code: \(code)). Please try again later."
//             } else {
//                  return "Received an unexpected response from the server (Code: \(code)). Please try again."
//             }
//        case .decodingError:
//            return "Failed to understand the response from the server. This might be a temporary issue."
//        default:
//            return error.localizedDescription // Fallback for other specific errors
//        }
//    }
//}
//
//// Placeholder for Empty States (Initial and No Results)
//struct EmptyStatePlaceholderView: View {
//    let searchQuery: String
//
//    var body: some View {
//        VStack(spacing: 15) {
////            Image(systemName: iconName)
////                .font(.system(size: 50))
////                .foregroundColor(.secondary)
////                .padding(.bottom, 5)
//            Image(iconName)
//                .resizable()
//                .aspectRatio(contentMode: .fit) // Fill available space
//                .frame(height: 200) // Fixed height for banner
//                .clipped() // Clip overflow
//
//            Text(title)
//                .font(.title2.weight(.semibold))
//
//            Text(message)
//                .font(.callout)
//                .foregroundColor(.secondary)
//                .multilineTextAlignment(.center)
//                .padding(.horizontal)
//        }
//        .padding()
//    }
//
//     private var isInitialState: Bool { searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
//
//     private var iconName: String {
//         //isInitialState ? "music.note.list.select" : "magnifyingglass"
//         isInitialState ? "My-meme-microphone" :  "My-meme-orange_2"
//        
//     }
//
//     private var title: String {
//         isInitialState ? "Spotify Search" : "No Results Found"
//     }
//
//     private var message: String {
//          if isInitialState {
//               return "Enter an album or artist name in the search bar above to find music."
//          } else {
//              // Use markdown for bolding the query
//               let markdownQuery = try? AttributedString(markdown: "No albums found matching **\"\(searchQuery)\"**. \nTry different keywords or check spelling.")
//               return markdownQuery?.description ?? // Fallback if markdown fails
//                   "No albums found matching \"\(searchQuery)\".\nTry different keywords or check spelling."
//          }
//     }
//}
//
//// MARK: - Other Supporting Views (Unchanged)
//// ... (ErrorView - Deprecated but kept for reference if needed, SearchMetadataHeader, AlbumRow, AlbumImageView, DetailItem) ...
//// Deprecated Error View Helper - Replaced by ErrorPlaceholderView
//// struct ErrorView: View { ... }
//
//struct SearchMetadataHeader: View {
//    let totalResults: Int
//    let limit: Int
//    let offset: Int
//
//    var body: some View {
//        HStack {
//            Text("Total: \(totalResults)")
//            Spacer()
//            if totalResults > limit {
//                Text("Showing \(offset + 1)-\(min(offset + limit, totalResults))")
//            }
//        }
//        .font(.caption)
//        .foregroundStyle(.secondary)
//        .padding(.bottom, 5) // Ensure some space below header
//    }
//}
//
//struct AlbumRow: View {
//    let album: AlbumItem
//
//    var body: some View {
//        HStack(alignment: .center, spacing: 15) {
//             AlbumImageView(url: album.listImageURL)
//                 .frame(width: 60, height: 60)
//                 .clipShape(RoundedRectangle(cornerRadius: 6))
//                 .shadow(color: .black.opacity(0.1), radius: 3, x: 1, y: 1)
//
//             VStack(alignment: .leading, spacing: 4) {
//                 Text(album.name)
//                     .font(.headline)
//                     .lineLimit(2)
//
//                 Text(album.formattedArtists)
//                     .font(.subheadline)
//                     .foregroundColor(.secondary)
//                     .lineLimit(1)
//
//                HStack(spacing: 8) {
//                     Text(album.album_type.capitalized)
//                         .font(.caption.weight(.medium))
//                         .padding(.horizontal, 8)
//                         .padding(.vertical, 3)
//                         .background(.quaternary, in: Capsule())
//                         .foregroundStyle(.secondary)
//                    Text("•")
//                    Text(album.formattedReleaseDate())
//                        .font(.caption)
//                        .foregroundColor(.gray)
//                    Text("• \(album.total_tracks) tracks")
//                         .font(.caption)
//                         .foregroundColor(.gray)
//                     Spacer() // Pushes content left
//                 }
//                 .padding(.top, 2) // Small space above tags/date
//             }
//             Spacer() // Ensures VStack takes available width
//        }
//         // Removed extra padding/background from here, handle in listRowInsets
//    }
//}
//
//struct AlbumImageView: View {
//    let url: URL?
//
//    var body: some View {
//        AsyncImage(url: url) { phase in
//            switch phase {
//            case .empty:
//                ZStack {
//                    Rectangle().fill(.ultraThickMaterial) // Placeholder bg
//                    ProgressView()
//                }
//            case .success(let image):
//                image.resizable().scaledToFit() // Maintain aspect ratio
//            case .failure:
//                ZStack {
//                     Rectangle().fill(.ultraThickMaterial)
//                     Image(systemName: "photo.fill")
//                         .resizable()
//                         .scaledToFit()
//                         .foregroundStyle(.secondary)
//                         .padding(10) // Padding around icon
//                }
//            @unknown default:
//                 ZStack {
//                     Rectangle().fill(.ultraThickMaterial)
//                     Image(systemName: "questionmark.diamond.fill")
//                         .resizable()
//                         .scaledToFit()
//                         .foregroundStyle(.secondary)
//                         .padding(10)
//                 }
//            }
//        }
//    }
//}
//
//struct DetailItem: View {
//    let label: String
//    let value: String
//
//    var body: some View {
//        HStack(alignment: .top) {
//            Text(label)
//                .font(.caption.weight(.medium)) // Make label slightly bolder
//                .foregroundColor(.secondary)
//                .frame(width: 100, alignment: .trailing) // Align labels consistently
//                .padding(.trailing, 5)
//            Text(value)
//                .font(.callout) // Use callout for value
//                .frame(maxWidth: .infinity, alignment: .leading) // Allow value to wrap
//        }
//        .padding(.vertical, 2) // Less vertical padding
//    }
//}
//
//// MARK: - Album Detail View and Sub-Components (Unchanged)
//// ... (AlbumDetailView, AlbumHeaderView, SpotifyEmbedPlayerView, TracksSectionView, TrackRowView, ExternalLinkButton) ...
//struct AlbumDetailView: View {
//    let album: AlbumItem
//
//    // State for fetched tracks
//    @State private var tracks: [Track] = []
//    @State private var isLoadingTracks: Bool = false
//    @State private var trackFetchError: SpotifyAPIError? = nil
//
//    // State for playback
//    @State private var selectedTrackUri: String? = nil
//    @StateObject private var playbackState = SpotifyPlaybackState() // State object for the player
//
//    @Environment(\.openURL) var openURL
//
//    var body: some View {
//        // Using List for better scroll performance and dividers
//        List {
//             // --- Album Header Section ---
//             Section {
//                 AlbumHeaderView(album: album)
//             }
//             .listRowInsets(EdgeInsets()) // Remove default insets
//             .listRowSeparator(.hidden)
//             .listRowBackground(Color.clear) // Remove default background
//
//             // --- Player Section (Conditional) ---
//             if let uriToPlay = selectedTrackUri {
//                 Section {
//                     SpotifyEmbedPlayerView(
//                         playbackState: playbackState,
//                         spotifyUri: uriToPlay
//                     )
//                 }
//                 .listRowSeparator(.hidden)
//                 .listRowInsets(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0)) // Control player spacing
//                 .transition(.opacity.combined(with: .scale(scale: 0.95, anchor: .top))) // Subtle animation
//             }
//
//             // --- Tracks Section ---
//              Section {
//                 TracksSectionView(
//                     tracks: tracks,
//                     isLoading: isLoadingTracks,
//                     error: trackFetchError,
//                     selectedTrackUri: $selectedTrackUri, // Pass binding
//                     retryAction: { Task { await fetchTracks() } }
//                 )
//             } header: {
//                  // Section header remains visible
//                  Text("Tracks")
//                    .font(.title3.weight(.semibold))
//                    .padding(.bottom, 5) // Add space below header
//             }
//             .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)) // No extra padding around tracks
//
//             // --- External Link Section ---
//             if let spotifyURL = URL(string: album.external_urls.spotify ?? "") {
//                     Section{
//                     ExternalLinkButton(url: spotifyURL)
//                 }
//                 .listRowInsets(EdgeInsets(top: 15, leading: 20, bottom: 15, trailing: 20)) // Give button room
//                 .listRowSeparator(.hidden)
//              }
//        }
//        .listStyle(.plain) // Use plain style for more control
//        .navigationTitle(album.name)
//        .navigationBarTitleDisplayMode(.inline)
//        .task { await fetchTracks() } // Use .task for async work on view appear
//          .animation(.easeInOut, value: selectedTrackUri) // Animate changes related to selection
//          .refreshable { // Allow pull-to-refresh for tracks
//               await fetchTracks(forceReload: true)
//          }
//    }
//
//    // Function to fetch tracks (Modified to allow forced reload)
//    private func fetchTracks(forceReload: Bool = false) async {
//        // Fetch only once unless forced or previous attempt failed
//        guard forceReload || tracks.isEmpty || trackFetchError != nil else {
//             print("Tracks already loaded and no force reload requested.")
//             return
//         }
//
//        await MainActor.run { // Update UI before fetch
//             isLoadingTracks = true
//             trackFetchError = nil // Clear previous error on retry/reload
//        }
//
//        do {
//            print("Fetching tracks for album ID: \(album.id)")
//            let response = try await SpotifyAPIService.shared.getAlbumTracks(albumId: album.id)
//
//            // Check for cancellation after await
//            try Task.checkCancellation()
//
//            await MainActor.run {
//                 self.tracks = response.items
//                 self.isLoadingTracks = false // Stop loading on success
//                 print("Successfully fetched \(response.items.count) tracks.")
//            }
//        } catch is CancellationError {
//             print("Track fetch task cancelled.")
//              await MainActor.run { isLoadingTracks = false } // Stop loading if cancelled
//        } catch let apiError as SpotifyAPIError {
//            print("❌ Error fetching tracks: \(apiError.localizedDescription)")
//            await MainActor.run {
//                 self.trackFetchError = apiError
//                 self.isLoadingTracks = false // Stop loading on error
//                 self.tracks = [] // Clear tracks on error
//            }
//        } catch {
//            print("❌ Unexpected error fetching tracks: \(error.localizedDescription)")
//            await MainActor.run {
//                 self.trackFetchError = .networkError(error)
//                 self.isLoadingTracks = false // Stop loading on error
//                 self.tracks = [] // Clear tracks on error
//            }
//        }
//    }
//}
//
//// MARK: - DetailView Sub-Components
//
//struct AlbumHeaderView: View {
//    let album: AlbumItem
//
//    var body: some View {
//        VStack(spacing: 16) {
//            AlbumImageView(url: album.bestImageURL)
//                .aspectRatio(1.0, contentMode: .fit) // Make it square
//                .clipShape(RoundedRectangle(cornerRadius: 8))
//                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
//                .padding(.horizontal, 40) // Adjust padding as needed
//                .padding(.bottom, 5) // Space below image
//
//            VStack(spacing: 4) {
//                Text(album.name)
//                    .font(.title2.weight(.bold))
//                    .multilineTextAlignment(.center)
//                Text("by \(album.formattedArtists)")
//                    .font(.headline)
//                    .foregroundColor(.secondary)
//                    .multilineTextAlignment(.center)
//                Text("\(album.album_type.capitalized) • \(album.formattedReleaseDate())")
//                    .font(.subheadline)
//                    .foregroundColor(.gray)
//            }
//            .padding(.horizontal)
//        }
//        .padding(.vertical, 20) // Add vertical padding to the header section
//    }
//}
//
//// Uses the state object passed from AlbumDetailView
//struct SpotifyEmbedPlayerView: View {
//   @ObservedObject var playbackState: SpotifyPlaybackState
//    let spotifyUri: String // The specific URI to play
//
//    var body: some View {
//        VStack {
//            SpotifyEmbedWebView( // Creates the actual WebView
//                 playbackState: playbackState,
//                 spotifyUri: spotifyUri
//             )
//             .frame(height: 85) // Standard embed height + a little buffer
//             .clipShape(RoundedRectangle(cornerRadius: 8)) // Clip the webview itself
//              // Optional: Add a subtle background or border
//             .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 8))
//             .padding(.horizontal) // Padding around the webview UI
//
//             // Display Playback State Info Below
//             HStack {
//                  // Combine Play/Pause state with current track URI for context
//                  if !playbackState.currentUri.isEmpty {
//                     let uriComponents = playbackState.currentUri.split(separator: ":")
//                     Text("\(uriComponents.count > 1 ? uriComponents[1].capitalized : "Track") \(playbackState.isPlaying ? "Playing" : "Paused")")
//                         .font(.caption)
//                         .foregroundColor(playbackState.isPlaying ? Color.green : Color.orange)
//                         .lineLimit(1)
//                  } else {
//                     Text("Player Idle")
//                         .font(.caption)
//                         .foregroundColor(.secondary)
//                  }
//
//                 Spacer()
//
//                 if playbackState.duration > 0 {
//                      // Show time progress only when duration is known
//                      Text("\(formatTime(playbackState.currentPosition)) / \(formatTime(playbackState.duration))")
//                          .font(.caption.monospacedDigit()) // Use monospaced for time
//                          .foregroundColor(.secondary)
//                 }
//             }
//             .padding(.horizontal)
//             .padding(.top, 4)
//             // Add minimal height to prevent layout collapse when playing state is missing
//             .frame(minHeight: 15)
//
//        } // End VStack
//        .onAppear {
//             print("SpotifyEmbedPlayerView Appeared for URI: \(spotifyUri)")
//          }
//         .onChange(of: spotifyUri) { newUri in
//             print("SpotifyEmbedPlayerView URI Changed to: \(newUri)")
//             // The WebView's updateUIView handles the actual loading change
//         }
//         .onChange(of: playbackState.isPlaying) { playing in
//              print("Playback state changed: \(playing ? "Playing" : "Paused")")
//         }
//    }
//
//     private func formatTime(_ time: Double) -> String {
//         let totalSeconds = max(0, Int(time)) // Ensure non-negative
//         let minutes = totalSeconds / 60
//         let seconds = totalSeconds % 60
//         return String(format: "%d:%02d", minutes, seconds)
//     }
//}
//
//struct TracksSectionView: View {
//    let tracks: [Track]
//    let isLoading: Bool
//    let error: SpotifyAPIError?
//    @Binding var selectedTrackUri: String? // Binding to update parent
//    let retryAction: () -> Void
//
//    var body: some View {
//        // No encompassing VStack needed if used directly in List Section
//        if isLoading {
//             HStack { // Center progress view within the list section area
//                Spacer()
//                ProgressView()
//                Text("Loading Tracks...")
//                    .foregroundColor(.secondary)
//                    .padding(.leading, 5)
//                Spacer()
//            }
//            .padding(.vertical, 20) // Give loading indicator space
//        } else if let error = error {
//             // Use the new ErrorPlaceholderView
//            ErrorPlaceholderView(error: error, retryAction: retryAction)
//                 .padding(.vertical, 20) // Give error view space
//        } else if tracks.isEmpty {
//            // Message for when tracks array is empty *after* successful load
//             Text("No tracks found for this album.")
//                 .foregroundColor(.secondary)
//                 .frame(maxWidth: .infinity, alignment: .center)
//                 .padding(.vertical, 20)
//        } else {
//            // Use ForEach directly within the List Section
//            ForEach(tracks) { track in
//                TrackRowView(
//                    track: track,
//                    isSelected: track.uri == selectedTrackUri // Check if this track is the selected one
//                )
//                .contentShape(Rectangle()) // Make the whole row tappable
//                .onTapGesture {
//                    // Update the selected URI - animation handled by parent
//                    selectedTrackUri = track.uri
//                }
//                 // Apply background highlight directly or via listRowBackground
//                 .listRowBackground(track.uri == selectedTrackUri ? Color.accentColor.opacity(0.15) : Color.clear)
//           }
//        }
//    }
//}
//
//// Row for displaying a single track (Added subtle improvements)
//struct TrackRowView: View {
//    let track: Track
//    let isSelected: Bool
//
//    var body: some View {
//        HStack(spacing: 12) { // Slightly more spacing
//            Text("\(track.track_number)")
//                .font(.caption.monospacedDigit().weight(.medium)) // Slightly bolder track number
//                .foregroundColor(.secondary)
//                .frame(width: 20, alignment: .center) // Centered track number
//
//            VStack(alignment: .leading, spacing: 3) { // Adjusted spacing
//                Text(track.name)
//                    .font(.body)
//                    .lineLimit(1)
//                     // Use accent color directly for selected track name
//                    .foregroundColor(isSelected ? .accentColor : .primary)
//
//                Text(track.formattedArtists)
//                    .font(.caption)
//                    .foregroundColor(.secondary)
//                    .lineLimit(1)
//            }
//
//            Spacer() // Pushes duration and icon to the right
//
//            Text(track.formattedDuration)
//                .font(.caption.monospacedDigit())
//                .foregroundColor(.secondary)
//                .padding(.trailing, 5) // Space before icon
//
//            Image(systemName: isSelected ? "speaker.wave.2.fill" : "play.circle")
//                 .foregroundColor(isSelected ? .accentColor : .secondary)
//                 .font(.title3)
//                 .frame(width: 25, height: 25)  // Ensure consistent icon size
//                 .animation(.easeInOut(duration: 0.2), value: isSelected) // Animate icon change
//        }
//        .padding(.vertical, 10) // More vertical padding for tap target
//         .padding(.horizontal) // Add horizontal padding within the row
//    }
//}
//
//struct ExternalLinkButton: View {
//     let url: URL
//     @Environment(\.openURL) var openURL
//
//     var body: some View {
//         Button {
//              print("Attempting to open URL: \(url)")
//              openURL(url) { accepted in
//                   if !accepted {
//                       print("Warning: URL could not be opened. Ensure Spotify app is installed or link is valid.")
//                       // Optionally show an alert to the user here
//                   }
//              }
//          } label: {
//             HStack {
//                 // Using a generic play icon, replace with Spotify logo if available
//                 Image(systemName: "link") // Changed to 'link' as it opens externally
//                 Text("View in Spotify App") // More specific text
//             }
//             .font(.headline)
//             .padding()
//             .frame(maxWidth: .infinity)
//             .background(Color.green.gradient) // Use gradient
//             .foregroundColor(.white)
//             .clipShape(Capsule()) // Use capsule shape
//             .shadow(color: .black.opacity(0.15), radius: 3, y: 2)
//         }
//         .buttonStyle(.plain) // Ensure background/foreground colors apply
//     }
//}
//
//// MARK: - Preview Providers (Updated for new placeholders)
//
//struct SpotifyAlbumListView_Previews: PreviewProvider {
//    static var previews: some View {
//        SpotifyAlbumListView()
////        Group {
//            // Initial Empty State
////            SpotifyAlbumListView(searchQuery: "")
////                .previewDisplayName("Initial Empty State")
////
////            // No Results State
////            SpotifyAlbumListView(searchQuery: "NonExistentAlbumXYZ", displayedAlbums: [], isLoading: false)
////                .previewDisplayName("No Results Empty State")
////
////             // Error State - Network
////             SpotifyAlbumListView(searchQuery: "Miles", displayedAlbums: [], isLoading: false, currentError: .networkError(URLError(.notConnectedToInternet)))
////                .previewDisplayName("Error State (Network)")
////
////            // Error State - Token
////            SpotifyAlbumListView(searchQuery: "Miles", displayedAlbums: [], isLoading: false, currentError: .invalidToken)
////                 .previewDisplayName("Error State (Token)")
////
////              // Error State - Server
////              SpotifyAlbumListView(searchQuery: "Miles", displayedAlbums: [], isLoading: false, currentError: .invalidResponse(500, "Internal Server Error"))
////                  .previewDisplayName("Error State (Server)")
////
////             // Loading State
////             SpotifyAlbumListView(searchQuery: "Loading...", displayedAlbums: [], isLoading: true)
////                 .previewDisplayName("Loading State")
////
////             // Example with results (using previous mock data for brevity)
////             SimulatedResultsView()
////                 .previewDisplayName("With Mock Results")
//
////        }
//    }
//
//     // Helper view to provide mock data for results preview
//     struct SimulatedResultsView: View {
//         // Reusing mock data setup from previous previews
//         static let mockArtist = Artist(id: "artist1", external_urls: nil, href: "", name: "Miles Davis Mock", type: "artist", uri: "")
//         static let mockImage = SpotifyImage(height: 64, url: "https://i.scdn.co/image/ab67616d000048517ab89c25093ea3787b1995b4", width: 64)
//         static let mockAlbumItem = AlbumItem(id: "album1", album_type: "album", total_tracks: 5, available_markets: ["US"], external_urls: ExternalUrls(spotify: ""), href: "", images: [mockImage], name: "Kind of Blue Mock", release_date: "1959-08-17", release_date_precision: "day", type: "album", uri: "spotify:album:1weenld61qoidwYuZ1GESA", artists: [mockArtist])
//         static let mockAlbumItem2 = AlbumItem(id: "album2", album_type: "album", total_tracks: 8, available_markets: ["US"], external_urls: ExternalUrls(spotify: ""), href: "", images: [mockImage], name: "Workin' Mock", release_date: "1959", release_date_precision: "year", type: "album", uri: "spotify:album:7buLIJn2VuqsVORghMEvli", artists: [mockArtist])
//         static let mockInfo = Albums(href: "", limit: 2, next: nil, offset: 0, previous: nil, total: 20, items: []) // Example info
//
//          var body: some View {
////              SpotifyAlbumListView(
////                  searchQuery: "Miles",
////                  displayedAlbums: [Self.mockAlbumItem, Self.mockAlbumItem2],
////                  searchInfo: Self.mockInfo
////              )
//              SpotifyAlbumListView()
//          }
//     }
//}
//
//struct AlbumDetailView_Previews: PreviewProvider {
//    static let mockArtist = Artist(id: "artist1", external_urls: nil, href: "", name: "Miles Davis Mock", type: "artist", uri: "")
//    static let mockImage = SpotifyImage(height: 640, url: "https://i.scdn.co/image/ab67616d0000b2737ab89c25093ea3787b1995b4", width: 640)
//    static let mockAlbum = AlbumItem(id: "1weenld61qoidwYuZ1GESA", album_type: "album", total_tracks: 5, available_markets: ["US", "GB"], external_urls: ExternalUrls(spotify: "https://open.spotify.com/album/1weenld61qoidwYuZ1GESA"), href: "", images: [mockImage], name: "Kind Of Blue (Preview)", release_date: "1959-08-17", release_date_precision: "day", type: "album", uri: "spotify:album:1weenld61qoidwYuZ1GESA", artists: [mockArtist])
//     static let mockTracks = [
//         Track(id: "track1", artists: [mockArtist], disc_number: 1, duration_ms: 200000, explicit: false, external_urls: nil, href: "", name: "So What (Mock)", preview_url: nil, track_number: 1, type: "track", uri: "spotify:track:4vLYewWIvqHfKtJDk8c8tq"),
//         Track(id: "track2", artists: [mockArtist], disc_number: 1, duration_ms: 180000, explicit: false, external_urls: nil, href: "", name: "Freddie Freeloader (Mock)", preview_url: nil, track_number: 2, type: "track", uri: "spotify:track:3mGgwVllZm11G9HNCrWr3I"),
//         Track(id: "track3", artists: [mockArtist], disc_number: 1, duration_ms: 210000, explicit: false, external_urls: nil, href: "", name: "Blue in Green (Mock)", preview_url: nil, track_number: 3, type: "track", uri: "spotify:track:0aWMVrwxPNYkKmFthzmpRi")
//     ]
//
//    static var previews: some View {
//        NavigationView {
////            AlbumDetailView(
////                album: mockAlbum,
////                tracks: mockTracks,
////                selectedTrackUri: mockTracks[1].uri
////            )
//            AlbumDetailView(
//                album: mockAlbum
//            )
//        }
//        .previewDisplayName("Detail (Loaded Tracks)")
//
//        NavigationView {
//            //AlbumDetailView(album: mockAlbum, isLoadingTracks: true)
//            AlbumDetailView(album: mockAlbum)
//        }
//         .previewDisplayName("Detail (Loading Tracks)")
//
//         NavigationView {
//             //AlbumDetailView(album: mockAlbum, trackFetchError: .networkError(URLError(.timedOut)))
//             AlbumDetailView(album: mockAlbum)
//         }
//          .previewDisplayName("Detail (Track Fetch Error)")
//    }
//}
//
//// MARK: - App Entry Point (Unchanged)
//@main
//struct SpotifyEmbedIntegrationApp: App {
//     init() {
//          // Basic check to remind about the token during development startup
//          if placeholderSpotifyToken == "YOUR_SPOTIFY_BEARER_TOKEN_HERE" {
//              print("⚠️ WARNING: Spotify Bearer Token is set to the placeholder. API calls will fail.")
//              print("➡️ Please replace 'YOUR_SPOTIFY_BEARER_TOKEN_HERE' in the code with a valid token for testing.")
//          }
//     }
//
//    var body: some Scene {
//        WindowGroup {
//            SpotifyAlbumListView() // Start with the search list view
//        }
//    }
//}
