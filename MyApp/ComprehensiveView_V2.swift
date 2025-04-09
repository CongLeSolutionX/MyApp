//
////
////  AuthenticationFlowView_Cleaned.swift
////  MyApp
////
////  Created by Cong Le on 4/7/25
////  Refactored: [Your Name/AI] on [Date]
////
//
//import SwiftUI
//import Combine // For ObservableObject
//import CryptoKit // For PKCE SHA256
//import AuthenticationServices // For ASWebAuthenticationSession
//
//// MARK: - Configuration (MUST REPLACE)
//struct SpotifyConstants {
//    // IMPORTANT: REPLACE THESE WITH YOUR ACTUAL SPOTIFY APP DETAILS
//    static let clientID = "YOUR_SPOTIFY_CLIENT_ID" // <-- REPLACE THIS
//    static let redirectURI = "YOUR_APP_CALLBACK_SCHEME://callback" // <-- REPLACE THIS (e.g., "myapp://callback")
//    // --- Ensure your redirectURI is registered in your Spotify App Dashboard ---
//
//    static let scopes = [
//        "user-read-private",
//        "user-read-email",
//        "playlist-read-private", // Needed for fetching user playlists
//        "playlist-read-collaborative", // Optional: To see collaborative playlists
//        "playlist-modify-public", // Example scope
//        "playlist-modify-private", // Example scope
//        "user-library-read", // Example scope for liked songs
//        "user-top-read" // Example scope for top items
//        // Add other scopes your app needs
//    ]
//    static let scopeString = scopes.joined(separator: " ")
//
//    // --- Spotify API Endpoints ---
//    static let authorizationEndpoint = URL(string: "https://accounts.spotify.com/authorize")!
//    static let tokenEndpoint = URL(string: "https://accounts.spotify.com/api/token")!
//    static let userProfileEndpoint = URL(string: "https://api.spotify.com/v1/me")!
//    static let userPlaylistsEndpoint = URL(string: "https://api.spotify.com/v1/me/playlists")!
//    // Base URL for playlist tracks - requires appending /{playlist_id}/tracks
//    static let playlistBaseEndpoint = "https://api.spotify.com/v1/playlists/"
//
//    // --- Persistence Key ---
//    // NOTE: Using UserDefaults for simplicity. Use Keychain for production!
//    static let tokenUserDefaultsKey = "spotifyTokens_secure" // Changed key slightly
//}
//
//// MARK: - Data Models
//
//// Represents the response from Spotify when requesting/refreshing tokens
//struct TokenResponse: Codable {
//    let accessToken: String
//    let tokenType: String
//    let expiresIn: Int // Seconds until expiry
//    let refreshToken: String? // May not always be returned on refresh
//    let scope: String // Scopes granted
//
//    // Calculated property for the absolute expiry date
//    var expiryDate: Date? {
//        return Calendar.current.date(byAdding: .second, value: expiresIn, to: Date())
//    }
//
//    enum CodingKeys: String, CodingKey {
//        case accessToken = "access_token"
//        case tokenType = "token_type"
//        case expiresIn = "expires_in"
//        case refreshToken = "refresh_token"
//        case scope
//    }
//}
//
//// Simple model for storing essential token data persistently
//// IMPORTANT: Use Keychain for storing tokens in a real application! UserDefaults is not secure.
//struct StoredTokens: Codable {
//    let accessToken: String
//    let refreshToken: String?
//    let expiryDate: Date?
//}
//
//// Represents the user's Spotify profile information
//struct SpotifyUserProfile: Codable, Identifiable {
//    let id: String
//    let displayName: String
//    let email: String // Requires user-read-email scope
//    let images: [SpotifyImage]? // Profile images (different sizes)
//    let externalUrls: [String: String]? // e.g., link to user's profile on Spotify
//
//    enum CodingKeys: String, CodingKey {
//        case id
//        case displayName = "display_name"
//        case email
//        case images
//        case externalUrls = "external_urls"
//    }
//}
//
//// Represents an image URL with dimensions (used in profiles, playlists, albums, etc.)
//struct SpotifyImage: Codable, Hashable {
//    let url: String
//    let height: Int?
//    let width: Int?
//
//    // Hashable conformance based on URL
//    func hash(into hasher: inout Hasher) {
//        hasher.combine(url)
//    }
//    static func == (lhs: SpotifyImage, rhs: SpotifyImage) -> Bool {
//        lhs.url == rhs.url
//    }
//}
//
//// --- Models for Playlists ---
//
//// Generic Paging Object used by many Spotify endpoints (like playlists, tracks)
//struct SpotifyPagingObject<T: Codable>: Codable {
//    let href: String // URL to the full request for this list
//    let items: [T] // The actual items (e.g., playlists, tracks)
//    let limit: Int // Max items per page
//    let next: String? // URL for the next page of items (null if none)
//    let offset: Int // Offset of the items returned
//    let previous: String? // URL for the previous page of items (null if none)
//    let total: Int // Total number of items available
//}
//
//// Represents the owner of a playlist
//struct SpotifyPlaylistOwner: Codable, Identifiable, Hashable {
//    let id: String
//    let displayName: String? // Might be nil sometimes (e.g., for Spotify curated)
//    let externalUrls: [String: String]?
//
//    // Hashable conformance based on ID
//    func hash(into hasher: inout Hasher) {
//        hasher.combine(id)
//    }
//    static func == (lhs: SpotifyPlaylistOwner, rhs: SpotifyPlaylistOwner) -> Bool {
//        lhs.id == rhs.id
//    }
//
//    enum CodingKeys: String, CodingKey {
//        case id
//        case displayName = "display_name"
//        case externalUrls = "external_urls"
//    }
//}
//
//// Contains information about the tracks within a playlist (total count and link)
//struct PlaylistTracksInfo: Codable, Hashable {
//    let href: String // Link to the full tracks endpoint for this playlist
//    let total: Int // Total number of tracks
//
//    // Hashable conformance based on relevant fields
//    func hash(into hasher: inout Hasher) {
//        hasher.combine(total)
//        hasher.combine(href) // href might change, but include for completeness
//    }
//    static func == (lhs: PlaylistTracksInfo, rhs: PlaylistTracksInfo) -> Bool {
//        lhs.total == rhs.total && lhs.href == rhs.href
//    }
//}
//
//// Represents a Spotify Playlist
//// Made Hashable for use in NavigationLink values
//struct SpotifyPlaylist: Codable, Identifiable, Hashable {
//    let id: String
//    let name: String
//    let description: String? // Can be empty HTML string or just empty
//    let owner: SpotifyPlaylistOwner
//    let collaborative: Bool // If the playlist is collaborative
//    let tracks: PlaylistTracksInfo // Summary of tracks
//    let images: [SpotifyImage]? // Playlist cover images
//    let externalUrls: [String: String]? // Link to the playlist on Spotify
//    let publicPlaylist: Bool? // Renamed from `public` to avoid keyword clash
//
//    // Implement Hashable: Use stable properties like id
//    func hash(into hasher: inout Hasher) {
//        hasher.combine(id)
//    }
//
//    // Implement Equatable based on id for Hashable conformance
//    static func == (lhs: SpotifyPlaylist, rhs: SpotifyPlaylist) -> Bool {
//        lhs.id == rhs.id
//    }
//
//    enum CodingKeys: String, CodingKey {
//        case id, name, description, owner, collaborative, tracks, images
//        case externalUrls = "external_urls"
//        case publicPlaylist = "public" // Map JSON key "public"
//    }
//}
//
//// Type alias for the specific paging object containing playlists
//typealias SpotifyPlaylistList = SpotifyPagingObject<SpotifyPlaylist>
//
//// --- Models for Playlist Tracks ---
//
//// Simplified Artist Object (used within Track objects)
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
//// Simplified Album Object (used within Track objects, mainly for images)
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
//// The actual Track Object details
//struct SpotifyTrack: Codable, Identifiable, Hashable {
//    let id: String
//    let name: String
//    let artists: [SpotifyArtistSimple]
//    let album: SpotifyAlbumSimple
//    let durationMs: Int // Duration in milliseconds
//    let trackNumber: Int? // Track number on the album
//    let discNumber: Int? // Disc number on the album
//    let explicit: Bool? // Whether the track has explicit content
//    let externalUrls: [String: String]? // Link to the track on Spotify
//    let uri: String // Spotify URI for the track (e.g., "spotify:track:...")
//    let isPlayable: Bool? // Added based on common Spotify API usage - indicates if track is playable in current market
//
//    // Calculated property for displayable duration (e.g., "3:45")
//    var formattedDuration: String {
//        let totalSeconds = durationMs / 1000
//        let minutes = totalSeconds / 60
//        let seconds = totalSeconds % 60
//        return String(format: "%d:%02d", minutes, seconds)
//    }
//
//    // Calculated property for a comma-separated list of artist names
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
//        case isPlayable = "is_playable" // Check if API returns this
//    }
//}
//
//// The object wrapping the track within a playlist response (includes added_at info)
//// Made Identifiable based on the underlying track's ID or a UUID fallback.
//struct SpotifyPlaylistTrack: Codable, Identifiable {
//    // Use track ID if available, otherwise generate a UUID (handles cases where track might be null but the item exists)
//    var id: String { track?.id ?? UUID().uuidString }
//    let addedAt: String? // Date string like "2014-09-01T12:00:00Z" - Can be decoded to Date if needed
//    // Track can be null if user cannot play it (e.g. market restriction) - IMPORTANT TO HANDLE!
//    let track: SpotifyTrack?
//
//    enum CodingKeys: String, CodingKey {
//        case track
//        case addedAt = "added_at"
//    }
//}
//
//// The full response type for the playlist tracks endpoint
//typealias SpotifyPlaylistTrackList = SpotifyPagingObject<SpotifyPlaylistTrack>
//
//// Model for Spotify's standard JSON error response structure
//struct SpotifyErrorResponse: Codable {
//    let error: SpotifyErrorDetail
//}
//struct SpotifyErrorDetail: Codable {
//    let status: Int
//    let message: String?
//}
//
//// Model for representing an empty successful response (e.g., for 204 No Content status codes)
//struct EmptyResponse: Codable {}
//
//// MARK: - Custom API Error Enum
//// Defines specific error types for better error handling and user feedback
//enum APIError: Error, LocalizedError {
//    case invalidRequest(message: String)
//    case networkError(Error)
//    case invalidResponse
//    case httpError(statusCode: Int, details: String) // Includes status code and details from response
//    case noData
//    case decodingError(Error?) // Includes underlying decoding error
//    case notLoggedIn
//    case tokenRefreshFailed
//    case authenticationFailed // Specifically after a refresh attempt also fails
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
//        case .maxRetriesReached: return "Maximum retry attempts reached for the request."
//        case .pkceGenerationFailed: return "Could not generate security challenge for login."
//        case .authUrlConstructionFailed: return "Could not create the authorization URL."
//        case .noAuthCodeReceived: return "Did not receive authorization code from Spotify."
//        case .spotifyAuthDenied(let reason): return "Spotify denied the login request: \(reason)"
//        case .unknown: return "An unexpected error occurred."
//        }
//    }
//
//    // Helper property to easily check if the error is related to authentication/authorization
//    var isAuthError: Bool {
//        switch self {
//        case .httpError(let statusCode, _):
//            return statusCode == 401 || statusCode == 403 // Unauthorized or Forbidden
//        case .authenticationFailed, .tokenRefreshFailed, .notLoggedIn:
//            return true
//        default:
//            return false
//        }
//    }
//}
//
//// MARK: - Authentication Manager (ObservableObject)
//// Manages the Spotify authentication state, token handling, and API calls.
//class SpotifyAuthManager: ObservableObject {
//
//    // --- Published Properties for UI State ---
//    @Published var isLoggedIn: Bool = false
//    @Published var userProfile: SpotifyUserProfile? = nil
//    @Published var isLoading: Bool = false // General loading state (login, profile fetch initial)
//    @Published var errorMessage: String? = nil // General error messages for UI
//
//    // Playlists List State
//    @Published var userPlaylists: [SpotifyPlaylist] = []
//    @Published var isLoadingPlaylists: Bool = false
//    @Published var playlistErrorMessage: String? = nil
//    private(set) var playlistNextPageUrl: String? = nil // Store next page URL privately
//
//    // Playlist Detail (Tracks) State
//    @Published var selectedPlaylist: SpotifyPlaylist? = nil // Keep track of the playlist being viewed
//    @Published var currentPlaylistTracks: [SpotifyPlaylistTrack] = []
//    @Published var isLoadingPlaylistTracks: Bool = false
//    @Published var playlistTracksErrorMessage: String? = nil
//    private(set) var playlistTracksNextPageUrl: String? = nil // Store next page URL privately
//
//    // --- Internal State ---
//    var currentTokens: StoredTokens? = nil // Holds the current access/refresh tokens
//    private var currentPKCEVerifier: String? // Stores PKCE verifier during auth flow
//    private var currentWebAuthSession: ASWebAuthenticationSession? // Manages the web auth session
//
//    // --- Initialization ---
//    init() {
//        loadTokens() // Load tokens from persistent storage
//
//        // Check if loaded tokens are valid and not expired
//        if let tokens = currentTokens, let expiry = tokens.expiryDate, expiry > Date() {
//            self.isLoggedIn = true
//            print("AuthManager Init: Found valid saved tokens. User is logged in.")
//            // Fetch initial data needed for logged-in state
//            fetchUserProfile()
//            fetchUserPlaylists()
//        } else if let tokens = currentTokens, tokens.refreshToken != nil {
//            // Tokens exist but might be expired, attempt refresh
//            print("AuthManager Init: Found expired tokens with refresh token. Attempting refresh...")
//            refreshToken { [weak self] success in
//                DispatchQueue.main.async {
//                    if success {
//                        print("AuthManager Init: Token refresh successful.")
//                        self?.fetchUserProfile()
//                        self?.fetchUserPlaylists()
//                    } else {
//                        print("AuthManager Init: Token refresh failed. Logging out.")
//                        // If refresh fails, clear potentially invalid tokens and log out
//                        self?.logout()
//                    }
//                }
//            }
//        } else {
//            // No valid or refreshable tokens found
//            print("AuthManager Init: No valid tokens found. User is logged out.")
//            self.isLoggedIn = false
//        }
//    }
//
//    // MARK: - PKCE Helper Functions
//    // Generates a cryptographically secure random string for PKCE code verifier
//    private func generateCodeVerifier() -> String {
//        var buffer = [UInt8](repeating: 0, count: 32)
//        _ = SecRandomCopyBytes(kSecRandomDefault, buffer.count, &buffer)
//        return Data(buffer).base64URLEncodedString() // Use base64 URL encoding
//    }
//
//    // Generates the SHA256 hash of the verifier, then base64 URL encodes it for PKCE code challenge
//    private func generateCodeChallenge(from verifier: String) -> String? {
//        guard let data = verifier.data(using: .utf8) else { return nil }
//        let digest = SHA256.hash(data: data)
//        return Data(digest).base64URLEncodedString()
//    }
//
//    // MARK: - Authentication Flow
//    // Initiates the Spotify OAuth 2.0 Authorization Code Flow with PKCE
//    func initiateAuthorization() {
//        guard !isLoading else { return } // Prevent multiple simultaneous auth attempts
//        prepareForNewAuth() // Reset state before starting
//
//        let verifier = generateCodeVerifier()
//        guard let challenge = generateCodeChallenge(from: verifier) else {
//            handleError_V1(APIError.pkceGenerationFailed)
//            return
//        }
//        currentPKCEVerifier = verifier // Store verifier for the token exchange step
//
//        var components = URLComponents(url: SpotifyConstants.authorizationEndpoint, resolvingAgainstBaseURL: true)
//        components?.queryItems = [
//            URLQueryItem(name: "client_id", value: SpotifyConstants.clientID),
//            URLQueryItem(name: "response_type", value: "code"), // Requesting authorization code
//            URLQueryItem(name: "redirect_uri", value: SpotifyConstants.redirectURI),
//            URLQueryItem(name: "scope", value: SpotifyConstants.scopeString),
//            URLQueryItem(name: "code_challenge_method", value: "S256"), // Specify SHA256 method
//            URLQueryItem(name: "code_challenge", value: challenge),
//            // Consider adding 'state' parameter for CSRF protection if needed
//        ]
//
//        guard let authURL = components?.url else {
//            handleError(APIError.authUrlConstructionFailed)
//            return
//        }
//
//        // Extract the scheme from the redirect URI for the callback
//        let scheme = URL(string: SpotifyConstants.redirectURI)?.scheme
//
//        // Create and configure the web authentication session
//        currentWebAuthSession = ASWebAuthenticationSession(
//            url: authURL,
//            callbackURLScheme: scheme) { [weak self] callbackURL, error in
//                // Ensure UI updates and logic run on the main thread after callback
//                DispatchQueue.main.async {
//                    self?.handleAuthCallback(callbackURL: callbackURL, error: error)
//                }
//            }
//
//        currentWebAuthSession?.presentationContextProvider = self
//        currentWebAuthSession?.prefersEphemeralWebBrowserSession = true // Recommended for privacy
//
//        // Start the web authentication session
//        DispatchQueue.main.async {
//            self.isLoading = true // Show loading indicator while web view is potentially active
//            self.currentWebAuthSession?.start()
//        }
//    }
//
//    // Resets authentication-related state before initiating a new flow
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
//        // Keep currentTokens for potential refresh, logout clears them explicitly
//    }
//
//    // Handles the callback from the ASWebAuthenticationSession
//    private func handleAuthCallback(callbackURL: URL?, error: Error?) {
//        isLoading = false // Hide general loading indicator
//
//        if let error = error {
//            if let authError = error as? ASWebAuthenticationSessionError, authError.code == .canceledLogin {
//                print("Auth cancelled by user.")
//                // Optionally set a user-facing message, or just do nothing
//                self.errorMessage = "Login cancelled."
//            } else {
//                handleError(APIError.networkError(error)) // Handle other web session errors
//            }
//            return
//        }
//
//        guard let successURL = callbackURL else {
//            handleError_V1(APIError.noAuthCodeReceived, message: "No callback URL received.")
//            return
//        }
//
//        // Extract the authorization code (or error) from the callback URL query parameters
//        let queryItems = URLComponents(string: successURL.absoluteString)?.queryItems
//        if let code = queryItems?.first(where: { $0.name == "code" })?.value {
//            print("Successfully received authorization code.")
//            exchangeCodeForToken(code: code)
//        } else {
//            // Check for Spotify-specific errors in the callback
//            if let spotifyError = queryItems?.first(where: { $0.name == "error" })?.value {
//                print("Spotify error in callback: \(spotifyError)")
//                handleError_V1(APIError.spotifyAuthDenied(reason: spotifyError))
//            } else {
//                handleError_V1(APIError.noAuthCodeReceived, message: "Could not find authorization code in callback.")
//            }
//        }
//    }
//
//    // Exchanges the received authorization code for access and refresh tokens
//    private func exchangeCodeForToken(code: String) {
//        guard let verifier = currentPKCEVerifier else {
//            handleError_V1(APIError.invalidRequest(message: "Missing PKCE verifier for token exchange."), clearVerifier: true)
//            return
//        }
//        guard !isLoading else { return } // Prevent concurrent requests
//        isLoading = true
//        errorMessage = nil
//
//        makeTokenRequest(grantType: "authorization_code", code: code, verifier: verifier) { [weak self] result in
//            guard let self = self else { return }
//            DispatchQueue.main.async {
//                self.isLoading = false
//                self.currentPKCEVerifier = nil // IMPORTANT: Clear verifier after use (success or failure)
//                switch result {
//                case .success(let tokenResponse):
//                    print("Successfully exchanged code for tokens.")
//                    self.processSuccessfulTokenResponse(tokenResponse)
//                    // Fetch user data immediately after successful login
//                    self.fetchUserProfile()
//                    self.fetchUserPlaylists()
//                case .failure(let error):
//                    self.handleError_V1(error as! APIError, message: "Failed to get tokens: \(error.localizedDescription)")
//                }
//            }
//        }
//    }
//
//    // MARK: - Token Refresh
//    // Uses the refresh token to get a new access token
//    // Includes a completion handler to signal success/failure, useful for retries.
//    func refreshToken(completion: ((_ success: Bool) -> Void)? = nil) {
//        guard !isLoading else { // Avoid concurrent refresh attempts
//            completion?(false)
//            return
//        }
//        guard let refreshToken = currentTokens?.refreshToken else {
//            print("Error: No refresh token available. Forcing logout.")
//            logout() // Can't refresh without a refresh token, force re-login
//            completion?(false)
//            return
//        }
//
//        isLoading = true // Consider a specific isLoadingRefreshToken state if needed
//        errorMessage = nil
//
//        makeTokenRequest(grantType: "refresh_token", refreshToken: refreshToken) { [weak self] result in
//            guard let self = self else {
//                completion?(false)
//                return
//            }
//            DispatchQueue.main.async {
//                self.isLoading = false
//                switch result {
//                case .success(let tokenResponse):
//                    print("Successfully refreshed tokens.")
//                    // Spotify might not return a *new* refresh token. Preserve the old one if needed.
//                    let updatedRefreshToken = tokenResponse.refreshToken ?? self.currentTokens?.refreshToken
//                    self.processSuccessfulTokenResponse(tokenResponse, explicitRefreshToken: updatedRefreshToken)
//                    completion?(true)
//                case .failure(let error):
//                    print("Token Refresh Error: \(error.localizedDescription)")
//                    self.handleError_V1(error as! APIError, message: "Session refresh failed. \(error.localizedDescription)")
//                    // If refresh fails persistently (e.g., invalid_grant), log the user out.
//                    if let apiError = error as? APIError, apiError.isAuthError {
//                        self.logout()
//                    }
//                    completion?(false)
//                }
//            }
//        }
//    }
//
//    // MARK: - Centralized Token Request Logic
//    // Internal function to handle both initial token request and refresh request
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
//        // Add parameters specific to the grant type
//        if grantType == "authorization_code", let code = code, let verifier = verifier {
//            queryItems.append(contentsOf: [
//                URLQueryItem(name: "code", value: code),
//                URLQueryItem(name: "redirect_uri", value: SpotifyConstants.redirectURI),
//                URLQueryItem(name: "code_verifier", value: verifier)
//            ])
//        } else if grantType == "refresh_token", let refreshToken = refreshToken {
//            queryItems.append(URLQueryItem(name: "refresh_token", value: refreshToken))
//        } else {
//            // Should not happen if called correctly from exchangeCode or refreshToken methods
//            completion(.failure(APIError.invalidRequest(message: "Invalid parameters for token request grant type '\(grantType)'.")))
//            return
//        }
//
//        components.queryItems = queryItems
//        request.httpBody = components.percentEncodedQuery?.data(using: .utf8) // Use percentEncodedQuery
//
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            if let error = error {
//                completion(.failure(APIError.networkError(error)))
//                return
//            }
//
//            guard let httpResponse = response as? HTTPURLResponse else {
//                completion(.failure(APIError.invalidResponse))
//                return
//            }
//
//            guard (200...299).contains(httpResponse.statusCode) else {
//                let errorDetails = self.extractErrorDetails(from: data, statusCode: httpResponse.statusCode)
//                let apiError = APIError.httpError(statusCode: httpResponse.statusCode, details: errorDetails)
//                completion(.failure(apiError))
//                return
//            }
//
//            guard let data = data else {
//                completion(.failure(APIError.noData))
//                return
//            }
//
//            do {
//                let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)
//                completion(.success(tokenResponse))
//            } catch {
//                print("Token JSON Decoding Error: \(error)")
//                // Log the raw data for debugging decoding issues
//                print("Raw Token Response Data: \(String(data: data, encoding: .utf8) ?? "Unable to decode data")")
//                completion(.failure(APIError.decodingError(error)))
//            }
//        }.resume()
//    }
//
//    // Helper to process a successful token response, update state, and save tokens
//    private func processSuccessfulTokenResponse(_ tokenResponse: TokenResponse, explicitRefreshToken: String? = nil) {
//        // Use the refresh token from the response, or the explicitly passed one (which might be the old one)
//        let refreshTokenToStore = explicitRefreshToken ?? tokenResponse.refreshToken
//
//        let newStoredTokens = StoredTokens(
//            accessToken: tokenResponse.accessToken,
//            refreshToken: refreshTokenToStore,
//            expiryDate: tokenResponse.expiryDate
//        )
//        self.currentTokens = newStoredTokens
//        self.saveTokens(tokens: newStoredTokens) // Persist the tokens
//        self.isLoggedIn = true // Update login state
//        self.errorMessage = nil // Clear general errors on success
//    }
//
//    // MARK: - Fetch User Data
//    // Fetches the profile of the currently authenticated user
//    func fetchUserProfile() {
//        guard isLoggedIn else { return } // Don't fetch if not logged in
//
//        // Can use the general 'isLoading' or add a specific 'isLoadingProfile' state
//        // isLoading = true // Optional: Set loading state if needed
//
//        makeAPIRequest(
//            url: SpotifyConstants.userProfileEndpoint,
//            responseType: SpotifyUserProfile.self
//        ) { [weak self] result in
//            guard let self = self else { return }
//            DispatchQueue.main.async {
//                // self.isLoading = false // Optional: Clear loading state
//                switch result {
//                case .success(let profile):
//                    self.userProfile = profile
//                    self.errorMessage = nil // Clear error on success
//                    print("Successfully fetched user profile for \(profile.displayName)")
//                case .failure(let error):
//                    self.handleError(error, prefix: "Could not fetch profile:")
//                }
//            }
//        }
//    }
//
//    // Fetches the user's playlists (first page or next page)
//    func fetchUserPlaylists(loadNextPage: Bool = false) {
//        guard !isLoadingPlaylists else { return } // Prevent concurrent loads for playlists
//        guard isLoggedIn, currentTokens?.accessToken != nil else {
//            handlePlaylistError(APIError.notLoggedIn)
//            return
//        }
//
//        var urlToFetch: URL?
//
//        if loadNextPage {
//            // Use the stored URL for the next page
//            guard let nextUrlString = playlistNextPageUrl else {
//                print("Playlist Fetch: No next page URL available.")
//                return // Nothing more to load
//            }
//            urlToFetch = URL(string: nextUrlString)
//        } else {
//            // Fetching the first page
//            urlToFetch = SpotifyConstants.userPlaylistsEndpoint
//            // Reset state for a fresh load
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
//        // Clear playlist-specific error message before request
//        if !loadNextPage { playlistErrorMessage = nil }
//
//        makeAPIRequest(
//            url: finalUrl,
//            responseType: SpotifyPlaylistList.self // Expecting the PagingObject for playlists
//        ) { [weak self] result in
//            guard let self = self else { return }
//            DispatchQueue.main.async {
//                self.isLoadingPlaylists = false
//                switch result {
//                case .success(let playlistResponse):
//                    if loadNextPage {
//                        self.userPlaylists.append(contentsOf: playlistResponse.items)
//                        print("Loaded next page of playlists. Total: \(self.userPlaylists.count) / \(playlistResponse.total)")
//                    } else {
//                        self.userPlaylists = playlistResponse.items
//                        print("Fetched initial playlists. Count: \(self.userPlaylists.count) / \(playlistResponse.total)")
//                    }
//                    // Update the URL for the *next* page
//                    self.playlistNextPageUrl = playlistResponse.next
//                    self.playlistErrorMessage = nil // Clear error on success
//
//                case .failure(let error):
//                     // Set the playlist-specific error message
//                     self.handlePlaylistError(error, prefix: "Could not fetch playlists:")
//                }
//            }
//        }
//    }
//
//    // Fetches the tracks for a specific playlist (by ID)
//    func fetchTracksForPlaylist(playlistID: String, loadNextPage: Bool = false) {
//        guard !isLoadingPlaylistTracks else { return } // Use specific loading flag
//        guard isLoggedIn, currentTokens?.accessToken != nil else {
//            handlePlaylistTracksError(APIError.notLoggedIn)
//            return
//        }
//
//        var urlToFetch: URL?
//
//        if loadNextPage {
//            guard let nextUrlString = playlistTracksNextPageUrl, let nextUrl = URL(string: nextUrlString) else {
//                print("Playlist Tracks Fetch: No next page URL available or invalid.")
//                return // Nothing more to load for this playlist
//            }
//            urlToFetch = nextUrl
//        } else {
//             // Construct the initial URL for the specific playlist's tracks
//             // Optionally add fields parameter to limit data: ?fields=items(track(...))&limit=50
//            let tracksEndpointString = SpotifyConstants.playlistBaseEndpoint + "\(playlistID)/tracks"
//            urlToFetch = URL(string: tracksEndpointString)
//
//            // Reset tracks state when fetching the first page for THIS playlist
//            currentPlaylistTracks = []
//            playlistTracksNextPageUrl = nil
//            playlistTracksErrorMessage = nil // Clear specific error
//        }
//
//        guard let finalUrl = urlToFetch else {
//            handlePlaylistTracksError(APIError.invalidRequest(message: "Invalid URL for playlist tracks \(playlistID)."))
//            return
//        }
//
//        isLoadingPlaylistTracks = true
//        // Clear track-specific error message before request
//        if !loadNextPage { playlistTracksErrorMessage = nil }
//
//        print("Fetching tracks from: \(finalUrl.absoluteString)") // Debugging
//
//        makeAPIRequest(
//            url: finalUrl,
//            responseType: SpotifyPlaylistTrackList.self // Expecting tracks paging object
//        ) { [weak self] result in
//            guard let self = self else { return }
//            DispatchQueue.main.async {
//                self.isLoadingPlaylistTracks = false
//                switch result {
//                case .success(let trackResponse):
//                    // Filter out items where track is nil immediately after fetch
//                    let validTracks = trackResponse.items.filter { $0.track != nil }
//
//                    if loadNextPage {
//                        self.currentPlaylistTracks.append(contentsOf: validTracks)
//                    } else {
//                        self.currentPlaylistTracks = validTracks
//                    }
//                    self.playlistTracksNextPageUrl = trackResponse.next // Update next page URL
//                    self.playlistTracksErrorMessage = nil // Clear track error on success
//                    print("Fetched tracks page for playlist \(playlistID). Valid tracks loaded: \(self.currentPlaylistTracks.count). Next page: \(self.playlistTracksNextPageUrl != nil)")
//
//                case .failure(let error):
//                     // Set the specific error message for the detail view
//                     self.handlePlaylistTracksError(error, prefix: "Could not fetch tracks:")
//                }
//            }
//        }
//    }
//
//    // Call this when navigating away from the playlist detail view to clear its state
//    func clearPlaylistDetailState() {
//        DispatchQueue.main.async {
//            print("Clearing playlist detail state.")
//            self.selectedPlaylist = nil
//            self.currentPlaylistTracks = []
//            self.playlistTracksErrorMessage = nil
//            self.playlistTracksNextPageUrl = nil
//            self.isLoadingPlaylistTracks = false // Ensure loading indicator is reset
//        }
//    }
//
//    // MARK: - Generic API Request Function
//    // Handles common API request logic: adding auth header, checking/refreshing token, decoding response, handling errors.
//    private func makeAPIRequest<T: Decodable>(
//        url: URL,
//        method: String = "GET", // Default to GET
//        body: Data? = nil,      // Optional request body for POST/PUT etc.
//        responseType: T.Type,
//        currentAttempt: Int = 1, // Track retry attempts
//        maxAttempts: Int = 2,    // Allow one retry after token refresh
//        completion: @escaping (Result<T, Error>) -> Void
//    ) {
//        guard currentAttempt <= maxAttempts else {
//            print("API Request Error: Max retries reached for \(url.lastPathComponent).")
//            completion(.failure(APIError.maxRetriesReached))
//            return
//        }
//
//        guard let accessToken = currentTokens?.accessToken else {
//            completion(.failure(APIError.notLoggedIn))
//            return
//        }
//
//        // --- Check for Token Expiry BEFORE making the call ---
//        if let expiryDate = currentTokens?.expiryDate, expiryDate <= Date().addingTimeInterval(-30) { // Add buffer (e.g., 30s)
//            print("Token likely expired or close to expiry. Attempting refresh before API call to \(url.lastPathComponent)...")
//            refreshToken { [weak self] success in
//                guard let self = self else {
//                    completion(.failure(APIError.unknown)); return
//                }
//                if success {
//                    print("Token refreshed successfully. Retrying API call to \(url.lastPathComponent)...")
//                    // Retry the original request with the NEW token
//                    self.makeAPIRequest(
//                        url: url, method: method, body: body, responseType: responseType,
//                        currentAttempt: currentAttempt + 1, // Increment attempt count
//                        maxAttempts: maxAttempts, completion: completion
//                    )
//                } else {
//                    print("Token refresh failed. Aborting API call to \(url.lastPathComponent).")
//                    completion(.failure(APIError.tokenRefreshFailed))
//                    // Optionally trigger logout if refresh fails consistently
//                     DispatchQueue.main.async { self.logout() }
//                }
//            }
//            return // Exit this attempt to allow refresh/retry
//        }
//        // --- End Token Expiry Check ---
//
//        // --- Create URLRequest ---
//        var request = URLRequest(url: url)
//        request.httpMethod = method
//        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
//        if let body = body, (method == "POST" || method == "PUT") { // Add body and Content-Type if needed
//            request.setValue("application/json", forHTTPHeaderField: "Content-Type") // Assuming JSON body
//            request.httpBody = body
//        }
//        // Can add other headers if required (e.g., If-None-Match for caching)
//
//        // --- Perform Data Task ---
//        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
//            guard let self = self else {
//                completion(.failure(APIError.unknown)); return
//            }
//
//            if let error = error {
//                completion(.failure(APIError.networkError(error)))
//                return
//            }
//
//            guard let httpResponse = response as? HTTPURLResponse else {
//                completion(.failure(APIError.invalidResponse))
//                return
//            }
//
//            // --- Handle Specific HTTP Status Codes ---
//
//            // Check for 401/403 (Unauthorized/Forbidden) -> Try refreshing token
//            if httpResponse.statusCode == 401 || httpResponse.statusCode == 403 {
//                print("Received \(httpResponse.statusCode) for \(url.lastPathComponent). Token might be invalid/expired. Attempting refresh...")
//                refreshToken { [weak self] success in
//                    guard let self = self else {
//                        completion(.failure(APIError.unknown)); return
//                    }
//                    if success {
//                        print("Token refreshed after \(httpResponse.statusCode). Retrying API call to \(url.lastPathComponent)...")
//                        // Retry the request - Increment attempt count
//                        self.makeAPIRequest(
//                            url: url, method: method, body: body, responseType: responseType,
//                            currentAttempt: currentAttempt + 1,
//                            maxAttempts: maxAttempts, completion: completion
//                        )
//                    } else {
//                        print("Token refresh failed after \(httpResponse.statusCode). Aborting API call to \(url.lastPathComponent).")
//                        completion(.failure(APIError.authenticationFailed))
//                        // Force logout if auth fails persistently even after refresh attempt
//                        DispatchQueue.main.async { self.logout() }
//                    }
//                }
//                return // Exit this dataTask closure to allow refresh and retry
//            }
//
//            // Check for other non-successful status codes
//            guard (200...299).contains(httpResponse.statusCode) else {
//                let errorDetails = self.extractErrorDetails(from: data, statusCode: httpResponse.statusCode)
//                completion(.failure(APIError.httpError(statusCode: httpResponse.statusCode, details: errorDetails)))
//                return
//            }
//
//            // Handle successful response (2xx)
//            guard let data = data else {
//                // If status is 2xx but no data, it might be valid (e.g., 204 No Content)
//                 if httpResponse.statusCode == 204 && T.self == EmptyResponse.self {
//                     if let empty = EmptyResponse() as? T {
//                         completion(.success(empty))
//                     } else {
//                         completion(.failure(APIError.decodingError(nil))) // Should not happen
//                     }
//                 } else {
//                    completion(.failure(APIError.noData))
//                 }
//                return
//            }
//
//            // --- Decode Successful Response Data ---
//            do {
//                let decoder = JSONDecoder()
//                // Add custom decoding strategies if needed (e.g., date decoding)
//                // decoder.dateDecodingStrategy = .iso8601
//                let decodedObject = try decoder.decode(T.self, from: data)
//                completion(.success(decodedObject))
//            } catch {
//                print("API JSON Decoding Error for \(T.self) from \(url.lastPathComponent): \(error)")
//                print("Raw response data: \(String(data: data, encoding: .utf8) ?? "Unable to decode data")")
//                completion(.failure(APIError.decodingError(error)))
//            }
//        }.resume()
//    }
//
//    // MARK: - Logout
//    // Clears authentication state, tokens, and cancels ongoing sessions.
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
//            self.clearTokens() // Remove from persistent storage
//            // Cancel any ongoing web auth session
//            self.currentWebAuthSession?.cancel()
//            self.currentWebAuthSession = nil
//            self.currentPKCEVerifier = nil // Clear PKCE state
//        }
//    }
//
//    // MARK: - Token Persistence (UserDefaults - USE KEYCHAIN IN PRODUCTION!)
//    // Saves the current tokens to UserDefaults. Replace with Keychain for security.
//    private func saveTokens(tokens: StoredTokens) {
//        // --- !!! WARNING: Using UserDefaults is insecure for tokens !!! ---
//        // --- Replace with Keychain Access for production apps.        ---
//        do {
//            let encoded = try JSONEncoder().encode(tokens)
//            UserDefaults.standard.set(encoded, forKey: SpotifyConstants.tokenUserDefaultsKey)
//            print("Tokens saved to UserDefaults (Insecure - Use Keychain!)")
//        } catch {
//            print("Error: Failed to encode tokens for saving: \(error)")
//        }
//    }
//
//    // Loads tokens from UserDefaults. Replace with Keychain access.
//    private func loadTokens() {
//        // --- !!! WARNING: Using UserDefaults is insecure for tokens !!! ---
//        guard let savedTokensData = UserDefaults.standard.data(forKey: SpotifyConstants.tokenUserDefaultsKey) else {
//            print("No saved tokens found in UserDefaults.")
//            self.currentTokens = nil
//            return
//        }
//
//        do {
//            let decodedTokens = try JSONDecoder().decode(StoredTokens.self, from: savedTokensData)
//            self.currentTokens = decodedTokens
//            print("Tokens loaded from UserDefaults.")
//        } catch {
//            print("Error: Failed to decode saved tokens: \(error). Clearing potentially corrupted data.")
//            clearTokens() // Clear corrupted data
//            self.currentTokens = nil
//        }
//    }
//
//    // Clears tokens from UserDefaults. Replace with Keychain removal.
//    private func clearTokens() {
//        // --- !!! WARNING: Using UserDefaults is insecure for tokens !!! ---
//        UserDefaults.standard.removeObject(forKey: SpotifyConstants.tokenUserDefaultsKey)
//        print("Tokens cleared from UserDefaults.")
//    }
//
//    // MARK: - Error Handling Helpers
//    // Centralized way to set the errorMessage property for the UI and log errors.
//    private func handleError(_ error: Error, prefix: String = "Error:", clearVerifier: Bool = false) {
//        DispatchQueue.main.async {
//            // Use the localizedDescription from the APIError enum or the underlying error
//            let message = (error as? APIError)?.localizedDescription ?? error.localizedDescription
//            self.errorMessage = "\(prefix) \(message)"
//            print("Error Details: \(error)") // Log the full error details
//            if clearVerifier {
//                self.currentPKCEVerifier = nil
//            }
//            // Stop loading indicators on error
//            self.isLoading = false
//            self.isLoadingPlaylists = false
//            self.isLoadingPlaylistTracks = false
//        }
//    }
//    // Overload for simple message strings
//     private func handleError_V1(_ error: APIError, message: String? = nil, clearVerifier: Bool = false) {
//         DispatchQueue.main.async {
//            let displayMessage = message ?? error.localizedDescription ?? "An unknown error occurred."
//            self.errorMessage = displayMessage
//            print("Error: \(displayMessage) (Code: \(error))")
//             if clearVerifier {
//                 self.currentPKCEVerifier = nil
//             }
//             self.isLoading = false
//             self.isLoadingPlaylists = false
//             self.isLoadingPlaylistTracks = false
//         }
//     }
//
//
//    // Sets the playlist-specific error message
//    private func handlePlaylistError(_ error: Error, prefix: String = "Playlist Error:") {
//        DispatchQueue.main.async {
//             let message = (error as? APIError)?.localizedDescription ?? error.localizedDescription
//             self.playlistErrorMessage = "\(prefix) \(message)"
//             print("Playlist Error Details: \(error)")
//             self.isLoadingPlaylists = false // Stop playlist loading
//        }
//    }
//     // Overload for APIError
//     private func handlePlaylistError(_ error: APIError, prefix: String = "Playlist Error:") {
//         DispatchQueue.main.async {
//             self.playlistErrorMessage = "\(prefix) \(error.localizedDescription ?? "Unknown playlist error")"
//             print("Playlist Error: \(error.localizedDescription ?? "Unknown") (Code: \(error))")
//             self.isLoadingPlaylists = false
//         }
//     }
//
//
//    // Sets the playlist track-specific error message
//    private func handlePlaylistTracksError(_ error: Error, prefix: String = "Playlist Tracks Error:") {
//        DispatchQueue.main.async {
//            let message = (error as? APIError)?.localizedDescription ?? error.localizedDescription
//            self.playlistTracksErrorMessage = "\(prefix) \(message)"
//            print("Playlist Tracks Error Details: \(error)")
//             self.isLoadingPlaylistTracks = false // Stop track loading
//        }
//    }
//    // Overload for APIError
//    private func handlePlaylistTracksError(_ error: APIError, prefix: String = "Playlist Tracks Error:") {
//       DispatchQueue.main.async {
//            self.playlistTracksErrorMessage = "\(prefix) \(error.localizedDescription ?? "Unknown track error")"
//            print("Playlist Tracks Error: \(error.localizedDescription ?? "Unknown") (Code: \(error))")
//            self.isLoadingPlaylistTracks = false
//       }
//    }
//
//    // Helper to attempt decoding Spotify's standard error JSON or return basic info
//    private func extractErrorDetails(from data: Data?, statusCode: Int) -> String {
//        guard let data = data, !data.isEmpty else { return "Status code \(statusCode) with no data." }
//
//        // Try decoding Spotify's standard error object first
//        if let spotifyError = try? JSONDecoder().decode(SpotifyErrorResponse.self, from: data),
//           let message = spotifyError.error.message {
//            return message // Return the specific message from Spotify
//        }
//
//        // Fallback to generic JSON error structure (common in OAuth errors)
//        if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
//           let errorDesc = json["error_description"] as? String ?? json["error"] as? String {
//            return errorDesc
//        }
//
//        // Fallback to plain text response if it's not JSON
//        if let text = String(data: data, encoding: .utf8), !text.isEmpty {
//            return text
//        }
//
//        // Final fallback if data cannot be interpreted
//        return "Received status code \(statusCode)."
//    }
//}
//
//// MARK: - ASWebAuthenticationPresentationContextProviding
//// Provides the window anchor for the ASWebAuthenticationSession view controller.
//// Removed unnecessary boilerplate methods.
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
//    // This is the only required method from the protocol we need to implement correctly.
//    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
//        // Find the key window scene to present the authentication session
//        let keyWindow = UIApplication.shared.connectedScenes
//            .filter { $0.activationState == .foregroundActive }
//            .compactMap { $0 as? UIWindowScene }
//            .first?.windows
//            .filter { $0.isKeyWindow }
//            .first
//        return keyWindow ?? ASPresentationAnchor() // Fallback to default anchor
//    }
//}
//
//
//// MARK: - PKCE Helper Extension (Base64 URL Encoding)
//// Adds a helper to Data for Base64 URL encoding (RFC 4648 §5) used in PKCE.
//extension Data {
//    func base64URLEncodedString() -> String {
//        return self.base64EncodedString()
//            .replacingOccurrences(of: "+", with: "-") // Replace '+' with '-'
//            .replacingOccurrences(of: "/", with: "_") // Replace '/' with '_'
//            .replacingOccurrences(of: "=", with: "")  // Remove padding '='
//    }
//}
//
//// MARK: - Main SwiftUI View (Entry Point)
//struct AuthenticationFlowView: View {
//    // Use @StateObject because this view *owns* the instance of SpotifyAuthManager
//    @StateObject var authManager = SpotifyAuthManager()
//
//    var body: some View {
//        // NavigationStack allows pushing detail views like PlaylistDetailView
//        NavigationStack {
//            Group { // Use Group to switch between the logged-in/logged-out views
//                if !authManager.isLoggedIn {
//                    loggedOutView
//                        .navigationTitle("Spotify Login")
//                } else {
//                    loggedInContentView // Shows profile & playlists
//                }
//            }
//            // Define the navigation destination for when a SpotifyPlaylist is pushed
//            .navigationDestination(for: SpotifyPlaylist.self) { playlist in
//                PlaylistDetailView(playlist: playlist) // Navigate to the detail view
//                    .environmentObject(authManager) // Pass the authManager down
//            }
//            // General Loading Overlay (for login process, initial profile fetch)
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
//            // General Error Alert
//            .alert("Error", isPresented: Binding(
//                get: { authManager.errorMessage != nil },
//                set: { if !$0 { authManager.errorMessage = nil } } // Clear error when dismissed
//            ), presenting: authManager.errorMessage) { _ in // Presenting the message string
//                Button("OK") {
//                    authManager.errorMessage = nil // Action on button tap
//                }
//            } message: { message in
//                Text(message) // The actual message text
//            }
//            // Optional: Handle deep links if needed via .onOpenURL { url in ... }
//        }
//    }
//
//    // MARK: - Logged Out View Component
//    private var loggedOutView: some View {
//        VStack(spacing: 30) {
//            Spacer()
//
//            Image(systemName: "music.note.tv.fill") // Example Spotify-esque icon
//                .font(.system(size: 80))
//                .foregroundColor(Color(red: 30/255, green: 215/255, blue: 96/255)) // Spotify Green
//
//            Text("Connect your Spotify account to explore your music.")
//                .font(.title3)
//                .fontWeight(.medium)
//                .multilineTextAlignment(.center)
//                .padding(.horizontal, 40)
//
//            Button {
//                authManager.initiateAuthorization()
//            } label: {
//                HStack {
//                    // Consider adding a Spotify logo image here if available
//                    Text("Log in with Spotify")
//                        .fontWeight(.semibold)
//                        .foregroundColor(.white)
//                }
//                .padding(.vertical, 15)
//                .padding(.horizontal, 40)
//                .background(Color(red: 30/255, green: 215/255, blue: 96/255)) // Spotify Green
//                .cornerRadius(30) // Fully rounded corners
//                .shadow(color: .black.opacity(0.2), radius: 5, y: 3)
//            }
//            .disabled(authManager.isLoading) // Disable button during authentication
//
//            Spacer()
//            Spacer()
//        }
//        .padding()
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .background(Color(.systemBackground)) // Adapt to light/dark mode
//    }
//
//    // MARK: - Logged In Content View Component
//    // This is the main view shown after successful login.
//    private var loggedInContentView: some View {
//        List {
//            // Section for User Profile
//            Section(header: Text("Profile").font(.headline)) {
//                profileSection
//            }
//
//            // Section for Playlists
//            Section(header: Text("My Playlists").font(.headline)) {
//                playlistSection
//            }
//
//            // Section for Actions / Debug
//            Section(header: Text("Account").font(.headline)) {
//                actionSection
//            }
//        }
//        .navigationTitle("Your Spotify") // Set title for the logged-in view
//        .listStyle(.insetGrouped) // Use inset grouped style for better visual separation
//        .refreshable {
//            // Allow pull-to-refresh for profile and the first page of playlists
//            print("Refreshing data...")
//            authManager.fetchUserProfile()
//            authManager.fetchUserPlaylists(loadNextPage: false) // Reset and fetch first page
//        }
//        .onAppear {
//            // Fetch data if missing when the view appears (e.g., after initial login)
//            if authManager.userProfile == nil {
//                authManager.fetchUserProfile()
//            }
//            if authManager.userPlaylists.isEmpty && !authManager.isLoadingPlaylists {
//                 // Avoid fetching if already loading or if playlists already exist
//                authManager.fetchUserPlaylists()
//            }
//        }
//    }
//
//    // MARK: Profile Section (Extracted ViewBuilder)
//    @ViewBuilder
//    private var profileSection: some View {
//        if let profile = authManager.userProfile {
//            HStack(spacing: 15) {
//                // AsyncImage to load profile picture URL
//                AsyncImage(url: URL(string: profile.images?.first?.url ?? "" )) { phase in
//                     switch phase {
//                     case .empty:
//                         ProgressView().frame(width: 60, height: 60) // Placeholder while loading
//                     case .success(let image):
//                         image.resizable()
//                             .aspectRatio(contentMode: .fill)
//                     case .failure:
//                          Image(systemName: "person.circle.fill") // Fallback icon on failure
//                             .resizable()
//                             .aspectRatio(contentMode: .fit)
//                             .foregroundColor(.gray)
//                     @unknown default:
//                         EmptyView()
//                     }
//                 }
//                .frame(width: 60, height: 60)
//                .clipShape(Circle())
//                .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1)) // Subtle border
//
//                VStack(alignment: .leading) {
//                    Text(profile.displayName)
//                        .font(.title2)
//                        .fontWeight(.semibold)
//                    Text(profile.email)
//                        .font(.subheadline)
//                        .foregroundColor(.gray)
//                }
//            }
//            .padding(.vertical, 8) // Add some padding within the row
//        } else if authManager.isLoading {
//            // Loading state specific to profile fetch might be needed if separate
//             HStack { Spacer(); ProgressView(); Text("Loading Profile..."); Spacer() }.padding(.vertical)
//        } else if authManager.errorMessage != nil && authManager.userProfile == nil {
//            // Show error specific to profile loading if possible, or rely on general alert
//             Text("Could not load profile.")
//                 .foregroundColor(.red)
//                 .padding(.vertical)
//         } else {
//             // Placeholder if not loading and no profile (shouldn't happen often)
//             Text("Profile not available.")
//                 .foregroundColor(.gray)
//                 .padding(.vertical)
//         }
//    }
//
//    // MARK: Playlist Section (Extracted ViewBuilder)
//    @ViewBuilder
//    private var playlistSection: some View {
//        if authManager.isLoadingPlaylists && authManager.userPlaylists.isEmpty {
//            // Show loading indicator only during the initial playlist load
//            HStack { Spacer(); ProgressView(); Text("Loading Playlists..."); Spacer() }.padding(.vertical)
//        } else if let errorMsg = authManager.playlistErrorMessage {
//            // Show playlist-specific error message
//            Text(errorMsg)
//                .foregroundColor(.red)
//                .padding()
//        } else if authManager.userPlaylists.isEmpty && !authManager.isLoadingPlaylists {
//            // Show message if user has no playlists
//            Text("You don't have any playlists yet.")
//                .foregroundColor(.gray)
//                .padding()
//        } else {
//            // Display the list of fetched playlists
//            ForEach(authManager.userPlaylists) { playlist in
//                 // NavigationLink triggers navigationDestination defined earlier
//                NavigationLink(value: playlist) {
//                    PlaylistRow(playlist: playlist) // Use extracted row view
//                }
//                 .onAppear {
//                      // Trigger fetching the next page when the last item appears
//                      if playlist.id == authManager.userPlaylists.last?.id && authManager.playlistNextPageUrl != nil && !authManager.isLoadingPlaylists {
//                           print("Reached end of playlist list, loading next page...")
//                           authManager.fetchUserPlaylists(loadNextPage: true)
//                      }
//                  }
//            }
//
//            // Show loading indicator at the bottom ONLY when loading the *next* page
//            if authManager.isLoadingPlaylists && !authManager.userPlaylists.isEmpty {
//                ProgressView()
//                    .padding()
//                    .frame(maxWidth: .infinity, alignment: .center)
//            }
//        }
//    }
//
//    // MARK: Action Section (Extracted ViewBuilder)
//    @ViewBuilder
//    private var actionSection: some View {
//        // Manual Token Refresh Button (for debugging/testing)
//        Button("Refresh Token Manually") {
//            authManager.refreshToken()
//        }
//        .disabled(authManager.currentTokens?.refreshToken == nil || authManager.isLoading) // Disable if no refresh token or already loading
//
//        // Logout Button
//        Button("Log Out", role: .destructive) { // Use destructive role for logout
//            authManager.logout()
//        }
//        .tint(.red) // Emphasize logout action
//
//        // Optional: Debug Token Info (Collapse/Expand)
//        if let tokens = authManager.currentTokens {
//            DisclosureGroup("Token Details (Debug)") {
//                VStack(alignment: .leading, spacing: 5) {
//                    Text("Access Token:").font(.caption.weight(.bold))
//                    Text(tokens.accessToken)
//                        .font(.caption)
//                        .lineLimit(1)
//                        .truncationMode(.middle) // Show middle part if long
//
//                    if let expiry = tokens.expiryDate {
//                        Text("Expires:")
//                            .font(.caption.weight(.bold)) + // Combine bold label with value
//                        Text(" \(expiry, style: .relative) ago (\(expiry, style: .time))")
//                            .font(.caption)
//                            .foregroundColor(expiry <= Date() ? .red : .green) // Highlight expired
//                    } else {
//                         Text("Expiry: Unknown").font(.caption).foregroundColor(.orange)
//                    }
//
//                    Text("Refresh Token:")
//                        .font(.caption.weight(.bold)) +
//                    Text(tokens.refreshToken != nil ? " Present" : " Missing")
//                         .font(.caption)
//                         .foregroundColor(tokens.refreshToken != nil ? .primary : .red)
//
//                }
//                .padding(.top, 5)
//             }
//             .font(.callout) // Style for the DisclosureGroup label
//         }
//    }
//}
//
//// MARK: - Helper Row View for Playlist List
//struct PlaylistRow: View {
//    let playlist: SpotifyPlaylist
//
//    var body: some View {
//        HStack(spacing: 12) {
//            // Playlist Cover Image
//            AsyncImage(url: URL(string: playlist.images?.first?.url ?? "")) { phase in
//                switch phase {
//                case .empty:
//                    Color.gray.opacity(0.3).frame(width: 45, height: 45).cornerRadius(4) // Placeholder color
//                        .overlay(ProgressView().scaleEffect(0.5))
//                case .success(let image):
//                    image.resizable()
//                         .aspectRatio(contentMode: .fill)
//                case .failure:
//                     Image(systemName: "music.note.list") // Fallback icon
//                         .resizable()
//                         .aspectRatio(contentMode: .fit)
//                         .padding(8)
//                         .frame(width: 45, height: 45)
//                         .background(Color.gray.opacity(0.2))
//                         .foregroundColor(.gray)
//                         .cornerRadius(4)
//                 @unknown default:
//                     EmptyView()
//                 }
//            }
//            .frame(width: 45, height: 45)
//            .cornerRadius(4)
//
//             // Playlist Name and Details
//            VStack(alignment: .leading) {
//                Text(playlist.name)
//                    .lineLimit(1)
//                    .font(.headline)
//                Text("By \(playlist.owner.displayName ?? "Spotify") • \(playlist.tracks.total) track\(playlist.tracks.total == 1 ? "" : "s")")
//                    .font(.caption)
//                    .foregroundColor(.gray)
//                    .lineLimit(1)
//            }
//
//            Spacer() // Pushes collaborator icon to the right
//
//            // Indicator for collaborative playlists
//            if playlist.collaborative {
//                Image(systemName: "person.2.fill")
//                    .foregroundColor(.blue)
//                     .imageScale(.small) // Make icon slightly smaller
//                     .accessibilityLabel("Collaborative playlist")
//            }
//        }
//         .padding(.vertical, 4) // Small padding within the row
//    }
//}
//
//
//// MARK: - Playlist Detail SwiftUI View
//struct PlaylistDetailView: View {
//    @EnvironmentObject var authManager: SpotifyAuthManager // Injected from parent
//    let playlist: SpotifyPlaylist // Passed in during navigation
//
//    var body: some View {
//         List {
//              // --- Playlist Header (Sticky Section?) ---
//              // Using Section allows the header to potentially stick if desired,
//              // otherwise, place PlaylistHeaderView directly in List { ... }
//              Section {
//                   PlaylistHeaderView(playlist: playlist)
//                        .padding(.bottom) // Add padding below header inside the section
//              }
//              // Optional: .listRowInsets(EdgeInsets()) to remove default padding around header
//
//              // --- Tracks Section ---
//              Section(header: Text("Tracks (\(authManager.currentPlaylistTracks.count))")) {
//                   // Content based on track loading state
//                   tracksListContentView
//              }
//          }
//          .listStyle(.plain) // Use plain style for edge-to-edge content typically
//          .navigationTitle(playlist.name)
//          .navigationBarTitleDisplayMode(.inline) // Keep title compact
//          .onAppear {
//              // Fetch tracks when the view appears, but only if it's for a different playlist
//              // or if tracks haven't been loaded yet for the current one.
//              if authManager.selectedPlaylist?.id != playlist.id || authManager.currentPlaylistTracks.isEmpty {
//                  print("PlaylistDetailView Appearing for \(playlist.name). Fetching tracks.")
//                  authManager.selectedPlaylist = playlist // Update the manager's state
//                  authManager.fetchTracksForPlaylist(playlistID: playlist.id, loadNextPage: false)
//              } else {
//                  print("PlaylistDetailView Appearing for \(playlist.name). Tracks already loaded or loading.")
//              }
//          }
//          .onDisappear {
//              // Clear the detail state *only* if the view disappearing is the one
//              // currently selected in the manager. Prevents clearing if navigating deeper.
//              if authManager.selectedPlaylist?.id == playlist.id {
//                  print("PlaylistDetailView Disappearing for \(playlist.name). Clearing state.")
//                 // Consider if clearing state is always desired on disappear.
//                 // Maybe only clear if navigating BACK? This requires more complex state tracking.
//                 // For simplicity, let's clear it. User can pull-to-refresh if needed.
//                  authManager.clearPlaylistDetailState()
//              }
//          }
//          .refreshable {
//               // Allow pull-to-refresh for the first page of tracks
//               print("Refreshing tracks for playlist \(playlist.id)")
//               authManager.fetchTracksForPlaylist(playlistID: playlist.id, loadNextPage: false)
//           }
//    }
//
//    // Extracted ViewBuilder for tracks list content logic
//    @ViewBuilder
//    private var tracksListContentView: some View {
//        if authManager.isLoadingPlaylistTracks && authManager.currentPlaylistTracks.isEmpty {
//             // Loading indicator for initial tracks load
//             HStack { Spacer(); ProgressView(); Text("Loading Tracks..."); Spacer() }.padding(.vertical)
//         } else if let errorMsg = authManager.playlistTracksErrorMessage {
//             // Show track-specific error message
//             Text(errorMsg)
//                 .foregroundColor(.red)
//                 .padding()
//         } else if authManager.currentPlaylistTracks.isEmpty && !authManager.isLoadingPlaylistTracks {
//              // Show message if playlist is empty or tracks couldn't load (and no error shown)
//              Text("This playlist is empty or tracks could not be loaded.")
//                   .foregroundColor(.gray)
//                   .padding()
//         } else {
//             // Display the fetched tracks
//             ForEach(authManager.currentPlaylistTracks) { playlistTrack in
//                  // Safely use the track - already filtered in manager
//                  if let track = playlistTrack.track {
//                      TrackRowView(track: track) // Use dedicated row view
//                          .onAppear {
//                              // Trigger TRACKS pagination when last item appears
//                              if playlistTrack.id == authManager.currentPlaylistTracks.last?.id &&
//                                     authManager.playlistTracksNextPageUrl != nil &&
//                                     !authManager.isLoadingPlaylistTracks {
//                                   print("Reached end of tracks list, loading next page...")
//                                   authManager.fetchTracksForPlaylist(playlistID: playlist.id, loadNextPage: true)
//                              }
//                          }
//                  }
//                  // We filter out nil tracks in the manager now, so no need for else here.
//              }
//
//             // Show loading indicator at the bottom ONLY when loading the *next* page of tracks
//             if authManager.isLoadingPlaylistTracks && !authManager.currentPlaylistTracks.isEmpty {
//                  ProgressView().padding().frame(maxWidth: .infinity, alignment: .center)
//             }
//         }
//    }
//}
//
//// MARK: - Helper Views for Playlist Detail View
//
//// Header View for the Playlist Detail screen
//struct PlaylistHeaderView: View {
//    let playlist: SpotifyPlaylist
//
//    var body: some View {
//        HStack(alignment: .center, spacing: 15) {
//            // Playlist Cover Image
//             AsyncImage(url: URL(string: playlist.images?.first?.url ?? "")) { phase in
//                 switch phase {
//                 case .empty:
//                     Color.gray.opacity(0.3).frame(width: 120, height: 120).cornerRadius(8)
//                         .overlay(ProgressView())
//                 case .success(let image):
//                      image.resizable().aspectRatio(contentMode: .fill)
//                         .frame(width: 120, height: 120)
//                          .cornerRadius(8)
//                          .shadow(radius: 5)
//                 case .failure:
//                      Image(systemName: "music.note.list")
//                          .resizable().aspectRatio(contentMode: .fit).padding(20)
//                          .frame(width: 120, height: 120)
//                          .background(Color.gray.opacity(0.2)).foregroundColor(.gray)
//                           .cornerRadius(8)
//                  @unknown default:
//                      EmptyView()
//                  }
//             }
//             .frame(width: 120, height: 120) // Fixed size for the image
//
//             // Playlist Metadata
//             VStack(alignment: .leading, spacing: 4) {
//                 Text(playlist.name)
//                      .font(.title2)
//                      .fontWeight(.bold)
//                      .lineLimit(2)
//
//                 // Show description only if it's not nil and not empty
//                 if let description = playlist.description, !description.isEmpty, description != "<null>" { // Handle potential "<null>" string
//                     Text(description.trimmingCharacters(in: .whitespacesAndNewlines)) // Trim whitespace
//                         .font(.caption)
//                         .foregroundColor(.gray)
//                         .lineLimit(3) // Limit description lines
//                 }
//
//                 // Owner and track count
//                 Text("By \(playlist.owner.displayName ?? "Unknown") • \(playlist.tracks.total) track\(playlist.tracks.total == 1 ? "" : "s")")
//                     .font(.caption)
//                     .foregroundColor(.secondary)
//
//                 // Collaborative indicator
//                 if playlist.collaborative {
//                     Text("Collaborative")
//                         .font(.caption)
//                         .fontWeight(.medium)
//                         .foregroundColor(.blue)
//                         .padding(.horizontal, 6)
//                         .padding(.vertical, 2)
//                         .background(Color.blue.opacity(0.1))
//                         .cornerRadius(10)
//                 }
//                 Spacer() // Push content up if needed
//             }
//             Spacer() // Push content to the left
//         }
//         .padding(.vertical) // Add padding around the header content
//    }
//}
//
//// Row View for displaying a single track in the playlist detail list
//struct TrackRowView: View {
//    let track: SpotifyTrack
//
//    var body: some View {
//        HStack(spacing: 12) {
//            // Album Art Thumbnail
//             AsyncImage(url: URL(string: track.album.images?.last?.url ?? track.album.images?.first?.url ?? "")) { phase in // Try smaller image first
//                 switch phase {
//                 case .empty:
//                      Color.gray.opacity(0.2).frame(width: 45, height: 45).cornerRadius(4)
//                           .overlay(ProgressView().scaleEffect(0.5))
//                 case .success(let image):
//                      image.resizable().aspectRatio(contentMode: .fill)
//                 case .failure:
//                      Image(systemName: "music.mic") // Fallback icon
//                           .resizable().aspectRatio(contentMode: .fit).padding(10)
//                           .background(Color.gray.opacity(0.1)).foregroundColor(.gray)
//                  @unknown default:
//                      EmptyView()
//                  }
//             }
//             .frame(width: 45, height: 45)
//             .cornerRadius(4)
//
//             // Track Name and Artist
//            VStack(alignment: .leading) {
//                Text(track.name)
//                   .lineLimit(1)
//                   .font(.body)
//                Text(track.artistNames) // Use helper for artist string
//                    .font(.caption)
//                    .foregroundColor(.gray)
//                    .lineLimit(1)
//            }
//
//            Spacer() // Push duration to the right
//
//             // Explicit tag and Duration
//             HStack(spacing: 8) {
//                 if track.explicit ?? false {
//                     Image(systemName: "e.square.fill")
//                          .foregroundColor(.gray)
//                          .font(.caption)
//                          .accessibilityLabel("Explicit")
//                 }
//                 Text(track.formattedDuration) // Use helper for duration
//                     .font(.caption)
//                     .foregroundColor(.gray)
//                     .frame(minWidth: 35, alignment: .trailing) // Ensure consistent width for duration
//             }
//        }
//         .padding(.vertical, 6) // Padding within the row
//         .opacity((track.isPlayable ?? true) ? 1.0 : 0.5) // Dim unplayable tracks
//          // Could add context menu here for actions (add to queue, etc.)
//    }
//}
//
//// MARK: - Previews
//
//// Preview for the main entry point view (Logged Out state)
//#Preview("Logged Out") {
//    AuthenticationFlowView()
//}
//
//// Preview for Logged In state (Loading content)
//#Preview("Logged In - Loading") {
//    let manager = SpotifyAuthManager()
//    manager.isLoggedIn = true
//    manager.isLoading = true // Simulate general loading
//    manager.userProfile = nil
//    manager.userPlaylists = []
//    manager.isLoadingPlaylists = true // Simulate playlist loading too
//    return AuthenticationFlowView(authManager: manager)
//}
//
//// Preview for Logged In state with Profile and some Playlist data
//#Preview("Logged In - Playlists") {
//    let manager = SpotifyAuthManager()
//    manager.isLoggedIn = true
//    manager.userProfile = SpotifyUserProfile(id: "p_user", displayName: "List User", email: "list@example.com", images: nil, externalUrls: [:])
//    // Basic sample playlists
//    let owner = SpotifyPlaylistOwner(id: "test_owner", displayName: "Test Owner", externalUrls: [:])
//    let tracksInfo = PlaylistTracksInfo(href: "", total: 10)
//    manager.userPlaylists = [
//        SpotifyPlaylist(id: "pl1", name: "First Sample Playlist", description: "Desc 1", owner: owner, collaborative: false, tracks: tracksInfo, images: nil, externalUrls: [:], publicPlaylist: true),
//        SpotifyPlaylist(id: "pl2", name: "Second Collaborative", description: "Desc 2", owner: owner, collaborative: true, tracks: tracksInfo, images: nil, externalUrls: [:], publicPlaylist: false)
//    ]
////    manager.playlistNextPageUrl = "http://example.com/next" // Simulate next page exists
//    return AuthenticationFlowView(authManager: manager)
//}
//
//// Preview for Logged In state with a playlist specific error
//#Preview("Logged In - Playlist Error") {
//    let manager = SpotifyAuthManager()
//    manager.isLoggedIn = true
//    manager.userProfile = SpotifyUserProfile(id: "p_user", displayName: "Error User", email: "error@example.com", images: nil, externalUrls: [:])
//    manager.playlistErrorMessage = "Could not reach Spotify servers (Simulated Network Error)"
//    return AuthenticationFlowView(authManager: manager)
//}
//
//
//// --- Previews for Playlist Detail View ---
//
//// Sample Playlist Data for Detail Previews
//let sampleDetailPlaylist = SpotifyPlaylist(
//    id: "pl_detail_1",
//    name: "Awesome Mix Vol. 1",
//    description: "Legendary mixtape featuring classics from the 70s and 80s.",
//    owner: SpotifyPlaylistOwner(id: "peter", displayName: "Peter Quill", externalUrls: [:]),
//    collaborative: false,
//    tracks: PlaylistTracksInfo(href: "https://api.spotify.com/v1/playlists/pl_detail_1/tracks", total: 12),
//    images: [SpotifyImage(url: "https://via.placeholder.com/300/771796", height: 300, width: 300)], // Placeholder image URL
//    externalUrls: [:],
//    publicPlaylist: true
//)
//
//// Sample Track Data for Detail Previews
//let sampleArtistDetail = SpotifyArtistSimple(id: "art1", name: "Various Artists", externalUrls: [:])
//let sampleAlbumDetail = SpotifyAlbumSimple(id: "alb1", name: "Awesome Mix Vol. 1 (Soundtrack)", images: [SpotifyImage(url: "https://via.placeholder.com/100/771796", height: 100, width: 100)], externalUrls: [:])
//let sampleDetailTracks: [SpotifyPlaylistTrack] = [
//    SpotifyPlaylistTrack(addedAt: "2024-01-01T12:00:00Z", track: SpotifyTrack(id: "trk1", name: "Hooked on a Feeling", artists: [sampleArtistDetail], album: sampleAlbumDetail, durationMs: 172000, trackNumber: 1, discNumber: 1, explicit: false, externalUrls: [:], uri: "spotify:track:trk1", isPlayable: true)),
//    SpotifyPlaylistTrack(addedAt: "2024-01-01T12:01:00Z", track: SpotifyTrack(id: "trk2", name: "Go All the Way", artists: [sampleArtistDetail], album: sampleAlbumDetail, durationMs: 198000, trackNumber: 2, discNumber: 1, explicit: false, externalUrls: [:], uri: "spotify:track:trk2", isPlayable: true)),
//    SpotifyPlaylistTrack(addedAt: "2024-01-01T12:02:00Z", track: SpotifyTrack(id: "trk3", name: "Spirit in the Sky", artists: [sampleArtistDetail], album: sampleAlbumDetail, durationMs: 242000, trackNumber: 3, discNumber: 1, explicit: false, externalUrls: [:], uri: "spotify:track:trk3", isPlayable: false)), // Example unplayable
//    SpotifyPlaylistTrack(addedAt: "2024-01-01T12:03:00Z", track: nil) // Example unavailable track
//]
//
//
//#Preview("Playlist Detail - Loading Tracks") {
//    let manager = SpotifyAuthManager()
//    manager.isLoggedIn = true // Manager needs base state
//    manager.selectedPlaylist = sampleDetailPlaylist // Set the playlist being viewed
//    manager.isLoadingPlaylistTracks = true // Simulate loading
//    manager.currentPlaylistTracks = [] // No tracks loaded yet
//
//    // Embed in NavigationView for realistic presentation
//    return NavigationView {
//        PlaylistDetailView(playlist: sampleDetailPlaylist)
//            .environmentObject(manager) // Inject the manager
//    }
//}
//
//#Preview("Playlist Detail - With Tracks") {
//    let manager = SpotifyAuthManager()
//    manager.isLoggedIn = true
//    manager.selectedPlaylist = sampleDetailPlaylist
//    manager.isLoadingPlaylistTracks = false
//    manager.currentPlaylistTracks = sampleDetailTracks // Populate with sample tracks
//    // Simulate next page to test UI trigger for pagination (optional)
//    // manager.playlistTracksNextPageUrl = "https://example.com/next_tracks"
//
//    return NavigationView { // Embed for title display
//        PlaylistDetailView(playlist: sampleDetailPlaylist)
//            .environmentObject(manager)
//    }
//}
//
//#Preview("Playlist Detail - Track Error") {
//    let manager = SpotifyAuthManager()
//    manager.isLoggedIn = true
//    manager.selectedPlaylist = sampleDetailPlaylist
//    manager.playlistTracksErrorMessage = "Failed to load tracks (Simulated Server Error)"
//
//    return NavigationView {
//        PlaylistDetailView(playlist: sampleDetailPlaylist)
//            .environmentObject(manager)
//    }
//}
