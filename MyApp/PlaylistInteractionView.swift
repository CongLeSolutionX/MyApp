//
//  AuthenticationFlowView_V2.swift
//  MyApp
//
//  Created by Cong Le on 4/7/25.
//

import SwiftUI
import Combine // For ObservableObject
import CryptoKit // For PKCE SHA256
import AuthenticationServices // For ASWebAuthenticationSession

// MARK: - Configuration (MUST REPLACE)
struct SpotifyConstants {
    static let clientID = "YOUR_CLIENT_ID" // <-- REPLACE THIS
    static let redirectURI = "myapp://callback" // <-- REPLACE THIS (e.g., "myapp://callback")
    static let scopes = [
        "user-read-private",
        "user-read-email",
        "playlist-read-private", // Needed for fetching user playlists
        "playlist-read-collaborative", // Optional: To see collaborative playlists
        "playlist-modify-public",
        "playlist-modify-private"
        // Add other scopes your app needs
    ]
    static let scopeString = scopes.joined(separator: " ")

    static let authorizationEndpoint = URL(string: "https://accounts.spotify.com/authorize")!
    static let tokenEndpoint = URL(string: "https://accounts.spotify.com/api/token")!
    static let userProfileEndpoint = URL(string: "https://api.spotify.com/v1/me")!
    // New endpoint for user playlists
    static let userPlaylistsEndpoint = URL(string: "https://api.spotify.com/v1/me/playlists")!

    static let tokenUserDefaultsKey = "spotifyTokens"
}

// MARK: - Data Models

// Existing Models (TokenResponse, StoredTokens, SpotifyUserProfile, SpotifyImage) remain the same...

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
    let externalUrls: [String: String]? // Added for potential use

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


// --- New Models for Playlists ---

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


// MARK: - Authentication Manager (ObservableObject)
class SpotifyAuthManager: ObservableObject {

    @Published var isLoggedIn: Bool = false
    @Published var currentTokens: StoredTokens? = nil
    @Published var userProfile: SpotifyUserProfile? = nil
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    // --- New State for Playlists ---
    @Published var userPlaylists: [SpotifyPlaylist] = []
    @Published var isLoadingPlaylists: Bool = false
    @Published var playlistErrorMessage: String? = nil


    private var currentPKCEVerifier: String?
    private var currentWebAuthSession: ASWebAuthenticationSession?
    var playlistNextPageUrl: String? // For pagination

    init() {
        loadTokens()
        if let tokens = currentTokens, let expiry = tokens.expiryDate, expiry > Date() {
            self.isLoggedIn = true
            // Automatically fetch profile and playlists if logged in on init
            fetchUserProfile()
            fetchUserPlaylists() // Fetch initial playlists
        } else if currentTokens != nil {
            refreshToken { [weak self] success in
                if success {
                    self?.fetchUserProfile()
                    self?.fetchUserPlaylists() // Fetch initial playlists after successful refresh
                } else {
                    // If refresh fails definitively, ensure logout
                    self?.logout()
                }
            }
        }
    }

    // --- PKCE Helper Functions (Remain the same) ---
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

    // --- Authentication Flow (initiateAuthorization, exchangeCodeForToken remain largely the same) ---
    func initiateAuthorization() {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        userProfile = nil // Clear old profile
        userPlaylists = [] // Clear old playlists
        playlistErrorMessage = nil
        playlistNextPageUrl = nil

        let verifier = generateCodeVerifier()
        guard let challenge = generateCodeChallenge(from: verifier) else {
            handleError("Could not start authentication (PKCE).")
            isLoading = false
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
        ]

        guard let authURL = components?.url else {
            handleError("Could not construct authorization URL.")
            isLoading = false
            return
        }

        let scheme = URL(string: SpotifyConstants.redirectURI)?.scheme

        currentWebAuthSession = ASWebAuthenticationSession(
            url: authURL,
            callbackURLScheme: scheme) { [weak self] callbackURL, error in
                guard let self = self else { return }
                // Always ensure UI updates happen on the main thread
                DispatchQueue.main.async {
                    self.isLoading = false // Stop general loading indicator
                    self.handleAuthCallback(callbackURL: callbackURL, error: error)
                }
            }

        currentWebAuthSession?.presentationContextProvider = self
        currentWebAuthSession?.prefersEphemeralWebBrowserSession = true // Recommended for privacy

        DispatchQueue.main.async {
            self.currentWebAuthSession?.start()
        }
    }

    private func handleAuthCallback(callbackURL: URL?, error: Error?) {
        if let error = error {
            if let authError = error as? ASWebAuthenticationSessionError, authError.code == .canceledLogin {
                print("Auth cancelled by user.")
                self.errorMessage = "Login cancelled."
            } else {
                print("Auth Error: \(error.localizedDescription)")
                self.errorMessage = "Authentication failed: \(error.localizedDescription)"
            }
            return
        }

        guard let successURL = callbackURL else {
            print("Auth Error: No callback URL received.")
            self.errorMessage = "Authentication failed: No callback URL."
            return
        }

        // Extract the authorization code
        let queryItems = URLComponents(string: successURL.absoluteString)?.queryItems
        if let code = queryItems?.first(where: { $0.name == "code" })?.value {
            print("Successfully received authorization code.")
            exchangeCodeForToken(code: code)
        } else {
            print("Error: Could not find authorization code in callback URL.")
            self.errorMessage = "Could not get authorization code from Spotify."
            // Check for Spotify-specific errors in the callback
            if let spotifyError = queryItems?.first(where: { $0.name == "error" })?.value {
                print("Spotify error in callback: \(spotifyError)")
                self.errorMessage = "Spotify denied the request: \(spotifyError)"
            }
        }
    }


    private func exchangeCodeForToken(code: String) {
        guard let verifier = currentPKCEVerifier else {
            handleError("Authentication failed (missing verifier).", clearVerifier: true)
            return
        }
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil

        makeTokenRequest(grantType: "authorization_code", code: code, verifier: verifier) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isLoading = false
                self.currentPKCEVerifier = nil // Important: Clear verifier after use
                switch result {
                case .success(let tokenResponse):
                    print("Successfully exchanged code for tokens.")
                    self.processSuccessfulTokenResponse(tokenResponse)
                    // Fetch user data after successful login
                    self.fetchUserProfile()
                    self.fetchUserPlaylists() // Fetch initial playlists
                case .failure(let error):
                    print("Token Exchange Error: \(error.localizedDescription)")
                    self.errorMessage = "Failed to get tokens: \(error.localizedDescription)"
                }
            }
        }
    }

    // --- Token Refresh ---
    // Added a completion handler to know if refresh was successful
    func refreshToken(completion: ((Bool) -> Void)? = nil) {
        guard !isLoading else {
            completion?(false)
            return
        }
        guard let refreshToken = currentTokens?.refreshToken else {
            print("Error: No refresh token available for refresh.")
            logout() // Force re-login if no refresh token exists
            completion?(false)
            return
        }

        isLoading = true
        errorMessage = nil

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
                    self.errorMessage = "Session expired. Please log in again. (\(error.localizedDescription))"
                    // Force logout on persistent refresh failure (e.g., invalid_grant)
                    if let apiError = error as? APIError, apiError.isAuthError {
                        self.logout()
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
            completion(.failure(APIError.invalidRequest(message: "Invalid parameters for token request.")))
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
                if let json = try? JSONSerialization.jsonObject(with: data, options: []) { print("Received JSON for Token Error: ", json) }
                completion(.failure(APIError.decodingError(error)))
            }
        }.resume()
    }

    // Helper to process successful token response and update state
    private func processSuccessfulTokenResponse(_ tokenResponse: TokenResponse, explicitRefreshToken: String? = nil) {
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

    // --- Fetch User Profile ---
    func fetchUserProfile() {
        makeAPIRequest(
            url: SpotifyConstants.userProfileEndpoint,
            responseType: SpotifyUserProfile.self,
            currentAttempt: 1,
            maxAttempts: 2 // Allow one retry after token refresh
        ) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isLoading = false // Assuming general loading might cover profile fetch initially
                switch result {
                case .success(let profile):
                    self.userProfile = profile
                    self.errorMessage = nil // Clear error on success
                    print("Successfully fetched user profile for \(profile.displayName)")
                case .failure(let error):
                    print("Fetch Profile Error: \(error.localizedDescription)")
                    self.errorMessage = "Could not fetch profile: \(error.localizedDescription)"
                }
            }
        }
    }


    // --- Fetch User Playlists ---
    // Fetches the first page or the next page if available
    func fetchUserPlaylists(loadNextPage: Bool = false) {
        guard !isLoadingPlaylists else { return } // Prevent concurrent loads
        guard isLoggedIn, currentTokens?.accessToken != nil else {
            handlePlaylistError("Cannot fetch playlists: Not logged in.")
            return
        }

        var urlToFetch: URL? = SpotifyConstants.userPlaylistsEndpoint

        if loadNextPage {
            guard let nextUrlString = playlistNextPageUrl else {
                print("Playlist Fetch: No next page URL available.")
                return // Nothing more to load
            }
            urlToFetch = URL(string: nextUrlString)
        } else {
            // Reset playlists if fetching the first page
            userPlaylists = []
            playlistNextPageUrl = nil
            playlistErrorMessage = nil
        }

        guard let finalUrl = urlToFetch else {
            handlePlaylistError("Invalid URL for fetching playlists.")
            return
        }

        isLoadingPlaylists = true
        playlistErrorMessage = nil

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
                    if loadNextPage {
                        self.userPlaylists.append(contentsOf: playlistResponse.items)
                        print("Loaded next page of playlists. Total: \(self.userPlaylists.count)")
                    } else {
                        self.userPlaylists = playlistResponse.items
                        print("Fetched initial playlists. Count: \(self.userPlaylists.count)")
                    }
                    // Update the URL for the *next* page
                    self.playlistNextPageUrl = playlistResponse.next
                    self.playlistErrorMessage = nil // Clear error on success

                case .failure(let error):
                    print("Fetch Playlists Error: \(error.localizedDescription)")
                    self.playlistErrorMessage = "Could not fetch playlists: \(error.localizedDescription)"
                }
            }
        }
    }

    // --- Generic API Request Function ---
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
            completion(.failure(APIError.maxRetriesReached))
            return
        }

        guard let accessToken = currentTokens?.accessToken else {
            completion(.failure(APIError.notLoggedIn))
            return
        }

        // --- Check for Token Expiry before making the call ---
        if let expiryDate = currentTokens?.expiryDate, expiryDate <= Date() {
            print("Token likely expired, attempting refresh before API call to \(url.lastPathComponent)...")
            refreshToken { [weak self] success in
                guard let self = self else {
                    completion(.failure(APIError.unknown)); return
                }
                if success {
                    print("Token refreshed successfully. Retrying API call to \(url.lastPathComponent)...")
                    // Important: Use the *updated* access token for the retry
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
                    print("Token refresh failed. Aborting API call to \(url.lastPathComponent).")
                    completion(.failure(APIError.tokenRefreshFailed))
                }
            }
            return // Exit the current function call to let the refresh happen
        }
        // --- End Token Expiry Check ---


        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        if let body = body, (method == "POST" || method == "PUT") {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type") // Assuming JSON body
            request.httpBody = body
        }

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else {
                completion(.failure(APIError.unknown)); return
            }

            if let error = error {
                completion(.failure(APIError.networkError(error)))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(APIError.invalidResponse))
                return
            }

            // --- Handle Auth Error (401/403) by Refreshing Token ---
            if (httpResponse.statusCode == 401 || httpResponse.statusCode == 403) {
                print("Received \(httpResponse.statusCode) for \(url.lastPathComponent). Token might be invalid/expired. Attempting refresh...")
                refreshToken { [weak self] success in
                    guard let self = self else {
                        completion(.failure(APIError.unknown)); return
                    }
                    if success {
                        print("Token refreshed. Retrying API call to \(url.lastPathComponent)...")
                        // Retry the request - Increment attempt count
                        self.makeAPIRequest(
                            url: url,
                            method: method,
                            body: body,
                            responseType: responseType,
                            currentAttempt: currentAttempt + 1,
                            maxAttempts: maxAttempts,
                            completion: completion
                        )
                    } else {
                        print("Token refresh failed after \(httpResponse.statusCode). Aborting API call to \(url.lastPathComponent).")
                        // Pass specific error indicating auth failure after refresh attempt
                        completion(.failure(APIError.authenticationFailed))
                        // Optional: Log out the user immediately if auth fails persistently
                        DispatchQueue.main.async { self.logout() }
                    }
                }
                return // Exit the current dataTask closure to allow refresh and retry
            }
            // --- End Auth Error Handling ---


            guard (200...299).contains(httpResponse.statusCode) else {
                let errorDetails = self.extractErrorDetails(from: data, statusCode: httpResponse.statusCode)
                completion(.failure(APIError.httpError(statusCode: httpResponse.statusCode, details: errorDetails)))
                return
            }

            guard let data = data else {
                completion(.failure(APIError.noData))
                return
            }

            // Special case: If expecting no data (e.g., 204 No Content)
            if data.isEmpty && T.self == EmptyResponse.self {
                if let empty = EmptyResponse() as? T {
                    completion(.success(empty))
                } else {
                    completion(.failure(APIError.decodingError(nil))) // Should not happen
                }
                return
            }


            do {
                let decodedObject = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decodedObject))
            } catch {
                print("API JSON Decoding Error for \(T.self) from \(url.lastPathComponent): \(error)")
                print("Raw response data: \(String(data: data, encoding: .utf8) ?? "Unable to decode data")")
                completion(.failure(APIError.decodingError(error)))
            }
        }.resume()
    }


    // --- Logout ---
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
        if let savedTokens = UserDefaults.standard.data(forKey: SpotifyConstants.tokenUserDefaultsKey) {
            if let decodedTokens = try? JSONDecoder().decode(StoredTokens.self, from: savedTokens) {
                self.currentTokens = decodedTokens
                print("Tokens loaded from UserDefaults.")
                return
            } else {
                print("Error: Failed to decode saved tokens. Clearing potentially corrupted data.")
                clearTokens() // Clear corrupted data
            }
        }
        print("No saved tokens found in UserDefaults.")
        self.currentTokens = nil
    }

    private func clearTokens() {
        UserDefaults.standard.removeObject(forKey: SpotifyConstants.tokenUserDefaultsKey)
        print("Tokens cleared from UserDefaults.")
    }

    // --- Error Handling Helpers ---
    private func handleError(_ message: String, clearVerifier: Bool = false) {
        DispatchQueue.main.async {
            self.errorMessage = message
            if clearVerifier {
                self.currentPKCEVerifier = nil
            }
        }
        print("Error: \(message)")
    }

    private func handlePlaylistError(_ message: String) {
        DispatchQueue.main.async {
            self.playlistErrorMessage = message
        }
        print("Playlist Error: \(message)")
    }

    private func extractErrorDetails(from data: Data?, statusCode: Int) -> String {
        guard let data = data else { return "Status code \(statusCode)" }
        // Try decoding Spotify's standard error object
        if let spotifyError = try? JSONDecoder().decode(SpotifyErrorResponse.self, from: data) {
            return spotifyError.error.message ?? "Status code \(statusCode) (Spotify Error)"
        }
        // Fallback to generic JSON error or plain text
        if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
           let errorDesc = json["error_description"] as? String ?? json["error"] as? String {
            return errorDesc
        }
        if let text = String(data: data, encoding: .utf8), !text.isEmpty {
            return text
        }
        return "Status code \(statusCode)"
    }
}

// MARK: - API Error Enum
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
        // Updated to find the key window more reliably
        let keyWindow = UIApplication.shared.connectedScenes
            .filter({$0.activationState == .foregroundActive})
            .map({$0 as? UIWindowScene})
            .compactMap({$0})
            .first?.windows
            .filter({$0.isKeyWindow}).first
        return keyWindow ?? ASPresentationAnchor()
    }
}


// MARK: - PKCE Helper Extension
extension Data {
    func base64URLEncodedString() -> String {
        return self.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}

// MARK: - SwiftUI View
struct AuthenticationFlowView: View {
    // Use @StateObject if this view creates the instance,
    // Use @ObservedObject if it's passed in (like from the App struct)
    @StateObject var authManager = SpotifyAuthManager()

    var body: some View {
        NavigationView {
            Group { // Use Group to switch between major views
                if !authManager.isLoggedIn {
                    loggedOutView
                        .navigationTitle("Spotify Login")
                } else {
                    loggedInContentView
                        .navigationTitle("Your Spotify")
                }
            }
            .overlay { // Show loading indicator overlay
                if authManager.isLoading {
                    VStack {
                        ProgressView("Authenticating...")
                            .padding()
                            .background(Color(.systemBackground).opacity(0.8))
                            .cornerRadius(10)
                    }
                }
            }
            .alert("Error", isPresented: Binding(get: { authManager.errorMessage != nil }, set: { if !$0 { authManager.errorMessage = nil } }), presenting: authManager.errorMessage) { message in
                Button("OK") { authManager.errorMessage = nil }
            } message: { message in
                Text(message)
            }

        }
        // Optional: Handle URL callback if needed at this level
        // .onOpenURL { url in
        //     // Pass the URL to the manager if it needs to handle deep links post-auth
        // }
    }

    // MARK: Logged Out View
    private var loggedOutView: some View {
        VStack {
            Spacer() // Pushes content to center

            Text("Connect your Spotify account to continue.")
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding()

            Button {
                authManager.initiateAuthorization()
            } label: {
                HStack {
                    Image(systemName: "music.note.list") // Placeholder
                        .foregroundColor(.white)
                    Text("Log in with Spotify")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 25)
                .background(Color(red: 30/255, green: 215/255, blue: 96/255)) // Spotify Green
                .cornerRadius(30) // More rounded
                .shadow(radius: 5)
            }
            .disabled(authManager.isLoading) // Disable while loading

            Spacer() // Pushes content to center
            Spacer() // Add more space at bottom maybe
        }
        .padding()
    }

    // MARK: Logged In Content View
    private var loggedInContentView: some View {
        List {
            // Section for User Profile
            Section(header: Text("Profile")) {
                profileSection
            }

            // Section for Playlists
            Section(header: Text("My Playlists")) {
                playlistSection
            }

            // Section for Actions / Debug
            Section(header: Text("Account Actions")) {
                actionSection
            }
        }
        .listStyle(InsetGroupedListStyle()) // Nicer grouping
        .refreshable {
            // Allow pull-to-refresh for profile and playlists
            print("Refreshing data...")
            authManager.fetchUserProfile()
            authManager.fetchUserPlaylists(loadNextPage: false) // Fetch first page on refresh
        }
        .onAppear {
            // Fetch data only if it's missing when the view appears
            if authManager.userProfile == nil {
                authManager.fetchUserProfile()
            }
            if authManager.userPlaylists.isEmpty {
                authManager.fetchUserPlaylists()
            }
        }
    }

    // MARK: Profile Section (Extracted)
    @ViewBuilder // Allows returning different view types
    private var profileSection: some View {
        if let profile = authManager.userProfile {
            HStack {
                AsyncImage(url: URL(string: profile.images?.first?.url ?? "" )) { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 60, height: 60) // Slightly smaller
                        .clipShape(Circle())
                } placeholder: {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                        .foregroundColor(.gray)
                }
                .padding(.trailing, 8)

                VStack(alignment: .leading) {
                    Text(profile.displayName)
                        .font(.headline)
                    Text(profile.email)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            .padding(.vertical, 5) // Add padding within the cell
        } else {
            // Show placeholder while loading profile
            HStack {
                Spacer()
                ProgressView()
                Text("Loading Profile...")
                Spacer()
            }.padding()
        }
    }

    // MARK: Playlist Section (Extracted)
    @ViewBuilder
    private var playlistSection: some View {
        if authManager.isLoadingPlaylists && authManager.userPlaylists.isEmpty {
            HStack { // Loading indicator for initial playlist load
                Spacer()
                ProgressView()
                Text("Loading Playlists...")
                Spacer()
            }.padding()
        } else if let errorMsg = authManager.playlistErrorMessage {
            Text("Error loading playlists: \(errorMsg)")
                .foregroundColor(.red)
                .padding()
        } else if authManager.userPlaylists.isEmpty && !authManager.isLoadingPlaylists {
            Text("You don't have any playlists yet.")
                .foregroundColor(.gray)
                .padding()
        } else {
            // Display fetched playlists
            ForEach(authManager.userPlaylists) { playlist in
                HStack {
                    AsyncImage(url: URL(string: playlist.images?.first?.url ?? "")) { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 45, height: 45)
                            .cornerRadius(4)
                    } placeholder: {
                        Image(systemName: "music.note.list")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 45, height: 45)
                            .padding(8)
                            .background(Color.gray.opacity(0.3))
                            .foregroundColor(.gray)
                            .cornerRadius(4)
                    }

                    VStack(alignment: .leading) {
                        Text(playlist.name).lineLimit(1)
                        Text("By \(playlist.owner.displayName ?? "Spotify") • \(playlist.tracks.total) tracks")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }

                    Spacer()

                    // Indicate collaborative playlists
                    if playlist.collaborative {
                        Image(systemName: "person.2.fill")
                            .foregroundColor(.blue)
                    }
                }
                // Add pagination trigger
                if playlist.id == authManager.userPlaylists.last?.id && authManager.playlistNextPageUrl != nil {
                    // Show a loading indicator or button at the bottom
                    ProgressView()
                        .padding()
                        .frame(maxWidth: .infinity)
                        .onAppear {
                            print("Reached end of playlist, loading next page...")
                            authManager.fetchUserPlaylists(loadNextPage: true)
                        }
                }
            }
        }

        // Show loading indicator only when loading the *next* page below the list
        if authManager.isLoadingPlaylists && !authManager.userPlaylists.isEmpty {
            ProgressView()
                .padding()
                .frame(maxWidth: .infinity)
        }

    }

    // MARK: Action Section (Extracted)
    private var actionSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            // Token Refresh Button
            Button("Refresh Token") {
                authManager.refreshToken()
            }
            .disabled(authManager.currentTokens?.refreshToken == nil || authManager.isLoading)

            // Logout Button
            Button("Log Out", role: .destructive) { // Use destructive role for logout
                authManager.logout()
            }

            // Debug Token Info (Optional)
            if let tokens = authManager.currentTokens {
                DisclosureGroup("Token Details (Debug)") {
                    VStack(alignment: .leading) {
                        Text("Access Token:").font(.caption.weight(.bold))
                        Text(tokens.accessToken).font(.caption).lineLimit(1)
                        if let expiry = tokens.expiryDate {
                            Text("Expires: \(expiry, style: .relative)")
                                .font(.caption)
                                .foregroundColor(expiry <= Date() ? .red : .green) // Highlight expired
                        }
                        Text("Refresh Token Present: \(tokens.refreshToken != nil ? "Yes" : "No")")
                            .font(.caption)
                            .foregroundColor(tokens.refreshToken != nil ? .primary : .orange)

                    }
                    .padding(.top, 5)
                }
                .font(.callout)
            }
        }
        .padding(.vertical, 5) // Add padding within the cell
    }
}


// MARK: - App Entry Point (Example)
// @main
// struct SpotifyPKCEApp: App {
//     var body: some Scene {
//         WindowGroup {
//             AuthenticationFlowView()
//         }
//     }
// }

// MARK: - Previews
#Preview("Logged Out") {
    AuthenticationFlowView()
}

#Preview("Logged In - Loading") {
    let manager = SpotifyAuthManager()
    manager.isLoggedIn = true
    manager.userProfile = nil // Simulate loading profile
    manager.userPlaylists = []
    manager.isLoadingPlaylists = true
    return AuthenticationFlowView(authManager: manager)
}

//#Preview("Logged In - With Data") {
//    let manager = SpotifyAuthManager()
//    manager.isLoggedIn = true
//    manager.userProfile = SpotifyUserProfile(id: "preview_user", displayName: "Preview User", email: "preview@example.com", images: [SpotifyImage(url: "https://via.placeholder.com/150", height: 150, width: 150)], externalUrls: [:])
//    manager.currentTokens = StoredTokens(accessToken: "dummy_access_token_very_long...", refreshToken: "dummy_refresh_token...", expiryDate: Date().addingTimeInterval(3600))
//    manager.userPlaylists = [
//        SpotifyPlaylist(id: "pl1", name: "Chill Vibes", description: "Music to relax to", owner: SpotifyPlaylistOwner(id: "user1", displayName: "Alice", externalUrls: [:]), collaborative: false, tracks: PlaylistTracksInfo(href: "", total: 50), images: [SpotifyImage(url: "https://via.placeholder.com/100", height: 100, width: 100)], externalUrls: [:], publicPlaylist: true),
//        SpotifyPlaylist(id: "pl2", name: "Workout Beats", description: nil, owner: SpotifyPlaylistOwner(id: "user2", displayName: "Bob", externalUrls: [:]), collaborative: true, tracks: PlaylistTracksInfo(href: "", total: 100), images: nil, externalUrls: [:], publicPlaylist: false),
//        SpotifyPlaylist(id: "pl3", name: "Focus Flow", description: "Deep focus music", owner: SpotifyPlaylistOwner(id: "spotify", displayName: "Spotify", externalUrls: [:]), collaborative: false, tracks: PlaylistTracksInfo(href: "", total: 75), images: [SpotifyImage(url: "https://via.placeholder.com/100", height: 100, width: 100)], externalUrls: [:], publicPlaylist: true)
//    ]
//    manager.playlistNextPageUrl = "https://api.spotify.com/v1/me/playlists?offset=3&limit=3" // Simulate next page
//
//    AuthenticationFlowView(authManager: manager)
//}

#Preview("Logged In - Playlist Error") {
    let manager = SpotifyAuthManager()
    manager.isLoggedIn = true
    manager.userProfile = SpotifyUserProfile(id: "preview_user", displayName: "Preview User", email: "preview@example.com", images: [SpotifyImage(url: "https://via.placeholder.com/150", height: 150, width: 150)], externalUrls: [:])
    manager.playlistErrorMessage = "Could not reach Spotify servers (Network Error)"
    return AuthenticationFlowView(authManager: manager)
}
