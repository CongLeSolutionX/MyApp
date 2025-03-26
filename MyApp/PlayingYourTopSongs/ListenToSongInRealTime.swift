////
////  ListenToSongInRealTime.swift
////  MyApp
////
////  Created by Cong Le on 3/26/25.
////
//
//import SwiftUI
//import WebKit // Import WebKit for WKWebView
//
//// --- Constants and Configuration ---
//// WARNING: Hardcoding tokens is insecure and bad practice for production apps.
//// Obtain a token via Spotify's authorization flows for a real application.
//// See: https://developer.spotify.com/documentation/web-api/concepts/authorization
//let spotifyApiToken = "YOUR_SPOTIFY_API_TOKEN" // <--- REPLACE WITH YOUR ACTUAL TOKEN
//
//// Predefined track URIs from the example screenshot
//let sampleTrackUris = [
//    "spotify:track:3myLRVDhN4Vba1F2JCQU0W", // Example URI 1 (Replace if needed)
//    "spotify:track:5qbjUmVV1mSClfNrpV33jS"  // Example URI 2 (Add more or replace as needed)
//    // Add the other 3 URIs if you have them
//]
//
//// --- Data Models (Matching Spotify API Payloads & Responses) ---
//// (Keep existing models: SpotifyUser, CreatePlaylistPayload, SpotifyPlaylist, AddTracksPayload, SpotifySnapshotResponse, EmptyResponse)
//struct SpotifyUser: Decodable { let id: String }
//struct CreatePlaylistPayload: Encodable { let name: String; let description: String; let `public`: Bool }
//struct SpotifyPlaylist: Decodable { let id: String; let name: String }
//struct AddTracksPayload: Encodable { let uris: [String] }
//struct SpotifySnapshotResponse: Decodable { let snapshot_id: String }
//struct EmptyResponse: Decodable {}
//
//// --- API Service ---
//// (Keep existing ApiError enum and SpotifyPlaylistService class with overloaded fetchWebApi methods)
//enum ApiError: Error {
//    case invalidURL
//    case requestFailed(Error)
//    case invalidResponse
//    case decodingError(Error)
//    case encodingError(Error)
//    case httpError(statusCode: Int, details: String?)
//}
//
//class SpotifyPlaylistService {
//    private let apiBaseUrl = "https://api.spotify.com/v1"
//
//    // Overload 1: For requests WITH a body (POST, PUT, etc.)
//    private func fetchWebApi<T: Decodable, B: Encodable>(endpoint: String, method: String, body: B, token: String) async throws -> T {
//        guard let url = URL(string: apiBaseUrl + endpoint) else { throw ApiError.invalidURL }
//        var request = URLRequest(url: url)
//        request.httpMethod = method
//        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        do { request.httpBody = try JSONEncoder().encode(body) } catch { throw ApiError.encodingError(error) }
//        return try await performRequestAndDecode(request: request)
//    }
//
//    // Overload 2: For requests WITHOUT a body (GET, DELETE, etc.)
//    private func fetchWebApi<T: Decodable>(endpoint: String, method: String, token: String) async throws -> T {
//        guard let url = URL(string: apiBaseUrl + endpoint) else { throw ApiError.invalidURL }
//        var request = URLRequest(url: url)
//        request.httpMethod = method
//        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//        return try await performRequestAndDecode(request: request)
//    }
//
//    // Private Helper for Network Call & Decoding
//    private func performRequestAndDecode<T: Decodable>(request: URLRequest) async throws -> T {
//        let data: Data
//        let response: URLResponse
//        do { (data, response) = try await URLSession.shared.data(for: request) } catch { throw ApiError.requestFailed(error) }
//        guard let httpResponse = response as? HTTPURLResponse else { throw ApiError.invalidResponse }
//        guard (200...299).contains(httpResponse.statusCode) else {
//            let errorDetails = String(data: data, encoding: .utf8)
//            print("HTTP Error: \(httpResponse.statusCode) for URL: \(request.url?.absoluteString ?? "Unknown URL")")
//            print("Response Data: \(errorDetails ?? "Undecodable error data")")
//            throw ApiError.httpError(statusCode: httpResponse.statusCode, details: errorDetails)
//        }
//        if data.isEmpty {
//            if T.self == EmptyResponse.self { if let empty = EmptyResponse() as? T { return empty } }
//             // Consider throwing decodingError or invalidResponse if data is empty but T is not EmptyResponse
//             // For current Spotify APIs used, we expect data, so let decoding handle it.
//         }
//        do {
//            let decoder = JSONDecoder()
//            return try decoder.decode(T.self, from: data)
//        } catch {
//            print("Decoding failed for type \(T.self): \(error)")
//             if let decodingError = error as? DecodingError { print("Decoding Error Details: \(decodingError)") }
//            print("Failed Data: \(String(data: data, encoding: .utf8) ?? "Undecodable data")")
//            throw ApiError.decodingError(error)
//        }
//    }
//
//    // Public API Methods
//    func getCurrentUserId(token: String) async throws -> String {
//        let user: SpotifyUser = try await fetchWebApi(endpoint: "/me", method: "GET", token: token)
//        return user.id
//    }
//    func createPlaylist(userId: String, name: String, description: String, isPublic: Bool, token: String) async throws -> SpotifyPlaylist {
//        let endpoint = "/users/\(userId)/playlists"
//        let payload = CreatePlaylistPayload(name: name, description: description, public: isPublic)
//        let playlist: SpotifyPlaylist = try await fetchWebApi(endpoint: endpoint, method: "POST", body: payload, token: token)
//        return playlist
//    }
//    func addTracksToPlaylist(playlistId: String, trackUris: [String], token: String) async throws -> SpotifySnapshotResponse {
//        let endpoint = "/playlists/\(playlistId)/tracks"
//        let payload = AddTracksPayload(uris: trackUris)
//        let snapshotResponse: SpotifySnapshotResponse = try await fetchWebApi(endpoint: endpoint, method: "POST", body: payload, token: token)
//        return snapshotResponse
//    }
//}
//
//// --- WebView Component ---
//// Wrapper struct to use WKWebView in SwiftUI
//struct WebView: UIViewRepresentable {
//    let url: URL
//
//    func makeUIView(context: Context) -> WKWebView {
//        // Enable JavaScript - Spotify Embed might need it
//        let preferences = WKPreferences()
//        preferences.javaScriptEnabled = true
//
//        let configuration = WKWebViewConfiguration()
//        configuration.preferences = preferences
//        // Allow inline playback if needed, might not be necessary for embed
//        configuration.allowsInlineMediaPlayback = true
//
//        let webView = WKWebView(frame: .zero, configuration: configuration)
//        webView.allowsBackForwardNavigationGestures = false // Disable navigation gestures within the embed
//        webView.scrollView.isScrollEnabled = true // Allow scrolling within the embed if content overflows
//        return webView
//    }
//
//    func updateUIView(_ uiView: WKWebView, context: Context) {
//        let request = URLRequest(url: url)
//        uiView.load(request)
//    }
//}
//
//
//// --- SwiftUI View ---
//struct PlaylistCreationAndPlayView: View { // Renamed View
//    @State private var statusMessage: String = "Ready."
//    @State private var isLoading: Bool = false
//    @State private var createdPlaylistName: String? = nil
//    @State private var createdPlaylistId: String? = nil // <-- Store the ID
//    @State private var errorMessage: String? = nil
//    @State private var showSuccessAlert: Bool = false // Keep alert for creation success
//
//    private let playlistService = SpotifyPlaylistService()
//
//    // Computed property for the embed URL
//    private var spotifyEmbedUrl: URL? {
//        guard let playlistId = createdPlaylistId else { return nil }
//        // Construct the URL based on Step 3 screenshot
//        // theme=0 likely represents the dark theme
//        let urlString = "https://open.spotify.com/embed/playlist/\(playlistId)?theme=0"
//        return URL(string: urlString)
//    }
//
//    var body: some View {
//        VStack(spacing: 15) { // Adjusted spacing
//            Text("Spotify Playlist Creator & Player")
//                .font(.title2) // Slightly smaller title
//                .padding(.bottom)
//
//            // --- Status and Control Area ---
//            if isLoading {
//                ProgressView()
//                    .padding(.bottom, 5)
//                Text(statusMessage)
//                    .foregroundColor(.secondary)
//                    .multilineTextAlignment(.center)
//            } else {
//                 // Display general status or error
//                 Text(statusMessage)
//                     .foregroundColor(errorMessage != nil ? .red : .primary)
//                     .multilineTextAlignment(.center)
//                     .padding(.bottom, 5)
//
//                 // Display detailed error message if present
//                 if let errorMsg = errorMessage {
//                     Text("Error Details: \(errorMsg)")
//                         .font(.caption)
//                         .foregroundColor(.red)
//                         .multilineTextAlignment(.center)
//                         .padding(.horizontal)
//                 }
//
//                // Button to start creation (only show if not loading and playlist not yet created)
//                if !isLoading && createdPlaylistId == nil {
//                    Button("1. Create 'My top tracks playlist'") {
//                        Task { await createAndAddTracks() }
//                    }
//                    .buttonStyle(.borderedProminent)
//                    .disabled(isLoading)
//                }
//                 // Retry button if error occurred before playlist creation finished
//                 else if errorMessage != nil && createdPlaylistId == nil {
//                     Button("Retry Creation") { Task { await createAndAddTracks() } }
//                         .buttonStyle(.bordered)
//                 }
//            }
//
//            // --- Embedded Player Area ---
//            if let playlistName = createdPlaylistName, let embedUrl = spotifyEmbedUrl {
//                 Divider().padding(.vertical, 10) // Separator
//                 Text("2. Listen to '\(playlistName)'")
//                    .font(.headline)
//                    .padding(.bottom, 5)
//
//                // Embed the WebView
//                WebView(url: embedUrl)
//                    // Set a frame based on the iframe example (minHeight: 360px)
//                    // Adjust height as needed for your UI
//                    .frame(height: 380) // Default height for Spotify embed
//                    .border(Color.gray.opacity(0.5), width: 1) // Optional border
//                    .padding(.horizontal) // Add some horizontal padding
//
//            } else if createdPlaylistId != nil && spotifyEmbedUrl == nil {
//                 // Handle unlikely case where ID exists but URL fails
//                 Text("Error: Could not create embed URL.")
//                     .foregroundColor(.red)
//            }
//
//            Spacer() // Pushes content to the top
//        }
//        .padding()
//        // Alert only confirms the creation part
//        .alert("Playlist Created!", isPresented: $showSuccessAlert) {
//             Button("OK", role: .cancel) { }
//         } message: {
//             Text("Playlist '\(createdPlaylistName ?? "My top tracks playlist")' created and tracks added. Now displaying player.")
//         }
//    }
//
//    // Main function orchestrating the API calls
//    private func createAndAddTracks() async {
//        // Reset state for retry
//        isLoading = true
//        errorMessage = nil
//        createdPlaylistName = nil
//        createdPlaylistId = nil // Reset ID on retry
//        statusMessage = "Starting playlist creation..."
//
//        let playlistName = "My top tracks playlist"
//        let playlistDescription = "Playlist created by the tutorial on developer.spotify.com"
//
//        guard spotifyApiToken != "YOUR_SPOTIFY_API_TOKEN", !spotifyApiToken.isEmpty else {
//             await MainActor.run {
//                 errorMessage = "Spotify API Token is not set."
//                 isLoading = false
//                 statusMessage = "Error: Token Required."
//             }
//            return
//        }
//
//        do {
//            // Step 1: Get User ID
//            await updateStatus("Fetching user info...")
//            let userId = try await playlistService.getCurrentUserId(token: spotifyApiToken)
//
//            // Step 2: Create Playlist
//            await updateStatus("Creating playlist '\(playlistName)'...")
//            let newPlaylist = try await playlistService.createPlaylist(
//                userId: userId,
//                name: playlistName,
//                description: playlistDescription,
//                isPublic: false,
//                token: spotifyApiToken
//            )
//            // Store details needed later *before* adding tracks
//             let finalPlaylistName = newPlaylist.name
//             let finalPlaylistId = newPlaylist.id
//             await updateStatus("Playlist created: \(newPlaylist.name)")
//
//
//            // Step 3: Add Tracks
//            await updateStatus("Adding \(sampleTrackUris.count) tracks...")
//            let _ = try await playlistService.addTracksToPlaylist( // snapshotResponse not used here
//                playlistId: newPlaylist.id,
//                trackUris: sampleTrackUris,
//                token: spotifyApiToken
//            )
//
//            // Update state now that everything succeeded
//            await MainActor.run {
//                 self.createdPlaylistName = finalPlaylistName
//                 self.createdPlaylistId = finalPlaylistId // <-- Store the ID
//                 self.statusMessage = "Playlist ready!" // Update final status
//                 self.showSuccessAlert = true // Show confirmation alert
//             }
//             print("Playlist created (\(finalPlaylistId)) and tracks added.")
//
//
//        } catch let apiError as ApiError {
//            await MainActor.run {
//                 var detailedError = ""
//                 // (Keep existing detailed error handling switch)
//                 switch apiError {
//                 case .invalidURL: detailedError = "Internal error: Invalid API URL."
//                 case .requestFailed(let e): detailedError = "Network failed. Check connection. (\(e.localizedDescription))"
//                 case .invalidResponse: detailedError = "Invalid server response."
//                 case .decodingError(let e): detailedError = "Failed to decode response. (\(e.localizedDescription))"
//                 case .encodingError(let e): detailedError = "Failed to encode request. (\(e.localizedDescription))"
//                 case .httpError(let code, let details):
//                     var hint = ""
//                      if code == 401 { hint = " (Hint: Token invalid/expired?)." }
//                      else if code == 403 { hint = " (Hint: Token lacks scopes like 'playlist-modify-private'?)." }
//                      else if code == 404 { hint = " (Hint: User/Endpoint not found?)." }
//                     detailedError = "API Error (Status \(code))\(hint) \(details ?? "")"
//                 }
//                 self.errorMessage = detailedError
//                 self.statusMessage = "Playlist creation failed."
//             }
//         } catch {
//            await MainActor.run {
//                 self.errorMessage = "Unexpected error: \(error.localizedDescription)"
//                 self.statusMessage = "Playlist creation failed."
//             }
//        }
//
//        // Ensure isLoading is set to false after completion
//        await MainActor.run { isLoading = false }
//    }
//
//    // Helper to update status message on the main thread
//    @MainActor
//    private func updateStatus(_ message: String) {
//         if isLoading { statusMessage = message }
//    }
//}
//
//// --- App Entry Point ---
//// @main // Uncomment this line to make this the entry point
//struct SpotifyPlaylistAppFull: App {
//    var body: some Scene {
//        WindowGroup {
//            PlaylistCreationAndPlayView() // Use the updated view
//        }
//    }
//}
//
//#Preview {
//    PlaylistCreationAndPlayView()
//}
//
////
////// --- Preview Provider ---
////struct PlaylistCreationAndPlayView_Previews: PreviewProvider {
////    static var previews: some View {
////        // Default preview (Initial State)
////        PlaylistCreationAndPlayView()
////            .previewDisplayName("1. Initial State")
////
////        // Preview showing Player (Success State)
////        let successView = PlaylistCreationAndPlayView()
////        successView._createdPlaylistId = State(initialValue: "1Aptu3B7oWn5o7eALG4wyK") // Use ID from screenshot
////        successView._createdPlaylistName = State(initialValue: "My top tracks playlist")
////        successView._statusMessage = State(initialValue: "Playlist ready!")
////        return successView
////             .previewDisplayName("2. Player Shown")
////
////         // Preview in loading state
////         let loadingView = PlaylistCreationAndPlayView()
////         loadingView._isLoading = State(initialValue: true)
////         loadingView._statusMessage = State(initialValue: "Adding tracks...")
////         return loadingView
////              .previewDisplayName("Loading State")
////
////          // Preview in error state
////          let errorView = PlaylistCreationAndPlayView()
////          errorView._errorMessage = State(initialValue: "API Error (Status 403) (Hint: Token lacks scopes...).")
////          errorView._statusMessage = State(initialValue: "Playlist creation failed.")
////          return errorView
////              .previewDisplayName("Error State")
////    }
////}
