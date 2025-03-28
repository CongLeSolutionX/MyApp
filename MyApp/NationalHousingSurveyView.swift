//
//  NationalHousingSurveyView.swift
//  MyApp
//
//  Created by Cong Le on 3/28/25.
//

//
//  NationalHousingSurveyView.swift
//  MyApp
//
//  Created by Cong Le on 3/24/25.
//

import SwiftUI
import Combine

// MARK: - Internal Application Data Models

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
    private let baseURLString = "https://api.fanniemae.com"
    // NOTE: Consider making the token URL configurable as well.
    private let tokenURLString = "https://auth.pingone.com/4c2b23f9-52b1-4f8f-aa1f-1d477590770c/as/token"
    private let tokenHeader = "x-public-access-token" // Header name for the data request token

    // MARK: State Management
    private var accessToken: String?
    private var tokenExpiration: Date?
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Token Management

    /// Fetches a new OAuth access token or returns a cached one if valid.
    private func getAccessToken(completion: @escaping (Result<String, NationalHousingSurveyViewAPIError>) -> Void) {
        // 1. Check cache: Return token if still valid (with a small buffer).
        if let token = accessToken, let expiration = tokenExpiration, Date() < expiration.addingTimeInterval(-60) { // 60 sec buffer
            completion(.success(token))
            return
        }

        // 2. Prepare token request
        guard let url = URL(string: tokenURLString) else {
            completion(.failure(.invalidURL))
            return
        }

        let credentials = "\(NationalHousingSurvey_AuthCredentials.clientID):\(NationalHousingSurvey_AuthCredentials.clientSecret)"
        guard let base64Credentials = credentials.data(using: .utf8)?.base64EncodedString() else {
            // This should ideally not happen if credentials are valid strings
            completion(.failure(.authenticationFailed))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = "grant_type=client_credentials".data(using: .utf8)

        // 3. Execute token request using Combine
        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse else {
                  throw NationalHousingSurveyViewAPIError.requestFailed("No HTTP response from token endpoint.")
                }
                guard (200...299).contains(httpResponse.statusCode) else {
                    // Attempt to log response body for debugging
                    let responseString = String(data: data, encoding: .utf8) ?? "No response body"
                    throw NationalHousingSurveyViewAPIError.authenticationFailed // Treat any non-2xx as auth failure
                }
                return data
            }
            .decode(type: NationalHousingSurveyTokenResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main) // Switch to main thread for state updates
            .sink { [weak self] completionResult in
                guard let self = self else { return }
                switch completionResult {
                case .finished:
                    break // Token successfully received and decoded (handled in receiveValue)
                case .failure(let error):
                    // Map potential decoding or network errors to our custom APIError type
                    let apiError: NationalHousingSurveyViewAPIError
                    if let mappedError = error as? NationalHousingSurveyViewAPIError {
                        apiError = mappedError
                    } else if error is DecodingError {
                        apiError = .decodingFailed // Specifically for token response decoding
                    } else {
                        apiError = .unknown(error)
                    }
                    self.handleError(apiError) // Update UI state
                    completion(.failure(apiError)) // Propagate the failure
                }
            } receiveValue: { [weak self] tokenResponse in
                guard let self = self else { return }
                // 4. Cache the new token and its expiration
                self.accessToken = tokenResponse.access_token
                self.tokenExpiration = Date().addingTimeInterval(TimeInterval(tokenResponse.expires_in))
                completion(.success(tokenResponse.access_token)) // Callback with the new token
            }
            .store(in: &cancellables) // Manage subscription lifecycle
    }

    // MARK: - Public API Data Fetching

    /// Initiates fetching data for a given API endpoint.
    func fetchData(for endpoint: NationalHousingSurveyViewAPIEndpoint) {
        isLoading = true
        errorMessage = nil
        // Clear previous data specific to the type of endpoint being fetched
        if case .nhsResults = endpoint {
            surveyData = []
        } else {
            hpsiData = []
        }


        // 1. Get a valid access token (either cached or new)
        getAccessToken { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async { // Ensure UI updates happen on the main thread
                switch result {
                case .success(let token):
                    // 2. If token is available, make the actual data request
                    self.makeDataRequest(endpoint: endpoint, accessToken: token)
                case .failure(let error):
                    // If token fetching failed, update state and stop
                    self.isLoading = false
                    self.handleError(error)
                }
            }
        }
    }

    // MARK: - Private Data Request Logic

    /// Performs the actual data request using a valid access token.
    private func makeDataRequest(endpoint: NationalHousingSurveyViewAPIEndpoint, accessToken: String) {
        guard let url = URL(string: baseURLString + endpoint.path) else {
            // This should not happen if endpoint paths are correct
            handleError(.invalidURL)
            isLoading = false // Ensure loading state is reset
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET" // All endpoints are GET
        request.addValue("application/json", forHTTPHeaderField: "Accept") // Prefer JSON
        // Use the specific header name required by the API
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization") // Standard Bearer token

        // Execute data request using Combine
        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NationalHousingSurveyViewAPIError.requestFailed("No HTTP response received.")
                }

                // Handle HTTP status codes specifically
                switch httpResponse.statusCode {
                case 200...299:
                    return data // Success
                case 400:
                    // Try to determine which parameter was invalid from the endpoint path
                    let pathComponents = endpoint.path.components(separatedBy: "/")
                    let invalidParamGuess = pathComponents.last(where: { $0.contains("{") == false }) ?? "Unknown"
                    throw NationalHousingSurveyViewAPIError.invalidParameter(invalidParamGuess)
                 case 401:
                     // This could mean the token expired *between* getAccessToken and this request
                     throw NationalHousingSurveyViewAPIError.authenticationFailed
                 case 403:
                     throw NationalHousingSurveyViewAPIError.forbidden
                 case 404:
                      throw NationalHousingSurveyViewAPIError.noData
                 case 500...599:
                     let responseString = String(data: data, encoding: .utf8) ?? "No Response Body"
                     throw NationalHousingSurveyViewAPIError.requestFailed("Server Error (\(httpResponse.statusCode)): \(responseString)")
                default:
                    // Catch-all for other unexpected status codes
                    let responseString = String(data: data, encoding: .utf8) ?? "No Response Body"
                    throw NationalHousingSurveyViewAPIError.requestFailed("Unexpected HTTP Status Code: \(httpResponse.statusCode). Response: \(responseString)")
                }
            }
            .receive(on: DispatchQueue.main) // Switch to main thread for UI updates
            .sink { [weak self] completionResult in
                guard let self = self else { return }
                // This block executes *after* receiveValue or on failure
                self.isLoading = false // Always ensure loading is stopped on completion/failure
                switch completionResult {
                case .finished:
                    break // Data successfully received and processed (handled in receiveValue)
                case .failure(let error):
                    // Map potential network or status code errors to our APIError
                    let apiError = (error as? NationalHousingSurveyViewAPIError) ?? NationalHousingSurveyViewAPIError.unknown(error)
                    self.handleError(apiError)
                }
            } receiveValue: { [weak self] data in
                guard let self = self else { return }
                // isLoading is set to false in the completion block now

                // Determine the expected response type based on the endpoint
                let responseType = self.determineResponseType(for: endpoint)

                do {
                    let decoder = JSONDecoder()
                    // Decode based on the determined type
                    if responseType == [NhsResults].self {
                        let decodedResponse = try decoder.decode([NhsResults].self, from: data)
                        // Map API models to internal App models
                        self.surveyData = decodedResponse.map { SurveyData(from: $0) }
                         self.hpsiData = [] // Clear other data type

                    } else if responseType == [HpsiData].self {
                        let decodedResponse = try decoder.decode([HpsiData].self, from: data)
                        // Map API models to internal App models
                        self.hpsiData = decodedResponse.map { HpsiDataModel(from: $0) }
                        self.surveyData = [] // Clear other data type

                    } else {
                        // This case should not be reachable if determineResponseType is correct
                        self.handleError(.decodingFailed) // Indicate a logic error
                    }
                    self.errorMessage = nil // Clear error message on successful decode
                } catch {
                    print("Decoding Error: \(error)") // Log detailed decoding error
                    self.handleError(NationalHousingSurveyViewAPIError.decodingFailed)
                }
            }
            .store(in: &cancellables)
    }

    /// Helper to determine the expected Decodable type based on the endpoint.
    private func determineResponseType(for endpoint: NationalHousingSurveyViewAPIEndpoint) -> Decodable.Type {
        switch endpoint {
        case .nhsResults:
            return [NhsResults].self // Expect an array of NhsResults
        case .hpsiData, .hpsiDataByAreaType, .hpsiDataByOwnershipStatus, .hpsiDataByHousingCostRatio,
             .hpsiDataByAgeGroup, .hpsiDataByCensusRegion, .hpsiDataByIncomeGroup, .hpsiDataByEducation:
            return [HpsiData].self // Expect an array of HpsiData
        }
    }

    // MARK: - Local Data Management

    /// Clears the locally held survey and HPSI data.
    func clearLocalData() {
       DispatchQueue.main.async {
           self.surveyData.removeAll()
           self.hpsiData.removeAll()
           self.errorMessage = nil // Also clear any error messages
       }
    }

    // MARK: - Error Handling

    /// Updates the errorMessage property for the UI.
    private func handleError(_ error: NationalHousingSurveyViewAPIError) {
        // Update the published property on the main thread
        DispatchQueue.main.async {
            self.errorMessage = error.localizedDescription
            print("API Error Encountered: \(error.localizedDescription)") // Log for debugging
        }
    }
}

// MARK: - SwiftUI View

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

    // Data for Pickers (could be structs with display names)
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

                     Button { dataService.fetchData(for: .hpsiData) } label: {
                          Label("Fetch All HPSI Data", systemImage: "chart.line.uptrend.xyaxis")
                      }

                    // --- Filtered HPSI Data ---
                    DisclosureGroup("Fetch Filtered HPSI Data") {
                        VStack {
                           createPicker(label: "Area Type", selection: $selectedAreaType, options: areaTypes) {
                               dataService.fetchData(for: .hpsiDataByAreaType(areaType: selectedAreaType))
                           }
                            createPicker(label: "Ownership Status", selection: $selectedOwnershipStatus, options: ownershipStatuses) {
                                dataService.fetchData(for: .hpsiDataByOwnershipStatus(ownershipStatus: selectedOwnershipStatus))
                            }
                            createPicker(label: "Housing Cost Ratio", selection: $selectedHousingCostRatio, options: housingCostRatios) {
                                dataService.fetchData(for: .hpsiDataByHousingCostRatio(housingCostRatio: selectedHousingCostRatio))
                            }
                            createPicker(label: "Age Group", selection: $selectedAgeGroup, options: ageGroups) {
                                dataService.fetchData(for: .hpsiDataByAgeGroup(ageGroup: selectedAgeGroup))
                            }
                            createPicker(label: "Census Region", selection: $selectedCensusRegion, options: censusRegions) {
                                dataService.fetchData(for: .hpsiDataByCensusRegion(censusRegion: selectedCensusRegion))
                            }
                             createPicker(label: "Income Group", selection: $selectedIncomeGroup, options: incomeGroups) {
                                 dataService.fetchData(for: .hpsiDataByIncomeGroup(incomeGroup: selectedIncomeGroup))
                             }
                            createPicker(label: "Education Level", selection: $selectedEducation, options: educationLevels) {
                                dataService.fetchData(for: .hpsiDataByEducation(educationLevel: selectedEducation))
                            }
                        }
                        .padding(.top, 5)
                    } // End DisclosureGroup

                    // Clear Data Button
                    Button("Clear Displayed Data", role: .destructive) {
                        dataService.clearLocalData()
                    }
                    .frame(maxWidth: .infinity, alignment: .center)

                } // End Section Fetch Data

                // MARK: - Results Display
                Section(header: Text("Results")) {
                    if dataService.isLoading {
                        HStack {
                             ProgressView()
                             Text("Loading...").padding(.leading, 5)
                         }
                         .frame(maxWidth: .infinity)
                    } else if let errorMessage = dataService.errorMessage {
                         Label(errorMessage, systemImage: "exclamationmark.triangle.fill")
                             .foregroundColor(.red)
                    } else if !dataService.surveyData.isEmpty {
                        // Display NHS Survey Results
                         List {
                            ForEach(dataService.surveyData) { survey in
                                Section(header: Text("Survey Date: \(survey.date)")) {
                                     ForEach(survey.questions) { question in
                                         VStack(alignment: .leading, spacing: 5) {
                                             Text(question.description).font(.headline)
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
                                         .padding(.vertical, 4)
                                     }
                                 }
                             }
                         }
                         .listStyle(PlainListStyle()) // Use PlainListStyle within Form section
                    } else if !dataService.hpsiData.isEmpty {
                         // Display HPSI Data
                         List(dataService.hpsiData) { data in
                             HStack {
                                 Text(data.date)
                                 Spacer()
                                 Text("HPSI: \(String(format: "%.1f", data.hpsiValue))") // Format HPSI
                                     .fontWeight(.semibold)
                             }
                         }
                         .listStyle(PlainListStyle())
                    } else {
                        Text("No data fetched yet. Use controls above.")
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity)
                    }
                } // End Section Results
            } // End Form
            .navigationTitle("NHS Data Explorer")
        } // End NavigationView
        .navigationViewStyle(StackNavigationViewStyle()) // Use stack style for broader compatibility
    }

    // Helper function to create Picker + Button Row
    @ViewBuilder
    private func createPicker(
        label: String,
        selection: Binding<String>,
        options: [(String, String)],
        fetchAction: @escaping () -> Void
    ) -> some View {
        HStack {
            Picker(label, selection: selection) {
                 ForEach(options, id: \.0) { value, name in
                     Text(name).tag(value) // Use value as tag, display name
                 }
             }
             // Limit picker style if needed for space
             // .pickerStyle(.menu)

            Spacer() // Add Spacer for better layout

            Button(action: fetchAction) {
                 Image(systemName: "magnifyingglass") // Use SF Symbol for Fetch button
             }
             .buttonStyle(.bordered)
             .tint(.accentColor) // Use accent color for fetch buttons
        }
    }
}

// MARK: - Preview

struct NationalHousingSurveyView_Previews: PreviewProvider {
    static var previews: some View {
        NationalHousingSurveyView()
    }
}
