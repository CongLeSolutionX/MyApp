////
////  AuthenticationFlowView_V3.swift
////  MyApp
////
////  Created by Cong Le on 4/15/25.
////
//import SwiftUI
//import Combine
//import CryptoKit // For PKCE SHA256
//import AuthenticationServices // For ASWebAuthenticationSession
//import WebKit // For SpotifyEmbedWebView
//
//// MARK: - Configuration (MUST REPLACE)
//struct SpotifyConstants {
//    // ---vvv--- MUST REPLACE THESE ---vvv---
//    static let clientID = "YOUR_CLIENT_ID" // <-- REPLACE THIS
//    static let redirectURI = "myapp://callback" // <-- REPLACE THIS (must match plist & Spotify Dashboard)
//    // ---^^^--- MUST REPLACE THESE ---^^^---
//    
//    static let scopes = [
//        "user-read-private",
//        "user-read-email",
//        "playlist-read-private",
//        "playlist-read-collaborative",
//        // Removed playlist modify scopes for this example
//        "streaming" // REQUIRED for web playback SDK functionality (even if just embed)
//    ]
//    static let scopeString = scopes.joined(separator: " ")
//    
//    // Endpoints
//    static let authorizationEndpoint = URL(string: "https://accounts.spotify.com/authorize")!
//    static let tokenEndpoint = URL(string: "https://accounts.spotify.com/api/token")!
//    static let userProfileEndpoint = URL(string: "https://api.spotify.com/v1/me")!
//    static let userPlaylistsEndpoint = URL(string: "https://api.spotify.com/v1/me/playlists")!
//    // New endpoints
//    static func playlistTracksEndpoint(playlistId: String) -> URL? {
//        return URL(string: "https://api.spotify.com/v1/playlists/\(playlistId)/tracks")
//    }
//    static func trackDetailEndpoint(trackId: String) -> URL? {
//        return URL(string: "https://api.spotify.com/v1/tracks/\(trackId)")
//    }
//    
//    static let tokenUserDefaultsKey = "spotifyTokens_v3_withPlayer" // Distinct key
//}
//
//// MARK: - Spotify Data Models (Expanded)
//
//struct TokenResponse: Codable { // No changes needed
//    let accessToken: String
//    let tokenType: String
//    let expiresIn: Int
//    let refreshToken: String?
//    let scope: String
//    var expiryDate: Date? { Calendar.current.date(byAdding: .second, value: expiresIn, to: Date()) }
//    enum CodingKeys: String, CodingKey { case accessToken = "access_token", tokenType = "token_type", expiresIn = "expires_in", refreshToken = "refresh_token", scope }
//}
//
//struct StoredTokens: Codable { // No changes needed
//    let accessToken: String
//    let refreshToken: String?
//    let expiryDate: Date?
//}
//
//struct SpotifyUserProfile: Codable, Identifiable { // No changes needed
//    let id: String
//    let displayName: String
//    let email: String
//    let images: [SpotifyImage]?
//    let externalUrls: [String: String]?
//    enum CodingKeys: String, CodingKey { case id, displayName = "display_name", email, images, externalUrls = "external_urls" }
//}
//
//struct SpotifyImage: Codable { // No changes needed
//    let url: String
//    let height: Int?
//    let width: Int?
//}
//
//// --- Playlist Models --- (No changes needed)
//
//struct SpotifyPagingObject<T: Codable>: Codable {
//    let href: String, items: [T], limit: Int, next: String?, offset: Int, previous: String?, total: Int
//}
//struct SpotifyPlaylistOwner: Codable, Identifiable {
//    let id: String, displayName: String?, externalUrls: [String: String]?
//    enum CodingKeys: String, CodingKey { case id, displayName = "display_name", externalUrls = "external_urls" }
//}
//struct PlaylistTracksInfo: Codable { let href: String, total: Int }
//struct SpotifyPlaylist: Codable, Identifiable {
//    let id: String, name: String, description: String?, owner: SpotifyPlaylistOwner, collaborative: Bool, tracks: PlaylistTracksInfo, images: [SpotifyImage]?, externalUrls: [String: String]?, publicPlaylist: Bool?
//    enum CodingKeys: String, CodingKey { case id, name, description, owner, collaborative, tracks, images, externalUrls = "external_urls", publicPlaylist = "public" }
//}
//typealias SpotifyPlaylistList = SpotifyPagingObject<SpotifyPlaylist>
//
//// --- Playlist Track Item Models --- (NEW)
//
//struct SpotifyPlaylistTracksResponse: Codable {
//    let href: String
//    let items: [PlaylistTrackItem] // Array of track items
//    let limit: Int
//    let next: String?
//    let offset: Int
//    let previous: String?
//    let total: Int
//}
//
//struct PlaylistTrackItem: Codable, Identifiable {
//    var id: String { track?.id ?? UUID().uuidString } // Use track ID if available, else generate one
//    let addedAt: String? // Or Date? if you parse it
//    // let addedBy: User? // Simplified: Ignoring user who added it
//    let isLocal: Bool
//    let track: SimplifiedTrackObject? // The actual track details
//    
//    enum CodingKeys: String, CodingKey {
//        case addedAt = "added_at"
//        // case addedBy = "added_by"
//        case isLocal = "is_local"
//        case track
//    }
//}
//
//// Simplified Track Object (often embedded in playlist responses)
//struct SimplifiedTrackObject: Codable, Identifiable {
//    let artists: [SimplifiedArtistObject]
//    let availableMarkets: [String]?
//    let discNumber: Int?
//    let durationMs: Int
//    let explicit: Bool
//    let externalUrls: [String: String]?
//    let href: String? // Link to full track details
//    let id: String
//    let isPlayable: Bool?
//    // linked_from: LinkedTrackObject? // Ignoring linked track for simplicity
//    let name: String
//    let previewUrl: String? // MP3 Preview link
//    let trackNumber: Int?
//    let type: String // Should be "track"
//    let uri: String // Spotify URI
//    
//    // Computed property for display
//    var artistNames: String {
//        artists.map { $0.name }.joined(separator: ", ")
//    }
//    
//    enum CodingKeys: String, CodingKey {
//        case artists
//        case availableMarkets = "available_markets"
//        case discNumber = "disc_number"
//        case durationMs = "duration_ms"
//        case explicit
//        case externalUrls = "external_urls"
//        case href
//        case id
//        case isPlayable = "is_playable"
//        // case linked_from
//        case name
//        case previewUrl = "preview_url"
//        case trackNumber = "track_number"
//        case type
//        case uri
//    }
//}
//
//// Simplified Artist Object
//struct SimplifiedArtistObject: Codable, Identifiable {
//    let externalUrls: [String: String]?
//    let href: String?
//    let id: String
//    let name: String
//    let type: String // Should be "artist"
//    let uri: String
//    
//    enum CodingKeys: String, CodingKey {
//        case externalUrls = "external_urls", href, id, name, type, uri
//    }
//}
//
//// --- Full Track Detail Models --- (NEW)
//
//struct SpotifyTrackDetail: Codable, Identifiable {
//    let album: SimplifiedAlbumObject // Album info
//    let artists: [SimplifiedArtistObject] // Artist info
//    let availableMarkets: [String]?
//    let discNumber: Int?
//    let durationMs: Int
//    let explicit: Bool
//    let externalIds: [String: String]? // e.g., isrc
//    let externalUrls: [String: String]?
//    let href: String?
//    let id: String
//    let isPlayable: Bool?
//    // linked_from: LinkedTrackObject?
//    let name: String
//    let popularity: Int? // 0-100
//    let previewUrl: String?
//    let trackNumber: Int?
//    let type: String // "track"
//    let uri: String // Spotify URI
//    let isLocal: Bool?
//    
//    enum CodingKeys: String, CodingKey {
//        case album, artists
//        case availableMarkets = "available_markets"
//        case discNumber = "disc_number"
//        case durationMs = "duration_ms"
//        case explicit
//        case externalIds = "external_ids"
//        case externalUrls = "external_urls"
//        case href, id
//        case isPlayable = "is_playable"
//        // case linked_from
//        case name, popularity
//        case previewUrl = "preview_url"
//        case trackNumber = "track_number"
//        case type, uri
//        case isLocal = "is_local"
//    }
//}
//
//// Simplified Album Object (used within Track Detail)
//struct SimplifiedAlbumObject: Codable, Identifiable {
//    let albumType: String? // e.g., "album", "single"
//    let totalTracks: Int?
//    let availableMarkets: [String]?
//    let externalUrls: [String: String]?
//    let href: String?
//    let id: String
//    let images: [SpotifyImage]? // Album artwork
//    let name: String
//    let releaseDate: String? // e.g., "1981-12"
//    let releaseDatePrecision: String? // e.g., "year"
//    let type: String // "album"
//    let uri: String // Spotify URI
//    // artists: [SimplifiedArtistObject]? // Sometimes included, simplified here
//    
//    enum CodingKeys: String, CodingKey {
//        case albumType = "album_type"
//        case totalTracks = "total_tracks"
//        case availableMarkets = "available_markets"
//        case externalUrls = "external_urls"
//        case href, id, images, name
//        case releaseDate = "release_date"
//        case releaseDatePrecision = "release_date_precision"
//        case type, uri
//    }
//}
//
//// MARK: - Error Handling Models (No changes needed)
//enum APIError: Error, LocalizedError { case invalidRequest(message: String), networkError(Error), invalidResponse, httpError(statusCode: Int, details: String), noData, decodingError(Error?), notLoggedIn, tokenRefreshFailed, authenticationFailed, maxRetriesReached, unknown; var errorDescription: String? { /* ... Full implementation omitted for brevity ... */ switch self { case .invalidRequest(let message): return "Invalid request: \(message)"; case .networkError(let error): return "Network error: \(error.localizedDescription)"; case .invalidResponse: return "Invalid response from server."; case .httpError(let statusCode, let details): return "HTTP Error \(statusCode): \(details)"; case .noData: return "No data received from server."; case .decodingError: return "Failed to decode server response."; case .notLoggedIn: return "User is not logged in."; case .tokenRefreshFailed: return "Could not refresh session token."; case .authenticationFailed: return "Authentication failed."; case .maxRetriesReached: return "Maximum retry attempts reached."; case .unknown: return "An unknown error occurred." } }; var isAuthError: Bool { /* ... */ switch self { case .httpError(let statusCode, _): return statusCode == 401 || statusCode == 403; case .authenticationFailed, .tokenRefreshFailed, .notLoggedIn: return true; default: return false } } }
//struct SpotifyErrorResponse: Codable { let error: SpotifyErrorDetail }
//struct SpotifyErrorDetail: Codable { let status: Int, message: String? }
//struct EmptyResponse: Codable {} // For 204 No Content
//
//// MARK: - TrackDetails struct (UI Model - From previous example, slightly adapted)
//// This struct unifies data from different sources (playlist item, track detail) for the UI
//struct TrackDetails: Identifiable, Equatable {
//    let id: String // Spotify URI (e.g., "spotify:track:123")
//    let title: String
//    let artistName: String
//    let albumTitle: String?
//    let artworkURL: URL?
//    let durationMs: Int
//    let previewURL: URL? // Added for potential direct preview playback
//    
//    // Computed properties
//    var formattedDuration: String {
//        let totalSeconds = durationMs / 1000
//        let minutes = totalSeconds / 60
//        let seconds = totalSeconds % 60
//        return String(format: "%d:%02d", minutes, seconds)
//    }
//    
//    var webLink: URL? {
//        let parts = id.split(separator: ":")
//        guard parts.count == 3 else { return nil }
//        return URL(string: "https://open.spotify.com/\(parts[1])/\(parts[2])")
//    }
//    
//    // Initializer from SimplifiedTrackObject (Playlist Item)
//    init?(from simplifiedTrack: SimplifiedTrackObject, albumImageURL: URL? = nil) {
//        guard !simplifiedTrack.id.isEmpty else { return nil } // Need an ID
//        self.id = simplifiedTrack.uri // Use the URI directly
//        self.title = simplifiedTrack.name
//        self.artistName = simplifiedTrack.artistNames
//        self.albumTitle = nil // Album info not directly in SimplifiedTrackObject often
//        self.artworkURL = albumImageURL // Can be passed in from playlist context if needed
//        self.durationMs = simplifiedTrack.durationMs
//        self.previewURL = URL(string: simplifiedTrack.previewUrl ?? "")
//    }
//    
//    // Initializer from SpotifyTrackDetail (Full Track Detail)
//    init(from detail: SpotifyTrackDetail) {
//        self.id = detail.uri
//        self.title = detail.name
//        self.artistName = detail.artists.map { $0.name }.joined(separator: ", ")
//        self.albumTitle = detail.album.name
//        self.artworkURL = URL(string: detail.album.images?.first?.url ?? "")
//        self.durationMs = detail.durationMs
//        self.previewURL = URL(string: detail.previewUrl ?? "")
//    }
//}
//
//// MARK: - SpotifyAuthManager (Expanded with Track/Playlist Track Fetching)
//class SpotifyAuthManager: ObservableObject {
//    
//    @Published var isLoggedIn: Bool = false
//    @Published var currentTokens: StoredTokens? = nil
//    @Published var userProfile: SpotifyUserProfile? = nil
//    @Published var isLoading: Bool = false // General loading (auth, profile)
//    @Published var errorMessage: String? = nil // General errors
//    
//    // Playlist State
//    // ... (variables remain the same: userPlaylists, isLoadingPlaylists, etc.) ...
//    @Published var userPlaylists: [SpotifyPlaylist] = []
//    @Published var isLoadingPlaylists: Bool = false
//    @Published var playlistErrorMessage: String? = nil
//    @Published var canLoadMorePlaylists: Bool = false
//    private var playlistNextPageUrl: String? { didSet { DispatchQueue.main.async { self.canLoadMorePlaylists = (self.playlistNextPageUrl != nil) } } }
//    
//    // Track Fetching State (Could wrap in a helper class if it gets complex)
//    @Published var isLoadingTrack: Bool = false
//    @Published var trackError: String? = nil
//    
//    // Playlist Tracks State
//    @Published var isLoadingPlaylistTracks: Bool = false
//    @Published var playlistTracksError: String? = nil
//    @Published var canLoadMorePlaylistTracks: Bool = false
//    private var playlistTracksNextPageUrl: String? { didSet { DispatchQueue.main.async { self.canLoadMorePlaylistTracks = (self.playlistTracksNextPageUrl != nil) } } }
//    
//    private var currentPKCEVerifier: String?
//    private var currentWebAuthSession: ASWebAuthenticationSession?
//    
//    // Initialization & Token Management (No significant changes needed from previous version)
//    // ... (init, saveTokens, loadTokens, clearTokens, checkTokenExpiryAndUpdateState) ...
//    init() { loadTokens(); if let t = currentTokens, let e = t.expiryDate, e > Date() { self.isLoggedIn = true; fetchUserProfile(); fetchUserPlaylists() } else if currentTokens != nil { refreshToken { [weak self] s in if s { self?.fetchUserProfile(); self?.fetchUserPlaylists() } else { self?.logout() } } } }
//    private func saveTokens(tokens: StoredTokens) { if let e = try? JSONEncoder().encode(tokens) { UserDefaults.standard.set(e, forKey: SpotifyConstants.tokenUserDefaultsKey); print("Tokens saved (UserDefaults - Use Keychain)") } else { print("Failed to save tokens.") } }
//    private func loadTokens() { if let d = UserDefaults.standard.data(forKey: SpotifyConstants.tokenUserDefaultsKey), let t = try? JSONDecoder().decode(StoredTokens.self, from: d) {currentTokens = t; checkTokenExpiryAndUpdateState()} else { currentTokens = nil; isLoggedIn = false } }
//    private func clearTokens() { UserDefaults.standard.removeObject(forKey: SpotifyConstants.tokenUserDefaultsKey) }
//    private func checkTokenExpiryAndUpdateState() { guard let e = currentTokens?.expiryDate else { isLoggedIn = false; return }; isLoggedIn = e > Date() }
//    
//    // PKCE Helpers (No changes needed)
//    // ... (generateCodeVerifier, generateCodeChallenge) ...
//    private func generateCodeVerifier() -> String { var b = [UInt8](repeating: 0, count: 32); SecRandomCopyBytes(kSecRandomDefault, b.count, &b); return Data(b).base64URLEncodedString() }
//    private func generateCodeChallenge(from v: String) -> String? { guard let d=v.data(using: .utf8) else { return nil }; let h=SHA256.hash(data: d); return Data(h).base64URLEncodedString() }
//    
//    // Authorization Flow (No significant changes needed)
//    // ... (initiateAuthorization, handleAuthCallback, exchangeCodeForToken) ...
//    func initiateAuthorization() { guard !isLoading else { return }; DispatchQueue.main.async { self.isLoading = true; self.errorMessage = nil; /* Clear other state */ }; let v = generateCodeVerifier(); guard let c = generateCodeChallenge(from: v) else { handleError("PKCE Error."); DispatchQueue.main.async{ self.isLoading=false }; return }; currentPKCEVerifier = v; var comps = URLComponents(url: SpotifyConstants.authorizationEndpoint, resolvingAgainstBaseURL: true)!; comps.queryItems = [ /* ... client_id, response_type, redirect_uri, scope, code_challenge_method, code_challenge ... */ URLQueryItem(name: "client_id", value: SpotifyConstants.clientID), URLQueryItem(name: "response_type", value: "code"), URLQueryItem(name: "redirect_uri", value: SpotifyConstants.redirectURI), URLQueryItem(name: "scope", value: SpotifyConstants.scopeString), URLQueryItem(name: "code_challenge_method", value: "S256"), URLQueryItem(name: "code_challenge", value: c) ]; guard let authURL = comps.url else { handleError("Auth URL Error."); DispatchQueue.main.async{ self.isLoading=false }; return }; let scheme = URL(string: SpotifyConstants.redirectURI)?.scheme; DispatchQueue.main.async { self.currentWebAuthSession = ASWebAuthenticationSession(url: authURL, callbackURLScheme: scheme) { [weak self] url, err in DispatchQueue.main.async { guard let self = self else { return }; self.isLoading = false; self.handleAuthCallback(callbackURL: url, error: err) } }; self.currentWebAuthSession?.presentationContextProvider = self; self.currentWebAuthSession?.prefersEphemeralWebBrowserSession = true; self.currentWebAuthSession?.start() } }
//    private func handleAuthCallback(callbackURL: URL?, error: Error?) { guard currentPKCEVerifier != nil else { return }; if let e = error { if let ae = e as? ASWebAuthenticationSessionError, ae.code == .canceledLogin { handleError("Login cancelled.") } else { handleError("Auth failed: \(e.localizedDescription)") } } else if let u = callbackURL, let c = URLComponents(string: u.absoluteString)?.queryItems?.first(where: { $0.name == "code" })?.value { exchangeCodeForToken(code: c); return /* success path */ } else { handleError("Auth failed: Invalid callback URL/code.") }; currentPKCEVerifier = nil /* clear verifier on any exit from here */ }
//    private func exchangeCodeForToken(code: String) { guard let v = currentPKCEVerifier else { handleError("Auth failed (verifier missing)."); return }; DispatchQueue.main.async { self.isLoading = true }; makeTokenRequest(grantType: "authorization_code", code: code, verifier: v) { [weak self] result in DispatchQueue.main.async { guard let self = self else { return }; self.isLoading = false; self.currentPKCEVerifier = nil; switch result { case .success(let r): self.processSuccessfulTokenResponse(r); self.fetchUserProfile(); self.fetchUserPlaylists(); case .failure(let e): self.handleError("Token exchange failed: \(e.localizedDescription)") } } } }
//    
//    // Token Refresh (No significant changes needed)
//    // ... (refreshToken) ...
//    func refreshToken(completion: ((Bool) -> Void)? = nil) { guard !isLoading else { completion?(false); return }; guard let rt = currentTokens?.refreshToken else { logout(); completion?(false); return }; DispatchQueue.main.async { self.isLoading = true; self.errorMessage = nil }; makeTokenRequest(grantType: "refresh_token", refreshToken: rt) { [weak self] result in DispatchQueue.main.async { guard let self = self else { completion?(false); return }; self.isLoading = false; switch result { case .success(let r): let u = r.refreshToken ?? self.currentTokens?.refreshToken; self.processSuccessfulTokenResponse(r, explicitRefreshToken: u); completion?(true); case .failure(let e): self.handleError("Session expired."); if let ae = e as? APIError, ae.isAuthError { self.logout() }; completion?(false) } } } }
//    
//    // Centralized Token Request Logic (No changes needed)
//    // ... (makeTokenRequest) ...
//    private func makeTokenRequest(grantType: String, code: String? = nil, verifier: String? = nil, refreshToken: String? = nil, completion: @escaping (Result<TokenResponse, Error>) -> Void) { var r = URLRequest(url: SpotifyConstants.tokenEndpoint); r.httpMethod = "POST"; r.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type"); var comps = URLComponents(); var qi = [URLQueryItem(name: "client_id", value: SpotifyConstants.clientID), URLQueryItem(name: "grant_type", value: grantType)]; if let c=code, let v=verifier, grantType=="authorization_code" { qi.append(contentsOf: [URLQueryItem(name: "code", value: c), URLQueryItem(name: "redirect_uri", value: SpotifyConstants.redirectURI), URLQueryItem(name: "code_verifier", value: v)]) } else if let rt=refreshToken, grantType=="refresh_token" { qi.append(URLQueryItem(name: "refresh_token", value: rt)) } else { completion(.failure(APIError.invalidRequest(message:"Bad params"))); return }; comps.queryItems = qi; r.httpBody = comps.query?.data(using: .utf8); URLSession.shared.dataTask(with: r) { d, rsp, err in if let e = err { completion(.failure(APIError.networkError(e))); return }; guard let hr = rsp as? HTTPURLResponse else { completion(.failure(APIError.invalidResponse)); return }; guard (200...299).contains(hr.statusCode) else { let de = self.extractErrorDetails(from: d, statusCode: hr.statusCode); completion(.failure(APIError.httpError(statusCode: hr.statusCode, details: de))); return }; guard let data = d else { completion(.failure(APIError.noData)); return }; do { let tr = try JSONDecoder().decode(TokenResponse.self, from: data); completion(.success(tr)); } catch { completion(.failure(APIError.decodingError(error))) } }.resume() }
//    private func processSuccessfulTokenResponse(_ tokenResponse: TokenResponse, explicitRefreshToken: String? = nil) { let n = explicitRefreshToken ?? tokenResponse.refreshToken; let s = StoredTokens(accessToken: tokenResponse.accessToken, refreshToken: n, expiryDate: tokenResponse.expiryDate); DispatchQueue.main.async {self.currentTokens = s; self.saveTokens(tokens: s); self.isLoggedIn = true; self.errorMessage = nil} }
//    
//    // User Profile Fetching (No significant changes needed)
//    // ... (fetchUserProfile) ...
//    func fetchUserProfile() { if userProfile == nil { DispatchQueue.main.async { self.isLoading = true } }; makeAPIRequest(url: SpotifyConstants.userProfileEndpoint, responseType: SpotifyUserProfile.self, currentAttempt: 1, maxAttempts: 2) { [weak self] result in DispatchQueue.main.async { guard let self = self else { return }; self.isLoading = false; switch result { case .success(let p): self.userProfile = p; self.errorMessage = nil; case .failure(let e): self.handleError("Fetch Profile Error: \(e.localizedDescription)") } } } }
//    
//    // Playlist Fetching (No significant changes needed)
//    // ... (fetchUserPlaylists) ...
//    func fetchUserPlaylists(loadNextPage: Bool = false) { var urlToFetch: URL?; if loadNextPage, let next = playlistNextPageUrl { urlToFetch = URL(string: next) } else if !loadNextPage { urlToFetch = SpotifyConstants.userPlaylistsEndpoint; DispatchQueue.main.async { self.userPlaylists = []; self.playlistNextPageUrl = nil; self.playlistErrorMessage = nil } } else { return }; guard let finalUrl = urlToFetch, !isLoadingPlaylists, isLoggedIn else { return }; DispatchQueue.main.async { self.isLoadingPlaylists = true; self.playlistErrorMessage = nil }; makeAPIRequest(url: finalUrl, responseType: SpotifyPlaylistList.self, currentAttempt: 1, maxAttempts: 2) { [weak self] result in DispatchQueue.main.async { guard let self = self else { return }; self.isLoadingPlaylists = false; switch result { case .success(let r): if loadNextPage { self.userPlaylists.append(contentsOf: r.items) } else { self.userPlaylists = r.items }; self.playlistNextPageUrl = r.next; self.playlistErrorMessage = nil; case .failure(let e): self.handlePlaylistError("Fetch Playlists Error: \(e.localizedDescription)"); self.playlistNextPageUrl = nil } } } }
//    
//    // --- Playlist TRACKS Fetching --- (NEW)
//    func fetchPlaylistTracks(playlistId: String, loadNextPage: Bool = false, currentTracks: [PlaylistTrackItem] = []) async throws -> (items: [PlaylistTrackItem], nextUrl: String?) {
//        var urlToFetch: URL?
//        if loadNextPage, let nextUrl = self.playlistTracksNextPageUrl {
//            urlToFetch = URL(string: nextUrl)
//            print("Fetching next page of tracks for playlist \(playlistId) from \(nextUrl)")
//        } else if !loadNextPage {
//            urlToFetch = SpotifyConstants.playlistTracksEndpoint(playlistId: playlistId)
//            print("Fetching initial tracks for playlist \(playlistId)")
//            // Reset pagination for this specific playlist's tracks
//            DispatchQueue.main.async { // Ensure UI updates happen on main thread
//                self.playlistTracksNextPageUrl = nil
//                self.canLoadMorePlaylistTracks = false
//            }
//        } else {
//            print("No more playlist tracks to load for \(playlistId)")
//            throw APIError.noData // Or a custom "noMorePages" error
//        }
//        
//        guard let finalUrl = urlToFetch else {
//            throw APIError.invalidRequest(message: "Invalid playlist tracks URL")
//        }
//        
//        // Use main actor for state changes before await
//        await MainActor.run {
//            self.isLoadingPlaylistTracks = true
//            self.playlistTracksError = nil
//        }
//        
//        // Generic request function using async/await (needs adaptation or parallel func)
//        // For simplicity, sticking with completion handler structure for now
//        return try await withCheckedThrowingContinuation { continuation in
//            makeAPIRequest(
//                url: finalUrl,
//                responseType: SpotifyPlaylistTracksResponse.self,
//                currentAttempt: 1,
//                maxAttempts: 2
//            ) { [weak self] result in
//                guard let self = self else {
//                    continuation.resume(throwing: APIError.unknown)
//                    return
//                }
//                // Switch back to main thread for state updates
//                DispatchQueue.main.async {
//                    self.isLoadingPlaylistTracks = false
//                    switch result {
//                    case .success(let response):
//                        print("Fetched \(response.items.count) tracks for playlist \(playlistId). Next URL: \(response.next ?? "None")")
//                        // Update the next page URL *before* resuming
//                        self.playlistTracksNextPageUrl = response.next
//                        // Combine new tracks with existing ones if loading next page
//                        let combinedItems = loadNextPage ? currentTracks + response.items : response.items
//                        continuation.resume(returning: (combinedItems, response.next))
//                    case .failure(let error):
//                        print("Error fetching tracks for playlist \(playlistId): \(error)")
//                        self.playlistTracksError = "Failed to load tracks: \(error.localizedDescription)"
//                        // Reset next page URL on error
//                        self.playlistTracksNextPageUrl = nil
//                        continuation.resume(throwing: error)
//                    }
//                } // end DispatchQueue.main.async
//            } // end makeAPIRequest
//        } // end withCheckedThrowingContinuation
//    }
//    
//    // --- Track Detail Fetching --- (NEW)
//    func fetchTrackDetails(trackId: String) async throws -> TrackDetails {
//        guard let finalUrl = SpotifyConstants.trackDetailEndpoint(trackId: trackId) else {
//            throw APIError.invalidRequest(message: "Invalid track detail URL")
//        }
//        
//        await MainActor.run {
//            self.isLoadingTrack = true
//            self.trackError = nil
//        }
//        
//        return try await withCheckedThrowingContinuation { continuation in
//            makeAPIRequest(
//                url: finalUrl,
//                responseType: SpotifyTrackDetail.self,
//                currentAttempt: 1,
//                maxAttempts: 2
//            ) { [weak self] result in
//                guard let self = self else {
//                    continuation.resume(throwing: APIError.unknown)
//                    return
//                }
//                DispatchQueue.main.async {
//                    self.isLoadingTrack = false
//                    switch result {
//                    case .success(let trackDetail):
//                        print("Successfully fetched details for track: \(trackDetail.name)")
//                        // Convert the detailed API response to the simplified UI model
//                        let uiDetails = TrackDetails(from: trackDetail)
//                        continuation.resume(returning: uiDetails)
//                    case .failure(let error):
//                        print("Error fetching track details for ID \(trackId): \(error)")
//                        self.trackError = "Failed to load track details."
//                        continuation.resume(throwing: error)
//                    }
//                }
//            }
//        }
//    }
//    
//    // Generic API Request (No significant changes needed, still uses completion handlers)
//    // ... (makeAPIRequest) ... - Keep the existing one that uses completion handlers
//    private func makeAPIRequest<T: Decodable>(url: URL, method: String = "GET", body: Data? = nil, responseType: T.Type, currentAttempt: Int, maxAttempts: Int, completion: @escaping (Result<T, Error>) -> Void) {
//        guard currentAttempt <= maxAttempts else { completion(.failure(APIError.maxRetriesReached)); return }
//        
//        // --- Pre-emptive Token Refresh Check ---
//        if let expiry = currentTokens?.expiryDate, expiry <= Date() {
//            print("Token expired/expiring, refreshing before \(url.lastPathComponent)...")
//            refreshToken { [weak self] success in
//                guard let self = self else { completion(.failure(APIError.unknown)); return }
//                if success {
//                    // Retry call AFTER refresh completes
//                    self.makeAPIRequest(url: url, method: method, body: body, responseType: responseType, currentAttempt: currentAttempt + 1, maxAttempts: maxAttempts, completion: completion)
//                } else {
//                    // Refresh failed, log out and report error
//                    self.logout()
//                    completion(.failure(APIError.tokenRefreshFailed))
//                }
//            }
//            return // Wait for refresh cycle
//        }
//        // --- End Pre-emptive Refresh ---
//        
//        guard let accessToken = currentTokens?.accessToken else { logout(); completion(.failure(APIError.notLoggedIn)); return }
//        var request = URLRequest(url: url); request.httpMethod = method; request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization"); if let b = body, ["POST","PUT","DELETE"].contains(method) { request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type"); request.httpBody = b }
//        
//        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
//            guard let self = self else { completion(.failure(APIError.unknown)); return }
//            if let e = error { completion(.failure(APIError.networkError(e))); return }
//            guard let httpResponse = response as? HTTPURLResponse else { completion(.failure(APIError.invalidResponse)); return }
//            
//            // --- 401/403 Refresh Handling ---
//            if (httpResponse.statusCode == 401 || httpResponse.statusCode == 403) && currentAttempt < maxAttempts {
//                print("Received \(httpResponse.statusCode) for \(url.lastPathComponent), refreshing token (attempt \(currentAttempt + 1))...")
//                self.refreshToken { success in
//                    if success {
//                        self.makeAPIRequest(url: url, method: method, body: body, responseType: responseType, currentAttempt: currentAttempt + 1, maxAttempts: maxAttempts, completion: completion)
//                    } else {
//                        print("Refresh failed after \(httpResponse.statusCode), logging out.")
//                        self.logout()
//                        completion(.failure(APIError.authenticationFailed))
//                    }
//                }
//                return // Wait for refresh cycle
//            }
//            // --- End 401/403 Handling ---
//            
//            guard (200...299).contains(httpResponse.statusCode) else { let de = self.extractErrorDetails(from: data, statusCode: httpResponse.statusCode); completion(.failure(APIError.httpError(statusCode: httpResponse.statusCode, details: de))); return }
//            guard let d = data else { if httpResponse.statusCode == 204, T.self == EmptyResponse.self, let e = EmptyResponse() as? T { completion(.success(e)); return } else { completion(.failure(APIError.noData)); return } } // Handle No Content (204)
//            if httpResponse.statusCode == 204 { if T.self == EmptyResponse.self, let e = EmptyResponse() as? T { completion(.success(e)); return } else { completion(.failure(APIError.noData)); return } } // Handle No Content (204) again jic
//            
//            do { let o = try JSONDecoder().decode(T.self, from: d); completion(.success(o)) } catch let decErr { print("Decode err for \(T.self) from \(url.lastPathComponent): \(decErr)\nData:\(String(data:d,encoding:.utf8) ?? "nil")"); completion(.failure(APIError.decodingError(decErr))) }
//        }.resume()
//    }
//    
//    // Logout (No changes needed)
//    // ... (logout) ...
//    func logout() { DispatchQueue.main.async { self.isLoggedIn = false; self.currentTokens = nil; self.userProfile = nil; self.errorMessage = nil; self.userPlaylists = []; /* clear other states */ self.playlistErrorMessage = nil; self.isLoading = false; self.isLoadingPlaylists = false; self.playlistNextPageUrl = nil; self.clearTokens(); self.currentWebAuthSession?.cancel(); self.currentWebAuthSession = nil; self.currentPKCEVerifier = nil; print("Logged out.") } }
//    
//    // Error Handling Helpers (No changes needed)
//    // ... (handleError, handlePlaylistError, extractErrorDetails) ...
//    private func handleError(_ message: String) { DispatchQueue.main.async { self.errorMessage = message }; print("AuthMgr Error: \(message)") }
//    private func handlePlaylistError(_ message: String) { DispatchQueue.main.async { self.playlistErrorMessage = message }; print("AuthMgr Playlist Error: \(message)") }
//    private func extractErrorDetails(from data: Data?, statusCode: Int) -> String { guard let d=data, !d.isEmpty else{ return "Status \(statusCode) (No details)" }; if let se = try? JSONDecoder().decode(SpotifyErrorResponse.self, from: d) { return se.error.message ?? "Status \(statusCode) (Spotify Error)" }; if let j = try? JSONSerialization.jsonObject(with: d, options: []) as? [String: Any], let ed = j["error_description"] as? String ?? j["error"] as? String { return "\(ed) (Status \(statusCode))" }; if let t = String(data: d, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines), !t.isEmpty { return "\(t) (Status \(statusCode))" }; return "Status \(statusCode)" }
//}
//
//// MARK: - ASWebAuthenticationPresentationContextProviding (No changes needed)
//extension SpotifyAuthManager: ASWebAuthenticationPresentationContextProviding {
//    func isEqual(_ object: Any?) -> Bool {
//        <#code#>
//    }
//    
//    var hash: Int {
//        <#code#>
//    }
//    
//    var superclass: AnyClass? {
//        <#code#>
//    }
//    
//    func `self`() -> Self {
//        <#code#>
//    }
//    
//    func perform(_ aSelector: Selector!) -> Unmanaged<AnyObject>! {
//        <#code#>
//    }
//    
//    func perform(_ aSelector: Selector!, with object: Any!) -> Unmanaged<AnyObject>! {
//        <#code#>
//    }
//    
//    func perform(_ aSelector: Selector!, with object1: Any!, with object2: Any!) -> Unmanaged<AnyObject>! {
//        <#code#>
//    }
//    
//    func isProxy() -> Bool {
//        <#code#>
//    }
//    
//    func isKind(of aClass: AnyClass) -> Bool {
//        <#code#>
//    }
//    
//    func isMember(of aClass: AnyClass) -> Bool {
//        <#code#>
//    }
//    
//    func conforms(to aProtocol: Protocol) -> Bool {
//        <#code#>
//    }
//    
//    func responds(to aSelector: Selector!) -> Bool {
//        <#code#>
//    }
//    
//    var description: String {
//        <#code#>
//    }
//    
//    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
//        UIApplication.shared.connectedScenes.filter{$0.activationState == .foregroundActive}.compactMap{$0 as? UIWindowScene}.first?.windows.filter{$0.isKeyWindow}.first ?? ASPresentationAnchor()
//    }
//}
//
//// MARK: - PKCE Helper Extension (No changes needed)
//extension Data { func base64URLEncodedString() -> String { self.base64EncodedString().replacingOccurrences(of: "+", with: "-").replacingOccurrences(of: "/", with: "_").replacingOccurrences(of: "=", with: "") } }
//
//// MARK: - UI Components (Re-introduced and Adapted)
//
//// MARK: SpotifyEmbedWebView (From previous example - Essential for player)
//struct SpotifyEmbedWebView: UIViewRepresentable {
//    let spotifyUri: String // Expects Spotify URI e.g., "spotify:track:123"
//    
//    func makeUIView(context: Context) -> WKWebView {
//        let prefs = WKWebpagePreferences()
//        prefs.allowsContentJavaScript = true // Essential for the embed player
//        let config = WKWebViewConfiguration()
//        config.defaultWebpagePreferences = prefs
//        config.allowsInlineMediaPlayback = true // Allow playback within the view
//        
//        let webView = WKWebView(frame: .zero, configuration: config)
//        webView.isOpaque = false
//        webView.backgroundColor = .clear
//        webView.scrollView.isScrollEnabled = false // Disable scrolling within the embed itself
//        webView.navigationDelegate = context.coordinator // Assign delegate
//        
//        // Initial load
//        loadContent(in: webView)
//        return webView
//    }
//    
//    func updateUIView(_ webView: WKWebView, context: Context) {
//        // Handle URI changes if necessary (less common for a detail view)
//        // Compare context.coordinator.lastLoadedUri with spotifyUri and reload if different
//        if context.coordinator.lastLoadedUri != spotifyUri {
//            print("Spotify URI changed in WebView. Reloading...")
//            loadContent(in: webView)
//            context.coordinator.lastLoadedUri = spotifyUri
//        }
//    }
//    
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//    
//    private func loadContent(in webView: WKWebView) {
//        let html = generateHTML(uri: spotifyUri)
//        webView.loadHTMLString(html, baseURL: URL(string: "https://open.spotify.com")) // Set base URL for origin policies
//    }
//    
//    // Helper to extract type (track, episode, album, etc.) and ID from Spotify URI
//    private func parseSpotifyUri(_ uri: String) -> (type: String, id: String)? {
//        let components = uri.split(separator: ":")
//        guard components.count == 3, components[0] == "spotify" else {
//            print("Invalid Spotify URI format: \(uri)")
//            return nil
//        }
//        return (type: String(components[1]), id: String(components[2]))
//    }
//    
//    private func generateHTML(uri: String) -> String {
//        guard let parsed = parseSpotifyUri(uri) else {
//            // Return fallback HTML or an error message
//            return """
//            <html><body>Invalid Spotify URI provided.</body></html>
//            """
//        }
//        
//        return """
//        <!DOCTYPE html>
//        <html lang="en">
//        <head>
//          <meta charset="UTF-8">
//          <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
//          <style>
//            body, html { margin: 0; padding: 0; overflow: hidden; background-color: transparent; }
//            iframe { display: block; /* Removes bottom space */ width: 100%; height: 100%; border: none; }
//          </style>
//        </head>
//        <body>
//          <iframe
//            title="Spotify Embed Player"
//            id="spotify-embed-\(parsed.id)"
//            src="https://open.spotify.com/embed/\(parsed.type)/\(parsed.id)?utm_source=generator&theme=0"
//            allow="autoplay; clipboard-write; encrypted-media; fullscreen; picture-in-picture"
//            loading="lazy">
//          </iframe>
//        </body>
//        </html>
//        """
//        // Theme=0 for dark, Theme=1 for light
//        // Added more allow attributes based on Spotify's current recommendations
//    }
//    
//    // Coordinator to handle navigation delegate methods if needed (optional for basic embed)
//    class Coordinator: NSObject, WKNavigationDelegate {
//        var parent: SpotifyEmbedWebView
//        var lastLoadedUri: String? // To track updates
//        
//        init(_ parent: SpotifyEmbedWebView) {
//            self.parent = parent
//            self.lastLoadedUri = parent.spotifyUri
//        }
//        
//        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//            print("Spotify Embed WebView finished loading content for: \(parent.spotifyUri)")
//            // Potential JavaScript injection here if needed
//        }
//        
//        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
//            print("Spotify Embed WebView failed to load: \(error.localizedDescription)")
//        }
//        
//        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
//            print("Spotify Embed WebView failed provisional navigation: \(error.localizedDescription)")
//        }
//    }
//}
//
//// MARK: TrackDetailsView (Adapted to fetch data based on trackID)
//struct TrackDetailsView: View {
//    let trackID: String // Input: Just the ID (e.g., "abcdef12345")
//    let trackNameInitial: String // Pass initial name for title while loading
//    
//    @EnvironmentObject var authManager: SpotifyAuthManager // Get access to the auth manager
//    @State private var trackDetails: TrackDetails? = nil // State for fetched details
//    @State private var isLoading: Bool = false
//    @State private var errorMessage: String? = nil
//    
//    var spotifyUri: String { "spotify:track:\(trackID)" } // Construct the URI
//    
//    var body: some View {
//        ScrollView {
//            VStack(alignment: .leading, spacing: 16) { // Added spacing
//                if isLoading {
//                    ProgressView("Loading Track Details...")
//                        .frame(maxWidth: .infinity)
//                        .padding(.vertical, 50)
//                } else if let error = errorMessage {
//                    Text("Error: \(error)")
//                        .foregroundColor(.red)
//                        .frame(maxWidth: .infinity)
//                        .padding()
//                } else if let details = trackDetails {
//                    // --- Embed Player ---
//                    VStack { // Center the embed
//                        SpotifyEmbedWebView(spotifyUri: details.id) // Use the URI from fetched details
//                            .frame(height: 90) // Standard compact height
//                            .cornerRadius(8)
//                            .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
//                    }
//                    .padding(.horizontal) // Give it some horizontal space
//                    
//                    // --- Track Info ---
//                    VStack(alignment: .leading, spacing: 6) {
//                        Text(details.title)
//                            .font(.title2)
//                            .fontWeight(.bold)
//                        
//                        Text(details.artistName)
//                            .font(.title3)
//                            .foregroundColor(.secondary)
//                        
//                        if let album = details.albumTitle {
//                            Text("Album: \(album)")
//                                .font(.headline)
//                                .foregroundColor(.accentColor)
//                                .padding(.top, 4)
//                        }
//                        
//                        HStack {
//                            Label(details.formattedDuration, systemImage: "clock")
//                            Spacer()
//                            // Add other info if available (release date etc.)
//                        }
//                        .font(.subheadline)
//                        .foregroundColor(.secondary)
//                        .padding(.top, 4)
//                        
//                        // --- Action Buttons ---
//                        HStack {
//                            if let url = details.webLink {
//                                Link(destination: url) {
//                                    Label("Open in Spotify", systemImage: "arrow.up.forward.app.fill")
//                                }
//                                .buttonStyle(.bordered)
//                            }
//                            if let url = details.webLink { // Use same URL for ShareLink
//                                ShareLink(item: url) {
//                                    Label("Share", systemImage: "square.and.arrow.up")
//                                }
//                                .buttonStyle(.bordered)
//                                .labelStyle(.iconOnly) // Only show icon if needed
//                            }
//                            Spacer()
//                        }
//                        .padding(.top, 10)
//                        
//                    }
//                    .padding(.horizontal)
//                    
//                    // --- Artwork (Optional) ---
//                    if let artworkURL = details.artworkURL {
//                        AsyncImage(url: artworkURL) { phase in
//                            switch phase {
//                            case .success(let image):
//                                image.resizable()
//                                    .aspectRatio(contentMode: .fit)
//                                    .cornerRadius(8)
//                                    .shadow(radius: 3)
//                            case .failure:
//                                Image(systemName: "photo") // Placeholder
//                                    .resizable().scaledToFit().foregroundColor(.gray)
//                            default:
//                                ProgressView().frame(height: 200) // Loading placeholder
//                            }
//                        }
//                        .padding()
//                    }
//                    
//                } else {
//                    // Should ideally not be reached if loading/error handled
//                    Text("Track details not available.")
//                        .foregroundColor(.secondary)
//                        .padding()
//                        .frame(maxWidth: .infinity)
//                }
//            }
//            .padding(.vertical) // Add padding top/bottom
//        }
//        .navigationTitle(trackDetails?.title ?? trackNameInitial) // Show initial name while loading
//        .navigationBarTitleDisplayMode(.inline)
//        .task { // Use .task for async operations in SwiftUI views
//            await loadTrackDetails()
//        }
//        // Or use .onAppear { Task { await loadTrackDetails() } } for older iOS versions
//    }
//    
//    private func loadTrackDetails() async {
//        guard trackDetails == nil else { return } // Don't reload if already loaded
//        
//        errorMessage = nil
//        isLoading = true
//        do {
//            let details = try await authManager.fetchTrackDetails(trackId: trackID)
//            // Update state on the main thread
//            await MainActor.run {
//                self.trackDetails = details
//                self.isLoading = false
//            }
//        } catch {
//            // Update state on the main thread
//            await MainActor.run {
//                self.errorMessage = error.localizedDescription
//                self.isLoading = false
//            }
//        }
//    }
//}
//
//// --- PlaylistTracksView (NEW) ---
//struct PlaylistTracksView: View {
//    let playlistId: String
//    let playlistName: String
//    
//    @EnvironmentObject var authManager: SpotifyAuthManager
//    @State private var tracks: [PlaylistTrackItem] = []
//    @State private var isLoading: Bool = false
//    @State private var errorMessage: String? = nil
//    @State private var nextPageUrl: String? = nil // Track pagination specific to this view
//    
//    var body: some View {
//        List {
//            if isLoading && tracks.isEmpty {
//                ProgressView("Loading Tracks...")
//                    .frame(maxWidth: .infinity)
//            } else if let error = errorMessage {
//                Text("Error loading tracks: \(error)")
//                    .foregroundColor(.red)
//            } else if tracks.isEmpty {
//                Text("This playlist is empty.")
//                    .foregroundColor(.secondary)
//            } else {
//                ForEach(tracks) { item in
//                    // Ensure we only show valid tracks with IDs
//                    if let track = item.track, !track.id.isEmpty {
//                        NavigationLink {
//                            // Pass ONLY the track ID and maybe initial name
//                            TrackDetailsView(trackID: track.id, trackNameInitial: track.name)
//                                .environmentObject(authManager) // Pass manager down
//                        } label: {
//                            TrackRow(track: track) // Extracted row view
//                        }
//                        .disabled(item.isLocal || track.isPlayable == false) // Disable local/unplayable tracks
//                        .opacity(item.isLocal || track.isPlayable == false ? 0.5 : 1.0)
//                        .onAppear {
//                            // Load next page when last item appears
//                            if item.id == tracks.last?.id && nextPageUrl != nil && !isLoading {
//                                Task { await loadTracks(loadNextPage: true) }
//                            }
//                        }
//                    } else if item.isLocal {
//                        Text("Local Track (Unavailable)")
//                            .foregroundColor(.secondary).opacity(0.5)
//                    }
//                } // End ForEach
//                
//                // Loading indicator at the bottom for pagination
//                if isLoading && !tracks.isEmpty {
//                    ProgressView().frame(maxWidth: .infinity).padding(.vertical)
//                }
//            }
//        }
//        .navigationTitle(playlistName)
//        .task { // Fetch initial tracks when the view appears
//            await loadTracks(loadNextPage: false)
//        }
//        .refreshable { // Allow pull-to-refresh
//            await loadTracks(loadNextPage: false)
//        }
//    }
//    
//    // Function to load tracks (initial or next page)
//    private func loadTracks(loadNextPage: Bool) async {
//        guard !isLoading else { return } // Prevent simultaneous loads
//        
//        isLoading = true
//        if !loadNextPage { // Clear error only when loading first page
//            errorMessage = nil
//        }
//        
//        do {
//            // Pass the currently loaded tracks if paging
//            let currentItems = loadNextPage ? self.tracks : []
//            let result = try await authManager.fetchPlaylistTracks(
//                playlistId: playlistId,
//                loadNextPage: loadNextPage,
//                currentTracks: currentItems // <-- Pass current items
//            )
//            // Update state on the main thread
//            await MainActor.run {
//                self.tracks = result.items // Update with combined/new tracks
//                self.nextPageUrl = result.nextUrl // Update pagination URL
//                self.isLoading = false
//            }
//        } catch {
//            // Update state on the main thread
//            await MainActor.run {
//                self.errorMessage = error.localizedDescription
//                self.isLoading = false
//                // Don't clear existing tracks on error
//            }
//        }
//    }
//    
//}
//
//// Extracted row view for playlist tracks
//struct TrackRow: View {
//    let track: SimplifiedTrackObject
//    
//    var body: some View {
//        HStack {
//            VStack(alignment: .leading, spacing: 3) {
//                Text(track.name)
//                    .fontWeight(.medium)
//                    .lineLimit(1)
//                Text(track.artistNames)
//                    .font(.caption)
//                    .foregroundColor(.gray)
//                    .lineLimit(1)
//            }
//            Spacer()
//            Text(formattedDuration(track.durationMs))
//                .font(.caption)
//                .foregroundColor(.secondary)
//        }
//        .padding(.vertical, 4)
//    }
//    
//    private func formattedDuration(_ ms: Int) -> String {
//        let totalSeconds = ms / 1000
//        let minutes = totalSeconds / 60
//        let seconds = totalSeconds % 60
//        return String(format: "%d:%02d", minutes, seconds)
//    }
//}
//
//// MARK: - Main SwiftUI Views (AuthenticationFlowView and related components)
//
//struct AuthenticationFlowView: View {
//    @StateObject var authManager = SpotifyAuthManager() // Create instance here
//    
//    var body: some View {
//        NavigationView {
//            Group {
//                if !authManager.isLoggedIn {
//                    loggedOutView
//                    // No navigation title needed for the base login view in NavigationView
//                } else {
//                    loggedInContentView
//                        .navigationTitle("Your Spotify") // Title for the logged-in view
//                        .navigationBarTitleDisplayMode(.inline)
//                }
//            }
//            .overlay { // Loading overlay
//                if authManager.isLoading {
//                    ProgressView("Loading...").padding().background(.regularMaterial).cornerRadius(10)
//                }
//            }
//            .alert("Error", isPresented: Binding(get: { authManager.errorMessage != nil }, set: { if !$0 { authManager.errorMessage = nil } }), presenting: authManager.errorMessage) { _ in Button("OK") { authManager.errorMessage = nil } } message: { msg in Text(msg) }
//        }
//        .environmentObject(authManager) // Make authManager available to child views like PlaylistTracksView and TrackDetailsView
//    }
//    
//    // MARK: Logged Out View (Simplified for brevity - same as previous)
//    private var loggedOutView: some View {
//        VStack(spacing: 25) {
//            Spacer()
//            Image(systemName: "music.note.house.fill").resizable().scaledToFit().frame(width: 80, height: 80).foregroundColor(Color(red: 30/255, green: 215/255, blue: 96/255))
//            Text("Connect your Spotify account.").font(.headline).multilineTextAlignment(.center).padding(.horizontal)
//            Button { authManager.initiateAuthorization() } label: { HStack { Image(systemName: "lock.open.fill").foregroundColor(.white); Text("Log in with Spotify").fontWeight(.bold).foregroundColor(.white) }.padding(.vertical, 15).padding(.horizontal, 30).background(Color(red: 30/255, green: 215/255, blue: 96/255)).cornerRadius(40).shadow(color: .gray.opacity(0.4), radius: 5, y: 3) }.disabled(authManager.isLoading); Spacer(); Spacer()
//        }.padding()
//    }
//    
//    // MARK: Logged In Content View (Modified for Playlist Navigation)
//    private var loggedInContentView: some View {
//        List {
//            Section(header: Text("Profile")) { profileSection }
//            
//            Section {
//                playlistSection // Modified to use NavigationLink
//            } header: { Text("My Playlists") } footer: {
//                // Footer handles playlist list loading indicator/error
//                if authManager.isLoadingPlaylists {
//                    HStack { Spacer(); ProgressView(); Spacer() }.padding(.vertical, 5)
//                } else if let errorMsg = authManager.playlistErrorMessage {
//                    Text("Error: \(errorMsg)").font(.caption).foregroundColor(.red).frame(maxWidth: .infinity, alignment: .center)
//                }
//            }
//            
//            Section(header: Text("Account Actions")) { actionSection }
//        }
//        .listStyle(.insetGrouped)
//        .refreshable { // Refresh playlists and profile
//            await refreshData()
//        }
//        .onAppear { // Initial data load if needed
//            if authManager.userProfile == nil && authManager.isLoggedIn && !authManager.isLoading {
//                Task { await authManager.fetchUserProfile() }
//            }
//            if authManager.userPlaylists.isEmpty && authManager.isLoggedIn && !authManager.isLoadingPlaylists {
//                Task { await authManager.fetchUserPlaylists() }
//            }
//        }
//    }
//    
//    // Async func for refreshable
//    private func refreshData() async {
//        // Create tasks for concurrent fetching
//        async let profileTask: () = authManager.fetchUserProfile()
//        async let playlistsTask: () = authManager.fetchUserPlaylists(loadNextPage: false)
//        // Await both tasks to complete
//        _ = await [profileTask, playlistsTask]
//        print("Pull-to-refresh complete.")
//    }
//    
//    // MARK: Profile Section (No changes needed)
//    @ViewBuilder private var profileSection: some View { if let p = authManager.userProfile { HStack(spacing: 15) { AsyncImage(url: URL(string: p.images?.first?.url ?? "")) { $0.resizable().aspectRatio(contentMode: .fill).frame(width: 60, height: 60).clipShape(Circle()).overlay(Circle().stroke(.gray.opacity(0.3), lineWidth: 1)) } placeholder: { Image(systemName: "person.circle.fill").resizable().aspectRatio(contentMode: .fit).frame(width: 60, height: 60).foregroundColor(.secondary) }; VStack(alignment: .leading) { Text(p.displayName).font(.headline); Text(p.email).font(.subheadline).foregroundColor(.gray).lineLimit(1) } }.padding(.vertical, 8) } else if authManager.isLoading { HStack { Spacer(); ProgressView(); Spacer() }.padding(.vertical) } else { Text("Could not load profile.").foregroundColor(.secondary) } }
//    
//    // MARK: Playlist Section (Modified for Navigation)
//    @ViewBuilder
//    private var playlistSection: some View {
//        // Show empty state if applicable
//        if authManager.userPlaylists.isEmpty && !authManager.isLoadingPlaylists && authManager.playlistErrorMessage == nil {
//            Text("No playlists found.")
//                .foregroundColor(.secondary)
//                .frame(maxWidth: .infinity, alignment: .center)
//                .padding()
//        } else {
//            ForEach(authManager.userPlaylists) { playlist in
//                // Wrap the row content in NavigationLink
//                NavigationLink {
//                    // Destination: The view showing tracks *within* this playlist
//                    PlaylistTracksView(playlistId: playlist.id, playlistName: playlist.name)
//                    // EnvironmentObject is already passed from the parent NavigationView
//                } label: {
//                    // The visual content of the playlist row
//                    HStack {
//                        // Artwork Placeholder
//                        AsyncImage(url: URL(string: playlist.images?.first?.url ?? "")) { image in
//                            image.resizable().aspectRatio(contentMode: .fill).frame(width: 50, height: 50).cornerRadius(4)
//                        } placeholder: {
//                            ZStack { Rectangle().fill(.secondary.opacity(0.1)).frame(width: 50, height: 50).cornerRadius(4); Image(systemName: "music.note.list").resizable().scaledToFit().frame(width: 25, height: 25).foregroundStyle(.secondary) }
//                        }
//                        // Text Info
//                        VStack(alignment: .leading, spacing: 3) {
//                            Text(playlist.name).fontWeight(.medium).lineLimit(1)
//                            Text("By \(playlist.owner.displayName ?? "Spotify") • \(playlist.tracks.total) track\(playlist.tracks.total == 1 ? "" : "s")")
//                                .font(.caption).foregroundColor(.gray).lineLimit(1)
//                        }
//                        Spacer() // Push collab icon
//                        // Collab Icon
//                        if playlist.collaborative {
//                            Image(systemName: "person.2.fill").foregroundColor(.blue).imageScale(.small)
//                        }
//                    }
//                    .padding(.vertical, 4)
//                } // End Label
//                .onAppear {
//                    // Load next page of *playlists* when the last playlist appears
//                    if playlist.id == authManager.userPlaylists.last?.id && authManager.canLoadMorePlaylists && !authManager.isLoadingPlaylists {
//                        print("Reached end of playlist list, loading next playlist page...")
//                        Task { authManager.fetchUserPlaylists(loadNextPage: true) }
//                    }
//                }
//            } // End ForEach
//        }
//    }
//    private var actionSection: some View { EmptyView() }
//    
//    
//    // MARK: Action Section (Simplified for brevity - same as previous)
//    //    private var actionSection: some View { Group { Button("Force Refresh Token") { authManager.refreshToken() }.disabled(authManager.currentTokens?.refreshToken == nil || authManager.isLoading).tint(.orange); Button("Log Out", role: .destructive) { authManager.logout() }; #if DEBUG if let t=authManager.currentTokens { DisclosureGroup("Token Details (Debug)") { VStack(alignment: .leading, spacing: 4) { Text("Access Token:").font(.caption.bold); Text(t.accessToken).font(.caption).lineLimit(2).truncationMode(.middle); if let e=t.expiryDate{ Text("Expires:").font(.caption.bold) + Text(" \(e, style: .relative) (\(e.formatted(date: .omitted, time: .shortened)))").font(.caption).foregroundColor(e <= Date() ? .red : .green) } else { Text("Expiry Date: Not Set").font(.caption) }; Text("Refresh Token Present: \(t.refreshToken != nil ? "Yes" : "No")").font(.caption).foregroundColor(t.refreshToken != nil ? .primary : .orange) }.padding(.top, 5) }.font(.callout) } #endif } }
//    //
//    //    } // End AuthenticationFlowView
//    
//  
//}
//
//// MARK: - App Entry Point
////@main
////struct SpotifyPlayerAuthDemoApp: App {
////    var body: some Scene {
////        WindowGroup {
////            AuthenticationFlowView() // Start with the main view
////        }
////    }
////}
