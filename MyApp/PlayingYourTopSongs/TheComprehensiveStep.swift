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

// --- Preview Provider --- WITH ENHANCED MOCK STATES ---
struct PlaylistCreationAndPlayView_Previews: PreviewProvider {
    static var previews: some View {
        // Use a Group to return a single container for multiple previews
        Group {
            // 1. Initial State - Before any action
            PlaylistCreationAndPlayView()
                .previewDisplayName("1. Initial - Ready")

            // --- Loading States ---

            // 2a. Loading State - Fetching User ID
            let loadingUserView: PlaylistCreationAndPlayView = {
                let view = PlaylistCreationAndPlayView()
                view.isLoading = true
                view.statusMessage = "Fetching your User ID..."
                return view
            }()
            loadingUserView
                .previewDisplayName("2a. Loading - Fetching User")

            // 2b. Loading State - Creating Playlist
            let loadingCreateView: PlaylistCreationAndPlayView = {
                let view = PlaylistCreationAndPlayView()
                view.isLoading = true
                // Use the actual playlist name expected
                view.statusMessage = "Creating playlist: 'My top tracks playlist'..."
                return view
            }()
            loadingCreateView
                .previewDisplayName("2b. Loading - Creating Playlist")

            // 2c. Loading State - Adding Tracks
            let loadingAddTracksView: PlaylistCreationAndPlayView = {
                let view = PlaylistCreationAndPlayView()
                view.isLoading = true
                // Show how many tracks are being added
                view.statusMessage = "Adding \(sampleTrackUris.count) tracks to playlist..."
                return view
            }()
            loadingAddTracksView
                .previewDisplayName("2c. Loading - Adding Tracks")


            // --- Success State ---

            // 3. Success State - Player Shown
            let successView: PlaylistCreationAndPlayView = {
                let view = PlaylistCreationAndPlayView()
                // Use a known good, stable playlist ID for visual consistency in previews
                view.createdPlaylistId = "37i9dQZF1DXcBWIGoYBM5M" // Example: Spotify's "Today's Top Hits"
                view.createdPlaylistName = "Today's Top Hits"    // Matching name for the example ID
                view.statusMessage = "Playlist ready!"           // Final success status
                // Simulate alert being ready to show (though it won't pop up in static preview)
                // view.showCreationAlert = true // Optional: Set if UI changes based on this
                return view
            }()
            successView
                 .previewDisplayName("3. Success - Player Active")
                 .environment(\.colorScheme, .dark) // Show in dark mode


            // --- Error States ---

            // 4a. Error State - No Token Configured (Simulates guard check failure)
            let errorNoTokenView: PlaylistCreationAndPlayView = {
                let view = PlaylistCreationAndPlayView()
                // Simulate the specific error message from the guard check
                view.errorMessage = "Dev Error: API Token not set."
                view.statusMessage = "Config Error."
                view.isLoading = false // Ensure loading is off
                return view
            }()
            errorNoTokenView
                .previewDisplayName("4a. Error - No Token")

            // 4b. Error State - Unauthorized (401)
            let error401View: PlaylistCreationAndPlayView = {
                let view = PlaylistCreationAndPlayView()
                // Use the actual formatted error message from your ApiError enum
                view.errorMessage = "API Error (401). Check API token."
                view.statusMessage = "Operation failed"
                view.isLoading = false
                return view
            }()
            error401View
                .previewDisplayName("4b. Error - Unauthorized (401)")

            // 4c. Error State - Forbidden (403 - e.g., bad scopes)
            let error403View: PlaylistCreationAndPlayView = {
                let view = PlaylistCreationAndPlayView()
                view.errorMessage = "API Error (403). Check token scopes."
                view.statusMessage = "Operation failed"
                view.isLoading = false
                return view
            }()
            error403View
                .previewDisplayName("4c. Error - Forbidden (403)")

            // 4d. Error State - Not Found (404)
             let error404View: PlaylistCreationAndPlayView = {
                 let view = PlaylistCreationAndPlayView()
                 view.errorMessage = "API Error (404). Resource not found." // Simulate incorrect User ID or Playlist ID
                 view.statusMessage = "Operation failed"
                 view.isLoading = false
                 return view
             }()
             error404View
                 .previewDisplayName("4d. Error - Not Found (404)")

            // 4e. Error State - Generic Network Failure (Simulates ApiError.requestFailed)
             let errorNetworkView: PlaylistCreationAndPlayView = {
                 let view = PlaylistCreationAndPlayView()
                 // Simulate a generic network error description
                 view.errorMessage = "Network request failed. Check connection. (The request timed out.)"
                 view.statusMessage = "Operation failed"
                 view.isLoading = false
                 return view
             }()
             errorNetworkView
                 .previewDisplayName("4e. Error - Network Failure")

            // 4f. Error State - Decoding Failure (Simulates ApiError.decodingError)
             let errorDecodingView: PlaylistCreationAndPlayView = {
                 let view = PlaylistCreationAndPlayView()
                 view.errorMessage = "Failed to process server response." // Simulate bad JSON from API
                 view.statusMessage = "Operation failed"
                 view.isLoading = false
                 return view
             }()
             errorDecodingView
                 .previewDisplayName("4f. Error - Decoding Failure")

        }
        // Apply global modifiers to all previews within the Group if needed
         .previewLayout(.sizeThatFits) // Example: Adjust layout behavior
    }
}
