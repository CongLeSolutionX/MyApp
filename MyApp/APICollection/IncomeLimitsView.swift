//
//  IncomeLimitsView.swift
//  MyApp
//
//  Created by Cong Le on 3/23/25.
//

import SwiftUI
import Combine

// MARK: - Data Models

/// Represents a single set of income limits for a census tract.
struct IncomeLimits: Identifiable, Decodable {
    let id = UUID()
    let dts_income_limit: Int?
    let hr_income_limit: Int?
    let vli_income_limit: Int?
    let rural_indicator: Bool?
    let high_needs_rural_indicator: Bool?
    let fips_code: String?

     // CodingKeys to match JSON keys exactly
    enum CodingKeys: String, CodingKey {
        case dts_income_limit
        case hr_income_limit
        case vli_income_limit
        case rural_indicator
        case high_needs_rural_indicator
        case fips_code
    }
    
    // Custom initializer to handle nested structure
       init(from decoder: Decoder) throws {
           _ = try decoder.container(keyedBy: CodingKeys.self)
           // Directly decode properties from the 'incomeLimitsList' if available; otherwise, decode from main container
                let incomeLimitsContainer = try? decoder.container(keyedBy: CodingKeys.self)
                 dts_income_limit = try incomeLimitsContainer?.decodeIfPresent(Int.self, forKey: .dts_income_limit)
                 hr_income_limit = try incomeLimitsContainer?.decodeIfPresent(Int.self, forKey: .hr_income_limit)
                 vli_income_limit = try incomeLimitsContainer?.decodeIfPresent(Int.self, forKey: .vli_income_limit)
                 rural_indicator = try incomeLimitsContainer?.decodeIfPresent(Bool.self, forKey: .rural_indicator)
                 high_needs_rural_indicator = try incomeLimitsContainer?.decodeIfPresent(Bool.self, forKey: .high_needs_rural_indicator)
                 fips_code = try incomeLimitsContainer?.decodeIfPresent(String.self, forKey: .fips_code)
       }
}

/// Represents the API response, which contains a list of IncomeLimits.
struct IncomeLimitsCollection: Decodable {
    let incomeLimitsList: [IncomeLimits]
    
    // CodingKeys to match the JSON structure
    enum CodingKeys: String, CodingKey {
        case incomeLimitsList
    }

    // Custom initializer for handling the outer array in the JSON response
    init(from decoder: Decoder) throws {
        // Try to decode as an array of IncomeLimits directly
        var container = try decoder.unkeyedContainer()
        var list: [IncomeLimits] = []
        while !container.isAtEnd {
            if let incomeLimit = try? container.decode(IncomeLimits.self) {
                list.append(incomeLimit)
            }
        }
        // Check if any items were decoded; if so, assign to incomeLimitsList
          if !list.isEmpty {
              self.incomeLimitsList = list
          } else {
            // If the response is a single IncomeLimits object wrapped in an array.
              let topLevelContainer = try decoder.singleValueContainer()
              let incomeLimitsWrapped = try topLevelContainer.decode([IncomeLimits].self)
              self.incomeLimitsList = incomeLimitsWrapped

          }
    }
}


// MARK: - API Endpoints

/// Enumerates the available API endpoints.
enum IncomeLimitsAPIEndpoint {
    case getIncomeLimitsForFipsCode(fipsCode: String)
    case getIncomeLimitsByAddress(number: String, street: String, city: String, state: String, zip: String)

    var path: String {
        switch self {
        case .getIncomeLimitsForFipsCode:
            return "/v1/income-limits/censustracts"
        case .getIncomeLimitsByAddress:
            return "/v1/income-limits/addresscheck"
        }
    }
    
    var queryItems: [URLQueryItem]? {
            switch self {
            case .getIncomeLimitsForFipsCode(let fipsCode):
                return [URLQueryItem(name: "fips_code", value: fipsCode)]
            case .getIncomeLimitsByAddress(let number, let street, let city, let state, let zip):
                return [
                    URLQueryItem(name: "number", value: number),
                    URLQueryItem(name: "street", value: street),
                    URLQueryItem(name: "city", value: city),
                    URLQueryItem(name: "state", value: state),
                    URLQueryItem(name: "zip", value: zip)
                ]
            }
        }
}

// MARK: - API Errors

/// Defines the possible errors that can occur during API interaction.
enum IncomeLimitsAPIError: Error, LocalizedError {
    case invalidURL
    case requestFailed(String)
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
            return "No data was returned."
        case .authenticationFailed:
            return "Authentication failed. Please check your credentials."
        case .unknown(let error):
            return "An unknown error occurred: \(error.localizedDescription)"
        }
    }
}

// MARK: - Authentication

/// IMPORTANT: Replace with secure credential storage in production.
struct IncomeLimitsAuthCredentials {
    static let clientID = "clientIDKeyHere"
    static let clientSecret = "clientSecretKeyHere"
}

/// Represents the token response from the authentication API.
struct IncomeLimitsAPI_TokenResponse: Decodable {
    let access_token: String
    let token_type: String
    let expires_in: Int
    let scope: String
}

// MARK: - Data Service

/// Service for fetching income limits data.
final class IncomeLimitsService: ObservableObject {
    @Published var incomeLimits: [IncomeLimits] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let baseURLString = "https://api.fanniemae.com"
    private let tokenURL = "https://auth.pingone.com/4c2b23f9-52b1-4f8f-aa1f-1d477590770c/as/token" // Same as previous example
    private var accessToken: String?
    private var tokenExpiration: Date?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Token Management
        
    private func getAccessToken(completion: @escaping (Result<String, IncomeLimitsAPIError>) -> Void) {
       // Return token if still valid.
        if let token = accessToken, let expiration = tokenExpiration, Date() < expiration {
            completion(.success(token))
            return
        }

        guard let url = URL(string: tokenURL) else {
            completion(.failure(.invalidURL))
            return
        }

        let credentials = "\(IncomeLimitsAuthCredentials.clientID):\(IncomeLimitsAuthCredentials.clientSecret)"
        guard let base64Credentials = credentials.data(using: .utf8)?.base64EncodedString() else {
            completion(.failure(.authenticationFailed))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = "grant_type=client_credentials".data(using: .utf8)

        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    let responseString = String(data: data, encoding: .utf8) ?? ""
                    throw IncomeLimitsAPIError.requestFailed("Invalid response. Response: \(responseString)")
                }
                return data
            }
            .decode(type: IncomeLimitsAPI_TokenResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completionResult in
                switch completionResult {
                case .finished:
                    break
                case .failure(let error):
                    let apiError = (error as? IncomeLimitsAPIError) ?? IncomeLimitsAPIError.unknown(error)
                    self?.handleError(apiError)
                    completion(.failure(apiError))
                }
            } receiveValue: { [weak self] tokenResponse in
                self?.accessToken = tokenResponse.access_token
                self?.tokenExpiration = Date().addingTimeInterval(TimeInterval(tokenResponse.expires_in))
                completion(.success(tokenResponse.access_token))
            }
            .store(in: &cancellables)
    }

    // MARK: - Public API

    /// Fetches income limits data based on the provided endpoint.
    func fetchData(for endpoint: IncomeLimitsAPIEndpoint) {
        isLoading = true
        errorMessage = nil
        
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
    
    
    private func makeDataRequest(endpoint: IncomeLimitsAPIEndpoint, accessToken: String) {
        var components = URLComponents(string: baseURLString + endpoint.path)!
        components.queryItems = endpoint.queryItems

        guard let url = components.url else {
            handleError(.invalidURL)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
         request.addValue(accessToken, forHTTPHeaderField: "x-public-access-token") // Using the correct header.

        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    let responseString = String(data: data, encoding: .utf8) ?? "No Response Body"
                    throw IncomeLimitsAPIError.requestFailed("HTTP Status Code error. Response: \(responseString)")
                }
                return data
            }
           .decode(type: IncomeLimitsCollection.self, decoder: JSONDecoder()) // Decode as IncomeLimitsCollection
            .map { $0.incomeLimitsList } // Extract the array
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completionResult in
                self?.isLoading = false
                switch completionResult {
                case .finished:
                    break
                case .failure(let error):
                    let apiError = (error as? IncomeLimitsAPIError) ?? IncomeLimitsAPIError.unknown(error)
                    self?.handleError(apiError)
                }
            } receiveValue: { [weak self] incomeLimits in
                self?.incomeLimits = incomeLimits
            }
            .store(in: &cancellables)
    }

    // MARK: - Error Handling

    private func handleError(_ error: IncomeLimitsAPIError) {
        errorMessage = error.localizedDescription
        print("API Error: \(error.localizedDescription)")  // Log for debugging
    }
    
    /// Clears any locally stored data.
      func clearLocalData() {
          incomeLimits.removeAll()
      }
}

// MARK: - SwiftUI Views

struct IncomeLimitsView: View {
    @StateObject private var dataService = IncomeLimitsService()
    @State private var fipsCode: String = ""
    @State private var addressNumber: String = ""
        @State private var streetName: String = ""
        @State private var cityName: String = ""
        @State private var stateAbbreviation: String = ""
        @State private var zipCode: String = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("FIPS Code Input")) {
                                    TextField("Enter 11-digit FIPS Code", text: $fipsCode)
                                        .keyboardType(.numberPad)
                                    Button("Get Income Limits by FIPS Code") {
                                        dataService.fetchData(for: .getIncomeLimitsForFipsCode(fipsCode: fipsCode))
                                    }
                                     .buttonStyle(.bordered)
                                }
                
                Section(header: Text("Address Input")) {
                                  TextField("Building Number", text: $addressNumber)
                                  TextField("Street Name", text: $streetName)
                                  TextField("City", text: $cityName)
                                  TextField("State (e.g., VA)", text: $stateAbbreviation)
                                  TextField("Zip Code", text: $zipCode)
                                     
                                  Button("Get Income Limits by Address") {
                                      dataService.fetchData(for: .getIncomeLimitsByAddress(number: addressNumber, street: streetName, city: cityName, state: stateAbbreviation, zip: zipCode))
                                  }
                                   .buttonStyle(.bordered)
                              }
                
                 Button("Clear Data", role: .destructive) {
                       dataService.clearLocalData()
                    }
                .buttonStyle(.bordered)
                
                Section(header: Text("Income Limits")) {
                    if dataService.isLoading {
                        ProgressView("Loading...")
                    } else if let errorMessage = dataService.errorMessage {
                        Text("Error: \(errorMessage)")
                            .foregroundColor(.red)
                    } else if dataService.incomeLimits.isEmpty{
                        Text("No data available, enter valid inputs")
                    }else {
                        List(dataService.incomeLimits) { limit in
                            VStack(alignment: .leading) {
                                Text("FIPS Code: \(limit.fips_code ?? "N/A")")
                                Text("DTS Income Limit: \(limit.dts_income_limit.map(String.init) ?? "N/A")")
                                Text("HR Income Limit: \(limit.hr_income_limit.map(String.init) ?? "N/A")")
                                Text("VLI Income Limit: \(limit.vli_income_limit.map(String.init) ?? "N/A")")
                                Text("Rural Indicator: \(limit.rural_indicator.map(String.init) ?? "N/A")")
                                Text("High Needs Rural: \(limit.high_needs_rural_indicator.map(String.init) ?? "N/A")")
                            }
                        }
                    }
                }
            }
            .navigationTitle("Income Limits")
        }
    }
}

// MARK: - Preview
struct IncomeLimitsView_Previews: PreviewProvider {
    static var previews: some View {
        IncomeLimitsView()
    }
}
