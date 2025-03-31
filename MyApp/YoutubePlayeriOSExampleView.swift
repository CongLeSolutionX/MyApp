//
//  ComprehensiveVersion.swift
//  MyApp
//
//  Created by Cong Le on 3/31/25.
//

import SwiftUI
import WebKit
import Combine // Needed for NSNotificationCenter publisher

// --- Enums (Matching ObjC version) ---

enum PlayerState: Int, CaseIterable, CustomStringConvertible {
    case unstarted = -1
    case ended = 0
    case playing = 1
    case paused = 2
    case buffering = 3
    case cued = 5
    case unknown = -99 // Add a distinct unknown case

    var description: String {
        switch self {
        case .unstarted: return "Unstarted (-1)"
        case .ended: return "Ended (0)"
        case .playing: return "Playing (1)"
        case .paused: return "Paused (2)"
        case .buffering: return "Buffering (3)"
        case .cued: return "Cued (5)"
        case .unknown: return "Unknown"
        }
    }

    static func from(string: String?) -> PlayerState {
        guard let string = string, let val = Int(string) else { return .unknown }
        return PlayerState(rawValue: val) ?? .unknown
    }
}

enum PlaybackQuality: String, CaseIterable, CustomStringConvertible {
    case small = "small"
    case medium = "medium"
    case large = "large"
    case hd720 = "hd720"
    case hd1080 = "hd1080"
    case highres = "highres"
    case auto = "auto"
    case unknown = "unknown" // Fallback

    var description: String {
        switch self {
        case .small: return "Small"
        case .medium: return "Medium"
        case .large: return "Large"
        case .hd720: return "HD720"
        case .hd1080: return "HD1080"
        case .highres: return "HighRes"
        case .auto: return "Auto"
        case .unknown: return "Unknown"
        }
    }
    static func from(string: String?) -> PlaybackQuality {
        guard let string = string else { return .unknown }
        return PlaybackQuality(rawValue: string) ?? .unknown
    }
}

enum PlayerError: Int, CaseIterable, CustomStringConvertible {
    case invalidParam = 2
    case html5Error = 5
    case videoNotFound = 100 // Covers 100, 105
    case notEmbeddable = 101 // Covers 101, 150
    case unknown = -99 // Fallback

    var description: String {
        switch self {
        case .invalidParam: return "Invalid Parameter (2)"
        case .html5Error: return "HTML5 Error (5)"
        case .videoNotFound: return "Video Not Found (100/105)"
        case .notEmbeddable: return "Not Embeddable (101/150)"
        case .unknown: return "Unknown Error"
        }
    }
    static func from(string: String?) -> PlayerError {
        guard let string = string, let val = Int(string) else { return .unknown }
        // Handle grouped error codes
        if val == 100 || val == 105 { return .videoNotFound }
        if val == 101 || val == 150 { return .notEmbeddable }
        return PlayerError(rawValue: val) ?? .unknown
    }
}

// --- Actions Enum for Control ---
enum PlayerAction: Equatable {
    static func == (lhs: PlayerAction, rhs: PlayerAction) -> Bool {
        return true
    }
    
    case loadVideo(id: String, vars: [String: Any]?)
    case loadPlaylist(id: String, vars: [String: Any]?)
    case play
    case pause
    case stop
    case seek(seconds: Float)
    case next
    case previous
    // Add other actions like cue, set quality etc. if needed
}

// --- Notification Name ---
extension Notification.Name {
    static let playbackStarted = Notification.Name("Playback started")
}


// --- HTML Content ---
// Bundled HTML Content for the YouTube IFrame Player Bridge
let youtubeHTML = """
<!DOCTYPE html>
<html>
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <style>
        body { margin: 0; width:100%; height:100%; background-color:#000000; overflow: hidden; }
        html { width:100%; height:100%; background-color:#000000; }
        .embed-container iframe,
        .embed-container object,
        .embed-container embed {
            position: absolute;
            top: 0;
            left: 0;
            width: 100% !important;
            height: 100% !important;
        }
    </style>
</head>
<body>
    <div class="embed-container">
        <div id="player"></div>
    </div>
    <!-- Error handling for API load failure -->
    <script src="https://www.youtube.com/iframe_api" onerror="handleApiLoadError()"></script>
    <script>
        var player;
        var HMTLInitData = %@; // DATA WILL BE INJECTED HERE
        var playTimeInterval;

        function handleApiLoadError() {
           // Send message back to native code that API failed to load
           if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.youtubePlayer) {
               window.webkit.messageHandlers.youtubePlayer.postMessage({ event: "apiLoadError" });
           } else {
                window.location.href = 'ytplayer://onYouTubeIframeAPIFailedToLoad';
           }
        }

        // Function called when the API is ready
        function onYouTubeIframeAPIReady() {
            if (typeof YT !== 'undefined' && YT.Player) {
                player = new YT.Player('player', HMTLInitData);
                 // Note: setSize is called by native code on bounds change
            } else {
                handleApiLoadError(); // API loaded but YT.Player is missing
            }
        }

        // --- Player Event Callbacks ---
        function onReady(event) {
            postMessageToNative('onReady');
        }

        function onStateChange(event) {
            postMessageToNative('onStateChange', event.data);
            // Manage Play Time interval based on state
            if (event.data == YT.PlayerState.PLAYING) {
                startPlayTimeUpdates();
            } else {
                stopPlayTimeUpdates();
            }
        }

        function onPlaybackQualityChange(event) {
            postMessageToNative('onPlaybackQualityChange', event.data);
        }

        function onPlayerError(event) {
            postMessageToNative('onError', event.data);
        }

        // --- Play Time Update ---
        function startPlayTimeUpdates() {
            stopPlayTimeUpdates(); // Clear any existing interval
            playTimeInterval = setInterval(function() {
                if (player && typeof player.getCurrentTime === 'function') {
                    var currentTime = player.getCurrentTime();
                    postMessageToNative('onPlayTime', currentTime);
                }
            }, 500); // Update every 500ms
        }

        function stopPlayTimeUpdates() {
            if (playTimeInterval) {
                clearInterval(playTimeInterval);
                playTimeInterval = null;
            }
        }

        // --- Communication Back to Swift ---
        function postMessageToNative(event, data) {
           var message = { event: event };
           if (data !== undefined) {
               message.data = data;
           }
           // Use WKScriptMessageHandler if available (preferred)
           if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.youtubePlayer) {
               window.webkit.messageHandlers.youtubePlayer.postMessage(message);
           } else {
               // Fallback to URL scheme for older implementations or edge cases
               var url = 'ytplayer://' + event;
               if (data !== undefined) {
                   url += '?data=' + encodeURIComponent(data);
               }
               window.location.href = url;
           }
       }

        // --- Resize Handling ---
        // Native code should call this on view resize
        function setPlayerSize(width, height) {
          if (player && typeof player.setSize === 'function') {
            player.setSize(width, height);
          }
        }

        // Initial call to signal JS is ready (if API loads async)
        postMessageToNative('jsReady');

    </script>
</body>
</html>
"""


// --- UIViewRepresentable for YouTube Player ---

struct YouTubePlayerView: UIViewRepresentable {
    // Input properties
    let videoId: String?
    let playlistId: String?
    let playerVars: [String: Any]?

    // Binding for triggering actions from SwiftUI View
    @Binding var playerAction: PlayerAction?

    // Callbacks for events from the player
    var onReady: (() -> Void)? = nil
    var onStateChange: ((PlayerState) -> Void)? = nil
    var onQualityChange: ((PlaybackQuality) -> Void)? = nil
    var onError: ((PlayerError) -> Void)? = nil
    var onPlayTime: ((Float) -> Void)? = nil

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> WKWebView {
        let coordinator = context.coordinator

        // Configure WKWebView
        let webViewConfig = WKWebViewConfiguration()
        webViewConfig.allowsInlineMediaPlayback = true // Essential for inline playback
        webViewConfig.mediaTypesRequiringUserActionForPlayback = [] // Allows autoplay if playerVars enable it

        // Setup communication bridge using WKScriptMessageHandler
        let contentController = WKUserContentController()
        contentController.add(coordinator, name: "youtubePlayer") // Matches JS message handler name
        webViewConfig.userContentController = contentController

        let webView = WKWebView(frame: .zero, configuration: webViewConfig)
        webView.navigationDelegate = coordinator
        webView.uiDelegate = coordinator // For handling potential popups/new windows
        webView.scrollView.isScrollEnabled = false // Disable scrolling within the webview
        webView.scrollView.bounces = false
        webView.backgroundColor = .black
        webView.isOpaque = true // Usually black background

        coordinator.webView = webView // Give coordinator a reference
        coordinator.setupNotificationObserver() // Setup notification listener

        // Initial Load based on provided properties
        DispatchQueue.main.async { // Ensure initial action happens after setup
             coordinator.performInitialLoad()
        }


        return webView
    }


    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Handle resizing. SwiftUI should manage frame, but maybe JS needs update?
        // Consider calling coordinator.updateSize(frame: uiView.frame) if necessary.
        context.coordinator.updateSize(frame: uiView.frame) // Tell JS player to resize

        // Handle actions requested by the SwiftUI view
        if let action = playerAction {
            print("SwiftUI PlayerAction Received: \(action)")
            context.coordinator.handleAction(action)
            // Reset the action binding after handling it
             DispatchQueue.main.async {
                 self.playerAction = nil
             }
        }

        // --- Handle potential changes in video/playlist ID ---
        // This logic determines if a reload is needed if the ID changes *after* initial load.
        // The `performInitialLoad` in the Coordinator handles the very first load.
        let coordinator = context.coordinator
        let needsReload: Bool

        if let videoId = videoId, coordinator.currentVideoId != videoId {
            needsReload = true
            coordinator.currentVideoId = videoId
            coordinator.currentPlaylistId = nil // Clear playlist if video is loaded
        } else if let playlistId = playlistId, coordinator.currentPlaylistId != playlistId {
            needsReload = true
            coordinator.currentPlaylistId = playlistId
            coordinator.currentVideoId = nil // Clear video if playlist is loaded
        } else {
            needsReload = false
        }

        if needsReload && coordinator.isPlayerReady { // Only reload if ID changed and player *was* ready
            print("ID changed, reloading player...")
            coordinator.performInitialLoad() // Trigger a reload with the new ID
        }
    }

    // --- Coordinator Class ---
    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
        var parent: YouTubePlayerView
        weak var webView: WKWebView?
        var notificationObserver: Any? = nil
        var isPlayerReady = false
        var playerSizeNeedsUpdate = false
        var lastKnownSize: CGRect = .zero

        // Track current content to avoid unnecessary reloads in updateUIView
        var currentVideoId: String? = nil
        var currentPlaylistId: String? = nil

        init(_ parent: YouTubePlayerView) {
            self.parent = parent
            self.currentVideoId = parent.videoId
            self.currentPlaylistId = parent.playlistId
        }

        deinit {
           // Clean up observers and message handlers
            if let observer = notificationObserver {
                NotificationCenter.default.removeObserver(observer)
                print("YouTube Player Notification Observer Removed")
            }
             webView?.configuration.userContentController.removeScriptMessageHandler(forName: "youtubePlayer")
            print("YouTube Player Script Message Handler Removed")

        }

        func setupNotificationObserver() {
            notificationObserver = NotificationCenter.default.addObserver(
                forName: .playbackStarted,
                object: nil, // Observe from any object
                queue: .main
            ) { [weak self] notification in
                 guard let self = self,
                       let postingCoordinator = notification.object as? Coordinator, // Check if object is Coordinator
                       postingCoordinator !== self // Check if it's NOT self
                 else {
                    return
                 }

                print("Notification received from other player, pausing this one.")
                // Pause this player if another one started playing
                self.webView?.evaluateJavaScript("player.pauseVideo();", completionHandler: nil)

            }
             print("YouTube Player Notification Observer Added")
        }

        // --- Initial Load ---
        func performInitialLoad() {
            guard let webView = webView else { return }
            isPlayerReady = false // Reset ready state on load

            let loadParams = createPlayerParameters()

            guard let jsonParamsData = try? JSONSerialization.data(withJSONObject: loadParams, options: .prettyPrinted),
                  let jsonParamsString = String(data: jsonParamsData, encoding: .utf8) else {
                print("Error: Could not serialize player parameters")
                parent.onError?(.invalidParam) // Signal an error
                return
            }

            // Inject parameters into HTML
            let finalHTML = youtubeHTML.replacingOccurrences(of: "%@", with: jsonParamsString)

            // Use loadHTMLString. The baseURL is important for origin checks in JS/API
             let bundleId = Bundle.main.bundleIdentifier ?? "com.unknown.app"
             // Ensure the URL is valid (lowercase, no special chars other than allowed)
             let originString = "http://" + bundleId.lowercased().filter { $0.isLetter || $0.isNumber || $0 == "." || $0 == "-" }
             let originURL = URL(string: originString) ?? URL(string: "http://com.example.app")! // Fallback URL

             print("Loading Player with Origin URL: \(originURL.absoluteString)")
             webView.loadHTMLString(finalHTML, baseURL: originURL)
        }

        // Helper to construct the parameters for JS YT.Player constructor
        private func createPlayerParameters() -> [String: Any] {
            var params: [String: Any] = [:]
            var playerVarsDict = parent.playerVars ?? [:]

            // --- Player Vars ---
            // Ensure 'origin' is set correctly for JS API security
             let bundleId = Bundle.main.bundleIdentifier ?? "com.unknown.app"
             let originString = "http://" + bundleId.lowercased().filter { $0.isLetter || $0.isNumber || $0 == "." || $0 == "-" }
             playerVarsDict["origin"] = originString // Crucial for JS API

            // Ensure playsinline is set for inline playback
            if playerVarsDict["playsinline"] == nil {
                playerVarsDict["playsinline"] = 1
            }
            // Ensure controls are specified if needed (0 = hides controls)
            // playerVarsDict["controls"] = 0 (Example if needed)

            params["playerVars"] = playerVarsDict

            // --- Events ---
            // These function names MUST match the functions defined in the JS part of youtubeHTML
            params["events"] = [
                "onReady": "onReady",
                "onStateChange": "onStateChange",
                "onPlaybackQualityChange": "onPlaybackQualityChange",
                "onError": "onPlayerError"
                // onPlayTime is handled by interval timer in JS now
            ]

            // --- Content ID ---
            if let videoId = parent.videoId {
                params["videoId"] = videoId
            } else if let playlistId = parent.playlistId {
                // Playlist requires specific playerVars structure
                var listVars = playerVarsDict
                listVars["listType"] = "playlist"
                listVars["list"] = playlistId
                params["playerVars"] = listVars // Override playerVars with playlist structure
            } else {
                 print("Warning: Neither videoId nor playlistId provided.")
                 // Maybe load a placeholder or default video?
                 // params["videoId"] = "dQw4w9WgXcQ" // Example default
            }

            // Width/Height needed by JS constructor but can be placeholders
            // Native code will resize via setPlayerSize JS call
            params["height"] = "100%"
            params["width"] = "100%"


            print("Player Params for JS: \(params)")
            return params
        }


        // --- Player Action Handling ---
        func handleAction(_ action: PlayerAction) {
            guard isPlayerReady, let webView = webView else {
                 print("Action ignored: Player not ready or webView missing.")
                 return
             }

            var jsCommand: String?

            switch action {
            case .loadVideo(let id, _): // Vars handled by triggering aRepresentable update
                 // This should ideally be handled by updateUIView detecting ID change
                 print("Load Video Action - should trigger updateUIView")
                 // We could force it here, but SwiftUI update flow is preferred
                 // performInitialLoad() // Re-evaluate if direct reload is needed
                 break
            case .loadPlaylist(let id, _):
                 print("Load Playlist Action - should trigger updateUIView")
                 // performInitialLoad()
                 break
            case .play:
                jsCommand = "player.playVideo();"
                // Post notification when *this* player starts
                 NotificationCenter.default.post(name: .playbackStarted, object: self)
                 print("Posted Playback Started notification from \(self)")
            case .pause:
                jsCommand = "player.pauseVideo();"
            case .stop:
                jsCommand = "player.stopVideo();"
            case .seek(let seconds):
                // Seek ahead should usually be true for better UX
                jsCommand = "player.seekTo(\(seconds), true);"
            case .next:
                jsCommand = "player.nextVideo();"
            case .previous:
                jsCommand = "player.previousVideo();"
            }

            if let command = jsCommand {
                webView.evaluateJavaScript(command) { result, error in
                    if let error = error {
                        print("JS Command Error (\(command)): \(error)")
                        // Optionally report error back to SwiftUI view
                    } else {
                         // print("JS Command Success: \(command)")
                    }
                }
            }
        }

         // --- WKScriptMessageHandler ---
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
             guard message.name == "youtubePlayer", // Ensure message is from our handler
                  let body = message.body as? [String: Any], // Expect a dictionary
                  let event = body["event"] as? String else {
                 print("Received invalid message from WKWebView: \(message.body)")
                 return
             }

             let data = body["data"] // Data might be nil or different types

             print("JS Bridge Received -> Event: \(event), Data: \(data ?? "nil")")

             switch event {
             case "jsReady":
                 // JavaScript environment is ready, API is likely loading.
                 print("JS Bridge: JavaScript environment ready.")
                 break // Often no action needed here, wait for onReady

             case "apiLoadError":
                 print("JS Bridge Error: YouTube IFrame API failed to load.")
                 parent.onError?(.html5Error) // Report as HTML5 error

             case "onReady":
                print("JS Bridge: Player Ready.")
                isPlayerReady = true
                parent.onReady?()
                 // If size update was deferred, apply it now
                 if playerSizeNeedsUpdate {
                     updateSize(frame: lastKnownSize)
                     playerSizeNeedsUpdate = false
                 }
             case "onStateChange":
                 let state = PlayerState.from(string: data as? String ?? "\(data ?? "")") // Handle Int/String data
                 print("JS Bridge: State Change - \(state.description)")
                 parent.onStateChange?(state)
             case "onPlaybackQualityChange":
                let quality = PlaybackQuality.from(string: data as? String)
                print("JS Bridge: Quality Change - \(quality.description)")
                parent.onQualityChange?(quality)
             case "onError":
                 let error = PlayerError.from(string: data as? String ?? "\(data ?? "")") // Handle Int/String data
                 print("JS Bridge: Error - \(error.description)")
                 parent.onError?(error)
             case "onPlayTime":
                 if let playTime = data as? Double { // JS numbers often come as Double
                      // print("JS Bridge: Play Time - \(Float(playTime))")
                      parent.onPlayTime?(Float(playTime))
                 }
             default:
                 print("JS Bridge: Received unknown event - \(event)")
             }
        }


       // --- WKNavigationDelegate Methods ---

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            print("WKWebView didFinish navigation (Initial HTML likely loaded)")
            // HTML is loaded, but JS player might still be initializing.
            // Wait for 'onReady' message via WKScriptMessageHandler.
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print("WKWebView didFail navigation: \(error)")
            isPlayerReady = false
            parent.onError?(.html5Error) // Report general webview fail
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            print("WKWebView didFailProvisionalNavigation: \(error)")
            isPlayerReady = false
            parent.onError?(.html5Error) // Report URL loading fail
        }

        // Policy decisions: Decide which navigation requests to allow/block
         func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
             guard let url = navigationAction.request.url else {
                 decisionHandler(.allow) // Allow if no URL
                 return
             }

            print("WKWebView Navigate To: \(url.absoluteString)")

            // --- Handle Custom Scheme (Fallback Method) ---
            // This is less preferred than WKScriptMessageHandler but kept as a backup concept
            if url.scheme == "ytplayer" {
                print("WKWebView Fallback Scheme Intercepted: \(url.absoluteString)")
                // Parse the URL and trigger corresponding callbacks (similar to ObjC version)
                // This should ideally NOT be hit if WKScriptMessageHandler is working.
                 handleLegacyCallbackUrl(url)
                decisionHandler(.cancel) // Don't navigate
                return
            }

            // --- Handle HTTP/HTTPS Navigation ---
            // Allow initial load (baseURL), YouTube embed URLs, ad URLs, auth URLs etc.
            // Block other external navigation attempts (open in Safari instead)
            // Extract domain for easier comparison
            let host = url.host?.lowercased()

            // Allowed Domains/Patterns (Refined from ObjC Regex)
             let allowedHosts = [
                 "youtube.com", "www.youtube.com",
                 "google.com", // For potential auth flows
                 "accounts.google.com",
                 "googlesyndication.com", "tpc.googlesyndication.com",
                 "doubleclick.net", "pubads.g.doubleclick.net",
                 "googleads.g.doubleclick.net",
                 "googleapis.com", // For things like static proxy
             ]

             // Get origin URL host used during loadHTMLString
             let originHost = webView.url?.host?.lowercased() // Origin might not be set yet, use load base
             let baseOriginHost = (webView.configuration.websiteDataStore.isPersistent) ? nil : URL(string:(webView.configuration.websiteDataStore.isPersistent) ? "http://localhost" : parent.playerVars?["origin"] as? String ?? "http://com.example.app")?.host?.lowercased() // The origin we *told* it load with


             if allowedHosts.contains(where: { host?.hasSuffix($0) ?? false }) || host == originHost || host == baseOriginHost {
                 // Allow navigation within YouTube, Google auth, ads, and the origin itself
                 decisionHandler(.allow)
             } else if url.scheme == "http" || url.scheme == "https" {
                 // External URL clicked, open in system browser
                 print("WKWebView blocked external navigation, opening in Safari: \(url.absoluteString)")
                 if UIApplication.shared.canOpenURL(url) {
                     UIApplication.shared.open(url, options: [:], completionHandler: nil)
                 }
                 decisionHandler(.cancel) // Block in WebView
             } else {
                 // Allow other schemes (like mailto:, tel:, etc.)
                 decisionHandler(.allow)
             }
        }


        // Fallback for ytplayer:// scheme (if WKScriptMessageHandler fails/not used)
        private func handleLegacyCallbackUrl(_ url: URL) {
            guard let action = url.host else { return }
            let data = url.query?.components(separatedBy: "=").last // Simple parsing

            print("Legacy Callback Handling -> Action: \(action), Data: \(data ?? "nil")")

            switch action {
             case "onYouTubeIframeAPIFailedToLoad":
                 isPlayerReady = false
                 parent.onError?(.html5Error)
             case "onReady":
                 isPlayerReady = true
                 parent.onReady?()
                  if playerSizeNeedsUpdate {
                     updateSize(frame: lastKnownSize)
                     playerSizeNeedsUpdate = false
                 }
             case "onStateChange":
                 parent.onStateChange?(PlayerState.from(string: data))
             case "onPlaybackQualityChange":
                 parent.onQualityChange?(PlaybackQuality.from(string: data))
             case "onError":
                 parent.onError?(PlayerError.from(string: data))
             case "onPlayTime":
                 if let timeString = data, let time = Float(timeString) {
                     parent.onPlayTime?(time)
                 }
             default:
                print("Legacy Callback: Unknown action \(action)")
            }
        }

         // --- WKUIDelegate ---
        // Handle requests to open new windows (e.g., target="_blank" links)
        func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
            // If a link tries to open a new window, intercept and open in Safari instead
            if let url = navigationAction.request.url {
                 print("WKWebView intercepted new window request for: \(url.absoluteString)")
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
            return nil // Prevent WKWebView from creating a new window
        }

        // --- Resizing ---
        func updateSize(frame: CGRect) {
            guard frame != .zero, frame != lastKnownSize else { return }
            lastKnownSize = frame

            if isPlayerReady {
                // print("Updating Player Size: \(frame.size)")
                let jsCommand = "setPlayerSize(\(frame.width), \(frame.height));"
                webView?.evaluateJavaScript(jsCommand, completionHandler: nil)
            } else {
                // If player isn't ready yet, defer size update
                playerSizeNeedsUpdate = true
                print("Player not ready, deferred size update: \(frame.size)")
            }
        }
    }
}

// --- SwiftUI Views ---

struct SingleVideoView: View {
    @State private var playerAction: PlayerAction? = nil
    @State private var statusText: String = "Player Status:\n"
    @State private var sliderValue: Float = 0.0
    @State private var sliderIsEditing: Bool = false
    @State private var lastPlayTime: Float = 0.0
    @State private var videoDuration: Float = 1.0 // Avoid division by zero

    // Define player variables for this view
    let playerVars: [String: Any] = [
        "controls": 0, // Hide native controls
        "playsinline": 1, // Play inline MUST be 1
        "autohide": 1,
        "showinfo": 0,
        "modestbranding": 1
    ]
    let videoId = "M7lc1UVf-VE" // Example Video ID

    var body: some View {
        VStack {
            YouTubePlayerView(
                videoId: videoId,
                playlistId: nil,
                playerVars: playerVars,
                playerAction: $playerAction,
                onReady: {
                    appendStatus("Player Ready")
                },
                onStateChange: { state in
                    appendStatus("State: \(state.description)")
                    // Could update UI based on state, e.g., disable play button if playing
                     if state == .ended {
                         lastPlayTime = 0 // Reset time on end
                         sliderValue = 0
                     }
                },
                onQualityChange: { quality in
                    appendStatus("Quality: \(quality.description)")
                },
                onError: { error in
                     appendStatus("Error: \(error.description)")
                },
                onPlayTime: { time in
                     // Only update slider if user isn't actively dragging it
                    if !sliderIsEditing {
                        lastPlayTime = time
                        // Fetch duration async if needed, or assume it was fetched on ready/state change
                        // For simplicity here, we assume duration is known or fetched elsewhere
                        // In a real app, might need another @State for duration
                         sliderValue = (videoDuration > 0) ? time / videoDuration : 0
                    }
                }
            )
            .border(Color.gray) // Add border for visibility
            .padding(.horizontal)

            // --- Controls ---
             VStack {
                 Slider(value: $sliderValue, in: 0...1, onEditingChanged: sliderEditingChanged)
                     .padding(.horizontal)

                 HStack(spacing: 10) {
                    Button("|<") { playerAction = .seek(seconds: 0); appendStatus("Seek to Start") }
                    Button("<<") { playerAction = .seek(seconds: max(0, lastPlayTime - 30)); appendStatus("Seek Back 30s") }
                    Button("Play") { playerAction = .play }
                    Button("Pause") { playerAction = .pause }
                     Button("Stop") { playerAction = .stop } // Stop often behaves like pause+seek(0)
                    Button(">>") { playerAction = .seek(seconds: lastPlayTime + 30); appendStatus("Seek Fwd 30s") }
                 }
                 .padding(.bottom, 5)
             }


            // --- Status Area ---
            ScrollView {
                Text(statusText)
                    .font(.footnote)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
            }
            .frame(height: 100) // Fixed height for status area
            .border(Color.gray)
            .padding(.horizontal)

        }
        .onAppear {
            // Fetch duration once when the view appears or player is ready
            // For now, we just set a default
            fetchDuration() // TODO: Implement proper async duration fetch if needed
        }
        .navigationTitle("Single Video")
         .navigationBarTitleDisplayMode(.inline)
    }

    private func appendStatus(_ message: String) {
        statusText += "\(message)\n"
        print(message) // Also log to console
    }

    // Fake duration fetch for example
    private func fetchDuration() {
        // In a real app, you'd use evaluateJavascript to call player.getDuration()
        // and update a @State variable. Here we hardcode.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { // Simulate delay
            self.videoDuration = 245 // Example duration for video M7lc1UVf-VE
            appendStatus("Duration set: \(videoDuration)s (Simulated)")
        }
    }

    private func sliderEditingChanged(editing: Bool) {
        sliderIsEditing = editing
        if !editing {
            // User finished dragging, trigger the seek action
             let seekTime = sliderValue * videoDuration
            playerAction = .seek(seconds: seekTime)
             appendStatus("Seek to: \(Int(seekTime))s")
        } else {
            // User started dragging
        }
    }
}

struct PlaylistView: View {
    @State private var playerAction: PlayerAction? = nil
    @State private var statusText: String = "Player Status:\n"

    let playerVars: [String: Any] = [
        "controls": 0,
        "playsinline": 1,
        "autohide": 1,
        "showinfo": 0,
        "modestbranding": 1
    ]
    // Example Playlist ID (Google Developers channel)
     let playlistId = "PLKC17Q5JdQGjQ_GMWF_zljn6ueM5FNysk"
    //let playlistId = "PLhBgTdAWkxeCMHYCQ0uuLyhydRJGDRNo5" // Original from ObjC code

    var body: some View {
        VStack {
            YouTubePlayerView(
                videoId: nil,
                playlistId: playlistId,
                playerVars: playerVars,
                playerAction: $playerAction,
                onReady: {
                    appendStatus("Player Ready")
                },
                onStateChange: { state in
                    appendStatus("State: \(state.description)")
                },
                onError: { error in
                     appendStatus("Error: \(error.description)")
                }
                 // Add other callbacks if needed (quality, playTime...)
            )
            .border(Color.gray)
            .padding(.horizontal)

            // --- Controls ---
             HStack(spacing: 10) {
                Button("<< Prev") { playerAction = .previous; appendStatus("Load Previous") }
                Button("Play") { playerAction = .play }
                Button("Pause") { playerAction = .pause }
                 Button("Stop") { playerAction = .stop }
                Button("Next >>") { playerAction = .next; appendStatus("Load Next") }
             }
             .padding(.bottom, 5)

            // --- Status Area ---
            ScrollView {
                Text(statusText)
                    .font(.footnote)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
            }
            .frame(height: 100)
            .border(Color.gray)
            .padding(.horizontal)

            Spacer() // Push content to top
        }
         .navigationTitle("Playlist")
         .navigationBarTitleDisplayMode(.inline)
    }

    private func appendStatus(_ message: String) {
        statusText += "\(message)\n"
        print(message) // Also log to console
    }
}


// --- Main App Structure ---

@main
struct YouTubePlayerSwiftUIApp: App {
    // If AppDelegate logic is needed (e.g., global setup), use an adaptor:
    // @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            TabView {
                NavigationView { // Embed each view in a NavigationView for titles
                     SingleVideoView()
                 }
                .tabItem {
                    Label("Single Video", systemImage: "video")
                }
                .navigationViewStyle(.stack) // Use stack style

                NavigationView {
                    PlaylistView()
                }
                .tabItem {
                    Label("Playlist", systemImage: "list.and.film")
                }
                 .navigationViewStyle(.stack)
            }
        }
    }
}

// Optional: If you needed an AppDelegate for specific setup
// class AppDelegate: NSObject, UIApplicationDelegate {
//    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
//        print("App Delegate: Did finish launching")
//        // Perform any initial setup here if needed
//        return true
//    }
// }
