////
////  AppleMusicAPIView.swift
////  MyApp
////
////  Created by Cong Le on 4/8/25.
////
//
//import SwiftUI
//import StoreKit // For SKCloudServiceController
//import Combine  // For ObservableObject
//
//// MARK: - Constants
//struct AppleMusicConstants {
//    // Base URL for the Apple Music Web API
//    static let apiBaseURL = "https://api.music.apple.com/v1/"
//
//    // Example User-Specific Endpoints (replace with actual ones needed)
//    static let libraryPlaylistsEndpoint = "me/library/playlists"
//    static let heavyRotationEndpoint = "me/history/heavy-rotation"
//
//    // TODO: Add more endpoints as required
//}
//
//// MARK: - Apple Music API Error Enum
//enum AppleMusicError: Error, LocalizedError {
//    case authorizationFailed(SKCloudServiceAuthorizationStatus)
//    case authorizationDenied
//    case authorizationRestricted
//    case capabilitiesCheckFailed(Error?)
//    case storefrontCheckFailed(Error?)
//    case userTokenFetchFailed(Error?)
//    case userTokenUnavailable // Specifically when the token is nil after trying to fetch
//    case developerTokenMissing
//    case storefrontMissing
//    case notAuthorized // General state check before making a call
//    case networkError(Error)
//    case invalidResponse
//    case httpError(statusCode: Int, details: String?) // Include optional details from response body
//    case noData
//    case decodingError(Error?)
//    case requestCreationFailed(String)
//    case maxRetriesReached
//    case unknown(Error? = nil)
//
//    var errorDescription: String? {
//        switch self {
//        case .authorizationFailed(let status): return "Authorization failed with status: \(status.rawValue)."
//        case .authorizationDenied: return "Access to Apple Music / Media Library was denied. Please grant access in Settings."
//        case .authorizationRestricted: return "Access to Apple Music / Media Library is restricted (e.g., by parental controls)."
//        case .capabilitiesCheckFailed(let error): return "Could not check Apple Music capabilities: \(error?.localizedDescription ?? "Unknown reason")."
//        case .storefrontCheckFailed(let error): return "Could not determine Apple Music storefront: \(error?.localizedDescription ?? "Unknown reason")."
//        case .userTokenFetchFailed(let error): return "Failed to fetch Music User Token: \(error?.localizedDescription ?? "Unknown reason"). Ensure Developer Token is valid and User is authorized."
//        case .userTokenUnavailable: return "Music User Token is unavailable. Cannot perform user-specific actions."
//        case .developerTokenMissing: return "Developer Token was not provided."
//        case .storefrontMissing: return "User storefront identifier is missing."
//        case .notAuthorized: return "User has not authorized access to Apple Music / Media Library."
//        case .networkError(let error): return "Network error: \(error.localizedDescription)."
//        case .invalidResponse: return "Received an invalid response from the Apple Music API."
//        case .httpError(let statusCode, let details): return "Apple Music API Error \(statusCode): \(details ?? "No details provided")."
//        case .noData: return "No data received from the Apple Music API."
//        case .decodingError(let error): return "Failed to decode response: \(error?.localizedDescription ?? "Unknown decoding error")."
//        case .requestCreationFailed(let reason): return "Failed to create API request: \(reason)."
//        case .maxRetriesReached: return "Maximum number of retries reached for API request."
//        case .unknown(let error): return "An unknown Apple Music error occurred: \(error?.localizedDescription ?? "N/A")."
//        }
//    }
//}
//
//// MARK: - Placeholder Data Structures (Replace with Actual API Models)
//// Examples: Define structs matching the JSON structure of Apple Music API responses
//
//struct Playlist: Decodable, Identifiable {
//    let id: String
//    let type: String // e.g., "library-playlists"
//    let href: String
//    struct Attributes: Decodable {
//        let name: String
//        let description: PlaylistDescription? // Description might be optional/nested
//        let canEdit: Bool
//        // Add other attributes like artwork, playParams, isPublic, dateAdded etc.
//    }
//    let attributes: Attributes? // Attributes might be optional in some list responses
//}
//
//struct PlaylistDescription: Decodable {
//    let standard: String
//}
//
//// Generic structure for Apple Music API responses (often nested under "data")
//struct MusicDataResponse<T: Decodable>: Decodable {
//    let data: [T]
//    let next: String? // For pagination
//    // Meta information might also be present
//}
//
//// Example for a simple error body from Apple Music API
//struct AppleMusicApiErrorResponse: Decodable {
//    struct ApiError: Decodable {
//        let id: String?
//        let title: String?
//        let detail: String?
//        let status: String? // Typically string representation of HTTP status
//    }
//    let errors: [ApiError]?
//}
//
//
//// MARK: - Apple Music Authentication Manager
//class AppleMusicAuthManager: ObservableObject {
//
//    // --- Published Properties for UI Binding ---
//    @Published var authorizationStatus: SKCloudServiceAuthorizationStatus = .notDetermined
//    @Published var isAuthorized: Bool = false // Convenience bool derived from status
//    @Published var canPlayCatalog: Bool = false
//    @Published var hasAppleMusicSubscription: Bool = false // Derived from capabilities
//    @Published var userStorefront: String? = nil // e.g., "us", "gb"
//    @Published var musicUserToken: String? = nil
//
//    @Published var isLoading: Bool = false // For general auth/setup tasks
//    @Published var errorMessage: String? = nil
//
//    // --- Placeholder Data Properties (TODO: Implement fetching) ---
//    @Published var userLibraryPlaylists: [Playlist] = []
//    @Published var isLoadingPlaylists: Bool = false
//    @Published var playlistErrorMessage: String? = nil
//
//    // --- Private Properties ---
//    private let developerToken: String // MUST be provided
//    private let cloudServiceController = SKCloudServiceController()
//    private var setupCompletion: ((Bool, Error?) -> Void)?
//
//    // MARK: - Initialization
//    init(developerToken: String) {
//        guard !developerToken.isEmpty else {
//            fatalError("Developer Token cannot be empty. Please provide a valid token.")
//        }
//        self.developerToken = developerToken
//        print("AppleMusicAuthManager initialized.")
//        // Check initial status immediately, but don't request yet
//        checkInitialAuthorization()
//    }
//
//    // MARK: - Setup Flow (Combined Check & Request)
//    /// Performs the complete setup sequence: Check status, Request Auth (if needed), Check Capabilities, Fetch Storefront, Fetch User Token.
//    func performFullSetup(completion: @escaping (Bool, Error?) -> Void) {
//         guard !isLoading else {
//             print("Setup already in progress.")
//             // Potentially call completion with current state or failure?
//             completion(false, AppleMusicError.unknown(nil)) // Indicate setup didn't run now
//             return
//         }
//
//         print("Starting full Apple Music setup...")
//         self.isLoading = true
//         self.errorMessage = nil
//         self.setupCompletion = completion // Store completion handler
//
//
//         // 1. Check current authorization status
//         let currentStatus = SKCloudServiceController.authorizationStatus()
//         updateAuthorizationState(status: currentStatus)
//
//         if currentStatus == .authorized {
//             print("Already authorized. Proceeding with capability checks...")
//             checkCapabilitiesAndStorefront() // Start next steps directly
//         } else if currentStatus == .notDetermined {
//             print("Authorization not determined. Requesting access...")
//             requestAuthorization() // Request permission first
//         } else {
//             // Denied or Restricted
//             print("Authorization denied or restricted (\(currentStatus)). Setup cannot complete.")
//             let error = (currentStatus == .denied) ? AppleMusicError.authorizationDenied : AppleMusicError.authorizationRestricted
//             finishSetup(success: false, error: error)
//         }
//     }
//
//
//    // MARK: - Core Authorization & Checks
//
//    /// Checks the current authorization status without requesting.
//    private func checkInitialAuthorization() {
//        let status = SKCloudServiceController.authorizationStatus()
//        print("Initial Apple Music Authorization Status: \(status.rawValue)")
//        updateAuthorizationState(status: status)
//    }
//
//    /// Requests user authorization for Apple Music / Media Library access.
//     func requestAuthorization() {
//         guard !isLoading || setupCompletion == nil else { // Allow request even if loading if it's part of setup
//             print("Authorization request blocked: Already loading or not part of setup flow.")
//             return
//         }
//         // If not part of initial setup, manage loading state here
//          if setupCompletion == nil {
//             self.isLoading = true
//             self.errorMessage = nil
//         }
//
//         SKCloudServiceController.requestAuthorization { [weak self] status in
//             DispatchQueue.main.async { // Ensure UI updates are on main thread
//                 print("Authorization request completed with status: \(status.rawValue)")
//                 self?.updateAuthorizationState(status: status)
//
//                 if status == .authorized {
//                     // If authorized, proceed to fetch capabilities and storefront
//                     self?.checkCapabilitiesAndStorefront()
//                 } else {
//                     // Failed (Denied or Restricted)
//                      let error = (status == .denied) ? AppleMusicError.authorizationDenied : AppleMusicError.authorizationRestricted
//                      // If part of full setup, use the stored completion
//                      if self?.setupCompletion != nil {
//                           self?.finishSetup(success: false, error: error)
//                      } else {
//                         // If called standalone, update local state
//                         self?.isLoading = false
//                          self?.errorMessage = error.localizedDescription
//                      }
//                 }
//             }
//         }
//     }
//
//    /// Checks capabilities and then fetches the storefront. Called after authorization is confirmed.
//    private func checkCapabilitiesAndStorefront() {
//         print("Checking Apple Music capabilities...")
//         cloudServiceController.requestCapabilities { [weak self] capabilities, error in
//              DispatchQueue.main.async {
//                  guard let self = self else { return }
//
//                  if let error = error {
//                       print("Capability check failed: \(error.localizedDescription)")
//                       let checkError = AppleMusicError.capabilitiesCheckFailed(error)
//                       // If part of setup, fail the whole setup
//                       if self.setupCompletion != nil {
//                           self.finishSetup(success: false, error: checkError)
//                       } else {
//                            // If called standalone
//                            self.errorMessage = checkError.localizedDescription
//                            self.isLoading = false // May need separate loading state?
//                       }
//                       return
//                  }
//
//                  self.canPlayCatalog = capabilities.contains(.musicCatalogPlayback)
//                  // Common heuristic: Add-to-library or subscription-eligible implies subscription
//                  self.hasAppleMusicSubscription = capabilities.contains(.addToCloudMusicLibrary) || capabilities.contains(.musicCatalogSubscriptionEligible)
//
//                  print("Capabilities received: CanPlayCatalog=\(self.canPlayCatalog), HasSubscription=\(self.hasAppleMusicSubscription)")
//
//                  // Proceed to fetch storefront *after* capabilities check succeeds
//                   self.fetchStorefront()
//              }
//         }
//    }
//
//     /// Fetches the user's storefront identifier. Called after capabilities check.
//     private func fetchStorefront() {
//          print("Fetching user storefront...")
//          cloudServiceController.requestStorefrontIdentifier { [weak self] storefrontId, error in
//               DispatchQueue.main.async {
//                   guard let self = self else { return }
//
//                   if let error = error {
//                       print("Storefront check failed: \(error.localizedDescription)")
//                       let checkError = AppleMusicError.storefrontCheckFailed(error)
//                       if self.setupCompletion != nil {
//                            self.finishSetup(success: false, error: checkError)
//                       } else {
//                            self.errorMessage = checkError.localizedDescription
//                            self.isLoading = false
//                       }
//                       return
//                   }
//
//                   self.userStorefront = storefrontId
//                   print("Storefront identifier received: \(storefrontId ?? "nil")")
//
//                    // Proceed to fetch User Token *after* storefront succeeds
//                    self.fetchMusicUserToken()
//               }
//          }
//     }
//
//    /// Fetches the Music User Token required for user-specific API calls.
//     func fetchMusicUserToken() {
//          guard self.authorizationStatus == .authorized else {
//               print("Cannot fetch user token: Not authorized.")
//               let error = AppleMusicError.notAuthorized
//                if self.setupCompletion != nil {
//                    self.finishSetup(success: false, error: error)
//                } else {
//                     self.errorMessage = error.localizedDescription
//                     self.isLoading = false
//                }
//               return
//          }
//          guard !self.developerToken.isEmpty else {
//               print("Cannot fetch user token: Developer Token is missing.")
//               let error = AppleMusicError.developerTokenMissing
//                if self.setupCompletion != nil {
//                   self.finishSetup(success: false, error: error)
//                } else {
//                   self.errorMessage = error.localizedDescription
//                   self.isLoading = false
//                }
//               return
//          }
//
//          print("Fetching Music User Token...")
//          // This method requires the Developer Token you obtained from Apple
//          cloudServiceController.requestUserToken(forDeveloperToken: developerToken) { [weak self] userToken, error in
//               DispatchQueue.main.async {
//                   guard let self = self else { return }
//
//                   if let error = error {
//                       print("Music User Token fetch failed: \(error.localizedDescription)")
//                        // Distinguish specific errors if possible (e.g., token unavailable vs network error)
//                       let fetchError = AppleMusicError.userTokenFetchFailed(error)
//                       self.musicUserToken = nil // Ensure token is nil on error
//                       if self.setupCompletion != nil {
//                           self.finishSetup(success: false, error: fetchError)
//                       } else {
//                           self.errorMessage = fetchError.localizedDescription
//                            // If called standalone, manage loading state
//                            self.isLoading = false
//                       }
//                       return
//                   }
//
//                   self.musicUserToken = userToken
//                   print("Music User Token received: \(userToken != nil ? "Present" : "nil")")
//
//                   if userToken == nil {
//                        // Handle case where token fetch didn't error, but token is still nil
//                        let fetchError = AppleMusicError.userTokenUnavailable
//                        if self.setupCompletion != nil {
//                           self.finishSetup(success: false, error: fetchError)
//                        } else {
//                            self.errorMessage = fetchError.localizedDescription
//                            self.isLoading = false
//                        }
//                   } else {
//                       // SUCCESS! All setup steps completed.
//                        if self.setupCompletion != nil {
//                           self.finishSetup(success: true, error: nil)
//                        } else {
//                           // If called standalone
//                           self.isLoading = false
//                           self.errorMessage = nil
//                        }
//                   }
//               }
//          }
//     }
//
//    // Helper to finish the setup flow and call completion handler
//     private func finishSetup(success: Bool, error: Error?) {
//          print("Finishing setup. Success: \(success), Error: \(error?.localizedDescription ?? "None")")
//          self.isLoading = false // Stop loading indicator
//          if let error = error {
//              self.errorMessage = error.localizedDescription // Set final error message
//          } else {
//              self.errorMessage = nil // Clear error on success
//          }
//          self.setupCompletion?(success, error)
//          self.setupCompletion = nil // Clear completion handler after calling
//      }
//
//
//     // Helper to update authorization state consistently
//     private func updateAuthorizationState(status: SKCloudServiceAuthorizationStatus) {
//         DispatchQueue.main.async { // Ensure updates happen on the main thread
//             self.authorizationStatus = status
//             self.isAuthorized = (status == .authorized)
//             if status != .authorized {
//                 // Clear user-specific data if authorization is lost or never granted
//                 self.resetUserSpecificState(clearAuthStatus: false) // Keep the current non-authorized status
//             }
//              print("Auth state updated: Status \(status.rawValue), isAuthorized \(self.isAuthorized)")
//         }
//     }
//
//
//    // MARK: - API Request Function (Adapted for Apple Music)
//
//    /// Makes a generic request to the Apple Music API.
//     func makeAPIRequest<T: Decodable>(
//        endpoint: String, // Relative path, e.g., "me/library/playlists"
//        method: String = "GET",
//        queryParameters: [String: String] = [:], // Additional query params
//        body: Data? = nil, // For POST/PUT requests
//        responseType: T.Type,
//        currentAttempt: Int = 1,
//        maxAttempts: Int = 2, // Allow one retry after fetching user token
//        requiresUserToken: Bool = true, // Does this endpoint need the Music-User-Token header?
//        completion: @escaping (Result<T, Error>) -> Void
//    ) {
//         // 1. Pre-flight checks
//         guard !developerToken.isEmpty else {
//             completion(.failure(AppleMusicError.developerTokenMissing)); return
//         }
//         guard isAuthorized || !requiresUserToken else {
//             // Allow non-user requests even if not authorized locally,
//             // but fail user requests if local state is not authorized.
//             completion(.failure(AppleMusicError.notAuthorized)); return
//         }
//         guard let storefront = userStorefront, !storefront.isEmpty else {
//              // Most requests need storefront, fail if missing
//              completion(.failure(AppleMusicError.storefrontMissing)); return
//         }
//          guard let userToken = musicUserToken, requiresUserToken else {
//              if requiresUserToken {
//                  // Attempt to fetch user token if it's missing and required
//                   print("User token missing for required endpoint '\(endpoint)', attempting fetch...")
//                   fetchMusicUserToken() // Fetch the token
//                   // How to retry after fetch? This requires more complex async handling or Combine chains.
//                   // For simplicity here, we fail immediately. A more robust solution would re-call makeAPIRequest after fetch.
//                   completion(.failure(AppleMusicError.userTokenUnavailable))
//                   return
//              } else {
//                  // Proceed without user token if not required
//                   print("Making API request to '\(endpoint)' without user token.")
//                  return
//              }
//
//         }
//
//         guard currentAttempt <= maxAttempts else {
//             completion(.failure(AppleMusicError.maxRetriesReached)); return
//         }
//
//          // 2. Construct URL
//          guard let baseURL = URL(string: AppleMusicConstants.apiBaseURL) else {
//               completion(.failure(AppleMusicError.requestCreationFailed("Invalid base URL"))); return
//          }
//          let fullURLWithPath = baseURL.appendingPathComponent(endpoint)
//          var components = URLComponents(url: fullURLWithPath, resolvingAgainstBaseURL: false)
//
//           // Add storefront and any custom query parameters
//           var allQueryItems = [URLQueryItem(name: "l", value: storefront)] // Add required storefront param
//           allQueryItems.append(contentsOf: queryParameters.map { URLQueryItem(name: $0.key, value: $0.value) })
//           components?.queryItems = allQueryItems.isEmpty ? nil : allQueryItems
//
//
//          guard let finalURL = components?.url else {
//              completion(.failure(AppleMusicError.requestCreationFailed("Could not construct final URL"))); return
//          }
//
//         // 3. Create Request
//         var request = URLRequest(url: finalURL)
//         request.httpMethod = method.uppercased()
//         request.setValue("Bearer \(developerToken)", forHTTPHeaderField: "Authorization")
//
//         // Add user token header if required and available
//          if requiresUserToken, let token = musicUserToken {
//             request.setValue(token, forHTTPHeaderField: "Music-User-Token")
//         }
//
//         // Add body if present
//         if let bodyData = body, ["POST", "PUT", "PATCH"].contains(request.httpMethod ?? "") {
//             request.httpBody = bodyData
//             // Assume JSON, set content type. Adjust if needed.
//             request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//         }
//
//         print("Making API Request [\(method)] to \(finalURL)")
//
//         // 4. Perform Data Task
//         URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
//             guard let self = self else { return }
//
//             // 5. Handle Network Error
//             if let networkError = error {
//                 print("Network error for \(finalURL): \(networkError.localizedDescription)")
//                 completion(.failure(AppleMusicError.networkError(networkError)))
//                 return
//             }
//
//             // 6. Validate Response
//             guard let httpResponse = response as? HTTPURLResponse else {
//                 print("Invalid response type for \(finalURL)")
//                 completion(.failure(AppleMusicError.invalidResponse))
//                 return
//             }
//
//             // 7. Handle HTTP Errors (Including potential token errors 401/403)
//             guard (200...299).contains(httpResponse.statusCode) else {
//                 let errorDetails = self.extractErrorDetails(from: data)
//                 print("HTTP Error \(httpResponse.statusCode) for \(finalURL): \(errorDetails ?? "No details")")
//
//                 // Check if it's an auth error (401/403) AND requires user token
//                 // This might indicate the user token needs refreshing.
//                 if (httpResponse.statusCode == 401 || httpResponse.statusCode == 403) && requiresUserToken {
//                     print("Received \(httpResponse.statusCode). Potential User Token issue. Attempting token refresh and retry...")
//                     // Attempt to fetch a new user token
//                     self.fetchMusicUserToken() { success, fetchError in // Modify fetchMusicUserToken to have optional completion
//                          if success {
//                              print("User token fetched successfully after \(httpResponse.statusCode). Retrying API request...")
//                              // Retry the original request
//                              self.makeAPIRequest(
//                                   endpoint: endpoint,
//                                   method: method,
//                                  queryParameters: queryParameters,
//                                  body: body,
//                                  responseType: responseType,
//                                  currentAttempt: currentAttempt + 1, // Increment attempt
//                                  maxAttempts: maxAttempts,
//                                  requiresUserToken: requiresUserToken,
//                                  completion: completion
//                              )
//                          } else {
//                              print("Failed to fetch user token after \(httpResponse.statusCode). Aborting retry.")
//                               // Fail with the original HTTP error or the token fetch error
//                               completion(.failure(AppleMusicError.httpError(statusCode: httpResponse.statusCode, details: errorDetails ?? "Token refresh also failed.")))
//                          }
//                     }
//                     return // Exit this path to allow token fetch and retry
//                 } else {
//                     // Other HTTP error, fail immediately
//                     completion(.failure(AppleMusicError.httpError(statusCode: httpResponse.statusCode, details: errorDetails)))
//                 }
//                 return
//             }
//
//             // 8. Handle No Data
//             guard let responseData = data else {
//                  // Check if 204 No Content is expected/valid for this request type?
//                  if httpResponse.statusCode == 204 {
//                       // If T is an Optional or a specific "EmptyOK" type, handle success?
//                       // For simplicity, assume data is required unless status is 204 and T allows nil/empty.
//                       // Let's treat missing data as an error for now unless T specifically handles it.
//                       print("No data received for \(finalURL), status \(httpResponse.statusCode).")
//                       completion(.failure(AppleMusicError.noData))
//                  } else {
//                         print("No data received for \(finalURL), status \(httpResponse.statusCode).")
//                          completion(.failure(AppleMusicError.noData))
//                  }
//
//                 return
//             }
//              // Handle explicit 204 No Content success? Depends on responseType T.
//              // If T handled optionality or an Empty type, we could succeed here.
//
//
//             // 9. Decode Response
//             do {
//                 #if DEBUG
//                 // Print raw response in debug builds for inspection
//                  if let jsonString = String(data: responseData, encoding: .utf8) {
//                       print("Raw JSON response for \(endpoint):\n\(jsonString)")
//                   }
//                 #endif
//
//                 let decoder = JSONDecoder()
//                  // Configure decoder if needed (e.g., date strategies)
//                  // decoder.dateDecodingStrategy = .iso8601
//                 let decodedObject = try decoder.decode(T.self, from: responseData)
//                 completion(.success(decodedObject))
//             } catch let decodingError {
//                 print("Decoding error for \(T.self) from \(finalURL): \(decodingError)")
//                  if let jsonString = String(data: responseData, encoding: .utf8) {
//                     print("Failed JSON: \(jsonString)")
//                  }
//                 completion(.failure(AppleMusicError.decodingError(decodingError)))
//             }
//
//         }.resume()
//    }
//
//
//    // MARK: - Placeholder Data Fetching Example (TODO: Implement)
//
//    func fetchUserLibraryPlaylists() {
//        guard !isLoadingPlaylists else { return }
//
//        isLoadingPlaylists = true
//        playlistErrorMessage = nil
//
//        // Example usage of makeAPIRequest
//        makeAPIRequest(
//            endpoint: AppleMusicConstants.libraryPlaylistsEndpoint,
//            method: "GET",
//            queryParameters: ["limit": "100"], // Example parameter
//            responseType: MusicDataResponse<Playlist>.self,
//            requiresUserToken: true
//        ) { [weak self] result in
//             DispatchQueue.main.async {
//                 self?.isLoadingPlaylists = false
//                 switch result {
//                 case .success(let response):
//                     self?.userLibraryPlaylists = response.data
//                     self?.playlistErrorMessage = nil
//                      print("Successfully fetched \(response.data.count) library playlists.")
//                     // Handle pagination with response.next if needed
//                 case .failure(let error):
//                     self?.userLibraryPlaylists = []
//                     self?.playlistErrorMessage = "Failed to load library playlists: \(error.localizedDescription)"
//                     print("Error fetching library playlists: \(error)")
//                 }
//            }
//        }
//    }
//
//    // MARK: - State Management
//
//    /// Resets user-specific state, optionally keeping the known authorization status.
//     func resetUserSpecificState(clearAuthStatus: Bool = true) {
//         print("Resetting user-specific state...")
//         DispatchQueue.main.async {
//             if clearAuthStatus {
//                 self.authorizationStatus = .notDetermined
//                 self.isAuthorized = false
//             }
//             self.canPlayCatalog = false
//             self.hasAppleMusicSubscription = false
//             self.userStorefront = nil
//             self.musicUserToken = nil
//             self.errorMessage = nil // Clear general errors
//
//             // Clear fetched data
//             self.userLibraryPlaylists = []
//             self.isLoadingPlaylists = false
//             self.playlistErrorMessage = nil
//
//             // Reset loading states?
//             self.isLoading = false
//         }
//     }
//
//    /// Call this to simulate a full logout or deauthorization.
//    func deauthorizeAndReset() {
//        print("Deauthorizing and resetting all state.")
//         // There's no API to force deauthorization. We just clear local state.
//         resetUserSpecificState(clearAuthStatus: true)
//        // NOTE: This does NOT revoke the user's permission in iOS Settings.
//        // If the user launches again, status will likely be '.authorized',
//        // and the setup flow would run again.
//    }
//
//
//    // MARK: - Error Handling Helpers
//
//    private func extractErrorDetails(from data: Data?) -> String? {
//        guard let data = data, !data.isEmpty else { return nil }
//        // Try decoding Apple Music's standard error format
//        if let errorResponse = try? JSONDecoder().decode(AppleMusicApiErrorResponse.self, from: data),
//           let firstError = errorResponse.errors?.first {
//            return firstError.detail ?? firstError.title ?? "Unknown API Error Detail"
//        }
//        // Fallback to plain text
//        return String(data: data, encoding: .utf8)
//    }
//
//     // Modify fetchMusicUserToken to accept completion for retry logic
//     private func fetchMusicUserToken(completion: ((Bool, Error?) -> Void)? = nil) {
//         guard self.authorizationStatus == .authorized else {
//              let error = AppleMusicError.notAuthorized; print(error.localizedDescription); completion?(false, error); return
//         }
//         guard !self.developerToken.isEmpty else {
//              let error = AppleMusicError.developerTokenMissing; print(error.localizedDescription); completion?(false, error); return
//         }
//
//         print("Fetching Music User Token (with completion)...")
//         cloudServiceController.requestUserToken(forDeveloperToken: developerToken) { [weak self] userToken, error in
//              DispatchQueue.main.async {
//                  guard let self = self else { completion?(false, AppleMusicError.unknown()); return }
//
//                  if let error = error {
//                       print("Music User Token fetch failed: \(error.localizedDescription)")
//                       let fetchError = AppleMusicError.userTokenFetchFailed(error)
//                       self.musicUserToken = nil
//                       completion?(false, fetchError) // Report failure
//                       return
//                  }
//
//                  self.musicUserToken = userToken
//                   print("Music User Token received: \(userToken != nil ? "Present" : "nil")")
//
//                  if userToken == nil {
//                        let fetchError = AppleMusicError.userTokenUnavailable
//                        completion?(false, fetchError) // Report failure (token is nil)
//                   } else {
//                        completion?(true, nil) // Report success
//                   }
//              }
//         }
//     }
//}
