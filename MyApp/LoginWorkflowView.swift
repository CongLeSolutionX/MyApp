//
//  LoginWorkflowView.swift
//  MyApp
//
//  Created by Cong Le on 4/5/25.
//

import SwiftUI
import AuthenticationServices // Required for ASWebAuthenticationSession
import Security           // Required for Keychain access

// MARK: - Constants (Replace with your actual Client Info)
enum Constants {
    static let clientId = "YOUR_CLIENT_ID" // <-- Replace
    // IMPORTANT: Client Secret should ideally NOT be stored directly in the app
    // for public clients. PKCE is the primary security. If needed for a
    // specific grant type not typical for mobile, server-side handling is safer.
    // static let clientSecret = "YOUR_CLIENT_SECRET" // <-- Use with caution/server-side

    static let redirectURI = "YOUR_CUSTOM_SCHEME://callback" // <-- Replace with your custom scheme
    static let scopes = ["openid", "profile", "email", "read-repos", "inference-api"] // Request desired scopes

    static let authorizationEndpoint = "https://huggingface.co/oauth/authorize"
    static let tokenEndpoint = "https://huggingface.co/oauth/token"
    static let userInfoEndpoint = "https://huggingface.co/oauth/userinfo"

    // Keychain keys
    static let accessTokenKey = "hf_accessToken"
    static let refreshTokenKey = "hf_refreshToken"
    static let idTokenKey = "hf_idToken"
    static let keychainService = "co.huggingface.yourapp.tokens" // Unique service identifier
}

// MARK: - Data Structures
struct TokenResponse: Codable {
    let accessToken: String
    let tokenType: String
    let expiresIn: Int
    let refreshToken: String?
    let scope: String
    let idToken: String?

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
        case refreshToken = "refresh_token"
        case scope
        case idToken = "id_token"
    }
}

struct UserInfo: Codable, Identifiable {
    let sub: String // Subject identifier (user ID) - Use as id
    let name: String
    let preferredUsername: String
    let profile: String
    let picture: String
    let website: String
    let email: String? // Only if email scope was granted
    let emailVerified: Bool?
    // Add other fields as needed based on HF userinfo response

    var id: String { sub }

    enum CodingKeys: String, CodingKey {
        case sub, name, profile, picture, website, email
        case preferredUsername = "preferred_username"
        case emailVerified = "email_verified"
    }
}

// MARK: - Authentication Service (ObservableObject for State Management)
class AuthenticationService: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var userInfo: UserInfo? = nil
    @Published var errorMessage: String? = nil
    @Published var isLoading: Bool = false

    private var webAuthSession: ASWebAuthenticationSession?
    private var currentAccessToken: String?
    private var currentRefreshToken: String?

    // PKCE Properties
    private var codeVerifier: String?

    init() {
        // Check for existing tokens on init
        loadTokensFromKeychain()
        if currentAccessToken != nil {
            self.isLoggedIn = true
            // Optionally fetch user info immediately if tokens exist
             fetchUserInfo()
        }
    }

    // MARK: - Authentication Flow
    func signIn() {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        userInfo = nil // Clear previous user info

        // 1. Generate PKCE codes
        self.codeVerifier = generateCodeVerifier()
        guard let verifier = self.codeVerifier,
              let codeChallenge = generateCodeChallenge(from: verifier) else {
            self.errorMessage = "Failed to generate PKCE codes."
            self.isLoading = false
            return
        }

        // 2. Construct Authorization URL
        var urlComponents = URLComponents(string: Constants.authorizationEndpoint)!
        let state = generateRandomString() // CSRF protection

        urlComponents.queryItems = [
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "client_id", value: Constants.clientId),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "scope", value: Constants.scopes.joined(separator: " ")),
            URLQueryItem(name: "state", value: state),
            URLQueryItem(name: "code_challenge", value: codeChallenge),
            URLQueryItem(name: "code_challenge_method", value: "S256")
            // Add orgIds here if needed: URLQueryItem(name: "orgIds", value: "YOUR_ORG_ID")
        ]

        guard let authURL = urlComponents.url else {
            self.errorMessage = "Failed to create authorization URL."
            self.isLoading = false
            return
        }

        // 3. Start ASWebAuthenticationSession
        self.webAuthSession = ASWebAuthenticationSession(
            url: authURL,
            callbackURLScheme: extractScheme(from: Constants.redirectURI) // Extract "YOUR_CUSTOM_SCHEME"
        ) { [weak self] callbackURL, error in

            guard let self = self else { return }
            self.isLoading = false // Stop loading indicator

            // 4. Handle Callback
            if let error = error {
                if let authError = error as? ASWebAuthenticationSessionError,
                   authError.code == .canceledLogin {
                    self.errorMessage = "Login cancelled."
                } else {
                    self.errorMessage = "Login failed: \(error.localizedDescription)"
                }
                return
            }

            guard let callbackURL = callbackURL else {
                self.errorMessage = "Invalid callback URL received."
                return
            }

            // 5. Extract Code and Verify State
            guard let receivedCode = self.extractQueryParam(from: callbackURL, name: "code"),
                  let receivedState = self.extractQueryParam(from: callbackURL, name: "state"),
                  receivedState == state else {
                self.errorMessage = "Invalid state or missing code in callback."
                return
            }

            // 6. Exchange Code for Tokens
            self.exchangeCodeForTokens(code: receivedCode, codeVerifier: verifier)
        }

        // Required for iOS 13+
        webAuthSession?.presentationContextProvider = self
        // Required on Mac if catalyst
        // webAuthSession?.prefersEphemeralWebBrowserSession = false

        webAuthSession?.start()
    }

    func signOut() {
        isLoading = true
        // Clear local state
        self.currentAccessToken = nil
        self.currentRefreshToken = nil
        self.userInfo = nil
        self.isLoggedIn = false
        self.errorMessage = nil

        // Clear tokens from Keychain
        deleteTokenFromKeychain(key: Constants.accessTokenKey)
        deleteTokenFromKeychain(key: Constants.refreshTokenKey)
        deleteTokenFromKeychain(key: Constants.idTokenKey)

        isLoading = false
        print("Signed out.")
    }

    // MARK: - Token Exchange
    private func exchangeCodeForTokens(code: String, codeVerifier: String) {
        guard let url = URL(string: Constants.tokenEndpoint) else {
             self.errorMessage = "Invalid token endpoint URL."
             return
        }
        isLoading = true

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "grant_type", value: "authorization_code"),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "client_id", value: Constants.clientId),
            URLQueryItem(name: "code_verifier", value: codeVerifier)
            // If using client secret (not recommended for public clients):
            // URLQueryItem(name: "client_secret", value: Constants.clientSecret)
        ]

        request.httpBody = components.query?.data(using: .utf8)

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                 self.isLoading = false

                if let error = error {
                    self.errorMessage = "Token exchange failed: \(error.localizedDescription)"
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    self.errorMessage = "Invalid response from token endpoint."
                    return
                }

                guard let data = data else {
                    self.errorMessage = "No data received from token endpoint."
                    return
                }

                guard (200...299).contains(httpResponse.statusCode) else {
                    let errorBody = String(data: data, encoding: .utf8) ?? "Unknown error"
                    self.errorMessage = "Token exchange error (\(httpResponse.statusCode)): \(errorBody)"
                    return
                }

                do {
                    let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)
                    // Securely store tokens
                    self.saveTokenToKeychain(token: tokenResponse.accessToken, key: Constants.accessTokenKey)
                    if let refreshToken = tokenResponse.refreshToken {
                         self.saveTokenToKeychain(token: refreshToken, key: Constants.refreshTokenKey)
                         self.currentRefreshToken = refreshToken
                    }
                    if let idToken = tokenResponse.idToken {
                         self.saveTokenToKeychain(token: idToken, key: Constants.idTokenKey)
                         // You might want to decode and verify the ID token here
                    }

                    self.currentAccessToken = tokenResponse.accessToken
                    self.isLoggedIn = true
                    print("Successfully obtained tokens.")
                    // Fetch user info after successful login
                    self.fetchUserInfo()

                } catch {
                    self.errorMessage = "Failed to decode token response: \(error.localizedDescription)"
                }
            }
        }.resume()
    }

     // MARK: - Token Refresh (Conceptual - Needs Implementation)
    func refreshTokenIfNeeded(completion: @escaping (Bool) -> Void) {
        // 1. Check if access token exists and is expired (requires storing expiry or trying API call)
        // 2. If needed, retrieve refresh token from keychain
        guard let refreshToken = self.currentRefreshToken ?? loadTokenFromKeychain(key: Constants.refreshTokenKey) else {
            print("No refresh token available.")
             signOut() // Force sign out if no refresh token
            completion(false)
            return
        }

        print("Attempting token refresh...")
        isLoading = true

        // 3. Make request to token endpoint with grant_type='refresh_token'
        guard let url = URL(string: Constants.tokenEndpoint) else {
            self.errorMessage = "Invalid token endpoint URL."
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "grant_type", value: "refresh_token"),
            URLQueryItem(name: "refresh_token", value: refreshToken),
            URLQueryItem(name: "client_id", value: Constants.clientId)
            // Scopes are often optional/ignored during refresh, depends on provider
            // URLQueryItem(name: "scope", value: Constants.scopes.joined(separator: " ")),
            // If using client secret:
            // URLQueryItem(name: "client_secret", value: Constants.clientSecret)
        ]
        request.httpBody = components.query?.data(using: .utf8)

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                 guard let self = self else { completion(false); return }
                 self.isLoading = false

                if let error = error {
                    self.errorMessage = "Token refresh failed: \(error.localizedDescription)"
                     // Often, an invalid refresh token means sign out
                     self.signOut()
                    completion(false)
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode),
                      let data = data else {
                    let errorBody = String(data: data ?? Data(), encoding: .utf8) ?? "Unknown error"
                    self.errorMessage = "Token refresh error (\(httpResponse?.statusCode ?? 0)): \(errorBody)"
                     // Often, an invalid refresh token means sign out
                     self.signOut()
                    completion(false)
                    return
                }

                 do {
                    let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)
                    print("Token refresh successful.")
                    // Store new tokens
                    self.saveTokenToKeychain(token: tokenResponse.accessToken, key: Constants.accessTokenKey)
                    self.currentAccessToken = tokenResponse.accessToken

                    // Handle potential new refresh token
                    if let newRefreshToken = tokenResponse.refreshToken {
                        self.saveTokenToKeychain(token: newRefreshToken, key: Constants.refreshTokenKey)
                        self.currentRefreshToken = newRefreshToken
                    }
                    // ID token might also be refreshed
                     if let newIdToken = tokenResponse.idToken {
                         self.saveTokenToKeychain(token: newIdToken, key: Constants.idTokenKey)
                     }

                    self.isLoggedIn = true // Ensure still logged in
                    completion(true) // Indicate success

                } catch {
                     self.errorMessage = "Failed to decode refresh token response: \(error)"
                     self.signOut() // Treat decoding error as needing sign out
                     completion(false)
                }

            }
        }.resume()
    }


    // MARK: - API Call Example
    func fetchUserInfo() {
        guard isLoggedIn, let token = currentAccessToken else {
            // Attempt refresh if needed, or prompt login
            refreshTokenIfNeeded { [weak self] success in
                 if success {
                     self?.fetchUserInfo() // Retry after successful refresh
                 } else {
                      self?.errorMessage = "Session expired. Please sign in again."
                      // No need to call signOut explicitly as refresh failure handles it
                 }
            }
            return
        }

        guard let url = URL(string: Constants.userInfoEndpoint) else {
            self.errorMessage = "Invalid user info endpoint URL."
            return
        }
        isLoading = true

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false

                if let error = error {
                    self.errorMessage = "Failed to fetch user info: \(error.localizedDescription)"
                    // Consider token refresh here on auth errors (e.g., 401)
                    if (error as NSError).code == NSURLErrorUserAuthenticationRequired || (response as? HTTPURLResponse)?.statusCode == 401 {
                        self.refreshTokenIfNeeded { success in
                             if success { self.fetchUserInfo() } // Retry
                        }
                    }
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    self.errorMessage = "Invalid response fetching user info."
                    return
                }

                 guard let data = data else {
                    self.errorMessage = "No data received for user info."
                    return
                }

                guard (200...299).contains(httpResponse.statusCode) else {
                     let errorBody = String(data: data, encoding: .utf8) ?? "Unknown error"
                     self.errorMessage = "Fetch user info error (\(httpResponse.statusCode)): \(errorBody)"
                     // Consider token refresh on 401
                     if httpResponse.statusCode == 401 {
                         self.refreshTokenIfNeeded { success in
                              if success { self.fetchUserInfo() } // Retry
                         }
                     }
                    return
                 }

                do {
                    let fetchedUserInfo = try JSONDecoder().decode(UserInfo.self, from: data)
                    self.userInfo = fetchedUserInfo
                    print("Successfully fetched user info for: \(fetchedUserInfo.name)")
                } catch {
                    self.errorMessage = "Failed to decode user info: \(error.localizedDescription)"
                }
            }
        }.resume()
    }


    // MARK: - PKCE Helpers
    private func generateCodeVerifier() -> String? {
        var buffer = [UInt8](repeating: 0, count: 32)
        let status = SecRandomCopyBytes(kSecRandomDefault, buffer.count, &buffer)
        guard status == errSecSuccess else { return nil }
        return Data(buffer).base64URLEncodedString()
    }

    private func generateCodeChallenge(from verifier: String) -> String? {
        guard let data = verifier.data(using: .utf8) else { return nil }

        // Use CommonCrypto (needs import CommonCrypto at top if not implicitly available)
        // Or use CryptoKit for iOS 13+
        if #available(iOS 13.0, *) {
            return Data(SHA256.hash(data: data)).base64URLEncodedString()
        } else {
            // Fallback or error for older iOS versions if CommonCrypto not used
             print("PKCE SHA256 not directly available on this iOS version without CommonCrypto.")
             return nil // Needs CommonCrypto implementation for older versions
        }
    }

    // MARK: - URL Handling Helpers
    private func extractQueryParam(from url: URL, name: String) -> String? {
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        return components?.queryItems?.first(where: { $0.name == name })?.value
    }

    private func extractScheme(from urlString: String) -> String? {
        return URLComponents(string: urlString)?.scheme
    }

    // MARK: - Keychain Helpers (Simplified)
    private func saveTokenToKeychain(token: String, key: String) {
        guard let data = token.data(using: .utf8) else { return }
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: Constants.keychainService,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly // Good practice accessibility
        ]

        // Delete existing item first
        SecItemDelete(query as CFDictionary)

        // Add new item
        let status = SecItemAdd(query as CFDictionary, nil)
        if status != errSecSuccess {
            print("Error saving \(key) to Keychain: \(status)")
        } else {
             print("\(key) saved to Keychain.")
        }
    }

    private func loadTokenFromKeychain(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: Constants.keychainService,
            kSecAttrAccount as String: key,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)

        if status == errSecSuccess {
            guard let data = dataTypeRef as? Data,
                  let token = String(data: data, encoding: .utf8) else {
                return nil
            }
            print("\(key) loaded from Keychain.")
            return token
        } else {
             if status != errSecItemNotFound {
                 print("Error loading \(key) from Keychain: \(status)")
             }
             return nil
        }
    }

    private func deleteTokenFromKeychain(key: String) {
         let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: Constants.keychainService,
            kSecAttrAccount as String: key
        ]
        let status = SecItemDelete(query as CFDictionary)
         if status != errSecSuccess && status != errSecItemNotFound {
            print("Error deleting \(key) from Keychain: \(status)")
        } else {
            print("\(key) deleted from Keychain.")
        }
    }

    private func loadTokensFromKeychain() {
         self.currentAccessToken = loadTokenFromKeychain(key: Constants.accessTokenKey)
         self.currentRefreshToken = loadTokenFromKeychain(key: Constants.refreshTokenKey)
         // ID token can also be loaded if needed for display/validation
    }

    // MARK: - Utility
     private func generateRandomString(length: Int = 32) -> String {
         let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
         return String((0..<length).map { _ in letters.randomElement()! })
     }
}

// MARK: - ASWebAuthenticationPresentationContextProviding
// Required for ASWebAuthenticationSession presentation on iOS 13+
extension AuthenticationService: ASWebAuthenticationPresentationContextProviding {
    func isEqual(_ object: Any?) -> Bool {
        return true
    }
    
    var hash: Int {
        return 0
    }
    
    var superclass: AnyClass? {
        return NSObject.self
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
    
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        // Return the window scene's key window
        return UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { $0 as? UIWindowScene }
            .first?.windows
            .filter { $0.isKeyWindow }
            .first ?? ASPresentationAnchor() // Provide a fallback anchor
    }
}


// MARK: - Data Extension for Base64 URL Encoding
// Helper for PKCE
extension Data {
    func base64URLEncodedString() -> String {
        return self.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}


// MARK: - SwiftUI View
struct ContentView: View {
    @StateObject private var authService = AuthenticationService()

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if authService.isLoading {
                    ProgressView("Loading...")
                }

                if authService.isLoggedIn {
                    Text("Welcome!")
                        .font(.title)

                    if let userInfo = authService.userInfo {
                        VStack(alignment: .leading) {
                             // Use AsyncImage for loading profile picture
                             if let pictureURL = URL(string: userInfo.picture) {
                                  AsyncImage(url: pictureURL) { image in
                                      image.resizable()
                                           .aspectRatio(contentMode: .fit)
                                           .frame(width: 80, height: 80)
                                           .clipShape(Circle())
                                  } placeholder: {
                                      ProgressView()
                                           .frame(width: 80, height: 80)
                                  }
                             }
                             Text("ID: \(userInfo.id)")
                             Text("Name: \(userInfo.name)")
                             Text("Username: \(userInfo.preferredUsername)")
                             Text("Email: \(userInfo.email ?? "N/A")")
                             Text("Website: \(userInfo.website)")
                         }
                         .padding()
                         .background(Color.gray.opacity(0.1))
                         .cornerRadius(8)

                         Button("Fetch User Info Again") {
                              authService.fetchUserInfo()
                         }
                         .buttonStyle(.bordered)

                    } else {
                         Text("Fetching user info...")
                         ProgressView()
                         Button("Fetch User Info") { // Button to initiate fetch if auto-fetch failed
                              authService.fetchUserInfo()
                         }
                         .buttonStyle(.bordered)
                    }

                    Button("Sign Out") {
                        authService.signOut()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)

                } else {
                    Image(systemName: "lock.shield") // Example Icon
                        .font(.largeTitle)
                        .padding(.bottom)

                    Text("Sign in to Your App")
                         .font(.headline)


                    // Use the official Hugging Face button image if desired
                    // You'd need to add the SVG/PNG to your assets
                    // Image("sign-in-with-huggingface-lg-dark") // Example
                    //    .resizable()
                    //    .scaledToFit()
                    //    .frame(maxWidth: 250)
                    //    .onTapGesture {
                    //        authService.signIn()
                    //    }

                    // Or a standard button:
                    Button {
                        authService.signIn()
                    } label: {
                        HStack {
                            // Placeholder for HF logo if available
                            Image(systemName: "face.smiling") // Replace with actual logo if desired
                            Text("Sign in with Hugging Face")
                        }
                        .padding(.horizontal)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color(red: 248/255, green: 178/255, blue: 41/255)) // HF Yellow-ish

                }

                if let errorMessage = authService.errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                        .padding()
                }

                Spacer() // Push content to top
            }
            .padding()
            .navigationTitle("HF OAuth Demo")
            // Fetch user info when the view appears if logged in but no user info yet
            .onAppear {
                 if authService.isLoggedIn && authService.userInfo == nil {
                     authService.fetchUserInfo()
                 }
            }
        }
        // Add sheet presentation for ASWebAuthenticationSession on macOS Catalyst if needed
    }
}

// MARK: - App Entry Point
@main
struct HFOAuthDemoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
            // Handle the callback URL when the app is opened via the custom scheme
             .onOpenURL { url in
                 // While ASWebAuthenticationSession handles the callback internally,
                 // this is the place for general deep linking. For OAuth,
                 // ASWebAuthSession's completion handler is the primary mechanism.
                 print("App opened with URL: \(url)")
                 // Example: Check if it's the OAuth callback, although ASWebAuthSession should capture it.
                 if url.scheme == extractScheme(from: Constants.redirectURI) {
                      print("OAuth callback URL detected (handled by ASWebAuthSession).")
                 }
             }
        }
    }

    // Helper function accessible here or globally
    func extractScheme(from urlString: String) -> String? {
          return URLComponents(string: urlString)?.scheme
    }
}


// MARK: - Preview
#Preview {
    ContentView()
}
