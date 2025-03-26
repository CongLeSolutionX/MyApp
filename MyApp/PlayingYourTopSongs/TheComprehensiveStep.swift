//
//  TheComprehensiveStep.swift
//  MyApp
//
//  Created by Cong Le on 3/26/25.
//

import SwiftUI
import WebKit // Required for WKWebView

// --- Constants and Configuration ---
// WARNING: Hardcoding tokens is insecure and bad practice for production apps.
// Obtain a token via Spotify's authorization flows for a real application.
// See: https://developer.spotify.com/documentation/web-api/concepts/authorization
let spotifyApiToken = "YOUR_SPOTIFY_API_TOKEN" // <--- !!! REPLACE WITH YOUR ACTUAL TOKEN !!!

// Predefined track URIs from the example screenshot (or your chosen tracks)
let sampleTrackUris = [
    // Replace with the 5 URIs you intend to use
    "spotify:track:3myLRVDhN4Vba1F2JCQU0W", // Example track 1
    "spotify:track:5qbjUmVV1mSClfNrpV33jS", // Example track 2
    "spotify:track:2tnVG71enUj33Ic2nFN6kZ", // Example track 3 (Placeholder)
    "spotify:track:0DQyHCvclI1f44QrzjN7jQ", // Example track 4 (Placeholder)
    "spotify:track:0VjIjW4GlUZAMYd2vXMi3b"  // Example track 5 (Placeholder)
]

// --- Data Models (Matching Spotify API Payloads & Responses) ---

// --- User profile response (only need ID for this example)
struct SpotifyUser: Decodable {
    let id: String
    // Add other fields like display_name if needed
}

// --- Payload for creating a playlist
struct CreatePlaylistPayload: Encodable {
    let name: String
    let description: String
    let `public`: Bool // Use backticks because 'public' is a keyword
}

// --- Playlist response after creation (need ID and name)
struct SpotifyPlaylist: Decodable {
    let id: String
    let name: String
    // Add other fields like 'external_urls' if needed
}

// --- Payload for adding tracks to a playlist
struct AddTracksPayload: Encodable {
    let uris: [String]
    // position: Int? // Optional: where to insert tracks
}

// --- Response after adding tracks (snapshot_id)
struct SpotifySnapshotResponse: Decodable {
    let snapshot_id: String
}

// --- Helper struct for handling potentially empty responses ---
// Spotify doesn't typically return empty bodies for these specific POSTs on success,
// but it's good practice if dealing with APIs that might (e.g., DELETE).
struct EmptyResponse: Decodable {}

// --- API Service ---
enum ApiError: Error, LocalizedError { // Conform to LocalizedError for better display
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case decodingError(Error)
    case encodingError(Error)
    case httpError(statusCode: Int, details: String?) // Include details if possible

    // Provide user-facing descriptions
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Internal configuration error (Invalid URL)."
        case .requestFailed(let error):
            return "Network request failed. Please check your connection. (\(error.localizedDescription))"
        case .invalidResponse:
            return "Received an invalid or unexpected response from the server."
        case .decodingError(let error):
            // Print detailed decoding error for debugging, but show simpler message to user
            print("Decoding Error Details: \(error)")
            return "Failed to process server response (Decoding Error)."
        case .encodingError(let error):
            return "Failed to prepare data for sending. (\(error.localizedDescription))"
        case .httpError(let statusCode, _): // Details are logged, not shown directly
            var message = "API request failed (Status Code: \(statusCode))."
            if statusCode == 401 {
                message += " Please check if your API token is valid or expired."
            } else if statusCode == 403 {
                message += " You might not have permission (check token scopes)."
            } else if statusCode == 404 {
                 message += " The requested resource was not found."
            }
            return message
        }
    }
}

class SpotifyPlaylistService {
    private let apiBaseUrl = "https://api.spotify.com/v1"

    // --- fetchWebApi Overloads ---
    // Overload 1: For requests WITH a body (POST, PUT, etc.)
    private func fetchWebApi<T: Decodable, B: Encodable>(endpoint: String, method: String, body: B, token: String) async throws -> T {
        guard let url = URL(string: apiBaseUrl + endpoint) else {
            throw ApiError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type") // Required for POST/PUT with JSON body

        // Encode the provided body
        do {
            // Use JSONEncoder for converting struct to Data
            let encoder = JSONEncoder()
            // encoder.outputFormatting = .prettyPrinted // Optional: for debugging request body
            request.httpBody = try encoder.encode(body)
            // print("Request Body: \(String(data: request.httpBody ?? Data(), encoding: .utf8) ?? "nil")") // Debug log
        } catch {
            throw ApiError.encodingError(error)
        }

        return try await performRequestAndDecode(request: request)
    }

    // Overload 2: For requests WITHOUT a body (GET, DELETE, etc.)
    private func fetchWebApi<T: Decodable>(endpoint: String, method: String, token: String) async throws -> T {
        guard let url = URL(string: apiBaseUrl + endpoint) else {
            throw ApiError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        // No Content-Type or body needed for typical GET/DELETE

        return try await performRequestAndDecode(request: request)
    }

    // --- Private Helper for Network Call & Decoding ---
    private func performRequestAndDecode<T: Decodable>(request: URLRequest) async throws -> T {
        let data: Data
        let response: URLResponse
        do {
            // Perform the network request
            (data, response) = try await URLSession.shared.data(for: request)
            // print("Response received for \(request.url?.absoluteString ?? "")") // Debug log
        } catch {
            // Handle lower-level network errors (timeout, DNS, connection refused etc.)
            throw ApiError.requestFailed(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            // Should generally be an HTTPURLResponse
            throw ApiError.invalidResponse
        }

        // Check if the status code indicates success (200-299)
        guard (200...299).contains(httpResponse.statusCode) else {
            // Try to get error details from Spotify's JSON response body
            let errorDetails = String(data: data, encoding: .utf8)
            // Log detailed error for debugging
            print("HTTP Error: \(httpResponse.statusCode) for URL: \(request.url?.absoluteString ?? "Unknown URL")")
            print("Response Data: \(errorDetails ?? "Undecodable error data")")
            throw ApiError.httpError(statusCode: httpResponse.statusCode, details: errorDetails)
        }

        // Handle cases where response might be empty and the expected type allows it
        if data.isEmpty {
             // Check if the expected type T is specifically EmptyResponse
            if T.self == EmptyResponse.self {
                // If T is EmptyResponse, create an instance and cast it (safely)
                if let empty = EmptyResponse() as? T { return empty }
             }
            // If data is empty but T is not EmptyResponse, it's likely unexpected for these Spotify endpoints
            // Throwing a decoding error or invalid response might be appropriate.
            // Let the JSONDecoder handle it below, it will likely throw 'dataCorrupted'.
         }

        // Attempt to decode the JSON response data into the expected type T
        do {
            let decoder = JSONDecoder()
            // Spotify often uses snake_case, uncomment if needed, but explicit CodingKeys are safer
            // decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(T.self, from: data)
        } catch {
            // Handle JSON decoding errors
            // Print detailed error and raw data for debugging
            print("Decoding failed for type \(T.self): \(error)")
             if let decodingError = error as? DecodingError {
                 print("Decoding Error Details: \(decodingError)")
             }
            print("Failed Data String: \(String(data: data, encoding: .utf8) ?? "Undecodable data")")
            throw ApiError.decodingError(error)
        }
    }

    // --- Public API Methods ---

    // 1. Get Current User ID
    func getCurrentUserId(token: String) async throws -> String {
        let user: SpotifyUser = try await fetchWebApi(endpoint: "/me", method: "GET", token: token)
        return user.id
    }

    // 2. Create Playlist
    func createPlaylist(userId: String, name: String, description: String, isPublic: Bool, token: String) async throws -> SpotifyPlaylist {
        let endpoint = "/users/\(userId)/playlists"
        let payload = CreatePlaylistPayload(name: name, description: description, public: isPublic)
        let playlist: SpotifyPlaylist = try await fetchWebApi(endpoint: endpoint, method: "POST", body: payload, token: token)
        return playlist
    }

    // 3. Add Tracks to Playlist
    func addTracksToPlaylist(playlistId: String, trackUris: [String], token: String) async throws -> SpotifySnapshotResponse {
        let endpoint = "/playlists/\(playlistId)/tracks"
        let payload = AddTracksPayload(uris: trackUris)
        let snapshotResponse: SpotifySnapshotResponse = try await fetchWebApi(endpoint: endpoint, method: "POST", body: payload, token: token)
        return snapshotResponse
    }
}


// --- WebView Component ---
struct WebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        // Enable JavaScript - Spotify Embed player relies heavily on it
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true

        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences
        // Allow media playback without going fullscreen automatically
        configuration.allowsInlineMediaPlayback = true
        // Allow Picture in Picture if needed
        configuration.allowsPictureInPictureMediaPlayback = true

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.allowsBackForwardNavigationGestures = false // Usually not desired for embeds
        webView.scrollView.isScrollEnabled = true // Allow scrolling within the embed frame
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Only load if the URL has changed (or initially)
        // This check might be redundant if the view hierarchy ensures this, but it's safe.
        if uiView.url != url {
            let request = URLRequest(url: url)
            uiView.load(request)
        }
    }
}


// --- SwiftUI View ---
struct PlaylistCreationAndPlayView: View {
    // State variables to manage UI and data flow
    @State private var statusMessage: String = "Ready to create playlist."
    @State private var isLoading: Bool = false
    @State private var createdPlaylistName: String? = nil
    @State private var createdPlaylistId: String? = nil // Store the ID for the embed URL
    @State private var errorMessage: String? = nil
    @State private var showCreationAlert: Bool = false // Alert confirms creation step

    // Instance of the API service
    private let playlistService = SpotifyPlaylistService()

    // Computed property to build the Spotify embed URL when the ID is available
    private var spotifyEmbedUrl: URL? {
        guard let playlistId = createdPlaylistId else { return nil }
        // Construct the URL based on Step 3 screenshot structure
        // theme=0 likely represents the dark theme
        let urlString = "https://open.spotify.com/embed/playlist/\(playlistId)?theme=0"
        return URL(string: urlString)
    }

    var body: some View {
        NavigationStack { // Use NavigationStack for a title bar
            VStack(spacing: 15) {

                // --- Status and Control Area ---
                Group { // Group for easier conditional logic reading
                    if isLoading {
                        ProgressView("Working...") // ProgressView with label
                            .padding(.vertical) // Give it some space
                    } else {
                         // Display general status or error
                         Text(statusMessage)
                             .font(.headline)
                             .foregroundColor(errorMessage != nil ? .red : .secondary) // Make status stand out less than error
                             .multilineTextAlignment(.center)
                             .padding(.bottom, 5)

                         // Display detailed error message if present
                         if let errorMsg = errorMessage {
                             Text(errorMsg) // Use the localizedError description
                                 .font(.caption)
                                 .foregroundColor(.red)
                                 .multilineTextAlignment(.center)
                                 .padding(.horizontal)
                                 .padding(.bottom, 10)
                         }

                        // Button to start creation (only if not loading and playlist doesn't exist yet)
                        if !isLoading && createdPlaylistId == nil {
                            Button {
                                Task { await createAndAddTracks() }
                            } label: {
                                Label("Create Playlist & Add Tracks", systemImage: "plus.music.note")
                            }
                            .buttonStyle(.borderedProminent)
                            .padding(.top) // Add space above the button
                        }
                         // Retry button if error occurred before playlist creation finished
                         else if errorMessage != nil && createdPlaylistId == nil {
                             Button("Retry Creation", systemImage: "arrow.clockwise") {
                                 Task { await createAndAddTracks() }
                             }
                             .buttonStyle(.bordered)
                             .tint(.orange) // Make retry stand out
                         }
                    }
                }
                .padding(.horizontal) // Padding for the status/control area


                // --- Embedded Player Area ---
                // Show this section only after successful creation (ID is available)
                if let playlistName = createdPlaylistName, let embedUrl = spotifyEmbedUrl {
                     Divider().padding(.vertical, 10) // Visual separator

                     Text("Now Playing: \(playlistName)")
                        .font(.title3)
                        .padding(.bottom, 5)

                    // Embed the WebView using the UIViewRepresentable wrapper
                    WebView(url: embedUrl)
                        // Recommended height for Spotify embed is 352, but allow flexibility
                        // Using geometry reader allows it to take available space
                        .frame(minHeight: 352) // Ensure minimum height
                        // Add border for clarity
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 8)) // Clip to rounded corners
                        .padding(.horizontal) // Add horizontal padding to the webview container
                        .padding(.bottom) // Add padding below webview

                } else if createdPlaylistId != nil && spotifyEmbedUrl == nil {
                     // Handle unlikely case where ID exists but URL construction fails
                     Text("Error: Could not create embed URL.")
                         .foregroundColor(.red)
                         .padding()
                } else {
                    // If playlist not created yet, provide instructions or leave empty
                     Spacer() // Take up space if player isn't shown
                     Text("Click the button above to create the playlist.")
                         .font(.caption)
                         .foregroundColor(.secondary)
                         .padding(.bottom)
                }
                 // Spacer ensures content is pushed towards the top if webview isn't filling space
                 // Remove if you want button centered when player isn't shown.
                 if createdPlaylistId == nil {  Spacer() }
            }
            .navigationTitle("Spotify Playlist Creator") // Title for the view
            .navigationBarTitleDisplayMode(.inline)
            // Alert confirms the background *creation* process succeeded
            .alert("Playlist Created", isPresented: $showCreationAlert) {
                 Button("OK", role: .cancel) { }
             } message: {
                 Text("Playlist '\(createdPlaylistName ?? "...")' is ready and tracks have been added. The player is now displayed.")
             }
        }
    }

    // --- Main function orchestrating the API calls ---
    @MainActor // Ensure UI updates happen on the main thread implicitly
    private func createAndAddTracks() async {
        // 1. Reset State for initiating the process or retrying
        isLoading = true
        errorMessage = nil
        createdPlaylistName = nil // Reset previous results on retry
        createdPlaylistId = nil   // Reset previous results on retry
        statusMessage = "Starting process..."

        // Basic check for placeholder token
        guard spotifyApiToken != "YOUR_SPOTIFY_API_TOKEN", !spotifyApiToken.isEmpty else {
             errorMessage = "Developer Error: Spotify API Token is not configured in the code."
             isLoading = false
             statusMessage = "Configuration Error"
            return
        }

        // Playlist details
        let playlistName = "My top tracks playlist" // Name from example
        let playlistDescription = "Playlist created via SwiftUI" // Custom description

        do {
            // Step 1: Get User ID
            statusMessage = "Fetching your User ID..."
            let userId = try await playlistService.getCurrentUserId(token: spotifyApiToken)
             print("User ID: \(userId)") // Log user ID

            // Step 2: Create Playlist
            statusMessage = "Creating playlist: '\(playlistName)'..."
            let newPlaylist = try await playlistService.createPlaylist(
                userId: userId,
                name: playlistName,
                description: playlistDescription,
                isPublic: false, // Set to false as per example screenshot context
                token: spotifyApiToken
            )
            print("Playlist Created: ID \(newPlaylist.id), Name: \(newPlaylist.name)")

            // Store details needed for the UI and next step *before* adding tracks
             let tempPlaylistName = newPlaylist.name // Store temporarily
             let tempPlaylistId = newPlaylist.id     // Store temporarily


            // Step 3: Add Tracks
            statusMessage = "Adding \(sampleTrackUris.count) tracks to playlist..."
            let snapshotResponse = try await playlistService.addTracksToPlaylist(
                playlistId: newPlaylist.id,
                trackUris: sampleTrackUris,
                token: spotifyApiToken
            )
            print("Tracks added successfully! Snapshot ID: \(snapshotResponse.snapshot_id)")


            // --- Final Success State Update ---
            // Update state variables now that all steps have succeeded
             createdPlaylistName = tempPlaylistName    // Use stored name
             createdPlaylistId = tempPlaylistId      // Use stored ID to trigger WebView display
             statusMessage = "Playlist ready!"         // Final success status
             showCreationAlert = true                // Show confirmation alert

        } catch {
            // --- Error Handling ---
            // Handle specific API errors or generic errors
            print("Error during playlist creation process: \(error)")
            if let localized = error as? LocalizedError {
                 errorMessage = localized.errorDescription ?? "An unknown error occurred."
             } else {
                 errorMessage = error.localizedDescription
             }
            statusMessage = "Operation failed" // Generic failure status
        }

        // --- Cleanup ---
        // Ensure isLoading is set back to false regardless of success or failure
        isLoading = false
    }
}

// --- App Entry Point ---
@main
struct SpotifyPlaylistCreatorApp: App {
    var body: some Scene {
        WindowGroup {
            PlaylistCreationAndPlayView() // The main view of the app
        }
    }
}

// --- Preview Provider ---
struct PlaylistCreationAndPlayView_Previews: PreviewProvider {
    static var previews: some View {
        // 1. Initial State (Before button tap)
        PlaylistCreationAndPlayView()
            .previewDisplayName("1. Initial State")

        // 2. Player Shown State (Simulates successful creation)
        // Use a hardcoded ID known to work for previewing the player layout
        let successView = PlaylistCreationAndPlayView()
        successView._createdPlaylistId = State(initialValue: "37i9dQZF1DXcBWIGoYBM5M") // Example: Spotify's "Today's Top Hits"
        successView._createdPlaylistName = State(initialValue: "Today's Top Hits")
        successView._statusMessage = State(initialValue: "Playlist ready!")
        return successView
             .previewDisplayName("2. Player Active")
             .environment(\.colorScheme, .dark) // Preview in dark mode like Spotify

         // 3. Loading State (Simulates process running)
         let loadingView = PlaylistCreationAndPlayView()
         loadingView._isLoading = State(initialValue: true)
         loadingView._statusMessage = State(initialValue: "Adding tracks...")
         return loadingView
              .previewDisplayName("3. Loading")

          // 4. Error State (Simulates API failure)
          let errorView = PlaylistCreationAndPlayView()
          errorView._errorMessage = State(initialValue: "API request failed (Status Code: 401). Please check if your API token is valid or expired.")
          errorView._statusMessage = State(initialValue: "Operation failed")
          return errorView
              .previewDisplayName("4. Error State")
    }
}
