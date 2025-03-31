//
//  Helper.swift
//  MyApp
//
//  Created by Cong Le on 3/30/25.
//

import SwiftUI
@preconcurrency import WebKit

// MARK: - Enums (Replicating Original Concepts)

/// Represents the state of the current video in the player.
public enum PlayerState: Int, Equatable {
    case unstarted = -1
    case ended = 0
    case playing = 1
    case paused = 2
    case buffering = 3
    case cued = 5
    case unknown
}

/// Represents the resolution of the currently loaded video.
public enum PlaybackQuality: String, Equatable {
    case small
    case medium
    case large
    case hd720
    case hd1080
    case highRes
    case auto // Addition for YouTube Live Events.
    case unknown // Should never be returned. For future proofing.
    // Note: 'default' is a keyword, mapping conceptually
}

/// Represents error codes thrown by the player.
public enum PlayerError: Int, Equatable, Error {
    case invalidParam = 2
    case html5Error = 5
    case videoNotFound = 100 // Also covers 105
    case notEmbeddable = 101 // Also covers 150
    case unknown
}

// MARK: - Player Configuration

/// Configuration parameters for the YouTube player.
public struct PlayerConfig {
    let playerVars: [String: Any]?
    let videoId: String?
    let playlistId: String?

    public init(videoId: String, playerVars: [String: Any]? = nil) {
        self.videoId = videoId
        self.playlistId = nil
        self.playerVars = playerVars ?? ["playsinline": 1] // Default to inline playback
    }

    public init(playlistId: String, playerVars: [String: Any]? = nil) {
        self.videoId = nil
        self.playlistId = playlistId
        self.playerVars = playerVars ?? ["playsinline": 1]
    }

    // Internal representation suitable for JS API
    func buildPlayerParameters() -> [String: Any] {
        var params: [String: Any] = ["height": "100%", "width": "100%"]
        var finalPlayerVars = self.playerVars ?? [:]

        // Ensure origin is set for JS API security
        if let bundleId = Bundle.main.bundleIdentifier {
             finalPlayerVars["origin"] = "http://\(bundleId.lowercased())"
        } else {
             finalPlayerVars["origin"] = "http://com.example.unknown" // Fallback origin
        }

        // Add mandatory event callbacks for Coordinator
        params["events"] = [
            "onReady": "onReady",
            "onStateChange": "onStateChange",
            "onPlaybackQualityChange": "onPlaybackQualityChange",
            "onError": "onPlayerError",
            "onPlayTime": "onPlayTime" // Assuming YTPlayerView-iframe-player.html functionality
        ]

        if let videoId = self.videoId {
            params["videoId"] = videoId
        } else if let playlistId = self.playlistId {
            finalPlayerVars["listType"] = "playlist"
            finalPlayerVars["list"] = playlistId
        }

        params["playerVars"] = finalPlayerVars
        return params
    }
}


// MARK: - YouTubePlayerView (SwiftUI Interface)

public struct YouTubePlayerView: View {

    // Configuration
    private let configuration: PlayerConfig

    // Coordinator to manage WKWebView and commands/callbacks
    @StateObject private var coordinator = Coordinator()

    // Callbacks (SwiftUI style replacement for Delegate)
    private var onReady: ((YouTubePlayerAPI) -> Void)?
    private var onStateChange: ((PlayerState) -> Void)?
    private var onQualityChange: ((PlaybackQuality) -> Void)?
    private var onError: ((PlayerError) -> Void)?
    private var onPlayTime: ((Double) -> Void)? // Changed to Double for precision
    private var preferredInitialLoadingView: (() -> AnyView)?
    private var preferredWebViewBackgroundColor: Color = .black // Default background


    /// Initialize with a specific Video ID.
    public init(videoId: String, playerVars: [String: Any]? = nil) {
        self.configuration = PlayerConfig(videoId: videoId, playerVars: playerVars)
    }

    /// Initialize with a specific Playlist ID.
    public init(playlistId: String, playerVars: [String: Any]? = nil) {
        self.configuration = PlayerConfig(playlistId: playlistId, playerVars: playerVars)
    }

    // Builder-style modifiers for callbacks (SwiftUI convention)
    public func onReady(perform action: @escaping (YouTubePlayerAPI) -> Void) -> Self {
        var view = self
        view.onReady = action
        return view
    }

    public func onStateChange(perform action: @escaping (PlayerState) -> Void) -> Self {
        var view = self
        view.onStateChange = action
        return view
    }

    public func onQualityChange(perform action: @escaping (PlaybackQuality) -> Void) -> Self {
        var view = self
        view.onQualityChange = action
        return view
    }

    public func onError(perform action: @escaping (PlayerError) -> Void) -> Self {
        var view = self
        view.onError = action
        return view
    }

    public func onPlayTime(perform action: @escaping (Double) -> Void) -> Self {
        var view = self
        view.onPlayTime = action
        return view
    }

    /// Sets a custom view to show while the iframe API is initially loading.
    public func initialLoadingView<Content: View>(@ViewBuilder _ view: @escaping () -> Content) -> Self {
        var newSelf = self
        newSelf.preferredInitialLoadingView = { AnyView(view()) }
        return newSelf
    }

    /// Sets the preferred background color of the underlying WebView.
    public func webViewBackgroundColor(_ color: Color) -> Self {
        var newSelf = self
        newSelf.preferredWebViewBackgroundColor = color
        return newSelf
    }


    public var body: some View {
        WebViewRepresentable(
            configuration: configuration,
            coordinator: coordinator,
            onReady: onReady,
            onStateChange: onStateChange,
            onQualityChange: onQualityChange,
            onError: onError,
            onPlayTime: onPlayTime,
            preferredInitialLoadingView: preferredInitialLoadingView,
            preferredWebViewBackgroundColor: preferredWebViewBackgroundColor
        )
        .environmentObject(coordinator) // Make coordinator available for API calls
    }
}

// MARK: - Asynchronous API Accessor (Passed to onReady)

/// Provides a programmatic interface to control the YouTube player once ready.
public struct YouTubePlayerAPI {
    private weak var coordinator: YouTubePlayerView.Coordinator?

    init(coordinator: YouTubePlayerView.Coordinator) {
        self.coordinator = coordinator
    }

    // Player Controls
    @MainActor public func play() { coordinator?.evaluateJavaScript("player.playVideo();") }
    @MainActor public func pause() { coordinator?.evaluateJavaScript("player.pauseVideo();") }
    @MainActor public func stop() { coordinator?.evaluateJavaScript("player.stopVideo();") }
    @MainActor public func seek(to seconds: Double, allowSeekAhead: Bool) {
        coordinator?.evaluateJavaScript("player.seekTo(\(seconds), \(allowSeekAhead ? "true" : "false"));")
    }

    // Cueing Videos
    @MainActor public func cue(videoId: String, startSeconds: Double = 0) {
        coordinator?.evaluateJavaScript("player.cueVideoById('\(videoId)', \(startSeconds));")
    }
    @MainActor public func cue(videoId: String, startSeconds: Double, endSeconds: Double) {
        coordinator?.evaluateJavaScript("player.cueVideoById({'videoId': '\(videoId)', 'startSeconds': \(startSeconds), 'endSeconds': \(endSeconds)});")
    }
    // ... similar methods for cueVideoByUrl ...

    // Loading Videos (Loads and plays)
    @MainActor public func load(videoId: String, startSeconds: Double = 0) {
        coordinator?.evaluateJavaScript("player.loadVideoById('\(videoId)', \(startSeconds));")
    }
    @MainActor public func load(videoId: String, startSeconds: Double, endSeconds: Double) {
        coordinator?.evaluateJavaScript("player.loadVideoById({'videoId': '\(videoId)', 'startSeconds': \(startSeconds), 'endSeconds': \(endSeconds)});")
    }
    // ... similar methods for loadVideoByUrl ...

    // Cueing Playlists
    @MainActor public func cue(playlistId: String, index: Int = 0, startSeconds: Double = 0) {
         coordinator?.evaluateJavaScript("player.cuePlaylist('\(playlistId)', \(index), \(startSeconds));")
    }
    @MainActor public func cue(videoIds: [String], index: Int = 0, startSeconds: Double = 0) {
         let arrayString = videoIds.map { "'\($0)'" }.joined(separator: ", ")
         coordinator?.evaluateJavaScript("player.cuePlaylist([\(arrayString)], \(index), \(startSeconds));")
    }

    // Loading Playlists
    @MainActor public func load(playlistId: String, index: Int = 0, startSeconds: Double = 0) {
          coordinator?.evaluateJavaScript("player.loadPlaylist('\(playlistId)', \(index), \(startSeconds));")
    }
    @MainActor public func load(videoIds: [String], index: Int = 0, startSeconds: Double = 0) {
          let arrayString = videoIds.map { "'\($0)'" }.joined(separator: ", ")
          coordinator?.evaluateJavaScript("player.loadPlaylist([\(arrayString)], \(index), \(startSeconds));")
    }

    // Playlist Controls
    @MainActor public func nextVideo() { coordinator?.evaluateJavaScript("player.nextVideo();") }
    @MainActor public func previousVideo() { coordinator?.evaluateJavaScript("player.previousVideo();") }
    @MainActor public func playVideo(at index: Int) { coordinator?.evaluateJavaScript("player.playVideoAt(\(index));") }

    // Playback Rate
    @MainActor public func set(playbackRate: Float) {
        coordinator?.evaluateJavaScript("player.setPlaybackRate(\(playbackRate));")
    }

    // Playlist Behaviour
    @MainActor public func setLoop(_ loop: Bool) {
        coordinator?.evaluateJavaScript("player.setLoop(\(loop ? "true" : "false"));")
    }
    @MainActor public func setShuffle(_ shuffle: Bool) {
        coordinator?.evaluateJavaScript("player.setShuffle(\(shuffle ? "true" : "false"));")
    }

    // --- Async Getters (Returning values via async/await) ---

    public func getPlaybackRate() async throws -> Float {
        try await coordinator?.evaluateJavaScriptAsync("player.getPlaybackRate();") as? Float ?? 0.0
    }

    public func getAvailablePlaybackRates() async throws -> [Float] {
        let result = try await coordinator?.evaluateJavaScriptAsync("player.getAvailablePlaybackRates();") as? [NSNumber]
        return result?.map { $0.floatValue } ?? []
    }

    public func getVideoLoadedFraction() async throws -> Float {
        try await coordinator?.evaluateJavaScriptAsync("player.getVideoLoadedFraction();") as? Float ?? 0.0
    }

     public func getPlayerState() async throws -> PlayerState {
         guard let stateInt = try await coordinator?.evaluateJavaScriptAsync("player.getPlayerState();") as? Int else {
             return .unknown
         }
         return PlayerState(rawValue: stateInt) ?? .unknown
     }

    public func getCurrentTime() async throws -> Double {
        try await coordinator?.evaluateJavaScriptAsync("player.getCurrentTime();") as? Double ?? 0.0
    }

    public func getDuration() async throws -> Double {
        try await coordinator?.evaluateJavaScriptAsync("player.getDuration();") as? Double ?? 0.0
    }

    public func getVideoUrl() async throws -> URL? {
        guard let urlString = try await coordinator?.evaluateJavaScriptAsync("player.getVideoUrl();") as? String else {
          return nil
        }
        return URL(string: urlString)
    }

    public func getVideoEmbedCode() async throws -> String? {
         try await coordinator?.evaluateJavaScriptAsync("player.getVideoEmbedCode();") as? String
    }

    public func getPlaylist() async throws -> [String]? {
         try await coordinator?.evaluateJavaScriptAsync("player.getPlaylist();") as? [String]
    }

     public func getPlaylistIndex() async throws -> Int {
         try await coordinator?.evaluateJavaScriptAsync("player.getPlaylistIndex();") as? Int ?? -1
     }
}


// MARK: - WebViewRepresentable (Bridge to WKWebView)

struct WebViewRepresentable: UIViewRepresentable {
    let configuration: PlayerConfig
    @ObservedObject var coordinator: YouTubePlayerView.Coordinator

    // Callbacks to pass to Coordinator
    let onReady: ((YouTubePlayerAPI) -> Void)?
    let onStateChange: ((PlayerState) -> Void)?
    let onQualityChange: ((PlaybackQuality) -> Void)?
    let onError: ((PlayerError) -> Void)?
    let onPlayTime: ((Double) -> Void)?
    let preferredInitialLoadingView: (() -> AnyView)?
    let preferredWebViewBackgroundColor: Color

    func makeUIView(context: Context) -> WKWebView {
        let webView = coordinator.getWebView() // Coordinator manages the WKWebView instance

        // Add initial loading view if provided
        if let loadingViewBuilder = preferredInitialLoadingView {
            let hostingController = UIHostingController(rootView: loadingViewBuilder())
            hostingController.view.frame = webView.bounds
            hostingController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            hostingController.view.backgroundColor = .clear // Allow webview color to show
             webView.addSubview(hostingController.view)
            coordinator.initialLoadingUIView = hostingController.view // Hold reference to remove later
            coordinator.initialLoadingViewController = hostingController // Keep controller alive
        }

        coordinator.load(config: configuration) // Use coordinator to load
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Potential future use: Reload if configuration changes significantly.
        // Be careful, as reloading is expensive. Often better handled via API calls.
        // Example: If config ID changes, tell coordinator to load new ID via JS API
        // coordinator.load(videoId: newConfig.videoId) // This would call JS, not reload HTML
    }

    // Connect Coordinator for delegate methods
    func makeCoordinator() -> YouTubePlayerView.Coordinator {
        coordinator.parent = self // Link back representable to coordinator
        return coordinator
    }

     // Clean up WKWebView resources
     static func dismantleUIView(_ uiView: WKWebView, coordinator: YouTubePlayerView.Coordinator) {
         coordinator.cleanup()
     }
}

// MARK: - Coordinator (Handles WKWebView Delegate and JS Communication)

extension YouTubePlayerView {

    @MainActor // Ensure coordinator updates run on the main thread
    final class Coordinator: NSObject, ObservableObject, WKNavigationDelegate, WKUIDelegate {
        weak var parent: WebViewRepresentable?
        var webView: WKWebView?
        var api: YouTubePlayerAPI? // Hold the API instance

        var initialLoadingUIView: UIView?
        var initialLoadingViewController: UIViewController? // Keep strong ref

        private var isReady: Bool = false // Track if player API is ready
        private var pendingJSEvaluation: [(String, CheckedContinuation<Any?, Error>)] = [] // Queue for async JS


        override init() {
            super.init()
            self.api = YouTubePlayerAPI(coordinator: self) // Initialize API accessor
        }

        func getWebView() -> WKWebView {
            if let existingWebView = webView {
                return existingWebView
            }

            let config = WKWebViewConfiguration()
            config.allowsInlineMediaPlayback = true // Essential for inline playback
            // config.mediaTypesRequiringUserActionForPlayback = [] // Removed in newer iOS/iPadOS, use below
             config.setValue(true, forKey: "_requiresUserActionForMediaPlayback") // Allow autoplay
             config.setValue(true, forKey: "_mediaDataLoadsAutomatically") // Recommended

            let newWebView = WKWebView(frame: .zero, configuration: config)
            newWebView.navigationDelegate = self
            newWebView.uiDelegate = self
            newWebView.scrollView.isScrollEnabled = false // Disable scrolling
            newWebView.scrollView.bounces = false
            newWebView.isOpaque = false // Allow background color to show through
            newWebView.backgroundColor = UIColor(parent?.preferredWebViewBackgroundColor ?? .black)

            self.webView = newWebView
            return newWebView
        }

        func cleanup() {
              webView?.stopLoading()
              webView?.navigationDelegate = nil
              webView?.uiDelegate = nil
              webView?.removeFromSuperview()
              webView = nil
              initialLoadingUIView?.removeFromSuperview()
              initialLoadingUIView = nil
              initialLoadingViewController = nil // Release controller
              isReady = false
              // Fail any pending continuations
              pendingJSEvaluation.forEach { $0.1.resume(throwing: CancellationError()) }
              pendingJSEvaluation.removeAll()
          }


        func load(config: PlayerConfig) {
            guard let webView = webView else { return }

            let playerParams = config.buildPlayerParameters()

            guard let htmlPath = findHTMLPath(),
                  let htmlTemplate = try? String(contentsOfFile: htmlPath, encoding: .utf8),
                  let jsonData = try? JSONSerialization.data(withJSONObject: playerParams, options: .prettyPrinted), // Use prettyPrinted for debug
                  let jsonString = String(data: jsonData, encoding: .utf8) else {
                print("Error: Could not load HTML template or serialize player parameters.")
                parent?.onError?(.unknown) // Notify of loading error
                return
            }

            let finalHTML = String(format: htmlTemplate, jsonString)
            // Determine the origin URL
            let originString = (playerParams["playerVars"] as? [String: Any])?["origin"] as? String ?? "http://com.example.local"
            let originURL = URL(string: originString)!

            webView.loadHTMLString(finalHTML, baseURL: originURL)
        }

        // --- WKNavigationDelegate Methods ---

        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            guard let url = navigationAction.request.url else {
                decisionHandler(.allow)
                return
            }

            // Intercept custom scheme callbacks
            if url.scheme == "ytplayer" {
                handleCallback(from: url)
                decisionHandler(.cancel)
                return
            }

            // Allow initial load based on origin/baseURL
            if url.absoluteString == webView.url?.absoluteString || url.absoluteString == webView.configuration.websiteDataStore.httpCookieStore.accessibilityElementsHidden {
                 decisionHandler(.allow)
                 return
             }

            // Mimic original behavior for external links vs allowed domains
             if url.scheme == "http" || url.scheme == "https" {
                 if shouldAllowNavigation(to: url) {
                     decisionHandler(.allow)
                 } else {
                     // Open external links in Safari
                     UIApplication.shared.open(url, options: [:], completionHandler: nil)
                     decisionHandler(.cancel)
                 }
                 return
             }


            decisionHandler(.allow) // Allow other schemes by default
        }

          func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
              print("WKWebView didFail navigation: \(error)")
              if let loadingView = initialLoadingUIView {
                  loadingView.removeFromSuperview()
                  initialLoadingUIView = nil
                  initialLoadingViewController = nil
              }
              parent?.onError?(.unknown) // Or potentially map error codes if possible
          }

          func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
               print("WKWebView didFailProvisionalNavigation: \(error)")
                if let loadingView = initialLoadingUIView {
                  loadingView.removeFromSuperview()
                  initialLoadingUIView = nil
                  initialLoadingViewController = nil // Release controller
              }
               // Check for specific errors like "Frame load interrupted" which might happen on rapid reloads
               let nsError = error as NSError
               if nsError.domain == "WebKitErrorDomain" && nsError.code == 102 {
                   print("Frame load interrupted - potentially okay if reloading.")
               } else {
                    parent?.onError?(.unknown) // Treat other provisional load errors as problems
               }
          }


        // --- WKUIDelegate ---
         func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
              // Handle links that try to open new windows (_blank targets)
              if let url = navigationAction.request.url, navigationAction.targetFrame == nil {
                   if UIApplication.shared.canOpenURL(url) {
                       UIApplication.shared.open(url, options: [:], completionHandler: nil)
                   }
              }
              return nil // Don't allow WKWebView to create new webviews
         }

        // --- JavaScript Communication ---

        func evaluateJavaScript(_ script: String) {
             guard let webView = webView else { return }
                    webView.evaluateJavaScript(script, completionHandler: nil) // Fire and forget
        }


        func evaluateJavaScriptAsync(_ script: String) async throws -> Any? {
             guard let webView = webView else { throw PlayerError.unknown } // Should have a webview if API is available

             return try await withCheckedThrowingContinuation { continuation in
                 // If API not ready, queue the call
                 guard isReady else {
                     pendingJSEvaluation.append((script, continuation))
                     return
                 }

                 webView.evaluateJavaScript(script) { (result, error) in
                     if let error = error {
                         continuation.resume(throwing: error)
                     } else {
                         continuation.resume(returning: result)
                     }
                 }
             }
          }


        // --- Callback Handling ---

        private func handleCallback(from url: URL) {
            guard let host = url.host else { return }

            // Extract data payload if present
            let dataString = url.query?.components(separatedBy: "=").last?.removingPercentEncoding

            switch host {
            case "onReady":
                isReady = true
                // Remove initial loading view
                 if let loadingView = initialLoadingUIView {
                     loadingView.removeFromSuperview()
                     initialLoadingUIView = nil
                     initialLoadingViewController = nil // Release controller
                 }
                 // Provide the API object to the user
                if let api = self.api {
                     parent?.onReady?(api)
                }
                 // Process any queued JS calls
                processPendingJSEvaluations()

            case "onStateChange":
                let state = PlayerState(rawValue: Int(dataString ?? "") ?? -99) ?? .unknown
                parent?.onStateChange?(state)

            case "onPlaybackQualityChange":
                let quality = PlaybackQuality(rawValue: dataString ?? "") ?? .unknown
                parent?.onQualityChange?(quality)

            case "onError":
                let error = PlayerError(rawValue: Int(dataString ?? "") ?? -99) ?? .unknown
                parent?.onError?(error)

            case "onPlayTime":
                if let time = Double(dataString ?? "") {
                    parent?.onPlayTime?(time)
                }
             case "onYouTubeIframeAPIFailedToLoad":
                   print("Error: YouTube IFrame API failed to load. Check network connection.")
                    if let loadingView = initialLoadingUIView {
                        loadingView.removeFromSuperview()
                        initialLoadingUIView = nil
                        initialLoadingViewController = nil
                    }
                   parent?.onError?(.html5Error) // Treat as HTML error

            default:
                print("Received unknown callback: \(url)")
            }
        }

         private func processPendingJSEvaluations() {
             guard isReady, let webView = webView, !pendingJSEvaluation.isEmpty else { return }

             let queue = pendingJSEvaluation
             pendingJSEvaluation.removeAll() // Clear the queue first

             queue.forEach { script, continuation in
                 webView.evaluateJavaScript(script) { result, error in
                     if let error = error {
                         continuation.resume(throwing: error)
                     } else {
                         continuation.resume(returning: result)
                     }
                 }
             }
         }

        // --- Helper Methods ---

        private func findHTMLPath() -> String? {
             // Try finding the resource in the main bundle first
            if let path = Bundle.main.path(forResource: "YTPlayerView-iframe-player", ofType: "html") {
                 return path
             }
             // Try finding the resource via Bundle(for: Coordinator.self) in case it's in a framework/package
             if let path = Bundle(for: Coordinator.self).path(forResource: "YTPlayerView-iframe-player", ofType: "html", inDirectory: nil) {
                 // Check if running in SPM context where resources might be nested
                 if path.contains(".bundle/") {
                      return path // Use path directly if it looks like SPM bundle structure
                 }
                 #if SWIFT_PACKAGE
                     // If compiled as SPM, resource might be in the module bundle
                       if let moduleBundlePath = Bundle.module.path(forResource: "YTPlayerView-iframe-player", ofType: "html") {
                         return moduleBundlePath
                     }
                 #endif
             }
             // Fallback check for CocoaPods resources bundle
             if let cocoapodsBundleURL = Bundle(for: Coordinator.self).url(forResource: "YouTubeiOSPlayerHelper", withExtension: "bundle"),
                let resourcesBundle = Bundle(url: cocoapodsBundleURL),
                let path = resourcesBundle.path(forResource: "YTPlayerView-iframe-player", ofType: "html") {
                 return path
             }


             print("Error: YTPlayerView-iframe-player.html not found.")
             return nil
        }

        private func shouldAllowNavigation(to url: URL) -> Bool {
             // Basic regex patterns (use proper NSRegularExpression for production)
             let urlString = url.absoluteString
             let embedPattern = #"^https?://(www\.)?youtube\.com/embed/.*"#
             let adPattern = #"^https?://pubads\.g\.doubleclick\.net/pagead/conversion/.*"#
             let oauthPattern = #"^https?://accounts\.google\.com/o/oauth2/.*"#
             let staticProxyPattern = #"^https://content\.googleapis\.com/static/proxy\.html.*"#
             let syndicationPattern = #"^https://tpc\.googlesyndication\.com/sodar/.*\.html"#
             let originHost = webView?.url?.host // Check against the initial base URL host

            if let originHost = originHost, url.host?.lowercased() == originHost.lowercased() {
                return true // Allow navigation to the origin itself
            }
             if urlString.range(of: embedPattern, options: .regularExpression) != nil ||
                urlString.range(of: adPattern, options: .regularExpression) != nil ||
                urlString.range(of: oauthPattern, options: .regularExpression) != nil ||
                urlString.range(of: staticProxyPattern, options: .regularExpression) != nil ||
                urlString.range(of: syndicationPattern, options: .regularExpression) != nil {
                 return true
             }
             return false
         }
    }
}

// MARK: - Example Usage (Illustrative)

struct ContentView_YouTubeExample: View {
    @State private var playerState: PlayerState = .unknown
    @State private var currentTime: Double = 0.0
    @State private var api: YouTubePlayerAPI? // Hold the API to call methods

    var body: some View {
        VStack {
            YouTubePlayerView(videoId: "M7lc1UVf-VE") // Example Video ID
                .frame(height: 250)
                .onReady { playerAPI in
                    print("Player is ready!")
                    self.api = playerAPI // Store the API
                    // Optionally start playback or perform other actions
                    // playerAPI.play()
                     Task {
                         do {
                             let duration = try await playerAPI.getDuration()
                             print("Video duration: \(duration)")
                         } catch {
                             print("Failed to get duration: \(error)")
                         }
                     }
                }
                .onStateChange { state in
                    print("State changed: \(state)")
                    self.playerState = state
                }
                .onError { error in
                    print("Player error: \(error)")
                }
                .onPlayTime { time in
                    // Update frequently, perhaps throttle this in a real app
                     Task { @MainActor in // Ensure UI updates are on main thread
                        self.currentTime = time
                     }
                }
                 .initialLoadingView {
                      ProgressView() // Show a spinner while loading
                 }


            Text("Player Status: \(String(describing: playerState))")
            Text("Current Time: \(String(format: "%.2f", currentTime))")

            HStack {
                Button("Play") { api?.play() }
                Button("Pause") { api?.pause() }
                Button("Seek +10s") {
                     Task {
                         do {
                             let current = try await api?.getCurrentTime() ?? 0
                             api?.seek(to: current + 10, allowSeekAhead: true)
                         } catch {
                             print("Failed to get current time for seek: \(error)")
                         }
                     }
                }
            }
            Spacer()
        }
    }
}
