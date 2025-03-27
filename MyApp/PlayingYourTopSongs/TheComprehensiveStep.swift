//
//  TheComprehensiveStep.swift
//  MyApp
//
//  Created by Cong Le on 3/26/25.
//

import SwiftUI
import WebKit // Required for WKWebView

// --- Constants and Configuration ---
let spotifyApiToken = "YOUR_SPOTIFY_API_TOKEN" // <--- !!! REPLACE WITH YOUR ACTUAL TOKEN !!!
let sampleTrackUris = [
    "spotify:track:3myLRVDhN4Vba1F2JCQU0W", "spotify:track:5qbjUmVV1mSClfNrpV33jS",
    "spotify:track:2tnVG71enUj33Ic2nFN6kZ", "spotify:track:0DQyHCvclI1f44QrzjN7jQ",
    "spotify:track:0VjIjW4GlUZAMYd2vXMi3b"
]

// --- Data Models ---
// (Keep existing: SpotifyUser, CreatePlaylistPayload, SpotifyPlaylist, AddTracksPayload, SpotifySnapshotResponse, EmptyResponse)
struct SpotifyUser: Decodable { let id: String }
struct CreatePlaylistPayload: Encodable { let name: String; let description: String; let `public`: Bool }
struct SpotifyPlaylist: Decodable { let id: String; let name: String }
struct AddTracksPayload: Encodable { let uris: [String] }
struct SpotifySnapshotResponse: Decodable { let snapshot_id: String }
struct EmptyResponse: Decodable {}

// --- API Service ---
// (Keep existing ApiError enum and SpotifyPlaylistService class - they are correct)
enum ApiError: Error, LocalizedError {
    case invalidURL; case requestFailed(Error); case invalidResponse;
    case decodingError(Error); case encodingError(Error); case httpError(statusCode: Int, details: String?)
    var errorDescription: String? { /* ... existing implementation ... */
        switch self {
        case .invalidURL: return "Internal configuration error (Invalid URL)."
        case .requestFailed(let error): return "Network request failed. Check connection. (\(error.localizedDescription))"
        case .invalidResponse: return "Invalid server response."
        case .decodingError(let error): print("Decoding Error: \(error)"); return "Failed to process server response."
        case .encodingError(let error): return "Failed to prepare data. (\(error.localizedDescription))"
        case .httpError(let code, _):
            var msg = "API Error (\(code))."
            if code == 401 { msg += " Check API token." }
            else if code == 403 { msg += " Check token scopes." }
            else if code == 404 { msg += " Resource not found." }
            return msg
        }
    }
}
class SpotifyPlaylistService {
    private let apiBaseUrl = "https://api.spotify.com/v1"
    private func fetchWebApi<T: Decodable, B: Encodable>(endpoint: String, method: String, body: B, token: String) async throws -> T { /* ... existing implementation ... */
        guard let url = URL(string: apiBaseUrl + endpoint) else { throw ApiError.invalidURL }
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        do { request.httpBody = try JSONEncoder().encode(body) } catch { throw ApiError.encodingError(error) }
        return try await performRequestAndDecode(request: request)
    }
    private func fetchWebApi<T: Decodable>(endpoint: String, method: String, token: String) async throws -> T { /* ... existing implementation ... */
        guard let url = URL(string: apiBaseUrl + endpoint) else { throw ApiError.invalidURL }
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return try await performRequestAndDecode(request: request)
    }
    private func performRequestAndDecode<T: Decodable>(request: URLRequest) async throws -> T { /* ... existing implementation ... */
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else { throw ApiError.invalidResponse }
        guard (200...299).contains(httpResponse.statusCode) else {
            let details = String(data: data, encoding: .utf8)
            print("HTTP Error \(httpResponse.statusCode): \(details ?? "N/A")")
            throw ApiError.httpError(statusCode: httpResponse.statusCode, details: details)
        }
        if data.isEmpty && T.self == EmptyResponse.self { if let empty = EmptyResponse() as? T { return empty } }
        do { return try JSONDecoder().decode(T.self, from: data) } catch {
            print("Decoding Error for \(T.self): \(error)"); print("Data: \(String(data: data, encoding: .utf8) ?? "N/A")")
            throw ApiError.decodingError(error)
        }
    }
    func getCurrentUserId(token: String) async throws -> String { let user: SpotifyUser = try await fetchWebApi(endpoint: "/me", method: "GET", token: token)
        return user.id }
    func createPlaylist(userId: String, name: String, description: String, isPublic: Bool, token: String) async throws -> SpotifyPlaylist { try await fetchWebApi(endpoint: "/users/\(userId)/playlists", method: "POST", body: CreatePlaylistPayload(name: name, description: description, public: isPublic), token: token) }
    func addTracksToPlaylist(playlistId: String, trackUris: [String], token: String) async throws -> SpotifySnapshotResponse { try await fetchWebApi(endpoint: "/playlists/\(playlistId)/tracks", method: "POST", body: AddTracksPayload(uris: trackUris), token: token) }
}

// --- WebView Component ---
// (Keep existing WebView struct - it's correct)
struct WebView: UIViewRepresentable {
    let url: URL
    func makeUIView(context: Context) -> WKWebView { /* ... existing implementation ... */
        let config = WKWebViewConfiguration()
//        config.preferences.javaScriptEnabled = true
        config.allowsInlineMediaPlayback = true
        let webView = WKWebView(frame: .zero, configuration: config)
        
        let webpagePrefs = WKWebpagePreferences()
        webpagePrefs.allowsContentJavaScript = true
        config.defaultWebpagePreferences = webpagePrefs
        
        return webView
    }
    func updateUIView(_ uiView: WKWebView, context: Context) { /* ... existing implementation ... */
        if uiView.url != url { uiView.load(URLRequest(url: url)) }
    }
}

// --- SwiftUI View ---
struct PlaylistCreationAndPlayView: View {
    // State variables - REMOVED 'private'
    @State var statusMessage: String = "Ready to create playlist."
    @State var isLoading: Bool = false
    @State var createdPlaylistName: String? = nil
    @State var createdPlaylistId: String? = nil
    @State var errorMessage: String? = nil
    @State var showCreationAlert: Bool = false

    // Keep service instance private
    private let playlistService = SpotifyPlaylistService()

    // Computed property - Keep private
    private var spotifyEmbedUrl: URL? {
        guard let playlistId = createdPlaylistId else { return nil }
        let urlString = "https://open.spotify.com/embed/playlist/\(playlistId)?theme=0"
        return URL(string: urlString)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 15) {
                // --- Status and Control Area ---
                Group {
                    if isLoading {
                         ProgressView("Working...")
                             .padding(.vertical)
                    } else {
                         Text(statusMessage)
                             .font(.headline)
                             .foregroundColor(errorMessage != nil ? .red : .secondary)
                             .multilineTextAlignment(.center)
                             .padding(.bottom, 5)

                         if let errorMsg = errorMessage {
                             Text(errorMsg)
                                 .font(.caption)
                                 .foregroundColor(.red)
                                 .multilineTextAlignment(.center)
                                 .padding(.horizontal)
                                 .padding(.bottom, 10)
                         }

                        if !isLoading && createdPlaylistId == nil {
                            Button { Task { await createAndAddTracks() } } label: {
                                Label("Create Playlist & Add Tracks", systemImage: "plus.music.note")
                            }
                            .buttonStyle(.borderedProminent)
                            .padding(.top)
                         } else if errorMessage != nil && createdPlaylistId == nil {
                             Button("Retry Creation", systemImage: "arrow.clockwise") { Task { await createAndAddTracks() } }
                             .buttonStyle(.bordered).tint(.orange)
                         }
                    }
                }.padding(.horizontal)

                // --- Embedded Player Area ---
                if let playlistName = createdPlaylistName, let embedUrl = spotifyEmbedUrl {
                     Divider().padding(.vertical, 10)
                     Text("Now Playing: \(playlistName)")
                        .font(.title3).padding(.bottom, 5)
                    WebView(url: embedUrl)
                        .frame(minHeight: 352)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .padding(.horizontal).padding(.bottom)
                } else if createdPlaylistId != nil && spotifyEmbedUrl == nil {
                     Text("Error: Could not create embed URL.").foregroundColor(.red).padding()
                } else {
                     Spacer()
                     Text("Click the button above to create the playlist.").font(.caption).foregroundColor(.secondary).padding(.bottom)
                }
                if createdPlaylistId == nil { Spacer() }
            }
            .navigationTitle("Spotify Playlist Creator")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Playlist Created", isPresented: $showCreationAlert) { Button("OK", role: .cancel) { } }
            message: { Text("Playlist '\(createdPlaylistName ?? "...")' is ready. Player displayed.") }
        }
    }

    // --- Main function orchestrating the API calls ---
    // (Keep existing createAndAddTracks() function - it remains the same)
    @MainActor
    private func createAndAddTracks() async { /* ... existing implementation ... */
        isLoading = true; errorMessage = nil; createdPlaylistName = nil; createdPlaylistId = nil
        statusMessage = "Starting..."
        guard spotifyApiToken != "YOUR_SPOTIFY_API_TOKEN", !spotifyApiToken.isEmpty else {
            errorMessage = "Dev Error: API Token not set."; isLoading = false; statusMessage = "Config Error."; return
        }
        let name = "My top tracks playlist"; let desc = "Created via SwiftUI"
        do {
            statusMessage = "Fetching User ID..."; let userId = try await playlistService.getCurrentUserId(token: spotifyApiToken)
            statusMessage = "Creating Playlist..."; let list = try await playlistService.createPlaylist(userId: userId, name: name, description: desc, isPublic: false, token: spotifyApiToken)
            let tempName = list.name; let tempId = list.id
            statusMessage = "Adding Tracks..."; let _ = try await playlistService.addTracksToPlaylist(playlistId: list.id, trackUris: sampleTrackUris, token: spotifyApiToken)
            createdPlaylistName = tempName; createdPlaylistId = tempId
            statusMessage = "Playlist ready!"; showCreationAlert = true
        } catch {
            print("Error: \(error)")
            if let localized = error as? LocalizedError { errorMessage = localized.errorDescription ?? "Unknown error." }
            else { errorMessage = error.localizedDescription }
            statusMessage = "Operation failed"
        }
        isLoading = false
    }
}

// --- App Entry Point ---
// (Keep existing App struct - it remains the same)
@main
struct SpotifyPlaylistCreatorApp: App {
    var body: some Scene { WindowGroup { PlaylistCreationAndPlayView() } }
}

// --- Preview Provider --- FIXES APPLIED HERE ---
struct PlaylistCreationAndPlayView_Previews: PreviewProvider {
    static var previews: some View {
        // Use a Group to return a single container
        Group {
            // 1. Initial State
            PlaylistCreationAndPlayView()
                .previewDisplayName("1. Initial State")

            // --- 2. Player Shown State ---
            // Configure the view *before* placing it in the Group
            let successView: PlaylistCreationAndPlayView = {
                let view = PlaylistCreationAndPlayView()
                // Modify state variables (now accessible because 'private' was removed)
                view.createdPlaylistId = "37i9dQZF1DXcBWIGoYBM5M" // Example: Spotify's "Today's Top Hits"
                view.createdPlaylistName = "Today's Top Hits"    // Matching name
                view.statusMessage = "Playlist ready!"           // Set status
                return view // Return the configured view
            }() // Immediately invoke the closure
            // Now place the fully configured view into the Group
            successView
                 .previewDisplayName("2. Player Active")
                 .environment(\.colorScheme, .dark) // Example modifier


            // --- 3. Loading State ---
            let loadingView: PlaylistCreationAndPlayView = {
                let view = PlaylistCreationAndPlayView()
                view.isLoading = true                         // Set state
                view.statusMessage = "Adding tracks..."       // Set state
                return view
            }()
            loadingView
                .previewDisplayName("3. Loading")


            // --- 4. Error State ---
            let errorView: PlaylistCreationAndPlayView = {
                let view = PlaylistCreationAndPlayView()
                view.errorMessage = "API request failed (401). Check token." // Set state
                view.statusMessage = "Operation failed"                   // Set state
                return view
            }()
            errorView
                .previewDisplayName("4. Error State")

        }
        // You can apply global modifiers to the Group if needed, e.g.,
         .previewLayout(.sizeThatFits)
    }
}
