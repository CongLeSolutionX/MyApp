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

    // Generic function to perform API calls
    private func fetchWebApi<T: Decodable>(endpoint: String, method: String, body: (some Encodable)? = nil, token: String) async throws -> T {
        guard let url = URL(string: apiBaseUrl + endpoint) else {
            throw ApiError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type") // Important for POST

        // Encode body if provided
        if let body = body {
            do {
                request.httpBody = try JSONEncoder().encode(body)
            } catch {
                throw ApiError.encodingError(error)
            }
        }

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
            print("HTTP Error: \(httpResponse.statusCode)")
            print("Response Data: \(errorDetails ?? "Undecodable error data")")
            throw ApiError.httpError(statusCode: httpResponse.statusCode, details: errorDetails)
        }

        // Handle cases where response might be empty (like successful POST sometimes)
        if data.isEmpty && T.self == EmptyResponse.self {
           if let empty = EmptyResponse() as? T { return empty }
           else { throw ApiError.invalidResponse } // Should not happen
        }


        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            print("Decoding failed: \(error)")
             if let decodingError = error as? DecodingError {
                 print("Decoding Error Details: \(decodingError)")
             }
            throw ApiError.decodingError(error)
        }
    }

    // Helper struct for empty responses
    struct EmptyResponse: Decodable {}


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
        // Note: Spotify API Reference says this returns a snapshot_id
        let snapshotResponse: SpotifySnapshotResponse = try await fetchWebApi(endpoint: endpoint, method: "POST", body: payload, token: token)
        return snapshotResponse
    }
}

// --- SwiftUI View ---
struct PlaylistCreationView: View {
    @State private var statusMessage: String = "Ready to create playlist."
    @State private var isLoading: Bool = false
    @State private var createdPlaylistName: String? = nil
    @State private var errorMessage: String? = nil
    @State private var showSuccessAlert: Bool = false

    private let playlistService = SpotifyPlaylistService()

    var body: some View {
        VStack(spacing: 20) {
            Text("Spotify Playlist Creator")
                .font(.title)

            if isLoading {
                ProgressView()
                Text(statusMessage)
                    .foregroundColor(.secondary)
            } else {
                Text(statusMessage)
                    .foregroundColor(errorMessage != nil ? .red : .secondary)
                    .multilineTextAlignment(.center)

                if let playlistName = createdPlaylistName {
                    Text("Successfully created playlist: \(playlistName)")
                        .foregroundColor(.green)
                }

                 if let errorMsg = errorMessage {
                     Text("Error: \(errorMsg)")
                         .foregroundColor(.red)
                         .multilineTextAlignment(.center)
                 }

                Button("Create 'My top tracks playlist'") {
                    // Start the creation process
                    Task {
                        await createAndAddTracks()
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(isLoading) // Disable button while loading
            }

            Spacer() // Pushes content to the top
        }
        .padding()
        .alert("Success", isPresented: $showSuccessAlert) {
             Button("OK", role: .cancel) { }
         } message: {
             Text("Playlist '\(createdPlaylistName ?? "Unknown")' created and tracks added successfully!")
         }
    }

    // Main function orchestrating the API calls
    private func createAndAddTracks() async {
        isLoading = true
        errorMessage = nil
        createdPlaylistName = nil
        let playlistName = "My top tracks playlist"
        let playlistDescription = "Playlist created by the tutorial on developer.spotify.com"

        // Basic check for token placeholder
        guard spotifyApiToken != "YOUR_SPOTIFY_API_TOKEN", !spotifyApiToken.isEmpty else {
            errorMessage = "Spotify API Token is not set. Please replace 'YOUR_SPOTIFY_API_TOKEN' in the code."
            isLoading = false
            statusMessage = "Error: Token not configured."
            return
        }

        do {
            // Step 1: Get User ID
            await updateStatus("Fetching user ID...")
            let userId = try await playlistService.getCurrentUserId(token: spotifyApiToken)
            await updateStatus("User ID found: \(userId)")

            // Step 2: Create Playlist
            await updateStatus("Creating playlist: \(playlistName)...")
            let newPlaylist = try await playlistService.createPlaylist(
                userId: userId,
                name: playlistName,
                description: playlistDescription,
                isPublic: false, // As per the example (public: false)
                token: spotifyApiToken
            )
            await updateStatus("Playlist created with ID: \(newPlaylist.id)")
            await MainActor.run { self.createdPlaylistName = newPlaylist.name }


            // Step 3: Add Tracks
            await updateStatus("Adding \(sampleTrackUris.count) tracks to playlist...")
            let snapshotResponse = try await playlistService.addTracksToPlaylist(
                playlistId: newPlaylist.id,
                trackUris: sampleTrackUris,
                token: spotifyApiToken
            )
            await updateStatus("Tracks added successfully! Snapshot ID: \(snapshotResponse.snapshot_id)")
            await MainActor.run { showSuccessAlert = true }


        } catch let apiError as ApiError {
            // Handle specific API errors
             await MainActor.run {
                 var detailedError = ""
                 switch apiError {
                 case .invalidURL:
                     detailedError = "Internal error: Invalid API URL."
                 case .requestFailed(let error):
                     detailedError = "Network request failed: \(error.localizedDescription)"
                 case .invalidResponse:
                     detailedError = "Received an invalid response from the server."
                 case .decodingError(let error):
                     detailedError = "Failed to decode server response. \(error.localizedDescription)"
                 case .encodingError(let error):
                    detailedError = "Failed to encode request body. \(error.localizedDescription)"
                 case .httpError(let statusCode, let details):
                      detailedError = "API request failed (Status: \(statusCode)). Check token or request details. \(details ?? "")"
                 }
                 self.errorMessage = detailedError
                 self.statusMessage = "Process failed."
             }
         } catch {
            // Handle unexpected errors
             await MainActor.run {
                 self.errorMessage = "An unexpected error occurred: \(error.localizedDescription)"
                 self.statusMessage = "Process failed."
             }
        }

        // Ensure isLoading is set to false after completion
        await MainActor.run {
            isLoading = false
        }
    }

    // Helper to update status message on the main thread
    @MainActor // Ensures UI updates happen on the main thread
    private func updateStatus(_ message: String) {
        statusMessage = message
    }
}

// --- App Entry Point ---
// @main
// struct SpotifyPlaylistApp: App {
//     var body: some Scene {
//         WindowGroup {
//             PlaylistCreationView()
//         }
//     }
// }

// --- Preview Provider ---
struct PlaylistCreationView_Previews: PreviewProvider {
    static var previews: some View {
        PlaylistCreationView()
    }
}
