//
//  LoanLimitsView_V2.swift
//  MyApp
//
//  Created by Cong Le on 4/28/25.
//

import SwiftUI
import Combine // Essential for asynchronous operations

// MARK: - Data Models (Aligned with API Response Payload)

// Wrapper struct to match the top-level JSON structure: {"loanLimit": [...]}
struct LoanLimitsResponse: Decodable {
    let loanLimit: [LoanLimit]? // Make the array itself optional for safety
}

// Represents a single loan limit entry for a specific location/year
struct LoanLimit: Decodable, Identifiable, Hashable { // Add Hashable for potential future use in Sets or Diffs
    let id = UUID() // Needed for Identifiable in SwiftUI Lists
    let stateCode: String?
    let countyName: String?
    let reportingYear: Int?
    let cbsaNumber: String?
    let fipsCode: String?
    let issuers: [Issuer]?

    // Conform to Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(fipsCode) // fipsCode is a good candidate for uniqueness
        hasher.combine(reportingYear)
    }

    // Conform to Equatable (needed for Hashable)
    static func == (lhs: LoanLimit, rhs: LoanLimit) -> Bool {
        return lhs.fipsCode == rhs.fipsCode && lhs.reportingYear == rhs.reportingYear
    }

    // Explicit CodingKeys are good practice, though not strictly needed if names match exactly
    enum CodingKeys: String, CodingKey {
        case stateCode, countyName, reportingYear, cbsaNumber, fipsCode, issuers
    }
}

// Represents the issuer details within a LoanLimit
struct Issuer: Decodable, Identifiable, Hashable { // Add Hashable
    let id = UUID() // Needed for List iteration if you ever need it
    let issuerType: String?
    let oneUnitLimit: Int?
    let twoUnitLimit: Int?
    let threeUnitLimit: Int?
    let fourUnitLimit: Int?

    // Conform to Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(issuerType)
        // Combine other relevant properties if needed for uniqueness within an issuer context
    }

    // Conform to Equatable (needed for Hashable)
    static func == (lhs: Issuer, rhs: Issuer) -> Bool {
        return lhs.issuerType == rhs.issuerType &&
               lhs.oneUnitLimit == rhs.oneUnitLimit &&
               lhs.twoUnitLimit == rhs.twoUnitLimit &&
               lhs.threeUnitLimit == rhs.threeUnitLimit &&
               lhs.fourUnitLimit == rhs.fourUnitLimit
    }

    // Explicit CodingKeys example
    enum CodingKeys: String, CodingKey {
        case issuerType, oneUnitLimit, twoUnitLimit, threeUnitLimit, fourUnitLimit
    }
}

// MARK: - API Endpoints Enum

enum LoanLimitsAPIEndpoint {
    case all
    case historical(year: String)
    case byCounty(state: String, county: String)

    var path: String {
        switch self {
        case .all:
            return "/v1/loan-limits/all"
        case .historical(let year):
            // Basic URL encoding for safety, although year usually doesn't need it
            let encodedYear = year.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? year
            return "/v1/loan-limits/historical/\(encodedYear)"
        case .byCounty(let state, let county):
            // Encode state and county names which might contain spaces or special characters
            let encodedState = state.trimmingCharacters(in: .whitespacesAndNewlines).addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? state
            let encodedCounty = county.trimmingCharacters(in: .whitespacesAndNewlines).addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? county
            return "/v1/loan-limits/state/\(encodedState)/county/\(encodedCounty)"
        }
    }
}

// MARK: - API Errors Enum

enum LoanLimitsAPIError: Error, LocalizedError {
    case invalidURL
    case requestFailed(statusCode: Int, message: String)
    case authenticationFailed(String)
    case tokenDecodingFailed
    case dataDecodingFailed(Error) // Include underlying decoding error
    case noData
    case unknown(Error) // Catch-all for other errors

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The API URL provided was invalid."
        case .requestFailed(let statusCode, let message):
            return "The API request failed with status code \(statusCode). Response: \(message)"
        case .authenticationFailed(let reason):
            return "Authentication failed: \(reason)"
        case .tokenDecodingFailed:
            return "Failed to decode the authentication token."
        case .dataDecodingFailed(let underlyingError):
             return "Failed to decode the loan limit data. Error: \(underlyingError.localizedDescription)"
        case .noData:
            return "The API returned no data for this request."
        case .unknown(let error):
             return "An unexpected error occurred: \(error.localizedDescription)"
        }
    }
}

// MARK: - Authentication Handling

struct LoanLimitsAuthCredentials {
     // --- ⚠️ IMPORTANT SECURITY WARNING ⚠️ ---
     // NEVER hardcode credentials directly in production code.
     // Use Keychain for secure storage or a configuration management system.
     // These are placeholders only.
     static let clientID = "YOUR_CLIENT_ID_HERE"        // Replace with your actual Client ID
     static let clientSecret = "YOUR_CLIENT_SECRET_HERE" // Replace with your actual Client Secret
     // -----------------------------------------
 }

// Structure to decode the token response from the authentication server
struct LoanLimits_TokenResponse: Decodable {
    let access_token: String
    let token_type: String
    let expires_in: Int // Duration in seconds
    // let scope: String // Include if needed
}

// MARK: - Data Service (ObservableObject)

final class LoanLimitsService: ObservableObject {
    @Published var loanLimits: [LoanLimit] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let baseURLString = "https://api.fanniemae.com"
    // Provided Token URL (ensure this is correct for the environment you're targeting)
    private let tokenURLString = "https://auth.pingone.com/4c2b23f9-52b1-4f8f-aa1f-1d477590770c/as/token"

    // WARNING: Storing tokens in memory like this is simple but not persistent across app launches.
    // For a production app, consider secure storage (Keychain) if needed beyond a single session.
    private var accessToken: String?
    private var tokenExpiration: Date?

    private var cancellables = Set<AnyCancellable>()
    private var tokenFetchCancellable: AnyCancellable? // Dedicated cancellable for token request

    // MARK: - Token Management
    /// Fetches a new access token or returns a valid cached one. Uses a Future to handle the async operation.
    private func getAccessToken() -> Future<String, LoanLimitsAPIError> {
        return Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(.unknown(NSError(domain: "LoanLimitsService", code: -2, userInfo: [NSLocalizedDescriptionKey: "Service deallocated"]))))
                return
            }

            // Check if existing token is valid (adding a small buffer for safety)
            if let token = self.accessToken, let expiration = self.tokenExpiration, Date().addingTimeInterval(60) < expiration {
                print("Using cached access token.")
                promise(.success(token))
                return
            }

            print("Fetching new access token...")
            guard let url = URL(string: self.tokenURLString) else {
                promise(.failure(.invalidURL))
                return
            }

            // --- Basic Authentication Header ---
            let credentials = "\(LoanLimitsAuthCredentials.clientID):\(LoanLimitsAuthCredentials.clientSecret)"
            guard let base64Credentials = credentials.data(using: .utf8)?.base64EncodedString() else {
                promise(.failure(.authenticationFailed("Could not encode credentials.")))
                return
            }

            // --- Request Setup ---
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")
            request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.httpBody = "grant_type=client_credentials".data(using: .utf8)

            // --- Make the Request ---
           self.tokenFetchCancellable = URLSession.shared.dataTaskPublisher(for: request)
                .tryMap { data, response -> Data in
                    guard let httpResponse = response as? HTTPURLResponse else {
                         throw LoanLimitsAPIError.requestFailed(statusCode: -1, message: "Invalid response object.")
                    }
                    // Check for successful status code specifically for token endpoint
                    guard (200...299).contains(httpResponse.statusCode) else {
                        let responseString = String(data: data, encoding: .utf8) ?? "No response body"
                        throw LoanLimitsAPIError.authenticationFailed("Token request failed with status \(httpResponse.statusCode). Response: \(responseString)")
                    }
                    return data
                }
                .decode(type: LoanLimits_TokenResponse.self, decoder: JSONDecoder())
                .receive(on: DispatchQueue.main) // Switch to main thread for state updates
                .sink(receiveCompletion: { completionResult in
                    switch completionResult {
                    case .finished:
                        print("Token fetching finished.")
                        break // Successfully fetched and decoded
                    case .failure(let error):
                         print("Token fetching failed: \(error)")
                         if let decodingError = error as? DecodingError {
                             promise(.failure(.tokenDecodingFailed))
                         } else if let apiError = error as? LoanLimitsAPIError {
                              promise(.failure(apiError))
                         } else {
                             promise(.failure(.unknown(error)))
                         }
                    }
                }, receiveValue: { tokenResponse in
                     print("Successfully fetched new token.")
                    // Store token and calculate expiration
                    self.accessToken = tokenResponse.access_token
                    self.tokenExpiration = Date().addingTimeInterval(TimeInterval(tokenResponse.expires_in))
                    promise(.success(tokenResponse.access_token)) // Resolve the Future with the token
                })
                
        }
    }

    // MARK: - Public API Data Fetching
    /// Fetches Loan Limits data for the specified endpoint. Handles token acquisition.
    func fetchData(for endpoint: LoanLimitsAPIEndpoint) {
        isLoading = true
        errorMessage = nil
        // Consider clearing old data immediately or only on success
        // loanLimits.removeAll()

        // Chain token fetch with data request
        getAccessToken()
            .flatMap { [weak self] token -> AnyPublisher<[LoanLimit], LoanLimitsAPIError> in // FlatMap expects a Publisher
                guard let self = self else {
                    // If self is nil, return a failing publisher
                    return Fail(error: LoanLimitsAPIError.unknown(NSError(domain: "LoanLimitsService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Service deallocated"])))
                           .eraseToAnyPublisher()
                }
                // Make the actual data request using the obtained token
                return self.makeDataRequest(endpoint: endpoint, accessToken: token)
            }
            .receive(on: DispatchQueue.main) // Ensure UI updates are on the main thread
            .sink(receiveCompletion: { [weak self] completionResult in
                guard let self = self else { return }
                self.isLoading = false // Stop loading indicator regardless of outcome
                switch completionResult {
                case .finished:
                    print("Data fetch completed successfully for endpoint: \(endpoint.path)")
                    if self.loanLimits.isEmpty { // Check if data was actually received
                        self.errorMessage = "No loan limits found for the specified criteria."
                    }
                case .failure(let error):
                     let apiError = (error as? LoanLimitsAPIError) ?? .unknown(error)
                     print("Data fetch failed for endpoint: \(endpoint.path) with error: \(apiError.localizedDescription)")
                    self.handleError(apiError) // Set the error message for the UI
                }
            }, receiveValue: { [weak self] fetchedLimits in
                print("Received \(fetchedLimits.count) loan limits for endpoint: \(endpoint.path)")
                self?.loanLimits = fetchedLimits // Update the published property
            })
            .store(in: &cancellables) // Store the subscription to keep it alive
    }

    /// Makes the actual network request to fetch LoanLimits data.
    private func makeDataRequest(endpoint: LoanLimitsAPIEndpoint, accessToken: String) -> AnyPublisher<[LoanLimit], LoanLimitsAPIError> {
        guard let url = URL(string: baseURLString + endpoint.path) else {
            return Fail(error: LoanLimitsAPIError.invalidURL).eraseToAnyPublisher()
        }
        print("Making data request to: \(url.absoluteString)")

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        // API expects the token in a specific header 'x-public-access-token'
        request.addValue(accessToken, forHTTPHeaderField: "x-public-access-token")
         // Explicitly accept JSON, although the API seems to default to it based on the spec
         request.addValue("application/json", forHTTPHeaderField: "Accept")

        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw LoanLimitsAPIError.requestFailed(statusCode: -1, message: "Invalid response object.")
                }
                guard (200...299).contains(httpResponse.statusCode) else {
                     let responseBody = String(data: data, encoding: .utf8) ?? "No response body"
                     // Special handling for 404
                     if httpResponse.statusCode == 404 {
                         throw LoanLimitsAPIError.noData
                     } else {
                         throw LoanLimitsAPIError.requestFailed(statusCode: httpResponse.statusCode, message: responseBody)
                     }
                }
                 // Optional: Log raw response for debugging
                 // if let jsonString = String(data: data, encoding: .utf8) {
                 //     print("Raw JSON response: \(jsonString)")
                 // }
                return data
            }
             // Decode the *wrapper* object first
            .decode(type: LoanLimitsResponse.self, decoder: JSONDecoder())
             // Extract the array, providing an empty array if the key is missing or null
            .map { $0.loanLimit ?? [] }
            .mapError { error -> LoanLimitsAPIError in // Map any error to our custom API error type
                 print("Decoding error: \(error)")
                 if let decodingError = error as? DecodingError {
                    return .dataDecodingFailed(decodingError)
                } else if let apiError = error as? LoanLimitsAPIError {
                    return apiError // Propagate already mapped errors
                } else {
                    return .unknown(error)
                }
            }
            .eraseToAnyPublisher() // Type erase to AnyPublisher
    }
    
    // MARK: - Error Handling
    /// Updates the errorMessage property for the UI.
    private func handleError(_ error: LoanLimitsAPIError) {
       self.errorMessage = error.localizedDescription
    }

    // MARK: - Utility
    /// Clears the locally stored data and error message.
    func clearLocalData() {
         loanLimits.removeAll()
         errorMessage = nil
         print("Local data cleared.")
     }
}

// MARK: - SwiftUI Views

struct LoanLimitsView: View {
    // Use @StateObject to create and manage the lifecycle of the service
    @StateObject private var dataService = LoanLimitsService()

    // State variables for user input
    @State private var inputYear: String = ""//String(Calendar.current.component(.year, from: Date()) - 1) // Default example
    @State private var inputState: String = ""
    @State private var inputCounty: String = ""

    // Computed properties for button disabling
    private var isHistoricalFetchDisabled: Bool {
        dataService.isLoading || inputYear.isEmpty || Int(inputYear) == nil || (Int(inputYear) ?? 0 < 2009 || Int(inputYear) ?? 0 > 2019)
    }

    private var isCountyFetchDisabled: Bool {
        dataService.isLoading || inputState.trimmingCharacters(in: .whitespaces).count != 2 || inputCounty.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section(header: Text("Fetch Loan Limits Data").font(.headline)) {
                        // --- Fetch All ---
                        Button {
                            dataService.fetchData(for: .all)
                        } label: {
                            Label("Fetch All Current Limits", systemImage: "list.bullet.clipboard.fill")
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(dataService.isLoading) // Disable while loading

                        // --- Fetch Historical ---
                        VStack(alignment: .leading) {
                             Text("Fetch Historical by Year (2009-2019 Only)")
                                 .font(.caption)
                             HStack {
                                 TextField("YYYY", text: $inputYear)
                                     .keyboardType(.numberPad)
                                     .textFieldStyle(RoundedBorderTextFieldStyle())
                                     .frame(width: 80)
                                     .onChange(of: inputYear) { newValue in
                                         // Limit input to 4 digits
                                         if newValue.count > 4 {
                                             inputYear = String(newValue.prefix(4))
                                         }
                                     }

                                 Button {
                                     dataService.fetchData(for: .historical(year: inputYear))
                                 } label: {
                                     Label("Fetch", systemImage: "calendar.badge.clock")
                                 }
                                 .buttonStyle(.bordered)
                                 .disabled(isHistoricalFetchDisabled)
                             }
                             if !inputYear.isEmpty && (Int(inputYear) ?? 0 < 2009 || Int(inputYear) ?? 0 > 2019) {
                                 Text("Year must be between 2009 and 2019.")
                                     .font(.caption)
                                     .foregroundColor(.orange)
                             }
                        }

                        // --- Fetch by County ---
                        VStack(alignment: .leading) {
                             Text("Fetch by State & County")
                                 .font(.caption)
                             HStack {
                                 TextField("State (e.g., VA)", text: $inputState)
                                     .textFieldStyle(RoundedBorderTextFieldStyle())
                                     .textInputAutocapitalization(.characters) // Auto-caps state
                                     .onChange(of: inputState) { newValue in
                                         // Limit input to 2 chars
                                          if newValue.count > 2 {
                                              inputState = String(newValue.prefix(2)).uppercased()
                                          } else {
                                              inputState = newValue.uppercased() // Ensure uppercase
                                          }
                                      }
                                     .frame(width: 60)

                                 TextField("County Name", text: $inputCounty)
                                     .textFieldStyle(RoundedBorderTextFieldStyle())
                                     .textInputAutocapitalization(.words) // Capitalize words

                                 Button {
                                      // Trim whitespace before sending
                                     let stateTrimmed = inputState.trimmingCharacters(in: .whitespaces)
                                     let countyTrimmed = inputCounty.trimmingCharacters(in: .whitespaces)
                                     dataService.fetchData(for: .byCounty(state: stateTrimmed, county: countyTrimmed))
                                 } label: {
                                     Label("Fetch", systemImage: "location.magnifyingglass")
                                 }
                                 .buttonStyle(.bordered)
                                 .disabled(isCountyFetchDisabled)
                             }
                        }
                         
                         // --- Clear Data ---
                         Button("Clear Displayed Data", role: .destructive) {
                             dataService.clearLocalData()
                         }
                         .buttonStyle(.bordered)
                         .tint(.orange) // Use tint for destructive-like appearance with bordered style
                         .disabled(dataService.isLoading)
                    } // End Section Fetch Data

                    // --- Results Section ---
                    Section(header: Text("Results").font(.headline)) {
                        if dataService.isLoading {
                             ProgressView("Fetching data...")
                                 .frame(maxWidth: .infinity, alignment: .center)
                        } else if let errorMessage = dataService.errorMessage {
                             Text(errorMessage)
                                 .foregroundColor(.red)
                                 .frame(maxWidth: .infinity, alignment: .center)
                        } else if dataService.loanLimits.isEmpty {
                            Text("No data to display. Use the buttons above to fetch loan limits.")
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.vertical)
                        } else {
                            List {
                                ForEach(dataService.loanLimits) { limit in
                                     LoanLimitRow(loanLimit: limit) // Use a dedicated row view
                                         .padding(.vertical, 4) // Add padding between items
                                 }
                             }
                             // Add a count footer for clarity
                            .overlay(alignment: .bottom) {
                                Text("\(dataService.loanLimits.count) result(s)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.vertical, 4)
                                    .frame(maxWidth: .infinity)
                                    .background(.thinMaterial) // Subtle background
                             }
                        }
                    } // End Section Results
                } // End Form
                .navigationTitle("Fannie Mae Loan Limits")
                 .navigationBarTitleDisplayMode(.inline)
            } // End VStack
            .onAppear {
                // Optional: Fetch initial data if desired, e.g., all limits
                // dataService.fetchData(for: .all)
                
                 // Check if placeholder credentials are still there
                 if LoanLimitsAuthCredentials.clientID == "YOUR_CLIENT_ID_HERE" || LoanLimitsAuthCredentials.clientSecret == "YOUR_CLIENT_SECRET_HERE" {
                     dataService.errorMessage = "Error: Please replace placeholder API credentials in LoanLimitsAuthCredentials."
                 }
            }
        } // End NavigationView
        .navigationViewStyle(.stack) // Use stack style for broader compatibility
    }
}

// MARK: - Loan Limit Row View (for better organization)

struct LoanLimitRow: View {
    let loanLimit: LoanLimit

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                 Text("\(loanLimit.countyName ?? "N/A County"), \(loanLimit.stateCode ?? "N/A")")
                    .font(.headline)
                 Spacer()
                 Text("Year: \(loanLimit.reportingYear.map(String.init) ?? "N/A")")
                     .font(.subheadline)
                     .foregroundColor(.secondary)
            }

             Text("FIPS: \(loanLimit.fipsCode ?? "N/A") | CBSA: \(loanLimit.cbsaNumber ?? "N/A")")
                 .font(.caption)
                 .foregroundColor(.gray)
                 .padding(.bottom, 4)

             if let issuers = loanLimit.issuers, !issuers.isEmpty {
                 // Typically there's only one issuer (FHFA) per entry in this API based on payload
                 ForEach(issuers) { issuer in
                     IssuerView(issuer: issuer)
                 }
             } else {
                 Text("No issuer data available.")
                     .font(.footnote)
                     .foregroundColor(.orange)
             }
        }
    }
 }

// MARK: - Issuer View (displays limits for different units)

struct IssuerView: View {
    let issuer: Issuer

    var body: some View {
         VStack(alignment: .leading, spacing: 4) {
             Text("Issuer: \(issuer.issuerType ?? "Unknown")")
                 .font(.caption.weight(.medium))

             // Using Grid for cleaner alignment
            Grid(alignment: .leading) {
                 GridRow{
                     Text("1 Unit:")
                     Text(formatLimit(issuer.oneUnitLimit))
                 }
                  GridRow{
                     Text("2 Units:")
                     Text(formatLimit(issuer.twoUnitLimit))
                 }
                 GridRow{
                     Text("3 Units:")
                    Text(formatLimit(issuer.threeUnitLimit))
                 }
                 GridRow{
                     Text("4 Units:")
                     Text(formatLimit(issuer.fourUnitLimit))
                 }
             }
             .font(.footnote)
         }
         .padding(.leading, 10) // Indent issuer details slightly
    }

    // Helper to format the currency nicely
    private func formatLimit(_ limit: Int?) -> String {
        guard let limit = limit else { return "N/A" }
        
        let formatter = NumberFormatter()
         formatter.numberStyle = .currency
         formatter.maximumFractionDigits = 0 // No cents needed for these limits
         formatter.currencySymbol = "$"
         
        return formatter.string(from: NSNumber(value: limit)) ?? "\(limit)"
     }
}

// MARK: - Preview Provider

struct LoanLimitsView_Previews: PreviewProvider {
    static var previews: some View {
        // Create mock data for the preview
        let mockIssuer = Issuer(issuerType: "FHFA", oneUnitLimit: 806500, twoUnitLimit: 1032650, threeUnitLimit: 1248150, fourUnitLimit: 1551250)
        let mockLimit1 = LoanLimit(stateCode: "VA", countyName: "Fairfax County", reportingYear: 2025, cbsaNumber: "47900", fipsCode: "51059", issuers: [mockIssuer])
        let mockLimit2 = LoanLimit(stateCode: "CA", countyName: "Los Angeles County", reportingYear: 2025, cbsaNumber: "31080", fipsCode: "06037", issuers: [mockIssuer])
        
        // Create a service instance for the preview
        let previewService = LoanLimitsService()
        previewService.loanLimits = [mockLimit1, mockLimit2] // Populate with mock data
        // previewService.errorMessage = "Sample Error Message for Preview" // Uncomment to test error display
        // previewService.isLoading = true // Uncomment to test loading indicator

        //return LoanLimitsView(dataService: previewService) // Inject the service
        return LoanLimitsView()
    }
}

// MARK: - Optional: Helper Extensions (Example)

 extension String {
     // Simple validation (could be more robust)
     var isValidYear: Bool {
         Int(self) != nil && self.count == 4
     }
     var isValidStateCode: Bool {
         self.count == 2 && self.allSatisfy { $0.isLetter }
     }
 }
