//
//  AppleMusicAPIContentView_V2.swift
//  MyApp
//
//  Created by Cong Le on 4/8/25.
//

import SwiftUI
import StoreKit // For SKCloudServiceController & SKCloudServiceAuthorizationStatus
import Combine  // For ObservableObject

// MARK: - Constants & Configuration
struct AppConfig {
    // WARNING: NEVER hardcode real tokens in production apps.
    // Use Keychain, fetch from a secure server, or use other secure methods.
    static let developerTokenPlaceholder = "YOUR_DEVELOPER_TOKEN_HERE" // REPLACE THIS
}

struct AppleMusicConstants {
    static let apiBaseURL = "https://api.music.apple.com/v1/"
    static let libraryPlaylistsEndpoint = "me/library/playlists"
    static let heavyRotationEndpoint = "me/history/heavy-rotation" // Example endpoint
    // Add other endpoints...
}

// MARK: - Apple Music API Error Enum (Unchanged)
enum AppleMusicError: Error, LocalizedError {
    // ... (Keep the enum definition from the previous response) ...
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
    case mockDataError // Added for mock data failures
    case unknown(Error? = nil)
    
    var errorDescription: String? {
        // ... (Keep the descriptions from the previous response) ...
        // Add description for mockDataError if needed
        switch self {
            // ... existing cases
        case .mockDataError: return "Failed to load mock data."
            // Default or update other descriptions as needed
        default: return "An Apple Music error occurred." // Simplified default
        }
    }
    var isAuthError: Bool {
        switch self {
        case .authorizationDenied, .authorizationRestricted, .notAuthorized, .userTokenUnavailable:
            return true
        default:
            return false
        }
    }
}


// MARK: - Data Structures (Refined with Optionality)

struct Playlist: Decodable, Identifiable, Hashable { // Added Hashable
    let id: String
    let type: String
    let href: String?
    struct Attributes: Decodable, Hashable { // Added Hashable
        let name: String
        // Optional properties based on API variance
        let description: PlaylistDescription?
        let canEdit: Bool?
        let isPublic: Bool?
        let dateAdded: String? // Consider Date with strategy
        let playParams: PlayParams? // Added placeholder
        let artwork: Artwork?       // Added placeholder
        // Mock property
        let mockTrackCount: Int? // Add non-Decodable properties for mock data
    }
    let attributes: Attributes?
    
    // Conformance to Hashable (if attributes are Hashable)
    static func == (lhs: Playlist, rhs: Playlist) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    
    // Default empty state for previews or errors
    static let empty = Playlist(id: "_empty_", type: "library-playlists", href: nil, attributes: nil)
}

struct PlaylistDescription: Decodable, Hashable { // Added Hashable
    let standard: String?
}

// Placeholder: Add actual structure later
struct PlayParams: Decodable, Hashable { let id: String? }
struct Artwork: Decodable, Hashable {
    let url: String?
    // Add width, height, bgColor etc. if needed
}


struct HeavyRotationSong: Decodable, Identifiable, Hashable { // Renamed & Added Hashable
    let id: String
    let type: String // e.g., "library-songs", "songs"
    let href: String?
    struct Attributes: Decodable, Hashable { // Added Hashable
        let name: String
        let artistName: String
        let albumName: String?
        let playParams: PlayParams?
        let artwork: Artwork?
        // Add genreNames, releaseDate, durationInMillis etc.
    }
    let attributes: Attributes?
    
    static func == (lhs: HeavyRotationSong, rhs: HeavyRotationSong) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    
    static let empty = HeavyRotationSong(id: "_empty_song_", type: "songs", href: nil, attributes: nil)
}


struct MusicDataResponse<T: Decodable>: Decodable {
    let data: [T]?
    let next: String? // URL for next page
    // let meta: Meta? // Optional metadata
}


struct AppleMusicApiErrorResponse: Decodable { // Unchanged
    // ... (Keep the structure from the previous response) ...
    struct ApiError: Decodable { let id: String?, title: String?, detail: String?, status: String?, code: String? }
    let errors: [ApiError]?
}


// MARK: - Apple Music Authentication Manager (Expanded)
class AppleMusicAuthManager: ObservableObject {
    
    // --- Configuration ---
    let useMockData: Bool = false // << TOGGLE FOR MOCK DATA
    
    // --- Published Properties ---
    @Published var authorizationStatus: SKCloudServiceAuthorizationStatus = .notDetermined
    @Published var isAuthorized: Bool = false
    @Published var canPlayCatalog: Bool = false
    @Published var hasAppleMusicSubscription: Bool = false
    @Published var userStorefront: String? = nil
    @Published var musicUserToken: String? = nil
    
    // Loading & Error States
    @Published var isLoadingSetup: Bool = false // Specific loading for the initial setup/auth flow
    @Published var setupError: Error? = nil // Use specific error for setup issues presented in alert
    @Published var showErrorAlert: (Bool, String) = (false, "") // Tuple for alert presentation
    
    // Playlist Data
    @Published var userLibraryPlaylists: [Playlist] = []
    @Published var isLoadingPlaylists: Bool = false
    @Published var playlistErrorMessage: String? = nil
    @Published var canLoadMorePlaylists: Bool = false // Pagination simulation
    private var nextPlaylistUrl: String? = nil
    
    // Heavy Rotation Data (New)
    @Published var heavyRotationSongs: [HeavyRotationSong] = []
    @Published var isLoadingHeavyRotation: Bool = false
    @Published var heavyRotationErrorMessage: String? = nil
    
    // --- Private Properties ---
    private let developerToken: String
    private let cloudServiceController = SKCloudServiceController()
    private var setupCompletion: ((Bool, Error?) -> Void)?
    
    // MARK: - Initialization
    init(developerToken: String = AppConfig.developerTokenPlaceholder) {
        // Basic check for placeholder token - crucial for live API
        if developerToken == AppConfig.developerTokenPlaceholder && !useMockData {
            print("⚠️ WARNING: Using placeholder developer token. API calls will FAIL. Set 'useMockData' to true in AppleMusicAuthManager or provide a real token to run live.")
            // Consider preventing live operations entirely here
        } else if !useMockData {
            print("🚀 Using REAL developer token. Live API calls enabled.")
        }
        self.developerToken = developerToken
        print("AppleMusicAuthManager initialized. Using Mock Data: \(useMockData)")
        
        // Get initial status synchronously for immediate UI state
        let initialStatus = SKCloudServiceController.authorizationStatus()
        DispatchQueue.main.async { // Ensure UI updates happen on main thread
            print("Initial Auth Status: \(initialStatus.rawValue)")
            self.authorizationStatus = initialStatus
            self.isAuthorized = (initialStatus == .authorized)
        }
    }
    
    // MARK: - Mock Data Generation
    private func createMockPlaylist(id: Int) -> Playlist {
        let name = "My Mock Playlist \(id)"
        let desc = Bool.random() ? "A great collection of mock tracks #\(id)." : nil
        let trackCount = Int.random(in: 5...50)
        return Playlist(
            id: "mock_playlist_\(id)",
            type: "library-playlists",
            href: "/v1/me/library/playlists/mock_playlist_\(id)",
            attributes: .init(
                name: name,
                description: desc != nil ? .init(standard: desc) : nil,
                canEdit: Bool.random(),
                isPublic: Bool.random(),
                dateAdded: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-Double.random(in: 1...1000)*3600*24)),
                playParams: .init(id: "mock_pp_\(id)"),
                artwork: Artwork(url:"https://via.placeholder.com/60/007AFF/FFFFFF?text=P\(id)"), // Placeholder URL
                mockTrackCount: trackCount // Store mock track count
            )
        )
    }
    /// Attempts to parse standard Apple Music API error JSON or return raw string data.
    private func extractErrorDetails(from data: Data?) -> String? {
        guard let data = data, !data.isEmpty else { return nil }
        
        // Attempt 1: Try decoding the expected Apple Music Error JSON structure
        do {
            let errorResponse = try JSONDecoder().decode(AppleMusicApiErrorResponse.self, from: data)
            // If decoding succeeds, format the error details
            if let firstError = errorResponse.errors?.first {
                var details = [String]()
                if let title = firstError.title, !title.isEmpty { details.append("Title: \(title)") }
                if let detail = firstError.detail, !detail.isEmpty { details.append("Detail: \(detail)") }
                if let code = firstError.code, !code.isEmpty { details.append("Code: \(code)") }
                if let status = firstError.status, !status.isEmpty { details.append("Status: \(status)") }
                // Return combined details or nil if all parts were empty
                return details.isEmpty ? nil : details.joined(separator: "; ")
            }
        } catch let decodingError {
            // Decoding failed, log it and fall through to next attempt
            print("⚠️ Could not decode Apple Music API error JSON: \(decodingError.localizedDescription). Trying raw string fallback.")
        }
        
        // Attempt 2: Try converting raw data to string (fallback for non-JSON errors)
        if let rawString = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines), !rawString.isEmpty {
            // Limit length to prevent overly long raw error messages
            let maxLength = 300
            return (rawString.count > maxLength) ? String(rawString.prefix(maxLength)) + "..." : rawString
        }
        
        // If all attempts fail to produce a string
        return nil
    }
    
    
    private func createMockSong(id: Int) -> HeavyRotationSong {
        let artists = ["The Mockers", "Simulated Sound", "Virtual Vibes", "Test Tone Titans"]
        let albums = ["Digital Dreams", "Placeholder Paradise", "Code Compositions"]
        let songs = ["Binary Beat", "API Anthem", "JSON Jam", "Callback Calypso", "Swift Serenade"]
        return HeavyRotationSong(
            id: "mock_song_\(id)",
            type: Bool.random() ? "library-songs" : "songs",
            href: "/v1/catalog/us/songs/mock_song_\(id)",
            attributes: .init(
                name: songs.randomElement() ?? "Mock \(id)",
                artistName: artists.randomElement() ?? "Mock Artist",
                albumName: albums.randomElement(),
                playParams: .init(id: "mock_song_pp_\(id)"),
                artwork: Artwork(url: "https://via.placeholder.com/60/FF9500/FFFFFF?text=S\(id)") // Placeholder URL
            )
        )
    }
    
    // MARK: - Setup Flow (Entry Point)
    func performFullSetup() {
        guard !isLoadingSetup else { print("Setup already in progress."); return }
        print("🚀 Starting full Apple Music setup...")
        DispatchQueue.main.async {
            self.isLoadingSetup = true
            self.setupError = nil
            self.showErrorAlert = (false, "")
        }
        
        // Explicitly handle mock data scenario for setup
        if useMockData {
            print(" MOCK MODE: Simulating successful setup.")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { // Simulate delay
                self.authorizationStatus = .authorized
                self.isAuthorized = true
                self.canPlayCatalog = true
                self.hasAppleMusicSubscription = true
                self.userStorefront = "mock_us"
                self.musicUserToken = "mock_user_token_123"
                self.isLoadingSetup = false
                print(" MOCK MODE: Setup complete.")
                // Fetch mock data only after simulated setup success
                self.fetchUserLibraryPlaylists()
                self.fetchHeavyRotation()
            }
            return
        }
        
        // Actual LIVE setup flow
        let currentStatus = SKCloudServiceController.authorizationStatus()
        print(" Current Auth Status during setup: \(currentStatus.rawValue)")
        updateAuthorizationState(status: currentStatus) // Update publishers
        
        switch currentStatus {
        case .authorized:
            print("-> Already authorized. Proceeding with capability & token checks...")
            checkCapabilitiesAndStorefront() // Already authorized, fetch details
        case .notDetermined:
            print("-> Authorization not determined. Requesting access...")
            requestAuthorization() // Needs user permission
        case .denied:
            print("-> Access denied by user previously.")
            finishSetup(success: false, error: AppleMusicError.authorizationDenied)
        case .restricted:
            print("-> Access restricted (e.g., parental controls).")
            finishSetup(success: false, error: AppleMusicError.authorizationRestricted)
        @unknown default:
            print("-> Unknown authorization status encountered.")
            finishSetup(success: false, error: AppleMusicError.unknown())
        }
    }
    
    // MARK: - Core Authorization & Checks (Error Handling Focused)
    
    private func checkInitialAuthorization() {
        let status = SKCloudServiceController.authorizationStatus()
        print("Initial Auth Status: \(status.rawValue)")
        // Update state directly - needed for initial UI layout
        self.authorizationStatus = status
        self.isAuthorized = (status == .authorized)
    }
    
    func requestAuthorization() {
          // This is usually called by performFullSetup, but could be called directly too
          // Ensure loading state is active if called directly
           if !isLoadingSetup {
                DispatchQueue.main.async { self.isLoadingSetup = true }
           }

         SKCloudServiceController.requestAuthorization { [weak self] status in
             DispatchQueue.main.async {
                 guard let self = self else { return }
                 print("Authorization request completed with status: \(status.rawValue)")
                 self.updateAuthorizationState(status: status) // Update published status

                 if status == .authorized {
                     print("-> Authorization granted! Proceeding with capability & token checks...")
                     self.checkCapabilitiesAndStorefront() // Now authorized, fetch details
                 } else {
                    // If was .notDetermined and now it's denied/restricted
                     let error: AppleMusicError = (status == .denied) ? .authorizationDenied : .authorizationRestricted
                     print("-> Authorization not granted (\(status.rawValue)).")
                     self.finishSetup(success: false, error: error)
                 }
             }
         }
     }
    
    // checkCapabilitiesAndStorefront, fetchStorefront, fetchMusicUserToken
    // remain largely the same logically, but now call finishSetup on error.
    
    private func checkCapabilitiesAndStorefront() { /* ... calls fetchStorefront or finishSetup ... */
         print(" Checking capabilities...")
         cloudServiceController.requestCapabilities { [weak self] capabilities, error in
              DispatchQueue.main.async {
                  guard let self = self else { return }
                  if let error = error {
                       print("❌ Capability check failed: \(error.localizedDescription)")
                       self.finishSetup(success: false, error: AppleMusicError.capabilitiesCheckFailed(error)); return
                  }
                  self.canPlayCatalog = capabilities.contains(.musicCatalogPlayback)
                  self.hasAppleMusicSubscription = capabilities.contains(.addToCloudMusicLibrary) || capabilities.contains(.musicCatalogSubscriptionEligible)
                  print(" Capabilities: PlayCatalog=\(self.canPlayCatalog), HasSubscription=\(self.hasAppleMusicSubscription)")
                   self.fetchStorefront() // Proceed to next step
              }
         }
    }
    private func fetchStorefront() { /* ... calls fetchMusicUserToken or finishSetup ... */
         print(" Fetching storefront...")
         cloudServiceController.requestStorefrontIdentifier { [weak self] storefrontId, error in
              DispatchQueue.main.async {
                   guard let self = self else { return }
                   if let error = error {
                       print("❌ Storefront check failed: \(error.localizedDescription)")
                       self.finishSetup(success: false, error: AppleMusicError.storefrontCheckFailed(error)); return
                   }
                   guard let id = storefrontId, !id.isEmpty else {
                        print("❌ Storefront ID received but is nil or empty.")
                        self.finishSetup(success: false, error: AppleMusicError.storefrontMissing); return
                   }
                   self.userStorefront = id
                   print(" Storefront: \(id)")
                   self.fetchMusicUserTokenInternal() // Proceed to next step
               }
          }
     }
    
    // Renamed internal version for setup flow
    private func fetchMusicUserTokenInternal() { /* ... calls finishSetup ... */
         guard self.isAuthorized else { finishSetup(success: false, error: AppleMusicError.notAuthorized); return }

         // Check for placeholder developer token BEFORE making the request
          guard !self.developerToken.isEmpty, self.developerToken != AppConfig.developerTokenPlaceholder else {
               print("❌ Aborting User Token fetch: Developer token is missing or is the placeholder.")
               finishSetup(success: false, error: AppleMusicError.developerTokenMissing); return
           }

         print(" Fetching Music User Token (setup flow)...")
         cloudServiceController.requestUserToken(forDeveloperToken: developerToken) { [weak self] userToken, error in
              DispatchQueue.main.async {
                  guard let self = self else { return }
                  if let error = error {
                       print("❌ User Token fetch failed: \(error.localizedDescription)")
                       self.musicUserToken = nil
                       self.finishSetup(success: false, error: AppleMusicError.userTokenFetchFailed(error)); return
                  }
                  guard let token = userToken, !token.isEmpty else {
                       print("❌ User Token received but is nil or empty.")
                       self.musicUserToken = nil
                       self.finishSetup(success: false, error: AppleMusicError.userTokenUnavailable)
                       return
                  }
                  self.musicUserToken = token
                  print("✅ User Token fetch successful.")
                  self.finishSetup(success: true, error: nil) // Final step of setup successful
               }
           }
    }
    
    
    // Public function for manual refresh, potentially showing alert on failure
    func refreshMusicUserToken() { /* ... shows alert ... */
         guard !isLoadingSetup else { print("Cannot refresh token during setup."); return }
         guard isAuthorized else { presentErrorAlert(AppleMusicError.notAuthorized, title: "Not Authorized"); return }
          guard !developerToken.isEmpty, developerToken != AppConfig.developerTokenPlaceholder else {
               presentErrorAlert(AppleMusicError.developerTokenMissing, title: "Configuration Error"); return
           }

            print("🔄 Refreshing Music User Token (manual)...")
           // Consider adding a small, specific loading indicator maybe?
           cloudServiceController.requestUserToken(forDeveloperToken: developerToken) { [weak self] userToken, error in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                     if let error = error {
                         print("❌ Manual User Token refresh failed: \(error.localizedDescription)")
                          self.musicUserToken = nil
                         self.presentErrorAlert(AppleMusicError.userTokenFetchFailed(error), title: "Token Refresh Failed")
                     } else if let token = userToken, !token.isEmpty {
                          print("✅ Manual User Token refresh successful.")
                          self.musicUserToken = token
                     } else { // Token is nil or empty
                         print("❌ Manual User Token refresh returned nil or empty.")
                          self.musicUserToken = nil
                          self.presentErrorAlert(AppleMusicError.userTokenUnavailable, title: "Token Unavailable")
                     }
                 }
             }
      }
    
    // Helper to finish the setup flow and update state
    private func finishSetup(success: Bool, error: Error?) {
         print("🏁 Finishing setup. Success: \(success), Error: \(error?.localizedDescription ?? "None")")
         DispatchQueue.main.async {
              self.isLoadingSetup = false
              if let error = error {
                  self.setupError = error // Store the specific setup error
                  let appleError = error as? AppleMusicError // Cast for specific handling
                  let title = (appleError?.isAuthError ?? false) ? "Authorization Issue" : "Setup Failed"
                  self.presentErrorAlert(error, title: title) // Use the helper to show alert
              } else {
                  self.setupError = nil // Clear setup error on success
                  print("✅ Apple Music Setup Successful!")
                  // Fetch initial data after successful setup
                  self.fetchUserLibraryPlaylists()
                  self.fetchHeavyRotation()
              }
         }
     }
    
    
    // Helper to update authorization state publishers
    private func updateAuthorizationState(status: SKCloudServiceAuthorizationStatus) {
         // Must be on main thread
          DispatchQueue.main.async {
              guard self.authorizationStatus != status else { return } // Avoid redundant updates
              print("Auth state changed: \(self.authorizationStatus.rawValue) -> \(status.rawValue)")
              self.authorizationStatus = status
              self.isAuthorized = (status == .authorized) // Update derived state

              if status != .authorized {
                   // IMPORTANT: Clear sensitive data if authorization is lost or downgraded
                   print("Authorization lost or downgraded. Resetting user-specific state.")
                   self.resetUserSpecificState(clearAuthStatus: false) // Keep the new non-auth status
              }
         }
    }
    
    
    // MARK: - API Request Function
    func makeAPIRequest<T: Decodable>(
        endpoint: String, method: String = "GET", queryParameters: [String: String] = [:], body: Data? = nil,
        responseType: T.Type, currentAttempt: Int = 1, maxAttempts: Int = 2,
        requiresUserToken: Bool = true, completion: @escaping (Result<T, Error>) -> Void
    ) {
        // ... (Keep the implementation from the previous response) ...
        // Ensure it uses the refined error types and handling if needed (especially for 401/403 retry)
        // Ensure it handles the mock data toggle if appropriate for specific requests
        guard !useMockData else {
            print("Intercepted API request (\(endpoint)) due to useMockData=true. Returning mock failure.")
            // Or route to specific mock functions based on endpoint? Too complex for here.
            completion(.failure(AppleMusicError.mockDataError))
            return
        }
        
        // Existing pre-flight checks...
        guard !developerToken.isEmpty, developerToken != AppConfig.developerTokenPlaceholder else {
            completion(.failure(AppleMusicError.developerTokenMissing)); return
        }
        guard let storefront = userStorefront, !storefront.isEmpty else { completion(.failure(AppleMusicError.storefrontMissing)); return }
        guard isAuthorized || !requiresUserToken else { completion(.failure(AppleMusicError.notAuthorized)); return }
        if requiresUserToken { guard let userToken = musicUserToken, !userToken.isEmpty else { completion(.failure(AppleMusicError.userTokenUnavailable)); return } }
        guard currentAttempt <= maxAttempts else { completion(.failure(AppleMusicError.maxRetriesReached)); return }
        
        // ... Rest of URL construction, request creation, and URLSession.shared.dataTask ...
        // (Retry logic for 401/403 needs the internal token refresh mechanism)
        guard let baseURL = URL(string: AppleMusicConstants.apiBaseURL) /* ... */ else { /*...*/ return }
        let fullURLWithPath = baseURL.appendingPathComponent(endpoint)
        var components = URLComponents(url: fullURLWithPath, resolvingAgainstBaseURL: false)
        var allQueryItems = [URLQueryItem(name: "l", value: storefront)]
        allQueryItems.append(contentsOf: queryParameters.map { URLQueryItem(name: $0.key, value: $0.value) })
        components?.queryItems = allQueryItems.isEmpty ? nil : allQueryItems
        guard let finalURL = components?.url else { /*...*/ return }
        
        var request = URLRequest(url: finalURL)
        request.httpMethod = method.uppercased()
        request.setValue("Bearer \(developerToken)", forHTTPHeaderField: "Authorization")
        if requiresUserToken, let token = musicUserToken { request.setValue(token, forHTTPHeaderField: "Music-User-Token") }
        // ... Body and Content-Type ...
        
        print("API Request [\(method)\(requiresUserToken ? " + UserToken" : "")] to \(finalURL)")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { completion(.failure(AppleMusicError.unknown())); return }
            // ... Network error handling ...
            if let networkError = error { completion(.failure(AppleMusicError.networkError(networkError))); return }
            // ... Invalid response handling ...
            guard let httpResponse = response as? HTTPURLResponse else { completion(.failure(AppleMusicError.invalidResponse)); return }
            
            // ... HTTP status code handling (including 401/403 retry) ...
            guard (200...299).contains(httpResponse.statusCode) else {
                let errorDetails = self.extractErrorDetails(from: data)
                print("HTTP Error \(httpResponse.statusCode) for \(finalURL): \(errorDetails ?? "No details")")
                
                if (httpResponse.statusCode == 401 || httpResponse.statusCode == 403) && requiresUserToken && currentAttempt < maxAttempts {
                    print("Attempting token refresh and retry...")
                    // Use the internal refresh mechanism that doesn't show UI alerts directly
                    self.refreshMusicUserTokenInternalForRetry { success in
                        if success {
                            print("Token refreshed. Retrying API request...")
                            self.makeAPIRequest(endpoint: endpoint, method: method, queryParameters: queryParameters, body: body, responseType: responseType, currentAttempt: currentAttempt + 1, maxAttempts: maxAttempts, requiresUserToken: requiresUserToken, completion: completion)
                        } else {
                            print("Token refresh failed. Aborting retry.")
                            completion(.failure(AppleMusicError.httpError(statusCode: httpResponse.statusCode, details: errorDetails ?? "Token refresh failed.")))
                        }
                    }
                    
                } else { // Fail non-auth errors or if max retries reached
                    completion(.failure(AppleMusicError.httpError(statusCode: httpResponse.statusCode, details: errorDetails)))
                }
                return
            }
            
            // ... No data / 204 handling ...
            guard let responseData = data, !responseData.isEmpty else {
                // Handle 204 or other cases where empty data might be valid for T
                if httpResponse.statusCode == 204 {
                    print("Received 204 No Content for \(endpoint). Attempting decode (may fail if T requires data).")
                    return
                } else {
                    print("No data received despite 2xx status (\(httpResponse.statusCode)).")
                    completion(.failure(AppleMusicError.noData))
                    return
                }
            }
            
            
            // ... Decoding ...
            do {
                // Debug print
                #if DEBUG
                if let jsonString = String(data: responseData ?? Data(), encoding: .utf8), !jsonString.isEmpty { print("Raw JSON [\(endpoint)]:\n\(jsonString)") }
                else { print("Raw response [\(endpoint)]: Empty Data") }
                #endif
                let decoder = JSONDecoder() // Configure if needed
                let decodedObject = try decoder.decode(T.self, from: responseData ?? Data()) // Use empty data for 204 case
                completion(.success(decodedObject))
            } catch let decodingError {
                print("Decoding error for \(T.self) from \(finalURL): \(decodingError)")
                completion(.failure(AppleMusicError.decodingError(decodingError)))
            }
            
        }.resume()
    }
    
    // Internal token refresh specifically for the retry mechanism
    private func refreshMusicUserTokenInternalForRetry(completion: @escaping (Bool) -> Void) {
        guard self.isAuthorized else { completion(false); return }
        guard !self.developerToken.isEmpty, developerToken != AppConfig.developerTokenPlaceholder else { completion(false); return }
        
        print("Refreshing Music User Token (internal for retry)...")
        cloudServiceController.requestUserToken(forDeveloperToken: developerToken) { [weak self] userToken, error in
            DispatchQueue.main.async {
                guard let self = self else { completion(false); return }
                if error == nil, let token = userToken, !token.isEmpty {
                    print("Internal token refresh successful.")
                    self.musicUserToken = token
                    completion(true)
                } else {
                    print("Internal token refresh failed: \(error?.localizedDescription ?? "Token was nil")")
                    self.musicUserToken = nil // Ensure token is cleared on failure
                    completion(false)
                }
            }
        }
    }
    
    // MARK: - Data Fetching Functions (Playlist with Mock Toggle & Pagination)
    func fetchUserLibraryPlaylists(loadMore: Bool = false) {
        if useMockData { fetchMockPlaylists(loadMore: loadMore); return }
        
        guard !isLoadingPlaylists else { print("Already loading playlists."); return }
        guard isAuthorized else { presentErrorAlert(AppleMusicError.notAuthorized); return }
        
        let urlString: String
        if loadMore {
            guard let nextUrl = nextPlaylistUrl else { print("No more playlists to load."); return }
            // Note: nextUrl is usually absolute, so we don't use makeAPIRequest directly here.
            // We need a separate function or adapt makeAPIRequest to handle absolute URLs.
            // For simplicity, we'll stick to makeAPIRequest assuming relative paths for now.
            // In a real app, parse the 'next' URL and make a direct URLSession request.
            print("Pagination with absolute URL '\(nextUrl)' not implemented in this simplified example. Fetching first page again.")
            urlString = AppleMusicConstants.libraryPlaylistsEndpoint // Fallback for demo
            // Better: Extract path and params from nextUrl if possible relative to base.
        } else {
            // Fetching first page
            urlString = AppleMusicConstants.libraryPlaylistsEndpoint
            // Reset pagination state only when fetching the first page
            DispatchQueue.main.async {
                self.nextPlaylistUrl = nil
                self.canLoadMorePlaylists = false
                self.userLibraryPlaylists = [] // Clear previous results for a fresh load
            }
        }
        
        DispatchQueue.main.async {
            self.isLoadingPlaylists = true
            self.playlistErrorMessage = nil
        }
        
        makeAPIRequest(
            endpoint: urlString, // Use the determined endpoint/path
            method: "GET",
            queryParameters: loadMore ? [:] : ["limit": "20"], // Params for first page only in this simplified version
            responseType: MusicDataResponse<Playlist>.self,
            requiresUserToken: true
        ) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoadingPlaylists = false
                switch result {
                case .success(let response):
                    let fetchedPlaylists = response.data ?? []
                    if loadMore {
                        self.userLibraryPlaylists.append(contentsOf: fetchedPlaylists)
                    } else {
                        self.userLibraryPlaylists = fetchedPlaylists
                    }
                    self.nextPlaylistUrl = response.next // Store URL for next page
                    self.canLoadMorePlaylists = (response.next != nil) // Enable load more if available
                    print("Fetched \(fetchedPlaylists.count) playlists. Total: \(self.userLibraryPlaylists.count). Can load more: \(self.canLoadMorePlaylists)")
                case .failure(let error):
                    if !loadMore { self.userLibraryPlaylists = [] } // Clear on initial load error
                    self.playlistErrorMessage = "Playlist Error: \(error.localizedDescription)"
                    print("Error fetching playlists: \(error)")
                }
            }
        }
    }
    
    private func fetchMockPlaylists(loadMore: Bool = false) {
        guard !isLoadingPlaylists else { return }
        DispatchQueue.main.async {
            self.isLoadingPlaylists = true
            self.playlistErrorMessage = nil
            if !loadMore { // If it's not "load more", clear existing
                self.userLibraryPlaylists = []
                self.canLoadMorePlaylists = false // Reset pagination for mock
            }
        }
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + (loadMore ? 1.5 : 1.0)) {
            let baseId = loadMore ? self.userLibraryPlaylists.count : 0
            let newPlaylists = (0..<15).map { self.createMockPlaylist(id: baseId + $0) }
            
            self.userLibraryPlaylists.append(contentsOf: newPlaylists)
            self.isLoadingPlaylists = false
            // Simulate having more pages based on total count
            self.canLoadMorePlaylists = self.userLibraryPlaylists.count < 50 // Arbitrary limit for mock 'more'
            print("Loaded \(newPlaylists.count) mock playlists. Total: \(self.userLibraryPlaylists.count). Can load more: \(self.canLoadMorePlaylists)")
        }
    }
    
    // MARK: - Data Fetching Functions (Heavy Rotation - New)
    func fetchHeavyRotation() {
        if useMockData { fetchMockHeavyRotation(); return }
        
        guard !isLoadingHeavyRotation else { print("Already loading heavy rotation."); return }
        guard isAuthorized else { presentErrorAlert(AppleMusicError.notAuthorized); return }
        
        DispatchQueue.main.async {
            self.isLoadingHeavyRotation = true
            self.heavyRotationErrorMessage = nil
            self.heavyRotationSongs = [] // Clear previous
        }
        
        makeAPIRequest(
            endpoint: AppleMusicConstants.heavyRotationEndpoint,
            method: "GET",
            queryParameters: ["limit": "25"], // Example limit
            responseType: MusicDataResponse<HeavyRotationSong>.self,
            requiresUserToken: true
        ) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoadingHeavyRotation = false
                switch result {
                case .success(let response):
                    self.heavyRotationSongs = response.data ?? []
                    print("Fetched \(self.heavyRotationSongs.count) heavy rotation songs.")
                    // Handle pagination if needed for this endpoint
                case .failure(let error):
                    self.heavyRotationSongs = []
                    self.heavyRotationErrorMessage = "Heavy Rotation Error: \(error.localizedDescription)"
                    print("Error fetching heavy rotation: \(error)")
                }
            }
        }
    }
    
    private func fetchMockHeavyRotation() {
        guard !isLoadingHeavyRotation else { return }
        DispatchQueue.main.async {
            self.isLoadingHeavyRotation = true
            self.heavyRotationErrorMessage = nil
            self.heavyRotationSongs = []
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            let newSongs = (0..<20).map { self.createMockSong(id: $0) }
            self.heavyRotationSongs = newSongs
            self.isLoadingHeavyRotation = false
            print("Loaded \(newSongs.count) mock heavy rotation songs.")
        }
    }
    
    
    // MARK: - State Management & Error Presentation
    func resetUserSpecificState(clearAuthStatus: Bool = true) {
        print("Resetting user state...")
        DispatchQueue.main.async {
            if clearAuthStatus {
                self.authorizationStatus = .notDetermined
                self.isAuthorized = false
            }
            self.canPlayCatalog = false
            self.hasAppleMusicSubscription = false
            self.userStorefront = nil
            self.musicUserToken = nil
            self.setupError = nil // Clear setup error
            self.showErrorAlert = (false, "") // Hide alert
            
            self.userLibraryPlaylists = []
            self.isLoadingPlaylists = false
            self.playlistErrorMessage = nil
            self.nextPlaylistUrl = nil
            self.canLoadMorePlaylists = false
            
            self.heavyRotationSongs = []
            self.isLoadingHeavyRotation = false
            self.heavyRotationErrorMessage = nil
            
            self.isLoadingSetup = false // Ensure setup loading is reset
        }
    }
    
    func deauthorizeAndReset() {
        print("Deauthorizing and resetting all state.")
        resetUserSpecificState(clearAuthStatus: true)
    }
    
    // Helper to present errors via alert
    private func presentErrorAlert(_ error: Error, title: String = "Error") {
         // Avoid showing multiple alerts simultaneously if one is pending
         guard !showErrorAlert.0 else {
              print("Alert suppressed: Another alert is already being shown.")
              return
         }

        let message = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        print("🚨 Presenting Alert: Title='\(title)', Message='\(message)'")
        DispatchQueue.main.async {
            self.showErrorAlert = (true, title + message) // Update tuple to trigger alert
        }
    }
}

// Add rawValue descriptions for easier logging/debugging
extension SKCloudServiceAuthorizationStatus {
    var description: String {
        switch self {
        case .notDetermined: return "notDetermined"
        case .denied: return "denied"
        case .restricted: return "restricted"
        case .authorized: return "authorized"
        @unknown default: return "unknown (\(rawValue))"
        }
    }
}


// MARK: - SwiftUI Views

struct AppleMusicContentView: View {
    // Use AppStorage or Keychain for token in real apps
    @StateObject private var authManager = AppleMusicAuthManager() // Uses placeholder by default
    
    var body: some View {
        // Use NavigationView for title and potential navigation
        NavigationView {
            VStack(spacing: 0) { // Reduced spacing for tighter layout
                AuthStatusHeader(authManager: authManager)
                    .padding(.bottom, 5)
                
                Divider()
                
                if authManager.isAuthorized {
                    AuthorizedContentView(authManager: authManager)
                } else {
                    UnauthorizedView(authManager: authManager)
                }
                
                Spacer() // Push content towards top
                
                // Show Reset button only in debug builds perhaps?
#if DEBUG
                ResetButton(authManager: authManager)
                    .padding(.vertical, 10)
#endif
            }
            .navigationTitle("My Apple Music")
            // Use .sheet or .alert based on error state
            .alert(isPresented: Binding( // Two-way binding for alert presentation
                get: { authManager.showErrorAlert.0 },
                set: { newValue in if !newValue { authManager.showErrorAlert = (false, "") } } // Reset on dismiss
                                       )) {
                                           Alert(
                                            title: Text("Error"), // Or use a more specific title if stored
                                            message: Text(authManager.showErrorAlert.1),
                                            dismissButton: .default(Text("OK"))
                                           )
                                       }
            // Initial data loading or setup trigger
                                       .onAppear {
                                           // If authorized but missing key data, try to fetch it automatically
                                           if authManager.isAuthorized && authManager.userStorefront == nil {
                                               print("ContentView appeared, authorized but missing storefront. Running setup checks.")
                                               // Trigger parts of setup if needed, without full blocking UI
                                               // authManager.performFullSetup() // Or just specific checks
                                           }
                                       }
        }
        // Apply a consistent style for navigation appearance if desired
        // .navigationViewStyle(.stack) // Example style
    }
}

// MARK: - Helper Views: Authentication & Status

struct AuthStatusHeader: View {
    @ObservedObject var authManager: AppleMusicAuthManager
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Status:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(authStatusText(authManager.authorizationStatus))
                    .font(.headline)
                    .foregroundColor(authStatusColor(authManager.authorizationStatus))
            }
            Spacer()
            if authManager.isLoadingSetup {
                ProgressView()
                    .scaleEffect(0.8) // Smaller progress view
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8) // Slightly reduced vertical padding
        .background(Color(UIColor.secondarySystemBackground)) // Subtle background
    }
    
    // Helper functions remain the same
    private func authStatusText(_ status: SKCloudServiceAuthorizationStatus) -> String { /* ... */
        switch status {
        case .notDetermined: return "Not Connected"
        case .denied: return "Denied"
        case .restricted: return "Restricted"
        case .authorized: return "Connected"
        @unknown default: return "Unknown"
        }
    }
    private func authStatusColor(_ status: SKCloudServiceAuthorizationStatus) -> Color { /* ... */
        switch status {
        case .notDetermined: return .orange
        case .denied: return .red
        case .restricted: return .red
        case .authorized: return .green
        @unknown default: return .primary
        }
    }
}

struct UnauthorizedView: View {
    @ObservedObject var authManager: AppleMusicAuthManager
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer() // Push content to center
            Image(systemName: "music.note.house.fill")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            switch authManager.authorizationStatus {
            case .notDetermined:
                Text("Connect to Apple Music to access your library and recommendations.")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                ConnectButton(authManager: authManager)
                
            case .denied:
                Text("Access Denied. Please grant Media & Apple Music access in iOS Settings to continue.")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.red)
                SettingsButton() // Button to open settings
                
            case .restricted:
                Text("Access Restricted. Media & Apple Music access may be limited by Screen Time or other restrictions.")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.orange)
                SettingsButton()
                
            case .authorized:
                // Should not be visible if authorized, but handle defensively
                Text("Unexpected state: Authorized but showing unauthorized view.")
                
            @unknown default:
                Text("Unknown authorization status.")
            }
            Spacer()
        }
        .padding()
    }
}

struct ConnectButton: View {
    @ObservedObject var authManager: AppleMusicAuthManager
    
    var body: some View {
        Button {
            authManager.performFullSetup() // Trigger the setup flow
        } label: {
            Text("Connect Apple Music")
                .fontWeight(.semibold)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(Color.accentColor) // Use theme color
                .foregroundColor(.white)
                .cornerRadius(8)
        }
        .disabled(authManager.isLoadingSetup) // Disable while setup is running
    }
}

struct SettingsButton: View {
    var body: some View {
        Button("Open Settings") {
            // Open the app's settings in the Settings app
            if let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }
        .padding(.top, 5)
    }
}


// MARK: - Helper Views: Authorized Content

struct AuthorizedContentView: View {
    @ObservedObject var authManager: AppleMusicAuthManager
    
    var body: some View {
        // Use a List or ScrollView depending on content structure
        List {
            Section(header: Text("Account Details").font(.caption).foregroundColor(.secondary)) {
                CapabilitiesView(authManager: authManager)
            }
            
            Section(header: PlaylistHeaderView(authManager: authManager)) { // Pass manager for refresh
                PlaylistListView(authManager: authManager)
            }
            
            Section(header: HeavyRotationHeaderView(authManager: authManager)) {
                HeavyRotationListView(authManager: authManager)
            }
        }
        .listStyle(.grouped) // Use grouped style for sections
        .refreshable { // Pull-to-refresh for primary sections
            print("Pull to refresh triggered")
            // Refresh primary data sources
            // Use async/await if manager functions support it, otherwise handle completion blocks
            await refreshPrimaryData()
        }
    }
    
    // Example async refresh function
    private func refreshPrimaryData() async {
        // Wrap completion-based functions in async tasks if needed
        // For simplicity, just call the existing functions
        authManager.fetchUserLibraryPlaylists()
        authManager.fetchHeavyRotation()
        // Add a small delay maybe if needed for visual feedback
        // try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
    }
}

struct CapabilitiesView: View {
    @ObservedObject var authManager: AppleMusicAuthManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) { // Increased spacing slightly
            InfoRow(label: "Storefront", value: authManager.userStorefront ?? "N/A")
            InfoRow(label: "Can Play Catalog", isEnabled: authManager.canPlayCatalog)
            InfoRow(label: "Subscription Active", isEnabled: authManager.hasAppleMusicSubscription)
            HStack {
                InfoRow(label: "User Token", isEnabled: authManager.musicUserToken != nil)
                Spacer()
                Button("Refresh") { authManager.refreshMusicUserToken() }
                    .font(.caption)
                    .buttonStyle(.borderless) // Less prominent button style
                    .disabled(!authManager.isAuthorized) // Disable if not authorized
            }
        }
        .padding(.vertical, 4) // Add slight vertical padding within the row
    }
}

// Reusable Row for Capability Info
struct InfoRow: View {
    let label: String
    var value: String? = nil
    var isEnabled: Bool? = nil
    
    var body: some View {
        HStack {
            Text(label).foregroundColor(.secondary)
            Spacer()
            if let value = value {
                Text(value)
            } else if let isEnabled = isEnabled {
                Image(systemName: isEnabled ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(isEnabled ? .green : .red)
            }
        }
    }
}

// MARK: - Playlist Views

struct PlaylistHeaderView: View {
    @ObservedObject var authManager: AppleMusicAuthManager
    var body: some View {
        HStack {
            Text("Library Playlists")
            Spacer()
            if authManager.isLoadingPlaylists { ProgressView().scaleEffect(0.6) } // Inline loading
            Button { authManager.fetchUserLibraryPlaylists() } label: { Image(systemName: "arrow.clockwise") }
                .disabled(authManager.isLoadingPlaylists)
        }
    }
}

struct PlaylistListView: View {
    @ObservedObject var authManager: AppleMusicAuthManager
    
    var body: some View {
        // If loading initial data, show progress
        if authManager.isLoadingPlaylists && authManager.userLibraryPlaylists.isEmpty {
            HStack { Spacer(); ProgressView(); Spacer() }
        }
        // If error occurred on initial load
        else if let errorMsg = authManager.playlistErrorMessage, authManager.userLibraryPlaylists.isEmpty {
            Text("Error: \(errorMsg)")
                .foregroundColor(.red)
                .font(.caption) // Smaller error text in list
        }
        // If list has content (or is empty after successful load)
        else {
            if authManager.userLibraryPlaylists.isEmpty {
                Text("No playlists found in your library.")
                    .foregroundColor(.secondary)
            } else {
                // List the playlists
                ForEach(authManager.userLibraryPlaylists) { playlist in
                    NavigationLink(destination: PlaylistDetailView(playlist: playlist)) {
                        PlaylistRow(playlist: playlist)
                            .onAppear {
                                // Trigger load more when last item appears (basic pagination)
                                if playlist.id == authManager.userLibraryPlaylists.last?.id && authManager.canLoadMorePlaylists {
                                    print("Last playlist appeared, attempting to load more...")
                                    authManager.fetchUserLibraryPlaylists(loadMore: true)
                                }
                            }
                    }
                }
                // Show loading indicator at the bottom if loading more
                if authManager.isLoadingPlaylists && !authManager.userLibraryPlaylists.isEmpty {
                    HStack { Spacer(); ProgressView("Loading more..."); Spacer() }.padding(.vertical, 5)
                }
                // Show "Load More" button if available and not currently loading
                else if authManager.canLoadMorePlaylists {
                    Button("Load More Playlists") {
                        authManager.fetchUserLibraryPlaylists(loadMore: true)
                    }
                }
            }
        }
    }
}


struct PlaylistRow: View {
    let playlist: Playlist
    
    var body: some View {
        HStack(spacing: 12) {
            // Placeholder Artwork
            AsyncImage(url: URL(string: playlist.attributes?.artwork?.url ?? "")) { phase in
                if let image = phase.image {
                    image.resizable().aspectRatio(contentMode: .fill)
                } else if phase.error != nil || playlist.attributes?.artwork?.url == nil {
                    // Placeholder Icon
                    Image(systemName: "music.note.list")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(8)
                        .background(Color.gray.opacity(0.3))
                        .foregroundColor(.secondary)
                } else {
                    ProgressView().scaleEffect(0.5) // Loading indicator for image
                }
            }
            .frame(width: 45, height: 45) // Consistent size
            .cornerRadius(4)
            .clipped()
            
            
            VStack(alignment: .leading) {
                Text(playlist.attributes?.name ?? "Unknown Playlist")
                    .font(.headline)
                    .lineLimit(1)
                if let trackCount = playlist.attributes?.mockTrackCount { // Use mock count
                    Text("\(trackCount) \(trackCount == 1 ? "track" : "tracks")") // Pluralization
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else if let desc = playlist.attributes?.description?.standard {
                    Text(desc)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1) // Keep row height consistent
                }
            }
            Spacer() // Push content left
        }
        .padding(.vertical, 4) // Add padding for better spacing in the list
    }
}

// Placeholder Detail View
struct PlaylistDetailView: View {
    let playlist: Playlist
    
    // In a real app, fetch tracks here
    //@StateObject private var trackLoader = TrackLoader(playlistId: playlist.id)
    
    var body: some View {
        List {
            Section(header: Text("Playlist Info")) {
                // Display artwork prominently if available
                // ...
                Text("Name: \(playlist.attributes?.name ?? "N/A")")
                if let desc = playlist.attributes?.description?.standard {
                    Text("Description: \(desc)")
                }
                Text("ID: \(playlist.id)").font(.caption).foregroundColor(.gray)
            }
            Section(header: Text("Tracks (Placeholder)")) {
                // Placeholder for track list
                //                 ForEach(1... (playlist.attributes?.mockTrackCount ?? 5), id: \.self) { i in
                //                     Text("Track \(i) Name")
                //                 }
                // Add loading/error handling for tracks
            }
        }
        .navigationTitle(playlist.attributes?.name ?? "Playlist")
        // .onAppear {
        //     trackLoader.fetchTracks()
        // }
    }
}

// MARK: - Heavy Rotation Views (New)

struct HeavyRotationHeaderView: View {
    @ObservedObject var authManager: AppleMusicAuthManager
    var body: some View {
        HStack {
            Text("Heavy Rotation")
            Spacer()
            if authManager.isLoadingHeavyRotation { ProgressView().scaleEffect(0.6) }
            Button { authManager.fetchHeavyRotation() } label: { Image(systemName: "arrow.clockwise") }
                .disabled(authManager.isLoadingHeavyRotation)
        }
    }
}

struct HeavyRotationListView: View {
    @ObservedObject var authManager: AppleMusicAuthManager
    
    var body: some View {
        if authManager.isLoadingHeavyRotation && authManager.heavyRotationSongs.isEmpty {
            HStack { Spacer(); ProgressView(); Spacer() }
        } else if let errorMsg = authManager.heavyRotationErrorMessage, authManager.heavyRotationSongs.isEmpty {
            Text("Error: \(errorMsg)")
                .foregroundColor(.red)
                .font(.caption)
        } else if authManager.heavyRotationSongs.isEmpty {
            Text("No heavy rotation data found.")
                .foregroundColor(.secondary)
        } else {
            ForEach(authManager.heavyRotationSongs) { song in
                // Make songs navigable if desired (e.g., to an album or artist view)
                // NavigationLink(destination: SongDetailView(song: song)) { // Example
                HeavyRotationRow(song: song)
                // }
            }
        }
    }
}

struct HeavyRotationRow: View {
    let song: HeavyRotationSong
    
    var body: some View {
        HStack(spacing: 12) {
            // Placeholder Artwork
            AsyncImage(url: URL(string: song.attributes?.artwork?.url ?? "")) { phase in
                if let image = phase.image { image.resizable().aspectRatio(contentMode: .fill) }
                else {
                    Image(systemName: "music.note")
                        .resizable().aspectRatio(contentMode: .fit).padding(10)
                        .background(Color.gray.opacity(0.3)).foregroundColor(.secondary)
                }
            }
            .frame(width: 45, height: 45)
            .cornerRadius(4)
            .clipped()
            
            VStack(alignment: .leading) {
                Text(song.attributes?.name ?? "Unknown Song")
                    .font(.headline).lineLimit(1)
                Text(song.attributes?.artistName ?? "Unknown Artist")
                    .font(.subheadline).foregroundColor(.secondary).lineLimit(1)
            }
            Spacer()
        }
        .padding(.vertical, 4)
    }
}


// MARK: - Reset Button View

struct ResetButton: View {
    @ObservedObject var authManager: AppleMusicAuthManager
    
    var body: some View {
        Button("Reset State / Simulate Logout", role: .destructive) { // Use destructive role
            authManager.deauthorizeAndReset()
        }
        .buttonStyle(.bordered) // Less prominent style maybe
        .controlSize(.small)
        .padding(.horizontal)
    }
}

//
//// MARK: - Application Entry Point (for preview)
//struct AppleMusicDemoAppEnhanced: App {
//    var body: some Scene {
//        WindowGroup {
//            AppleMusicContentView()
//        }
//    }
//}
#Preview("AppleMusicContentView") {
    AppleMusicContentView()
}
