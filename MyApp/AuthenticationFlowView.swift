//
//  AuthenticationFlowView.swift
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
    static let redirectURI = "YOUR_REDIRECT_URI" // <-- REPLACE THIS (e.g., "myapp://callback")
    static let scopes = [
        "user-read-private",
        "user-read-email",
        "playlist-read-private",
        "playlist-modify-public",
        "playlist-modify-private"
        // Add other scopes your app needs
    ]
    static let scopeString = scopes.joined(separator: " ")

    static let authorizationEndpoint = URL(string: "https://accounts.spotify.com/authorize")!
    static let tokenEndpoint = URL(string: "https://accounts.spotify.com/api/token")!
    static let userProfileEndpoint = URL(string: "https://api.spotify.com/v1/me")!

    static let tokenUserDefaultsKey = "spotifyTokens"
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

    enum CodingKeys: String, CodingKey {
        case id
        case displayName = "display_name"
        case email
        case images
    }
}

struct SpotifyImage: Codable {
    let url: String
    let height: Int?
    let width: Int?
}


// MARK: - Authentication Manager (ObservableObject)
class SpotifyAuthManager: ObservableObject {

    @Published var isLoggedIn: Bool = false
    @Published var currentTokens: StoredTokens? = nil
    @Published var userProfile: SpotifyUserProfile? = nil
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    private var currentPKCEVerifier: String?
    private var currentWebAuthSession: ASWebAuthenticationSession?

    init() {
        loadTokens()
        // Optionally trigger a refresh if tokens exist and might be expired
        // Or check validity before setting isLoggedIn = true
        if let tokens = currentTokens, let expiry = tokens.expiryDate, expiry > Date() {
           self.isLoggedIn = true
           // Optionally fetch user profile on init if logged in
           // fetchUserProfile()
        } else if currentTokens != nil {
            // Tokens exist but might be expired, try refreshing
            refreshToken()
        }
    }

    // --- PKCE Helper Functions ---
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

    // --- Authentication Flow ---
    func initiateAuthorization() {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        userProfile = nil // Clear old profile

        let verifier = generateCodeVerifier()
        guard let challenge = generateCodeChallenge(from: verifier) else {
            print("Error: Could not generate PKCE challenge")
            errorMessage = "Could not start authentication (PKCE)."
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
            // Optional: Add state parameter for extra CSRF protection if needed
            // URLQueryItem(name: "state", value: generateRandomStateString())
        ]

        guard let authURL = components?.url else {
            print("Error: Could not construct authorization URL")
            errorMessage = "Could not construct authorization URL."
            isLoading = false
            return
        }

        // Use ASWebAuthenticationSession
        // Ensure your redirect URI uses a custom scheme registered in Info.plist
        let scheme = URL(string: SpotifyConstants.redirectURI)?.scheme

        currentWebAuthSession = ASWebAuthenticationSession(
                                    url: authURL,
                                    callbackURLScheme: scheme) { [weak self] callbackURL, error in
            guard let self = self else { return }
            DispatchQueue.main.async { // Ensure UI updates are on main thread
                 self.isLoading = false // Stop loading indicator regardless of outcome
                 guard error == nil, let successURL = callbackURL else {
                     if let authError = error as? ASWebAuthenticationSessionError, authError.code == .canceledLogin {
                         print("Auth cancelled by user.")
                         self.errorMessage = "Login cancelled."
                     } else {
                         print("Auth Error: \(error?.localizedDescription ?? "Unknown error")")
                         self.errorMessage = "Authentication failed: \(error?.localizedDescription ?? "Unknown")"
                     }
                     return
                 }

                 // Extract the authorization code
                 let queryItems = URLComponents(string: successURL.absoluteString)?.queryItems
                 if let code = queryItems?.first(where: { $0.name == "code" })?.value {
                     print("Successfully received authorization code.")
                     self.exchangeCodeForToken(code: code)
                 } else {
                     print("Error: Could not find authorization code in callback URL.")
                     self.errorMessage = "Could not get authorization code from Spotify."
                     // Also check for 'error' query parameter from Spotify
                     if let spotifyError = queryItems?.first(where: { $0.name == "error" })?.value {
                          print("Spotify error in callback: \(spotifyError)")
                          self.errorMessage = "Spotify denied the request: \(spotifyError)"
                     }
                 }
             }
         }

        // Required for iOS 13+
        currentWebAuthSession?.presentationContextProvider = self
        currentWebAuthSession?.prefersEphemeralWebBrowserSession = false // Set to true to prevent cookie sharing

        DispatchQueue.main.async {
            self.currentWebAuthSession?.start()
        }
    }


    private func exchangeCodeForToken(code: String) {
         guard let verifier = currentPKCEVerifier else {
             print("Error: PKCE Verifier not found.")
             errorMessage = "Authentication failed (missing verifier)."
             return
         }
         guard !isLoading else { return }
         isLoading = true
         errorMessage = nil

         var request = URLRequest(url: SpotifyConstants.tokenEndpoint)
         request.httpMethod = "POST"
         request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

         var components = URLComponents()
         components.queryItems = [
             URLQueryItem(name: "client_id", value: SpotifyConstants.clientID),
             URLQueryItem(name: "grant_type", value: "authorization_code"),
             URLQueryItem(name: "code", value: code),
             URLQueryItem(name: "redirect_uri", value: SpotifyConstants.redirectURI),
             URLQueryItem(name: "code_verifier", value: verifier)
         ]

         request.httpBody = components.query?.data(using: .utf8)

         URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
             guard let self = self else { return }
             DispatchQueue.main.async {
                 self.isLoading = false
                 self.currentPKCEVerifier = nil // Important: Clear verifier after use

                 if let error = error {
                     print("Token Exchange Error: \(error.localizedDescription)")
                     self.errorMessage = "Failed to get tokens: \(error.localizedDescription)"
                     return
                 }

                 guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                     let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                     var errorDetails = "Unknown HTTP error"
                    if let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                         errorDetails = json["error_description"] as? String ?? json["error"] as? String ?? "Status code \(statusCode)"
                    } else if let data = data, let text = String(data: data, encoding: .utf8) {
                        errorDetails = text.isEmpty ? "Status code \(statusCode)" : text
                    } else {
                        errorDetails = "Status code \(statusCode)"
                    }
                     print("Token Exchange HTTP Error: \(statusCode). Details: \(errorDetails)")
                     self.errorMessage = "Failed to get tokens: \(errorDetails)"
                     return
                 }

                 guard let data = data else {
                     print("Token Exchange Error: No data received")
                     self.errorMessage = "Failed to get tokens: No data received."
                     return
                 }

                 do {
                    let decoder = JSONDecoder()
                    let tokenResponse = try decoder.decode(TokenResponse.self, from: data)
                    print("Successfully exchanged code for tokens.")
                    // Store tokens securely (Use Keychain in production!)
                    let newStoredTokens = StoredTokens(accessToken: tokenResponse.accessToken,
                                                      refreshToken: tokenResponse.refreshToken,
                                                      expiryDate: tokenResponse.expiryDate)
                    self.currentTokens = newStoredTokens
                    self.saveTokens(tokens: newStoredTokens)
                    self.isLoggedIn = true
                    // Fetch user profile after successful login
                    self.fetchUserProfile()

                 } catch {
                     print("Token Decoding Error: \(error)")
                     if let json = try? JSONSerialization.jsonObject(with: data, options: []) { print("Received JSON: ", json) }
                     self.errorMessage = "Failed to process tokens: \(error.localizedDescription)"
                 }
             }
         }.resume()
     }

    // --- Token Refresh ---
    func refreshToken() {
        guard !isLoading else { return }
        guard let refreshToken = currentTokens?.refreshToken else {
            print("Error: No refresh token available.")
            // If no refresh token, force re-login
            logout()
            return
        }
        isLoading = true
        errorMessage = nil

        var request = URLRequest(url: SpotifyConstants.tokenEndpoint)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "grant_type", value: "refresh_token"),
            URLQueryItem(name: "refresh_token", value: refreshToken),
            URLQueryItem(name: "client_id", value: SpotifyConstants.clientID) // Required for refresh
        ]

        request.httpBody = components.query?.data(using: .utf8)

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
             guard let self = self else { return }
             DispatchQueue.main.async {
                 self.isLoading = false

                 if let error = error {
                     print("Token Refresh Error: \(error.localizedDescription)")
                     self.errorMessage = "Failed to refresh token: \(error.localizedDescription)"
                     // Consider logging out if refresh fails permanently
                     // self.logout()
                     return
                 }

                 guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                     let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                    var errorDetails = "Unknown HTTP error"
                    if let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                         errorDetails = json["error_description"] as? String ?? json["error"] as? String ?? "Status code \(statusCode)"
                    } else {
                        errorDetails = "Status code \(statusCode)"
                    }
                     print("Token Refresh HTTP Error: \(statusCode). Details: \(errorDetails)")
                     self.errorMessage = "Failed to refresh token: \(errorDetails)"
                    // A 400 error (e.g., invalid_grant) often means the refresh token expired or was revoked
                    if statusCode == 400 {
                        self.logout() // Force re-login
                    }
                     return
                 }

                 guard let data = data else {
                     print("Token Refresh Error: No data received")
                     self.errorMessage = "Failed to refresh token: No data."
                     return
                 }

                 do {
                     let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)
                     print("Successfully refreshed tokens.")
                     // Update stored tokens (refresh token might change)
                     // Use the *old* refresh token if the response doesn't include a new one
                      let newRefreshToken = tokenResponse.refreshToken ?? self.currentTokens?.refreshToken
                     let newStoredTokens = StoredTokens(accessToken: tokenResponse.accessToken,
                                                       refreshToken: newRefreshToken,
                                                       expiryDate: tokenResponse.expiryDate)
                     self.currentTokens = newStoredTokens
                     self.saveTokens(tokens: newStoredTokens)
                     self.isLoggedIn = true // Ensure state is correct
                     print("Token refresh successful.")

                 } catch {
                     print("Token Refresh Decoding Error: \(error)")
                     self.errorMessage = "Failed to process refreshed tokens."
                    // Potentially logout if decoding fails after a 200 OK
                    // self.logout()
                 }
             }
         }.resume()
    }


    // --- Fetch User Profile ---
    func fetchUserProfile() {
        guard let accessToken = currentTokens?.accessToken else {
            print("Error: Cannot fetch profile without access token.")
            errorMessage = "Not logged in."
            // Maybe try refreshing token here?
            return
        }
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil // Clear previous errors

        var request = URLRequest(url: SpotifyConstants.userProfileEndpoint)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isLoading = false

                if let error = error {
                    print("Fetch Profile Error: \(error.localizedDescription)")
                    self.errorMessage = "Could not fetch profile: \(error.localizedDescription)"
                    // Check for 401/403 to potentially trigger refresh
                    if let httpResponse = response as? HTTPURLResponse,
                       (httpResponse.statusCode == 401 || httpResponse.statusCode == 403) {
                        self.refreshToken()
                    }
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                    let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                        print("Fetch Profile HTTP Error: \(statusCode)")
                        self.errorMessage = "Could not fetch profile (Status: \(statusCode))."
                        // Check for 401/403 to potentially trigger refresh
                        if statusCode == 401 || statusCode == 403 {
                            self.refreshToken()
                        }
                    return
                }

                guard let data = data else {
                    print("Fetch Profile Error: No data received")
                    self.errorMessage = "Could not fetch profile (No data)."
                    return
                }

                do {
                    self.userProfile = try JSONDecoder().decode(SpotifyUserProfile.self, from: data)
                    print("Successfully fetched user profile for \(self.userProfile?.displayName ?? "user")")
                } catch {
                    print("Fetch Profile Decoding Error: \(error)")
                     self.errorMessage = "Could not process user profile."
                }
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
        if let encoded = try? JSONEncoder().encode(tokens) {
            UserDefaults.standard.set(encoded, forKey: SpotifyConstants.tokenUserDefaultsKey)
            print("Tokens saved to UserDefaults.")
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
                 print("Error: Failed to decode saved tokens.")
                 clearTokens() // Clear corrupted data
            }
        }
        print("No saved tokens found.")
        self.currentTokens = nil
    }

    private func clearTokens() {
        UserDefaults.standard.removeObject(forKey: SpotifyConstants.tokenUserDefaultsKey)
        print("Tokens cleared from UserDefaults.")
    }
}

// MARK: - ASWebAuthenticationPresentationContextProviding
// Required for ASWebAuthenticationSession presentation on iOS 13+
extension SpotifyAuthManager: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return UIApplication.shared.keyWindow!
    }
    
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
    
//    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
//        // Return the main window of the app
//        return UIApplication.shared.windows.first { $0.isKeyWindow } ?? ASPresentationAnchor()
//    }
 
}


// MARK: - PKCE Helper Extension
// Base64 URL Encoding without padding
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
    @StateObject private var authManager = SpotifyAuthManager()

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if authManager.isLoading {
                    ProgressView("Loading...")
                        .padding()
                }

                if let errorMessage = authManager.errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                }

                if authManager.isLoggedIn {
                    loggedInView
                } else {
                    loggedOutView
                }
            }
            .navigationTitle("Spotify Auth PKCE")
            .onAppear {
                 // Optional: Fetch profile when view appears if logged in
                 if authManager.isLoggedIn && authManager.userProfile == nil {
                     authManager.fetchUserProfile()
                 }
             }
        }
    }

    // MARK: Logged In View
    private var loggedInView: some View {
        VStack(spacing: 15) {
            Text("Welcome!")
                .font(.title)

            if let profile = authManager.userProfile {
                AsyncImage(url: URL(string: profile.images?.first?.url ?? "" )) { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                } placeholder: {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .foregroundColor(.gray)
                }

                Text(profile.displayName)
                    .font(.headline)
                Text(profile.email)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            } else {
                 Text("Fetching profile...")
                 ProgressView()
                    .onAppear { // Trigger fetch if profile is nil but logged in
                        if authManager.userProfile == nil {
                             authManager.fetchUserProfile()
                        }
                    }
            }

            // Display Token Info (For Debugging - Remove in Prod)
             if let tokens = authManager.currentTokens {
                 DisclosureGroup("Token Details (Debug)") {
                     VStack(alignment: .leading) {
                         Text("Access Token:")
                             .font(.caption.weight(.bold))
                         Text(tokens.accessToken)
                             .font(.caption)
                             .lineLimit(1)
                         if let expiry = tokens.expiryDate {
                              Text("Expires: \(expiry, style: .relative)")
                                 .font(.caption)
                          }
                         if let refresh = tokens.refreshToken {
                             Text("Refresh Token Present: Yes: \(refresh)")
                                 .font(.caption)
                         } else {
                              Text("Refresh Token Present: No")
                                 .font(.caption)
                             .foregroundColor(.orange)
                         }
                     }
                     .padding(.top, 5)
                 }
                 .font(.callout)
                 .padding(.horizontal)
             }


            Button("Refresh Token") {
                authManager.refreshToken()
            }
            .buttonStyle(.bordered)
            .disabled(authManager.currentTokens?.refreshToken == nil || authManager.isLoading)


            Button("Log Out") {
                authManager.logout()
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)

            Spacer() // Push content to top
        }
        .padding()

    }

    // MARK: Logged Out View
    private var loggedOutView: some View {
        VStack {
            Text("Please log in to Spotify.")
                .padding(.bottom, 30)

            Button {
                authManager.initiateAuthorization()
            } label: {
                HStack {
                    // Using a placeholder Spotify logo - replace with actual asset
                    Image(systemName: "music.note.list") // Placeholder
                        .foregroundColor(.white)
                    Text("Log in with Spotify")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 20)
                .background(Color(red: 30/255, green: 215/255, blue: 96/255)) // Spotify Green
                .cornerRadius(25)
            }
             .disabled(authManager.isLoading) // Disable while loading

             Spacer() // Push content to top
        }
         .padding()
    }
}

// MARK: - App Entry Point
//@main
//struct SpotifyPKCEApp: App {
//    var body: some Scene {
//        WindowGroup {
//            AuthenticationFlowView()
//                // Optional: Handle the redirect URL at the app level if needed,
//                // although ASWebAuthenticationSession often makes this unnecessary
//                // .onOpenURL { url in
//                //     authManager.handleRedirect(url: url) // Need instance or Singleton
//                // }
//        }
//    }
//}

// MARK: - Previews (Optional)
#Preview {
    // Preview with a non-logged-in state
    AuthenticationFlowView()

    // Preview with a simulated logged-in state (requires manually setting state in AuthManager)
    // You'd need to create a 'preview' authManager instance and pass it in.
    /*
     let previewAuthManager: SpotifyAuthManager = {
         let manager = SpotifyAuthManager()
         manager.isLoggedIn = true
         manager.userProfile = SpotifyUserProfile(id: "preview_user", displayName: "Preview User", email: "preview@example.com", images: [SpotifyImage(url: "https://via.placeholder.com/150", height: 150, width: 150)])
         manager.currentTokens = StoredTokens(accessToken: "dummy_access_token_very_long...", refreshToken: "dummy_refresh_token...", expiryDate: Date().addingTimeInterval(3600))
         return manager
     }()

     ContentView(authManager: previewAuthManager) // Need to adjust ContentView init
         .previewDisplayName("Logged In State")
     */
}
