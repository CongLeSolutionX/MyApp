//
//  InstagramContentView.swift
//  MyApp
//
//  Created by Cong Le on 3/26/25.
//

import SwiftUI
import Combine
import AuthenticationServices // Needed for ASWebAuthenticationSession

// MARK: - Data Models

/// Represents basic Instagram user profile information.
struct InstagramUserProfile: Identifiable, Decodable {
    let id: String
    let username: String
}

/// Represents a single Instagram media item.
struct InstagramMediaItem: Identifiable, Decodable, Hashable {
    let id: String
    let caption: String?
    let media_type: String // IMAGE, VIDEO, CAROUSEL_ALBUM
    let media_url: String? // Not returned for CAROUSEL_ALBUM
    let permalink: String?
    let thumbnail_url: String? // Only for VIDEO type
    let timestamp: String?

    // Make Hashable for use in ForEach/Lists
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    static func == (lhs: InstagramMediaItem, rhs: InstagramMediaItem) -> Bool {
        lhs.id == rhs.id
    }
}

/// Represents the structure of an error response from the Instagram API.
struct InstagramErrorResponse: Decodable, Error {
    let error: InstagramErrorDetail
}

struct InstagramErrorDetail: Decodable {
    let message: String
    let type: String
    let code: Int
    let fbtrace_id: String?
}

// MARK: - API Endpoints

enum InstagramAPIEndpoint {
    case userProfile
    case userMedia

    var path: String {
        switch self {
        case .userProfile:
            return "/me"
        case .userMedia:
            return "/me/media"
        }
    }

    // Fields commonly requested for each endpoint
    var fields: String {
        switch self {
        case .userProfile:
            return "id,username"
        case .userMedia:
            return "id,caption,media_type,media_url,permalink,thumbnail_url,timestamp"
        }
    }
}

// MARK: - API Errors

enum InstagramAPIError: Error, LocalizedError {
    case invalidURL
    case requestFailed(String)
    case decodingFailed(Error? = nil) // Include underlying decoding error
    case authenticationFailed(String? = nil)
    case apiError(message: String, code: Int) // Specific error from Instagram
    case missingToken
    case authenticationCancelled
    case tokenExchangeFailed(String)
    case keychainError(OSStatus)
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid API URL constructed."
        case .requestFailed(let message): return "API request failed: \(message)"
        case .decodingFailed(let underlyingError):
            var message = "Failed to decode the response."
            if let error = underlyingError {
                message += " Error: \(error.localizedDescription)"
            }
            return message
        case .authenticationFailed(let reason): return "Authentication failed. \(reason ?? "")"
        case .apiError(let message, let code): return "Instagram API Error (\(code)): \(message)"
        case .missingToken: return "Access token is missing. Please log in."
        case .authenticationCancelled: return "Instagram login was cancelled."
        case .tokenExchangeFailed(let reason): return "Failed to exchange code/token: \(reason)"
        case .keychainError(let status): return "Keychain operation failed with status: \(status)"
        case .unknown(let error): return "An unknown error occurred: \(error.localizedDescription)"
        }
    }
}

// MARK: - Authentication Configuration

struct InstagramConfig {
    // --- SECURITY WARNING ---
    // NEVER hardcode your App Secret in production code.
    // Load it securely (e.g., from a configuration file not checked into Git, environment variables, or a secure backend).
    static let appID = "YOUR_INSTAGRAM_APP_ID" // Replace with your App ID
    static let appSecret = "YOUR_INSTAGRAM_APP_SECRET" // Replace with your App Secret - LOAD SECURELY
    static let redirectURI = "YOUR_APP_REDIRECT_URI" // Replace with your registered Redirect URI (e.g., "myapp://auth")
    static let scope = "user_profile,user_media"

    // Use a unique service name for Keychain
    static let keychainServiceName = "com.yourapp.instagramtoken"
    static let keychainAccountName = "instagramAccessToken"
}

// MARK: - Data Service

final class InstagramDataService: ObservableObject {

    @Published var userProfile: InstagramUserProfile?
    @Published var mediaItems: [InstagramMediaItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isAuthenticated = false // Track authentication state

    private let graphHost = "https://graph.instagram.com"
    private let apiHost = "https://api.instagram.com" // For token exchange
    private var accessToken: String?
    private var authenticationSession: ASWebAuthenticationSession? // For OAuth flow

    private var cancellables = Set<AnyCancellable>()

    init() {
        loadTokenFromKeychain() // Attempt to load token on startup
    }

    // MARK: - Authentication Flow (OAuth 2.0)

    func initiateAuthentication() {
        guard let authURL = buildAuthorizationURL() else {
            handleError(.invalidURL)
            return
        }

        // Use ASWebAuthenticationSession for managing the OAuth web flow
        authenticationSession = ASWebAuthenticationSession(
            url: authURL,
            callbackURLScheme: URL(string: InstagramConfig.redirectURI)?.scheme // Extract scheme like "myapp"
        ) { [weak self] callbackURL, error in
            guard let self = self else { return }

            if let error = error {
                if let authError = error as? ASWebAuthenticationSessionError, authError.code == .canceledLogin {
                     self.handleError(.authenticationCancelled)
                } else {
                    self.handleError(.authenticationFailed("Session failed: \(error.localizedDescription)"))
                }
                return
            }

            guard let callbackURL = callbackURL else {
                self.handleError(.authenticationFailed("Invalid callback URL."))
                return
            }

            // Extract the authorization code from the callback URL
            self.handleRedirect(url: callbackURL)
        }

        // Crucial for iOS 13+
        authenticationSession?.presentationContextProvider = self
        authenticationSession?.prefersEphemeralWebBrowserSession = true // Recommended for privacy

        authenticationSession?.start()
    }

    private func buildAuthorizationURL() -> URL? {
        var components = URLComponents(string: "\(apiHost)/oauth/authorize")
        components?.queryItems = [
            URLQueryItem(name: "client_id", value: InstagramConfig.appID),
            URLQueryItem(name: "redirect_uri", value: InstagramConfig.redirectURI),
            URLQueryItem(name: "scope", value: InstagramConfig.scope),
            URLQueryItem(name: "response_type", value: "code")
        ]
        return components?.url
    }

    /// Handles the redirect URI after the user authorizes the app.
    func handleRedirect(url: URL) {
        // Example Redirect URI: YOUR_APP_REDIRECT_URI?code=AUTHORIZATION_CODE#_
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let codeItem = components.queryItems?.first(where: { $0.name == "code" }),
              let code = codeItem.value else {
            handleError(.authenticationFailed("Could not extract authorization code from redirect URL."))
            return
        }

        // Exchange the code for an access token
        exchangeCodeForToken(code: code)
    }

    private func exchangeCodeForToken(code: String) {
        isLoading = true
        errorMessage = nil

        guard let url = URL(string: "\(apiHost)/oauth/access_token") else {
            handleError(.invalidURL)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let bodyParams: [String: String] = [
            "client_id": InstagramConfig.appID,
            "client_secret": InstagramConfig.appSecret, // SECURITY: Load securely
            "grant_type": "authorization_code",
            "redirect_uri": InstagramConfig.redirectURI,
            "code": code
        ]

        guard let httpBody = createFormURLEncodedBody(parameters: bodyParams) else {
             handleError(.requestFailed("Could not create request body."))
             return
        }
        request.httpBody = httpBody

        // Combine publisher for the token exchange
        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                    // Try decoding error response
                    if let errorResponse = try? JSONDecoder().decode(InstagramErrorResponse.self, from: data) {
                         throw InstagramAPIError.apiError(message: errorResponse.error.message, code: errorResponse.error.code)
                    }
                    let responseString = String(data: data, encoding: .utf8) ?? "No Response Body"
                    throw InstagramAPIError.tokenExchangeFailed("HTTP Status Code error. Response: \(responseString)")
                }
                return data
            }
            .decode(type: AccessTokenResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completionResult in
                guard let self = self else { return }
                 self.isLoading = false // Stop loading indicator on completion/failure
                switch completionResult {
                case .finished:
                    break // Handled in receiveValue
                case .failure(let error):
                     if let apiError = error as? InstagramAPIError {
                        self.handleError(apiError)
                    } else {
                        self.handleError(.tokenExchangeFailed(error.localizedDescription))
                    }
                }
            } receiveValue: { [weak self] tokenResponse in
                 guard let self = self else { return }
                 self.accessToken = tokenResponse.access_token
                 self.saveTokenToKeychain(token: tokenResponse.access_token) // Save securely
                 self.isAuthenticated = true
                 print("Successfully obtained access token.")
                // Optionally fetch profile/media immediately after login
                 // self.fetchUserProfile()
                 // self.fetchUserMedia()
            }
            .store(in: &cancellables)
    }

    // Response structure for the access token endpoint
    private struct AccessTokenResponse: Decodable {
        let access_token: String
        let user_id: Int // Or String depending on API version
    }

    // Helper to create form URL encoded body
    private func createFormURLEncodedBody(parameters: [String: String]) -> Data? {
         var components = URLComponents()
         components.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
         return components.query?.data(using: .utf8)
     }

    // MARK: - Data Fetching

    func fetchUserProfile() {
        makeAPIRequest(endpoint: .userProfile) { [weak self] (result: Result<InstagramUserProfile, InstagramAPIError>) in
             guard let self = self else { return }
            DispatchQueue.main.async {
                 switch result {
                 case .success(let profile):
                     self.userProfile = profile
                 case .failure(let error):
                     self.handleError(error)
                 }
            }
        }
    }

    func fetchUserMedia() {
        makeAPIRequest(endpoint: .userMedia) { [weak self] (result: Result<PagedResponse<InstagramMediaItem>, InstagramAPIError>) in
             guard let self = self else { return }
            DispatchQueue.main.async {
                 switch result {
                 case .success(let pagedResponse):
                     self.mediaItems = pagedResponse.data
                     // TODO: Implement pagination handling using pagedResponse.paging?.next
                 case .failure(let error):
                     self.handleError(error)
                 }
            }
        }
    }


    // Generic function to make authenticated GET requests
    private func makeAPIRequest<T: Decodable>(endpoint: InstagramAPIEndpoint, completion: @escaping (Result<T, InstagramAPIError>) -> Void) {
        guard let token = accessToken else {
            completion(.failure(.missingToken))
            return
        }

        isLoading = true
        errorMessage = nil

        var components = URLComponents(string: "\(graphHost)\(endpoint.path)")
        components?.queryItems = [
            URLQueryItem(name: "fields", value: endpoint.fields),
            URLQueryItem(name: "access_token", value: token)
        ]

        guard let url = components?.url else {
            handleError(.invalidURL) // Also call completion handler
            completion(.failure(.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                    if let errorResponse = try? JSONDecoder().decode(InstagramErrorResponse.self, from: data) {
                        throw InstagramAPIError.apiError(message: errorResponse.error.message, code: errorResponse.error.code)
                    }
                    let responseString = String(data: data, encoding: .utf8) ?? "No Response Body"
                    throw InstagramAPIError.requestFailed("HTTP Status Code error. Response: \(responseString)")
                }
                return data
            }
            .decode(type: T.self, decoder: JSONDecoder())
             .receive(on: DispatchQueue.main) // Ensure completion handler is called on main thread
            .sink { [weak self] completionResult in
                 guard let self = self else { return }
                 self.isLoading = false // Stop loading regardless of outcome
                switch completionResult {
                case .finished:
                    break // Success handled by receiveValue
                case .failure(let error):
                     if let decodingError = error as? DecodingError {
                        completion(.failure(.decodingFailed(decodingError)))
                    } else if let apiError = error as? InstagramAPIError {
                        completion(.failure(apiError))
                    } else {
                        completion(.failure(.unknown(error)))
                    }
                }
            } receiveValue: { decodedResponse in
                completion(.success(decodedResponse))
            }
            .store(in: &cancellables)
    }

    // Structure for handling paged responses (like media)
    private struct PagedResponse<T: Decodable>: Decodable {
        let data: [T]
        let paging: Paging?
    }
    private struct Paging: Decodable {
        let cursors: Cursors?
        let next: String? // URL for the next page
    }
    private struct Cursors: Decodable {
        let before: String?
        let after: String?
    }


    // MARK: - Keychain Management

    private func saveTokenToKeychain(token: String) {
        guard let data = token.data(using: .utf8) else { return }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: InstagramConfig.keychainServiceName,
            kSecAttrAccount as String: InstagramConfig.keychainAccountName,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked // Or appropriate level
        ]

        // Delete any existing item first
        SecItemDelete(query as CFDictionary)

        // Add the new item
        let status = SecItemAdd(query as CFDictionary, nil)
        if status != errSecSuccess {
            print("Error saving token to keychain: \(status)")
            handleError(.keychainError(status))
        } else {
             print("Token saved to keychain.")
        }
    }

    private func loadTokenFromKeychain() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: InstagramConfig.keychainServiceName,
            kSecAttrAccount as String: InstagramConfig.keychainAccountName,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)

        if status == errSecSuccess {
            if let retrievedData = dataTypeRef as? Data,
               let token = String(data: retrievedData, encoding: .utf8) {
                self.accessToken = token
                self.isAuthenticated = true // Update state if token loaded
                print("Token loaded from keychain.")
                // Optionally fetch data if token is loaded successfully
                // fetchUserProfile()
                // fetchUserMedia()
            } else {
                 print("Token loaded but data conversion failed")
                clearAuthentication() // Clear invalid state
            }
        } else if status == errSecItemNotFound {
            print("No token found in keychain.")
            self.isAuthenticated = false
        } else {
            print("Error loading token from keychain: \(status)")
            // Optionally handle error, maybe clear state
            clearAuthentication()
             handleError(.keychainError(status)) // Report error
        }
    }

    // MARK: - Logout / Clear Data

    func clearAuthentication() {
        accessToken = nil
        userProfile = nil
        mediaItems = []
        isAuthenticated = false
        isLoading = false // Reset loading state
        errorMessage = nil // Clear any previous errors

        // Clear token from keychain
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: InstagramConfig.keychainServiceName,
            kSecAttrAccount as String: InstagramConfig.keychainAccountName
        ]
        let status = SecItemDelete(query as CFDictionary)
        if status != errSecSuccess && status != errSecItemNotFound {
            print("Error deleting token from keychain: \(status)")
             handleError(.keychainError(status))
        } else {
             print("Token deleted from keychain.")
        }

        // Cancel any ongoing network requests
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
    }

    // MARK: - Error Handling
    private func handleError(_ error: InstagramAPIError) {
        // Avoid overwriting existing errors if multiple occur quickly
         if errorMessage == nil {
             errorMessage = error.localizedDescription
        }
        // Log detailed error
        print("Instagram API Error: \(error.localizedDescription)")

         // If authentication fails specifically, update the state
         if case .authenticationFailed = error {
             DispatchQueue.main.async {
                 self.isAuthenticated = false
            }
        }
          if case .missingToken = error {
             DispatchQueue.main.async {
                 self.isAuthenticated = false
            }
        }
    }
}

// MARK: - ASWebAuthenticationPresentationContextProviding
// Required for ASWebAuthenticationSession on iOS 13+

extension InstagramDataService: ASWebAuthenticationPresentationContextProviding {
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
        
    }
    
    func perform(_ aSelector: Selector!) -> Unmanaged<AnyObject>! {
        
    }
    
    func perform(_ aSelector: Selector!, with object: Any!) -> Unmanaged<AnyObject>! {
      
    }
    
    func perform(_ aSelector: Selector!, with object1: Any!, with object2: Any!) -> Unmanaged<AnyObject>! {
    
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
        <#code#>
    }
    
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        // Return the main window of your app
        return UIApplication.shared.windows.first { $0.isKeyWindow } ?? ASPresentationAnchor()
    }
}


// MARK: - SwiftUI Views

struct InstagramContentView: View {
    @StateObject private var dataService = InstagramDataService()

    var body: some View {
        NavigationView {
            VStack {
                if dataService.isLoading {
                    ProgressView("Loading...")
                } else if let errorMessage = dataService.errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                        .padding()
                }

                if dataService.isAuthenticated {
                    // --- Authenticated View ---
                    AuthenticatedView(dataService: dataService)
                } else {
                    // --- Login View ---
                    Button("Login with Instagram") {
                        dataService.initiateAuthentication()
                    }
                    .padding()
                    .buttonStyle(.borderedProminent)
                }
            }
            .navigationTitle("Instagram Data")
             // Crucial: Handle the redirect URL when the app is opened via the custom scheme
             .onOpenURL { url in
                print("App opened with URL: \(url)")
                 if url.scheme == URL(string: InstagramConfig.redirectURI)?.scheme { // Check if it's our redirect
                     dataService.handleRedirect(url: url)
                 }
             }
        }
    }
}

struct AuthenticatedView: View {
    @ObservedObject var dataService: InstagramDataService // Use ObservedObject here

    // Grid layout for media items
     let columns = [
         GridItem(.flexible()),
         GridItem(.flexible()),
         GridItem(.flexible())
     ]

    var body: some View {
        List { // Using List to organize sections easily
            Section(header: Text("Profile Info")) {
                if let profile = dataService.userProfile {
                    Text("Username: \(profile.username)")
                    Text("User ID: \(profile.id)")
                } else {
                    Button("Fetch Profile") {
                        dataService.fetchUserProfile()
                    }
                }
            }

            Section(header: Text("Media")) {
                 if dataService.mediaItems.isEmpty {
                     Button("Fetch Media") {
                         dataService.fetchUserMedia()
                     }
                } else {
                    LazyVGrid(columns: columns, spacing: 5) {
                        ForEach(dataService.mediaItems, id: \.self) { item in
                            MediaItemView(item: item)
                        }
                    }
                    // TODO: Add button or logic for pagination (fetching next page)
                }
            }

            Section {
                Button("Logout", role: .destructive) {
                    dataService.clearAuthentication()
                }
            }
        }
    }
}

struct MediaItemView: View {
    let item: InstagramMediaItem

    var body: some View {
        Group {
            // Use AsyncImage for loading images from URLs
            if let urlString = item.media_type == "VIDEO" ? item.thumbnail_url : item.media_url,
               let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                         ProgressView()
                            .aspectRatio(1, contentMode: .fit) // Maintain square aspect ratio
                     case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .aspectRatio(1, contentMode: .fit) // Maintain square aspect ratio
                            .clipped() // Clip if image is larger than frame
                    case .failure:
                        Image(systemName: "photo") // Placeholder for failure
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.gray)
                             .aspectRatio(1, contentMode: .fit) // Maintain square aspect ratio
                     @unknown default:
                        EmptyView()
                    }
                }
            } else if item.media_type == "CAROUSEL_ALBUM" {
                 Image(systemName: "square.stack.3d.up.fill") // Placeholder for carousel
                     .resizable()
                     .scaledToFit()
                     .foregroundColor(.gray)
                     .aspectRatio(1, contentMode: .fit)
                     .overlay(Text("Album").font(.caption).foregroundColor(.white).padding(2).background(Color.black.opacity(0.5)), alignment: .bottomTrailing)

            } else {
                Image(systemName: "photo") // Generic placeholder
                     .resizable()
                     .scaledToFit()
                     .foregroundColor(.gray)
                      .aspectRatio(1, contentMode: .fit)
            }
        }
         .frame(maxWidth: .infinity) // Ensure it takes up grid space
         .aspectRatio(1, contentMode: .fit) // Maintain square shape
         .background(Color.gray.opacity(0.1)) // Background for empty/loading states
    }
}
