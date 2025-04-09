//
//  AppleMusicContentView.swift
//  MyApp
//
//  Created by Cong Le on 4/8/25.
//

import SwiftUI
import StoreKit // For SKCloudServiceController & SKCloudServiceAuthorizationStatus
import Combine  // For ObservableObject

// MARK: - Constants
struct AppleMusicConstants {
    static let apiBaseURL = "https://api.music.apple.com/v1/"
    static let libraryPlaylistsEndpoint = "me/library/playlists"
    static let heavyRotationEndpoint = "me/history/heavy-rotation"
    // Add more endpoints as required
}

// MARK: - Apple Music API Error Enum
enum AppleMusicError: Error, LocalizedError {
    case authorizationFailed(SKCloudServiceAuthorizationStatus)
    case authorizationDenied
    case authorizationRestricted
    case capabilitiesCheckFailed(Error?)
    case storefrontCheckFailed(Error?)
    case userTokenFetchFailed(Error?)
    case userTokenUnavailable
    case developerTokenMissing
    case storefrontMissing
    case notAuthorized
    case networkError(Error)
    case invalidResponse
    case httpError(statusCode: Int, details: String?)
    case noData
    case decodingError(Error?)
    case requestCreationFailed(String)
    case maxRetriesReached
    case unknown(Error? = nil)
    
    var errorDescription: String? {
        switch self {
        case .authorizationFailed(let status): return "Authorization failed with status: \(status.rawValue)."
        case .authorizationDenied: return "Access to Apple Music / Media Library was denied. Please grant access in Settings."
        case .authorizationRestricted: return "Access to Apple Music / Media Library is restricted (e.g., by parental controls)."
        case .capabilitiesCheckFailed(let error): return "Could not check Apple Music capabilities: \(error?.localizedDescription ?? "Unknown reason")."
        case .storefrontCheckFailed(let error): return "Could not determine Apple Music storefront: \(error?.localizedDescription ?? "Unknown reason")."
        case .userTokenFetchFailed(let error): return "Failed to fetch Music User Token: \(error?.localizedDescription ?? "Unknown reason"). Ensure Developer Token is valid and User is authorized."
        case .userTokenUnavailable: return "Music User Token is unavailable. Cannot perform user-specific actions."
        case .developerTokenMissing: return "Developer Token was not provided."
        case .storefrontMissing: return "User storefront identifier is missing."
        case .notAuthorized: return "User has not authorized access to Apple Music / Media Library."
        case .networkError(let error): return "Network error: \(error.localizedDescription)."
        case .invalidResponse: return "Received an invalid response from the Apple Music API."
        case .httpError(let statusCode, let details): return "Apple Music API Error \(statusCode): \(details ?? "No details provided")."
        case .noData: return "No data received from the Apple Music API."
        case .decodingError(let error): return "Failed to decode response: \(error?.localizedDescription ?? "Unknown decoding error")."
        case .requestCreationFailed(let reason): return "Failed to create API request: \(reason)."
        case .maxRetriesReached: return "Maximum number of retries reached for API request."
        case .unknown(let error): return "An unknown Apple Music error occurred: \(error?.localizedDescription ?? "N/A")."
        }
    }
}

// MARK: - Data Structures (Matching Apple Music API Responses)
// These should accurately reflect the structure of the JSON you expect

struct Playlist: Decodable, Identifiable {
    let id: String
    let type: String // e.g., "library-playlists"
    let href: String? // Href might be optional sometimes
    struct Attributes: Decodable {
        let name: String
        let description: PlaylistDescription?
        let canEdit: Bool? // Optionality depends on context
        let isPublic: Bool?
        let dateAdded: String? // Or Date if using dateDecodingStrategy
        // Add 'artwork' and 'playParams' structs if needed
    }
    let attributes: Attributes?
}

struct PlaylistDescription: Decodable {
    let standard: String? // Description text might be optional
}

// Generic structure for paginated Apple Music API responses
struct MusicDataResponse<T: Decodable>: Decodable {
    let data: [T]? // Data might be missing on error or empty response
    let next: String? // URL for the next page of results
    // Add other potential top-level keys like 'meta' if needed
}

// Example for parsing Apple Music API errors
struct AppleMusicApiErrorResponse: Decodable {
    struct ApiError: Decodable {
        let id: String?
        let title: String?
        let detail: String?
        let status: String?
        let code: String? // Sometimes an error code is provided
    }
    let errors: [ApiError]?
}


// MARK: - Apple Music Authentication Manager (ObservableObject)
class AppleMusicAuthManager: ObservableObject {
    
    // --- Published Properties for UI Binding ---
    @Published var authorizationStatus: SKCloudServiceAuthorizationStatus = .notDetermined
    @Published var isAuthorized: Bool = false
    @Published var canPlayCatalog: Bool = false
    @Published var hasAppleMusicSubscription: Bool = false
    @Published var userStorefront: String? = nil
    @Published var musicUserToken: String? = nil
    @Published var isLoading: Bool = false // General loading for setup/auth
    @Published var errorMessage: String? = nil // General errors
    
    @Published var userLibraryPlaylists: [Playlist] = []
    @Published var isLoadingPlaylists: Bool = false // Specific loading for playlists
    @Published var playlistErrorMessage: String? = nil
    
    // --- Private Properties ---
    private let developerToken: String
    private let cloudServiceController = SKCloudServiceController()
    private var setupCompletion: ((Bool, Error?) -> Void)?
    
    // MARK: - Initialization
    init(developerToken: String) {
        guard !developerToken.isEmpty else {
            // In a real app, handle this more gracefully (e.g., disable functionality)
            fatalError("Developer Token cannot be empty. Please provide a valid token.")
        }
        self.developerToken = developerToken
        print("AppleMusicAuthManager initialized.")
        checkInitialAuthorization() // Check status synchronously on init
    }
    
    // MARK: - Setup Flow
    func performFullSetup(completion: @escaping (Bool, Error?) -> Void) {
        guard !isLoading else {
            print("Setup already in progress.")
            completion(false, AppleMusicError.unknown(nil)) // Indicate setup didn't run now
            return
        }
        print("Starting full Apple Music setup...")
        DispatchQueue.main.async { // Ensure UI updates start on main thread
            self.isLoading = true
            self.errorMessage = nil
        }
        self.setupCompletion = completion
        
        let currentStatus = SKCloudServiceController.authorizationStatus()
        updateAuthorizationState(status: currentStatus) // Update state immediately
        
        if currentStatus == .authorized {
            print("Already authorized. Proceeding with capability checks...")
            checkCapabilitiesAndStorefront()
        } else if currentStatus == .notDetermined {
            print("Authorization not determined. Requesting access...")
            requestAuthorization()
        } else {
            print("Authorization denied or restricted (\(currentStatus)). Setup cannot complete.")
            let error = (currentStatus == .denied) ? AppleMusicError.authorizationDenied : AppleMusicError.authorizationRestricted
            finishSetup(success: false, error: error)
        }
    }
    
    
    // MARK: - Core Authorization & Checks
    
    private func checkInitialAuthorization() {
        let status = SKCloudServiceController.authorizationStatus()
        print("Initial Apple Music Authorization Status: \(status.rawValue)")
        // IMPORTANT: Don't trigger UI updates directly in init.
        // Just store the initial state. Update publisher on main thread later if needed.
        // Let the UI read this value initially.
        self.authorizationStatus = status
        self.isAuthorized = (status == .authorized)
    }
    
    func requestAuthorization() {
        // Check if loading ONLY if not part of the setup flow
        guard !isLoading || setupCompletion != nil else {
            print("Authorization request blocked: Already loading outside of setup flow.")
            return
        }
        // If not part of initial setup, manage loading state here
        if setupCompletion == nil {
            DispatchQueue.main.async {
                self.isLoading = true
                self.errorMessage = nil
            }
        }
        
        SKCloudServiceController.requestAuthorization { [weak self] status in
            DispatchQueue.main.async {
                print("Authorization request completed with status: \(status.rawValue)")
                self?.updateAuthorizationState(status: status) // Update published state
                
                if status == .authorized {
                    self?.checkCapabilitiesAndStorefront() // Proceed if authorized
                } else {
                    let error = (status == .denied) ? AppleMusicError.authorizationDenied : AppleMusicError.authorizationRestricted
                    if self?.setupCompletion != nil {
                        self?.finishSetup(success: false, error: error)
                    } else {
                        self?.isLoading = false // Stop loading if standalone request
                        self?.errorMessage = error.localizedDescription
                    }
                }
            }
        }
    }
    
    private func checkCapabilitiesAndStorefront() {
        print("Checking Apple Music capabilities...")
        cloudServiceController.requestCapabilities { [weak self] capabilities, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if let error = error {
                    print("Capability check failed: \(error.localizedDescription)")
                    let checkError = AppleMusicError.capabilitiesCheckFailed(error)
                    if self.setupCompletion != nil { self.finishSetup(success: false, error: checkError) }
                    else { self.errorMessage = checkError.localizedDescription; self.isLoading = false }
                    return
                }
                self.canPlayCatalog = capabilities.contains(.musicCatalogPlayback)
                self.hasAppleMusicSubscription = capabilities.contains(.addToCloudMusicLibrary) || capabilities.contains(.musicCatalogSubscriptionEligible)
                print("Capabilities: CanPlayCatalog=\(self.canPlayCatalog), HasSubscription=\(self.hasAppleMusicSubscription)")
                self.fetchStorefront() // Proceed only on success
            }
        }
    }
    
    private func fetchStorefront() {
        print("Fetching user storefront...")
        cloudServiceController.requestStorefrontIdentifier { [weak self] storefrontId, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if let error = error {
                    print("Storefront check failed: \(error.localizedDescription)")
                    let checkError = AppleMusicError.storefrontCheckFailed(error)
                    if self.setupCompletion != nil { self.finishSetup(success: false, error: checkError) }
                    else { self.errorMessage = checkError.localizedDescription; self.isLoading = false }
                    return
                }
                self.userStorefront = storefrontId
                print("Storefront identifier: \(storefrontId ?? "nil")")
                self.fetchMusicUserToken() // Proceed only on success
            }
        }
    }
    
    // Fetch User Token (modified to accept optional completion)
    func fetchMusicUserToken(completion: ((Bool, Error?) -> Void)? = nil) {
        guard self.isAuthorized else {
            let error = AppleMusicError.notAuthorized; print(error.localizedDescription)
            if self.setupCompletion != nil && completion == nil { // Part of setup, use finishSetup
                self.finishSetup(success: false, error: error)
            } else { // Standalone call or retry, use provided completion
                completion?(false, error)
                // Update general error if standalone
                if self.setupCompletion == nil && completion == nil {
                    DispatchQueue.main.async { self.errorMessage = error.localizedDescription; self.isLoading = false }
                }
            }
            return
        }
        guard !self.developerToken.isEmpty else {
            let error = AppleMusicError.developerTokenMissing; print(error.localizedDescription)
            if self.setupCompletion != nil && completion == nil { self.finishSetup(success: false, error: error) }
            else {
                completion?(false, error)
                if self.setupCompletion == nil && completion == nil {
                    DispatchQueue.main.async { self.errorMessage = error.localizedDescription; self.isLoading = false }
                }
            }
            return
        }
        
        print("Fetching Music User Token...")
        cloudServiceController.requestUserToken(forDeveloperToken: developerToken) { [weak self] userToken, error in
            DispatchQueue.main.async {
                guard let self = self else { completion?(false, AppleMusicError.unknown()); return }
                
                if let error = error {
                    print("Music User Token fetch failed: \(error.localizedDescription)")
                    let fetchError = AppleMusicError.userTokenFetchFailed(error)
                    self.musicUserToken = nil
                    if self.setupCompletion != nil && completion == nil { self.finishSetup(success: false, error: fetchError) }
                    else {
                        completion?(false, fetchError)
                        if self.setupCompletion == nil && completion == nil {
                            self.errorMessage = fetchError.localizedDescription; self.isLoading = false
                        }
                    }
                    return
                }
                
                self.musicUserToken = userToken
                print("Music User Token received: \(userToken != nil ? "Present" : "nil")")
                
                if userToken == nil {
                    let fetchError = AppleMusicError.userTokenUnavailable
                    if self.setupCompletion != nil && completion == nil { self.finishSetup(success: false, error: fetchError) }
                    else {
                        completion?(false, fetchError)
                        if self.setupCompletion == nil && completion == nil {
                            self.errorMessage = fetchError.localizedDescription; self.isLoading = false
                        }
                    }
                } else {
                    // SUCCESS fetching token
                    if self.setupCompletion != nil && completion == nil { // End of initial setup
                        self.finishSetup(success: true, error: nil)
                    } else { // Standalone call or retry successful
                        completion?(true, nil)
                        // Clear general error if standalone
                        if self.setupCompletion == nil && completion == nil {
                            self.errorMessage = nil; self.isLoading = false
                        }
                    }
                }
            }
        }
    }
    
    // Helper to finish the setup flow
    private func finishSetup(success: Bool, error: Error?) {
        print("Finishing setup. Success: \(success), Error: \(error?.localizedDescription ?? "None")")
        // Ensure UI updates happen on main thread
        DispatchQueue.main.async {
            self.isLoading = false
            if let error = error {
                self.errorMessage = error.localizedDescription
            } else {
                self.errorMessage = nil // Clear error message on success
            }
            // Call the original completion handler
            self.setupCompletion?(success, error)
            self.setupCompletion = nil // Clear completion handler
        }
    }
    
    
    // Helper to update authorization state publishers
    private func updateAuthorizationState(status: SKCloudServiceAuthorizationStatus) {
        // Ensure updates run on main thread if called from background callbacks
        DispatchQueue.main.async {
            self.authorizationStatus = status
            self.isAuthorized = (status == .authorized)
            print("Auth state updated: Status=\(status.rawValue), isAuthorized=\(self.isAuthorized)")
            if status != .authorized {
                // Clear potentially sensitive user data if authorization lost
                self.resetUserSpecificState(clearAuthStatus: false)
            }
        }
    }
    
    
    // MARK: - API Request Function
    func makeAPIRequest<T: Decodable>(
        endpoint: String,
        method: String = "GET",
        queryParameters: [String: String] = [:],
        body: Data? = nil,
        responseType: T.Type,
        currentAttempt: Int = 1,
        maxAttempts: Int = 2,
        requiresUserToken: Bool = true,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        guard !developerToken.isEmpty else { completion(.failure(AppleMusicError.developerTokenMissing)); return }
        guard let storefront = userStorefront, !storefront.isEmpty else { completion(.failure(AppleMusicError.storefrontMissing)); return }
        
        // Check authorization status *before* checking for user token
        guard isAuthorized || !requiresUserToken else {
            completion(.failure(AppleMusicError.notAuthorized))
            return
        }
        
        // Check for user token only *if* required
        if requiresUserToken {
            guard let userToken = musicUserToken, !userToken.isEmpty else {
                print("Error: User token required for '\(endpoint)' but is missing.")
                // Don't attempt fetch here to avoid complexity, fail fast.
                // The UI should ideally prevent calls needing a token if it's not available.
                completion(.failure(AppleMusicError.userTokenUnavailable))
                return
            }
        }
        
        guard currentAttempt <= maxAttempts else { completion(.failure(AppleMusicError.maxRetriesReached)); return }
        
        guard let baseURL = URL(string: AppleMusicConstants.apiBaseURL) else { completion(.failure(AppleMusicError.requestCreationFailed("Invalid base URL"))); return }
        let fullURLWithPath = baseURL.appendingPathComponent(endpoint)
        var components = URLComponents(url: fullURLWithPath, resolvingAgainstBaseURL: false)
        var allQueryItems = [URLQueryItem(name: "l", value: storefront)]
        allQueryItems.append(contentsOf: queryParameters.map { URLQueryItem(name: $0.key, value: $0.value) })
        components?.queryItems = allQueryItems.isEmpty ? nil : allQueryItems
        
        guard let finalURL = components?.url else { completion(.failure(AppleMusicError.requestCreationFailed("Could not construct final URL"))); return }
        
        var request = URLRequest(url: finalURL)
        request.httpMethod = method.uppercased()
        request.setValue("Bearer \(developerToken)", forHTTPHeaderField: "Authorization")
        if requiresUserToken, let token = musicUserToken { request.setValue(token, forHTTPHeaderField: "Music-User-Token") }
        if let bodyData = body, ["POST", "PUT", "PATCH"].contains(request.httpMethod ?? "") { request.httpBody = bodyData; request.setValue("application/json", forHTTPHeaderField: "Content-Type") }
        
        print("API Request [\(method)\(requiresUserToken ? " + UserToken" : "")] to \(finalURL)")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { completion(.failure(AppleMusicError.unknown())); return }
            if let networkError = error { completion(.failure(AppleMusicError.networkError(networkError))); return }
            guard let httpResponse = response as? HTTPURLResponse else { completion(.failure(AppleMusicError.invalidResponse)); return }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                let errorDetails = self.extractErrorDetails(from: data)
                print("HTTP Error \(httpResponse.statusCode) for \(finalURL): \(errorDetails ?? "No details")")
                if (httpResponse.statusCode == 401 || httpResponse.statusCode == 403) && requiresUserToken {
                    print("Received \(httpResponse.statusCode). Potential User Token issue. Attempting token refresh and retry...")
                    self.fetchMusicUserToken() { success, fetchError in
                        if success {
                            print("User token refreshed. Retrying API request...")
                            self.makeAPIRequest(endpoint: endpoint, method: method, queryParameters: queryParameters, body: body, responseType: responseType, currentAttempt: currentAttempt + 1, maxAttempts: maxAttempts, requiresUserToken: requiresUserToken, completion: completion)
                        } else {
                            print("Failed to refresh user token. Aborting retry.")
                            completion(.failure(AppleMusicError.httpError(statusCode: httpResponse.statusCode, details: errorDetails ?? "Token refresh also failed: \(fetchError?.localizedDescription ?? "Unknown").")))
                        }
                    }
                } else {
                    completion(.failure(AppleMusicError.httpError(statusCode: httpResponse.statusCode, details: errorDetails)))
                }
                return
            }
            
            // Handle success but potentially no data (e.g., 204 No Content)
            guard let responseData = data, !responseData.isEmpty else {
                // Check if T allows nil or empty data (e.g., if T is Optional or a specific Void-like type)
                // For simplicity, assume data is needed unless T handles emptiness.
                if httpResponse.statusCode == 204 {
                    // Try decoding T from empty data if T supports it (e.g., an Optional type)
                    // This is complex. A common approach is to have a special `EmptyResponse` type or handle Void.
                    // Hacky workaround: Check if T is Any? - Not reliable.
                    // Let's attempt decode and let it fail if T requires data.
                    print("Received status \(httpResponse.statusCode) with no data. Attempting decode...")
                    return
                } else {
                    print("No data received despite 2xx status (\(httpResponse.statusCode)).")
                    completion(.failure(AppleMusicError.noData))
                    return
                }
            }
            
            
            do {
                #if DEBUG
                if let jsonString = String(data: responseData ?? Data(), encoding: .utf8), !jsonString.isEmpty { print("Raw JSON response for \(endpoint):\n\(jsonString)") }
                else if responseData == nil || responseData.isEmpty { print("Raw response for \(endpoint): Empty Data") }
                #endif
                let decoder = JSONDecoder()
                let decodedObject = try decoder.decode(T.self, from: responseData ?? Data()) // Pass empty data for 204 case
                completion(.success(decodedObject))
            } catch let decodingError {
                print("Decoding error for \(T.self) from \(finalURL): \(decodingError)")
                completion(.failure(AppleMusicError.decodingError(decodingError)))
            }
            
        }.resume()
    }
    
    
    // MARK: - Playlist Fetching Example
    func fetchUserLibraryPlaylists() {
        guard !isLoadingPlaylists else { print("Already loading playlists."); return }
        guard isAuthorized else { print("Not authorized to fetch playlists."); playlistErrorMessage = "Authorization required."; return } // Prevent unnecessary calls
        
        DispatchQueue.main.async {
            self.isLoadingPlaylists = true
            self.playlistErrorMessage = nil
            self.userLibraryPlaylists = [] // Clear previous results
        }
        
        makeAPIRequest(
            endpoint: AppleMusicConstants.libraryPlaylistsEndpoint,
            method: "GET",
            queryParameters: ["limit": "50"], // Example fetch limit
            responseType: MusicDataResponse<Playlist>.self,
            requiresUserToken: true
        ) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoadingPlaylists = false
                switch result {
                case .success(let response):
                    self.userLibraryPlaylists = response.data ?? [] // Handle potential nil data array
                    self.playlistErrorMessage = nil
                    print("Successfully fetched \(self.userLibraryPlaylists.count) library playlists.")
                    // TODO: Handle pagination using response.next if needed
                case .failure(let error):
                    self.userLibraryPlaylists = []
                    // Extract a more user-friendly message from the specific error
                    if let appleError = error as? AppleMusicError {
                        self.playlistErrorMessage = "Failed to load playlists: \(appleError.localizedDescription)"
                    } else {
                        self.playlistErrorMessage = "Failed to load playlists: \(error.localizedDescription)"
                    }
                    print("Error fetching library playlists: \(error)")
                }
            }
        }
    }
    
    // MARK: - State Management
    func resetUserSpecificState(clearAuthStatus: Bool = true) {
        print("Resetting user-specific state...")
        DispatchQueue.main.async { // Ensure UI updates on main thread
            if clearAuthStatus {
                self.authorizationStatus = .notDetermined
                self.isAuthorized = false
            }
            // Reset capabilities and tokens
            self.canPlayCatalog = false
            self.hasAppleMusicSubscription = false
            self.userStorefront = nil
            self.musicUserToken = nil
            self.errorMessage = nil // Clear general errors
            
            // Clear fetched data and related states
            self.userLibraryPlaylists = []
            self.isLoadingPlaylists = false
            self.playlistErrorMessage = nil
            
            // Reset loading states
            self.isLoading = false
        }
    }
    
    func deauthorizeAndReset() {
        print("Deauthorizing and resetting all state.")
        resetUserSpecificState(clearAuthStatus: true)
        // As noted before, this doesn't revoke permissions in Settings.
    }
    
    
    // MARK: - Error Handling Helpers
    private func extractErrorDetails(from data: Data?) -> String? {
        guard let data = data, !data.isEmpty else { return nil }
        // Try decoding Apple Music's standard error format
        if let errorResponse = try? JSONDecoder().decode(AppleMusicApiErrorResponse.self, from: data),
           let firstError = errorResponse.errors?.first {
            return "\(firstError.title ?? "API Error") (\(firstError.status ?? "Unknown Status")): \(firstError.detail ?? "No details provided.")"
        }
        // Fallback to plain text
        return String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}


// MARK: - SwiftUI Views

struct AppleMusicContentView: View {
    // Instantiate the manager. Replace "YOUR_DEVELOPER_TOKEN" with your actual token.
    // WARNING: Storing tokens directly in code is insecure for production apps.
    // Use a secure storage mechanism (Keychain) or fetch it from a server.
    @StateObject private var authManager = AppleMusicAuthManager(developerToken: "YOUR_DEVELOPER_TOKEN")
    
    var body: some View {
        NavigationView {
            VStack(spacing: 15) {
                AuthStatusView(authManager: authManager)
                
                // General Error Display
                if let errorMessage = authManager.errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                        .padding(.horizontal)
                }
                
                if authManager.isAuthorized {
                    AuthorizedContentView(authManager: authManager)
                } else {
                    // Show authorize button only if not determined and not loading
                    if authManager.authorizationStatus == .notDetermined && !authManager.isLoading {
                        AuthorizeButton(authManager: authManager)
                    } else if authManager.authorizationStatus == .denied || authManager.authorizationStatus == .restricted {
                        Text("Access to Apple Music / Media Library is \(authManager.authorizationStatus == .denied ? "denied" : "restricted"). Please check iOS Settings.")
                            .foregroundColor(.orange)
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                }
                
                Spacer() // Push content to top
                
                // Reset Button (Optional)
                ResetButton(authManager: authManager)
                    .padding(.bottom)
                
            }
            .navigationTitle("Apple Music Demo")
        }// Optional: Perform initial setup check when view appears
        .onAppear {
            if authManager.authorizationStatus == .notDetermined {
                // Maybe trigger setup automatically? Or wait for user action.
                // authManager.performFullSetup { _,_ in }
            } else if authManager.isAuthorized && authManager.musicUserToken == nil {
                // If authorized but lost token, try fetching again automatically?
                authManager.fetchMusicUserToken()
            }
        }
    }
}

#Preview("AppleMusicContentView") {
    AppleMusicContentView()
}
// MARK: - Helper Views

struct AuthStatusView: View {
    @ObservedObject var authManager: AppleMusicAuthManager
    
    var body: some View {
        VStack {
            Text("Authorization Status:")
                .font(.headline)
            Text("\(authStatusText(authManager.authorizationStatus))")
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(authStatusColor(authManager.authorizationStatus))
            
            if authManager.isLoading {
                ProgressView("Working...")
                    .padding(.top, 5)
            }
        }
        .padding(.vertical)
    }
    
    private func authStatusText(_ status: SKCloudServiceAuthorizationStatus) -> String {
        switch status {
        case .notDetermined: return "Not Determined"
        case .denied: return "Denied"
        case .restricted: return "Restricted"
        case .authorized: return "Authorized"
        @unknown default: return "Unknown"
        }
    }
    
    private func authStatusColor(_ status: SKCloudServiceAuthorizationStatus) -> Color {
        switch status {
        case .notDetermined: return .gray
        case .denied: return .red
        case .restricted: return .orange
        case .authorized: return .green
        @unknown default: return .black
        }
    }
}
#Preview("AuthStatusView"){
    AuthStatusView(authManager: AppleMusicAuthManager(developerToken: "CHANGE_ME_DADDY"))
}

struct AuthorizeButton: View {
    @ObservedObject var authManager: AppleMusicAuthManager
    
    var body: some View {
        Button {
            authManager.performFullSetup { success, error in
                // Completion handler on the button action itself.
                // The UI primarily relies on observing @Published properties,
                // but you could add specific feedback here if needed.
                if success {
                    print("Setup completed successfully from button press.")
                } else {
                    print("Setup failed from button press: \(error?.localizedDescription ?? "Unknown reason")")
                    // Error is already set on authManager.errorMessage, UI will update.
                }
            }
        } label: {
            Text("Connect Apple Music")
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
        .disabled(authManager.isLoading) // Disable while loading
        .padding(.horizontal)
    }
}
#Preview("AuthorizeButton") {
    AuthorizeButton(authManager: AppleMusicAuthManager(developerToken: "CHANGE_ME_DADDY"))
}

struct AuthorizedContentView: View {
    @ObservedObject var authManager: AppleMusicAuthManager
    
    var body: some View {
        ScrollView { // Use ScrollView for potentially long content
            VStack(alignment: .leading, spacing: 20) {
                CapabilitiesView(authManager: authManager)
                
                Divider()
                
                PlaylistSection(authManager: authManager)
                
                // Add sections for other data fetching (e.g., Heavy Rotation) here
            }
            .padding()
        }
    }
}
#Preview("AuthorizedContentView") {
    AuthorizedContentView(authManager: AppleMusicAuthManager(developerToken: "CHANGE_ME_DADDY"))
}

struct CapabilitiesView: View {
    @ObservedObject var authManager: AppleMusicAuthManager
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("User Details").font(.headline)
            HStack {
                Text("Storefront:")
                Text(authManager.userStorefront ?? "N/A").foregroundColor(.gray)
            }
            HStack {
                Text("Can Play Catalog:")
                Image(systemName: authManager.canPlayCatalog ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(authManager.canPlayCatalog ? .green : .red)
            }
            HStack {
                Text("Has Subscription:")
                Image(systemName: authManager.hasAppleMusicSubscription ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(authManager.hasAppleMusicSubscription ? .green : .red)
            }
            HStack {
                Text("User Token:")
                Image(systemName: authManager.musicUserToken != nil ? "checkmark.circle.fill" : "questionmark.circle.fill")
                    .foregroundColor(authManager.musicUserToken != nil ? .green : .orange)
                Text(authManager.musicUserToken != nil ? "(Present)" : "(Missing/Not Fetched)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            // Button to explicitly refresh token if needed
            Button("Refresh User Token") {
                authManager.fetchMusicUserToken() // Call the standalone fetch
            }
            .font(.caption)
            .buttonStyle(.bordered)
            .disabled(authManager.isLoading) // Disable during general loading
        }
    }
}
#Preview("CapabilitiesView") {
    CapabilitiesView(authManager: AppleMusicAuthManager(developerToken: "CHANGE_ME_DADDY"))
}
struct PlaylistSection: View {
    @ObservedObject var authManager: AppleMusicAuthManager
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Library Playlists").font(.headline)
                Spacer()
                Button {
                    authManager.fetchUserLibraryPlaylists()
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .disabled(authManager.isLoadingPlaylists) // Disable only when playlists are loading
            }
            
            if authManager.isLoadingPlaylists {
                ProgressView("Loading Playlists...")
                    .frame(maxWidth: .infinity, alignment: .center)
            } else if let errorMsg = authManager.playlistErrorMessage {
                Text("Error loading playlists: \(errorMsg)")
                    .foregroundColor(.red)
            } else if authManager.userLibraryPlaylists.isEmpty && !authManager.isLoadingPlaylists {
                Text("No library playlists found or not loaded yet.")
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
                // Optionally add the fetch button here too
                Button("Fetch Library Playlists") {
                    authManager.fetchUserLibraryPlaylists()
                }
                .padding(.top, 5)
                
            } else {
                // Limit displayed playlists or use a List
                ForEach(authManager.userLibraryPlaylists.prefix(10)) { playlist in // Display first 10
                    PlaylistRow(playlist: playlist)
                    Divider()
                }
                if authManager.userLibraryPlaylists.count > 10 {
                    Text("... and \(authManager.userLibraryPlaylists.count - 10) more.")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
    }
}
#Preview("PlaylistSection"){
    PlaylistSection(authManager: AppleMusicAuthManager(developerToken: "CHANGE_ME_DADDY"))
}
struct PlaylistRow: View {
    let playlist: Playlist
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(playlist.attributes?.name ?? "No Name")
                .font(.body).bold()
            if let description = playlist.attributes?.description?.standard {
                Text(description)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }
            // Add more details if needed (e.g., track count, artwork)
        }
        // Make the row expandable or navigable if desired
        // .onTapGesture { /* Navigate to playlist detail */ }
    }
}
#Preview("PlaylistRow") {
    PlaylistRow(playlist: Playlist(id: "some ID", type: "Sample Type", href: "asadsdsd", attributes: nil))
}


struct ResetButton: View {
    @ObservedObject var authManager: AppleMusicAuthManager
    
    var body: some View {
        Button("Reset State / Simulate Logout") {
            authManager.deauthorizeAndReset()
        }
        .foregroundColor(.red)
        .padding(.horizontal)
    }
}
#Preview("ResetButton") {
    ResetButton(authManager: AppleMusicAuthManager(developerToken: "CHANGE_ME_DADDY"))
}

// MARK: - Application Entry Point (for preview)
struct AppleMusicDemoApp: App {
    var body: some Scene {
        WindowGroup {
            AppleMusicContentView()
        }
    }
}
