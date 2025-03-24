//
//  OpportunityZonesView.swift
//  MyApp
//
//  Created by Cong Le on 3/23/25.
//
//
import SwiftUI
import Combine

// MARK: - Data Models

/// Represents the result of an address check against Opportunity Zones.
struct OpportunityZoneCheckResult: Identifiable, Decodable {
    var id = UUID()
    let streetAddress: String
    let city: String
    let state: String
    let zip: String
    let result: Result
    
    struct Result: Decodable {
        let resultStatus: String
        let belongsToOpportunityZones: String
        let censusTractNumber: String? // Optional
        let category: String?          // Optional
    }
    
    // Computed property for presentation logic.
    var isInOpportunityZone: Bool {
        return result.belongsToOpportunityZones.lowercased() == "yes"
    }
}

/// Represents a collection of addresses.  Useful for the bulk check request.
struct AddressCollection: Encodable {
    let addresses: [Address]
    struct Address: Encodable {
        let number: String
        let street: String
        let city: String
        let state: String
        let zip: String
    }
}

// Response model for the bulk address check endpoint.
struct AddressCollectionResponse: Decodable {
    let addressList: [OpportunityZoneCheckResult]  // Directly use the model.
}


/// Represents a census tract.
struct OpportunityZone: Identifiable, Decodable {
    var id = UUID() // Unique identifier.
    let state: String
    let county: String
    let censusTractNumber: String
    let tractType: String
    let acsDataSource: String
}

/// Represents the response for the /censustracts endpoint.
struct OpportunityZoneCollection: Decodable {
    let opportunityZoneList: [OpportunityZone]
}

// MARK: - API Endpoints

/// Enumerates the available API endpoints and their parameters.
enum OpportunityZonesAPIEndpoint {
    case singleAddressCheck(number: String, street: String, city: String, state: String, zip: String)
    case bulkAddressCheck(addresses: [AddressCollection.Address])
    case censusTracts(state: String, county: String?)
    
    var path: String {
        switch self {
        case .singleAddressCheck:
            return "/v1/opportunity-zones/addresscheck"
        case .bulkAddressCheck:
            return "/v1/opportunity-zones/addressvalidation"
        case .censusTracts:
            return "/v1/opportunity-zones/censustracts"
        }
    }
    
    var queryItems: [URLQueryItem]? {
        switch self {
        case .singleAddressCheck(let number, let street, let city, let state, let zip):
            return [
                URLQueryItem(name: "number", value: number),
                URLQueryItem(name: "street", value: street),
                URLQueryItem(name: "city", value: city),
                URLQueryItem(name: "state", value: state),
                URLQueryItem(name: "zip", value: zip)
            ]
        case .censusTracts(let state, let county):
            var items = [URLQueryItem(name: "state", value: state)]
            if let county = county {
                items.append(URLQueryItem(name: "county", value: county))
            }
            return items
        case .bulkAddressCheck:
            return nil // No query items - data is in the request body.
        }
    }
    
    // Explicitly define HTTP methods for different operations.
    var httpMethod: String {
        switch self {
        case .singleAddressCheck, .censusTracts:
            return "GET"
        case .bulkAddressCheck:
            return "POST"
        }
    }
}

// MARK: - API Errors

/// Defines the possible errors, including a rate limit error.
enum OpportunityZonesAPIError: Error, LocalizedError {
    case invalidURL
    case requestFailed(String)
    case decodingFailed
    case noData
    case authenticationFailed
    case unknown(Error)
    case rateLimitExceeded // Now included.
    
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
struct OpportunityZonesAuthCredentials {
    static let clientID = "clientIDKeyHere"
    static let clientSecret = "clientSecretKeyHere"
}

struct OpportunityZonesAPI_TokenResponse: Decodable {
    let access_token: String
    let token_type: String
    let expires_in: Int
    let scope: String
}
// MARK: - Data Service

/// Service for fetching and managing Opportunity Zone data.
final class OpportunityZoneService: ObservableObject {
    @Published var results: [OpportunityZoneCheckResult] = []
    @Published var censusTracts: [OpportunityZone] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let baseURLString = "https://api.fanniemae.com"
    private let tokenURL = "https://auth.pingone.com/4c2b23f9-52b1-4f8f-aa1f-1d477590770c/as/token"  //Fannie Mae Auth server.
    private var accessToken: String?
    private var tokenExpiration: Date?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Token Management
    /// Retrieves an access token, either from cache or by requesting a new one.
    private func getAccessToken(completion: @escaping (Result<String, OpportunityZonesAPIError>) -> Void) {
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
        let credentials = "\(OpportunityZonesAuthCredentials.clientID):\(OpportunityZonesAuthCredentials.clientSecret)"
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
                    throw OpportunityZonesAPIError.requestFailed("Invalid HTTP response")
                }
                // Check for rate limit (HTTP 429)
                if httpResponse.statusCode == 429 {
                    throw OpportunityZonesAPIError.rateLimitExceeded
                }
                guard (200...299).contains(httpResponse.statusCode) else {
                    let responseString = String(data: data, encoding: .utf8) ?? "No Response Body"
                    throw OpportunityZonesAPIError.requestFailed("HTTP Status Code error. Response: \(responseString)")
                }
                return data
            }
            .decode(type: OpportunityZonesAPI_TokenResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completionResult in
                print(completionResult)
                switch completionResult {
                case .finished:
                    break
                case .failure(let error):
                    let apiError = (error as? OpportunityZonesAPIError) ?? OpportunityZonesAPIError.unknown(error)
                    self?.handleError(apiError)
                    completion(.failure(apiError))
                }
            } receiveValue: { [weak self] tokenResponse in
                self?.accessToken = tokenResponse.access_token
                // Set token expiration time (subtracting a buffer).
                self?.tokenExpiration = Date().addingTimeInterval(TimeInterval(tokenResponse.expires_in - 60))
                completion(.success(tokenResponse.access_token))
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public API
    /// Public method to fetch data based on a specified endpoint
    func fetchData(for endpoint: OpportunityZonesAPIEndpoint) {
        isLoading = true
        errorMessage = nil
        results = []           // Clear the previous results
        censusTracts = []   // Clear the previous census tracts
        
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
    
    /// Makes the actual API request using the provided access token.
    private func makeDataRequest(endpoint: OpportunityZonesAPIEndpoint, accessToken: String) {
        
        var request: URLRequest
        
        switch endpoint {
        case .bulkAddressCheck(let addresses):
            guard let url = URL(string: baseURLString + endpoint.path) else {
                handleError(.invalidURL)
                return
            }
            request = URLRequest(url: url)
            request.httpMethod = endpoint.httpMethod // Should be "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue(accessToken, forHTTPHeaderField: "x-public-access-token") // Custom header.
            
            
            let addressCollection = AddressCollection(addresses: addresses)
            do {
                request.httpBody = try JSONEncoder().encode(addressCollection)
            } catch {
                handleError(.requestFailed("Could not encode addresses for bulk check. \(error.localizedDescription)"))
                return
            }
            
            
        case .singleAddressCheck, .censusTracts:
            guard let url = buildURL(for: endpoint) else {
                handleError(.invalidURL)
                return
            }
            request = URLRequest(url: url)
            request.httpMethod = endpoint.httpMethod // Should be "GET"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue(accessToken, forHTTPHeaderField: "x-public-access-token")  // Custom header.
        }
        
        // Use a single publisher pipeline with generics for different response types
        let publisher: AnyPublisher<any Decodable, Error>
        
        switch endpoint {
        case .singleAddressCheck:
            publisher = URLSession.shared.dataTaskPublisher(for: request)
                .tryMap { data, response in
                    guard let httpResponse = response as? HTTPURLResponse else {
                        throw OpportunityZonesAPIError.requestFailed("Invalid HTTP response")
                    }
                    if httpResponse.statusCode == 429 {
                        throw OpportunityZonesAPIError.rateLimitExceeded
                    }
                    guard (200...299).contains(httpResponse.statusCode) else {
                        let responseString = String(data: data, encoding: .utf8) ?? "No Response Body"
                        throw OpportunityZonesAPIError.requestFailed("HTTP Status Code error. Response: \(responseString)")
                    }
                    return data
                }
                .decode(type: [OpportunityZoneCheckResult].self, decoder: JSONDecoder()) // Decode to OpportunityZoneCheckResult
                .map { $0 as Decodable } // Cast to Decodable for generic handling
                .eraseToAnyPublisher()
        case .bulkAddressCheck:
            publisher = URLSession.shared.dataTaskPublisher(for: request)
                .tryMap { data, response in
                    guard let httpResponse = response as? HTTPURLResponse else {
                        throw OpportunityZonesAPIError.requestFailed("Invalid HTTP response")
                    }
                    if httpResponse.statusCode == 429 {
                        throw OpportunityZonesAPIError.rateLimitExceeded
                    }
                    guard (200...299).contains(httpResponse.statusCode) else {
                        let responseString = String(data: data, encoding: .utf8) ?? "No Response Body"
                        throw OpportunityZonesAPIError.requestFailed("HTTP Status Code error. Response: \(responseString)")
                    }
                    return data
                }
                .decode(type: [OpportunityZoneCheckResult].self, decoder: JSONDecoder()) // Decode to AddressCollectionResponse
                .map { $0 as Decodable } // Cast to Decodable for generic processing
                .eraseToAnyPublisher()
        case .censusTracts:
            publisher = URLSession.shared.dataTaskPublisher(for: request)
                .tryMap{ data, response in
                    guard let httpResponse = response as? HTTPURLResponse else {
                        throw OpportunityZonesAPIError.requestFailed("Invalid HTTP response")
                    }
                    if httpResponse.statusCode == 429 {
                        throw OpportunityZonesAPIError.rateLimitExceeded
                    }
                    guard (200...299).contains(httpResponse.statusCode) else {
                        let responseString = String(data: data, encoding: .utf8) ?? "No Response Body"
                        throw OpportunityZonesAPIError.requestFailed("HTTP Status Code error. Response: \(responseString)")
                    }
                    return data
                }
                .decode(type: OpportunityZoneCollection.self, decoder: JSONDecoder()) // Decode to OpportunityZoneCollection.
                .map { $0 as Decodable } // Cast for consistency.
                .eraseToAnyPublisher() // Type erasure.
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
                    let apiError = (error as? OpportunityZonesAPIError) ?? OpportunityZonesAPIError.unknown(error)
                    self.handleError(apiError)
                }
            }, receiveValue: { [weak self] decodedResponse in
                guard let self = self else {return}
                self.isLoading = false
                switch decodedResponse {
                case let singleAddressResult as [OpportunityZoneCheckResult]:
                    self.results = singleAddressResult
                case let bulkAddressResult as [OpportunityZoneCheckResult]:
                    self.results = bulkAddressResult
                case let censusTractResult as OpportunityZoneCollection:
                    self.censusTracts = censusTractResult.opportunityZoneList
                default:
                    print("Unexpected response type: \(type(of: decodedResponse))")
                }
            })
            .store(in: &cancellables) // Manage subscription lifecycle.
    }
    
    /// Helper method to build URLs with query parameters.
    private func buildURL(for endpoint: OpportunityZonesAPIEndpoint) -> URL? {
        guard let baseURL = URL(string: baseURLString) else {
            return nil
        }
        
        var components = URLComponents(url: baseURL.appendingPathComponent(endpoint.path), resolvingAgainstBaseURL: true)
        components?.queryItems = endpoint.queryItems
        return components?.url
    }
    
    // MARK: - Error Handling
    
    private func handleError(_ error: OpportunityZonesAPIError) {
        errorMessage = error.localizedDescription
        print("API Error: \(error.localizedDescription)")  // Log for debugging
    }
    
    // Add a cancel request method.
    func cancelRequest() {
        cancellables.forEach { $0.cancel() } // Cancel all active network requests
        cancellables.removeAll()
        isLoading = false
    }
    
    /// Clears any locally stored data.
    func clearLocalData() {
        results.removeAll()
        censusTracts.removeAll()
    }
}

// MARK: - SwiftUI Views

/// Main view for the application.
struct OpportunityZonesView: View {
    @StateObject private var service = OpportunityZoneService()
    @State private var addressNumber: String = ""
    @State private var streetName: String = ""
    @State private var cityName: String = ""
    @State private var stateAbbreviation: String = ""
    @State private var zipCode: String = ""
    @State private var showBulkInput = false
    @State private var bulkInputText: String = ""
    
    @State private var selectedState: String = ""
    @State private var selectedCounty: String? = nil // Optional
    
    // Ideally, this would come from a data source or be dynamically generated.
    private let stateAbbreviations = ["AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "FL", "GA", "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME", "MD", "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH", "NJ", "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI", "SC", "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", "WY"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Single Address Check")) {
                    TextField("Address Number", text: $addressNumber)
                    TextField("Street Name", text: $streetName)
                    TextField("City", text: $cityName)
                    TextField("State (Abbr.)", text: $stateAbbreviation)
                    TextField("Zip Code", text: $zipCode)
                    
                    Button("Check Address") {
                        service.fetchData(for: .singleAddressCheck(
                            number: addressNumber,
                            street: streetName,
                            city: cityName,
                            state: stateAbbreviation,
                            zip: zipCode
                        ))
                    } .buttonStyle(.bordered)
                }
                
                Section(header: Text("Bulk Address Check")) {
                    Text("Enter addresses, one per line (Number, Street, City, State, Zip):")
                    TextEditor(text: $bulkInputText)
                        .frame(height: 100)
                    
                    Button("Check Bulk Addresses") {
                        let addresses = parseBulkInput(bulkInputText)
                        if !addresses.isEmpty { // Prevent calling API on empty input.
                            service.fetchData(for: .bulkAddressCheck(addresses: addresses))
                        } else {
                            service.errorMessage = "No valid address input."
                        }
                    } .buttonStyle(.bordered)
                }
                
                Section(header: Text("Census Tracts by State/County")) {
                    Picker("State", selection: $selectedState) {
                        ForEach(stateAbbreviations, id: \.self) {
                            Text($0)
                        }
                    }
                    
                    // County is optional; use TextField with dynamic optional binding.
                    TextField("County (Optional)", text: Binding(
                        get: { self.selectedCounty ?? "" },
                        set: { self.selectedCounty = $0.isEmpty ? nil : $0 }
                    ))
                    
                    Button("Get Census Tracts") {
                        service.fetchData(for: .censusTracts(state: selectedState, county: selectedCounty))
                    } .buttonStyle(.bordered)
                }
                
                Section(header: Text("Results")) {
                    if service.isLoading {
                        ProgressView("Loading...")
                    } else if let errorMessage = service.errorMessage {
                        Text("Error: \(errorMessage)")
                            .foregroundColor(.red)
                    } else if !service.results.isEmpty {
                        List(service.results) { result in
                            VStack(alignment: .leading) {
                                Text("Address: \(result.streetAddress), \(result.city), \(result.state) \(result.zip)")
                                Text("In Opportunity Zone: \(result.isInOpportunityZone ? "Yes" : "No")")
                                    .fontWeight(result.isInOpportunityZone ? .bold : .regular)
                                    .foregroundColor(result.isInOpportunityZone ? .green : .red)
                                if let tractNumber = result.result.censusTractNumber {
                                    Text("Census Tract: \(tractNumber)")
                                }
                                if let category = result.result.category{
                                    Text("Category: \(category)")
                                }
                            }
                        }
                    }   else if !service.censusTracts.isEmpty {
                        List(service.censusTracts) { tract in
                            VStack(alignment: .leading) {
                                Text("State: \(tract.state)")
                                Text("County: \(tract.county)")
                                Text("Census Tract: \(tract.censusTractNumber)")
                                Text("Type: \(tract.tractType)")
                                Text("Data Source: \(tract.acsDataSource)")
                            }
                        }
                    }
                }
                
                Button("Clear Data", role: .destructive) {
                    service.clearLocalData()
                }
            }
            .navigationTitle("Opportunity Zones")
            .onDisappear {
                service.cancelRequest()  // Cancel requests if the view disappears.
            }
        }
    }
    // Helper function for parsing the address in bulk request section.
    func parseBulkInput(_ input: String) -> [AddressCollection.Address] {
        let lines = input.split(separator: "\n")
        var addresses: [AddressCollection.Address] = []
        
        for line in lines {
            let components = line.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
            guard components.count == 5 else {
                continue // Skip invalid addresses
            }
            let address = AddressCollection.Address(
                number: components[0],
                street: components[1],
                city: components[2],
                state: components[3],
                zip: components[4]
            )
            addresses.append(address)
        }
        return addresses
    }
}

// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        OpportunityZonesView()
    }
}
