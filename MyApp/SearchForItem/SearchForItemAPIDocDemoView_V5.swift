////
////  SearchForItemAPIDocDemoView_V5.swift
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
//// MARK: - Data Models (Album Search - Unchanged)
//
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
//// MARK: - Track Models (Needed for Album Tracks Endpoint)
//
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
//// MARK: - Spotify Embed WebView and Related Code (Copied from User Input)
//
//// MARK: - Playback State Observable for SpotifyEmbedWebView
//
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
//            print("Spotify Embed Native: JS Message received - \(message.body)")
//
//            // Check if it's the 'ready' signal from the API script
//            if let body = message.body as? String, body == "ready" {
//                print("Spotify Embed Native: Spotify IFrame API is ready.")
//                isApiReady = true
//                // Important: Create the controller *after* the API is ready
//                createSpotifyController(with: parent.spotifyUri)
//            }
//            // Check if it's a dictionary containing an event
//            else if let bodyDict = message.body as? [String: Any],
//                      let event = bodyDict["event"] as? String
//            {
//                switch event {
//                case "controllerCreated":
//                    print("Spotify Embed Native: Embed controller successfully created by JS.")
//                    // No specific state update needed here unless required elsewhere
//
//                case "playbackUpdate":
//                    print("Spotify Embed Native: Received playback update.")
//                    if let data = bodyDict["data"] as? [String: Any] {
//                        // Update the ObservableObject on the main thread
//                        DispatchQueue.main.async {
//                            if let isPaused = data["paused"] as? Bool {
//                                self.parent.playbackState.isPlaying = !isPaused
//                            }
//                            if let posMs = data["position"] as? Double {
//                                self.parent.playbackState.currentPosition = posMs / 1000.0 // Convert ms to s
//                            }
//                            if let durMs = data["duration"] as? Double {
//                                self.parent.playbackState.duration = durMs / 1000.0 // Convert ms to s
//                            }
//                        }
//                    } else {
//                         print("Spotify Embed Native: Playback update data missing or invalid format.")
//                    }
//
//                case "error":
//                    if let msg = bodyDict["message"] as? String {
//                        print("⚠️ Spotify Embed JS Error: \(msg)")
//                        // Potentially surface this error to the user
//                    } else {
//                         print("⚠️ Spotify Embed JS Error: Received unknown error format.")
//                    }
//                default:
//                    print("Spotify Embed Native: Received unknown event type: \(event)")
//                }
//            } else {
//                 print("Spotify Embed Native: Received message in unexpected format: \(message.body)")
//            }
//        }
//
//        // --- Helper to Execute JS for Creating the Embed Controller ---
//        private func createSpotifyController(with initialUri: String) {
//             guard let webView = webView else {
//                  print("Spotify Embed Native: WebView is nil, cannot create controller.")
//                  return
//             }
//             guard isApiReady else {
//                  print("Spotify Embed Native: API not ready, deferring controller creation.")
//                  return
//             }
//            // Only initialize if it hasn't been initialized yet or if the URI changed *before* ready
//            guard lastLoadedUri == nil else {
//                print("Spotify Embed Native: Controller likely already initializing or created.")
//                // If the initial URI changed between view creation and API ready, load it now
//                if initialUri != lastLoadedUri {
//                    loadUri(initialUri)
//                }
//                return
//            }
//
//             print("Spotify Embed Native: Attempting to create controller for URI: \(initialUri)")
//             lastLoadedUri = initialUri // Mark as attempting to load/create
//
//            // JavaScript to find the div and create the Spotify controller
//            let script = """
//            const element = document.getElementById('embed-iframe');
//            if (!element) {
//                console.error('Spotify Embed JS: Could not find element with id embed-iframe!');
//                if (window.webkit && window.webkit.messageHandlers.spotifyController) {
//                    window.webkit.messageHandlers.spotifyController.postMessage({ event: 'error', message: 'HTML element embed-iframe not found' });
//                }
//            } else if (!window.IFrameAPI) {
//                 console.error('Spotify Embed JS: IFrameAPI is not loaded yet!');
//                 if (window.webkit && window.webkit.messageHandlers.spotifyController) {
//                     window.webkit.messageHandlers.spotifyController.postMessage({ event: 'error', message: 'Spotify IFrame API not loaded' });
//                 }
//            } else {
//                console.log('Spotify Embed JS: Found element and IFrameAPI. Creating controller...');
//                const options = { uri: '\(initialUri)', width: '100%', height: '100%' }; // Ensure height is set if needed visually
//
//                // Define the callback function for when the controller is created
//                const callback = (controller) => {
//                    console.log('Spotify Embed JS: Controller created successfully.');
//                    window.embedController = controller; // Store globally in JS window
//
//                    // Notify native code that the controller is created
//                    if (window.webkit && window.webkit.messageHandlers.spotifyController) {
//                        window.webkit.messageHandlers.spotifyController.postMessage({ event: 'controllerCreated' });
//                    }
//
//                    // --- Add Listeners ---
//                    controller.addListener('ready', () => {
//                        console.log('Spotify Embed JS: Controller Ready event received.');
//                        // You could post another message here if needed
//                    });
//
//                    controller.addListener('playback_update', e => {
//                        // console.log('Spotify Embed JS: Playback update:', e.data); // Debugging
//                        if (window.webkit && window.webkit.messageHandlers.spotifyController) {
//                            window.webkit.messageHandlers.spotifyController.postMessage({ event: 'playbackUpdate', data: e.data });
//                        } else {
//                            // console.error('Spotify Embed JS: Native message handler not found for playback_update.');
//                        }
//                    });
//
//                     // Add other listeners as needed (e.g., 'account_error', 'autoplay_failed')
//                    controller.addListener('account_error', (e) => {
//                        console.warn('Spotify Embed JS: Account Error:', e.data);
//                        if (window.webkit && window.webkit.messageHandlers.spotifyController) {
//                            window.webkit.messageHandlers.spotifyController.postMessage({ event: 'error', message: 'Account Error: ' + (e.data?.message ?? 'Unknown') });
//                        }
//                    });
//                     controller.addListener('autoplay_failed', () => {
//                         console.warn('Spotify Embed JS: Autoplay failed');
//                         if (window.webkit && window.webkit.messageHandlers.spotifyController) {
//                             window.webkit.messageHandlers.spotifyController.postMessage({ event: 'error', message: 'Autoplay failed' });
//                         }
//                     });
//
//                };
//
//                // --- Create the Controller ---
//                try {
//                   window.IFrameAPI.createController(element, options, callback);
//                } catch (e) {
//                    console.error('Spotify Embed JS: Error calling createController:', e);
//                    if (window.webkit && window.webkit.messageHandlers.spotifyController) {
//                        window.webkit.messageHandlers.spotifyController.postMessage({ event: 'error', message: 'JS exception during createController: ' + e.message });
//                    }
//                   // Reset lastLoadedUri if creation failed fundamentally before callback
//                   // Note: Might be overly cautious, callback might handle internal errors
//                   self.parent.lastLoadedUri = nil; // Use parent property
//                }
//            }
//            """
//            // Execute the JavaScript
//            webView.evaluateJavaScript(script) { result, error in
//                if let error = error {
//                    print("⚠️ Spotify Embed Native: Error evaluating JS for controller creation: \(error.localizedDescription)")
//                    // Consider resetting state if JS itself failed
//                    self.lastLoadedUri = nil // Reset if JS execution failed
//                } else {
//                     print("Spotify Embed Native: JS for controller creation evaluated. Result: \(result ?? "nil")")
//                }
//            }
//        }
//
//        // --- Helper to Execute JS for Loading a New URI ---
//        func loadUri(_ uri: String) {
//            guard let webView = webView else {
//                print("Spotify Embed Native: WebView is nil, cannot load URI.")
//                return
//            }
//            guard isApiReady else {
//                print("Spotify Embed Native: API not ready, cannot load URI \(uri). Will load when ready.")
//                // No need to do anything else, updateUIView will call this again when ready
//                return
//            }
//            guard lastLoadedUri != uri else {
//                 print("Spotify Embed Native: URI \(uri) is already loaded or being loaded.")
//                 return
//            }
//            // Prevent loading if controller isn't even created yet
//            guard lastLoadedUri != nil else {
//                 print("Spotify Embed Native: Controller not yet created, cannot load URI \(uri). It will be loaded on creation.")
//                 return
//            }
//
//            print("Spotify Embed Native: Attempting to load URI: \(uri)")
//            lastLoadedUri = uri // Update the tracker *before* calling JS
//
//            let script = """
//            if (window.embedController) {
//                console.log('Spotify Embed JS: Loading URI: \(uri)');
//                window.embedController.loadUri('\(uri)');
//            } else {
//                console.error('Spotify Embed JS: embedController not found when trying to load URI.');
//                 if (window.webkit && window.webkit.messageHandlers.spotifyController) {
//                     window.webkit.messageHandlers.spotifyController.postMessage({ event: 'error', message: 'JS embedController not found during loadUri' });
//                 }
//            }
//            """
//            webView.evaluateJavaScript(script) { _, error in
//                if let error = error {
//                    print("⚠️ Spotify Embed Native: Error evaluating JS for loading URI \(uri): \(error.localizedDescription)")
//                    // Optionally revert lastLoadedUri if the call failed? Depends on desired behavior.
//                    // self.lastLoadedUri = self.parent.spotifyUri // Revert to the parent's intended URI?
//                } else {
//                     print("Spotify Embed Native: JS for loading URI \(uri) evaluated.")
//                }
//            }
//        }
//
//        // --- WKUIDelegate Method (Optional but good practice) ---
//        // Handle simple JavaScript alert() calls from the web page
//        func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
//            print("Spotify Embed Received JS Alert: \(message)")
//            // In a real app, you might show a native alert view.
//            // Here, we just print it and complete immediately.
//            completionHandler()
//        }
//
//         // Add stubs for other WKUIDelegate methods if needed (confirm panels, prompts)
//    }
//
//    // --- Helper to Generate the Initial HTML for the WebView ---
//    private func generateHTML() -> String {
//        // Basic HTML structure with viewport settings, CSS for transparent background,
//        // the container div, and the script to load the Spotify IFrame API.
//        // The `window.onSpotifyIframeApiReady` function is the entry point when the Spotify API script loads.
//         """
//        <!DOCTYPE html>
//        <html>
//        <head>
//            <meta charset="utf-8">
//            <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
//            <style>
//                /* Basic styling for the body and the iframe container */
//                body { margin: 0; padding: 0; background-color: transparent; overflow: hidden; }
//                #embed-iframe {
//                    width: 100%;
//                    /* Let SwiftUI control the height */
//                    height: 100%; /* Take full height of WKWebView frame */
//                    box-sizing: border-box;
//                    display: block;         /* Avoid extra space below div */
//                }
//            </style>
//        </head>
//        <body>
//            <!-- The div where the Spotify player will be embedded -->
//            <div id="embed-iframe"></div>
//
//            <!-- Load the Spotify IFrame Player API asynchronously -->
//            <script src="https://open.spotify.com/embed/iframe-api/v1" async></script>
//
//            <script>
//                // This function will be called once the Spotify API script is loaded and ready
//                window.onSpotifyIframeApiReady = (IFrameAPI) => {
//                    console.log('Spotify Embed JS: IFrame API Loaded.');
//                    // Store the API object globally or pass it as needed
//                    window.IFrameAPI = IFrameAPI;
//                    // *** IMPORTANT: Send a message to the native app (Coordinator) ***
//                    // Check if the native message handler exists before posting
//                    if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.spotifyController) {
//                        console.log('Spotify Embed JS: Posting "ready" message to native app.');
//                        // Post a simple string or a structured message
//                        window.webkit.messageHandlers.spotifyController.postMessage("ready");
//                    } else {
//                        console.error('Spotify Embed JS: Native message handler (spotifyController) not found!');
//                        // Cannot communicate readiness back to Swift
//                    }
//                };
//
//                // --- Optional: Add error handling for script loading itself ---
//                const scriptTag = document.querySelector('script[src*="iframe-api"]');
//                if (scriptTag) {
//                    scriptTag.onerror = (event) => {
//                         console.error('Spotify Embed JS: Failed to load the Spotify API script.', event);
//                         if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.spotifyController) {
//                              window.webkit.messageHandlers.spotifyController.postMessage({ event: 'error', message: 'Failed to load Spotify API script' });
//                         }
//                    };
//                } else {
//                    console.warn('Spotify Embed JS: Could not find the Spotify API script tag to attach onerror handler.');
//                }
//            </script>
//        </body>
//        </html>
//        """
//    }
//}
//
//// MARK: - API Service Helper
//
//// !!! --- CRITICAL SECURITY WARNING --- !!!
//// Replace this placeholder with a securely obtained token via OAuth 2.0 flow.
//// DO NOT ship an app with a hardcoded token.
//let placeholderSpotifyToken = "YOUR_SPOTIFY_BEARER_TOKEN_HERE" // <--- Replace for testing ONLY
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
//                print("✅ Successfully decoded response of type \(T.self)")
//                return decodedObject
//            } catch {
//                print("❌ Error: Failed to decode JSON for type \(T.self).")
//                if let jsonString = String(data: data, encoding: .utf8) {
//                    print("📄 Received JSON String: \(jsonString)")
//                }
//                // Print detailed decoding error
//                if let decodingError = error as? DecodingError {
//                    print("🔧 Decoding Error Details: \(decodingError)")
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
//// MARK: - Main List View with Search (Largely Unchanged)
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
//                 // Simplified conditional logic
//                 Group {
//                     if isLoading && displayedAlbums.isEmpty {
//                         ProgressView("Searching...") // Show only if loading initially
//                     } else if let error = currentError {
//                         ErrorView(error: error) {
//                             // Retry Action
//                             Task { await performDebouncedSearch() }
//                         }
//                     } else if displayedAlbums.isEmpty {
//                         Text(searchQuery.isEmpty ? "Enter a search term..." : "No results for \"\(searchQuery)\"")
//                        //                             .foregroundColor(.secondary)
//                        //                             .multilineTextAlignment(.center)
//                        //                             .padding()
//                         Image("My-meme-orange_2")
//                             .resizable()
//                             .aspectRatio(contentMode: .fit) // Fill available space
//                             .frame(height: 200) // Fixed height for banner
//                             .clipped() // Clip overflow
////                             .overlay( // Gradient overlay for text readability
////                                 Text("Image unavailable").foregroundStyle(.secondary)
//// //                                LinearGradient(
//// //                                    gradient: Gradient(colors: [.clear, .black.opacity(0.6)]),
//// //                                    startPoint: .center,
//// //                                    endPoint: .bottom
//// //                                )
////                             )
//                             .cornerRadius(8) // Optional corner radius
//                     } else {
//                         albumList // Extracted list view
//                     }
//                 }
//                 .frame(maxWidth: .infinity, maxHeight: .infinity) // Center placeholders
//                 .transition(.opacity.animation(.easeInOut)) // Smooth transitions
//
//                 // Separate overlay for ongoing loading indicator (doesn't hide list)
//                 if isLoading && !displayedAlbums.isEmpty {
//                     VStack {
//                         HStack {
//                             Spacer()
//                             ProgressView()
//                                 .padding(5)
//                             Text("Loading...")
//                                 .font(.caption)
//                                 .foregroundColor(.secondary)
//                             Spacer()
//                         }
//                         .padding(.vertical, 4)
//                         .background(.ultraThickMaterial, in: Capsule())
//                         .padding(.top, 5)
//                         Spacer()
//                     }
//                     .transition(.opacity.animation(.easeInOut))
//                 }
//            }
//            .navigationTitle("Spotify Album Search")
//            .searchable(text: $searchQuery,
//                        placement: .navigationBarDrawer(displayMode: .always),
//                        prompt: "Search Albums or Artists")
//            .task(id: searchQuery) { await performDebouncedSearch() }
//            .onChange(of: searchQuery) {
//                currentError = nil
//            } // Clear error on new search
//        }
//    }
//
//    // Extracted List View for clarity
//    private var albumList: some View {
//        List {
//            if let info = searchInfo {
//                SearchMetadataHeader(totalResults: info.total, limit: info.limit, offset: info.offset)
//                    .listRowSeparator(.hidden)
//                    .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 5, trailing: 16))
//            }
//
//            ForEach(displayedAlbums) { album in
//                // Navigate to the *updated* AlbumDetailView
//                NavigationLink(destination: AlbumDetailView(album: album)) {
//                    AlbumRow(album: album)
//                }
//                 // Enhance row appearance
//                 .listRowSeparator(.hidden)
//                 .padding(.vertical, 4)
//            }
//
//            // Optional: Add pagination loading indicator or button here
//        }
//        .listStyle(PlainListStyle())
//    }
//
//    // Async search function (Unchanged core logic, uses API service)
//    private func performDebouncedSearch() async {
//        let trimmedQuery = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
//        guard !trimmedQuery.isEmpty else {
//            displayedAlbums = []
//            isLoading = false
//            currentError = nil
//            searchInfo = nil
//            return
//        }
//
//        do { try await Task.sleep(for: .milliseconds(600)) } // Adjusted debounce
//        catch { print("Search task cancelled."); return }
//
//        isLoading = true
//        // Don't clear error immediately, only on success or new search
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
//                 currentError = nil // Clear error on success
//             }
//
//        } catch is CancellationError {
//            print("Search task cancelled after API call started.")
//            // Don't change loading state here, let it naturally resolve if needed
//        } catch let apiError as SpotifyAPIError {
//            print("❌ API Error: \(apiError.localizedDescription)")
//             await MainActor.run {
//                 displayedAlbums = []
//                 searchInfo = nil
//                 currentError = apiError
//             }
//        } catch {
//             print("❌ Unexpected Error: \(error.localizedDescription)")
//             await MainActor.run {
//                 displayedAlbums = []
//                 searchInfo = nil
//                 currentError = .networkError(error)
//            }
//        }
//         await MainActor.run { // Ensure loading state is updated on main thread
//            isLoading = false
//         }
//    }
//}
//
//// MARK: - Error View Helper
//struct ErrorView: View {
//    let error: SpotifyAPIError
//    let retryAction: (() -> Void)?
//
//    var body: some View {
//        VStack(spacing: 15) {
//            Image(systemName: "exclamationmark.triangle.fill")
//                .font(.system(size: 50))
//                .foregroundColor(.orange)
//            Text("Error")
//                .font(.title)
//            Text(error.localizedDescription)
//                .font(.callout)
//                .foregroundColor(.secondary)
//                .multilineTextAlignment(.center)
//                .padding(.horizontal)
//
//            if let retryAction = retryAction {
//                Button("Retry", action: retryAction)
//                    .buttonStyle(.borderedProminent)
//                    .padding(.top)
//            }
//        }
//        .padding()
//    }
//}
//
//// MARK: - Header View for Search Metadata (Unchanged)
//struct SearchMetadataHeader: View {
//    let totalResults: Int
//    let limit: Int
//    let offset: Int
//
//    var body: some View {
//        HStack {
//            Text("Total Results: \(totalResults)")
//                .foregroundStyle(.secondary)
//            Spacer()
//            // Display page info only if potentially paginated
//            if totalResults > limit {
//                Text("Showing \(offset + 1)-\(min(offset + limit, totalResults))")
//                    .foregroundStyle(.secondary)
//            }
//        }
//        .font(.caption)
//    }
//}
//
//// MARK: - View for a single row in the album list (Unchanged)
//struct AlbumRow: View {
//    let album: AlbumItem
//
//    var body: some View {
//        HStack(alignment: .center, spacing: 15) { // Center items vertically
//            AlbumImageView(url: album.listImageURL)
//                .frame(width: 60, height: 60) // Slightly larger image
//                .clipShape(RoundedRectangle(cornerRadius: 6))
//                .shadow(color: .black.opacity(0.1), radius: 3, x: 1, y: 1)
//
//            VStack(alignment: .leading, spacing: 4) {
//                Text(album.name)
//                    .font(.headline)
//                    .lineLimit(2) // Allow two lines for album name
//
//                Text(album.formattedArtists)
//                    .font(.subheadline)
//                    .foregroundColor(.secondary)
//                    .lineLimit(1)
//
//                HStack(spacing: 8) {
//                    Text(album.album_type.capitalized)
//                        .font(.caption.weight(.medium))
//                        .padding(.horizontal, 8)
//                        .padding(.vertical, 3)
//                        .background(.quaternary, in: Capsule()) // Use semantic background
//                        .foregroundStyle(.secondary)
//
//                    Text("•") // Separator
//
//                    Text(album.formattedReleaseDate())
//                        .font(.caption)
//                        .foregroundColor(.gray)
//
//                    Text("• \(album.total_tracks) tracks")
//                         .font(.caption)
//                         .foregroundColor(.gray)
//                     Spacer()
//                }
//                .padding(.top, 2)
//            }
//        }
//         .padding(.horizontal) // Add padding to the whole row
//         .padding(.vertical, 5)
//         .background(Color(.systemBackground)) // Ensure contrast in plain list style
//         .cornerRadius(8) // Optional: round corners of the row background
//    }
//}
//
//// MARK: - Album Detail View (*** UPDATED ***)
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
//        ScrollView {
//            VStack(alignment: .leading, spacing: 0) { // Remove top-level spacing initially
//                // --- Album Header ---
//                AlbumHeaderView(album: album)
//
//                // --- Player Placeholder/View ---
//                // Embed player appears here when a track is selected
//                if let uriToPlay = selectedTrackUri {
//                    VStack { // Add spacing around player
//                         Divider().padding(.horizontal)
//                         Text("Now Playing")
//                             .font(.headline)
//                             .padding(.top, 10)
//                         SpotifyEmbedPlayerView(
//                             playbackState: playbackState,
//                             spotifyUri: uriToPlay // Pass the selected URI
//                         )
//                         Divider().padding(.horizontal)
//                    }
//                    .padding(.vertical, 10) // Space above/below divider+player
//                    .transition(.opacity.combined(with: .scale(scale: 0.9, anchor: .top)))
//                    .animation(.easeInOut, value: selectedTrackUri)
//                }
//
//                // --- Tracks Section ---
//                TracksSectionView(
//                    tracks: tracks,
//                    isLoading: isLoadingTracks,
//                    error: trackFetchError,
//                    selectedTrackUri: $selectedTrackUri, // Pass binding
//                    retryAction: { Task { await fetchTracks() } }
//                )
//
//                 // --- External Link Button ---
//                 if let spotifyURL = URL(string: album.external_urls.spotify ?? "") {
//                     ExternalLinkButton(url: spotifyURL)
//                         .padding() // Padding around the button
//                 }
//            }
//        }
//        .navigationTitle(album.name)
//        .navigationBarTitleDisplayMode(.inline)
//        .task { // Use .task for async work on view appear
//            await fetchTracks()
//        }
//        .onChange(of: selectedTrackUri){
//             // Optional: Log when URI changes
//             if let selectedTrackUri {
//                 print("Selected track URI changed to: \(selectedTrackUri)")
//             }
//         }
//    }
//
//    // Function to fetch tracks
//    private func fetchTracks() async {
//        guard tracks.isEmpty else { return } // Fetch only once
//
//        isLoadingTracks = true
//        trackFetchError = nil
//
//        do {
//            let response = try await SpotifyAPIService.shared.getAlbumTracks(albumId: album.id)
//
//            // Check for cancellation after await
//            try Task.checkCancellation()
//
//            await MainActor.run {
//                 self.tracks = response.items
//            }
//        } catch is CancellationError {
//             print("Track fetch task cancelled.")
//        } catch let apiError as SpotifyAPIError {
//            print("❌ Error fetching tracks: \(apiError.localizedDescription)")
//            await MainActor.run {
//                 self.trackFetchError = apiError
//            }
//        } catch {
//            print("❌ Unexpected error fetching tracks: \(error.localizedDescription)")
//            await MainActor.run {
//                 self.trackFetchError = .networkError(error)
//            }
//        }
//
//        await MainActor.run {
//             isLoadingTracks = false
//        }
//    }
//}
//
//// MARK: - AlbumDetailView Sub-Components
//
//struct AlbumHeaderView: View {
//    let album: AlbumItem
//
//    var body: some View {
//        VStack(spacing: 16) {
//            AlbumImageView(url: album.bestImageURL)
//                .aspectRatio(contentMode: .fit)
//                .cornerRadius(8)
//                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
//                .padding(.horizontal, 40) // More horizontal padding for large image
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
//// View specifically for holding the embed player and its state info
//struct SpotifyEmbedPlayerView: View {
//   @ObservedObject var playbackState: SpotifyPlaybackState
//    let spotifyUri: String
//
//    var body: some View {
//        VStack {
//             SpotifyEmbedWebView(playbackState: playbackState, spotifyUri: spotifyUri)
//                 .frame(height: 80) // Standard Spotify embed height
//                  // Optional: Add a border or background for visual separation
//                 .background(Color.black.opacity(0.05), in: RoundedRectangle(cornerRadius: 8))
//                 .padding(.horizontal)
//
//             // Optional: Display playback state from the WebView
//             HStack {
//                 Text(playbackState.isPlaying ? "Playing" : "Paused")
//                     .font(.caption)
//                     .foregroundColor(playbackState.isPlaying ? Color.green : Color.secondary)
//                     .animation(.easeInOut, value: playbackState.isPlaying)
//                 Spacer()
//                 if playbackState.duration > 0 {
//                     Text("\(formatTime(playbackState.currentPosition)) / \(formatTime(playbackState.duration))")
//                         .font(.caption)
//                         .foregroundColor(.secondary)
//                 }
//             }
//             .padding(.horizontal)
//             .padding(.top, 4)
//        }
//    }
//
//     private func formatTime(_ time: Double) -> String {
//         let totalSeconds = Int(time)
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
//         VStack(alignment: .leading) {
//             Text("Tracks")
//                 .font(.title3.weight(.semibold))
//                 .padding(.horizontal)
//                 .padding(.bottom, 5)
//
//             if isLoading {
//                 ProgressView("Loading Tracks...")
//                     .frame(maxWidth: .infinity, alignment: .center)
//                     .padding()
//             } else if let error = error {
//                  ErrorView(error: error, retryAction: retryAction)
//                      .padding()
//             } else if tracks.isEmpty {
//                 Text("No tracks found for this album.")
//                     .foregroundColor(.secondary)
//                     .frame(maxWidth: .infinity, alignment: .center)
//                     .padding()
//             } else {
//                 // Using LazyVStack within ScrollView for better performance with many tracks
//                 LazyVStack(spacing: 0) {
//                    ForEach(tracks) { track in
//                        TrackRowView(
//                            track: track,
//                            isSelected: track.uri == selectedTrackUri // Check if this track is the selected one
//                        )
//                        .contentShape(Rectangle()) // Make the whole row tappable
//                        .onTapGesture {
//                            // Update the selected URI when a row is tapped
//                             selectedTrackUri = track.uri
//                        }
//                        .background(track.uri == selectedTrackUri ? Color.accentColor.opacity(0.1) : Color.clear) // Highlight selected row
//                        Divider() // Separator between tracks
//                            .padding(.leading, 55) // Indent divider
//                    }
//                }
//                 .padding(.horizontal) // Padding around the list of tracks
//             }
//         }
//         .padding(.top, 10) // Space above "Tracks" title
//    }
//}
//
//// Row for displaying a single track in the AlbumDetailView list
//struct TrackRowView: View {
//    let track: Track
//    let isSelected: Bool
//
//    var body: some View {
//        HStack {
//            Text("\(track.track_number)")
//                .font(.caption.monospacedDigit())
//                .foregroundColor(.secondary)
//                .frame(width: 25, alignment: .trailing)
//
//            VStack(alignment: .leading, spacing: 2) {
//                Text(track.name)
//                    .font(.body)
//                    .lineLimit(1)
//                    .foregroundColor(isSelected ? .accentColor : .primary) // Highlight selected text
//                Text(track.formattedArtists)
//                    .font(.caption)
//                    .foregroundColor(.secondary)
//                    .lineLimit(1)
//            }
//
//            Spacer()
//
//            Text(track.formattedDuration)
//                .font(.caption.monospacedDigit())
//                .foregroundColor(.secondary)
//
//            Image(systemName: isSelected ? "speaker.wave.2.fill" : "play.circle")
//                 .foregroundColor(isSelected ? .accentColor : .secondary)
//                 .font(.title3) // Make icon slightly larger
//                 .frame(width: 30) // Fixed width for alignment
//        }
//        .padding(.vertical, 8)
//        // No .onTapGesture here, handled by the parent `LazyVStack` `ForEach`
//    }
//}
//
//struct ExternalLinkButton: View {
//     let url: URL
//     @Environment(\.openURL) var openURL
//
//     var body: some View {
//         Button { openURL(url) } label: {
//             HStack {
//                 Image(systemName: "play.circle.fill") // Or a Spotify logo asset
//                 Text("Open in Spotify")
//             }
//             .font(.headline)
//             .padding()
//             .frame(maxWidth: .infinity)
//              // Use a distinct button style
//             .background(Color.green.opacity(0.9))
//             .foregroundColor(.white)
//             .clipShape(RoundedRectangle(cornerRadius: 10))
//             .shadow(radius: 3)
//         }
//         .buttonStyle(.plain) // Avoid default button styles interfering
//     }
//}
//
//// MARK: - DetailItem Helper View (Unchanged, but maybe not needed directly in AlbumDetailView now)
//// Keeping it in case it's useful elsewhere
//struct DetailItem: View {
//    let label: String
//    let value: String
//
//    var body: some View {
//        HStack(alignment: .top) {
//            Text(label)
//                .font(.headline)
//                .foregroundColor(.secondary)
//                .frame(width: 120, alignment: .leading)
//            Text(value)
//                .font(.body)
//                .fixedSize(horizontal: false, vertical: true)
//            Spacer()
//        }
//    }
//}
//
//// MARK: - Reusable Async Image View (Unchanged)
//struct AlbumImageView: View {
//    let url: URL?
//
//    var body: some View {
//        AsyncImage(url: url) { phase in
//            switch phase {
//            case .empty:
//                ZStack {
//                    Color(.secondarySystemBackground) // Placeholder bg
//                    ProgressView()
//                }
//            case .success(let image):
//                image.resizable() // Let the caller decide aspect ratio
//            case .failure:
//                ZStack {
//                     Color(.secondarySystemBackground)
//                     Image(systemName: "photo.fill")
//                         .resizable()
//                         .scaledToFit()
//                         .foregroundStyle(.tertiary) // Subdued color
//                         .padding() // Padding around icon
//                }
//            @unknown default:
//                ZStack {
//                     Color(.secondarySystemBackground)
//                     Image(systemName: "questionmark.diamond.fill")
//                         .resizable()
//                         .scaledToFit()
//                         .foregroundStyle(.tertiary)
//                         .padding()
//                 }
//            }
//        }
//    }
//}
//
//// MARK: - Preview Providers
//
//// Preview for the main list view
//struct SpotifyAlbumListView_Previews: PreviewProvider {
//    static var previews: some View {
//        // Sample data for previews
//        let mockArtist = Artist(id: "artist1", external_urls: nil, href: "", name: "Miles Davis Mock", type: "artist", uri: "")
//        let mockImage = SpotifyImage(height: 64, url: "https://i.scdn.co/image/ab67616d000048517ab89c25093ea3787b1995b4", width: 64) // Real image URL
//        let mockAlbumItem = AlbumItem(id: "album1", album_type: "album", total_tracks: 5, available_markets: ["US"], external_urls: ExternalUrls(spotify: ""), href: "", images: [mockImage], name: "Kind of Blue Mock", release_date: "1959-08-17", release_date_precision: "day", type: "album", uri: "spotify:album:1weenld61qoidwYuZ1GESA", artists: [mockArtist])
//        let mockAlbumItem2 = AlbumItem(id: "album2", album_type: "album", total_tracks: 8, available_markets: ["US"], external_urls: ExternalUrls(spotify: ""), href: "", images: [mockImage], name: "Workin' Mock", release_date: "1959", release_date_precision: "year", type: "album", uri: "spotify:album:7buLIJn2VuqsVORghMEvli", artists: [mockArtist])
//        
//        
//        SpotifyAlbumListView()
//        
////        Group {
////            SpotifyAlbumListView()
////                .previewDisplayName("Initial State")
////
////            SpotifyAlbumListView(displayedAlbums: [mockAlbumItem, mockAlbumItem2], searchInfo: Albums(href: "", limit: 2, next: nil, offset: 0, previous: nil, total: 2, items: []))
////                 .previewDisplayName("With Mock Results")
////
////            SpotifyAlbumListView(isLoading: true)
////                  .previewDisplayName("Loading State")
////
////             SpotifyAlbumListView(currentError: .invalidToken)
////                 .previewDisplayName("Error State (Token)")
////
////             SpotifyAlbumListView(searchQuery: "zzzzz", displayedAlbums: [])
////                 .previewDisplayName("No Results")
////        }
//    }
//}
//
//// Preview for the detail view
//struct AlbumDetailView_Previews: PreviewProvider {
//     static let mockArtist = Artist(id: "artist1", external_urls: nil, href: "", name: "Miles Davis Mock", type: "artist", uri: "")
//     static let mockImage = SpotifyImage(height: 640, url: "https://i.scdn.co/image/ab67616d0000b2737ab89c25093ea3787b1995b4", width: 640) // Real image URL
//     static let mockAlbum = AlbumItem(id: "1weenld61qoidwYuZ1GESA", album_type: "album", total_tracks: 5, available_markets: ["US", "GB"], external_urls: ExternalUrls(spotify: "https://open.spotify.com/album/1weenld61qoidwYuZ1GESA"), href: "", images: [mockImage], name: "Kind Of Blue (Preview)", release_date: "1959-08-17", release_date_precision: "day", type: "album", uri: "spotify:album:1weenld61qoidwYuZ1GESA", artists: [mockArtist])
//
//     // Mock tracks for the detail view preview
//     static let mockTracks = [
//         Track(id: "track1", artists: [mockArtist], disc_number: 1, duration_ms: 200000, explicit: false, external_urls: nil, href: "", name: "So What (Mock)", preview_url: nil, track_number: 1, type: "track", uri: "spotify:track:4vLYewWIvqHfKtJDk8c8tq"), // Real URI for testing player
//         Track(id: "track2", artists: [mockArtist], disc_number: 1, duration_ms: 180000, explicit: false, external_urls: nil, href: "", name: "Freddie Freeloader (Mock)", preview_url: nil, track_number: 2, type: "track", uri: "spotify:track:3mGgwVllZm11G9HNCrWr3I"), // Real URI
//         Track(id: "track3", artists: [mockArtist], disc_number: 1, duration_ms: 210000, explicit: false, external_urls: nil, href: "", name: "Blue in Green (Mock)", preview_url: nil, track_number: 3, type: "track", uri: "spotify:track:0aWMVrwxPNYkKmFthzmpRi") // Real URI
//     ]
//
//    static var previews: some View {
//        NavigationView {
////            AlbumDetailView(
////                album: mockAlbum,
////                tracks: mockTracks, // Provide mock tracks directly
////                selectedTrackUri: mockTracks[1].uri // Pre-select a track for preview
////            )
//            AlbumDetailView(
//                album: mockAlbum
//            )
//        }
//        .previewDisplayName("Detail View (Mock Tracks)")
//
//        NavigationView {
////            AlbumDetailView(
////                 album: mockAlbum,
////                 isLoadingTracks: true // Simulate loading tracks state
////             )
//            AlbumDetailView(
//                 album: mockAlbum
//             )
//        }
//         .previewDisplayName("Detail View (Loading Tracks)")
//
//         NavigationView {
////             AlbumDetailView(
////                  album: mockAlbum,
////                  trackFetchError: .networkError(URLError(.notConnectedToInternet)) // Simulate error
////              )
//             AlbumDetailView(
//                  album: mockAlbum
//              )
//         }
//          .previewDisplayName("Detail View (Track Fetch Error)")
//    }
//}
//
//// Example App entry point
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
