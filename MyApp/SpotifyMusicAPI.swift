//
//  SpotifyMusicAPI.swift
//  MyApp
//
//  Created by Cong Le on 3/25/25.
//

import SwiftUI
import Combine
import Foundation // For URLQueryItem

// MARK: - Data Models (Simplified for Brevity)

// Unified/Display Models (Optional, but good practice for decoupling UI)
struct DisplayTrack: Identifiable {
    let id: String
    let name: String
    let artistNames: String // Combined artist names
    let albumName: String
    let previewUrl: URL?
    let imageUrl: URL?
    let spotifyUrl: URL?
}

// API Response Models (Matching Spotify JSON)
struct SpotifyTokenResponse: Decodable {
    let access_token: String
    let token_type: String // Should be "Bearer"
    let expires_in: Int
    // scope might be present depending on flow
}

struct SpotifySearchResponse: Decodable {
    let tracks: SpotifyPagingObject<SpotifyTrack>?
    let artists: SpotifyPagingObject<SpotifyArtist>?
    let albums: SpotifyPagingObject<SpotifyAlbum>?
}

struct SpotifyRecommendationsResponse: Decodable {
    let tracks: [SpotifyTrack]
    let seeds: [SpotifyRecommendationSeed]
}

struct SpotifyPagingObject<T: Decodable>: Decodable {
    let items: [T]
    let total: Int
    let limit: Int
    let offset: Int
    let next: String?
    let previous: String?
}

struct SpotifyTrack: Decodable, Identifiable {
    let id: String
    let name: String
    let artists: [SpotifyArtistSimple]
    let album: SpotifyAlbumSimple
    let duration_ms: Int
    let preview_url: String? // Note: Can be null
    let external_urls: SpotifyExternalUrls
    let uri: String
}

struct SpotifyArtist: Decodable, Identifiable {
    let id: String
    let name: String
    let genres: [String]?
    let images: [SpotifyImage]?
    let external_urls: SpotifyExternalUrls
    let uri: String
}

struct SpotifyAlbum: Decodable, Identifiable {
    let id: String
    let name: String
    let artists: [SpotifyArtistSimple]
    let images: [SpotifyImage]
    let release_date: String?
    let external_urls: SpotifyExternalUrls
    let uri: String
}

// Simplified versions often nested in other objects
struct SpotifyArtistSimple: Decodable, Identifiable {
    let id: String
    let name: String
    let external_urls: SpotifyExternalUrls
    let uri: String
}

struct SpotifyAlbumSimple: Decodable, Identifiable {
    let id: String
    let name: String
    let images: [SpotifyImage]? // May not always be present
    let external_urls: SpotifyExternalUrls
    let uri: String
}

struct SpotifyImage: Decodable {
    let url: String
    let height: Int?
    let width: Int?
}

struct SpotifyExternalUrls: Decodable {
    let spotify: String?
}

struct SpotifyRecommendationSeed: Decodable {
    let initialPoolSize: Int
    let afterFilteringSize: Int
    let afterRelinkingSize: Int
    let id: String
    let type: String // e.g., "ARTIST", "TRACK", "GENRE"
    let href: String?
}

// MARK: - API Endpoints

enum SpotifyAPIEndpoint {
    case search(query: String, types: [String]) // types e.g., ["track", "artist"]
    case recommendations(seedArtists: [String]?, seedGenres: [String]?, seedTracks: [String]?, limit: Int = 20)
    case trackDetails(id: String)
    // Add more endpoints as needed (e.g., artistDetails, albumDetails)

    var path: String {
        switch self {
        case .search:
            return "/v1/search"
        case .recommendations:
            return "/v1/recommendations"
        case .trackDetails(let id):
            return "/v1/tracks/\(id)"
        }
    }

    var queryItems: [URLQueryItem]? {
        switch self {
        case .search(let query, let types):
            return [
                URLQueryItem(name: "q", value: query),
                URLQueryItem(name: "type", value: types.joined(separator: ","))
                // Add limit, offset etc. if needed
            ]
        case .recommendations(let seedArtists, let seedGenres, let seedTracks, let limit):
            var items: [URLQueryItem] = []
            if let artists = seedArtists, !artists.isEmpty {
                items.append(URLQueryItem(name: "seed_artists", value: artists.joined(separator: ",")))
            }
            if let genres = seedGenres, !genres.isEmpty {
                 items.append(URLQueryItem(name: "seed_genres", value: genres.joined(separator: ",")))
            }
            if let tracks = seedTracks, !tracks.isEmpty {
                items.append(URLQueryItem(name: "seed_tracks", value: tracks.joined(separator: ",")))
            }
            items.append(URLQueryItem(name: "limit", value: String(limit)))
            // Ensure at least one seed is provided (API requirement)
            guard items.count > 1 else { return nil } // Check > 1 because limit is always added
            return items
        case .trackDetails:
            return nil // No query items for this endpoint
        }
    }
}

// MARK: - API Errors

enum SpotifyAPIError: Error, LocalizedError {
    case invalidURL
    case requestFailed(String)
    case decodingFailed(Error? = nil) // Include underlying error if possible
    case noData
    case authenticationFailed(String? = nil)
    case rateLimitExceeded
    case badRequest(String? = nil) // 400
    case forbidden(String? = nil) // 403
    case notFound // 404
    case serverError(String? = nil) // 5xx
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid API URL."
        case .requestFailed(let msg): return "Request failed: \(msg)"
        case .decodingFailed(let underlying):
            var message = "Failed to decode response."
            if let underlying = underlying { message += " Error: \(underlying.localizedDescription)" }
            return message
        case .noData: return "No data received."
        case .authenticationFailed(let msg): return "Authentication failed. \(msg ?? "")"
        case .rateLimitExceeded: return "Rate limit exceeded. Please try again later."
        case .badRequest(let msg): return "Bad request. Check parameters. \(msg ?? "")"
        case .forbidden(let msg): return "Forbidden. Insufficient permissions. \(msg ?? "")"
        case .notFound: return "Resource not found."
        case .serverError(let msg): return "Spotify server error. \(msg ?? "")"
        case .unknown(let error): return "An unknown error occurred: \(error.localizedDescription)"
        }
    }
}

// MARK: - Authentication

struct SpotifyAuthCredentials {
    // IMPORTANT: DO NOT HARDCODE IN PRODUCTION. Use secure storage (Keychain) or configuration.
    static let clientID = "YOUR_SPOTIFY_CLIENT_ID"
    static let clientSecret = "YOUR_SPOTIFY_CLIENT_SECRET"
}

// MARK: - Data Service

final class SpotifyDataService: ObservableObject {
    @Published var searchResults: [DisplayTrack] = []
    @Published var recommendations: [DisplayTrack] = []
    // Add more @Published properties for other data types if needed
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let baseURLString = "https://api.spotify.com"
    private let tokenURLString = "https://accounts.spotify.com/api/token"
    private var accessToken: String?
    private var tokenExpiration: Date?
    private var cancellables = Set<AnyCancellable>()

    init() {
       // Immediately check if credentials are placeholder values
        if SpotifyAuthCredentials.clientID == "YOUR_SPOTIFY_CLIENT_ID" || SpotifyAuthCredentials.clientSecret == "YOUR_SPOTIFY_CLIENT_SECRET" {
           print("WARNING: Spotify Client ID or Secret not set. Authentication will fail.")
           errorMessage = "Spotify Client ID/Secret not configured."
       }
    }

    // MARK: - Token Management (Client Credentials Flow)

    private func getAccessToken(completion: @escaping (Result<String, SpotifyAPIError>) -> Void) {
        if let token = accessToken, let expiration = tokenExpiration, Date() < expiration {
            completion(.success(token))
            return
        }

        // Prevent auth attempt if credentials are placeholders
        guard SpotifyAuthCredentials.clientID != "YOUR_SPOTIFY_CLIENT_ID", SpotifyAuthCredentials.clientSecret != "YOUR_SPOTIFY_CLIENT_SECRET" else {
            completion(.failure(.authenticationFailed("Client ID/Secret not configured.")))
            return
        }

        guard let url = URL(string: tokenURLString) else {
            completion(.failure(.invalidURL))
            return
        }

        let credentials = "\(SpotifyAuthCredentials.clientID):\(SpotifyAuthCredentials.clientSecret)"
        guard let base64Credentials = credentials.data(using: .utf8)?.base64EncodedString() else {
            completion(.failure(.authenticationFailed("Could not encode credentials.")))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = "grant_type=client_credentials".data(using: .utf8)

        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw SpotifyAPIError.requestFailed("No HTTP response.")
                }
                // Check for auth errors specifically
                if httpResponse.statusCode == 400 || httpResponse.statusCode == 401 {
                     let responseString = String(data: data, encoding: .utf8)
                     print("Auth Error Response: \(responseString ?? "N/A")")
                     throw SpotifyAPIError.authenticationFailed("Invalid credentials or request. Status: \(httpResponse.statusCode)")
                }
                guard (200...299).contains(httpResponse.statusCode) else {
                     let responseString = String(data: data, encoding: .utf8)
                    throw SpotifyAPIError.requestFailed("Auth request failed with status \(httpResponse.statusCode). Response: \(responseString ?? "")")
                }
                return data
            }
            .decode(type: SpotifyTokenResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completionResult in
                if case .failure(let error) = completionResult {
                    print("Token fetch error: \(error)")
                    let apiError = (error as? SpotifyAPIError) ?? SpotifyAPIError.unknown(error)
                    self?.handleError(apiError) // Update UI on failure
                    completion(.failure(apiError))
                }
            } receiveValue: { [weak self] tokenResponse in
                self?.accessToken = tokenResponse.access_token
                // Add a small buffer (e.g., 60 seconds) to expiration
                let buffer: TimeInterval = 60
                self?.tokenExpiration = Date().addingTimeInterval(TimeInterval(tokenResponse.expires_in) - buffer)
                print("Successfully obtained Spotify token.")
                completion(.success(tokenResponse.access_token))
            }
            .store(in: &cancellables)
    }

    // MARK: - Public API Data Fetching

    func performSearch(query: String) {
        fetchData(for: .search(query: query, types: ["track"])) // Search only for tracks for simplicity
    }

    func fetchRecommendations(seedTrackIDs: [String]) {
         // Ensure seeds are provided before making the request
        guard !seedTrackIDs.isEmpty else {
            handleError(.badRequest("No seed tracks provided for recommendations."))
            return
        }
        fetchData(for: .recommendations(seedArtists: nil, seedGenres: seedTrackIDs, seedTracks: nil, limit: 10))
    }

    // Generic Fetch Function
    private func fetchData(for endpoint: SpotifyAPIEndpoint) {
        isLoading = true
        errorMessage = nil
        // Clear previous results specific to the type of fetch if desired
        // if case .search = endpoint { searchResults = [] }
        // if case .recommendations = endpoint { recommendations = [] }

        getAccessToken { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let token):
                self.makeDataRequest(endpoint: endpoint, accessToken: token)
            case .failure(let error):
                // Ensure UI updates on the main thread
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.handleError(error)
                }
            }
        }
    }

    private func makeDataRequest(endpoint: SpotifyAPIEndpoint, accessToken: String) {
        var components = URLComponents(string: baseURLString)
        components?.path = endpoint.path
        components?.queryItems = endpoint.queryItems // Get query items from endpoint

        guard let url = components?.url else {
            handleError(.invalidURL)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET" // Assuming GET for these endpoints
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization") // Use Bearer token

        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw SpotifyAPIError.requestFailed("No HTTP response.")
                }
                // More granular status code handling
                switch httpResponse.statusCode {
                case 200...299:
                    return data
                case 400:
                    let msg = String(data: data, encoding: .utf8)
                    throw SpotifyAPIError.badRequest(msg)
                case 401:
                    // Token might have expired JUST before the request - potentially trigger refresh?
                    throw SpotifyAPIError.authenticationFailed("Invalid access token.")
                 case 403:
                    let msg = String(data: data, encoding: .utf8)
                    throw SpotifyAPIError.forbidden(msg)
                case 404:
                    throw SpotifyAPIError.notFound
                case 429:
                    throw SpotifyAPIError.rateLimitExceeded
                case 500...599:
                     let msg = String(data: data, encoding: .utf8)
                     throw SpotifyAPIError.serverError(msg)
                default:
                     let msg = String(data: data, encoding: .utf8)
                    throw SpotifyAPIError.requestFailed("Unhandled status: \(httpResponse.statusCode). Response: \(msg ?? "")")
                }
            }
            .receive(on: DispatchQueue.main) // Switch to main thread for decoding and UI updates
            .sink { [weak self] completionResult in
                self?.isLoading = false // Stop loading indicator on completion or failure
                if case .failure(let error) = completionResult {
                    let apiError = (error as? SpotifyAPIError) ?? SpotifyAPIError.unknown(error)
                     print("Data request error: \(apiError.localizedDescription)")
                    self?.handleError(apiError)
                }
            } receiveValue: { [weak self] data in
                guard let self = self else { return }
                // Decode based on the endpoint
                do {
                    switch endpoint {
                    case .search:
                        let decodedResponse = try JSONDecoder().decode(SpotifySearchResponse.self, from: data)
                        // Map SpotifyTrack to DisplayTrack for the UI
                        self.searchResults = (decodedResponse.tracks?.items ?? []).map { self.mapTrackToDisplay($0) }
                        print("Search successful. Found \(self.searchResults.count) tracks.")

                    case .recommendations:
                         let decodedResponse = try JSONDecoder().decode(SpotifyRecommendationsResponse.self, from: data)
                         self.recommendations = decodedResponse.tracks.map { self.mapTrackToDisplay($0) }
                         print("Recommendations successful. Found \(self.recommendations.count) tracks.")

                    case .trackDetails:
                         let decodedTrack = try JSONDecoder().decode(SpotifyTrack.self, from: data)
                         // Example: Update a specific track details view or just print
                         print("Track Details: \(decodedTrack.name)")
                         // You might want a separate @Published var for single track details
                    }
                     self.errorMessage = nil // Clear error on success

                } catch let decodingError {
                    print("Decoding Error: \(decodingError)")
                    self.handleError(.decodingFailed(decodingError))
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - Data Mapping

    private func mapTrackToDisplay(_ track: SpotifyTrack) -> DisplayTrack {
        let artistNames = track.artists.map { $0.name }.joined(separator: ", ")
        // Find the first non-null image URL, preferring medium size if available
        let imageUrl = track.album.images?.first(where: { $0.height ?? 0 > 100 && $0.height ?? 0 < 400 })?.url ?? track.album.images?.first?.url
        let previewUrl = track.preview_url != nil ? URL(string: track.preview_url!) : nil
        let spotifyUrl = track.external_urls.spotify != nil ? URL(string: track.external_urls.spotify!) : nil

        return DisplayTrack(
            id: track.id,
            name: track.name,
            artistNames: artistNames,
            albumName: track.album.name,
            previewUrl: previewUrl,
            imageUrl: imageUrl != nil ? URL(string: imageUrl!) : nil,
            spotifyUrl: spotifyUrl
        )
    }


    // MARK: - Error Handling
    private func handleError(_ error: SpotifyAPIError) {
         // Update UI on main thread
         DispatchQueue.main.async {
              self.errorMessage = error.localizedDescription
              self.isLoading = false // Ensure loading stops on error
             // Optionally clear data on specific errors (e.g., auth failure)
             // if case .authenticationFailed = error { self.clearLocalData() }
         }
    }

    // MARK: - Utility
    func clearLocalData() {
        searchResults = []
        recommendations = []
        errorMessage = nil
    }
}


// MARK: - SwiftUI Views

struct SpotifyMusicAPI_ContentView: View {
    @StateObject private var spotifyService = SpotifyDataService()
    @State private var searchQuery: String = ""
    @State private var seedTrackInput: String = "" // For entering comma-separated IDs

    var body: some View {
        NavigationView {
            Form {
                // Immediately show configuration error if present
                if let initialError = spotifyService.errorMessage, spotifyService.searchResults.isEmpty && spotifyService.recommendations.isEmpty {
                     Section(header: Text("Configuration Error")) {
                         Text(initialError)
                             .foregroundColor(.red)
                     }
                 }


                // --- Search Section ---
                Section(header: Text("Search Tracks")) {
                    TextField("Enter search query", text: $searchQuery)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    Button("Search") {
                        if !searchQuery.isEmpty {
                            spotifyService.performSearch(query: searchQuery)
                            // Hide keyboard
                           UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }
                    }
                    .disabled(searchQuery.isEmpty || spotifyService.isLoading)
                }

                // --- Recommendations Section ---
                 Section(header: Text("Recommendations")) {
                     TextField("Enter Seed Track IDs (comma-separated)", text: $seedTrackInput)
                         .autocapitalization(.none)
                         .disableAutocorrection(true)
                     Button("Get Recommendations") {
                         let trackIDs = seedTrackInput.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
                         if !trackIDs.isEmpty {
                             spotifyService.fetchRecommendations(seedTrackIDs: trackIDs)
                              UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                         }
                     }
                     .disabled(seedTrackInput.isEmpty || spotifyService.isLoading)
                 }

                // --- Results Section ---
                Section(header: Text("Results")) {
                    if spotifyService.isLoading {
                        ProgressView("Loading...")
                            .frame(maxWidth: .infinity)
                    } else if let errorMessage = spotifyService.errorMessage, !(errorMessage.contains("configured")) { // Don't show API errors if config error is shown initially
                         Text("Error: \(errorMessage)")
                             .foregroundColor(.red)
                    } else if !spotifyService.searchResults.isEmpty {
                        List(spotifyService.searchResults) { track in
                            TrackRow(track: track)
                        }
                        Button("Clear Search Results", role: .destructive) {
                            spotifyService.searchResults = []
                        }.frame(maxWidth: .infinity)
                    } else if !spotifyService.recommendations.isEmpty {
                         List(spotifyService.recommendations) { track in
                            TrackRow(track: track)
                         }
                         Button("Clear Recommendations", role: .destructive) {
                             spotifyService.recommendations = []
                         }.frame(maxWidth: .infinity)
                    }
                     else {
                        Text("No results to display. Perform a search or get recommendations.")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Spotify API Demo")
        }
    }
}

// Simple Row View for displaying track info
struct TrackRow: View {
    let track: DisplayTrack

    var body: some View {
        HStack {
            // Album Art (using AsyncImage)
            AsyncImage(url: track.imageUrl) { phase in
                switch phase {
                case .empty:
                    ProgressView().frame(width: 50, height: 50)
                case .success(let image):
                    image.resizable()
                         .aspectRatio(contentMode: .fit)
                         .frame(width: 50, height: 50)
                         .cornerRadius(4)
                case .failure:
                    Image(systemName: "music.note")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                         .padding(10)
                        .frame(width: 50, height: 50)
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(4)
                @unknown default:
                    EmptyView()
                }
            }


            VStack(alignment: .leading) {
                Text(track.name).font(.headline)
                Text(track.artistNames).font(.subheadline).foregroundColor(.secondary)
                Text(track.albumName).font(.caption).foregroundColor(.gray)
            }

            Spacer() // Push content to the left

            // Optionally add a button to play preview or open Spotify
             if let url = track.spotifyUrl {
                Link(destination: url) {
                    Image(systemName: "arrow.up.forward.app.fill")
                }
            }
        }
    }
}


// MARK: - Preview

struct SpotifyMusicAPI_ContentView_Previews: PreviewProvider {
    static var previews: some View {
        SpotifyMusicAPI_ContentView()
    }
}
