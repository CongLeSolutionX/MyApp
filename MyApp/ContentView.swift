////
////  ContentView.swift
////  MyApp
////
////  Created by Cong Le on 8/19/24.
////
//
////import SwiftUI
////
////// Step 2: Use in SwiftUI view
////struct ContentView: View {
////    var body: some View {
////        UIKitViewControllerWrapper()
////            .edgesIgnoringSafeArea(.all) /// Ignore safe area to extend the background color to the entire screen
////    }
////}
////
////// Before iOS 17, use this syntax for preview UIKit view controller
////struct UIKitViewControllerWrapper_Previews: PreviewProvider {
////    static var previews: some View {
////        UIKitViewControllerWrapper()
////    }
////}
////
////// After iOS 17, we can use this syntax for preview:
////#Preview {
////    ContentView()
////}
//import SwiftUI
//import Combine
//
//// MARK: - Data Models
//
///// Represents a unified loan performance data item.
//struct LoanPerformanceData: Identifiable, Codable {
//    let id = UUID()
//    let s3Uri: String
//    let year: Int?
//    let quarter: String?
//    let effectiveDate: String?
//    
//    // Initializer for LphDetails (no effective date)
//    init(from details: LphDetails) {
//        self.s3Uri = details.s3Uri
//        self.year = details.year
//        self.quarter = details.quarter
//        self.effectiveDate = nil
//    }
//    
//    // Initializer for LphResponse (has effective date only)
//    init(from response: LphResponse) {
//        self.s3Uri = response.s3Uri
//        self.effectiveDate = response.effectiveDate
//        self.year = nil
//        self.quarter = nil
//    }
//}
//
///// Mirrors the API response where multiple loan detail entries are provided.
//struct LphDetailResponse: Decodable {
//    let effectiveDate: String
//    let lphResponse: [LphDetails]
//}
//
///// Detail information for individual loan performance.
//struct LphDetails: Decodable {
//    let s3Uri: String
//    let year: Int?
//    let quarter: String?
//}
//
///// Single entry response.
//struct LphResponse: Decodable {
//    let s3Uri: String
//    let effectiveDate: String
//}
//
//// MARK: - API Endpoints
//
///// Enumeration for API endpoints used in the service.
//enum APIEndpoint {
//    case yearlyQuarterly(year: Int, quarter: String)
//    case harp
//    case primary
//    
//    var path: String {
//        switch self {
//        case .yearlyQuarterly(let year, let quarter):
//            return "/v1/sf-loan-performance-data/years/\(year)/quarters/\(quarter)"
//        case .harp:
//            return "/v1/sf-loan-performance-data/harp-dataset"
//        case .primary:
//            return "/v1/sf-loan-performance-data/primary-dataset"
//        }
//    }
//}
//
//// MARK: - API Errors
//
///// API error definition for common network / decoding failures.
//enum APIError: Error, LocalizedError {
//    case invalidURL
//    case requestFailed(String)
//    case decodingFailed
//    case noData
//    case authenticationFailed
//    case unknown(Error)
//    
//    var errorDescription: String? {
//        switch self {
//        case .invalidURL:
//            return "Invalid API URL."
//        case .requestFailed(let message):
//            return "API request failed: \(message)"
//        case .decodingFailed:
//            return "Failed to decode the response."
//        case .noData:
//            return "No data was returned."
//        case .authenticationFailed:
//            return "Authentication failed. Please check your credentials."
//        case .unknown(let error):
//            return "An unknown error occurred: \(error.localizedDescription)"
//        }
//    }
//}
//
//// MARK: - Authentication
//
///// IMPORTANT: In an actual production app, never hardcode client credentials.
///// Use secure storage or environment variables instead.
//struct AuthCredentials {
//    static let clientID = "clientIDKeyHere"
//    static let clientSecret = "clientSecretKeyHere"
//}
//
///// Model for the token response from the authentication API.
//struct TokenResponse: Decodable {
//    let access_token: String
//    let token_type: String
//    let expires_in: Int
//    let scope: String
//}
//
//// MARK: - Data Service
//
///// Service responsible for fetching and decoding loan performance data.
//final class LoanPerformanceDataService: ObservableObject {
//    @Published var loanData: [LoanPerformanceData] = []
//    @Published var isLoading = false
//    @Published var errorMessage: String?
//    
//    private let baseURLString = "https://api.fanniemae.com"
//    private let tokenURL = "https://auth.pingone.com/4c2b23f9-52b1-4f8f-aa1f-1d477590770c/as/token"
//    private var accessToken: String?
//    private var tokenExpiration: Date?
//    private var cancellables = Set<AnyCancellable>()
//    
//    // MARK: - Token Management
//    
//    private func getAccessToken(completion: @escaping (Result<String, APIError>) -> Void) {
//        // Return token if still valid.
//        if let token = accessToken, let expiration = tokenExpiration, Date() < expiration {
//            completion(.success(token))
//            return
//        }
//        
//        guard let url = URL(string: tokenURL) else {
//            completion(.failure(.invalidURL))
//            return
//        }
//        
//        let credentials = "\(AuthCredentials.clientID):\(AuthCredentials.clientSecret)"
//        guard let base64Credentials = credentials.data(using: .utf8)?.base64EncodedString() else {
//            completion(.failure(.authenticationFailed))
//            return
//        }
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.addValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")
//        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
//        request.httpBody = "grant_type=client_credentials".data(using: .utf8)
//        
//        URLSession.shared.dataTaskPublisher(for: request)
//            .tryMap { data, response -> Data in
//                guard let httpResponse = response as? HTTPURLResponse,
//                      (200...299).contains(httpResponse.statusCode) else {
//                    let responseString = String(data: data, encoding: .utf8) ?? ""
//                    throw APIError.requestFailed("Invalid response. Response: \(responseString)")
//                }
//                return data
//            }
//            .decode(type: TokenResponse.self, decoder: JSONDecoder())
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] completionResult in
//                switch completionResult {
//                case .finished:
//                    break
//                case .failure(let error):
//                    let apiError = (error as? APIError) ?? APIError.unknown(error)
//                    self?.handleError(apiError)
//                    completion(.failure(apiError))
//                }
//            } receiveValue: { [weak self] tokenResponse in
//                self?.accessToken = tokenResponse.access_token
//                self?.tokenExpiration = Date().addingTimeInterval(TimeInterval(tokenResponse.expires_in))
//                completion(.success(tokenResponse.access_token))
//            }
//            .store(in: &cancellables)
//    }
//    
//    // MARK: - Public API Data Fetching
//    
//    func fetchData(for endpoint: APIEndpoint) {
//        isLoading = true
//        errorMessage = nil
//        
//        getAccessToken { [weak self] result in
//            guard let self = self else { return }
//            switch result {
//            case .success(let token):
//                self.makeDataRequest(endpoint: endpoint, accessToken: token)
//            case .failure(let error):
//                DispatchQueue.main.async {
//                    self.isLoading = false
//                    self.handleError(error)
//                }
//            }
//        }
//    }
//    
//    private func makeDataRequest(endpoint: APIEndpoint, accessToken: String) {
//        
//        guard let url = URL(string: baseURLString + endpoint.path) else {
//            handleError(.invalidURL)
//            return
//        }
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.addValue(accessToken, forHTTPHeaderField: "x-public-access-token")
//        
//        let publisher: AnyPublisher<any Decodable, Error>
//        switch endpoint {
//        case .yearlyQuarterly:
//            publisher = URLSession.shared.dataTaskPublisher(for: request)
//                .tryMap { data, response in
//                    guard let httpResponse = response as? HTTPURLResponse,
//                          (200...299).contains(httpResponse.statusCode) else {
//                        let responseString = String(data: data, encoding: .utf8) ?? "No Response Body"
//                        throw APIError.requestFailed("HTTP Status Code error. Response: \(responseString)")
//                    }
//                    return data
//                }
//                .decode(type: LphDetailResponse.self, decoder: JSONDecoder())
//                .map { $0 as Decodable }
//                .eraseToAnyPublisher()
//        default:
//            publisher = URLSession.shared.dataTaskPublisher(for: request)
//                .tryMap { data, response in
//                    guard let httpResponse = response as? HTTPURLResponse,
//                          (200...299).contains(httpResponse.statusCode) else {
//                        let responseString = String(data: data, encoding: .utf8) ?? "No Response Body"
//                        throw APIError.requestFailed("HTTP Status Code error. Response: \(responseString)")
//                    }
//                    return data
//                }
//                .decode(type: LphResponse.self, decoder: JSONDecoder())
//                .map { $0 as any Decodable }
//                .eraseToAnyPublisher()
//        }
//        
//    }
//    
//    /// Determines the expected type for decoding based on the API endpoint.
//    private func determineResponseType(for endpoint: APIEndpoint) -> Decodable.Type {
//        switch endpoint {
//        case .yearlyQuarterly:
//            return LphDetailResponse.self
//        case .harp, .primary:
//            return LphResponse.self
//        }
//    }
//    
//    // MARK: - Error Handling
//    
//    private func handleError(_ error: APIError) {
//        errorMessage = error.localizedDescription
//        print("API Error: \(error.localizedDescription)")
//    }
//    
//    /// Clears any locally stored data.
//    func clearLocalData() {
//        loanData.removeAll()
//    }
//}
//
//// MARK: - SwiftUI Views
//
//struct ContentView: View {
//    @StateObject private var dataService = LoanPerformanceDataService()
//    @State private var selectedYear: Int = Calendar.current.component(.year, from: Date())
//    @State private var selectedQuarter: String = "Q1"
//    
//    private let quarters = ["Q1", "Q2", "Q3", "Q4", "All"]
//    private var availableYears: [Int] {
//        let startYear = 2000
//        let currentYear = Calendar.current.component(.year, from: Date())
//        return Array(startYear...currentYear)
//    }
//    
//    var body: some View {
//        NavigationView {
//            Form {
//                Section(header: Text("Data Selection")) {
//                    Picker("Year", selection: $selectedYear) {
//                        ForEach(availableYears, id: \.self) { year in
//                            Text("\(year)").tag(year)
//                        }
//                    }
//                    Picker("Quarter", selection: $selectedQuarter) {
//                        ForEach(quarters, id: \.self) { quarter in
//                            Text(quarter).tag(quarter)
//                        }
//                    }
//                    
//                    // Buttons for different endpoints with consistent styling
//                    Button("Fetch Yearly/Quarterly Data") {
//                        dataService.fetchData(for: .yearlyQuarterly(year: selectedYear, quarter: selectedQuarter))
//                    }
//                    .buttonStyle(.bordered)
//                    
//                    Button("Fetch HARP Data") {
//                        dataService.fetchData(for: .harp)
//                    }
//                    .buttonStyle(.bordered)
//                    
//                    Button("Fetch Primary Data") {
//                        dataService.fetchData(for: .primary)
//                    }
//                    .buttonStyle(.borderedProminent)
//                    
//                    Button("Clear Data", role: .destructive) {
//                        dataService.clearLocalData()
//                    }
//                }
//                
//                Section(header: Text("Loan Performance Data")) {
//                    if dataService.isLoading {
//                        ProgressView("Loading...")
//                    } else if let errorMessage = dataService.errorMessage {
//                        Text("Error: \(errorMessage)")
//                            .foregroundColor(.red)
//                    } else {
//                        // Display list of loan performance items.
//                        List(dataService.loanData) { item in
//                            VStack(alignment: .leading, spacing: 4) {
//                                Text("S3 URI: \(item.s3Uri)")
//                                    .font(.caption)
//                                if let year = item.year {
//                                    Text("Year: \(year)")
//                                }
//                                if let quarter = item.quarter {
//                                    Text("Quarter: \(quarter)")
//                                }
//                                if let effectiveDate = item.effectiveDate {
//                                    Text("Effective Date: \(effectiveDate)")
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//            .navigationTitle("Fannie Mae Data")
//        }
//    }
//}
//
//// MARK: - Preview
//
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
