//
//  Google_OAuth_2_for_Mobile_App_Authorization_Flow.swift
//  MyApp
//
//  Created by Cong Le on 3/31/25.
//

import Foundation
import AuthenticationServices // For ASWebAuthenticationSession
import CommonCrypto // For SHA256 (used by PKCE)

// MARK: - Configuration Data

struct OAuthConfiguration {
    let clientId: String
    let redirectUri: String // Must match one configured in Google Cloud Console
    let scope: String // Space-separated list of scopes
    let authorizationEndpoint: URL = URL(string: "https://accounts.google.com/o/oauth2/v2/auth")!
    let tokenEndpoint: URL = URL(string: "https://oauth2.googleapis.com/token")!
    let revocationEndpoint: URL = URL(string: "https://oauth2.googleapis.com/revoke")!
    // Add other endpoints or config as needed
}

// MARK: - Token Data Structure

struct TokenData: Codable, Sendable {
    let accessToken: String
    let refreshToken: String? // Refresh tokens are standard for installed apps
    let expiresIn: Int // Lifetime in seconds for access token
    let scope: String // Actual scopes granted
    let tokenType: String
    let idToken: String? // If openid scope was requested
    // let refreshTokenExpiresIn: Int? // Only if time-based access was granted

    // Calculated property for access token expiry date
    var expiryDate: Date? {
        return Calendar.current.date(byAdding: .second, value: expiresIn, to: Date())
    }
}

// MARK: - OAuth Errors

enum OAuthError: Error, LocalizedError, Sendable {
    case missingConfiguration
    case pkceGenerationFailed
    case authenticationSessionFailed(Error?)
    case invalidCallbackURL
    case stateMismatch
    case authorizationCodeMissing
    case tokenExchangeFailed(statusCode: Int, data: Data?)
    case tokenDecodingFailed(Error)
    case apiRequestFailed(Error)
    case noRefreshToken
    case tokenRefreshFailed(statusCode: Int, data: Data?)
    case accessTokenExpiredOrMissing
    case tokenRevocationFailed(statusCode: Int, data: Data?)
    case keychainError(OSStatus)

    var errorDescription: String? {
        switch self {
        case .missingConfiguration: return "OAuth configuration is missing."
        case .pkceGenerationFailed: return "Failed to generate PKCE code verifier or challenge."
        case .authenticationSessionFailed(let underlyingError):
            return "Authentication session failed. \(underlyingError?.localizedDescription ?? "Unknown reason.")"
        case .invalidCallbackURL: return "Received an invalid callback URL."
        case .stateMismatch: return "OAuth state parameter did not match."
        case .authorizationCodeMissing: return "Authorization code not found in callback URL."
        case .tokenExchangeFailed(let statusCode, _): return "Token exchange failed with status code \(statusCode)."
        case .tokenDecodingFailed(let error): return "Failed to decode token response: \(error.localizedDescription)"
        case .apiRequestFailed(let error): return "API request failed: \(error.localizedDescription)"
        case .noRefreshToken: return "No refresh token available to refresh access token."
        case .tokenRefreshFailed(let statusCode, _): return "Token refresh failed with status code \(statusCode)."
        case .accessTokenExpiredOrMissing: return "Access token is missing or expired, and refresh failed or wasn't possible."
        case .tokenRevocationFailed(let statusCode, _): return "Token revocation failed with status code \(statusCode)."
        case .keychainError(let status): return "Keychain operation failed with status: \(status)."
        }
    }
}

// MARK: - OAuth Manager Class

@MainActor // Use MainActor if this class updates UI state directly or indirectly
class OAuthManager: NSObject, ObservableObject, ASWebAuthenticationPresentationContextProviding {

    private var configuration: OAuthConfiguration?
    private var currentTokenData: TokenData?
    private var currentAccessTokenExpiry: Date?

    // Temporary storage for PKCE and state during auth flow
    private var currentCodeVerifier: String?
    private var currentState: String?
    private var currentAuthenticationSession: ASWebAuthenticationSession?

    // Keychain Service identifiers (customize these)
    private let keychainService = "com.yourapp.oauth"
    private let keychainTokenAccount = "googleTokens"

    // Published properties for UI updates (if using SwiftUI)
    @Published var isAuthenticated: Bool = false
    @Published var lastError: OAuthError? = nil

    override init() {
        super.init()
        loadTokensFromKeychain() // Load tokens on initialization
    }

    // MARK: - Configuration

    func configure(clientId: String, redirectUri: String, scopes: [String]) {
        self.configuration = OAuthConfiguration(
            clientId: clientId,
            redirectUri: redirectUri,
            scope: scopes.joined(separator: " ") // Convert array to space-delimited string
        )
        // Check if loaded tokens are still valid after configuration
        Task {
            self.isAuthenticated = await checkTokenValidity()
        }
    }

    // MARK: - Authentication Flow (Sign In)

    func signIn() async throws {
        guard let config = configuration else {
            throw OAuthError.missingConfiguration
        }

        // 1. Generate PKCE and State
        guard let (verifier, challenge) = generatePKCE() else {
            throw OAuthError.pkceGenerationFailed
        }
        self.currentCodeVerifier = verifier
        self.currentState = generateRandomString(length: 32) // Generate state CSRF token

        // 2. Construct Authorization URL
        var urlComponents = URLComponents(url: config.authorizationEndpoint, resolvingAgainstBaseURL: false)!
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: config.clientId),
            URLQueryItem(name: "redirect_uri", value: config.redirectUri),
            URLQueryItem(name: "scope", value: config.scope),
            URLQueryItem(name: "response_type", value: "code"), // Use Authorization Code flow
            URLQueryItem(name: "state", value: currentState!),
            URLQueryItem(name: "code_challenge", value: challenge),
            URLQueryItem(name: "code_challenge_method", value: "S256") // Recommended method
            // Optional: Add 'login_hint' or other parameters if needed
        ]

        guard let authURL = urlComponents.url else {
            throw OAuthError.invalidCallbackURL // Or a more specific error
        }

        // 3. Start ASWebAuthenticationSession
        try await performAuthenticationSession(url: authURL, callbackScheme: URL(string: config.redirectUri)?.scheme)
    }

    private func performAuthenticationSession(url: URL, callbackScheme: String?) async throws {
         return try await withCheckedThrowingContinuation { [weak self] (continuation: CheckedContinuation<Void, Error>) in
            guard let self = self else {
                 continuation.resume(throwing: OAuthError.authenticationSessionFailed(nil)) // Or a different error
                 return
             }

            self.currentAuthenticationSession = ASWebAuthenticationSession(
                url: url,
                callbackURLScheme: callbackScheme
            ) { callbackURL, error in
                Task { // Ensure processing happens on the correct actor context
                    await self.handleAuthenticationCallback(callbackURL: callbackURL, error: error, continuation: continuation)
                }
            }

            self.currentAuthenticationSession?.presentationContextProvider = self
            // For iOS 13+, prevents session from requiring user interaction if cookies/session exist
            self.currentAuthenticationSession?.prefersEphemeralWebBrowserSession = false

            if !(self.currentAuthenticationSession?.start() ?? false) {
                continuation.resume(throwing: OAuthError.authenticationSessionFailed(nil)) // Failed to start
            }
            // Continuation is resumed within handleAuthenticationCallback
        }
    }


    private func handleAuthenticationCallback(callbackURL: URL?, error: Error?, continuation: CheckedContinuation<Void, Error>) async {
        // Clear temporary PKCE/state values regardless of outcome
        let verifier = self.currentCodeVerifier
        let expectedState = self.currentState
        self.currentCodeVerifier = nil
        self.currentState = nil
        self.currentAuthenticationSession = nil // Release session

        if let error = error {
            // Check if the error is user cancellation
            if let authError = error as? ASWebAuthenticationSessionError,
               authError.code == .canceledLogin {
                print("OAuth Login Cancelled by User")
                // Don't throw an error for cancellation, just return peacefully
                 continuation.resume()
                return
            } else {
                self.lastError = OAuthError.authenticationSessionFailed(error)
                continuation.resume(throwing: self.lastError!)
                return
            }
        }

        guard let callbackURL = callbackURL else {
            self.lastError = OAuthError.invalidCallbackURL
            continuation.resume(throwing: self.lastError!)
            return
        }

        // 4. Parse Callback URL
        guard let components = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems else {
            self.lastError = OAuthError.invalidCallbackURL
            continuation.resume(throwing: self.lastError!)
            return
        }

        // Check for error parameter
        if let errorParam = queryItems.first(where: { $0.name == "error" })?.value {
            // Handle errors like 'access_denied'
            print("OAuth Error received: \(errorParam)")
            self.lastError = OAuthError.authenticationSessionFailed(nil) // Be more specific if possible
            continuation.resume(throwing: self.lastError!)
            return
        }

        // Verify state
        guard let receivedState = queryItems.first(where: { $0.name == "state" })?.value,
              receivedState == expectedState else {
            self.lastError = OAuthError.stateMismatch
            continuation.resume(throwing: self.lastError!)
            return
        }

        // Extract authorization code
        guard let code = queryItems.first(where: { $0.name == "code" })?.value else {
            self.lastError = OAuthError.authorizationCodeMissing
            continuation.resume(throwing: self.lastError!)
            return
        }

        guard let codeVerifier = verifier else {
             // This should not happen if flow is correct
            self.lastError = OAuthError.pkceGenerationFailed // Reuse error type
            continuation.resume(throwing: self.lastError!)
            return
         }


        // 5. Exchange Code for Tokens
        do {
            try await exchangeCodeForTokens(code: code, codeVerifier: codeVerifier)
            self.isAuthenticated = true
            self.lastError = nil
            continuation.resume() // Success!
        } catch let exchangeError as OAuthError {
            self.isAuthenticated = false
            self.lastError = exchangeError
             continuation.resume(throwing: exchangeError)
        } catch {
            self.isAuthenticated = false
            self.lastError = OAuthError.tokenExchangeFailed(statusCode: -1, data: nil) // Generic fallback
             continuation.resume(throwing: self.lastError!)
         }
    }

    // MARK: - Token Exchange (Step 5)

    private func exchangeCodeForTokens(code: String, codeVerifier: String) async throws {
        guard let config = configuration else {
            throw OAuthError.missingConfiguration
        }

        var request = URLRequest(url: config.tokenEndpoint)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "client_id", value: config.clientId),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "code_verifier", value: codeVerifier), // PKCE verifier
            URLQueryItem(name: "grant_type", value: "authorization_code"),
            URLQueryItem(name: "redirect_uri", value: config.redirectUri)
            // NO client_secret for installed apps
        ]

        guard let bodyData = components.query?.data(using: .utf8) else {
            throw OAuthError.tokenExchangeFailed(statusCode: -1, data: nil) // Or different error
        }
        request.httpBody = bodyData

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw OAuthError.tokenExchangeFailed(statusCode: -1, data: data)
        }

        guard (200...299).contains(httpResponse.statusCode) else {
             print("Token exchange failed body: \(String(data: data, encoding: .utf8) ?? "nil")")
            throw OAuthError.tokenExchangeFailed(statusCode: httpResponse.statusCode, data: data)
        }

        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase // Handles keys like "access_token"
            let receivedTokenData = try decoder.decode(TokenData.self, from: data)
            // TODO: Verify granted scopes vs requested scopes if needed
            // let grantedScopes = Set(receivedTokenData.scope.split(separator: " "))
            // let requestedScopes = Set(config.scope.split(separator: " "))
            // if !grantedScopes.isSuperset(of: requestedScopes) { ... handle partial grant ... }

            saveTokensToKeychain(tokenData: receivedTokenData) // Save securely
            self.currentTokenData = receivedTokenData
            self.currentAccessTokenExpiry = receivedTokenData.expiryDate
        } catch {
            throw OAuthError.tokenDecodingFailed(error)
        }
    }

    // MARK: - Token Refresh

    func refreshAccessToken() async throws -> String {
        guard let config = configuration else {
            throw OAuthError.missingConfiguration
        }
        guard let currentTokens = loadTokensFromKeychain(), // Get latest from secure storage
              let refreshToken = currentTokens.refreshToken else {
            clearTokens() // Ensure inconsistent state is cleared
            throw OAuthError.noRefreshToken
        }

        print("Attempting token refresh...")

        var request = URLRequest(url: config.tokenEndpoint)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "client_id", value: config.clientId),
            URLQueryItem(name: "refresh_token", value: refreshToken),
            URLQueryItem(name: "grant_type", value: "refresh_token")
            // NO client_secret
        ]

        request.httpBody = components.query?.data(using: .utf8)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
             print("Refresh failed - non-HTTP response?")
            throw OAuthError.tokenRefreshFailed(statusCode: -1, data: data)
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            print("Token refresh failed! Status: \(httpResponse.statusCode), Body: \(String(data: data, encoding: .utf8) ?? "nil")")
            // If refresh fails (e.g., 400 invalid_grant), the refresh token is likely invalid.
            if httpResponse.statusCode == 400 || httpResponse.statusCode == 401 {
                clearTokens() // User needs to sign in again
                 self.isAuthenticated = false // Update state
                throw OAuthError.noRefreshToken // Or a more specific "Refresh Token Invalidated" error
            }
            throw OAuthError.tokenRefreshFailed(statusCode: httpResponse.statusCode, data: data)
        }

        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            // Google often returns same fields as initial exchange, but refresh_token might be missing
            struct RefreshResponse: Codable {
                let accessToken: String
                let expiresIn: Int
                let scope: String? // Scope might not always be returned on refresh
                let tokenType: String
                let idToken: String?
            }
            let refreshResponse = try decoder.decode(RefreshResponse.self, from: data)

            // Update only the necessary parts, keeping the original refresh token
            let updatedTokenData = TokenData(
                accessToken: refreshResponse.accessToken,
                refreshToken: refreshToken, // Keep original refresh token
                expiresIn: refreshResponse.expiresIn,
                scope: refreshResponse.scope ?? currentTokens.scope, // Use old scope if not returned
                tokenType: refreshResponse.tokenType,
                idToken: refreshResponse.idToken ?? currentTokens.idToken // Use old idToken if not returned
                // refreshTokenExpiresIn: currentTokens.refreshTokenExpiresIn // Keep original time-based expiry if applicable
            )

            saveTokensToKeychain(tokenData: updatedTokenData) // Save updated data
            self.currentTokenData = updatedTokenData
            self.currentAccessTokenExpiry = updatedTokenData.expiryDate
             self.isAuthenticated = true // Should be true if refresh succeeded
            print("Token refresh successful.")
            return updatedTokenData.accessToken
        } catch {
             print("Failed to decode refresh response: \(error)")
            throw OAuthError.tokenDecodingFailed(error)
        }
    }

    // MARK: - Accessing Tokens

    func getAccessToken() async throws -> String {
        if let token = currentTokenData?.accessToken, let expiry = currentAccessTokenExpiry, expiry > Date() {
            // Return valid, non-expired token
            return token
        }

        // If token is expired or missing, try refreshing
        print("Access token expired or missing, attempting refresh.")
        do {
            return try await refreshAccessToken()
        } catch {
            // If refresh fails, throw error indicating need for re-authentication
             print("Refresh failed during getAccessToken: \(error)")
             self.isAuthenticated = false
            throw OAuthError.accessTokenExpiredOrMissing
        }
    }

    // Check validity without necessarily refreshing immediately
    private func checkTokenValidity() async -> Bool {
         guard let expiry = currentAccessTokenExpiry else { return false }
         if expiry > Date() {
             return true // Access token is still valid
         } else {
             // Access token expired, check if refresh token exists
             return currentTokenData?.refreshToken != nil
         }
     }


    // MARK: - Authenticated API Calls

    func makeAuthenticatedRequest(url: URL, method: String = "GET", body: Data? = nil) async throws -> (Data, HTTPURLResponse) {
        let token = try await getAccessToken() // This handles refresh if needed

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        if let body = body {
            request.httpBody = body
            // Potentially set Content-Type header here if needed (e.g., application/json)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw OAuthError.apiRequestFailed(URLError(.badServerResponse))
            }
            // Could check status code here or let caller handle it
            return (data, httpResponse)
        } catch {
            throw OAuthError.apiRequestFailed(error)
        }
    }

    // MARK: - Sign Out / Revocation

    func signOut() async {
        // Optionally revoke the token on Google's side first
        if let tokenToRevoke = currentTokenData?.refreshToken ?? currentTokenData?.accessToken {
            try? await revokeToken(token: tokenToRevoke)
        }
        // Always clear local tokens
        clearTokens()
        self.isAuthenticated = false
    }

    func revokeToken(token: String) async throws {
        guard let config = configuration else {
            throw OAuthError.missingConfiguration
        }

        var request = URLRequest(url: config.revocationEndpoint)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        var components = URLComponents()
        components.queryItems = [URLQueryItem(name: "token", value: token)]
        request.httpBody = components.query?.data(using: .utf8)

        print("Attempting to revoke token...")
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw OAuthError.tokenRevocationFailed(statusCode: -1, data: data)
        }

        // Google Revoke endpoint returns 200 OK on success *or* if token was already invalid.
        // It returns 400 Bad Request for malformed requests.
        guard httpResponse.statusCode == 200 || httpResponse.statusCode == 400 else {
             print("Token revocation unexpected status: \(httpResponse.statusCode)")
            throw OAuthError.tokenRevocationFailed(statusCode: httpResponse.statusCode, data: data)
        }

        // Even if revocation fails (e.g., network error), clear local tokens
        clearTokens()
        self.isAuthenticated = false
        print("Token revocation processed (or attempted). Local tokens cleared.")
    }


    // MARK: - Secure Token Storage (Keychain Placeholders)

    private func saveTokensToKeychain(tokenData: TokenData) {
        print("Attempting to save tokens to Keychain...")
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(tokenData)

            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: keychainService,
                kSecAttrAccount as String: keychainTokenAccount,
                kSecValueData as String: data,
                kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly // Good default
            ]

            // Delete existing item first to ensure update works
            SecItemDelete(query as CFDictionary)

            // Add new item
            let status = SecItemAdd(query as CFDictionary, nil)
            if status == errSecSuccess {
                print("Tokens successfully saved to Keychain.")
            } else {
                 print("Keychain save error: \(status)")
                // Don't throw here? Maybe log or handle differently
                 self.lastError = .keychainError(status)
            }
        } catch {
             print("Failed to encode token data for Keychain: \(error)")
            // Handle encoding error
             self.lastError = .tokenDecodingFailed(error) // Reusing error type slightly
        }
    }

    private func loadTokensFromKeychain() -> TokenData? {
        print("Attempting to load tokens from Keychain...")
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: keychainTokenAccount,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)

        if status == errSecSuccess {
            guard let data = dataTypeRef as? Data else {
                 print("Keychain data retrieval failed conversion")
                 return nil
             }
            do {
                let decoder = JSONDecoder()
                let tokenData = try decoder.decode(TokenData.self, from: data)
                print("Tokens successfully loaded from Keychain.")
                // Update manager state immediately after loading
                self.currentTokenData = tokenData
                self.currentAccessTokenExpiry = tokenData.expiryDate
                Task { // Check validity async
                     self.isAuthenticated = await checkTokenValidity()
                 }
                return tokenData
            } catch {
                 print("Failed to decode token data from Keychain: \(error)")
                 // Clear potentially corrupt data
                 clearTokens()
                 return nil
             }
        } else if status == errSecItemNotFound {
            print("No tokens found in Keychain.")
            return nil
        } else {
             print("Keychain load error: \(status)")
             self.lastError = .keychainError(status)
            return nil
        }
    }

    private func clearTokens() {
        print("Clearing tokens from Keychain and memory...")
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: keychainTokenAccount
        ]
        let status = SecItemDelete(query as CFDictionary)
         if status != errSecSuccess && status != errSecItemNotFound {
             print("Keychain delete error: \(status)")
             self.lastError = .keychainError(status)
         }
        // Clear in-memory state
        currentTokenData = nil
        currentAccessTokenExpiry = nil
         Task {
             self.isAuthenticated = false // Ensure published property is updated
         }
    }

    // MARK: - PKCE Helper Functions

    private func generatePKCE() -> (verifier: String, challenge: String)? {
        guard let verifier = generateRandomString(length: 128) else { return nil } // Max length 128
        guard let challenge = generateCodeChallenge(from: verifier) else { return nil }
        return (verifier, challenge)
    }

    private func generateRandomString(length: Int) -> String? {
        var buffer = [UInt8](repeating: 0, count: length)
        let status = SecRandomCopyBytes(kSecRandomDefault, length, &buffer)
        guard status == errSecSuccess else { return nil }

        // Use URL-safe Base64 encoding
        return Data(buffer).base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "") // No padding
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func generateCodeChallenge(from verifier: String) -> String? {
        guard let data = verifier.data(using: .ascii) else { return nil }

        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        _ = data.withUnsafeBytes {
            CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash)
        }

        // Use URL-safe Base64 encoding without padding
        return Data(hash).base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }


    // MARK: - ASWebAuthenticationPresentationContextProviding

    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        // Return the window associated with your app's UI
        // This requires access to the scene's window, which can be tricky
        // in pure SwiftUI. A common approach involves passing it in or using
        // UIApplication extensions. Using the key window is often sufficient.
        return UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { $0 as? UIWindowScene }
            .first?.windows
            .filter { $0.isKeyWindow }.first ?? ASPresentationAnchor() // Fallback
    }
}

// MARK: - Example Usage (Conceptual)
/*
 // In your SwiftUI View or AppDelegate/SceneDelegate:

 struct ContentView: View {
     @StateObject private var oauthManager = OAuthManager()
     @State private var apiResponse: String = "Not loaded"

     // --- Configuration ---
     private let googleClientID = "YOUR_GOOGLE_CLIENT_ID.apps.googleusercontent.com"
     // Ensure this matches EXACTLY what's in Google Cloud Console for your iOS Client ID
     private let googleRedirectURI = "com.yourcompany.yourapp:/oauth2redirect"
     // Ensure your app handles this URL Scheme in Info.plist
     private let googleScopes = ["https://www.googleapis.com/auth/userinfo.profile", "https://www.googleapis.com/auth/userinfo.email"]
     // --------------------

     var body: some View {
         VStack(spacing: 20) {
             if oauthManager.isAuthenticated {
                 Text("✅ Signed In")
                 Button("Call UserInfo API") {
                     callUserInfoAPI()
                 }
                 Button("Sign Out") {
                     Task {
                         await oauthManager.signOut()
                     }
                 }
                 Text("API Response:\n\(apiResponse)")
                     .lineLimit(nil)
                     .padding()
             } else {
                 Text("❌ Signed Out")
                 Button("Sign In with Google") {
                     Task {
                         do {
                             try await oauthManager.signIn()
                             // Sign-in successful state is updated via @Published property
                         } catch {
                             apiResponse = "Sign In Error: \(error.localizedDescription)"
                             print("Sign In Error: \(error)")
                         }
                     }
                 }
                 if let error = oauthManager.lastError {
                     Text("Last Error: \(error.localizedDescription)")
                         .foregroundColor(.red)
                         .padding()
                 }
             }
         }
         .onAppear {
             oauthManager.configure(
                 clientId: googleClientID,
                 redirectUri: googleRedirectURI,
                 scopes: googleScopes
             )
         }
         // Handle the custom URL Scheme callback (necessary for Custom URI Scheme redirect)
         // This is often done in the App/SceneDelegate or using .onOpenURL in SwiftUI
         .onOpenURL { url in
             // While ASWebAuthenticationSession handles the callback directly,
             // if you were using a different method or needed deep linking,
             // you might need to handle the URL here. For ASWebAuthSession,
             // this might not be strictly necessary for the auth callback itself.
              print("App opened URL: \(url)")
             // Potentially pass the URL to the manager if it needed to handle it manually
         }
     }

     func callUserInfoAPI() {
         Task {
             do {
                 // Example: Google's UserInfo endpoint
                 let url = URL(string: "https://www.googleapis.com/oauth2/v3/userinfo")!
                 let (data, response) = try await oauthManager.makeAuthenticatedRequest(url: url)

                 if (200...299).contains(response.statusCode) {
                     if let jsonString = String(data: data, encoding: .utf8) {
                         apiResponse = "User Info:\n\(jsonString)"
                     } else {
                         apiResponse = "API Success (Status \(response.statusCode)), but failed to decode data."
                     }
                 } else {
                     apiResponse = "API Error: Status \(response.statusCode)\nBody: \(String(data: data, encoding: .utf8) ?? "")"
                 }
             } catch {
                 apiResponse = "API Call Failed: \(error.localizedDescription)"
                 print("API Call Error: \(error)")
             }
         }
     }
 }

 // In your App struct (or AppDelegate/SceneDelegate):
 // - Ensure you have registered the custom URL scheme (`com.yourcompany.yourapp` in this example)
 //   in your Info.plist under "URL Types".

*/
import SwiftUI

struct ContentView: View {
    @StateObject private var oauthManager = OAuthManager()
    @State private var apiResponse: String = "Not loaded"

    // --- Configuration ---
    private let googleClientID = "YOUR_GOOGLE_CLIENT_ID.apps.googleusercontent.com"
    // Ensure this matches EXACTLY what's in Google Cloud Console for your iOS Client ID
    private let googleRedirectURI = "com.yourcompany.yourapp:/oauth2redirect"
    // Ensure your app handles this URL Scheme in Info.plist
    private let googleScopes = ["https://www.googleapis.com/auth/userinfo.profile", "https://www.googleapis.com/auth/userinfo.email"]
    // --------------------

    var body: some View {
        VStack(spacing: 20) {
            if oauthManager.isAuthenticated {
                Text("✅ Signed In")
                Button("Call UserInfo API") {
                    callUserInfoAPI()
                }
                Button("Sign Out") {
                    Task {
                        await oauthManager.signOut()
                    }
                }
                Text("API Response:\n\(apiResponse)")
                    .lineLimit(nil)
                    .padding()
            } else {
                Text("❌ Signed Out")
                Button("Sign In with Google") {
                    Task {
                        do {
                            try await oauthManager.signIn()
                            // Sign-in successful state is updated via @Published property
                        } catch {
                            apiResponse = "Sign In Error: \(error.localizedDescription)"
                            print("Sign In Error: \(error)")
                        }
                    }
                }
                if let error = oauthManager.lastError {
                    Text("Last Error: \(error.localizedDescription)")
                        .foregroundColor(.red)
                        .padding()
                }
            }
        }
        .onAppear {
            oauthManager.configure(
                clientId: googleClientID,
                redirectUri: googleRedirectURI,
                scopes: googleScopes
            )
        }
        // Handle the custom URL Scheme callback (necessary for Custom URI Scheme redirect)
        // This is often done in the App/SceneDelegate or using .onOpenURL in SwiftUI
        .onOpenURL { url in
            // While ASWebAuthenticationSession handles the callback directly,
            // if you were using a different method or needed deep linking,
            // you might need to handle the URL here. For ASWebAuthSession,
            // this might not be strictly necessary for the auth callback itself.
             print("App opened URL: \(url)")
            // Potentially pass the URL to the manager if it needed to handle it manually
        }
    }

    func callUserInfoAPI() {
        Task {
            do {
                // Example: Google's UserInfo endpoint
                let url = URL(string: "https://www.googleapis.com/oauth2/v3/userinfo")!
                let (data, response) = try await oauthManager.makeAuthenticatedRequest(url: url)

                if (200...299).contains(response.statusCode) {
                    if let jsonString = String(data: data, encoding: .utf8) {
                        apiResponse = "User Info:\n\(jsonString)"
                    } else {
                        apiResponse = "API Success (Status \(response.statusCode)), but failed to decode data."
                    }
                } else {
                    apiResponse = "API Error: Status \(response.statusCode)\nBody: \(String(data: data, encoding: .utf8) ?? "")"
                }
            } catch {
                apiResponse = "API Call Failed: \(error.localizedDescription)"
                print("API Call Error: \(error)")
            }
        }
    }
}

#Preview {
    ContentView()
}
