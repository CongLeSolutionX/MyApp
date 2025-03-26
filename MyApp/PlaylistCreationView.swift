//
//  Save5SongsInAPlaylist.swift
//  MyApp
//
//  Created by Cong Le on 3/26/25.
//

import SwiftUI

// --- Constants and Configuration ---
// WARNING: Hardcoding tokens is insecure and bad practice for production apps.
// Obtain a token via Spotify's authorization flows for a real application.
// See: https://developer.spotify.com/documentation/web-api/concepts/authorization
let spotifyApiToken = "YOUR_SPOTIFY_API_TOKEN" // <--- REPLACE WITH YOUR ACTUAL TOKEN

// Predefined track URIs from the example screenshot
let sampleTrackUris = [
    "spotify:track:3myLRVDhN4Vba1F2JCQU0W", // Example URI 1 (Replace if needed)
    "spotify:track:5qbjUmVV1mSClfNrpV33jS"  // Example URI 2 (Add more or replace as needed)
    // Add the other 3 URIs if you have them
]

// --- Data Models (Matching Spotify API Payloads & Responses) ---

// User profile response (only need ID for this example)
struct SpotifyUser: Decodable {
    let id: String
}

// Payload for creating a playlist
struct CreatePlaylistPayload: Encodable {
    let name: String
    let description: String
    let `public`: Bool // Use backticks because 'public' is a keyword
}

// Playlist response after creation (only need ID)
struct SpotifyPlaylist: Decodable {
    let id: String
    let name: String // Include name for displaying result
    // You can add other fields like 'external_urls' if needed
}

// Payload for adding tracks to a playlist
struct AddTracksPayload: Encodable {
    let uris: [String]
}

// Response after adding tracks (snapshot_id)
struct SpotifySnapshotResponse: Decodable {
    let snapshot_id: String
}

// Helper struct for handling potentially empty responses if needed, though snapshot_id should always be present on success for adding tracks
struct EmptyResponse: Decodable {}

// --- API Service ---
enum ApiError: Error {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case decodingError(Error)
    case encodingError(Error)
    case httpError(statusCode: Int, details: String?) // Include details if possible
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
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Encode the provided body
        do {
            request.httpBody = try JSONEncoder().encode(body)
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
    // This refactored part contains the common logic for both overloads
    private func performRequestAndDecode<T: Decodable>(request: URLRequest) async throws -> T {
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw ApiError.requestFailed(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw ApiError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            // Try to decode error details from Spotify if available
            let errorDetails = String(data: data, encoding: .utf8)
            print("HTTP Error: \(httpResponse.statusCode) for URL: \(request.url?.absoluteString ?? "Unknown URL")")
            print("Response Data: \(errorDetails ?? "Undecodable error data")")
            throw ApiError.httpError(statusCode: httpResponse.statusCode, details: errorDetails)
        }

        // Handle cases where response might be empty and the expected type allows it
        if data.isEmpty {
             // Check if the expected type T is specifically EmptyResponse
            if T.self == EmptyResponse.self {
                // If T is EmptyResponse, create an instance and cast it (safely)
                if let empty = EmptyResponse() as? T {
                    return empty
                }
             }
            // If data is empty but T is not EmptyResponse, it might be an error or unexpected
             // Depending on API specifics, you might throw invalidResponse or handle differently
            // For Spotify, getting user/playlist/snapshot should have data, so decoding error is likely.
         }

        do {
            let decoder = JSONDecoder()
            // Handle snake_case if Spotify uses it (common in web APIs)
            // decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(T.self, from: data)
        } catch {
            print("Decoding failed for type \(T.self): \(error)")
             if let decodingError = error as? DecodingError {
                 print("Decoding Error Details: \(decodingError)")
             }
            print("Failed Data: \(String(data: data, encoding: .utf8) ?? "Undecodable data")")
            throw ApiError.decodingError(error)
        }
    }

    // --- Public API Methods ---

    // 1. Get Current User ID (Uses overload WITHOUT body)
    func getCurrentUserId(token: String) async throws -> String {
        // This call now unambiguously matches the overload without a body parameter
        let user: SpotifyUser = try await fetchWebApi(endpoint: "/me", method: "GET", token: token)
        return user.id
    }

    // 2. Create Playlist (Uses overload WITH body)
    func createPlaylist(userId: String, name: String, description: String, isPublic: Bool, token: String) async throws -> SpotifyPlaylist {
        let endpoint = "/users/\(userId)/playlists"
        let payload = CreatePlaylistPayload(name: name, description: description, public: isPublic)
        // This call matches the overload with the 'body: B' parameter
        let playlist: SpotifyPlaylist = try await fetchWebApi(endpoint: endpoint, method: "POST", body: payload, token: token)
        return playlist
    }

    // 3. Add Tracks to Playlist (Uses overload WITH body)
    func addTracksToPlaylist(playlistId: String, trackUris: [String], token: String) async throws -> SpotifySnapshotResponse {
        let endpoint = "/playlists/\(playlistId)/tracks"
        let payload = AddTracksPayload(uris: trackUris)
        // This call also matches the overload with the 'body: B' parameter
        let snapshotResponse: SpotifySnapshotResponse = try await fetchWebApi(endpoint: endpoint, method: "POST", body: payload, token: token)
        return snapshotResponse
    }
}


// --- SwiftUI View ---
struct PlaylistCreationView: View {
    @State var statusMessage: String = "Ready to create playlist."
    @State var isLoading: Bool = false
    @State var createdPlaylistName: String? = nil
    @State var errorMessage: String? = nil
    @State var showSuccessAlert: Bool = false

    private let playlistService = SpotifyPlaylistService()

    var body: some View {
        VStack(spacing: 20) {
            Text("Spotify Playlist Creator")
                .font(.title)
                .padding(.bottom)

            if isLoading {
                ProgressView()
                    .padding(.bottom, 5)
                Text(statusMessage)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            } else {
                // Display final success message prominently if available
                if let playlistName = createdPlaylistName {
                    Text("Successfully created playlist: \(playlistName)")
                        .font(.headline)
                        .foregroundColor(.green)
                        .padding(.bottom, 5)
                } else {
                    // Otherwise show current status or initial message
                     Text(statusMessage)
                         .foregroundColor(errorMessage != nil ? .red : .primary) // Make error stand out
                         .multilineTextAlignment(.center)
                         .padding(.bottom, 5)
                }

                 // Display detailed error message if present
                 if let errorMsg = errorMessage {
                     Text("Error Details: \(errorMsg)")
                         .font(.caption)
                         .foregroundColor(.red)
                         .multilineTextAlignment(.center)
                         .padding(.horizontal) // Add padding for longer error messages
                 }

                // Show button only if not loading and no final success message shown yet
                if !isLoading && createdPlaylistName == nil {
                    Button("Create 'My top tracks playlist'") {
                        // Start the creation process
                        Task {
                            await createAndAddTracks()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isLoading) // Redundant check, but safe
                }
                 // Optionally, add a button to retry or reset if failed
                 else if errorMessage != nil {
                     Button("Retry") {
                         Task {
                             await createAndAddTracks()
                         }
                     }
                     .buttonStyle(.bordered)
                 }
            }

            Spacer() // Pushes content to the top
        }
        .padding()
        .alert("Success!", isPresented: $showSuccessAlert) { // More enthusiastic title
             Button("Awesome!", role: .cancel) { } // More enthusiastic button
         } message: {
             Text("Playlist '\(createdPlaylistName ?? "My top tracks playlist")' created and \(sampleTrackUris.count) tracks added successfully!")
         }
    }

    // Main function orchestrating the API calls
    private func createAndAddTracks() async {
        // Reset state for retry
        isLoading = true
        errorMessage = nil
        createdPlaylistName = nil
        statusMessage = "Starting process..." // Initial status on click/retry

        let playlistName = "My top tracks playlist"
        let playlistDescription = "Playlist created by the tutorial on developer.spotify.com"

        // Basic check for token placeholder
        guard spotifyApiToken != "YOUR_SPOTIFY_API_TOKEN", !spotifyApiToken.isEmpty else {
             await MainActor.run {
                 errorMessage = "Spotify API Token is not set. Please replace 'YOUR_SPOTIFY_API_TOKEN' in the code."
                 isLoading = false
                 statusMessage = "Error: Token not configured."
             }
            return
        }

        do {
            // Step 1: Get User ID
            await updateStatus("Fetching user ID...")
            let userId = try await playlistService.getCurrentUserId(token: spotifyApiToken)
            // Don't necessarily need to show user ID in status
            // await updateStatus("User ID found: \(userId)")

            // Step 2: Create Playlist
            await updateStatus("Creating playlist: '\(playlistName)'...")
            let newPlaylist = try await playlistService.createPlaylist(
                userId: userId,
                name: playlistName,
                description: playlistDescription,
                isPublic: false, // As per the example (public: false)
                token: spotifyApiToken
            )
            await updateStatus("Playlist created: \(newPlaylist.name)")
            // Store name for success message *after* tracks are added too
            let finalPlaylistName = newPlaylist.name


            // Step 3: Add Tracks
            await updateStatus("Adding \(sampleTrackUris.count) tracks...")
            let snapshotResponse = try await playlistService.addTracksToPlaylist(
                playlistId: newPlaylist.id,
                trackUris: sampleTrackUris,
                token: spotifyApiToken
            )
            // Update final status and trigger alert
            await MainActor.run {
                 self.createdPlaylistName = finalPlaylistName // Set name for UI update
                 self.statusMessage = "Tracks added successfully!" // Final status before alert
                 self.showSuccessAlert = true // Show alert
             }
             print("Tracks added successfully! Snapshot ID: \(snapshotResponse.snapshot_id)")


        } catch let apiError as ApiError {
            // Handle specific API errors
             await MainActor.run {
                 var detailedError = ""
                 switch apiError {
                 case .invalidURL:
                     detailedError = "Internal error: Invalid API URL configuration."
                 case .requestFailed(let error):
                     detailedError = "Network request failed. Check connection. (\(error.localizedDescription))"
                 case .invalidResponse:
                     detailedError = "Received an invalid or unexpected response from the server."
                 case .decodingError(let error):
                     detailedError = "Failed to decode server response. API might have changed. (\(error.localizedDescription))"
                 case .encodingError(let error):
                    detailedError = "Failed to encode request data. (\(error.localizedDescription))"
                 case .httpError(let statusCode, let details):
                      // Provide more context for common errors like 401/403
                     var hint = ""
                     if statusCode == 401 {
                         hint = " (Hint: Token might be invalid or expired)."
                     } else if statusCode == 403 {
                         hint = " (Hint: Token might lack necessary scopes like 'playlist-modify-private')."
                      } else if statusCode == 404 {
                          hint = " (Hint: User/Playlist ID might be incorrect, or endpoint changed)."
                      }
                      detailedError = "API request failed (Status \(statusCode))\(hint) \(details ?? "")"
                 }
                 self.errorMessage = detailedError
                 self.statusMessage = "Process failed during execution." // More specific failure status
             }
         } catch {
            // Handle unexpected errors
             await MainActor.run {
                 self.errorMessage = "An unexpected error occurred: \(error.localizedDescription)"
                 self.statusMessage = "Process failed unexpectedly."
             }
        }

        // Ensure isLoading is set to false after completion, regardless of success/failure
        await MainActor.run {
            isLoading = false
        }
    }

    // Helper to update status message on the main thread
    @MainActor // Ensures UI updates happen on the main thread
    private func updateStatus(_ message: String) {
         // Only update status if we are still loading (avoid overwriting final success/error)
         if isLoading {
             statusMessage = message
         }
    }
}


#Preview {
    PlaylistCreationView()
}

//// --- App Entry Point ---
//// @main // Uncomment this line to make this the entry point
//struct SpotifyPlaylistApp: App {
//    var body: some Scene {
//        WindowGroup {
//            PlaylistCreationView()
//        }
//    }
//}
//
//// --- Preview Provider ---
//struct PlaylistCreationView_Previews: PreviewProvider {
//    static var previews: some View {
//        // Default preview
//        PlaylistCreationView()
//            .previewDisplayName("Initial State")
//
//        // Preview in loading state
//        let loadingView = PlaylistCreationView()
//        loadingView._isLoading = State(initialValue: true)
//        loadingView._statusMessage = State(initialValue: "Creating playlist...")
//        return loadingView
//             .previewDisplayName("Loading State")
//
//
//         // Preview in error state
//         let errorView = PlaylistCreationView()
//         errorView._errorMessage = State(initialValue: "API request failed (Status 401) (Hint: Token might be invalid or expired).")
//         errorView._statusMessage = State(initialValue: "Process failed during execution.")
//         return errorView
//             .previewDisplayName("Error State")
//
//
//         // Preview in success state
//         let successView = PlaylistCreationView()
//         successView._createdPlaylistName = State(initialValue: "My top tracks playlist")
//         successView._statusMessage = State(initialValue: "Tracks added successfully!")
//         return successView
//             .previewDisplayName("Success State")
//    }
//}
