//
//  HERAView.swift
//  MyApp
//
//  Created by Cong Le on 3/23/25.
//
import SwiftUI
import Combine

// MARK: - Data Models

/// Represents a single entry in the HERA data response.
struct HeraData: Decodable, Identifiable {
    var id = UUID() // Add a unique identifier for SwiftUI
    let enterprise: String?
    let msaType: String?
    let censusTractPctMinority: String?
    let tractIncomeRatio: String?
    let borrowerIncomeRatio: String?
    let dateAcquiredVsDateOriginated: String?
    let loanPurpose: String?
    let federalGuarantee: String?
    let sellerInstitutionType: String?
    let borrowerRaceOriginEthnicity: String?
    let coborrowerRaceOriginEthnicity: String?
    let borrowerGender: String?
    let coborrowerGender: String?
    let occupancyCode: String?
    let numberOfUnits: Int?
    let ownerOccupied: String?
    let affordabilityCategory: String?
    let reportingYear: Int?
}

/// Represents the top-level structure for the /all endpoint, including hypermedia links.
struct HeraResponse: Decodable {
    let links: HeraLinks?
    let results: HeraResults
    
    struct HeraResults: Decodable {
        let embedded: [HeraData]?
        
        enum CodingKeys: String, CodingKey {
            case embedded = "_embedded"  //This matches the response that comes from the API server
        }
    }
}

/// Represents the hypermedia links in the HERA response.
struct HeraLinks: Decodable {
    let next: HeraLink? // Only "next" is present in the provided JSON
    //let selfLink: HeraLink?  // Example if there was a self link.
    
    enum CodingKeys: String, CodingKey {
        case next
        //case selfLink = "self"
    }
}

/// Represents an individual hypermedia link.
struct HeraLink: Decodable {
    let href: String?
}

// MARK: - API Endpoint

/// Enum representing the API endpoint (only /all for this task).
enum APIEndpoint {
    case all(page: Int)
    
    var path: String {
        switch self {
        case .all:
            return "/v1/national-file-b/all"
        }
    }
}

// MARK: - API Error

/// Enum for possible API errors.
enum APIError: Error, LocalizedError {
    case invalidURL
    case requestFailed(String)
    case decodingFailed
    case noData
    case authenticationFailed
    case unauthorized
    case forbidden
    case serverError(String)
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid API URL."
        case .requestFailed(let message): return "API request failed: \(message)"
        case .decodingFailed: return "Failed to decode the response."
        case .noData: return "No data was returned."
        case .authenticationFailed: return "Authentication Failed, Check Your Credentials."
        case .unauthorized : return "Unauthorized Access.  Check credentials."
        case .forbidden : return "Forbidden.  Check permissions."
        case .serverError(let message): return "Internal Server Error: \(message)"
        case .unknown(let error): return "An unknown error occurred: \(error.localizedDescription)"
            
        }
    }
}



// MARK: - Authentication (Reusing from previous examples, adapted for error cases)

struct AuthCredentials {
    static let clientID = "clientIDKeyHere"
    static let clientSecret = "clientSecretKeyHere"
}

struct TokenResponse: Decodable {
    let access_token: String
    let token_type: String
    let expires_in: Int
    let scope: String
}

// MARK: - Data Service
// ObservableObject for UI updates
final class HeraDataService: ObservableObject  {
    @Published var heraData: [HeraData] = []  // Directly stores the array of HeraData, removing one layer
    @Published var nextPageURL: String?       // Store the URL for the next page, if available
    @Published var isLoading = false        // Tracks if a network request is in progress.
    @Published var errorMessage: String?      // Stores any error message for display.
    
    private let baseURLString = "https://api.fanniemae.com"  // Base API URL
    private let tokenURL = "https://auth.pingone.com/4c2b23f9-52b1-4f8f-aa1f-1d477590770c/as/token" //Token URL
    private var accessToken: String?  // Holds active access token.
    private var tokenExpiration: Date?  // Holds expiration of the access token
    private var cancellables = Set<AnyCancellable>() // Manages Combine subscriptions.
    
    // MARK: - Token Management
    private func getAccessToken(completion: @escaping (Result<String, APIError>) -> Void) {
        if let token = accessToken, let expiration = tokenExpiration, Date() < expiration {
            completion(.success(token))
            return
        }
        
        guard let url = URL(string: tokenURL) else {
            completion(.failure(.invalidURL))
            return
        }
        
        let credentials = "\(AuthCredentials.clientID):\(AuthCredentials.clientSecret)"
        guard let base64Credentials = credentials.data(using: .utf8)?.base64EncodedString() else {
            completion(.failure(.authenticationFailed)) // Indicate authentication failure.
            return
        }
        
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type") //Corrected Content-Type
        request.httpBody = "grant_type=client_credentials".data(using: .utf8)
        
        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.requestFailed("Invalid response type")
                }
                switch httpResponse.statusCode {
                case 200...299:
                    return data
                case 400:  // Specifically check for bad request, can indicate problems in your request (e.g., invalid credentials)
                    let responseString = String(data: data, encoding: .utf8) ?? "No Response Body"
                    throw APIError.requestFailed("Bad Reqeuest. Response: \(responseString)")
                case 401: // Unauthorized
                    throw APIError.authenticationFailed
                    
                case 403:   //Forbidden
                    throw APIError.forbidden
                case 500...599:       // Server errors
                    let responseString = String(data: data, encoding: .utf8) ?? ""
                    throw APIError.serverError("Server error: \(httpResponse.statusCode), Response: \(responseString)") //Specific error
                    
                default:
                    let responseString = String(data: data, encoding: .utf8) ?? ""
                    throw APIError.requestFailed("Unhandled HTTP Status Code: \(httpResponse.statusCode). Response: \(responseString)")
                }
            }
            .decode(type: TokenResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completionResult in
                switch completionResult {
                case .finished:
                    break
                case .failure(let error):  // All errors handled in sink
                    let apiError = (error as? APIError) ?? APIError.unknown(error)
                    // Error handling unified here.
                    self?.handleError(apiError)   //Consistent Error Handling
                    completion(.failure(apiError))
                }
            } receiveValue: { [weak self] tokenResponse in
                self?.accessToken = tokenResponse.access_token
                // Convert the expiration time from seconds (Int) to a Date.
                self?.tokenExpiration = Date().addingTimeInterval(TimeInterval(tokenResponse.expires_in))
                completion(.success(tokenResponse.access_token)) // Provide token.
            }
            .store(in: &cancellables)
    } // End getAccessToken
    
    
    // MARK: - Data Fetching
    
    func fetchData(for endpoint: APIEndpoint) {
        isLoading = true
        errorMessage = nil //Always reset error on new fetch
        
        getAccessToken { [weak self] result in
            guard let self = self else { return }  // Ensure that self still exisit
            switch result {
            case .success(let token):
                self.makeDataRequest(endpoint: endpoint, accessToken: token)
            case .failure(let error):
                DispatchQueue.main.async { // Main thread to update UI.
                    self.isLoading = false //Clear loading state
                    self.handleError(error)  //Handle token errors
                }
            }
        }
    }
    
    private func makeDataRequest(endpoint: APIEndpoint, accessToken: String) {
        //Construct URL with pagination
        guard let url = URL(string: baseURLString + endpoint.path + "?page=\(pageNumber(for: endpoint))") else
        {
            handleError(.invalidURL)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")  // Corrected header.
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")  // Corrected token.
        
        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in  //Correctly checks for error codes
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.requestFailed("Invalid Response Type")
                }
                
                switch httpResponse.statusCode {
                case 200...299:   // Handle Successful Status Codes
                    return data
                case 401:  // Unauthorized
                    throw APIError.unauthorized
                case 403:    // Forbidden
                    throw APIError.forbidden
                case 404:   //Not Found
                    let responseString = String(data: data, encoding: .utf8) ?? "No Response Body"
                    throw APIError.requestFailed("Resource not found - 404 Not Found. Response: \(responseString)")
                    
                    // Additional handling of Error statuses.
                case 500...599:  // Handle Server Error statuses
                    let body = String(data: data, encoding: .utf8) ?? "No Response Body"
                    throw APIError.serverError("Server Error: \(httpResponse.statusCode) , Details: \(body)")
                    
                default:
                    let responseString = String(data: data, encoding: .utf8) ?? ""
                    throw APIError.requestFailed("Unhandled HTTP Status Code: \(httpResponse.statusCode); Response = \(responseString)")
                }
            }
            .decode(type: HeraResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main) // ensures that any UI updates triggered by changes to @Published properties of  HeraDataService happen on the main thread
            .sink { [weak self] completionResult in
                guard let self = self else { return }
                self.isLoading = false // Ensure loading state is updated
                switch completionResult {
                case .finished:
                    break
                case .failure(let error): // Handle or Report Any Decoding Erros
                    let apiError = (error as? APIError) ?? APIError.unknown(error)
                    self.handleError(apiError)
                    
                }
            } receiveValue: { [weak self] heraResponse in
                guard let self = self else { return }
                
                if let heraData = heraResponse.results.embedded, !heraData.isEmpty
                {
                    self.heraData.append(contentsOf: heraData)
                    
                    // Update the next page URL, using optional chaining and nil coalescing
                    self.nextPageURL = heraResponse.links?.next?.href
                } else {
                    self.handleError(.noData)  //Proper Handling for No-Data Responses.
                }
                
            }
            .store(in: &cancellables)
    }
    
    private func pageNumber(for endpoint: APIEndpoint) -> Int
    {
        switch endpoint {
        case .all( let page):
            return page
        }
    }
    
    // MARK: Utility
    
    // Centralized error handling
    func handleError(_ error: APIError) {
        errorMessage = error.localizedDescription
        print("API Error: \(error.localizedDescription)")
    }
    func clearLocalData() {
        heraData.removeAll()  // Only /all logic
        nextPageURL = nil     // Reset pagination.
    }
}

// MARK: - SwiftUI Views

struct HERAView: View {
    @StateObject private var dataService = HeraDataService()
    @State private var currentPage = 0
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("HERA Data")) {
                    Button("Fetch Initial Data (Page 0)")
                    {
                        dataService.clearLocalData()  // Always clear before fetching.
                        dataService.fetchData(for: .all(page: 0))
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Fetch Next Page")
                    {
                        if let urlString = dataService.nextPageURL,
                           let url = URL(string: urlString),
                           let pageComponent = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems?.first(where: { $0.name == "page" }),
                           let pageValue = pageComponent.value,
                           let nextPage = Int(pageValue)
                        {
                            dataService.fetchData(for: .all(page: nextPage))
                            
                        } else {
                            
                            dataService.handleError(.invalidURL)  // Handle invalid URL case
                        }
                    }
                    .buttonStyle(.bordered)
                    .disabled(dataService.nextPageURL == nil) //Disable if no more pages
                    
                    Button("Clear Data", role: .destructive) {
                        dataService.clearLocalData()
                    }
                }
                Section(header: Text("Results")) {
                    if dataService.isLoading {
                        ProgressView("Loading...")
                    } else if let errorMessage = dataService.errorMessage {
                        Text("Error: \(errorMessage)")
                            .foregroundColor(.red)
                    } else {
                        List(dataService.heraData) { item in
                            VStack(alignment: .leading) {
                                if let val = item.enterprise
                                {
                                    Text("Enterprise:  \(val)")
                                }
                                if let val = item.msaType
                                {
                                    Text("msaType: \(val)")
                                }
                                
                                if let val = item.censusTractPctMinority
                                {
                                    Text("censusTractPctMinority \(val)")
                                }
                                
                                if let val = item.tractIncomeRatio
                                {
                                    Text(" tractIncomeRatio: \(val)")
                                }
                                
                                if let val = item.borrowerIncomeRatio
                                {
                                    Text("borrowerIncomeRatio: \(val)")
                                }
                                
                                if let val = item.dateAcquiredVsDateOriginated
                                {
                                    Text("dateAcquiredVsDateOriginated: \(val)")
                                }
                                
                                if let val = item.loanPurpose
                                {
                                    Text("loanPurpose: \(val)")
                                }
                                if let val =  item.federalGuarantee
                                {
                                    Text("federalGuarantee: \(val)")
                                }
                                
                                if let val =  item.sellerInstitutionType
                                {
                                    Text("sellerInstitutionType: \(val)")
                                }
                                
                                if let val = item.borrowerRaceOriginEthnicity
                                {
                                    Text("borrowerRaceOriginEthnicity:  \(val)")
                                }
                                
                                if let val = item.coborrowerRaceOriginEthnicity
                                {
                                    Text("coborrowerRaceOriginEthnicity: \(val)")
                                }
                                
                                if let val = item.borrowerGender
                                {
                                    Text("borrowerGender:\(val)")
                                }
                                
                                if let val = item.coborrowerGender
                                {
                                    Text("coborrowerGender:  \(val)")
                                }
                                
                                if let val = item.occupancyCode
                                {
                                    Text("occupancyCode: \(val)")
                                }
                                if let val = item.numberOfUnits   {
                                    Text("numberOfUnits:   \(val)")
                                }
                                if let val = item.ownerOccupied
                                {
                                    Text("ownerOccupied:  \(val)")
                                }
                                if let val = item.affordabilityCategory
                                {
                                    Text("affordabilityCategory:\(val)")
                                }
                                if let val = item.reportingYear
                                {
                                    Text("reportingYear:  \(val)")
                                }
                            }
                        }
                    }
                    
                }
                
            }
        }.navigationTitle("HERA Data")
    }
}



// MARK: - Preview
struct HERAView_Previews: PreviewProvider {
    static var previews: some View {
        HERAView()
    }
}
