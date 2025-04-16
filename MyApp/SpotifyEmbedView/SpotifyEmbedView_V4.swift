//
//  SpotifyEmbedView_V4.swift
//  MyApp
//
//  Created by Cong Le on 4/15/25.
//

import SwiftUI
@preconcurrency import WebKit // Don't forget to import WebKit

// MARK: - SwiftUI Host View (Card Design)

struct SpotifyEmbedView: View {
    // State to hold the URI, allowing dynamic updates
    @State private var currentUri: String

    // Example URIs (Replace with your actual choices)
    let episodeUri = "spotify:episode:7makk4oTQel546B0PZlDM5" // Life at Spotify
    let trackUri = "spotify:track:11dFghVXANMlKmJXsNCbNl" // Rick Astley
    let playlistUri = "spotify:playlist:37i9dQZF1DXcBWIGoYBM5M" // Today's Top Hits
    let albumUri = "spotify:album:6ZG5lRT77aJ3btmArcykra" // Rumours - Fleetwood Mac

    init(initialUri: String? = nil) {
        // Use provided URI or default to an example
        _currentUri = State(initialValue: initialUri ?? "spotify:episode:7makk4oTQel546B0PZlDM5")
    }

    var body: some View {
        VStack(spacing: 15) {

            // --- The Actual Embed ---
            SpotifyEmbedWebView(spotifyUri: currentUri)
                .frame(height: 200) // Set desired height for the embed player card area
                .background(Color(.systemGray6)) // Subtle background for the card
                .disabled(false) // Make sure webview interaction is enabled

            // --- Controls (Example) ---
            Text("Spotify Embed")
                 .font(.headline)
            HStack {
                Button("Load Episode") { currentUri = episodeUri }
                Button("Load Track") { currentUri = trackUri }
                Button("Load Album") { currentUri = albumUri }
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal)

            Spacer() // Push content to the top
        }
        .navigationTitle("Spotify Embed Card")
        // --- Card Styling ---
        .padding() // Padding inside the card
        .background(Color(.secondarySystemBackground)) // Card background color
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
        .padding() // Padding outside the card
    }
}

// MARK: - Preview

struct SpotifyEmbedView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView { // Add NavigationView for title
            SpotifyEmbedView(initialUri: "spotify:track:11dFghVXANMlKmJXsNCbNl")
        }
    }
}

// <<< PASTE the full SpotifyEmbedWebView struct and its Coordinator here >>>
// From your first response...
import SwiftUI
import WebKit // Don't forget to import WebKit

// MARK: - Spotify Embed WebView (UIViewRepresentable)
struct SpotifyEmbedWebView: UIViewRepresentable {
    // ... (Keep the entire struct implementation as provided before) ...
    // including makeCoordinator, makeUIView, updateUIView, dismantleUIView,
    // Coordinator class, and generateHTML()
    // ...
    // --- Make sure this struct is fully defined ---
    let spotifyUri: String // Input: The Spotify URI to load

    // Creates the coordinator bridge between Swift and JS
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    // Creates the initial WKWebView
    func makeUIView(context: Context) -> WKWebView {
        // --- 1. Configure JavaScript Communication ---
        let userContentController = WKUserContentController()
        userContentController.add(context.coordinator, name: "spotifyController")

        let configuration = WKWebViewConfiguration()
        configuration.userContentController = userContentController
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []

        // --- 2. Create WKWebView ---
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator // Handle navigation events
        webView.uiDelegate = context.coordinator // Optional: handle UI events like alerts
        webView.isOpaque = false // Allow background to show through if needed
        webView.backgroundColor = .clear // Match SwiftUI background if desired
        webView.scrollView.isScrollEnabled = false // Disable scrolling within the embed box

        // --- 3. Load Initial HTML ---
        let html = generateHTML()
        webView.loadHTMLString(html, baseURL: nil)

        context.coordinator.webView = webView // Give coordinator a reference
        return webView
    }

    // Handles updates from SwiftUI state changes (e.g., new URI)
    func updateUIView(_ webView: WKWebView, context: Context) {
        if context.coordinator.isApiReady && context.coordinator.lastLoadedUri != spotifyUri {
            context.coordinator.loadUri(spotifyUri)
            print("SpotifyEmbedWebView: updateUIView called, attempting to load new URI: \(spotifyUri)")
        } else if !context.coordinator.isApiReady {
             print("SpotifyEmbedWebView: updateUIView called, but API not ready yet.")
        } else {
             print("SpotifyEmbedWebView: updateUIView called, but URI hasn't changed (\(spotifyUri)).")
        }
    }

    // Cleanup
    static func dismantleUIView(_ uiView: WKWebView, coordinator: Coordinator) {
         print("SpotifyEmbedWebView: dismantleUIView called.")
         uiView.stopLoading()
         uiView.configuration.userContentController.removeScriptMessageHandler(forName: "spotifyController")
    }

    // MARK: - Coordinator (Bridge)
    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
        var parent: SpotifyEmbedWebView
        weak var webView: WKWebView? // Use weak reference to avoid retain cycles
        var isApiReady = false
        var lastLoadedUri: String? = nil

        init(_ parent: SpotifyEmbedWebView) {
            self.parent = parent
        }

        // --- WKNavigationDelegate ---
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            print("Spotify Embed WebView: Initial HTML loaded (didFinish navigation).")
            // We still wait for the postMessage 'ready'
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print("Spotify Embed WebView: Navigation Failed - \(error.localizedDescription)")
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
             print("Spotify Embed WebView: Provisional Navigation Failed - \(error.localizedDescription)")
             // Consider notifying the parent or showing an error state
        }

        // --- WKScriptMessageHandler ---
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            guard message.name == "spotifyController" else { return }
            print("Spotify Embed WebView (Coordinator): Received message: \(message.body)")

            if let body = message.body as? String, body == "ready" {
                print("Spotify Embed WebView: Spotify API Ready message received from JS.")
                isApiReady = true
                 // *** Now safely call createController and load the initial URI ***
                 // Use the URI that was set when the view was created/updated
                 createSpotifyController(with: parent.spotifyUri)
            }
            // --- Add Handling for Playback Updates (If needed) ---
            else if let bodyDict = message.body as? [String: Any],
                      let event = bodyDict["event"] as? String,
                      event == "playbackUpdate",
                      let data = bodyDict["data"] as? [String: Any] {
                 print("Spotify Embed WebView: Playback Update Received - Data: \(data)")
                 // Process playback data (e.g., update UI elsewhere)
                 // let isPaused = data["isPaused"] as? Bool
                 // let position = data["position"] as? Double
                 // let duration = data["duration"] as? Double
            }
            // --- Add Handling for Controller Creation Confirmation (Optional) ---
            else if let bodyDict = message.body as? [String: Any],
                      let event = bodyDict["event"] as? String,
                      event == "controllerCreated" {
                 print("Spotify Embed WebView: Controller Creation confirmed by JS.")
                 // Can perform actions that depend on the controller *definitely* existing
            }
        }

        // --- Helper Methods ---
        private func createSpotifyController(with initialUri: String) {
            guard let webView = webView else {
                 print("Spotify Embed WebView: Error - WebView reference lost before creating controller.")
                 return
            }

            // Prevent duplicate controller creation if somehow called twice
            guard lastLoadedUri == nil else {
                 print("Spotify Embed WebView: Controller likely already created, skipping duplicate creation.")
                 // Maybe just call loadUri if the URI is different?
                 if initialUri != lastLoadedUri {
                     loadUri(initialUri)
                 }
                 return
            }

            print("Spotify Embed WebView: Preparing to create controller with URI: \(initialUri)")
            lastLoadedUri = initialUri // Set initial loaded URI *before* evaluating JS

            let script = """
            console.log('Swift calling IFrameAPI.createController for URI: \(initialUri)');
            const element = document.getElementById('embed-iframe');
            if (!element) {
                 console.error('Placeholder element #embed-iframe not found!');
            } else {
                const options = {
                    uri: '\(initialUri)',
                    width: '100%',
                    height: '100%'
                };
                const callback = (controller) => {
                    console.log('Spotify EmbedController created by API.');
                    window.embedController = controller; // Store globally

                    // Notify Swift that controller is created
                    if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.spotifyController) {
                       window.webkit.messageHandlers.spotifyController.postMessage({ event: 'controllerCreated' });
                    }

                    // Add listeners
                    controller.addListener('ready', () => console.log('Embed Controller Event: Ready'));
                    controller.addListener('playback_update', e => {
                         // Send detailed playback update to Swift
                         if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.spotifyController) {
                            window.webkit.messageHandlers.spotifyController.postMessage({ event: 'playbackUpdate', data: e.data });
                         } else {
                             console.log('Embed Playback Update (Swift handler MIA):', e.data);
                         }
                    });
                };

                if (window.IFrameAPI) {
                    window.IFrameAPI.createController(element, options, callback);
                     console.log('Called IFrameAPI.createController.');
                } else {
                     console.error('IFrameAPI not found when trying to create controller!');
                }
            }
            """
            webView.evaluateJavaScript(script) { result, error in
                if let error = error {
                    print("Spotify Embed WebView: Error evaluating createController script - \(error.localizedDescription)")
                     // Reset state maybe?
                     self.lastLoadedUri = nil
                } else {
                    print("Spotify Embed WebView: createController script evaluated successfully.")
                }
            }
        }

        func loadUri(_ uri: String) {
            guard let webView = webView else {
                 print("Spotify Embed WebView: Error - WebView reference lost before loading URI.")
                 return
            }
             // Only proceed if the API is ready AND the controller should exist
            guard isApiReady else {
                 print("Spotify Embed WebView: API not ready, cannot load URI: \(uri)")
                 // Maybe queue the URI to load later?
                 return
            }

            // Optimistically assume controller exists if API is ready,
            // but log if JS reports failure
            print("Spotify Embed WebView: Preparing loadUri for: \(uri)")
            lastLoadedUri = uri // Update last loaded URI track

            let script = """
            console.log('Swift calling embedController.loadUri for: \(uri)');
            if (window.embedController) {
                window.embedController.loadUri('\(uri)');
                console.log('Called embedController.loadUri.');
            } else {
                console.error('window.embedController not found when trying to load URI!');
                // Attempt to recreate controller MAYBE? Risky. Better to signal error.
            }
            """
            webView.evaluateJavaScript(script) { result, error in
                if let error = error {
                    print("Spotify Embed WebView: Error evaluating loadUri script - \(error.localizedDescription)")
                     // Maybe URI format was bad?
                } else {
                    print("Spotify Embed WebView: loadUri script evaluated for \(uri).")
                }
            }
        }

        // Optional: Handle JS alerts
        func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
            print("JS Alert: \(message)")
            completionHandler()
        }
    }

    // MARK: - HTML Generator
    private func generateHTML() -> String {
        // Same HTML content as before
        return """
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="utf-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
            <style>
                body { margin: 0; padding: 0; background-color: transparent; overflow: hidden; } /* Added overflow: hidden */
                #embed-iframe {
                    width: 100%; /* Fill available space */
                    height: 100vh; /* Use viewport height to ensure it has dimensions */
                    box-sizing: border-box;
                    display: block;
                }
            </style>
        </head>
        <body>
            <div id="embed-iframe"></div>
            <script src="https://open.spotify.com/embed/iframe-api/v1" async></script>
            <script>
                console.log('HTML loaded, waiting for onSpotifyIframeApiReady...');
                window.onSpotifyIframeApiReady = (IFrameAPI) => {
                    console.log('onSpotifyIframeApiReady CALLED by Spotify script.');
                    window.IFrameAPI = IFrameAPI; // Store globally

                    if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.spotifyController) {
                         console.log('Posting "ready" message to Swift...');
                         window.webkit.messageHandlers.spotifyController.postMessage("ready");
                    } else {
                         console.error('Swift message handler (spotifyController) not found!');
                    }
                };

                // Add error handling for script loading
                const scriptTag = document.querySelector('script[src*="iframe-api"]');
                if (scriptTag) {
                    scriptTag.onerror = (event) => {
                        console.error('Failed to load Spotify IFrame API script:', event);
                        // Optionally notify Swift about the failure
                        if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.spotifyController) {
                           window.webkit.messageHandlers.spotifyController.postMessage({ event: 'error', message: 'Failed to load Spotify API script' });
                        }
                    };
                }
            </script>
        </body>
        </html>
        """
    }
}

// From your second response...
import Foundation // Needed for Date

struct TrackDetails: Identifiable { // Make Identifiable if used in ForEach
    let id: String // Treat as Spotify URI (e.g., spotify:track:xxxx)
    let title: String
    let artistName: String
    let albumTitle: String?
    let artworkURL: URL?
    let durationMs: Int
    let releaseDate: Date?
    let description: String?
    let isEpisode: Bool

    var formattedDuration: String {
        let totalSeconds = durationMs / 1000
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    var formattedReleaseDate: String {
        guard let releaseDate else { return "N/A" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: releaseDate)
    }

    // Helper to get a web URL for sharing
    var webLink: URL? {
        let parts = id.split(separator: ":")
        guard parts.count == 3 else { return nil }
        let type = parts[1] // "track", "episode", "album", etc.
        let identifier = parts[2]
        return URL(string: "https://open.spotify.com/\(type)/\(identifier)")
    }

    // --- Mock Data Factory ---
    static func mockTrack() -> TrackDetails {
        return TrackDetails(
             id: "spotify:track:11dFghVXANMlKmJXsNCbNl", // Rick Astley
             title: "Never Gonna Give You Up",
             artistName: "Rick Astley",
             albumTitle: "Whenever You Need Somebody",
             artworkURL: URL(string: "https://i.scdn.co/image/ab67616d0000b2730c45d941ba59e17f5314a8a4"),
             durationMs: 213573,
             releaseDate: Calendar.current.date(from: DateComponents(year: 1987, month: 7, day: 27)),
             description: "Released in 1987, this song became an international number-one hit.",
             isEpisode: false
        )
    }

    static func mockEpisode() -> TrackDetails {
         return TrackDetails(
            id: "spotify:episode:7makk4oTQel546B0PZlDM5", // Life at Spotify
            title: "Life at Spotify: Navigating Work During the Pandemic", // Slightly longer title
            artistName: "Spotify: For the Record",
            albumTitle: "Spotify: For the Record Podcast", // More descriptive album/series
            artworkURL: URL(string: "https://i.scdn.co/image/ab6765630000ba8a8a847b9630621b655357ecaa"),
            durationMs: 1783000,
            releaseDate: Calendar.current.date(from: DateComponents(year: 2020, month: 5, day: 14)),
            description: "We pull back the curtain and learn what life has been like for employees at Spotify over the past few months during the global pandemic.",
            isEpisode: true
         )
    }

     static func mockTrackNoArtwork() -> TrackDetails {
         return TrackDetails(
             id: "spotify:track:0UaMYEvWZi0ZqiDOoHU3YI", // Example: Another track ID
             title: "Placeholder Track Title",
             artistName: "Various Artists",
             albumTitle: "Unknown Album",
             artworkURL: nil, // No artwork
             durationMs: 180000, // 3:00
             releaseDate: nil,
             description: "This is a track without artwork.",
             isEpisode: false
         )
    }
}

import SwiftUI
import WebKit // Crucial: Import WebKit here too

// MARK: - Spotify Embed Card View

struct SpotifyEmbedCardView: View {
    let trackData: TrackDetails

    // Optional: State to track navigation to full details
    @State private var showingFullDetails = false

    var body: some View {
        VStack(spacing: 0) { // Remove spacing for seamless look

            // --- Spotify Embed Player ---
            SpotifyEmbedWebView(spotifyUri: trackData.id)
                // The standard Spotify embed height is typically 80px or 152px
                // Use 80 for the most compact version within a card
                .frame(height: 80)
                // Clip the webview to prevent potential overflow if JS/CSS issue
                 .clipped()
                 // Disable interaction IF the card itself is just for show,
                 // but usually you WANT interaction with the embed player.
                 // .disabled(true)

            // --- Metadata & Actions ---
            VStack(alignment: .leading, spacing: 10) {
                Text(trackData.title)
                    .font(.headline)
                    .lineLimit(1) // Keep title concise in card

                Text(trackData.artistName)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)

                HStack {
                    // --- View Details Button (Example Navigation) ---
                    Button {
                        print("Navigate to full details for: \(trackData.title)")
                        showingFullDetails = true // Trigger sheet/navigation
                    } label: {
                        Label("Details", systemImage: "info.circle")
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small) // Make buttons smaller for card context

                    Spacer() // Push share button to the right

                    // --- Share Button ---
                    // Share the web link if available
                    if let shareURL = trackData.webLink {
                        ShareLink(item: shareURL) {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                        .labelStyle(.iconOnly) // Just show icon for share
                    }
                }
            }
            .padding() // Add padding around the metadata/actions
            .background(.regularMaterial) // Use material for a modern card background
        }
        // --- Card Styling ---
        .background(Color(.secondarySystemBackground)) // Base background if material isn't enough
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        // Trigger the sheet presentation
        .sheet(isPresented: $showingFullDetails) {
             // Present the FULL TrackDetailsView modally
             // Wrap in NavigationView if TrackDetailsView needs a title bar/close button
             NavigationView {
                 TrackDetailsView(track: trackData)
                      .toolbar { // Add a close button to the modal sheet
                          ToolbarItem(placement: .navigationBarLeading) {
                              Button("Close") { showingFullDetails = false }
                          }
                      }
             }
        }
    }
}

// MARK: - Content View (Example Usage)

struct ContentView: View {
    // Use the mock data directly
    let currentTrack = TrackDetails.mockTrack()
    let currentEpisode = TrackDetails.mockEpisode()
    let trackWithoutArt = TrackDetails.mockTrackNoArtwork()

    var body: some View {
        NavigationView { // Often good to have a NavigationView
            ScrollView {
                VStack(spacing: 20) {
                    Text("Spotify Embed Cards")
                        .font(.largeTitle)
                        .padding(.bottom)

                    SpotifyEmbedCardView(trackData: currentTrack)

                    SpotifyEmbedCardView(trackData: currentEpisode)

                    SpotifyEmbedCardView(trackData: trackWithoutArt)

                    Spacer() // Push cards to top if content is short
                }
                .padding() // Padding around the ScrollView content
            }
            .navigationTitle("Spotify Cards")
            .navigationBarHidden(true) // Hide if the large title is enough
        }
    }
}

// MARK: - Preview Provider

struct SpotifyEmbedCardView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView() // Preview the main content view holding the cards
    }
}

// MARK: - Full Track Details View (Required for the "Details" button sheet)
// <<< PASTE the TrackDetailsView struct here >>>
// From your second response...
struct TrackDetailsView: View {
    // including body with AsyncImage, metadata, Action Buttons, Description
    let track: TrackDetails
    @Environment(\.dismiss) var dismiss // Already included usually
     // ... rest of the TrackDetailsView code ...
     var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // --- Artwork ---
                AsyncImage(url: track.artworkURL) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(height: 300)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(8)
                            .shadow(color: .black.opacity(0.2), radius: 10, y: 5)
                    case .failure:
                        Image(systemName: track.isEpisode ? "mic.fill" : "music.note")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding(50)
                            .frame(height: 300)
                            .background(Color(.systemGray5))
                            .foregroundColor(Color(.systemGray))
                            .cornerRadius(8)
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 10)

                // --- Metadata ---
                 VStack(alignment: .leading, spacing: 5) {
                    Text(track.title)
                        .font(.largeTitle.weight(.bold)) // Combine weight modifier
                        .lineLimit(nil) // Allow multiple lines in detail view

                    Text(track.artistName)
                        .font(.title2)
                        .foregroundColor(.secondary)

                    if let albumTitle = track.albumTitle, !track.isEpisode {
                        Text("From \"\(albumTitle)\"")
                             .font(.headline)
                            .foregroundColor(.accentColor)
                            .onTapGesture { print("Navigate to Album: \(albumTitle)") }
                    } else if let seriesTitle = track.albumTitle, track.isEpisode {
                         Text("Podcast: \(seriesTitle)")
                             .font(.headline)
                            .foregroundColor(.purple)
                            .onTapGesture { print("Navigate to Podcast Series: \(seriesTitle)") }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // --- Duration & Release Date ---
                HStack {
                    Label(track.formattedDuration, systemImage: "clock")
                    Spacer()
                    Label(track.formattedReleaseDate, systemImage: "calendar")
                }
                .font(.subheadline)
                .foregroundColor(.secondary)

                Divider()

                // --- Action Buttons ---
                 HStack(spacing: 15) { // Give buttons a bit more space
                    Button { print("Play Action Tapped: \(track.id)") } label: {
                        Label("Play Now", systemImage: "play.fill") // Use filled icon for primary action
                            .padding(.vertical, 8)
                             .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)

                    Button { print("Add Action Tapped: \(track.id)") } label: {
                        Label("Add", systemImage: "plus") // Simpler icon
                            .padding(.vertical, 8)
                    }
                    .buttonStyle(.bordered)

                     // Using ShareLink is more idiomatic in SwiftUI for sharing
                     if let shareURL = track.webLink {
                         ShareLink(item: shareURL) {
                             Label("Share", systemImage: "square.and.arrow.up")
                                 .padding(.vertical, 8)
                         }
                         .buttonStyle(.bordered)
                     }
                     // Optional: Keep just the share button logic if ShareLink unavailable/undesired
                     // Button { print("Share Action Tapped: \(track.id)") } label: { ... }

                }
                 .font(.headline) // Make button text slightly larger
                 .labelStyle(.titleAndIcon) // Show both icon and text in detail view
                 .padding(.vertical, 5)

                Divider()

                // --- Description / Show Notes ---
                if let description = track.description, !description.isEmpty {
                    VStack(alignment: .leading) {
                        Text(track.isEpisode ? "Episode Notes" : "About")
                            .font(.title3.weight(.semibold))
                            .padding(.bottom, 2)
                        Text(description)
                            .font(.body)
                            .foregroundColor(.secondary)
                             .lineLimit(nil) // Ensure full description is readable
                    }
                }

                Spacer()
            }
            .padding()
        }
        .navigationTitle(track.isEpisode ? "Episode Details" : "Track Details")
         .navigationBarTitleDisplayMode(.inline)
         // Toolbar is added in the .sheet modifier in SpotifyEmbedCardView
    }
}
