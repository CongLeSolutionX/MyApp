//
//  TransferRiskView.swift
//  MyApp
//
//  Created by Cong Le on 3/22/25.
//

import SwiftUI
import Combine

// MARK: - Data Models

/// Represents loan-level data for Credit Insurance Risk Transfer (CIRT) deals.
struct CIRTData: Identifiable, Codable {
    let id = UUID()
    let currentState: String?
    let s3Uri: String?
    let requestId: String?
    let stateEntryTimestamp: String?

    // Initializer from CirtRequestState
    init(from state: CirtRequestState) {
        self.currentState = state.currentState
        self.s3Uri = state.s3Uri
        self.requestId = state.requestId
        self.stateEntryTimestamp = state.stateEntryTimestamp
    }
}

/// Mirrors the API response structure.
struct CirtRequestState: Decodable {
    let currentState: String?
    let s3Uri: String?
    let requestId: String?
    let stateEntryTimestamp: String?

    enum CodingKeys: String, CodingKey {
        case currentState
        case s3Uri = "s3Uri"
        case requestId = "request-id"
        case stateEntryTimestamp = "state-entry-timestamp"
    }
}

// MARK: - API Endpoints

/// Enumerates API endpoints for the service.
enum CIRTApiEndpoint {
    case programToDate
    case currentReportingPeriod

    var path: String {
        switch self {
        case .programToDate:
            return "/v1/credit-insurance-risk-transfer/program-to-date"
        case .currentReportingPeriod:
            return "/v1/credit-insurance-risk-transfer/current-reporting-period"
        }
    }
}

// MARK: - API Errors

/// Defines API errors for common network and decoding issues.
enum CIRTApiError: Error, LocalizedError {
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

/// IMPORTANT: Securely store credentials in production.  This is for example purposes ONLY.
struct CIRTAuthCredentials {
    static let clientID = "clientIDKeyHere"
    static let clientSecret = "clientSecretKeyHere"
}

/// Represents the token response from the authentication API.
struct CIRTTokenResponse: Decodable {
    let access_token: String
    let token_type: String
    let expires_in: Int
    let scope: String
}

// MARK: - Data Service

/// Service for fetching and decoding Credit Insurance Risk Transfer data.
final class CIRTDataService: ObservableObject {
    @Published var cirtData: [CIRTData] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let baseURLString = "https://api.fanniemae.com"
    private let tokenURL = "https://auth.pingone.com/4c2b23f9-52b1-4f8f-aa1f-1d477590770c/as/token" // Same as previous example, confirm if correct
    private var accessToken: String?
    private var tokenExpiration: Date?
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Token Management

   private func getAccessToken(completion: @escaping (Result<String, CIRTApiError>) -> Void) {
        // Return token if still valid.
        if let token = accessToken, let expiration = tokenExpiration, Date() < expiration {
            completion(.success(token))
            return
        }

        guard let url = URL(string: tokenURL) else {
            completion(.failure(.invalidURL))
            return
        }

        let credentials = "\(CIRTAuthCredentials.clientID):\(CIRTAuthCredentials.clientSecret)"
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
                    let responseString = String(data: data, encoding: .utf8) ?? "No Response Body"
                    throw CIRTApiError.requestFailed("Invalid response: \(responseString)")
                }
                return data
            }
            .decode(type: CIRTTokenResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completionResult in
                switch completionResult {
                case .finished:
                    break
                case .failure(let error):
                     let apiError = (error as? CIRTApiError) ?? CIRTApiError.unknown(error)
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
    
    func fetchData(for endpoint: CIRTApiEndpoint) {
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
    
        private func makeDataRequest(endpoint: CIRTApiEndpoint, accessToken: String) {
        guard let url = URL(string: baseURLString + endpoint.path) else {
            handleError(.invalidURL)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(accessToken, forHTTPHeaderField: "x-public-access-token") // Using x-public-access-token

        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                          let responseString = String(data: data, encoding: .utf8) ?? "No Response Body"
                    throw CIRTApiError.requestFailed("HTTP Status Code error.  Response: \(responseString)")
                }
                return data
            }
            .decode(type: CirtRequestState.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completionResult in
                guard let self = self else { return }
                self.isLoading = false
                switch completionResult {
                case .finished:
                    break
                case .failure(let error):
                    self.handleError(error as? CIRTApiError ?? .unknown(error))
                }
            } receiveValue: { [weak self] cirtRequestState in
                guard let self = self else { return }
                // Transform the response into the unified CIRTData model, avoid duplicates
                let newData = CIRTData(from: cirtRequestState)
                if !self.cirtData.contains(where: {$0.s3Uri == newData.s3Uri}) {
                    self.cirtData.append(newData)
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - Error Handling

    private func handleError(_ error: CIRTApiError) {
        errorMessage = error.localizedDescription
        print("API Error: \(error.localizedDescription)")
    }

    /// Clears any locally stored data.
    func clearLocalData() {
        cirtData.removeAll()
    }
}

// MARK: - SwiftUI Views

struct CIRTContentView: View {
    @StateObject private var dataService = CIRTDataService()

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Data Selection")) {
                    Button("Fetch Program-to-Date Data") {
                        dataService.fetchData(for: .programToDate)
                    }
                    .buttonStyle(.bordered)

                    Button("Fetch Current Reporting Period Data") {
                        dataService.fetchData(for: .currentReportingPeriod)
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("Clear Data", role: .destructive) {
                        dataService.clearLocalData()
                    }
                }

                Section(header: Text("CIRT Data")) {
                    if dataService.isLoading {
                        ProgressView("Loading...")
                    } else if let errorMessage = dataService.errorMessage {
                        Text("Error: \(errorMessage)")
                            .foregroundColor(.red)
                    } else {
                        List(dataService.cirtData) { item in
                            VStack(alignment: .leading, spacing: 4) {
                                if let currentState = item.currentState {
                                    Text("Current State: \(currentState)")
                                }
                                if let s3Uri = item.s3Uri {
                                    Text("S3 URI: \(s3Uri)")
                                        .font(.caption)
                                }
                                if let requestId = item.requestId {
                                    Text("Request ID: \(requestId)")
                                }
                                
                                if let timestamp = item.stateEntryTimestamp {
                                    Text("Timestamp: \(timestamp)")
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("CIRT Data")
        }
    }
}

// MARK: - Preview
struct CIRTContentView_Previews: PreviewProvider {
    static var previews: some View {
        CIRTContentView()
    }
}
