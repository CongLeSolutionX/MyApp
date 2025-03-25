//
//  PoolPrefixView.swift
//  MyApp
//
//  Created by Cong Le on 3/24/25.
//

import SwiftUI
import Combine

// MARK: - Data Models

/// Represents a single pool prefix data entry.
struct PoolPrefixData: Decodable, Identifiable {
    let id = UUID() // Added for Identifiable conformance
    let prefix: String?
    let description: String?
    let businessLine: String?
    let amortizationType: String?

    enum CodingKeys: String, CodingKey {
        case prefix, description, businessLine = "business-line", amortizationType = "amortization-type"
    }
}

/// Represents the response for the /multiple endpoint.
struct PoolPrefixMultipleResponse: Decodable {
    let incorrectRequestIndices: [Int]?
    let poolPrefixData: [PoolPrefixData]?
}

/// Represents a single request item within the /multiple endpoint's request body.
struct PoolPrefixRequestDto: Encodable {
    let businessLine: String?
    let amortizationType: String?

     enum CodingKeys: String, CodingKey {
        case businessLine = "businessLine"
        case amortizationType = "amortizationType"
    }
}

/// Represents the overall request body for the /multiple endpoint.
struct PoolPrefixRequest: Encodable {
    let poolPrefixRequests: [PoolPrefixRequestDto]?
}


/// Represents the structure returned by the /v1/pool-prefix (GET) and /v1/pool-prefix/keyword (GET) endpoints.
struct PoolPrefixDto: Decodable { // Top-level Dto for List responses.
    let poolPrefixData: [PoolPrefixData]?

    // Custom initializer to handle direct array decoding
      init(from decoder: Decoder) throws {
          var container = try decoder.unkeyedContainer()
          var tempData: [PoolPrefixData] = []
          while !container.isAtEnd {
              let prefixData = try container.decode(PoolPrefixData.self)
              tempData.append(prefixData)
          }
          self.poolPrefixData = tempData.isEmpty ? nil : tempData
      }
}
// MARK: - API Endpoints

/// Enumerates the available API endpoints for the Pool Prefix API.
enum APIEndpointPoolPrefix {
    case multiple(request: PoolPrefixRequest)
    case single(businessLine: String?, amortizationType: String?, prefix: String?)
    case keyword(keyword: String)

    var path: String {
        switch self {
        case .multiple:
            return "/v1/pool-prefix/multiple"
        case .single:
            return "/v1/pool-prefix"
        case .keyword:
            return "/v1/pool-prefix/keyword"
        }
    }
}

// MARK: - API Errors

/// Defines the possible errors that can occur during API interactions.
enum APIErrorPoolPrefix: Error, LocalizedError {
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


// MARK: - Data Service
/// Service for fetching pool prefix data from the Fannie Mae API.
final class PoolPrefixDataService: ObservableObject {
    @Published var poolPrefixData: [PoolPrefixData] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let baseURLString = "https://api.fanniemae.com" // From OpenAPI spec
    private let tokenURL = "https://auth.pingone.com/4c2b23f9-52b1-4f8f-aa1f-1d477590770c/as/token"  // Same as previous example
    private var accessToken: String? =  "ValidToken"// Same as previous example
    private var tokenExpiration: Date? = Date().addingTimeInterval(3600) // Add dummy value to avoid Optionals
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Token Management

       private func getAccessToken(completion: @escaping (Result<String, APIErrorPoolPrefix>) -> Void) {
        // Return token if still valid.
        if let token = accessToken, let expiration = tokenExpiration, Date() < expiration {
            completion(.success(token))
            return
        }

        guard let url = URL(string: tokenURL) else {
            completion(.failure(.invalidURL))
            return
        }

        let credentials = "\(PoolPrefix_AuthCredentials.clientID):\(PoolPrefix_AuthCredentials.clientSecret)"
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
                    throw APIErrorPoolPrefix.requestFailed("Invalid response. Response: \(responseString)")
                }
                return data
            }
            .decode(type: PoolPrefix_TokenResponse.self, decoder: JSONDecoder()) // Reuse TokenResponse
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completionResult in
                switch completionResult {
                case .finished:
                    break
                case .failure(let error):
                    let apiError = (error as? APIErrorPoolPrefix) ?? APIErrorPoolPrefix.unknown(error)
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

    // MARK: - Public API - Data Fetching

    func fetchData(for endpoint: APIEndpointPoolPrefix) {
        isLoading = true
        errorMessage = nil
        poolPrefixData.removeAll() // Clear previous data

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


 private func makeDataRequest(endpoint: APIEndpointPoolPrefix, accessToken: String) {
        guard let url = buildURL(for: endpoint) else {
            handleError(.invalidURL)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = determineHTTPMethod(for: endpoint)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(accessToken, forHTTPHeaderField: "x-public-access-token") // Using token

        // Set request body for POST requests
        if case .multiple(let poolPrefixRequest) = endpoint {
            do {
                request.httpBody = try JSONEncoder().encode(poolPrefixRequest)
            } catch {
                handleError(.requestFailed("Could not encode request body: \(error.localizedDescription)"))
                return
            }
        }

       let publisher: AnyPublisher<[PoolPrefixData], Error> = URLSession.shared.dataTaskPublisher(for: request)
           .tryMap { data, response in
               guard let httpResponse = response as? HTTPURLResponse,
                     (200...299).contains(httpResponse.statusCode) else {
                   let responseString = String(data: data, encoding: .utf8) ?? "No Response Body"
                   throw APIErrorPoolPrefix.requestFailed("HTTP Status Code error. Response: \(responseString)")
               }
               print("Received data: \(String(data: data, encoding: .utf8) ?? "Invalid Data")")
               return data
           }
           .flatMap { data -> AnyPublisher<[PoolPrefixData], Error> in
                do {
                    let decodedResponse: [PoolPrefixData]
                    
                    switch endpoint{
                    case .multiple:
                        let multipleResponse = try JSONDecoder().decode(PoolPrefixMultipleResponse.self, from: data)
                        decodedResponse = multipleResponse.poolPrefixData ?? []
                    default: do {
                        // Attempt to decode as a single PoolPrefixDto
                        if let dto = try? JSONDecoder().decode(PoolPrefixDto.self, from: data),
                           let data = dto.poolPrefixData {
                            decodedResponse = data
                            
                        } else {
                            // If it's not an object with poolPrefixData, try decoding as an array directly
                           decodedResponse = try JSONDecoder().decode([PoolPrefixData].self, from: data)
                        }
                    }
                    }
                    return Just(decodedResponse)
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                } catch {
                    return Fail(error: error)
                        .eraseToAnyPublisher()
                }
           }
           .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()

        publisher
          .sink(receiveCompletion: { [weak self] completion in
              guard let self = self else { return }
              self.isLoading = false
              switch completion {
              case .finished:
                  break
              case .failure(let error):
                  self.handleError((error as? APIErrorPoolPrefix) ?? APIErrorPoolPrefix.unknown(error))
              }
          }, receiveValue: { [weak self] data in
              guard let self = self else { return }
              self.poolPrefixData = data
          })
          .store(in: &cancellables)
    }

    private func buildURL(for endpoint: APIEndpointPoolPrefix) -> URL? {
        var components = URLComponents(string: baseURLString + endpoint.path)

        switch endpoint {
        case .single(let businessLine, let amortizationType, let prefix):
            var queryItems: [URLQueryItem] = []
            if let businessLine = businessLine, !businessLine.isEmpty {
                queryItems.append(URLQueryItem(name: "businessLine", value: businessLine))
            }
            if let amortizationType = amortizationType, !amortizationType.isEmpty {
                queryItems.append(URLQueryItem(name: "amortizationType", value: amortizationType))
            }
            if let prefix = prefix, !prefix.isEmpty {
                queryItems.append(URLQueryItem(name: "prefix", value: prefix))
            }
            components?.queryItems = queryItems.isEmpty ? nil : queryItems

        case .keyword(let keyword):
            components?.queryItems = [URLQueryItem(name: "keyword", value: keyword)]

        case .multiple:
            break // No query parameters for multiple; it uses a request body
        }

        return components?.url
    }


      /// Determines the appropriate HTTP method based on the endpoint.
    private func determineHTTPMethod(for endpoint: APIEndpointPoolPrefix) -> String {
        switch endpoint {
        case .multiple:
            return "POST"
        case .single, .keyword:
            return "GET"
        }
    }

    // MARK: - Error Handling

    private func handleError(_ error: APIErrorPoolPrefix) {
        errorMessage = error.localizedDescription
        print("API Error: \(error.localizedDescription)") // Log the error
    }
   /// Clears all fetched data.
    func clearLocalData() {
        poolPrefixData.removeAll()
    }
}

// MARK: - SwiftUI Views

struct ContentViewPoolPrefix: View {
    @StateObject private var dataService = PoolPrefixDataService()
    @State private var businessLine: String = ""
    @State private var amortizationType: String = ""
    @State private var prefix: String = ""
    @State private var keyword: String = ""
    @State private var multiBusinessLine: String = ""
    @State private var multiAmortizationType: String = ""
    @State private var multiRequests: [PoolPrefixRequestDto] = []

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Single Pool Prefix Search")) {
                    TextField("Business Line", text: $businessLine)
                    TextField("Amortization Type", text: $amortizationType)
                    TextField("Prefix", text: $prefix)
                    Button("Fetch Single") {
                        dataService.fetchData(for: .single(businessLine: businessLine, amortizationType: amortizationType, prefix: prefix))
                    }
                    .buttonStyle(.bordered)
                }

                Section(header: Text("Keyword Search")) {
                    TextField("Keyword", text: $keyword)
                    Button("Fetch by Keyword") {
                        dataService.fetchData(for: .keyword(keyword: keyword))
                    }
                    .buttonStyle(.bordered)
                }

                Section(header: Text("Multiple Pool Prefix Search")) {
                    TextField("Business Line", text: $multiBusinessLine)
                    TextField("Amortization Type", text: $multiAmortizationType)

                    Button("Add Request") {
                        let newRequest = PoolPrefixRequestDto(businessLine: multiBusinessLine.isEmpty ? nil : multiBusinessLine,
                                                            amortizationType: multiAmortizationType.isEmpty ? nil : multiAmortizationType)
                        multiRequests.append(newRequest)
                        multiBusinessLine = "" // Clear fields after adding
                        multiAmortizationType = ""
                    }
                    .buttonStyle(.bordered)

                    List {
                        ForEach(multiRequests.indices, id: \.self) { index in
                            HStack {
                                if let businessLine = multiRequests[index].businessLine {
                                     Text("Business Line: \(businessLine)")
                                }
                               
                                if let amortizationType = multiRequests[index].amortizationType {
                                     Text("Amortization Type: \(amortizationType)")
                                }
                            }
                        }
                        .onDelete { indexSet in
                            multiRequests.remove(atOffsets: indexSet)
                        }
                    }

                    Button("Fetch Multiple") {
                        let request = PoolPrefixRequest(poolPrefixRequests: multiRequests.isEmpty ? nil : multiRequests)
                        dataService.fetchData(for: .multiple(request: request))
                    }
                    .buttonStyle(.borderedProminent)
                }
                Section(header: Text("Clear Data"))
                {
                    Button("Clear Data", role: .destructive) {
                        dataService.clearLocalData()
                    }
                }

                Section(header: Text("Results")) {
                    if dataService.isLoading {
                        ProgressView()
                    } else if let errorMessage = dataService.errorMessage {
                        Text("Error: \(errorMessage)")
                    } else {
                        List(dataService.poolPrefixData) { item in
                            VStack(alignment: .leading) {
                                if let prefix = item.prefix{
                                    Text("Prefix: \(prefix)")
                                }
                                if let desc = item.description {
                                     Text("Description: \(desc)")
                                }
                               
                                if let business = item.businessLine{
                                    Text("Business Line: \(business)")
                                }
                                if let amor = item.amortizationType{
                                    Text("Amortization Type: \(amor)")
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Pool Prefix Data")
        }
    }
}

// MARK: - Preview

struct ContentViewPoolPrefix_Previews: PreviewProvider {
    static var previews: some View {
        ContentViewPoolPrefix()
    }
}

/// IMPORTANT:  This is for reuse.  It MUST be defined in your previous code example.
/// Model for the token response from the authentication API.
struct PoolPrefix_TokenResponse: Decodable {
    let access_token: String
    let token_type: String
    let expires_in: Int
    let scope: String
}

/// IMPORTANT: In an actual production app, never hardcode client credentials.
/// Use secure storage or environment variables instead.
struct PoolPrefix_AuthCredentials {
    static let clientID = "clientIDKeyHere"
    static let clientSecret = "clientSecretKeyHere"
}
