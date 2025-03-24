//
//  ConnecticutAvenueSecuritiesView.swift
//  MyApp
//
//  Created by Cong Le on 3/23/25.
//

//ConnecticutAvenueSecuritiesView
import SwiftUI
import Combine

// MARK: - Data Models

/// Represents the response from the Connecticut Avenue Securities API.
struct CasResponse: Decodable, Identifiable {
    // Using UUID as a unique identifier. Consider if the API provides a better, more stable ID.
    let id = UUID()
    let currentState: String
    let s3Uri: String
    let requestId: String
    let stateEntryTimestamp: String
    
    // CodingKeys to map the JSON keys to our Swift property names, handling the hyphenated names.
    enum CodingKeys: String, CodingKey {
        case currentState
        case s3Uri
        case requestId = "request-id"
        case stateEntryTimestamp = "state-entry-timestamp"
    }
}

// MARK: - API Endpoints

/// Enumeration for API endpoints, making it easy to manage and update URLs.
enum ConnecticutAvenueSecuritiesAPIEndpoint {
    case currentReportingPeriod
    case programToDate
    
    var path: String {
        switch self {
        case .currentReportingPeriod:
            return "/v1/connecticut-ave-securities/current-reporting-period"
        case .programToDate:
            return "/v1/connecticut-ave-securities/program-to-date"
        }
    }
}

// MARK: - API Errors

/// API error definition for common network/decoding failures, including localized descriptions.
enum ConnecticutAvenueSecuritiesAPIError: Error, LocalizedError {
    case invalidURL  // URL creation failed.
    case requestFailed(String) // The request failed, with a detailed message.
    case decodingFailed // Response JSON decoding failed.
    case noData // No data was returned.
    case authenticationFailed // Authentication failed.
    case unknown(Error) // An unknown error occurred.
    
    // Provides a user-friendly description of the error.
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL."
        case .requestFailed(let message):
            return "API request failed: \(message)"
        case .decodingFailed:
            return "Failed to decode the response."
        case .noData:
            return "No data was returned."
        case .authenticationFailed:
            return "Authentication failed or token refresh failed. Please check your credentials."
        case .unknown(let error):
            return "An unknown error occurred: \(error.localizedDescription)"
        }
    }
}

// MARK: - Authentication
// IMPORTANT:  This is placeholder code.  In a production app, never hardcode secrets. Use secure storage like the Keychain.
struct ConnecticutAvenueSecuritiesAPIAuthCredentials {
    static let clientID = "your_client_id" // Placeholder
    static let clientSecret = "your_client_secret" // Placeholder
}

/// Decodes the token response from the authentication API.
struct ConnecticutAvenueSecurities_TokenResponse: Decodable {
    let access_token: String
    let token_type: String
    let expires_in: Int
    let scope: String
}

// MARK: - Data Service

/// Service responsible for fetching and decoding CAS data, using Combine for reactive updates.
final class ConnecticutAvenueSecuritiesService: ObservableObject {
    @Published var casData: [CasResponse] = []     // Holds the fetched CAS data.
    @Published var isLoading = false           // Indicates data loading state.
    @Published var errorMessage: String?       // Stores error messages for display.
    
    private let baseURLString = "https://api.fanniemae.com" // Base URL for the API.
    private let tokenURL = "https://auth.pingone.com/4c2b23f9-52b1-4f8f-aa1f-1d477590770c/as/token" // Hardcoded URL for the authentication.
    private var accessToken: String?           // Stores the current access token.
    private var tokenExpiration: Date?      // Tracks token expiration.
    private var cancellables = Set<AnyCancellable>() // Holds Combine subscriptions for automatic cleanup.
    
    // MARK: - Token Management
    
    /// Fetches or refreshes the access token.
    private func getAccessToken(completion: @escaping (Result<String, ConnecticutAvenueSecuritiesAPIError>) -> Void) {
        // Return token if still valid.
        if let token = accessToken, let expiration = tokenExpiration, Date() < expiration {
            completion(.success(token))
            return
        }
        
        guard let url = URL(string: tokenURL) else {
            completion(.failure(.invalidURL))
            return
        }
        
        let credentials = "\(ConnecticutAvenueSecuritiesAPIAuthCredentials.clientID):\(ConnecticutAvenueSecuritiesAPIAuthCredentials.clientSecret)" // Format credentials
        guard let base64Credentials = credentials.data(using: .utf8)?.base64EncodedString() else {
            completion(.failure(.authenticationFailed))
            return
        }
        // Setup request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = "grant_type=client_credentials".data(using: .utf8) // Set request body
        
        // Perform the token request.
        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                // Ensure the response is valid and within the 200 status range.
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    let responseString = String(data: data, encoding: .utf8) ?? ""
                    // Throw a requestFailed error with details.
                    throw ConnecticutAvenueSecuritiesAPIError.requestFailed("Invalid response.  Reason: \(responseString)")
                }
                return data // Return data if successful.
            }
            .decode(type: ConnecticutAvenueSecurities_TokenResponse.self, decoder: JSONDecoder()) // Decode the token response
            .receive(on: DispatchQueue.main)  // Switch to the main thread for UI updates.
            .sink { [weak self] completionResult in
                switch completionResult {
                case .finished:
                    break
                case .failure(let error):
                    // Convert any error to a CasAPIError, or use .unknown if not already a CasAPIError.
                    let apiError = (error as? ConnecticutAvenueSecuritiesAPIError) ?? ConnecticutAvenueSecuritiesAPIError.unknown(error)
                    self?.handleError(apiError) // Handle the error.
                    completion(.failure(apiError))  // Complete with failure.
                }
            } receiveValue: { [weak self] tokenResponse in
                // Store the token and calculate its expiration date.
                self?.accessToken = tokenResponse.access_token
                self?.tokenExpiration = Date().addingTimeInterval(TimeInterval(tokenResponse.expires_in))
                completion(.success(tokenResponse.access_token))  // Complete successfully with the token.
            }
            .store(in: &cancellables) // Store the subscription to manage its lifecycle.
    }
    
    // MARK: - Public API Data Fetching
    
    /// Fetches data from the specified CAS API endpoint.
    func fetchData(for endpoint: ConnecticutAvenueSecuritiesAPIEndpoint) {
        isLoading = true     // Indicate loading is in progress.
        errorMessage = nil  // Clear any previous error messages.
        
        // Get an access token before proceeding.
        getAccessToken { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let token):
                // If token retrieval is successful, make the data request.
                self.makeDataRequest(endpoint: endpoint, accessToken: token)
            case .failure(let error):
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.handleError(error)  // Handle the token retrieval error.
                }
            }
        }
    }
    
    /// Makes the actual data request to the API.
    private func makeDataRequest(endpoint: ConnecticutAvenueSecuritiesAPIEndpoint, accessToken: String) {
        // Construct the full URL using the base URL and the endpoint's path.
        guard let url = URL(string: baseURLString + endpoint.path) else {
            handleError(.invalidURL) // Handle URL creation failure.
            return
        }
        
        // Setup request with proper headers.
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type") // Request should respond with JSON content.
        request.addValue(accessToken, forHTTPHeaderField: "x-public-access-token") // Use Custom Header for access token.
        
        // Perform the data request using a URLSession data task publisher
        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                // Ensure the response is an HTTP response and the status code is in the 200 range.
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    let responseString = String(data: data, encoding: .utf8) ?? "No Response Body" // Descriptive String of error
                    // Throw a requestFailed error with details.
                    throw ConnecticutAvenueSecuritiesAPIError.requestFailed("HTTP Status Code error. Reason: \(responseString)")
                }
                return data // Return data for further processing.
            }
            .decode(type: CasResponse.self, decoder: JSONDecoder()) // Decode the JSON response into CasResponse.
            .receive(on: DispatchQueue.main)  // Switch to the main thread for UI updates.
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false // Update loading state.
                switch completion {
                case .finished:
                    break // Do nothing on successful finish.
                case .failure(let error):
                    // Convert any error to a CasAPIError, or use .unknown if not already one.
                    let apiError = (error as? ConnecticutAvenueSecuritiesAPIError) ?? ConnecticutAvenueSecuritiesAPIError.unknown(error)
                    self.handleError(apiError)  // Handle the error.
                }
            }, receiveValue: { [weak self] casResponse in
                guard let self = self else { return }
                // Assign the received data to the casData array and remove duplicates.
                var newData = self.casData
                newData.append(casResponse)
                
                // Remove duplicates based on 'requestId', assuming 'requestId' is unique
                let uniqueData = newData.reduce(into: [String: CasResponse]()) { result, response in
                    result[response.requestId] = response
                }.map { $0.value }
                
                self.casData = uniqueData
            })
            .store(in: &cancellables)  // Store the subscription to manage its lifecycle.
    }
    
    // MARK: - Error Handling
    
    // Centralized error handling method
    private func handleError(_ error: ConnecticutAvenueSecuritiesAPIError) {
        errorMessage = error.localizedDescription // Update error message for UI.
        print("CAS API Error: \(error.localizedDescription)") // Log the error.
    }
    // Method to clear all stored data, useful for resetting state or on logout.
    func clearLocalData() {
        casData.removeAll()
    }
}

// MARK: - SwiftUI Views

// Main ContentView to display data and controls.
struct ConnecticutAvenueSecuritiesView_ContentView: View {
    @StateObject private var dataService = ConnecticutAvenueSecuritiesService() // Observe the data service.
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Data Selection")) {
                    // Buttons with consistent styling to fetch data from different endpoints.
                    Button("Fetch Current Reporting Period Data") {
                        dataService.fetchData(for: .currentReportingPeriod)
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Fetch Program to Date Data") {
                        dataService.fetchData(for: .programToDate)
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("Clear Data", role: .destructive) {
                        dataService.clearLocalData()
                    }
                }
                
                Section(header: Text("Connecticut Avenue Securities Data")) {
                    // Display a loading indicator while fetching data.
                    if dataService.isLoading {
                        ProgressView("Loading...")
                    } else if let errorMessage = dataService.errorMessage {
                        // Display error messages, if any.
                        Text("Error: \(errorMessage)")
                            .foregroundColor(.red)
                    } else {
                        // List the fetched data.
                        List(dataService.casData) { item in
                            VStack(alignment: .leading, spacing: 4) {
                                Text("State: \(item.currentState)")
                                Text("S3 URI: \(item.s3Uri)")
                                    .font(.caption)
                                Text("Request ID: \(item.requestId)")
                                    .font(.caption)
                                Text("Timestamp: \(item.stateEntryTimestamp)")
                                    .font(.caption)
                            }
                        }
                    }
                }
            }
            .navigationTitle("CAS Data") // Set the navigation title.
        }
    }
}

// MARK: - Preview
// Provides a preview of ContentView in Xcode's canvas.
struct ConnecticutAvenueSecuritiesContentView_Previews: PreviewProvider {
    static var previews: some View {
        ConnecticutAvenueSecuritiesView_ContentView()
    }
}
