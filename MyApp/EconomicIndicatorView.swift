////
////  EconomicIndicatorView.swift
////  MyApp
////
////  Created by Cong Le on 3/22/25.
////
//
//import SwiftUI
//import Combine
//
//// MARK: - Data Models
//
///// Unified data model for economic indicator data.
//struct EconomicIndicatorData: Identifiable, Equatable {
//    let id = UUID()
//    let effectiveDate: Date
//    let indicatorName: String
//    let points: [DataPoint]
//
//    struct DataPoint: Identifiable, Equatable {
//        let id = UUID()
//        let forecast: Bool
//        let quarter: String
//        let year: Int
//        let value: Double
//    }
//    
//    // Initializes from IndicatorTimeSeriesDouble
//        init(from series: IndicatorTimeSeriesDouble) {
//            // Date formatter for converting string to Date
//            let dateFormatter = DateFormatter()
//            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
//            dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
//            self.effectiveDate = dateFormatter.date(from: series.effectiveDate) ?? Date()
//            self.indicatorName = series.indicatorName
//            self.points = series.points.map {
//                DataPoint(forecast: $0.forecast, quarter: $0.quarter, year: $0.year, value: $0.value)
//            }
//        }
//}
//
///// Represents a single time series data point with a double value.
//struct TimeSeriesDataPointQuarterDouble: Decodable, Equatable {
//    let forecast: Bool
//    let value: Double
//    let year: Int
//    let quarter: String
//}
//
///// Represents the entire report containing multiple indicators.
//struct IndicatorsReport: Decodable {
//    let indicators: [IndicatorTimeSeriesDouble]
//}
///// Represents a time series of economic indicator data.
//struct IndicatorTimeSeriesDouble: Decodable, Equatable {
//    let effectiveDate: String
//    let indicatorName: String
//    let points: [TimeSeriesDataPointQuarterDouble]
//}
//
//// MARK: - API Endpoints
//
///// Enumerates the available API endpoints.
//enum APIEndpointEconomic {
//    case indicatorByName(indicator: String)
//    case indicatorForYear(year: Int)
//    case indicatorForYearAndMonth(year: Int, month: Int)
//    case indicatorForYearAndQuarter(year: Int, quarter: String)
//    case indicatorReportForYear(year: Int)
//
//      /// Computed property to determine the path with any query parameters needed.
//    var path: String {
//        switch self {
//        case .indicatorByName(let indicator):
//            return "/v1/economic-forecasts/indicators/\(indicator)"
//        case .indicatorForYear(let year):
//            return "/v1/economic-forecasts/data/years/\(year)"
//        case .indicatorForYearAndMonth(let year, let month):
//            return "/v1/economic-forecasts/reports/years/\(year)/months/\(month)"
//        case .indicatorForYearAndQuarter(let year, let quarter):
//            return "/v1/economic-forecasts/data/years/\(year)/quarters/\(quarter)"
//        case .indicatorReportForYear(let year):
//            return "/v1/economic-forecasts/reports/years/\(year)"
//        }
//    }
//}
//
//// MARK: - API Errors
//
///// Defines the possible API errors.  Uses LocalizedError for user-friendly messages.
//enum APIErrorEconomic: Error, LocalizedError {
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
//// MARK: - Authentication (Shared with Previous Example - Consider a separate file)
//
//struct AuthCredentialsEconomic {
//    static let clientID = "clientIDKeyHere"
//    static let clientSecret = "clientSecretKeyHere"
//}
//
//struct TokenResponseEconomic: Decodable {
//    let access_token: String
//    let token_type: String
//    let expires_in: Int
//    let scope: String
//}
//
//// MARK: - Data Service
//
///// Service for fetching and managing economic indicator data.
//final class EconomicIndicatorDataService: ObservableObject {
//    @Published var economicData: [EconomicIndicatorData] = []
//    @Published var isLoading = false
//    @Published var errorMessage: String?
//
//    private let baseURLString = "https://api.fanniemae.com"
//    private let tokenURL = "https://auth.pingone.com/4c2b23f9-52b1-4f8f-aa1f-1d477590770c/as/token"
//      private var accessToken: String? // Store the token for reuse
//      private var tokenExpiration: Date?  // Store expiry for reuse
//    private var cancellables = Set<AnyCancellable>() // cancel Combine operations
//    
//    // MARK: - Token Management (Reused and adapted from previous example)
//
//     private func getAccessToken(completion: @escaping (Result<String, APIErrorEconomic>) -> Void) {
//               // Return token if still valid.
//           if let token = accessToken, let expiration = tokenExpiration, Date() < expiration {
//               completion(.success(token))
//               return
//           }
//
//           guard let url = URL(string: tokenURL) else {
//               completion(.failure(.invalidURL))
//               return
//           }
//
//           let credentials = "\(AuthCredentialsEconomic.clientID):\(AuthCredentialsEconomic.clientSecret)"
//           guard let base64Credentials = credentials.data(using: .utf8)?.base64EncodedString() else {
//               completion(.failure(.authenticationFailed))
//               return
//           }
//
//           var request = URLRequest(url: url)
//           request.httpMethod = "POST"
//           request.addValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")
//           request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
//           request.httpBody = "grant_type=client_credentials".data(using: .utf8)
//
//           URLSession.shared.dataTaskPublisher(for: request)
//               .tryMap { data, response -> Data in
//                   guard let httpResponse = response as? HTTPURLResponse,
//                         (200...299).contains(httpResponse.statusCode) else {
//                       let responseString = String(data: data, encoding: .utf8) ?? ""
//                       throw APIErrorEconomic.requestFailed("Invalid response.  Response: \(responseString)")
//                   }
//                   return data
//               }
//               .decode(type: TokenResponseEconomic.self, decoder: JSONDecoder())
//               .receive(on: DispatchQueue.main)
//               .sink { [weak self] completionResult in
//                switch completionResult {
//                case .finished:
//                    break // Handle successful completion if needed
//                case .failure(let error):
//                    let apiError = (error as? APIErrorEconomic) ?? APIErrorEconomic.unknown(error)
//                    self?.handleError(apiError) // Use the common error handler
//                    completion(.failure(apiError))
//                }
//            } receiveValue: { [weak self] tokenResponse in
//                // Store token and expiration, handling potential threading issues
//                self?.accessToken = tokenResponse.access_token
//                self?.tokenExpiration = Date().addingTimeInterval(TimeInterval(tokenResponse.expires_in))
//                completion(.success(tokenResponse.access_token))
//            }
//            .store(in: &cancellables)
//       }
//
//    // MARK: - Public API
//
//    /// Fetches data for the specified endpoint.
//    func fetchData(for endpoint: APIEndpointEconomic) {
//        isLoading = true
//        errorMessage = nil
//        
//        getAccessToken { [weak self] result in
//                   guard let self = self else { return }
//                   switch result {
//                   case .success(let token):
//                       self.makeDataRequest(endpoint: endpoint, accessToken: token)
//                   case .failure(let error):
//                       DispatchQueue.main.async {
//                           self.isLoading = false
//                           self.handleError(error)
//                       }
//                   }
//               }
//    }
//    
//        
//        
//    private func makeDataRequest(endpoint: APIEndpointEconomic, accessToken: String) {
//              guard let url = URL(string: baseURLString + endpoint.path) else {
//                  handleError(.invalidURL)
//                  return
//              }
//
//              var request = URLRequest(url: url)
//              request.httpMethod = "GET"
//              request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//              request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
//
//              URLSession.shared.dataTaskPublisher(for: request)
//                  .tryMap { data, response -> Data in
//                      guard let httpResponse = response as? HTTPURLResponse,
//                            (200...299).contains(httpResponse.statusCode) else {
//                          let responseString = String(data: data, encoding: .utf8) ?? "No Response Body"
//                          throw APIErrorEconomic.requestFailed("HTTP Status Code error. Response: \(responseString)")
//                      }
//                      return data
//                  }
//                  .decode(type: IndicatorsReport.self, decoder: JSONDecoder())
//                  .map { report in
//                    report.indicators.map { EconomicIndicatorData(from: $0) }
//                    }
//                  .receive(on: DispatchQueue.main)
//                  .sink { [weak self] completionResult in
//                      guard let self = self else { return }
//                      self.isLoading = false
//                      switch completionResult {
//                      case .finished:
//                          break
//                      case .failure(let error):
//                          let apiError = (error as? APIErrorEconomic) ?? APIErrorEconomic.unknown(error)
//                              self.handleError(apiError)
//                      }
//                  } receiveValue: { [weak self] unifiedData in
//                      guard let self = self else { return }
//                    
//                    // Remove duplicates using the Equatable conformance
//                       var uniqueData = [EconomicIndicatorData]()
//                       for item in unifiedData {
//                           if !uniqueData.contains(item) {
//                            uniqueData.append(item)
//                           }
//                       }
//                       self.economicData = uniqueData // Update the published property
//                  }
//                  .store(in: &cancellables)
//          }
//
//    // MARK: - Error Handling
//
//    /// Centralized error handling.
//    private func handleError(_ error: APIErrorEconomic) {
//        errorMessage = error.localizedDescription
//        print("API Error: \(error.localizedDescription)") // Log for debugging
//    }
//    /// Clears any locally stored data.
//       func clearLocalData() {
//           economicData.removeAll()
//       }
//}
//
//// MARK: - SwiftUI Views
//
///// Main view for displaying economic indicators.
//struct EconomicIndicatorView: View {
//    @StateObject private var dataService = EconomicIndicatorDataService()
//    @State private var selectedYear: Int = Calendar.current.component(.year, from: Date())
//    @State private var selectedQuarter: String = "Q1"
//      @State private var selectedMonth: Int = Calendar.current.component(.month, from: Date())
//      @State private var selectedIndicator: String = "gross-domestic-product"
//
//    private let quarters = ["Q1", "Q2", "Q3", "Q4", "EOY"]
//    
//      private let indicators = [
//            "gross-domestic-product",
//            "personal-consumption-expenditures",
//            "residential-fixed-investment",
//            "business-fixed-investment",
//            "government-consumption-and-investment",
//            "net-exports",
//            "change-in-business-inventories",
//            "consumer-price-index",
//            "core-consumer-price-index-excl-food-and-energy",
//            "personal-chain-expenditures-chain-price-index",
//            "core-personal-chain-expenditures-chain-price-index-excl-food-and-energy",
//            "unemployment-rate",
//            "employment-total-nonfarm",
//            "federal-funds-rate",
//            "1-year-treasury-note-yield",
//            "10-year-treasury-note-yield"
//        ]
//    
//    private var availableYears: [Int] {
//          let startYear = 2000 // Or any start year you prefer
//          let currentYear = Calendar.current.component(.year, from: Date())
//          return Array(startYear...currentYear)
//      }
//    
//    private var availableMonths: [Int] {
//            return Array(1...12)
//        }
//
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
//                          ForEach(quarters, id: \.self) { quarter in
//                              Text(quarter).tag(quarter)
//                          }
//                      }
//                    
//                      Picker("Month", selection: $selectedMonth) {
//                          ForEach(availableMonths, id: \.self) { month in
//                              Text("\(month)").tag(month)
//                          }
//                      }
//
//                      Picker("Indicator", selection: $selectedIndicator) {
//                          ForEach(indicators, id: \.self) { indicator in
//                              Text(indicator).tag(indicator)
//                          }
//                      }
//
//                    // Buttons to fetch specific endpoints data
//                     Button("Fetch by Indicator") {
//                         dataService.fetchData(for: .indicatorByName(indicator: selectedIndicator))
//                     }
//                     .buttonStyle(.bordered)
//                    
//                    Button("Fetch by Year") {
//                         dataService.fetchData(for: .indicatorForYear(year: selectedYear))
//                     }
//                     .buttonStyle(.bordered)
//
//                     Button("Fetch by Year and Month") {
//                         dataService.fetchData(for: .indicatorForYearAndMonth(year: selectedYear, month: selectedMonth))
//                     }
//                     .buttonStyle(.bordered)
//
//                     Button("Fetch by Year and Quarter") {
//                         dataService.fetchData(for: .indicatorForYearAndQuarter(year: selectedYear, quarter: selectedQuarter))
//                     }
//                     .buttonStyle(.bordered)
//                    
//                    Button("Fetch Report by Year") {
//                        dataService.fetchData(for: .indicatorReportForYear(year: selectedYear))
//                    }
//                    .buttonStyle(.borderedProminent)
//                    
//                    Button("Clear Data", role: .destructive) {
//                          dataService.clearLocalData()
//                      }
//                }
//
//                Section(header: Text("Economic Indicators")) {
//                    if dataService.isLoading {
//                        ProgressView("Loading...")
//                    } else if let errorMessage = dataService.errorMessage {
//                        Text("Error: \(errorMessage)")
//                            .foregroundColor(.red)
//                    } else {
//                        List(dataService.economicData) { indicatorData in
//                            
//                            VStack(alignment: .leading) {
//                                Text("Indicator: \(indicatorData.indicatorName)")
//                                    .font(.headline)
//                                Text("Effective Date: \(formattedDate(indicatorData.effectiveDate))")
//                                    .font(.subheadline)
//                                ForEach(indicatorData.points) { point in
//                                    HStack {
//                                        Text("Year: \(point.year)")
//                                        Text("Quarter: \(point.quarter)")
//                                        Text("Value: \(point.value, specifier: "%.2f")")
//                                        Text("Forecast: \(point.forecast ? "Yes" : "No")")
//                                    }
//                                }
//                            }
//                           
//                        }
//                    }
//                }
//            }
//            .navigationTitle("Economic Indicators")
//        }
//    }
//    
//    private func formattedDate(_ date: Date) -> String {
//           let formatter = DateFormatter()
//           formatter.dateStyle = .medium
//           formatter.timeStyle = .none
//           return formatter.string(from: date)
//       }
//}
//
//// MARK: - Preview
//
//struct EconomicIndicatorView_Previews: PreviewProvider {
//    static var previews: some View {
//        EconomicIndicatorView()
//    }
//}
