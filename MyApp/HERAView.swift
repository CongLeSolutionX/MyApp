//
//  HERAView.swift
//  MyApp
//
//  Created by Cong Le on 3/23/25.
//

import SwiftUI
import Combine

// MARK: - Data Models

/// Represents a single row in the aggregated HERA data response.
struct HeraRow: Decodable {
    let groupedByColumnValues: String?
    let count: Int?
}

/// Represents the overall HERA data response structure.
struct HeraResponse: Decodable {
    let groupedByColumnNames: String?
    let rows: [HeraRow]?
}

/// Represents the query specification for the HERA API, used for POST requests.
struct HeraQuerySpecification: Encodable {
    let translatedWhereClause: Where?
    let translatedGroupByColumns: [String]?
    let aggregationColumns: String?  // Keep original casing
    let whereClauseColumns: String? // Keep original casing
    let whereClauseValues: [String]?

    // Custom CodingKeys to handle the camelCase/kebab-case mismatch
    enum CodingKeys: String, CodingKey {
        case translatedWhereClause
        case translatedGroupByColumns
        case aggregationColumns = "aggregation-columns"
        case whereClauseColumns = "where-clause-columns"
        case whereClauseValues = "where-clause-values"
    }

    // Custom encoding to handle wrapped XML for whereClauseValues
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(translatedWhereClause, forKey: .translatedWhereClause)
        try container.encodeIfPresent(translatedGroupByColumns, forKey: .translatedGroupByColumns)
        try container.encodeIfPresent(aggregationColumns, forKey: .aggregationColumns)
        try container.encodeIfPresent(whereClauseColumns, forKey: .whereClauseColumns)

        // Handle whereClauseValues as a wrapped array (special case)
        if let values = whereClauseValues {
            var wrapperContainer = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .whereClauseValues)
            var arrayContainer = wrapperContainer.nestedUnkeyedContainer(forKey: .whereClauseValues)
            for value in values {
                try arrayContainer.encode(value)
            }
        }
    }
}

/// Represents a `WHERE` clause in the HERA query.
struct Where: Encodable {
    let columnNames: [String]?
    let columnValues: [[String: String]]? // Changed the type to Array
}

/// Represents a single entry in the `HeraTransformedHypermediaPage` response for /v1/national-file-b/all.
struct HeraTransformed: Decodable, Identifiable {
  var id = UUID()  // Add a unique identifier
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

//HeraTransformedEmbedded
struct HeraTransformedEmbedded: Decodable {
    let hera: [HeraTransformed]?
}

//HeraTransformedHypermediaPage
struct HeraTransformedHypermediaPage: Decodable {
  let _links: Links?
  let total: Int?
  let _embedded: HeraTransformedEmbedded?
}

//Href
struct Href: Decodable {
    let href: String?
}

//Links
struct Links: Decodable {
    let self_: Href?
    let results: Href?
    let next: Href?
    let previous: Href?
    
    enum CodingKeys: String, CodingKey {
      case self_ = "self"
      case results, next, previous
    }
}


// MARK: - API Endpoints

/// Enumerates the available API endpoints for the HERA service.
enum HeraAPIEndpoint {
    case aggregate(HeraQuerySpecification)
    case all(page: Int)

    var path: String {
        switch self {
        case .aggregate:
            return "/v1/national-file-b/specification"
        case .all:
            return "/v1/national-file-b/all"
        }
    }
}

// MARK: - API Errors

/// Defines the possible errors that can occur during API interaction.
enum HeraAPIError: Error, LocalizedError {
    case invalidURL
    case requestFailed(String)
    case decodingFailed
    case noData
    case tooManyGroupByColumns
    case authenticationFailed
    case forbidden
    case notFound
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
        case .tooManyGroupByColumns:
            return "Too many group-by columns specified."
        case .authenticationFailed:
            return "Authentication failed. Check credentials."
        case .forbidden:
            return "Access forbidden."
        case .notFound:
            return "Resource not found."
        case .unknown(let error):
            return "An unknown error occurred: \(error.localizedDescription)"
        }
    }
}

// MARK: - Authentication
// IMPORTANT:  This is placeholder code.  In a production app, never hardcode secrets. Use secure storage like the Keychain.
struct AuthCredentials {
    static let clientID = "your_client_id" // Placeholder
    static let clientSecret = "your_client_secret" // Placeholder
}

/// Decodes the token response from the authentication API.
struct TokenResponse: Decodable {
    let access_token: String
    let token_type: String
    let expires_in: Int
    let scope: String
}


// MARK: - Data Service

final class HeraDataService: ObservableObject {
    @Published var heraData: [HeraRow] = [] // For /specification endpoint
    @Published var heraAllData: [HeraTransformed] = [] //for the /all endpoint
    @Published var hyperMediaPage: HeraTransformedHypermediaPage? /// For /all endpoint
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let baseURLString = "https://api.fanniemae.com"
      private let tokenURL = "https://auth.pingone.com/4c2b23f9-52b1-4f8f-aa1f-1d477590770c/as/token"
      private var accessToken: String?
      private var tokenExpiration: Date?
      private var cancellables = Set<AnyCancellable>()

    // MARK: - Token Management (Reusing from LoanPerformanceDataService, but adapted)
    
      private func getAccessToken(completion: @escaping (Result<String, HeraAPIError>) -> Void) {
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
                guard let httpResponse = response as? HTTPURLResponse else {
                  throw HeraAPIError.requestFailed("Invalid response type")
                }
                switch httpResponse.statusCode {
                case 200...299:
                    return data
                case 401:
                    throw HeraAPIError.authenticationFailed
                case 403:
                    throw HeraAPIError.forbidden
                default:
                    let responseString = String(data: data, encoding: .utf8) ?? ""
                    throw HeraAPIError.requestFailed("Invalid response. Status code: \(httpResponse.statusCode), Response: \(responseString)")
                }
            }
            .decode(type: TokenResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completionResult in
                switch completionResult {
                case .finished:
                    break
                case .failure(let error):
                    let apiError = (error as? HeraAPIError) ?? HeraAPIError.unknown(error)
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


    // MARK: - Public API Data Fetching

    func fetchData(for endpoint: HeraAPIEndpoint) {
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
    
    private func makeDataRequest(endpoint: HeraAPIEndpoint, accessToken: String) {
        guard let url = URL(string: baseURLString + endpoint.path) else {
          handleError(.invalidURL)
          return
        }

        var request: URLRequest
        switch endpoint {
        case .aggregate(let querySpec):
             request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            // No x-public-access-token, use standard Authorization
             request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            do {
                request.httpBody = try JSONEncoder().encode(querySpec)
            } catch {
                handleError(.unknown(error))
                return
            }
        case .all(let page):
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
            components.queryItems = [URLQueryItem(name: "page", value: String(page))]
          guard let urlWithPage = components.url else {
                handleError(.invalidURL) // Handle invalid URL
                return;
            }
            request = URLRequest(url: urlWithPage)
            request.httpMethod = "GET"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }

      let publisher: AnyPublisher<Data, Error> = URLSession.shared.dataTaskPublisher(for: request)
      .tryMap { data, response in
          guard let httpResponse = response as? HTTPURLResponse else {
              throw HeraAPIError.requestFailed("Invalid response type")
          }
        
          switch httpResponse.statusCode {
            case 200...299:
              return data
            case 400:
              throw HeraAPIError.tooManyGroupByColumns // Specific error for 400
            case 401: // Unauthorized
                throw HeraAPIError.authenticationFailed
            case 403:
              throw HeraAPIError.forbidden
            case 404:
              throw HeraAPIError.notFound
            case 500: // Internal Server Error.
              let responseString = String(data: data, encoding: .utf8) ?? "No Response Body"
              throw HeraAPIError.requestFailed("HTTP Status Code error. Response: \(responseString)")
            
            default:
              let responseString = String(data: data, encoding: .utf8) ?? "No Response Body"
              throw HeraAPIError.requestFailed("Unhandled HTTP Status Code: \(httpResponse.statusCode). Response: \(responseString)")
          }
      }
      .eraseToAnyPublisher()

        publisher
        .receive(on: DispatchQueue.main)
          .sink { [weak self] completionResult in
              guard let self = self else { return }
              self.isLoading = false
              switch completionResult {
              case .finished:
                  break
              case .failure(let error):
                  self.handleError((error as? HeraAPIError) ?? .unknown(error))
              }
          } receiveValue: { [weak self] data in
              guard let self = self else { return }
              self.decodeData(data: data, for: endpoint)
          }
          .store(in: &cancellables)
    }
    
    private func decodeData(data: Data, for endpoint: HeraAPIEndpoint) {
        let decoder = JSONDecoder()
        do {
            switch endpoint {
            case .aggregate:
                let heraResponse = try decoder.decode(HeraResponse.self, from: data)
                if let rows = heraResponse.rows, !rows.isEmpty {
                  self.heraData = rows
                } else {
                  self.handleError(.noData)
                }
            case .all:
              let page = try decoder.decode(HeraTransformedHypermediaPage.self, from: data)
                self.hyperMediaPage = page
                if let datas = page._embedded?.hera, !datas.isEmpty {
                  self.heraAllData.append(contentsOf: datas) // Accumulate data
                } else {
                  self.handleError(.noData)
                }

            }
        } catch {
          print(error) // Always log
            handleError(.decodingFailed)
        }
    }
    
    
    
    // MARK: - Error Handling

    private func handleError(_ error: HeraAPIError) {
        errorMessage = error.localizedDescription
        print("HERA API Error: \(error.localizedDescription)")  // More specific log
    }

    /// Clears any locally stored data.
      func clearLocalData() {
          heraData.removeAll()
          heraAllData.removeAll() //also clear heraAllData
        hyperMediaPage = nil
      }
}
// MARK: - SwiftUI Views (Example)

struct HeraContentView: View {
    @StateObject private var dataService = HeraDataService()
    @State private var selectedGroupBy: String = ""
    @State private var page: Int = 0;

    var body: some View {
        NavigationView {
            Form {
              Section(header: Text("HERA Data Aggregation")) {
                TextField("Group By (e.g., enterprise)", text: $selectedGroupBy)
                
                
                Button("Aggregate Data") {
                    
                    let querySpec = HeraQuerySpecification(translatedWhereClause: nil,
                                                           translatedGroupByColumns: [selectedGroupBy],
                                                           aggregationColumns: "count",
                                                           whereClauseColumns: nil,
                                                           whereClauseValues: nil)
                    dataService.fetchData(for: .aggregate(querySpec))
                }
                .buttonStyle(.bordered)
              }
              Section {
                Button("Fetch All Data Page \(page)") {
                    dataService.fetchData(for: .all(page: page))
                }
                .buttonStyle(.borderedProminent)
                Button("Clear Data", role: .destructive) {
                    dataService.clearLocalData()
                }
                
                Button("Next Page") {
                    page += 1
                  dataService.fetchData(for: .all(page: page))
                }.buttonStyle(.bordered)
              }
            
                Section(header: Text("Results")) {
                    if dataService.isLoading {
                        ProgressView("Loading...")
                    } else if let errorMessage = dataService.errorMessage {
                        Text("Error: \(errorMessage)")
                            .foregroundColor(.red)
                    } else {
                      if (!dataService.heraData.isEmpty){
                        List(dataService.heraData, id: \.groupedByColumnValues) { item in
                            VStack(alignment: .leading) {
                                Text("Group: \(item.groupedByColumnValues ?? "N/A")")
                                Text("Count: \(item.count ?? 0)")
                            }
                        }
                      } else {
                        List(dataService.heraAllData) {
                          item in
                          VStack(alignment: .leading, spacing: 4) {
                            if let val = item.enterprise {
                              Text("Enterprise: \(val)")
                            }
                            if let val = item.msaType {
                                Text("msaType: \(val)")
                              }
                            if let val = item.censusTractPctMinority {
                                Text("censusTractPctMinority: \(val)")
                              }
                            if let val = item.tractIncomeRatio {
                                Text("tractIncomeRatio: \(val)")
                              }
                            if let val = item.borrowerIncomeRatio {
                                Text("borrowerIncomeRatio: \(val)")
                              }
                            if let val = item.dateAcquiredVsDateOriginated {
                                Text("dateAcquiredVsDateOriginated: \(val)")
                              }
                            if let val = item.loanPurpose {
                                Text("loanPurpose: \(val)")
                              }
                            if let val = item.federalGuarantee {
                              Text("federalGuarantee: \(val)")
                            }
                            if let val = item.sellerInstitutionType {
                                Text("sellerInstitutionType: \(val)")
                              }
                            if let val = item.borrowerRaceOriginEthnicity {
                                Text("borrowerRaceOriginEthnicity: \(val)")
                              }
                            if let val = item.coborrowerRaceOriginEthnicity {
                                Text("coborrowerRaceOriginEthnicity: \(val)")
                              }
                            if let val = item.borrowerGender {
                                Text("borrowerGender: \(val)")
                              }
                            if let val = item.coborrowerGender {
                                Text("coborrowerGender: \(val)")
                              }
                            if let val = item.occupancyCode {
                                Text("occupancyCode: \(val)")
                              }
                            if let val = item.numberOfUnits {
                                Text("numberOfUnits: \(val)")
                              }
                            if let val = item.ownerOccupied {
                                Text("ownerOccupied: \(val)")
                              }
                            if let val = item.affordabilityCategory {
                                Text("affordabilityCategory: \(val)")
                              }
                            if let val = item.reportingYear {
                              Text("reportingYear: \(val)")
                            }
                          }
                        }
                      }
                    }
                }
              if let pageInfo = dataService.hyperMediaPage, let total = pageInfo.total {
                Text("Total results: \(total)")
              }

            }
            .navigationTitle("HERA Data")
        }
    }
}

// MARK: - Preview

struct HeraContentView_Previews: PreviewProvider {
    static var previews: some View {
        HeraContentView()
    }
}
