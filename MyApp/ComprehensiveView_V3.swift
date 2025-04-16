////
////  ComprehensiveView_V3.swift
////  MyApp
////
////  Created by Cong Le on 4/9/25.
////
//
//import SwiftUI
//import Combine
//import CryptoKit
//import AuthenticationServices
//
//// MARK: - Configuration (MUST REPLACE)
//struct SpotifyConstants {
//    static let clientID = "YOUR_SPOTIFY_CLIENT_ID" // REPLACE
//    static let redirectURI = "YOUR_APP_CALLBACK_SCHEME://callback" // REPLACE (e.g., "myapp://callback")
//    static let scopes = [
//        "user-read-private",
//        "user-read-email",
//        "playlist-read-private",
//        "playlist-read-collaborative",
//        "playlist-modify-public",
//        "playlist-modify-private",
//        "user-library-read",
//        "user-top-read"
//    ]
//    static let scopeString = scopes.joined(separator: " ")
//    static let authorizationEndpoint = URL(string: "https://accounts.spotify.com/authorize")!
//    static let tokenEndpoint = URL(string: "https://accounts.spotify.com/api/token")!
//    static let userProfileEndpoint = URL(string: "https://api.spotify.com/v1/me")!
//    static let userPlaylistsEndpoint = URL(string: "https://api.spotify.com/v1/me/playlists")!
//    static let playlistBaseEndpoint = "https://api.spotify.com/v1/playlists/"
//    static let tokenUserDefaultsKey = "spotifyTokens_secure"
//}
//
//// MARK: - Data Models
//
//struct TokenResponse: Codable {
//    let accessToken: String
//    let tokenType: String
//    let expiresIn: Int
//    let refreshToken: String?
//    let scope: String
//
//    var expiryDate: Date? {
//        Calendar.current.date(byAdding: .second, value: expiresIn, to: Date())
//    }
//
//    enum CodingKeys: String, CodingKey {
//        case accessToken = "access_token"
//        case tokenType   = "token_type"
//        case expiresIn   = "expires_in"
//        case refreshToken = "refresh_token"
//        case scope
//    }
//}
//
//struct StoredTokens: Codable {
//    let accessToken: String
//    let refreshToken: String?
//    let expiryDate: Date?
//}
//
//struct SpotifyUserProfile: Codable, Identifiable {
//    let id: String
//    let displayName: String
//    let email: String
//    let images: [SpotifyImage]?
//    let externalUrls: [String: String]?
//
//    enum CodingKeys: String, CodingKey {
//        case id
//        case displayName = "display_name"
//        case email, images
//        case externalUrls = "external_urls"
//    }
//}
//
//struct SpotifyImage: Codable, Hashable {
//    let url: String
//    let height: Int?
//    let width: Int?
//    
//    func hash(into hasher: inout Hasher) { hasher.combine(url) }
//    static func == (lhs: SpotifyImage, rhs: SpotifyImage) -> Bool { lhs.url == rhs.url }
//}
//
//// MARK: - Models for Playlists
//
//struct SpotifyPagingObject<T: Codable>: Codable {
//    let href: String
//    let items: [T]
//    let limit: Int
//    let next: String?
//    let offset: Int
//    let previous: String?
//    let total: Int
//}
//
//struct SpotifyPlaylistOwner: Codable, Identifiable, Hashable {
//    let id: String
//    let displayName: String?
//    let externalUrls: [String: String]?
//
//    func hash(into hasher: inout Hasher) { hasher.combine(id) }
//    static func == (lhs: SpotifyPlaylistOwner, rhs: SpotifyPlaylistOwner) -> Bool { lhs.id == rhs.id }
//    
//    enum CodingKeys: String, CodingKey {
//        case id
//        case displayName = "display_name"
//        case externalUrls = "external_urls"
//    }
//}
//
//struct PlaylistTracksInfo: Codable, Hashable {
//    let href: String
//    let total: Int
//
//    func hash(into hasher: inout Hasher) {
//        hasher.combine(total)
//        hasher.combine(href)
//    }
//    static func == (lhs: PlaylistTracksInfo, rhs: PlaylistTracksInfo) -> Bool {
//        lhs.total == rhs.total && lhs.href == rhs.href
//    }
//}
//
//struct SpotifyPlaylist: Codable, Identifiable, Hashable {
//    let id: String
//    let name: String
//    let description: String?
//    let owner: SpotifyPlaylistOwner
//    let collaborative: Bool
//    let tracks: PlaylistTracksInfo
//    let images: [SpotifyImage]?
//    let externalUrls: [String: String]?
//    let publicPlaylist: Bool?
//
//    func hash(into hasher: inout Hasher) { hasher.combine(id) }
//    static func == (lhs: SpotifyPlaylist, rhs: SpotifyPlaylist) -> Bool { lhs.id == rhs.id }
//
//    enum CodingKeys: String, CodingKey {
//        case id, name, description, owner, collaborative, tracks, images
//        case externalUrls = "external_urls"
//        case publicPlaylist = "public"
//    }
//}
//
//typealias SpotifyPlaylistList = SpotifyPagingObject<SpotifyPlaylist>
//
//// MARK: - Models for Playlist Tracks
//
//struct SpotifyArtistSimple: Codable, Identifiable, Hashable {
//    let id: String
//    let name: String
//    let externalUrls: [String: String]?
//    
//    func hash(into hasher: inout Hasher) { hasher.combine(id) }
//    static func == (lhs: SpotifyArtistSimple, rhs: SpotifyArtistSimple) -> Bool { lhs.id == rhs.id }
//    
//    enum CodingKeys: String, CodingKey {
//        case id, name
//        case externalUrls = "external_urls"
//    }
//}
//
//struct SpotifyAlbumSimple: Codable, Identifiable, Hashable {
//    let id: String
//    let name: String
//    let images: [SpotifyImage]?
//    let externalUrls: [String: String]?
//
//    func hash(into hasher: inout Hasher) { hasher.combine(id) }
//    static func == (lhs: SpotifyAlbumSimple, rhs: SpotifyAlbumSimple) -> Bool { lhs.id == rhs.id }
//    
//    enum CodingKeys: String, CodingKey {
//        case id, name, images
//        case externalUrls = "external_urls"
//    }
//}
//
//struct SpotifyTrack: Codable, Identifiable, Hashable {
//    let id: String
//    let name: String
//    let artists: [SpotifyArtistSimple]
//    let album: SpotifyAlbumSimple
//    let durationMs: Int
//    let trackNumber: Int?
//    let discNumber: Int?
//    let explicit: Bool?
//    let externalUrls: [String: String]?
//    let uri: String
//    let isPlayable: Bool?
//
//    var formattedDuration: String {
//        let totalSeconds = durationMs / 1000
//        let minutes = totalSeconds / 60
//        let seconds = totalSeconds % 60
//        return String(format: "%d:%02d", minutes, seconds)
//    }
//    
//    var artistNames: String {
//        artists.map { $0.name }.joined(separator: ", ")
//    }
//    
//    func hash(into hasher: inout Hasher) { hasher.combine(id) }
//    static func == (lhs: SpotifyTrack, rhs: SpotifyTrack) -> Bool { lhs.id == rhs.id }
//
//    enum CodingKeys: String, CodingKey {
//        case id, name, artists, album, uri, explicit
//        case durationMs = "duration_ms"
//        case trackNumber = "track_number"
//        case discNumber = "disc_number"
//        case externalUrls = "external_urls"
//        case isPlayable = "is_playable"
//    }
//}
//
//struct SpotifyPlaylistTrack: Codable, Identifiable {
//    var id: String { track?.id ?? UUID().uuidString }
//    let addedAt: String?
//    let track: SpotifyTrack?
//
//    enum CodingKeys: String, CodingKey {
//        case track
//        case addedAt = "added_at"
//    }
//}
//
//typealias SpotifyPlaylistTrackList = SpotifyPagingObject<SpotifyPlaylistTrack>
//
//struct SpotifyErrorResponse: Codable {
//    let error: SpotifyErrorDetail
//}
//struct SpotifyErrorDetail: Codable {
//    let status: Int
//    let message: String?
//}
//
//struct EmptyResponse: Codable {}
//
//// MARK: - Custom API Error Enum
//
//enum APIError: Error, LocalizedError {
//    case invalidRequest(message: String)
//    case networkError(Error)
//    case invalidResponse
//    case httpError(statusCode: Int, details: String)
//    case noData
//    case decodingError(Error?)
//    case notLoggedIn
//    case tokenRefreshFailed
//    case authenticationFailed
//    case maxRetriesReached
//    case pkceGenerationFailed
//    case authUrlConstructionFailed
//    case noAuthCodeReceived
//    case spotifyAuthDenied(reason: String)
//    case unknown
//
//    var errorDescription: String? {
//        switch self {
//        case .invalidRequest(let message): return "Invalid request: \(message)"
//        case .networkError(let error): return "Network error: \(error.localizedDescription)"
//        case .invalidResponse: return "Invalid response received from the server."
//        case .httpError(let statusCode, let details): return "Server error \(statusCode): \(details)"
//        case .noData: return "No data received from server."
//        case .decodingError: return "Failed to decode the server response."
//        case .notLoggedIn: return "Action requires login."
//        case .tokenRefreshFailed: return "Could not refresh session token."
//        case .authenticationFailed: return "Authentication failed. Please log in again."
//        case .maxRetriesReached: return "Maximum retry attempts reached."
//        case .pkceGenerationFailed: return "Could not generate security challenge for login."
//        case .authUrlConstructionFailed: return "Could not create the authorization URL."
//        case .noAuthCodeReceived: return "Did not receive authorization code from Spotify."
//        case .spotifyAuthDenied(let reason): return "Spotify denied the login request: \(reason)"
//        case .unknown: return "An unexpected error occurred."
//        }
//    }
//    
//    var isAuthError: Bool {
//        switch self {
//        case .httpError(let statusCode, _):
//            return statusCode == 401 || statusCode == 403
//        case .authenticationFailed, .tokenRefreshFailed, .notLoggedIn:
//            return true
//        default:
//            return false
//        }
//    }
//}
//
//// MARK: - Authentication Manager
//
//class SpotifyAuthManager: ObservableObject {
//    @Published var isLoggedIn: Bool = false
//    @Published var userProfile: SpotifyUserProfile? = nil
//    @Published var isLoading: Bool = false
//    @Published var errorMessage: String? = nil
//
//    @Published var userPlaylists: [SpotifyPlaylist] = []
//    @Published var isLoadingPlaylists: Bool = false
//    @Published var playlistErrorMessage: String? = nil
//    private(set) var playlistNextPageUrl: String? = nil
//
//    @Published var selectedPlaylist: SpotifyPlaylist? = nil
//    @Published var currentPlaylistTracks: [SpotifyPlaylistTrack] = []
//    @Published var isLoadingPlaylistTracks: Bool = false
//    @Published var playlistTracksErrorMessage: String? = nil
//    private(set) var playlistTracksNextPageUrl: String? = nil
//
//    var currentTokens: StoredTokens? = nil
//    private var currentPKCEVerifier: String?
//    private var currentWebAuthSession: ASWebAuthenticationSession?
//
//    init() {
//        loadTokens()
//        if let tokens = currentTokens, let expiry = tokens.expiryDate, expiry > Date() {
//            self.isLoggedIn = true
//            print("Found valid tokens. User is logged in.")
//            fetchUserProfile()
//            fetchUserPlaylists()
//        } else if let tokens = currentTokens, tokens.refreshToken != nil {
//            print("Found expired tokens with refresh token. Attempting refresh...")
//            refreshToken { [weak self] success in
//                DispatchQueue.main.async {
//                    if success {
//                        print("Token refresh successful.")
//                        self?.fetchUserProfile()
//                        self?.fetchUserPlaylists()
//                    } else {
//                        print("Token refresh failed. Logging out.")
//                        self?.logout()
//                    }
//                }
//            }
//        } else {
//            print("No valid tokens found. User is logged out.")
//            self.isLoggedIn = false
//        }
//    }
//
//    // MARK: - PKCE Helpers
//
//    private func generateCodeVerifier() -> String {
//        var buffer = [UInt8](repeating: 0, count: 32)
//        _ = SecRandomCopyBytes(kSecRandomDefault, buffer.count, &buffer)
//        return Data(buffer).base64URLEncodedString()
//    }
//
//    private func generateCodeChallenge(from verifier: String) -> String? {
//        guard let data = verifier.data(using: .utf8) else { return nil }
//        let digest = SHA256.hash(data: data)
//        return Data(digest).base64URLEncodedString()
//    }
//
//    // MARK: - Authentication Flow
//
//    func initiateAuthorization() {
//        guard !isLoading else { return }
//        prepareForNewAuth()
//        
//        let verifier = generateCodeVerifier()
//        guard let challenge = generateCodeChallenge(from: verifier) else {
//            handleError(APIError.pkceGenerationFailed)
//            return
//        }
//        currentPKCEVerifier = verifier
//
//        var components = URLComponents(url: SpotifyConstants.authorizationEndpoint, resolvingAgainstBaseURL: true)
//        components?.queryItems = [
//            URLQueryItem(name: "client_id", value: SpotifyConstants.clientID),
//            URLQueryItem(name: "response_type", value: "code"),
//            URLQueryItem(name: "redirect_uri", value: SpotifyConstants.redirectURI),
//            URLQueryItem(name: "scope", value: SpotifyConstants.scopeString),
//            URLQueryItem(name: "code_challenge_method", value: "S256"),
//            URLQueryItem(name: "code_challenge", value: challenge)
//        ]
//        
//        guard let authURL = components?.url else {
//            handleError(APIError.authUrlConstructionFailed)
//            return
//        }
//        
//        let scheme = URL(string: SpotifyConstants.redirectURI)?.scheme
//        
//        currentWebAuthSession = ASWebAuthenticationSession(url: authURL, callbackURLScheme: scheme) { [weak self] callbackURL, error in
//            DispatchQueue.main.async {
//                self?.handleAuthCallback(callbackURL: callbackURL, error: error)
//            }
//        }
//        currentWebAuthSession?.presentationContextProvider = self
//        currentWebAuthSession?.prefersEphemeralWebBrowserSession = true
//        
//        DispatchQueue.main.async {
//            self.isLoading = true
//            self.currentWebAuthSession?.start()
//        }
//    }
//
//    private func prepareForNewAuth() {
//        errorMessage = nil
//        userProfile = nil
//        userPlaylists = []
//        playlistErrorMessage = nil
//        playlistNextPageUrl = nil
//        playlistTracksErrorMessage = nil
//        playlistTracksNextPageUrl = nil
//        currentPlaylistTracks = []
//        selectedPlaylist = nil
//    }
//
//    private func handleAuthCallback(callbackURL: URL?, error: Error?) {
//        isLoading = false
//        if let error = error {
//            if (error as NSError).code == ASWebAuthenticationSessionError.canceledLogin.rawValue {
//                print("Auth cancelled by user.")
//                self.errorMessage = "Login cancelled."
//            } else {
//                handleError(APIError.networkError(error))
//            }
//            return
//        }
//        
//        guard let successURL = callbackURL,
//              let queryItems = URLComponents(string: successURL.absoluteString)?.queryItems else {
//            handleError(APIError.noAuthCodeReceived)
//            return
//        }
//        
//        if let code = queryItems.first(where: { $0.name == "code" })?.value {
//            print("Received authorization code.")
//            exchangeCodeForToken(code: code)
//        } else if let spotifyError = queryItems.first(where: { $0.name == "error" })?.value {
//            print("Spotify error in callback: \(spotifyError)")
//            handleError(APIError.spotifyAuthDenied(reason: spotifyError))
//        } else {
//            handleError(APIError.noAuthCodeReceived)
//        }
//    }
//
//    private func exchangeCodeForToken(code: String) {
//        guard let verifier = currentPKCEVerifier else {
//            handleError(APIError.invalidRequest(message: "Missing PKCE verifier."), clearVerifier: true)
//            return
//        }
//        guard !isLoading else { return }
//        isLoading = true
//        errorMessage = nil
//        
//        makeTokenRequest(grantType: "authorization_code", code: code, verifier: verifier) { [weak self] result in
//            DispatchQueue.main.async {
//                self?.isLoading = false
//                self?.currentPKCEVerifier = nil
//                switch result {
//                case .success(let tokenResponse):
//                    print("Exchanged code for tokens.")
//                    self?.processSuccessfulTokenResponse(tokenResponse)
//                    self?.fetchUserProfile()
//                    self?.fetchUserPlaylists()
//                case .failure(let error):
//                    self?.handleError(error, prefix: "Failed to get tokens:")
//                }
//            }
//        }
//    }
//
//    // MARK: - Token Refresh
//
//    func refreshToken(completion: ((_ success: Bool) -> Void)? = nil) {
//        guard !isLoading else { completion?(false); return }
//        guard let refreshToken = currentTokens?.refreshToken else {
//            print("No refresh token available. Forcing logout.")
//            logout()
//            completion?(false)
//            return
//        }
//        
//        isLoading = true
//        errorMessage = nil
//        
//        makeTokenRequest(grantType: "refresh_token", refreshToken: refreshToken) { [weak self] result in
//            DispatchQueue.main.async {
//                self?.isLoading = false
//                switch result {
//                case .success(let tokenResponse):
//                    print("Successfully refreshed tokens.")
//                    let updatedRefreshToken = tokenResponse.refreshToken ?? self?.currentTokens?.refreshToken
//                    self?.processSuccessfulTokenResponse(tokenResponse, explicitRefreshToken: updatedRefreshToken)
//                    completion?(true)
//                case .failure(let error):
//                    print("Token Refresh Error: \(error.localizedDescription)")
//                    self?.handleError(error, prefix: "Session refresh failed:")
//                    if let apiError = error as? APIError, apiError.isAuthError {
//                        self?.logout()
//                    }
//                    completion?(false)
//                }
//            }
//        }
//    }
//
//    // MARK: - Centralized Token Request
//    private func makeTokenRequest(
//        grantType: String,
//        code: String? = nil,
//        verifier: String? = nil,
//        refreshToken: String? = nil,
//        completion: @escaping (Result<TokenResponse, Error>) -> Void
//    ) {
//        var request = URLRequest(url: SpotifyConstants.tokenEndpoint)
//        request.httpMethod = "POST"
//        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
//        
//        var components = URLComponents()
//        var queryItems = [
//            URLQueryItem(name: "client_id", value: SpotifyConstants.clientID),
//            URLQueryItem(name: "grant_type", value: grantType)
//        ]
//        
//        if grantType == "authorization_code", let code = code, let verifier = verifier {
//            queryItems.append(contentsOf: [
//                URLQueryItem(name: "code", value: code),
//                URLQueryItem(name: "redirect_uri", value: SpotifyConstants.redirectURI),
//                URLQueryItem(name: "code_verifier", value: verifier)
//            ])
//        } else if grantType == "refresh_token", let refreshToken = refreshToken {
//            queryItems.append(URLQueryItem(name: "refresh_token", value: refreshToken))
//        } else {
//            completion(.failure(APIError.invalidRequest(message: "Invalid parameters for grant type '\(grantType)'.")))
//            return
//        }
//        
//        components.queryItems = queryItems
//        request.httpBody = components.percentEncodedQuery?.data(using: .utf8)
//        
//        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
//            if let error = error {
//                completion(.failure(APIError.networkError(error)))
//                return
//            }
//            guard let httpResponse = response as? HTTPURLResponse else {
//                completion(.failure(APIError.invalidResponse))
//                return
//            }
//            if !(200...299).contains(httpResponse.statusCode) {
//                let errorDetails = self?.extractErrorDetails(from: data, statusCode: httpResponse.statusCode) ?? "Unknown error"
//                completion(.failure(APIError.httpError(statusCode: httpResponse.statusCode, details: errorDetails)))
//                return
//            }
//            guard let data = data else {
//                if httpResponse.statusCode == 204 && TokenResponse.self == EmptyResponse.self {
//                    if let empty = EmptyResponse() as? TokenResponse {
//                        completion(.success(empty))
//                    } else {
//                        completion(.failure(APIError.decodingError(nil)))
//                    }
//                } else {
//                    completion(.failure(APIError.noData))
//                }
//                return
//            }
//            do {
//                let decodedObject = try JSONDecoder().decode(TokenResponse.self, from: data)
//                completion(.success(decodedObject))
//            } catch {
//                print("Decoding Error: \(error)")
//                print("Raw data: \(String(data: data, encoding: .utf8) ?? "Unable to decode data")")
//                completion(.failure(APIError.decodingError(error)))
//            }
//        }.resume()
//    }
//
//    private func processSuccessfulTokenResponse(_ tokenResponse: TokenResponse, explicitRefreshToken: String? = nil) {
//        let refreshTokenToStore = explicitRefreshToken ?? tokenResponse.refreshToken
//        let newStoredTokens = StoredTokens(
//            accessToken: tokenResponse.accessToken,
//            refreshToken: refreshTokenToStore,
//            expiryDate: tokenResponse.expiryDate
//        )
//        self.currentTokens = newStoredTokens
//        self.saveTokens(tokens: newStoredTokens)
//        self.isLoggedIn = true
//        self.errorMessage = nil
//    }
//
//    // MARK: - Fetch User Data
//
//    func fetchUserProfile() {
//        guard isLoggedIn else { return }
//        makeAPIRequest(
//            url: SpotifyConstants.userProfileEndpoint,
//            responseType: SpotifyUserProfile.self
//        ) { [weak self] result in
//            DispatchQueue.main.async {
//                switch result {
//                case .success(let profile):
//                    self?.userProfile = profile
//                    self?.errorMessage = nil
//                    print("Successfully fetched profile for \(profile.displayName)")
//                case .failure(let error):
//                    self?.handleError(error, prefix: "Could not fetch profile:")
//                }
//            }
//        }
//    }
//
//    func fetchUserPlaylists(loadNextPage: Bool = false) {
//        guard !isLoadingPlaylists else { return }
//        guard isLoggedIn, currentTokens?.accessToken != nil else {
//            handlePlaylistError(APIError.notLoggedIn)
//            return
//        }
//        
//        var urlToFetch: URL?
//        if loadNextPage {
//            guard let nextUrlString = playlistNextPageUrl, let url = URL(string: nextUrlString) else {
//                print("No next page URL available.")
//                return
//            }
//            urlToFetch = url
//        } else {
//            urlToFetch = SpotifyConstants.userPlaylistsEndpoint
//            userPlaylists = []
//            playlistNextPageUrl = nil
//            playlistErrorMessage = nil
//        }
//        
//        guard let finalUrl = urlToFetch else {
//            handlePlaylistError(APIError.invalidRequest(message: "Invalid URL for fetching playlists."))
//            return
//        }
//        
//        isLoadingPlaylists = true
//        if !loadNextPage { playlistErrorMessage = nil }
//        
//        makeAPIRequest(
//            url: finalUrl,
//            responseType: SpotifyPlaylistList.self
//        ) { [weak self] result in
//            DispatchQueue.main.async {
//                self?.isLoadingPlaylists = false
//                switch result {
//                case .success(let playlistResponse):
//                    if loadNextPage {
//                        self?.userPlaylists.append(contentsOf: playlistResponse.items)
//                        print("Loaded next page. Total playlists: \(self?.userPlaylists.count ?? 0) / \(playlistResponse.total)")
//                    } else {
//                        self?.userPlaylists = playlistResponse.items
//                        print("Fetched playlists. Count: \(playlistResponse.items.count) / \(playlistResponse.total)")
//                    }
//                    self?.playlistNextPageUrl = playlistResponse.next
//                    self?.playlistErrorMessage = nil
//                case .failure(let error):
//                    self?.handlePlaylistError(error, prefix: "Could not fetch playlists:")
//                }
//            }
//        }
//    }
//
//    func fetchTracksForPlaylist(playlistID: String, loadNextPage: Bool = false) {
//        guard !isLoadingPlaylistTracks else { return }
//        guard isLoggedIn, currentTokens?.accessToken != nil else {
//            handlePlaylistTracksError(APIError.notLoggedIn)
//            return
//        }
//        
//        var urlToFetch: URL?
//        if loadNextPage {
//            guard let nextUrlString = playlistTracksNextPageUrl, let nextUrl = URL(string: nextUrlString) else {
//                print("No next page URL available for tracks.")
//                return
//            }
//            urlToFetch = nextUrl
//        } else {
//            let tracksEndpointString = SpotifyConstants.playlistBaseEndpoint + "\(playlistID)/tracks"
//            urlToFetch = URL(string: tracksEndpointString)
//            currentPlaylistTracks = []
//            playlistTracksNextPageUrl = nil
//            playlistTracksErrorMessage = nil
//        }
//        
//        guard let finalUrl = urlToFetch else {
//            handlePlaylistTracksError(APIError.invalidRequest(message: "Invalid URL for playlist tracks \(playlistID)."))
//            return
//        }
//        
//        isLoadingPlaylistTracks = true
//        if !loadNextPage { playlistTracksErrorMessage = nil }
//        
//        print("Fetching tracks from: \(finalUrl.absoluteString)")
//        makeAPIRequest(
//            url: finalUrl,
//            responseType: SpotifyPlaylistTrackList.self
//        ) { [weak self] result in
//            DispatchQueue.main.async {
//                self?.isLoadingPlaylistTracks = false
//                switch result {
//                case .success(let trackResponse):
//                    let validTracks = trackResponse.items.filter { $0.track != nil }
//                    if loadNextPage {
//                        self?.currentPlaylistTracks.append(contentsOf: validTracks)
//                    } else {
//                        self?.currentPlaylistTracks = validTracks
//                    }
//                    self?.playlistTracksNextPageUrl = trackResponse.next
//                    self?.playlistTracksErrorMessage = nil
//                    print("Fetched tracks for playlist \(playlistID). Tracks count: \(self?.currentPlaylistTracks.count ?? 0)")
//                case .failure(let error):
//                    self?.handlePlaylistTracksError(error, prefix: "Could not fetch tracks:")
//                }
//            }
//        }
//    }
//
//    func clearPlaylistDetailState() {
//        DispatchQueue.main.async {
//            print("Clearing playlist detail state.")
//            self.selectedPlaylist = nil
//            self.currentPlaylistTracks = []
//            self.playlistTracksErrorMessage = nil
//            self.playlistTracksNextPageUrl = nil
//            self.isLoadingPlaylistTracks = false
//        }
//    }
//
//    // MARK: - Generic API Request Function
//
//    private func makeAPIRequest<T: Decodable>(
//        url: URL,
//        method: String = "GET",
//        body: Data? = nil,
//        responseType: T.Type,
//        currentAttempt: Int = 1,
//        maxAttempts: Int = 2,
//        completion: @escaping (Result<T, Error>) -> Void
//    ) {
//        guard currentAttempt <= maxAttempts else {
//            print("Max retries reached for \(url.lastPathComponent).")
//            completion(.failure(APIError.maxRetriesReached))
//            return
//        }
//        
//        guard let accessToken = currentTokens?.accessToken else {
//            completion(.failure(APIError.notLoggedIn))
//            return
//        }
//        
//        if let expiryDate = currentTokens?.expiryDate, expiryDate <= Date().addingTimeInterval(-30) {
//            print("Token expired or near expiry. Refreshing before API call to \(url.lastPathComponent)...")
//            refreshToken { [weak self] success in
//                guard let self = self else { completion(.failure(APIError.unknown)); return }
//                if success {
//                    print("Token refreshed. Retrying API call to \(url.lastPathComponent)...")
//                    self.makeAPIRequest(url: url, method: method, body: body, responseType: responseType,
//                                        currentAttempt: currentAttempt + 1,
//                                        maxAttempts: maxAttempts,
//                                        completion: completion)
//                } else {
//                    print("Token refresh failed. Aborting API call to \(url.lastPathComponent).")
//                    completion(.failure(APIError.tokenRefreshFailed))
//                    DispatchQueue.main.async { self.logout() }
//                }
//            }
//            return
//        }
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = method
//        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
//        if let body = body, method == "POST" || method == "PUT" {
//            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//            request.httpBody = body
//        }
//        
//        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
//            guard let self = self else { completion(.failure(APIError.unknown)); return }
//            if let error = error {
//                completion(.failure(APIError.networkError(error)))
//                return
//            }
//            guard let httpResponse = response as? HTTPURLResponse else {
//                completion(.failure(APIError.invalidResponse))
//                return
//            }
//            
//            if httpResponse.statusCode == 401 || httpResponse.statusCode == 403 {
//                print("Received \(httpResponse.statusCode) for \(url.lastPathComponent); attempting token refresh...")
//                self.refreshToken { [weak self] success in
//                    guard let self = self else { completion(.failure(APIError.unknown)); return }
//                    if success {
//                        self.makeAPIRequest(url: url, method: method, body: body, responseType: responseType,
//                                            currentAttempt: currentAttempt + 1,
//                                            maxAttempts: maxAttempts,
//                                            completion: completion)
//                    } else {
//                        print("Token refresh failed after \(httpResponse.statusCode).")
//                        completion(.failure(APIError.authenticationFailed))
//                        DispatchQueue.main.async { self.logout() }
//                    }
//                }
//                return
//            }
//            
//            guard (200...299).contains(httpResponse.statusCode) else {
//                let errorDetails = self.extractErrorDetails(from: data, statusCode: httpResponse.statusCode)
//                completion(.failure(APIError.httpError(statusCode: httpResponse.statusCode, details: errorDetails)))
//                return
//            }
//            
//            guard let data = data else {
//                if httpResponse.statusCode == 204, T.self == EmptyResponse.self {
//                    if let empty = EmptyResponse() as? T {
//                        completion(.success(empty))
//                    } else {
//                        completion(.failure(APIError.decodingError(nil)))
//                    }
//                } else {
//                    completion(.failure(APIError.noData))
//                }
//                return
//            }
//            
//            do {
//                let decoder = JSONDecoder()
//                let decodedObject = try decoder.decode(T.self, from: data)
//                completion(.success(decodedObject))
//            } catch {
//                print("Decoding error for \(T.self) from \(url.lastPathComponent): \(error)")
//                print("Raw data: \(String(data: data, encoding: .utf8) ?? "Unable to decode data")")
//                completion(.failure(APIError.decodingError(error)))
//            }
//        }.resume()
//    }
//
//    private func extractErrorDetails(from data: Data?, statusCode: Int) -> String {
//        guard let data = data, !data.isEmpty else { return "Status code \(statusCode) with no data." }
//        if let spotifyError = try? JSONDecoder().decode(SpotifyErrorResponse.self, from: data),
//           let message = spotifyError.error.message {
//            return message
//        }
//        if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
//           let errorDesc = json["error_description"] as? String ?? json["error"] as? String {
//            return errorDesc
//        }
//        if let text = String(data: data, encoding: .utf8), !text.isEmpty {
//            return text
//        }
//        return "Received status code \(statusCode)."
//    }
//
//    // MARK: - Logout
//
//    func logout() {
//        DispatchQueue.main.async {
//            print("Logging out user...")
//            self.isLoggedIn = false
//            self.currentTokens = nil
//            self.userProfile = nil
//            self.errorMessage = nil
//            self.userPlaylists = []
//            self.playlistErrorMessage = nil
//            self.playlistNextPageUrl = nil
//            self.selectedPlaylist = nil
//            self.currentPlaylistTracks = []
//            self.playlistTracksErrorMessage = nil
//            self.playlistTracksNextPageUrl = nil
//            self.isLoading = false
//            self.isLoadingPlaylists = false
//            self.isLoadingPlaylistTracks = false
//            self.clearTokens()
//            self.currentWebAuthSession?.cancel()
//            self.currentWebAuthSession = nil
//            self.currentPKCEVerifier = nil
//        }
//    }
//
//    // MARK: - Token Persistence (UserDefaults for simplicity; use Keychain in production)
//    private func saveTokens(tokens: StoredTokens) {
//        do {
//            let encoded = try JSONEncoder().encode(tokens)
//            UserDefaults.standard.set(encoded, forKey: SpotifyConstants.tokenUserDefaultsKey)
//            print("Tokens saved (Insecure - Use Keychain for production)")
//        } catch {
//            print("Error saving tokens: \(error)")
//        }
//    }
//    
//    private func loadTokens() {
//        guard let savedData = UserDefaults.standard.data(forKey: SpotifyConstants.tokenUserDefaultsKey) else {
//            print("No saved tokens found.")
//            self.currentTokens = nil
//            return
//        }
//        do {
//            let decodedTokens = try JSONDecoder().decode(StoredTokens.self, from: savedData)
//            self.currentTokens = decodedTokens
//            print("Tokens loaded from storage.")
//        } catch {
//            print("Error decoding tokens: \(error)")
//            clearTokens()
//            self.currentTokens = nil
//        }
//    }
//    
//    private func clearTokens() {
//        UserDefaults.standard.removeObject(forKey: SpotifyConstants.tokenUserDefaultsKey)
//        print("Tokens cleared from storage.")
//    }
//    
//    // MARK: - Error Handling Helpers
//
//    private func handleError(_ error: Error, prefix: String = "Error:", clearVerifier: Bool = false) {
//        DispatchQueue.main.async {
//            let message = (error as? APIError)?.localizedDescription ?? error.localizedDescription
//            self.errorMessage = "\(prefix) \(message)"
//            print("Error Details: \(error)")
//            if clearVerifier { self.currentPKCEVerifier = nil }
//            self.isLoading = false
//            self.isLoadingPlaylists = false
//            self.isLoadingPlaylistTracks = false
//        }
//    }
//    
//    private func handlePlaylistError(_ error: Error, prefix: String = "Playlist Error:") {
//        DispatchQueue.main.async {
//            let message = (error as? APIError)?.localizedDescription ?? error.localizedDescription
//            self.playlistErrorMessage = "\(prefix) \(message)"
//            print("Playlist Error: \(message)")
//            self.isLoadingPlaylists = false
//        }
//    }
//    
//    private func handlePlaylistTracksError(_ error: Error, prefix: String = "Playlist Tracks Error:") {
//        DispatchQueue.main.async {
//            let message = (error as? APIError)?.localizedDescription ?? error.localizedDescription
//            self.playlistTracksErrorMessage = "\(prefix) \(message)"
//            print("Playlist Tracks Error: \(message)")
//            self.isLoadingPlaylistTracks = false
//        }
//    }
//}
//
//// MARK: - ASWebAuthenticationPresentationContextProviding
//
//extension SpotifyAuthManager: ASWebAuthenticationPresentationContextProviding {
//    func isEqual(_ object: Any?) -> Bool {
//        return true
//    }
//    
//    var hash: Int {
//        return 0
//    }
//    
//    var superclass: AnyClass? {
//        return nil
//    }
//    
//    func `self`() -> Self {
//        return self
//    }
//    
//    func perform(_ aSelector: Selector!) -> Unmanaged<AnyObject>! {
//        return Unmanaged.passUnretained(self)
//    }
//    
//    func perform(_ aSelector: Selector!, with object: Any!) -> Unmanaged<AnyObject>! {
//        return Unmanaged.passUnretained(self)
//    }
//    
//    func perform(_ aSelector: Selector!, with object1: Any!, with object2: Any!) -> Unmanaged<AnyObject>! {
//        return Unmanaged.passUnretained(self)
//    }
//    
//    func isProxy() -> Bool {
//        return true
//    }
//    
//    func isKind(of aClass: AnyClass) -> Bool {
//        return true
//    }
//    
//    func isMember(of aClass: AnyClass) -> Bool {
//        return true
//    }
//    
//    func conforms(to aProtocol: Protocol) -> Bool {
//        return true
//    }
//    
//    func responds(to aSelector: Selector!) -> Bool {
//        return true
//    }
//    
//    var description: String {
//        return ""
//    }
//    
//    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
//        // Return the key window for presenting the authentication session.
//        if let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
//           let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) {
//            return keyWindow
//        }
//        return ASPresentationAnchor()
//    }
//}
//
//// MARK: - PKCE Helper Extension
//
//extension Data {
//    func base64URLEncodedString() -> String {
//        self.base64EncodedString()
//            .replacingOccurrences(of: "+", with: "-")
//            .replacingOccurrences(of: "/", with: "_")
//            .replacingOccurrences(of: "=", with: "")
//    }
//}
//
//// MARK: - Main SwiftUI View
//
//struct AuthenticationFlowView: View {
//    @StateObject var authManager = SpotifyAuthManager()
//    
//    var body: some View {
//        NavigationStack {
//            Group {
//                if !authManager.isLoggedIn {
//                    loggedOutView
//                        .navigationTitle("Spotify Login")
//                } else {
//                    loggedInContentView
//                }
//            }
//            .navigationDestination(for: SpotifyPlaylist.self) { playlist in
//                PlaylistDetailView(playlist: playlist)
//                    .environmentObject(authManager)
//            }
//            .overlay {
//                if authManager.isLoading {
//                    VStack {
//                        ProgressView("Authenticating...")
//                            .padding()
//                            .background(Color(.systemBackground).opacity(0.8))
//                            .cornerRadius(10)
//                            .shadow(radius: 5)
//                    }
//                }
//            }
//            .alert("Error", isPresented: Binding(
//                get: { authManager.errorMessage != nil },
//                set: { if !$0 { authManager.errorMessage = nil } }
//            ), presenting: authManager.errorMessage) { _ in
//                Button("OK") {
//                    authManager.errorMessage = nil
//                }
//            } message: { message in
//                Text(message)
//            }
//        }
//    }
//    
//    private var loggedOutView: some View {
//        VStack(spacing: 30) {
//            Spacer()
//            Image(systemName: "music.note.tv.fill")
//                .font(.system(size: 80))
//                .foregroundColor(Color(red: 30/255, green: 215/255, blue: 96/255))
//            Text("Connect your Spotify account to explore your music.")
//                .font(.title3)
//                .fontWeight(.medium)
//                .multilineTextAlignment(.center)
//                .padding(.horizontal, 40)
//            Button {
//                authManager.initiateAuthorization()
//            } label: {
//                HStack {
//                    Text("Log in with Spotify")
//                        .fontWeight(.semibold)
//                        .foregroundColor(.white)
//                }
//                .padding(.vertical, 15)
//                .padding(.horizontal, 40)
//                .background(Color(red: 30/255, green: 215/255, blue: 96/255))
//                .cornerRadius(30)
//                .shadow(color: .black.opacity(0.2), radius: 5, y: 3)
//            }
//            .disabled(authManager.isLoading)
//            Spacer()
//            Spacer()
//        }
//        .padding()
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .background(Color(.systemBackground))
//    }
//    
//    private var loggedInContentView: some View {
//        List {
//            Section(header: Text("Profile").font(.headline)) {
//                profileSection
//            }
//            Section(header: Text("My Playlists").font(.headline)) {
//                playlistSection
//            }
//            Section(header: Text("Account").font(.headline)) {
//                actionSection
//            }
//        }
//        .navigationTitle("Your Spotify")
//        .listStyle(.insetGrouped)
//        .refreshable {
//            print("Refreshing data...")
//            authManager.fetchUserProfile()
//            authManager.fetchUserPlaylists(loadNextPage: false)
//        }
//        .onAppear {
//            if authManager.userProfile == nil {
//                authManager.fetchUserProfile()
//            }
//            if authManager.userPlaylists.isEmpty && !authManager.isLoadingPlaylists {
//                authManager.fetchUserPlaylists()
//            }
//        }
//    }
//    
//    @ViewBuilder
//    private var profileSection: some View {
//        if let profile = authManager.userProfile {
//            HStack(spacing: 15) {
//                AsyncImage(url: URL(string: profile.images?.first?.url ?? "")) { phase in
//                    switch phase {
//                    case .empty:
//                        ProgressView().frame(width: 60, height: 60)
//                    case .success(let image):
//                        image.resizable().aspectRatio(contentMode: .fill)
//                    case .failure:
//                        Image(systemName: "person.circle.fill")
//                            .resizable()
//                            .aspectRatio(contentMode: .fit)
//                            .foregroundColor(.gray)
//                    @unknown default:
//                        EmptyView()
//                    }
//                }
//                .frame(width: 60, height: 60)
//                .clipShape(Circle())
//                .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1))
//                VStack(alignment: .leading) {
//                    Text(profile.displayName)
//                        .font(.title2)
//                        .fontWeight(.semibold)
//                    Text(profile.email)
//                        .font(.subheadline)
//                        .foregroundColor(.gray)
//                }
//            }
//            .padding(.vertical, 8)
//        } else if authManager.isLoading {
//            HStack { Spacer(); ProgressView(); Text("Loading Profile..."); Spacer() }
//                .padding(.vertical)
//        } else {
//            Text("Profile not available.")
//                .foregroundColor(.gray)
//                .padding(.vertical)
//        }
//    }
//    
//    @ViewBuilder
//    private var playlistSection: some View {
//        if authManager.isLoadingPlaylists && authManager.userPlaylists.isEmpty {
//            HStack { Spacer(); ProgressView(); Text("Loading Playlists..."); Spacer() }
//                .padding(.vertical)
//        } else if let errorMsg = authManager.playlistErrorMessage {
//            Text(errorMsg)
//                .foregroundColor(.red)
//                .padding()
//        } else if authManager.userPlaylists.isEmpty && !authManager.isLoadingPlaylists {
//            Text("You don't have any playlists yet.")
//                .foregroundColor(.gray)
//                .padding()
//        } else {
//            ForEach(authManager.userPlaylists) { playlist in
//                NavigationLink(value: playlist) {
//                    PlaylistRow(playlist: playlist)
//                }
//                .onAppear {
//                    if playlist.id == authManager.userPlaylists.last?.id &&
//                        authManager.playlistNextPageUrl != nil &&
//                        !authManager.isLoadingPlaylists {
//                        print("Reached end of list, loading next page...")
//                        authManager.fetchUserPlaylists(loadNextPage: true)
//                    }
//                }
//            }
//            if authManager.isLoadingPlaylists && !authManager.userPlaylists.isEmpty {
//                ProgressView()
//                    .padding()
//                    .frame(maxWidth: .infinity, alignment: .center)
//            }
//        }
//    }
//    
//    @ViewBuilder
//    private var actionSection: some View {
//        Button("Refresh Token Manually") {
//            authManager.refreshToken()
//        }
//        .disabled(authManager.currentTokens?.refreshToken == nil || authManager.isLoading)
//        Button("Log Out", role: .destructive) {
//            authManager.logout()
//        }
//        .tint(.red)
//        
//        if let tokens = authManager.currentTokens {
//            DisclosureGroup("Token Details (Debug)") {
//                VStack(alignment: .leading, spacing: 5) {
//                    Text("Access Token:").font(.caption.bold())
//                    Text(tokens.accessToken)
//                        .font(.caption)
//                        .lineLimit(1)
//                        .truncationMode(.middle)
//                    if let expiry = tokens.expiryDate {
//                        Text("Expires:")
//                            .font(.caption.bold()) +
//                        Text(" \(expiry, style: .relative) ago (\(expiry, style: .time))")
//                            .font(.caption)
//                            .foregroundColor(expiry <= Date() ? .red : .green)
//                    } else {
//                        Text("Expiry: Unknown")
//                            .font(.caption)
//                            .foregroundColor(.orange)
//                    }
//                    Text("Refresh Token:")
//                        .font(.caption.bold()) +
//                    Text(tokens.refreshToken != nil ? " Present" : " Missing")
//                        .font(.caption)
//                        .foregroundColor(tokens.refreshToken != nil ? .primary : .red)
//                }
//                .padding(.top, 5)
//            }
//            .font(.callout)
//        }
//    }
//}
//
//struct PlaylistRow: View {
//    let playlist: SpotifyPlaylist
//    var body: some View {
//        HStack(spacing: 12) {
//            AsyncImage(url: URL(string: playlist.images?.first?.url ?? "")) { phase in
//                switch phase {
//                case .empty:
//                    Color.gray.opacity(0.3)
//                        .frame(width: 45, height: 45)
//                        .cornerRadius(4)
//                        .overlay(ProgressView().scaleEffect(0.5))
//                case .success(let image):
//                    image.resizable().aspectRatio(contentMode: .fill)
//                case .failure:
//                    Image(systemName: "music.note.list")
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//                        .padding(8)
//                        .frame(width: 45, height: 45)
//                        .background(Color.gray.opacity(0.2))
//                        .foregroundColor(.gray)
//                        .cornerRadius(4)
//                @unknown default:
//                    EmptyView()
//                }
//            }
//            .frame(width: 45, height: 45)
//            .cornerRadius(4)
//            VStack(alignment: .leading) {
//                Text(playlist.name)
//                    .lineLimit(1)
//                    .font(.headline)
//                Text("By \(playlist.owner.displayName ?? "Spotify") • \(playlist.tracks.total) track\(playlist.tracks.total == 1 ? "" : "s")")
//                    .font(.caption)
//                    .foregroundColor(.gray)
//                    .lineLimit(1)
//            }
//            Spacer()
//            if playlist.collaborative {
//                Image(systemName: "person.2.fill")
//                    .foregroundColor(.blue)
//                    .imageScale(.small)
//                    .accessibilityLabel("Collaborative playlist")
//            }
//        }
//        .padding(.vertical, 4)
//    }
//}
//
//struct PlaylistDetailView: View {
//    @EnvironmentObject var authManager: SpotifyAuthManager
//    let playlist: SpotifyPlaylist
//    var body: some View {
//        List {
//            Section {
//                PlaylistHeaderView(playlist: playlist)
//                    .padding(.bottom)
//            }
//            Section(header: Text("Tracks (\(authManager.currentPlaylistTracks.count))")) {
//                tracksListContentView
//            }
//        }
//        .listStyle(.plain)
//        .navigationTitle(playlist.name)
//        .navigationBarTitleDisplayMode(.inline)
//        .onAppear {
//            if authManager.selectedPlaylist?.id != playlist.id || authManager.currentPlaylistTracks.isEmpty {
//                print("PlaylistDetailView Appearing for \(playlist.name). Fetching tracks.")
//                authManager.selectedPlaylist = playlist
//                authManager.fetchTracksForPlaylist(playlistID: playlist.id, loadNextPage: false)
//            } else {
//                print("Tracks already loaded for \(playlist.name).")
//            }
//        }
//        .onDisappear {
//            if authManager.selectedPlaylist?.id == playlist.id {
//                print("PlaylistDetailView Disappearing for \(playlist.name). Clearing state.")
//                authManager.clearPlaylistDetailState()
//            }
//        }
//        .refreshable {
//            print("Refreshing tracks for playlist \(playlist.id)")
//            authManager.fetchTracksForPlaylist(playlistID: playlist.id, loadNextPage: false)
//        }
//    }
//    
//    @ViewBuilder
//    private var tracksListContentView: some View {
//        if authManager.isLoadingPlaylistTracks && authManager.currentPlaylistTracks.isEmpty {
//            HStack { Spacer(); ProgressView(); Text("Loading Tracks..."); Spacer() }
//                .padding(.vertical)
//        } else if let errorMsg = authManager.playlistTracksErrorMessage {
//            Text(errorMsg)
//                .foregroundColor(.red)
//                .padding()
//        } else if authManager.currentPlaylistTracks.isEmpty && !authManager.isLoadingPlaylistTracks {
//            Text("This playlist is empty or tracks could not be loaded.")
//                .foregroundColor(.gray)
//                .padding()
//        } else {
//            ForEach(authManager.currentPlaylistTracks) { playlistTrack in
//                if let track = playlistTrack.track {
//                    TrackRowView(track: track)
//                        .onAppear {
//                            if playlistTrack.id == authManager.currentPlaylistTracks.last?.id &&
//                               authManager.playlistTracksNextPageUrl != nil &&
//                               !authManager.isLoadingPlaylistTracks {
//                                print("Reached end of tracks, loading next page...")
//                                authManager.fetchTracksForPlaylist(playlistID: playlist.id, loadNextPage: true)
//                            }
//                        }
//                }
//            }
//            if authManager.isLoadingPlaylistTracks && !authManager.currentPlaylistTracks.isEmpty {
//                ProgressView().padding().frame(maxWidth: .infinity, alignment: .center)
//            }
//        }
//    }
//}
//
//struct PlaylistHeaderView: View {
//    let playlist: SpotifyPlaylist
//    var body: some View {
//        HStack(alignment: .center, spacing: 15) {
//            AsyncImage(url: URL(string: playlist.images?.first?.url ?? "")) { phase in
//                switch phase {
//                case .empty:
//                    Color.gray.opacity(0.3)
//                        .frame(width: 120, height: 120)
//                        .cornerRadius(8)
//                        .overlay(ProgressView())
//                case .success(let image):
//                    image.resizable()
//                        .aspectRatio(contentMode: .fill)
//                        .frame(width: 120, height: 120)
//                        .cornerRadius(8)
//                        .shadow(radius: 5)
//                case .failure:
//                    Image(systemName: "music.note.list")
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//                        .padding(20)
//                        .frame(width: 120, height: 120)
//                        .background(Color.gray.opacity(0.2))
//                        .foregroundColor(.gray)
//                        .cornerRadius(8)
//                @unknown default:
//                    EmptyView()
//                }
//            }
//            .frame(width: 120, height: 120)
//            VStack(alignment: .leading, spacing: 4) {
//                Text(playlist.name)
//                    .font(.title2)
//                    .fontWeight(.bold)
//                    .lineLimit(2)
//                if let description = playlist.description, !description.isEmpty, description != "<null>" {
//                    Text(description.trimmingCharacters(in: .whitespacesAndNewlines))
//                        .font(.caption)
//                        .foregroundColor(.gray)
//                        .lineLimit(3)
//                }
//                Text("By \(playlist.owner.displayName ?? "Unknown") • \(playlist.tracks.total) track\(playlist.tracks.total == 1 ? "" : "s")")
//                    .font(.caption)
//                    .foregroundColor(.secondary)
//                if playlist.collaborative {
//                    Text("Collaborative")
//                        .font(.caption)
//                        .fontWeight(.medium)
//                        .foregroundColor(.blue)
//                        .padding(.horizontal, 6)
//                        .padding(.vertical, 2)
//                        .background(Color.blue.opacity(0.1))
//                        .cornerRadius(10)
//                }
//                Spacer()
//            }
//            Spacer()
//        }
//        .padding(.vertical)
//    }
//}
//
//struct TrackRowView: View {
//    let track: SpotifyTrack
//    var body: some View {
//        HStack(spacing: 12) {
//            AsyncImage(url: URL(string: track.album.images?.last?.url ?? track.album.images?.first?.url ?? "")) { phase in
//                switch phase {
//                case .empty:
//                    Color.gray.opacity(0.2)
//                        .frame(width: 45, height: 45)
//                        .cornerRadius(4)
//                        .overlay(ProgressView().scaleEffect(0.5))
//                case .success(let image):
//                    image.resizable().aspectRatio(contentMode: .fill)
//                case .failure:
//                    Image(systemName: "music.mic")
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//                        .padding(10)
//                        .background(Color.gray.opacity(0.1))
//                        .foregroundColor(.gray)
//                @unknown default:
//                    EmptyView()
//                }
//            }
//            .frame(width: 45, height: 45)
//            .cornerRadius(4)
//            VStack(alignment: .leading) {
//                Text(track.name)
//                    .lineLimit(1)
//                    .font(.body)
//                Text(track.artistNames)
//                    .font(.caption)
//                    .foregroundColor(.gray)
//                    .lineLimit(1)
//            }
//            Spacer()
//            HStack(spacing: 8) {
//                if track.explicit ?? false {
//                    Image(systemName: "e.square.fill")
//                        .foregroundColor(.gray)
//                        .font(.caption)
//                        .accessibilityLabel("Explicit")
//                }
//                Text(track.formattedDuration)
//                    .font(.caption)
//                    .foregroundColor(.gray)
//                    .frame(minWidth: 35, alignment: .trailing)
//            }
//        }
//        .padding(.vertical, 6)
//        .opacity((track.isPlayable ?? true) ? 1.0 : 0.5)
//    }
//}
//
//// MARK: - Previews (Using #Preview syntax for SwiftUI previews)
//
//#Preview("Logged Out") {
//    AuthenticationFlowView()
//}
//
//#Preview("Logged In - Loading") {
//    let manager = SpotifyAuthManager()
//    manager.isLoggedIn = true
//    manager.isLoading = true
//    manager.userProfile = nil
//    manager.userPlaylists = []
//    manager.isLoadingPlaylists = true
//    return AuthenticationFlowView(authManager: manager)
//}
//
//#Preview("Logged In - Playlists") {
//    let manager = SpotifyAuthManager()
//    manager.isLoggedIn = true
//    manager.userProfile = SpotifyUserProfile(id: "p_user", displayName: "List User", email: "list@example.com", images: nil, externalUrls: [:])
//    let owner = SpotifyPlaylistOwner(id: "test_owner", displayName: "Test Owner", externalUrls: [:])
//    let tracksInfo = PlaylistTracksInfo(href: "", total: 10)
//    manager.userPlaylists = [
//        SpotifyPlaylist(id: "pl1", name: "First Sample Playlist", description: "Desc 1", owner: owner, collaborative: false, tracks: tracksInfo, images: nil, externalUrls: [:], publicPlaylist: true),
//        SpotifyPlaylist(id: "pl2", name: "Second Collaborative", description: "Desc 2", owner: owner, collaborative: true, tracks: tracksInfo, images: nil, externalUrls: [:], publicPlaylist: false)
//    ]
//    return AuthenticationFlowView(authManager: manager)
//}
//
//#Preview("Logged In - Playlist Error") {
//    let manager = SpotifyAuthManager()
//    manager.isLoggedIn = true
//    manager.userProfile = SpotifyUserProfile(id: "p_user", displayName: "Error User", email: "error@example.com", images: nil, externalUrls: [:])
//    manager.playlistErrorMessage = "Could not reach Spotify servers (Simulated Network Error)"
//    return AuthenticationFlowView(authManager: manager)
//}
