//
//  PlaylistInteractionView.swift
//  MyApp
//
//  Created by Cong Le on 4/8/25.
//

import SwiftUI
import Combine // For ObservableObject
import CryptoKit // For PKCE SHA256
import AuthenticationServices // For ASWebAuthenticationSession

// MARK: - Configuration (MUST REPLACE & EXPAND)
struct SpotifyConstants {
    // --- Existing ---
    static let clientID = "YOUR_CLIENT_ID" // <-- REPLACE THIS
    static let redirectURI = "myapp://callback" // <-- REPLACE THIS
    static let scopeString = scopes.joined(separator: " ")

    static let authorizationEndpoint = URL(string: "https://accounts.spotify.com/authorize")!
    static let tokenEndpoint = URL(string: "https://accounts.spotify.com/api/token")!
    static let userProfileEndpoint = URL(string: "https://api.spotify.com/v1/me")!
    static let userPlaylistsEndpoint = URL(string: "https://api.spotify.com/v1/me/playlists")!
    static let tokenUserDefaultsKey = "spotifyTokens"

    // --- Required Scopes (Add/Verify) ---
    static let scopes = [
        "user-read-private",
        "user-read-email",
        "playlist-read-private",        // Read user's private playlists
        "playlist-read-collaborative", // Read collaborative playlists
        "playlist-modify-public",       // Modify user's public playlists
        "playlist-modify-private",      // Modify user's private playlists
        "user-modify-playback-state",    // Needed for playback control (future)
        "user-library-read",            // Needed for Liked Songs (future)
        "user-library-modify"           // Needed to modify Liked Songs (future)
    ]

    // --- New Endpoints for Playlist Interaction ---
    // GET /v1/playlists/{playlist_id}/tracks
    static func playlistTracksEndpoint(playlistID: String) -> URL? {
        return URL(string: "https://api.spotify.com/v1/playlists/\(playlistID)/tracks")
    }
    // POST /v1/users/{user_id}/playlists
    static func createPlaylistEndpoint(userID: String) -> URL? {
        return URL(string: "https://api.spotify.com/v1/users/\(userID)/playlists")
    }
    // POST /v1/playlists/{playlist_id}/tracks
    static func addItemsToPlaylistEndpoint(playlistID: String) -> URL? {
        return URL(string: "https://api.spotify.com/v1/playlists/\(playlistID)/tracks") // Same endpoint as GET/DELETE but POST method
    }
    // DELETE /v1/playlists/{playlist_id}/tracks
    static func removeItemsFromPlaylistEndpoint(playlistID: String) -> URL? {
        return URL(string: "https://api.spotify.com/v1/playlists/\(playlistID)/tracks") // Same endpoint as GET/POST but DELETE method
    }
    // PUT /v1/playlists/{playlist_id}/tracks
    static func reorderPlaylistItemsEndpoint(playlistID: String) -> URL? {
         return URL(string: "https://api.spotify.com/v1/playlists/\(playlistID)/tracks") // Same endpoint, PUT method
    }
    // GET /v1/playlists/{playlist_id}/followers/contains?ids={user_ids}
    static func checkIfUsersFollowPlaylistEndpoint(playlistID: String, userIDs: [String]) -> URL? {
        let idsString = userIDs.joined(separator: ",")
        return URL(string: "https://api.spotify.com/v1/playlists/\(playlistID)/followers/contains?ids=\(idsString)")
    }
    // PUT /v1/playlists/{playlist_id}/followers
    static func followPlaylistEndpoint(playlistID: String) -> URL? {
        return URL(string: "https://api.spotify.com/v1/playlists/\(playlistID)/followers")
    }
    // DELETE /v1/playlists/{playlist_id}/followers
    static func unfollowPlaylistEndpoint(playlistID: String) -> URL? {
        return URL(string: "https://api.spotify.com/v1/playlists/\(playlistID)/followers")
    }

}

// MARK: - Data Models

// --- Existing Models ---
// TokenResponse, StoredTokens, SpotifyUserProfile, SpotifyImage,
// SpotifyPagingObject, SpotifyPlaylistOwner, PlaylistTracksInfo, SpotifyPlaylist
// (Include these from the previous response for completeness, omitted here for brevity)

// --- New Models for Playlist Interaction ---

// Represents a track item within a playlist response item
struct PlaylistTrack: Codable {
    let addedAt: String? // ISO 8601 format timestamp
    let addedBy: SpotifyPlaylistOwner? // User who added the track (if collaborative)
    let isLocal: Bool // Whether the track is hosted locally by the user
    let track: TrackItem? // The actual track details (can be null if unavailable)

    enum CodingKeys: String, CodingKey {
        case addedAt = "added_at"
        case addedBy = "added_by"
        case isLocal = "is_local"
        case track
    }
}

// Represents the detailed Track object
struct TrackItem: Codable, Identifiable {
    let album: SimpleAlbum?
    let artists: [SimpleArtist]
    let availableMarkets: [String]?
    let discNumber: Int
    let durationMs: Int
    let explicit: Bool
    let externalIds: [String: String]?
    let externalUrls: [String: String]
    let href: String
    let id: String? // Can be null sometimes
    let isPlayable: Bool?
    let name: String
    let popularity: Int?
    let previewUrl: String?
    let trackNumber: Int
    let type: String
    let uri: String // Spotify Track URI (e.g., "spotify:track:...")
    let isLocal: Bool

    // Computed property for display
    var artistNames: String {
        artists.map { $0.name }.joined(separator: ", ")
    }
    var durationFormatted: String {
            let totalSeconds = durationMs / 1000
            let minutes = totalSeconds / 60
            let seconds = totalSeconds % 60
            return String(format: "%d:%02d", minutes, seconds)
        }


    enum CodingKeys: String, CodingKey {
        case album, artists
        case availableMarkets = "available_markets"
        case discNumber = "disc_number"
        case durationMs = "duration_ms"
        case explicit
        case externalIds = "external_ids"
        case externalUrls = "external_urls"
        case href, id
        case isPlayable = "is_playable"
        case name, popularity
        case previewUrl = "preview_url"
        case trackNumber = "track_number"
        case type, uri
        case isLocal = "is_local"
    }

    // Provide a default ID even if Spotify's ID is null
    var identifier: String { id ?? uri }
}

// Simplified Artist object used within TrackItem
struct SimpleArtist: Codable, Identifiable {
    let externalUrls: [String: String]?
    let href: String?
    let id: String
    let name: String
    let type: String
    let uri: String?

    enum CodingKeys: String, CodingKey {
        case externalUrls = "external_urls"
        case href, id, name, type, uri
    }
}

// Simplified Album object used within TrackItem
struct SimpleAlbum: Codable, Identifiable {
    let albumType: String?
    let totalTracks: Int?
    let availableMarkets: [String]?
    let externalUrls: [String: String]
    let href: String
    let id: String
    let images: [SpotifyImage]?
    let name: String
    let releaseDate: String?
    let releaseDatePrecision: String?
    let type: String
    let uri: String

    enum CodingKeys: String, CodingKey {
        case albumType = "album_type"
        case totalTracks = "total_tracks"
        case availableMarkets = "available_markets"
        case externalUrls = "external_urls"
        case href, id, images, name
        case releaseDate = "release_date"
        case releaseDatePrecision = "release_date_precision"
        case type, uri
    }
}

// Response type for adding/removing/reordering tracks
struct PlaylistModificationResponse: Codable {
    let snapshotId: String

    enum CodingKeys: String, CodingKey {
        case snapshotId = "snapshot_id"
    }
}

// Request body structure for removing items
struct RemovePlaylistItemsBody: Codable {
    let tracks: [TrackToRemove]
    let snapshotId: String? // Optional: Provide if you want to ensure specific state

    enum CodingKeys: String, CodingKey {
        case tracks
        case snapshotId = "snapshot_id"
    }

    struct TrackToRemove: Codable {
        let uri: String
        // Optionally include 'positions' if removing specific occurrences
        // let positions: [Int]?
    }
}


// Type alias for the paging object containing playlist tracks
typealias SpotifyPlaylistTrackList = SpotifyPagingObject<PlaylistTrack>

// Generic Paging Object used by many Spotify endpoints
struct SpotifyPagingObject<T: Codable>: Codable {
    let href: String
    let items: [T]
    let limit: Int
    let next: String? // URL for the next page of items
    let offset: Int
    let previous: String? // URL for the previous page of items
    let total: Int
}

// Simple model for storing tokens persistently (Use Keychain in production!)
struct StoredTokens: Codable {
    let accessToken: String
    let refreshToken: String?
    let expiryDate: Date?
}

struct SpotifyUserProfile: Codable, Identifiable {
    let id: String
    let displayName: String
    let email: String
    let images: [SpotifyImage]?

    enum CodingKeys: String, CodingKey {
        case id
        case displayName = "display_name"
        case email
        case images
    }
}

// Simplified Playlist Owner Model
struct SpotifyPlaylistOwner: Codable, Identifiable {
    let id: String
    let displayName: String? // Might be nil sometimes
    let externalUrls: [String: String]?

    enum CodingKeys: String, CodingKey {
        case id
        case displayName = "display_name"
        case externalUrls = "external_urls"
    }
}

// Simplified Playlist Owner Model
struct SpotifyPlaylistOwner: Codable, Identifiable {
    let id: String
    let displayName: String? // Might be nil sometimes
    let externalUrls: [String: String]?

    enum CodingKeys: String, CodingKey {
        case id
        case displayName = "display_name"
        case externalUrls = "external_urls"
    }
}

// Playlist response after creation (only need ID)
struct SpotifyPlaylist: Decodable {
    let id: String
    let name: String // Include name for displaying result
    // You can add other fields like 'external_urls' if needed
}


// MARK: - Authentication Manager (ObservableObject) - EXTENDED
class SpotifyAuthManager: ObservableObject {

    // --- Existing Published Properties ---
    @Published var isLoggedIn: Bool = false
    @Published var currentTokens: StoredTokens? = nil
    @Published var userProfile: SpotifyUserProfile? = nil
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var userPlaylists: [SpotifyPlaylist] = []
    @Published var isLoadingPlaylists: Bool = false
    @Published var playlistErrorMessage: String? = nil

    // --- New Published Properties for Playlist Detail ---
    @Published var currentPlaylistTracks: [PlaylistTrack] = []
    @Published var tracksNextPageUrl: String? = nil
    @Published var isLoadingTracks: Bool = false
    @Published var tracksErrorMessage: String? = nil
    @Published var isFollowingCurrentPlaylist: Bool? = nil // Use optional Bool for undetermined state
    @Published var playlistModificationMessage: String? = nil // For success/error feedback
    @Published var isModifyingPlaylist: Bool = false      // Loading state for modifications

    private var currentPKCEVerifier: String?
    private var currentWebAuthSession: ASWebAuthenticationSession?
    private var playlistNextPageUrl: String? // For user's playlist list pagination

    // --- Initialization (remains the same) ---
    init() {
        loadTokens()
        if let tokens = currentTokens, let expiry = tokens.expiryDate, expiry > Date() {
            self.isLoggedIn = true
            fetchUserProfile()
            fetchUserPlaylists()
        } else if currentTokens != nil {
            refreshToken { [weak self] success in
                if success {
                    self?.fetchUserProfile()
                    self?.fetchUserPlaylists()
                } else {
                    self?.logout()
                }
            }
        }
    }

    // --- PKCE, Auth Flow, Token Exchange, Refresh (remain the same - omitted for brevity) ---

    // --- Fetch User Profile (remains the same) ---
    func fetchUserProfile() { /* ... implementation ... */ }

    // --- Fetch User Playlists (remains the same) ---
    func fetchUserPlaylists(loadNextPage: Bool = false) { /* ... implementation ... */ }


    // --- START: Playlist Interaction API Calls ---

    // MARK: Fetch Tracks for a Specific Playlist
    func fetchPlaylistTracks(playlistID: String, loadNextPage: Bool = false) {
        guard !isLoadingTracks else { return }
        guard isLoggedIn, currentTokens?.accessToken != nil else {
            handleTracksError("Cannot fetch tracks: Not logged in.")
            return
        }

        var urlToFetch: URL?

        if loadNextPage {
            guard let nextUrlString = tracksNextPageUrl else {
                print("Playlist Tracks: No next page URL available.")
                return // Nothing more to load
            }
            urlToFetch = URL(string: nextUrlString)
        } else {
            // Reset tracks if fetching the first page for this playlistID
            currentPlaylistTracks = []
            tracksNextPageUrl = nil
            tracksErrorMessage = nil
            urlToFetch = SpotifyConstants.playlistTracksEndpoint(playlistID: playlistID)
        }

        guard let finalUrl = urlToFetch else {
            handleTracksError("Invalid URL for fetching playlist tracks.")
            return
        }

        isLoadingTracks = true
        tracksErrorMessage = nil

        makeAPIRequest(
            url: finalUrl,
            responseType: SpotifyPlaylistTrackList.self,
            currentAttempt: 1,
            maxAttempts: 2
        ) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isLoadingTracks = false
                switch result {
                case .success(let trackResponse):
                    if loadNextPage {
                        self.currentPlaylistTracks.append(contentsOf: trackResponse.items)
                        print("Loaded next page of tracks for \(playlistID). Total: \(self.currentPlaylistTracks.count)")
                    } else {
                        self.currentPlaylistTracks = trackResponse.items
                        print("Fetched initial tracks for \(playlistID). Count: \(self.currentPlaylistTracks.count)")
                    }
                    self.tracksNextPageUrl = trackResponse.next
                    self.tracksErrorMessage = nil

                case .failure(let error):
                    print("Fetch Tracks Error: \(error.localizedDescription)")
                    self.tracksErrorMessage = "Could not fetch tracks: \(error.localizedDescription)"
                }
            }
        }
    }

    // MARK: Create New Playlist
    func createPlaylist(name: String, isPublic: Bool = true, isCollaborative: Bool = false, description: String? = nil, completion: ((Result<SpotifyPlaylist, Error>) -> Void)? = nil) {
        guard let userID = userProfile?.id else {
            completion?(.failure(APIError.invalidRequest(message: "User ID not available.")))
            return
        }
        guard let url = SpotifyConstants.createPlaylistEndpoint(userID: userID) else {
            completion?(.failure(APIError.invalidRequest(message: "Could not create playlist endpoint URL."))); return
        }

        let body: [String: Any?] = [
            "name": name,
            "public": isPublic,
            "collaborative": isCollaborative,
            "description": description
        ]

        guard let jsonData = try? JSONSerialization.data(withJSONObject: body.compactMapValues { $0 }, options: []) else {
            completion?(.failure(APIError.invalidRequest(message: "Could not encode playlist creation body."))); return
        }

        setIsModifyingPlaylist(true, message: "Creating playlist...")

        makeAPIRequest(
            url: url,
            method: "POST",
            body: jsonData,
            responseType: SpotifyPlaylist.self, // API returns the created playlist object
            currentAttempt: 1,
            maxAttempts: 2
        ) { [weak self] result in
            self?.handleModificationResponse(result: result, successMessage: "Playlist '\(name)' created!", completion: completion)
             // Optionally refresh user's playlist list after creation
             if case .success = result {
                 self?.fetchUserPlaylists()
             }
        }
    }

    // MARK: Add Items to Playlist
    func addItemsToPlaylist(playlistID: String, trackURIs: [String], completion: ((Result<PlaylistModificationResponse, Error>) -> Void)? = nil) {
        guard !trackURIs.isEmpty else {
            completion?(.failure(APIError.invalidRequest(message: "No track URIs provided."))); return
        }
        guard let url = SpotifyConstants.addItemsToPlaylistEndpoint(playlistID: playlistID) else {
            completion?(.failure(APIError.invalidRequest(message: "Could not create add items endpoint URL."))); return
        }

        let body = ["uris": trackURIs]

        guard let jsonData = try? JSONEncoder().encode(body) else {
            completion?(.failure(APIError.invalidRequest(message: "Could not encode track URIs."))); return
        }

        let itemsDesc = trackURIs.count == 1 ? "track" : "\(trackURIs.count) tracks"
        setIsModifyingPlaylist(true, message: "Adding \(itemsDesc)...")

        makeAPIRequest(
            url: url,
            method: "POST",
            body: jsonData,
            responseType: PlaylistModificationResponse.self, // Returns snapshot_id
            currentAttempt: 1,
            maxAttempts: 2
        ) { [weak self] result in
            self?.handleModificationResponse(result: result, successMessage: "\(itemsDesc) added.", completion: completion)
             // Optionally refresh the specific playlist's tracks view after adding
             if case .success = result {
                  self?.fetchPlaylistTracks(playlistID: playlistID) // Refresh current view if applicable
             }
        }
    }

    // MARK: Remove Items from Playlist
    func removeItemsFromPlaylist(playlistID: String, tracksToRemove: [RemovePlaylistItemsBody.TrackToRemove], snapshotID: String? = nil, completion: ((Result<PlaylistModificationResponse, Error>) -> Void)? = nil) {
        guard !tracksToRemove.isEmpty else {
             completion?(.failure(APIError.invalidRequest(message: "No tracks specified for removal."))); return
        }
        guard let url = SpotifyConstants.removeItemsFromPlaylistEndpoint(playlistID: playlistID) else {
            completion?(.failure(APIError.invalidRequest(message: "Could not create remove items endpoint URL."))); return
        }

        let requestBody = RemovePlaylistItemsBody(tracks: tracksToRemove, snapshotId: snapshotID)

        guard let jsonData = try? JSONEncoder().encode(requestBody) else {
            completion?(.failure(APIError.invalidRequest(message: "Could not encode remove items body."))); return
        }

        let itemsDesc = tracksToRemove.count == 1 ? "track" : "\(tracksToRemove.count) tracks"
        setIsModifyingPlaylist(true, message: "Removing \(itemsDesc)...")

        makeAPIRequest(
            url: url,
            method: "DELETE", // Use DELETE method
            body: jsonData,    // DELETE can have a body in HTTP/1.1+
            responseType: PlaylistModificationResponse.self, // Returns snapshot_id
            currentAttempt: 1,
            maxAttempts: 2
        ) { [weak self] result in
            self?.handleModificationResponse(result: result, successMessage: "\(itemsDesc) removed.", completion: completion)
             // Optionally refresh the specific playlist's tracks view after removing
             if case .success = result {
                  self?.fetchPlaylistTracks(playlistID: playlistID) // Refresh current view if applicable
             }
        }
    }

    // MARK: Reorder Playlist Items
       func reorderPlaylistItems(playlistID: String, rangeStart: Int, insertBefore: Int, rangeLength: Int = 1, snapshotID: String? = nil, completion: ((Result<PlaylistModificationResponse, Error>) -> Void)? = nil) {
           guard let url = SpotifyConstants.reorderPlaylistItemsEndpoint(playlistID: playlistID) else {
               completion?(.failure(APIError.invalidRequest(message: "Could not create reorder items endpoint URL."))); return
           }

           var body: [String: Any?] = [
               "range_start": rangeStart,
               "insert_before": insertBefore,
               "range_length": rangeLength,
               "snapshot_id": snapshotID
           ]

           guard let jsonData = try? JSONSerialization.data(withJSONObject: body.compactMapValues { $0 }, options: []) else {
               completion?(.failure(APIError.invalidRequest(message: "Could not encode reorder items body."))); return
           }

           setIsModifyingPlaylist(true, message: "Reordering tracks...")

           makeAPIRequest(
               url: url,
               method: "PUT", // Use PUT method
               body: jsonData,
               responseType: PlaylistModificationResponse.self, // Returns snapshot_id
               currentAttempt: 1,
               maxAttempts: 2
           ) { [weak self] result in
               self?.handleModificationResponse(result: result, successMessage: "Tracks reordered.", completion: completion)
                 // Optionally refresh the specific playlist's tracks view after reordering
                 if case .success = result {
                     self?.fetchPlaylistTracks(playlistID: playlistID) // Refresh current view if applicable
                 }
           }
       }

    // MARK: Check if Current User Follows Playlist
    func checkIfCurrentUserFollows(playlistID: String) {
        guard let currentUserID = userProfile?.id else {
            print("Cannot check follow status: User ID not available.")
            self.isFollowingCurrentPlaylist = nil // Indicate unknown state
            return
        }
        guard let url = SpotifyConstants.checkIfUsersFollowPlaylistEndpoint(playlistID: playlistID, userIDs: [currentUserID]) else {
            handleFollowError("Could not create check follow status URL."); return
        }

        // No loading indicator needed usually for this check, happens quickly
        makeAPIRequest(
            url: url,
            responseType: [Bool].self, // API returns an array of booleans
            currentAttempt: 1,
            maxAttempts: 2
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let follows):
                    // API returns an array, one bool per user ID requested. We only requested one.
                    self?.isFollowingCurrentPlaylist = follows.first
                    print("Checked follow status for \(playlistID): \(String(describing: self?.isFollowingCurrentPlaylist))")
                case .failure(let error):
                    self?.isFollowingCurrentPlaylist = nil // Reset on error
                    self?.handleFollowError("Could not check follow status: \(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: Follow Playlist
    func followPlaylist(playlistID: String, makePublic: Bool = true, completion: ((Result<EmptyResponse, Error>) -> Void)? = nil) {
        guard let url = SpotifyConstants.followPlaylistEndpoint(playlistID: playlistID) else {
             completion?(.failure(APIError.invalidRequest(message: "Could not create follow endpoint URL."))); return
        }

        let body = ["public": makePublic] // Body is optional for PUT follow, but good practice
        guard let jsonData = try? JSONEncoder().encode(body) else {
             completion?(.failure(APIError.invalidRequest(message: "Could not encode follow body."))); return
        }

        setIsModifyingPlaylist(true, message: "Following playlist...")

        makeAPIRequest(
            url: url,
            method: "PUT",
            body: jsonData,
            responseType: EmptyResponse.self, // PUT follow returns 200 OK with empty body
            currentAttempt: 1,
            maxAttempts: 2
        ) { [weak self] result in
            // Must use a slightly different handler as response type is EmptyResponse
            self?.handleFollowModificationResponse(result: result, successMessage: "Playlist followed.", completion: completion)
            if case .success = result {
                 DispatchQueue.main.async { self?.isFollowingCurrentPlaylist = true }
            }
        }
    }

    // MARK: Unfollow Playlist
    func unfollowPlaylist(playlistID: String, completion: ((Result<EmptyResponse, Error>) -> Void)? = nil) {
        guard let url = SpotifyConstants.unfollowPlaylistEndpoint(playlistID: playlistID) else {
             completion?(.failure(APIError.invalidRequest(message: "Could not create unfollow endpoint URL."))); return
        }

        setIsModifyingPlaylist(true, message: "Unfollowing playlist...")

        makeAPIRequest(
            url: url,
            method: "DELETE", // Use DELETE method
            responseType: EmptyResponse.self, // DELETE unfollow returns 200 OK with empty body
            currentAttempt: 1,
            maxAttempts: 2
        ) { [weak self] result in
            // Must use a slightly different handler as response type is EmptyResponse
            self?.handleFollowModificationResponse(result: result, successMessage: "Playlist unfollowed.", completion: completion)
            if case .success = result {
                 DispatchQueue.main.async { self?.isFollowingCurrentPlaylist = false }
            }
        }
    }

    // --- END: Playlist Interaction API Calls ---


    // --- Generic API Request Function (Updated for Methods/Body) ---
    private func makeAPIRequest<T: Decodable>(
        url: URL,
        method: String = "GET",
        body: Data? = nil,
        responseType: T.Type,
        currentAttempt: Int,
        maxAttempts: Int,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
         guard currentAttempt <= maxAttempts else {
             completion(.failure(APIError.maxRetriesReached))
             return
         }

         guard let accessToken = currentTokens?.accessToken else {
             completion(.failure(APIError.notLoggedIn))
             return
         }

         // Proactive Token Expiry Check (remain the same)
         if let expiryDate = currentTokens?.expiryDate, expiryDate <= Date() {
              print("Token likely expired, attempting refresh before API call [\(method)] to \(url.lastPathComponent)...")
              refreshToken { [weak self] success in
                   guard let self = self else { completion(.failure(APIError.unknown)); return }
                   if success {
                       print("Token refreshed successfully. Retrying API call [\(method)] \(url.lastPathComponent)...")
                       self.makeAPIRequest(url: url, method: method, body: body, responseType: responseType, currentAttempt: currentAttempt + 1, maxAttempts: maxAttempts, completion: completion)
                   } else {
                       print("Token refresh failed. Aborting API call [\(method)] \(url.lastPathComponent).")
                       completion(.failure(APIError.tokenRefreshFailed))
                   }
              }
              return
         }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        // Add body and content type header ONLY if body exists and method expects it
        if let body = body, ["POST", "PUT", "DELETE"].contains(method.uppercased()) {
            // Assume JSON, adjust if needed for other content types (like urlencoded for token endpoint)
            if url != SpotifyConstants.tokenEndpoint { // Don't override content-type for token requests
                 request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
            request.httpBody = body
        }

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { completion(.failure(APIError.unknown)); return }

            if let error = error { completion(.failure(APIError.networkError(error))); return }
            guard let httpResponse = response as? HTTPURLResponse else { completion(.failure(APIError.invalidResponse)); return }

            // Handle Auth Error (401/403) by Refreshing Token (remain the same)
            if (httpResponse.statusCode == 401 || httpResponse.statusCode == 403) && url != SpotifyConstants.tokenEndpoint {
                 print("Received \(httpResponse.statusCode) for [\(method)] \(url.lastPathComponent). Attempting refresh...")
                 refreshToken { [weak self] success in
                      guard let self = self else { completion(.failure(APIError.unknown)); return }
                      if success {
                          print("Token refreshed. Retrying API call [\(method)] \(url.lastPathComponent)...")
                          self.makeAPIRequest(url: url, method: method, body: body, responseType: responseType, currentAttempt: currentAttempt + 1, maxAttempts: maxAttempts, completion: completion)
                      } else {
                          print("Token refresh failed after \(httpResponse.statusCode). Aborting API call [\(method)] \(url.lastPathComponent).")
                          completion(.failure(APIError.authenticationFailed))
                          DispatchQueue.main.async { self.logout() }
                      }
                 }
                 return
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                 let errorDetails = self.extractErrorDetails(from: data, statusCode: httpResponse.statusCode)
                 completion(.failure(APIError.httpError(statusCode: httpResponse.statusCode, details: errorDetails)))
                 return
            }

             guard let data = data else {
                 // Allow no data for EmptyResponse scenarios (like 204 No Content or successful PUT/DELETE)
                 if httpResponse.statusCode == 204 || T.self == EmptyResponse.self {
                      if let empty = EmptyResponse() as? T {
                           completion(.success(empty))
                      } else {
                           completion(.failure(APIError.decodingError(nil))) // Should not happen
                      }
                 } else {
                     completion(.failure(APIError.noData)) // Fail if data expected but nil
                 }
                 return
             }

             // Handle successful response with empty body when EmptyResponse is expected
             if data.isEmpty && T.self == EmptyResponse.self {
                  if let empty = EmptyResponse() as? T {
                       completion(.success(empty))
                  } else {
                      completion(.failure(APIError.decodingError(nil))) // Should not happen
                  }
                  return
             }

            // Decode non-empty response
            do {
                let decodedObject = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decodedObject))
            } catch {
                print("API JSON Decoding Error for \(T.self) from [\(method)] \(url.lastPathComponent): \(error)")
                print("Raw response data: \(String(data: data, encoding: .utf8) ?? "Unable to decode data")")
                completion(.failure(APIError.decodingError(error)))
            }
        }.resume()
    }

    // --- Logout (includes clearing playlist detail state) ---
    func logout() {
        DispatchQueue.main.async {
            self.isLoggedIn = false
            self.currentTokens = nil
            self.userProfile = nil
            self.errorMessage = nil
            self.userPlaylists = []
            self.playlistErrorMessage = nil
            self.isLoading = false
            self.isLoadingPlaylists = false
            self.playlistNextPageUrl = nil
            // Clear playlist detail state
            self.currentPlaylistTracks = []
            self.tracksNextPageUrl = nil
            self.isLoadingTracks = false
            self.tracksErrorMessage = nil
            self.isFollowingCurrentPlaylist = nil
            self.playlistModificationMessage = nil
            self.isModifyingPlaylist = false
            // Clear storage and cancel sessions
            self.clearTokens()
            self.currentWebAuthSession?.cancel()
            self.currentWebAuthSession = nil
            self.currentPKCEVerifier = nil
            print("User logged out.")
        }
    }

    // --- Token Persistence (remain the same) ---
    private func saveTokens(tokens: StoredTokens) { /* ... */ }
    private func loadTokens() { /* ... */ }
    private func clearTokens() { /* ... */ }

    // --- Error Handling Helpers ---
    private func handleError(_ message: String, clearVerifier: Bool = false) { /* ... */ }
    private func handlePlaylistError(_ message: String) { /* ... */ }
    private func handleTracksError(_ message: String) {
        DispatchQueue.main.async { self.tracksErrorMessage = message }
        print("Tracks Error: \(message)")
    }
    private func handleFollowError(_ message: String) {
         // Maybe reuse general error message or add a specific one
         DispatchQueue.main.async { self.errorMessage = message }
         print("Follow Error: \(message)")
     }
    private func handleModificationResponse<T>(result: Result<T, Error>, successMessage: String, completion: ((Result<T, Error>) -> Void)?) {
         DispatchQueue.main.async {
             self.isModifyingPlaylist = false
             switch result {
             case .success(let value):
                 print("Playlist Modification Success: \(successMessage)")
                 self.playlistModificationMessage = successMessage // Show success briefly
                 completion?(.success(value))
                 // Clear the message after a delay
                 DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                     self.playlistModificationMessage = nil
                 }
             case .failure(let error):
                 print("Playlist Modification Error: \(error.localizedDescription)")
                 self.playlistModificationMessage = "Error: \(error.localizedDescription)" // Show error
                 completion?(.failure(error))
                 // Consider clearing message later or require user dismissal
             }
         }
     }
     // Specific handler for EmptyResponse results (Follow/Unfollow)
    private func handleFollowModificationResponse(result: Result<EmptyResponse, Error>, successMessage: String, completion: ((Result<EmptyResponse, Error>) -> Void)?) {
         DispatchQueue.main.async {
             self.isModifyingPlaylist = false
             switch result {
             case .success(let value):
                 print("Follow Modification Success: \(successMessage)")
                 self.playlistModificationMessage = successMessage
                 completion?(.success(value))
                 DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                     self.playlistModificationMessage = nil
                 }
             case .failure(let error):
                 print("Follow Modification Error: \(error.localizedDescription)")
                 self.playlistModificationMessage = "Error: \(error.localizedDescription)"
                 completion?(.failure(error))
             }
         }
     }

    private func extractErrorDetails(from data: Data?, statusCode: Int) -> String { /* ... implementation ... */ }

    // Helper to manage modification loading state
    private func setIsModifyingPlaylist(_ modifying: Bool, message: String? = nil) {
         DispatchQueue.main.async {
             self.isModifyingPlaylist = modifying
             self.playlistModificationMessage = modifying ? message : nil // Show message only while loading
         }
     }
}

// MARK: - API Error Enum (remain the same)
enum APIError: Error, LocalizedError { /* ... implementation ... */ }

// MARK: - Models for Errors and Empty Responses (remain the same)
struct SpotifyErrorResponse: Codable { /* ... */ }
struct SpotifyErrorDetail: Codable { /* ... */ }
struct EmptyResponse: Codable {}

// MARK: - ASWebAuthenticationPresentationContextProviding (remain the same)
extension SpotifyAuthManager: ASWebAuthenticationPresentationContextProviding { /* ... */ }

// MARK: - PKCE Helper Extension (remain the same)
extension Data { /* ... */ }


// MARK: - SwiftUI Views

// MARK: AuthenticationFlowView (Updated Navigation)
struct AuthenticationFlowView: View {
    @StateObject var authManager = SpotifyAuthManager()

    var body: some View {
        NavigationView {
            Group {
                if !authManager.isLoggedIn {
                    loggedOutView
                        .navigationTitle("Spotify Login")
                } else {
                    loggedInContentView // Modified to navigate
                        .navigationTitle("Your Spotify")
                }
            }
            // Overlays and Alerts remain the same...
        }
    }

    private var loggedOutView: some View { /* ... implementation ... */ }

    // MARK: Logged In Content View (Updated List)
    private var loggedInContentView: some View {
        List {
            Section(header: Text("Profile")) { profileSection }

            Section(header: Text("Actions")) { createPlaylistSection } // Added Create Playlist

            Section(header: Text("My Playlists")) { playlistSection } // Navigates to Detail

            Section(header: Text("Account")) { actionSection }
        }
        .listStyle(InsetGroupedListStyle())
        .refreshable {
            print("Refreshing data...")
            authManager.fetchUserProfile()
            authManager.fetchUserPlaylists(loadNextPage: false)
        }
        .onAppear {
            if authManager.userProfile == nil { authManager.fetchUserProfile() }
            if authManager.userPlaylists.isEmpty { authManager.fetchUserPlaylists() }
        }
        // Display modification messages overlay
        .overlay(alignment: .bottom) {
            if let message = authManager.playlistModificationMessage {
                Text(message)
                    .padding()
                    .background(authManager.isModifyingPlaylist ? Color.orange.opacity(0.8) : (message.starts(with: "Error:") ? Color.red.opacity(0.8) : Color.green.opacity(0.8) ) )
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .padding(.bottom)
                    .onAppear { // Auto-dismiss non-loading, non-error messages
                        if !authManager.isModifyingPlaylist && !message.starts(with: "Error:") {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                                // Check if the message is still the same one before dismissing
                                if authManager.playlistModificationMessage == message {
                                     authManager.playlistModificationMessage = nil
                                }
                            }
                        }
                    }
            }
        }
           .overlay { // Loading indicator for modifications
                if authManager.isModifyingPlaylist {
                     VStack {
                          ProgressView(authManager.playlistModificationMessage ?? "Working...")
                               .padding()
                               .background(Color(.systemBackground).opacity(0.8))
                               .cornerRadius(10)
                     }
                }
           }
    }

    // --- Extracted Sections (Profile, Actions Remain Similar) ---
    @ViewBuilder private var profileSection: some View { /* ... implementation ... */ }
    @ViewBuilder private var actionSection: some View { /* ... implementation ... */ }

    // --- New Section for Creating Playlist ---
    @State private var newPlaylistName: String = ""
    @ViewBuilder private var createPlaylistSection: some View {
        HStack {
            TextField("New Playlist Name", text: $newPlaylistName)
                .textFieldStyle(.roundedBorder)
            Button("Create") {
                if !newPlaylistName.isEmpty {
                    authManager.createPlaylist(name: newPlaylistName) { result in
                        // Handle completion if needed, e.g., clear text field on success
                         if case .success = result {
                             newPlaylistName = ""
                         }
                    }
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(newPlaylistName.isEmpty || authManager.isModifyingPlaylist)
        }
    }


    // --- Updated Playlist List Section for Navigation ---
    @ViewBuilder
    private var playlistSection: some View {
        if authManager.isLoadingPlaylists && authManager.userPlaylists.isEmpty {
            // Loading indicator...
        } else if let errorMsg = authManager.playlistErrorMessage {
            // Error message...
        } else if authManager.userPlaylists.isEmpty && !authManager.isLoadingPlaylists {
            // Empty state...
        } else {
            ForEach(authManager.userPlaylists) { playlist in
                 // Use NavigationLink to push to PlaylistDetailView
                 NavigationLink(destination: PlaylistDetailView(authManager: authManager, playlist: playlist)) {
                      // Existing HStack for playlist row content
                     HStack {
                         AsyncImage(url: URL(string: playlist.images?.first?.url ?? "")) { /* ... */ } placeholder: { /* ... */ }
                         VStack(alignment: .leading) { /* ... Name, Owner, Tracks ... */ }
                         Spacer()
                         if playlist.collaborative { /* ... */ }
                     }
                 }

                // Pagination trigger (remains the same)
                if playlist.id == authManager.userPlaylists.last?.id && authManager.playlistNextPageUrl != nil {
                    ProgressView().padding().frame(maxWidth: .infinity).onAppear {
                        authManager.fetchUserPlaylists(loadNextPage: true)
                    }
                }
            }
        }
        // Loading indicator for next page (remains the same)
        if authManager.isLoadingPlaylists && !authManager.userPlaylists.isEmpty { /* ... */ }
    }
}


// MARK: - PlaylistDetailView (NEW)
struct PlaylistDetailView: View {
    @ObservedObject var authManager: SpotifyAuthManager // Passed from parent
    let playlist: SpotifyPlaylist // Playlist to display details for

    @State private var showAddTrackAlert = false // State for simple add demo
    @State private var trackURIToAdd: String = "spotify:track:4iV5W9uYEdYUVa79Axb7Rh" // Example track URI (replace with search later)


    var body: some View {
        List {
            // Section 1: Playlist Header
            Section {
                playlistHeaderView
            }

            // Section 2: Follow/Unfollow Action
            Section {
                followButton
            }

            // Section 3: Add Track (Demo)
            Section {
                addTrackButton
            }

            // Section 4: Tracks List
            Section(header: Text("Tracks (\(authManager.currentPlaylistTracks.count))")) {
                tracksListView
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle(playlist.name)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // Fetch tracks and follow status when the view appears
            authManager.fetchPlaylistTracks(playlistID: playlist.id)
            authManager.checkIfCurrentUserFollows(playlistID: playlist.id)
        }
         // Display modification messages overlay (can be added similarly to AuthenticationFlowView if needed at this level)
         // .overlay(alignment: .bottom) { ... }
         // .overlay { if authManager.isModifyingPlaylist { ... } } // Loading indicator
        .alert("Add Track URI", isPresented: $showAddTrackAlert) {
             TextField("Spotify Track URI", text: $trackURIToAdd)
                 .textInputAutocapitalization(.never)
                 .autocorrectionDisabled()
             Button("Add") {
                 if !trackURIToAdd.isEmpty, trackURIToAdd.starts(with: "spotify:track:") {
                     authManager.addItemsToPlaylist(playlistID: playlist.id, trackURIs: [trackURIToAdd])
                 }
             }
             Button("Cancel", role: .cancel) { }
        } message: {
             Text("Enter the full Spotify Track URI (e.g., spotify:track:xxxxxx)")
        }
    }

    // --- Extracted Views for PlaylistDetailView ---

    @ViewBuilder
    private var playlistHeaderView: some View {
        HStack(alignment: .top, spacing: 15) {
            AsyncImage(url: URL(string: playlist.images?.first?.url ?? "")) { image in
                image.resizable().aspectRatio(contentMode: .fit)
            } placeholder: {
                Image(systemName: "music.note.list")
                    .resizable().aspectRatio(contentMode: .fit).padding().background(Color.gray.opacity(0.3))
            }
            .frame(width: 100, height: 100)
            .cornerRadius(8)

            VStack(alignment: .leading) {
                Text(playlist.name).font(.headline)
                if let desc = playlist.description, !desc.isEmpty {
                    Text(desc).font(.caption).foregroundColor(.gray).lineLimit(2)
                }
                Text("By \(playlist.owner.displayName ?? "Unknown")").font(.caption2)
                Text("\(playlist.tracks.total) tracks").font(.caption2)
                if playlist.collaborative {
                     Text("Collaborative").font(.caption2).foregroundColor(.blue)
                }
                 if let isPublic = playlist.publicPlaylist {
                      Text(isPublic ? "Public" : "Private").font(.caption2).foregroundColor(.orange)
                 }
            }
        }
        .padding(.vertical, 5)
    }

    @ViewBuilder
    private var followButton: some View {
        Group { // Use Group to handle optional isFollowing state
            if let isFollowing = authManager.isFollowingCurrentPlaylist {
                Button {
                    if isFollowing {
                        authManager.unfollowPlaylist(playlistID: playlist.id)
                    } else {
                        authManager.followPlaylist(playlistID: playlist.id)
                    }
                } label: {
                    Label(isFollowing ? "Unfollow" : "Follow", systemImage: isFollowing ? "heart.slash.fill" : "heart.fill")
                }
                .disabled(authManager.isModifyingPlaylist)
                .foregroundColor(isFollowing ? .red : .green)
            } else {
                // Show loading or placeholder while checking follow status
                HStack {
                     ProgressView()
                     Text("Checking follow status...")
                          .font(.caption)
                          .foregroundColor(.gray)
                }
            }
        }
    }

    @ViewBuilder
    private var addTrackButton: some View {
         Button {
              showAddTrackAlert = true
         } label: {
              Label("Add Track by URI (Demo)", systemImage: "plus.circle.fill")
         }
         .disabled(authManager.isModifyingPlaylist)
     }

    @ViewBuilder
    private var tracksListView: some View {
        if authManager.isLoadingTracks && authManager.currentPlaylistTracks.isEmpty {
            HStack { Spacer(); ProgressView(); Text("Loading Tracks..."); Spacer() }.padding()
        } else if let errorMsg = authManager.tracksErrorMessage {
            Text("Error: \(errorMsg)").foregroundColor(.red)
        } else if authManager.currentPlaylistTracks.isEmpty && !authManager.isLoadingTracks {
            Text("This playlist is empty.").foregroundColor(.gray)
        } else {
            ForEach(authManager.currentPlaylistTracks, id: \.track?.identifier) { playlistTrack in
                if let track = playlistTrack.track {
                     TrackRowView(track: track)
                       .swipeActions { // Add swipe-to-delete
                           Button(role: .destructive) {
                               print("Attempting to remove track: \(track.uri)")
                                authManager.removeItemsFromPlaylist(
                                    playlistID: playlist.id,
                                    tracksToRemove: [RemovePlaylistItemsBody.TrackToRemove(uri: track.uri)]
                                )
                           } label: {
                               Label("Remove", systemImage: "trash")
                           }
                        }
                        .contextMenu { // Example: Context menu to add (redundant with other button for now)
                              Button {
                                   authManager.addItemsToPlaylist(playlistID: playlist.id, trackURIs: [track.uri])
                              } label: {
                                   Label("Add Again (Demo)", systemImage: "plus")
                              }
                         }
                } else {
                    // Handle cases where track data might be missing (e.g., local or deleted tracks)
                    Text("Unavailable Track")
                        .foregroundColor(.gray)
                        .italic()
                }

                // Pagination Trigger
                if playlistTrack.track?.identifier == authManager.currentPlaylistTracks.last?.track?.identifier && authManager.tracksNextPageUrl != nil {
                     ProgressView().padding().frame(maxWidth: .infinity).onAppear {
                         authManager.fetchPlaylistTracks(playlistID: playlist.id, loadNextPage: true)
                     }
                }
            }
             // TODO: Implement reordering UI (e.g., using .onMove in ForEach with Edit Mode)
             //       This requires more complex state management. For now, could add a button:
             // Button("Demo Reorder (Move First Track to Pos 2)") {
             //     if authManager.currentPlaylistTracks.count >= 2 {
             //         authManager.reorderPlaylistItems(playlistID: playlist.id, rangeStart: 0, insertBefore: 2)
             //     }
             // }.disabled(authManager.isModifyingPlaylist)

        }
        // Loading indicator for next page tracks
        if authManager.isLoadingTracks && !authManager.currentPlaylistTracks.isEmpty {
            ProgressView().padding().frame(maxWidth: .infinity)
        }
    }
}


// MARK: - TrackRowView (NEW)
struct TrackRowView: View {
    let track: TrackItem

    var body: some View {
        HStack {
            AsyncImage(url: URL(string: track.album?.images?.first?.url ?? "")) { image in
                 image.resizable()
                      .aspectRatio(contentMode: .fit)
                      .frame(width: 45, height: 45)
                      .cornerRadius(4)
            } placeholder: {
                 Image(systemName: "music.note")
                      .resizable()
                      .aspectRatio(contentMode: .fit)
                      .frame(width: 45, height: 45)
                      .padding(10)
                      .background(Color.gray.opacity(0.2))
                      .cornerRadius(4)
            }

            VStack(alignment: .leading) {
                Text(track.name)
                    .lineLimit(1)
                Text(track.artistNames)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }

            Spacer()

            Text(track.durationFormatted)
                 .font(.caption)
                 .foregroundColor(.gray)


            if track.explicit {
                Image(systemName: "e.square.fill")
                     .foregroundColor(.gray)
            }
        }
    }
}


// MARK: - App Entry Point & Previews (remain similar)
// @main
// struct SpotifyPKCEApp: App { ... }

// #Preview("...") { ... } Add previews for PlaylistDetailView

