//
//  ConstructionSpendingVview.swift
//  MyApp
//
//  Created by Cong Le on 3/22/25.
//

import SwiftUI
import Combine

// MARK: - Data Models

/// Represents a single data point in construction spending.
struct ConstructionSpendingDatumDto: Decodable, Identifiable {
    let id = UUID()
    let constructionSpendingValue: Double?
    let monthAndValueType: String?
    let monthLabelType: String?
    let dataSectionName: String?

    enum CodingKeys: String, CodingKey {
        case constructionSpendingValue = "construction-spending-value"
        case monthAndValueType = "month-and-value-type"
        case monthLabelType = "month-label-type"
        case dataSectionName = "data-section-name"
    }
}

/// Represents a collection of construction spending data.
struct ConstructionSpendingDto: Decodable {
    let constructionSpending: [ConstructionSpendingDatumDto]?
}

/// Aggregated model for easier UI display
struct SpendingData: Identifiable {
    let id = UUID()
    let value: Double?
    let monthYear: String?
    let section: String?
    let sector: String?
    let subsector: String?
    
    init(from datum: ConstructionSpendingDatumDto, section: String? = nil, sector: String? = nil, subsector: String? = nil) {
        self.value = datum.constructionSpendingValue
        self.monthYear = datum.monthAndValueType // or datum.monthLabelType, choose the most appropriate
        self.section = section
        self.sector = sector
        self.subsector = subsector
    }
}


/// Represents a query item for the multiple endpoint.
struct MultiplePostQueryItem: Encodable {
    let section: String?
    let sector: String?
    let subsector: String?
}

/// Represents the request body for the multiple endpoint.
struct MultiplePostQuery: Encodable {
    let queryItems: [MultiplePostQueryItem]
}

/// Represents a single item in the response from the multiple endpoint.
struct MultiplePostResponseItem: Decodable {
    let value: Double?
    let path: String?
    let spendingValueType: String?
    let monthYear: String?
}

/// Represents the response from the multiple endpoint.
struct MultiplePostResponse: Decodable {
    let postResponseItems: [MultiplePostResponseItem]?
}

// MARK: - API Endpoints

/// Enumeration for API endpoints.
enum ConstructionSpendingAPIEndpoint {
    case section(section: String)
    case sectionAndSector(section: String, sector: String)
    case sectionSectorAndSubsector(section: String, sector: String, subsector: String)
    case multiple(query: MultiplePostQuery)

    var path: String {
        switch self {
        case .section:
            return "/v1/construction-spending/section"
        case .sectionAndSector:
            return "/v1/construction-spending/sectionandsector"
        case .sectionSectorAndSubsector:
            return "/v1/construction-spending/sectionsectorandsubsector"
        case .multiple:
            return "/v1/construction-spending/multiple"
        }
    }
    
    var queryItems: [URLQueryItem]? {
           switch self {
           case .section(let section):
               return [URLQueryItem(name: "section", value: section)]
           case .sectionAndSector(let section, let sector):
               return [
                   URLQueryItem(name: "section", value: section),
                   URLQueryItem(name: "sector", value: sector)
               ]
           case .sectionSectorAndSubsector(let section, let sector, let subsector):
               return [
                   URLQueryItem(name: "section", value: section),
                   URLQueryItem(name: "sector", value: sector),
                   URLQueryItem(name: "subsector", value: subsector)
               ]
           case .multiple:
               return nil // POST request, handled separately
           }
       }
    
    var httpMethod: String {
            switch self {
            case .multiple:
                return "POST"
            default:
                return "GET"
            }
        }
}

// MARK: - API Errors

/// API error definition.  Reuse the one from the previous example, or create a new one.
enum ConstructionSpendingAPIError: Error, LocalizedError {
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

/// Reuse the AuthCredentials and TokenResponse from the previous example.
struct ConstructionSpendingAPIAuthCredentials {
    static let clientID = "clientIDKeyHere"
    static let clientSecret = "clientSecretKeyHere"
}

struct ConstructionSpendingAPITokenResponse: Decodable {
    let access_token: String
    let token_type: String
    let expires_in: Int
    let scope: String
}

// MARK: - Data Service

/// Service for fetching construction spending data.
final class ConstructionSpendingService: ObservableObject {
    @Published var spendingData: [SpendingData] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let baseURLString = "https://api.fanniemae.com"
    private let tokenURL = "https://auth.pingone.com/4c2b23f9-52b1-4f8f-aa1f-1d477590770c/as/token"  // Same as previous example
    private var accessToken: String?
    private var tokenExpiration: Date?
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Token Management (Same as previous example, but using ConstructionSpending types)
    private func getAccessToken(completion: @escaping (Result<String, ConstructionSpendingAPIError>) -> Void) {
            // Return token if still valid.
            if let token = accessToken, let expiration = tokenExpiration, Date() < expiration {
                completion(.success(token))
                return
            }
            
            guard let url = URL(string: tokenURL) else {
                completion(.failure(.invalidURL))
                return
            }
            
            let credentials = "\(ConstructionSpendingAPIAuthCredentials.clientID):\(ConstructionSpendingAPIAuthCredentials.clientSecret)"
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
                        throw ConstructionSpendingAPIError.requestFailed("Invalid response. Response: \(responseString)")
                    }
                    return data
                }
                .decode(type: ConstructionSpendingAPITokenResponse.self, decoder: JSONDecoder())
                .receive(on: DispatchQueue.main)
                .sink { [weak self] completionResult in
                    switch completionResult {
                    case .finished:
                        break
                    case .failure(let error):
                        let apiError = (error as? ConstructionSpendingAPIError) ?? ConstructionSpendingAPIError.unknown(error)
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

        func fetchData(for endpoint: ConstructionSpendingAPIEndpoint) {
            isLoading = true
            errorMessage = nil
            spendingData = [] // Clear previous data

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

        private func makeDataRequest(endpoint: ConstructionSpendingAPIEndpoint, accessToken: String) {
            var request: URLRequest

            do {
                 request = try createRequest(endpoint: endpoint, accessToken: accessToken)
            } catch let error as ConstructionSpendingAPIError {
                handleError(error)
                return
            } catch {
                handleError(.unknown(error))
                return
            }
           

            let publisher: AnyPublisher<[SpendingData], Error>

            switch endpoint {
            case .multiple:
                publisher = URLSession.shared.dataTaskPublisher(for: request)
                    .tryMap { data, response in
                        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                            let responseString = String(data: data, encoding: .utf8) ?? "No Response Body"
                            throw ConstructionSpendingAPIError.requestFailed("HTTP Status Code Error. Response: \(responseString)")
                        }
                        return data
                    }
                    .decode(type: MultiplePostResponse.self, decoder: JSONDecoder())
                    .map { response -> [SpendingData] in
                        guard let items = response.postResponseItems else { return [] }
                        return items.map { SpendingData(from: ConstructionSpendingDatumDto(constructionSpendingValue: $0.value, monthAndValueType: $0.monthYear, monthLabelType: nil, dataSectionName: $0.spendingValueType), section: $0.path, sector: nil, subsector: nil) }
                    }
                    .eraseToAnyPublisher()

            case .section, .sectionAndSector, .sectionSectorAndSubsector:
                publisher = URLSession.shared.dataTaskPublisher(for: request)
                    .tryMap { data, response in
                        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                             let responseString = String(data: data, encoding: .utf8) ?? "No Response Body"
                            throw ConstructionSpendingAPIError.requestFailed("HTTP Status Code Error. Response: \(responseString)")
                        }
                        return data
                    }
                    .decode(type: ConstructionSpendingDto.self, decoder: JSONDecoder())
                    .map { dto -> [SpendingData] in
                        let section = (endpoint.queryItems?.first { $0.name == "section" })?.value
                        let sector = (endpoint.queryItems?.first { $0.name == "sector" })?.value
                        let subsector = (endpoint.queryItems?.first { $0.name == "subsector" })?.value

                        return dto.constructionSpending?.compactMap { datum in
                            SpendingData(from: datum, section: section, sector: sector, subsector: subsector)
                        } ?? []
                    }
                    .eraseToAnyPublisher()
            }

            publisher
              .receive(on: DispatchQueue.main)
              .sink(receiveCompletion: { [weak self] completion in
                  guard let self = self else { return }
                  self.isLoading = false
                  switch completion {
                  case .failure(let error):
                      if let apiError = error as? ConstructionSpendingAPIError {
                          self.handleError(apiError)
                      } else {
                          self.handleError(.unknown(error))
                      }
                  case .finished:
                      break
                  }
              }, receiveValue: { [weak self] spendingData in
                  guard let self = self else { return }
                  self.spendingData = spendingData
              })
              .store(in: &cancellables)
        }
    
    private func createRequest(endpoint: ConstructionSpendingAPIEndpoint, accessToken: String) throws ->  URLRequest {
        
        guard let baseURL = URL(string: baseURLString) else {
            throw ConstructionSpendingAPIError.invalidURL
        }
        let fullURL = baseURL.appendingPathComponent(endpoint.path)
        var components = URLComponents(url: fullURL, resolvingAgainstBaseURL: false)
        
        if endpoint.httpMethod == "GET"{
            components?.queryItems = endpoint.queryItems
        }
        
        guard let finalURL = components?.url else {
            throw ConstructionSpendingAPIError.invalidURL
               }
               var request = URLRequest(url: finalURL)
               request.httpMethod = endpoint.httpMethod
               request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization") // Using standard Bearer token

               if endpoint.httpMethod == "POST", case .multiple(let query) = endpoint {
                   do {
                       request.httpBody = try JSONEncoder().encode(query)
                   } catch {
                       throw ConstructionSpendingAPIError.requestFailed("Failed to encode request body: \(error.localizedDescription)")
                   }
               }
        return request
    }

    // MARK: - Error Handling

    private func handleError(_ error: ConstructionSpendingAPIError) {
        errorMessage = error.localizedDescription
        print("API Error: \(error.localizedDescription)")
    }
    /// Clears any locally stored data
    func clearLocalData() {
        spendingData = []
    }
}

// MARK: - SwiftUI Views (Example)

struct ContentViewConstruction: View {
    @StateObject private var service = ConstructionSpendingService()
    @State private var selectedSection: String = "Total"
  @State private var selectedSector: String = ""
   @State private var selectedSubsector: String = ""
    let sections = ["Total", "Private", "Public"]
    let sectors = ["Residential", "Nonresidential"]
    let subsectors = ["Lodging", "Office", "Commercial", "Health care", "Educational", "Religious", "Public safety", "Amusement and recreation", "Transportation", "Communication", "Power", "Highway and street", "Sewage and waste disposal", "Water supply", "Conservation and development", "Manufacturing"]

    var body: some View {
           NavigationView {
               Form {
                   Section(header: Text("Data Selection")) {
                       Picker("Section", selection: $selectedSection) {
                           ForEach(sections, id: \.self) {
                               Text($0)
                           }
                       }
                       
                       Picker("Sector", selection: $selectedSector) {
                           Text("").tag("") // Empty option
                           ForEach(sectors, id: \.self) {
                               Text($0)
                           }
                       }
                       .disabled(selectedSection.isEmpty)
                       
                       
                       Picker("Subsector", selection: $selectedSubsector) {
                           Text("").tag("") // Empty option
                           ForEach(subsectors, id: \.self) {
                               Text($0)
                           }
                       }
                       .disabled(selectedSector.isEmpty)

                       
                       Button("Fetch by Section") {
                           service.fetchData(for: .section(section: selectedSection))
                       }
                       .disabled(selectedSection.isEmpty)

                       Button("Fetch by Section and Sector") {
                           service.fetchData(for: .sectionAndSector(section: selectedSection, sector: selectedSector))
                       }
                       .disabled(selectedSection.isEmpty || selectedSector.isEmpty)
                       Button("Fetch by Section, Sector and Subsector") {
                           service.fetchData(for: .sectionSectorAndSubsector(section: selectedSection, sector: selectedSector, subsector: selectedSubsector))
                       }
                       .disabled(selectedSection.isEmpty || selectedSector.isEmpty || selectedSubsector.isEmpty)
                    
                       Button("Fetch Multiple") {
                           // Example multiple query
                           let query = MultiplePostQuery(queryItems: [
                               MultiplePostQueryItem(section: "Total", sector: nil, subsector: nil),
                               MultiplePostQueryItem(section: "Private", sector: "Residential", subsector: nil)
                           ])
                           service.fetchData(for: .multiple(query: query))
                       }
                       Button("Clear Data", role: .destructive) {
                           service.clearLocalData()
                       }

                       
                   }
                   Section(header: Text("Construction Spending")) {
                       if service.isLoading {
                           ProgressView()
                       } else if let errorMessage = service.errorMessage {
                           Text("Error: \(errorMessage)")
                       } else {
                           List(service.spendingData) { data in
                               VStack(alignment: .leading) {
                                   if let value = data.value {
                                       Text("Value: \(value)")
                                   }
                                   if let monthYear = data.monthYear {
                                       Text("Month/Year: \(monthYear)")
                                   }
                                   if let section = data.section {
                                                                      Text("Section: \(section)")
                                                                  }
                                 if let sector = data.sector, !sector.isEmpty{
                                                                      Text("Sector: \(sector)")
                                                                  }
                                   if let subsector = data.subsector, !subsector.isEmpty {
                                                                      Text("Subsector: \(subsector)")
                                                                  }
                               }
                           }
                       }
                   }
               }
               .navigationTitle("Construction Spending")
           }
       }
}

#Preview {
    ContentViewConstruction()
}
