//
//  AuthenticationFlowView_V3.swift
//  MyApp
//
//  Created by Cong Le on 4/15/25.
//

import SwiftUI
import Combine // For ObservableObject
import CryptoKit // For PKCE SHA256
import AuthenticationServices // For ASWebAuthenticationSession

// MARK: - Configuration (MUST REPLACE)
// Make sure to add your Redirect URI Scheme ("myapp" in this example)
// to your Info.plist -> URL Types
struct SpotifyConstants {
    // ---vvv--- MUST REPLACE THESE ---vvv---
    static let clientID = "YOUR_CLIENT_ID" // <-- REPLACE THIS
    static let redirectURI = "myapp://callback" // <-- REPLACE THIS (must match Info.plist URL Scheme and Spotify Dashboard)
    // ---^^^--- MUST REPLACE THESE ---^^^---

    static let scopes = [
        "user-read-private",
        "user-read-email",
        "playlist-read-private", // Needed for fetching user playlists
        "playlist-read-collaborative", // Optional: To see collaborative playlists
        "playlist-modify-public", // Optional: Example if you want to modify playlists
        "playlist-modify-private" // Optional: Example if you want to modify playlists
        // Add other scopes your app needs
    ]
    static let scopeString = scopes.joined(separator: " ")

    static let authorizationEndpoint = URL(string: "https://accounts.spotify.com/authorize")!
    static let tokenEndpoint = URL(string: "https://accounts.spotify.com/api/token")!
    static let userProfileEndpoint = URL(string: "https://api.spotify.com/v1/me")!
    static let userPlaylistsEndpoint = URL(string: "https://api.spotify.com/v1/me/playlists")!

    static let tokenUserDefaultsKey = "spotifyTokens_v2" // Use a distinct key
}

// MARK: - Data Models

struct TokenResponse: Codable {
    let accessToken: String
    let tokenType: String
    let expiresIn: Int
    let refreshToken: String? // May not always be returned on refresh
    let scope: String

    // Calculated property for expiry date
    var expiryDate: Date? {
        return Calendar.current.date(byAdding: .second, value: expiresIn, to: Date())
    }

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
        case refreshToken = "refresh_token"
        case scope
    }
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
    let externalUrls: [String: String]?

    enum CodingKeys: String, CodingKey {
        case id
        case displayName = "display_name"
        case email
        case images
        case externalUrls = "external_urls"
    }
}

struct SpotifyImage: Codable {
    let url: String
    let height: Int?
    let width: Int?
}

// --- Playlist Models ---

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

// Playlist Track Information (simplified)
struct PlaylistTracksInfo: Codable {
    let href: String // Link to the full tracks endpoint for this playlist
    let total: Int
}

// Detailed Spotify Playlist Model
struct SpotifyPlaylist: Codable, Identifiable {
    let id: String
    let name: String
    let description: String? // Can be empty
    let owner: SpotifyPlaylistOwner
    let collaborative: Bool
    let tracks: PlaylistTracksInfo
    let images: [SpotifyImage]? // Playlists can have cover images
    let externalUrls: [String: String]?
    let publicPlaylist: Bool? // Renamed from `public` to avoid keyword clash

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case owner
        case collaborative
        case tracks
        case images
        case externalUrls = "external_urls"
        case publicPlaylist = "public" // Map JSON key "public" to Swift property "publicPlaylist"
    }
}

// Type alias for the specific paging object containing playlists
typealias SpotifyPlaylistList = SpotifyPagingObject<SpotifyPlaylist>

// MARK: - Error Handling Models

// Define custom errors for better handling
enum APIError: Error, LocalizedError {
    case invalidRequest(message: String)
    case networkError(Error)
    case invalidResponse
    case httpError(statusCode: Int, details: String)
    case noData
    case decodingError(Error?)
    case notLoggedIn
    case tokenRefreshFailed
    case authenticationFailed // Specifically after a refresh attempt fails
    case maxRetriesReached
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidRequest(let message): return "Invalid request: \(message)"
        case .networkError(let error): return "Network error: \(error.localizedDescription)"
        case .invalidResponse: return "Invalid response from server."
        case .httpError(let statusCode, let details): return "HTTP Error \(statusCode): \(details)"
        case .noData: return "No data received from server."
        case .decodingError: return "Failed to decode server response."
        case .notLoggedIn: return "User is not logged in."
        case .tokenRefreshFailed: return "Could not refresh session token."
        case .authenticationFailed: return "Authentication failed."
        case .maxRetriesReached: return "Maximum retry attempts reached."
        case .unknown: return "An unknown error occurred."
        }
    }

    // Helper to check if it's an auth-related HTTP error
    var isAuthError: Bool {
        switch self {
        case .httpError(let statusCode, _):
            return statusCode == 401 || statusCode == 403
        case .authenticationFailed, .tokenRefreshFailed, .notLoggedIn:
            return true
        default:
            return false
        }
    }
}

// Model for Spotify's standard JSON error response
struct SpotifyErrorResponse: Codable {
    let error: SpotifyErrorDetail
}
struct SpotifyErrorDetail: Codable {
    let status: Int
    let message: String?
}

// Model for representing an empty successful response (e.g., 204 No Content)
struct EmptyResponse: Codable {}

// MARK: - Authentication Manager (ObservableObject)
class SpotifyAuthManager: ObservableObject {

    @Published var isLoggedIn: Bool = false
    @Published var currentTokens: StoredTokens? = nil
    @Published var userProfile: SpotifyUserProfile? = nil
    @Published var isLoading: Bool = false // General loading (auth, profile)
    @Published var errorMessage: String? = nil // General errors

    // --- Playlist State ---
    @Published var userPlaylists: [SpotifyPlaylist] = []
    @Published var isLoadingPlaylists: Bool = false
    @Published var playlistErrorMessage: String? = nil
    @Published var canLoadMorePlaylists: Bool = false // Derived from playlistNextPageUrl

    private var playlistNextPageUrl: String? {
        didSet {
            // Update the public binding automatically
            DispatchQueue.main.async {
                self.canLoadMorePlaylists = (self.playlistNextPageUrl != nil)
            }
        }
    }
    private var currentPKCEVerifier: String?
    private var currentWebAuthSession: ASWebAuthenticationSession?

    // MARK: - Initialization & Token Management
    init() {
        loadTokens()
        if let tokens = currentTokens, let expiry = tokens.expiryDate, expiry > Date() {
            print("AuthManager: Valid token found on init.")
            self.isLoggedIn = true
            // Automatically fetch profile and playlists if logged in on init
            fetchUserProfile()
            fetchUserPlaylists() // Fetch initial playlists
        } else if currentTokens != nil {
            print("AuthManager: Expired token found on init, attempting refresh.")
            // Attempt refresh immediately if token exists but is expired
            refreshToken { [weak self] success in
                if success {
                    print("AuthManager: Refresh successful on init.")
                    self?.fetchUserProfile()
                    self?.fetchUserPlaylists() // Fetch initial playlists after successful refresh
                } else {
                    // If refresh fails definitively, ensure logout state
                    print("AuthManager: Refresh failed on init, logging out.")
                    self?.logout()
                }
            }
        } else {
            print("AuthManager: No token found on init.")
        }
    }

    // --- Token Persistence (UserDefaults - USE KEYCHAIN IN PRODUCTION!) ---
    private func saveTokens(tokens: StoredTokens) {
        // IMPORTANT: Use Keychain for storing tokens in a real application!
        // UserDefaults is not secure for sensitive data like refresh tokens.
        if let encoded = try? JSONEncoder().encode(tokens) {
            UserDefaults.standard.set(encoded, forKey: SpotifyConstants.tokenUserDefaultsKey)
            print("Tokens saved to UserDefaults (Insecure - Use Keychain in Production).")
        } else {
            print("Error: Failed to encode tokens for saving.")
        }
    }

    private func loadTokens() {
        if let savedTokensData = UserDefaults.standard.data(forKey: SpotifyConstants.tokenUserDefaultsKey) {
            if let decodedTokens = try? JSONDecoder().decode(StoredTokens.self, from: savedTokensData) {
                self.currentTokens = decodedTokens
                print("Tokens loaded from UserDefaults.")
                // Update expiry status immediately after loading
                self.checkTokenExpiryAndUpdateState()
                return
            } else {
                print("Error: Failed to decode saved tokens. Clearing potentially corrupted data.")
                clearTokens() // Clear corrupted data
            }
        }
        print("No saved tokens found in UserDefaults.")
        self.currentTokens = nil
        self.isLoggedIn = false
    }

    private func clearTokens() {
        UserDefaults.standard.removeObject(forKey: SpotifyConstants.tokenUserDefaultsKey)
        print("Tokens cleared from UserDefaults.")
    }

    // Helper to check current token validity and update isLoggedIn
    private func checkTokenExpiryAndUpdateState() {
        guard let expiry = currentTokens?.expiryDate else {
            self.isLoggedIn = false // No token or expiry date
            return
        }
        self.isLoggedIn = expiry > Date()
    }

    // MARK: - PKCE Helpers
    private func generateCodeVerifier() -> String {
        var buffer = [UInt8](repeating: 0, count: 32)
        _ = SecRandomCopyBytes(kSecRandomDefault, buffer.count, &buffer)
        return Data(buffer).base64URLEncodedString()
    }

    private func generateCodeChallenge(from verifier: String) -> String? {
        guard let data = verifier.data(using: .utf8) else { return nil }
        let digest = SHA256.hash(data: data)
        return Data(digest).base64URLEncodedString()
    }

    // MARK: - Authorization Flow
    func initiateAuthorization() {
        guard !isLoading else { return }
        // Reset state before starting
        DispatchQueue.main.async {
            self.isLoading = true
            self.errorMessage = nil
            self.userProfile = nil
            self.userPlaylists = []
            self.playlistErrorMessage = nil
            self.playlistNextPageUrl = nil
        }

        let verifier = generateCodeVerifier()
        guard let challenge = generateCodeChallenge(from: verifier) else {
            handleError("Could not start authentication (PKCE).")
            DispatchQueue.main.async { self.isLoading = false }
            return
        }
        currentPKCEVerifier = verifier

        var components = URLComponents(url: SpotifyConstants.authorizationEndpoint, resolvingAgainstBaseURL: true)
        components?.queryItems = [
            URLQueryItem(name: "client_id", value: SpotifyConstants.clientID),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "redirect_uri", value: SpotifyConstants.redirectURI),
            URLQueryItem(name: "scope", value: SpotifyConstants.scopeString),
            URLQueryItem(name: "code_challenge_method", value: "S256"),
            URLQueryItem(name: "code_challenge", value: challenge),
            // URLQueryItem(name: "show_dialog", value: "true") // Optional: Force user approval screen
        ]

        guard let authURL = components?.url else {
            handleError("Could not construct authorization URL.")
            DispatchQueue.main.async { self.isLoading = false }
            return
        }

        let scheme = URL(string: SpotifyConstants.redirectURI)?.scheme

        // Ensure ASWebAuthenticationSession runs on the main thread
        DispatchQueue.main.async {
            self.currentWebAuthSession = ASWebAuthenticationSession(
                url: authURL,
                callbackURLScheme: scheme) { [weak self] callbackURL, error in
                    // Important: Handle callback results back on the main thread
                    DispatchQueue.main.async {
                        guard let self = self else { return }
                        // Ensure loading stops regardless of outcome
                        self.isLoading = false
                        self.handleAuthCallback(callbackURL: callbackURL, error: error)
                    }
                }

            self.currentWebAuthSession?.presentationContextProvider = self
            self.currentWebAuthSession?.prefersEphemeralWebBrowserSession = true // Recommended for privacy

            // Start the session now that it's configured
            self.currentWebAuthSession?.start()
        }
    }

    private func handleAuthCallback(callbackURL: URL?, error: Error?) {
        // Guard against multiple calls if session finishes unexpectedly
        guard currentPKCEVerifier != nil else {
             print("Callback handled already or verifier missing.")
             return
        }

        if let error = error {
            if let authError = error as? ASWebAuthenticationSessionError, authError.code == .canceledLogin {
                print("Auth cancelled by user.")
                handleError("Login cancelled.")
            } else {
                print("Auth Error: \(error.localizedDescription)")
                handleError("Authentication failed: \(error.localizedDescription)")
            }
            currentPKCEVerifier = nil // Clear verifier on error/cancel
            return
        }

        guard let successURL = callbackURL else {
            print("Auth Error: No callback URL received.")
            handleError("Authentication failed: No callback URL.")
            currentPKCEVerifier = nil // Clear verifier on error
            return
        }

        // Extract the authorization code
        let queryItems = URLComponents(string: successURL.absoluteString)?.queryItems
        if let code = queryItems?.first(where: { $0.name == "code" })?.value {
            print("Successfully received authorization code.")
            // Exchange code immediately
            exchangeCodeForToken(code: code)
        } else {
            print("Error: Could not find authorization code in callback URL.")
            // Check for Spotify-specific errors in the callback
             let spotifyError = queryItems?.first(where: { $0.name == "error" })?.value
             let errorDesc = spotifyError ?? "Unknown error in callback."
             handleError("Could not get authorization code from Spotify: \(errorDesc)")
             currentPKCEVerifier = nil // Clear verifier on error
        }
    }

    private func exchangeCodeForToken(code: String) {
        guard let verifier = currentPKCEVerifier else {
            handleError("Authentication failed (missing verifier).")
            currentPKCEVerifier = nil // Ensure it's cleared even if logic fails here
            return
        }
        // No need for separate isLoading check here, callback ensures it happens
        DispatchQueue.main.async { self.isLoading = true }
        errorMessage = nil

        makeTokenRequest(grantType: "authorization_code", code: code, verifier: verifier) { [weak self] result in
            guard let self = self else { return }
            // Ensure UI updates happen on the main thread after network call
            DispatchQueue.main.async {
                self.isLoading = false
                // IMPORTANT: Clear the verifier ONLY after the token request is complete (success or failure)
                self.currentPKCEVerifier = nil
                switch result {
                case .success(let tokenResponse):
                    print("Successfully exchanged code for tokens.")
                    self.processSuccessfulTokenResponse(tokenResponse)
                    // Fetch user data after successful login
                    self.fetchUserProfile()
                    self.fetchUserPlaylists() // Fetch initial playlists
                case .failure(let error):
                    print("Token Exchange Error: \(error.localizedDescription)")
                    self.handleError("Failed to get tokens: \(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: - Token Refresh
    // Added a completion handler to know if refresh was successful
    func refreshToken(completion: ((Bool) -> Void)? = nil) {
        guard !isLoading else {
            print("Refresh token called while already loading.")
            completion?(false)
            return
        }
        guard let refreshToken = currentTokens?.refreshToken else {
            print("Error: No refresh token available for refresh.")
             // If no refresh token, user must log in again.
             logout() // Force re-login
             completion?(false)
            return
        }

        print("Attempting to refresh token...")
        DispatchQueue.main.async {
             self.isLoading = true // Use general loading for refresh
             self.errorMessage = nil
        }

        makeTokenRequest(grantType: "refresh_token", refreshToken: refreshToken) { [weak self] result in
            guard let self = self else {
                completion?(false); return
            }
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let tokenResponse):
                    print("Successfully refreshed tokens.")
                    // Preserve the old refresh token if the response doesn't contain a new one
                    let updatedRefreshToken = tokenResponse.refreshToken ?? self.currentTokens?.refreshToken
                    self.processSuccessfulTokenResponse(tokenResponse, explicitRefreshToken: updatedRefreshToken)
                    completion?(true)
                case .failure(let error):
                    print("Token Refresh Error: \(error.localizedDescription)")
                     self.handleError("Session expired. Please log in again.") // User-friendly message

                    // Optional: Force logout on persistent refresh failure (e.g., invalid_grant)
                    if let apiError = error as? APIError, apiError.isAuthError {
                         print("Refresh failed due to auth error, logging out.")
                         self.logout() // Automatically log out user
                    }
                    completion?(false)
                }
            }
        }
    }

    // --- Centralized Token Request Logic ---
    private func makeTokenRequest(grantType: String, code: String? = nil, verifier: String? = nil, refreshToken: String? = nil, completion: @escaping (Result<TokenResponse, Error>) -> Void) {

        var request = URLRequest(url: SpotifyConstants.tokenEndpoint)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        var components = URLComponents()
        var queryItems = [
            URLQueryItem(name: "client_id", value: SpotifyConstants.clientID),
            URLQueryItem(name: "grant_type", value: grantType)
        ]

        if let code = code, let verifier = verifier, grantType == "authorization_code" {
            queryItems.append(contentsOf: [
                URLQueryItem(name: "code", value: code),
                URLQueryItem(name: "redirect_uri", value: SpotifyConstants.redirectURI),
                URLQueryItem(name: "code_verifier", value: verifier)
            ])
        } else if let refreshToken = refreshToken, grantType == "refresh_token" {
            queryItems.append(URLQueryItem(name: "refresh_token", value: refreshToken))
        } else {
            // Should not happen with current usage, but good practice
            completion(.failure(APIError.invalidRequest(message: "Internal error: Invalid parameters for token request.")))
            return
        }

        components.queryItems = queryItems
        request.httpBody = components.query?.data(using: .utf8)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(APIError.networkError(error)))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(APIError.invalidResponse))
                return
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                let errorDetails = self.extractErrorDetails(from: data, statusCode: httpResponse.statusCode)
                let apiError = APIError.httpError(statusCode: httpResponse.statusCode, details: errorDetails)
                completion(.failure(apiError))
                return
            }

            guard let data = data else {
                completion(.failure(APIError.noData))
                return
            }

            do {
                let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)
                completion(.success(tokenResponse))
            } catch {
                print("Token JSON Decoding Error: \(error)")
                if let jsonString = String(data: data, encoding: .utf8) { print("Received JSON for Token Error: ", jsonString) }
                completion(.failure(APIError.decodingError(error)))
            }
        }.resume()
    }

    // Helper to process successful token response and update state
    private func processSuccessfulTokenResponse(_ tokenResponse: TokenResponse, explicitRefreshToken: String? = nil) {
        // This function MUST be called on the main thread because it updates @Published properties
        let newRefreshToken = explicitRefreshToken ?? tokenResponse.refreshToken
        let newStoredTokens = StoredTokens(
            accessToken: tokenResponse.accessToken,
            refreshToken: newRefreshToken, // Use the explicitly passed or the one from response
            expiryDate: tokenResponse.expiryDate
        )
        self.currentTokens = newStoredTokens
        self.saveTokens(tokens: newStoredTokens)
        self.isLoggedIn = true
        self.errorMessage = nil // Clear general errors on success
    }

    // MARK: - User Profile Fetching
    func fetchUserProfile() {
        // Use general isLoading indicator for the first fetch
        if userProfile == nil {
            DispatchQueue.main.async { self.isLoading = true }
        }

        makeAPIRequest(
            url: SpotifyConstants.userProfileEndpoint,
            responseType: SpotifyUserProfile.self,
            currentAttempt: 1,
            maxAttempts: 2 // Allow one retry after token refresh
        ) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                 self.isLoading = false // Stop general loading indicator
                switch result {
                case .success(let profile):
                    self.userProfile = profile
                    self.errorMessage = nil // Clear error on success
                    print("Successfully fetched user profile for \(profile.displayName)")
                case .failure(let error):
                    print("Fetch Profile Error: \(error.localizedDescription)")
                     self.handleError("Could not fetch profile: \(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: - Playlist Fetching
    // Fetches the first page or the next page if url is provided
    func fetchUserPlaylists(loadNextPage: Bool = false) {
        // Determine the URL to fetch
        var urlToFetch: URL?
        if loadNextPage {
            guard let nextUrlString = self.playlistNextPageUrl else {
                 print("Playlist Fetch: No next page URL available.")
                 return // Exit silently, nothing more to load
            }
            urlToFetch = URL(string: nextUrlString)
        } else {
            // Fetching the first page
            urlToFetch = SpotifyConstants.userPlaylistsEndpoint
             // Reset state only when fetching the FIRST page
             DispatchQueue.main.async {
                 self.userPlaylists = []
                 self.playlistNextPageUrl = nil // This also sets canLoadMorePlaylists via didSet
                 self.playlistErrorMessage = nil
             }
        }

        guard let finalUrl = urlToFetch else {
             handlePlaylistError("Invalid URL for fetching playlists.")
             return
        }

        // Don't proceed if already loading playlists
        guard !isLoadingPlaylists else {
            print("Playlist fetch requested while already loading.")
            return
        }
        // Ensure logged in state
        guard isLoggedIn, currentTokens?.accessToken != nil else {
            handlePlaylistError("Cannot fetch playlists: Not logged in.")
            return
        }

        print("Fetching playlists from: \(finalUrl.absoluteString)")
        DispatchQueue.main.async {
            self.isLoadingPlaylists = true
             // Clear error message specifically for playlists before starting a new load
             self.playlistErrorMessage = nil
        }

        makeAPIRequest(
            url: finalUrl,
            responseType: SpotifyPlaylistList.self, // Expecting the PagingObject
            currentAttempt: 1,
            maxAttempts: 2
        ) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isLoadingPlaylists = false
                switch result {
                case .success(let playlistResponse):
                    print("Successfully fetched playlists page. Count: \(playlistResponse.items.count), Total Items: \(playlistResponse.total), Next URL: \(playlistResponse.next ?? "None")")
                    if loadNextPage {
                         self.userPlaylists.append(contentsOf: playlistResponse.items)
                         print("Appended next page of playlists. New total count: \(self.userPlaylists.count)")
                    } else {
                         self.userPlaylists = playlistResponse.items
                         print("Fetched and set initial playlists. Count: \(self.userPlaylists.count)")
                    }
                    // Update the URL for the *next* page
                    self.playlistNextPageUrl = playlistResponse.next
                    // Clear playlist-specific error on success
                    self.playlistErrorMessage = nil

                case .failure(let error):
                    print("Fetch Playlists Error: \(error.localizedDescription)")
                     self.handlePlaylistError("Could not fetch playlists: \(error.localizedDescription)")
                     // Don't clear existing playlists on error, user might want to see old data
                      // Reset next page URL on error to prevent trying to load more from a failed state
                      self.playlistNextPageUrl = nil
                }
            }
        }
    }

    // MARK: - Generic API Request Function
    // Handles making the request, adding auth header, decoding, and retrying on token expiry
    private func makeAPIRequest<T: Decodable>(
        url: URL,
        method: String = "GET", // Default to GET
        body: Data? = nil,      // For POST/PUT requests
        responseType: T.Type,
        currentAttempt: Int,
        maxAttempts: Int,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        guard currentAttempt <= maxAttempts else {
            print("API Request \(url.lastPathComponent): Max retries reached.")
            // Don't call completion on main thread here, let the caller decide
            completion(.failure(APIError.maxRetriesReached))
            return
        }

        // --- Check for Token Expiry and Refresh BEFORE the call ---
        if let expiryDate = currentTokens?.expiryDate, expiryDate <= Date() {
            print("Token likely expired (expires: \(expiryDate)), attempting refresh before API call to \(url.lastPathComponent)...")
            refreshToken { [weak self] success in
                guard let self = self else {
                    completion(.failure(APIError.unknown)); return
                }
                if success {
                    print("Token refreshed successfully. Retrying API call to \(url.lastPathComponent)...")
                    // Retry the request with the *updated* token
                    self.makeAPIRequest(
                        url: url,
                        method: method,
                        body: body,
                        responseType: responseType,
                        currentAttempt: currentAttempt + 1, // Increment attempt count because refresh *was* the action
                        maxAttempts: maxAttempts,
                        completion: completion
                    )
                } else {
                    print("Token refresh failed. Aborting API call to \(url.lastPathComponent).")
                     // Handle logout or specific error if needed
                    self.logout() // Force logout if refresh fails
                    completion(.failure(APIError.tokenRefreshFailed))
                }
            }
            return // Exit the current function call to let the refresh logic complete
        }
        // --- End Token Expiry Check ---

        // Proceed with the API call if token seems valid
        guard let accessToken = currentTokens?.accessToken else {
            // Should not happen if expiry check passed, but good safety check
             print("API Request \(url.lastPathComponent): No access token found despite Check.")
             logout() // Log out if token is missing unexpectedly
            completion(.failure(APIError.notLoggedIn))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        // Set Content-Type for relevant methods
        if let body = body, (method == "POST" || method == "PUT" || method == "DELETE") {
            // Assume JSON, but could be parameterized if needed
            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            request.httpBody = body
        }

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else {
                completion(.failure(APIError.unknown)); return
            }

            if let error = error {
                 print("API Request Network Error for \(url.lastPathComponent): \(error)")
                completion(.failure(APIError.networkError(error)))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                 print("API Request Invalid Response for \(url.lastPathComponent): Not an HTTP Response")
                completion(.failure(APIError.invalidResponse))
                return
            }

            // --- Handle Auth Error (401 Unauthorized, 403 Forbidden) AFTER the call ---
            // This handles cases where the token became invalid *between* the pre-check and the API call
            if (httpResponse.statusCode == 401 || httpResponse.statusCode == 403) && currentAttempt < maxAttempts {
                print("Received \(httpResponse.statusCode) for \(url.lastPathComponent). Token might be invalid/expired. Attempting refresh (attempt \(currentAttempt+1))...")
                refreshToken { [weak self] success in
                    guard let self = self else {
                        completion(.failure(APIError.unknown)); return
                    }
                    if success {
                        print("Token refreshed after \(httpResponse.statusCode). Retrying API call to \(url.lastPathComponent)...")
                        // Retry the request - Use the NOW updated token
                        self.makeAPIRequest(
                            url: url,
                            method: method,
                            body: body,
                            responseType: responseType,
                            currentAttempt: currentAttempt + 1, // Increment attempt count
                            maxAttempts: maxAttempts,
                            completion: completion
                        )
                    } else {
                        print("Token refresh failed after \(httpResponse.statusCode). Aborting API call to \(url.lastPathComponent).")
                        // Indicate authentication specifically failed after trying to recover
                         self.logout() // Force logout
                        completion(.failure(APIError.authenticationFailed))
                    }
                }
                return // Exit the current dataTask closure to allow refresh and retry
            }
            // --- End Auth Error Handling ---

            // Handle non-2xx status codes that aren't auth errors handled above
            guard (200...299).contains(httpResponse.statusCode) else {
                let errorDetails = self.extractErrorDetails(from: data, statusCode: httpResponse.statusCode)
                 print("API Request HTTP Error for \(url.lastPathComponent): \(httpResponse.statusCode) - \(errorDetails)")
                completion(.failure(APIError.httpError(statusCode: httpResponse.statusCode, details: errorDetails)))
                return
            }

            // Handle successful responses (2xx)
            guard let data = data else {
                // Should ideally not happen with a 2xx unless it's 204 No Content
                if httpResponse.statusCode == 204 {
                     // Handle 204 No Content specifically if the expected type is EmptyResponse
                     if T.self == EmptyResponse.self, let empty = EmptyResponse() as? T {
                         completion(.success(empty))
                         return
                     } else {
                         // If 204 received but non-EmptyResponse expected, it's likely an error
                         print("API Request Error for \(url.lastPathComponent): Received 204 No Content but expected data type \(T.self)")
                         completion(.failure(APIError.noData))
                         return
                     }
                } else {
                     // Other 2xx codes should have data
                     print("API Request Error for \(url.lastPathComponent): No data received for status \(httpResponse.statusCode)")
                     completion(.failure(APIError.noData))
                     return
                }
            }

            // Handle 204 No Content even if data is technically present (e.g., empty data `''`)
            if httpResponse.statusCode == 204 {
                 if T.self == EmptyResponse.self, let empty = EmptyResponse() as? T {
                     completion(.success(empty))
                 } else {
                     completion(.failure(APIError.decodingError(nil))) // Mismatch
                 }
                 return
            }

             // Decode the data for 200 OK or other successful 2xx responses with bodies
            do {
                let decodedObject = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decodedObject))
            } catch let decodingError {
                 print("API JSON Decoding Error for \(T.self) from \(url.lastPathComponent): \(decodingError)")
                 print("Raw response data: \(String(data: data, encoding: .utf8) ?? "Unable to decode data")")
                completion(.failure(APIError.decodingError(decodingError)))
            }
        }.resume()
    }

    // MARK: - Logout
    func logout() {
        DispatchQueue.main.async {
            self.isLoggedIn = false
            self.currentTokens = nil
            self.userProfile = nil
            self.errorMessage = nil
            self.userPlaylists = [] // Clear playlists on logout
            self.playlistErrorMessage = nil
            self.isLoading = false
            self.isLoadingPlaylists = false
            self.playlistNextPageUrl = nil
            self.clearTokens()
            // Cancel any ongoing web auth session
            self.currentWebAuthSession?.cancel()
            self.currentWebAuthSession = nil
            self.currentPKCEVerifier = nil
            print("User logged out.")
        }
    }

    // MARK: - Error Handling Helpers
    private func handleError(_ message: String) {
        // Ensure UI updates are on the main thread
        DispatchQueue.main.async {
            self.errorMessage = message
        }
        print("AuthManager Error: \(message)")
    }

    private func handlePlaylistError(_ message: String) {
        DispatchQueue.main.async {
            self.playlistErrorMessage = message
        }
        print("AuthManager Playlist Error: \(message)")
    }

    private func extractErrorDetails(from data: Data?, statusCode: Int) -> String {
        guard let data = data, !data.isEmpty else { return "Status code \(statusCode) (No details)" }
        // Try decoding Spotify's standard error object first
        if let spotifyError = try? JSONDecoder().decode(SpotifyErrorResponse.self, from: data) {
            return spotifyError.error.message ?? "Status code \(statusCode) (Spotify Error)"
        }
        // Fallback to generic JSON structure often used in OAuth errors
        if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
           let errorDesc = json["error_description"] as? String ?? json["error"] as? String {
            return "\(errorDesc) (Status code \(statusCode))"
        }
        // Fallback to plain text if JSON decoding fails
        if let text = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty {
            return "\(text) (Status code \(statusCode))"
        }
        // Absolute fallback
        return "Status code \(statusCode)"
    }
}

// MARK: - ASWebAuthenticationPresentationContextProviding
extension SpotifyAuthManager: ASWebAuthenticationPresentationContextProviding {
    func isEqual(_ object: Any?) -> Bool {
        return true
    }
    
    var hash: Int {
        return 0
    }
    
    var superclass: AnyClass? {
        return nil
    }
    
    func `self`() -> Self {
        return self
    }
    
    func perform(_ aSelector: Selector!) -> Unmanaged<AnyObject>! {
        return Unmanaged.passUnretained(self)
    }
    
    func perform(_ aSelector: Selector!, with object: Any!) -> Unmanaged<AnyObject>! {
        return Unmanaged.passUnretained(self)
    }
    
    func perform(_ aSelector: Selector!, with object1: Any!, with object2: Any!) -> Unmanaged<AnyObject>! {
        return Unmanaged.passUnretained(self)
    }
    
    func isProxy() -> Bool {
        return true
    }
    
    func isKind(of aClass: AnyClass) -> Bool {
        return true
    }
    
    func isMember(of aClass: AnyClass) -> Bool {
        return true
    }
    
    func conforms(to aProtocol: Protocol) -> Bool {
        return true
    }
    
    func responds(to aSelector: Selector!) -> Bool {
        return true
    }
    
    var description: String {
        return ""
    }
    
    // Use the key window as the presentation anchor
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        let keyWindow = UIApplication.shared.connectedScenes
               .filter { $0.activationState == .foregroundActive }
               .compactMap { $0 as? UIWindowScene }
               .first?.windows
               .filter { $0.isKeyWindow }
               .first
        // Fallback required for initialization if no window is key yet
        return keyWindow ?? ASPresentationAnchor()
    }
}

// MARK: - PKCE Helper Extension
extension Data {
    // Helper to create Base64 URL-encoded string (needed for PKCE)
    func base64URLEncodedString() -> String {
        return self.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "") // Remove padding
    }
}

// MARK: - SwiftUI View (Using the Reference AuthenticationFlowView)

struct AuthenticationFlowView: View {
    @StateObject var authManager = SpotifyAuthManager()

    var body: some View {
        NavigationView {
            Group { // Use Group to switch between major views
                if !authManager.isLoggedIn {
                    loggedOutView
                        .navigationTitle("Spotify Login")
                        .navigationBarTitleDisplayMode(.inline)
                } else {
                    loggedInContentView
                        .navigationTitle("Your Spotify")
                        .navigationBarTitleDisplayMode(.inline)
                }
            }
            .overlay { // Show loading indicator overlay for general auth/profile loading
                if authManager.isLoading {
                    VStack {
                        ProgressView("Loading...")
                            .padding()
                            .background(.regularMaterial) // Use material background
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }
                }
            }
             // Display general errors as an alert
             .alert("Error", isPresented: Binding(
                 get: { authManager.errorMessage != nil },
                 set: { if !$0 { authManager.errorMessage = nil } } // Clear error when dismissed
             ), presenting: authManager.errorMessage) { _ in // Explicitly ignore the presented value
                 Button("OK") { authManager.errorMessage = nil } // Action to clear the error model
             } message: { message in
                 Text(message) // Display the error message from the authManager
             }
        }
        // Handle the redirect URI callback (if needed at view level, though manager handles internally)
        // .onOpenURL { url in
        //     print("Received URL via onOpenURL: \(url)")
        //     // You might pass this to the manager if it needs to handle specific deep links post-auth,
        //     // but the ASWebAuthSession callback handles the primary auth flow.
        // }
    }

    // MARK: Logged Out View
    private var loggedOutView: some View {
        VStack(spacing: 25) { // Added spacing
            Spacer() // Pushes content towards center

            Image(systemName: "music.note.house.fill") // More relevant icon
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(Color(red: 30/255, green: 215/255, blue: 96/255)) // Spotify Green

            Text("Connect your Spotify account to see your profile and playlists.")
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding(.horizontal) // Add horizontal padding

            Button {
                authManager.initiateAuthorization()
            } label: {
                HStack {
                    // You could add a small Spotify logo image here if you have one
                    Image(systemName: "lock.open.fill") // Changed icon
                        .foregroundColor(.white)
                    Text("Log in with Spotify")
                        .fontWeight(.bold) // Bolder text
                        .foregroundColor(.white)
                }
                .padding(.vertical, 15) // Slightly larger padding
                .padding(.horizontal, 30)
                .background(Color(red: 30/255, green: 215/255, blue: 96/255)) // Spotify Green
                .cornerRadius(40) // Fully rounded ends
                .shadow(color: .gray.opacity(0.4), radius: 5, y: 3) // Add shadow
            }
            .disabled(authManager.isLoading) // Disable while loading

            Spacer() // Pushes content towards center
            Spacer() // Add more space at bottom
        }
        .padding() // Add padding to the whole VStack
    }

    // MARK: Logged In Content View
    private var loggedInContentView: some View {
        List {
            // Section for User Profile
            Section(header: Text("Profile")) {
                profileSection
            }

            // Section for Playlists
            Section { // Use implicit header/footer for cleaner look maybe
                playlistSection
            } header: {
                Text("My Playlists")
            } footer: {
                // Show playlist loading/error state in the footer
                if authManager.isLoadingPlaylists {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }.padding(.vertical, 5)
                } else if let errorMsg = authManager.playlistErrorMessage {
                    Text("Error loading playlists: \(errorMsg)")
                        .font(.caption)
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }

            // Section for Actions / Debug
            Section(header: Text("Account Actions")) {
                actionSection
            }
        }
        .listStyle(.insetGrouped) // Use InsetGroupedListStyle
        .refreshable { // Enable pull-to-refresh
            print("Refreshing profile and playlists via pull-to-refresh...")
            // Don't show the main loading overlay for pull-to-refresh
            authManager.fetchUserProfile()
            authManager.fetchUserPlaylists(loadNextPage: false) // Refresh starts from the first page
        }
        .onAppear {
            // Fetch data only if it's missing when the view *appears*
            // This avoids redundant fetches if data was loaded on init
            if authManager.userProfile == nil && authManager.isLoggedIn && !authManager.isLoading {
                 print("LoggedIn view appeared, fetching missing profile...")
                 authManager.fetchUserProfile()
            }
            if authManager.userPlaylists.isEmpty && authManager.isLoggedIn && !authManager.isLoadingPlaylists {
                print("LoggedIn view appeared, fetching missing playlists...")
                authManager.fetchUserPlaylists()
            }
        }
    }

    // MARK: Profile Section (Extracted ViewBuilder)
    @ViewBuilder
    private var profileSection: some View {
        if let profile = authManager.userProfile {
            HStack(spacing: 15) { // Add spacing
                AsyncImage(url: URL(string: profile.images?.first?.url ?? "" )) { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1)) // Add a subtle border
                } placeholder: {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                         .aspectRatio(contentMode: .fit)
                         .frame(width: 60, height: 60)
                         .foregroundColor(.secondary) // Use secondary color
                }

                VStack(alignment: .leading) {
                    Text(profile.displayName)
                        .font(.headline)
                    Text(profile.email)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .lineLimit(1) // Ensure email doesn't wrap awkwardly
                }
            }
            .padding(.vertical, 8) // Add padding inside the cell
        } else if authManager.isLoading {
            // Show placeholder only while general loading is active
             HStack {
                 Spacer()
                 ProgressView()
                 Spacer()
             }.padding(.vertical)
        } else {
             // Show if not loading but profile is still nil (might indicate an error)
             Text("Could not load profile.")
             .foregroundColor(.secondary)
        }
    }

    // MARK: Playlist Section (Extracted ViewBuilder)
    @ViewBuilder
    private var playlistSection: some View {
       if authManager.userPlaylists.isEmpty && !authManager.isLoadingPlaylists && authManager.playlistErrorMessage == nil {
            // Show empty state only if not loading and no error
            Text("No playlists found.")
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding()
        } else {
            // Only iterate if playlists exist
            ForEach(authManager.userPlaylists) { playlist in
                HStack {
                    AsyncImage(url: URL(string: playlist.images?.first?.url ?? "")) { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 50, height: 50) // Slightly larger
                            .cornerRadius(4)
                    } placeholder: {
                        // Placeholder with centered icon
                        ZStack {
                             Rectangle().fill(Color.secondary.opacity(0.1))
                                 .frame(width: 50, height: 50)
                                 .cornerRadius(4)
                             Image(systemName: "music.note.list")
                                 .resizable()
                                 .scaledToFit()
                                 .frame(width: 25, height: 25)
                                 .foregroundStyle(.secondary)
                        }
                    }

                    VStack(alignment: .leading, spacing: 3) { // Add Spacing
                        Text(playlist.name).fontWeight(.medium).lineLimit(1)
                        Text("By \(playlist.owner.displayName ?? "Spotify") • \(playlist.tracks.total) track\(playlist.tracks.total == 1 ? "" : "s")")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }

                    Spacer() // Pushes collab icon to the right

                    if playlist.collaborative {
                        Image(systemName: "person.2.fill")
                            .foregroundColor(.blue)
                             .imageScale(.small) // Make icon smaller
                    }
                }
                .padding(.vertical, 4) // Fine-tune vertical padding in row
                .onAppear {
                    // Trigger loading next page when the *last* item appears
                    if playlist.id == authManager.userPlaylists.last?.id && authManager.canLoadMorePlaylists && !authManager.isLoadingPlaylists {
                          print("Reached end of playlist list (\(playlist.name)), loading next page...")
                          authManager.fetchUserPlaylists(loadNextPage: true)
                    }
                }
            } // End ForEach
        } // End else (playlists not empty)
    }

    // MARK: Action Section (Extracted)
    private var actionSection: some View {
        Group { // Use Group for conditional content if needed
            // --- Standard Actions ---
            Button("Force Refresh Token") {
                authManager.refreshToken()
            }
            .disabled(authManager.currentTokens?.refreshToken == nil || authManager.isLoading)
            .tint(.orange) // Give it a distinct color

            Button("Log Out", role: .destructive) {
                authManager.logout()
            }

            // --- Debug Information ---
            #if DEBUG // Only show debug info in Debug builds
            if let tokens = authManager.currentTokens {
                DisclosureGroup("Token Details (Debug)") {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Access Token:").font(.caption.weight(.bold))
                        Text(tokens.accessToken)
                            .font(.caption)
                            .lineLimit(2) // Allow wrapping slightly
                            .truncationMode(.middle) // Truncate middle if needed

                        if let expiry = tokens.expiryDate {
                            Text("Expires:")
                                .font(.caption.weight(.bold)) +
                            Text(" \(expiry, style: .relative) (\(expiry.formatted(date: .omitted, time: .shortened)))")
                                .font(.caption)
                                .foregroundColor(expiry <= Date() ? .red : .green)
                        } else {
                             Text("Expiry Date: Not Set").font(.caption)
                        }

                        Text("Refresh Token Present: \(tokens.refreshToken != nil ? "Yes" : "No")")
                            .font(.caption)
                            .foregroundColor(tokens.refreshToken != nil ? .primary : .orange)

                    }
                    .padding(.top, 5)
                }
                .font(.callout) // Make the disclosure group label smaller
            }
            #endif
        }
    }
}
#Preview("AuthenticationFlowView") {
    AuthenticationFlowView()
}

//
//// MARK: - App Entry Point
//@main
//struct SpotifyAuthDemoApp: App {
//    var body: some Scene {
//        WindowGroup {
//            // Start with the main authentication view
//            AuthenticationFlowView()
//        }
//    }
//}
