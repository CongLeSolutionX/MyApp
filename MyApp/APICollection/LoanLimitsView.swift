//
//  LoanLimitsView.swift
//  MyApp
//
//  Created by Cong Le on 3/23/25.
//

import SwiftUI
import Combine

// MARK: - Data Models

struct LoanLimit: Decodable, Identifiable {
    let id = UUID() // Still needed for SwiftUI Lists
    let stateCode: String?
    let countyName: String?
    let reportingYear: Int?
    let cbsaNumber: String?
    let fipsCode: String?
    let issuers: [Issuer]?
    
    // Implement Identifiable
    static func == (lhs: LoanLimit, rhs: LoanLimit) -> Bool { // Still needed for comparison
        return lhs.id == rhs.id
    }
    
    // Optional: Custom CodingKeys if you want to handle different key names
    enum CodingKeys: String, CodingKey {
        case stateCode, countyName, reportingYear, cbsaNumber, fipsCode, issuers
        // No mapping needed if JSON keys *exactly* match property names
    }
}

struct Issuer: Decodable, Identifiable {  // Identifiable is good practice for Lists
    var id = UUID()
    let issuerType: String?
    let oneUnitLimit: Int?
    let twoUnitLimit: Int?
    let threeUnitLimit: Int?
    let fourUnitLimit: Int?
    
    
    static func == (lhs: Issuer, rhs: Issuer) -> Bool {
        return lhs.id == rhs.id
    }
    
}

// MARK: - API Endpoints

enum LoanLimitsAPIEndpoint {
    case all
    case historical(year: String)
    case byCounty(state: String, county: String)
    
    var path: String {
        switch self {
        case .all:
            return "/v1/loan-limits/all"
        case .historical(let year):
            return "/v1/loan-limits/historical/\(year)"
        case .byCounty(let state, let county):
            return "/v1/loan-limits/state/\(state)/county/\(county)"
        }
    }
}

// MARK: - API Errors

enum LoanLimitsAPIError: Error, LocalizedError {
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

struct LoanLimitsAuthCredentials {
    // IMPORTANT: Replace with secure storage in a production app
    static let clientID = "clientIDKeyHere"
    static let clientSecret = "clientSecretKeyHere"
}

struct LoanLimitsAPI_TokenResponse: Decodable {
    let access_token: String
    let token_type: String
    let expires_in: Int
    let scope: String
}

// MARK: - Data Service
final class LoanLimitsService: ObservableObject {
    @Published var loanLimits: [LoanLimit] = []  // Now directly an array of LoanLimit
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let baseURLString = "https://api.fanniemae.com"
    private let tokenURL = "https://auth.pingone.com/4c2b23f9-52b1-4f8f-aa1f-1d477590770c/as/token"
    private var accessToken: String?
    private var tokenExpiration: Date?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Token Management (Corrected - Now uses Future)
    // No changes to getAccessToken function.
    private func getAccessToken() -> Future<String, LoanLimitsAPIError> {
        return Future { promise in
            // Return token if still valid.
            if let token = self.accessToken, let expiration = self.tokenExpiration, Date() < expiration {
                promise(.success(token))
                return
            }
            
            guard let url = URL(string: self.tokenURL) else {
                promise(.failure(.invalidURL))
                return
            }
            
            let credentials = "\(LoanLimitsAuthCredentials.clientID):\(LoanLimitsAuthCredentials.clientSecret)"
            guard let base64Credentials = credentials.data(using: .utf8)?.base64EncodedString() else {
                promise(.failure(.authenticationFailed))
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
                        throw LoanLimitsAPIError.requestFailed("Invalid response. Response: \(responseString)")
                    }
                    return data
                }
                .decode(type: TokenResponse.self, decoder: JSONDecoder())
                .receive(on: DispatchQueue.main)
                .sink { completionResult in
                    switch completionResult {
                    case .finished:
                        break
                    case .failure(let error):
                        let apiError = (error as? LoanLimitsAPIError) ?? LoanLimitsAPIError.unknown(error)
                        self.handleError(apiError)
                        promise(.failure(apiError)) // Fail the Future
                    }
                } receiveValue: { tokenResponse in
                    self.accessToken = tokenResponse.access_token
                    self.tokenExpiration = Date().addingTimeInterval(TimeInterval(tokenResponse.expires_in))
                    promise(.success(tokenResponse.access_token)) // Resolve the Future
                }
                .store(in: &self.cancellables)
        }
    }
    
    // MARK: - Public API Data Fetching (Corrected)
    
    func fetchData(for endpoint: LoanLimitsAPIEndpoint) {
        isLoading = true
        errorMessage = nil
        loanLimits.removeAll() // Clear any previous data.
        
        getAccessToken() // Now returns a Future
            .flatMap { [weak self] token -> AnyPublisher<[LoanLimit], LoanLimitsAPIError> in // Corrected return type
                guard let self = self else {
                    return Fail(error: LoanLimitsAPIError.unknown(NSError(domain: "LoanLimitsService", code: -1, userInfo: nil))).eraseToAnyPublisher()
                }
                return self.makeDataRequest(endpoint: endpoint, accessToken: token) // Pass the token
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completionResult in
                guard let self = self else { return }
                self.isLoading = false
                switch completionResult {
                case .finished:
                    break
                case .failure(let error):
                    self.handleError((error as? LoanLimitsAPIError) ?? LoanLimitsAPIError.unknown(error))
                }
            } receiveValue: { [weak self] loanLimits in
                guard let self = self else { return }
                var uniqueLoanLimits = [LoanLimit]()
                for limit in loanLimits {
                    if !uniqueLoanLimits.contains(where: { $0.id == limit.id }) {
                        uniqueLoanLimits.append(limit)
                    }
                }
                self.loanLimits = uniqueLoanLimits // Update on the main thread.
            }
            .store(in: &cancellables)
    }
    
    private func makeDataRequest(endpoint: LoanLimitsAPIEndpoint, accessToken: String) -> AnyPublisher<[LoanLimit], LoanLimitsAPIError> {
        guard let url = URL(string: baseURLString + endpoint.path) else {
            return Fail(error: .invalidURL).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(accessToken, forHTTPHeaderField: "x-public-access-token")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    let responseString = String(data: data, encoding: .utf8) ?? "No response body"
                    throw LoanLimitsAPIError.requestFailed("HTTP Status Code Error. Response: \(responseString)")
                }
                
                if let responseString = String(data: data, encoding: .utf8) {
                    print("RAW JSON RESPONSE:\n\(responseString)\n")
                }
                return data
            }
            .decode(type: [LoanLimit].self, decoder: JSONDecoder()) // Decode directly into [LoanLimit]
            .mapError { error in
                return (error as? LoanLimitsAPIError) ?? LoanLimitsAPIError.unknown(error)
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Error Handling
    private func handleError(_ error: LoanLimitsAPIError) {
        errorMessage = error.localizedDescription
        print("API Error: \(error.localizedDescription)") // Log for debugging
    }
    
    func clearLocalData() {
        loanLimits.removeAll()
        errorMessage = nil // Clear errors as well
    }
}
// MARK: - SwiftUI Views

struct LoanLimitsView: View {
    @StateObject private var dataService = LoanLimitsService()
    @State private var selectedYear: String = String(Calendar.current.component(.year, from: Date()))
    @State private var selectedState: String = ""
    @State private var selectedCounty: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Data Selection")) {
                    
                    Button("Fetch All Loan Limits") {
                        dataService.fetchData(for: .all)
                    }
                    .buttonStyle(.bordered)
                    
                    HStack {
                        TextField("Year (2009-2019)", text: $selectedYear)
                            .keyboardType(.numberPad)
                        Button("Fetch Historical") {
                            dataService.fetchData(for: .historical(year: selectedYear))
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    HStack {
                        TextField("State (e.g., VA)", text: $selectedState)
                            .textInputAutocapitalization(.characters)
                        TextField("County (e.g., Fairfax)", text: $selectedCounty)
                        Button("Fetch by County") {
                            dataService.fetchData(for: .byCounty(state: selectedState, county: selectedCounty))
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    Button("Clear Data", role: .destructive) {
                        dataService.clearLocalData()
                    }
                }
                
                Section(header: Text("Loan Limits Data")) {
                    if dataService.isLoading {
                        ProgressView("Loading...")
                    } else if let errorMessage = dataService.errorMessage {
                        Text("Error: \(errorMessage)")
                            .foregroundColor(.red)
                    } else {
                        List(dataService.loanLimits, id: \.id) { loanLimit in // Directly use loanLimits
                            VStack(alignment: .leading) {
                                if let state = loanLimit.stateCode{
                                    Text("State: \(state)")
                                }
                                if let county = loanLimit.countyName {
                                    Text("County: \(county)")
                                }
                                
                                if let year = loanLimit.reportingYear{
                                    Text("Year: \(year)")
                                }
                                
                                if let issuers = loanLimit.issuers{
                                    ForEach(issuers) { issuer in // No change to ForEach
                                        if let type = issuer.issuerType {
                                            Text("Issuer Type: \(type)")
                                                .bold()
                                        }
                                        
                                        if let one = issuer.oneUnitLimit{
                                            Text("One Unit Limit: \(one)")
                                        }
                                        if let two = issuer.twoUnitLimit {
                                            Text("Two Unit Limit: \(two)")
                                        }
                                        
                                        if let three = issuer.threeUnitLimit{
                                            Text("Three Unit Limit: \(three)")
                                        }
                                        if let four = issuer.fourUnitLimit{
                                            Text("Four Unit Limit: \(four)")
                                        }
                                        
                                    }
                                }
                                
                            }
                        }
                    }
                }
            }
            .navigationTitle("Loan Limits")
        }
    }
}
// MARK: - Preview

struct LoanLimitsView_Previews: PreviewProvider {
    static var previews: some View {
        LoanLimitsView()
    }
}
