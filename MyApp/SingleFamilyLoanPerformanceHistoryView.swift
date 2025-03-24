//
//  SingleFamilyLoanPerformanceHistoryView.swift
//  MyApp
//
//  Created by Cong Le on 3/23/25.
//

import SwiftUI
import Combine

// MARK: - Data Models

/// Unified model representing loan performance data.
struct LoanPerformanceData: Identifiable, Codable {
    let id = UUID()
    let s3Uri: String
    let year: Int?
    let quarter: String?
    let effectiveDate: String?

    // Initializer for LphDetails (used with /years/{year}/quarters/{quarter})
    init(from details: LphDetails) {
        self.s3Uri = details.s3Uri
        self.year = details.year
        self.quarter = details.quarter
        self.effectiveDate = nil // No effective date in LphDetails
    }

    // Initializer for LphResponse (used with /harp-dataset and /primary-dataset)
    init(from response: LphResponse) {
        self.s3Uri = response.s3Uri
        self.effectiveDate = response.effectiveDate
        self.year = nil
        self.quarter = nil
    }
}

/// Represents the API response for the /years/{year}/quarters/{quarter} endpoint.
struct LphDetailResponse: Decodable {
    let effectiveDate: String
    let lphResponse: [LphDetails]
}

/// Represents individual loan details within the LphDetailResponse.
struct LphDetails: Decodable {
    let s3Uri: String
    let year: Int?
    let quarter: String?
}

/// Represents the API response for the /harp-dataset and /primary-dataset endpoints.
struct LphResponse: Decodable {
    let s3Uri: String
    let effectiveDate: String
}

// MARK: - API Endpoints

/// Enum defining the available API endpoints.
enum SingleFamilyLoanPerformanceHistoryAPIEndpoint {
    case yearlyQuarterly(year: Int, quarter: String)
    case harp
    case primary

    var path: String {
        switch self {
        case .yearlyQuarterly(let year, let quarter):
            return "/v1/sf-loan-performance-data/years/\(year)/quarters/\(quarter)"
        case .harp:
            return "/v1/sf-loan-performance-data/harp-dataset"
        case .primary:
            return "/v1/sf-loan-performance-data/primary-dataset"
        }
    }
}

// MARK: - API Errors

/// Enum defining possible API errors.
enum SingleFamilyLoanPerformanceHistoryAPIError: Error, LocalizedError {
    case invalidURL
    case requestFailed(String)
    case decodingFailed
    case noData
    case authenticationFailed
    case unknown(Error)
    case rateLimitExceeded // Added for rate limiting

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
            return "Authentication failed. Please check your credentials."
        case .unknown(let error):
            return "An unknown error occurred: \(error.localizedDescription)"
        case .rateLimitExceeded:
            return "API rate limit exceeded. Please try again later."
        }
    }
}

// MARK: - Authentication

/// Struct storing API credentials.  SECURITY NOTE:  Replace with secure storage.
struct SingleFamilyLoanPerformanceHistoryAuthCredentials {
    static let clientID = "clientIDKeyHere" // Replace with your actual client ID
    static let clientSecret = "clientSecretKeyHere" // Replace with your actual client secret
}

/// Model for the authentication token response.
struct SingleFamilyLoanPerformanceHistoryTokenResponse: Decodable {
    let access_token: String
    let token_type: String
    let expires_in: Int
    let scope: String
}

// MARK: - Data Service

/// Service class for fetching and managing loan performance data.
final class LoanPerformanceDataService: ObservableObject {
    @Published var loanData: [LoanPerformanceData] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let baseURLString = "https://api.fanniemae.com"
    private let tokenURL = "https://auth.pingone.com/4c2b23f9-52b1-4f8f-aa1f-1d477590770c/as/token" //Fannie Mae Auth server.
    private var accessToken: String?
    private var tokenExpiration: Date?
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Token Management
    /// Retrieves an access token, either from cache or by requesting a new one.
    private func getAccessToken(completion: @escaping (Result<String, SingleFamilyLoanPerformanceHistoryAPIError>) -> Void) {
        // Check if we have a valid cached token
        if let token = accessToken, let expiration = tokenExpiration, Date() < expiration {
            completion(.success(token))
            return
        }

        guard let url = URL(string: tokenURL) else {
            completion(.failure(.invalidURL))
            return
        }

        // Encode credentials for Basic Authorization
        let credentials = "\(SingleFamilyLoanPerformanceHistoryAuthCredentials.clientID):\(SingleFamilyLoanPerformanceHistoryAuthCredentials.clientSecret)"
        guard let base64Credentials = credentials.data(using: .utf8)?.base64EncodedString() else {
            completion(.failure(.authenticationFailed))
            return
        }

        // Prepare the token request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = "grant_type=client_credentials".data(using: .utf8)

        // Make the token request using URLSession's dataTaskPublisher
        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw SingleFamilyLoanPerformanceHistoryAPIError.requestFailed("Invalid HTTP response")
                }
                
                // Added to check for rate limit (HTTP 429)
                if httpResponse.statusCode == 429 {
                    throw SingleFamilyLoanPerformanceHistoryAPIError.rateLimitExceeded
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                     let responseString = String(data: data, encoding: .utf8) ?? "No Response Body"
                     throw SingleFamilyLoanPerformanceHistoryAPIError.requestFailed("HTTP Status Code error. Response: \(responseString)")
                }
                return data
            }
            .decode(type: SingleFamilyLoanPerformanceHistoryTokenResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completionResult in
                switch completionResult {
                case .finished:
                    break
                case .failure(let error):
                    let apiError = (error as? SingleFamilyLoanPerformanceHistoryAPIError) ?? SingleFamilyLoanPerformanceHistoryAPIError.unknown(error)
                    self?.handleError(apiError)
                    completion(.failure(apiError))
                }
            } receiveValue: { [weak self] tokenResponse in
                self?.accessToken = tokenResponse.access_token
                // Set token expiration time (subtracting a small buffer for safety)
                self?.tokenExpiration = Date().addingTimeInterval(TimeInterval(tokenResponse.expires_in - 60))
                completion(.success(tokenResponse.access_token))
            }
            .store(in: &cancellables)
    }

    // MARK: - Public API for Fetching Data
    /// Fetches data for a given API endpoint.
    func fetchData(for endpoint: SingleFamilyLoanPerformanceHistoryAPIEndpoint) {
        isLoading = true
        errorMessage = nil
        
        // Clear previous data
        loanData.removeAll()

        getAccessToken { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let token):
                self.makeDataRequest(endpoint: endpoint, accessToken: token)
            case .failure(let error):
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.handleError(error)
                }
            }
        }
    }

    // MARK: - Private Network Request Logic
      /// Makes the actual data request to the API.
      private func makeDataRequest(endpoint: SingleFamilyLoanPerformanceHistoryAPIEndpoint, accessToken: String) {
         guard let url = URL(string: baseURLString + endpoint.path) else {
             handleError(.invalidURL)
             return
          }

         var request = URLRequest(url: url)
         request.httpMethod = "GET"
         request.addValue("application/json", forHTTPHeaderField: "Content-Type")
         request.addValue(accessToken, forHTTPHeaderField: "x-public-access-token") // Custom header for Fannie Mae.
         
         // Use a single publisher pipeline with generics for different response types
         let publisher: AnyPublisher<any Decodable, Error>
         switch endpoint {
         case .yearlyQuarterly:
             publisher = URLSession.shared.dataTaskPublisher(for: request)
                 .tryMap { data, response in
                      guard let httpResponse = response as? HTTPURLResponse else {
                         throw SingleFamilyLoanPerformanceHistoryAPIError.requestFailed("Invalid HTTP response")
                      }
                      if httpResponse.statusCode == 429 {
                             throw SingleFamilyLoanPerformanceHistoryAPIError.rateLimitExceeded
                         }
                         guard (200...299).contains(httpResponse.statusCode) else {
                         let responseString = String(data: data, encoding: .utf8) ?? "No Response Body"
                          throw SingleFamilyLoanPerformanceHistoryAPIError.requestFailed("HTTP Status Code error. Response: \(responseString)")
                      }
                    return data
                  }
                 .decode(type: LphDetailResponse.self, decoder: JSONDecoder()) // Decode to LphDetailResponse
                 .map { $0 as Decodable } // Cast to Decodable for generic handling
                 .eraseToAnyPublisher() // Type erasure
         case .harp, .primary:
               publisher = URLSession.shared.dataTaskPublisher(for: request)
                     .tryMap { data, response in
                        guard let httpResponse = response as? HTTPURLResponse else {
                           throw SingleFamilyLoanPerformanceHistoryAPIError.requestFailed("Invalid HTTP response")
                        }
                           if httpResponse.statusCode == 429 {
                             throw SingleFamilyLoanPerformanceHistoryAPIError.rateLimitExceeded
                           }
                           guard (200...299).contains(httpResponse.statusCode) else {
                           let responseString = String(data: data, encoding: .utf8) ?? "No Response Body"
                           throw SingleFamilyLoanPerformanceHistoryAPIError.requestFailed("HTTP Status Code error. Response: \(responseString)")
                        }
                      return data
                     }
                     .decode(type: LphResponse.self, decoder: JSONDecoder())// Decode to LphResponse
                     .map { $0 as any Decodable } // Cast to Decodable for generic handling
                     .eraseToAnyPublisher()  // Type erasure.
           }
          
          publisher
              .receive(on: DispatchQueue.main)
              .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else {return}
                  self.isLoading = false
                  switch completion {
                  case .finished:
                      break
                  case .failure(let error):
                      let apiError = (error as? SingleFamilyLoanPerformanceHistoryAPIError) ?? SingleFamilyLoanPerformanceHistoryAPIError.unknown(error)
                       self.handleError(apiError)
                  }
              }, receiveValue: { [weak self] decodedResponse in
                guard let self = self else {return}
                self.isLoading = false
                switch decodedResponse {
                        case let detailResponse as LphDetailResponse:
                          // Transform LphDetails into LoanPerformanceData
                          let newData = detailResponse.lphResponse.map { LoanPerformanceData(from: $0) }
                            self.loanData.append(contentsOf: newData) // Append new data
                  

                         case let singleResponse as LphResponse:
                             // Transform LphResponse into LoanPerformanceData
                             let newData = LoanPerformanceData(from: singleResponse)
                                self.loanData.append(newData) // Append new data
                          default:
                              print("Unexpected response type: \(type(of: decodedResponse))")
                            }
              })
             .store(in: &cancellables) // Essential for managing the subscription's lifecycle
      }

    // MARK: - Error Handling
    /// Centralized error handling function.
    private func handleError(_ error: SingleFamilyLoanPerformanceHistoryAPIError) {
        errorMessage = error.localizedDescription
        print("API Error: \(error.localizedDescription)")
    }
    
    // Add a cancel request method.
     func cancelRequest() {
         cancellables.forEach { $0.cancel() } // Cancel all active network requests
         cancellables.removeAll()
         isLoading = false
     }

    /// Clear the data
    func clearLocalData() {
        loanData.removeAll()
    }
}

// MARK: - SwiftUI Views

/// Main content view of the application.
struct SingleFamilyLoanPerformanceHistoryView: View {
    @StateObject private var dataService = LoanPerformanceDataService()
    @State private var selectedYear: Int = Calendar.current.component(.year, from: Date())
    @State private var selectedQuarter: String = "Q1"
    @State private var isFetching = false // Tracks if a fetch is in progress
    private let quarters = ["Q1", "Q2", "Q3", "Q4", "All"]
    
    private var availableYears: [Int] {
        let startYear = 2000 // API starts from 2000
        // Get current year.
        let currentYear = Calendar.current.component(.year, from: Date())
        return Array(startYear...currentYear)
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Data Selection")) {
                    Picker("Year", selection: $selectedYear) {
                        ForEach(availableYears, id: \.self) { year in
                            Text("\(year)").tag(year)
                        }
                    }

                    Picker("Quarter", selection: $selectedQuarter) {
                        ForEach(quarters, id: \.self) { quarter in
                            Text(quarter).tag(quarter)
                        }
                    }

                    // Fetch Yearly/Quarterly Data Button
                    Button("Fetch Yearly/Quarterly Data") {
                        
                        dataService.fetchData(for: .yearlyQuarterly(year: selectedYear, quarter: selectedQuarter))
                    }
                    .buttonStyle(.bordered)

                    // Fetch HARP Data Button
                    Button("Fetch HARP Data") {
                        
                        dataService.fetchData(for: .harp)
                    }
                    .buttonStyle(.bordered)

                    // Fetch Primary Data Button
                    Button("Fetch Primary Data") {
                        
                        dataService.fetchData(for: .primary)
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("Clear Data", role: .destructive) {
                         dataService.clearLocalData()
                    }
                }

                Section(header: Text("Loan Performance Data")) {
                    if dataService.isLoading {
                        ProgressView("Loading...")
                    } else if let errorMessage = dataService.errorMessage {
                        Text("Error: \(errorMessage)")
                            .foregroundColor(.red)
                    } else {
                        List(dataService.loanData) { item in
                            VStack(alignment: .leading) {
                                Text("S3 URI: \(item.s3Uri)")
                                    .font(.caption)
                                if let year = item.year {
                                    Text("Year: \(year)")
                                }
                                if let quarter = item.quarter {
                                    Text("Quarter: \(quarter)")
                                }
                                if let effectiveDate = item.effectiveDate {
                                    Text("Effective Date: \(effectiveDate)")
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Fannie Mae Data")
            .onDisappear { // To handle cancel request when goes to background.
                dataService.cancelRequest()
            }
        }
    }
}

// MARK: - Preview
struct SingleFamilyLoanPerformanceHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        SingleFamilyLoanPerformanceHistoryView()
    }
}
