//
//  ConstructionSpendingView_v3.swift
//  MyApp
//
//  Created by Cong Le on 4/28/25.
//

import SwiftUI
import Combine // For asynchronous operations and networking

// MARK: - Data Models (Aligned with OpenAPI Spec)

// --- Models for GET Endpoints ---

// Represents the overall spending data for a specific category (Section/Sector/Subsector)
struct ConstructionSpendingDto: Decodable, Identifiable, Hashable {
    let id = UUID() // For SwiftUI List identification
    // The actual data points are nested within this array
    let constructionSpending: [ConstructionSpendingDatumDto]?

    // Need CodingKeys if JSON key differs or for clarity
    enum CodingKeys: String, CodingKey {
        case constructionSpending // JSON key matches property name
    }

    // Required for Hashable
    func hash(into hasher: inout Hasher) {
        // Hash based on the content; could be more specific if a unique identifier existed in the DTO
        hasher.combine(constructionSpending)
    }

    // Required for Hashable
    static func == (lhs: ConstructionSpendingDto, rhs: ConstructionSpendingDto) -> Bool {
        // Compare based on content
        return lhs.constructionSpending == rhs.constructionSpending
    }
}

// Represents a single data point (value for a specific month/type)
struct ConstructionSpendingDatumDto: Decodable, Identifiable, Hashable {
    let id = UUID() // For SwiftUI List identification
    let constructionSpendingValue: Double? // Mapped from "construction-spending-value"
    let monthAndValueType: String?         // Mapped from "month-and-value-type" (e.g., "MAY23 SA")
    let monthLabelType: String?            // Mapped from "month-label-type" (e.g., "MAY-2023")
    let dataSectionName: String?           // Mapped from "data-section-name" (e.g., "Total Construction")

    // Maps JSON keys (with hyphens) to Swift properties (camelCase)
    enum CodingKeys: String, CodingKey {
        case constructionSpendingValue = "construction-spending-value"
        case monthAndValueType = "month-and-value-type"
        case monthLabelType = "month-label-type"
        case dataSectionName = "data-section-name"
    }

    // Required for Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(monthAndValueType) // Often unique within a parent Dto
        hasher.combine(dataSectionName)
    }

    // Required for Hashable
    static func == (lhs: ConstructionSpendingDatumDto, rhs: ConstructionSpendingDatumDto) -> Bool {
        return lhs.monthAndValueType == rhs.monthAndValueType &&
               lhs.dataSectionName == rhs.dataSectionName &&
               lhs.constructionSpendingValue == rhs.constructionSpendingValue
    }
}

// --- Models for POST Endpoint (/multiple) ---
// We define these for completeness, though the UI won't use the POST endpoint in this example.

// Request Body Structure
struct MultiplePostQuery: Encodable { // Encodable for sending
    let queryItems: [MultiplePostQueryItem]
}

struct MultiplePostQueryItem: Encodable {
    let section: String
    let sector: String? // Optional based on description
    let subsector: String? // Optional based on description
}

// Response Body Structure
struct MultiplePostResponse: Decodable {
    let postResponseItems: [MultiplePostResponseItem]?
}

struct MultiplePostResponseItem: Decodable, Identifiable, Hashable {
    let id = UUID() // For SwiftUI
    let value: Double?
    let path: String? // The original path queried (e.g., "Total/Residential")
    let spendingValueType: String? // e.g., "SA" (Seasonally Adjusted) or "NSA"
    let monthYear: String? // e.g., "MAY23"

    enum CodingKeys: String, CodingKey {
        case value, path
        case spendingValueType = "spending-value-type" // Map hyphenated key
        case monthYear = "month-year"               // Map hyphenated key
    }

    // Hashable & Equatable conformance
     func hash(into hasher: inout Hasher) {
         hasher.combine(path)
         hasher.combine(monthYear)
     }

     static func == (lhs: MultiplePostResponseItem, rhs: MultiplePostResponseItem) -> Bool {
         return lhs.path == rhs.path && lhs.monthYear == rhs.monthYear
     }
}

// MARK: - API Endpoints Enum

enum ConstructionSpendingAPIEndpoint {
    case bySection(section: String)
    case bySectionAndSector(section: String, sector: String)
    case bySectionSectorAndSubsector(section: String, sector: String, subsector: String)
    // case multiple(items: [MultiplePostQueryItem]) // POST Endpoint definition (not used in UI)

    // Base path component
    private var basePath: String { "/v1/construction-spending" }

    // Computed property for the full path (without query params)
    var path: String {
        switch self {
        case .bySection:
            return "\(basePath)/section"
        case .bySectionAndSector:
            return "\(basePath)/sectionandsector"
        case .bySectionSectorAndSubsector:
            return "\(basePath)/sectionsectorandsubsector"
        // case .multiple: // POST endpoint
        //     return "\(basePath)/multiple"
        }
    }

    // Computed property for query parameters (for GET requests)
    var queryItems: [URLQueryItem]? {
        switch self {
        case .bySection(let section):
            return [URLQueryItem(name: "section", value: section)]
        case .bySectionAndSector(let section, let sector):
            return [
                URLQueryItem(name: "section", value: section),
                URLQueryItem(name: "sector", value: sector)
            ]
        case .bySectionSectorAndSubsector(let section, let sector, let subsector):
            return [
                URLQueryItem(name: "section", value: section),
                URLQueryItem(name: "sector", value: sector),
                URLQueryItem(name: "subsector", value: subsector)
            ]
        // case .multiple: // POST endpoint doesn't use query params
        //     return nil
        }
    }

    // HTTP Method
    var method: String {
        switch self {
        // case .multiple: return "POST"
        default: return "GET"
        }
    }
}

// MARK: - API Errors Enum

enum ConstructionSpendingAPIError: Error, LocalizedError {
    case invalidURL
    case requestFailed(statusCode: Int, message: String)
    case authenticationFailed(String)
    case tokenDecodingFailed
    case dataDecodingFailed(Error) // Include underlying decoding error
    case requestEncodingFailed(Error) // For POST body encoding issues
    case noData // Specifically for 204 or empty results
    case invalidParameters(String) // For input validation issues
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The API URL provided was invalid."
        case .requestFailed(let statusCode, let message):
            return "The API request failed with status code \(statusCode). Message: \(message)"
        case .authenticationFailed(let reason):
            return "Authentication failed: \(reason). Check credentials."
        case .tokenDecodingFailed:
            return "Failed to decode the authentication token."
        case .dataDecodingFailed(let underlyingError):
            return "Failed to decode the construction spending data. Error: \(underlyingError.localizedDescription)"
        case .requestEncodingFailed(let underlyingError):
             return "Failed to encode the request body. Error: \(underlyingError.localizedDescription)"
        case .noData:
            return "No construction spending data was found for the selected criteria."
        case .invalidParameters(let message):
            return "Invalid input parameters: \(message)"
        case .unknown(let error):
            return "An unexpected error occurred: \(error.localizedDescription)"
        }
    }
}

// MARK: - Authentication Handling (Reused Logic)

struct ConstructionSpendingAuthCredentials {
    // --- ⚠️ IMPORTANT SECURITY WARNING ⚠️ ---
    // Replace with your actual credentials securely. NEVER commit real secrets.
    static let clientID = "YOUR_CLIENT_ID_HERE"
    static let clientSecret = "YOUR_CLIENT_SECRET_HERE"
    // -----------------------------------------
}

// Reusing TokenResponse struct from previous example
// struct TokenResponse: Decodable { ... }

// MARK: - Data Service (ObservableObject)

final class ConstructionSpendingService: ObservableObject {
    // Published properties for UI updates
    // The main data array will hold DTOs, each containing multiple datum points
    @Published var spendingDataGroups: [ConstructionSpendingDto] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    // API and Token URLs
    private let baseURLString = "https://api.fanniemae.com"
    // Assuming same token URL as Loan Limits API
    private let tokenURLString = "https://auth.pingone.com/4c2b23f9-52b1-4f8f-aa1f-1d477590770c/as/token"

    // Token cache (simple in-memory)
    private var accessToken: String?
    private var tokenExpiration: Date?

    // Combine cancellables
    private var cancellables = Set<AnyCancellable>()
    private var tokenFetchCancellable: AnyCancellable?

    // MARK: - Token Management (Identical to LoanLimitsService)
    private func getAccessToken() -> Future<String, ConstructionSpendingAPIError> {
         return Future { [weak self] promise in
              guard let self = self else {
                   promise(.failure(.unknown(NSError(domain: "ConstructionSpendingService", code: -2, userInfo: [NSLocalizedDescriptionKey: "Service deallocated"]))))
                   return
              }

              if let token = self.accessToken, let expiration = self.tokenExpiration, Date().addingTimeInterval(60) < expiration {
                   print("Using cached access token.")
                   promise(.success(token))
                   return
              }

              print("Fetching new access token...")
              guard let url = URL(string: self.tokenURLString) else {
                   promise(.failure(.invalidURL))
                   return
              }

              let credentials = "\(ConstructionSpendingAuthCredentials.clientID):\(ConstructionSpendingAuthCredentials.clientSecret)"
              guard let base64Credentials = credentials.data(using: .utf8)?.base64EncodedString() else {
                   promise(.failure(.authenticationFailed("Could not encode credentials.")))
                   return
              }

              var request = URLRequest(url: url)
              request.httpMethod = "POST"
              request.addValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")
              request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
              request.httpBody = "grant_type=client_credentials".data(using: .utf8)

              self.tokenFetchCancellable = URLSession.shared.dataTaskPublisher(for: request)
                   .tryMap { data, response -> Data in
                       guard let httpResponse = response as? HTTPURLResponse else {
                            throw ConstructionSpendingAPIError.requestFailed(statusCode: -1, message: "Invalid response object.")
                       }
                       guard (200...299).contains(httpResponse.statusCode) else {
                           let responseString = String(data: data, encoding: .utf8) ?? "No response body"
                            throw ConstructionSpendingAPIError.authenticationFailed("Token request failed with status \(httpResponse.statusCode). Response: \(responseString)")
                       }
                       return data
                   }
                   .decode(type: TokenResponse.self, decoder: JSONDecoder())
                   .receive(on: DispatchQueue.main)
                   .sink(receiveCompletion: { completionResult in
                       switch completionResult {
                       case .finished: break
                       case .failure(let error):
                           print("Token fetching failed: \(error)")
                           if let _ = error as? DecodingError {
                               promise(.failure(.tokenDecodingFailed))
                           } else if let apiError = error as? ConstructionSpendingAPIError {
                               promise(.failure(apiError))
                           } else {
                               promise(.failure(.unknown(error)))
                           }
                       }
                   }, receiveValue: { tokenResponse in
                       print("Successfully fetched new token.")
                       self.accessToken = tokenResponse.access_token
                       self.tokenExpiration = Date().addingTimeInterval(TimeInterval(tokenResponse.expires_in))
                       promise(.success(tokenResponse.access_token))
                   })
        }
    }

    // MARK: - Public Data Fetching (GET Endpoints)
    func fetchData(for endpoint: ConstructionSpendingAPIEndpoint) {
         guard endpoint.method == "GET" else {
              print("Error: FetchData called with non-GET endpoint: \(endpoint)")
              self.handleError(.invalidParameters("This function only handles GET requests."))
              return
         }

         isLoading = true
         errorMessage = nil
         spendingDataGroups.removeAll() // Clear previous results

         getAccessToken()
             .flatMap { [weak self] token -> AnyPublisher<[ConstructionSpendingDto], ConstructionSpendingAPIError> in
                 guard let self = self else {
                      return Fail(error: .unknown(NSError(domain: "ConstructionSpendingService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Service deallocated"])))
                            .eraseToAnyPublisher()
                 }
                 return self.makeGETDataRequest(endpoint: endpoint, accessToken: token)
             }
             .receive(on: DispatchQueue.main)
             .sink(receiveCompletion: { [weak self] completionResult in
                 guard let self = self else { return }
                 self.isLoading = false
                 switch completionResult {
                 case .finished:
                      print("Data fetch finished for endpoint: \(endpoint.path)")
                      // Check if the *resulting* array is empty even after a successful fetch (e.g., 204 or valid empty JSON)
                      if self.spendingDataGroups.isEmpty {
                           self.handleError(.noData) // Use the specific noData error
                      }
                 case .failure(let error):
                     // Error already mapped in makeGETDataRequest, just handle it
                     self.handleError(error) // Use the mapped error directly
                 }
             }, receiveValue: { [weak self] fetchedDataGroups in
                  print("Received \(fetchedDataGroups.count) data groups for endpoint: \(endpoint.path)")
                  self?.spendingDataGroups = fetchedDataGroups
             })
             .store(in: &cancellables)
    }

    /// Makes the actual GET network request for Construction Spending data.
    private func makeGETDataRequest(endpoint: ConstructionSpendingAPIEndpoint, accessToken: String) -> AnyPublisher<[ConstructionSpendingDto], ConstructionSpendingAPIError> {
         guard var urlComponents = URLComponents(string: baseURLString + endpoint.path) else {
              return Fail(error: .invalidURL).eraseToAnyPublisher()
         }
         // Add query parameters
         urlComponents.queryItems = endpoint.queryItems

         guard let url = urlComponents.url else {
              return Fail(error: .invalidURL).eraseToAnyPublisher()
         }
         print("Making GET data request to: \(url.absoluteString)")

         var request = URLRequest(url: url)
         request.httpMethod = "GET"
         request.addValue(accessToken, forHTTPHeaderField: "x-public-access-token")
         request.addValue("application/json", forHTTPHeaderField: "Accept") // Prefer JSON

         return URLSession.shared.dataTaskPublisher(for: request)
             .tryMap { data, response -> Data in
                 guard let httpResponse = response as? HTTPURLResponse else {
                      throw ConstructionSpendingAPIError.requestFailed(statusCode: -1, message: "Invalid response object.")
                 }
                  // Handle 204 No Content explicitly
                  if httpResponse.statusCode == 204 {
                      return Data() // Return empty data for 204, will result in empty array downstream
                  }
                 guard (200...299).contains(httpResponse.statusCode) else {
                      let responseBody = String(data: data, encoding: .utf8) ?? "No response body"
                      if httpResponse.statusCode == 404 {
                         throw ConstructionSpendingAPIError.noData // Map 404 to NoData
                      } else {
                         throw ConstructionSpendingAPIError.requestFailed(statusCode: httpResponse.statusCode, message: responseBody)
                      }
                 }
                 return data
             }
             // Decode the expected array response
             .decode(type: [ConstructionSpendingDto].self, decoder: JSONDecoder())
             .mapError { error -> ConstructionSpendingAPIError in // Map errors
                  print("Decoding/Network error: \(error)")
                  if let decodingError = error as? DecodingError {
                      return .dataDecodingFailed(decodingError)
                  } else if let apiError = error as? ConstructionSpendingAPIError {
                      return apiError
                  } else {
                      return .unknown(error)
                  }
             }
             .eraseToAnyPublisher()
    }

    // MARK: - Error Handling
    private func handleError(_ error: ConstructionSpendingAPIError) {
        self.errorMessage = error.localizedDescription
        print("API Error Handled: \(error.localizedDescription)")
    }

    // MARK: - Utility
    func clearLocalData() {
        spendingDataGroups.removeAll()
        errorMessage = nil
        print("Local spending data cleared.")
    }
}

// MARK: - SwiftUI Views

struct ConstructionSpendingView: View {
    @StateObject private var dataService = ConstructionSpendingService()

    // State for Pickers
    @State private var selectedSection: String = "Total" // Default value
    @State private var selectedSector: String = "Residential" // Default value
    @State private var selectedSubsector: String = "Lodging" // Default value

    // Define Picker options clearly
    let sections = ["Total", "Private", "Public"]
    let sectors = ["Residential", "Nonresidential"]
    let subsectors = ["Lodging", "Office", "Commercial", "Health care", "Educational", "Religious", "Public safety", "Amusement and recreation", "Transportation", "Communication", "Power", "Highway and street", "Sewage and waste disposal", "Water supply", "Conservation and development", "Manufacturing"]

    var body: some View {
        NavigationView {
            VStack {
                Form {
                    // --- Selection Section ---
                    Section(header: Text("Select Criteria").font(.headline)) {
                        Picker("Section", selection: $selectedSection) {
                            ForEach(sections, id: \.self) { Text($0) }
                        }

                        Picker("Sector", selection: $selectedSector) {
                            ForEach(sectors, id: \.self) { Text($0) }
                        }
                        // Only show subsector picker if Nonresidential is selected, as it's only valid there
                        if selectedSector == "Nonresidential" {
                            Picker("Subsector", selection: $selectedSubsector) {
                                ForEach(subsectors, id: \.self) { Text($0) }
                            }
                        } else {
                            Text("Subsector (N/A for Residential)")
                                .foregroundColor(.secondary)
                        }
                    }

                    // --- Fetch Action Buttons ---
                    Section(header: Text("Fetch Data").font(.headline)) {
                        HStack(spacing: 15) { // Use HStack for button row layout
                            Spacer() // Push buttons to center/right

                            Button {
                                dataService.fetchData(for: .bySection(section: selectedSection))
                            } label: {
                                Label("By Section", systemImage: "chart.pie")
                            }
                            .buttonStyle(.bordered)
                            .disabled(dataService.isLoading)

                            Button {
                                dataService.fetchData(for: .bySectionAndSector(section: selectedSection, sector: selectedSector))
                            } label: {
                                Label("By Section & Sector", systemImage: "chart.bar.xaxis")
                            }
                            .buttonStyle(.bordered)
                            .disabled(dataService.isLoading)

                            // Only enable subsector fetch if Nonresidential is selected
                            Button {
                                dataService.fetchData(for: .bySectionSectorAndSubsector(section: selectedSection, sector: selectedSector, subsector: selectedSubsector))
                            } label: {
                                Label("By Subsector", systemImage: "list.number")
                            }
                            .buttonStyle(.bordered)
                            .disabled(dataService.isLoading || selectedSector != "Nonresidential")

                            Spacer() // Push buttons to center/left
                        }

                        Button("Clear Results", role: .destructive) {
                              dataService.clearLocalData()
                        }
                        .buttonStyle(.bordered)
                        .tint(.orange)
                         .disabled(dataService.isLoading)
                         .frame(maxWidth: .infinity, alignment: .center) // Center the clear button
                    }

                    // --- Results Display ---
                    Section(header: Text("Spending Data Results").font(.headline)) {
                        if dataService.isLoading {
                            ProgressView("Fetching data...")
                                .frame(maxWidth: .infinity, alignment: .center)
                        } else if let errorMessage = dataService.errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding()
                        } else if dataService.spendingDataGroups.isEmpty {
                             Text("No data to display. Select criteria and fetch.")
                                 .foregroundColor(.secondary)
                                 .frame(maxWidth: .infinity, alignment: .center)
                                 .padding()
                        } else {
                             List {
                                 // Iterate through each DTO (which represents a specific requested category)
                                 ForEach(dataService.spendingDataGroups) { dataGroup in
                                     // Iterate through the actual data points (monthly values) within that DTO
                                      // Use .flatMap to safely unwrap the optional array and handle nil
                                      ForEach(dataGroup.constructionSpending ?? []) { datum in
                                          SpendingDatumRow(datum: datum)
                                      }
                                 }
                             }
                              // Add a count (consider counting total datums if more meaningful)
                             .overlay(alignment: .bottom) {
                                 Text("\(totalDataPoints) data point(s) displayed")
                                     .font(.caption)
                                     .foregroundColor(.secondary)
                                     .padding(.vertical, 4)
                                     .frame(maxWidth: .infinity)
                                     .background(.thinMaterial)
                             }
                        }
                    }
                } // End Form
                .navigationTitle("Construction Spending")
                .navigationBarTitleDisplayMode(.inline)
            } // End VStack
            .onAppear {
                // Check credentials on appear
                 if ConstructionSpendingAuthCredentials.clientID == "YOUR_CLIENT_ID_HERE" || ConstructionSpendingAuthCredentials.clientSecret == "YOUR_CLIENT_SECRET_HERE" {
                     dataService.errorMessage = "⚠️ Config Error: Update API credentials in ConstructionSpendingAuthCredentials."
                 }
            }

        } // End NavigationView
          .navigationViewStyle(.stack)
    }
    
    // Helper computed property to count total displayed points
    private var totalDataPoints: Int {
        dataService.spendingDataGroups.reduce(0) { count, group in
            count + (group.constructionSpending?.count ?? 0)
        }
    }
}

// MARK: - Spending Datum Row View

struct SpendingDatumRow: View {
    let datum: ConstructionSpendingDatumDto

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(datum.dataSectionName ?? "Unknown Section") // Display the category name
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("Period: \(datum.monthLabelType ?? datum.monthAndValueType ?? "N/A")") // Prefer formatted label
                    .font(.subheadline)
            }
            Spacer()
            Text(formatCurrency(datum.constructionSpendingValue)) // Format the value
                .font(.headline)
        }
    }

    // Currency formatter
    private func formatCurrency(_ value: Double?) -> String {
        guard let value = value else { return "N/A" }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0 // Assuming these are large dollar amounts
        formatter.currencySymbol = "$" // Or relevant symbol
        // API values are likely in millions, but display as is unless context demands conversion
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}

// MARK: - Preview Provider

struct ConstructionSpendingView_Previews: PreviewProvider {
    static var previews: some View {
        // Mock data for previewing the UI layout
         let mockDatum1 = ConstructionSpendingDatumDto(constructionSpendingValue: 150000.50, monthAndValueType: "JAN23 SA", monthLabelType: "Jan-2023", dataSectionName: "Total Residential")
         let mockDatum2 = ConstructionSpendingDatumDto(constructionSpendingValue: 165000.00, monthAndValueType: "FEB23 SA", monthLabelType: "Feb-2023", dataSectionName: "Total Residential")
         let mockGroup1 = ConstructionSpendingDto(constructionSpending: [mockDatum1, mockDatum2])

         let mockDatum3 = ConstructionSpendingDatumDto(constructionSpendingValue: 50000.0, monthAndValueType: "JAN23 SA", monthLabelType: "Jan-2023", dataSectionName: "Private Nonresidential Office")
         let mockGroup2 = ConstructionSpendingDto(constructionSpending: [mockDatum3])

        // Create a service instance for the preview
        let previewService = ConstructionSpendingService()
         previewService.spendingDataGroups = [mockGroup1, mockGroup2] // Populate with mock data
         // previewService.errorMessage = "Sample Preview Error Message" // Test error state
         // previewService.isLoading = true // Test loading state

        // Return the view, injecting the mock service
        //ConstructionSpendingView(dataService: previewService)
        return ConstructionSpendingView()
    }
}
