//
//  AppleMusicAPIView.swift
//  MyApp
//
//  Created by Cong Le on 3/25/25.
//

import SwiftUI
import Combine
// import JWTKit // Would be needed for actual client-side generation (NOT RECOMMENDED)

// MARK: - Data Models (Simplified based on common uses)

// Unified Model for UI display (Search Result)
struct AppleMusicSearchResult: Identifiable {
    let id: String
    let type: String // "songs", "albums", "artists" etc.
    let name: String
    let artistName: String?
    let artworkURL: URL?
}

// Unified Model for UI display (Album Detail)
struct AppleMusicAlbumDetail: Identifiable {
    let id: String
    let name: String
    let artistName: String
    let artworkURL: URL?
    let releaseDate: String?
    let songs: [Song] // Simplified song representation
    
    struct Song: Identifiable {
        let id: String
        let name: String
        let trackNumber: Int
        let durationInMillis: Int?
    }
}


// --- API Response Models (Matching Apple Music JSON Structure) ---

struct SearchResponse: Decodable {
    let results: SearchResultsContainer?
    // Add other top-level keys if needed (e.g., 'next')
}

struct SearchResultsContainer: Decodable {
    let songs: MusicItemCollection<SongData>?
    let albums: MusicItemCollection<AlbumData>?
    let artists: MusicItemCollection<ArtistData>?
    // Add other types like playlists, etc. as needed
}

struct MusicItemCollection<T: Decodable>: Decodable {
    let data: [T]
    let href: String?
    let next: String?
}

// Generic structure for various music items
struct MusicItemData<Attributes: Decodable, Relationships: Decodable>: Decodable, Identifiable {
    let id: String
    let type: String // e.g., "songs", "albums"
    let href: String?
    let attributes: Attributes?
    let relationships: Relationships?
}

// Specific Data Types (Combine Attributes and Relationships)
typealias SongData = MusicItemData<SongAttributes, SongRelationships>
typealias AlbumData = MusicItemData<AlbumAttributes, AlbumRelationships>
typealias ArtistData = MusicItemData<ArtistAttributes, ArtistRelationships> // Assuming ArtistRelationships exists if needed
typealias TrackData = MusicItemData<SongAttributes, NoRelationships> // For album tracks


// Attributes
struct SongAttributes: Decodable {
    let name: String
    let artistName: String
    let albumName: String?
    let trackNumber: Int?
    let durationInMillis: Int?
    let artwork: Artwork?
    let url: String? // Apple Music URL
    let releaseDate: String? // Usually YYYY-MM-DD
    // Add other attributes as needed
}

struct AlbumAttributes: Decodable {
    let name: String
    let artistName: String
    let artwork: Artwork?
    let trackCount: Int?
    let releaseDate: String? // Usually YYYY-MM-DD or just YYYY
    let url: String? // Apple Music URL
    // Add other attributes
}

struct ArtistAttributes: Decodable {
    let name: String
    let url: String?
    // Add other attributes
}

struct Artwork: Decodable {
    let width: Int?
    let height: Int?
    let url: String // Template URL, needs formatting
    
    // Helper to get a specific size URL
    func url(width: Int, height: Int) -> URL? {
        let formatted = url.replacingOccurrences(of: "{w}", with: "\(width)")
            .replacingOccurrences(of: "{h}", with: "\(height)")
        return URL(string: formatted)
    }
}

// Relationships
struct SongRelationships: Decodable {
    let albums: Relationship<AlbumData>?
    let artists: Relationship<ArtistData>?
    // Add others
}

struct AlbumRelationships: Decodable {
    let artists: Relationship<ArtistData>?
    let tracks: Relationship<TrackData>? // Tracks within the album
    // Add others
}

struct ArtistRelationships: Decodable {
    // Relationships artists might have (e.g., albums)
    let albums: Relationship<AlbumData>?
}

// Generic Relationship Structure
struct Relationship<T: Decodable>: Decodable {
    let data: [T] // Can be single item or array, API returns array often
    let href: String?
    let next: String?
}

// Placeholder for items with no defined relationships in the context
struct NoRelationships: Decodable {}


// MARK: - API Endpoints

enum APIEndpoint {
    case search(storefront: String, term: String, types: [String])
    case getAlbum(storefront: String, id: String, includeTracks: Bool = true)
    // Add other endpoints like getSong, getArtist, recommendations, etc.
    
    var path: String {
        switch self {
        case .search(let storefront, _, _):
            return "/v1/catalog/\(storefront)/search"
        case .getAlbum(let storefront, let id, _):
            return "/v1/catalog/\(storefront)/albums/\(id)"
            // Add other paths
        }
    }
    
    var queryItems: [URLQueryItem]? {
        switch self {
        case .search(_, let term, let types):
            var items = [URLQueryItem]()
            items.append(URLQueryItem(name: "term", value: term))
            if !types.isEmpty {
                items.append(URLQueryItem(name: "types", value: types.joined(separator: ",")))
            }
            // Add other parameters like limit, offset if needed
            return items.isEmpty ? nil : items
        case .getAlbum(_, _, let includeTracks):
            if includeTracks {
                // Request to include track relationship data
                return [URLQueryItem(name: "include", value: "tracks")]
            }
            return nil // No specific query items needed by default
            // Add query items for other endpoints if needed
        }
    }
}

// MARK: - API Errors

enum APIError: Error, LocalizedError {
    case invalidURL
    case requestFailed(String) // Includes HTTP status code errors
    case decodingFailed(Error?) // Include underlying decoding error
    case noData
    case authenticationFailed(String) // e.g., Invalid token
    case tokenGenerationFailed(String) // Specific to JWT generation
    case forbidden(String) // 403
    case notFound(String) // 404
    case rateLimited // 429
    case serverError(String) // 5xx
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid API URL."
        case .requestFailed(let message): return "API request failed: \(message)"
        case .decodingFailed(let underlyingError):
            var msg = "Failed to decode the response."
            if let error = underlyingError { msg += " Error: \(error)" }
            return msg
        case .noData: return "No data was returned."
        case .authenticationFailed(let reason): return "Authentication failed: \(reason)."
        case .tokenGenerationFailed(let reason): return "Failed to generate developer token: \(reason)."
        case .forbidden(let reason): return "Forbidden: \(reason)."
        case .notFound(let reason): return "Resource not found: \(reason)."
        case .rateLimited: return "Rate limit exceeded. Please try again later."
        case .serverError(let reason): return "Server error: \(reason)."
        case .unknown(let error): return "An unknown error occurred: \(error.localizedDescription)"
        }
    }
}


// MARK: - Authentication (Developer Token Simulation)

struct AuthCredentials {
    // --- SECURITY WARNING ---
    // NEVER embed your private key or sensitive credentials directly in the app.
    // These should be handled by a secure backend server.
    static let keyID = "YOUR_KEY_ID"           // Replace with your Key ID
    static let teamID = "YOUR_TEAM_ID"         // Replace with your Team ID
    // static let privateKey = """
    // -----BEGIN PRIVATE KEY-----
    // YOUR_PRIVATE_KEY_CONTENT_HERE
    // -----END PRIVATE KEY-----
    // """ // THIS IS HIGHLY INSECURE IN A CLIENT APP
}

/// Simulates providing a developer token. In a real app, this would fetch from your server.
struct DeveloperTokenProvider {
    static func getToken(completion: @escaping (Result<String, APIError>) -> Void) {
        // --- SIMULATION ---
        print("⚠️ WARNING: Using simulated developer token. In production, fetch securely from your backend.")
        
        // In a real app, you would:
        // 1. Call your backend endpoint.
        // 2. Your backend generates a JWT using your private key, key ID, team ID.
        // 3. Your backend returns the JWT string.
        
        // Simulate a successful token retrieval
        let dummyToken = "SIMULATED_JWT_TOKEN_\(UUID().uuidString)"
        // Simulate a potential failure (uncomment to test error handling)
        // completion(.failure(.tokenGenerationFailed("Simulated backend unavailable")))
        // return
        
        completion(.success(dummyToken))
        
        
        // If you were *insecurely* generating on client (NOT RECOMMENDED):
        /*
         guard !AuthCredentials.keyID.isEmpty, !AuthCredentials.teamID.isEmpty /*, !AuthCredentials.privateKey.isEmpty */ else {
         completion(.failure(.tokenGenerationFailed("Missing credentials (INSECURE CLIENT-SIDE)")))
         return
         }
         // Use JWTKit or similar library to create and sign the JWT here
         // let header = JWTHeader(alg: "ES256", kid: AuthCredentials.keyID)
         // let payload = JWTPayload(...) // Set 'iss' (Team ID), 'iat', 'exp'
         // let signedToken = try JWTSigner.es256(key: .private(pem: AuthCredentials.privateKey)).sign(payload, kid: AuthCredentials.keyID)
         // completion(.success(signedToken))
         */
    }
}


// MARK: - Data Service

final class AppleMusicService: ObservableObject {
    @Published var searchResults: [AppleMusicSearchResult] = []
    @Published var albumDetail: AppleMusicAlbumDetail? = nil
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let baseURLString = "https://api.music.apple.com"
    private var currentDeveloperToken: String?
    // Token expiration is typically handled by checking the 'exp' claim in a real JWT,
    // or by fetching a new token periodically/on error from the backend.
    // For simulation, we'll just fetch it each time for simplicity.
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Token Management
    private func getDeveloperToken(completion: @escaping (Result<String, APIError>) -> Void) {
        // For this simulation, we always fetch a "new" token.
        // In a real app with backend, you might cache the token with its expiration.
        DeveloperTokenProvider.getToken { result in
            switch result {
            case .success(let token):
                self.currentDeveloperToken = token
                completion(.success(token))
            case .failure(let error):
                // Ensure error is APIError type
                let apiError = (error as? APIError) ?? APIError.tokenGenerationFailed(error.localizedDescription)
                completion(.failure(apiError))
            }
        }
    }
    
    
    // MARK: - Public API Data Fetching
    func fetchData(for endpoint: APIEndpoint) {
        isLoading = true
        errorMessage = nil
        // Clear previous specific data depending on request type if desired
        if case .search = endpoint { searchResults = [] }
        if case .getAlbum = endpoint { albumDetail = nil }
        
        
        getDeveloperToken { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let token):
                self.makeDataRequest(endpoint: endpoint, token: token)
            case .failure(let error):
                // Update UI on main thread for errors during token fetch
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.handleError(error)
                }
            }
        }
    }
    
    
    private func makeDataRequest(endpoint: APIEndpoint, token: String) {
        var components = URLComponents(string: baseURLString)
        components?.path = endpoint.path
        components?.queryItems = endpoint.queryItems
        
        guard let url = components?.url else {
            DispatchQueue.main.async { self.handleError(.invalidURL) }
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        // Add other headers if required by Apple Music API
        
        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.requestFailed("No HTTP response received.")
                }
                
                let responseBodyString = String(data: data, encoding: .utf8) ?? "Could not decode response body"
                
                switch httpResponse.statusCode {
                case 200...299:
                    return data
                case 401:
                    throw APIError.authenticationFailed("Invalid developer token.")
                case 403:
                    let errorDetail = Self.parseErrorDetail(from: data) ?? "Access forbidden."
                    throw APIError.forbidden(errorDetail)
                case 404:
                    let errorDetail = Self.parseErrorDetail(from: data) ?? "Resource not found."
                    throw APIError.notFound(errorDetail)
                case 429:
                    throw APIError.rateLimited
                case 500...599:
                    throw APIError.serverError("Server error (\(httpResponse.statusCode)). \(responseBodyString)")
                default:
                    throw APIError.requestFailed("Unhandled HTTP Status: \(httpResponse.statusCode). \(responseBodyString)")
                }
            }
            .decode(type: determineResponseType(for: endpoint), decoder: JSONDecoder())
            .receive(on: DispatchQueue.main) // Switch to main thread *before* sink
            .sink { [weak self] completionResult in
                guard let self = self else { return }
                self.isLoading = false // Stop loading indicator on completion/failure
                switch completionResult {
                case .finished:
                    break // Data processing happens in receiveValue
                case .failure(let error):
                    if let decodingError = error as? DecodingError {
                        self.handleError(APIError.decodingFailed(decodingError))
                    }
                    else if let apiError = error as? APIError {
                        self.handleError(apiError)
                    } else {
                        self.handleError(APIError.unknown(error))
                    }
                }
            } receiveValue: { [weak self] decodedResponse in
                guard let self = self else { return }
                self.processDecodedData(response: decodedResponse, endpoint: endpoint)
            }
            .store(in: &cancellables)
    }
    
    /// Determines the expected root Decodable type based on the API endpoint.
    private func determineResponseType(for endpoint: APIEndpoint) -> Decodable.Type {
        switch endpoint {
        case .search:
            return SearchResponse.self // The root is SearchResponse
        case .getAlbum:
            // Assuming getting a single album returns a collection with one item
            return MusicItemCollection<AlbumData>.self
            // Add cases for other endpoints returning different root types
        }
    }
    
    /// Processes the successfully decoded data and updates the UI models.
    private func processDecodedData(response: Decodable, endpoint: APIEndpoint) {
        switch (endpoint, response) {
        case (.search, let searchResponse as SearchResponse):
            var results: [AppleMusicSearchResult] = []
            // Process albums
            searchResponse.results?.albums?.data.forEach { albumData in
                results.append(AppleMusicSearchResult(
                    id: albumData.id,
                    type: albumData.type,
                    name: albumData.attributes?.name ?? "Unknown Album",
                    artistName: albumData.attributes?.artistName,
                    artworkURL: albumData.attributes?.artwork?.url(width: 100, height: 100) // Example size
                ))
            }
            // Process songs
            searchResponse.results?.songs?.data.forEach { songData in
                results.append(AppleMusicSearchResult(
                    id: songData.id,
                    type: songData.type,
                    name: songData.attributes?.name ?? "Unknown Song",
                    artistName: songData.attributes?.artistName,
                    artworkURL: songData.attributes?.artwork?.url(width: 100, height: 100)
                ))
            }
            // Process artists, playlists etc. similarly
            self.searchResults = results
            
        case (.getAlbum(_, _, _), let albumCollection as MusicItemCollection<AlbumData>):
            guard let albumData = albumCollection.data.first else {
                self.handleError(.noData) // Or specific "Album not found in response"
                return
            }
            
            let songs = albumData.relationships?.tracks?.data.map { trackData -> AppleMusicAlbumDetail.Song in
                return AppleMusicAlbumDetail.Song(
                    id: trackData.id,
                    name: trackData.attributes?.name ?? "Unknown Track",
                    trackNumber: trackData.attributes?.trackNumber ?? 0,
                    durationInMillis: trackData.attributes?.durationInMillis
                )
            } ?? [] // Default to empty array if tracks relationship is missing
            
            self.albumDetail = AppleMusicAlbumDetail(
                id: albumData.id,
                name: albumData.attributes?.name ?? "Unknown Album",
                artistName: albumData.attributes?.artistName ?? "Unknown Artist",
                artworkURL: albumData.attributes?.artwork?.url(width: 300, height: 300), // Larger artwork
                releaseDate: albumData.attributes?.releaseDate,
                songs: songs.sorted { $0.trackNumber < $1.trackNumber } // Sort songs by track number
            )
        default:
            print("Unhandled endpoint/response combination: \(endpoint)")
            self.handleError(APIError.decodingFailed(nil)) // Or a more specific error
        }
    }
    
    // MARK: - Helper for Error Parsing
    private static func parseErrorDetail(from data: Data) -> String? {
        // Apple Music API errors often have a specific JSON structure
        struct ErrorResponse: Decodable {
            struct ErrorDetail: Decodable {
                let title: String?
                let detail: String?
                let code: String?
            }
            let errors: [ErrorDetail]?
        }
        if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data),
           let firstError = errorResponse.errors?.first {
            return firstError.detail ?? firstError.title ?? "No specific error detail provided."
        }
        return nil
    }
    
    
    // MARK: - Error Handling
    private func handleError(_ error: APIError) {
        isLoading = false // Ensure loading stops on error
        errorMessage = error.localizedDescription
        print("🔴 API Error: \(error.localizedDescription)") // Log the error
    }
    
    /// Clears locally stored data.
    func clearLocalData() {
        searchResults = []
        albumDetail = nil
        errorMessage = nil
    }
}


// MARK: - SwiftUI Views

struct AppleMusicAPIView: View {
    @StateObject private var musicService = AppleMusicService()
    @State private var searchTerm: String = "Taylor Swift" // Default search term
    @State private var selectedStorefront: String = "us" // Default storefront
    
    // Basic list of storefronts, a real app might get this dynamically or use device region
    let storefronts = ["us", "gb", "jp", "ca", "au", "de", "fr"]
    
    var body: some View {
        NavigationView {
            VStack {
                // Search Bar and Storefront Picker
                HStack {
                    Picker("Storefront", selection: $selectedStorefront) {
                        ForEach(storefronts, id: \.self) { sf in
                            Text(sf.uppercased()).tag(sf)
                        }
                    }
                    .pickerStyle(.menu)
                    .padding(.leading)
                    
                    TextField("Search Albums, Songs...", text: $searchTerm)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                        .onSubmit { // Allow searching by pressing return key
                            searchMusic()
                        }
                    
                    Button(action: searchMusic) {
                        Image(systemName: "magnifyingglass")
                    }
                    .padding(.trailing)
                }
                .padding(.top)
                
                // Results Area
                if musicService.isLoading {
                    ProgressView("Loading...")
                        .padding()
                } else if let errorMessage = musicService.errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                        .padding()
                } else if !musicService.searchResults.isEmpty {
                    List(musicService.searchResults) { result in
                        HStack {
                            // Basic Artwork View (AsyncImage requires iOS 15+)
                            if let artworkURL = result.artworkURL {
                                AsyncImage(url: artworkURL) { image in
                                    image.resizable()
                                } placeholder: {
                                    Rectangle().fill(Color.gray.opacity(0.3)) // Placeholder view
                                }
                                .frame(width: 50, height: 50)
                                .cornerRadius(4)
                            } else {
                                Rectangle().fill(Color.gray.opacity(0.3)).frame(width: 50, height: 50)
                                    .cornerRadius(4)
                            }
                            
                            VStack(alignment: .leading) {
                                Text(result.name).font(.headline)
                                if let artist = result.artistName {
                                    Text(artist).font(.subheadline).foregroundColor(.gray)
                                }
                                Text(result.type.capitalized).font(.caption).foregroundColor(.blue)
                            }
                        }
                        .onTapGesture {
                            // Example: Fetch album details if it's an album
                            if result.type == "albums" {
                                fetchAlbumDetails(id: result.id)
                            }
                        }
                    }
                } else if let albumDetail = musicService.albumDetail {
                    // Display Album Detail View (Simplified)
                    AlbumDetailView(album: albumDetail)
                }
                else {
                    Text("Enter a search term or select an item.")
                        .padding()
                }
                
                Spacer() // Pushes content to the top
                
                Button("Clear Results", role:.destructive) {
                    musicService.clearLocalData()
                    searchTerm = "" // Optionally clear search term too
                }
                .padding()
                
            }
            .navigationTitle("Apple Music Search")
        }
    }
    
    private func searchMusic() {
        guard !searchTerm.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        musicService.fetchData(for: .search(storefront: selectedStorefront,
                                            term: searchTerm,
                                            types: ["albums", "songs"])) // Search for albums and songs
        // Dismiss keyboard if needed
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    private func fetchAlbumDetails(id: String) {
        musicService.fetchData(for: .getAlbum(storefront: selectedStorefront, id: id, includeTracks: true))
    }
    
}


// Simple view to display album details
struct AlbumDetailView: View {
    let album: AppleMusicAlbumDetail
    
    var body: some View {
        ScrollView {
            VStack(alignment:.center) {
                if let artworkURL = album.artworkURL {
                    AsyncImage(url: artworkURL) { image in
                        image.resizable().aspectRatio(contentMode: .fit)
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(maxWidth: 300)
                    .cornerRadius(8)
                    .shadow(radius: 5)
                    .padding(.bottom)
                }
                
                Text(album.name).font(.title).multilineTextAlignment(.center)
                Text(album.artistName).font(.title3).foregroundColor(.secondary).padding(.bottom)
                if let releaseDate = album.releaseDate {
                    Text("Released: \(formattedDate(releaseDate))").font(.caption).foregroundColor(.gray)
                }
                
                Divider().padding(.vertical)
                
                Text("Tracks").font(.headline)
                ForEach(album.songs) { song in
                    HStack {
                        Text("\(song.trackNumber).")
                        Text(song.name)
                        Spacer()
                        if let duration = song.durationInMillis {
                            Text(formattedDuration(duration))
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.vertical, 2)
                }
            }
            .padding()
        }
        .navigationTitle("Album Details") // Assuming it's within a NavigationView
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // Helper for formatting duration
    private func formattedDuration(_ millis: Int) -> String {
        let totalSeconds = millis / 1000
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    // Helper for formatting date (handles YYYY-MM-DD or YYYY)
    private func formattedDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        if dateString.contains("-") {
            formatter.dateFormat = "yyyy-MM-dd"
            if let date = formatter.date(from: dateString) {
                formatter.dateStyle = .medium
                formatter.timeStyle = .none
                return formatter.string(from: date)
            }
        } else { // Assume YYYY if no hyphen
            formatter.dateFormat = "yyyy"
            if let date = formatter.date(from: dateString) {
                return formatter.string(from: date) // Just return the year
            }
        }
        return dateString // Fallback
    }
}

// MARK: - Preview

struct AppleMusicAPIView_Previews: PreviewProvider {
    static var previews: some View {
        AppleMusicAPIView()
    }
}
