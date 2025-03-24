//
//  OpportunityZonesView.swift
//  MyApp
//
//  Created by Cong Le on 3/23/25.
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
        let censusTractNumber: String? // Optional, as it might not be present in all cases
        let category: String?          // Optional, similar reason
    }

    // Computed property for a cleaner presentation.
    var isInOpportunityZone: Bool {
        return result.belongsToOpportunityZones.lowercased() == "yes"
    }
}

/// Represents a collection of addresses for bulk validation.  This isn't directly
/// used in decoding, but is useful for structuring the request.
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

/// Represents a census tract within an Opportunity Zone.
struct OpportunityZone: Identifiable, Decodable {
    let id = UUID() // Add a unique identifier, as the Census Tract Number alone may not be globally unique
    let state: String
    let county: String
    let censusTractNumber: String
    let tractType: String
    let acsDataSource: String
}

/// Represents a collection of opportunity zone for easy parsing.
struct OpportunityZoneCollection: Decodable {
    let opportunityZoneList: [OpportunityZone]
}


// MARK: - API Endpoints

/// Enumerates the available API endpoints.
enum APIEndpoint {
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
            return nil // No query items for POST request
        }
    }
    
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

/// Defines the possible errors that can occur during API interaction.
enum APIError: Error, LocalizedError {
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

/// Service for fetching and managing Opportunity Zone data.
final class OpportunityZoneService: ObservableObject {
    @Published var results: [OpportunityZoneCheckResult] = []
    @Published var censusTracts: [OpportunityZone] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let baseURLString = "https://api.fanniemae.com"
    private let tokenURL = "https://auth.pingone.com/4c2b23f9-52b1-4f8f-aa1f-1d477590770c/as/token"
    private var accessToken: String?
    private var tokenExpiration: Date?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Token Management
    
    private func getAccessToken(completion: @escaping (Result<String, APIError>) -> Void) {
        // Return token if still valid.
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
                    throw APIError.requestFailed("Invalid response. Response: \(responseString)")
                }
                return data
            }
            .decode(type: TokenResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completionResult in
                switch completionResult {
                case .finished:
                    break
                case .failure(let error):
                    let apiError = (error as? APIError) ?? APIError.unknown(error)
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

    /// Fetches Opportunity Zone data based on the provided endpoint.
    func fetchData(for endpoint: APIEndpoint) {
        isLoading = true
        errorMessage = nil
        results = []       // Clear previous results
        censusTracts = [] // Clear census tracts
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

    private func makeDataRequest(endpoint: APIEndpoint, accessToken: String) {
           var request: URLRequest
           
           switch endpoint {
           case .bulkAddressCheck(let addresses):
               guard let url = URL(string: baseURLString + endpoint.path) else {
                   handleError(.invalidURL)
                   return
               }
               request = URLRequest(url: url)
               request.httpMethod = endpoint.httpMethod
               request.addValue("application/json", forHTTPHeaderField: "Content-Type")
               request.addValue(accessToken, forHTTPHeaderField: "x-public-access-token")
               
               // Encode the AddressCollection for the POST body
               let addressCollection = AddressCollection(addresses: addresses)
               do {
                   request.httpBody = try JSONEncoder().encode(addressCollection)
               } catch {
                   handleError(.requestFailed("Could not encode addresses for bulk check."))
                   return
               }
               
           case .singleAddressCheck, .censusTracts:
               guard let url = buildURL(for: endpoint) else {
                   handleError(.invalidURL)
                   return
               }
               request = URLRequest(url: url)
               request.httpMethod = endpoint.httpMethod
               request.addValue("application/json", forHTTPHeaderField: "Content-Type")
               request.addValue(accessToken, forHTTPHeaderField: "x-public-access-token")
               
           }
           
           URLSession.shared.dataTaskPublisher(for: request)
               .tryMap { data, response -> Data in
                   guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                       let responseStr = String(data: data, encoding: .utf8) ?? "No response body"
                       throw APIError.requestFailed("Invalid HTTP response. Response: \(responseStr)")
                   }
                   return data
               }
               .receive(on: DispatchQueue.main)
               .sink { [weak self] completion in
                   guard let self = self else {return}
                   self.isLoading = false
                   switch completion {
                   case .finished:
                       break
                   case .failure(let error):
                       self.handleError((error as? APIError) ?? APIError.unknown(error))
                   }
               } receiveValue: { [weak self] data in
                   guard let self = self else { return }
                   self.isLoading = false
                   
                   switch endpoint {
                   case .singleAddressCheck, .bulkAddressCheck :
                       do {
                           // Decode the response as an array of OpportunityZoneCheckResult
                           let decodedResults = try JSONDecoder().decode([OpportunityZoneCheckResult].self, from: data)
                           self.results = decodedResults
                       } catch {
                           self.handleError(.decodingFailed)
                       }
                       
                   case .censusTracts:
                       do {
                           let decodedResponse = try JSONDecoder().decode(OpportunityZoneCollection.self, from: data)
                           self.censusTracts = decodedResponse.opportunityZoneList
                       } catch {
                           self.handleError(.decodingFailed)
                       }
                   }
               }
               .store(in: &cancellables)
           
       }
    
    
    /// Constructs the full URL, including query parameters.  Separated for clarity.
        private func buildURL(for endpoint: APIEndpoint) -> URL? {
            guard let baseURL = URL(string: baseURLString) else {
                return nil
            }

            var components = URLComponents(url: baseURL.appendingPathComponent(endpoint.path), resolvingAgainstBaseURL: true)
            components?.queryItems = endpoint.queryItems

            return components?.url
        }

       

    // MARK: - Error Handling

    private func handleError(_ error: APIError) {
        errorMessage = error.localizedDescription
        print("API Error: \(error.localizedDescription)")  // Log for debugging
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
        @State private var selectedCounty: String? = nil // Optional county
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
                                           if !addresses.isEmpty { // prevent calling API if no valid addresses found.
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
                                  // For simplicity, county input as text field. In reality --> another picker to the relevant endpoint.
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
                                if let category = result.result.category {
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
        }
    }
    
    // Helper Function for Bulk Processing
    func parseBulkInput(_ input: String) -> [AddressCollection.Address] {
           let lines = input.split(separator: "\n")
           var addresses: [AddressCollection.Address] = []

           for line in lines {
               let components = line.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
               guard components.count == 5 else {
                   // Log or display a user-friendly error, e.g., "Invalid address format on line: \(line)"
                   continue // Skip to the next address
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

struct OpportunityZonesView_Previews: PreviewProvider {
    static var previews: some View {
        OpportunityZonesView()
    }
}
