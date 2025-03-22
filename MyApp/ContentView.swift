//
//  ContentView.swift
//  MyApp
//
//  Created by Cong Le on 8/19/24.
//

//import SwiftUI
//
//// Step 2: Use in SwiftUI view
//struct ContentView: View {
//    var body: some View {
//        UIKitViewControllerWrapper()
//            .edgesIgnoringSafeArea(.all) /// Ignore safe area to extend the background color to the entire screen
//    }
//}
//
//// Before iOS 17, use this syntax for preview UIKit view controller
//struct UIKitViewControllerWrapper_Previews: PreviewProvider {
//    static var previews: some View {
//        UIKitViewControllerWrapper()
//    }
//}
//
//// After iOS 17, we can use this syntax for preview:
//#Preview {
//    ContentView()
//}
import SwiftUI
import Combine

// MARK: - Data Models

struct LoanPerformanceData: Identifiable, Codable {
    let id = UUID()
    let s3Uri: String
    let year: Int?
    let quarter: String?
    let effectiveDate: String? // For LphDetailResponse

    // Custom initializer to handle both LphDetails and LphResponse
    init(from details: LphDetails) {
        self.s3Uri = details.s3Uri
        self.year = details.year
        self.quarter = details.quarter
        self.effectiveDate = nil // Not applicable for individual details
    }

    init(from response: LphResponse) {
        self.s3Uri = response.s3Uri
        self.effectiveDate = response.effectiveDate
        self.year = nil
        self.quarter = nil
    }
}

// Structs for API response decoding.  Mirrors the OpenAPI spec.
struct LphDetailResponse: Decodable {
    let effectiveDate: String
    let lphResponse: [LphDetails]
}

struct LphDetails: Decodable {
    let s3Uri: String
    let year: Int?
    let quarter: String?
}

struct LphResponse: Decodable {
    let s3Uri: String
    let effectiveDate: String
}

// MARK: - Enums for API Endpoints

enum APIEndpoint {
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


// MARK: - Error Handling

enum APIError: Error, LocalizedError {
    case invalidURL
    case requestFailed(String) // Include error message from API
    case decodingFailed
    case noData
    case authenticationFailed
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL."
        case .requestFailed(let message):
            return "API request failed: \(message)"
        case .decodingFailed:
            return "Failed to decode the response."
        case .noData:
            return "No data found for the given parameters."
        case .authenticationFailed:
            return "Authentication failed. Please check your credentials."
        case .unknown(let error):
            return "An unknown error occurred: \(error.localizedDescription)"
        }
    }
}

// MARK: - Authentication Data

//  CRITICAL: In a production app, NEVER store client ID and secret directly in code.
//  Use environment variables or, even better, a secure key management service.
// This is ONLY for demonstration and MUST be replaced with a secure approach.
struct AuthCredentials {
    static let clientID = "clientIDKeyHere"
    static let clientSecret = "clientSecretKeyHere"
}

// MARK: - Token Response Model

struct TokenResponse: Decodable {
    let access_token: String
    let token_type: String
    let expires_in: Int
    let scope: String
}



// MARK: - Data Service (with Network Requests)

class LoanPerformanceDataService: ObservableObject {
    @Published var loanData: [LoanPerformanceData] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let baseURLString = "https://api.fanniemae.com"
    private let tokenURL = "https://auth.pingone.com/4c2b23f9-52b1-4f8f-aa1f-1d477590770c/as/token"  // For token requests
    private var accessToken: String?
    private var tokenExpiration: Date?
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Token Management

        private func getAccessToken(completion: @escaping (Result<String, APIError>) -> Void) {
            // Check if we have a valid, unexpired token
            if let token = accessToken, let expiration = tokenExpiration, Date() < expiration {
                completion(.success(token))
                return
            }

            // Prepare the request
            guard let url = URL(string: tokenURL) else {
                completion(.failure(.invalidURL))
                return
            }
            
            let credentials = "\(AuthCredentials.clientID):\(AuthCredentials.clientSecret)"
            guard let base64Credentials = credentials.data(using: .utf8)?.base64EncodedString() else {
                completion(.failure(.authenticationFailed))
                return // Could not encode.
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")
            request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-type")
            request.httpBody = "grant_type=client_credentials".data(using: .utf8)
            
            URLSession.shared.dataTaskPublisher(for: request)
                .tryMap { data, response in
                    guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                         let responseString = String(data: data, encoding: .utf8) ?? ""
                        throw APIError.requestFailed("Invalid response or status code. Response = \(responseString)")
                    }
                    return data
                }
            
                .decode(type: TokenResponse.self, decoder: JSONDecoder())
                .receive(on: DispatchQueue.main) // Switch back to the main thread for UI updates
                .sink { [weak self] receiveCompletion in
                    switch receiveCompletion {
                    case .finished:
                        break
                    case .failure(let error):
                        if let apiError = error as? APIError {
                                    self?.handleError(apiError)  // More specific
                                    completion(.failure(apiError)) // Propagate
                                } else {
                                    let unknown = APIError.unknown(error)
                                    self?.handleError(unknown)
                                    completion(.failure(unknown))
                                }
                    }
                } receiveValue: { [weak self] tokenResponse in
                    self?.accessToken = tokenResponse.access_token
                    // Calculate the expiration date (current time + expires_in seconds)
                    self?.tokenExpiration = Date().addingTimeInterval(TimeInterval(tokenResponse.expires_in))
                    completion(.success(tokenResponse.access_token))
                }
                .store(in: &cancellables) // Prevent memory leaks
        }


    // MARK: - Public API Data Fetching Methods

    func fetchData(for endpoint: APIEndpoint) {
        isLoading = true
        errorMessage = nil

        getAccessToken { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let token):
                // Now that you have the token, construct and make the data request.
                self.makeDataRequest(endpoint: endpoint, accessToken: token)
            case .failure(let error):
                DispatchQueue.main.async {
                    self.isLoading = false
                   self.handleError(error) // Display auth error to user.
                }
            }
        }
    }

    private func makeDataRequest(endpoint: APIEndpoint, accessToken: String) {
        guard let url = URL(string: baseURLString + endpoint.path) else {
            handleError(.invalidURL)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(accessToken, forHTTPHeaderField: "x-public-access-token") // Correct header

        URLSession.shared.dataTaskPublisher(for: request)
        .tryMap { data, response in
              guard let httpResponse = response as? HTTPURLResponse else {
               throw APIError.requestFailed("Invalid response")

                }
                if httpResponse.statusCode == 401 { // Unauthorized
                 throw APIError.authenticationFailed

                 }

                  guard (200...299).contains(httpResponse.statusCode) else {
                      let responseString = String(data: data, encoding: .utf8) ?? "No Response Body"
                       print("full data \(data)")
                      throw APIError.requestFailed("HTTP Status Code: \(httpResponse.statusCode). Response: \(responseString)")
                    }
                return data
              }
            .decode(type: self.determineResponseType(for: endpoint), decoder: JSONDecoder()) // Dynamic Decoding
             .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else {return} // Ensure self is still valid
             self.isLoading = false
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                     if let apiError = error as? APIError {
                        self.handleError(apiError) // Already handled.
                      } else {
                        self.handleError(.unknown(error))
                      }
                }
            } receiveValue: { [weak self] response in
             guard let self = self else {return} // Ensure self is still valid
                // Handle different response types.
                switch response {
                case let detailResponse as LphDetailResponse:
                   self.loanData = detailResponse.lphResponse.map { LoanPerformanceData(from: $0) }
                case let singleResponse as LphResponse:
                   self.loanData = [LoanPerformanceData(from: singleResponse)]
                default:
                   print("Unexpected response type.")
                   self.handleError(.decodingFailed)  //  This is important

                }
            }
            .store(in: &cancellables)
    }


        private func determineResponseType(for endpoint: APIEndpoint) -> Decodable.Type {
            switch endpoint {
            case .yearlyQuarterly:
                return LphDetailResponse.self
            case .harp, .primary:
                return LphResponse.self
            }
        }



    private func handleError(_ error: APIError) {
        errorMessage = error.localizedDescription
         print("API Error: \(error)") // Log for debugging.

    }

    //Clear local data.  For this example, it clears the fetched data. In a real app, might clear cached tokens.
    func clearLocalData() {
        loanData = []
    }
}


// MARK: - SwiftUI Views

struct ContentView: View {
    @StateObject private var dataService = LoanPerformanceDataService()
    @State private var selectedYear: Int = Calendar.current.component(.year, from: Date())
    @State private var selectedQuarter: String = "Q1"
    private let quarters = ["Q1", "Q2", "Q3", "Q4", "All"]
      private var availableYears: [Int] {
           // Generate a range of years, e.g., from 2000 to the current year.
           let startYear = 2000
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

                    Button("Fetch Yearly/Quarterly Data") {
                        dataService.fetchData(for: .yearlyQuarterly(year: selectedYear, quarter: selectedQuarter))
                    }

                    Button("Fetch HARP Data") {
                        dataService.fetchData(for: .harp)
                    }
                    .buttonStyle(.bordered)

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
                        ProgressView()
                    } else if let errorMessage = dataService.errorMessage {
                        Text("Error: \(errorMessage)")
                            .foregroundColor(.red)
                    } else {
                        List(dataService.loanData) { data in
                            VStack(alignment: .leading) {
                                Text("S3 URI: \(data.s3Uri)")
                                    .font(.caption)
                                if let year = data.year {
                                      Text("Year:  \(String(describing: year))")
                                }
                                if let quarter = data.quarter {
                                    Text("Quarter: \(quarter)")
                                }
                                if let effectDate = data.effectiveDate {
                                  Text("Effective Date: \(effectDate)")
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Fannie Mae Data")
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
