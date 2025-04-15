//
//  SpotifyEmbedView_V2.swift
//  MyApp
//
//  Created by Cong Le on 4/15/25.
//

import SwiftUI
@preconcurrency import WebKit
import Combine // Needed for ObservableObject

// MARK: - Data Model

enum SpotifyItemType: String {
    case track = "Track"
    case episode = "Episode"
    case album = "Album"
    case playlist = "Playlist"
}

struct SpotifyItem: Identifiable, Hashable {
    let id = UUID() // Conformance to Identifiable for Picker
    let name: String
    let type: SpotifyItemType
    let uri: String
    let artistOrShow: String? // Optional extra info

    // Mock Data - Replace with your actual data source
    static let mockItems: [SpotifyItem] = [
        SpotifyItem(name: "Never Gonna Give You Up", type: .track, uri: "spotify:track:4uLU6hMCjMI75M1A2tKUQC", artistOrShow: "Rick Astley"), // Updated URI, original might be unavailable
        SpotifyItem(name: "Life At Spotify", type: .episode, uri: "spotify:episode:7makk4oTQel546B0PZlDM5", artistOrShow: "A Product Story"),
        SpotifyItem(name: "Rumours", type: .album, uri: "spotify:album:6ZG5lRT77aJ3btmArcykra", artistOrShow: "Fleetwood Mac"),
        SpotifyItem(name: "Today's Top Hits", type: .playlist, uri: "spotify:playlist:37i9dQZF1DXcBWIGoYBM5M", artistOrShow: "Spotify"),
        SpotifyItem(name: "Invalid URI (For Error Test)", type: .track, uri: "spotify:track:invaliduri", artistOrShow: "Error Tester") // Example for testing errors
    ]
}

// MARK: - Controller Proxy (ObservableObject for State Bridging)

// This class acts as a bridge to pass state changes *from* the Coordinator *to* SwiftUI
// and to pass action requests *from* SwiftUI *to* the Coordinator (via updateUIView).
class SpotifyControllerProxy: ObservableObject {
    @Published var isReady: Bool = false
    @Published var isPlaying: Bool = false
    @Published var errorMessage: String? = nil

    // Internal state to trigger actions via updateUIView
    enum PendingAction { case none, play, pause, togglePlayPause }
    var pendingAction: PendingAction = .none

    func play() {
        pendingAction = .play
        // The Bool change will trigger updateUIView in the representable
        objectWillChange.send()
    }

    func pause() {
        pendingAction = .pause
        objectWillChange.send()
    }

    func togglePlayPause() {
        print("Proxy: Toggle action requested. Current isPlaying guess: \(isPlaying)")
        pendingAction = .togglePlayPause
        objectWillChange.send()
    }

     // Called by Coordinator
     func resetPendingAction() {
         if pendingAction != .none {
             pendingAction = .none
             // Don't need to send objectWillChange here, prevents update loops
         }
     }
}

// MARK: - Spotify Embed WebView (UIViewRepresentable - Enhanced)

struct SpotifyEmbedWebViewRepresentable: UIViewRepresentable {

    let spotifyUri: String
    @ObservedObject var controllerProxy: SpotifyControllerProxy // Use the proxy

    func makeCoordinator() -> Coordinator {
        Coordinator(self, controllerProxy: controllerProxy) // Pass proxy to Coordinator
    }

    func makeUIView(context: Context) -> WKWebView {
        let userContentController = WKUserContentController()
        // Register message handler
        userContentController.add(context.coordinator, name: "spotifyController")

        let configuration = WKWebViewConfiguration()
        configuration.userContentController = userContentController
        configuration.allowsInlineMediaPlayback = true
        // Important: Allow autoplay *after* user interaction with the app often works better
        // Depending on iOS version and context, full programmatic autoplay can be blocked.
        configuration.mediaTypesRequiringUserActionForPlayback = [] // Try allowing more

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.isScrollEnabled = false // Keep embed fixed

        // Initial Load - Important: Loading needs to be async, webview isn't ready immediately
        // The coordinator will trigger the actual spotify load once the HTML base is ready.
        let html = generateHTML()
        // Setting a base URL can sometimes help with CORS or relative path issues if needed
        // webView.loadHTMLString(html, baseURL: URL(string: "https://open.spotify.com"))
        webView.loadHTMLString(html, baseURL: nil)

        context.coordinator.webView = webView // Give coordinator reference
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        context.coordinator.parent = self// Make sure coordinator has latest parent reference

        // 1. Handle Pending Actions (Play/Pause/Toggle)
        switch controllerProxy.pendingAction {
        case .play:
            context.coordinator.play()
        case .pause:
            context.coordinator.pause()
        case .togglePlayPause:
             context.coordinator.togglePlayPause() // Let coordinator handle logic
         case .none:
            break // No action needed
        }
         // Reset immediately after processing to avoid re-triggering
        context.coordinator.resetPendingAction()

        // 2. Handle URI Changes (only if ready and URI differs)
        if controllerProxy.isReady && context.coordinator.lastLoadedUri != spotifyUri {
             print("updateUIView: Detected URI change. Current: \(String(describing: context.coordinator.lastLoadedUri)), New: \(spotifyUri)")
             context.coordinator.loadUri(spotifyUri)
         } else if !controllerProxy.isReady && context.coordinator.lastLoadedUri != nil {
              print("updateUIView: Received update but proxy/API not ready or URI is the same.")
         }
    }

    static func dismantleUIView(_ uiView: WKWebView, coordinator: Coordinator) {
        print("Dismantling WebView")
        uiView.stopLoading()
        coordinator.webView = nil // Break reference cycle
        // Important: Remove message handler
        uiView.configuration.userContentController.removeScriptMessageHandler(forName: "spotifyController")
        // Reset proxy state if needed (optional)
        // coordinator.controllerProxy.isReady = false
        // coordinator.controllerProxy.isPlaying = false
    }

    // MARK: - Coordinator (Bridge - Enhanced)
    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
        var parent: SpotifyEmbedWebViewRepresentable
        weak var webView: WKWebView? // Use weak reference to avoid retain cycles
        var controllerProxy: SpotifyControllerProxy // Hold the proxy
        var lastLoadedUri: String? = nil
        private var initialURILoadAttempted = false

        init(_ parent: SpotifyEmbedWebViewRepresentable, controllerProxy: SpotifyControllerProxy) {
            self.parent = parent
            self.controllerProxy = controllerProxy
        }

        // --- WKNavigationDelegate ---
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
             print("Coordinator: Base HTML loaded (didFinish navigation).")
             // Base HTML is loaded, but Spotify script is async.
             // We wait for the 'ready' message from onSpotifyIframeApiReady.
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print("Coordinator: Navigation Failed - \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.controllerProxy.errorMessage = "Failed to load player resources: \(error.localizedDescription)"
                self.controllerProxy.isReady = false
            }
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
             print("Coordinator: Provisional Navigation Failed - \(error.localizedDescription)")
             DispatchQueue.main.async {
                 self.controllerProxy.errorMessage = "Failed to navigate: \(error.localizedDescription)"
                 self.controllerProxy.isReady = false
             }
        }

        // --- WKScriptMessageHandler ---
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
             guard message.name == "spotifyController" else { return }

             if let body = message.body as? String {
                 if body == "spotifyApiReady" { // Changed message string slightly for clarity
                     print("Coordinator: Received 'spotifyApiReady' message from JS.")
                     // JS confirms the Spotify *API* script loaded. Now *create* the controller.
                     // Reset error on successful API load
                    DispatchQueue.main.async {
                         self.controllerProxy.errorMessage = nil
                         // Create the controller if it hasn't been attempted yet
                         if !self.initialURILoadAttempted {
                              self.createSpotifyController(uri: self.parent.spotifyUri) // Use initial URI from parent
                         }
                    }
                 }
                 // Add other string messages if needed
             } else if let dict = message.body as? [String: Any] {
                 // Handle dictionary-based messages (like events)
                 if let event = dict["event"] as? String {
                     switch event {
                     case "controllerReady":
                          print("Coordinator: Received 'controllerReady' message from JS.")
                          // The *controller* itself is ready for interaction
                         DispatchQueue.main.async {
                             self.controllerProxy.isReady = true // Enable UI controls
                             self.controllerProxy.errorMessage = nil // Clear any previous errors
                             // Update playback state if provided
                             if let data = dict["data"] as? [String: Any],
                                let isPaused = data["isPaused"] as? Bool {
                                 print("Coordinator: Controller ready, initial isPaused state: \(!isPaused)")
                                 self.controllerProxy.isPlaying = !isPaused
                             } else {
                                  // If initial paused state not provided, assume paused
                                 self.controllerProxy.isPlaying = false
                             }
                         }
                     case "playbackUpdate":
                         if let data = dict["data"] as? [String: Any],
                            let isPaused = data["isPaused"] as? Bool {
                              print("Coordinator: Received 'playbackUpdate'. isPaused: \(isPaused)")
                             DispatchQueue.main.async {
                                 self.controllerProxy.isPlaying = !isPaused // Update SwiftUI state
                             }
                         }
                     case "error":
                         if let data = dict["data"] as? [String: Any],
                            let errorMessage = data["message"] as? String {
                              print("Coordinator: Received 'error' from JS: \(errorMessage)")
                             DispatchQueue.main.async {
                                  self.controllerProxy.errorMessage = errorMessage
                                  self.controllerProxy.isReady = false // Assume controller is unusable on error
                             }
                         }

                     default:
                         print("Coordinator: Received unknown event message from JS: \(event)")
                     }
                 }
             }
        }

        // --- Action Methods Called by updateUIView ---

        func play() {
             guard controllerProxy.isReady else { return } // Ensure controller is ready
             print("Coordinator: Executing play command.")
             evaluateJavaScript("window.embedController.play();")
        }

        func pause() {
             guard controllerProxy.isReady else { return }
             print("Coordinator: Executing pause command.")
             evaluateJavaScript("window.embedController.pause();")
        }

        func togglePlayPause() {
             guard controllerProxy.isReady else { return }
             // The proxy's isPlaying state might be slightly stale, but it's the best guess
             if controllerProxy.isPlaying {
                 print("Coordinator: Executing toggle command (detected playing -> pause).")
                 evaluateJavaScript("window.embedController.pause();")
             } else {
                 print("Coordinator: Executing toggle command (detected paused -> play).")
                 evaluateJavaScript("window.embedController.play();")
             }
             // Note: JS playback_update message will provide the ground truth state update
        }

        func loadUri(_ uri: String) {
            guard controllerProxy.isReady else { // Check if controller is actually ready
                 print("Coordinator: loadUri called but controller not ready. Deferring or ignoring.")
                 // Option 1: Defer (more complex state needed)
                 // Option 2: Ignore (simpler for now)
                 // Option 3: Reload the controller if needed (might be necessary if initial load failed)
                 // Let's try just creating/recreating the controller if loadUri is called when not ready
                 // after the initial attempt.

                 // Check if webView exists before attempting reload
                 guard webView != nil else {
                     print("Coordinator: WebView not available, cannot load URI.")
                     controllerProxy.errorMessage = "Player not initialized."
                     return
                 }

                 print("Coordinator: Controller not ready, but URI changed. Attempting to create controller with new URI: \(uri)")
                 // Reset potentially stale state before attempting creation
                 DispatchQueue.main.async {
                     self.controllerProxy.isReady = false
                     self.controllerProxy.isPlaying = false
                     self.controllerProxy.errorMessage = "Loading..." // Provide loading feedback
                 }
                 createSpotifyController(uri: uri)
                 return
             }

             print("Coordinator: Executing loadUri command for \(uri).")
             lastLoadedUri = uri // Update tracking *before* evaluating JS
             DispatchQueue.main.async {
                  self.controllerProxy.isReady = false // Set to not ready while loading new content
                  self.controllerProxy.isPlaying = false // Assume paused initially
                  self.controllerProxy.errorMessage = nil // Clear previous error on new load attempt
             }
             evaluateJavaScript("""
                  if (window.embedController) {
                      console.log('JS: Loading URI: \(uri)');
                      window.embedController.loadUri('\(uri)');
                  } else {
                      console.error('JS: window.embedController not found when trying to load URI!');
                      // Optionally notify Swift of this specific error
                      if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.spotifyController) {
                           window.webkit.messageHandlers.spotifyController.postMessage({ event: 'error', data: { message: 'Embed controller lost.' } });
                      }
                  }
             """)
        }

        // --- Helper Methods ---

        private func createSpotifyController(uri: String) {
              guard let webView = webView else {
                  print("Coordinator: WebView gone, cannot create controller.")
                  DispatchQueue.main.async { self.controllerProxy.errorMessage = "Player unavailable." }
                  return
              }

               print("Coordinator: Attempting to create Spotify controller with URI: \(uri)")
              initialURILoadAttempted = true // Mark that we've tried
              lastLoadedUri = uri // Track the URI we are trying to load

              // Reset state before creation attempt
               DispatchQueue.main.async {
                   self.controllerProxy.isReady = false
                   self.controllerProxy.isPlaying = false // Assume paused
                   self.controllerProxy.errorMessage = nil // Clear errors
               }

              let script = """
              console.log('JS: Swift calling IFrameAPI.createController for URI: \(uri)');
              const element = document.getElementById('embed-iframe');
              if (!element) {
                   console.error('JS: Placeholder element #embed-iframe not found!');
                   if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.spotifyController) {
                        window.webkit.messageHandlers.spotifyController.postMessage({ event: 'error', data: { message: 'HTML placeholder missing.' } });
                   }
                   return; // Stop execution
              }
              const options = {
                  uri: '\(uri)',
                  width: '100%',
                  height: '100%'
              };
              const callback = (controller) => {
                  console.log('JS: Spotify EmbedController created by API.');
                  window.embedController = controller; // Store globally

                   // Send message that controller is ready, include initial state
                   if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.spotifyController) {
                        window.webkit.messageHandlers.spotifyController.postMessage({
                           event: 'controllerReady',
                           data: { isPaused: controller.isPaused } // Send initial state back
                        });
                   }

                  // Add listeners for events
                  controller.addListener('ready', () => {
                      console.log('JS Embed Event: Ready');
                      // This 'ready' is the controller instance confirming it's ready, differs from API ready
                      // We already signaled readiness in the main callback above.
                       if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.spotifyController) {
                          window.webkit.messageHandlers.spotifyController.postMessage({
                               event: 'controllerReady', // Can send again if needed, includes updated state
                               data: { isPaused: controller.isPaused }
                          });
                       }
                  });
                  controller.addListener('playback_update', e => {
                       console.log('JS Embed Playback Update:', e.data.isPaused);
                       if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.spotifyController) {
                            window.webkit.messageHandlers.spotifyController.postMessage({ event: 'playbackUpdate', data: e.data });
                       }
                  });
                  // Add error listener
                  controller.addListener('error', errorEvent => {
                       console.error('JS Embed Error Event:', errorEvent.data.message);
                       if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.spotifyController) {
                           window.webkit.messageHandlers.spotifyController.postMessage({ event: 'error', data: errorEvent.data });
                       }
                  });
              };
              // Ensure IFrameAPI exists
              if (window.IFrameAPI) {
                  window.IFrameAPI.createController(element, options, callback);
              } else {
                   console.error('JS: IFrameAPI not found when trying to create controller!');
                    if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.spotifyController) {
                         window.webkit.messageHandlers.spotifyController.postMessage({ event: 'error', data: { message: 'Spotify API script failed to load.' } });
                    }
              }
              """
              evaluateJavaScript(script)
        }

        // Helper to evaluate JS and handle potential errors
        private func evaluateJavaScript(_ script: String) {
            guard let webView = webView else {
                print("Coordinator: Cannot evaluate JS, WebView is nil.")
                return
            }
            webView.evaluateJavaScript(script) { result, error in
                if let error = error {
                    print("Coordinator: Error evaluating JS - \(error.localizedDescription)")
                    // Don't set generic error message here, let specific errors from JS API report
                    print("Coordinator: Failing script was:\n\(script)")
                     // Optionally report this *evaluation* error if critical
                     // DispatchQueue.main.async {
                     //    self.controllerProxy.errorMessage = "JavaScript communication error."
                     // }
                }
                // Optional: Log successful evaluation result if needed for debugging
                // else if let result = result { print("Coordinator: JS evaluation result: \\(result)") }
            }
        }

         // Called by Representable before triggering actions in updateUIView
         func resetPendingAction() {
             controllerProxy.resetPendingAction()
         }

        // Optional: Handle JS alerts nicely
        func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
            print("JS Alert: \(message)")
            DispatchQueue.main.async {
                // In a real app, present a UIAlertController or similar
                if self.controllerProxy.errorMessage == nil { // Avoid overwriting specific errors
                  // self.controllerProxy.errorMessage = "JS Alert: \(message)" // Optional: surface alerts
                }
            }
            completionHandler() // Must call this
        }
    }

    // MARK: - HTML Generator (Enhanced JS Communication)
    private func generateHTML() -> String {
        return """
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="utf-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
            <style>
                /* Basic styling */
                html, body { height: 100%; margin: 0; padding: 0; background-color: transparent; overflow: hidden; }
                #embed-iframe {
                    width: 100%;
                    height: 100%; /* Fill containing element */
                    box-sizing: border-box;
                    display: block;
                }
            </style>
        </head>
        <body>
            <!-- Placeholder -->
            <div id="embed-iframe"></div>

            <!-- API script -->
            <script src="https://open.spotify.com/embed/iframe-api/v1" async></script>

            <!-- Readiness Callback -->
            <script>
                console.log('JS: HTML loaded, waiting for onSpotifyIframeApiReady...');
                window.onSpotifyIframeApiReady = (IFrameAPI) => {
                    console.log('JS: onSpotifyIframeApiReady CALLED.');
                    window.IFrameAPI = IFrameAPI; // Store globally (optional)

                    // *** Send message to Swift: API script is ready ***
                    if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.spotifyController) {
                         console.log('JS: Posting "spotifyApiReady" message to Swift...');
                         window.webkit.messageHandlers.spotifyController.postMessage("spotifyApiReady");
                    } else {
                         console.error('JS: Swift message handler (spotifyController) not found!');
                    }
                };
            </script>
        </body>
        </html>
        """
    }
}

// MARK: - SwiftUI Host View (Enhanced Card Design)

struct SpotifyEmbedView: View {
    // Use the proxy owned by this view
    @StateObject private var controllerProxy = SpotifyControllerProxy()

    // State for the currently selected *item*, driving the URI
    @State private var selectedItem: SpotifyItem = SpotifyItem.mockItems[0] // Default selection

    // Predefined list of items to choose from
    let items: [SpotifyItem] = SpotifyItem.mockItems

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

             // --- Content Picker ---
             Picker("Select Content", selection: $selectedItem) {
                 ForEach(items) { item in
                     Text("\(item.name) (\(item.type.rawValue))")
                         .tag(item) // Tag with the whole item for selection
                 }
             }
             .pickerStyle(.menu) // Or .wheel, .segmented etc.
             .padding(.bottom, 5)
             .disabled(!controllerProxy.isReady && controllerProxy.errorMessage == nil) // Disable while initially loading

            // --- Spotify Embed Area ---
            ZStack {
                // The WebView Representable
                SpotifyEmbedWebViewRepresentable(
                    spotifyUri: selectedItem.uri, // Pass the selected URI
                    controllerProxy: controllerProxy // Pass the proxy instance
                )
                .frame(height: 200) // Specific height for the player
                .background(Color.black.opacity(0.1)) // Subtle background for player area
                .clipShape(RoundedRectangle(cornerRadius: 8)) // Clip the player corners slightly

                // --- Loading / Error Overlay ---
                if !controllerProxy.isReady || controllerProxy.errorMessage != nil {
                    RoundedRectangle(cornerRadius: 8) // Match the player shape
                         .fill(Color(.systemGray6).opacity(0.95)) // Semi-opaque background
                         .overlay(
                            VStack {
                                if let errorMsg = controllerProxy.errorMessage {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(.red)
                                        .imageScale(.large)
                                    Text("Error")
                                         .font(.headline).foregroundColor(.red)
                                    Text(errorMsg)
                                         .font(.caption)
                                         .foregroundColor(.secondary)
                                         .multilineTextAlignment(.center)
                                         .padding(.horizontal)
                                } else {
                                    ProgressView() // Loading indicator
                                         .scaleEffect(1.5)
                                    Text("Loading Player...")
                                         .font(.caption)
                                         .foregroundColor(.secondary)
                                         .padding(.top, 8)
                                }
                            }
                        )
                }
            }

             // --- Basic Info Display ---
            HStack {
                 VStack(alignment: .leading) {
                     Text(selectedItem.name).font(.headline)
                     if let artist = selectedItem.artistOrShow {
                         Text(artist).font(.subheadline).foregroundColor(.secondary)
                     }
                 }
                Spacer() // Push controls to the right
                 // --- Playback Controls ---
                if controllerProxy.isReady && controllerProxy.errorMessage == nil {
                    Button {
                        controllerProxy.togglePlayPause()
                    } label: {
                        Image(systemName: controllerProxy.isPlaying ? "pause.fill" : "play.fill")
                             .font(.title2) // Adjust icon size
                             .frame(width: 44, height: 44) // Make tappable area larger
                             .contentShape(Rectangle()) // Ensure entire frame is tappable
                    }
                    .buttonStyle(.plain) // Use plain style for icon-only buttons typically
                }
            }
        }
        .padding() // Padding inside the card
        .background(Color(.systemGray6)) // Card background color
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        .padding() // Padding outside the card
        .navigationTitle("Spotify Player Card")
        .animation(.default, value: selectedItem) // Animate changes when item changes
        .animation(.default, value: controllerProxy.isReady)
        .animation(.default, value: controllerProxy.isPlaying) // Animate play/pause icon
    }
}

// MARK: - Preview

struct SpotifyEmbedView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView { // Add NavigationView for title
            SpotifyEmbedView()
                .previewLayout(.sizeThatFits) // Good for previewing card components
        }
    }
}
