//
//  HousingIndicatorsView.swift
//  MyApp
//
//  Created by Cong Le on 3/22/25.
//

import SwiftUI
import Combine

// MARK: - Data Models

/// Represents a single data point for a housing indicator.
struct HousingDataPoint: Codable {
    let forecast: Bool
    let quarter: String
    let year: Int
    let value: Double
}

/// Represents a time series of data for a specific housing indicator.
struct IndicatorTimeSeries: Codable, Identifiable {
    let id = UUID()
    let effectiveDate: String
    let indicatorName: String
    let points: [HousingDataPoint]
    
    // CodingKeys to match JSON structure, handling "indicator-name"
    enum CodingKeys: String, CodingKey {
        case id // Include id in CodingKeys
        case effectiveDate
        case indicatorName = "indicator-name"
        case points
    }
}

/// Represents the overall response structure, containing multiple indicator time series.
struct HousingIndicatorsReport: Codable {
    let indicators: [IndicatorTimeSeries]
}

// MARK: - API Endpoints

/// Enumeration for API endpoints.  Includes associated values for dynamic path construction.
enum APIEndpoint {
    case byIndicator(String)
    case forYear(Int)
    case forYearAndMonth(year: Int, month: Int)
    case forReportYear(Int)
    case forYearAndQuarter(year: Int, quarter: String)
    
    var path: String {
        switch self {
        case .byIndicator(let indicator):
            return "/v1/housing-indicators/indicators/\(indicator)"
        case .forYear(let year):
            return "/v1/housing-indicators/data/years/\(year)"
        case .forYearAndMonth(let year, let month):
            return "/v1/housing-indicators/reports/years/\(year)/months/\(month)"
        case .forReportYear(let year):
            return "/v1/housing-indicators/reports/years/\(year)"
        case .forYearAndQuarter(let year, let quarter):
            return "/v1/housing-indicators/data/years/\(year)/quarters/\(quarter)"
        }
    }
    
    //List of allowable indicators.
    static let validIndicators = [
        "total-housing-starts",
        "single-family-1-unit-housing-starts",
        "multifamily-2+units-housing-starts",
        "total-home-sales",
        "new-single-family-home-sales",
        "existing-single-family-condos-coops-home-sales",
        "median-new-home-price",
        "median-existing-home-price",
        "federal-housing-finance-agency-purchase-only-house-price-index",
        "30-year-fixed-rate-mortgage",
        "5-year-adjustable-rate-mortgage",
        "single-family-mortgage-originations",
        "single-family-purchase-mortgage-originations",
        "single-family-refinance-mortgage-originations",
        "refinance-share-of-total-single-family-mortgage-originations"
    ]
}

// MARK: - API Errors

/// Enum representing potential API errors, conforming to LocalizedError for user-friendly messages.
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

// MARK: - Authentication (Simplified for this example - See Notes)
// IMPORTANT: In a production app, never hardcode client credentials.
// Use secure storage (Keychain) or environment variables. This is a simplified approach
// for demonstration purposes *only*.  The previous example's complete authentication
// mechanism is reusable here.
struct AuthCredentials {
    static let clientID = "clientIDKeyHere"  // Replace with your actual client ID
    static let clientSecret = "clientSecretKeyHere" // Replace with your actual client secret
}

struct TokenResponse: Decodable {
    let access_token: String
    let token_type: String
    let expires_in: Int
    let scope: String
}

// MARK: - Data Service

final class HousingDataService: ObservableObject {
    @Published var housingData: [IndicatorTimeSeries] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var availableIndicators: [String] = APIEndpoint.validIndicators
    
    private let baseURLString = "https://api.fanniemae.com"
    private let tokenURL = "https://auth.pingone.com/4c2b23f9-52b1-4f8f-aa1f-1d477590770c/as/token" //Use correct URL, do not hardcode
    private var accessToken: String? = nil
    private var tokenExpiration: Date? = nil
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
                    // Downcast to APIError, or wrap as .unknown
                    let apiError = (error as? APIError) ?? APIError.unknown(error)
                    self?.handleError(apiError)  // centralized error handling
                    completion(.failure(apiError)) // Propagate error
                }
            } receiveValue: { [weak self] tokenResponse in
                self?.accessToken = tokenResponse.access_token
                // Calculate and store the token's expiration date.
                self?.tokenExpiration = Date().addingTimeInterval(TimeInterval(tokenResponse.expires_in))
                completion(.success(tokenResponse.access_token))
            }
            .store(in: &cancellables) // Manage the subscription
    }
    
    
    // MARK: - Public API
    func fetchData(for endpoint: APIEndpoint) {
        isLoading = true
        errorMessage = nil
        getAccessToken { [weak self] result in
            guard let self = self else {return}
            
            switch result {
            case .success(let token):
                self.makeDataRequest(endpoint: endpoint, accessToken: token)
            case .failure(let error):
                DispatchQueue.main.async {
                    self.isLoading = false;
                    self.handleError(error)
                }
            }
        }
    }
    
    private func makeDataRequest(endpoint: APIEndpoint, accessToken: String) {
        
        guard let url = URL(string: baseURLString + endpoint.path) else {
            handleError(.invalidURL) // Use centralized error handling
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(accessToken, forHTTPHeaderField: "x-public-access-token")
        
        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    let responseString = String(data: data, encoding: .utf8) ?? "No Response Body" //Provide meaningful string in case of nil.
                    throw APIError.requestFailed("HTTP Status Code error. Response: \(responseString)")
                }
                return data
            }
            .decode(type: HousingIndicatorsReport.self, decoder: createDecoder()) // Use the custom decoder
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    let apiError = (error as? APIError) ?? APIError.unknown(error)
                    self.handleError(apiError)
                }
            } receiveValue: { [weak self] report in
                guard let self = self else {return}
                // Sort by effective date from newest to oldest.
                let sortedIndicators = report.indicators.sorted {
                    guard let date1 = self.dateFormatter.date(from: $0.effectiveDate),
                          let date2 = self.dateFormatter.date(from: $1.effectiveDate) else {
                        return false // If dates can't be parsed, maintain original order.
                    }
                    return date1 > date2
                }
                self.housingData = sortedIndicators
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Date Handling (For Sorting)
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ" // ISO 8601 format
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0) //Or correct timezone
        return formatter
    }()
    
    // MARK: - JSON Decoder Configuration
    private func createDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase // Handles key conversion
        decoder.dateDecodingStrategy = .formatted(dateFormatter) // Use the dateFormatter
        return decoder
    }
    
    // MARK: - Error Handling
    
    private func handleError(_ error: APIError) {
        errorMessage = error.localizedDescription
        print("API Error: \(error.localizedDescription)")  // Log the error
    }
    
    // MARK: - Clear Local Data
    
    ///Clears any existing data
    func clearLocalData() {
        housingData.removeAll()
    }
}

// MARK: - SwiftUI Views

struct ContentView: View {
    @StateObject private var dataService = HousingDataService()
    @State private var selectedIndicator: String = APIEndpoint.validIndicators.first ?? ""
    @State private var selectedYear: Int? = Calendar.current.component(.year, from: Date())
    @State private var selectedQuarter: String = "Q1"
    @State private var selectedMonth: Int? = Calendar.current.component(.month, from: Date())
    
    private let quarters = ["Q1", "Q2", "Q3", "Q4", "EOY"]
    private var availableYears: [Int] {
        let startYear = 2000 // Adjust as needed
        let currentYear = Calendar.current.component(.year, from: Date())
        return Array(startYear...currentYear)
    }
    private var availableMonths: [Int] {
        return Array(1...12)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Data Selection")) {
                    Picker("Indicator", selection: $selectedIndicator) {
                        ForEach(dataService.availableIndicators, id: \.self) { indicator in
                            Text(indicator).tag(indicator)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    
                    Picker("Year", selection: Binding<Int>(
                        get: { self.selectedYear ?? 0 },
                        set: { self.selectedYear = $0 }
                    )) {
                        ForEach(availableYears, id: \.self) { year in
                            Text("\(year)").tag(year)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    
                    Picker("Month", selection: Binding<Int?>(
                        get: { self.selectedMonth },
                        set: { self.selectedMonth = $0 }
                    )) {
                        Text("None").tag(nil as Int?) // Add a "None" option
                        ForEach(availableMonths, id: \.self) { month in
                            Text("\(month)").tag(month as Int?)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .disabled(selectedYear == nil) //Disable if year not selected
                    
                    Picker("Quarter", selection: $selectedQuarter) {
                        ForEach(quarters, id: \.self) { quarter in
                            Text(quarter).tag(quarter)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .disabled(selectedYear == nil)
                    
                    // Buttons with error handling for invalid selections
                    Button("Fetch by Indicator") {
                        dataService.fetchData(for: .byIndicator(selectedIndicator))
                    }
                    .buttonStyle(.bordered)
                    
                    //Validate year before fetching yearly report
                    Button("Fetch by Year") {
                        if let year = selectedYear{
                            dataService.fetchData(for: .forYear(year))
                        } else {
                            dataService.errorMessage = "Please select a year."
                        }
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Fetch by Year and Month") {
                        if let year = selectedYear, let month = selectedMonth {
                            dataService.fetchData(for: .forYearAndMonth(year: year, month: month))
                        } else {
                            dataService.errorMessage = "Please select both year and month."
                        }
                        
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Fetch by Report Year") {
                        if let year = selectedYear {
                            dataService.fetchData(for: .forReportYear(year))
                        } else {
                            dataService.errorMessage = "Please select a report year."
                        }
                        
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Fetch by Year and Quarter") {
                        if let year = selectedYear {
                            dataService.fetchData(for: .forYearAndQuarter(year: year, quarter: selectedQuarter))
                        } else {
                            dataService.errorMessage = "Please select a year."
                        }
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Clear Data", role: .destructive) {
                        dataService.clearLocalData()
                    }
                }
                
                Section(header: Text("Housing Indicators Data")) {
                    if dataService.isLoading {
                        ProgressView("Loading...")
                    } else if let errorMessage = dataService.errorMessage {
                        Text("Error: \(errorMessage)")
                            .foregroundColor(.red)
                    } else {
                        List(dataService.housingData) { indicatorData in
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Indicator: \(indicatorData.indicatorName)")
                                    .font(.headline)
                                Text("Effective Date: \(indicatorData.effectiveDate)")
                                    .font(.subheadline)
                                ForEach(indicatorData.points, id: \.year) { point in
                                    HStack {
                                        Text("Year: \(point.year), \(point.quarter)")
                                        Spacer()
                                        Text("Value: \(point.value, specifier: "%.2f")")
                                        Text(point.forecast ? "(Forecast)" : "(Historical)")
                                            .font(.caption)
                                            .foregroundColor(point.forecast ? .blue : .gray)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Housing Indicators")
        }
    }
}

// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
