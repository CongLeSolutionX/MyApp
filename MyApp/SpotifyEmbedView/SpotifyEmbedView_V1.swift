////
////  SpotifyEmbedView.swift
////  MyApp
////
////  Created by Cong Le on 4/15/25.
////
//
//import SwiftUI
//@preconcurrency import WebKit // Don't forget to import WebKit
//
//// MARK: - Spotify Embed WebView (UIViewRepresentable)
//
//struct SpotifyEmbedWebView: UIViewRepresentable {
//
//    let spotifyUri: String // Input: The Spotify URI to load
//
//    // Creates the coordinator bridge between Swift and JS
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//
//    // Creates the initial WKWebView
//    func makeUIView(context: Context) -> WKWebView {
//        // --- 1. Configure JavaScript Communication ---
//        let userContentController = WKUserContentController()
//        // Register a message handler named "spotifyController" that the JS can call
//        // The Coordinator will handle received messages
//        userContentController.add(context.coordinator, name: "spotifyController")
//
//        let configuration = WKWebViewConfiguration()
//        configuration.userContentController = userContentController
//        // Allow inline media playback, essential for the embed
//        configuration.allowsInlineMediaPlayback = true
//        // Allow media playback without user gesture (optional, use with caution)
//        configuration.mediaTypesRequiringUserActionForPlayback = []
//
//        // --- 2. Create WKWebView ---
//        let webView = WKWebView(frame: .zero, configuration: configuration)
//        webView.navigationDelegate = context.coordinator // Handle navigation events
//        webView.uiDelegate = context.coordinator // Optional: handle UI events like alerts
//        webView.isOpaque = false // Allow background to show through if needed
//        webView.backgroundColor = .clear // Match SwiftUI background if desired
//        webView.scrollView.isScrollEnabled = false // Disable scrolling within the embed box
//
//        // --- 3. Load Initial HTML ---
//        // This HTML sets up the placeholder div, includes the API script,
//        // and defines the crucial `onSpotifyIframeApiReady` function.
//        let html = generateHTML()
//        webView.loadHTMLString(html, baseURL: nil)
//
//        context.coordinator.webView = webView // Give coordinator a reference
//        return webView
//    }
//
//    // Handles updates from SwiftUI state changes (e.g., new URI)
//    func updateUIView(_ webView: WKWebView, context: Context) {
//        // If the API is ready and the controller exists in JS, load the new URI
//        // Compare with the coordinator's last loaded URI to avoid redundant loads
//        if context.coordinator.isApiReady && context.coordinator.lastLoadedUri != spotifyUri {
//            context.coordinator.loadUri(spotifyUri)
//        }
//        // Note: More robust checks might be needed in complex scenarios
//        // to ensure the JS `embedController` variable is definitely set
//        // before calling `loadUri`. This could involve another message
//        // back from the JS `createController` callback.
//    }
//
//    // Cleanup
//    static func dismantleUIView(_ uiView: WKWebView, coordinator: Coordinator) {
//         uiView.stopLoading()
//         // Remove the message handler to prevent leaks
//         uiView.configuration.userContentController.removeScriptMessageHandler(forName: "spotifyController")
//    }
//
//    // MARK: - Coordinator (Bridge)
//    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
//        var parent: SpotifyEmbedWebView
//        var webView: WKWebView? // Keep a reference if needed elsewhere
//        var isApiReady = false
//        var lastLoadedUri: String? = nil
//
//        init(_ parent: SpotifyEmbedWebView) {
//            self.parent = parent
//        }
//
//        // --- WKNavigationDelegate ---
//        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//            print("Spotify Embed WebView: Initial HTML loaded.")
//            // HTML is loaded, but Spotify script might still be initializing.
//            // We rely on the `onSpotifyIframeApiReady` postMessage.
//        }
//
//        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
//            print("Spotify Embed WebView: Navigation Failed - \(error.localizedDescription)")
//        }
//
//        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
//             print("Spotify Embed WebView: Provisional Navigation Failed - \(error.localizedDescription)")
//        }
//
//        // --- WKScriptMessageHandler ---
//        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
//            // Check if the message is from our designated handler
//            guard message.name == "spotifyController" else { return }
//
//            // Check the message content
//            if let body = message.body as? String, body == "ready" {
//                print("Spotify Embed WebView: Spotify API Ready message received from JS.")
//                isApiReady = true
//                // *** Crucial: Now that JS says API is ready, create the controller ***
//                createSpotifyController()
//            }
//            // Add more message handling here if needed (e.g., for playback events)
//            // else if let data = message.body as? [String: Any] { /* handle data */ }
//        }
//
//        // --- Helper Methods ---
//
//        // Injects JavaScript to create the Spotify Embed Controller
//        private func createSpotifyController() {
//            guard let webView = webView else { return }
//
//            // Use the initial URI from the parent struct
//            let initialUri = parent.spotifyUri
//            lastLoadedUri = initialUri // Set initial loaded URI
//
//            // Note: width and height are set relative to the placeholder div in generateHTML()
//            // We control the div size via the WKWebView's frame in SwiftUI.
//            let script = """
//            console.log('Swift calling IFrameAPI.createController for URI: \(initialUri)');
//            const element = document.getElementById('embed-iframe');
//            const options = {
//                uri: '\(initialUri)',
//                width: '100%',  // Fill the container div
//                height: '100%' // Fill the container div
//            };
//            const callback = (controller) => {
//                console.log('Spotify EmbedController created by API.');
//                // Store controller globally in JS for later access (e.g., by loadUri)
//                window.embedController = controller;
//
//                // Optional: notify Swift that controller is created if more complex sync is needed
//                // if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.spotifyController) {
//                //     window.webkit.messageHandlers.spotifyController.postMessage({ event: 'controllerCreated' });
//                // }
//
//                // Optional: Add listeners here if needed in JS
//                controller.addListener('ready', () => console.log('Embed Controller Event: Ready'));
//                controller.addListener('playback_update', e => {
//                     console.log('Embed Playback Update:', e.data.position, e.data.duration, e.data.isPaused);
//                     // Optional: Send playback data back to Swift
//                     // if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.spotifyController) {
//                     //    window.webkit.messageHandlers.spotifyController.postMessage({ event: 'playbackUpdate', data: e.data });
//                     // }
//                });
//            };
//            // Ensure IFrameAPI is available (it should be if 'ready' was received)
//            if (window.IFrameAPI) {
//                window.IFrameAPI.createController(element, options, callback);
//            } else {
//                 console.error('IFrameAPI not found when trying to create controller!');
//            }
//            """
//            webView.evaluateJavaScript(script) { result, error in
//                if let error = error {
//                    print("Spotify Embed WebView: Error creating controller - \(error.localizedDescription)")
//                } else {
//                    print("Spotify Embed WebView: createController script evaluated.")
//                }
//            }
//        }
//
//        // Injects JavaScript to load a new URI using the existing controller
//        func loadUri(_ uri: String) {
//            guard let webView = webView, isApiReady else { return }
//            lastLoadedUri = uri // Update last loaded URI track
//
//            // Assumes `window.embedController` was set in the createController callback
//            let script = """
//            console.log('Swift calling embedController.loadUri for: \(uri)');
//            if (window.embedController) {
//                window.embedController.loadUri('\(uri)');
//            } else {
//                console.error('window.embedController not found when trying to load URI!');
//            }
//            """
//            webView.evaluateJavaScript(script) { result, error in
//                if let error = error {
//                    print("Spotify Embed WebView: Error calling loadUri - \(error.localizedDescription)")
//                } else {
//                    print("Spotify Embed WebView: loadUri script evaluated for \(uri).")
//                }
//            }
//        }
//
//        // Optional: Handle JS alerts
//        func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
//            print("JS Alert: \(message)")
//            // In a real app, you might present a UIAlertController here
//            completionHandler()
//        }
//    }
//
//    // MARK: - HTML Generator
//    private func generateHTML() -> String {
//        return """
//        <!DOCTYPE html>
//        <html>
//        <head>
//            <meta charset="utf-8">
//            <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
//            <style>
//                body { margin: 0; padding: 0; background-color: transparent; }
//                #embed-iframe {
//                    width: 100%; /* Make the div fill available space */
//                    height: 100vh; /* Use viewport height to ensure it has dimensions */
//                    box-sizing: border-box; /* Include padding/border in element's total width/height */
//                    display: block; /* Ensure it takes up space */
//                }
//            </style>
//        </head>
//        <body>
//            <!-- 1. The Placeholder Element -->
//            <div id="embed-iframe"></div>
//
//            <!-- 2. The API script -->
//            <script src="https://open.spotify.com/embed/iframe-api/v1" async></script>
//
//            <!-- 3. The readiness callback -->
//            <script>
//                console.log('HTML loaded, waiting for onSpotifyIframeApiReady...');
//                window.onSpotifyIframeApiReady = (IFrameAPI) => {
//                    console.log('onSpotifyIframeApiReady CALLED by Spotify script.');
//                    // Store the API object globally if needed elsewhere (optional usually)
//                    window.IFrameAPI = IFrameAPI;
//
//                    // *** Crucial: Send message to Swift to signal readiness ***
//                    if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.spotifyController) {
//                         console.log('Posting "ready" message to Swift...');
//                         window.webkit.messageHandlers.spotifyController.postMessage("ready");
//                    } else {
//                         console.error('Swift message handler (spotifyController) not found!');
//                         // Fallback or error handling for environments without the handler
//                    }
//                };
//            </script>
//        </body>
//        </html>
//        """
//    }
//}
//
//// MARK: - SwiftUI Host View (Card Design)
//
//struct SpotifyEmbedView: View {
//    // State to hold the URI, allowing dynamic updates
//    @State private var currentUri: String
//
//    // Example URIs (Replace with your actual choices)
//    let episodeUri = "spotify:episode:7makk4oTQel546B0PZlDM5" // Life at Spotify
//    let trackUri = "spotify:track:11dFghVXANMlKmJXsNCbNl" // Rick Astley
//    let playlistUri = "spotify:playlist:37i9dQZF1DXcBWIGoYBM5M" // Today's Top Hits
//    let albumUri = "spotify:album:6ZG5lRT77aJ3btmArcykra" // Rumours - Fleetwood Mac
//
//    init(initialUri: String? = nil) {
//        // Use provided URI or default to an example
//        _currentUri = State(initialValue: initialUri ?? "spotify:episode:7makk4oTQel546B0PZlDM5")
//    }
//
//    var body: some View {
//        VStack(spacing: 15) {
//
//            // --- The Actual Embed ---
//            SpotifyEmbedWebView(spotifyUri: currentUri)
//                .frame(height: 200) // Set desired height for the embed player card area
//                .background(Color(.systemGray6)) // Subtle background for the card
//                .disabled(false) // Make sure webview interaction is enabled
//
//            // --- Controls (Example) ---
//            Text("Spotify Embed")
//                 .font(.headline)
//            HStack {
//                Button("Load Episode") { currentUri = episodeUri }
//                Button("Load Track") { currentUri = trackUri }
//                Button("Load Album") { currentUri = albumUri }
//            }
//            .buttonStyle(.borderedProminent)
//            .padding(.horizontal)
//
//            Spacer() // Push content to the top
//        }
//        .navigationTitle("Spotify Embed Card")
//        // --- Card Styling ---
//        .padding() // Padding inside the card
//        .background(Color(.secondarySystemBackground)) // Card background color
//        .cornerRadius(12)
//        .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
//        .padding() // Padding outside the card
//    }
//}
//
//// MARK: - Preview
//
//struct SpotifyEmbedView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView { // Add NavigationView for title
//            SpotifyEmbedView(initialUri: "spotify:track:11dFghVXANMlKmJXsNCbNl")
//        }
//    }
//}
