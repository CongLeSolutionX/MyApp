//
//  NationalHousingSurveyView.swift
//  MyApp
//
//  Created by Cong Le on 3/24/25.
//
//  Updated with Debug Logging and Cache Clarification
//

import SwiftUI
import Combine

// MARK: - Internal Application Data Models
// ... (SurveyData, HpsiDataModel, Question, Response - No changes) ...
/// Unified data model for National Housing Survey results, used within the app's UI and logic.
/// Maps from the API's `NhsResults` structure.
struct SurveyData: Identifiable {
    let id = UUID()
    let date: String
    let questions: [Question]

    struct Question: Identifiable {
        let id: String // Corresponds to NhsQuestion.id
        let description: String
        let responses: [Response]

        struct Response: Identifiable {
            let id = UUID()
            let description: String // Corresponds to NhsResponse.description
            let percent: Double
        }
    }

    // Initializer to map from the API response model
    init(from nhsResult: NhsResults) {
        self.date = nhsResult.date
        self.questions = nhsResult.questions.map { question in
            Question(id: question.id,
                     description: question.description,
                     responses: question.responses.map { response in
                         // Create the internal Response model
                         Question.Response(description: response.description, percent: response.percent)
                     })
        }
    }
}

/// Unified data model for HPSI data, used within the app's UI and logic.
/// Maps from the API's `HpsiData` structure.
struct HpsiDataModel: Identifiable {
    let id = UUID()
    let hpsiValue: Double
    let date: String

    // Initializer to map from the API response model
    init(from hpsiData: HpsiData) {
        self.hpsiValue = hpsiData.hpsiValue
        self.date = hpsiData.date
    }
}


// MARK: - API Response Decodable Models (Matching JSON structure)
// ... (NhsResults, NhsQuestion, NhsResponse, HpsiData - No changes) ...
/// Decodable struct matching the `NhsResults` schema in the API response.
struct NhsResults: Decodable {
    let date: String
    let questions: [NhsQuestion]
}

/// Decodable struct matching the `NhsQuestion` schema in the API response.
struct NhsQuestion: Decodable {
    let id: String // Consider making this an enum if the values are strictly fixed
    let description: String
    let responses: [NhsResponse]
}

/// Decodable struct matching the `NhsResponse` schema in the API response.
struct NhsResponse: Decodable {
    let description: String
    let percent: Double
}

/// Decodable struct matching the `HpsiData` schema in the API response.
struct HpsiData: Decodable {
    let hpsiValue: Double
    let date: String
}


// MARK: - API Endpoints
// ... (NationalHousingSurveyViewAPIEndpoint enum - No changes) ...
/// Enumeration defining the available API endpoints for type safety.
enum NationalHousingSurveyViewAPIEndpoint {
    case nhsResults
    case hpsiData
    case hpsiDataByAreaType(areaType: String)
    case hpsiDataByOwnershipStatus(ownershipStatus: String)
    case hpsiDataByHousingCostRatio(housingCostRatio: String)
    case hpsiDataByAgeGroup(ageGroup: String)
    case hpsiDataByCensusRegion(censusRegion: String)
    case hpsiDataByIncomeGroup(incomeGroup: String)
    case hpsiDataByEducation(educationLevel: String)

    /// Computed property to get the relative path for the endpoint.
    var path: String {
        switch self {
        case .nhsResults:
            return "/v1/nhs/results"
        case .hpsiData:
            return "/v1/nhs/hpsi"
        case .hpsiDataByAreaType(let areaType):
            // Basic validation/sanitization could be added here if needed
            return "/v1/nhs/hpsi/area-type/\(areaType)"
        case .hpsiDataByOwnershipStatus(let ownershipStatus):
            return "/v1/nhs/hpsi/ownership-status/\(ownershipStatus)"
        case .hpsiDataByHousingCostRatio(let housingCostRatio):
            return "/v1/nhs/hpsi/housing-cost-ratio/\(housingCostRatio)"
        case .hpsiDataByAgeGroup(let ageGroup):
            return "/v1/nhs/hpsi/age-groups/\(ageGroup)"
        case .hpsiDataByCensusRegion(let censusRegion):
            return "/v1/nhs/hpsi/census-region/\(censusRegion)"
        case .hpsiDataByIncomeGroup(let incomeGroup):
            return "/v1/nhs/hpsi/income-groups/\(incomeGroup)"
        case .hpsiDataByEducation(let educationLevel):
            return "/v1/nhs/hpsi/education/\(educationLevel)"
        }
    }
}


// MARK: - API Errors
// ... (NationalHousingSurveyViewAPIError enum - No changes) ...
/// Custom error enum for handling specific API and network related errors.
enum NationalHousingSurveyViewAPIError: Error, LocalizedError {
    case invalidURL
    case requestFailed(String) // Includes underlying reason/status code
    case decodingFailed
    case noData // Specifically for 404 or empty success responses
    case authenticationFailed // Specifically for 401 or token fetch issues
    case forbidden // Specifically for 403
    case invalidParameter(String) // Specifically for 400
    case unknown(Error) // Wraps any other system or unexpected error

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API endpoint URL."
        case .requestFailed(let message):
            return "API request failed: \(message)"
        case .decodingFailed:
            return "Failed to decode the server response."
        case .noData:
            return "No data was found for the request (404)."
        case .authenticationFailed:
            return "Authentication failed (401). Check credentials or token."
        case .forbidden:
            return "Access denied (403)."
        case .invalidParameter(let parameter):
            return "Invalid request parameter: \(parameter) (400)."
        case .unknown(let error):
            return "An unexpected error occurred: \(error.localizedDescription)"
        }
    }
}


// MARK: - Authentication
// ... (NationalHousingSurvey_AuthCredentials, NationalHousingSurveyTokenResponse - No changes) ...
/// Placeholder for securely storing client credentials.
struct NationalHousingSurvey_AuthCredentials {
    // !!! WARNING: Storing credentials directly in code is highly insecure! !!!
    // Replace these placeholders with values securely retrieved from the Keychain
    // or a secure configuration management system. Never commit secrets to Git.
   static let clientID = "YOUR_CLIENT_ID_HERE" // Replace with secure retrieval
   static let clientSecret = "YOUR_CLIENT_SECRET_HERE" // Replace with secure retrieval
}

/// Model for decoding the OAuth token response.
struct NationalHousingSurveyTokenResponse: Decodable {
    let access_token: String
    let token_type: String // e.g., "Bearer"
    let expires_in: Int // Seconds until expiration
    let scope: String? // Optional scope information
}

// MARK: - Data Service (ViewModel)
final class NationalHousingSurveyService: ObservableObject {
    // MARK: Published Properties for UI Binding
    @Published var surveyData: [SurveyData] = []
    @Published var hpsiData: [HpsiDataModel] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    // MARK: Configuration
    private let baseURLString = "https://api.fanniemae.com" // <-- TODO: Verify this matches the environment for your credentials
    private let tokenURLString = "https://auth.pingone.com/4c2b23f9-52b1-4f8f-aa1f-1d477590770c/as/token" // <-- TODO: Verify this is the correct token endpoint for the API
    private let tokenHeader = "Authorization" // Standard Authorization header for Bearer token

    // MARK: State Management (In-Memory Cache for Token)
    private var accessToken: String?
    private var tokenExpiration: Date?
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Token Management

    /// Fetches a new OAuth access token or returns a cached one if valid.
    private func getAccessToken(completion: @escaping (Result<String, NationalHousingSurveyViewAPIError>) -> Void) {
        print("[Network Debug] Checking for cached access token.")

        // 1. Check In-Memory Cache: Return token if still valid (with a 60-second buffer).
        if let token = accessToken, let expiration = tokenExpiration, Date() < expiration.addingTimeInterval(-60) {
            print("[Network Debug] Using valid cached token (Expires: \(expiration)).")
            completion(.success(token))
            return
        } else if let expiration = tokenExpiration {
             print("[Network Debug] Cached token expired at \(expiration) or is missing/invalidated.")
        } else {
            print("[Network Debug] No token cached.")
        }

        // 2. Prepare token request
        print("[Network Debug] Requesting new access token from: \(tokenURLString)")
        guard let url = URL(string: tokenURLString) else {
            print("[Network Debug] ERROR: Invalid token URL string.")
            completion(.failure(.invalidURL))
            return
        }

        // --- TODO: CRITICAL - Verify Credentials ---
        // Ensure NationalHousingSurvey_AuthCredentials.clientID and .clientSecret
        // are correct for the target environment (matching baseURLString) and have
        // the necessary permissions for the /v1/nhs/* endpoints.
        let credentials = "\(NationalHousingSurvey_AuthCredentials.clientID):\(NationalHousingSurvey_AuthCredentials.clientSecret)"
        guard let base64Credentials = credentials.data(using: .utf8)?.base64EncodedString() else {
            print("[Network Debug] ERROR: Could not encode credentials.")
            completion(.failure(.authenticationFailed))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = "grant_type=client_credentials".data(using: .utf8)

        print("[Network Debug] Token Request Details: URL=\(request.url!), Method=\(request.httpMethod!), Headers=\(request.allHTTPHeaderFields ?? [:])")

        // 3. Execute token request using Combine
        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse else {
                  print("[Network Debug] ERROR: No HTTP response received from token endpoint.")
                  throw NationalHousingSurveyViewAPIError.requestFailed("No HTTP response from token endpoint.")
                }
                print("[Network Debug] Token Response Status: \(httpResponse.statusCode)")
                guard (200...299).contains(httpResponse.statusCode) else {
                    let responseString = String(data: data, encoding: .utf8) ?? "No response body"
                    print("[Network Debug] ERROR: Token request failed with status \(httpResponse.statusCode). Response: \(responseString)")
                    if httpResponse.statusCode == 401 || httpResponse.statusCode == 403 {
                         throw NationalHousingSurveyViewAPIError.authenticationFailed
                    } else {
                         throw NationalHousingSurveyViewAPIError.requestFailed("Token endpoint error (\(httpResponse.statusCode))")
                    }
                }
                print("[Network Debug] Token response received data (\(data.count) bytes).")
                return data
            }
            .decode(type: NationalHousingSurveyTokenResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completionResult in
                 guard let self = self else { return } // Added guard
                 switch completionResult {
                 case .finished:
                     print("[Network Debug] Token request publisher finished.")
                     break
                 case .failure(let error):
                     print("[Network Debug] ERROR in token request pipeline: \(error)")
                     let apiError: NationalHousingSurveyViewAPIError
                     if let mappedError = error as? NationalHousingSurveyViewAPIError {
                          apiError = mappedError
                     } else if error is DecodingError {
                          print("[Network Debug] ERROR: Failed to decode token response.")
                          apiError = .decodingFailed
                     } else {
                          apiError = .unknown(error)
                     }
                     DispatchQueue.main.async { // Ensure UI update on main thread
                        self.handleError(apiError)
                        completion(.failure(apiError)) // Call completion on main thread too
                     }
                 }
            } receiveValue: { [weak self] tokenResponse in
                 guard let self = self else { return } // Added guard
                 // 4. Cache the new token and its expiration
                 self.accessToken = tokenResponse.access_token
                 self.tokenExpiration = Date().addingTimeInterval(TimeInterval(tokenResponse.expires_in))
                 print("[Network Debug] Successfully received and cached new token. Expires: \(self.tokenExpiration!).")
                 completion(.success(tokenResponse.access_token)) // Callback AFTER caching
            }
            .store(in: &cancellables)
    }

    // MARK: - Public API Data Fetching
    func fetchData(for endpoint: NationalHousingSurveyViewAPIEndpoint) {
        // ... (Log, isLoading, clear data - same as before) ...
        print("[Network Debug] Initiating fetchData for endpoint: \(endpoint.path)")
        isLoading = true
        errorMessage = nil
        if case .nhsResults = endpoint {
            surveyData = []
        } else {
            hpsiData = []
        }

        // 1. Get a valid access token (checks cache first)
        getAccessToken { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let token):
                    print("[Network Debug] Access token obtained successfully. Proceeding with data request.")
                    self.makeDataRequest(endpoint: endpoint, accessToken: token)
                case .failure(let error): // Error already handled in getAccessToken
                    print("[Network Debug] Failed to obtain access token. Aborting data request.")
                    self.isLoading = false // Explicitly stop loading if token fails
                    // Error message is already set by handleError called within getAccessToken
                }
            }
        }
    }


    // MARK: - Private Data Request Logic
    private func makeDataRequest(endpoint: NationalHousingSurveyViewAPIEndpoint, accessToken: String) {
        guard let url = URL(string: baseURLString + endpoint.path) else {
            // ... (error handling - same as before) ...
            print("[Network Debug] ERROR: Invalid data request URL string: \(baseURLString + endpoint.path)")
            DispatchQueue.main.async {
                self.handleError(.invalidURL)
                self.isLoading = false
            }
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        // --- TODO: Verify Header ---
        // Confirm with API documentation if "Authorization: Bearer <token>" is correct.
        // If it expects "x-public-access-token: <token>", change the line below.
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: tokenHeader) // Using "Authorization" header

        // ... (Log request details - same as before) ...
        let tokenSnippet = accessToken.prefix(8)
        print("[Network Debug] Making data request: URL=\(url), Method=\(request.httpMethod!), Headers=\(request.allHTTPHeaderFields?.description ?? "None"), Token=\(tokenHeader): Bearer \(tokenSnippet)...")


        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { [weak self] data, response -> Data in // Capture weak self
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("[Network Debug] ERROR: No HTTP response received for data request.")
                    throw NationalHousingSurveyViewAPIError.requestFailed("No HTTP response received for data request.")
                }
                print("[Network Debug] Data Response Status: \(httpResponse.statusCode)")

                switch httpResponse.statusCode {
                case 200...299:
                    print("[Network Debug] Data request successful (\(data.count) bytes received).")
                    return data
                case 401:
                    print("[Network Debug] ERROR: Authentication failed (401) during data request. Invalidating cached token.")
                    // *** CHANGE: Invalidate the token used for this failed request ***
                    DispatchQueue.main.async { // Ensure state mutation is on main thread
                       self?.accessToken = nil
                       self?.tokenExpiration = nil
                    }
                    // *****************************************************************
                    throw NationalHousingSurveyViewAPIError.authenticationFailed // Propagate the specific error
                // ... (Handle 400, 403, 404, 5xx - same as before) ...
                case 400:
                    let pathComponents = endpoint.path.components(separatedBy: "/")
                    let invalidParamGuess = pathComponents.last(where: { $0.contains("{") == false }) ?? "Unknown"
                    print("[Network Debug] ERROR: Invalid parameter (400). Guessed parameter: \(invalidParamGuess)")
                    throw NationalHousingSurveyViewAPIError.invalidParameter(invalidParamGuess)
                 case 403:
                    print("[Network Debug] ERROR: Forbidden (403).")
                     throw NationalHousingSurveyViewAPIError.forbidden
                 case 404:
                     print("[Network Debug] No data found (404).")
                      throw NationalHousingSurveyViewAPIError.noData
                 case 500...599:
                     let responseString = String(data: data, encoding: .utf8) ?? "No Response Body"
                     print("[Network Debug] ERROR: Server Error (\(httpResponse.statusCode)). Response: \(responseString)")
                     throw NationalHousingSurveyViewAPIError.requestFailed("Server Error (\(httpResponse.statusCode))")
                default:
                    let responseString = String(data: data, encoding: .utf8) ?? "No Response Body"
                    print("[Network Debug] ERROR: Unexpected HTTP Status Code: \(httpResponse.statusCode). Response: \(responseString)")
                    throw NationalHousingSurveyViewAPIError.requestFailed("Unexpected HTTP Status Code: \(httpResponse.statusCode)")
                }
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completionResult in
                guard let self = self else { return }
                print("[Network Debug] Data request publisher completed.")
                // Stop loading indicator ONLY AFTER ensuring all state updates are done
                 if case .failure = completionResult {
                      self.isLoading = false // Stop loading on failure
                 }
                // On success, isLoading should stop AFTER receiveValue processing ideally,
                // but stopping here is simpler and often acceptable. Let's keep it here.
                // We'll ensure isLoading=false happens on main thread anyway.
                DispatchQueue.main.async {
                    if self.isLoading { // Check might be redundant but safe
                        self.isLoading = false
                    }
                }


                switch completionResult {
                case .finished:
                    print("[Network Debug] Data pipeline finished successfully.")
                    break // Success handled in receiveValue
                case .failure(let error):
                    print("[Network Debug] ERROR in data request pipeline: \(error)")
                     // Error should have already been mapped in tryMap or be an unknown error
                    let apiError = (error as? NationalHousingSurveyViewAPIError) ?? NationalHousingSurveyViewAPIError.unknown(error)
                    self.handleError(apiError) // Update UI
                }
            } receiveValue: { [weak self] data in
                guard let self = self else { return }

                let responseType = self.determineResponseType(for: endpoint)
                print("[Network Debug] Attempting to decode \(data.count) bytes as \(responseType)...")

                do {
                    let decoder = JSONDecoder()
                    if responseType == [NhsResults].self {
                        let decodedResponse = try decoder.decode([NhsResults].self, from: data)
                        self.surveyData = decodedResponse.map { SurveyData(from: $0) }
                        self.hpsiData = []
                        print("[Network Debug] Successfully decoded as [NhsResults]. Count: \(self.surveyData.count)")
                    } else if responseType == [HpsiData].self {
                        let decodedResponse = try decoder.decode([HpsiData].self, from: data)
                        self.hpsiData = decodedResponse.map { HpsiDataModel(from: $0) }
                        self.surveyData = []
                        print("[Network Debug] Successfully decoded as [HpsiData]. Count: \(self.hpsiData.count)")
                    } else {
                        print("[Network Debug] ERROR: Unknown response type determined.")
                        throw NationalHousingSurveyViewAPIError.decodingFailed // Throw to be caught below
                    }
                    self.errorMessage = nil // Clear error on successful decode
                     // Ensure isLoading is false after successful processing on main thread
                     DispatchQueue.main.async {
                         if self.isLoading { self.isLoading = false }
                     }

                } catch {
                    print("[Network Debug] ERROR: Decoding failed. Error: \(error)")
                    if let decodingError = error as? DecodingError {
                        print("[Network Debug] Decoding Error Details: \(decodingError)")
                    }
                    self.handleError(NationalHousingSurveyViewAPIError.decodingFailed)
                    // Ensure isLoading is false after failed processing on main thread
                    DispatchQueue.main.async {
                         if self.isLoading { self.isLoading = false }
                     }
                }
            }
            .store(in: &cancellables)
    }

    // ... (determineResponseType, clearLocalData, handleError - same as before) ...
    /// Helper to determine the expected Decodable type based on the endpoint.
    private func determineResponseType(for endpoint: NationalHousingSurveyViewAPIEndpoint) -> Decodable.Type {
        // ... same implementation ...
        switch endpoint {
        case .nhsResults:
            return [NhsResults].self
        case .hpsiData, .hpsiDataByAreaType, .hpsiDataByOwnershipStatus, .hpsiDataByHousingCostRatio,
             .hpsiDataByAgeGroup, .hpsiDataByCensusRegion, .hpsiDataByIncomeGroup, .hpsiDataByEducation:
            return [HpsiData].self
        }
    }

    /// Clears the locally held survey and HPSI data.
    func clearLocalData() {
       // ... same implementation ...
        DispatchQueue.main.async {
            print("[Network Debug] Clearing local data arrays.")
           self.surveyData.removeAll()
           self.hpsiData.removeAll()
           self.errorMessage = nil
       }
    }

    /// Updates the errorMessage property for the UI and logs the error.
    private func handleError(_ error: NationalHousingSurveyViewAPIError) {
        // ... ensure main thread - same implementation ...
        DispatchQueue.main.async {
             if self.errorMessage != error.localizedDescription {
                 self.errorMessage = error.localizedDescription
             }
            print("[Error Handler] API Error: \(error.localizedDescription)")
        }
    }

} // End NationalHousingSurveyService

// MARK: - SwiftUI View
// ... (NationalHousingSurveyView struct - No functional changes needed, layout improvements kept) ...
struct NationalHousingSurveyView: View {
    @StateObject private var dataService = NationalHousingSurveyService()

    // State for Pickers - correspond to API parameter values
    @State private var selectedAreaType: String = "1"  // Default: Urban
    @State private var selectedOwnershipStatus: String = "1" // Default: Owner
    @State private var selectedHousingCostRatio: String = "1" //Default: Low
    @State private var selectedAgeGroup: String = "1" // Default: 18-34
    @State private var selectedCensusRegion: String = "1" // Default: NORTHEAST
    @State private var selectedIncomeGroup: String = "1" // Default: <$50K
    @State private var selectedEducation: String = "4" // Default: College/Grad School

    // Data for Pickers (using Tuples for value and display name)
    let areaTypes = [("1", "Urban"), ("2", "Suburban"), ("3", "Rural")]
    let ownershipStatuses = [("1", "Owner"), ("2", "Renter")]
    let housingCostRatios = [("1", "Low"), ("2", "Mid"), ("3", "High")]
    let ageGroups = [("1", "18-34"), ("2", "35-44"), ("3", "45-64"), ("4", "65+")]
    let censusRegions = [("1", "Northeast"), ("2", "Midwest"), ("3", "South"), ("4", "West")]
    let incomeGroups = [("1", "<$50K"), ("2", "$50K-100K"), ("3", "$100K+")]
    let educationLevels = [("1", "< High School"), ("2", "High School"), ("3", "Some College"), ("4", "College/Grad")]

    var body: some View {
        NavigationView {
            Form {
                // MARK: - Data Fetching Controls
                Section(header: Text("Fetch Data")) {
                    // General Data Buttons
                     Button { dataService.fetchData(for: .nhsResults) } label: {
                         Label("Fetch All NHS Results", systemImage: "list.bullet.clipboard")
                     }
                     .buttonStyle(.borderedProminent) // Make primary actions stand out

                     Button { dataService.fetchData(for: .hpsiData) } label: {
                          Label("Fetch All HPSI Data", systemImage: "chart.line.uptrend.xyaxis")
                      }
                     .buttonStyle(.borderedProminent)

                    // --- Filtered HPSI Data ---
                    DisclosureGroup("Fetch Filtered HPSI Data") {
                        VStack(alignment: .leading, spacing: 10) { // Add spacing
                           createPicker(label: "Area Type", selection: $selectedAreaType, options: areaTypes) {
                               dataService.fetchData(for: .hpsiDataByAreaType(areaType: selectedAreaType))
                           }
                            Divider() // Add separators between filters
                            createPicker(label: "Ownership Status", selection: $selectedOwnershipStatus, options: ownershipStatuses) {
                                dataService.fetchData(for: .hpsiDataByOwnershipStatus(ownershipStatus: selectedOwnershipStatus))
                            }
                             Divider()
                            createPicker(label: "Housing Cost Ratio", selection: $selectedHousingCostRatio, options: housingCostRatios) {
                                dataService.fetchData(for: .hpsiDataByHousingCostRatio(housingCostRatio: selectedHousingCostRatio))
                            }
                            Divider()
                            createPicker(label: "Age Group", selection: $selectedAgeGroup, options: ageGroups) {
                                dataService.fetchData(for: .hpsiDataByAgeGroup(ageGroup: selectedAgeGroup))
                            }
                             Divider()
                            createPicker(label: "Census Region", selection: $selectedCensusRegion, options: censusRegions) {
                                dataService.fetchData(for: .hpsiDataByCensusRegion(censusRegion: selectedCensusRegion))
                            }
                             Divider()
                             createPicker(label: "Income Group", selection: $selectedIncomeGroup, options: incomeGroups) {
                                 dataService.fetchData(for: .hpsiDataByIncomeGroup(incomeGroup: selectedIncomeGroup))
                             }
                            Divider()
                            createPicker(label: "Education Level", selection: $selectedEducation, options: educationLevels) {
                                dataService.fetchData(for: .hpsiDataByEducation(educationLevel: selectedEducation))
                            }
                        }
                        .padding(.vertical, 5) // Add padding inside disclosure group
                    } // End DisclosureGroup

                    // Clear Data Button
                    Button(role: .destructive) {
                         dataService.clearLocalData()
                     } label: {
                         Label("Clear Displayed Data", systemImage: "xmark.bin")
                             .frame(maxWidth: .infinity, alignment: .center) // Center align
                     }
                     .tint(.red) // Ensure destructive tint

                } // End Section Fetch Data

                // MARK: - Results Display
                Section(header: Text("Results")) {
                    if dataService.isLoading {
                        HStack(spacing: 8) { // Add spacing for ProgressView
                             ProgressView()
                            Text("Loading...")
                                .foregroundColor(.secondary) // Use secondary color
                         }
                         .frame(maxWidth: .infinity, alignment: .center) // Center align
                         .padding(.vertical, 10) // Add padding
                    } else if let errorMessage = dataService.errorMessage {
                         Label {
                             Text(errorMessage)
                         } icon: {
                              Image(systemName: "exclamationmark.triangle.fill")
                         }
                        .foregroundColor(.red)
                        .padding(.vertical, 5)
                    } else if !dataService.surveyData.isEmpty {
                        // Display NHS Survey Results
                         List { // Remove implicit List, let Form section handle it? Or keep for structure.
                            ForEach(dataService.surveyData) { survey in
                                Section(header: Text("Survey Date: \(survey.date)")) {
                                     ForEach(survey.questions) { question in
                                         VStack(alignment: .leading, spacing: 5) {
                                             Text(question.description).font(.headline)
                                              Divider().padding(.bottom, 3) // Add divider for clarity
                                             ForEach(question.responses) { response in
                                                 HStack {
                                                     Text("• \(response.description)").foregroundColor(.secondary)
                                                     Spacer()
                                                     Text("\(String(format: "%.1f", response.percent))%")
                                                         .fontWeight(.medium)
                                                 }
                                                 .font(.subheadline)
                                             }
                                         }
                                         .padding(.vertical, 6) // Add padding around each question block
                                     }
                                 }
                             }
                         }
                         .listStyle(InsetGroupedListStyle()) // Apply style within section if needed
                    } else if !dataService.hpsiData.isEmpty {
                         // Display HPSI Data
                         // Use ForEach directly in the section for better Form integration
                        ForEach(dataService.hpsiData) { data in
                            HStack {
                                Text(data.date)
                                    .font(.caption) // Smaller font for date?
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("HPSI: \(String(format: "%.1f", data.hpsiValue))")
                                    .fontWeight(.semibold)
                            }
                         }
                         // .listStyle(PlainListStyle()) // Not needed if ForEach is direct child

                    } else {
                        Text("No data fetched yet. Use controls above.")
                            .foregroundColor(.gray) // Use gray for placeholder
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 10)
                    }
                } // End Section Results
            } // End Form
            .navigationTitle("NHS Data Explorer")
            // .navigationBarTitleDisplayMode(.inline) // Optional: Adjust title display
        } // End NavigationView
        .navigationViewStyle(StackNavigationViewStyle())
    }

    // Helper function to create Picker + Button Row
    @ViewBuilder
    private func createPicker(
        label: String,
        selection: Binding<String>,
        options: [(String, String)],
        fetchAction: @escaping () -> Void
    ) -> some View {
        // Use VStack for better alignment control if needed, or keep HStack
            HStack {
                Text(label) // Use a Text label for consistency if Picker label is hidden
                    .frame(minWidth: 120, alignment: .leading) // Align labels

                Picker(label, selection: selection) {
                     ForEach(options, id: \.0) { value, name in
                         Text(name).tag(value)
                     }
                 }
                 .labelsHidden() // Hide the Picker's default label if using Text label
                 .pickerStyle(.menu) // Use menu style for compactness in Form


                Spacer()

                Button(action: fetchAction) {
                     Image(systemName: "magnifyingglass")
                 }
                 .buttonStyle(.bordered)
                 .tint(.accentColor)
            }
    }
}


// MARK: - Preview
struct NationalHousingSurveyView_Previews: PreviewProvider {
    static var previews: some View {
        NationalHousingSurveyView()
    }
}
