////
////  AuthenticationFlowView_V2.swift
////  MyApp
////
////  Created by Cong Le on 4/7/25.
////
//
//import SwiftUI
//import Combine // For ObservableObject
//import CryptoKit // For PKCE SHA256
//import AuthenticationServices // For ASWebAuthenticationSession
//
//// MARK: - Configuration (MUST REPLACE)
//struct SpotifyConstants {
//    static let clientID = "adb2903676fc47b8aac6acf1d4a19df6" // <-- REPLACE THIS
//    static let redirectURI = "myapp://callback" // <-- REPLACE THIS (e.g., "myapp://callback")
//    static let scopes = [
//        "user-read-private",
//        "user-read-email",
//        "playlist-read-private", // Needed for fetching user playlists
//        "playlist-read-collaborative", // Optional: To see collaborative playlists
//        "playlist-modify-public", // Example scope
//        "playlist-modify-private", // Example scope
//        "user-library-read", // Example scope for liked songs
//        "user-top-read", // Example scope for top items
//        "user-modify-playback-state" // *** ADD THIS SCOPE *** Needed for Web API playback control (Optional future feature)
//        
//        
//        // Add other scopes your app needs
//    ]
//    static let scopeString = scopes.joined(separator: " ")
//    
//    static let authorizationEndpoint = URL(string: "https://accounts.spotify.com/authorize")!
//    static let tokenEndpoint = URL(string: "https://accounts.spotify.com/api/token")!
//    static let userProfileEndpoint = URL(string: "https://api.spotify.com/v1/me")!
//    // New endpoint for user playlists
//    static let userPlaylistsEndpoint = URL(string: "https://api.spotify.com/v1/me/playlists")!
//    
//    // Base URL for playlist tracks - requires appending /tracks
//    static let playlistBaseEndpoint = "https://api.spotify.com/v1/playlists/"
//    
//    static let tokenUserDefaultsKey = "spotifyTokens"
//}
//
//// MARK: - Data Models
//
//// Existing Models (TokenResponse, StoredTokens, SpotifyUserProfile, SpotifyImage) remain the same...
//
//struct TokenResponse: Codable {
//    let accessToken: String
//    let tokenType: String
//    let expiresIn: Int
//    let refreshToken: String? // May not always be returned on refresh
//    let scope: String
//    
//    // Calculated property for expiry date
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
////// Simple model for storing tokens persistently (Use Keychain in production!)
////struct StoredTokens: Codable {
////    let accessToken: String
////    let refreshToken: String?
////    let expiryDate: Date?
////}
//
//struct SpotifyUserProfile: Codable, Identifiable {
//    let id: String
//    let displayName: String
//    let email: String
//    let images: [SpotifyImage]?
//    let externalUrls: [String: String]? // Added for potential use
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
//struct SpotifyImage: Codable {
//    let url: String
//    let height: Int?
//    let width: Int?
//}
//
//
//// --- New Models for Playlists ---
//
//// Generic Paging Object used by many Spotify endpoints
//struct SpotifyPagingObject<T: Codable>: Codable {
//    let href: String
//    let items: [T]
//    let limit: Int
//    let next: String? // URL for the next page of items
//    let offset: Int
//    let previous: String? // URL for the previous page of items
//    let total: Int
//}
//
//// Simplified Playlist Owner Model
//struct SpotifyPlaylistOwner: Codable, Identifiable {
//    let id: String
//    let displayName: String? // Might be nil sometimes
//    let externalUrls: [String: String]?
//    
//    enum CodingKeys: String, CodingKey {
//        case id
//        case displayName = "display_name"
//        case externalUrls = "external_urls"
//    }
//}
//
//// Playlist Track Information (simplified)
//struct PlaylistTracksInfo: Codable {
//    let href: String // Link to the full tracks endpoint for this playlist
//    let total: Int
//}
//
//// Updated to be Hashable for NavigationLink value
//struct SpotifyPlaylist: Codable, Identifiable, Hashable {
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
//    
//    let id: String
//    let name: String
//    let description: String? // Can be empty
//    let owner: SpotifyPlaylistOwner // Note: Owner might need Hashable conformance if Playlist is passed as value
//    let collaborative: Bool
//    let tracks: PlaylistTracksInfo
//    let images: [SpotifyImage]? // Playlists can have cover images
//    let externalUrls: [String: String]?
//    let publicPlaylist: Bool? // Renamed from `public` to avoid keyword clash
//    
//    // Make non-Hashable properties optional or provide default hash values if needed
//    // For simplicity here, relying on id is usually sufficient if owners/tracks don't impact equality *for navigation purposes*.
//    
//    enum CodingKeys: String, CodingKey {
//        case id
//        case name
//        case description
//        case owner
//        case collaborative
//        case tracks
//        case images
//        case externalUrls = "external_urls"
//        case publicPlaylist = "public" // Map JSON key "public" to Swift property "publicPlaylist"
//    }
//}
//
//// Type alias for the specific paging object containing playlists
//typealias SpotifyPlaylistList = SpotifyPagingObject<SpotifyPlaylist>
//
//// --- Models for Playlist Tracks ---
//
//// Simplified Artist Object
//struct SpotifyArtistSimple: Codable, Identifiable, Hashable {
//    let id: String
//    let name: String
//    let externalUrls: [String: String]?
//    
//    func hash(into hasher: inout Hasher) { hasher.combine(id) }
//    static func == (lhs: SpotifyArtistSimple, rhs: SpotifyArtistSimple) -> Bool { lhs.id == rhs.id }
//    
//    enum CodingKeys: String, CodingKey {
//        case id, name, externalUrls = "external_urls"
//    }
//}
//
//// Simplified Album Object (mainly for images)
//struct SpotifyAlbumSimple: Codable, Identifiable, Hashable {
//    let id: String
//    let name: String
//    let images: [SpotifyImage]? // Images might need Hashable too if needed
//    let externalUrls: [String: String]?
//    
//    func hash(into hasher: inout Hasher) { hasher.combine(id) }
//    static func == (lhs: SpotifyAlbumSimple, rhs: SpotifyAlbumSimple) -> Bool { lhs.id == rhs.id }
//    
//    enum CodingKeys: String, CodingKey {
//        case id, name, images, externalUrls = "external_urls"
//    }
//}
//
//// The actual Track Object
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
//    let uri: String // Spotify URI for the track
//    
//    var formattedDuration: String {
//        let totalSeconds = durationMs / 1000
//        let minutes = totalSeconds / 60
//        let seconds = totalSeconds % 60
//        return String(format: "%d:%02d", minutes, seconds)
//    }
//    
//    // Simplified artists string
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
//    }
//}
//
//// The object wrapping the track within a playlist response
//struct SpotifyPlaylistTrack: Codable, Identifiable {
//    var id: String { track?.id ?? UUID().uuidString } // Use track ID if available, fallback for safety
//    let addedAt: String? // Date string like "2014-09-01T12:00:00Z"
//    //Track can be null if user cannot play it (e.g. market restriction) - Handle this!
//    let track: SpotifyTrack?
//    
//    enum CodingKeys: String, CodingKey {
//        case track
//        case addedAt = "added_at"
//    }
//}
//
//// The full response for playlist tracks endpoint
//typealias SpotifyPlaylistTrackList = SpotifyPagingObject<SpotifyPlaylistTrack>
//
//// Add Hashable conformance to models used in navigation links if passing objects
//// Note: Deep Hashable conformance can be complex. Often just using the `id` is sufficient
//// for distinguishing navigation destinations if you fetch details based on ID.
//// The example below adds Hashable conformance where needed for navigation.
//
//// Add Hashable conformance to sub-models if the parent is Hashable and uses them
//extension SpotifyImage: Hashable {
//    func hash(into hasher: inout Hasher) {
//        hasher.combine(url)
//    }
//    static func == (lhs: SpotifyImage, rhs: SpotifyImage) -> Bool {
//        lhs.url == rhs.url
//    }
//}
//extension PlaylistTracksInfo: Hashable {
//    // Hash based on relevant fields (href might change, total is good)
//    func hash(into hasher: inout Hasher) {
//        hasher.combine(total)
//        hasher.combine(href)
//    }
//    static func == (lhs: PlaylistTracksInfo, rhs: PlaylistTracksInfo) -> Bool {
//        lhs.total == rhs.total && lhs.href == rhs.href // Or simplify if href isn't needed for equality
//    }
//}
//
//extension SpotifyPlaylistOwner: Hashable {
//    func hash(into hasher: inout Hasher) {
//        hasher.combine(id)
//    }
//    static func == (lhs: SpotifyPlaylistOwner, rhs: SpotifyPlaylistOwner) -> Bool {
//        lhs.id == rhs.id
//    }
//}
//
//
//
//// MARK: - Authentication Manager (ObservableObject)
//class SpotifyAuthManager: ObservableObject {
//    
//    // --- Authentication & Profile State ---
//    @Published var isLoggedIn: Bool = false
//    //    @Published var currentTokens: StoredTokens? = nil
//    
//    // MARK: - Token Storage Strategies
//    /// Strategy for handling standard access/refresh tokens (`StoredTokens`).
//    private let standardTokenStorage: any TokenStorageStrategy<StoredTokens>
//    
//    /// Strategy for handling the secondary, keychain-specific tokens (`KeychainStoredTokens`).
//    private let keychainSpecificTokenStorage: any TokenStorageStrategy<KeychainStoredTokens>
//    
//    // MARK: - Token State Properties
//    /// Holds the currently loaded standard tokens.
//    @Published var currentTokens: StoredTokens? = nil
//    
//    /// Holds the currently loaded keychain-specific tokens.
//    @Published var currentKeychainTokens: KeychainStoredTokens? = nil // Add state for the new type
//    
//    @Published var userProfile: SpotifyUserProfile? = nil
//    @Published var isLoading: Bool = false
//    @Published var errorMessage: String? = nil
//    
//    // --- New State for Playlists ---
//    @Published var userPlaylists: [SpotifyPlaylist] = []
//    @Published var isLoadingPlaylists: Bool = false // Loading main playlist list
//    @Published var playlistErrorMessage: String? = nil
//    var playlistNextPageUrl: String? = nil // For pagination
//    
//    // --- Playlist Detail (Tracks) State ---
//    @Published var selectedPlaylist: SpotifyPlaylist? = nil // Holds the playlist being viewed
//    @Published var currentPlaylistTracks: [SpotifyPlaylistTrack] = []
//    @Published var isLoadingPlaylistTracks: Bool = false // Loading tracks for *selected* playlist
//    @Published var playlistTracksErrorMessage: String? = nil
//    var playlistTracksNextPageUrl: String? = nil
//    
//    private var currentPKCEVerifier: String?
//    private var currentWebAuthSession: ASWebAuthenticationSession?
//    
//    // --- Initialization ---
//    init() {
//        // --- Instantiate the desired Strategies ---
//        // Configure EACH strategy with UNIQUE Keychain identifiers
//        
//        // 1. Strategy for StoredTokens (Access/Refresh)
//        // Option A: Use Keychain (Recommended)
//        self.standardTokenStorage = KeychainTokenStorageStrategy<StoredTokens>(
//            service: "com.yourapp.spotify.standardtokens", // <<-- UNIQUE SERVICE Name
//            account: "userStandardSpotifyTokens"          // <<-- UNIQUE ACCOUNT Name
//        )
//        // Option B: Use UserDefaults (Less Secure - Example Only)
//        // self.standardTokenStorage = UserDefaultsTokenStorageStrategy<StoredTokens>(key: "spotifyStandardTokens_v2")
//        
//        // 2. Strategy for KeychainStoredTokens (Your custom type)
//        // Option A: Use Keychain (Most likely scenario)
////        self.keychainSpecificTokenStorage = KeychainTokenStorageStrategy<KeychainStoredTokens>(
////            service: "com.yourapp.spotify.keychainspecifictokens", // <<-- DIFFERENT, UNIQUE SERVICE
////            account: "userKeychainSpecificData"                   // <<-- DIFFERENT, UNIQUE ACCOUNT
////        )
//        // Option B: Use UserDefaults (If applicable for this type)
//         self.keychainSpecificTokenStorage = UserDefaultsTokenStorageStrategy<KeychainStoredTokens>(key: "spotifyKeychainTokens_v2")
//        
//        // --- End Strategy Instantiation ---
//        
//        // --- Load initial tokens using the strategies ---
//        loadInitialTokens()
//        
//        // --- Initial logic based on STANDARD tokens ---
//        if let tokens = currentTokens, let expiry = tokens.expiryDate, expiry > Date() {
//            self.isLoggedIn = true // isLoggedIn likely depends on standard tokens
//            fetchUserProfile()
//            fetchUserPlaylists()
//        } else if currentTokens != nil { // If standard tokens exist but expired/invalid
//            refreshToken { [weak self] success in // Refresh depends on standard refresh token
//                DispatchQueue.main.async {
//                    if success {
//                        self?.fetchUserProfile()
//                        self?.fetchUserPlaylists()
//                    } else {
//                        self?.logout()
//                    }
//                }
//            }
//        }
//    }
////    init() {
////        loadTokens()
////        if let tokens = currentTokens, let expiry = tokens.expiryDate, expiry > Date() {
////            self.isLoggedIn = true
////            // Automatically fetch profile and playlists if logged in on init
////            fetchUserProfile()
////            fetchUserPlaylists() // Fetch initial playlists
////        } else if currentTokens != nil {
////            refreshToken { [weak self] success in
////                DispatchQueue.main.async { // Ensure UI updates on main thread
////                    if success {
////                        self?.fetchUserProfile()
////                        self?.fetchUserPlaylists() // Fetch initial playlist *list* after refresh
////                    } else {
////                        self?.logout()
////                    }
////                }
////            }
////        }
////    }
//    // MARK: - Token Loading (Initial)
//    private func loadInitialTokens() {
//        self.currentTokens = standardTokenStorage.loadTokens()
//        print("Loaded standard tokens using \(type(of: standardTokenStorage)): \(currentTokens != nil ? "Found" : "Not Found")")
//        
//        self.currentKeychainTokens = keychainSpecificTokenStorage.loadTokens()
//        print("Loaded keychain-specific tokens using \(type(of: keychainSpecificTokenStorage)): \(currentKeychainTokens != nil ? "Found" : "Not Found")")
//    }
//    
//    // MARK: - Saving Tokens (Update existing or add new methods)
//    
//    /// Saves standard tokens using its configured storage strategy.
//    private func saveStandardTokens(_ tokens: StoredTokens) {
//        if standardTokenStorage.saveTokens(tokens) {
//            print("Saved standard tokens successfully.")
//            DispatchQueue.main.async { self.currentTokens = tokens }
//        } else {
//            print("Failed to save standard tokens.")
//            // Handle error appropriately
//        }
//    }
//    
//    /// Saves keychain-specific tokens using its configured storage strategy.
//    /// CALL THIS METHOD when you generate/receive KeychainStoredTokens.
//    func saveKeychainSpecificTokens(_ tokens: KeychainStoredTokens) { // Make public or internal as needed
//        if keychainSpecificTokenStorage.saveTokens(tokens) {
//            print("Saved keychain-specific tokens successfully.")
//            DispatchQueue.main.async { self.currentKeychainTokens = tokens }
//        } else {
//            print("Failed to save keychain-specific tokens.")
//            // Handle error appropriately
//        }
//    }
//    // MARK: - Clearing Tokens (Update Logout)
//    
//    /// Clears *all* managed tokens using their respective strategies.
//    private func clearAllTokensUsingStrategies() {
//        print("Clearing all stored tokens...")
//        if !standardTokenStorage.clearTokens() {
//            print("Warning: Failed to clear standard tokens storage.")
//        } else {
//            print("Standard tokens storage cleared.")
//        }
//        if !keychainSpecificTokenStorage.clearTokens() {
//            print("Warning: Failed to clear keychain-specific tokens storage.")
//        } else {
//            print("Keychain-specific tokens storage cleared.")
//        }
//        
//        // Clear in-memory references
//        DispatchQueue.main.async {
//            self.currentTokens = nil
//            self.currentKeychainTokens = nil
//            self.isLoggedIn = false // Likely tied to clearing standard tokens
//        }
//    }
//    
//    // --- Update methods that handle standard token responses ---
//    private func processSuccessfulTokenResponse(_ tokenResponse: TokenResponse, explicitRefreshToken: String? = nil) {
//        let refreshTokenToStore = tokenResponse.refreshToken ?? explicitRefreshToken ?? currentTokens?.refreshToken
//        let tokensToStore = StoredTokens(
//            accessToken: tokenResponse.accessToken,
//            refreshToken: refreshTokenToStore,
//            expiryDate: tokenResponse.expiryDate
//        )
//        // Save only the STANDARD tokens here
//        saveStandardTokens(tokensToStore)
//        // Decide when/how KeychainStoredTokens are created/saved separately
//    }
//    
//    
//    // --- PKCE Helper Functions ---
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
//    // --- Authentication Flow (initiateAuthorization, exchangeCodeForToken remain largely the same) ---
//    func initiateAuthorization() {
//        guard !isLoading else { return }
//        isLoading = true
//        errorMessage = nil
//        userProfile = nil // Clear old profile
//        userPlaylists = [] // Clear old playlists
//        playlistErrorMessage = nil
//        playlistNextPageUrl = nil
//        
//        let verifier = generateCodeVerifier()
//        guard let challenge = generateCodeChallenge(from: verifier) else {
//            handleError("Could not start authentication (PKCE).")
//            isLoading = false
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
//            URLQueryItem(name: "code_challenge", value: challenge),
//            // Optional: Add show_dialog=true to always force login prompt
//            URLQueryItem(name: "show_dialog", value: "true")
//        ]
//        
//        guard let authURL = components?.url else {
//            handleError("Could not construct authorization URL.")
//            isLoading = false
//            return
//        }
//        
//        let scheme = URL(string: SpotifyConstants.redirectURI)?.scheme
//        
//        currentWebAuthSession = ASWebAuthenticationSession(
//            url: authURL,
//            callbackURLScheme: scheme) { [weak self] callbackURL, error in
//                guard let self = self else { return }
//                // Always ensure UI updates happen on the main thread
//                DispatchQueue.main.async {
//                    self.isLoading = false // Stop general loading indicator
//                    self.handleAuthCallback(callbackURL: callbackURL, error: error)
//                }
//            }
//        
//        currentWebAuthSession?.presentationContextProvider = self
//        currentWebAuthSession?.prefersEphemeralWebBrowserSession = true // Recommended for privacy
//        
//        DispatchQueue.main.async {
//            self.currentWebAuthSession?.start()
//        }
//    }
//    
//    private func handleAuthCallback(callbackURL: URL?, error: Error?) {
//        if let error = error {
//            if let authError = error as? ASWebAuthenticationSessionError, authError.code == .canceledLogin {
//                print("Auth cancelled by user.")
//                self.errorMessage = "Login cancelled."
//            } else {
//                print("Auth Error: \(error.localizedDescription)")
//                self.errorMessage = "Authentication failed: \(error.localizedDescription)"
//            }
//            return
//        }
//        
//        guard let successURL = callbackURL else {
//            print("Auth Error: No callback URL received.")
//            self.errorMessage = "Authentication failed: No callback URL."
//            return
//        }
//        
//        // Extract the authorization code
//        let queryItems = URLComponents(string: successURL.absoluteString)?.queryItems
//        if let code = queryItems?.first(where: { $0.name == "code" })?.value {
//            print("Successfully received authorization code.")
//            exchangeCodeForToken(code: code)
//        } else {
//            print("Error: Could not find authorization code in callback URL.")
//            self.errorMessage = "Could not get authorization code from Spotify."
//            // Check for Spotify-specific errors in the callback
//            if let spotifyError = queryItems?.first(where: { $0.name == "error" })?.value {
//                print("Spotify error in callback: \(spotifyError)")
//                self.errorMessage = "Spotify denied the request: \(spotifyError)"
//            }
//        }
//    }
//    
//    
//    private func exchangeCodeForToken(code: String) {
//        guard let verifier = currentPKCEVerifier else {
//            handleError("Authentication failed (missing verifier).", clearVerifier: true)
//            return
//        }
//        guard !isLoading else { return }
//        isLoading = true
//        errorMessage = nil
//        
//        makeTokenRequest(grantType: "authorization_code", code: code, verifier: verifier) { [weak self] result in
//            guard let self = self else { return }
//            DispatchQueue.main.async {
//                self.isLoading = false
//                self.currentPKCEVerifier = nil // Important: Clear verifier after use
//                switch result {
//                case .success(let tokenResponse):
//                    print("Successfully exchanged code for tokens.")
//                    self.processSuccessfulTokenResponse(tokenResponse)
//                    // Fetch user data after successful login
//                    self.fetchUserProfile()
//                    self.fetchUserPlaylists() // Fetch initial playlists
//                case .failure(let error):
//                    print("Token Exchange Error: \(error.localizedDescription)")
//                    self.errorMessage = "Failed to get tokens: \(error.localizedDescription)"
//                }
//            }
//        }
//    }
//    
//    // --- Token Refresh ---
//    // Added a completion handler to know if refresh was successful
//    func refreshToken(completion: ((Bool) -> Void)? = nil) {
//        guard !isLoading else {
//            completion?(false)
//            return
//        }
//        guard let refreshToken = currentTokens?.refreshToken else {
//            print("Error: No refresh token available for refresh.")
//            logout() // Force re-login if no refresh token exists
//            completion?(false)
//            return
//        }
//        
//        isLoading = true
//        errorMessage = nil
//        
//        makeTokenRequest(grantType: "refresh_token", refreshToken: refreshToken) { [weak self] result in
//            guard let self = self else {
//                completion?(false); return
//            }
//            DispatchQueue.main.async {
//                self.isLoading = false
//                switch result {
//                case .success(let tokenResponse):
//                    print("Successfully refreshed tokens.")
//                    // Preserve the old refresh token if the response doesn't contain a new one
//                    let updatedRefreshToken = tokenResponse.refreshToken ?? self.currentTokens?.refreshToken
//                    self.processSuccessfulTokenResponse(tokenResponse, explicitRefreshToken: updatedRefreshToken)
//                    completion?(true)
//                case .failure(let error):
//                    print("Token Refresh Error: \(error.localizedDescription)")
//                    self.errorMessage = "Session expired. Please log in again. (\(error.localizedDescription))"
//                    // Force logout on persistent refresh failure (e.g., invalid_grant)
//                    if let apiError = error as? APIError, apiError.isAuthError {
//                        self.logout()
//                    }
//                    completion?(false)
//                }
//            }
//        }
//    }
//    
//    // --- Centralized Token Request Logic ---
//    private func makeTokenRequest(grantType: String, code: String? = nil, verifier: String? = nil, refreshToken: String? = nil, completion: @escaping (Result<TokenResponse, Error>) -> Void) {
//        
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
//        if let code = code, let verifier = verifier, grantType == "authorization_code" {
//            queryItems.append(contentsOf: [
//                URLQueryItem(name: "code", value: code),
//                URLQueryItem(name: "redirect_uri", value: SpotifyConstants.redirectURI),
//                URLQueryItem(name: "code_verifier", value: verifier)
//            ])
//        } else if let refreshToken = refreshToken, grantType == "refresh_token" {
//            queryItems.append(URLQueryItem(name: "refresh_token", value: refreshToken))
//        } else {
//            completion(.failure(APIError.invalidRequest(message: "Invalid parameters for token request.")))
//            return
//        }
//        
//        components.queryItems = queryItems
//        request.httpBody = components.query?.data(using: .utf8)
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
//                if let json = try? JSONSerialization.jsonObject(with: data, options: []) { print("Received JSON for Token Error: ", json) }
//                completion(.failure(APIError.decodingError(error)))
//            }
//        }.resume()
//    }
//    
//    // Helper to process successful token response and update state
////    private func processSuccessfulTokenResponse(_ tokenResponse: TokenResponse, explicitRefreshToken: String? = nil) {
////        let newRefreshToken = explicitRefreshToken ?? tokenResponse.refreshToken
////        let newStoredTokens = StoredTokens(
////            accessToken: tokenResponse.accessToken,
////            refreshToken: newRefreshToken, // Use the explicitly passed or the one from response
////            expiryDate: tokenResponse.expiryDate
////        )
////        self.currentTokens = newStoredTokens
////        self.saveTokens(tokens: newStoredTokens)
////        self.isLoggedIn = true
////        self.errorMessage = nil // Clear general errors on success
////    }
//    
//    // --- Fetch User Profile ---
//    func fetchUserProfile() {
//        makeAPIRequest(
//            url: SpotifyConstants.userProfileEndpoint,
//            responseType: SpotifyUserProfile.self,
//            currentAttempt: 1,
//            maxAttempts: 2 // Allow one retry after token refresh
//        ) { [weak self] result in
//            guard let self = self else { return }
//            DispatchQueue.main.async {
//                self.isLoading = false // Assuming general loading might cover profile fetch initially
//                switch result {
//                case .success(let profile):
//                    self.userProfile = profile
//                    self.errorMessage = nil // Clear error on success
//                    print("Successfully fetched user profile for \(profile.displayName)")
//                case .failure(let error):
//                    print("Fetch Profile Error: \(error.localizedDescription)")
//                    self.errorMessage = "Could not fetch profile: \(error.localizedDescription)"
//                }
//            }
//        }
//    }
//    
//    
//    // --- Fetch User Playlists ---
//    // Fetches the first page or the next page if available
//    func fetchUserPlaylists(loadNextPage: Bool = false) {
//        guard !isLoadingPlaylists else { return } // Prevent concurrent loads
//        guard isLoggedIn, currentTokens?.accessToken != nil else {
//            handlePlaylistError("Cannot fetch playlists: Not logged in.")
//            return
//        }
//        
//        var urlToFetch: URL? = SpotifyConstants.userPlaylistsEndpoint
//        
//        if loadNextPage {
//            guard let nextUrlString = playlistNextPageUrl else {
//                print("Playlist Fetch: No next page URL available.")
//                return // Nothing more to load
//            }
//            urlToFetch = URL(string: nextUrlString)
//        } else {
//            // Reset playlists if fetching the first page
//            userPlaylists = []
//            playlistNextPageUrl = nil
//            playlistErrorMessage = nil
//        }
//        
//        guard let finalUrl = urlToFetch else {
//            handlePlaylistError("Invalid URL for fetching playlists.")
//            return
//        }
//        
//        isLoadingPlaylists = true
//        playlistErrorMessage = nil
//        
//        makeAPIRequest(
//            url: finalUrl,
//            responseType: SpotifyPlaylistList.self, // Expecting the PagingObject
//            currentAttempt: 1,
//            maxAttempts: 2
//        ) { [weak self] result in
//            guard let self = self else { return }
//            DispatchQueue.main.async {
//                self.isLoadingPlaylists = false
//                switch result {
//                case .success(let playlistResponse):
//                    if loadNextPage {
//                        self.userPlaylists.append(contentsOf: playlistResponse.items)
//                        print("Loaded next page of playlists. Total: \(self.userPlaylists.count)")
//                    } else {
//                        self.userPlaylists = playlistResponse.items
//                        print("Fetched initial playlists. Count: \(self.userPlaylists.count)")
//                    }
//                    // Update the URL for the *next* page
//                    self.playlistNextPageUrl = playlistResponse.next
//                    self.playlistErrorMessage = nil // Clear error on success
//                    
//                case .failure(let error):
//                    print("Fetch Playlists Error: \(error.localizedDescription)")
//                    self.playlistErrorMessage = "Could not fetch playlists: \(error.localizedDescription)"
//                }
//            }
//        }
//    }
//    
//    
//    // --- NEW: Fetch Tracks for a SPECIFIC Playlist ---
//    func fetchTracksForPlaylist(playlistID: String, loadNextPage: Bool = false) {
//        guard !isLoadingPlaylistTracks else { return } // Use specific loading flag
//        guard isLoggedIn, currentTokens?.accessToken != nil else {
//            handlePlaylistTracksError("Cannot fetch tracks: Not logged in.")
//            return
//        }
//        
//        var urlToFetch: URL?
//        
//        if loadNextPage {
//            guard let nextUrlString = playlistTracksNextPageUrl, let nextUrl = URL(string: nextUrlString) else {
//                print("Playlist Tracks Fetch: No next page URL available or invalid.")
//                return // Nothing more to load for this specific playlist
//            }
//            urlToFetch = nextUrl
//        } else {
//            // Reset tracks when fetching the first page for THIS playlist
//            currentPlaylistTracks = []
//            playlistTracksNextPageUrl = nil
//            playlistTracksErrorMessage = nil // Clear track-specific errors
//            
//            // Construct the initial URL for the specific playlist's tracks
//            let tracksEndpointString = SpotifyConstants.playlistBaseEndpoint + "\(playlistID)/tracks"
//            // Optionally add fields parameter to limit data: ?fields=items(track(name,id,artists(name),album(images),duration_ms))
//            urlToFetch = URL(string: tracksEndpointString)
//        }
//        
//        guard let finalUrl = urlToFetch else {
//            handlePlaylistTracksError("Invalid URL constructed for fetching tracks of playlist \(playlistID).")
//            return
//        }
//        
//        isLoadingPlaylistTracks = true
//        playlistTracksErrorMessage = nil // Clear specific error
//        
//        print("Fetching tracks from: \(finalUrl.absoluteString)") // Debugging
//        
//        makeAPIRequest(
//            url: finalUrl,
//            responseType: SpotifyPlaylistTrackList.self, // Expecting tracks paging object
//            currentAttempt: 1,
//            maxAttempts: 2
//        ) { [weak self] result in
//            guard let self = self else { return }
//            DispatchQueue.main.async {
//                self.isLoadingPlaylistTracks = false
//                switch result {
//                case .success(let trackResponse):
//                    if loadNextPage {
//                        self.currentPlaylistTracks.append(contentsOf: trackResponse.items)
//                    } else {
//                        self.currentPlaylistTracks = trackResponse.items
//                    }
//                    self.playlistTracksNextPageUrl = trackResponse.next
//                    self.playlistTracksErrorMessage = nil // Clear track error on success
//                    print("Fetched tracks page for playlist \(playlistID). Total tracks loaded: \(self.currentPlaylistTracks.count)")
//                    
//                    // Filter out potential nil tracks immediately after fetching
//                    self.currentPlaylistTracks = self.currentPlaylistTracks.filter { $0.track != nil }
//                    
//                case .failure(let error):
//                    let errorDesc = (error as? APIError)?.errorDescription ?? error.localizedDescription
//                    print("Fetch Playlist Tracks Error for \(playlistID): \(errorDesc)")
//                    // Set the specific error message for the detail view
//                    self.playlistTracksErrorMessage = "Could not fetch tracks: \(errorDesc)"
//                }
//            }
//        }
//    }
//    
//    // --- NEW: Clear Playlist Detail State ---
//    // Call this when navigating away from the detail view
//    func clearPlaylistDetailState() {
//        DispatchQueue.main.async {
//            print("Clearing playlist detail state.")
//            self.selectedPlaylist = nil
//            self.currentPlaylistTracks = []
//            self.playlistTracksErrorMessage = nil
//            self.playlistTracksNextPageUrl = nil
//            self.isLoadingPlaylistTracks = false // Ensure loading is reset
//        }
//    }
//    
//    
//    
//    // --- Generic API Request Function ---
//    // Handles making the request, adding auth header, decoding, and retrying on token expiry
//    private func makeAPIRequest<T: Decodable>(
//        url: URL,
//        method: String = "GET", // Default to GET
//        body: Data? = nil,      // For POST/PUT requests
//        responseType: T.Type,
//        currentAttempt: Int,
//        maxAttempts: Int,
//        completion: @escaping (Result<T, Error>) -> Void
//    ) {
//        guard currentAttempt <= maxAttempts else {
//            completion(.failure(APIError.maxRetriesReached))
//            return
//        }
//        
//        guard let accessToken = currentTokens?.accessToken else {
//            completion(.failure(APIError.notLoggedIn))
//            return
//        }
//        
//        // --- Check for Token Expiry before making the call ---
//        if let expiryDate = currentTokens?.expiryDate, expiryDate <= Date() {
//            print("Token likely expired, attempting refresh before API call to \(url.lastPathComponent)...")
//            refreshToken { [weak self] success in
//                guard let self = self else {
//                    completion(.failure(APIError.unknown)); return
//                }
//                if success {
//                    print("Token refreshed successfully. Retrying API call to \(url.lastPathComponent)...")
//                    // Important: Use the *updated* access token for the retry
//                    self.makeAPIRequest(
//                        url: url,
//                        method: method,
//                        body: body,
//                        responseType: responseType,
//                        currentAttempt: currentAttempt + 1, // Increment attempt count
//                        maxAttempts: maxAttempts,
//                        completion: completion
//                    )
//                } else {
//                    print("Token refresh failed. Aborting API call to \(url.lastPathComponent).")
//                    completion(.failure(APIError.tokenRefreshFailed))
//                }
//            }
//            return // Exit the current function call to let the refresh happen
//        }
//        // --- End Token Expiry Check ---
//        
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = method
//        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
//        if let body = body, (method == "POST" || method == "PUT") {
//            request.setValue("application/json", forHTTPHeaderField: "Content-Type") // Assuming JSON body
//            request.httpBody = body
//        }
//        
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
//            // --- Handle Auth Error (401/403) by Refreshing Token ---
//            if (httpResponse.statusCode == 401 || httpResponse.statusCode == 403) {
//                print("Received \(httpResponse.statusCode) for \(url.lastPathComponent). Token might be invalid/expired. Attempting refresh...")
//                refreshToken { [weak self] success in
//                    guard let self = self else {
//                        completion(.failure(APIError.unknown)); return
//                    }
//                    if success {
//                        print("Token refreshed. Retrying API call to \(url.lastPathComponent)...")
//                        // Retry the request - Increment attempt count
//                        self.makeAPIRequest(
//                            url: url,
//                            method: method,
//                            body: body,
//                            responseType: responseType,
//                            currentAttempt: currentAttempt + 1,
//                            maxAttempts: maxAttempts,
//                            completion: completion
//                        )
//                    } else {
//                        print("Token refresh failed after \(httpResponse.statusCode). Aborting API call to \(url.lastPathComponent).")
//                        // Pass specific error indicating auth failure after refresh attempt
//                        completion(.failure(APIError.authenticationFailed))
//                        // Optional: Log out the user immediately if auth fails persistently
//                        DispatchQueue.main.async { self.logout() }
//                    }
//                }
//                return // Exit the current dataTask closure to allow refresh and retry
//            }
//            // --- End Auth Error Handling ---
//            
//            
//            guard (200...299).contains(httpResponse.statusCode) else {
//                let errorDetails = self.extractErrorDetails(from: data, statusCode: httpResponse.statusCode)
//                completion(.failure(APIError.httpError(statusCode: httpResponse.statusCode, details: errorDetails)))
//                return
//            }
//            
//            guard let data = data else {
//                completion(.failure(APIError.noData))
//                return
//            }
//            
//            // Special case: If expecting no data (e.g., 204 No Content)
//            if data.isEmpty && T.self == EmptyResponse.self {
//                if let empty = EmptyResponse() as? T {
//                    completion(.success(empty))
//                } else {
//                    completion(.failure(APIError.decodingError(nil))) // Should not happen
//                }
//                return
//            }
//            
//            
//            do {
//                let decodedObject = try JSONDecoder().decode(T.self, from: data)
//                completion(.success(decodedObject))
//            } catch {
//                print("API JSON Decoding Error for \(T.self) from \(url.lastPathComponent): \(error)")
//                print("Raw response data: \(String(data: data, encoding: .utf8) ?? "Unable to decode data")")
//                completion(.failure(APIError.decodingError(error)))
//            }
//        }.resume()
//    }
//    
//    
//    // --- Logout ---
//    func logout() {
//        DispatchQueue.main.async {
//            self.isLoggedIn = false
//            self.currentTokens = nil
//            self.userProfile = nil
//            self.errorMessage = nil
//            self.userPlaylists = [] // Clear playlists on logout
//            
//            
//            // Clear playlist detail state
//            self.clearPlaylistDetailState()
//            
//            
//            // Clear playlist list state
//            self.playlistErrorMessage = nil
//            self.isLoading = false // Clear general loading
//            
//            self.isLoadingPlaylists = false
//            self.playlistNextPageUrl = nil
//            self.clearTokens()
//            
//            // --- Clear ALL tokens using the strategies ---
//            self.clearAllTokensUsingStrategies()
//            // --- End Strategy Clearing ---
//            
//            
//            // Cancel any ongoing web auth session
//            self.currentWebAuthSession?.cancel()
//            self.currentWebAuthSession = nil
//            self.currentPKCEVerifier = nil
//            print("User logged out, all token strategies cleared.")
//        }
//    }
//    
//    // --- Token Persistence (UserDefaults - USE KEYCHAIN IN PRODUCTION!) ---
//    private func saveTokens(tokens: StoredTokens) {
//        // IMPORTANT: Use Keychain for storing tokens in a real application!
//        // UserDefaults is not secure for sensitive data like refresh tokens.
//        if let encoded = try? JSONEncoder().encode(tokens) {
//            UserDefaults.standard.set(encoded, forKey: SpotifyConstants.tokenUserDefaultsKey)
//            print("Tokens saved to UserDefaults (Insecure - Use Keychain in Production).")
//        } else {
//            print("Error: Failed to encode tokens for saving.")
//        }
//    }
//    
//    private func loadTokens() {
//        if let savedTokens = UserDefaults.standard.data(forKey: SpotifyConstants.tokenUserDefaultsKey) {
//            if let decodedTokens = try? JSONDecoder().decode(StoredTokens.self, from: savedTokens) {
//                self.currentTokens = decodedTokens
//                print("Tokens loaded from UserDefaults.")
//                return
//            } else {
//                print("Error: Failed to decode saved tokens. Clearing potentially corrupted data.")
//                clearTokens() // Clear corrupted data
//            }
//        }
//        print("No saved tokens found in UserDefaults.")
//        self.currentTokens = nil
//    }
//    
//    private func clearTokens() {
//        UserDefaults.standard.removeObject(forKey: SpotifyConstants.tokenUserDefaultsKey)
//        print("Tokens cleared from UserDefaults.")
//    }
//    
//    // --- Error Handling Helpers ---
//    private func handleError(_ message: String, clearVerifier: Bool = false) {
//        DispatchQueue.main.async {
//            self.errorMessage = message
//            if clearVerifier {
//                self.currentPKCEVerifier = nil
//            }
//        }
//        print("Error: \(message)")
//    }
//    
//    // Specific helper for playlist LIST errors
//    private func handlePlaylistError(_ message: String) {
//        DispatchQueue.main.async {
//            self.playlistErrorMessage = message
//        }
//        print("Playlist Error: \(message)")
//    }
//    
//    
//    
//    // Specific helper for playlist TRACK errors
//    private func handlePlaylistTracksError(_ message: String) {
//        DispatchQueue.main.async { self.playlistTracksErrorMessage = message }
//        print("Playlist Tracks Error: \(message)")
//    }
//    
//    
//    
//    private func extractErrorDetails(from data: Data?, statusCode: Int) -> String {
//        guard let data = data else { return "Status code \(statusCode)" }
//        // Try decoding Spotify's standard error object
//        if let spotifyError = try? JSONDecoder().decode(SpotifyErrorResponse.self, from: data) {
//            return spotifyError.error.message ?? "Status code \(statusCode) (Spotify Error)"
//        }
//        // Fallback for OAuth errors (different structure)
//        if let oauthError = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
//            let errorDesc = oauthError["error_description"] as? String
//            let errorType = oauthError["error"] as? String
//            var details = "Status code \(statusCode)"
//            if let type = errorType { details += ", Type: \(type)" }
//            if let desc = errorDesc { details += ", Desc: \(desc)" }
//            return details
//        }
//        // Fallback to plain text
//        if let text = String(data: data, encoding: .utf8), !text.isEmpty {
//            return text
//        }
//        return "Status code \(statusCode) (Unknown error format)"
//    }
//}
//
//// MARK: - API Error Enum
//// Define custom errors for better handling
//enum APIError: Error, LocalizedError {
//    case invalidRequest(message: String)
//    case networkError(Error)
//    case invalidResponse
//    case httpError(statusCode: Int, details: String)
//    case noData
//    case decodingError(Error?)
//    case notLoggedIn
//    case tokenRefreshFailed
//    case authenticationFailed // Specifically after a refresh attempt fails
//    case maxRetriesReached
//    case unknown
//    
//    var errorDescription: String? {
//        switch self {
//        case .invalidRequest(let message): return "Invalid request: \(message)"
//        case .networkError(let error): return "Network error: \(error.localizedDescription)"
//        case .invalidResponse: return "Invalid response from server."
//        case .httpError(let statusCode, let details): return "HTTP Error \(statusCode): \(details)"
//        case .noData: return "No data received from server."
//        case .decodingError: return "Failed to decode server response."
//        case .notLoggedIn: return "User is not logged in."
//        case .tokenRefreshFailed: return "Could not refresh session token."
//        case .authenticationFailed: return "Authentication failed."
//        case .maxRetriesReached: return "Maximum retry attempts reached."
//        case .unknown: return "An unknown error occurred."
//        }
//    }
//    
//    // Helper to check if it's an auth-related HTTP error
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
//// Model for Spotify's standard JSON error response
//struct SpotifyErrorResponse: Codable {
//    let error: SpotifyErrorDetail
//}
//struct SpotifyErrorDetail: Codable {
//    let status: Int
//    let message: String?
//}
//
//// Model for representing an empty successful response (e.g., 204 No Content)
//struct EmptyResponse: Codable {}
//
//
//// MARK: - ASWebAuthenticationPresentationContextProviding
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
//    // Use the key window as the presentation anchor
//    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
//        // Updated to find the key window more reliably
//        let keyWindow = UIApplication.shared.connectedScenes
//            .filter({$0.activationState == .foregroundActive})
//            .map({$0 as? UIWindowScene})
//            .compactMap({$0})
//            .first?.windows
//            .filter({$0.isKeyWindow}).first
//        return keyWindow ?? ASPresentationAnchor()
//    }
//}
//
//
//// MARK: - PKCE Helper Extension
//extension Data {
//    func base64URLEncodedString() -> String {
//        return self.base64EncodedString()
//            .replacingOccurrences(of: "+", with: "-")
//            .replacingOccurrences(of: "/", with: "_")
//            .replacingOccurrences(of: "=", with: "")
//    }
//}
//
//// MARK: - SwiftUI View
//struct AuthenticationFlowView: View {
//    // Use @StateObject if this view creates the instance,
//    // Use @ObservedObject if it's passed in (like from the App struct)
//    @StateObject var authManager = SpotifyAuthManager()
//    
//    var body: some View {
//        NavigationStack {
//            Group { // Use Group to switch between major views
//                if !authManager.isLoggedIn {
//                    loggedOutView
//                        .navigationTitle("Spotify Login")
//                } else {
//                    loggedInContentView
//                        .navigationTitle("Your Spotify")
//                }
//            }
//            // Place navigationDestination here for the Playlist type
//            .navigationDestination(for: SpotifyPlaylist.self) { playlist in
//                PlaylistDetailView(playlist: playlist) // Pass the selected playlist
//                    .environmentObject(authManager) // Pass the manager down
//            }
//            .overlay { // Show loading indicator overlay
//                if authManager.isLoading {
//                    VStack {
//                        ProgressView("Authenticating...")
//                            .padding()
//                            .background(Color(.systemBackground).opacity(0.8))
//                            .cornerRadius(10)
//                    }
//                }
//            }
//            .alert("Error", isPresented: Binding(get: { authManager.errorMessage != nil }, set: { if !$0 { authManager.errorMessage = nil } }), presenting: authManager.errorMessage) { message in
//                Button("OK") { authManager.errorMessage = nil }
//            } message: { message in
//                Text(message)
//            }
//            
//        }
//        // Optional: Handle URL callback if needed at this level
//        // .onOpenURL { url in
//        //     // Pass the URL to the manager if it needs to handle deep links post-auth
//        // }
//    }
//    
//    // MARK: Logged Out View
//    private var loggedOutView: some View {
//        VStack {
//            Spacer() // Pushes content to center
//            
//            Text("Connect your Spotify account to continue.")
//                .font(.headline)
//                .multilineTextAlignment(.center)
//                .padding()
//            
//            Button {
//                authManager.initiateAuthorization()
//            } label: {
//                HStack {
//                    Image(systemName: "music.note.list") // Placeholder
//                        .foregroundColor(.white)
//                    Text("Log in with Spotify")
//                        .fontWeight(.semibold)
//                        .foregroundColor(.white)
//                }
//                .padding(.vertical, 12)
//                .padding(.horizontal, 25)
//                .background(Color(red: 30/255, green: 215/255, blue: 96/255)) // Spotify Green
//                .cornerRadius(30) // More rounded
//                .shadow(radius: 5)
//            }
//            .disabled(authManager.isLoading) // Disable while loading
//            
//            Spacer() // Pushes content to center
//            Spacer() // Add more space at bottom maybe
//        }
//        .padding()
//    }
//    
//    // MARK: Logged In Content View
//    private var loggedInContentView: some View {
//        List {
//            // Section for User Profile
//            Section(header: Text("Profile")) {
//                profileSection
//            }
//            
//            // Section for Playlists
//            Section(header: Text("My Playlists")) {
//                playlistSection
//            }
//            
//            // Section for Actions / Debug
//            Section(header: Text("Account Actions")) {
//                actionSection
//            }
//        }
//        .listStyle(InsetGroupedListStyle()) // Nicer grouping
//        .refreshable {
//            // Allow pull-to-refresh for profile and playlists
//            print("Refreshing data...")
//            authManager.fetchUserProfile()
//            authManager.fetchUserPlaylists(loadNextPage: false) // Fetch first page on refresh
//        }
//        .onAppear {
//            // Fetch data only if it's missing when the view appears
//            if authManager.userProfile == nil {
//                authManager.fetchUserProfile()
//            }
//            if authManager.userPlaylists.isEmpty {
//                authManager.fetchUserPlaylists()
//            }
//        }
//    }
//    
//    // MARK: Profile Section (Extracted)
//    @ViewBuilder // Allows returning different view types
//    private var profileSection: some View {
//        if let profile = authManager.userProfile {
//            HStack {
//                AsyncImage(url: URL(string: profile.images?.first?.url ?? "" )) { image in
//                    image.resizable()
//                        .aspectRatio(contentMode: .fill)
//                        .frame(width: 60, height: 60) // Slightly smaller
//                        .clipShape(Circle())
//                } placeholder: {
//                    Image(systemName: "person.circle.fill")
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//                        .frame(width: 60, height: 60)
//                        .foregroundColor(.gray)
//                }
//                .padding(.trailing, 8)
//                
//                VStack(alignment: .leading) {
//                    Text(profile.displayName)
//                        .font(.headline)
//                    Text(profile.email)
//                        .font(.subheadline)
//                        .foregroundColor(.gray)
//                }
//            }
//            .padding(.vertical, 5) // Add padding within the cell
//        } else {
//            // Show placeholder while loading profile
//            HStack {
//                Spacer()
//                ProgressView()
//                Text("Loading Profile...")
//                Spacer()
//            }.padding()
//        }
//    }
//    
//    // MARK: Playlist Section (Extracted)
//    @ViewBuilder
//    private var playlistSection: some View {
//        if authManager.isLoadingPlaylists && authManager.userPlaylists.isEmpty {
//            HStack { // Loading indicator for initial playlist load
//                Spacer()
//                ProgressView()
//                Text("Loading Playlists...")
//                Spacer()
//            }.padding()
//        } else if let errorMsg = authManager.playlistErrorMessage {
//            Text("Error loading playlists: \(errorMsg)")
//                .foregroundColor(.red)
//                .padding()
//        } else if authManager.userPlaylists.isEmpty && !authManager.isLoadingPlaylists {
//            Text("You don't have any playlists yet.")
//                .foregroundColor(.gray)
//                .padding()
//        } else {
//            // Display fetched playlists
//            ForEach(authManager.userPlaylists) { playlist in
//                NavigationLink(value: playlist) {  // Pass playlist as value
//                    HStack {
//                        AsyncImage(url: URL(string: playlist.images?.first?.url ?? "")) { image in
//                            image.resizable()
//                                .aspectRatio(contentMode: .fill)
//                                .frame(width: 45, height: 45)
//                                .cornerRadius(4)
//                        } placeholder: {
//                            Image(systemName: "music.note.list")
//                                .resizable()
//                                .aspectRatio(contentMode: .fit)
//                                .frame(width: 45, height: 45)
//                                .padding(8)
//                                .background(Color.gray.opacity(0.3))
//                                .foregroundColor(.gray)
//                                .cornerRadius(4)
//                        }
//                        
//                        VStack(alignment: .leading) {
//                            Text(playlist.name).lineLimit(1)
//                            Text("By \(playlist.owner.displayName ?? "Spotify") • \(playlist.tracks.total) tracks")
//                                .font(.caption)
//                                .foregroundColor(.gray)
//                        }
//                        
//                        Spacer()
//                        
//                        // Indicate collaborative playlists
//                        if playlist.collaborative {
//                            Image(systemName: "person.2.fill")
//                                .foregroundColor(.blue)
//                        }
//                    }
//                }
//                
//                // Add pagination trigger
//                if playlist.id == authManager.userPlaylists.last?.id && authManager.playlistNextPageUrl != nil {
//                    // Show a loading indicator or button at the bottom
//                    ProgressView()
//                        .padding()
//                        .frame(maxWidth: .infinity)
//                        .onAppear {
//                            print("Reached end of playlist, loading next page...")
//                            authManager.fetchUserPlaylists(loadNextPage: true)
//                        }
//                }
//            }
//        }
//        
//        // Show loading indicator only when loading the *next* page below the list
//        if authManager.isLoadingPlaylists && !authManager.userPlaylists.isEmpty {
//            ProgressView()
//                .padding()
//                .frame(maxWidth: .infinity)
//        }
//        
//    }
//    
//    // MARK: Action Section (Extracted)
//    private var actionSection: some View {
//        VStack(alignment: .leading, spacing: 15) {
//            // Token Refresh Button
//            Button("Refresh Token") {
//                authManager.refreshToken()
//            }
//            .disabled(authManager.currentTokens?.refreshToken == nil || authManager.isLoading)
//            
//            // Logout Button
//            Button("Log Out", role: .destructive) { // Use destructive role for logout
//                authManager.logout()
//            }
//            
//            // Debug Token Info (Optional)
//            if let tokens = authManager.currentTokens {
//                DisclosureGroup("Token Details (Debug)") {
//                    VStack(alignment: .leading) {
//                        Text("Access Token:").font(.caption.weight(.bold))
//                        Text(tokens.accessToken).font(.caption).lineLimit(1)
//                        if let expiry = tokens.expiryDate {
//                            Text("Expires: \(expiry, style: .relative)")
//                                .font(.caption)
//                                .foregroundColor(expiry <= Date() ? .red : .green) // Highlight expired
//                        }
//                        Text("Refresh Token Present: \(tokens.refreshToken != nil ? "Yes" : "No")")
//                            .font(.caption)
//                            .foregroundColor(tokens.refreshToken != nil ? .primary : .orange)
//                        
//                    }
//                    .padding(.top, 5)
//                }
//                .font(.callout)
//            }
//        }
//        .padding(.vertical, 5) // Add padding within the cell
//    }
//}
//
//// MARK: - NEW: Playlist Detail SwiftUI View
//struct PlaylistDetailView: View {
//    @EnvironmentObject var authManager: SpotifyAuthManager // Inject manager
//    let playlist: SpotifyPlaylist // Passed in during navigation
//    
//    // State for the "Spotify Not Installed" alert
//    @State private var showSpotifyNotInstalledAlert = false
//    
//    var body: some View {
//        List {
//            // --- Playlist Header ---
//            Section {
//                PlaylistHeaderView(playlist: playlist)
//            }
//            
//            // --- Tracks Section ---
//            Section(header: Text("Tracks (\(authManager.currentPlaylistTracks.filter { $0.track != nil }.count))")) { // Show count of valid tracks
//                if authManager.isLoadingPlaylistTracks && authManager.currentPlaylistTracks.isEmpty {
//                    HStack { Spacer(); ProgressView(); Text("Loading Tracks..."); Spacer() }.padding()
//                } else if let errorMsg = authManager.playlistTracksErrorMessage {
//                    Text("Error loading tracks: \(errorMsg)")
//                        .foregroundColor(.red)
//                        .padding()
//                } else if authManager.currentPlaylistTracks.filter({ $0.track != nil }).isEmpty && !authManager.isLoadingPlaylistTracks {
//                    Text("This playlist is empty or tracks could not be loaded.")
//                        .foregroundColor(.gray)
//                        .padding()
//                } else {
//                    // Display fetched tracks
//                    ForEach(authManager.currentPlaylistTracks) { playlistTrack in
//                        // Safely unwrap the track object
//                        if let track = playlistTrack.track {
//                            TrackRowView(track: track) // Use dedicated row view
//                                .contentShape(Rectangle()) // Make entire row tappable
//                                .onTapGesture {
//                                    // --- Action to play track ---
//                                    openTrackInSpotify(track: track)
//                                }
//                                .onAppear { // Trigger pagination for *TRACKS*
//                                    if playlistTrack.id == authManager.currentPlaylistTracks.last?.id && authManager.playlistTracksNextPageUrl != nil && !authManager.isLoadingPlaylistTracks {
//                                        print("Reached end of tracks, loading next page...")
//                                        authManager.fetchTracksForPlaylist(playlistID: playlist.id, loadNextPage: true)
//                                    }
//                                }
//                        } else {
//                            // Optionally display a row indicating a track couldn't be loaded
//                            Text("Track unavailable (\(playlistTrack.id))").foregroundColor(.gray).font(.caption)
//                        }
//                    }
//                    
//                    // Show loading indicator for *TRACKS* pagination
//                    if authManager.isLoadingPlaylistTracks && !authManager.currentPlaylistTracks.isEmpty {
//                        ProgressView().padding().frame(maxWidth: .infinity)
//                    }
//                }
//            }
//        }
//        .navigationTitle(playlist.name)
//        .navigationBarTitleDisplayMode(.inline)
//        .onAppear {
//            // Set the selected playlist in the manager and fetch tracks if not already loaded
//            // Avoid re-fetching if we already have tracks for this specific playlist
//            if authManager.selectedPlaylist?.id != playlist.id || authManager.currentPlaylistTracks.isEmpty {
//                authManager.selectedPlaylist = playlist // Set the currently viewed playlist
//                authManager.fetchTracksForPlaylist(playlistID: playlist.id, loadNextPage: false)
//            }
//        }
//        .onDisappear {
//            // Clear the detail state when navigating away
//            // Only clear if the selected playlist *is* the one we are leaving
//            if authManager.selectedPlaylist?.id == playlist.id {
//                authManager.clearPlaylistDetailState()
//            }
//        }
//        .refreshable {
//            // Allow pull-to-refresh for the first page of tracks
//            print("Refreshing tracks for playlist \(playlist.id)")
//            authManager.fetchTracksForPlaylist(playlistID: playlist.id, loadNextPage: false)
//        }
//        // Alert modifier to inform user if Spotify isn't installed
//        .alert("Spotify Required", isPresented: $showSpotifyNotInstalledAlert) {
//            Button("OK") { } // Just dismiss
//            // Optional: Add button to App Store
//            Button("Get Spotify") {
//                // Replace with Spotify's actual App Store URL
//                if let url = URL(string: "https://apps.apple.com/us/app/spotify-music-and-podcasts/id324684580") { // Example URL
//                    UIApplication.shared.open(url)
//                }
//            }
//        } message: {
//            Text("Please install the Spotify app to play music.")
//        }
//        
//    }
//    
//    // --- Function to open track in Spotify ---
//    private func openTrackInSpotify(track: SpotifyTrack) {
//        let trackURI = track.uri
//        
//        guard let url = URL(string: trackURI) else {
//            print("Error: Invalid track URI: \(track.uri)")
//            // Optionally show a generic error alert here
//            return
//        }
//        
//        // Check if the Spotify app can handle the URI
//        if UIApplication.shared.canOpenURL(url) {
//            print("Opening Spotify for track: \(track.name)")
//            // Open the Spotify app
//            UIApplication.shared.open(url, options: [:]) { success in
//                if !success {
//                    print("Failed to open Spotify URL: \(url).")
//                    // Maybe show an error alert?
//                }
//            }
//        } else {
//            // Spotify is not installed, show the alert
//            print("Spotify app is not installed.")
//            showSpotifyNotInstalledAlert = true
//        }
//    }
//    
//}
//
//// MARK: - Helper Views for Detail View
//
//// Simple Header View for Playlist Detail
//struct PlaylistHeaderView: View {
//    let playlist: SpotifyPlaylist
//    
//    var body: some View {
//        HStack(alignment: .center, spacing: 15) {
//            AsyncImage(url: URL(string: playlist.images?.first?.url ?? "")) { image in
//                image.resizable().aspectRatio(contentMode: .fit)
//            } placeholder: {
//                Image(systemName: "music.note.list")
//                    .resizable().aspectRatio(contentMode: .fit).padding()
//                    .background(Color.gray.opacity(0.3)).foregroundColor(.gray)
//            }
//            .frame(width: 100, height: 100)
//            .cornerRadius(8)
//            .shadow(radius: 4)
//            
//            VStack(alignment: .leading) {
//                Text(playlist.name).font(.headline).lineLimit(2)
//                if let description = playlist.description, !description.isEmpty {
//                    Text(description).font(.caption).foregroundColor(.gray).lineLimit(3)
//                }
//                Text("By \(playlist.owner.displayName ?? "Unknown") • \(playlist.tracks.total) tracks")
//                    .font(.caption2).foregroundColor(.secondary)
//                if playlist.collaborative { Text("Collaborative").font(.caption2).foregroundColor(.blue) }
//            }
//            Spacer() // Push content to left
//        }
//        .padding(.vertical) // Add padding around the header
//    }
//}
//
//// Row View for a Single Track
//struct TrackRowView: View {
//    let track: SpotifyTrack
//    
//    var body: some View {
//        HStack {
//            AsyncImage(url: URL(string: track.album.images?.first?.url ?? "")) { image in
//                image.resizable().aspectRatio(contentMode: .fill)
//            } placeholder: {
//                Image(systemName: "music.mic")
//                    .resizable().aspectRatio(contentMode: .fit).padding(10)
//                    .background(Color.gray.opacity(0.2)).foregroundColor(.gray)
//            }
//            .frame(width: 45, height: 45)
//            .cornerRadius(4)
//            
//            VStack(alignment: .leading) {
//                Text(track.name)
//                    .lineLimit(1)
//                Text(track.artistNames) // Use helper for artist string
//                    .font(.caption)
//                    .foregroundColor(.gray)
//                    .lineLimit(1)
//            }
//            
//            Spacer() // Push duration to the right
//            
//            Text(track.formattedDuration) // Use helper for duration
//                .font(.caption)
//                .foregroundColor(.gray)
//        }
//        .padding(.vertical, 4) // Slight padding within row
//    }
//}
//
//// MARK: - App Entry Point (Example)
//// @main
//// struct SpotifyPKCEApp: App {
////     var body: some Scene {
////         WindowGroup {
////             AuthenticationFlowView()
////         }
////     }
//// }
//
//// MARK: - Previews
//#Preview("Logged Out") {
//    AuthenticationFlowView()
//}
//
//#Preview("Logged In - Loading") {
//    let manager = SpotifyAuthManager()
//    manager.isLoggedIn = true
//    manager.userProfile = nil // Simulate loading profile
//    manager.userPlaylists = []
//    manager.isLoadingPlaylists = true
//    return AuthenticationFlowView(authManager: manager)
//}
//
//
//#Preview("Logged In - Playlist List") {
//    let manager = SpotifyAuthManager()
//    manager.isLoggedIn = true
//    manager.userProfile = SpotifyUserProfile(id: "p_user", displayName: "Preview List User", email: "list@example.com", images: [], externalUrls: [:])
//    manager.userPlaylists = [ /* ... Sample playlist data ... */ ] // Add sample data if needed
//    return AuthenticationFlowView(authManager: manager)
//}
//
//#Preview("Playlist Detail - Loading Tracks") {
//    let manager = SpotifyAuthManager()
//    let samplePlaylist = SpotifyPlaylist(id: "pl_detail_1", name: "Awesome Mix Vol. 1", description: "Legendary mixtape.", owner: SpotifyPlaylistOwner(id: "peter", displayName: "Peter Quill", externalUrls: [:]), collaborative: false, tracks: PlaylistTracksInfo(href: "", total: 12), images: [], externalUrls: [:], publicPlaylist: true)
//    manager.isLoggedIn = true // Manager needs to think it's logged in
//    manager.selectedPlaylist = samplePlaylist // Set the playlist being viewed
//    manager.isLoadingPlaylistTracks = true // Simulate loading
//    manager.currentPlaylistTracks = [] // No tracks loaded yet
//    return PlaylistDetailView(playlist: samplePlaylist)
//        .environmentObject(manager) // Inject the manager
//        .navigationTitle(samplePlaylist.name) // Add title for context
//}
//
//#Preview("Playlist Detail - With Tracks") {
//    let manager = SpotifyAuthManager()
//    let samplePlaylist = SpotifyPlaylist(id: "pl_detail_2", name: "Chill Beats", description: "Focus time.", owner: SpotifyPlaylistOwner(id: "lofi_girl", displayName: "Lofi Girl", externalUrls: [:]), collaborative: false, tracks: PlaylistTracksInfo(href: "", total: 25), images: [], externalUrls: [:], publicPlaylist: true)
//    
//    // Create sample tracks
//    let sampleArtist = SpotifyArtistSimple(id: "art1", name: "Chill Hop", externalUrls: [:])
//    let sampleAlbum = SpotifyAlbumSimple(id: "alb1", name: "Study Vibes", images: [], externalUrls: [:])
//    let sampleTracks: [SpotifyPlaylistTrack] = [
//        SpotifyPlaylistTrack(addedAt: nil, track: SpotifyTrack(id: "trk1", name: "Sunrise", artists: [sampleArtist], album: sampleAlbum, durationMs: 180000, trackNumber: 1, discNumber: 1, explicit: false, externalUrls: [:], uri: "spotify:track:trk1")),
//        SpotifyPlaylistTrack(addedAt: nil, track: SpotifyTrack(id: "trk2", name: "Rainy Day", artists: [sampleArtist], album: sampleAlbum, durationMs: 210000, trackNumber: 2, discNumber: 1, explicit: false, externalUrls: [:], uri: "spotify:track:trk2")),
//        SpotifyPlaylistTrack(addedAt: nil, track: SpotifyTrack(id: "trk3", name: "Night Drive", artists: [sampleArtist], album: sampleAlbum, durationMs: 195000, trackNumber: 3, discNumber: 1, explicit: false, externalUrls: [:], uri: "spotify:track:trk3")),
//        // Add a track that might be unavailable (track is nil)
//        SpotifyPlaylistTrack(addedAt: nil, track: nil)
//    ]
//    
//    manager.isLoggedIn = true
//    manager.selectedPlaylist = samplePlaylist
//    manager.isLoadingPlaylistTracks = false
//    manager.currentPlaylistTracks = sampleTracks // Populate with sample tracks
//    // You could also set a dummy next page URL to test pagination UI trigger:
//    // manager.playlistTracksNextPageUrl = "https://..."
//    
//    return NavigationView { // Embed in NavigationView for title display in preview
//        PlaylistDetailView(playlist: samplePlaylist)
//            .environmentObject(manager)
//    }
//}
//
//
//
////#Preview("Logged In - With Data") {
////    let manager = SpotifyAuthManager()
////    manager.isLoggedIn = true
////    manager.userProfile = SpotifyUserProfile(id: "preview_user", displayName: "Preview User", email: "preview@example.com", images: [SpotifyImage(url: "https://via.placeholder.com/150", height: 150, width: 150)], externalUrls: [:])
////    manager.currentTokens = StoredTokens(accessToken: "dummy_access_token_very_long...", refreshToken: "dummy_refresh_token...", expiryDate: Date().addingTimeInterval(3600))
////    manager.userPlaylists = [
////        SpotifyPlaylist(id: "pl1", name: "Chill Vibes", description: "Music to relax to", owner: SpotifyPlaylistOwner(id: "user1", displayName: "Alice", externalUrls: [:]), collaborative: false, tracks: PlaylistTracksInfo(href: "", total: 50), images: [SpotifyImage(url: "https://via.placeholder.com/100", height: 100, width: 100)], externalUrls: [:], publicPlaylist: true),
////        SpotifyPlaylist(id: "pl2", name: "Workout Beats", description: nil, owner: SpotifyPlaylistOwner(id: "user2", displayName: "Bob", externalUrls: [:]), collaborative: true, tracks: PlaylistTracksInfo(href: "", total: 100), images: nil, externalUrls: [:], publicPlaylist: false),
////        SpotifyPlaylist(id: "pl3", name: "Focus Flow", description: "Deep focus music", owner: SpotifyPlaylistOwner(id: "spotify", displayName: "Spotify", externalUrls: [:]), collaborative: false, tracks: PlaylistTracksInfo(href: "", total: 75), images: [SpotifyImage(url: "https://via.placeholder.com/100", height: 100, width: 100)], externalUrls: [:], publicPlaylist: true)
////    ]
////    manager.playlistNextPageUrl = "https://api.spotify.com/v1/me/playlists?offset=3&limit=3" // Simulate next page
////
////    AuthenticationFlowView(authManager: manager)
////}
//
//#Preview("Logged In - Playlist Error") {
//    let manager = SpotifyAuthManager()
//    manager.isLoggedIn = true
//    manager.userProfile = SpotifyUserProfile(id: "preview_user", displayName: "Preview User", email: "preview@example.com", images: [SpotifyImage(url: "https://via.placeholder.com/150", height: 150, width: 150)], externalUrls: [:])
//    manager.playlistErrorMessage = "Could not reach Spotify servers (Network Error)"
//    return AuthenticationFlowView(authManager: manager)
//}
