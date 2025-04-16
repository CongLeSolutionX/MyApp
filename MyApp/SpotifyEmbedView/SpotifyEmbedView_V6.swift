////
////  SpotifyEmbedView_V6.swift
////  MyApp
////
////  Created by Cong Le on 4/15/25.
////
//
//import SwiftUI
//@preconcurrency import WebKit
//import Foundation
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
//    let spotifyUri: String
//
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//
//    func makeUIView(context: Context) -> WKWebView {
//        let userContentController = WKUserContentController()
//        userContentController.add(context.coordinator, name: "spotifyController")
//
//        let configuration = WKWebViewConfiguration()
//        configuration.userContentController = userContentController
//        configuration.allowsInlineMediaPlayback = true
//        configuration.mediaTypesRequiringUserActionForPlayback = []
//
//        let webView = WKWebView(frame: .zero, configuration: configuration)
//        webView.navigationDelegate = context.coordinator
//        webView.uiDelegate = context.coordinator
//        webView.isOpaque = false
//        webView.backgroundColor = .clear
//        webView.scrollView.isScrollEnabled = false
//
//        let html = generateHTML()
//        webView.loadHTMLString(html, baseURL: nil)
//
//        context.coordinator.webView = webView
//        return webView
//    }
//
//    func updateUIView(_ webView: WKWebView, context: Context) {
//        if context.coordinator.isApiReady && context.coordinator.lastLoadedUri != spotifyUri {
//            context.coordinator.loadUri(spotifyUri)
//            playbackState.currentUri = spotifyUri
//        }
//    }
//
//    static func dismantleUIView(_ uiView: WKWebView, coordinator: Coordinator) {
//        uiView.stopLoading()
//        uiView.configuration.userContentController.removeScriptMessageHandler(forName: "spotifyController")
//    }
//
//    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
//        var parent: SpotifyEmbedWebView
//        weak var webView: WKWebView?
//
//        var isApiReady = false
//        var lastLoadedUri: String?
//
//        init(_ parent: SpotifyEmbedWebView) {
//            self.parent = parent
//        }
//
//        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//            print("Spotify Embed WebView: HTML content loaded.")
//        }
//
//        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
//            print("Navigation failed: \(error.localizedDescription)")
//        }
//
//        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
//            print("Provisional navigation failed: \(error.localizedDescription)")
//        }
//
//        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
//            guard message.name == "spotifyController" else { return }
//            print("JS Message received: \(message.body)")
//
//            if let body = message.body as? String, body == "ready" {
//                isApiReady = true
//                createSpotifyController(with: parent.spotifyUri)
//            }
//            else if
//                let bodyDict = message.body as? [String: Any],
//                let event = bodyDict["event"] as? String
//            {
//                switch event {
//                case "controllerCreated":
//                    print("Controller created by JS.")
//                case "playbackUpdate":
//                    if let data = bodyDict["data"] as? [String: Any] {
//                        DispatchQueue.main.async {
//                            if let isPaused = data["paused"] as? Bool {
//                                self.parent.playbackState.isPlaying = !isPaused
//                            }
//                            if let posMs = data["position"] as? Double {
//                                self.parent.playbackState.currentPosition = posMs / 1000
//                            }
//                            if let durMs = data["duration"] as? Double {
//                                self.parent.playbackState.duration = durMs / 1000
//                            }
//                        }
//                    }
//                case "error":
//                    if let msg = bodyDict["message"] as? String {
//                        print("Spotify Embed JS Error: \(msg)")
//                    }
//                default:
//                    break
//                }
//            }
//        }
//
//        private func createSpotifyController(with initialUri: String) {
//            guard let webView = webView else { return }
//            guard lastLoadedUri == nil else {
//                if initialUri != lastLoadedUri {
//                    loadUri(initialUri)
//                }
//                return
//            }
//            lastLoadedUri = initialUri
//
//            let script = """
//            const element = document.getElementById('embed-iframe');
//            if (!element) {
//                console.error('No embed-iframe element!');
//            } else {
//                const options = { uri: '\(initialUri)', width: '100%', height: '100%' };
//                const callback = (controller) => {
//                    window.embedController = controller;
//                    if (window.webkit && window.webkit.messageHandlers.spotifyController) {
//                        window.webkit.messageHandlers.spotifyController.postMessage({ event: 'controllerCreated' });
//                    }
//
//                    controller.addListener('ready', () => console.log('Embed Controller: Ready'));
//                    controller.addListener('playback_update', e => {
//                        if (window.webkit && window.webkit.messageHandlers.spotifyController) {
//                            window.webkit.messageHandlers.spotifyController.postMessage({ event: 'playbackUpdate', data: e.data });
//                        }
//                    });
//                };
//                if (window.IFrameAPI) {
//                    window.IFrameAPI.createController(element, options, callback);
//                } else {
//                    console.error('IFrameAPI not found!');
//                }
//            }
//            """
//            webView.evaluateJavaScript(script) { _, error in
//                if let error = error {
//                    print("Error creating controller: \(error.localizedDescription)")
//                    self.lastLoadedUri = nil
//                }
//            }
//        }
//
//        func loadUri(_ uri: String) {
//            guard let webView = webView else { return }
//            guard isApiReady else {
//                print("API not ready, cannot load URI \(uri).")
//                return
//            }
//            lastLoadedUri = uri
//            let script = """
//            if (window.embedController) {
//                window.embedController.loadUri('\(uri)');
//            } else {
//                console.error('embedController not found');
//            }
//            """
//            webView.evaluateJavaScript(script) { _, error in
//                if let error = error {
//                    print("Error loading URI \(uri): \(error.localizedDescription)")
//                }
//            }
//        }
//
//        func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
//            print("JS Alert: \(message)")
//            completionHandler()
//        }
//    }
//
//    private func generateHTML() -> String {
//        """
//        <!DOCTYPE html><html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no"><style>
//        body { margin: 0; padding: 0; background-color: transparent; overflow: hidden; }
//        #embed-iframe { width: 100%; height: 100vh; box-sizing: border-box; display: block; }
//        </style></head><body>
//        <div id="embed-iframe"></div>
//        <script src="https://open.spotify.com/embed/iframe-api/v1" async></script>
//        <script>
//        window.onSpotifyIframeApiReady = (IFrameAPI) => {
//            window.IFrameAPI = IFrameAPI;
//            if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.spotifyController) {
//                window.webkit.messageHandlers.spotifyController.postMessage("ready");
//            }
//        };
//        const scriptTag = document.querySelector('script[src*="iframe-api"]');
//        if (scriptTag) {
//            scriptTag.onerror = (event) => {
//                if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.spotifyController) {
//                    window.webkit.messageHandlers.spotifyController.postMessage({ event: 'error', message: 'Failed to load Spotify API script' });
//                }
//            };
//        }
//        </script></body></html>
//        """
//    }
//}
//
//// MARK: - TrackDetails Model
//
//struct TrackDetails: Identifiable, Equatable {
//    let id: String
//    let title: String
//    let artistName: String
//    let albumTitle: String?
//    let artworkURL: URL?
//    let durationMs: Int
//    let releaseDate: Date?
//    let description: String?
//    let isEpisode: Bool
//
//    var formattedDuration: String {
//        let totalSeconds = durationMs / 1000
//        let minutes = totalSeconds / 60
//        let seconds = totalSeconds % 60
//        return String(format: "%d:%02d", minutes, seconds)
//    }
//
//    var formattedReleaseDate: String {
//        guard let releaseDate else { return "N/A" }
//        let formatter = DateFormatter()
//        formatter.dateStyle = .medium
//        formatter.timeStyle = .none
//        return formatter.string(from: releaseDate)
//    }
//
//    var webLink: URL? {
//        let parts = id.split(separator: ":")
//        guard parts.count == 3 else { return nil }
//        let type = parts[1]
//        let identifier = parts[2]
//        return URL(string: "https://open.spotify.com/\(type)/\(identifier)")
//    }
//
//    // MARK: Mock Data
//
//    static func mockTrack() -> TrackDetails {
//        TrackDetails(
//            id: "spotify:track:11dFghVXANMlKmJXsNCbNl",
//            title: "Never Gonna Give You Up",
//            artistName: "Rick Astley",
//            albumTitle: "Whenever You Need Somebody",
//            artworkURL: URL(string: "https://i.scdn.co/image/ab67616d0000b2730c45d941ba59e17f5314a8a4"),
//            durationMs: 213573,
//            releaseDate: Calendar.current.date(from: DateComponents(year: 1987, month: 7, day: 27)),
//            description: "Released in 1987, this song became an international number-one hit.",
//            isEpisode: false
//        )
//    }
//
//    static func mockEpisode() -> TrackDetails {
//        TrackDetails(
//            id: "spotify:episode:7makk4oTQel546B0PZlDM5",
//            title: "Life at Spotify: Navigating Work During the Pandemic",
//            artistName: "Spotify: For the Record",
//            albumTitle: "Spotify: For the Record Podcast",
//            artworkURL: URL(string: "https://i.scdn.co/image/ab6765630000ba8a8a847b9630621b655357ecaa"),
//            durationMs: 1783000,
//            releaseDate: Calendar.current.date(from: DateComponents(year: 2020, month: 5, day: 14)),
//            description: "We pull back the curtain and learn what life has been like for employees at Spotify over the past few months during the global pandemic.",
//            isEpisode: true
//        )
//    }
//
//    static func mockTrackNoArtwork() -> TrackDetails {
//        TrackDetails(
//            id: "spotify:track:0UaMYEvWZi0ZqiDOoHU3YI",
//            title: "CongLeSolutionX",
//            artistName: "Various Artists",
//            albumTitle: "Unknown Album",
//            artworkURL: nil,
//            durationMs: 180000,
//            releaseDate: nil,
//            description: "This is a track without artwork.",
//            isEpisode: false
//        )
//    }
//}
//
//// MARK: - SpotifyEmbedCardView
//
//struct SpotifyEmbedCardView: View {
//    let trackData: TrackDetails
//
//    @State private var showingFullDetails = false
//    @StateObject private var playbackState = SpotifyPlaybackState()
//
//    var body: some View {
//        VStack(spacing: 0) {
//            SpotifyEmbedWebView(playbackState: playbackState, spotifyUri: trackData.id)
//                .frame(height: 80)
//                .clipped()
//
//            VStack(alignment: .leading, spacing: 10) {
//                Text(trackData.title)
//                    .font(.headline)
//                    .lineLimit(1)
//
//                Text(trackData.artistName)
//                    .font(.subheadline)
//                    .foregroundColor(.secondary)
//                    .lineLimit(1)
//
//                HStack {
//                    Button {
//                        showingFullDetails = true
//                    } label: {
//                        Label("Details", systemImage: "info.circle")
//                    }
//                    .buttonStyle(.bordered)
//                    .controlSize(.small)
//
//                    Spacer()
//
//                    if let shareURL = trackData.webLink {
//                        ShareLink(item: shareURL) {
//                            Label("Share", systemImage: "square.and.arrow.up")
//                        }
//                        .buttonStyle(.bordered)
//                        .controlSize(.small)
//                        .labelStyle(.iconOnly)
//                    }
//                }
//
//                Text(playbackState.isPlaying ? "Playing" : "Paused")
//                    .font(.caption)
//                    .foregroundColor(playbackState.isPlaying ? .green : .secondary)
//                    .accessibilityLabel(playbackState.isPlaying ? "Is playing" : "Is paused")
//                    .animation(.easeInOut, value: playbackState.isPlaying)
//            }
//            .padding()
//            .background(.regularMaterial)
//        }
//        .background(Color(.secondarySystemBackground))
//        .cornerRadius(12)
//        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
//        .sheet(isPresented: $showingFullDetails) {
//            NavigationView {
//                TrackDetailsView(track: trackData)
//                    .toolbar {
//                        ToolbarItem(placement: .navigationBarLeading) {
//                            Button("Close") { showingFullDetails = false }
//                        }
//                    }
//            }
//        }
//    }
//}
//
//// MARK: - TrackDetailsView
//
//struct TrackDetailsView: View {
//    let track: TrackDetails
//
//    @State private var isPlaying = false
//
//    @Environment(\.dismiss) var dismiss
//
//    var body: some View {
//        ScrollView {
//            VStack(alignment: .leading, spacing: 20) {
//                AsyncImage(url: track.artworkURL) { phase in
//                    switch phase {
//                    case .empty:
//                        ProgressView()
//                            .frame(height: 300)
//                    case .success(let image):
//                        image
//                            .resizable()
//                            .aspectRatio(contentMode: .fit)
//                            .cornerRadius(8)
//                            .shadow(color: .black.opacity(0.2), radius: 10, y: 5)
//                    case .failure:
//                        Image(systemName: track.isEpisode ? "mic.fill" : "music.note")
//                            .resizable()
//                            .aspectRatio(contentMode: .fit)
//                            .padding(50)
//                            .frame(height: 300)
//                            .background(Color(.systemGray5))
//                            .foregroundColor(Color(.systemGray))
//                            .cornerRadius(8)
//                    @unknown default:
//                        EmptyView()
//                    }
//                }
//                .frame(maxWidth: .infinity)
//                .padding(.bottom, 10)
//
//                VStack(alignment: .leading, spacing: 5) {
//                    Text(track.title)
//                        .font(.largeTitle.weight(.bold))
//                        .lineLimit(nil)
//
//                    Text(track.artistName)
//                        .font(.title2)
//                        .foregroundColor(.secondary)
//
//                    if let albumTitle = track.albumTitle {
//                        if track.isEpisode {
//                            Text("Podcast: \(albumTitle)")
//                                .font(.headline)
//                                .foregroundColor(.purple)
//                                .onTapGesture {
//                                    print("Navigate to Podcast Series: \(albumTitle)")
//                                }
//                        } else {
//                            Text("From \"\(albumTitle)\"")
//                                .font(.headline)
//                                .foregroundColor(.accentColor)
//                                .onTapGesture {
//                                    print("Navigate to Album: \(albumTitle)")
//                                }
//                        }
//                    }
//                }
//                .frame(maxWidth: .infinity, alignment: .leading)
//
//                HStack {
//                    Label(track.formattedDuration, systemImage: "clock")
//                    Spacer()
//                    Label(track.formattedReleaseDate, systemImage: "calendar")
//                }
//                .font(.subheadline)
//                .foregroundColor(.secondary)
//
//                Divider()
//
//                HStack(spacing: 15) {
//                    Button {
//                        isPlaying.toggle()
//                        print("Play button tapped. Now \(isPlaying ? "playing" : "paused")")
//                    } label: {
//                        Label(
//                            isPlaying ? "Pause" : "Play Now",
//                            systemImage: isPlaying ? "pause.fill" : "play.fill"
//                        )
//                        .padding(.vertical, 8)
//                        .frame(maxWidth: .infinity)
//                    }
//                    .buttonStyle(.borderedProminent)
//                    .tint(isPlaying ? .orange : .green)
//
//                    Button {
//                        print("Add to playlist: \(track.id)")
//                    } label: {
//                        Label("Add", systemImage: "plus")
//                            .padding(.vertical, 8)
//                    }
//                    .buttonStyle(.bordered)
//
//                    if let shareURL = track.webLink {
//                        ShareLink(item: shareURL) {
//                            Label("Share", systemImage: "square.and.arrow.up")
//                                .padding(.vertical, 8)
//                        }
//                        .buttonStyle(.bordered)
//                    }
//                }
//                .font(.headline)
//                .labelStyle(.titleAndIcon)
//                .padding(.vertical, 5)
//
//                Divider()
//
//                if let description = track.description, !description.isEmpty {
//                    VStack(alignment: .leading) {
//                        Text(track.isEpisode ? "Episode Notes" : "About")
//                            .font(.title3.weight(.semibold))
//                            .padding(.bottom, 2)
//                        Text(description)
//                            .font(.body)
//                            .foregroundColor(.secondary)
//                            .fixedSize(horizontal: false, vertical: true)
//                    }
//                }
//
//                Spacer()
//            }
//            .padding()
//        }
//        .navigationTitle(track.isEpisode ? "Episode Details" : "Track Details")
//        .navigationBarTitleDisplayMode(.inline)
//    }
//}
//
//// MARK: - SpotifyEmbedView (Standalone embedded player with URI controls)
//
//struct SpotifyEmbedView: View {
//    @EnvironmentObject var globalPlayback: SpotifyPlaybackState
//
//    @State private var currentUri: String
//
//    let episodeUri = "spotify:episode:7makk4oTQel546B0PZlDM5"
//    let trackUri = "spotify:track:11dFghVXANMlKmJXsNCbNl"
//    let playlistUri = "spotify:playlist:37i9dQZF1DXcBWIGoYBM5M"
//    let albumUri = "spotify:album:6ZG5lRT77aJ3btmArcykra"
//
//    init(initialUri: String? = nil) {
//        _currentUri = State(initialValue: initialUri ?? "spotify:episode:7makk4oTQel546B0PZlDM5")
//    }
//
//    var body: some View {
//        VStack(spacing: 15) {
//            SpotifyEmbedWebView(playbackState: globalPlayback, spotifyUri: currentUri)
//                .frame(height: 200)
//                .background(Color(.systemGray6))
//                .cornerRadius(12)
//                .shadow(radius: 4)
//                .padding(.horizontal)
//                .accessibilityElement(children: .combine)
//                .accessibilityLabel("Spotify preview player")
//
//            Text("Spotify Embed")
//                .font(.headline)
//                .foregroundColor(.primary)
//
//            HStack(spacing: 15) {
//                Button("Load Episode") { currentUri = episodeUri }
//                Button("Load Track") { currentUri = trackUri }
//                Button("Load Album") { currentUri = albumUri }
//                Button("Load Playlist") { currentUri = playlistUri }
//            }
//            .buttonStyle(.borderedProminent)
//            .padding(.horizontal)
//
//            Spacer()
//        }
//        .navigationTitle("Spotify Embed Card")
//        .padding()
//        .background(Color(.secondarySystemBackground))
//        .cornerRadius(12)
//        .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
//        .padding()
//    }
//}
//
//// MARK: - ContentView (Show all cards with a global embed player and selection buttons)
//
//struct ContentView: View {
//    @State private var selectedUri: String? = nil
//    @StateObject private var globalPlayback = SpotifyPlaybackState()
//
//    let tracks = [
//        TrackDetails.mockTrack(),
//        TrackDetails.mockEpisode(),
//        TrackDetails.mockTrackNoArtwork()
//    ]
//
//    var body: some View {
//        NavigationView {
//            ScrollView {
//                VStack(spacing: 20) {
//                    Text("Spotify Embed Cards")
//                        .font(.largeTitle)
//                        .padding(.top)
//
//                    ForEach(tracks) { track in
//                        SpotifyEmbedCardView(trackData: track)
//                    }
//
//                    Divider()
//
//                    SpotifyEmbedView(initialUri: selectedUri)
//                        .environmentObject(globalPlayback)
//                        .frame(height: 240)
//
//                    VStack(spacing: 12) {
//                        Text("Quick Load Spotify URIs")
//                            .font(.headline)
//
//                        HStack(spacing: 10) {
//                            Button("Episode") {
//                                selectedUri = TrackDetails.mockEpisode().id
//                            }
//
//                            Button("Track") {
//                                selectedUri = TrackDetails.mockTrack().id
//                            }
//
//                            Button("Album") {
//                                selectedUri = "spotify:album:6ZG5lRT77aJ3btmArcykra"
//                            }
//
//                            Button("Playlist") {
//                                selectedUri = "spotify:playlist:37i9dQZF1DXcBWIGoYBM5M"
//                            }
//                        }
//                        .buttonStyle(.borderedProminent)
//                        .padding(.horizontal)
//                    }
//
//                    Spacer(minLength: 40)
//                }
//                .padding()
//            }
//            .navigationTitle("Spotify Cards & Embed")
//            .navigationBarTitleDisplayMode(.large)
//        }
//    }
//}
//
//// MARK: - SwiftUI Previews
//
//struct SpotifyEmbedView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//            SpotifyEmbedView()
//                .environmentObject(SpotifyPlaybackState())
//        }
//    }
//}
//
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
